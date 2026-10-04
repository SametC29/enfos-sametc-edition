-- Enfos Team Survival — SametC Edition
-- Authoritative Game Setup & Hero Selection Manager
-- Handles team assignment, difficulty selection, countdowns, and hero picking.

require("lib/log")

local EnfosSetupManager = {}
EnfosSetupManager.__index = EnfosSetupManager

EnfosSetupManager.DIFFICULTIES = {
	casual = { name = "CASUAL", hp_mult = 0.75, xp_mult = 0.85, label = "Creature HP x0.75" },
	normal = { name = "NORMAL", hp_mult = 1.00, xp_mult = 1.00, label = "Creature HP x1.00" },
	hard = { name = "HARD", hp_mult = 1.25, xp_mult = 1.15, label = "Creature HP x1.25" },
	nightmare = { name = "NIGHTMARE", hp_mult = 1.50, xp_mult = 1.30, label = "Creature HP x1.50" },
	hell = { name = "HELL", hp_mult = 2.00, xp_mult = 1.50, label = "Creature HP x2.00" },
}

-- One authoritative roster shared with Aghanim and validation.
EnfosSetupManager.HERO_ROSTER = require("heroes/roster")

function EnfosSetupManager:Init(waveManager)
	self.waveManager = waveManager
	self.selectedDifficulty = "normal"
	self.setupRemainingTime = 45.0
	self.heroSelectionRemainingTime = 90.0
	self.isSetupComplete = false
	self.playerPicks = {}
	self.teamPicks = {
		[DOTA_TEAM_GOODGUYS or 2] = {},
		[DOTA_TEAM_BADGUYS or 3] = {},
	}
	self.listenersRegistered = false

	self:RegisterListeners()
	GameRules:GetGameModeEntity():SetContextThink("EnfosSetupState", function()
		local state=GameRules:State_Get()
		if state>DOTA_GAMERULES_STATE_HERO_SELECTION then return nil end
		if state==DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP and not self.isSetupComplete then
			self.setupRemainingTime = math.max(0, self.setupRemainingTime - 1)
			if self.setupRemainingTime <= 0 then
				if self.waveManager and self.waveManager.SetDifficulty then
					self.waveManager:SetDifficulty(self.selectedDifficulty)
				end
				self.isSetupComplete = true
				self:BroadcastSetupState()
				Log:Info("setup_manager", "Setup countdown expired; starting the game with difficulty %s", self.selectedDifficulty)
				if GameRules and GameRules.FinishCustomGameSetup then GameRules:FinishCustomGameSetup() end
				return nil
			end
			self:BroadcastSetupState()
		end
		if state==DOTA_GAMERULES_STATE_HERO_SELECTION then
			self.heroSelectionRemainingTime=GameRules:GetStateTransitionTime()
			self:BroadcastHeroSelectionState()
		end
		return 1
	end,1)
	self:BroadcastSetupState()
	for _,role in ipairs({"Tank","Fighter","Carry","Mage","Support"}) do
		local heroes={}
		for _,hero in ipairs(self.HERO_ROSTER) do if hero.role==role then heroes[#heroes+1]=hero end end
		CustomNetTables:SetTableValue("hero_selection_state","roster_"..role,{heroes=heroes})
	end
	self:BroadcastHeroSelectionState()

	Log:Info("setup_manager", "EnfosSetupManager initialized successfully.")
end

function EnfosSetupManager:RegisterListeners()
	if self.listenersRegistered then return end
	self.listenersRegistered = true

	if CustomGameEventManager and CustomGameEventManager.RegisterListener then
		CustomGameEventManager:RegisterListener("enfos_setup_set_difficulty", function(_, event)
			self:OnSetDifficulty(event)
		end)

		CustomGameEventManager:RegisterListener("enfos_setup_join_team", function(_, event)
			self:OnJoinTeam(event)
		end)

		CustomGameEventManager:RegisterListener("enfos_setup_start_game", function(_, event)
			self:OnStartGame(event)
		end)

		CustomGameEventManager:RegisterListener("enfos_lock_in_hero", function(_, event)
			self:OnLockInHero(event)
		end)
	end
end

function EnfosSetupManager:ValidPlayer(id)
	return type(id)=="number" and id==math.floor(id) and PlayerResource:IsValidPlayerID(id)
end

function EnfosSetupManager:CanChooseTeam(id)
	if not self:ValidPlayer(id) then
		Log:Warn("setup_manager", "Setup action rejected: invalid PlayerID %s", tostring(id))
		return false
	end
	if self.isSetupComplete then
		Log:Warn("setup_manager", "Setup action rejected: setup is already complete (player %d)", id)
		return false
	end
	local state = GameRules:State_Get()
	if state ~= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		Log:Warn("setup_manager", "Setup action rejected: wrong game state %s (player %d)", tostring(state), id)
		return false
	end
	return true
end

-- Team choice is personal; only match configuration requires host privileges.
function EnfosSetupManager:CanConfigure(id)
	if not self:CanChooseTeam(id) then return false end
	if GameRules and GameRules.PlayerHasCustomGameHostPrivileges and PlayerResource and PlayerResource.GetPlayer then
		local player = PlayerResource:GetPlayer(id)
		if not player or not GameRules:PlayerHasCustomGameHostPrivileges(player) then
			Log:Warn("setup_manager", "Setup action rejected: player %d is not the lobby host", id)
			return false
		end
	end
	return true
end

function EnfosSetupManager:OnSetDifficulty(event)
	if not event or not event.difficulty then return end
	local playerId = event.PlayerID
	Log:Info("setup_manager", "Difficulty event received: player=%s difficulty=%s", tostring(playerId), tostring(event.difficulty))
	if not self:CanConfigure(playerId) then return false end
	local diffKey = tostring(event.difficulty):lower()
	if not self.DIFFICULTIES[diffKey] then return end

	self.selectedDifficulty = diffKey
	if self.waveManager and self.waveManager.SetDifficulty then
		self.waveManager:SetDifficulty(diffKey)
	end

	Log:Info("setup_manager", "Player %d updated difficulty to: %s", playerId, diffKey)
	self:BroadcastSetupState()
end

function EnfosSetupManager:OnJoinTeam(event)
	if not event or not event.team then return end
	local playerId = event.PlayerID
	Log:Info("setup_manager", "Team event received: player=%s team=%s", tostring(playerId), tostring(event.team))
	if not self:CanChooseTeam(playerId) then return false end
	local team = tonumber(event.team)
	if team ~= (DOTA_TEAM_GOODGUYS or 2) and team ~= (DOTA_TEAM_BADGUYS or 3) then return end

	local count=0
	for id=0,(DOTA_MAX_TEAM_PLAYERS or 24)-1 do
		if id~=playerId and self:ValidPlayer(id) and PlayerResource:GetTeam(id)==team then count=count+1 end
	end
	if count>=5 then return false end
	if PlayerResource and PlayerResource.SetCustomTeamAssignment then
		PlayerResource:SetCustomTeamAssignment(playerId, team)
	end

	Log:Info("setup_manager", "Player %d joined team %d", playerId, team)
	self:BroadcastSetupState()
end

function EnfosSetupManager:OnStartGame(event)
	local playerId = event and event.PlayerID
	Log:Info("setup_manager", "Start event received: player=%s", tostring(playerId))
	if not self:CanConfigure(playerId) then return false end
	Log:Info("setup_manager", "Start Game requested by player %d", playerId)

	if self.waveManager and self.waveManager.SetDifficulty then
		self.waveManager:SetDifficulty(self.selectedDifficulty)
	end

	self.isSetupComplete = true
	self:BroadcastSetupState()

	if GameRules and GameRules.FinishCustomGameSetup then
		GameRules:FinishCustomGameSetup()
	end
end

function EnfosSetupManager:OnLockInHero(event)
	if not event or not event.hero_name then return end
	local playerId = event.PlayerID
	Log:Info("setup_manager", "Hero request: player=%s phase=%s team=%s hero=%s", tostring(playerId), tostring(GameRules:State_Get()), tostring(self:ValidPlayer(playerId) and PlayerResource:GetTeam(playerId)), tostring(event.hero_name))
	if not self:ValidPlayer(playerId) or GameRules:State_Get() ~= DOTA_GAMERULES_STATE_HERO_SELECTION then
		Log:Warn("setup_manager", "Hero request rejected: invalid player or phase")
		return false
	end
	if self.playerPicks[playerId] then return false end
	local heroName = tostring(event.hero_name)

	-- Verify hero is in roster
	local validHero = false
	for _, h in ipairs(self.HERO_ROSTER) do
		if h.id == heroName then
			validHero = true
			break
		end
	end
	if not validHero then
		Log:Warn("setup_manager", "Invalid hero pick attempted: %s", heroName)
		return
	end

	local team = (PlayerResource and PlayerResource.GetTeam) and PlayerResource:GetTeam(playerId) or (DOTA_TEAM_GOODGUYS or 2)

	if team ~= 2 and team ~= 3 then Log:Warn("setup_manager", "Hero request rejected: player has no playing team") return false end
	-- Check same-team duplicate restriction
	if self.teamPicks[team] and self.teamPicks[team][heroName] then
		Log:Warn("setup_manager", "Same team duplicate hero rejected: %s for team %d", heroName, team)
		return
	end

	-- Lock in
	self.playerPicks[playerId] = heroName
	if not self.teamPicks[team] then self.teamPicks[team] = {} end
	self.teamPicks[team][heroName] = true

	Log:Info("setup_manager", "Player %d [Team %d] locked in hero: %s", playerId, team, heroName)

	-- Assign in engine if possible
	if PlayerResource and PlayerResource.GetPlayer then
		local player = PlayerResource:GetPlayer(playerId)
		if player and player.SetSelectedHero then
			player:SetSelectedHero(heroName)
		end
	end

	self:BroadcastHeroSelectionState()
end

function EnfosSetupManager:BroadcastSetupState()
	local playersData = {}
	for pid=0,(DOTA_MAX_TEAM_PLAYERS or 24)-1 do
		if self:ValidPlayer(pid) then
			playersData[tostring(pid)]={player_id=pid,team=PlayerResource:GetTeam(pid),
				name=PlayerResource.GetPlayerName and PlayerResource:GetPlayerName(pid) or ""}
		end
	end

	local diffInfo = self.DIFFICULTIES[self.selectedDifficulty] or self.DIFFICULTIES.normal
	local stateData = {
		difficulty = self.selectedDifficulty,
		difficulty_name = diffInfo.name,
		hp_multiplier = diffInfo.hp_mult,
		detail_label = diffInfo.label,
		is_setup_complete = self.isSetupComplete,
		remaining_time = math.max(0, math.floor(self.setupRemainingTime)),
		players = playersData,
	}

	if CustomNetTables and CustomNetTables.SetTableValue then
		CustomNetTables:SetTableValue("game_setup", "state", stateData)
	end
end

function EnfosSetupManager:BroadcastHeroSelectionState()
	local picksData = {}
	for pid, h in pairs(self.playerPicks) do
		picksData[tostring(pid)] = h
	end

	local stateData = {
		remaining_time = math.max(0, math.floor(self.heroSelectionRemainingTime)),
		picks = picksData,
	}

	if CustomNetTables and CustomNetTables.SetTableValue then
		CustomNetTables:SetTableValue("hero_selection_state", "state", stateData)
	end
end

return EnfosSetupManager

-- Enfos Team Survival — SametC Edition
-- Evolution Manager (In-match Level 4/7/10/13/16/19 Build Choice Milestones)
-- Server-authoritative build directions per GAME_DESIGN_MASTER.md §15

local Log = require("lib/log")

local EvolutionManager = {
	MILESTONE_LEVELS = { 4, 7, 10, 13, 16, 19 },
	playerStates = {},
	initialized = false,
}

EvolutionManager.MILESTONE_CHOICES = require("evolution/choices")
require("evolution/modifiers")

function EvolutionManager:Init()
	if self.initialized then return end
	self.playerStates = {}

	if CustomGameEventManager then
		CustomGameEventManager:RegisterListener("enfos_select_evolution", function(_, event)
			self:OnClientSelectEvolution(event)
		end)
		CustomGameEventManager:RegisterListener("enfos_defer_evolution", function(_, event)
			self:OnClientDeferEvolution(event)
		end)
	end

	if ListenToGameEvent then
		ListenToGameEvent("dota_player_gained_level", function(event)
			self:OnLevelGainedEvent(event)
		end, nil)
	end

	self.initialized = true
	Log:Info("evolution_manager", "EvolutionManager initialized successfully.")
end

function EvolutionManager:GetOrCreatePlayerState(playerId)
	if not self.playerStates[playerId] then
		self.playerStates[playerId] = {
			pendingQueue = {},      -- list of milestone levels [4, 7, ...]
			chosenHistory = {},     -- map: milestoneLevel -> choiceId
			isModalOpen = false,
            deferred = false,
		}
	end
	return self.playerStates[playerId]
end

function EvolutionManager:OnLevelGainedEvent(event)
	if not event then return end
	local playerId = event.player_id or event.PlayerID
	local level = event.level
	if playerId and level then
		local hero = PlayerResource and PlayerResource:GetSelectedHeroEntity(playerId)
		self:CheckHeroMilestones(playerId, hero, level)
	end
end

function EvolutionManager:CheckHeroMilestones(playerId, hero, newLevel)
	local state = self:GetOrCreatePlayerState(playerId)

	for _, mLevel in ipairs(self.MILESTONE_LEVELS) do
		if newLevel >= mLevel then
			local alreadyChosen = state.chosenHistory[mLevel] ~= nil
			local alreadyQueued = false
			for _, q in ipairs(state.pendingQueue) do
				if q == mLevel then
					alreadyQueued = true
					break
				end
			end

			if not alreadyChosen and not alreadyQueued then
				table.insert(state.pendingQueue, mLevel)
                state.deferred = false
				Log:Info("evolution_manager", "Queued milestone level %d for player %s (Queue size: %d)",
					mLevel, tostring(playerId), #state.pendingQueue)
			end
		end
	end

	self:SyncNetTable(playerId)
end

function EvolutionManager:OnClientSelectEvolution(event)
	if not event then return end
	local playerId = event.PlayerID
	local milestoneLevel = tonumber(event.milestone_level)
	local choiceId = event.choice_id

	if playerId ~= nil and milestoneLevel and choiceId then
		self:SelectChoice(playerId, milestoneLevel, choiceId)
	end
end

function EvolutionManager:OnClientDeferEvolution(event)
	if not event then return end
	local playerId = event.PlayerID
	if playerId ~= nil then
		local state = self:GetOrCreatePlayerState(playerId)
		state.isModalOpen = false
        state.deferred = true
		self:SyncNetTable(playerId)
	end
end

function EvolutionManager:SelectChoice(playerId, milestoneLevel, choiceId)
	local state = self:GetOrCreatePlayerState(playerId)

	-- Verify milestone is currently pending
	local foundIndex = nil
	for idx, qLevel in ipairs(state.pendingQueue) do
		if qLevel == milestoneLevel then
			foundIndex = idx
			break
		end
	end

	if not foundIndex then
		Log:Warn("evolution_manager", "Player %s attempted to select non-pending milestone %d",
			tostring(playerId), milestoneLevel)
		return false
	end

	-- Verify choice is valid for this milestone
	local validChoices = self.MILESTONE_CHOICES[milestoneLevel]
	if not validChoices then return false end

	local validChoice = nil
	for _, c in ipairs(validChoices) do
		if c.id == choiceId then
			validChoice = c
			break
		end
	end

	if not validChoice then
		Log:Warn("evolution_manager", "Invalid choice ID %s for milestone %d", tostring(choiceId), milestoneLevel)
		return false
	end

	-- Apply first: failed modifier creation must not consume a choice.
	local hero = PlayerResource and PlayerResource:GetSelectedHeroEntity(playerId)
	if not self:ApplyChoiceBonus(hero, validChoice) then return false end

	-- Dequeue and record
	table.remove(state.pendingQueue, foundIndex)
	state.chosenHistory[milestoneLevel] = choiceId
    state.deferred = false


	Log:Info("evolution_manager", "Player %s selected %s for milestone %d (Remaining queue: %d)",
		tostring(playerId), choiceId, milestoneLevel, #state.pendingQueue)

	self:SyncNetTable(playerId)
	return true
end

function EvolutionManager:ApplyChoiceBonus(hero, choice)
    if not hero or (hero.IsNull and hero:IsNull()) then return false end
    local name="modifier_enfos_evolution_"..choice.id
    if hero.HasModifier and hero:HasModifier(name) then return true end
    return hero:AddNewModifier(hero,nil,name,{}) ~= nil
end

function EvolutionManager:RestoreHero(playerId, hero)
    local state=self.playerStates[playerId]
    if not state then return end
    for level,id in pairs(state.chosenHistory) do
        for _,choice in ipairs(self.MILESTONE_CHOICES[tonumber(level)] or {}) do
            if choice.id==id then self:ApplyChoiceBonus(hero,choice) end
        end
    end
    self:SyncNetTable(playerId)
end

function EvolutionManager:SyncNetTable(playerId)
	if not CustomNetTables then return end

	local state = self:GetOrCreatePlayerState(playerId)
	local nextMilestone = state.pendingQueue[1]
	local activeChoices = nextMilestone and self.MILESTONE_CHOICES[nextMilestone] or nil

	local payload = {
		pending_count = #state.pendingQueue,
        deferred = state.deferred and 1 or 0,
		next_milestone = nextMilestone or 0,
		active_choices = activeChoices or {},
		chosen_history = state.chosenHistory,
	}

	CustomNetTables:SetTableValue("evolution_state", tostring(playerId), payload)
end

function EvolutionManager:GetPendingCount(playerId)
	local state = self:GetOrCreatePlayerState(playerId)
	return #state.pendingQueue
end

function EvolutionManager:GetChosenChoices(playerId)
	local state = self:GetOrCreatePlayerState(playerId)
	return state.chosenHistory
end

function EvolutionManager:IsMilestoneChosen(playerId, milestoneLevel)
	local state = self:GetOrCreatePlayerState(playerId)
	return state.chosenHistory[milestoneLevel] ~= nil
end

return EvolutionManager

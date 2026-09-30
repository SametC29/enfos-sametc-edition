-- Enfos Team Survival — SametC Edition
-- Evolution Manager (native Dota talent choices at levels 10/15/20/25)
-- Server-authoritative build directions per GAME_DESIGN_MASTER.md §15

local Log = require("lib/log")
local HeroTrees = require("evolution/hero_trees")

local EvolutionManager = {
	MILESTONE_LEVELS = { 10, 15, 20, 25 },
	playerStates = {},
	initialized = false,
}

local function choiceLevel(choice)
	return EvolutionManager.MILESTONE_LEVELS[(choice and choice.tier or -1)+1]
end


function EvolutionManager:Init()
	if self.initialized then return end
	self.playerStates = {}

	if ListenToGameEvent then
		ListenToGameEvent("dota_player_gained_level", function(event)
			self:OnLevelGainedEvent(event)
		end, nil)
		ListenToGameEvent("dota_player_learned_ability", function(event)
			self:OnNativeTalentLearned(event)
		end, nil)
	end

	self.initialized = true
	Log:Info("evolution_manager", "EvolutionManager initialized successfully.")
end

function EvolutionManager:GetOrCreatePlayerState(playerId)
	if not self.playerStates[playerId] then
		self.playerStates[playerId] = {
			pendingQueue = {},      -- native talent levels awaiting a choice [10, 15, 20, 25]
			chosenHistory = {},     -- map: milestoneLevel -> choiceId
			grantedTalentPoints = {}, -- one additional point at each native talent level
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
		self:GrantTalentPoints(playerId,hero,level)
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
				Log:Info("evolution_manager", "Queued milestone level %d for player %s (Queue size: %d)",
					mLevel, tostring(playerId), #state.pendingQueue)
			end
		end
	end

	self:SyncNetTable(playerId)
end

function EvolutionManager:OnNativeTalentLearned(event)
	if not event then return false end
	local playerId=event.PlayerID or event.player_id
	local talent=event.abilityname or event.ability_name
	if playerId==nil then return false end
	if not talent then return false end
	local choice=HeroTrees:GetTalentChoice(talent)
	if not choice then return false end
	local hero=PlayerResource and PlayerResource:GetSelectedHeroEntity(playerId)
	local level=choiceLevel(choice)
	if not hero or hero:IsNull() or hero:GetUnitName()~=choice.hero or hero:GetLevel()<level then return false end
	self:CheckHeroMilestones(playerId,hero,hero:GetLevel())
	return self:SelectChoice(playerId,level,choice.id)
end

-- Native talent choices spend normal Dota ability points. Add one point at
-- each talent gate so four talent picks fit alongside all 49 paid skill ranks
-- (the fifth Enfos passive starts at rank one for free).
function EvolutionManager:GrantTalentPoints(playerId,hero,newLevel)
	if not hero or hero:IsNull() or not hero.GetAbilityPoints or not hero.SetAbilityPoints then return 0 end
	newLevel=tonumber(newLevel) or (hero.GetLevel and hero:GetLevel()) or 0
	local state=self:GetOrCreatePlayerState(playerId)
	local granted=0
	for _,level in ipairs(self.MILESTONE_LEVELS) do
		if newLevel>=level and not state.grantedTalentPoints[level] then
			hero:SetAbilityPoints(hero:GetAbilityPoints()+1)
			state.grantedTalentPoints[level]=true
			granted=granted+1
			Log:Info("evolution_manager", "Granted the level-%d native talent point to player %s",level,tostring(playerId))
		end
	end
	return granted
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
	local hero = PlayerResource and PlayerResource:GetSelectedHeroEntity(playerId)
    if hero and hero.GetLevel and hero:GetLevel()<milestoneLevel then return false end
    local validChoices = HeroTrees:GetChoices(hero,milestoneLevel)
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
	if not self:ApplyChoiceBonus(hero, validChoice) then return false end

	-- Dequeue and record
	table.remove(state.pendingQueue, foundIndex)
	state.chosenHistory[milestoneLevel] = choiceId


	Log:Info("evolution_manager", "Player %s selected %s for milestone %d (Remaining queue: %d)",
		tostring(playerId), choiceId, milestoneLevel, #state.pendingQueue)

	self:SyncNetTable(playerId)
	return true
end

function EvolutionManager:ApplyChoiceBonus(hero, choice)
    if not hero or (hero.IsNull and hero:IsNull()) then return false end
    return HeroTrees:Apply(hero,choice)
end

function EvolutionManager:RestoreHero(playerId, hero)
    if not hero or (hero.IsNull and hero:IsNull()) then return false end
    local state=self:GetOrCreatePlayerState(playerId)
    for _,choice in ipairs(HeroTrees:GetAllChoices(hero)) do
        local talent=hero:FindAbilityByName(choice.talent)
        if talent and talent:GetLevel()>0 then
            self:ApplyChoiceBonus(hero,choice)
            state.chosenHistory[choiceLevel(choice)]=choice.id
        end
    end
    if hero and hero.GetLevel then
        -- Ability points persist with the hero across restore/reconnect. Rebuild
        -- these guards before granting so a fresh manager state cannot award
        -- already-earned level-gate points a second time.
        for _,level in ipairs(self.MILESTONE_LEVELS) do
            if hero:GetLevel()>=level then state.grantedTalentPoints[level]=true end
        end
        self:GrantTalentPoints(playerId,hero,hero:GetLevel())
        self:CheckHeroMilestones(playerId,hero,hero:GetLevel())
    end
    self:SyncNetTable(playerId)
    return true
end

function EvolutionManager:SyncNetTable(playerId)
	if not CustomNetTables then return end

	local state = self:GetOrCreatePlayerState(playerId)
	local nextMilestone = state.pendingQueue[1]
	local hero=PlayerResource and PlayerResource:GetSelectedHeroEntity(playerId)
    local activeChoices = nextMilestone and HeroTrees:GetChoices(hero,nextMilestone) or nil

	local payload = {
		hero_level = hero and hero.GetLevel and hero:GetLevel() or 0,
        tree = hero and hero.GetUnitName and HeroTrees.choices[hero:GetUnitName()] or {},
        pending_count = #state.pendingQueue,
		deferred = 0,
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

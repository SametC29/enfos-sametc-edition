-- Enfos Team Survival — SametC Edition
-- Evolution Manager (In-match Level 4/7/10/13/16/19 Build Choice Milestones)
-- Server-authoritative build directions per GAME_DESIGN_MASTER.md §15

local Log = require("lib/log")

local EvolutionManager = {
	MILESTONE_LEVELS = { 4, 7, 10, 13, 16, 19 },
	playerStates = {},
	initialized = false,
}

EvolutionManager.MILESTONE_CHOICES = {
	[4] = {
		{
			id = "evo_wave_clear",
			title = "Dalga Biçici",
			title_en = "Wave Sweeper",
			desc = "+%25 AoE Yetenek Hasarı ve Normal Saldırılarda %40 Alan Yarma (Cleave).",
			desc_en = "+25% AoE Spell Damage and 40% Cleave on basic attacks.",
			icon = "axe_counter_helix",
			bonus_damage_pct = 25,
			cleave_pct = 40,
		},
		{
			id = "evo_boss_slayer",
			title = "Dev Katili",
			title_en = "Giant Slayer",
			desc = "Boss ve Seçkin yaratıklara karşı +%35 hasar ve 5 Zırh Delme.",
			desc_en = "+35% Damage vs Bosses & Elites, and 5 Armor Penetration.",
			icon = "sniper_assassinate",
			boss_damage_pct = 35,
			armor_pierce = 5,
		},
	},
	[7] = {
		{
			id = "evo_spell_surge",
			title = "Büyü Taşkını",
			title_en = "Spell Surge",
			desc = "+%20 Büyü Can Çalması ve Yetenek Bekleme Sürelerinde -%15 İndirim.",
			desc_en = "+20% Spell Lifesteal and -15% Cooldown Reduction.",
			icon = "lina_fiery_soul",
			spell_lifesteal = 20,
			cdr_pct = 15,
		},
		{
			id = "evo_battle_fury",
			title = "Savaş Gazabı",
			title_en = "Battle Ferocity",
			desc = "+45 Saldırı Hızı, +20 Hareket Hızı ve %15 Şansla 2x Kritik Darbe.",
			desc_en = "+45 Attack Speed, +20 Movement Speed, and 15% chance for 2x Critical Strike.",
			icon = "juggernaut_blade_dance",
			bonus_as = 45,
			bonus_ms = 20,
			crit_chance = 15,
		},
	},
	[10] = {
		{
			id = "evo_iron_bulwark",
			title = "Demir Muhafız",
			title_en = "Iron Bulwark",
			desc = "+750 Azami Can, +10 Zırh ve saniyede +20 Can Yenilenmesi.",
			desc_en = "+750 Max HP, +10 Armor, and +20 HP Regen per second.",
			icon = "sven_warcry",
			bonus_hp = 750,
			bonus_armor = 10,
			bonus_hp_regen = 20,
		},
		{
			id = "evo_arcane_flow",
			title = "Ark Akışı",
			title_en = "Arcane Conduit",
			desc = "+500 Azami Mana, +8 Mana Yenilenmesi ve +%15 Büyü Gücü Artışı.",
			desc_en = "+500 Max Mana, +8 Mana Regen, and +15% Spell Amplification.",
			icon = "crystal_maiden_brilliance_aura",
			bonus_mana = 500,
			bonus_mana_regen = 8,
			spell_amp = 15,
		},
	},
	[13] = {
		{
			id = "evo_destructive_force",
			title = "Yıkıcı Güç",
			title_en = "Ruinous Might",
			desc = "Saldırılar ve büyüler %25 şansla etrafındaki yaratıklara 400 hasarlık elemental şok yayar.",
			desc_en = "Attacks and spells have 25% chance to release a 400 damage elemental shockwave.",
			icon = "zuus_lightning_bolt",
			proc_chance = 25,
			proc_damage = 400,
		},
		{
			id = "evo_titan_carapace",
			title = "Titan Zırhı",
			title_en = "Colossus Shell",
			desc = "Gelen tüm hasarları %20 azaltır ve +%25 Statü Direnci sağlar.",
			desc_en = "Reduces all incoming damage by 20% and grants +25% Status Resistance.",
			icon = "centaur_return",
			damage_reduction = 20,
			status_res = 25,
		},
	},
	[16] = {
		{
			id = "evo_immortal_will",
			title = "Ölümsüz İrade",
			title_en = "Immortal Aegis",
			desc = "Can %25'in altına düştüğünde anında 4 saniye %80 hasar koruması ve hız kazanır (60s CD).",
			desc_en = "When HP drops below 25%, gain 80% damage protection and speed for 4s (60s CD).",
			icon = "omniknight_guardian_angel",
			threshold = 25,
			shield_duration = 4.0,
		},
		{
			id = "evo_overwhelming_burst",
			title = "Ezici Baskın",
			title_en = "Overwhelming Burst",
			desc = "Her 5 yetenek veya saldırıda 3 saniye boyunca tüm yetenek bekleme süreleri yarıya iner.",
			desc_en = "Every 5 casts or attacks, halve all ability cooldowns for 3 seconds.",
			icon = "storm_spirit_ball_lightning",
			trigger_count = 5,
		},
	},
	[19] = {
		{
			id = "evo_transcendence",
			title = "Aşkın Zirve",
			title_en = "Transcendent Avatar",
			desc = "Tüm temel özellikler +35 artar ve nihai yeteneğin bekleme süresi -%30 kısalır.",
			desc_en = "+35 All Attributes and -30% Ultimate Cooldown.",
			icon = "invoker_invoke",
			all_stats = 35,
			ult_cdr = 30,
		},
		{
			id = "evo_cataclysm_echo",
			title = "Kıyamet Yankısı",
			title_en = "Doom Cataclysm",
			desc = "Öldürülen her düşman yaratık, azami canının %25'i kadar çevresine alan hasarı patlatır.",
			desc_en = "Slain creeps explode dealing 25% of their max HP to nearby enemies.",
			icon = "nevermore_requiem",
			explosion_pct = 25,
		},
	},
}

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

	-- Dequeue and record
	table.remove(state.pendingQueue, foundIndex)
	state.chosenHistory[milestoneLevel] = choiceId

	-- Apply bonus to hero entity
	local hero = PlayerResource and PlayerResource:GetSelectedHeroEntity(playerId)
	self:ApplyChoiceBonus(hero, validChoice)

	Log:Info("evolution_manager", "Player %s selected %s for milestone %d (Remaining queue: %d)",
		tostring(playerId), choiceId, milestoneLevel, #state.pendingQueue)

	self:SyncNetTable(playerId)
	return true
end

function EvolutionManager:ApplyChoiceBonus(hero, choice)
	if not hero or (hero.IsNull and hero:IsNull()) then return end

	-- Authoritative stat buffs
	if choice.bonus_hp and hero.SetMaxHealth and hero.GetMaxHealth then
		hero:SetMaxHealth(hero:GetMaxHealth() + choice.bonus_hp)
		hero:SetHealth(hero:GetHealth() + choice.bonus_hp)
	end
	if choice.bonus_mana and hero.SetMaxMana and hero.GetMaxMana then
		hero:SetMaxMana(hero:GetMaxMana() + choice.bonus_mana)
	end
	if choice.all_stats and hero.ModifyStrength and hero.ModifyAgility and hero.ModifyIntellect then
		hero:ModifyStrength(choice.all_stats)
		hero:ModifyAgility(choice.all_stats)
		hero:ModifyIntellect(choice.all_stats)
	end

	-- Apply custom modifier tag so hero reflects build evolution
	if hero.AddNewModifier then
		pcall(function()
			hero:AddNewModifier(hero, nil, "modifier_enfos_evolution_" .. choice.id, {})
		end)
	end
end

function EvolutionManager:SyncNetTable(playerId)
	if not CustomNetTables then return end

	local state = self:GetOrCreatePlayerState(playerId)
	local nextMilestone = state.pendingQueue[1]
	local activeChoices = nextMilestone and self.MILESTONE_CHOICES[nextMilestone] or nil

	local payload = {
		pending_count = #state.pendingQueue,
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

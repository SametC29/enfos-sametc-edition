-- Enfos Team Survival — SametC Edition
-- Authoritative Game Setup & Hero Selection Manager
-- Handles team assignment, difficulty selection, countdowns, and hero picking.

require("lib/log")
local ProgressionCurves = require("progression/progression_curves")

local EnfosSetupManager = {}
EnfosSetupManager.__index = EnfosSetupManager

EnfosSetupManager.DIFFICULTIES = {
	casual = { name = "CASUAL", hp_mult = 0.85, xp_mult = 0.85, label = "Creature HP x0.85" },
	normal = { name = "NORMAL", hp_mult = 1.00, xp_mult = 1.00, label = "Creature HP x1.00" },
	hard = { name = "HARD", hp_mult = 1.25, xp_mult = 1.15, label = "Creature HP x1.25" },
	nightmare = { name = "NIGHTMARE", hp_mult = 1.50, xp_mult = 1.30, label = "Creature HP x1.50" },
	hell = { name = "HELL", hp_mult = 2.00, xp_mult = 1.50, label = "Creature HP x2.00" },
}

-- 20 Hero Roster definitions for selection screen
EnfosSetupManager.HERO_ROSTER = {
	-- Tank
	{ id = "npc_dota_hero_sven", name = "Sven", role = "Tank", primary = "DOTA_ATTRIBUTE_STRENGTH",
	  abilities = { "bulwark_shield_slam", "bulwark_challenge", "bulwark_iron_guard", "bulwark_fortress", "bulwark_unbreakable" } },
	{ id = "npc_dota_hero_axe", name = "Axe", role = "Tank", primary = "DOTA_ATTRIBUTE_STRENGTH",
	  abilities = { "enfos_axe_berserkers_call", "enfos_axe_battle_hunger", "enfos_axe_counter_helix", "enfos_axe_culling_blade", "enfos_axe_blood_armor" } },
	{ id = "npc_dota_hero_centaur", name = "Centaur Warrunner", role = "Tank", primary = "DOTA_ATTRIBUTE_STRENGTH",
	  abilities = { "enfos_centaur_hoof_stomp", "enfos_centaur_double_edge", "enfos_centaur_return", "enfos_centaur_stampede", "enfos_centaur_colossal_hide" } },
	{ id = "npc_dota_hero_bristleback", name = "Bristleback", role = "Tank", primary = "DOTA_ATTRIBUTE_STRENGTH",
	  abilities = { "enfos_bb_viscous_nasal_goo", "enfos_bb_quill_spray", "enfos_bb_bristleback", "enfos_bb_warpath", "enfos_bb_hairball" } },

	-- Fighter
	{ id = "npc_dota_hero_juggernaut", name = "Juggernaut", role = "Fighter", primary = "DOTA_ATTRIBUTE_AGILITY",
	  abilities = { "enfos_juggernaut_blade_fury", "enfos_juggernaut_healing_ward", "enfos_juggernaut_blade_dance", "enfos_juggernaut_omni_slash", "enfos_juggernaut_duelist" } },
	{ id = "npc_dota_hero_legion_commander", name = "Legion Commander", role = "Fighter", primary = "DOTA_ATTRIBUTE_STRENGTH",
	  abilities = { "enfos_legion_overwhelming_odds", "enfos_legion_press_the_attack", "enfos_legion_moment_of_courage", "enfos_legion_duel", "enfos_legion_commanders_banner" } },
	{ id = "npc_dota_hero_skeleton_king", name = "Wraith King", role = "Fighter", primary = "DOTA_ATTRIBUTE_STRENGTH",
	  abilities = { "enfos_wk_wraithfire_blast", "enfos_wk_vampiric_aura", "enfos_wk_mortal_strike", "enfos_wk_reincarnation", "enfos_wk_skeleton_army" } },
	{ id = "npc_dota_hero_slark", name = "Slark", role = "Fighter", primary = "DOTA_ATTRIBUTE_AGILITY",
	  abilities = { "enfos_slark_dark_pact", "enfos_slark_pounce", "enfos_slark_essence_shift", "enfos_slark_shadow_dance", "enfos_slark_fish_bait" } },

	-- Carry
	{ id = "npc_dota_hero_drow_ranger", name = "Drow Ranger", role = "Carry", primary = "DOTA_ATTRIBUTE_AGILITY",
	  abilities = { "enfos_drow_frost_arrows", "enfos_drow_gust", "enfos_drow_multishot", "enfos_drow_marksmanship", "enfos_drow_precision_aura" } },
	{ id = "npc_dota_hero_sniper", name = "Sniper", role = "Carry", primary = "DOTA_ATTRIBUTE_AGILITY",
	  abilities = { "enfos_sniper_shrapnel", "enfos_sniper_headshot", "enfos_sniper_take_aim", "enfos_sniper_assassinate", "enfos_sniper_keen_eye" } },
	{ id = "npc_dota_hero_phantom_assassin", name = "Phantom Assassin", role = "Carry", primary = "DOTA_ATTRIBUTE_AGILITY",
	  abilities = { "enfos_pa_stifling_dagger", "enfos_pa_phantom_strike", "enfos_pa_blur", "enfos_pa_coup_de_grace", "enfos_pa_fan_of_knives" } },
	{ id = "npc_dota_hero_luna", name = "Luna", role = "Carry", primary = "DOTA_ATTRIBUTE_AGILITY",
	  abilities = { "enfos_luna_lucent_beam", "enfos_luna_moon_glaives", "enfos_luna_lunar_blessing", "enfos_luna_eclipse", "enfos_luna_lunar_orbit" } },

	-- Mage
	{ id = "npc_dota_hero_lina", name = "Lina", role = "Mage", primary = "DOTA_ATTRIBUTE_INTELLECT",
	  abilities = { "enfos_lina_dragon_slave", "enfos_lina_light_strike_array", "enfos_lina_fiery_soul", "enfos_lina_laguna_blade", "enfos_lina_combustion" } },
	{ id = "npc_dota_hero_crystal_maiden", name = "Crystal Maiden", role = "Mage", primary = "DOTA_ATTRIBUTE_INTELLECT",
	  abilities = { "enfos_cm_crystal_nova", "enfos_cm_frostbite", "enfos_cm_arcane_aura", "enfos_cm_freezing_field", "enfos_cm_glacial_mastery" } },
	{ id = "npc_dota_hero_zuus", name = "Zeus", role = "Mage", primary = "DOTA_ATTRIBUTE_INTELLECT",
	  abilities = { "enfos_zeus_arc_lightning", "enfos_zeus_lightning_bolt", "enfos_zeus_static_field", "enfos_zeus_thundergods_wrath", "enfos_zeus_heavenly_jump" } },
	{ id = "npc_dota_hero_nevermore", name = "Shadow Fiend", role = "Mage", primary = "DOTA_ATTRIBUTE_INTELLECT",
	  abilities = { "enfos_sf_shadowraze", "enfos_sf_necromastery", "enfos_sf_presence_of_the_dark_lord", "enfos_sf_requiem_of_souls", "enfos_sf_feast_of_souls" } },

	-- Support
	{ id = "npc_dota_hero_omniknight", name = "Omniknight", role = "Support", primary = "DOTA_ATTRIBUTE_STRENGTH",
	  abilities = { "enfos_omni_purification", "enfos_omni_repel", "enfos_omni_degen_aura", "enfos_omni_guardian_angel", "enfos_omni_hammer_of_purity" } },
	{ id = "npc_dota_hero_dazzle", name = "Dazzle", role = "Support", primary = "DOTA_ATTRIBUTE_INTELLECT",
	  abilities = { "enfos_dazzle_poison_touch", "enfos_dazzle_shallow_grave", "enfos_dazzle_shadow_wave", "enfos_dazzle_bad_juju", "enfos_dazzle_nothl_weave" } },
	{ id = "npc_dota_hero_witch_doctor", name = "Witch Doctor", role = "Support", primary = "DOTA_ATTRIBUTE_INTELLECT",
	  abilities = { "enfos_wd_paralyzing_cask", "enfos_wd_voodoo_restoration", "enfos_wd_maledict", "enfos_wd_death_ward", "enfos_wd_voodoo_switcheroo" } },
	{ id = "npc_dota_hero_shadow_shaman", name = "Shadow Shaman", role = "Support", primary = "DOTA_ATTRIBUTE_INTELLECT",
	  abilities = { "enfos_ss_ether_shock", "enfos_ss_hex", "enfos_ss_shackles", "enfos_ss_mass_serpent_ward", "enfos_ss_fowl_play" } },
}

function EnfosSetupManager:Init(waveManager, progressionManager)
	self.waveManager = waveManager
	self.progressionManager = progressionManager
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
	self:BroadcastSetupState()
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

function EnfosSetupManager:OnSetDifficulty(event)
	if not event or not event.difficulty then return end
	local playerId = event.PlayerID or 0
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
	local playerId = event.PlayerID or 0
	local team = tonumber(event.team)
	if team ~= (DOTA_TEAM_GOODGUYS or 2) and team ~= (DOTA_TEAM_BADGUYS or 3) then return end

	if PlayerResource and PlayerResource.SetCustomTeamAssignment then
		PlayerResource:SetCustomTeamAssignment(playerId, team)
	end

	Log:Info("setup_manager", "Player %d joined team %d", playerId, team)
	self:BroadcastSetupState()
end

function EnfosSetupManager:OnStartGame(event)
	local playerId = event and event.PlayerID or 0
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
	local playerId = event.PlayerID or 0
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
	if PlayerResource and PlayerResource.GetPlayerCount then
		local count = PlayerResource:GetPlayerCount()
		if count == 0 then count = 1 end
		for pid = 0, count - 1 do
			local team = (PlayerResource.GetTeam and PlayerResource:GetTeam(pid)) or (DOTA_TEAM_GOODGUYS or 2)
			local name = (PlayerResource.GetPlayerName and PlayerResource:GetPlayerName(pid)) or ("Player " .. pid)
			if name == "" then name = "Player " .. pid end
			playersData[tostring(pid)] = {
				player_id = pid,
				team = team,
				name = name,
			}
		end
	else
		playersData["0"] = { player_id = 0, team = 2, name = "Player 1" }
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
		roster = self.HERO_ROSTER,
	}

	if CustomNetTables and CustomNetTables.SetTableValue then
		CustomNetTables:SetTableValue("hero_selection_state", "state", stateData)
	end
end

return EnfosSetupManager

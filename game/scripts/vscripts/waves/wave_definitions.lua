--------------------------------------------------------------------------------
-- wave_definitions.lua
-- Data-driven wave configuration for 60 authored waves
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 3, 5, 8, 9, 10
--------------------------------------------------------------------------------

local WaveDefinitions = {}

WaveDefinitions.TOTAL_WAVES = 60
WaveDefinitions.STARTING_LIFE = 100

-- Creep leak penalties
WaveDefinitions.LEAK_PENALTIES = {
	normal = 1,
	boss = 5,
	summon = 0,
}

-- Unit leak classification map
local UNIT_LEAK_TYPES = {
	-- Normal creeps (-1)
	["enfos_creep_soldier"] = "normal",
	["enfos_creep_archer"] = "normal",
	["enfos_creep_runner"] = "normal",
	["enfos_creep_frostguard"] = "normal",
	["enfos_creep_venomous"] = "normal",
	["enfos_creep_healer"] = "normal",
	["enfos_creep_shieldbearer"] = "normal",
	["enfos_creep_mindstealer"] = "normal",
	["enfos_creep_skyraker"] = "normal",
	["enfos_creep_silencer"] = "normal",
	["enfos_creep_conqueror"] = "normal",
	["enfos_creep_assassin"] = "normal",
	["enfos_creep_summoner"] = "normal",
	["enfos_creep_spellguard"] = "normal",
	["enfos_creep_reflector"] = "normal",
	["enfos_creep_exploder"] = "normal",
	["enfos_creep_splitter"] = "normal",
	["enfos_creep_bloodbeast"] = "normal",
	["enfos_creep_cursecaster"] = "normal",

	-- Bosses (-5)
	["enfos_boss_stonebreaker"] = "boss",
	["enfos_boss_brood_matron"] = "boss",
	["enfos_boss_bloodfang_alpha"] = "boss",
	["enfos_boss_frost_warden"] = "boss",
	["enfos_boss_mind_devourer"] = "boss",
	["enfos_boss_iron_colossus"] = "boss",
	["enfos_boss_gravecaller"] = "boss",
	["enfos_boss_storm_tyrant"] = "boss",
	["enfos_boss_shadow_huntress"] = "boss",
	["enfos_boss_plague_behemoth"] = "boss",
	["enfos_boss_rift_lord"] = "boss",
	["enfos_boss_ascendant_gatekeeper"] = "boss",

	-- Temporary summons (0)
	["enfos_creep_spiderling"] = "summon",
	["enfos_creep_skeleton"] = "summon",
	["enfos_creep_minion"] = "summon",
	["enfos_spellbringer_war_standard"] = "summon",
	["enfos_spellbringer_thorn_idol"] = "summon",
	["enfos_spellbringer_void_stalker"] = "summon",
	["enfos_spellbringer_reinforcement"] = "summon",
}

-- Authoritative wave table (1..60)
local WAVES = {
	-- =========================================================================
	-- ACT 1: Onboarding (Waves 1–10)
	-- =========================================================================
	[1] = {
		wave_number = 1,
		wave_type = "normal",
		title = "enfos_wave_title_1",
		description = "enfos_wave_desc_1",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 60,
		xp_bounty = 80,
		creeps = {
			{ unit_name = "enfos_creep_soldier", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 2, lane = "both" },
		},
	},
	[2] = {
		wave_number = 2,
		wave_type = "normal",
		title = "enfos_wave_title_2",
		description = "enfos_wave_desc_2",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 70,
		xp_bounty = 95,
		creeps = {
			{ unit_name = "enfos_creep_soldier", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_venomous", count_per_player = 4, lane = "both" },
		},
	},
	[3] = {
		wave_number = 3,
		wave_type = "normal",
		title = "enfos_wave_title_3",
		description = "enfos_wave_desc_3",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 80,
		xp_bounty = 110,
		creeps = {
			{ unit_name = "enfos_creep_soldier", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_conqueror", count_per_player = 2, lane = "both" },
		},
	},
	[4] = {
		wave_number = 4,
		wave_type = "normal",
		title = "enfos_wave_title_4",
		description = "enfos_wave_desc_4",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 90,
		xp_bounty = 130,
		creeps = {
			{ unit_name = "enfos_creep_frostguard", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 3, lane = "both" },
		},
	},
	[5] = {
		wave_number = 5,
		wave_type = "boss",
		title = "enfos_wave_title_5",
		description = "enfos_wave_desc_5",
		boss_name = "enfos_boss_stonebreaker",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 250,
		xp_bounty = 350,
		creeps = {
			{ unit_name = "enfos_boss_stonebreaker", count_per_player = 1, lane = "center", is_boss = true },
		},
	},
	[6] = {
		wave_number = 6,
		wave_type = "normal",
		title = "enfos_wave_title_6",
		description = "enfos_wave_desc_6",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 120,
		xp_bounty = 170,
		creeps = {
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_skyraker", count_per_player = 3, lane = "both" },
		},
	},
	[7] = {
		wave_number = 7,
		wave_type = "normal",
		title = "enfos_wave_title_7",
		description = "enfos_wave_desc_7",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 110,
		xp_bounty = 155,
		creeps = {
			{ unit_name = "enfos_creep_venomous", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 2, lane = "both" },
		},
	},
	[8] = {
		wave_number = 8,
		wave_type = "normal",
		title = "enfos_wave_title_8",
		description = "enfos_wave_desc_8",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 125,
		xp_bounty = 175,
		creeps = {
			{ unit_name = "enfos_creep_runner", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 2, lane = "both" },
		},
	},
	[9] = {
		wave_number = 9,
		wave_type = "normal",
		title = "enfos_wave_title_9",
		description = "enfos_wave_desc_9",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 140,
		xp_bounty = 195,
		creeps = {
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 2, lane = "both" },
		},
	},
	[10] = {
		wave_number = 10,
		wave_type = "boss",
		title = "enfos_wave_title_10",
		description = "enfos_wave_desc_10",
		boss_name = "enfos_boss_brood_matron",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 350,
		xp_bounty = 500,
		creeps = {
			{ unit_name = "enfos_boss_brood_matron", count_per_player = 1, lane = "center", is_boss = true },
		},
	},

	-- =========================================================================
	-- ACT 2: Control / Resource Pressure (Waves 11–20)
	-- =========================================================================
	[11] = {
		wave_number = 11,
		wave_type = "normal",
		title = "enfos_wave_title_11",
		description = "enfos_wave_desc_11",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 150,
		xp_bounty = 210,
		creeps = {
			{ unit_name = "enfos_creep_assassin", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 2, lane = "both" },
		},
	},
	[12] = {
		wave_number = 12,
		wave_type = "normal",
		title = "enfos_wave_title_12",
		description = "enfos_wave_desc_12",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 180,
		xp_bounty = 250,
		creeps = {
			{ unit_name = "enfos_creep_assassin", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_assassin", count_per_player = 3, lane = "both" },
		},
	},
	[13] = {
		wave_number = 13,
		wave_type = "normal",
		title = "enfos_wave_title_13",
		description = "enfos_wave_desc_13",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 165,
		xp_bounty = 230,
		creeps = {
			{ unit_name = "enfos_creep_mindstealer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 2, lane = "both" },
		},
	},
	[14] = {
		wave_number = 14,
		wave_type = "normal",
		title = "enfos_wave_title_14",
		description = "enfos_wave_desc_14",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 175,
		xp_bounty = 245,
		creeps = {
			{ unit_name = "enfos_creep_mindstealer", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 3, lane = "both" },
		},
	},
	[15] = {
		wave_number = 15,
		wave_type = "boss",
		title = "enfos_wave_title_15",
		description = "enfos_wave_desc_15",
		boss_name = "enfos_boss_bloodfang_alpha",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 450,
		xp_bounty = 650,
		creeps = {
			{ unit_name = "enfos_boss_bloodfang_alpha", count_per_player = 1, lane = "center", is_boss = true },
		},
	},
	[16] = {
		wave_number = 16,
		wave_type = "normal",
		title = "enfos_wave_title_16",
		description = "enfos_wave_desc_16",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 190,
		xp_bounty = 265,
		creeps = {
			{ unit_name = "enfos_creep_bloodbeast", count_per_player = 4, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 3, lane = "both" },
		},
	},
	[17] = {
		wave_number = 17,
		wave_type = "normal",
		title = "enfos_wave_title_17",
		description = "enfos_wave_desc_17",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 200,
		xp_bounty = 280,
		creeps = {
			{ unit_name = "enfos_creep_conqueror", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_frostguard", count_per_player = 2, lane = "both" },
		},
	},
	[18] = {
		wave_number = 18,
		wave_type = "normal",
		title = "enfos_wave_title_18",
		description = "enfos_wave_desc_18",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 230,
		xp_bounty = 320,
		creeps = {
			{ unit_name = "enfos_creep_summoner", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_summoner", count_per_player = 2, lane = "both" },
		},
	},
	[19] = {
		wave_number = 19,
		wave_type = "normal",
		title = "enfos_wave_title_19",
		description = "enfos_wave_desc_19",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 215,
		xp_bounty = 300,
		creeps = {
			{ unit_name = "enfos_creep_assassin", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 3, lane = "both" },
		},
	},
	[20] = {
		wave_number = 20,
		wave_type = "boss",
		title = "enfos_wave_title_20",
		description = "enfos_wave_desc_20",
		boss_name = "enfos_boss_frost_warden",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 550,
		xp_bounty = 800,
		creeps = {
			{ unit_name = "enfos_boss_frost_warden", count_per_player = 1, lane = "center", is_boss = true },
		},
	},

	-- =========================================================================
	-- ACT 3: Build Checks (Waves 21–30)
	-- =========================================================================
	[21] = {
		wave_number = 21,
		wave_type = "normal",
		title = "enfos_wave_title_21",
		description = "enfos_wave_desc_21",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 230,
		xp_bounty = 325,
		creeps = {
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 2, lane = "both" },
		},
	},
	[22] = {
		wave_number = 22,
		wave_type = "normal",
		title = "enfos_wave_title_22",
		description = "enfos_wave_desc_22",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 240,
		xp_bounty = 340,
		creeps = {
			{ unit_name = "enfos_creep_silencer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_spellguard", count_per_player = 2, lane = "both" },
		},
	},
	[23] = {
		wave_number = 23,
		wave_type = "normal",
		title = "enfos_wave_title_23",
		description = "enfos_wave_desc_23",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 250,
		xp_bounty = 355,
		creeps = {
			{ unit_name = "enfos_creep_healer", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
		},
	},
	[24] = {
		wave_number = 24,
		wave_type = "normal",
		title = "enfos_wave_title_24",
		description = "enfos_wave_desc_24",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 290,
		xp_bounty = 410,
		creeps = {
			{ unit_name = "enfos_creep_reflector", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_mindstealer", count_per_player = 2, lane = "both" },
		},
	},
	[25] = {
		wave_number = 25,
		wave_type = "boss",
		title = "enfos_wave_title_25",
		description = "enfos_wave_desc_25",
		boss_name = "enfos_boss_mind_devourer",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 700,
		xp_bounty = 1000,
		creeps = {
			{ unit_name = "enfos_boss_mind_devourer", count_per_player = 1, lane = "center", is_boss = true },
		},
	},
	[26] = {
		wave_number = 26,
		wave_type = "normal",
		title = "enfos_wave_title_26",
		description = "enfos_wave_desc_26",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 270,
		xp_bounty = 385,
		creeps = {
			{ unit_name = "enfos_creep_venomous", count_per_player = 4, lane = "both" },
			{ unit_name = "enfos_creep_conqueror", count_per_player = 2, lane = "both" },
		},
	},
	[27] = {
		wave_number = 27,
		wave_type = "normal",
		title = "enfos_wave_title_27",
		description = "enfos_wave_desc_27",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 280,
		xp_bounty = 400,
		creeps = {
			{ unit_name = "enfos_creep_skyraker", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 2, lane = "both" },
		},
	},
	[28] = {
		wave_number = 28,
		wave_type = "normal",
		title = "enfos_wave_title_28",
		description = "enfos_wave_desc_28",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 295,
		xp_bounty = 420,
		creeps = {
			{ unit_name = "enfos_creep_splitter", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 2, lane = "both" },
		},
	},
	[29] = {
		wave_number = 29,
		wave_type = "normal",
		title = "enfos_wave_title_29",
		description = "enfos_wave_desc_29",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 310,
		xp_bounty = 440,
		creeps = {
			{ unit_name = "enfos_creep_venomous", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
		},
	},
	[30] = {
		wave_number = 30,
		wave_type = "boss",
		title = "enfos_wave_title_30",
		description = "enfos_wave_desc_30",
		boss_name = "enfos_boss_iron_colossus",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 850,
		xp_bounty = 1250,
		creeps = {
			{ unit_name = "enfos_boss_iron_colossus", count_per_player = 1, lane = "center", is_boss = true },
		},
	},

	-- =========================================================================
	-- ACT 4: Combinations (Waves 31–40)
	-- =========================================================================
	[31] = {
		wave_number = 31,
		wave_type = "normal",
		title = "enfos_wave_title_31",
		description = "enfos_wave_desc_31",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 325,
		xp_bounty = 460,
		creeps = {
			{ unit_name = "enfos_creep_assassin", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_frostguard", count_per_player = 3, lane = "both" },
		},
	},
	[32] = {
		wave_number = 32,
		wave_type = "normal",
		title = "enfos_wave_title_32",
		description = "enfos_wave_desc_32",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 340,
		xp_bounty = 480,
		creeps = {
			{ unit_name = "enfos_creep_summoner", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_mindstealer", count_per_player = 3, lane = "both" },
		},
	},
	[33] = {
		wave_number = 33,
		wave_type = "normal",
		title = "enfos_wave_title_33",
		description = "enfos_wave_desc_33",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 355,
		xp_bounty = 500,
		creeps = {
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_splitter", count_per_player = 2, lane = "both" },
		},
	},
	[34] = {
		wave_number = 34,
		wave_type = "normal",
		title = "enfos_wave_title_34",
		description = "enfos_wave_desc_34",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 370,
		xp_bounty = 525,
		creeps = {
			{ unit_name = "enfos_creep_exploder", count_per_player = 4, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 2, lane = "both" },
		},
	},
	[35] = {
		wave_number = 35,
		wave_type = "boss",
		title = "enfos_wave_title_35",
		description = "enfos_wave_desc_35",
		boss_name = "enfos_boss_gravecaller",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 1000,
		xp_bounty = 1500,
		creeps = {
			{ unit_name = "enfos_boss_gravecaller", count_per_player = 1, lane = "center", is_boss = true },
		},
	},
	[36] = {
		wave_number = 36,
		wave_type = "normal",
		title = "enfos_wave_title_36",
		description = "enfos_wave_desc_36",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 410,
		xp_bounty = 580,
		creeps = {
			{ unit_name = "enfos_creep_skyraker", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_archer", count_per_player = 4, lane = "both" },
		},
	},
	[37] = {
		wave_number = 37,
		wave_type = "normal",
		title = "enfos_wave_title_37",
		description = "enfos_wave_desc_37",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 390,
		xp_bounty = 550,
		creeps = {
			{ unit_name = "enfos_creep_exploder", count_per_player = 4, lane = "both" },
			{ unit_name = "enfos_creep_healer", count_per_player = 3, lane = "both" },
		},
	},
	[38] = {
		wave_number = 38,
		wave_type = "normal",
		title = "enfos_wave_title_38",
		description = "enfos_wave_desc_38",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 405,
		xp_bounty = 575,
		creeps = {
			{ unit_name = "enfos_creep_conqueror", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_exploder", count_per_player = 3, lane = "both" },
		},
	},
	[39] = {
		wave_number = 39,
		wave_type = "normal",
		title = "enfos_wave_title_39",
		description = "enfos_wave_desc_39",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 420,
		xp_bounty = 600,
		creeps = {
			{ unit_name = "enfos_creep_reflector", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_healer", count_per_player = 3, lane = "both" },
		},
	},
	[40] = {
		wave_number = 40,
		wave_type = "boss",
		title = "enfos_wave_title_40",
		description = "enfos_wave_desc_40",
		boss_name = "enfos_boss_storm_tyrant",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 1200,
		xp_bounty = 1800,
		creeps = {
			{ unit_name = "enfos_boss_storm_tyrant", count_per_player = 1, lane = "center", is_boss = true },
		},
	},

	-- =========================================================================
	-- ACT 5: Coordination (Waves 41–50)
	-- =========================================================================
	[41] = {
		wave_number = 41,
		wave_type = "normal",
		title = "enfos_wave_title_41",
		description = "enfos_wave_desc_41",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 440,
		xp_bounty = 630,
		creeps = {
			{ unit_name = "enfos_creep_bloodbeast", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_spellguard", count_per_player = 3, lane = "both" },
		},
	},
	[42] = {
		wave_number = 42,
		wave_type = "normal",
		title = "enfos_wave_title_42",
		description = "enfos_wave_desc_42",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 490,
		xp_bounty = 700,
		creeps = {
			{ unit_name = "enfos_creep_assassin", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_assassin", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_venomous", count_per_player = 2, lane = "both" },
		},
	},
	[43] = {
		wave_number = 43,
		wave_type = "normal",
		title = "enfos_wave_title_43",
		description = "enfos_wave_desc_43",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 460,
		xp_bounty = 660,
		creeps = {
			{ unit_name = "enfos_creep_silencer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_frostguard", count_per_player = 3, lane = "both" },
		},
	},
	[44] = {
		wave_number = 44,
		wave_type = "normal",
		title = "enfos_wave_title_44",
		description = "enfos_wave_desc_44",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 480,
		xp_bounty = 690,
		creeps = {
			{ unit_name = "enfos_creep_summoner", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
		},
	},
	[45] = {
		wave_number = 45,
		wave_type = "boss",
		title = "enfos_wave_title_45",
		description = "enfos_wave_desc_45",
		boss_name = "enfos_boss_shadow_huntress",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 1400,
		xp_bounty = 2100,
		creeps = {
			{ unit_name = "enfos_boss_shadow_huntress", count_per_player = 1, lane = "center", is_boss = true },
		},
	},
	[46] = {
		wave_number = 46,
		wave_type = "normal",
		title = "enfos_wave_title_46",
		description = "enfos_wave_desc_46",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 500,
		xp_bounty = 720,
		creeps = {
			{ unit_name = "enfos_creep_assassin", count_per_player = 4, lane = "both" },
			{ unit_name = "enfos_creep_conqueror", count_per_player = 4, lane = "both" },
		},
	},
	[47] = {
		wave_number = 47,
		wave_type = "normal",
		title = "enfos_wave_title_47",
		description = "enfos_wave_desc_47",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 520,
		xp_bounty = 750,
		creeps = {
			{ unit_name = "enfos_creep_cursecaster", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_soldier", count_per_player = 3, lane = "both" },
		},
	},
	[48] = {
		wave_number = 48,
		wave_type = "normal",
		title = "enfos_wave_title_48",
		description = "enfos_wave_desc_48",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 570,
		xp_bounty = 820,
		creeps = {
			{ unit_name = "enfos_creep_exploder", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_exploder", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_splitter", count_per_player = 2, lane = "both" },
		},
	},
	[49] = {
		wave_number = 49,
		wave_type = "normal",
		title = "enfos_wave_title_49",
		description = "enfos_wave_desc_49",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 540,
		xp_bounty = 780,
		creeps = {
			{ unit_name = "enfos_creep_cursecaster", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_mindstealer", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 2, lane = "both" },
		},
	},
	[50] = {
		wave_number = 50,
		wave_type = "boss",
		title = "enfos_wave_title_50",
		description = "enfos_wave_desc_50",
		boss_name = "enfos_boss_plague_behemoth",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 1700,
		xp_bounty = 2500,
		creeps = {
			{ unit_name = "enfos_boss_plague_behemoth", count_per_player = 1, lane = "center", is_boss = true },
		},
	},

	-- =========================================================================
	-- ACT 6: Final Exam (Waves 51–60)
	-- =========================================================================
	[51] = {
		wave_number = 51,
		wave_type = "normal",
		title = "enfos_wave_title_51",
		description = "enfos_wave_desc_51",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 570,
		xp_bounty = 820,
		creeps = {
			{ unit_name = "enfos_creep_assassin", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_healer", count_per_player = 3, lane = "both" },
		},
	},
	[52] = {
		wave_number = 52,
		wave_type = "normal",
		title = "enfos_wave_title_52",
		description = "enfos_wave_desc_52",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 590,
		xp_bounty = 850,
		creeps = {
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_spellguard", count_per_player = 3, lane = "both" },
		},
	},
	[53] = {
		wave_number = 53,
		wave_type = "normal",
		title = "enfos_wave_title_53",
		description = "enfos_wave_desc_53",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 610,
		xp_bounty = 880,
		creeps = {
			{ unit_name = "enfos_creep_healer", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_summoner", count_per_player = 3, lane = "both" },
		},
	},
	[54] = {
		wave_number = 54,
		wave_type = "normal",
		title = "enfos_wave_title_54",
		description = "enfos_wave_desc_54",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 670,
		xp_bounty = 970,
		creeps = {
			{ unit_name = "enfos_creep_conqueror", count_per_player = 1, lane = "both" },
			{ unit_name = "enfos_creep_conqueror", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_mindstealer", count_per_player = 2, lane = "both" },
		},
	},
	[55] = {
		wave_number = 55,
		wave_type = "boss",
		title = "enfos_wave_title_55",
		description = "enfos_wave_desc_55",
		boss_name = "enfos_boss_rift_lord",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 2000,
		xp_bounty = 3000,
		creeps = {
			{ unit_name = "enfos_boss_rift_lord", count_per_player = 1, lane = "center", is_boss = true },
		},
	},
	[56] = {
		wave_number = 56,
		wave_type = "normal",
		title = "enfos_wave_title_56",
		description = "enfos_wave_desc_56",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 640,
		xp_bounty = 920,
		creeps = {
			{ unit_name = "enfos_creep_frostguard", count_per_player = 4, lane = "both" },
			{ unit_name = "enfos_creep_bloodbeast", count_per_player = 3, lane = "both" },
		},
	},
	[57] = {
		wave_number = 57,
		wave_type = "normal",
		title = "enfos_wave_title_57",
		description = "enfos_wave_desc_57",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 660,
		xp_bounty = 950,
		creeps = {
			{ unit_name = "enfos_creep_reflector", count_per_player = 3, lane = "both" },
			{ unit_name = "enfos_creep_venomous", count_per_player = 3, lane = "both" },
		},
	},
	[58] = {
		wave_number = 58,
		wave_type = "normal",
		title = "enfos_wave_title_58",
		description = "enfos_wave_desc_58",
		batches = 4,
		batch_interval = 3.0,
		gold_bounty = 680,
		xp_bounty = 980,
		creeps = {
			{ unit_name = "enfos_creep_spellguard", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_assassin", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_mindstealer", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_healer", count_per_player = 1, lane = "both" },
		},
	},
	[59] = {
		wave_number = 59,
		wave_type = "normal",
		title = "enfos_wave_title_59",
		description = "enfos_wave_desc_59",
		batches = 4,
		batch_interval = 3.5,
		gold_bounty = 700,
		xp_bounty = 1000,
		creeps = {
			{ unit_name = "enfos_creep_shieldbearer", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_summoner", count_per_player = 2, lane = "both" },
			{ unit_name = "enfos_creep_spellguard", count_per_player = 2, lane = "both" },
		},
	},
	[60] = {
		wave_number = 60,
		wave_type = "boss",
		title = "enfos_wave_title_60",
		description = "enfos_wave_desc_60",
		boss_name = "enfos_boss_ascendant_gatekeeper",
		batches = 1,
		batch_interval = 0,
		gold_bounty = 3000,
		xp_bounty = 5000,
		creeps = {
			{ unit_name = "enfos_boss_ascendant_gatekeeper", count_per_player = 1, lane = "center", is_boss = true },
		},
	},
}

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function WaveDefinitions:GetWave(waveNumber)
	return WAVES[waveNumber]
end

function WaveDefinitions:GetTotalWaves()
	return WaveDefinitions.TOTAL_WAVES
end

function WaveDefinitions:IsBossWave(waveNumber)
	return (waveNumber > 0) and (waveNumber % 5 == 0)
end


function WaveDefinitions:GetUnitLeakType(unitName)
	return UNIT_LEAK_TYPES[unitName] or "normal"
end

function WaveDefinitions:GetLeakPenalty(unitName)
	local leakType = WaveDefinitions:GetUnitLeakType(unitName)
	return WaveDefinitions.LEAK_PENALTIES[leakType] or 1
end

-- Threat cost is retained for audits; it no longer reduces scheduled unit counts.
function WaveDefinitions:GetThreatCost(name)
	if name:find("summoner", 1, true) or name:find("cursecaster", 1, true) or name:find("skyraker", 1, true) or name:find("silencer", 1, true) or name:find("conqueror", 1, true) then return 2.5 end
	if name:find("healer", 1, true) or name:find("shieldbearer", 1, true)
		or name:find("spellguard", 1, true) or name:find("reflector", 1, true) then return 2 end
	if name == "enfos_creep_soldier" or name == "enfos_creep_archer" then return 1 end
	return 1.25
end

-- Exact unit count, weighted composition (not a threat-budget reduction).
function WaveDefinitions:GetScheduledCount(waveNumber, players)
    if self:IsBossWave(waveNumber) then return players > 0 and 1 or 0 end
    return (20 + 2 * (waveNumber - 1)) * math.max(0, players)
end
function WaveDefinitions:GetDuration(waveNumber)
    if self:IsBossWave(waveNumber) then return 45 end
    return 22 + 2 * math.floor((waveNumber - 1) / 20)
end
function WaveDefinitions:GetSpawnPlan(waveNumber, players)
    local wave = assert(self:GetWave(waveNumber), "Unknown wave")
    if self:IsBossWave(waveNumber) then
        return {{unit_name=wave.boss_name,lane="center",count=players > 0 and 1 or 0,cost=1}}, players > 0 and 1 or 0, players > 0 and 1 or 0
    end
    local plan, totalWeight, spent = {}, 0, 0
    local budget = self:GetScheduledCount(waveNumber, players)
    for _, entry in ipairs(wave.creeps) do totalWeight = totalWeight + entry.count_per_player end
    for _, entry in ipairs(wave.creeps) do
        local desired = budget * entry.count_per_player / totalWeight
        local count = math.floor(desired)
        plan[#plan+1] = {unit_name=entry.unit_name,lane=entry.lane,count=count,cost=1,desired=desired}
        spent = spent + count
    end
    while spent < budget do
        local best
        for _, entry in ipairs(plan) do
            if not best or entry.desired-entry.count > best.desired-best.count then best=entry end
        end
        best.count=best.count+1; spent=spent+1
    end
    return plan, spent, budget
end

return WaveDefinitions

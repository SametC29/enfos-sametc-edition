import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = path.resolve(__dirname, '..');

const customAbilitiesPath = path.join(root, 'game/scripts/npc/npc_abilities_custom.txt');
const customHeroesPath = path.join(root, 'game/scripts/npc/npc_heroes_custom.txt');
const heroListPath = path.join(root, 'game/scripts/npc/herolist.txt');
const turkishJsonPath = path.join(root, 'localization/turkish.json');
const addonGameModePath = path.join(root, 'game/scripts/vscripts/addon_game_mode.lua');

// New 20 Heroes Metadata
const NEW_HEROES = [
  // Tanks (4)
  {
    hero: 'npc_dota_hero_tidehunter',
    id: '29',
    role: 'Tank',
    primary: 'DOTA_ATTRIBUTE_STRENGTH',
    str: '27', agi: '15', int: '18',
    ms: '300', armor: '3.0',
    abilities: ['enfos_tide_gush', 'enfos_tide_kraken_shell', 'enfos_tide_anchor_smash', 'enfos_tide_ravage', 'enfos_tide_colossal_presence']
  },
  {
    hero: 'npc_dota_hero_dragon_knight',
    id: '49',
    role: 'Tank',
    primary: 'DOTA_ATTRIBUTE_STRENGTH',
    str: '21', agi: '19', int: '18',
    ms: '310', armor: '4.0',
    abilities: ['enfos_dk_breathe_fire', 'enfos_dk_dragon_tail', 'enfos_dk_dragon_blood', 'enfos_dk_elder_dragon_form', 'enfos_dk_wyrm_vigor']
  },
  {
    hero: 'npc_dota_hero_pudge',
    id: '14',
    role: 'Tank',
    primary: 'DOTA_ATTRIBUTE_STRENGTH',
    str: '25', agi: '14', int: '16',
    ms: '280', armor: '2.0',
    abilities: ['enfos_pudge_meat_hook', 'enfos_pudge_rot', 'enfos_pudge_flesh_heap', 'enfos_pudge_dismember', 'enfos_pudge_meat_shield']
  },
  {
    hero: 'npc_dota_hero_abyssal_underlord',
    id: '108',
    role: 'Tank',
    primary: 'DOTA_ATTRIBUTE_STRENGTH',
    str: '25', agi: '12', int: '17',
    ms: '290', armor: '4.0',
    abilities: ['enfos_underlord_firestorm', 'enfos_underlord_pit_of_malice', 'enfos_underlord_atrophy_aura', 'enfos_underlord_dark_rift', 'enfos_underlord_abyssal_carapace']
  },

  // Fighters (4)
  {
    hero: 'npc_dota_hero_ursa',
    id: '70',
    role: 'Fighter',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '25', agi: '18', int: '16',
    ms: '310', armor: '4.0',
    abilities: ['enfos_ursa_earthshock', 'enfos_ursa_overpower', 'enfos_ursa_fury_swipes', 'enfos_ursa_enrage', 'enfos_ursa_ursa_minor']
  },
  {
    hero: 'npc_dota_hero_monkey_king',
    id: '114',
    role: 'Fighter',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '18', agi: '22', int: '20',
    ms: '300', armor: '4.0',
    abilities: ['enfos_mk_boundless_strike', 'enfos_mk_primal_spring', 'enfos_mk_jingu_mastery', 'enfos_mk_wukongs_command', 'enfos_mk_mischief']
  },
  {
    hero: 'npc_dota_hero_troll_warlord',
    id: '95',
    role: 'Fighter',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '21', agi: '21', int: '13',
    ms: '290', armor: '2.5',
    abilities: ['enfos_troll_berserkers_rage', 'enfos_troll_whirling_axes', 'enfos_troll_fervor', 'enfos_troll_battle_trance', 'enfos_troll_rampage']
  },
  {
    hero: 'npc_dota_hero_chaos_knight',
    id: '81',
    role: 'Fighter',
    primary: 'DOTA_ATTRIBUTE_STRENGTH',
    str: '22', agi: '18', int: '18',
    ms: '320', armor: '4.0',
    abilities: ['enfos_ck_chaos_bolt', 'enfos_ck_reality_rift', 'enfos_ck_chaos_strike', 'enfos_ck_phantasm', 'enfos_ck_entropy']
  },

  // Carries (4)
  {
    hero: 'npc_dota_hero_antimage',
    id: '1',
    role: 'Carry',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '21', agi: '24', int: '12',
    ms: '310', armor: '3.0',
    abilities: ['enfos_am_mana_break', 'enfos_am_blink', 'enfos_am_counterspell', 'enfos_am_mana_void', 'enfos_am_spellbreaker']
  },
  {
    hero: 'npc_dota_hero_faceless_void',
    id: '41',
    role: 'Carry',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '20', agi: '23', int: '15',
    ms: '300', armor: '4.0',
    abilities: ['enfos_void_time_walk', 'enfos_void_time_dilation', 'enfos_void_time_lock', 'enfos_void_chronosphere', 'enfos_void_backtrack']
  },
  {
    hero: 'npc_dota_hero_medusa',
    id: '94',
    role: 'Carry',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '17', agi: '22', int: '23',
    ms: '280', armor: '1.5',
    abilities: ['enfos_medusa_split_shot', 'enfos_medusa_mystic_snake', 'enfos_medusa_mana_shield', 'enfos_medusa_stone_gaze', 'enfos_medusa_gorgon_gaze']
  },
  {
    hero: 'npc_dota_hero_terrorblade',
    id: '109',
    role: 'Carry',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '16', agi: '22', int: '19',
    ms: '315', armor: '8.0',
    abilities: ['enfos_tb_reflection', 'enfos_tb_conjure_image', 'enfos_tb_metamorphosis', 'enfos_tb_sunder', 'enfos_tb_demon_zeal']
  },

  // Mages (4)
  {
    hero: 'npc_dota_hero_storm_spirit',
    id: '17',
    role: 'Mage',
    primary: 'DOTA_ATTRIBUTE_INTELLECT',
    str: '21', agi: '22', int: '23',
    ms: '285', armor: '4.0',
    abilities: ['enfos_storm_static_remnant', 'enfos_storm_electric_vortex', 'enfos_storm_overload', 'enfos_storm_ball_lightning', 'enfos_storm_galvanic_core']
  },
  {
    hero: 'npc_dota_hero_leshrac',
    id: '52',
    role: 'Mage',
    primary: 'DOTA_ATTRIBUTE_INTELLECT',
    str: '20', agi: '23', int: '22',
    ms: '315', armor: '3.5',
    abilities: ['enfos_leshrac_split_earth', 'enfos_leshrac_diabolic_edict', 'enfos_leshrac_lightning_storm', 'enfos_leshrac_pulse_nova', 'enfos_leshrac_defilement']
  },
  {
    hero: 'npc_dota_hero_invoker',
    id: '74',
    role: 'Mage',
    primary: 'DOTA_ATTRIBUTE_INTELLECT',
    str: '19', agi: '14', int: '19',
    ms: '285', armor: '1.5',
    abilities: ['enfos_invoker_chaos_meteor', 'enfos_invoker_sun_strike', 'enfos_invoker_deafening_blast', 'enfos_invoker_emp', 'enfos_invoker_alacrity']
  },
  {
    hero: 'npc_dota_hero_puck',
    id: '13',
    role: 'Mage',
    primary: 'DOTA_ATTRIBUTE_INTELLECT',
    str: '17', agi: '22', int: '23',
    ms: '290', armor: '0.0',
    abilities: ['enfos_puck_illusory_orb', 'enfos_puck_waning_rift', 'enfos_puck_phase_shift', 'enfos_puck_dream_coil', 'enfos_puck_faerie_magic']
  },

  // Supports (4)
  {
    hero: 'npc_dota_hero_lion',
    id: '26',
    role: 'Support',
    primary: 'DOTA_ATTRIBUTE_INTELLECT',
    str: '18', agi: '15', int: '20',
    ms: '290', armor: '2.5',
    abilities: ['enfos_lion_earth_spike', 'enfos_lion_hex', 'enfos_lion_mana_drain', 'enfos_lion_finger_of_death', 'enfos_lion_demon_soul']
  },
  {
    hero: 'npc_dota_hero_jakiro',
    id: '64',
    role: 'Support',
    primary: 'DOTA_ATTRIBUTE_INTELLECT',
    str: '25', agi: '15', int: '26',
    ms: '290', armor: '2.5',
    abilities: ['enfos_jakiro_dual_breath', 'enfos_jakiro_ice_path', 'enfos_jakiro_liquid_fire', 'enfos_jakiro_macropyre', 'enfos_jakiro_double_trouble']
  },
  {
    hero: 'npc_dota_hero_vengefulspirit',
    id: '20',
    role: 'Support',
    primary: 'DOTA_ATTRIBUTE_AGILITY',
    str: '19', agi: '20', int: '19',
    ms: '295', armor: '3.0',
    abilities: ['enfos_vs_magic_missile', 'enfos_vs_wave_of_terror', 'enfos_vs_vengeance_aura', 'enfos_vs_nether_swap', 'enfos_vs_retribution']
  },
  {
    hero: 'npc_dota_hero_lich',
    id: '31',
    role: 'Support',
    primary: 'DOTA_ATTRIBUTE_INTELLECT',
    str: '20', agi: '17', int: '24',
    ms: '295', armor: '1.5',
    abilities: ['enfos_lich_frost_blast', 'enfos_lich_frost_shield', 'enfos_lich_sinister_gaze', 'enfos_lich_chain_frost', 'enfos_lich_ice_aura']
  }
];

// ─────────────────────────────────────────────────────────────────────────────
// 1. Generate KV Definitions for the 100 Abilities
// ─────────────────────────────────────────────────────────────────────────────
function generateAbilitiesKV() {
  return `
	// =========================================================================
	// TIDEHUNTER ABILITIES (TANK)
	// =========================================================================

	"enfos_tide_gush"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"tidehunter_gush"
		"AbilityCastRange"			"700"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"10.0"
		"AbilityManaCost"			"90 100 110 120"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"gush_damage"		"110 180 250 320"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"armor_reduction"	"-3 -4 -5 -6"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"movement_slow"		"-40"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"4.5"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Tidehunter.GushCast"
				"Target"			"CASTER"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%gush_damage"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_tide_gush_debuff"
				"Target"			"TARGET"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_tide_gush_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%armor_reduction"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%movement_slow"
				}
			}
		}
	}

	"enfos_tide_kraken_shell"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"tidehunter_kraken_shell"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_reduction"	"18 32 46 60"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_hp_regen"	"6 12 18 24"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_tide_kraken_shell"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK" "%damage_reduction"
					"MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT" "%bonus_hp_regen"
				}
			}
		}
	}

	"enfos_tide_anchor_smash"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PHYSICAL"
		"AbilityTextureName"		"tidehunter_anchor_smash"
		"AbilityCastRange"			"375"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"6.0 5.0 4.0 3.0"
		"AbilityManaCost"			"40 50 60 70"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"375"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"attack_damage_bonus" "60 100 140 180"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_reduction"	"-30 -40 -50 -60"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"6.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Tidehunter.AnchorSmash"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_PHYSICAL"
						"Damage"	"%attack_damage_bonus"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_anchor_smash_debuff"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_anchor_smash_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE" "%damage_reduction"
				}
			}
		}
	}

	"enfos_tide_ravage"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"tidehunter_ravage"
		"AbilityCastRange"			"1000"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"150 225 300"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"1000"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"350 550 750"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"2.4 2.8 3.2"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Tidehunter.Ravage"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_stunned"
						"Target"	"TARGET"
						"Duration"	"%stun_duration"
					}
				}
			}
		}
	}

	"enfos_tide_colossal_presence"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"tidehunter_kraken_shell"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_health"		"500"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_armor"		"6"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_tide_colossal_presence"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_HEALTH_BONUS" "%bonus_health"
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%bonus_armor"
				}
			}
		}
	}

	// =========================================================================
	// DRAGON KNIGHT ABILITIES (TANK)
	// =========================================================================

	"enfos_dk_breathe_fire"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"dragon_knight_breathe_fire"
		"AbilityCastRange"			"750"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"9.0"
		"AbilityManaCost"			"80 90 100 110"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"120 190 260 330"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"750"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"reduction_pct"		"-25 -30 -35 -40"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"6.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_DragonKnight.BreathFire"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_dk_fire_debuff"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_dk_fire_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE" "%reduction_pct"
				}
			}
		}
	}

	"enfos_dk_dragon_tail"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"dragon_knight_dragon_tail"
		"AbilityCastRange"			"350"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"12.0 11.0 10.0 9.0"
		"AbilityManaCost"			"70 80 90 100"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"90 150 210 270"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.8 2.2 2.6 3.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_DragonKnight.DragonTail.Target"
				"Target"			"TARGET"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_stunned"
				"Target"			"TARGET"
				"Duration"			"%stun_duration"
			}
		}
	}

	"enfos_dk_dragon_blood"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"dragon_knight_dragon_blood"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_armor"		"5 10 15 20"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_hp_regen"	"8 16 24 32"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_dk_dragon_blood"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%bonus_armor"
					"MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT" "%bonus_hp_regen"
				}
			}
		}
	}

	"enfos_dk_elder_dragon_form"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityTextureName"		"dragon_knight_elder_dragon_form"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"100 125 150"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"40.0"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms"			"30 40 50"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"40 70 100"
			}
			"04"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_range"		"350"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_DragonKnight.ElderDragonForm"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_elder_dragon"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_elder_dragon"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT" "%bonus_ms"
					"MODIFIER_PROPERTY_ATTACK_RANGE_BONUS" "%bonus_range"
				}
			}
		}
	}

	"enfos_dk_wyrm_vigor"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"dragon_knight_fireball"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"magic_resist"		"18"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_strength"	"12"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_dk_wyrm_vigor"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS" "%magic_resist"
					"MODIFIER_PROPERTY_STATS_STRENGTH_BONUS" "%bonus_strength"
				}
			}
		}
	}

	// =========================================================================
	// PUDGE ABILITIES (TANK)
	// =========================================================================

	"enfos_pudge_meat_hook"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PURE"
		"AbilityTextureName"		"pudge_meat_hook"
		"AbilityCastRange"			"1000"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"12.0 10.0 8.0 6.0"
		"AbilityManaCost"			"90 100 110 120"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"hook_damage"		"150 240 330 420"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"hook_distance"		"1000"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Pudge.MeatHook"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"300"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_PURE"
						"Damage"	"%hook_damage"
					}
				}
			}
		}
	}

	"enfos_pudge_rot"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_TOGGLE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"pudge_rot"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"rot_damage"		"40 70 100 130"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"rot_slow"			"-16 -22 -28 -34"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"rot_radius"		"350"
			}
		}

		"OnToggleOn"
		{
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_pudge_rot"
				"Target"			"CASTER"
			}
		}

		"OnToggleOff"
		{
			"RemoveModifier"
			{
				"ModifierName"		"modifier_enfos_pudge_rot"
				"Target"			"CASTER"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_pudge_rot"
			{
				"ThinkInterval"		"0.5"
				"OnIntervalThink"
				{
					"ActOnTargets"
					{
						"Target"
						{
							"Center"	"CASTER"
							"Radius"	"%rot_radius"
							"Teams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
							"Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
						}
						"Action"
						{
							"Damage"
							{
								"Target" "TARGET"
								"Type"	"DAMAGE_TYPE_MAGICAL"
								"Damage" "%rot_damage"
							}
						}
					}
				}
			}
		}
	}

	"enfos_pudge_flesh_heap"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"pudge_flesh_heap"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_strength"	"10 18 26 34"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_block"		"12 20 28 36"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_pudge_flesh_heap"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_STATS_STRENGTH_BONUS" "%bonus_strength"
					"MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK" "%damage_block"
				}
			}
		}
	}

	"enfos_pudge_dismember"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_CHANNELLED"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"pudge_dismember"
		"AbilityCastRange"			"250"
		"AbilityCastPoint"			"0.2"
		"AbilityChannelTime"		"3.0"
		"AbilityCooldown"			"30.0 25.0 20.0"
		"AbilityManaCost"			"100 130 160"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"dps"				"140 220 300"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Pudge.Dismember"
				"Target"			"TARGET"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_stunned"
				"Target"			"TARGET"
				"Duration"			"3.0"
			}
		}

		"OnChannelThink"
		{
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%dps"
			}
		}
	}

	"enfos_pudge_meat_shield"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"pudge_eject"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"magic_resist"		"20"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_hp"			"600"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_pudge_meat_shield"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS" "%magic_resist"
					"MODIFIER_PROPERTY_HEALTH_BONUS" "%bonus_hp"
				}
			}
		}
	}

	// =========================================================================
	// UNDERLORD ABILITIES (TANK)
	// =========================================================================

	"enfos_underlord_firestorm"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"abyssal_underlord_firestorm"
		"AbilityCastRange"			"750"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"12.0"
		"AbilityManaCost"			"100 115 130 145"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"wave_damage"		"35 55 75 95"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"425"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"wave_count"		"6"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_AbyssalUnderlord.Firestorm.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%wave_damage"
					}
				}
			}
		}
	}

	"enfos_underlord_pit_of_malice"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityTextureName"		"abyssal_underlord_pit_of_malice"
		"AbilityCastRange"			"700"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"18.0 16.0 14.0 12.0"
		"AbilityManaCost"			"80 100 120 140"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"400"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"ensnare_duration"	"1.4 1.8 2.2 2.6"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_AbyssalUnderlord.PitOfMalice"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"ApplyModifier"
					{
						"ModifierName" "modifier_rooted"
						"Target"	"TARGET"
						"Duration"	"%ensnare_duration"
					}
				}
			}
		}
	}

	"enfos_underlord_atrophy_aura"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"abyssal_underlord_atrophy_aura"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_reduction_pct" "-12 -18 -24 -30"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"20 35 50 65"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_atrophy_aura"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_underlord_dark_rift"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"abyssal_underlord_dark_rift"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"150 200 250"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"burst_damage"		"350 550 750"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"750"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_AbyssalUnderlord.DarkRift.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%burst_damage"
					}
				}
			}
		}
	}

	"enfos_underlord_abyssal_carapace"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"abyssal_underlord_atrophy_aura"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_armor"		"8"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_hp"			"500"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_underlord_carapace"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%bonus_armor"
					"MODIFIER_PROPERTY_HEALTH_BONUS" "%bonus_hp"
				}
			}
		}
	}

	// =========================================================================
	// URSA ABILITIES (FIGHTER)
	// =========================================================================

	"enfos_ursa_earthshock"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"ursa_earthshock"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"9.0 8.0 7.0 6.0"
		"AbilityManaCost"			"75"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"90 160 230 300"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"450"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-30 -35 -40 -45"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"4.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Ursa.Earthshock"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_ursa_earthshock_slow"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_ursa_earthshock_slow"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}

	"enfos_ursa_overpower"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityTextureName"		"ursa_overpower"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"12.0 11.0 10.0 9.0"
		"AbilityManaCost"			"50 60 70 80"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"attack_speed"		"400"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"max_attacks"		"6"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"8.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Ursa.Overpower"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_ursa_overpower"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_ursa_overpower"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%attack_speed"
				}
			}
		}
	}

	"enfos_ursa_fury_swipes"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"ursa_fury_swipes"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"15 25 35 45"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_ursa_fury_swipes"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_ursa_enrage"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_IMMEDIATE"
		"AbilityTextureName"		"ursa_enrage"
		"AbilityCastPoint"			"0.0"
		"AbilityCooldown"			"40.0 35.0 30.0"
		"AbilityManaCost"			"0"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"5.0"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_reduction"	"80"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Ursa.Enrage"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_ursa_enrage"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_ursa_enrage"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE" "-80"
				}
			}
		}
	}

	"enfos_ursa_ursa_minor"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"ursa_enrage"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms"			"25"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_lifesteal"	"15"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_ursa_minor"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT" "%bonus_ms"
				}
			}
		}
	}

	// =========================================================================
	// MONKEY KING ABILITIES (FIGHTER)
	// =========================================================================

	"enfos_mk_boundless_strike"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PHYSICAL"
		"AbilityTextureName"		"monkey_king_boundless_strike"
		"AbilityCastRange"			"1000"
		"AbilityCastPoint"			"0.4"
		"AbilityCooldown"			"18.0 16.0 14.0 12.0"
		"AbilityManaCost"			"100"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"strike_damage"		"150 250 350 450"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.2 1.4 1.6 1.8"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"1000"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_MonkeyKing.Spring.Impact"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_PHYSICAL"
						"Damage"	"%strike_damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_stunned"
						"Target"	"TARGET"
						"Duration"	"%stun_duration"
					}
				}
			}
		}
	}

	"enfos_mk_primal_spring"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"monkey_king_primal_spring"
		"AbilityCastRange"			"800"
		"AbilityCastPoint"			"0.4"
		"AbilityCooldown"			"12.0 11.0 10.0 9.0"
		"AbilityManaCost"			"80 90 100 110"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"spring_damage"		"120 200 280 360"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"450"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-30 -40 -50 -60"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"4.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_MonkeyKing.Spring.Impact"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%spring_damage"
					}
				}
			}
		}
	}

	"enfos_mk_jingu_mastery"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"monkey_king_jingu_mastery"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"30 50 70 90"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"lifesteal_pct"		"15 20 25 30"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_mk_jingu"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_mk_wukongs_command"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PHYSICAL"
		"AbilityTextureName"		"monkey_king_wukongs_command"
		"AbilityCastRange"			"600"
		"AbilityCastPoint"			"0.4"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"150 200 250"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"ring_radius"		"600"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"soldier_damage"	"120 180 240"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"12.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_MonkeyKing.FurArmy"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%ring_radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_PHYSICAL"
						"Damage"	"%soldier_damage"
					}
				}
			}
		}
	}

	"enfos_mk_mischief"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"monkey_king_mischief"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_range"		"75"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"evasion_pct"		"15"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_mk_mischief"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACK_RANGE_BONUS" "%bonus_range"
					"MODIFIER_PROPERTY_EVASION_CONSTANT" "%evasion_pct"
				}
			}
		}
	}

	// =========================================================================
	// TROLL WARLORD ABILITIES (FIGHTER)
	// =========================================================================

	"enfos_troll_berserkers_rage"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_TOGGLE"
		"AbilityTextureName"		"troll_warlord_berserkers_rage"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_armor"		"3 5 7 9"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms"			"15 25 35 45"
			}
		}

		"OnToggleOn"
		{
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_berserkers_rage"
				"Target"			"CASTER"
			}
		}

		"OnToggleOff"
		{
			"RemoveModifier"
			{
				"ModifierName"		"modifier_enfos_berserkers_rage"
				"Target"			"CASTER"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_berserkers_rage"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%bonus_armor"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT" "%bonus_ms"
				}
			}
		}
	}

	"enfos_troll_whirling_axes"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"troll_warlord_whirling_axes_melee"
		"AbilityCastRange"			"450"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"9.0"
		"AbilityManaCost"			"50"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"90 150 210 270"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"450"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"blind_duration"	"5.0"
			}
			"04"
			{
				"var_type"			"FIELD_INTEGER"
				"blind_pct"			"60"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_TrollWarlord.WhirlingAxes.Melee"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_troll_fervor"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"troll_warlord_fervor"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"attack_speed"		"40 70 100 130"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_fervor"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%attack_speed"
				}
			}
		}
	}

	"enfos_troll_battle_trance"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_IMMEDIATE"
		"AbilityTextureName"		"troll_warlord_battle_trance"
		"AbilityCastPoint"			"0.0"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"100"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"6.5"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_as"			"140 180 220"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms_pct"		"30"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_TrollWarlord.BattleTrance.Cast"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_battle_trance"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_battle_trance"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_as"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%bonus_ms_pct"
				}
			}
		}
	}

	"enfos_troll_rampage"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"troll_warlord_rampage"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"25"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_status_res"	"15"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_troll_rampage"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	// =========================================================================
	// CHAOS KNIGHT ABILITIES (FIGHTER)
	// =========================================================================

	"enfos_ck_chaos_bolt"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"chaos_knight_chaos_bolt"
		"AbilityCastRange"			"600"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"12.0 11.0 10.0 9.0"
		"AbilityManaCost"			"90 100 110 120"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"140 210 280 350"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.5 2.0 2.5 3.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_ChaosKnight.ChaosBolt"
				"Target"			"CASTER"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_stunned"
				"Target"			"TARGET"
				"Duration"			"%stun_duration"
			}
		}
	}

	"enfos_ck_reality_rift"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"chaos_knight_reality_rift"
		"AbilityCastRange"			"700"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"14.0 12.0 10.0 8.0"
		"AbilityManaCost"			"50"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"armor_reduction"	"-3 -4 -5 -6"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"6.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_ChaosKnight.RealityRift"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_reality_rift_debuff"
				"Target"			"TARGET"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_reality_rift_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%armor_reduction"
				}
			}
		}
	}

	"enfos_ck_chaos_strike"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"chaos_knight_chaos_strike"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"crit_mult"			"160 190 220 250"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"20 35 50 65"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_chaos_strike"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_ck_phantasm"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityTextureName"		"chaos_knight_phantasm"
		"AbilityCastPoint"			"0.4"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"125 175 225"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"50 80 110"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"30.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_ChaosKnight.Phantasm"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_phantasm_buff"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_phantasm_buff"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_ck_entropy"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"chaos_knight_chaos_strike"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_strength"	"15"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_speed"		"20"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_ck_entropy"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_STATS_STRENGTH_BONUS" "%bonus_strength"
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_speed"
				}
			}
		}
	}

	// =========================================================================
	// ANTI-MAGE ABILITIES (CARRY)
	// =========================================================================

	"enfos_am_mana_break"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"antimage_mana_break"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"28 44 60 76"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_am_mana_break"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_am_blink"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityTextureName"		"antimage_blink"
		"AbilityCastRange"			"1150"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"12.0 9.0 6.0 4.0"
		"AbilityManaCost"			"45"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"blink_range"		"1150"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Antimage.Blink_out"
				"Target"			"CASTER"
			}
		}
	}

	"enfos_am_counterspell"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_IMMEDIATE"
		"AbilityTextureName"		"antimage_counterspell"
		"AbilityCastPoint"			"0.0"
		"AbilityCooldown"			"15.0 12.0 9.0 6.0"
		"AbilityManaCost"			"45"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"magic_resist"		"20 30 40 50"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"1.4"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_am_counterspell_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS" "%magic_resist"
				}
			}
		}
	}

	"enfos_am_mana_void"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"antimage_mana_void"
		"AbilityCastRange"			"600"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"125 200 275"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"base_damage"		"350 550 750"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"500"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"0.5"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Antimage.ManaVoid"
				"Target"			"TARGET"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%base_damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_stunned"
						"Target"	"TARGET"
						"Duration"	"%stun_duration"
					}
				}
			}
		}
	}

	"enfos_am_spellbreaker"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"antimage_spell_shield"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_as"			"35"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms"			"20"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_am_spellbreaker"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_as"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT" "%bonus_ms"
				}
			}
		}
	}

	// =========================================================================
	// FACELESS VOID ABILITIES (CARRY)
	// =========================================================================

	"enfos_void_time_walk"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityTextureName"		"faceless_void_time_walk"
		"AbilityCastRange"			"800"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"16.0 13.0 10.0 7.0"
		"AbilityManaCost"			"40"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"800"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_FacelessVoid.TimeWalk"
				"Target"			"CASTER"
			}
		}
	}

	"enfos_void_time_dilation"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"faceless_void_time_dilation"
		"AbilityCastRange"			"775"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"18.0 16.0 14.0 12.0"
		"AbilityManaCost"			"75"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"775"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-25 -30 -35 -40"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_per_sec"	"30 50 70 90"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"8.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_FacelessVoid.TimeDilation.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_time_dilation_debuff"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_time_dilation_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}

	"enfos_void_time_lock"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"faceless_void_time_lock"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"25 45 65 85"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_time_lock"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_void_chronosphere"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityTextureName"		"faceless_void_chronosphere"
		"AbilityCastRange"			"700"
		"AbilityCastPoint"			"0.35"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"150 200 250"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"500"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"4.5 5.0 5.5"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_FacelessVoid.Chronosphere"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"ApplyModifier"
					{
						"ModifierName" "modifier_stunned"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}
	}

	"enfos_void_backtrack"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"faceless_void_backtrack"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"dodge_pct"			"20"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_as"			"20"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_void_backtrack"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_EVASION_CONSTANT" "%dodge_pct"
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_as"
				}
			}
		}
	}

	// =========================================================================
	// MEDUSA ABILITIES (CARRY)
	// =========================================================================

	"enfos_medusa_split_shot"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_TOGGLE"
		"AbilityTextureName"		"medusa_split_shot"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"arrow_count"		"4 5 6 7"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_pct"		"-45 -35 -25 -15"
			}
		}

		"OnToggleOn"
		{
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_medusa_split_shot"
				"Target"			"CASTER"
			}
		}

		"OnToggleOff"
		{
			"RemoveModifier"
			{
				"ModifierName"		"modifier_enfos_medusa_split_shot"
				"Target"			"CASTER"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_medusa_split_shot"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE" "%damage_pct"
				}
			}
		}
	}

	"enfos_medusa_mystic_snake"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"medusa_mystic_snake"
		"AbilityCastRange"			"700"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"11.0"
		"AbilityManaCost"			"120 130 140 150"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"base_damage"		"120 180 240 300"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"jump_count"		"4 5 6 7"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Medusa.MysticSnake.Cast"
				"Target"			"CASTER"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%base_damage"
			}
		}
	}

	"enfos_medusa_mana_shield"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"medusa_mana_shield"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"damage_per_mana"	"1.8 2.2 2.6 3.0"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_mana"		"150 250 350 450"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_mana_shield"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MANA_BONUS" "%bonus_mana"
				}
			}
		}
	}

	"enfos_medusa_stone_gaze"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityTextureName"		"medusa_stone_gaze"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"150"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"5.0 6.0 7.0"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-35"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"900"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Medusa.StoneGaze.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_stone_gaze_debuff"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_stone_gaze_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}

	"enfos_medusa_gorgon_gaze"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"medusa_cold_blooded"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"25"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_range"		"75"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_gorgon_gaze"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
					"MODIFIER_PROPERTY_ATTACK_RANGE_BONUS" "%bonus_range"
				}
			}
		}
	}

	// =========================================================================
	// TERRORBLADE ABILITIES (CARRY)
	// =========================================================================

	"enfos_tb_reflection"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityTextureName"		"terrorblade_reflection"
		"AbilityCastRange"			"700"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"16.0 14.0 12.0 10.0"
		"AbilityManaCost"			"50"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"700"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-25 -30 -35 -40"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"5.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Terrorblade.Reflection"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_reflection_debuff"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_reflection_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}

	"enfos_tb_conjure_image"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityTextureName"		"terrorblade_conjure_image"
		"AbilityCastPoint"			"0.15"
		"AbilityCooldown"			"16.0"
		"AbilityManaCost"			"55 65 75 85"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"20 35 50 65"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"25.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Terrorblade.ConjureImage"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_conjure_image_buff"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_conjure_image_buff"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_tb_metamorphosis"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityTextureName"		"terrorblade_metamorphosis"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"100"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"35 60 85 110"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_range"		"400"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"35.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Terrorblade.Metamorphosis"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_metamorphosis"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_metamorphosis"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
					"MODIFIER_PROPERTY_ATTACK_RANGE_BONUS" "%bonus_range"
				}
			}
		}
	}

	"enfos_tb_sunder"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_BOTH"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"terrorblade_sunder"
		"AbilityCastRange"			"475"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"45.0 35.0 25.0"
		"AbilityManaCost"			"100 75 50"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"heal_amount"		"400 700 1000"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Terrorblade.Sunder.Cast"
				"Target"			"CASTER"
			}
			"Heal"
			{
				"Target"			"CASTER"
				"HealAmount"		"%heal_amount"
			}
		}
	}

	"enfos_tb_demon_zeal"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"terrorblade_terror_wave"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_as"			"25"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms"			"20"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_demon_zeal"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_as"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT" "%bonus_ms"
				}
			}
		}
	}

	// =========================================================================
	// STORM SPIRIT ABILITIES (MAGE)
	// =========================================================================

	"enfos_storm_static_remnant"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"storm_spirit_static_remnant"
		"AbilityCastPoint"			"0.0"
		"AbilityCooldown"			"3.5"
		"AbilityManaCost"			"70 80 90 100"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"120 180 240 300"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"300"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_StormSpirit.StaticRemnantPlant"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_storm_electric_vortex"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"storm_spirit_electric_vortex"
		"AbilityCastRange"			"450"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"16.0 14.0 12.0 10.0"
		"AbilityManaCost"			"60 70 80 90"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"1.5 2.0 2.5 3.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_StormSpirit.ElectricVortex"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_stunned"
				"Target"			"TARGET"
				"Duration"			"%duration"
			}
		}
	}

	"enfos_storm_overload"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"storm_spirit_overload"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"35 60 85 110"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_overload"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_storm_ball_lightning"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"storm_spirit_ball_lightning"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"0.0"
		"AbilityManaCost"			"60 90 120"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"200 350 500"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"350"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_StormSpirit.BallLightning.Loop"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_storm_galvanic_core"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"storm_spirit_electric_rave"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"mana_regen"		"6"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_int"			"15"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_galvanic_core"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MANA_REGEN_CONSTANT" "%mana_regen"
					"MODIFIER_PROPERTY_STATS_INTELLECT_BONUS" "%bonus_int"
				}
			}
		}
	}

	// =========================================================================
	// LESHRAC ABILITIES (MAGE)
	// =========================================================================

	"enfos_leshrac_split_earth"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"leshrac_split_earth"
		"AbilityCastRange"			"750"
		"AbilityCastPoint"			"0.35"
		"AbilityCooldown"			"9.0"
		"AbilityManaCost"			"80 100 120 140"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"120 180 240 300"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"350"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.4 1.7 2.0 2.3"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Leshrac.Split_Earth"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_stunned"
						"Target"	"TARGET"
						"Duration"	"%stun_duration"
					}
				}
			}
		}
	}

	"enfos_leshrac_diabolic_edict"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PURE"
		"AbilityTextureName"		"leshrac_diabolic_edict"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"22.0 19.0 16.0 13.0"
		"AbilityManaCost"			"90 110 130 150"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_per_explosion" "24 38 52 66"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"500"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"10.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Leshrac.Diabolic_Edict"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_diabolic_edict"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_diabolic_edict"
			{
				"ThinkInterval"		"0.5"
				"OnIntervalThink"
				{
					"ActOnTargets"
					{
						"Target"
						{
							"Center"	"CASTER"
							"Radius"	"%radius"
							"Teams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
							"Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
						}
						"Action"
						{
							"Damage"
							{
								"Target" "TARGET"
								"Type"	"DAMAGE_TYPE_PURE"
								"Damage" "%damage_per_explosion"
							}
						}
					}
				}
			}
		}
	}

	"enfos_leshrac_lightning_storm"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"leshrac_lightning_storm"
		"AbilityCastRange"			"750"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"6.0 5.0 4.0 3.0"
		"AbilityManaCost"			"70 80 90 100"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"90 150 210 270"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"jump_count"		"5 7 9 11"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Leshrac.Lightning_Storm"
				"Target"			"CASTER"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
		}
	}

	"enfos_leshrac_pulse_nova"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_TOGGLE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"leshrac_pulse_nova"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"100 160 220"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"525"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"mana_cost_per_sec"	"40 60 80"
			}
		}

		"OnToggleOn"
		{
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_pulse_nova"
				"Target"			"CASTER"
			}
		}

		"OnToggleOff"
		{
			"RemoveModifier"
			{
				"ModifierName"		"modifier_enfos_pulse_nova"
				"Target"			"CASTER"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_pulse_nova"
			{
				"ThinkInterval"		"1.0"
				"OnIntervalThink"
				{
					"ActOnTargets"
					{
						"Target"
						{
							"Center"	"CASTER"
							"Radius"	"%radius"
							"Teams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
							"Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
						}
						"Action"
						{
							"Damage"
							{
								"Target" "TARGET"
								"Type"	"DAMAGE_TYPE_MAGICAL"
								"Damage" "%damage"
							}
						}
					}
				}
			}
		}
	}

	"enfos_leshrac_defilement"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"leshrac_pulse_nova"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"spell_lifesteal"	"15"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_int"			"15"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_defilement"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_STATS_INTELLECT_BONUS" "%bonus_int"
				}
			}
		}
	}

	// =========================================================================
	// INVOKER ABILITIES (MAGE)
	// =========================================================================

	"enfos_invoker_chaos_meteor"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"invoker_chaos_meteor"
		"AbilityCastRange"			"800"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"24.0 20.0 16.0 12.0"
		"AbilityManaCost"			"120 140 160 180"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"impact_damage"		"200 320 440 560"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"375"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Invoker.ChaosMeteor.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%impact_damage"
					}
				}
			}
		}
	}

	"enfos_invoker_sun_strike"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PURE"
		"AbilityTextureName"		"invoker_sun_strike"
		"AbilityCastRange"			"9999"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"20.0 18.0 16.0 14.0"
		"AbilityManaCost"			"120 140 160 180"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"250 375 500 625"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"300"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Invoker.SunStrike.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_PURE"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_invoker_deafening_blast"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"invoker_deafening_blast"
		"AbilityCastRange"			"800"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"18.0 16.0 14.0 12.0"
		"AbilityManaCost"			"100 120 140 160"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"120 200 280 360"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"disarm_duration"	"2.0 2.5 3.0 3.5"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"800"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Invoker.DeafeningBlast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_invoker_emp"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PURE"
		"AbilityTextureName"		"invoker_emp"
		"AbilityCastRange"			"900"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"30.0 25.0 20.0"
		"AbilityManaCost"			"125 150 175"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"300 450 600"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"675"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Invoker.EMP.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_PURE"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_invoker_alacrity"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"invoker_alacrity"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_as"			"30"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"25"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_alacrity"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_as"
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	// =========================================================================
	// PUCK ABILITIES (MAGE)
	// =========================================================================

	"enfos_puck_illusory_orb"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"puck_illusory_orb"
		"AbilityCastRange"			"1100"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"11.0 10.0 9.0 8.0"
		"AbilityManaCost"			"80 95 110 125"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"110 180 250 320"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"1100"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Puck.Illusory_Orb"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_puck_waning_rift"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"puck_waning_rift"
		"AbilityCastRange"			"400"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"13.0 12.0 11.0 10.0"
		"AbilityManaCost"			"100"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"100 160 220 280"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"400"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"silence_duration"	"2.0 2.5 3.0 3.5"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Puck.Waning_Rift"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_silence"
						"Target"	"TARGET"
						"Duration"	"%silence_duration"
					}
				}
			}
		}
	}

	"enfos_puck_phase_shift"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_CHANNELLED"
		"AbilityTextureName"		"puck_phase_shift"
		"AbilityCastPoint"			"0.0"
		"AbilityChannelTime"		"3.25"
		"AbilityCooldown"			"8.0 7.0 6.0 5.0"
		"AbilityManaCost"			"0"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"3.25"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Puck.Phase_Shift"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_invulnerable"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}
	}

	"enfos_puck_dream_coil"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"puck_dream_coil"
		"AbilityCastRange"			"750"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"100 150 200"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"initial_damage"	"150 250 350"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"snap_damage"		"300 450 600"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"400"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"coil_duration"		"6.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Puck.Dream_Coil"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%initial_damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_rooted"
						"Target"	"TARGET"
						"Duration"	"%coil_duration"
					}
				}
			}
		}
	}

	"enfos_puck_faerie_magic"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"puck_phase_shift"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms"			"25"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_spell_amp"	"10"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_faerie_magic"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT" "%bonus_ms"
				}
			}
		}
	}

	// =========================================================================
	// LION ABILITIES (SUPPORT)
	// =========================================================================

	"enfos_lion_earth_spike"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"lion_impale"
		"AbilityCastRange"			"825"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"12.0"
		"AbilityManaCost"			"90 110 130 150"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"110 180 250 320"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.4 1.8 2.2 2.6"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"825"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lion.Impale"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_stunned"
						"Target"	"TARGET"
						"Duration"	"%stun_duration"
					}
				}
			}
		}
	}

	"enfos_lion_hex"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"lion_voodoo"
		"AbilityCastRange"			"550"
		"AbilityCastPoint"			"0.1"
		"AbilityCooldown"			"15.0 14.0 13.0 12.0"
		"AbilityManaCost"			"120 140 160 180"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"2.5 3.0 3.5 4.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lion.Voodoo"
				"Target"			"TARGET"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_sheepstick_debuff"
				"Target"			"TARGET"
				"Duration"			"%duration"
			}
		}
	}

	"enfos_lion_mana_drain"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_CHANNELLED"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"lion_mana_drain"
		"AbilityCastRange"			"850"
		"AbilityCastPoint"			"0.3"
		"AbilityChannelTime"		"4.0"
		"AbilityCooldown"			"14.0 12.0 10.0 8.0"
		"AbilityManaCost"			"10"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"mana_per_second"	"40 70 100 130"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lion.ManaDrain"
				"Target"			"CASTER"
			}
		}

		"OnChannelThink"
		{
			"GiveMana"
			{
				"Target"			"CASTER"
				"ManaAmount"		"30"
			}
		}
	}

	"enfos_lion_finger_of_death"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"lion_finger_of_death"
		"AbilityCastRange"			"900"
		"AbilityCastPoint"			"0.4"
		"AbilityCooldown"			"60.0 45.0 30.0"
		"AbilityManaCost"			"200 350 500"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"600 900 1200"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"splash_radius"		"350"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lion.FingerOfDeath"
				"Target"			"TARGET"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%splash_radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
				}
			}
		}
	}

	"enfos_lion_demon_soul"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"lion_finger_of_death"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"cast_range_bonus"	"125"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_mana_regen"	"4"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_lion_demon_soul"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_CAST_RANGE_BONUS" "%cast_range_bonus"
					"MODIFIER_PROPERTY_MANA_REGEN_CONSTANT" "%bonus_mana_regen"
				}
			}
		}
	}

	// =========================================================================
	// JAKIRO ABILITIES (SUPPORT)
	// =========================================================================

	"enfos_jakiro_dual_breath"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"jakiro_dual_breath"
		"AbilityCastRange"			"750"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"10.0"
		"AbilityManaCost"			"100 115 130 145"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"100 170 240 310"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-28 -32 -36 -40"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"5.0"
			}
			"04"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"750"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Jakiro.DualBreath.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_dual_breath_slow"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_dual_breath_slow"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}

	"enfos_jakiro_ice_path"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"jakiro_ice_path"
		"AbilityCastRange"			"1100"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"18.0 15.0 12.0 9.0"
		"AbilityManaCost"			"90"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"80 140 200 260"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.5 2.0 2.5 3.0"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"1100"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Jakiro.IcePath.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_stunned"
						"Target"	"TARGET"
						"Duration"	"%stun_duration"
					}
				}
			}
		}
	}

	"enfos_jakiro_liquid_fire"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"jakiro_liquid_fire"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"25 45 65 85"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_liquid_fire"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE" "%bonus_damage"
				}
			}
		}
	}

	"enfos_jakiro_macropyre"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"jakiro_macropyre"
		"AbilityCastRange"			"1400"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"150 200 250"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_per_sec"	"120 180 240"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"10.0"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"length"			"1400"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Jakiro.Macropyre.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%length"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage_per_sec"
					}
				}
			}
		}
	}

	"enfos_jakiro_double_trouble"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"jakiro_dual_breath"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_int"			"15"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_as"			"20"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_double_trouble"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_STATS_INTELLECT_BONUS" "%bonus_int"
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_as"
				}
			}
		}
	}

	// =========================================================================
	// VENGEFUL SPIRIT ABILITIES (SUPPORT)
	// =========================================================================

	"enfos_vs_magic_missile"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"vengefulspirit_magic_missile"
		"AbilityCastRange"			"650"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"10.0 9.0 8.0 7.0"
		"AbilityManaCost"			"90 100 110 120"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"120 190 260 330"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.5 1.7 1.9 2.1"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_VengefulSpirit.MagicMissile"
				"Target"			"CASTER"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_stunned"
				"Target"			"TARGET"
				"Duration"			"%stun_duration"
			}
		}
	}

	"enfos_vs_wave_of_terror"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"vengefulspirit_wave_of_terror"
		"AbilityCastRange"			"1400"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"12.0 11.0 10.0 9.0"
		"AbilityManaCost"			"40"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"80 130 180 230"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"armor_reduction"	"-3 -4 -5 -6"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"8.0"
			}
			"04"
			{
				"var_type"			"FIELD_INTEGER"
				"range"				"1400"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_VengefulSpirit.WaveOfTerror"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"CASTER"
					"Radius"		"%range"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_wave_of_terror_debuff"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_wave_of_terror_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%armor_reduction"
				}
			}
		}
	}

	"enfos_vs_vengeance_aura"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"vengefulspirit_command_aura"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage_pct"	"12 18 24 30"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_vengeance_aura"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE" "%bonus_damage_pct"
				}
			}
		}
	}

	"enfos_vs_nether_swap"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_BOTH"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"vengefulspirit_nether_swap"
		"AbilityCastRange"			"700 850 1000"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"40.0 30.0 20.0"
		"AbilityManaCost"			"100 150 200"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"250 400 550"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_VengefulSpirit.NetherSwap"
				"Target"			"CASTER"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
		}
	}

	"enfos_vs_retribution"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"vengefulspirit_command_aura"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_agi"			"15"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_as"			"20"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_vs_retribution"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_STATS_AGILITY_BONUS" "%bonus_agi"
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_as"
				}
			}
		}
	}

	// =========================================================================
	// LICH ABILITIES (SUPPORT)
	// =========================================================================

	"enfos_lich_frost_blast"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"lich_frost_nova"
		"AbilityCastRange"			"600"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"7.0"
		"AbilityManaCost"			"105 120 135 150"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"target_damage"		"100 170 240 310"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"300"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-30"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"4.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lich.FrostNova"
				"Target"			"TARGET"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"		"TARGET"
					"Radius"		"%radius"
					"Teams"			"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"			"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%target_damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_frost_blast_slow"
						"Target"	"TARGET"
						"Duration"	"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_frost_blast_slow"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}

	"enfos_lich_frost_shield"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_FRIENDLY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"lich_frost_shield"
		"AbilityCastRange"			"750"
		"AbilityCastPoint"			"0.2"
		"AbilityCooldown"			"20.0 17.0 14.0 11.0"
		"AbilityManaCost"			"90 100 110 120"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_reduction"	"-30 -40 -50 -60"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"6.0"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lich.FrostShield"
				"Target"			"TARGET"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_frost_shield"
				"Target"			"TARGET"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_frost_shield"
			{
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE" "%damage_reduction"
				}
			}
		}
	}

	"enfos_lich_sinister_gaze"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_CHANNELLED"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"lich_sinister_gaze"
		"AbilityCastRange"			"600"
		"AbilityCastPoint"			"0.3"
		"AbilityChannelTime"		"2.5"
		"AbilityCooldown"			"24.0 21.0 18.0 15.0"
		"AbilityManaCost"			"80"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"1.6 1.9 2.2 2.5"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lich.SinisterGaze.Cast"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_stunned"
				"Target"			"TARGET"
				"Duration"			"%duration"
			}
		}
	}

	"enfos_lich_chain_frost"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"AbilityTextureName"		"lich_chain_frost"
		"AbilityCastRange"			"850"
		"AbilityCastPoint"			"0.4"
		"AbilityCooldown"			"60.0 50.0 40.0"
		"AbilityManaCost"			"180 240 300"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"300 450 600"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"jump_count"		"10 15 20"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lich.ChainFrost"
				"Target"			"TARGET"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
		}
	}

	"enfos_lich_ice_aura"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"lich_frost_shield"
		"MaxLevel"					"1"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_armor"		"6"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"mana_regen"		"4"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_ice_aura"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%bonus_armor"
					"MODIFIER_PROPERTY_MANA_REGEN_CONSTANT" "%mana_regen"
				}
			}
		}
	}
`;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Generate Turkish Localization Tokens
// ─────────────────────────────────────────────────────────────────────────────
const TURKISH_HERO_TOKENS = {
  // Tidehunter
  "DOTA_Tooltip_Ability_enfos_tide_gush": "Su Fışkırtması",
  "DOTA_Tooltip_Ability_enfos_tide_gush_Description": "Hedefe ve arkasındaki düşmanlara basınçlı su fışkırtarak {{gush_damage}} büyü hasarı verir, zırhlarını {{duration}} saniye boyunca {{armor_reduction}} azaltır ve onları yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_tide_kraken_shell": "Kraken Kabuğu",
  "DOTA_Tooltip_Ability_enfos_tide_kraken_shell_Description": "Gelen her fiziksel hasarın {{damage_reduction}} miktarını pasif olarak bloklar ve +{{bonus_hp_regen}} can yenilenmesi sağlar.",
  "DOTA_Tooltip_Ability_enfos_tide_anchor_smash": "Çapa Vuruşu",
  "DOTA_Tooltip_Ability_enfos_tide_anchor_smash_Description": "Ağır çapasını {{radius}} menzilde savurarak düşmanlara {{attack_damage_bonus}} fiziksel hasar verir ve saldırı güçlerini {{duration}} saniye boyunca %{{damage_reduction}} azaltır.",
  "DOTA_Tooltip_Ability_enfos_tide_ravage": "Yıkım",
  "DOTA_Tooltip_Ability_enfos_tide_ravage_Description": "Yer altından devasa dokunaç dalgaları fırlatarak {{radius}} menzildeki tüm yaratıklara {{damage}} büyü hasarı verir ve onları {{stun_duration}} saniye sersemletir.",
  "DOTA_Tooltip_Ability_enfos_tide_colossal_presence": "Devasa Varlık",
  "DOTA_Tooltip_Ability_enfos_tide_colossal_presence_Description": "Doğuştan gelen kadim deniz devi cüssesiyle pasif olarak +{{bonus_health}} azami can ve +{{bonus_armor}} zırh kazanır.",

  // Dragon Knight
  "DOTA_Tooltip_Ability_enfos_dk_breathe_fire": "Alev Nefesi",
  "DOTA_Tooltip_Ability_enfos_dk_breathe_fire_Description": "Önündeki koni alanda kor gibi alev püskürterek {{damage}} büyü hasarı verir ve yaratıkların hasarını {{duration}} saniye boyunca %{{reduction_pct}} azaltır.",
  "DOTA_Tooltip_Ability_enfos_dk_dragon_tail": "Ejder Kuyruğu",
  "DOTA_Tooltip_Ability_enfos_dk_dragon_tail_Description": "Hedefe güçlü kalkanıyla vurarak {{damage}} hasar verir ve onu {{stun_duration}} saniye sersemletir.",
  "DOTA_Tooltip_Ability_enfos_dk_dragon_blood": "Ejderha Kanı",
  "DOTA_Tooltip_Ability_enfos_dk_dragon_blood_Description": "Damarlarındaki ejderha kanı sayesinde pasif olarak +{{bonus_armor}} zırh ve +{{bonus_hp_regen}} can yenilenmesi kazanır.",
  "DOTA_Tooltip_Ability_enfos_dk_elder_dragon_form": "Ulu Ejder Formu",
  "DOTA_Tooltip_Ability_enfos_dk_elder_dragon_form_Description": "{{duration}} saniye boyunca kudretli bir ejderhaya dönüşür. Menzilli saldırılar yapar, saldırıları alana sıçrar ve +{{bonus_damage}} hasar kazanır.",
  "DOTA_Tooltip_Ability_enfos_dk_wyrm_vigor": "Ejderha Kudreti",
  "DOTA_Tooltip_Ability_enfos_dk_wyrm_vigor_Description": "Pasif olarak +%{{magic_resist}} büyü direnci ve +{{bonus_strength}} güç bahşeder.",

  // Pudge
  "DOTA_Tooltip_Ability_enfos_pudge_meat_hook": "Et Kancası",
  "DOTA_Tooltip_Ability_enfos_pudge_meat_hook_Description": "Düz bir hatta kanlı kanca fırlatarak yakaladığı düşmana {{hook_damage}} saf hasar vurur ve onu Pudge'a doğru çeker.",
  "DOTA_Tooltip_Ability_enfos_pudge_rot": "Çürüme",
  "DOTA_Tooltip_Ability_enfos_pudge_rot_Description": "Etrafına zehirli gaz yayarak {{rot_radius}} menzildeki yaratıkları yavaşlatır ve her saniye {{rot_damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_pudge_flesh_heap": "Et Yığını",
  "DOTA_Tooltip_Ability_enfos_pudge_flesh_heap_Description": "Gelen fiziksel hasarları {{damage_block}} puan bloklar ve pasif olarak +{{bonus_strength}} güç kazandırır.",
  "DOTA_Tooltip_Ability_enfos_pudge_dismember": "Parçalara Ayır",
  "DOTA_Tooltip_Ability_enfos_pudge_dismember_Description": "Hedefi sersemleterek çiğner, saniye başına {{dps}} büyü hasarı verir ve bu hasar kadar Pudge'ı iyileştirir.",
  "DOTA_Tooltip_Ability_enfos_pudge_meat_shield": "Et Kalkanı",
  "DOTA_Tooltip_Ability_enfos_pudge_meat_shield_Description": "Kalın yağ tabakası pasif olarak +%{{magic_resist}} büyü direnci ve +{{bonus_hp}} azami can sağlar.",

  // Underlord
  "DOTA_Tooltip_Ability_enfos_underlord_firestorm": "Ateş Fırtınası",
  "DOTA_Tooltip_Ability_enfos_underlord_firestorm_Description": "Hedef bölgeye gökten {{wave_count}} dalga alev yağdırır. Her dalga {{wave_damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_underlord_pit_of_malice": "Kötülük Çukuru",
  "DOTA_Tooltip_Ability_enfos_underlord_pit_of_malice_Description": "Açılan karanlık çukur üzerindeki yaratıkları {{ensnare_duration}} saniye boyunca yere sabitler.",
  "DOTA_Tooltip_Ability_enfos_underlord_atrophy_aura": "Körelme Halesi",
  "DOTA_Tooltip_Ability_enfos_underlord_atrophy_aura_Description": "Düşmanların saldırı hasarını pasif olarak azaltır ve Underlord'a +{{bonus_damage}} bonus saldırı gücü verir.",
  "DOTA_Tooltip_Ability_enfos_underlord_dark_rift": "Karanlık Yırtık",
  "DOTA_Tooltip_Ability_enfos_underlord_dark_rift_Description": "Abis yarığı açarak {{radius}} menzildeki tüm yaratıklara {{burst_damage}} yoğun karanlık büyü hasarı patlatır.",
  "DOTA_Tooltip_Ability_enfos_underlord_abyssal_carapace": "Abis Kabuğu",
  "DOTA_Tooltip_Ability_enfos_underlord_abyssal_carapace_Description": "Pasif olarak +{{bonus_armor}} zırh ve +{{bonus_hp}} azami can kazandırır.",

  // Ursa
  "DOTA_Tooltip_Ability_enfos_ursa_earthshock": "Yer Sarsıntısı",
  "DOTA_Tooltip_Ability_enfos_ursa_earthshock_Description": "Yere güçlü bir darbe indirerek {{radius}} menzildeki yaratıklara {{damage}} büyü hasarı verir ve hareket hızlarını yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_ursa_overpower": "Ezici Güç",
  "DOTA_Tooltip_Ability_enfos_ursa_overpower_Description": "Sıradaki {{max_attacks}} saldırısı için saldırı hızını azami seviyeye (+{{attack_speed}}) çıkarır.",
  "DOTA_Tooltip_Ability_enfos_ursa_fury_swipes": "Öfke Pençeleri",
  "DOTA_Tooltip_Ability_enfos_ursa_fury_swipes_Description": "Saldırıları pasif olarak her vuruşta +{{bonus_damage}} artan hasar uygular.",
  "DOTA_Tooltip_Ability_enfos_ursa_enrage": "Hiddet",
  "DOTA_Tooltip_Ability_enfos_ursa_enrage_Description": "{{duration}} saniye boyunca gelen tüm hasarları %{{damage_reduction}} azaltır.",
  "DOTA_Tooltip_Ability_enfos_ursa_ursa_minor": "Bozayı Çevikliği",
  "DOTA_Tooltip_Ability_enfos_ursa_ursa_minor_Description": "Pasif olarak +{{bonus_ms}} hareket hızı ve vuruşlarda can çalma sağlar.",

  // Monkey King
  "DOTA_Tooltip_Ability_enfos_mk_boundless_strike": "Sonsuz Darbe",
  "DOTA_Tooltip_Ability_enfos_mk_boundless_strike_Description": "Asasını {{range}} menzillik bir hatta yere vurarak yaratıklara {{strike_damage}} fiziksel hasar verir ve onları sersemletir.",
  "DOTA_Tooltip_Ability_enfos_mk_primal_spring": "İlkel Sıçrayış",
  "DOTA_Tooltip_Ability_enfos_mk_primal_spring_Description": "Havaya yükselip hedef alana çarparak {{spring_damage}} büyü hasarı verir ve yaratıkları yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_mk_jingu_mastery": "Jingu Ustalığı",
  "DOTA_Tooltip_Ability_enfos_mk_jingu_mastery_Description": "Saldırı gücünü pasif olarak +{{bonus_damage}} artırır ve can çalma kazandırır.",
  "DOTA_Tooltip_Ability_enfos_mk_wukongs_command": "Wukong'un Ordusu",
  "DOTA_Tooltip_Ability_enfos_mk_wukongs_command_Description": "Bir asker halkası çağırarak {{ring_radius}} alandaki yaratıklara periyodik {{soldier_damage}} darbe indirir.",
  "DOTA_Tooltip_Ability_enfos_mk_mischief": "Muziplik",
  "DOTA_Tooltip_Ability_enfos_mk_mischief_Description": "Pasif olarak saldırı menzilini +{{bonus_range}} ve savuşturma şansını %{{evasion_pct}} artırır.",

  // Troll Warlord
  "DOTA_Tooltip_Ability_enfos_troll_berserkers_rage": "Delişmen Öfkesi",
  "DOTA_Tooltip_Ability_enfos_troll_berserkers_rage_Description": "Yakın dövüş duruşuna geçerek +{{bonus_armor}} zırh ve +{{bonus_ms}} hareket hızı kazanır.",
  "DOTA_Tooltip_Ability_enfos_troll_whirling_axes": "Dönen Baltalar",
  "DOTA_Tooltip_Ability_enfos_troll_whirling_axes_Description": "Çevresinde baltalar savurarak {{radius}} menzildeki yaratıklara {{damage}} büyü hasarı verir ve onları kör eder.",
  "DOTA_Tooltip_Ability_enfos_troll_fervor": "Coşku",
  "DOTA_Tooltip_Ability_enfos_troll_fervor_Description": "Ardı ardına yapılan saldırılarla pasif olarak saldırı hızını +{{attack_speed}} artırır.",
  "DOTA_Tooltip_Ability_enfos_troll_battle_trance": "Savaş Transı",
  "DOTA_Tooltip_Ability_enfos_troll_battle_trance_Description": "Durdurulamaz bir hiddete girerek +{{bonus_as}} saldırı hızı kazanır ve ölümcül hasara karşı dayanır.",
  "DOTA_Tooltip_Ability_enfos_troll_rampage": "Vahşet",
  "DOTA_Tooltip_Ability_enfos_troll_rampage_Description": "Pasif olarak saldırı gücünü +{{bonus_damage}} ve statü direncini artırır.",

  // Chaos Knight
  "DOTA_Tooltip_Ability_enfos_ck_chaos_bolt": "Kaos Oku",
  "DOTA_Tooltip_Ability_enfos_ck_chaos_bolt_Description": "Hedefe kaotik enerji fırlatarak {{damage}} büyü hasarı verir ve onu rastgele süreli sersemletir.",
  "DOTA_Tooltip_Ability_enfos_ck_reality_rift": "Gerçeklik Yarığı",
  "DOTA_Tooltip_Ability_enfos_ck_reality_rift_Description": "Hedefi ve Kaos Şövalyesini bir araya çekerek hedefin zırhını {{duration}} saniye boyunca {{armor_reduction}} kırar.",
  "DOTA_Tooltip_Ability_enfos_ck_chaos_strike": "Kaos Vuruşu",
  "DOTA_Tooltip_Ability_enfos_ck_chaos_strike_Description": "Saldırılarda pasif olarak +{{bonus_damage}} bonus hasar ve kritik vuruş şansı sağlar.",
  "DOTA_Tooltip_Ability_enfos_ck_phantasm": "Fantezi Ordusu",
  "DOTA_Tooltip_Ability_enfos_ck_phantasm_Description": "Kendi suretinde güçlü yanılsamalar oluşturur ve +{{bonus_damage}} ek hasar kazanır.",
  "DOTA_Tooltip_Ability_enfos_ck_entropy": "Entropi",
  "DOTA_Tooltip_Ability_enfos_ck_entropy_Description": "Pasif olarak +{{bonus_strength}} güç ve +{{bonus_speed}} saldırı hızı bahşeder.",

  // Anti-Mage
  "DOTA_Tooltip_Ability_enfos_am_mana_break": "Mana Kırma",
  "DOTA_Tooltip_Ability_enfos_am_mana_break_Description": "Saldırılarına büyü bozucu enerji katarak her vuruşta +{{bonus_damage}} ek fiziksel hasar vurur.",
  "DOTA_Tooltip_Ability_enfos_am_blink": "Göz Kırpma",
  "DOTA_Tooltip_Ability_enfos_am_blink_Description": "{{blink_range}} menzile anında ışınlanır.",
  "DOTA_Tooltip_Ability_enfos_am_counterspell": "Büyü Kalkanı",
  "DOTA_Tooltip_Ability_enfos_am_counterspell_Description": "Pasif olarak +%{{magic_resist}} büyü direnci bahşeder.",
  "DOTA_Tooltip_Ability_enfos_am_mana_void": "Mana Boşluğu",
  "DOTA_Tooltip_Ability_enfos_am_mana_void_Description": "Hedef üzerinde patlama yaratarak {{radius}} menzildeki tüm yaratıklara {{base_damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_am_spellbreaker": "Büyü Kırıcı",
  "DOTA_Tooltip_Ability_enfos_am_spellbreaker_Description": "Pasif olarak +{{bonus_as}} saldırı hızı ve +{{bonus_ms}} hareket hızı sağlar.",

  // Faceless Void
  "DOTA_Tooltip_Ability_enfos_void_time_walk": "Zaman Yürüyüşü",
  "DOTA_Tooltip_Ability_enfos_void_time_walk_Description": "Hedef noktaya {{range}} birim atılarak son saniyelerde alınan hasarı geri alır.",
  "DOTA_Tooltip_Ability_enfos_void_time_dilation": "Zaman Genişlemesi",
  "DOTA_Tooltip_Ability_enfos_void_time_dilation_Description": "{{radius}} menzildeki yaratıkları zaman durgunluğuna hapsederek yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_void_time_lock": "Zaman Kilidi",
  "DOTA_Tooltip_Ability_enfos_void_time_lock_Description": "Saldırılarda pasif olarak +{{bonus_damage}} bonus hasar ve zamanı dondurma şansı verir.",
  "DOTA_Tooltip_Ability_enfos_void_chronosphere": "Kronosfer",
  "DOTA_Tooltip_Ability_enfos_void_chronosphere_Description": "{{radius}} menzilde zamanı donduran bir küre yaratır. İçindeki yaratıklar {{duration}} saniye boyunca tamamen hareketsiz kalır.",
  "DOTA_Tooltip_Ability_enfos_void_backtrack": "Geçmişe Dönüş",
  "DOTA_Tooltip_Ability_enfos_void_backtrack_Description": "Gelen saldırı ve büyü hasarlarını pasif olarak %{{dodge_pct}} şansla tamamen savuşturur.",

  // Medusa
  "DOTA_Tooltip_Ability_enfos_medusa_split_shot": "Çoklu Atış",
  "DOTA_Tooltip_Ability_enfos_medusa_split_shot_Description": "Oklarını aynı anda {{arrow_count}} hedefe birden fırlatır.",
  "DOTA_Tooltip_Ability_enfos_medusa_mystic_snake": "Mistik Yılan",
  "DOTA_Tooltip_Ability_enfos_medusa_mystic_snake_Description": "Düşmanlar arasında {{jump_count}} kez seken ve her sekmede {{base_damage}} büyü hasarı veren bir enerji yılanı fırlatır.",
  "DOTA_Tooltip_Ability_enfos_medusa_mana_shield": "Mana Kalkanı",
  "DOTA_Tooltip_Ability_enfos_medusa_mana_shield_Description": "Gelen hasarı emen koruyucu bir bariyer ve pasif +{{bonus_mana}} azami mana sağlar.",
  "DOTA_Tooltip_Ability_enfos_medusa_stone_gaze": "Taşlaştıran Bakış",
  "DOTA_Tooltip_Ability_enfos_medusa_stone_gaze_Description": "{{radius}} alandaki yaratıkları yavaşlatır ve taşa dönüştürerek aldıkları hasarı artırır.",
  "DOTA_Tooltip_Ability_enfos_medusa_gorgon_gaze": "Gorgon Gazabı",
  "DOTA_Tooltip_Ability_enfos_medusa_gorgon_gaze_Description": "Pasif olarak saldırı gücünü +{{bonus_damage}} ve menzilini +{{bonus_range}} artırır.",

  // Terrorblade
  "DOTA_Tooltip_Ability_enfos_tb_reflection": "Yansıma",
  "DOTA_Tooltip_Ability_enfos_tb_reflection_Description": "{{radius}} alandaki yaratıkların karanlık yansımalarını oluşturarak onları yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_tb_conjure_image": "Suret Yarat",
  "DOTA_Tooltip_Ability_enfos_tb_conjure_image_Description": "Kendisine +{{bonus_damage}} ek hasar kazandıran bir suret çağırır.",
  "DOTA_Tooltip_Ability_enfos_tb_metamorphosis": "Başkalaşım",
  "DOTA_Tooltip_Ability_enfos_tb_metamorphosis_Description": "{{duration}} saniye boyunca korkunç bir iblise dönüşerek +{{bonus_damage}} saldırı gücü ve menzil kazanır.",
  "DOTA_Tooltip_Ability_enfos_tb_sunder": "Ruh Takası",
  "DOTA_Tooltip_Ability_enfos_tb_sunder_Description": "Hedefin yaşam enerjisini çekerek Terrorblade'i anında {{heal_amount}} can iyileştirir.",
  "DOTA_Tooltip_Ability_enfos_tb_demon_zeal": "İblis Şevki",
  "DOTA_Tooltip_Ability_enfos_tb_demon_zeal_Description": "Pasif olarak +{{bonus_as}} saldırı hızı ve +{{bonus_ms}} hareket hızı bahşeder.",

  // Storm Spirit
  "DOTA_Tooltip_Ability_enfos_storm_static_remnant": "Statik Kalıntı",
  "DOTA_Tooltip_Ability_enfos_storm_static_remnant_Description": "Olduğu yere bir elektrik kalıntısı bırakır; düşman yaklaştığında patlayarak {{damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_storm_electric_vortex": "Elektrik Girdabı",
  "DOTA_Tooltip_Ability_enfos_storm_electric_vortex_Description": "Hedefi manyetik çekimle kendine doğru çeker ve sersemletir.",
  "DOTA_Tooltip_Ability_enfos_storm_overload": "Aşırı Yükleme",
  "DOTA_Tooltip_Ability_enfos_storm_overload_Description": "Saldırılarına pasif olarak +{{bonus_damage}} elektrik hasarı ekler.",
  "DOTA_Tooltip_Ability_enfos_storm_ball_lightning": "Yıldırım Küresi",
  "DOTA_Tooltip_Ability_enfos_storm_ball_lightning_Description": "Saf elektriğe dönüşerek hedef alana uçar ve çarptığı yaratıklara {{damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_storm_galvanic_core": "Galvanik Çekirdek",
  "DOTA_Tooltip_Ability_enfos_storm_galvanic_core_Description": "Pasif olarak +{{mana_regen}} mana yenilenmesi ve +{{bonus_int}} zeka kazandırır.",

  // Leshrac
  "DOTA_Tooltip_Ability_enfos_leshrac_split_earth": "Toprak Yarığı",
  "DOTA_Tooltip_Ability_enfos_leshrac_split_earth_Description": "Toprağı yararak {{radius}} menzildeki yaratıklara {{damage}} büyü hasarı verir ve onları sersemletir.",
  "DOTA_Tooltip_Ability_enfos_leshrac_diabolic_edict": "Şeytani Ferman",
  "DOTA_Tooltip_Ability_enfos_leshrac_diabolic_edict_Description": "Çevresinde rastgele patlayan saf enerji dalgaları yayarak yaratıklara patlama başı {{damage_per_explosion}} hasar vurur.",
  "DOTA_Tooltip_Ability_enfos_leshrac_lightning_storm": "Yıldırım Fırtınası",
  "DOTA_Tooltip_Ability_enfos_leshrac_lightning_storm_Description": "Düşmanlar arasında {{jump_count}} kez seken yıldırım çağırarak her sekmede {{damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_leshrac_pulse_nova": "Darbeli Nova",
  "DOTA_Tooltip_Ability_enfos_leshrac_pulse_nova_Description": "Açıldığında her saniye etrafındaki yaratıklara {{damage}} büyü hasarı patlatır.",
  "DOTA_Tooltip_Ability_enfos_leshrac_defilement": "Lekelenme",
  "DOTA_Tooltip_Ability_enfos_leshrac_defilement_Description": "Pasif olarak +{{bonus_int}} zeka ve büyü can çalması kazandırır.",

  // Invoker
  "DOTA_Tooltip_Ability_enfos_invoker_chaos_meteor": "Kaos Göktaşı",
  "DOTA_Tooltip_Ability_enfos_invoker_chaos_meteor_Description": "Gökten devasa yanan bir meteor indirerek çarptığı yaratıklara {{impact_damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_invoker_sun_strike": "Güneş Işını",
  "DOTA_Tooltip_Ability_enfos_invoker_sun_strike_Description": "Hedef alana odaklanmış güneş ışını göndererek {{radius}} menzildeki yaratıklara {{damage}} saf hasar vurur.",
  "DOTA_Tooltip_Ability_enfos_invoker_deafening_blast": "Sağır Edici Patlama",
  "DOTA_Tooltip_Ability_enfos_invoker_deafening_blast_Description": "Önündeki dalga boyunca düşmanlara {{damage}} büyü hasarı vurur ve onları silahsız bırakır.",
  "DOTA_Tooltip_Ability_enfos_invoker_emp": "Elektromanyetik Dalga",
  "DOTA_Tooltip_Ability_enfos_invoker_emp_Description": "Yüksek enerjili manyetik dalga patlatarak {{radius}} alandaki yaratıklara {{damage}} saf hasar verir.",
  "DOTA_Tooltip_Ability_enfos_invoker_alacrity": "Çevik Zihin",
  "DOTA_Tooltip_Ability_enfos_invoker_alacrity_Description": "Pasif olarak +{{bonus_as}} saldırı hızı ve +{{bonus_damage}} saldırı hasarı sağlar.",

  // Puck
  "DOTA_Tooltip_Ability_enfos_puck_illusory_orb": "Yanılsama Küresi",
  "DOTA_Tooltip_Ability_enfos_puck_illusory_orb_Description": "Düz bir hatta ilerleyen sihirli bir küre fırlatarak çarptığı tüm yaratıklara {{damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_puck_waning_rift": "Sönen Yarık",
  "DOTA_Tooltip_Ability_enfos_puck_waning_rift_Description": "Çevresine peri tozu saçarak {{radius}} menzildeki yaratıklara {{damage}} hasar verir ve onları susturur.",
  "DOTA_Tooltip_Ability_enfos_puck_phase_shift": "Faz Kayması",
  "DOTA_Tooltip_Ability_enfos_puck_phase_shift_Description": "Kısa süreliğine başka bir boyuta geçerek tamamen dokunulmaz hale gelir.",
  "DOTA_Tooltip_Ability_enfos_puck_dream_coil": "Rüya Sarmalı",
  "DOTA_Tooltip_Ability_enfos_puck_dream_coil_Description": "{{radius}} alandaki yaratıkları sihirli sarmallarla bağlayarak onları sabitler ve hasar verir.",
  "DOTA_Tooltip_Ability_enfos_puck_faerie_magic": "Peri Büyüsü",
  "DOTA_Tooltip_Ability_enfos_puck_faerie_magic_Description": "Pasif olarak +{{bonus_ms}} hareket hızı kazandırır.",

  // Lion
  "DOTA_Tooltip_Ability_enfos_lion_earth_spike": "Toprak Dikenleri",
  "DOTA_Tooltip_Ability_enfos_lion_earth_spike_Description": "Yerden çıkan sivri taşlarla yaratıklara {{damage}} büyü hasarı verir ve onları havaya fırlatarak sersemletir.",
  "DOTA_Tooltip_Ability_enfos_lion_hex": "Lanet",
  "DOTA_Tooltip_Ability_enfos_lion_hex_Description": "Hedefi {{duration}} saniye boyunca savunmasız bir kurbağaya dönüştürür.",
  "DOTA_Tooltip_Ability_enfos_lion_mana_drain": "Mana Çekme",
  "DOTA_Tooltip_Ability_enfos_lion_mana_drain_Description": "Hedefin ruh enerjisini çekerek Lion'ın manasını hızla doldurur.",
  "DOTA_Tooltip_Ability_enfos_lion_finger_of_death": "Ölüm Parmağı",
  "DOTA_Tooltip_Ability_enfos_lion_finger_of_death_Description": "Hedefe iblis ışını fırlatarak {{splash_radius}} alandaki tüm yaratıklara {{damage}} devasa büyü hasarı patlatır.",
  "DOTA_Tooltip_Ability_enfos_lion_demon_soul": "İblis Ruhu",
  "DOTA_Tooltip_Ability_enfos_lion_demon_soul_Description": "Pasif olarak yetenek kullanım menzilini +{{cast_range_bonus}} ve mana yenilenmesini artırır.",

  // Jakiro
  "DOTA_Tooltip_Ability_enfos_jakiro_dual_breath": "Çifte Nefes",
  "DOTA_Tooltip_Ability_enfos_jakiro_dual_breath_Description": "Buz ve ateş dalgası püskürterek yaratıklara {{damage}} büyü hasarı verir ve onları yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_jakiro_ice_path": "Buz Yolu",
  "DOTA_Tooltip_Ability_enfos_jakiro_ice_path_Description": "Önüne dondurucu bir buz yolu örerek basan yaratıkları {{stun_duration}} saniye dondurur ve hasar verir.",
  "DOTA_Tooltip_Ability_enfos_jakiro_liquid_fire": "Sıvı Ateş",
  "DOTA_Tooltip_Ability_enfos_jakiro_liquid_fire_Description": "Saldırılarına pasif olarak +{{bonus_damage}} alana sıçrayan yanıcı hasar ekler.",
  "DOTA_Tooltip_Ability_enfos_jakiro_macropyre": "Cehennem Ateşi",
  "DOTA_Tooltip_Ability_enfos_jakiro_macropyre_Description": "Önünde {{length}} menzillik alev denizi yaratarak saniye başına {{damage_per_sec}} büyü hasarı yakar.",
  "DOTA_Tooltip_Ability_enfos_jakiro_double_trouble": "Çifte Baş",
  "DOTA_Tooltip_Ability_enfos_jakiro_double_trouble_Description": "Pasif olarak +{{bonus_int}} zeka ve +{{bonus_as}} saldırı hızı kazandırır.",

  // Vengeful Spirit
  "DOTA_Tooltip_Ability_enfos_vs_magic_missile": "Büyü Füzesi",
  "DOTA_Tooltip_Ability_enfos_vs_magic_missile_Description": "Hedefe büyü güllesi fırlatarak {{damage}} büyü hasarı verir ve onu {{stun_duration}} saniye sersemletir.",
  "DOTA_Tooltip_Ability_enfos_vs_wave_of_terror": "Dehşet Dalgası",
  "DOTA_Tooltip_Ability_enfos_vs_wave_of_terror_Description": "Çığlık dalgası yayarak yolundaki tüm yaratıklara {{damage}} hasar vurur ve zırhlarını {{duration}} saniye kırar.",
  "DOTA_Tooltip_Ability_enfos_vs_vengeance_aura": "İntikam Halesi",
  "DOTA_Tooltip_Ability_enfos_vs_vengeance_aura_Description": "Pasif olarak tüm dost birimlerin temel saldırı gücünü %{{bonus_damage_pct}} artırır.",
  "DOTA_Tooltip_Ability_enfos_vs_nether_swap": "Ruh Takası",
  "DOTA_Tooltip_Ability_enfos_vs_nether_swap_Description": "Hedef birimle anında yer değiştirerek ona {{damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_vs_retribution": "Misilleme",
  "DOTA_Tooltip_Ability_enfos_vs_retribution_Description": "Pasif olarak +{{bonus_agi}} çeviklik ve +{{bonus_as}} saldırı hızı sağlar.",

  // Lich
  "DOTA_Tooltip_Ability_enfos_lich_frost_blast": "Donma Patlaması",
  "DOTA_Tooltip_Ability_enfos_lich_frost_blast_Description": "Hedefe ve çevresine buz patlaması uygulayarak {{target_damage}} büyü hasarı verir ve onları yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_lich_frost_shield": "Don Kalkanı",
  "DOTA_Tooltip_Ability_enfos_lich_frost_shield_Description": "Hedef dosta buz zırhı giydirerek gelen hasarı %{{damage_reduction}} azaltır.",
  "DOTA_Tooltip_Ability_enfos_lich_sinister_gaze": "Uğursuz Bakış",
  "DOTA_Tooltip_Ability_enfos_lich_sinister_gaze_Description": "Hedef yaratığı hipnoz ederek Lich'e doğru çeker ve onu çaresiz bırakır.",
  "DOTA_Tooltip_Ability_enfos_lich_chain_frost": "Zincirleme Don",
  "DOTA_Tooltip_Ability_enfos_lich_chain_frost_Description": "Yaratıklar arasında {{jump_count}} kez seken dev bir buz küresi fırlatarak her vuruşta {{damage}} ağır hasar verir.",
  "DOTA_Tooltip_Ability_enfos_lich_ice_aura": "Buzul Halesi",
  "DOTA_Tooltip_Ability_enfos_lich_ice_aura_Description": "Pasif olarak +{{bonus_armor}} zırh ve +{{mana_regen}} mana yenilenmesi bahşeder."
};

// ─────────────────────────────────────────────────────────────────────────────
// 3. Execution
// ─────────────────────────────────────────────────────────────────────────────
console.log('--- Step 1: Appending Abilities to npc_abilities_custom.txt ---');
let abilitiesFile = fs.readFileSync(customAbilitiesPath, 'utf8');
const lastClosingBraceIndex = abilitiesFile.lastIndexOf('}');
if (lastClosingBraceIndex !== -1) {
  const abilitiesKV = generateAbilitiesKV();
  abilitiesFile = abilitiesFile.slice(0, lastClosingBraceIndex) + abilitiesKV + '\n}\n';
  fs.writeFileSync(customAbilitiesPath, abilitiesFile, 'utf8');
  console.log('Successfully appended 100 new abilities to npc_abilities_custom.txt');
} else {
  console.error('Failed to locate closing brace in npc_abilities_custom.txt');
}

console.log('--- Step 2: Appending Heroes to npc_heroes_custom.txt ---');
let heroesFile = fs.readFileSync(customHeroesPath, 'utf8');
const heroesClosingBrace = heroesFile.lastIndexOf('}');
if (heroesClosingBrace !== -1) {
  let heroesKV = '\n';
  for (const h of NEW_HEROES) {
    heroesKV += `\t// =========================================================================\n`;
    heroesKV += `\t// ${h.role.toUpperCase()}: ${h.hero}\n`;
    heroesKV += `\t// =========================================================================\n`;
    heroesKV += `\t"${h.hero}"\n\t{\n`;
    heroesKV += `\t\t"override_hero"\t\t\t"${h.hero}"\n`;
    heroesKV += `\t\t"HeroID"\t\t\t\t"${h.id}"\n`;
    heroesKV += `\t\t"Role"\t\t\t\t\t"${h.role}"\n`;
    heroesKV += `\t\t"AttributePrimary"\t\t"${h.primary}"\n`;
    heroesKV += `\t\t"AttributeBaseStrength"\t"${h.str}"\n`;
    heroesKV += `\t\t"AttributeBaseAgility"\t"${h.agi}"\n`;
    heroesKV += `\t\t"AttributeBaseIntelligence" "${h.int}"\n`;
    heroesKV += `\t\t"MovementSpeed"\t\t\t"${h.ms}"\n`;
    heroesKV += `\t\t"ArmorPhysical"\t\t\t"${h.armor}"\n\n`;
    heroesKV += `\t\t"Ability1"\t\t\t\t"${h.abilities[0]}"\n`;
    heroesKV += `\t\t"Ability2"\t\t\t\t"${h.abilities[1]}"\n`;
    heroesKV += `\t\t"Ability3"\t\t\t\t"${h.abilities[2]}"\n`;
    heroesKV += `\t\t"Ability4"\t\t\t\t"${h.abilities[3]}"\n`;
    heroesKV += `\t\t"Ability5"\t\t\t\t"${h.abilities[4]}"\n`;
    heroesKV += `\t\t"Ability6"\t\t\t\t"generic_hidden"\n`;
    heroesKV += `\t}\n\n`;
  }
  heroesFile = heroesFile.slice(0, heroesClosingBrace) + heroesKV + '}\n';
  fs.writeFileSync(customHeroesPath, heroesFile, 'utf8');
  console.log('Successfully appended 20 new heroes to npc_heroes_custom.txt');
}

console.log('--- Step 3: Appending Heroes to herolist.txt ---');
let heroListContent = fs.readFileSync(heroListPath, 'utf8');
const heroListClosingBrace = heroListContent.lastIndexOf('}');
if (heroListClosingBrace !== -1) {
  let listEntries = '';
  for (const h of NEW_HEROES) {
    if (!heroListContent.includes(h.hero)) {
      listEntries += `\t"${h.hero}"\t\t"1"\n`;
    }
  }
  if (listEntries) {
    heroListContent = heroListContent.slice(0, heroListClosingBrace) + listEntries + '}\n';
    fs.writeFileSync(heroListPath, heroListContent, 'utf8');
    console.log('Successfully appended heroes to herolist.txt');
  }
}

console.log('--- Step 4: Updating turkish.json with Tokens ---');
const turkishData = JSON.parse(fs.readFileSync(turkishJsonPath, 'utf8'));
for (const [k, v] of Object.entries(TURKISH_HERO_TOKENS)) {
  turkishData.Tokens[k] = v;
}
fs.writeFileSync(turkishJsonPath, JSON.stringify(turkishData, null, 2) + '\n', 'utf8');
console.log(`Updated turkish.json. Total tokens: ${Object.keys(turkishData.Tokens).length}`);

console.log('--- Step 5: Precache Particles in addon_game_mode.lua ---');
const PARTICLES_TO_PRECACHE = [
  'particles/units/heroes/hero_tidehunter/tidehunter_gush.vpcf',
  'particles/units/heroes/hero_tidehunter/tidehunter_anchor_smash.vpcf',
  'particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage.vpcf',
  'particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf',
  'particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail.vpcf',
  'particles/units/heroes/hero_pudge/pudge_meathook.vpcf',
  'particles/units/heroes/hero_pudge/pudge_rot.vpcf',
  'particles/units/heroes/hero_pudge/pudge_dismember.vpcf',
  'particles/units/heroes/hero_abyssal_underlord/abyssal_underlord_firestorm_wave.vpcf',
  'particles/units/heroes/hero_abyssal_underlord/abyssal_underlord_pitofmalice.vpcf',
  'particles/units/heroes/hero_ursa/ursa_earthshock.vpcf',
  'particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf',
  'particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf',
  'particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf',
  'particles/units/heroes/hero_monkey_king/monkey_king_spring.vpcf',
  'particles/units/heroes/hero_monkey_king/monkey_king_fur_army_ring.vpcf',
  'particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_melee.vpcf',
  'particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf',
  'particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf',
  'particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf',
  'particles/units/heroes/hero_antimage/antimage_blink_start.vpcf',
  'particles/units/heroes/hero_antimage/antimage_blink_end.vpcf',
  'particles/units/heroes/hero_antimage/antimage_manavoid.vpcf',
  'particles/units/heroes/hero_faceless_void/faceless_void_time_walk.vpcf',
  'particles/units/heroes/hero_faceless_void/faceless_void_timedilation_mod.vpcf',
  'particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf',
  'particles/units/heroes/hero_medusa/medusa_split_shot.vpcf',
  'particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf',
  'particles/units/heroes/hero_medusa/medusa_stone_gaze_active.vpcf',
  'particles/units/heroes/hero_terrorblade/terrorblade_reflection_slow.vpcf',
  'particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf',
  'particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf',
  'particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf',
  'particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf',
  'particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf',
  'particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf',
  'particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf',
  'particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf',
  'particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf',
  'particles/units/heroes/hero_invoker/invoker_emp.vpcf',
  'particles/units/heroes/hero_puck/puck_illusory_orb.vpcf',
  'particles/units/heroes/hero_puck/puck_waning_rift.vpcf',
  'particles/units/heroes/hero_puck/puck_phase_shift.vpcf',
  'particles/units/heroes/hero_puck/puck_dream_coil.vpcf',
  'particles/units/heroes/hero_lion/lion_spell_impale.vpcf',
  'particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf',
  'particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf',
  'particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf',
  'particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf',
  'particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf',
  'particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf',
  'particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf',
  'particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf',
  'particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf',
  'particles/units/heroes/hero_lich/lich_frost_nova.vpcf',
  'particles/units/heroes/hero_lich/lich_frost_shield.vpcf',
  'particles/units/heroes/hero_lich/lich_chain_frost.vpcf'
];

let addonGameMode = fs.readFileSync(addonGameModePath, 'utf8');
let precacheBlock = '';
for (const p of PARTICLES_TO_PRECACHE) {
  if (!addonGameMode.includes(p)) {
    precacheBlock += `\tPrecacheResource("particle", "${p}", context)\n`;
  }
}
if (precacheBlock) {
  addonGameMode = addonGameMode.replace('function Precache(context)\n', 'function Precache(context)\n' + precacheBlock);
  fs.writeFileSync(addonGameModePath, addonGameMode, 'utf8');
  console.log('Precached hero particles in addon_game_mode.lua.');
}

console.log('--- Step 6: Sync Localization Across Languages ---');
execSync('node tools/update_localization.mjs', { cwd: root, stdio: 'inherit' });

console.log('All 20 new heroes and 100 abilities generated successfully!');

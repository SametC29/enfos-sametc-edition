import fs from 'node:fs';
import path from 'node:path';
import { root, SOURCE_LANG } from './localization.mjs';

const customAbilitiesPath = path.join(root, 'game/scripts/npc/npc_abilities_custom.txt');
const turkishJsonPath = path.join(root, `localization/${SOURCE_LANG}.json`);
const addonGameModePath = path.join(root, 'game/scripts/vscripts/addon_game_mode.lua');

// ─────────────────────────────────────────────────────────────────────────────
// 1. Ability Definitions (KV Text)
// ─────────────────────────────────────────────────────────────────────────────
const heroAbilitiesKV = `
	// =========================================================================
	// JUGGERNAUT (FIGHTER) ABILITIES
	// =========================================================================

	"enfos_juggernaut_blade_fury"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_IMMEDIATE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"SpellImmunityType"			"SPELL_IMMUNITY_ENEMIES_NO"
		"AbilityTextureName"		"juggernaut_blade_fury"
		"AbilityCastPoint"			"0.0"
		"AbilityCooldown"			"14.0"
		"AbilityManaCost"			"90 100 110 120"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"425"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"5.0"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"damage_per_sec"	"140 220 300 380"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"tick_interval"		"0.5"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Juggernaut.BladeFuryStart"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_blade_fury"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_blade_fury"
			{
				"IsBuff"			"1"
				"States"
				{
					"MODIFIER_STATE_MAGIC_IMMUNE" "MODIFIER_STATE_VALUE_ENABLED"
				}
				"OnCreated"
				{
					"AttachEffect"
					{
						"EffectName"		"particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf"
						"EffectAttachType"	"follow_origin"
						"Target"			"CASTER"
					}
				}
				"OnDestroy"
				{
					"FireSound"
					{
						"EffectName"		"Hero_Juggernaut.BladeFuryStop"
						"Target"			"CASTER"
					}
				}
				"ThinkInterval"		"%tick_interval"
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
								"Target"	"TARGET"
								"Type"		"DAMAGE_TYPE_MAGICAL"
								"Damage"	"%damage_per_sec * %tick_interval"
							}
						}
					}
				}
			}
		}
	}

	"enfos_juggernaut_healing_ward"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"AbilityTextureName"		"juggernaut_healing_ward"
		"AbilityCastPoint"			"0.3"
		"AbilityCooldown"			"25.0"
		"AbilityManaCost"			"100 110 120 130"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"600"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"heal_pct"			"3 4 5 6"
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
				"EffectName"		"Hero_Juggernaut.HealingWard.Cast"
				"Target"			"CASTER"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_healing_ward_aura"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_healing_ward_aura"
			{
				"IsBuff"			"1"
				"Aura"				"modifier_enfos_healing_ward_buff"
				"Aura_Radius"		"%radius"
				"Aura_Teams"		"DOTA_UNIT_TARGET_TEAM_FRIENDLY"
				"Aura_Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				"Aura_ApplyToCaster" "1"
				"OnCreated"
				{
					"AttachEffect"
					{
						"EffectName"		"particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf"
						"EffectAttachType"	"follow_origin"
						"Target"			"CASTER"
					}
				}
			}
			"modifier_enfos_healing_ward_buff"
			{
				"IsBuff"			"1"
				"ThinkInterval"		"1.0"
				"OnIntervalThink"
				{
					"Heal"
					{
						"Target"	"TARGET"
						"HealAmount" "%heal_pct * TARGET:GetMaxHealth() / 100"
					}
				}
			}
		}
	}

	"enfos_juggernaut_blade_dance"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"juggernaut_blade_dance"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"crit_chance"		"25 30 35 40"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"crit_mult"			"200 230 260 300"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_blade_dance_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE" "%crit_mult"
				}
			}
		}
	}

	"enfos_juggernaut_omni_slash"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PHYSICAL"
		"SpellImmunityType"			"SPELL_IMMUNITY_ENEMIES_YES"
		"AbilityTextureName"		"juggernaut_omni_slash"
		"AbilityCastPoint"			"0.3"
		"AbilityCastRange"			"450"
		"AbilityCooldown"			"60.0"
		"AbilityManaCost"			"150 200 250"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"3.0 3.5 4.0"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"50 80 110"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"450"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"slash_interval"	"0.3"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Juggernaut.OmniSlash"
				"Target"			"TARGET"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_omni_slash_active"
				"Target"			"CASTER"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_omni_slash_active"
			{
				"IsBuff"			"1"
				"States"
				{
					"MODIFIER_STATE_INVULNERABLE" "MODIFIER_STATE_VALUE_ENABLED"
					"MODIFIER_STATE_NO_HEALTH_BAR" "MODIFIER_STATE_VALUE_ENABLED"
				}
				"ThinkInterval"		"%slash_interval"
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
								"Target"	"TARGET"
								"Type"		"DAMAGE_TYPE_PHYSICAL"
								"Damage"	"%bonus_damage"
							}
							"AttachEffect"
							{
								"EffectName"		"particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf"
								"EffectAttachType"	"follow_origin"
								"Target"			"TARGET"
							}
						}
					}
				}
			}
		}
	}

	"enfos_juggernaut_duelist"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"juggernaut_swift_slash"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_attack_speed" "15 25 35 50"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_ms_pct"		"10 15 20 25"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_juggernaut_duelist_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%bonus_attack_speed"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%bonus_ms_pct"
				}
			}
		}
	}

	// =========================================================================
	// DROW RANGER (CARRY) ABILITIES
	// =========================================================================

	"enfos_drow_frost_arrows"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_AUTOCAST | DOTA_ABILITY_BEHAVIOR_ATTACK"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PHYSICAL"
		"AbilityTextureName"		"drow_ranger_frost_arrows"
		"AbilityCastRange"			"625"
		"AbilityCooldown"			"0.0"
		"AbilityManaCost"			"10"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-20 -30 -40 -50"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"15 30 45 60"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"3.0"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_frost_arrows_slow"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}

	"enfos_drow_gust"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PHYSICAL"
		"AbilityTextureName"		"drow_ranger_wave_of_silence"
		"AbilityCastPoint"			"0.25"
		"AbilityCastRange"			"900"
		"AbilityCooldown"			"15.0"
		"AbilityManaCost"			"90"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"wave_speed"		"1500"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"wave_distance"		"900"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"wave_width"		"250"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"silence_duration"	"3.0 4.0 5.0 6.0"
			}
			"05"
			{
				"var_type"			"FIELD_INTEGER"
				"knockback_distance" "200"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_DrowRanger.Silence"
				"Target"			"CASTER"
			}
			"LinearProjectile"
			{
				"Target"			"POINT"
				"EffectName"		"particles/units/heroes/hero_drow/drow_silence_wave.vpcf"
				"MoveSpeed"			"%wave_speed"
				"StartRadius"		"%wave_width"
				"EndRadius"			"%wave_width"
				"FixedDistance"		"%wave_distance"
				"StartPosition"		"attach_attack1"
				"TargetTeams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
				"TargetTypes"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
			}
		}

		"OnProjectileHitUnit"
		{
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_gust_silence"
				"Target"			"TARGET"
				"Duration"			"%silence_duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_gust_silence"
			{
				"IsDebuff"			"1"
				"States"
				{
					"MODIFIER_STATE_SILENCED" "MODIFIER_STATE_VALUE_ENABLED"
				}
			}
		}
	}

	"enfos_drow_multishot"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_CHANNELLED"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PHYSICAL"
		"AbilityTextureName"		"drow_ranger_multishot"
		"AbilityChannelTime"		"2.0"
		"AbilityCastPoint"			"0.1"
		"AbilityCastRange"			"1100"
		"AbilityCooldown"			"18.0"
		"AbilityManaCost"			"80 90 100 110"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"arrow_count"		"12 16 20 24"
			}
			"02"
			{
				"var_type"			"FIELD_FLOAT"
				"channel_time"		"2.0"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"arrow_damage_pct"	"100 120 140 160"
			}
			"04"
			{
				"var_type"			"FIELD_INTEGER"
				"arrow_range"		"1100"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_DrowRanger.Multishot.Channel"
				"Target"			"CASTER"
			}
		}
	}

	"enfos_drow_marksmanship"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"drow_ranger_marksmanship"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"proc_chance"		"30 35 40"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_damage"		"80 140 200"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"disable_range"		"400"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_marksmanship_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"OnAttackLanded"
				{
					"Random"
					{
						"Chance"	"%proc_chance"
						"OnSuccess"
						{
							"Damage"
							{
								"Target"	"TARGET"
								"Type"		"DAMAGE_TYPE_PHYSICAL"
								"Damage"	"%bonus_damage"
							}
							"FireSound"
							{
								"EffectName" "Hero_DrowRanger.Marksmanship.Frost"
								"Target"	 "TARGET"
							}
						}
					}
				}
			}
		}
	}

	"enfos_drow_precision_aura"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"drow_ranger_trueshot"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_agility_pct"	"10 15 20 25"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_range"		"100 150 200 250"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_precision_aura_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACK_RANGE_BONUS" "%bonus_range"
				}
			}
		}
	}

	// =========================================================================
	// LINA (MAGE) ABILITIES
	// =========================================================================

	"enfos_lina_dragon_slave"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"SpellImmunityType"			"SPELL_IMMUNITY_ENEMIES_NO"
		"AbilityTextureName"		"lina_dragon_slave"
		"AbilityCastPoint"			"0.45"
		"AbilityCastRange"			"1100"
		"AbilityCooldown"			"8.0"
		"AbilityManaCost"			"100 115 130 145"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"160 240 320 400"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"dragon_slave_distance" "1100"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"dragon_slave_width_initial" "275"
			}
			"04"
			{
				"var_type"			"FIELD_INTEGER"
				"dragon_slave_width_end" "200"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Lina.DragonSlave"
				"Target"			"CASTER"
			}
			"LinearProjectile"
			{
				"Target"			"POINT"
				"EffectName"		"particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf"
				"MoveSpeed"			"1200"
				"StartRadius"		"%dragon_slave_width_initial"
				"EndRadius"			"%dragon_slave_width_end"
				"FixedDistance"		"%dragon_slave_distance"
				"StartPosition"		"attach_attack1"
				"TargetTeams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
				"TargetTypes"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
			}
		}

		"OnProjectileHitUnit"
		{
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
		}
	}

	"enfos_lina_light_strike_array"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_POINT | DOTA_ABILITY_BEHAVIOR_AOE"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"SpellImmunityType"			"SPELL_IMMUNITY_ENEMIES_NO"
		"AbilityTextureName"		"lina_light_strike_array"
		"AbilityCastPoint"			"0.45"
		"AbilityCastRange"			"700"
		"AbilityCooldown"			"9.0"
		"AbilityManaCost"			"100 110 120 130"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"350"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"120 190 260 330"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"stun_duration"		"1.6 1.9 2.2 2.5"
			}
			"04"
			{
				"var_type"			"FIELD_INTEGER"
				"light_strike_array_aoe" "350"
			}
		}

		"OnSpellStart"
		{
			"DelayedAction"
			{
				"Delay"				"0.5"
				"Action"
				{
					"FireSound"
					{
						"EffectName"		"Ability.LightStrikeArray"
						"Target"			"POINT"
					}
					"AttachEffect"
					{
						"EffectName"		"particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
						"EffectAttachType"	"world_origin"
						"Target"			"POINT"
					}
					"ActOnTargets"
					{
						"Target"
						{
							"Center"	"POINT"
							"Radius"	"%radius"
							"Teams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
							"Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
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
								"ModifierName" "modifier_enfos_lsa_stun"
								"Target"	"TARGET"
								"Duration"	"%stun_duration"
							}
						}
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_lsa_stun"
			{
				"IsDebuff"			"1"
				"States"
				{
					"MODIFIER_STATE_STUNNED" "MODIFIER_STATE_VALUE_ENABLED"
				}
			}
		}
	}

	"enfos_lina_fiery_soul"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"lina_fiery_soul"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"fiery_soul_attack_speed_bonus" "30 45 60 75"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"fiery_soul_move_speed_bonus" "4 6 8 10"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"fiery_soul_max_stacks" "4"
			}
			"04"
			{
				"var_type"			"FIELD_FLOAT"
				"fiery_soul_stack_duration" "10.0"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_fiery_soul_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%fiery_soul_attack_speed_bonus"
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%fiery_soul_move_speed_bonus"
				}
			}
		}
	}

	"enfos_lina_laguna_blade"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_MAGICAL"
		"SpellImmunityType"			"SPELL_IMMUNITY_ENEMIES_NO"
		"AbilityTextureName"		"lina_laguna_blade"
		"AbilityCastPoint"			"0.45"
		"AbilityCastRange"			"600"
		"AbilityCooldown"			"45.0"
		"AbilityManaCost"			"200 300 400"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"600 950 1300"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"overflow_radius"	"450"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"overflow_damage_pct" "50"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Ability.LagunaBladeImpact"
				"Target"			"TARGET"
			}
			"AttachEffect"
			{
				"EffectName"		"particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
				"EffectAttachType"	"follow_origin"
				"Target"			"TARGET"
			}
			"Damage"
			{
				"Target"			"TARGET"
				"Type"				"DAMAGE_TYPE_MAGICAL"
				"Damage"			"%damage"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"	"TARGET"
					"Radius"	"%overflow_radius"
					"Teams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_MAGICAL"
						"Damage"	"%damage * %overflow_damage_pct / 100"
					}
				}
			}
		}
	}

	"enfos_lina_combustion"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"lina_flame_cloak"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"spell_amp"			"6 10 14 18"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"burn_dps"			"20 35 50 65"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"burn_duration"		"3.0"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_combustion_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE" "%spell_amp"
				}
			}
		}
	}

	// =========================================================================
	// OMNIKNIGHT (SUPPORT) ABILITIES
	// =========================================================================

	"enfos_omni_purification"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_FRIENDLY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityUnitDamageType"		"DAMAGE_TYPE_PURE"
		"SpellImmunityType"			"SPELL_IMMUNITY_ALLIES_YES"
		"AbilityTextureName"		"omniknight_purification"
		"AbilityCastPoint"			"0.2"
		"AbilityCastRange"			"600"
		"AbilityCooldown"			"12.0 10.5 9.0 7.5"
		"AbilityManaCost"			"85 100 115 130"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"heal_amount"		"150 240 330 420"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"damage"			"150 240 330 420"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"375"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Omniknight.Purification"
				"Target"			"TARGET"
			}
			"AttachEffect"
			{
				"EffectName"		"particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"
				"EffectAttachType"	"follow_origin"
				"Target"			"TARGET"
			}
			"Heal"
			{
				"Target"			"TARGET"
				"HealAmount"		"%heal_amount"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"	"TARGET"
					"Radius"	"%radius"
					"Teams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
					"Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
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

	"enfos_omni_repel"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_UNIT_TARGET"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_FRIENDLY"
		"AbilityUnitTargetType"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
		"AbilityTextureName"		"omniknight_repel"
		"AbilityCastPoint"			"0.25"
		"AbilityCastRange"			"600"
		"AbilityCooldown"			"18.0 16.0 14.0 12.0"
		"AbilityManaCost"			"80 90 100 110"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_hp_regen"	"15 25 35 45"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_strength"	"10 18 26 34"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_armor"		"6 9 12 15"
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
				"EffectName"		"Hero_Omniknight.Repel"
				"Target"			"TARGET"
			}
			"ApplyModifier"
			{
				"ModifierName"		"modifier_enfos_repel_buff"
				"Target"			"TARGET"
				"Duration"			"%duration"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_repel_buff"
			{
				"IsBuff"			"1"
				"OnCreated"
				{
					"AttachEffect"
					{
						"EffectName"		"particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
						"EffectAttachType"	"follow_origin"
						"Target"			"TARGET"
					}
				}
				"Properties"
				{
					"MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT" "%bonus_hp_regen"
					"MODIFIER_PROPERTY_STATS_STRENGTH_BONUS" "%bonus_strength"
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "%bonus_armor"
				}
			}
		}
	}

	"enfos_omni_degen_aura"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE | DOTA_ABILITY_BEHAVIOR_AURA"
		"AbilityUnitTargetTeam"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
		"AbilityTextureName"		"omniknight_degen_aura"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"450"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-15 -22 -29 -36"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"attack_slow"		"-20 -30 -40 -50"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_degen_aura"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"Aura"				"modifier_enfos_degen_aura_debuff"
				"Aura_Radius"		"%radius"
				"Aura_Teams"		"DOTA_UNIT_TARGET_TEAM_ENEMY"
				"Aura_Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
			}
			"modifier_enfos_degen_aura_debuff"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
					"MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT" "%attack_slow"
				}
			}
		}
	}

	"enfos_omni_guardian_angel"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_NO_TARGET"
		"SpellImmunityType"			"SPELL_IMMUNITY_ALLIES_YES"
		"AbilityTextureName"		"omniknight_guardian_angel"
		"AbilityCastPoint"			"0.4"
		"AbilityCooldown"			"90.0 75.0 60.0"
		"AbilityManaCost"			"150 200 250"
		"MaxLevel"					"3"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_FLOAT"
				"duration"			"6.0 7.5 9.0"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"radius"			"1200"
			}
			"03"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_hp_regen"	"30 50 70"
			}
		}

		"OnSpellStart"
		{
			"FireSound"
			{
				"EffectName"		"Hero_Omniknight.GuardianAngel.Cast"
				"Target"			"CASTER"
			}
			"ActOnTargets"
			{
				"Target"
				{
					"Center"	"CASTER"
					"Radius"	"%radius"
					"Teams"		"DOTA_UNIT_TARGET_TEAM_FRIENDLY"
					"Types"		"DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC"
				}
				"Action"
				{
					"ApplyModifier"
					{
						"ModifierName"		"modifier_enfos_guardian_angel_buff"
						"Target"			"TARGET"
						"Duration"			"%duration"
					}
				}
			}
		}

		"Modifiers"
		{
			"modifier_enfos_guardian_angel_buff"
			{
				"IsBuff"			"1"
				"OnCreated"
				{
					"AttachEffect"
					{
						"EffectName"		"particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
						"EffectAttachType"	"follow_origin"
						"Target"			"TARGET"
					}
				}
				"Properties"
				{
					"MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT" "%bonus_hp_regen"
					"MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS" "1000"
				}
			}
		}
	}

	"enfos_omni_hammer_of_purity"
	{
		"BaseClass"					"ability_datadriven"
		"AbilityBehavior"			"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"		"omniknight_hammer_of_purity"
		"MaxLevel"					"4"

		"AbilitySpecial"
		{
			"01"
			{
				"var_type"			"FIELD_INTEGER"
				"bonus_pure_damage"	"30 50 70 90"
			}
			"02"
			{
				"var_type"			"FIELD_INTEGER"
				"slow_pct"			"-20 -25 -30 -35"
			}
			"03"
			{
				"var_type"			"FIELD_FLOAT"
				"slow_duration"		"2.0"
			}
		}

		"Modifiers"
		{
			"modifier_enfos_hammer_of_purity_passive"
			{
				"Passive"			"1"
				"IsBuff"			"1"
				"OnAttackLanded"
				{
					"Damage"
					{
						"Target"	"TARGET"
						"Type"		"DAMAGE_TYPE_PURE"
						"Damage"	"%bonus_pure_damage"
					}
					"ApplyModifier"
					{
						"ModifierName" "modifier_enfos_hammer_slow"
						"Target"	"TARGET"
						"Duration"	"%slow_duration"
					}
				}
			}
			"modifier_enfos_hammer_slow"
			{
				"IsDebuff"			"1"
				"Properties"
				{
					"MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE" "%slow_pct"
				}
			}
		}
	}
`;

let customAbilities = fs.readFileSync(customAbilitiesPath, 'utf8');
const insertRegex = /\r?\n\t\/\/ =========================================================================\r?\n\t\/\/ Creep Archetype Abilities/;
if (!customAbilities.includes('enfos_juggernaut_blade_fury')) {
  customAbilities = customAbilities.replace(insertRegex, '\n' + heroAbilitiesKV.trim() + '\n\n\t// =========================================================================\n\t// Creep Archetype Abilities');
  fs.writeFileSync(customAbilitiesPath, customAbilities, 'utf8');
  console.log('Added 20 hero abilities to npc_abilities_custom.txt.');
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Turkish Localization Tokens (Source of Truth)
// ─────────────────────────────────────────────────────────────────────────────
const turkishHeroTokens = {
  // Hero Names & Hypes
  "npc_dota_hero_juggernaut": "Kılıç Ustası",
  "npc_dota_hero_juggernaut_hype": "Dövüşçü (Fighter) rolünün öncüsü. Kesintisiz kılıç darbeleri, büyü bağışıklığı sağlayan dönüşleri ve takımını ayakta tutan şifa totemiyle dalgaları biçer.",
  "npc_dota_hero_drow_ranger": "Okçu Muhafız",
  "npc_dota_hero_drow_ranger_hype": "Taşıyıcı (Carry) rolünün ustası. Dondurucu okları, dalgaları temizleyen yaylım ateşi ve zırh delen nişancılığı ile uzaktan yıkım yaratır.",
  "npc_dota_hero_lina": "Alev Büyücüsü",
  "npc_dota_hero_lina_hype": "Büyücü (Mage) rolünün ateş gücü. Ejderha alevleri, alan sersemletmesi ve Laguna Blade yıldırım patlamasıyla düşman sürülerini küle çevirir.",
  "npc_dota_hero_omniknight": "Işık Koruyucusu",
  "npc_dota_hero_omniknight_hype": "Destek (Support) rolünün koruyucu kalkanı. Saf hasarla iyileştiren arınması, büyü direnci ve takıma fiziksel hasar dokunulmazlığı veren koruyucu meleğiyle orduları kurtarır.",

  // Juggernaut Abilities
  "DOTA_Tooltip_Ability_enfos_juggernaut_blade_fury": "Kılıç Fırtınası",
  "DOTA_Tooltip_Ability_enfos_juggernaut_blade_fury_Description": "Kılıcıyla dönerek büyü bağışıklığı kazanır ve {{duration}} saniye boyunca {{radius}} menzildeki düşmanlara saniyede {{damage_per_sec}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_juggernaut_healing_ward": "Şifa Totemi",
  "DOTA_Tooltip_Ability_enfos_juggernaut_healing_ward_Description": "{{radius}} menzil içindeki dost birimleri {{duration}} saniye boyunca saniyede azami canlarının %{{heal_pct}} kadarı oranında iyileştirir.",
  "DOTA_Tooltip_Ability_enfos_juggernaut_blade_dance": "Kılıç Dansı",
  "DOTA_Tooltip_Ability_enfos_juggernaut_blade_dance_Description": "Her saldırıda %{{crit_chance}} ihtimalle %{{crit_mult}} kritik hasar verme şansı sağlar.",
  "DOTA_Tooltip_Ability_enfos_juggernaut_omni_slash": "Kutsal Kılıç Akını",
  "DOTA_Tooltip_Ability_enfos_juggernaut_omni_slash_Description": "Düşman birimler arasında {{duration}} saniye boyunca sıçrayarak dokunulmazlık kazanır ve her vuruşta +{{bonus_damage}} bonus fiziksel hasar indirir.",
  "DOTA_Tooltip_Ability_enfos_juggernaut_duelist": "Düellocu Çevikliği",
  "DOTA_Tooltip_Ability_enfos_juggernaut_duelist_Description": "Doğuştan gelen savaş ustalığıyla pasif olarak +{{bonus_attack_speed}} saldırı hızı ve %{{bonus_ms_pct}} hareket hızı kazanır.",

  // Drow Ranger Abilities
  "DOTA_Tooltip_Ability_enfos_drow_frost_arrows": "Buzul Oklar",
  "DOTA_Tooltip_Ability_enfos_drow_frost_arrows_Description": "Oklarına dondurucu soğuk ekleyerek hedefin hareket hızını {{duration}} saniye boyunca %{{slow_pct|percent}} yavaşlatır ve her vuruşta +{{bonus_damage}} bonus hasar verir.",
  "DOTA_Tooltip_Ability_enfos_drow_gust": "Susturan Rüzgar",
  "DOTA_Tooltip_Ability_enfos_drow_gust_Description": "Düşmanları {{knockback_distance}} birim geri savuran sert bir rüzgar dalgası fırlatır ve onları {{silence_duration}} saniye boyunca susturur.",
  "DOTA_Tooltip_Ability_enfos_drow_multishot": "Çoklu Ok Yaylımı",
  "DOTA_Tooltip_Ability_enfos_drow_multishot_Description": "{{channel_time}} saniye boyunca odaklanarak {{arrow_range}} menzile {{arrow_count}} adet ok fırlatır. Her ok baz saldırı gücünün %{{arrow_damage_pct}} kadarını uygular.",
  "DOTA_Tooltip_Ability_enfos_drow_marksmanship": "Usta Nişancılık",
  "DOTA_Tooltip_Ability_enfos_drow_marksmanship_Description": "Saldırılarda %{{proc_chance}} şansla düşman zırhını delen ve +{{bonus_damage}} bonus fiziksel hasar vuran ölümcül bir atış yapar.",
  "DOTA_Tooltip_Ability_enfos_drow_precision_aura": "Hassasiyet Halesi",
  "DOTA_Tooltip_Ability_enfos_drow_precision_aura_Description": "Pasif olarak menzilli saldırı menzilini {{bonus_range}} birim ve çeviklik verimini artırır.",

  // Lina Abilities
  "DOTA_Tooltip_Ability_enfos_lina_dragon_slave": "Ejderha Nefesi",
  "DOTA_Tooltip_Ability_enfos_lina_dragon_slave_Description": "{{dragon_slave_distance}} menzil boyunca ilerleyen alev dalgası yayarak yoluna çıkan tüm düşmanlara {{damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_lina_light_strike_array": "Alev Sütunu",
  "DOTA_Tooltip_Ability_enfos_lina_light_strike_array_Description": "{{radius}} alanda bir alev sütunu patlatarak düşmanları {{stun_duration}} saniye sersemletir ve {{damage}} büyü hasarı verir.",
  "DOTA_Tooltip_Ability_enfos_lina_fiery_soul": "Ateşli Ruh",
  "DOTA_Tooltip_Ability_enfos_lina_fiery_soul_Description": "Kullanılan her yetenekle pasif olarak +{{fiery_soul_attack_speed_bonus}} saldırı hızı ve %{{fiery_soul_move_speed_bonus}} hareket hızı kazanır.",
  "DOTA_Tooltip_Ability_enfos_lina_laguna_blade": "Laguna Bıçağı",
  "DOTA_Tooltip_Ability_enfos_lina_laguna_blade_Description": "Hedefe yoğunlaştırılmış yıldırım yıldırımı fırlatarak {{damage}} büyü hasarı verir. Enerji taşkını {{overflow_radius}} alandaki birimlere %{{overflow_damage_pct}} hasar sıçratır.",
  "DOTA_Tooltip_Ability_enfos_lina_combustion": "Tutuşma",
  "DOTA_Tooltip_Ability_enfos_lina_combustion_Description": "Büyü hasarını pasif olarak %{{spell_amp}} artırır ve düşmanların yanmasını sağlar.",

  // Omniknight Abilities
  "DOTA_Tooltip_Ability_enfos_omni_purification": "Kutsal Arınma",
  "DOTA_Tooltip_Ability_enfos_omni_purification_Description": "Dost birimi anında {{heal_amount}} can iyileştirir ve etrafındaki {{radius}} menzildeki düşmanlara {{damage}} saf hasar verir.",
  "DOTA_Tooltip_Ability_enfos_omni_repel": "Cennet Lütfu",
  "DOTA_Tooltip_Ability_enfos_omni_repel_Description": "Hedef dosta {{duration}} saniye boyunca +{{bonus_hp_regen}} can yenilenmesi, +{{bonus_strength}} güç ve +{{bonus_armor}} zırh bahşeder.",
  "DOTA_Tooltip_Ability_enfos_omni_degen_aura": "Çöküş Halesi",
  "DOTA_Tooltip_Ability_enfos_omni_degen_aura_Description": "{{radius}} menzildeki tüm düşmanların hareket hızını %{{slow_pct|percent}} ve saldırı hızını {{attack_slow}} yavaşlatır.",
  "DOTA_Tooltip_Ability_enfos_omni_guardian_angel": "Koruyucu Melek",
  "DOTA_Tooltip_Ability_enfos_omni_guardian_angel_Description": "{{radius}} menzil içindeki tüm dostlara {{duration}} saniye boyunca fiziksel hasar bağışıklığı ve +{{bonus_hp_regen}} can yenilenmesi sağlar.",
  "DOTA_Tooltip_Ability_enfos_omni_hammer_of_purity": "Saflık Çekici",
  "DOTA_Tooltip_Ability_enfos_omni_hammer_of_purity_Description": "Her normal saldırıda hedefe +{{bonus_pure_damage}} saf hasar vurur ve {{slow_duration}} saniye boyunca hareket hızını %{{slow_pct|percent}} yavaşlatır."
};

const turkishData = JSON.parse(fs.readFileSync(turkishJsonPath, 'utf8'));
for (const [k, v] of Object.entries(turkishHeroTokens)) {
  turkishData.Tokens[k] = v;
}
fs.writeFileSync(turkishJsonPath, JSON.stringify(turkishData, null, 2) + '\n', 'utf8');
console.log(`Updated turkish.json with ${Object.keys(turkishData.Tokens).length} tokens.`);

// ─────────────────────────────────────────────────────────────────────────────
// 3. Precache Resources in addon_game_mode.lua
// ─────────────────────────────────────────────────────────────────────────────
const heroParticlesToPrecache = [
  'particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf',
  'particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf',
  'particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf',
  'particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf',
  'particles/units/heroes/hero_drow/drow_frost_arrow.vpcf',
  'particles/units/heroes/hero_drow/drow_silence_wave.vpcf',
  'particles/units/heroes/hero_drow/drow_multishot_proj_linear_proj.vpcf',
  'particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf',
  'particles/units/heroes/hero_drow/drow_precision.vpcf',
  'particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf',
  'particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf',
  'particles/units/heroes/hero_lina/lina_fiery_soul.vpcf',
  'particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_purification.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_degen_aura.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf'
];

let addonGameMode = fs.readFileSync(addonGameModePath, 'utf8');
let precacheBlock = '';
for (const p of heroParticlesToPrecache) {
  if (!addonGameMode.includes(p)) {
    precacheBlock += `\tPrecacheResource("particle", "${p}", context)\n`;
  }
}
if (precacheBlock) {
  addonGameMode = addonGameMode.replace('function Precache(context)\n', 'function Precache(context)\n' + precacheBlock);
  fs.writeFileSync(addonGameModePath, addonGameMode, 'utf8');
  console.log('Precached hero particles in addon_game_mode.lua.');
}

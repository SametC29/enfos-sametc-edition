--------------------------------------------------------------------------------
-- addon_game_mode.lua
-- Dota 2 entry point for Enfos Team Survival — SametC Edition
-- This file is loaded by the engine. It delegates to EnfosSametC game mode class.
--------------------------------------------------------------------------------

require("enfos_sametc")
local WaveManager = require("waves/wave_manager")

function Precache(context)
	PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_frost_arrow.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_silence_wave.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_multishot_proj_linear_proj.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_drow/drow_precision.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_degen_aura.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf", context)
	PrecacheResource("particle", "particles/rain_fx/coloseum_terrain_motes.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf", context)
	PrecacheUnitByNameSync("npc_dota_courier", context)
	PrecacheUnitByNameSync("npc_dota_flying_courier", context)
end

function Activate()
	GameRules.EnfosSametC = EnfosSametC()
	GameRules.EnfosSametC:InitGameMode()
	WaveManager:Init()
	require("map/portals"):Init()
end

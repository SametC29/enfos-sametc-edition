--------------------------------------------------------------------------------
-- addon_game_mode.lua
-- Dota 2 entry point for Enfos Team Survival — SametC Edition
-- This file is loaded by the engine. It delegates to EnfosSametC game mode class.
--------------------------------------------------------------------------------

require("enfos_sametc")

function Precache(context)
	PrecacheResource("particle", "particles/rain_fx/coloseum_terrain_motes.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf", context)
end

function Activate()
	GameRules.EnfosSametC = EnfosSametC()
	GameRules.EnfosSametC:InitGameMode()
end

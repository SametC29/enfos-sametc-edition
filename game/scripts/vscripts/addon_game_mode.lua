--------------------------------------------------------------------------------
-- addon_game_mode.lua
-- Dota 2 entry point for Enfos Team Survival — SametC Edition
-- This file is loaded by the engine. It delegates to EnfosSametC game mode class.
--------------------------------------------------------------------------------

require("enfos_sametc")

function Precache(context)
	-- Precache resources here as the project grows.
	-- Examples:
	--   PrecacheResource("model", "models/example.vmdl", context)
	--   PrecacheResource("soundfile", "soundevents/example.vsndevts", context)
	--   PrecacheResource("particle", "particles/example.vpcf", context)
end

function Activate()
	GameRules.EnfosSametC = EnfosSametC()
	GameRules.EnfosSametC:InitGameMode()
end

--------------------------------------------------------------------------------
-- enfos_sametc.lua
-- Main game mode class for Enfos Team Survival — SametC Edition
--------------------------------------------------------------------------------

require("lib/log")

-- Read build version from file
local function ReadBuildVersion()
	local version = "unknown"
	-- LoadKeyValues is available for txt files; for simple version we use a constant
	-- that gets updated by build tooling.
	return "0.1.0-dev"
end

--------------------------------------------------------------------------------
-- Class definition
--------------------------------------------------------------------------------
if EnfosSametC == nil then
	EnfosSametC = class({})
end

--------------------------------------------------------------------------------
-- InitGameMode
-- Called once when the addon activates. Sets up game rules and registers
-- event listeners.
--------------------------------------------------------------------------------
function EnfosSametC:InitGameMode()
	self.buildVersion = ReadBuildVersion()

	Log:Info("system", "========================================")
	Log:Info("system", "Enfos Team Survival — SametC Edition")
	Log:Info("system", "Build: %s", self.buildVersion)
	Log:Info("system", "========================================")

	-- Game rules configuration
	local gameMode = GameRules:GetGameModeEntity()

	-- Basic game settings
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)
	GameRules:SetUseUniversalShopMode(true)

	-- Thinking
	gameMode:SetThink("OnThink", self, "GlobalThink", 1)

	-- Register event listeners
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(EnfosSametC, "OnGameRulesStateChange"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(EnfosSametC, "OnNPCSpawned"), self)

	Log:Info("system", "Game mode initialized successfully.")
end

--------------------------------------------------------------------------------
-- OnThink
-- Global think function, called once per second.
--------------------------------------------------------------------------------
function EnfosSametC:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- Main game loop will go here
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil -- Stop thinking
	end
	return 1 -- Think again in 1 second
end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------
function EnfosSametC:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	Log:Info("system", "Game state changed to: %d", state)
end

function EnfosSametC:OnNPCSpawned(event)
	-- Will be used for hero setup, creep AI, etc.
end

--------------------------------------------------------------------------------
-- life_core.lua
-- Server-authoritative Life Core management, leak penalties, and match resolution
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 4, 5
--------------------------------------------------------------------------------

require("lib/log")
local WaveDefinitions = require("waves/wave_definitions")

local LifeCore = {}
LifeCore.__index = LifeCore

LifeCore.STARTING_LIFE = 100

LifeCore.CORE_POSITIONS = {
	[DOTA_TEAM_GOODGUYS or 2] = Vector(7656.83, -3451.99, 726.59),
	[DOTA_TEAM_BADGUYS or 3] = Vector(-7809.26, -3683.53, 470.43),
}

LifeCore.CORE_TRIGGER_RADIUS = 320

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------
function LifeCore:Init(waveManager)
	self.waveManager = waveManager
	self.life = {
		[DOTA_TEAM_GOODGUYS or 2] = LifeCore.STARTING_LIFE,
		[DOTA_TEAM_BADGUYS or 3] = LifeCore.STARTING_LIFE,
	}
	self.isGameOver = false

	self:SyncNetTable()
	Log:Info("life_core", "Life Core initialized with %d Life per team.", LifeCore.STARTING_LIFE)
end

--------------------------------------------------------------------------------
-- Get / Set Life
--------------------------------------------------------------------------------
function LifeCore:GetLife(team)
	return self.life[team] or 0
end

function LifeCore:SetLife(team, amount)
	local oldLife = self.life[team] or 0
	self.life[team] = math.max(0, amount)
	Log:Info("life_core", "Team %s Life updated: %d -> %d", tostring(team), oldLife, self.life[team])
	self:SyncNetTable()
	self:CheckGameOver()
end

--------------------------------------------------------------------------------
-- Apply Damage (Leak or Overflow)
--------------------------------------------------------------------------------
function LifeCore:ApplyDamage(team, damage, reason, unitName)
	if self.isGameOver then return end
	if damage <= 0 then return end

	local current = self.life[team] or 0
	local newLife = math.max(0, current - damage)
	self.life[team] = newLife

	Log:Warn("life_core", "LEAK! Team %s lost %d Life (Reason: %s, Unit: %s). Remaining: %d",
		tostring(team), damage, tostring(reason or "leak"), tostring(unitName or "unknown"), newLife)

	-- Visual and audio feedback
	self:PlayLeakEffects(team, damage)

	-- Sync state to clients
	self:SyncNetTable()

	-- Check for elimination
	self:CheckGameOver()
end

--------------------------------------------------------------------------------
-- Process Unit Leak at Core
--------------------------------------------------------------------------------
function LifeCore:ProcessLeak(unit, team)
	if not unit or unit:IsNull() then return end
	if unit.enfosLeaked then return end
	unit.enfosLeaked = true

	local unitName = unit:GetUnitName()
	local damage = WaveDefinitions:GetLeakPenalty(unitName)

	-- Apply the authoritative Life penalty
	if damage > 0 then
		self:ApplyDamage(team, damage, "creep_reached_core", unitName)
	else
		Log:Info("life_core", "Summoned unit %s reached core without Life penalty.", unitName)
	end

	-- Notify wave manager to unregister this hostile
	if self.waveManager and self.waveManager.OnCreepRemoved then
		self.waveManager:OnCreepRemoved(unit, team)
	end

	-- Immediately remove leaking unit from the world
	-- (No gold or XP is awarded when a unit leaks)
	if not unit:IsNull() and unit:IsAlive() then
		unit:ForceKill(false)
	end
	if not unit:IsNull() then
		UTIL_Remove(unit)
	end
end

--------------------------------------------------------------------------------
-- Effects
--------------------------------------------------------------------------------
function LifeCore:PlayLeakEffects(team, damage)
	local corePos = LifeCore.CORE_POSITIONS[team]
	if not corePos then return end

	-- Sound notification
	if damage >= 5 then
		-- Boss leak alert
		EmitGlobalSound("Hero_Terrorblade.Sunder.Target")
	else
		-- Standard leak alert
		EmitGlobalSound("Hero_Life_Stealer.Consume.Target")
	end

	-- Screen shake for defending players
	ScreenShake(corePos, 8.0, 150.0, 0.6, 2000, 0, true)
end

--------------------------------------------------------------------------------
-- Check Game Over
--------------------------------------------------------------------------------
function LifeCore:CheckGameOver()
	if self.isGameOver then return end

	local goodLife = self.life[DOTA_TEAM_GOODGUYS or 2] or 0
	local badLife = self.life[DOTA_TEAM_BADGUYS or 3] or 0

	if goodLife <= 0 and badLife <= 0 then
		-- Draw (extremely rare)
		self.isGameOver = true
		Log:Warn("life_core", "MATCH END: Draw! Both teams reached 0 Life.")
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS or 2)
	elseif goodLife <= 0 then
		self.isGameOver = true
		Log:Warn("life_core", "MATCH END: Radiant eliminated! Dire wins.")
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS or 3)
	elseif badLife <= 0 then
		-- In single-team Co-op, Badguys life can be ignored or initialized to 100
		-- Check if there are active badguys players
		local hasBadguysPlayers = false
		for p = 0, 9 do
			if PlayerResource:IsValidPlayerID(p) and PlayerResource:GetTeam(p) == (DOTA_TEAM_BADGUYS or 3) then
				hasBadguysPlayers = true
				break
			end
		end

		if hasBadguysPlayers then
			self.isGameOver = true
			Log:Warn("life_core", "MATCH END: Dire eliminated! Radiant wins.")
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS or 2)
		end
	end
end

--------------------------------------------------------------------------------
-- NetTable Sync
--------------------------------------------------------------------------------
function LifeCore:SyncNetTable()
	if not CustomNetTables then return end

	CustomNetTables:SetTableValue("wave_info", "team_life", {
		goodguys = self.life[DOTA_TEAM_GOODGUYS or 2] or 0,
		badguys = self.life[DOTA_TEAM_BADGUYS or 3] or 0,
	})
end

return LifeCore

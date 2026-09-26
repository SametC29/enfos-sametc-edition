-- Project-owned portal behavior, using only the selected map's placement data.
local Portals = {}
Portals.points = {
    {team=2, from=Vector(9243,-3200,683), to=Vector(11572,828,256)},
    {team=2, from=Vector(11564,912,320), to=Vector(9249,-3295,640)},
    {team=2, from=Vector(6111,-3133,722), to=Vector(3831,752,256)},
    {team=2, from=Vector(3831,851,338), to=Vector(6118,-3218,640)},
    {team=3, from=Vector(-6123,-2932,594), to=Vector(-4069,854,256)},
    {team=3, from=Vector(-4070,950,338), to=Vector(-6132,-3028,512)},
    {team=3, from=Vector(-9276,-3064,594), to=Vector(-11561,728,256)},
    {team=3, from=Vector(-11567,829,338), to=Vector(-9274,-3161,512)},
}

function Portals:TryTeleport(hero, now)
    if not hero or hero:IsNull() or not hero:IsRealHero() or not hero:IsAlive()
        or hero:IsIllusion() or hero:IsChanneling() or hero:IsStunned() or hero:IsRooted() then return false end
    if now < (hero.enfosPortalReadyAt or 0) then return false end
    local pos = hero:GetAbsOrigin()
    if hero.enfosPortalNeedsExit then
        for _, portal in ipairs(self.points) do
            if (pos - portal.from):Length2D() <= 220 and math.abs(pos.z - portal.from.z) <= 180 then return false end
        end
        hero.enfosPortalNeedsExit = nil
    end
    for _, portal in ipairs(self.points) do
        if hero:GetTeamNumber() == portal.team and (pos - portal.from):Length2D() <= 150
            and math.abs(pos.z - portal.from.z) <= 180 then
            hero.enfosPortalReadyAt = now + 3
            hero.enfosPortalNeedsExit = true
            hero:Stop()
            FindClearSpaceForUnit(hero, portal.to, true)
            EmitSoundOn("Portal.Hero_Appear", hero)
            return true
        end
    end
    return false
end

function Portals:Init()
    GameRules:GetGameModeEntity():SetContextThink("EnfosPortals", function()
        if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then return nil end
        if not GameRules:IsGamePaused() then
            for id=0, DOTA_MAX_TEAM_PLAYERS-1 do
                if PlayerResource:IsValidPlayerID(id) then
                    self:TryTeleport(PlayerResource:GetSelectedHeroEntity(id), GameRules:GetGameTime())
                end
            end
        end
        return 0.15
    end, 0.15)
end
return Portals

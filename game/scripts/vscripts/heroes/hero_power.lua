require("lib/log")
local Config=require("heroes/power_config")
local Power={snapshot=nil}
local NAME="modifier_enfos_hero_power"
if LinkLuaModifier then LinkLuaModifier(NAME,"heroes/modifier_hero_power",LUA_MODIFIER_MOTION_NONE) end

function Power:Apply(hero)
    if not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
        or hero:IsClone() or hero:IsTempestDouble() then return false end
    local id=hero:GetPlayerID()
    if not id or not PlayerResource:IsValidPlayerID(id) then return false end
    local team=hero:GetTeamNumber()
    if team~=2 and team~=3 then return false end
    local values=self.snapshot and self.snapshot.heroPower or Config.Values(false)
    local modifier=hero:FindModifierByName(NAME)
    if modifier and modifier:Matches(values) then return false end
    local oldHP,oldMana=hero:GetHealth(),hero:GetMana()
    local oldMaxHP,oldMaxMana=hero:GetMaxHealth(),hero:GetMaxMana()
    if modifier then modifier:OnRefresh(values)
    else modifier=hero:AddNewModifier(hero,nil,NAME,values) end
    if not modifier then return false end
    hero:CalculateStatBonus(true)
    -- Fill only the newly added capacity; repeat events never become a free heal.
    if hero:IsAlive() then
        hero:SetHealth(math.min(hero:GetMaxHealth(),oldHP+math.max(0,hero:GetMaxHealth()-oldMaxHP)))
        hero:SetMana(math.min(hero:GetMaxMana(),oldMana+math.max(0,hero:GetMaxMana()-oldMaxMana)))
    end
    Log:Info("hero_power","Applied player=%d solo=%s health=%d damage=%d spell_amp=%d cooldown=%d",id,
        tostring(self.snapshot and self.snapshot.solo or false),values.health,values.damage,values.spellAmp,values.cooldown)
    return true
end

function Power:SetSnapshot(snapshot)
    self.snapshot=snapshot
    -- One bounded pass at match start. Later spawns/reconnects use the same data.
    for id=0,(DOTA_MAX_TEAM_PLAYERS or 24)-1 do
        if PlayerResource:IsValidPlayerID(id) then self:Apply(PlayerResource:GetSelectedHeroEntity(id)) end
    end
end
return Power

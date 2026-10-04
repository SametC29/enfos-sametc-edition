local Ownership={}
local function owns(hero)
    if not hero or (hero.IsNull and hero:IsNull()) or not hero.GetUnitName
        or hero:GetUnitName()~='npc_dota_hero_dragon_knight' or not hero.FindAbilityByName then return false end
    local r=hero:FindAbilityByName('enfos_dk_elder_dragon_form')
    return r and not r:IsNull() and r:GetCaster()==hero or false
end
Ownership.UsesNativeScepter=owns
Ownership.UsesNativeShard=owns
return Ownership

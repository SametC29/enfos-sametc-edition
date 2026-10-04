local Ownership={}
function Ownership.UsesNativeScepter(hero)
    if not hero or (hero.IsNull and hero:IsNull()) or not hero.GetUnitName
        or hero:GetUnitName()~='npc_dota_hero_ursa' or not hero.FindAbilityByName then return false end
    local r=hero:FindAbilityByName('enfos_ursa_enrage')
    return r~=nil and (not r.IsNull or not r:IsNull())
end
return Ownership

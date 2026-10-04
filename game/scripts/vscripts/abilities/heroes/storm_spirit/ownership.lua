local Ownership={}
function Ownership.UsesNativeShard(hero)
    if not hero or not hero.GetUnitName or hero:GetUnitName()~='npc_dota_hero_storm_spirit' or not hero.FindAbilityByName then return false end
    local e=hero:FindAbilityByName('enfos_storm_overload')
    return e and not e:IsNull() or false
end
return Ownership

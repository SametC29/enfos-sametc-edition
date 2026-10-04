local Ownership={}
function Ownership.UsesNativeScepter(hero)
    if not hero or (hero.IsNull and hero:IsNull()) or not hero.GetUnitName
        or hero:GetUnitName()~='npc_dota_hero_slark' or not hero.FindAbilityByName then return false end
    local w=hero:FindAbilityByName('enfos_slark_pounce')
    return w~=nil and (not w.IsNull or not w:IsNull())
end
return Ownership

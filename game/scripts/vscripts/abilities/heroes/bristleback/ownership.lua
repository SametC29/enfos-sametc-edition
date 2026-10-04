local Ownership={}
function Ownership.IsEnfos(hero)
    return hero and (not hero.IsNull or not hero:IsNull()) and hero.GetUnitName
        and hero:GetUnitName()=='npc_dota_hero_bristleback' and hero.FindAbilityByName
        and hero:FindAbilityByName('enfos_bb_warpath')~=nil
end
return Ownership

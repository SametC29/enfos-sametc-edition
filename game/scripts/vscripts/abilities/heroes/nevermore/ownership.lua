-- Read-only, client-safe upgrade ownership; never initialize providers here.
local Ownership={}
function Ownership.IsEnfos(hero)
    return hero and not (hero.IsNull and hero:IsNull()) and hero.GetUnitName
        and hero:GetUnitName()=='npc_dota_hero_nevermore' and hero.FindAbilityByName
        and hero:FindAbilityByName('enfos_sf_shadowraze')~=nil
end
return Ownership

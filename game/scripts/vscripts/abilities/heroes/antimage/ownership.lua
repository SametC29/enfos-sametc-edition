-- Pure client/server ownership query; no gameplay restoration or manager imports.
local Ownership={}
function Ownership.UsesNativeShard(hero)
    if not hero or (hero.IsNull and hero:IsNull()) or not hero.GetUnitName
        or hero:GetUnitName()~='npc_dota_hero_antimage' or not hero.FindAbilityByName then return false end
    local e=hero:FindAbilityByName('enfos_am_counterspell')
    return e~=nil and (not e.IsNull or not e:IsNull())
end
return Ownership

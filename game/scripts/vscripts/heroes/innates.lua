-- The fifth authored skill is the hero's innate. One free starting rank;
-- subsequent ranks still use the authored skill-point progression.
local Innates={byHero={}}
for _,hero in ipairs(require("heroes/roster")) do Innates.byHero[hero.id]=hero.abilities[5] end
function Innates:Apply(hero)
    if not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion() then return false end
    local id=self.byHero[hero:GetUnitName()]
    local ability=id and hero:FindAbilityByName(id)
    if not ability then return false end
    if ability:GetLevel()==0 then ability:SetLevel(1) end
    return true
end
return Innates

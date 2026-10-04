-- Paid ranks tune bounded wave growth; native rank1 Catch owns real fish.
enfos_tide_colossal_presence=class({})
function enfos_tide_colossal_presence:GetIntrinsicModifierName() return 'modifier_enfos_tide_wave_catch' end
function enfos_tide_colossal_presence:OnUpgrade()
    if not IsServer() then return end
    local c=self:GetCaster()
    if c and not c:IsNull() then c:CalculateStatBonus(true) end
end
modifier_enfos_tide_wave_catch=class({})
local D=modifier_enfos_tide_wave_catch
function D:IsHidden() return true end
function D:IsPurgable() return false end
function D:RemoveOnDeath() return false end
function D:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,MODIFIER_EVENT_ON_DEATH} end
local function source(m)
    local c,a=m:GetParent(),m:GetAbility()
    if not c or c:IsNull() or c:IsIllusion() or c:PassivesDisabled() or not a or a:IsNull() or a:GetLevel()<1 then return end
    return c,a
end
function D:GetModifierHealthBonus()
    local c,a=source(self)
    if not c then return 0 end
    local cap=a:GetSpecialValueFor('wave_stack_cap')
    return cap>0 and math.min(self:GetStackCount(),cap)*a:GetSpecialValueFor('wave_health_max')/cap or 0
end
function D:GetModifierAttackRangeBonus()
    local c,a=source(self)
    return c and math.min(self:GetStackCount(),a:GetSpecialValueFor('wave_stack_cap'))*a:GetSpecialValueFor('wave_attack_range') or 0
end
function D:OnStackCountChanged()
    if not IsServer() then return end
    local c=self:GetParent()
    if c and not c:IsNull() then c:CalculateStatBonus(true) end
end
function D:OnDeath(params)
    if not IsServer() or not params then return end
    local c,a=source(self)
    if not c or not c:IsAlive() or params.attacker~=c then return end
    local u=params.unit
    if not u or u:IsNull() or u==c or u:GetTeamNumber()==c:GetTeamNumber() or u:IsHero() or u:IsIllusion()
        or not (u:IsCreep() or u:IsCreature()) then return end
    local cap=a:GetSpecialValueFor('wave_stack_cap')
    if cap<=0 or self:GetStackCount()>=cap then return end
    self:SetStackCount(math.min(cap,self:GetStackCount()+1))
end

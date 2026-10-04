local Trace=require('lib/hero_trace')
local function upgrade(a)
    if IsServer() then require('abilities/heroes/bristleback/integration').Refresh(a:GetCaster()) end
end
local function cast(a,id,slot)
    if not IsServer() then return end
    local native,hero=require('abilities/heroes/bristleback/integration').Provider(a,id)
    if not native then a:EndCooldown();a:RefundManaCost();return end
    if slot=='Q' then
        local target=a:GetCursorTarget()
        if not target or target:IsNull() or not target:IsAlive() then a:EndCooldown();a:RefundManaCost();return end
        hero:SetCursorCastTarget(target)
    elseif slot=='R' or slot=='E' then
        hero:SetCursorPosition(a:GetCursorPosition())
    end
    native:OnSpellStart()
    if a:IsNull() or native:IsNull() then return end
    native:StartCooldown(a:GetCooldownTimeRemaining())
    Trace:Log('BB',slot,'native_cast rank=%s',tostring(a:GetLevel()))
end
enfos_bb_viscous_nasal_goo=class({})
function enfos_bb_viscous_nasal_goo:OnUpgrade() upgrade(self) end
function enfos_bb_viscous_nasal_goo:OnSpellStart() cast(self,'bristleback_viscous_nasal_goo','Q') end
enfos_bb_quill_spray=class({})
function enfos_bb_quill_spray:OnUpgrade() upgrade(self) end
function enfos_bb_quill_spray:OnSpellStart() cast(self,'bristleback_quill_spray','W') end
function enfos_bb_quill_spray:GetAOERadius() return self:GetSpecialValueFor('radius') end
enfos_bb_hairball=class({})
function enfos_bb_hairball:OnUpgrade() upgrade(self) end
function enfos_bb_hairball:OnSpellStart() cast(self,'enfos_bb_native_hairball','R') end
function enfos_bb_hairball:GetAOERadius() return self:GetSpecialValueFor('radius') end
enfos_bb_bristleback=class({})
function enfos_bb_bristleback:GetIntrinsicModifierName() return 'modifier_enfos_bb_native_scaling' end
function enfos_bb_bristleback:OnUpgrade() upgrade(self) end
function enfos_bb_bristleback:OnSpellStart() cast(self,'bristleback_bristleback','E') end
function enfos_bb_bristleback:GetBehavior()
    local hero=self:GetCaster()
    local native=hero and not hero:IsNull() and hero:FindAbilityByName('bristleback_bristleback')
    if not native or native:IsNull() then return DOTA_ABILITY_BEHAVIOR_PASSIVE end
    return bit.band(native:GetBehavior(),bit.bnot(DOTA_ABILITY_BEHAVIOR_HIDDEN))
end
function enfos_bb_bristleback:GetManaCost(level)
    local hero=self:GetCaster()
    return hero and not hero:IsNull() and hero:HasScepter() and self:GetSpecialValueFor('activation_manacost') or 0
end
function enfos_bb_bristleback:GetCooldown(level)
    local hero=self:GetCaster()
    return hero and not hero:IsNull() and hero:HasScepter() and self:GetSpecialValueFor('activation_cooldown') or 0
end
function enfos_bb_bristleback:GetCastRange(location,target)
    local hero=self:GetCaster()
    local native=hero and not hero:IsNull() and hero:FindAbilityByName('bristleback_bristleback')
    return native and not native:IsNull() and native:GetCastRange(location,target) or 0
end

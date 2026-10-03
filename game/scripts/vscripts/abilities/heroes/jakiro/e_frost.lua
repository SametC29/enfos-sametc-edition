-- Linked E component: impact and per-instance bonus damage, never a Frost DoT.
require('abilities/heroes/jakiro/e')
local H = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function immune(x) return (x.IsDebuffImmune and x:IsDebuffImmune()) or (x.IsMagicImmune and x:IsMagicImmune()) end
local function eligible(c,t)
    return valid(c) and valid(t) and t:IsAlive() and t:GetTeamNumber()~=c:GetTeamNumber()
        and not (t.IsBuilding and t:IsBuilding()) and not immune(t)
end
LinkLuaModifier('modifier_enfos_jakiro_liquid_frost_orb','abilities/heroes/jakiro/e_frost',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_jakiro_liquid_frost_debuff','abilities/heroes/jakiro/e_frost',LUA_MODIFIER_MOTION_NONE)
enfos_jakiro_liquid_frost=class({})
enfos_jakiro_liquid_frost.GetManaCost=enfos_jakiro_liquid_fire.GetManaCost
enfos_jakiro_liquid_frost.SyncLinkedCooldown=enfos_jakiro_liquid_fire.SyncLinkedCooldown
function enfos_jakiro_liquid_frost:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local t=self:GetCursorTarget()
    if not valid(t) or (t.IsBuilding and t:IsBuilding()) then return end
    return enfos_jakiro_liquid_fire.OnSpellStart(self)
end
function enfos_jakiro_liquid_frost:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_liquid_frost_orb' end
function enfos_jakiro_liquid_frost:SnapshotImpact()
    return {impact=H.value(self,'impact_damage'),bonus=H.value(self,'bonus_damage'),
        slow=H.value(self,'movement_slow'),duration=H.value(self,'duration')}
end
function enfos_jakiro_liquid_frost:FireAt(t,data)
    if not IsServer() or not valid(self) then return false end
    local c=self:GetCaster()
    if not eligible(c,t) then return false end
    data=data or self:SnapshotImpact()
    local origin=t:GetAbsOrigin()
    local p=ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_base_attack_frost_explosion.vpcf',PATTACH_WORLDORIGIN,t)
    ParticleManager:SetParticleControl(p,0,origin)
    ParticleManager:SetParticleControl(p,1,origin) -- Smoke children attract to CP1, not world zero.
    ParticleManager:SetParticleControl(p,3,origin)
    ParticleManager:ReleaseParticleIndex(p) -- Installed instantaneous emitter, finite lifetime.
    if not valid(self) or not eligible(c,t) then return false end
    t:EmitSound('Hero_Jakiro.LiquidFire')
    if not valid(self) or not eligible(c,t) then return false end
    -- Apply damage before the new debuff; this hit cannot amplify itself.
    H.damage(self,t,data.impact,DAMAGE_TYPE_MAGICAL)
    if not valid(self) or not eligible(c,t) then return false end
    t:AddNewModifier(c,self,'modifier_enfos_jakiro_liquid_frost_debuff',{
        duration=data.duration,slow=data.slow,bonus=data.bonus})
    Trace:Log('JAKIRO','E','frost_impact target=%s impact=%s bonus=%s',Trace:Name(t),tostring(data.impact),tostring(data.bonus))
    return true
end
modifier_enfos_jakiro_liquid_frost_orb=class({})
-- Same tested funded-record protocol; a distinct modifier keeps both owners independent.
for _,method in ipairs({'IsHidden','IsPurgable','IsPurgeException','RemoveOnDeath','OnCreated',
    'OnAttack','OnAttackLanded','ForgetRecord','OnAttackFail','OnAttackRecordDestroy','OnDestroy'}) do
    modifier_enfos_jakiro_liquid_frost_orb[method]=modifier_enfos_jakiro_liquid_fire_passive[method]
end
function modifier_enfos_jakiro_liquid_frost_orb:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK,MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_EVENT_ON_ATTACK_FAIL,MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY}
end
function modifier_enfos_jakiro_liquid_frost_orb:OnAttack(params)
    local t=params and params.target
    if not valid(t) or (t.IsBuilding and t:IsBuilding()) then return end
    return modifier_enfos_jakiro_liquid_fire_passive.OnAttack(self,params)
end
modifier_enfos_jakiro_liquid_frost_debuff=class({})
function modifier_enfos_jakiro_liquid_frost_debuff:IsDebuff() return true end
function modifier_enfos_jakiro_liquid_frost_debuff:IsPurgable() return true end
function modifier_enfos_jakiro_liquid_frost_debuff:GetTexture() return 'jakiro_liquid_ice' end
function modifier_enfos_jakiro_liquid_frost_debuff:GetEffectName() return 'particles/generic_gameplay/generic_slowed_cold.vpcf' end
function modifier_enfos_jakiro_liquid_frost_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_jakiro_liquid_frost_debuff:Read(params)
    self.slow=math.max(0,tonumber(params and params.slow) or 0)
    self.bonus=math.max(0,tonumber(params and params.bonus) or 0)
end
function modifier_enfos_jakiro_liquid_frost_debuff:OnCreated(params)
    if not IsServer() then return end
    self.closed=false;self.proccing=false;self:Read(params);self:SetHasCustomTransmitterData(true)
    Trace:Log('JAKIRO','E','frost_debuff_applied target=%s slow=%s bonus=%s',Trace:Name(self:GetParent()),tostring(self.slow),tostring(self.bonus))
end
function modifier_enfos_jakiro_liquid_frost_debuff:OnRefresh(params)
    if not IsServer() or self.closed then return end
    self:Read(params);self:SendBuffRefreshToClients()
end
function modifier_enfos_jakiro_liquid_frost_debuff:AddCustomTransmitterData() return {slow=self.slow or 0,bonus=self.bonus or 0} end
function modifier_enfos_jakiro_liquid_frost_debuff:HandleCustomTransmitterData(data) self:Read(data) end
function modifier_enfos_jakiro_liquid_frost_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_TOOLTIP,MODIFIER_EVENT_ON_TAKEDAMAGE}
end
function modifier_enfos_jakiro_liquid_frost_debuff:GetModifierMoveSpeedBonus_Percentage()
    local t,c,a=self:GetParent(),self:GetCaster(),self:GetAbility()
    return not self.closed and valid(c) and valid(a) and valid(t) and t:IsAlive() and not immune(t) and -(self.slow or 0) or 0
end
function modifier_enfos_jakiro_liquid_frost_debuff:OnTooltip() return self.bonus or 0 end
function modifier_enfos_jakiro_liquid_frost_debuff:OnTakeDamage(keys)
    if not IsServer() or self.closed or self.proccing or not keys or (keys.damage or 0)<=0 then return end
    local c,a,t=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(a) or not eligible(c,t) or keys.unit~=t or keys.attacker~=c or keys.inflictor==a then return end
    if bit.band(keys.damage_flags or 0,DOTA_DAMAGE_FLAG_REFLECTION)~=0 then return end
    self.proccing=true
    local actual=H.damage(a,t,self.bonus,DAMAGE_TYPE_MAGICAL) or 0
    self.proccing=false
    Trace:Log('JAKIRO','E','frost_bonus target=%s requested=%s actual=%s',Trace:Name(t),tostring(self.bonus),tostring(actual))
end
function modifier_enfos_jakiro_liquid_frost_debuff:OnDestroy()
    if not IsServer() or self.closed then return end
    self.closed=true
    Trace:Log('JAKIRO','E','frost_debuff_removed target=%s',Trace:Name(self:GetParent()))
end

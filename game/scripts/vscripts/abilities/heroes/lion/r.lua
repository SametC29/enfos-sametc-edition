-- Lion R: finite targeted burst; native delay/grace/upgrade review remains pending.
local H=require('abilities/shared/pve_helpers')
local Trace=require('lib/hero_trace')
local Upgrades=require('abilities/heroes/lion/upgrades')
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function eligible(c,t)
    return valid(c) and c:IsAlive() and valid(t) and t:IsAlive()
        and t:GetTeamNumber()~=c:GetTeamNumber()
        and not (t.IsBuilding and t:IsBuilding())
        and not (t.IsDebuffImmune and t:IsDebuffImmune())
        and not (t.IsMagicImmune and t:IsMagicImmune())
end
local function beam(a,c,t)
    local function active() return valid(a) and eligible(c,t) end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf',PATTACH_ABSORIGIN_FOLLOW,c)
    if active() then ParticleManager:SetParticleControlEnt(fx,0,c,PATTACH_ABSORIGIN_FOLLOW,'',c:GetAbsOrigin(),false) end
    if active() then ParticleManager:SetParticleControlEnt(fx,1,t,PATTACH_ABSORIGIN_FOLLOW,'',t:GetAbsOrigin(),false) end
    if not active() then ParticleManager:DestroyParticle(fx,true) end
    ParticleManager:ReleaseParticleIndex(fx)
    return active()
end
LinkLuaModifier('modifier_enfos_lion_finger_counter', 'abilities/heroes/lion/r', LUA_MODIFIER_MOTION_NONE)

enfos_lion_finger_of_death=class({})
function enfos_lion_finger_of_death:GetAOERadius()
    if not valid(self) or not valid(self:GetCaster()) then return 0 end
    return Upgrades.HasScepter(self:GetCaster()) and H.value(self,'splash_radius') or 0
end
function enfos_lion_finger_of_death:GetIntrinsicModifierName() return 'modifier_enfos_lion_finger_counter' end
function enfos_lion_finger_of_death:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c,t=self:GetCaster(),self:GetCursorTarget()
    if not eligible(c,t) then return end
    if t:TriggerSpellAbsorb(self) then Trace:Log('LION','R','spell absorbed');return end
    if not valid(self) or not eligible(c,t) then return end
    local base=H.value(self,'damage')
    if base<=0 then return end
    local mod=c:FindModifierByName('modifier_enfos_lion_finger_counter')
    local cap=math.max(0,H.value(self,'kill_stack_cap'))
    local stacks=valid(mod) and math.min(math.max(0,mod:GetStackCount()),cap) or 0
    local upgraded=Upgrades.HasScepter(c)
    local total=base+(upgraded and H.value(self,'scepter_bonus_damage') or 0)+H.get_int(c)*H.value(self,'int_scaling_pct')/100+stacks*H.value(self,'kill_stack_damage')
    local radius=upgraded and math.max(0,H.value(self,'splash_radius')) or 0
    local origin=t:GetAbsOrigin()
    c:EmitSound('Hero_Lion.FingerOfDeath')
    if not valid(self) or not eligible(c,t) or not beam(self,c,t) then return end
    Trace:Log('LION','R','cast damage=%.1f radius=%.1f stacks=%.0f',total,radius,stacks)
    local targets,seen={t},{[t]=true}
    if radius>0 then
        for _,u in ipairs(H.enemies(c,origin,radius)) do
            if not seen[u] then seen[u]=true;targets[#targets+1]=u end
        end
    end
    for _,u in ipairs(targets) do
        if not valid(self) or not valid(c) or not c:IsAlive() then break end
        if eligible(c,u) then
            H.damage(self,u,total,DAMAGE_TYPE_MAGICAL)
            Trace:Log('LION','R','hit authored_damage=%.1f',total)
            if not valid(self) or not valid(c) or not c:IsAlive() then break end
            if valid(u) and not u:IsAlive() and valid(mod) then
                mod:SetStackCount(math.min(cap,math.max(0,mod:GetStackCount())+1))
                Trace:Log('LION','R','instant kill stack credited')
            end
        end
    end
end

modifier_enfos_lion_finger_counter=class({})
local function counter_bonus(m,key)
    if m.closed or not valid(m) or not valid(m:GetParent()) then return 0 end
    local a=m:GetAbility()
    if not valid(a) or a:GetLevel()<=0 then return 0 end
    local stacks=math.min(math.max(0,m:GetStackCount()),math.max(0,H.value(a,'kill_stack_cap')))
    return stacks*H.value(a,key)
end
function modifier_enfos_lion_finger_counter:IsHidden() return false end
function modifier_enfos_lion_finger_counter:GetTexture() return 'lion_finger_of_death' end
function modifier_enfos_lion_finger_counter:DeclareFunctions()
    return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,MODIFIER_PROPERTY_TOOLTIP,MODIFIER_PROPERTY_TOOLTIP2}
end
function modifier_enfos_lion_finger_counter:GetModifierSpellAmplify_Percentage()
    return counter_bonus(self,'kill_stack_spell_amp_pct')
end
function modifier_enfos_lion_finger_counter:OnTooltip() return counter_bonus(self,'kill_stack_damage') end
function modifier_enfos_lion_finger_counter:OnTooltip2() return counter_bonus(self,'kill_stack_spell_amp_pct') end
function modifier_enfos_lion_finger_counter:TraceLifecycle(event)
    if Trace:Enabled() then
        Trace:Log('LION','R','counter %s damage=%.1f spell_amp=%.1f',event,counter_bonus(self,'kill_stack_damage'),counter_bonus(self,'kill_stack_spell_amp_pct'))
    end
end
function modifier_enfos_lion_finger_counter:OnCreated()
    self.closed=false
    self:TraceLifecycle('applied')
end
function modifier_enfos_lion_finger_counter:OnRefresh()
    if not self.closed then self:TraceLifecycle('refreshed') end
end
function modifier_enfos_lion_finger_counter:OnDestroy()
    if self.closed then return end
    self:TraceLifecycle('removed')
    self.closed=true
end

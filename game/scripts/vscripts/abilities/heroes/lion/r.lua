-- Lion R: finite targeted burst and match-local, expiring kill attribution.
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
    local grace=math.max(0,H.value(self,'grace_period'))
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
    local delay=H.value(self,'damage_delay')
    if delay<=0 then Trace:Log('LION','R','impact rejected invalid delay');return end
    local completed=false
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('EnfosLionFingerImpact'),function()
        if completed then return nil end
        if not valid(self) or not valid(c) or not c:IsAlive() then completed=true;return nil end
        if GameRules.IsGamePaused and GameRules:IsGamePaused() then return 0.03 end
        completed=true -- Own completion before damage callbacks can reenter.
        for _,u in ipairs(targets) do
            if not valid(self) or not valid(c) or not c:IsAlive() then break end
            if eligible(c,u) then
                -- Register before synchronous damage/death callbacks can run.
                local receipt=valid(mod) and mod:MarkFingerTarget(u,grace,self)
                H.damage(self,u,total,DAMAGE_TYPE_MAGICAL)
                Trace:Log('LION','R','hit authored_damage=%.1f',total)
                if receipt and valid(mod) then mod:CreditFingerKill(u,receipt) end
            end
        end
        return nil
    end,delay)
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
function modifier_enfos_lion_finger_counter:IsPurgable() return false end
function modifier_enfos_lion_finger_counter:RemoveOnDeath() return false end
function modifier_enfos_lion_finger_counter:GetTexture() return 'lion_finger_of_death' end
function modifier_enfos_lion_finger_counter:DeclareFunctions()
    return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,MODIFIER_PROPERTY_TOOLTIP,MODIFIER_PROPERTY_TOOLTIP2,MODIFIER_EVENT_ON_DEATH}
end
local function counter_owner(m)
    if not valid(m) or m.closed then return end
    local c,a=m:GetParent(),m:GetAbility()
    if not valid(c) or not valid(a) or a:GetLevel()<=0 or a:GetCaster()~=c then return end
    return c,a
end
function modifier_enfos_lion_finger_counter:MarkFingerTarget(t,grace,source)
    if not IsServer() or grace<=0 then return end
    local c,a=counter_owner(self)
    if not c or (source and source~=a) or not eligible(c,t) then return end
    local pending=self.pendingFingerHits
    if not pending then pending={};self.pendingFingerHits=pending end
    local receipt={expires=GameRules:GetGameTime()+grace,ability=a,team=c:GetTeamNumber(),targetTeam=t:GetTeamNumber()}
    pending[t]=receipt -- Refresh one target window; never accumulate duplicate claims.
    Trace:Log('LION','R','kill window opened duration=%.2f',grace)
    if not self.fingerCleanupArmed then
        self.fingerCleanupArmed=true
        local token={}
        self.fingerCleanupToken=token
        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('EnfosLionFingerGrace'),function()
            -- An old lifecycle cannot clear a newly created counter's ledger.
            if not valid(self) or self.closed or self.pendingFingerHits~=pending or self.fingerCleanupToken~=token then return nil end
            if not counter_owner(self) then
                self.pendingFingerHits=nil;self.fingerCleanupArmed=false;self.fingerCleanupToken=nil;return nil
            end
            local now,nextExpiry=GameRules:GetGameTime(),nil
            for unit,claim in pairs(pending) do
                if not valid(unit) or now>claim.expires then pending[unit]=nil
                else nextExpiry=math.min(nextExpiry or claim.expires,claim.expires) end
            end
            if not nextExpiry then self.fingerCleanupArmed=false;self.fingerCleanupToken=nil;return nil end
            -- Keep the authored inclusive boundary; game time does not advance while paused.
            return math.max(0.03,nextExpiry-now)
        end,grace)
    end
    return receipt
end
function modifier_enfos_lion_finger_counter:CreditFingerKill(t,expected)
    if not IsServer() then return false end
    local c,a=counter_owner(self)
    if not c or not valid(t) or t:IsAlive() then return false end
    local pending=self.pendingFingerHits
    local receipt=pending and pending[t]
    if not receipt or (expected and receipt~=expected) then return false end
    pending[t]=nil -- Consume before SetStackCount can reenter a death callback.
    if receipt.ability~=a or GameRules:GetGameTime()>receipt.expires
        or receipt.team~=c:GetTeamNumber() or receipt.targetTeam~=t:GetTeamNumber()
        or t:GetTeamNumber()==c:GetTeamNumber() or (t.IsBuilding and t:IsBuilding()) then return false end
    local cap=math.max(0,H.value(a,'kill_stack_cap'))
    self:SetStackCount(math.min(cap,math.max(0,self:GetStackCount())+1))
    Trace:Log('LION','R','kill stack credited within grace window')
    return true
end
function modifier_enfos_lion_finger_counter:OnDeath(event)
    if event then self:CreditFingerKill(event.unit) end
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
    if IsServer() then self.pendingFingerHits={};self.fingerCleanupArmed=false;self.fingerCleanupToken=nil end
    self:TraceLifecycle('applied')
end
function modifier_enfos_lion_finger_counter:OnRefresh()
    if not self.closed then self:TraceLifecycle('refreshed') end
end
function modifier_enfos_lion_finger_counter:OnDestroy()
    if self.closed then return end
    self:TraceLifecycle('removed')
    self.closed=true
    self.pendingFingerHits=nil
    self.fingerCleanupArmed=false
    self.fingerCleanupToken=nil
end

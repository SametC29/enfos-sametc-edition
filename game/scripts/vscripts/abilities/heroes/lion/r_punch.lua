-- Native Finger melee empowerment; the active modifier owns reversible state/VFX.
local H=require('abilities/shared/pve_helpers')
local Trace=require('lib/hero_trace')
local Punch={}
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function source(m)
    if not valid(m) or m.closed then return end
    local c,a=m:GetParent(),m:GetAbility()
    if not valid(c) or not valid(a) or not c:IsAlive() or a:GetCaster()~=c or a:GetLevel()<=0
        or c:IsIllusion() then return end
    return c,a
end
LinkLuaModifier('modifier_enfos_lion_finger_punch','abilities/heroes/lion/r_punch',LUA_MODIFIER_MOTION_NONE)
function Punch.Grant(a,c,upgraded,alt)
    if alt or not IsServer() or not valid(a) or not valid(c) or not c:IsAlive()
        or a:GetCaster()~=c or a:GetLevel()<=0 then return end
    local duration=a:GetPunchDuration(upgraded)
    if duration<=0 or c:IsIllusion() then return end
    c:AddNewModifier(c,a,a:GetPunchModifierName(),{
        duration=duration,cleave_pct=a:GetPunchCleave(upgraded),
    })
end
modifier_enfos_lion_finger_punch=class({})
function modifier_enfos_lion_finger_punch:IsHidden() return false end
function modifier_enfos_lion_finger_punch:IsPurgable() return false end
function modifier_enfos_lion_finger_punch:RemoveOnDeath() return true end
function modifier_enfos_lion_finger_punch:GetTexture() return 'lion_finger_of_death' end
function modifier_enfos_lion_finger_punch:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,MODIFIER_EVENT_ON_ATTACK_START,MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_TOOLTIP,MODIFIER_PROPERTY_TOOLTIP2}
end
function modifier_enfos_lion_finger_punch:CheckState()
    return {[MODIFIER_STATE_ATTACKS_ARE_MELEE]=source(self)~=nil}
end
function modifier_enfos_lion_finger_punch:GetModifierAttackRangeOverride()
    local c,a=source(self);if c then return H.value(a,'punch_attack_range') end
    -- nil releases this override; zero would impose a zero-range attack.
end
function modifier_enfos_lion_finger_punch:GetModifierMoveSpeedBonus_Constant()
    local c,a=source(self);return c and H.value(a,'punch_bonus_movespeed') or 0
end
function modifier_enfos_lion_finger_punch:GetModifierPreAttack_BonusDamage()
    local c,a=source(self);if not c then return 0 end
    return H.value(a,'punch_bonus_damage')+(IsServer() and self:ReadStackBonus() or (self.stack_bonus or 0))
end
function modifier_enfos_lion_finger_punch:ReadStackBonus()
    local c,a=source(self);if not c then return 0 end
    local counter=c:FindModifierByName('modifier_enfos_lion_finger_counter')
    local bonus=0
    if valid(counter) and not counter.closed and counter:GetAbility()==a and counter:GetParent()==c then
        bonus=math.min(math.max(0,counter:GetStackCount()),math.max(0,H.value(a,'kill_stack_cap')))*H.value(a,'kill_stack_damage')
    end
    return bonus
end
function Punch.SyncCounter(counter)
    if not IsServer() or not valid(counter) then return end
    local c,a=counter:GetParent(),counter:GetAbility()
    if not valid(c) or not valid(a) or a:GetCaster()~=c then return end
    local m=c:FindModifierByName('modifier_enfos_lion_finger_punch')
    if source(m)==c and m:GetAbility()==a then
        m.stack_bonus=m:ReadStackBonus();m:SendBuffRefreshToClients()
    end
end
function Punch.CreditKill(counter,event)
    if not IsServer() or not valid(counter) or counter.closed or not event then return false end
    local c,a=counter:GetParent(),counter:GetAbility()
    if not valid(c) or not valid(a) or a:GetCaster()~=c or a:GetLevel()<=0 then return false end
    local m=c:FindModifierByName('modifier_enfos_lion_finger_punch')
    if source(m)~=c or m:GetAbility()~=a then return false end
    if event.attacker~=c then return false end
    local t=event.unit
    if not valid(t) or t:IsAlive() or t:GetTeamNumber()==c:GetTeamNumber()
        or (t.IsBuilding and t:IsBuilding()) or (t.IsIllusion and t:IsIllusion()) then return false end
    local melee=event.damage_category==DOTA_DAMAGE_CATEGORY_ATTACK and event.inflictor==nil and event.ranged_attack==false
    local cleave=m.cleaving and event.inflictor==a and event.damage_category==DOTA_DAMAGE_CATEGORY_SPELL
    if not melee and not cleave then return false end
    if not counter:AwardKill(t) then return false end
    Trace:Log('LION','R','kill stack credited by empowered fist')
    return true
end
function modifier_enfos_lion_finger_punch:GetActivityTranslationModifiers()
    if source(self) then return 'melee' end
end
function modifier_enfos_lion_finger_punch:GetAttackSound()
    if source(self) then return 'Hero_Lion.Punch.Attack' end
end
function modifier_enfos_lion_finger_punch:OnTooltip() return self:GetModifierPreAttack_BonusDamage() end
function modifier_enfos_lion_finger_punch:OnTooltip2() return source(self) and (self.cleave_pct or 0) or 0 end
function modifier_enfos_lion_finger_punch:OnAttackStart(event)
    if not IsServer() or not event then return end
    local c,a=source(self)
    if c and event.attacker==c then
        local counter=c:FindModifierByName('modifier_enfos_lion_finger_counter')
        if valid(counter) and not counter.closed and counter:GetAbility()==a and counter:GetParent()==c then
            counter:BeginPunchAttack(event.target,a)
        end
        c:EmitSound('Hero_Lion.Punch.PreAttack')
    end
end
function modifier_enfos_lion_finger_punch:OnAttackLanded(event)
    if not IsServer() or not event or self.cleaving then return end
    local c,a=source(self);local t=event.target
    if not c or event.attacker~=c or not valid(t) or t:GetTeamNumber()==c:GetTeamNumber()
        or t:IsBuilding() or not event.damage or event.damage<=0 then return end
    -- The primary can already be dead at OnAttackLanded; cleave still originates there.
    local pct=self.cleave_pct or 0;if pct<=0 then return end
    self.cleaving=true
    DoCleaveAttack(c,t,a,event.damage*pct/100,H.value(a,'punch_cleave_start_width'),
        H.value(a,'punch_cleave_end_width'),H.value(a,'punch_cleave_distance'),
        'particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf')
    self.cleaving=false
    Trace:Log('LION','R','punch cleave damage=%.1f pct=%.1f',event.damage*pct/100,pct)
end
function modifier_enfos_lion_finger_punch:OnCreated(kv)
    self.closed=false;self.cleave_pct=tonumber(kv and kv.cleave_pct) or 0
    if not IsServer() then return end
    self.stack_bonus=self:ReadStackBonus()
    self:SetHasCustomTransmitterData(true)
    local c=source(self);if not c then return end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_fistofdeath_buff.vpcf',PATTACH_POINT_FOLLOW,c)
    if source(self) then ParticleManager:SetParticleControlEnt(fx,0,c,PATTACH_POINT_FOLLOW,'attach_palm_l',c:GetAbsOrigin(),true) end
    if not source(self) then
        ParticleManager:DestroyParticle(fx,true);ParticleManager:ReleaseParticleIndex(fx);return
    end
    self.punch_fx=fx
    Trace:Log('LION','R','punch applied cleave_pct=%.1f',self.cleave_pct)
end
function modifier_enfos_lion_finger_punch:OnRefresh(kv)
    if self.closed then return end
    self.cleave_pct=tonumber(kv and kv.cleave_pct) or 0
    if IsServer() then self.stack_bonus=self:ReadStackBonus();self:SendBuffRefreshToClients() end
end
function modifier_enfos_lion_finger_punch:AddCustomTransmitterData() return {cleave_pct=self.cleave_pct or 0,stack_bonus=self.stack_bonus or 0} end
function modifier_enfos_lion_finger_punch:HandleCustomTransmitterData(data)
    self.cleave_pct=tonumber(data.cleave_pct) or 0;self.stack_bonus=tonumber(data.stack_bonus) or 0
end
function modifier_enfos_lion_finger_punch:OnDestroy()
    if self.closed then return end
    self.closed=true
    if not IsServer() then return end
    local fx=self.punch_fx;self.punch_fx=nil
    if fx~=nil then ParticleManager:DestroyParticle(fx,true);ParticleManager:ReleaseParticleIndex(fx) end
    Trace:Log('LION','R','punch removed')
end
return Punch

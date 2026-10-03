-- Lion W: ranked Hex with engine-owned transformation and visual lifetime.
local H = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_lion_hex_debuff', 'abilities/heroes/lion/w', LUA_MODIFIER_MOTION_NONE)
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function immune(t)
    return (t.IsDebuffImmune and t:IsDebuffImmune()) or (t.IsMagicImmune and t:IsMagicImmune())
end
local function living(t) return valid(t) and t:IsAlive() end
local function eligible(c,t)
    return living(c) and living(t) and t:GetTeamNumber()~=c:GetTeamNumber()
        and not (t.IsBuilding and t:IsBuilding()) and not immune(t)
end
local function ordinary_illusion(t)
    return t.IsIllusion and t:IsIllusion() and not t:IsStrongIllusion()
end
local function illusion_burst(a,c,t)
    local function active() return valid(a) and eligible(c,t) and ordinary_illusion(t) end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf',PATTACH_ABSORIGIN_FOLLOW,t)
    if active() then
        ParticleManager:SetParticleControlEnt(fx,1,t,PATTACH_ABSORIGIN_FOLLOW,'',t:GetAbsOrigin(),false)
    end
    local ready=active()
    if not ready then ParticleManager:DestroyParticle(fx,true) end
    -- Native root and children are finite bursts; no lingering target modifier.
    ParticleManager:ReleaseParticleIndex(fx)
    return ready
end
local function speed(a,p)
    local n=tonumber(p and p.move_speed)
    if not n and valid(a) then n=H.value(a,'base_move_speed') end
    return n and n>0 and n or 140
end

enfos_lion_hex=class({})
function enfos_lion_hex:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c,t=self:GetCaster(),self:GetCursorTarget()
    if not eligible(c,t) then return end
    if t:TriggerSpellAbsorb(self) then
        Trace:Log('LION','W','spell absorbed')
        return
    end
    if not valid(self) or not eligible(c,t) then return end
    local duration=H.value(self,'duration')
    if duration<=0 then return end
    local move_speed=speed(self)
    c:EmitSound('Hero_Lion.Voodoo')
    if not valid(self) or not eligible(c,t) then return end
    if ordinary_illusion(t) then
        if not illusion_burst(self,c,t) then return end
        t:Kill(self,c)
        Trace:Log('LION','W','ordinary illusion destroyed')
        return
    end
    t:AddNewModifier(c,self,'modifier_enfos_lion_hex_debuff',{duration=duration,move_speed=move_speed})
    Trace:Log('LION','W','cast duration=%.2f speed=%.1f',duration,move_speed)
end

modifier_enfos_lion_hex_debuff=class({})
function modifier_enfos_lion_hex_debuff:IsDebuff() return true end
function modifier_enfos_lion_hex_debuff:IsPurgable() return false end
function modifier_enfos_lion_hex_debuff:IsPurgeException() return true end
function modifier_enfos_lion_hex_debuff:GetTexture() return 'lion_voodoo' end
function modifier_enfos_lion_hex_debuff:OnCreated(p)
    if not IsServer() then return end
    self.move_speed=speed(self:GetAbility(),p)
    self:SetHasCustomTransmitterData(true)
    local parent=self:GetParent()
    if not living(parent) or immune(parent) or self.closed then return end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf',PATTACH_ABSORIGIN_FOLLOW,parent)
    -- Creation/binding can invoke other scripts before ownership transfers.
    if not self.closed and living(parent) then
        ParticleManager:SetParticleControlEnt(fx,1,parent,PATTACH_ABSORIGIN_FOLLOW,'',parent:GetAbsOrigin(),false)
    end
    if self.closed or not living(parent) then
        ParticleManager:DestroyParticle(fx,true)
        ParticleManager:ReleaseParticleIndex(fx)
        return
    end
    self:AddParticle(fx,false,false,-1,false,false)
    Trace:Log('LION','W','hex applied speed=%.1f',self.move_speed)
end
function modifier_enfos_lion_hex_debuff:OnRefresh(p)
    if not IsServer() or self.closed then return end
    self.move_speed=speed(self:GetAbility(),p)
    self:SendBuffRefreshToClients()
    Trace:Log('LION','W','hex refreshed speed=%.1f',self.move_speed)
end
function modifier_enfos_lion_hex_debuff:AddCustomTransmitterData() return {move_speed=self.move_speed} end
function modifier_enfos_lion_hex_debuff:HandleCustomTransmitterData(p) self.move_speed=speed(nil,p) end
function modifier_enfos_lion_hex_debuff:Active()
    local parent=self:GetParent()
    return not self.closed and living(parent) and not immune(parent)
end
function modifier_enfos_lion_hex_debuff:CheckState()
    if not self:Active() then return {} end
    return {[MODIFIER_STATE_HEXED]=true,[MODIFIER_STATE_SILENCED]=true,[MODIFIER_STATE_DISARMED]=true,[MODIFIER_STATE_MUTED]=true}
end
function modifier_enfos_lion_hex_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,MODIFIER_PROPERTY_MODEL_CHANGE}
end
function modifier_enfos_lion_hex_debuff:GetModifierMoveSpeedOverride()
    if self:Active() then return self.move_speed or 140 end
end
function modifier_enfos_lion_hex_debuff:GetModifierModelChange()
    if self:Active() then return 'models/props_gameplay/frog.vmdl' end
end
function modifier_enfos_lion_hex_debuff:OnDestroy()
    if self.closed then return end
    self.closed=true -- Engine restores the model and destroys AddParticle indices.
    Trace:Log('LION','W','hex removed')
end

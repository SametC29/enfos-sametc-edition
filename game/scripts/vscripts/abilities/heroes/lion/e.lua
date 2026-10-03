-- Lion E: one explicitly owned channel visual; mana conversion review pending.
local H = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_mana_drain_channel', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_lion_mana_drain_debuff', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)

enfos_lion_mana_drain=class({})
function enfos_lion_mana_drain:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Lion.ManaDrain')
    local duration = value(self, 'channel_duration')
    if duration <= 0 then duration = 4.0 end
    c:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_channel', { duration = duration, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_debuff', { duration = duration })
end
function enfos_lion_mana_drain:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_lion_mana_drain_channel')
end

modifier_enfos_lion_mana_drain_channel=class({})
function modifier_enfos_lion_mana_drain_channel:ClearVisual()
    local fx=self.drain_fx
    self.drain_fx=nil -- Clear ownership before engine callbacks can reenter.
    if fx~=nil then
        ParticleManager:DestroyParticle(fx,true)
        ParticleManager:ReleaseParticleIndex(fx)
        Trace:Log('LION','E','beam removed')
    end
end
function modifier_enfos_lion_mana_drain_channel:StartVisual()
    self:ClearVisual()
    local c,t=self:GetParent(),self.drain_target
    if self.closed or not valid(c) or not valid(t) then return end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf',PATTACH_ABSORIGIN_FOLLOW,c)
    local function active() return not self.closed and valid(c) and valid(t) end
    if active() then ParticleManager:SetParticleControlEnt(fx,0,c,PATTACH_ABSORIGIN_FOLLOW,'',c:GetAbsOrigin(),false) end
    if active() then ParticleManager:SetParticleControlEnt(fx,1,t,PATTACH_ABSORIGIN_FOLLOW,'',t:GetAbsOrigin(),false) end
    if not active() then
        ParticleManager:DestroyParticle(fx,true)
        ParticleManager:ReleaseParticleIndex(fx)
        return
    end
    self.drain_fx=fx
    Trace:Log('LION','E','beam created')
end
function modifier_enfos_lion_mana_drain_channel:OnDestroy()
    if not IsServer() or self.closed then return end
    self.closed=true
    self:ClearVisual()
    local caster=self:GetCaster()
    local target=self.drain_target or (self.target_idx and EntIndexToHScript(self.target_idx))
    if valid(target) and valid(caster) then target:RemoveModifierByNameAndCaster('modifier_enfos_lion_mana_drain_debuff',caster) end
    if valid(caster) then caster:StopSound('Hero_Lion.ManaDrain') end
    Trace:Log('LION','E','channel visual teardown')
end
function modifier_enfos_lion_mana_drain_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx=kv and kv.target_idx or nil
    self.drain_target=self.target_idx and EntIndexToHScript(self.target_idx)
    self:StartVisual()
    if not self.closed then self:StartIntervalThink(0.5) end
end
function modifier_enfos_lion_mana_drain_channel:OnRefresh(kv)
    if not IsServer() or self.closed then return end
    local caster,old=self:GetCaster(),self.drain_target
    local index=kv and kv.target_idx
    local target=index and EntIndexToHScript(index)
    if old~=target and valid(old) and valid(caster) then old:RemoveModifierByNameAndCaster('modifier_enfos_lion_mana_drain_debuff',caster) end
    if self.closed then return end
    self.target_idx,self.drain_target=index,target
    self:StartVisual()
    Trace:Log('LION','E','channel visual refreshed')
end
function modifier_enfos_lion_mana_drain_channel:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not c or c:IsNull() or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then
        if a and a.EndChannel then a:EndChannel(true) else self:Destroy() end
        return
    end

    local base = (a and value(a, 'mana_per_second')) or 120
    local int = get_int(c)
    local tick_dmg = (base + (int * 0.8)) * 0.5

    damage(a, t, tick_dmg, DAMAGE_TYPE_MAGICAL)
    if c.GiveMana then c:GiveMana(tick_dmg) end
end

modifier_enfos_lion_mana_drain_debuff=class({})
function modifier_enfos_lion_mana_drain_debuff:IsDebuff() return true end
function modifier_enfos_lion_mana_drain_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_lion_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

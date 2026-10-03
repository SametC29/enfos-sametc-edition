-- Lion E: one explicitly owned channel visual; mana conversion review pending.
local H = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function eligible(c,t)
    return valid(c) and c:IsAlive() and valid(t) and t:IsAlive()
        and c:GetTeamNumber()~=t:GetTeamNumber()
        and not (t.IsBuilding and t:IsBuilding())
        and not (t.IsMagicImmune and t:IsMagicImmune())
        and not (t.IsDebuffImmune and t:IsDebuffImmune())
end
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_mana_drain_channel', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_lion_mana_drain_debuff', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)

enfos_lion_mana_drain=class({})
function enfos_lion_mana_drain:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not eligible(c,t) then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    if not valid(self) or not eligible(c,t) then return end
    local duration = value(self, 'channel_duration')
    if duration <= 0 then return end
    c:EmitSound('Hero_Lion.ManaDrain')
    if not valid(self) or not eligible(c,t) then return end
    c:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_channel', { duration = duration, target_idx = t:entindex() })
    if not valid(self) or not eligible(c,t) then return end
    t:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_debuff', { duration = duration })
end
function enfos_lion_mana_drain:OnChannelFinish(interrupted)
    if not IsServer() or not valid(self) then return end
    local c = self:GetCaster()
    if not valid(c) then return end
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
    local revision=self.revision
    self:ClearVisual()
    local c,t=self:GetParent(),self.drain_target
    if self.closed or self.revision~=revision or not valid(c) or not valid(t) then return end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf',PATTACH_ABSORIGIN_FOLLOW,c)
    local function active() return not self.closed and self.revision==revision and valid(c) and valid(t) end
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
    self.revision=(self.revision or 0)+1
    self.target_idx=kv and kv.target_idx or nil
    self.drain_target=self.target_idx and EntIndexToHScript(self.target_idx)
    self:StartVisual()
    if not self.closed then self:StartIntervalThink(0.5) end
end
function modifier_enfos_lion_mana_drain_channel:OnRefresh(kv)
    if not IsServer() or self.closed then return end
    self.revision=(self.revision or 0)+1
    local revision=self.revision
    local caster,old=self:GetCaster(),self.drain_target
    local index=kv and kv.target_idx
    local target=index and EntIndexToHScript(index)
    if old~=target and valid(old) and valid(caster) then old:RemoveModifierByNameAndCaster('modifier_enfos_lion_mana_drain_debuff',caster) end
    if self.closed or self.revision~=revision then return end
    self.target_idx,self.drain_target=index,target
    self:StartVisual()
    if self.closed or self.revision~=revision then return end
    Trace:Log('LION','E','channel visual refreshed')
end
function modifier_enfos_lion_mana_drain_channel:Abort(reason)
    if self.closed then return end
    local revision=self.revision
    local c,a=self:GetParent(),self:GetAbility()
    Trace:Log('LION','E','channel aborted reason=%s',reason)
    if valid(c) and valid(a) then a:EndChannel(true) end
    if not self.closed and self.revision==revision then self:Destroy() end
end
function modifier_enfos_lion_mana_drain_channel:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local revision=self.revision
    local c,a,t=self:GetParent(),self:GetAbility(),self.drain_target
    if not valid(c) or not c:IsAlive() then self:Abort('caster');return end
    if not valid(a) then self:Abort('ability');return end
    if not valid(t) or not t:IsAlive() then self:Abort('target');return end
    if not eligible(c,t) then self:Abort('target rules');return end
    local tick_dmg=(value(a,'mana_per_second')+get_int(c)*0.8)*0.5
    damage(a,t,tick_dmg,DAMAGE_TYPE_MAGICAL)
    -- Damage can kill/remove entities, close the modifier, or start another cast.
    if self.closed or self.revision~=revision then return end
    if not valid(c) or not c:IsAlive() or not valid(a) then self:Abort('source after damage');return end
    if not valid(t) then self:Abort('target after damage');return end
    if t:IsAlive() and not eligible(c,t) then self:Abort('target rules after damage');return end
    if c.GiveMana then c:GiveMana(tick_dmg) end
    if self.closed or self.revision~=revision then return end
    if not valid(c) or not c:IsAlive() or not valid(a) then self:Abort('source after mana');return end
    if not valid(t) or not t:IsAlive() then self:Abort('target after tick');return end
    if not eligible(c,t) then self:Abort('target rules after mana');return end
    Trace:Log('LION','E','channel tick authored_damage=%.2f authored_mana=%.2f',tick_dmg,tick_dmg)
end

modifier_enfos_lion_mana_drain_debuff=class({})
function modifier_enfos_lion_mana_drain_debuff:IsDebuff() return true end
function modifier_enfos_lion_mana_drain_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_lion_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

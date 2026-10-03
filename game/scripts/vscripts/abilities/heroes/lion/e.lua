-- Lion E: one explicitly owned channel visual; mana conversion review pending.
local H = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')
local Upgrades = require('abilities/heroes/lion/upgrades')
local Extras = require('abilities/heroes/lion/drain_extras')
local Economy = require('abilities/heroes/lion/drain_economy')
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function learned_source(a,c)
    return valid(a) and valid(c) and a:GetLevel()>0 and a:GetCaster()==c
end
local function eligible(c,t)
    return valid(c) and c:IsAlive() and valid(t) and t:IsAlive()
        and c:GetTeamNumber()~=t:GetTeamNumber()
        and not (t.IsBuilding and t:IsBuilding())
        and not (t.IsMagicImmune and t:IsMagicImmune())
        and not (t.IsDebuffImmune and t:IsDebuffImmune())
end
-- FoW lookup is server-only; client modifier getters use ordinary eligibility.
local function visible_enemy(c,t)
    return eligible(c,t) and not t:IsInvisible() and c:CanEntityBeSeenByMyTeam(t)
end
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_mana_drain_channel', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_lion_mana_drain_debuff', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)

enfos_lion_mana_drain=class({})
function enfos_lion_mana_drain:GetDrainBreakDistance()
    if not valid(self) then return 0 end
    local c=self:GetCaster()
    if not valid(c) then return 0 end
    return value(self,'break_distance')+(Upgrades.HasShard(c) and value(self,'shard_break_distance_bonus') or 0)
end
function enfos_lion_mana_drain:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c = self:GetCaster()
    if not learned_source(self,c) then return end
    local t = self:GetCursorTarget()
    if not visible_enemy(c,t) then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    if not learned_source(self,c) or not visible_enemy(c,t) then return end
    local duration = value(self, 'channel_duration')
    if duration <= 0 then return end
    c:EmitSound('Hero_Lion.ManaDrain')
    if not learned_source(self,c) or not visible_enemy(c,t) then return end
    c:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_channel', { duration = duration, target_idx = t:entindex() })
    if not learned_source(self,c) or not visible_enemy(c,t) then return end
    t:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_debuff', { duration = duration })
end
function enfos_lion_mana_drain:OnChannelFinish(interrupted)
    if not IsServer() or not valid(self) then return end
    local c = self:GetCaster()
    if not valid(c) then return end
    local m = c:FindModifierByName('modifier_enfos_lion_mana_drain_channel')
    -- A finish callback owns its source, not every same-name channel on the unit.
    -- Rank loss must still allow the legitimately owned channel to clean up.
    if not valid(m) or m.closed or m:GetAbility()~=self or m:GetParent()~=c then return end
    m:Destroy()
end

modifier_enfos_lion_mana_drain_channel=class({})
local function shard_channel_active(m)
    if m.closed or not valid(m) then return false end
    local c,a=m:GetParent(),m:GetAbility()
    if not learned_source(a,c) or not c:IsAlive() then return false end
    if IsServer() and not a:IsChanneling() then return false end
    return Upgrades.HasShard(c)
end
function modifier_enfos_lion_mana_drain_channel:IsHidden() return false end
function modifier_enfos_lion_mana_drain_channel:IsPurgable() return false end
function modifier_enfos_lion_mana_drain_channel:IsPurgeException() return false end
function modifier_enfos_lion_mana_drain_channel:GetTexture() return 'lion_mana_drain' end
function modifier_enfos_lion_mana_drain_channel:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_enfos_lion_mana_drain_channel:CheckState()
    return {[MODIFIER_STATE_DEBUFF_IMMUNE]=shard_channel_active(self)}
end
function modifier_enfos_lion_mana_drain_channel:GetModifierMagicalResistanceBonus()
    return shard_channel_active(self) and value(self:GetAbility(),'shard_magic_resistance') or 0
end
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
    if self.closed or self.revision~=revision or not learned_source(self:GetAbility(),c) or not valid(t) then return end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf',PATTACH_ABSORIGIN_FOLLOW,c)
    local function active() return not self.closed and self.revision==revision and learned_source(self:GetAbility(),c) and valid(t) end
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
    local caster=self:GetCaster()
    local target=self.drain_target
    -- Close old sound/slow before particle cleanup can start a fresh channel.
    if valid(caster) then caster:StopSound('Hero_Lion.ManaDrain') end
    if valid(target) and valid(caster) then target:RemoveModifierByNameAndCaster('modifier_enfos_lion_mana_drain_debuff',caster) end
    Extras.Clear(self)
    self:ClearVisual()
    Trace:Log('LION','E','channel visual teardown')
end
function modifier_enfos_lion_mana_drain_channel:OnCreated(kv)
    if not IsServer() then return end
    self.revision=(self.revision or 0)+1
    local revision=self.revision
    self.target_idx=kv and kv.target_idx or nil
    self.drain_target=self.target_idx and EntIndexToHScript(self.target_idx)
    self:StartVisual()
    if not self.closed and self.revision==revision then Extras.Start(self,visible_enemy,value(self:GetAbility(),'shard_bonus_targets')) end
    if not self.closed and self.revision==revision then self:StartIntervalThink(0.5) end
end
function modifier_enfos_lion_mana_drain_channel:OnRefresh(kv)
    if not IsServer() or self.closed then return end
    self.revision=(self.revision or 0)+1
    local revision=self.revision
    Extras.Clear(self)
    if self.closed or self.revision~=revision then return end
    local caster,old=self:GetCaster(),self.drain_target
    local index=kv and kv.target_idx
    local target=index and EntIndexToHScript(index)
    if old~=target and valid(old) and valid(caster) then old:RemoveModifierByNameAndCaster('modifier_enfos_lion_mana_drain_debuff',caster) end
    if self.closed or self.revision~=revision then return end
    self.target_idx,self.drain_target=index,target
    self:StartVisual()
    if self.closed or self.revision~=revision then return end
    Extras.Start(self,visible_enemy,value(self:GetAbility(),'shard_bonus_targets'))
    if self.closed or self.revision~=revision then return end
    -- The new recipients own a fresh cadence, not the previous cast's deadline.
    self:StartIntervalThink(0.5)
    Trace:Log('LION','E','channel visual refreshed')
end
function modifier_enfos_lion_mana_drain_channel:Abort(reason)
    if self.closed then return end
    local revision=self.revision
    local c,a=self:GetParent(),self:GetAbility()
    Trace:Log('LION','E','channel aborted reason=%s',reason)
    if valid(c) and valid(a) and a:GetCaster()==c then a:EndChannel(true) end
    if not self.closed and self.revision==revision then self:Destroy() end
end
function modifier_enfos_lion_mana_drain_channel:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local revision=self.revision
    local c,a,t=self:GetParent(),self:GetAbility(),self.drain_target
    if not valid(c) or not c:IsAlive() then self:Abort('caster');return end
    if not learned_source(a,c) then self:Abort('ability rank or owner');return end
    if not valid(t) or not t:IsAlive() then self:Abort('target');return end
    if not visible_enemy(c,t) then self:Abort('target rules or visibility');return end
    if not a:IsChanneling() then
        Trace:Log('LION','E','inactive engine channel cleaned')
        self:Destroy();return
    end
    local leash=a:GetDrainBreakDistance()
    if leash<=0 then self:Abort('invalid leash');return end
    local source,destination=c:GetAbsOrigin(),t:GetAbsOrigin()
    local dx,dy=source.x-destination.x,source.y-destination.y
    if dx*dx+dy*dy>leash*leash then self:Abort('leash');return end
    local tick_dmg=(value(a,'mana_per_second')+get_int(c)*0.8)*0.5
    local gained,mode=Economy.Take(a,t,tick_dmg)
    -- Mana reduction or damage can close the modifier or start another cast.
    if self.closed or self.revision~=revision then return end
    if not learned_source(a,c) or not c:IsAlive() then self:Abort('source after damage');return end
    if not a:IsChanneling() then self:Destroy();return end
    if not valid(t) then self:Abort('target after damage');return end
    if t:IsAlive() and not visible_enemy(c,t) then self:Abort('target rules or visibility after damage');return end
    if gained>0 then c:GiveMana(gained) end
    if self.closed or self.revision~=revision then return end
    if not learned_source(a,c) or not c:IsAlive() then self:Abort('source after mana');return end
    if not a:IsChanneling() then self:Destroy();return end
    if not valid(t) or not t:IsAlive() then self:Abort('target after tick');return end
    if not visible_enemy(c,t) then self:Abort('target rules or visibility after mana');return end
    Extras.Tick(self,revision,tick_dmg,visible_enemy)
    if self.closed or self.revision~=revision then return end
    Trace:Log('LION','E','channel tick mode=%s requested=%.2f mana=%.2f',mode,tick_dmg,gained)
end

modifier_enfos_lion_mana_drain_debuff=class({})
function modifier_enfos_lion_mana_drain_debuff:IsDebuff() return true end
function modifier_enfos_lion_mana_drain_debuff:IsHidden() return false end
function modifier_enfos_lion_mana_drain_debuff:IsPurgable() return false end
function modifier_enfos_lion_mana_drain_debuff:IsPurgeException() return false end
function modifier_enfos_lion_mana_drain_debuff:GetTexture() return 'lion_mana_drain' end
function modifier_enfos_lion_mana_drain_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_lion_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage()
    if self.closed or not valid(self) then return 0 end
    local a=self:GetAbility()
    if not learned_source(a,self:GetCaster()) or not eligible(self:GetCaster(),self:GetParent()) then return 0 end
    local t=self:GetParent()
    local slow=value(a,'slow_pct')
    if t:GetMaxMana()>0 and t:GetMana()<=0 then slow=slow+value(a,'movespeed_bonus_when_empty_pct') end
    return -slow
end
function modifier_enfos_lion_mana_drain_debuff:TraceLifecycle(event)
    if Trace:Enabled() then Trace:Log('LION','E','slow %s movement_pct=%.1f',event,self:GetModifierMoveSpeedBonus_Percentage()) end
end
function modifier_enfos_lion_mana_drain_debuff:OnCreated()
    self.closed=false
    self:TraceLifecycle('applied')
end
function modifier_enfos_lion_mana_drain_debuff:OnRefresh()
    if not self.closed then self:TraceLifecycle('refreshed') end
end
function modifier_enfos_lion_mana_drain_debuff:OnDestroy()
    if self.closed then return end
    self:TraceLifecycle('removed')
    self.closed=true
end

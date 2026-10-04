require('abilities/heroes/storm_spirit/modifier_links')
enfos_storm_overload=class({})
local function provider(a)
    local c=a:GetCaster()
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_storm_spirit' or a:GetLevel()<1 then return end
    local n=c:FindAbilityByName('storm_spirit_overload')
    if n and not n:IsNull() and n:GetLevel()>0 then return n end
end
function enfos_storm_overload:GetIntrinsicModifierName() return 'modifier_enfos_storm_native_scaling' end
function enfos_storm_overload:OnUpgrade()
    if IsServer() then require('abilities/heroes/storm_spirit/integration').Restore(self:GetCaster()) end
end
function enfos_storm_overload:GetBehavior()
    local n=provider(self)
    return n and bit.band(n:GetBehavior(),bit.bnot(DOTA_ABILITY_BEHAVIOR_HIDDEN)) or DOTA_ABILITY_BEHAVIOR_PASSIVE
end
function enfos_storm_overload:GetManaCost(level)
    local n=provider(self)
    return n and n:GetSpecialValueFor('shard_manacost') or 0
end
function enfos_storm_overload:GetCooldown(level)
    local n=provider(self)
    return n and n:GetSpecialValueFor('shard_cooldown') or 0
end
function enfos_storm_overload:GetCastRange(location,target) return 0 end
function enfos_storm_overload:GetAOERadius()
    local n=provider(self)
    return n and n:GetSpecialValueFor('shard_activation_radius') or 0
end
function enfos_storm_overload:OnSpellStart()
    if not IsServer() then return end
    local n=provider(self)
    if not n or n:GetSpecialValueFor('shard_activation_charges')<=0 then
        self:EndCooldown();self:RefundManaCost();return
    end
    n:OnSpellStart()
    if not n:IsNull() and not self:IsNull() then n:StartCooldown(self:GetCooldownTimeRemaining()) end
    require('lib/hero_trace'):Log('STORM','E','native_shard_cast paid_rank=%s',tostring(self:GetLevel()))
end

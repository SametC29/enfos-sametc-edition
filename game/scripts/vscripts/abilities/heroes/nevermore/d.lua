-- ENFOS passive sustain is not native Frenzy (an active ability).
-- Classes only; links belong to modifier_links.lua, shared by both bootstraps.
local Helpers = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')

enfos_sf_feast_of_souls=class({})
function enfos_sf_feast_of_souls:GetIntrinsicModifierName()
    return 'modifier_enfos_sf_feast_of_souls_passive'
end

modifier_enfos_sf_feast_of_souls_passive=class({})
local D=modifier_enfos_sf_feast_of_souls_passive
function D:IsHidden() return true end
function D:IsPurgable() return false end
function D:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end

local function source_ready(caster, ability)
    return caster and not caster:IsNull() and caster:IsAlive()
        and not caster:PassivesDisabled() and not caster:IsIllusion()
        and ability and not (ability.IsNull and ability:IsNull())
        and (not ability.GetLevel or ability:GetLevel()>0)
end

function D:OnDeath(event)
    if not IsServer() then return end
    local caster, ability = self:GetParent(), self:GetAbility()
    if not source_ready(caster, ability) then return end
    local victim=event and event.unit
    if not event or event.attacker~=caster or not victim or victim==caster
        or victim:IsNull() or victim:GetTeamNumber()==caster:GetTeamNumber()
        or victim:IsIllusion() then return end
    caster:Heal(Helpers.value(ability,'hp_per_kill'),ability)
    -- Healing callbacks may invalidate the caster/ability before the mana grant.
    if not source_ready(caster, ability) then return end
    caster:GiveMana(Helpers.value(ability,'mana_per_kill'))
    Trace:Log('SF','D','kill_sustain_applied victim=%s rank=%s',Trace:Name(victim),
        tostring(ability.GetLevel and ability:GetLevel() or '?'))
end

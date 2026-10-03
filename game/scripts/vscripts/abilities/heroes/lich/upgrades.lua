-- Reuse the authoritative acquisition/consumed-Blessing detection.
local Aghanim = require('heroes/aghanim_manager')
local Upgrades = {}
function Upgrades.HasScepter(caster) return Aghanim:HasScepter(caster) end
function Upgrades.CastBehavior(ability)
    local caster = ability:GetCaster()
    local gaze = caster and not caster:IsNull() and caster.FindAbilityByName
        and caster:FindAbilityByName('enfos_lich_sinister_gaze')
    if Upgrades.HasScepter(caster) and gaze and not gaze:IsNull() and gaze.gazeTargets then
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end
return Upgrades

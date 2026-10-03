-- Native Q damage scaling and native Eclipse's original-name Beam provider.
local Trace = require('lib/hero_trace')

local Scaling={}
function Scaling.Restore(hero)
    local q=hero:FindAbilityByName('enfos_luna_lucent_beam')
    if not q then return false end -- Native Boss Luna has no ENFOS Q.
    local peer=hero:FindAbilityByName('luna_lucent_beam')
    if not peer then peer=hero:AddAbility('luna_lucent_beam') end
    if not peer or peer:IsNull() then
        Trace:Log('LUNA','R','native_beam_provider_missing')
        return false
    end
    -- Keep the native provider at its safe first rank. Its beam_damage query
    -- resolves the current paid ENFOS Q rank through the modifier above.
    if peer:GetLevel()~=1 then peer:SetLevel(1) end
    peer:SetHidden(true)
    peer:SetActivated(false)
    if not hero:HasModifier('modifier_enfos_luna_native_scaling') then
        local modifier=hero:AddNewModifier(hero,q,'modifier_enfos_luna_native_scaling',{})
        if not modifier or (modifier.IsNull and modifier:IsNull()) then
            Trace:Log('LUNA','Q','native_scaling_modifier_missing')
            return false
        end
    end
    Trace:Log('LUNA','Q','native_scaling_ready rank=%s agility_multiplier=1.5',tostring(q:GetLevel()))
    Trace:Log('LUNA','R','native_beam_provider_ready ability=luna_lucent_beam hidden=true rank=1')
    return true
end
return Scaling

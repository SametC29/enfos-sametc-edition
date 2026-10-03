-- Only authored ENFOS armor/movement remain custom; native Blessing owns damage/vision.
local Trace=require('lib/hero_trace')

local Extension={}
function Extension.Restore(hero)
    local ability=hero:FindAbilityByName('enfos_luna_lunar_blessing')
    if not ability then return false end
    if not hero:HasModifier('modifier_enfos_luna_blessing_extension') then
        local modifier=hero:AddNewModifier(hero,ability,'modifier_enfos_luna_blessing_extension',{})
        if not modifier or (modifier.IsNull and modifier:IsNull()) then
            Trace:Log('LUNA','E','native_blessing_extension_missing')
            return false
        end
    end
    Trace:Log('LUNA','E','native_blessing_extension_ready rank=%s damage_owner=native armor_speed_owner=enfos',tostring(ability:GetLevel()))
    return true
end
return Extension

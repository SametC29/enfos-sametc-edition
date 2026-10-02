-- Shared existing PvE helpers; extracted without gameplay changes.
local function value(a, k)
    if not a or (a.IsNull and a:IsNull()) then return 0 end
    return (a.GetSpecialValueFor and a:GetSpecialValueFor(k)) or 0
end

local function enemies(c, p, r, target_flags)
    if not c or (c.IsNull and c:IsNull()) then return {} end
    return FindUnitsInRadius(c:GetTeamNumber(), p, nil, r, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_flags or DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false) or {}
end

local function is_boss(target)
    if not target or (target.IsNull and target:IsNull()) then return false end
    if target.isBoss == true then return true end
    local name = (target.GetUnitName and target:GetUnitName()) or ""
    return name:find("enfos_boss_", 1, true) ~= nil
end

local function get_int(c)
    if not c or (c.IsNull and c:IsNull()) then return 0 end
    if c.GetIntellect then
        local ok, val = pcall(c.GetIntellect, c, false)
        if ok and type(val) == "number" then return val end
        ok, val = pcall(c.GetIntellect, c)
        if ok and type(val) == "number" then return val end
    end
    return 0
end

local function damage(a, target, amount, kind, flags)
    if target and not (target.IsNull and target:IsNull()) and (target.IsAlive and target:IsAlive()) and amount and amount > 0 then
        local caster = (a and not (a.IsNull and a:IsNull()) and a.GetCaster) and a:GetCaster() or nil
        return ApplyDamage({
            victim = target,
            attacker = caster,
            ability = a,
            damage = amount,
            damage_flags = flags or 0,
            damage_type = kind or (a and a.GetAbilityDamageType and a:GetAbilityDamageType()) or DAMAGE_TYPE_PHYSICAL
        })
    end
end

return { value = value, enemies = enemies, is_boss = is_boss, get_int = get_int, damage = damage }

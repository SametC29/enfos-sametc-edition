-- Enfos Team Survival — SametC Edition: Authoritative PvE Hero Kits (Batch 1)
-- Implements complete, high-synergy PvE kits for 6 representative heroes:
-- Sven (Tank), Juggernaut (Fighter), Drow Ranger (Carry), Lina (Mage), Omniknight (Support), Luna (Carry)

local function value(a, k)
    if not a or (a.IsNull and a:IsNull()) then return 0 end
    return (a.GetSpecialValueFor and a:GetSpecialValueFor(k)) or 0
end

local function enemies(c, p, r)
    if not c or (c.IsNull and c:IsNull()) then return {} end
    return FindUnitsInRadius(c:GetTeamNumber(), p, nil, r, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false) or {}
end

local function allies(c, p, r)
    if not c or (c.IsNull and c:IsNull()) then return {} end
    return FindUnitsInRadius(c:GetTeamNumber(), p, nil, r, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false) or {}
end

local function is_boss(target)
    if not target or (target.IsNull and target:IsNull()) then return false end
    local name = (target.GetUnitName and target:GetUnitName()) or ""
    return name:find("enfos_boss_", 1, true) ~= nil
end

local function damage(a, target, amount, kind)
    if target and not (target.IsNull and target:IsNull()) and (target.IsAlive and target:IsAlive()) and amount and amount > 0 then
        local caster = (a and not (a.IsNull and a:IsNull()) and a.GetCaster) and a:GetCaster() or nil
        ApplyDamage({
            victim = target,
            attacker = caster,
            ability = a,
            damage = amount,
            damage_type = kind or (a and a.GetAbilityDamageType and a:GetAbilityDamageType()) or DAMAGE_TYPE_PHYSICAL
        })
    end
end

local function effect(path, target)
    if not target or (target.IsNull and target:IsNull()) or not ParticleManager then return end
    local p = ParticleManager:CreateParticle(path, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(p)
end

-- Link all Lua modifiers
local modifier_list = {
    -- Sven
    'modifier_bulwark_shield_slam_slow',
    'modifier_enfos_pve_warcry',
    'modifier_enfos_pve_taunt',
    'modifier_bulwark_iron_guard',
    'modifier_bulwark_fortress',
    'modifier_bulwark_unbreakable',
    'modifier_bulwark_gods_strength',
    -- Juggernaut
    'modifier_enfos_pve_fury',
    'modifier_enfos_juggernaut_healing_ward_thinker',
    'modifier_enfos_juggernaut_healing_ward_aura',
    'modifier_enfos_pve_crit',
    'modifier_enfos_pve_slashes',
    'modifier_enfos_juggernaut_duelist',
    'modifier_enfos_juggernaut_duelist_stack',
    -- Drow Ranger
    'modifier_enfos_pve_frost',
    'modifier_enfos_pve_slow',
    'modifier_enfos_pve_gust_vulnerable',
    'modifier_enfos_pve_marksmanship',
    'modifier_enfos_pve_precision',
    'modifier_enfos_pve_precision_buff',
    -- Lina
    'modifier_enfos_pve_fiery',
    'modifier_enfos_pve_fiery_stacks',
    'modifier_enfos_pve_combustion',
    'modifier_enfos_pve_burn',
    -- Omniknight
    'modifier_enfos_pve_repel',
    'modifier_enfos_pve_degen_aura',
    'modifier_enfos_pve_degen_debuff',
    'modifier_enfos_pve_angel',
    'modifier_enfos_pve_hammer',
    -- Luna
    'modifier_enfos_luna_moon_glaives_passive',
    'modifier_enfos_luna_lunar_blessing',
    'modifier_enfos_luna_lunar_blessing_aura',
    'modifier_enfos_luna_eclipse_thinker',
    'modifier_enfos_luna_lunar_orbit',
    'modifier_enfos_luna_lunar_orbit_buff'
}

for _, mod_name in ipairs(modifier_list) do
    LinkLuaModifier(mod_name, 'abilities/pve_kits', LUA_MODIFIER_MOTION_NONE)
end

-- Backward compatibility aliases for existing tests
modifier_enfos_pve_warcry=class({})
modifier_enfos_pve_taunt=class({})
modifier_enfos_pve_fury=class({})
modifier_enfos_pve_crit=class({})
modifier_enfos_pve_slashes=class({})
modifier_enfos_pve_frost=class({})
modifier_enfos_pve_slow=class({})
modifier_enfos_pve_marksmanship=class({})
modifier_enfos_pve_precision=class({})
modifier_enfos_pve_fiery=class({})
modifier_enfos_pve_fiery_stacks=class({})
modifier_enfos_pve_combustion=class({})
modifier_enfos_pve_burn=class({})
modifier_enfos_pve_angel=class({})

-- =========================================================================
-- SVEN (TANK)
-- =========================================================================

bulwark_shield_slam=class({})
function bulwark_shield_slam:OnSpellStart()
    local c = self:GetCaster()
    local origin = c:GetAbsOrigin()
    local radius = value(self, 'radius')
    if radius <= 0 then radius = 400 end
    local str = c.GetStrength and c:GetStrength() or 0
    local armor = c.GetPhysicalArmorValue and c:GetPhysicalArmorValue(false) or 0
    local total_damage = value(self, 'damage') + (str * 2.0) + (armor * 8.0)

    c:EmitSound('Hero_Sven.StormBolt')
    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf', PATTACH_ABSORIGIN, c)
    ParticleManager:ReleaseParticleIndex(p)

    for _, u in ipairs(enemies(c, origin, radius)) do
        damage(self, u, total_damage, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, self, 'modifier_bulwark_shield_slam_slow', { duration = value(self, 'slow_duration') })
        if not is_boss(u) then
            local dir = (u:GetAbsOrigin() - origin):Normalized()
            dir.z = 0
            u:SetAbsOrigin(u:GetAbsOrigin() + dir * 80)
            FindClearSpaceForUnit(u, u:GetAbsOrigin(), true)
        end
    end
end

modifier_bulwark_shield_slam_slow=class({})
function modifier_bulwark_shield_slam_slow:IsDebuff() return true end
function modifier_bulwark_shield_slam_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_bulwark_shield_slam_slow:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'slow_pct') end

bulwark_challenge=class({})
function bulwark_challenge:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Sven.WarCry')
    local dur = value(self, 'duration')
    c:AddNewModifier(c, self, 'modifier_enfos_pve_warcry', { duration = dur })

    for _, a in ipairs(allies(c, c:GetAbsOrigin(), value(self, 'radius'))) do
        a:AddNewModifier(c, self, 'modifier_enfos_pve_warcry', { duration = dur })
    end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(self, 'radius'))) do
        if u:GetUnitName() ~= 'enfos_creep_runner' then
            local t_dur = dur * (is_boss(u) and 0.25 or 1.0)
            local status_res = u.GetStatusResistance and u:GetStatusResistance() or 0
            u:AddNewModifier(c, self, 'modifier_enfos_pve_taunt', { duration = t_dur * (1 - status_res) })
        end
    end
end

function modifier_enfos_pve_warcry:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_pve_warcry:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'bonus_armor') end
function modifier_enfos_pve_warcry:GetModifierMoveSpeedBonus_Percentage() return 20 end
function modifier_enfos_pve_warcry:GetEffectName() return 'particles/units/heroes/hero_sven/sven_warcry_buff.vpcf' end

function modifier_enfos_pve_taunt:IsDebuff() return true end
function modifier_enfos_pve_taunt:CheckState() return { [MODIFIER_STATE_TAUNTED] = true } end
function modifier_enfos_pve_taunt:OnCreated()
    if not IsServer() then return end
    self:GetParent():SetForceAttackTarget(self:GetCaster())
    self:StartIntervalThink(0.2)
end
function modifier_enfos_pve_taunt:OnIntervalThink()
    local c = self:GetCaster()
    if not c or c:IsNull() or not c:IsAlive() then self:Destroy() end
end
function modifier_enfos_pve_taunt:OnDestroy()
    if IsServer() then self:GetParent():SetForceAttackTarget(nil) end
end

bulwark_iron_guard=class({})
function bulwark_iron_guard:GetIntrinsicModifierName() return 'modifier_bulwark_iron_guard' end

modifier_bulwark_iron_guard=class({})
function modifier_bulwark_iron_guard:IsHidden() return true end
function modifier_bulwark_iron_guard:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_bulwark_iron_guard:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'bonus_armor') end
function modifier_bulwark_iron_guard:GetModifierPhysical_ConstantBlock() return value(self:GetAbility(), 'damage_block') end
function modifier_bulwark_iron_guard:OnTakeDamage(e)
    if not IsServer() or e.unit ~= self:GetParent() or not e.attacker or e.attacker:IsNull() or e.attacker == e.unit then return end
    if e.damage_flags and bit and bit.band(e.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0 then return end
    local block = value(self:GetAbility(), 'damage_block')
    if block > 0 then
        local reflect = block * 0.3
        damage(self:GetAbility(), e.attacker, reflect, DAMAGE_TYPE_PHYSICAL)
    end
end

bulwark_fortress=class({})
function bulwark_fortress:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Sven.IronWill')
    c:AddNewModifier(c, self, 'modifier_bulwark_fortress', { duration = value(self, 'duration') })
end

modifier_bulwark_fortress=class({})
function modifier_bulwark_fortress:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE } end
function modifier_bulwark_fortress:GetModifierIncomingDamage_Percentage() return -value(self:GetAbility(), 'damage_reduction_pct') end
function modifier_bulwark_fortress:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.5)
end
function modifier_bulwark_fortress:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local str = c.GetStrength and c:GetStrength() or 0
    local dmg = value(a, 'shockwave_damage') + (str * 1.0)
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(a, 'radius'))) do
        damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL)
    end
    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf', PATTACH_ABSORIGIN, c)
    ParticleManager:ReleaseParticleIndex(p)
end

bulwark_unbreakable=class({})
function bulwark_unbreakable:GetIntrinsicModifierName() return 'modifier_bulwark_unbreakable' end
function bulwark_unbreakable:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Sven.GodsStrength')
    c:AddNewModifier(c, self, 'modifier_bulwark_gods_strength', { duration = value(self, 'gods_strength_duration') })
end

modifier_bulwark_unbreakable=class({})
function modifier_bulwark_unbreakable:IsHidden() return true end
function modifier_bulwark_unbreakable:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_bulwark_unbreakable:OnAttackLanded(e)
    local c = self:GetParent()
    if not IsServer() or e.attacker ~= c or c:PassivesDisabled() or e.target:GetTeamNumber() == c:GetTeamNumber() then return end
    local cleave_pct = value(self:GetAbility(), 'cleave_pct')
    if cleave_pct <= 0 then cleave_pct = 60 end
    local cleave_dmg = (e.original_damage or c:GetAverageTrueAttackDamage(e.target)) * (cleave_pct / 100)
    for _, u in ipairs(enemies(c, e.target:GetAbsOrigin(), 380)) do
        if u ~= e.target then damage(self:GetAbility(), u, cleave_dmg, DAMAGE_TYPE_PHYSICAL) end
    end
end

modifier_bulwark_gods_strength=class({})
function modifier_bulwark_gods_strength:DeclareFunctions()
    return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end
function modifier_bulwark_gods_strength:GetModifierBaseDamageOutgoing_Percentage() return value(self:GetAbility(), 'bonus_damage_pct') end
function modifier_bulwark_gods_strength:GetModifierConstantHealthRegen() return 25 end
function modifier_bulwark_gods_strength:GetEffectName() return 'particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf' end

-- =========================================================================
-- JUGGERNAUT (FIGHTER)
-- =========================================================================

enfos_juggernaut_blade_fury=class({})
function enfos_juggernaut_blade_fury:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Juggernaut.BladeFuryStart')
    c:AddNewModifier(c, self, 'modifier_enfos_pve_fury', { duration = value(self, 'duration') })
end

function modifier_enfos_pve_fury:OnCreated()
    if IsServer() then self:StartIntervalThink(value(self:GetAbility(), 'tick_interval')) end
end
function modifier_enfos_pve_fury:OnIntervalThink()
    local a = self:GetAbility()
    local c = self:GetParent()
    local agi = c.GetAgility and c:GetAgility() or 0
    local dps = value(a, 'damage_per_sec') + (agi * 1.5)
    local tick = value(a, 'tick_interval')
    if tick <= 0 then tick = 0.2 end
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(a, 'radius'))) do
        damage(a, u, dps * tick, DAMAGE_TYPE_MAGICAL)
    end
end
function modifier_enfos_pve_fury:CheckState()
    return { [MODIFIER_STATE_MAGIC_IMMUNE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true }
end
function modifier_enfos_pve_fury:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_enfos_pve_fury:GetModifierStatusResistanceStacking() return value(self:GetAbility(), 'status_resistance') end
function modifier_enfos_pve_fury:GetModifierMoveSpeedBonus_Constant() return 40 end
function modifier_enfos_pve_fury:GetEffectName() return 'particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf' end
function modifier_enfos_pve_fury:OnDestroy()
    if IsServer() then self:GetParent():StopSound('Hero_Juggernaut.BladeFuryStart') end
end

enfos_juggernaut_healing_ward=class({})
function enfos_juggernaut_healing_ward:OnSpellStart()
    local c = self:GetCaster()
    local point = self:GetCursorPosition()
    c:EmitSound('Hero_Juggernaut.HealingWard.Cast')
    CreateModifierThinker(c, self, 'modifier_enfos_juggernaut_healing_ward_thinker', { duration = value(self, 'duration') }, point, c:GetTeamNumber(), false)
end

modifier_enfos_juggernaut_healing_ward_thinker=class({})
function modifier_enfos_juggernaut_healing_ward_thinker:IsAura() return true end
function modifier_enfos_juggernaut_healing_ward_thinker:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_juggernaut_healing_ward_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_juggernaut_healing_ward_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_juggernaut_healing_ward_thinker:GetModifierAura() return 'modifier_enfos_juggernaut_healing_ward_aura' end

modifier_enfos_juggernaut_healing_ward_aura=class({})
function modifier_enfos_juggernaut_healing_ward_aura:DeclareFunctions() return { MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE } end
function modifier_enfos_juggernaut_healing_ward_aura:GetModifierHealthRegenPercentage() return value(self:GetAbility(), 'heal_pct') end

enfos_juggernaut_blade_dance=class({})
function enfos_juggernaut_blade_dance:GetIntrinsicModifierName() return 'modifier_enfos_pve_crit' end

function modifier_enfos_pve_crit:IsHidden() return true end
function modifier_enfos_pve_crit:DeclareFunctions() return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_pve_crit:GetModifierPreAttack_CriticalStrike(event)
    if IsServer() and not self:GetParent():PassivesDisabled() and event.target and event.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber()
        and RollPercentage(value(self:GetAbility(), 'crit_chance')) then
        self.is_crit = true
        return value(self:GetAbility(), 'crit_mult')
    end
    self.is_crit = false
end
function modifier_enfos_pve_crit:OnAttackLanded(event)
    if not IsServer() or event.attacker ~= self:GetParent() or not self.is_crit then return end
    local c = self:GetParent()
    local a = self:GetAbility()
    local dmg = (c:GetAverageTrueAttackDamage(event.target)) * 0.6
    for _, u in ipairs(enemies(c, event.target:GetAbsOrigin(), 350)) do
        if u ~= event.target then damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL) end
    end
    effect('particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf', event.target)
end

enfos_juggernaut_omni_slash=class({})
function enfos_juggernaut_omni_slash:OnSpellStart()
    local t = self:GetCursorTarget()
    if t:TriggerSpellAbsorb(self) then return end
    self:GetCaster():EmitSound('Hero_Juggernaut.OmniSlash')
    self:GetCaster():AddNewModifier(self:GetCaster(), self, 'modifier_enfos_pve_slashes', { duration = value(self, 'duration'), target = t:entindex() })
end

function modifier_enfos_pve_slashes:IsPurgable() return false end
function modifier_enfos_pve_slashes:CheckState()
    return { [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true }
end
function modifier_enfos_pve_slashes:OnCreated(kv)
    if not IsServer() then return end
    self.home = self:GetParent():GetAbsOrigin()
    self.target = EntIndexToHScript(kv.target)
    self:OnIntervalThink()
    self:StartIntervalThink(value(self:GetAbility(), 'slash_interval'))
end
function modifier_enfos_pve_slashes:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    if not c:IsAlive() then self:Destroy(); return end
    local t = self.target
    if not t or t:IsNull() or not t:IsAlive() then t = enemies(c, c:GetAbsOrigin(), value(a, 'radius'))[1] end
    if not t or (t:GetAbsOrigin() - self.home):Length2D() > 1400 then self:Destroy(); return end
    c:SetAbsOrigin(t:GetAbsOrigin() + Vector(64, 0, 0))
    damage(a, t, c:GetAverageTrueAttackDamage(t) + value(a, 'bonus_damage'), DAMAGE_TYPE_PHYSICAL)
    effect('particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf', t)
    self.target = nil
end
function modifier_enfos_pve_slashes:OnDestroy()
    if IsServer() and self.home then FindClearSpaceForUnit(self:GetParent(), self.home, true) end
end

enfos_juggernaut_duelist=class({})
function enfos_juggernaut_duelist:GetIntrinsicModifierName() return 'modifier_enfos_juggernaut_duelist' end

modifier_enfos_juggernaut_duelist=class({})
function modifier_enfos_juggernaut_duelist:IsHidden() return true end
function modifier_enfos_juggernaut_duelist:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_juggernaut_duelist:OnDeath(e)
    local c = self:GetParent()
    if not IsServer() or e.attacker ~= c or e.unit:GetTeamNumber() == c:GetTeamNumber() then return end
    local mod = c:FindModifierByName('modifier_enfos_juggernaut_duelist_stack')
    if not mod then
        mod = c:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_juggernaut_duelist_stack', { duration = 7.0 })
    end
    if mod then
        mod:SetStackCount(math.min(mod:GetStackCount() + 1, 10))
        mod:SetDuration(7.0, true)
    end
end

modifier_enfos_juggernaut_duelist_stack=class({})
function modifier_enfos_juggernaut_duelist_stack:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_juggernaut_duelist_stack:GetModifierAttackSpeedBonus_Constant() return self:GetStackCount() * 12 end
function modifier_enfos_juggernaut_duelist_stack:GetModifierPhysicalArmorBonus() return self:GetStackCount() * 2 end
function modifier_enfos_juggernaut_duelist_stack:GetModifierMoveSpeedBonus_Percentage() return self:GetStackCount() * 2 end
function modifier_enfos_juggernaut_duelist_stack:OnAttackLanded(e)
    if not IsServer() or e.attacker ~= self:GetParent() or self:GetStackCount() < 10 then return end
    local heal = (e.damage or 0) * 0.20
    if heal > 0 then self:GetParent():Heal(heal, self:GetAbility()) end
end

-- =========================================================================
-- DROW RANGER (CARRY)
-- =========================================================================

enfos_drow_frost_arrows=class({})
function enfos_drow_frost_arrows:GetIntrinsicModifierName() return 'modifier_enfos_pve_frost' end

function modifier_enfos_pve_frost:IsHidden() return true end
function modifier_enfos_pve_frost:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_pve_frost:OnAttackLanded(e)
    local c = self:GetParent()
    local a = self:GetAbility()
    if not IsServer() or e.attacker ~= c or c:PassivesDisabled() or c:IsIllusion() or e.target:GetTeamNumber() == c:GetTeamNumber() then return end
    local agi = c.GetAgility and c:GetAgility() or 0
    damage(a, e.target, value(a, 'bonus_damage') + (agi * value(a, 'agility_factor')), DAMAGE_TYPE_PHYSICAL)
    local status_res = e.target.GetStatusResistance and e.target:GetStatusResistance() or 0
    e.target:AddNewModifier(c, a, 'modifier_enfos_pve_slow', { duration = value(a, 'duration') * (1 - status_res) })
    effect('particles/units/heroes/hero_drow/drow_frost_arrow.vpcf', e.target)
    e.target:EmitSound('Hero_DrowRanger.FrostArrows')
end
function modifier_enfos_pve_frost:OnDeath(e)
    if not IsServer() or not e.unit or (e.unit.IsNull and e.unit:IsNull()) then return end
    if e.unit:HasModifier('modifier_enfos_pve_slow') then
        local c = self:GetParent()
        local a = self:GetAbility()
        local agi = c.GetAgility and c:GetAgility() or 0
        local shatter_dmg = 80 + (agi * 0.4)
        for _, u in ipairs(enemies(c, e.unit:GetAbsOrigin(), 325)) do
            if u ~= e.unit then
                damage(a, u, shatter_dmg, DAMAGE_TYPE_MAGICAL)
                u:AddNewModifier(c, a, 'modifier_enfos_pve_slow', { duration = 2.0 })
            end
        end
        effect('particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_explode.vpcf', e.unit)
    end
end

function modifier_enfos_pve_slow:IsDebuff() return true end
function modifier_enfos_pve_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_pve_slow:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'slow_pct') end

enfos_drow_gust=class({})
function enfos_drow_gust:OnSpellStart()
    local c = self:GetCaster()
    local origin = c:GetAbsOrigin()
    local target_pos = self:GetCursorPosition()
    local dir = (target_pos - origin):Normalized()
    dir.z = 0
    c:EmitSound('Hero_DrowRanger.Silence')

    ProjectileManager:CreateLinearProjectile({
        Ability = self,
        EffectName = 'particles/units/heroes/hero_drow/drow_silence_wave.vpcf',
        vSpawnOrigin = origin,
        fDistance = value(self, 'wave_distance'),
        fStartRadius = 250,
        fEndRadius = 250,
        Source = c,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        bDeleteOnHit = false,
        vVelocity = dir * value(self, 'wave_speed'),
        bProvidesVision = false
    })
end
function enfos_drow_gust:OnProjectileHit(t)
    if t and not (t.IsNull and t:IsNull()) and (t.IsAlive and t:IsAlive()) then
        local c = self:GetCaster()
        local dir = (t:GetAbsOrigin() - c:GetAbsOrigin()):Normalized()
        dir.z = 0
        if not is_boss(t) then
            t:SetAbsOrigin(t:GetAbsOrigin() + dir * 200)
            FindClearSpaceForUnit(t, t:GetAbsOrigin(), true)
        end
        local dur = value(self, 'silence_duration') * (is_boss(t) and 0.3 or 1.0)
        t:AddNewModifier(c, self, 'modifier_enfos_pve_gust_vulnerable', { duration = dur })
    end
    return false
end

modifier_enfos_pve_gust_vulnerable=class({})
function modifier_enfos_pve_gust_vulnerable:IsDebuff() return true end
function modifier_enfos_pve_gust_vulnerable:CheckState() return { [MODIFIER_STATE_SILENCED] = true } end
function modifier_enfos_pve_gust_vulnerable:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE } end
function modifier_enfos_pve_gust_vulnerable:GetModifierIncomingPhysicalDamage_Percentage() return 25 end

enfos_drow_multishot=class({})
function enfos_drow_multishot:GetChannelTime() return value(self, 'channel_time') end
function enfos_drow_multishot:OnSpellStart()
    self.elapsed = 0; self.sent = 0
    local c = self:GetCaster()
    self.direction = self:GetCursorPosition() - c:GetAbsOrigin()
    self.direction.z = 0
    if self.direction:Length2D() < 1 then self.direction = c:GetForwardVector() end
    self.direction = self.direction:Normalized()
    c:EmitSound('Hero_DrowRanger.Multishot.Channel')
end
function enfos_drow_multishot:OnChannelThink(dt)
    self.elapsed = self.elapsed + dt
    local count = value(self, 'arrow_count')
    local wanted = math.min(count, math.floor(self.elapsed / value(self, 'channel_time') * count) + 1)
    while self.sent < wanted do
        local c = self:GetCaster()
        local lane = self.sent % 6
        local angle = math.rad(-25 + lane * 10)
        local d = self.direction
        local velocity = Vector(d.x * math.cos(angle) - d.y * math.sin(angle), d.x * math.sin(angle) + d.y * math.cos(angle), 0) * 1200
        ProjectileManager:CreateLinearProjectile({
            Ability = self,
            EffectName = 'particles/units/heroes/hero_drow/drow_multishot_proj_linear_proj.vpcf',
            vSpawnOrigin = c:GetAbsOrigin(),
            fDistance = value(self, 'arrow_range'),
            fStartRadius = 75,
            fEndRadius = 75,
            Source = c,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            bDeleteOnHit = false,
            vVelocity = velocity,
            bProvidesVision = false
        })
        self.sent = self.sent + 1
    end
end
function enfos_drow_multishot:OnProjectileHit(t)
    if t then
        local c = self:GetCaster()
        damage(self, t, c:GetAverageTrueAttackDamage(t) * value(self, 'arrow_damage_pct') / 100, DAMAGE_TYPE_PHYSICAL)
        local frost = c:FindAbilityByName('enfos_drow_frost_arrows')
        if frost and frost:GetLevel() > 0 then
            t:AddNewModifier(c, frost, 'modifier_enfos_pve_slow', { duration = 2.0 })
        end
    end
    return false
end
function enfos_drow_multishot:OnChannelFinish() self:GetCaster():StopSound('Hero_DrowRanger.Multishot.Channel') end

enfos_drow_marksmanship=class({})
function enfos_drow_marksmanship:GetIntrinsicModifierName() return 'modifier_enfos_pve_marksmanship' end

function modifier_enfos_pve_marksmanship:IsHidden() return true end
function modifier_enfos_pve_marksmanship:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_pve_marksmanship:OnAttackLanded(e)
    local c = self:GetParent()
    if not IsServer() or e.attacker ~= c or c:PassivesDisabled() or c:IsIllusion() or e.target:GetTeamNumber() == c:GetTeamNumber() then return end
    if RollPercentage(value(self:GetAbility(), 'proc_chance')) then
        local agi = c.GetAgility and c:GetAgility() or 0
        local bonus_dmg = value(self:GetAbility(), 'bonus_damage') + (agi * 0.5)
        damage(self:GetAbility(), e.target, bonus_dmg, DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf', e.target)

        -- Arrow Splinters to up to 3 nearby creeps
        local targets = enemies(c, e.target:GetAbsOrigin(), 450)
        local count = 0
        for _, u in ipairs(targets) do
            if u ~= e.target and count < 3 then
                damage(self:GetAbility(), u, c:GetAverageTrueAttackDamage(u) * 0.6, DAMAGE_TYPE_PHYSICAL)
                effect('particles/units/heroes/hero_drow/drow_base_attack.vpcf', u)
                count = count + 1
            end
        end
    end
end

enfos_drow_precision_aura=class({})
function enfos_drow_precision_aura:GetIntrinsicModifierName() return 'modifier_enfos_pve_precision' end

function modifier_enfos_pve_precision:IsAura() return true end
function modifier_enfos_pve_precision:GetAuraRadius() return 1200 end
function modifier_enfos_pve_precision:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_pve_precision:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_pve_precision:GetModifierAura() return 'modifier_enfos_pve_precision_buff' end

modifier_enfos_pve_precision_buff=class({})
function modifier_enfos_pve_precision_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end
function modifier_enfos_pve_precision_buff:GetModifierBonusStats_Agility()
    local base_agi = self:GetParent().GetBaseAgility and self:GetParent():GetBaseAgility() or 0
    return base_agi * value(self:GetAbility(), 'bonus_agility_pct') / 100
end
function modifier_enfos_pve_precision_buff:GetModifierAttackRangeBonus() return value(self:GetAbility(), 'bonus_range') end

-- =========================================================================
-- LINA (MAGE)
-- =========================================================================

enfos_lina_dragon_slave=class({})
function enfos_lina_dragon_slave:OnSpellStart()
    local c = self:GetCaster()
    local origin = c:GetAbsOrigin()
    local target_pos = self:GetCursorPosition()
    local dir = (target_pos - origin):Normalized()
    dir.z = 0
    c:EmitSound('Hero_Lina.DragonSlave')

    ProjectileManager:CreateLinearProjectile({
        Ability = self,
        EffectName = 'particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf',
        vSpawnOrigin = origin,
        fDistance = value(self, 'dragon_slave_distance'),
        fStartRadius = value(self, 'dragon_slave_width_initial'),
        fEndRadius = value(self, 'dragon_slave_width_end'),
        Source = c,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        bDeleteOnHit = false,
        vVelocity = dir * 1200,
        bProvidesVision = false
    })
end
function enfos_lina_dragon_slave:OnProjectileHit(t)
    if t and not (t.IsNull and t:IsNull()) and (t.IsAlive and t:IsAlive()) then
        local c = self:GetCaster()
        local int = c.GetIntellect and c:GetIntellect() or 0
        local dmg = value(self, 'damage') + (int * 1.2)
        damage(self, t, dmg, DAMAGE_TYPE_MAGICAL)
        local comb = c:FindAbilityByName('enfos_lina_combustion')
        if comb and comb:GetLevel() > 0 then
            t:AddNewModifier(c, comb, 'modifier_enfos_pve_burn', { duration = 3.0 })
        end
    end
    return false
end

enfos_lina_light_strike_array=class({})
function enfos_lina_light_strike_array:OnSpellStart()
    local c = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = value(self, 'radius')
    local stun_dur = value(self, 'stun_duration')
    local int = c.GetIntellect and c:GetIntellect() or 0
    local dmg = value(self, 'damage') + (int * 1.0)

    c:EmitSound('Ability.LightStrikeArray')
    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf', PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, point)
    ParticleManager:SetParticleControl(p, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(p)

    for _, u in ipairs(enemies(c, point, radius)) do
        local dur = stun_dur * (is_boss(u) and 0.35 or 1.0)
        u:AddNewModifier(c, self, 'modifier_stunned', { duration = dur })
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_lina_fiery_soul=class({})
function enfos_lina_fiery_soul:GetIntrinsicModifierName() return 'modifier_enfos_pve_fiery' end

function modifier_enfos_pve_fiery:IsHidden() return true end
function modifier_enfos_pve_fiery:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_pve_fiery:OnAbilityFullyCast(e)
    if IsServer() and e.unit == self:GetParent() and not e.ability:IsItem() and not e.unit:PassivesDisabled() then
        e.unit:AddNewModifier(e.unit, self:GetAbility(), 'modifier_enfos_pve_fiery_stacks', { duration = value(self:GetAbility(), 'fiery_soul_stack_duration') })
    end
end
function modifier_enfos_pve_fiery:OnAttackLanded(e)
    if IsServer() and e.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and RollPercentage(25) then
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), 'modifier_enfos_pve_fiery_stacks', { duration = value(self:GetAbility(), 'fiery_soul_stack_duration') })
    end
end

function modifier_enfos_pve_fiery_stacks:OnCreated() if IsServer() then self:SetStackCount(1) end end
function modifier_enfos_pve_fiery_stacks:OnRefresh()
    if IsServer() then self:SetStackCount(math.min(self:GetStackCount() + 1, value(self:GetAbility(), 'fiery_soul_max_stacks'))) end
end
function modifier_enfos_pve_fiery_stacks:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_enfos_pve_fiery_stacks:GetModifierAttackSpeedBonus_Constant() return self:GetStackCount() * value(self:GetAbility(), 'fiery_soul_attack_speed_bonus') end
function modifier_enfos_pve_fiery_stacks:GetModifierMoveSpeedBonus_Percentage() return self:GetStackCount() * value(self:GetAbility(), 'fiery_soul_move_speed_bonus') end
function modifier_enfos_pve_fiery_stacks:GetModifierSpellAmplify_Percentage() return self:GetStackCount() * 5 end
function modifier_enfos_pve_fiery_stacks:GetEffectName() return 'particles/units/heroes/hero_lina/lina_fiery_soul.vpcf' end

enfos_lina_laguna_blade=class({})
function enfos_lina_laguna_blade:OnSpellStart()
    local t = self:GetCursorTarget()
    if t:TriggerSpellAbsorb(self) then return end
    local c = self:GetCaster()
    local pos = t:GetAbsOrigin()
    t:EmitSound('Ability.LagunaBladeImpact')
    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf', PATTACH_CUSTOMORIGIN, c)
    ParticleManager:SetParticleControlEnt(p, 0, c, PATTACH_POINT_FOLLOW, 'attach_attack1', c:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(p, 1, t, PATTACH_POINT_FOLLOW, 'attach_hitloc', pos, true)
    ParticleManager:ReleaseParticleIndex(p)

    local int = c.GetIntellect and c:GetIntellect() or 0
    local dmg = value(self, 'damage') + (int * 2.0)
    damage(self, t, dmg, DAMAGE_TYPE_MAGICAL)

    -- Overflow Blast
    local overflow = dmg * (value(self, 'overflow_damage_pct') / 100)
    for _, u in ipairs(enemies(c, pos, value(self, 'overflow_radius'))) do
        if u ~= t then damage(self, u, overflow, DAMAGE_TYPE_MAGICAL) end
    end
end

enfos_lina_combustion=class({})
function enfos_lina_combustion:GetIntrinsicModifierName() return 'modifier_enfos_pve_combustion' end

function modifier_enfos_pve_combustion:IsHidden() return true end
function modifier_enfos_pve_combustion:DeclareFunctions() return { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_pve_combustion:GetModifierSpellAmplify_Percentage() return value(self:GetAbility(), 'spell_amp') end
function modifier_enfos_pve_combustion:OnTakeDamage(e)
    local a = self:GetAbility()
    local c = self:GetParent()
    if IsServer() and e.attacker == c and e.inflictor and e.inflictor ~= a and not e.inflictor:IsItem()
        and not c:PassivesDisabled() and e.unit:IsAlive() and e.unit:GetTeamNumber() ~= c:GetTeamNumber() then
        e.unit:AddNewModifier(c, a, 'modifier_enfos_pve_burn', { duration = value(a, 'burn_duration') })
    end
end
function modifier_enfos_pve_combustion:OnDeath(e)
    if not IsServer() or not e.unit or (e.unit.IsNull and e.unit:IsNull()) then return end
    if e.unit:HasModifier('modifier_enfos_pve_burn') then
        local c = self:GetParent()
        local a = self:GetAbility()
        local max_hp = e.unit:GetMaxHealth() or 500
        local corpse_dmg = 120 + math.min(max_hp * 0.08, 600)
        for _, u in ipairs(enemies(c, e.unit:GetAbsOrigin(), 300)) do
            if u ~= e.unit then damage(a, u, corpse_dmg, DAMAGE_TYPE_MAGICAL) end
        end
        effect('particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf', e.unit)
    end
end

function modifier_enfos_pve_burn:IsDebuff() return true end
function modifier_enfos_pve_burn:OnCreated() if IsServer() then self:StartIntervalThink(0.5) end end
function modifier_enfos_pve_burn:OnIntervalThink()
    local c = self:GetCaster()
    local int = (c and not (c.IsNull and c:IsNull()) and c.GetIntellect) and c:GetIntellect() or 0
    local dps = value(self:GetAbility(), 'burn_dps') + (int * 0.3)
    damage(self:GetAbility(), self:GetParent(), dps * 0.5, DAMAGE_TYPE_MAGICAL)
end

-- =========================================================================
-- OMNIKNIGHT (SUPPORT)
-- =========================================================================

enfos_omni_purification=class({})
function enfos_omni_purification:OnSpellStart()
    local target = self:GetCursorTarget() or self:GetCaster()
    local c = self:GetCaster()
    local str = c.GetStrength and c:GetStrength() or 0
    local amount = value(self, 'heal_amount') + (str * 2.0)
    local radius = value(self, 'radius')

    target:EmitSound('Hero_Omniknight.Purification')
    if target.Heal then target:Heal(amount, self) end

    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_omniknight/omniknight_purification.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(p)

    for _, u in ipairs(enemies(c, target:GetAbsOrigin(), radius)) do
        damage(self, u, amount, DAMAGE_TYPE_PURE)
    end
end

enfos_omni_repel=class({})
function enfos_omni_repel:OnSpellStart()
    local target = self:GetCursorTarget() or self:GetCaster()
    local c = self:GetCaster()
    target:EmitSound('Hero_Omniknight.Repel')
    target:AddNewModifier(c, self, 'modifier_enfos_pve_repel', { duration = value(self, 'duration') })
end

modifier_enfos_pve_repel=class({})
function modifier_enfos_pve_repel:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_enfos_pve_repel:GetModifierConstantHealthRegen() return value(self:GetAbility(), 'bonus_hp_regen') end
function modifier_enfos_pve_repel:GetModifierBonusStats_Strength() return value(self:GetAbility(), 'bonus_strength') end
function modifier_enfos_pve_repel:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'bonus_armor') end
function modifier_enfos_pve_repel:CheckState() return { [MODIFIER_STATE_MAGIC_IMMUNE] = true } end
function modifier_enfos_pve_repel:GetEffectName() return 'particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf' end

enfos_omni_degen_aura=class({})
function enfos_omni_degen_aura:GetIntrinsicModifierName() return 'modifier_enfos_pve_degen_aura' end

modifier_enfos_pve_degen_aura=class({})
function modifier_enfos_pve_degen_aura:IsAura() return true end
function modifier_enfos_pve_degen_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_pve_degen_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_enfos_pve_degen_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_pve_degen_aura:GetModifierAura() return 'modifier_enfos_pve_degen_debuff' end

modifier_enfos_pve_degen_debuff=class({})
function modifier_enfos_pve_degen_debuff:IsDebuff() return true end
function modifier_enfos_pve_degen_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT } end
function modifier_enfos_pve_degen_debuff:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_pve_degen_debuff:GetModifierAttackSpeedBonus_Constant() return value(self:GetAbility(), 'attack_slow') end
function modifier_enfos_pve_degen_debuff:OnCreated() if IsServer() then self:StartIntervalThink(1.0) end end
function modifier_enfos_pve_degen_debuff:OnIntervalThink()
    local c = self:GetCaster()
    local str = (c and not (c.IsNull and c:IsNull()) and c.GetStrength) and c:GetStrength() or 0
    damage(self:GetAbility(), self:GetParent(), 40 + (str * 0.5), DAMAGE_TYPE_PURE)
end

enfos_omni_guardian_angel=class({})
function enfos_omni_guardian_angel:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Omniknight.GuardianAngel.Cast')
    local allies_list = FindUnitsInRadius(c:GetTeamNumber(), c:GetAbsOrigin(), nil, value(self, 'radius'), DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, u in ipairs(allies_list) do
        u:AddNewModifier(c, self, 'modifier_enfos_pve_angel', { duration = value(self, 'duration') })
    end
end

function modifier_enfos_pve_angel:DeclareFunctions() return { MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT } end
function modifier_enfos_pve_angel:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_enfos_pve_angel:GetModifierConstantHealthRegen() return value(self:GetAbility(), 'bonus_hp_regen') end
function modifier_enfos_pve_angel:GetEffectName() return 'particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf' end

enfos_omni_hammer_of_purity=class({})
function enfos_omni_hammer_of_purity:GetIntrinsicModifierName() return 'modifier_enfos_pve_hammer' end

modifier_enfos_pve_hammer=class({})
function modifier_enfos_pve_hammer:IsHidden() return true end
function modifier_enfos_pve_hammer:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_pve_hammer:OnAttackLanded(e)
    local c = self:GetParent()
    local a = self:GetAbility()
    if not IsServer() or e.attacker ~= c or c:PassivesDisabled() or e.target:GetTeamNumber() == c:GetTeamNumber() then return end
    local str = c.GetStrength and c:GetStrength() or 0
    local dmg = value(a, 'bonus_pure_damage') + (str * 1.2)
    damage(a, e.target, dmg, DAMAGE_TYPE_PURE)
    if c.Heal then c:Heal(dmg * 0.5, a) end
    for _, u in ipairs(enemies(c, e.target:GetAbsOrigin(), 275)) do
        if u ~= e.target then damage(a, u, dmg * 0.5, DAMAGE_TYPE_PURE) end
    end
    effect('particles/units/heroes/hero_omniknight/omniknight_hammer_of_purity.vpcf', e.target)
end

-- =========================================================================
-- LUNA (CARRY)
-- =========================================================================

enfos_luna_lucent_beam=class({})
function enfos_luna_lucent_beam:OnSpellStart()
    local target = self:GetCursorTarget()
    if not target or target:IsNull() or target:TriggerSpellAbsorb(self) then return end
    local c = self:GetCaster()
    c:EmitSound('Hero_Luna.LucentBeam.Cast')
    target:EmitSound('Hero_Luna.LucentBeam.Target')

    local agi = c.GetAgility and c:GetAgility() or 0
    local dmg = value(self, 'beam_damage') + (agi * 1.5)
    damage(self, target, dmg, DAMAGE_TYPE_MAGICAL)
    target:AddNewModifier(c, self, 'modifier_stunned', { duration = value(self, 'stun_duration') })
    effect('particles/units/heroes/hero_luna/luna_lucent_beam.vpcf', target)

    -- Lunar Resonance: Call secondary beams on up to 3 nearby creeps
    local count = 0
    for _, u in ipairs(enemies(c, target:GetAbsOrigin(), 450)) do
        if u ~= target and count < 3 then
            damage(self, u, dmg * 0.6, DAMAGE_TYPE_MAGICAL)
            effect('particles/units/heroes/hero_luna/luna_lucent_beam.vpcf', u)
            count = count + 1
        end
    end
end

enfos_luna_moon_glaives=class({})
function enfos_luna_moon_glaives:GetIntrinsicModifierName() return 'modifier_enfos_luna_moon_glaives_passive' end

modifier_enfos_luna_moon_glaives_passive=class({})
function modifier_enfos_luna_moon_glaives_passive:IsHidden() return true end
function modifier_enfos_luna_moon_glaives_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_luna_moon_glaives_passive:OnAttackLanded(e)
    local c = self:GetParent()
    local a = self:GetAbility()
    if not IsServer() or e.attacker ~= c or c:PassivesDisabled() or e.target:GetTeamNumber() == c:GetTeamNumber() then return end
    local bounces = 3 + a:GetLevel() * 2
    local cur_target = e.target
    local cur_dmg = c:GetAverageTrueAttackDamage(cur_target) * 0.85
    local visited = { [cur_target:entindex()] = true }

    for b = 1, bounces do
        local next_target = nil
        for _, u in ipairs(enemies(c, cur_target:GetAbsOrigin(), 500)) do
            if not visited[u:entindex()] and u:IsAlive() then
                next_target = u
                break
            end
        end
        if not next_target then break end
        visited[next_target:entindex()] = true
        damage(a, next_target, cur_dmg, DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_luna/luna_moon_glaive_bounce.vpcf', next_target)
        cur_dmg = cur_dmg * 0.85
        cur_target = next_target
    end
end

enfos_luna_lunar_blessing=class({})
function enfos_luna_lunar_blessing:GetIntrinsicModifierName() return 'modifier_enfos_luna_lunar_blessing' end

modifier_enfos_luna_lunar_blessing=class({})
function modifier_enfos_luna_lunar_blessing:IsAura() return true end
function modifier_enfos_luna_lunar_blessing:GetAuraRadius() return 1200 end
function modifier_enfos_luna_lunar_blessing:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_luna_lunar_blessing:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_luna_lunar_blessing:GetModifierAura() return 'modifier_enfos_luna_lunar_blessing_aura' end

modifier_enfos_luna_lunar_blessing_aura=class({})
function modifier_enfos_luna_lunar_blessing_aura:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_luna_lunar_blessing_aura:GetModifierPreAttack_BonusDamage() return value(self:GetAbility(), 'bonus_damage') end
function modifier_enfos_luna_lunar_blessing_aura:GetModifierMoveSpeedBonus_Percentage() return 12 end

enfos_luna_eclipse=class({})
function enfos_luna_eclipse:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Luna.Eclipse.Cast')
    c:AddNewModifier(c, self, 'modifier_enfos_luna_eclipse_thinker', { duration = value(self, 'duration') })
end

modifier_enfos_luna_eclipse_thinker=class({})
function modifier_enfos_luna_eclipse_thinker:OnCreated()
    if not IsServer() then return end
    self.hit_counts = {}
    self:StartIntervalThink(0.3)
end
function modifier_enfos_luna_eclipse_thinker:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local targets = enemies(c, c:GetAbsOrigin(), value(a, 'radius'))
    if #targets == 0 then return end
    local valid_targets = {}
    for _, u in ipairs(targets) do
        local hits = self.hit_counts[u:entindex()] or 0
        if hits < 6 then table.insert(valid_targets, u) end
    end
    if #valid_targets == 0 then return end
    local target = valid_targets[RandomInt(1, #valid_targets)]
    self.hit_counts[target:entindex()] = (self.hit_counts[target:entindex()] or 0) + 1

    local beam = c:FindAbilityByName('enfos_luna_lucent_beam')
    local agi = c.GetAgility and c:GetAgility() or 0
    local dmg = (beam and value(beam, 'beam_damage') or 200) + (agi * 1.5)
    damage(a, target, dmg, DAMAGE_TYPE_MAGICAL)
    target:EmitSound('Hero_Luna.LucentBeam.Target')
    effect('particles/units/heroes/hero_luna/luna_lucent_beam.vpcf', target)
end

enfos_luna_lunar_orbit=class({})
function enfos_luna_lunar_orbit:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Luna.Eclipse.NoTarget')
    c:AddNewModifier(c, self, 'modifier_enfos_luna_lunar_orbit_buff', { duration = 8.0 })
end

modifier_enfos_luna_lunar_orbit_buff=class({})
function modifier_enfos_luna_lunar_orbit_buff:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE } end
function modifier_enfos_luna_lunar_orbit_buff:GetModifierIncomingDamage_Percentage() return -25 end
function modifier_enfos_luna_lunar_orbit_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end
function modifier_enfos_luna_lunar_orbit_buff:OnIntervalThink()
    local c = self:GetParent()
    local agi = c.GetAgility and c:GetAgility() or 0
    local dmg = 50 + (agi * 0.4)
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 320)) do
        damage(self:GetAbility(), u, dmg, DAMAGE_TYPE_PHYSICAL)
    end
    effect('particles/units/heroes/hero_luna/luna_moon_glaive_bounce.vpcf', c)
end

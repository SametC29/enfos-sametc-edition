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

local function get_agi(c)
    if not c or (c.IsNull and c:IsNull()) then return 0 end
    if c.GetAgility then
        local ok, val = pcall(c.GetAgility, c)
        if ok and type(val) == "number" then return val end
    end
    return 0
end

local function get_str(c)
    if not c or (c.IsNull and c:IsNull()) then return 0 end
    if c.GetStrength then
        local ok, val = pcall(c.GetStrength, c)
        if ok and type(val) == "number" then return val end
    end
    return 0
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
    'modifier_enfos_luna_lunar_orbit_buff',
    -- Axe
    'modifier_enfos_axe_call_buff',
    'modifier_enfos_axe_call_taunt',
    'modifier_enfos_axe_battle_hunger_debuff',
    'modifier_enfos_axe_battle_hunger_speed',
    'modifier_enfos_axe_counter_helix_passive',
    'modifier_enfos_axe_culling_blade_buff',
    'modifier_enfos_axe_blood_armor_passive',
    -- Centaur
    'modifier_enfos_centaur_hoof_stomp_stun',
    'modifier_enfos_centaur_return_passive',
    'modifier_enfos_centaur_stampede_buff',
    'modifier_enfos_centaur_stampede_slow',
    'modifier_enfos_centaur_colossal_hide_passive',
    -- Legion Commander
    'modifier_enfos_legion_overwhelming_odds_buff',
    'modifier_enfos_legion_press_the_attack_buff',
    'modifier_enfos_legion_moment_of_courage_passive',
    'modifier_enfos_legion_duel_buff',
    'modifier_enfos_legion_commanders_banner_aura',
    'modifier_enfos_legion_commanders_banner_buff',
    -- Sniper
    'modifier_enfos_sniper_shrapnel_thinker',
    'modifier_enfos_sniper_shrapnel_slow',
    'modifier_enfos_sniper_headshot_passive',
    'modifier_enfos_sniper_take_aim_passive',
    'modifier_enfos_sniper_take_aim_buff',
    'modifier_enfos_sniper_keen_eye_passive',
    -- Crystal Maiden
    'modifier_enfos_cm_crystal_nova_slow',
    'modifier_enfos_cm_frostbite_debuff',
    'modifier_enfos_cm_arcane_aura',
    'modifier_enfos_cm_arcane_aura_buff',
    'modifier_enfos_cm_freezing_field_channel',
    'modifier_enfos_cm_freezing_field_slow',
    'modifier_enfos_cm_glacial_mastery_passive',
    'modifier_enfos_cm_frost_stack',
    'modifier_enfos_cm_frozen',
    -- Dazzle
    'modifier_enfos_dazzle_poison_touch_debuff',
    'modifier_enfos_dazzle_shallow_grave_buff',
    'modifier_enfos_dazzle_bad_juju_passive',
    'modifier_enfos_dazzle_bad_juju_buff',
    'modifier_enfos_dazzle_bad_juju_debuff',
    'modifier_enfos_dazzle_nothl_weave_aura',
    'modifier_enfos_dazzle_nothl_weave_buff',
    'modifier_enfos_dazzle_nothl_weave_debuff',
    -- Bristleback
    'modifier_enfos_bb_viscous_nasal_goo_debuff',
    'modifier_enfos_bb_quill_spray_debuff',
    'modifier_enfos_bb_bristleback_passive',
    'modifier_enfos_bb_warpath_passive',
    'modifier_enfos_bb_warpath_buff',
    -- Tidehunter
    'modifier_enfos_tide_gush_debuff',
    'modifier_enfos_tide_kraken_shell_passive',
    'modifier_enfos_tide_anchor_smash_debuff',
    'modifier_enfos_tide_ravage_stun',
    'modifier_enfos_tide_colossal_presence_aura',
    'modifier_enfos_tide_colossal_presence_debuff',
    -- Wraith King
    'modifier_enfos_wk_wraithfire_blast_stun',
    'modifier_enfos_wk_wraithfire_blast_dot',
    'modifier_enfos_wk_vampiric_aura',
    'modifier_enfos_wk_vampiric_aura_buff',
    'modifier_enfos_wk_mortal_strike_passive',
    'modifier_enfos_wk_reincarnation_passive',
    'modifier_enfos_wk_skeleton_army_passive',
    -- Phantom Assassin
    'modifier_enfos_pa_stifling_dagger_slow',
    'modifier_enfos_pa_phantom_strike_buff',
    'modifier_enfos_pa_blur_passive',
    'modifier_enfos_pa_blur_active',
    'modifier_enfos_pa_coup_de_grace_passive',
    -- Zeus
    'modifier_enfos_zeus_static_field_passive',
    'modifier_enfos_zeus_heavenly_jump_buff',
    'modifier_enfos_zeus_heavenly_jump_slow',
    -- Witch Doctor
    'modifier_enfos_wd_paralyzing_cask_stun',
    'modifier_enfos_wd_voodoo_restoration_aura',
    'modifier_enfos_wd_maledict_debuff',
    'modifier_enfos_wd_death_ward_channel',
    'modifier_enfos_wd_voodoo_switcheroo_buff',
    'modifier_enfos_dk_breathe_fire_debuff',
    'modifier_enfos_dk_dragon_tail_stun',
    'modifier_enfos_dk_dragon_blood_passive',
    'modifier_enfos_dk_elder_dragon_form_buff',
    'modifier_enfos_dk_dragon_frost_slow',
    'modifier_enfos_dk_wyrm_vigor_passive',
    'modifier_enfos_pudge_rot_aura',
    'modifier_enfos_pudge_rot_debuff',
    'modifier_enfos_pudge_flesh_heap_passive',
    'modifier_enfos_pudge_dismember_channel',
    'modifier_enfos_pudge_dismember_target',
    'modifier_enfos_pudge_meat_shield_passive',
    'modifier_enfos_slark_dark_pact_buff',
    'modifier_enfos_slark_pounce_leash',
    'modifier_enfos_slark_essence_shift_passive',
    'modifier_enfos_slark_essence_shift_buff',
    'modifier_enfos_slark_shadow_dance_buff',
    'modifier_enfos_slark_fish_bait_passive',
    'modifier_enfos_ursa_earthshock_slow',
    'modifier_enfos_ursa_overpower_buff',
    'modifier_enfos_ursa_fury_swipes_passive',
    'modifier_enfos_ursa_fury_swipes_debuff',
    'modifier_enfos_ursa_enrage_buff',
    'modifier_enfos_ursa_minor_passive',
    'modifier_enfos_mk_boundless_strike_stun',
    'modifier_enfos_mk_primal_spring_slow',
    'modifier_enfos_mk_jingu_mastery_passive',
    'modifier_enfos_mk_jingu_mastery_buff',
    'modifier_enfos_mk_wukongs_command_thinker',
    'modifier_enfos_mk_mischief_passive',
    'modifier_enfos_am_mana_break_passive',
    'modifier_enfos_am_counterspell_passive',
    'modifier_enfos_am_counterspell_active',
    'modifier_enfos_am_spellbreaker_passive',
    'modifier_enfos_void_time_dilation_debuff',
    'modifier_enfos_void_time_lock_passive',
    'modifier_enfos_void_time_lock_stun',
    'modifier_enfos_void_chronosphere_thinker',
    'modifier_enfos_void_chronosphere_freeze',
    'modifier_enfos_void_backtrack_passive',
    'modifier_enfos_sf_necromastery_passive',
    'modifier_enfos_sf_presence_aura',
    'modifier_enfos_sf_presence_debuff',
    'modifier_enfos_sf_requiem_fear',
    'modifier_enfos_sf_feast_of_souls_passive',
    'modifier_enfos_storm_static_remnant_thinker',
    'modifier_enfos_storm_electric_vortex_debuff',
    'modifier_enfos_storm_overload_passive',
    'modifier_enfos_storm_overload_slow',
    'modifier_enfos_storm_galvanic_core_passive',
    'modifier_enfos_ss_hex_debuff',
    'modifier_enfos_ss_shackles_channel',
    'modifier_enfos_ss_shackles_debuff',
    'modifier_enfos_ss_fowl_play_passive',
    'modifier_enfos_ss_fowl_play_buff',
    'modifier_enfos_lion_earth_spike_stun',
    'modifier_enfos_lion_hex_debuff',
    'modifier_enfos_lion_mana_drain_channel',
    'modifier_enfos_lion_mana_drain_debuff',
    'modifier_enfos_lion_finger_counter',
    'modifier_enfos_lion_demon_soul_passive',
    -- Underlord
    'modifier_enfos_underlord_firestorm_burn',
    'modifier_enfos_underlord_pit_root',
    'modifier_enfos_underlord_atrophy_aura',
    'modifier_enfos_underlord_atrophy_debuff',
    'modifier_enfos_underlord_carapace',
    -- Troll Warlord
    'modifier_enfos_troll_berserkers_rage',
    'modifier_enfos_troll_whirling_axes_blind',
    'modifier_enfos_troll_fervor',
    'modifier_enfos_troll_battle_trance',
    'modifier_enfos_troll_rampage',
    -- Chaos Knight
    'modifier_enfos_ck_reality_rift_debuff',
    'modifier_enfos_ck_chaos_strike',
    'modifier_enfos_ck_phantasm_buff',
    'modifier_enfos_ck_entropy',
    -- Medusa
    'modifier_enfos_medusa_split_shot',
    'modifier_enfos_medusa_mana_shield',
    'modifier_enfos_medusa_petrified',
    'modifier_enfos_medusa_gorgon_gaze',
    -- Terrorblade
    'modifier_enfos_tb_reflection',
    'modifier_enfos_tb_conjure_image_buff',
    'modifier_enfos_tb_metamorphosis',
    'modifier_enfos_tb_demon_zeal',
    -- Leshrac
    'modifier_enfos_leshrac_diabolic_edict',
    'modifier_enfos_leshrac_pulse_nova',
    'modifier_enfos_leshrac_defilement',
    -- Invoker
    'modifier_enfos_invoker_meteor_burn',
    'modifier_enfos_invoker_disarm',
    'modifier_enfos_invoker_alacrity',
    -- Puck
    'modifier_enfos_puck_silence',
    'modifier_enfos_puck_phase_shift',
    'modifier_enfos_puck_faerie_magic',
    -- Jakiro
    'modifier_enfos_jakiro_dual_breath_slow',
    'modifier_enfos_jakiro_liquid_fire_passive',
    'modifier_enfos_jakiro_double_trouble',
    -- Vengeful Spirit
    'modifier_enfos_vs_wave_debuff',
    'modifier_enfos_vs_vengeance_aura',
    'modifier_enfos_vs_vengeance_aura_buff',
    'modifier_enfos_vs_nether_swap_buff',
    'modifier_enfos_vs_retribution',
    -- Lich
    'modifier_enfos_lich_frost_blast_slow',
    'modifier_enfos_lich_frost_shield',
    'modifier_enfos_lich_sinister_gaze_debuff',
    'modifier_enfos_lich_ice_aura',
}
_G.ENFOS_PVE_MODIFIER_LIST = modifier_list

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
    local str = get_str(c)
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
    local p = self:GetParent()
    if p and p.SetForceAttackTarget then p:SetForceAttackTarget(self:GetCaster()) end
    self:StartIntervalThink(0.2)
end
function modifier_enfos_pve_taunt:OnIntervalThink()
    local c = self:GetCaster()
    if not c or c:IsNull() or not c:IsAlive() then self:Destroy() end
end
function modifier_enfos_pve_taunt:OnDestroy()
    if IsServer() then
        local p = self:GetParent()
        if p and p.SetForceAttackTarget then p:SetForceAttackTarget(nil) end
    end
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
    local str = get_str(c)
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
    local agi = get_agi(c)
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
    local p = self:GetParent()
    self.home = p and p:GetAbsOrigin() or nil
    self.target = (kv and kv.target and EntIndexToHScript(kv.target)) or nil
    self:OnIntervalThink()
    self:StartIntervalThink(value(self:GetAbility(), 'slash_interval'))
end
function modifier_enfos_pve_slashes:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    if not c or not c:IsAlive() then self:Destroy(); return end
    local home = self.home or c:GetAbsOrigin()
    local t = self.target
    if not t or t:IsNull() or not t:IsAlive() then t = enemies(c, c:GetAbsOrigin(), value(a, 'radius'))[1] end
    if not t or (t:GetAbsOrigin() - home):Length2D() > 1400 then self:Destroy(); return end
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
    local agi = get_agi(c)
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
    local agi = get_agi(c)
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
    local agi = get_agi(c)
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
    local int = get_int(c)
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
    local int = get_int(c)
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
    local int = get_int(c)
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
    local int = get_int(c)
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
    local str = get_str(c)
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
    local str = get_str(c)
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
    local str = get_str(c)
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
    local agi = get_agi(c)
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
        if ProjectileManager and ProjectileManager.CreateTrackingProjectile then
            ProjectileManager:CreateTrackingProjectile({
                Target = next_target,
                Source = cur_target,
                Ability = a,
                EffectName = "particles/units/heroes/hero_luna/luna_base_attack.vpcf",
                iMoveSpeed = 900,
                bDodgeable = false,
                bVisibleToEnemies = true,
                bProvidesVision = false
            })
        end
        damage(a, next_target, cur_dmg, DAMAGE_TYPE_PHYSICAL)
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
    local agi = get_agi(c)
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
    local c = self:GetParent()
    if ParticleManager then
        self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_luna/luna_ambient_lunar_blessing.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    end
    if self.StartIntervalThink then self:StartIntervalThink(0.5) end
end
function modifier_enfos_luna_lunar_orbit_buff:OnDestroy()
    if not IsServer() then return end
    if self.pfx and ParticleManager then
        if ParticleManager.DestroyParticle then ParticleManager:DestroyParticle(self.pfx, false) end
        if ParticleManager.ReleaseParticleIndex then ParticleManager:ReleaseParticleIndex(self.pfx) end
        self.pfx = nil
    end
end
function modifier_enfos_luna_lunar_orbit_buff:OnIntervalThink()
    local c = self:GetParent()
    local agi = get_agi(c)
    local dmg = 50 + (agi * 0.4)
    local hit_any = false
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 320)) do
        damage(self:GetAbility(), u, dmg, DAMAGE_TYPE_PHYSICAL)
        if ParticleManager then
            local hit_pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_luna/luna_base_attack_impact.vpcf', PATTACH_ABSORIGIN_FOLLOW, u)
            ParticleManager:ReleaseParticleIndex(hit_pfx)
        end
        hit_any = true
    end
    if hit_any then
        c:EmitSound('Hero_Luna.MoonGlaive.Impact')
    end
end


-- ============================================================================
-- BATCH 2 PVE HERO KITS: AXE, CENTAUR, LEGION COMMANDER, SNIPER, CRYSTAL MAIDEN, DAZZLE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- AXE: BERSERKER'S CALL, BATTLE HUNGER, COUNTER HELIX, CULLING BLADE, BLOOD ARMOR
-- ----------------------------------------------------------------------------

enfos_axe_berserkers_call=class({})
function enfos_axe_berserkers_call:OnSpellStart()
    local c = self:GetCaster()
    local r = value(self, 'radius')
    if r <= 0 then r = 400 end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 3.0 end
    local armor = value(self, 'bonus_armor')
    if armor <= 0 then armor = 30 end

    c:EmitSound('Hero_Axe.BerserkersCall')
    effect('particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf', c)

    c:AddNewModifier(c, self, 'modifier_enfos_axe_call_buff', { duration = dur, bonus_armor = armor })

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        local target_dur = dur
        if is_boss(u) then
            target_dur = dur * 0.25
        end
        u:AddNewModifier(c, self, 'modifier_enfos_axe_call_taunt', { duration = target_dur })
    end
end

modifier_enfos_axe_call_buff=class({})
function modifier_enfos_axe_call_buff:IsPurgable() return false end
function modifier_enfos_axe_call_buff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_axe_call_buff:OnCreated(kv)
    self.bonus_armor = (kv and kv.bonus_armor) or (self.GetAbility and value(self:GetAbility(), 'bonus_armor')) or 30
end
function modifier_enfos_axe_call_buff:GetModifierPhysicalArmorBonus() return self.bonus_armor end

modifier_enfos_axe_call_taunt=class({})
function modifier_enfos_axe_call_taunt:IsDebuff() return true end
function modifier_enfos_axe_call_taunt:IsPurgable() return true end
function modifier_enfos_axe_call_taunt:CheckState()
    return {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_TAUNTED] = true
    }
end

enfos_axe_battle_hunger=class({})
function enfos_axe_battle_hunger:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 10.0 end
    c:EmitSound('Hero_Axe.Battle_Hunger')
    t:AddNewModifier(c, self, 'modifier_enfos_axe_battle_hunger_debuff', { duration = dur })
    c:AddNewModifier(c, self, 'modifier_enfos_axe_battle_hunger_speed', { duration = dur })
end

modifier_enfos_axe_battle_hunger_debuff=class({})
function modifier_enfos_axe_battle_hunger_debuff:IsDebuff() return true end
function modifier_enfos_axe_battle_hunger_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_axe_battle_hunger_debuff:GetModifierMoveSpeedBonus_Percentage() return -25 end
function modifier_enfos_axe_battle_hunger_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_axe_battle_hunger_debuff:OnIntervalThink()
    local p = self:GetParent()
    local a = self:GetAbility()
    local c = (a and a.GetCaster) and a:GetCaster() or nil
    local base = (a and value(a, 'damage_per_second')) or 50
    local str = get_str(c)
    local dmg = base + (str * 0.25)
    damage(a, p, dmg, DAMAGE_TYPE_PHYSICAL)
    effect('particles/units/heroes/hero_axe/axe_battle_hunger.vpcf', p)
end
function modifier_enfos_axe_battle_hunger_debuff:OnDeath(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        local p = self:GetParent()
        local a = self:GetAbility()
        local c = self:GetCaster()
        if c and not (c.IsNull and c:IsNull()) and a and not (a.IsNull and a:IsNull()) then
            local count = 0
            for _, u in ipairs(enemies(c, p:GetAbsOrigin(), 400)) do
                if u ~= p and not u:HasModifier('modifier_enfos_axe_battle_hunger_debuff') then
                    u:AddNewModifier(c, a, 'modifier_enfos_axe_battle_hunger_debuff', { duration = 8.0 })
                    count = count + 1
                    if count >= 2 then break end
                end
            end
        end
    end
end

modifier_enfos_axe_battle_hunger_speed=class({})
function modifier_enfos_axe_battle_hunger_speed:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_axe_battle_hunger_speed:GetModifierMoveSpeedBonus_Percentage() return 15 end

enfos_axe_counter_helix=class({})
function enfos_axe_counter_helix:GetIntrinsicModifierName() return 'modifier_enfos_axe_counter_helix_passive' end

modifier_enfos_axe_counter_helix_passive=class({})
function modifier_enfos_axe_counter_helix_passive:IsHidden() return true end
function modifier_enfos_axe_counter_helix_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACKED } end
function modifier_enfos_axe_counter_helix_passive:OnCreated()
    self.last_boss_proc = 0
end
function modifier_enfos_axe_counter_helix_passive:OnAttacked(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.target ~= c then return end
    local a = self:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or not c:IsAlive() then return end

    local chance = value(a, 'trigger_chance')
    if chance <= 0 then chance = 20 end
    if not RollPercentage(chance) then return end

    local attacker = params.attacker
    if attacker and is_boss(attacker) then
        local now = (GameRules and GameRules.GetGameTime) and GameRules:GetGameTime() or 0
        if (now - self.last_boss_proc) < 0.2 then return end
        self.last_boss_proc = now
    end

    c:EmitSound('Hero_Axe.CounterHelix')
    effect('particles/units/heroes/hero_axe/axe_counterhelix.vpcf', c)

    local base_dmg = value(a, 'helix_damage')
    if base_dmg <= 0 then base_dmg = 150 end
    local str = get_str(c)
    local dmg = base_dmg + (str * 1.0)
    local r = value(a, 'radius')
    if r <= 0 then r = 300 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        damage(a, u, dmg, DAMAGE_TYPE_PURE)
    end
end

enfos_axe_culling_blade=class({})
function enfos_axe_culling_blade:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    local creep_pct = value(self, 'kill_threshold_pct')
    if creep_pct <= 0 then creep_pct = 35 end
    local boss_pct = 15
    local threshold = is_boss(t) and boss_pct or creep_pct

    local current_pct = (t:GetHealth() / math.max(1, t:GetMaxHealth())) * 100
    if current_pct <= threshold then
        t:EmitSound('Hero_Axe.Culling_Blade_Success')
        effect('particles/units/heroes/hero_axe/axe_culling_blade.vpcf', t)
        if t.Kill then
            t:Kill(self, c)
        else
            damage(self, t, t:GetMaxHealth() * 10, DAMAGE_TYPE_PURE)
        end
        self:EndCooldown()
        for _, u in ipairs(allies(c, c:GetAbsOrigin(), 900)) do
            u:AddNewModifier(c, self, 'modifier_enfos_axe_culling_blade_buff', { duration = 6.0 })
        end
    else
        t:EmitSound('Hero_Axe.Culling_Blade_Fail')
        local base_dmg = value(self, 'damage')
        if base_dmg <= 0 then base_dmg = 350 end
    local str = get_str(c)
        local dmg = base_dmg + (str * 2.5)
        damage(self, t, dmg, DAMAGE_TYPE_PURE)
    end
end

modifier_enfos_axe_culling_blade_buff=class({})
function modifier_enfos_axe_culling_blade_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_axe_culling_blade_buff:GetModifierMoveSpeedBonus_Percentage() return 40 end
function modifier_enfos_axe_culling_blade_buff:GetModifierAttackSpeedBonus_Constant() return 60 end

enfos_axe_blood_armor=class({})
function enfos_axe_blood_armor:GetIntrinsicModifierName() return 'modifier_enfos_axe_blood_armor_passive' end

modifier_enfos_axe_blood_armor_passive=class({})
function modifier_enfos_axe_blood_armor_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end
function modifier_enfos_axe_blood_armor_passive:OnCreated()
    self.creep_kills = 0
    self.stacks = 0
end
function modifier_enfos_axe_blood_armor_passive:GetModifierPhysicalArmorBonus()
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_armor')) or 8
    return base + (self.stacks or 0)
end
function modifier_enfos_axe_blood_armor_passive:GetModifierConstantHealthRegen()
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_health_regen')) or 20
    return base + (self.stacks or 0)
end
function modifier_enfos_axe_blood_armor_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local dead = params.unit
    if not dead then return end
    if is_boss(dead) then
        self.stacks = math.min(50, (self.stacks or 0) + 1)
        self:SetStackCount(self.stacks)
    else
        self.creep_kills = (self.creep_kills or 0) + 1
        if self.creep_kills >= 10 then
            self.creep_kills = 0
            self.stacks = math.min(50, (self.stacks or 0) + 1)
            self:SetStackCount(self.stacks)
        end
    end
end
function modifier_enfos_axe_blood_armor_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c then return end
    local attacker = params.attacker
    if not attacker or attacker == c or (attacker.IsNull and attacker:IsNull()) or not attacker:IsAlive() then return end
    if bit and bit.band and bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0 then return end
    if params.damage_type == DAMAGE_TYPE_PHYSICAL and params.original_damage and params.original_damage > 0 then
        local refl = params.original_damage * 0.15
        ApplyDamage({
            victim = attacker,
            attacker = c,
            ability = self:GetAbility(),
            damage = refl,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION or 16
        })
    end
end

-- ----------------------------------------------------------------------------
-- CENTAUR: HOOF STOMP, DOUBLE EDGE, RETURN, STAMPEDE, COLOSSAL HIDE
-- ----------------------------------------------------------------------------

enfos_centaur_hoof_stomp=class({})
function enfos_centaur_hoof_stomp:OnSpellStart()
    local c = self:GetCaster()
    local r = value(self, 'radius')
    if r <= 0 then r = 350 end
    local dur = value(self, 'stun_duration')
    if dur <= 0 then dur = 2.0 end
    local base_dmg = value(self, 'damage')
    if base_dmg <= 0 then base_dmg = 200 end
    local str = get_str(c)
    local dmg = base_dmg + (str * 1.5)

    c:EmitSound('Hero_Centaur.HoofStomp')
    effect('particles/units/heroes/hero_centaur/centaur_warstomp.vpcf', c)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        local target_dur = dur
        if is_boss(u) then target_dur = 0.8 end
        u:AddNewModifier(c, self, 'modifier_enfos_centaur_hoof_stomp_stun', { duration = target_dur })
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
    end
end

modifier_enfos_centaur_hoof_stomp_stun=class({})
function modifier_enfos_centaur_hoof_stomp_stun:IsDebuff() return true end
function modifier_enfos_centaur_hoof_stomp_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_centaur_double_edge=class({})
function enfos_centaur_double_edge:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    local base_dmg = value(self, 'edge_damage')
    if base_dmg <= 0 then base_dmg = 250 end
    local str = get_str(c)
    local hp = c.GetMaxHealth and c:GetMaxHealth() or 1000
    local dmg = base_dmg + (str * 0.6) + (hp * 0.15)

    c:EmitSound('Hero_Centaur.DoubleEdge')
    effect('particles/units/heroes/hero_centaur/centaur_double_edge.vpcf', t)

    local self_dmg = dmg * 0.3
    if c:GetHealth() > self_dmg then
        c:SetHealth(c:GetHealth() - self_dmg)
    else
        c:SetHealth(1)
    end

    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 250)) do
        damage(self, u, dmg, DAMAGE_TYPE_PURE)
    end
end

enfos_centaur_return=class({})
function enfos_centaur_return:GetIntrinsicModifierName() return 'modifier_enfos_centaur_return_passive' end

modifier_enfos_centaur_return_passive=class({})
function modifier_enfos_centaur_return_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_TAKEDAMAGE } end
function modifier_enfos_centaur_return_passive:OnCreated()
    self.accumulated_damage = 0
end
function modifier_enfos_centaur_return_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c then return end
    local attacker = params.attacker
    if not attacker or attacker == c or (attacker.IsNull and attacker:IsNull()) or not attacker:IsAlive() then return end
    if bit and bit.band and bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0 then return end

    local a = self:GetAbility()
    local flat = (a and value(a, 'return_damage')) or 40
    local str = get_str(c)
    local refl = flat + (str * 0.5)

    ApplyDamage({
        victim = attacker,
        attacker = c,
        ability = a,
        damage = refl,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION or 16
    })

    self.accumulated_damage = (self.accumulated_damage or 0) + (params.damage or 0)
    if self.accumulated_damage >= 300 then
        self.accumulated_damage = 0
        effect('particles/units/heroes/hero_centaur/centaur_return.vpcf', c)
        for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 250)) do
            damage(a, u, refl, DAMAGE_TYPE_PHYSICAL)
        end
    end
end

enfos_centaur_stampede=class({})
function enfos_centaur_stampede:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Centaur.Stampede.Cast')
    for _, ally in ipairs(allies(c, c:GetAbsOrigin(), 99999)) do
        if ally:IsHero() then
            ally:AddNewModifier(c, self, 'modifier_enfos_centaur_stampede_buff', { duration = 5.0 })
        end
    end
end

modifier_enfos_centaur_stampede_buff=class({})
function modifier_enfos_centaur_stampede_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end
function modifier_enfos_centaur_stampede_buff:GetModifierMoveSpeed_Absolute() return 550 end
function modifier_enfos_centaur_stampede_buff:GetModifierIncomingDamage_Percentage() return -40 end
function modifier_enfos_centaur_stampede_buff:CheckState() return { [MODIFIER_STATE_NO_UNIT_COLLISION] = true } end
function modifier_enfos_centaur_stampede_buff:OnCreated()
    if not IsServer() then return end
    self.trampled = {}
    self:StartIntervalThink(0.2)
end
function modifier_enfos_centaur_stampede_buff:OnIntervalThink()
    local c = self:GetCaster()
    local p = self:GetParent()
    local a = self:GetAbility()
    local str = get_str(c)
    local dmg = 200 + (str * 2.0)

    for _, u in ipairs(enemies(c, p:GetAbsOrigin(), 150)) do
        local id = u:entindex()
        if not self.trampled[id] then
            self.trampled[id] = true
            damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL)
            u:AddNewModifier(c, a, 'modifier_enfos_centaur_stampede_slow', { duration = 1.5 })
        end
    end
end

modifier_enfos_centaur_stampede_slow=class({})
function modifier_enfos_centaur_stampede_slow:IsDebuff() return true end
function modifier_enfos_centaur_stampede_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_centaur_stampede_slow:GetModifierMoveSpeedBonus_Percentage() return -100 end

enfos_centaur_colossal_hide=class({})
function enfos_centaur_colossal_hide:GetIntrinsicModifierName() return 'modifier_enfos_centaur_colossal_hide_passive' end

modifier_enfos_centaur_colossal_hide_passive=class({})
function modifier_enfos_centaur_colossal_hide_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE }
end
function modifier_enfos_centaur_colossal_hide_passive:GetModifierPhysical_ConstantBlock()
    local c = self:GetParent()
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'damage_block')) or 40
    return base + (str * 0.05)
end
function modifier_enfos_centaur_colossal_hide_passive:GetModifierExtraHealthPercentage() return 20 end

-- ----------------------------------------------------------------------------
-- LEGION COMMANDER: OVERWHELMING ODDS, PRESS THE ATTACK, MOMENT OF COURAGE, DUEL, COMMANDER'S BANNER
-- ----------------------------------------------------------------------------

enfos_legion_overwhelming_odds=class({})
function enfos_legion_overwhelming_odds:OnSpellStart()
    local c = self:GetCaster()
    local point = self:GetCursorPosition()
    local r = value(self, 'radius')
    if r <= 0 then r = 600 end
    local base_dmg = value(self, 'damage')
    if base_dmg <= 0 then base_dmg = 180 end
    local creep_bonus = value(self, 'damage_per_unit')
    if creep_bonus <= 0 then creep_bonus = 35 end

    c:EmitSound('Hero_LegionCommander.OverwhelmingOdds')
    effect('particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf', c)

    local hit_units = enemies(c, point, r)
    local creep_count = 0
    local boss_count = 0
    for _, u in ipairs(hit_units) do
        if is_boss(u) or u:IsHero() then boss_count = boss_count + 1 else creep_count = creep_count + 1 end
    end

    local total_dmg = base_dmg + (creep_count * creep_bonus) + (boss_count * 100)
    for _, u in ipairs(hit_units) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end

    local total_as = (creep_count * 5) + (boss_count * 30)
    local total_ms = math.min(60, (creep_count * 2) + (boss_count * 10))
    c:AddNewModifier(c, self, 'modifier_enfos_legion_overwhelming_odds_buff', {
        duration = 6.0,
        bonus_as = total_as,
        bonus_ms = total_ms
    })
end

modifier_enfos_legion_overwhelming_odds_buff=class({})
function modifier_enfos_legion_overwhelming_odds_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_legion_overwhelming_odds_buff:OnCreated(kv)
    self.bonus_as = (kv and kv.bonus_as) or 20
    self.bonus_ms = (kv and kv.bonus_ms) or 10
end
function modifier_enfos_legion_overwhelming_odds_buff:GetModifierAttackSpeedBonus_Constant() return self.bonus_as end
function modifier_enfos_legion_overwhelming_odds_buff:GetModifierMoveSpeedBonus_Percentage() return self.bonus_ms end

enfos_legion_press_the_attack=class({})
function enfos_legion_press_the_attack:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget() or c
    if t.Purge then t:Purge(false, true, false, true, true) end
    t:EmitSound('Hero_LegionCommander.PressTheAttack')
    effect('particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf', t)
    t:AddNewModifier(c, self, 'modifier_enfos_legion_press_the_attack_buff', { duration = 5.0 })
end

modifier_enfos_legion_press_the_attack_buff=class({})
function modifier_enfos_legion_press_the_attack_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_legion_press_the_attack_buff:GetModifierConstantHealthRegen()
    local c = self:GetCaster()
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'hp_regen')) or 60
    return base + (str * 0.5)
end
function modifier_enfos_legion_press_the_attack_buff:GetModifierAttackSpeedBonus_Constant()
    return (self.GetAbility and value(self:GetAbility(), 'bonus_attack_speed')) or 80
end

enfos_legion_moment_of_courage=class({})
function enfos_legion_moment_of_courage:GetIntrinsicModifierName() return 'modifier_enfos_legion_moment_of_courage_passive' end

modifier_enfos_legion_moment_of_courage_passive=class({})
function modifier_enfos_legion_moment_of_courage_passive:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACKED, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_legion_moment_of_courage_passive:OnCreated()
    self.last_boss_proc = 0
    self.proc_active = false
end
function modifier_enfos_legion_moment_of_courage_passive:OnAttacked(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.target ~= c then return end
    local a = self:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or not c:IsAlive() then return end

    local chance = value(a, 'trigger_chance')
    if chance <= 0 then chance = 25 end
    if not RollPercentage(chance) then return end

    local attacker = params.attacker
    if attacker and is_boss(attacker) then
        local now = (GameRules and GameRules.GetGameTime) and GameRules:GetGameTime() or 0
        if (now - self.last_boss_proc) < 0.4 then return end
        self.last_boss_proc = now
    end

    c:EmitSound('Hero_LegionCommander.MomentOfCourage')
    effect('particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf', c)

    if attacker and not attacker:IsNull() and attacker:IsAlive() then
        self.proc_active = true
        if c.PerformAttack then
            c:PerformAttack(attacker, true, true, true, false, false, false, true)
        end
        self.proc_active = false
    end
end
function modifier_enfos_legion_moment_of_courage_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and self.proc_active and params.damage and params.damage > 0 then
        local heal = params.damage * 0.75
        c:Heal(heal, self:GetAbility())
    end
end

enfos_legion_duel=class({})
function enfos_legion_duel:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 4.5 end

    c:EmitSound('Hero_LegionCommander.Duel.Cast')
    c:AddNewModifier(c, self, 'modifier_enfos_legion_duel_buff', { duration = dur, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_legion_duel_buff', { duration = dur, target_idx = c:entindex() })
end

modifier_enfos_legion_duel_buff=class({})
function modifier_enfos_legion_duel_buff:CheckState()
    return { [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_TAUNTED] = true }
end
function modifier_enfos_legion_duel_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_DEATH }
end
function modifier_enfos_legion_duel_buff:OnCreated(kv)
    self.target_idx = kv and kv.target_idx
end
function modifier_enfos_legion_duel_buff:GetModifierIncomingDamage_Percentage(params)
    if params.attacker and params.attacker:entindex() ~= self.target_idx then
        return -40
    end
    return 0
end
function modifier_enfos_legion_duel_buff:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetCaster()
    if params.unit and params.unit:entindex() == self.target_idx and params.unit ~= c then
        local bonus = is_boss(params.unit) and 30 or 10
        c:EmitSound('Hero_LegionCommander.Duel.Victory')
        effect('particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf', c)
        if c.ModifyStrength then c:ModifyStrength(bonus) end
    end
end

enfos_legion_commanders_banner=class({})
function enfos_legion_commanders_banner:GetIntrinsicModifierName() return 'modifier_enfos_legion_commanders_banner_aura' end

modifier_enfos_legion_commanders_banner_aura=class({})
function modifier_enfos_legion_commanders_banner_aura:IsHidden() return true end
function modifier_enfos_legion_commanders_banner_aura:IsAura() return true end
function modifier_enfos_legion_commanders_banner_aura:GetAuraRadius() return 900 end
function modifier_enfos_legion_commanders_banner_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_legion_commanders_banner_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_legion_commanders_banner_aura:GetModifierAura() return 'modifier_enfos_legion_commanders_banner_buff' end

modifier_enfos_legion_commanders_banner_buff=class({})
function modifier_enfos_legion_commanders_banner_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_legion_commanders_banner_buff:GetModifierBaseDamageOutgoing_Percentage()
    local is_owner = self:GetParent() == self:GetCaster()
    return is_owner and 40 or 20
end
function modifier_enfos_legion_commanders_banner_buff:OnTakeDamage(params)
    if not IsServer() then return end
    local p = self:GetParent()
    if params.attacker == p and params.damage and params.damage > 0 then
        local pct = (p == self:GetCaster()) and 0.24 or 0.12
        p:Heal(params.damage * pct, self:GetAbility())
    end
end

-- ----------------------------------------------------------------------------
-- SNIPER: SHRAPNEL, HEADSHOT, TAKE AIM, ASSASSINATE, KEEN EYE
-- ----------------------------------------------------------------------------

enfos_sniper_shrapnel=class({})
function enfos_sniper_shrapnel:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    local r = value(self, 'radius')
    if r <= 0 then r = 450 end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 8.0 end

    c:EmitSound('Hero_Sniper.ShrapnelShoot')
    CreateModifierThinker(c, self, 'modifier_enfos_sniper_shrapnel_thinker', { duration = dur, radius = r }, pos, c:GetTeamNumber(), false)
end

modifier_enfos_sniper_shrapnel_thinker=class({})
function modifier_enfos_sniper_shrapnel_thinker:OnCreated(kv)
    if not IsServer() then return end
    self.radius = (kv and kv.radius) or 450
    self:StartIntervalThink(1.0)
    effect('particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf', self:GetParent())
end
function modifier_enfos_sniper_shrapnel_thinker:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local p = self:GetParent()
    local agi = get_agi(c)
    local base = (a and value(a, 'shrapnel_damage')) or 75
    local dmg = base + (agi * 0.35)

    for _, u in ipairs(enemies(c, p:GetAbsOrigin(), self.radius)) do
        damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, a, 'modifier_enfos_sniper_shrapnel_slow', { duration = 1.0 })
    end
end

modifier_enfos_sniper_shrapnel_slow=class({})
function modifier_enfos_sniper_shrapnel_slow:IsDebuff() return true end
function modifier_enfos_sniper_shrapnel_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_sniper_shrapnel_slow:GetModifierMoveSpeedBonus_Percentage() return -30 end

enfos_sniper_headshot=class({})
function enfos_sniper_headshot:GetIntrinsicModifierName() return 'modifier_enfos_sniper_headshot_passive' end

modifier_enfos_sniper_headshot_passive=class({})
function modifier_enfos_sniper_headshot_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_sniper_headshot_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    local chance = 40
    if c:HasModifier('modifier_enfos_sniper_take_aim_buff') then chance = 80 end
    if not RollPercentage(chance) then return end

    c:EmitSound('Hero_Sniper.Headshot')
    local a = self:GetAbility()
    local base = (a and value(a, 'headshot_damage')) or 120
    local agi = get_agi(c)
    local dmg = base + (agi * 0.75)
    damage(a, t, dmg, DAMAGE_TYPE_PHYSICAL)

    if not is_boss(t) and t.SetAbsOrigin then
        local fv = (t:GetAbsOrigin() - c:GetAbsOrigin()):Normalized()
        t:SetAbsOrigin(t:GetAbsOrigin() + fv * 60)
    end
end

enfos_sniper_take_aim=class({})
function enfos_sniper_take_aim:GetIntrinsicModifierName() return 'modifier_enfos_sniper_take_aim_passive' end
function enfos_sniper_take_aim:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Sniper.TakeAim.Cast')
    c:AddNewModifier(c, self, 'modifier_enfos_sniper_take_aim_buff', { duration = 5.0 })
end

modifier_enfos_sniper_take_aim_passive=class({})
function modifier_enfos_sniper_take_aim_passive:IsHidden() return true end
function modifier_enfos_sniper_take_aim_passive:DeclareFunctions() return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS } end
function modifier_enfos_sniper_take_aim_passive:GetModifierAttackRangeBonus()
    return (self.GetAbility and value(self:GetAbility(), 'bonus_range')) or 300
end

modifier_enfos_sniper_take_aim_buff=class({})
function modifier_enfos_sniper_take_aim_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_sniper_take_aim_buff:CheckState() return { [MODIFIER_STATE_CANNOT_MISS] = true } end
function modifier_enfos_sniper_take_aim_buff:GetModifierMoveSpeedBonus_Percentage() return 15 end

enfos_sniper_assassinate=class({})
function enfos_sniper_assassinate:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Sniper.AssassinateShot')
    effect('particles/units/heroes/hero_sniper/sniper_assassinate.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 650 end
    local agi = get_agi(c)
    local dmg = base + (agi * 3.0)

    damage(self, t, dmg, DAMAGE_TYPE_PHYSICAL)
    if not t:IsAlive() then
        self:EndCooldown()
        if c.GiveMana and self.GetManaCost then
            c:GiveMana(self:GetManaCost(-1) * 0.5)
        end
    end
end

enfos_sniper_keen_eye=class({})
function enfos_sniper_keen_eye:GetIntrinsicModifierName() return 'modifier_enfos_sniper_keen_eye_passive' end

modifier_enfos_sniper_keen_eye_passive=class({})
function modifier_enfos_sniper_keen_eye_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_sniper_keen_eye_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    local origin = t:GetAbsOrigin()
    local dir = (origin - c:GetAbsOrigin()):Normalized()

    local pierced = enemies(c, origin + (dir * 250), 300)
    local attack_dmg = (params.damage or 100) * 0.6
    for _, u in ipairs(pierced) do
        if u ~= t then
            damage(self:GetAbility(), u, attack_dmg, DAMAGE_TYPE_PHYSICAL)
        end
    end
end

-- ----------------------------------------------------------------------------
-- CRYSTAL MAIDEN: CRYSTAL NOVA, FROSTBITE, ARCANE AURA, FREEZING FIELD, GLACIAL MASTERY
-- ----------------------------------------------------------------------------

enfos_cm_crystal_nova=class({})
function enfos_cm_crystal_nova:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    local r = value(self, 'radius')
    if r <= 0 then r = 425 end
    local base = value(self, 'damage')
    if base <= 0 then base = 250 end
    local int = get_int(c)
    local dmg = base + (int * 1.2)

    c:EmitSound('Hero_Crystal.CrystalNova')
    effect('particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf', c)

    for _, u in ipairs(enemies(c, pos, r)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_cm_crystal_nova_slow', { duration = 4.5 })
        local gm = c:FindAbilityByName('enfos_cm_glacial_mastery')
        if gm then
            u:AddNewModifier(c, gm, 'modifier_enfos_cm_frost_stack', { duration = 5.0 })
        end
    end
end

modifier_enfos_cm_crystal_nova_slow=class({})
function modifier_enfos_cm_crystal_nova_slow:IsDebuff() return true end
function modifier_enfos_cm_crystal_nova_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_cm_crystal_nova_slow:GetModifierMoveSpeedBonus_Percentage() return -40 end
function modifier_enfos_cm_crystal_nova_slow:GetModifierAttackSpeedBonus_Constant() return -50 end

enfos_cm_frostbite=class({})
function enfos_cm_frostbite:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Crystal.Frostbite')
    t:AddNewModifier(c, self, 'modifier_enfos_cm_frostbite_debuff', { duration = 3.0 })
end

modifier_enfos_cm_frostbite_debuff=class({})
function modifier_enfos_cm_frostbite_debuff:IsDebuff() return true end
function modifier_enfos_cm_frostbite_debuff:CheckState()
    return { [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true }
end
function modifier_enfos_cm_frostbite_debuff:OnCreated()
    if not IsServer() then return end
    effect('particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf', self:GetParent())
    self:StartIntervalThink(0.5)
end
function modifier_enfos_cm_frostbite_debuff:OnIntervalThink()
    local p = self:GetParent()
    local a = self:GetAbility()
    local c = self:GetCaster()
    local int = get_int(c)
    local base = (a and value(a, 'damage_per_second')) or 120
    local dmg = (base + (int * 0.5)) * 0.5
    if not is_boss(p) and not p:IsHero() then
        dmg = dmg * 3.0
    end
    damage(a, p, dmg, DAMAGE_TYPE_MAGICAL)
    local gm = c and c:FindAbilityByName('enfos_cm_glacial_mastery')
    if gm then
        p:AddNewModifier(c, gm, 'modifier_enfos_cm_frost_stack', { duration = 5.0 })
    end
end

enfos_cm_arcane_aura=class({})
function enfos_cm_arcane_aura:GetIntrinsicModifierName() return 'modifier_enfos_cm_arcane_aura' end

modifier_enfos_cm_arcane_aura=class({})
function modifier_enfos_cm_arcane_aura:IsHidden() return true end
function modifier_enfos_cm_arcane_aura:IsAura() return true end
function modifier_enfos_cm_arcane_aura:GetAuraRadius() return 99999 end
function modifier_enfos_cm_arcane_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_cm_arcane_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_enfos_cm_arcane_aura:GetModifierAura() return 'modifier_enfos_cm_arcane_aura_buff' end

modifier_enfos_cm_arcane_aura_buff=class({})
function modifier_enfos_cm_arcane_aura_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_enfos_cm_arcane_aura_buff:GetModifierConstantManaRegen()
    local is_owner = self:GetParent() == self:GetCaster()
    local base = (self.GetAbility and value(self:GetAbility(), 'mana_regen')) or 4.0
    return is_owner and (base * 3.0) or base
end
function modifier_enfos_cm_arcane_aura_buff:GetModifierSpellAmplify_Percentage() return 15 end

enfos_cm_freezing_field=class({})
function enfos_cm_freezing_field:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('hero_Crystal.freezingField.wind')
    c:AddNewModifier(c, self, 'modifier_enfos_cm_freezing_field_channel', { duration = 8.0 })
end
function enfos_cm_freezing_field:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_cm_freezing_field_channel')
    c:StopSound('hero_Crystal.freezingField.wind')
end

modifier_enfos_cm_freezing_field_channel=class({})
function modifier_enfos_cm_freezing_field_channel:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end
function modifier_enfos_cm_freezing_field_channel:GetModifierPhysicalArmorBonus() return 20 end
function modifier_enfos_cm_freezing_field_channel:GetModifierMagicalResistanceBonus() return 50 end
function modifier_enfos_cm_freezing_field_channel:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.2)
end
function modifier_enfos_cm_freezing_field_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local int = get_int(c)
    local base = (a and value(a, 'explosion_damage')) or 180
    local dmg = base + (int * 0.6)

    local targets = enemies(c, c:GetAbsOrigin(), 800)
    if #targets > 0 then
        local t = targets[RandomInt(1, #targets)]
        damage(a, t, dmg, DAMAGE_TYPE_MAGICAL)
        t:AddNewModifier(c, a, 'modifier_enfos_cm_freezing_field_slow', { duration = 1.0 })
        effect('particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf', t)
        local gm = c:FindAbilityByName('enfos_cm_glacial_mastery')
        if gm then
            t:AddNewModifier(c, gm, 'modifier_enfos_cm_frost_stack', { duration = 5.0 })
        end
    end
end

modifier_enfos_cm_freezing_field_slow=class({})
function modifier_enfos_cm_freezing_field_slow:IsDebuff() return true end
function modifier_enfos_cm_freezing_field_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_cm_freezing_field_slow:GetModifierMoveSpeedBonus_Percentage() return -35 end

enfos_cm_glacial_mastery=class({})
function enfos_cm_glacial_mastery:GetIntrinsicModifierName() return 'modifier_enfos_cm_glacial_mastery_passive' end

modifier_enfos_cm_glacial_mastery_passive=class({})
function modifier_enfos_cm_glacial_mastery_passive:IsHidden() return true end

modifier_enfos_cm_frost_stack=class({})
function modifier_enfos_cm_frost_stack:IsDebuff() return true end
function modifier_enfos_cm_frost_stack:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end
function modifier_enfos_cm_frost_stack:OnRefresh()
    if not IsServer() then return end
    local count = self:GetStackCount() + 1
    if count >= 5 then
        self:Destroy()
        local p = self:GetParent()
        local c = self:GetCaster()
        local a = self:GetAbility()
        p:AddNewModifier(c, a, 'modifier_enfos_cm_frozen', { duration = 1.5 })

        local max_hp = p.GetMaxHealth and p:GetMaxHealth() or 1000
        local hp_dmg = max_hp * 0.10
        if is_boss(p) then hp_dmg = math.min(600, hp_dmg) end
        local shatter_dmg = 150 + hp_dmg

        effect('particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf', p)
        for _, u in ipairs(enemies(c, p:GetAbsOrigin(), 300)) do
            damage(a, u, shatter_dmg, DAMAGE_TYPE_MAGICAL)
        end
    else
        self:SetStackCount(count)
    end
end

modifier_enfos_cm_frozen=class({})
function modifier_enfos_cm_frozen:IsDebuff() return true end
function modifier_enfos_cm_frozen:CheckState() return { [MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_STUNNED] = true } end

-- ----------------------------------------------------------------------------
-- DAZZLE: POISON TOUCH, SHALLOW GRAVE, SHADOW WAVE, BAD JUJU, NOTHL WEAVE
-- ----------------------------------------------------------------------------

enfos_dazzle_poison_touch=class({})
function enfos_dazzle_poison_touch:OnSpellStart()
    local c = self:GetCaster()
    local targets = enemies(c, c:GetAbsOrigin(), 700)
    c:EmitSound('Hero_Dazzle.Poison_Touch')

    local count = 0
    for _, u in ipairs(targets) do
        u:AddNewModifier(c, self, 'modifier_enfos_dazzle_poison_touch_debuff', { duration = 6.0 })
        effect('particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf', u)
        count = count + 1
        if count >= 8 then break end
    end
end

modifier_enfos_dazzle_poison_touch_debuff=class({})
function modifier_enfos_dazzle_poison_touch_debuff:IsDebuff() return true end
function modifier_enfos_dazzle_poison_touch_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_dazzle_poison_touch_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -25 - (self.bonus_slow or 0)
end
function modifier_enfos_dazzle_poison_touch_debuff:OnCreated()
    if not IsServer() then return end
    self.bonus_slow = 0
    self:StartIntervalThink(1.0)
end
function modifier_enfos_dazzle_poison_touch_debuff:OnIntervalThink()
    local p = self:GetParent()
    local a = self:GetAbility()
    local c = self:GetCaster()
    local int = get_int(c)
    local base = (a and value(a, 'damage_per_second')) or 60
    local dmg = base + (int * 0.35)
    damage(a, p, dmg, DAMAGE_TYPE_PHYSICAL)
end
function modifier_enfos_dazzle_poison_touch_debuff:OnAttackLanded(params)
    if not IsServer() then return end
    if params.target == self:GetParent() then
        self:SetDuration(6.0, true)
        self.bonus_slow = math.min(35, (self.bonus_slow or 0) + 2)
    end
end

enfos_dazzle_shallow_grave=class({})
function enfos_dazzle_shallow_grave:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget() or c
    c:EmitSound('Hero_Dazzle.Shallow_Grave')
    effect('particles/units/heroes/hero_dazzle/dazzle_shallow_grave.vpcf', t)
    t:AddNewModifier(c, self, 'modifier_enfos_dazzle_shallow_grave_buff', { duration = 5.0 })
end

modifier_enfos_dazzle_shallow_grave_buff=class({})
function modifier_enfos_dazzle_shallow_grave_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET }
end
function modifier_enfos_dazzle_shallow_grave_buff:GetMinHealth() return 1 end
function modifier_enfos_dazzle_shallow_grave_buff:GetModifierHealAmplify_PercentageTarget() return 40 end

enfos_dazzle_shadow_wave=class({})
function enfos_dazzle_shadow_wave:OnSpellStart()
    local c = self:GetCaster()
    local initial = self:GetCursorTarget() or c
    c:EmitSound('Hero_Dazzle.Shadow_Wave')
    local int = get_int(c)
    local base_heal = value(self, 'heal_amount')
    if base_heal <= 0 then base_heal = 170 end
    local heal = base_heal + (int * 1.0)

    local healed = { [initial:entindex()] = true }
    local current = initial
    local jump_targets = { initial }

    for i = 1, 6 do
        local candidates = allies(c, current:GetAbsOrigin(), 500)
        local next_target = nil
        for _, u in ipairs(candidates) do
            if not healed[u:entindex()] then
                next_target = u
                break
            end
        end
        if not next_target then break end
        healed[next_target:entindex()] = true
        table.insert(jump_targets, next_target)
        current = next_target
    end

    for _, target in ipairs(jump_targets) do
        target:Heal(heal, self)
        effect('particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf', target)
        for _, enemy in ipairs(enemies(c, target:GetAbsOrigin(), 200)) do
            damage(self, enemy, heal, DAMAGE_TYPE_PHYSICAL)
        end
    end
end

enfos_dazzle_bad_juju=class({})
function enfos_dazzle_bad_juju:GetIntrinsicModifierName() return 'modifier_enfos_dazzle_bad_juju_passive' end
function enfos_dazzle_bad_juju:OnSpellStart()
    local c = self:GetCaster()
    local cost = c:GetHealth() * 0.10
    if c:GetHealth() > cost then c:SetHealth(c:GetHealth() - cost) end

    c:EmitSound('Hero_Dazzle.BadJuju.Cast')
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 600)) do
        u:AddNewModifier(c, self, 'modifier_enfos_dazzle_bad_juju_debuff', { duration = 8.0 })
    end
    for _, u in ipairs(allies(c, c:GetAbsOrigin(), 600)) do
        u:AddNewModifier(c, self, 'modifier_enfos_dazzle_bad_juju_buff', { duration = 8.0 })
    end
end

modifier_enfos_dazzle_bad_juju_passive=class({})
function modifier_enfos_dazzle_bad_juju_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST } end
function modifier_enfos_dazzle_bad_juju_passive:OnAbilityFullyCast(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c or params.ability == self:GetAbility() then return end

    for i = 0, 5 do
        local ab = c:GetAbilityByIndex(i)
        if ab and ab ~= params.ability and ab.GetCooldownTimeRemaining and ab:GetCooldownTimeRemaining() > 0 then
            local rem = ab:GetCooldownTimeRemaining() - 1.5
            ab:EndCooldown()
            if rem > 0 then ab:StartCooldown(rem) end
        end
    end
end

modifier_enfos_dazzle_bad_juju_buff=class({})
function modifier_enfos_dazzle_bad_juju_buff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_bad_juju_buff:GetModifierPhysicalArmorBonus() return 5 end

modifier_enfos_dazzle_bad_juju_debuff=class({})
function modifier_enfos_dazzle_bad_juju_debuff:IsDebuff() return true end
function modifier_enfos_dazzle_bad_juju_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_bad_juju_debuff:GetModifierPhysicalArmorBonus() return -5 end

enfos_dazzle_nothl_weave=class({})
function enfos_dazzle_nothl_weave:GetIntrinsicModifierName() return 'modifier_enfos_dazzle_nothl_weave_aura' end

modifier_enfos_dazzle_nothl_weave_aura=class({})
function modifier_enfos_dazzle_nothl_weave_aura:IsHidden() return true end
function modifier_enfos_dazzle_nothl_weave_aura:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(3.0)
end
function modifier_enfos_dazzle_nothl_weave_aura:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 900)) do
        local mod = u:FindModifierByName('modifier_enfos_dazzle_nothl_weave_debuff')
        if not mod then
            mod = u:AddNewModifier(c, a, 'modifier_enfos_dazzle_nothl_weave_debuff', { duration = 6.0 })
        end
        if mod then
            mod:SetStackCount(math.min(5, mod:GetStackCount() + 1))
            mod:SetDuration(6.0, true)
        end
    end
    for _, u in ipairs(allies(c, c:GetAbsOrigin(), 900)) do
        local mod = u:FindModifierByName('modifier_enfos_dazzle_nothl_weave_buff')
        if not mod then
            mod = u:AddNewModifier(c, a, 'modifier_enfos_dazzle_nothl_weave_buff', { duration = 6.0 })
        end
        if mod then
            mod:SetStackCount(math.min(5, mod:GetStackCount() + 1))
            mod:SetDuration(6.0, true)
        end
    end
end

modifier_enfos_dazzle_nothl_weave_buff=class({})
function modifier_enfos_dazzle_nothl_weave_buff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_nothl_weave_buff:GetModifierPhysicalArmorBonus() return (self:GetStackCount() or 1) * 2 end

modifier_enfos_dazzle_nothl_weave_debuff=class({})
function modifier_enfos_dazzle_nothl_weave_debuff:IsDebuff() return true end
function modifier_enfos_dazzle_nothl_weave_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_nothl_weave_debuff:GetModifierPhysicalArmorBonus() return (self:GetStackCount() or 1) * -2 end


-- ============================================================================
-- BATCH 3 PVE HERO KITS: BRISTLEBACK, TIDEHUNTER, WRAITH KING, PA, ZEUS, WITCH DOCTOR
-- ============================================================================

-- ----------------------------------------------------------------------------
-- BRISTLEBACK: VISCOUS NASAL GOO, QUILL SPRAY, BRISTLEBACK, WARPATH, HAIRBALL
-- ----------------------------------------------------------------------------

enfos_bb_viscous_nasal_goo=class({})
function enfos_bb_viscous_nasal_goo:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Bristleback.ViscousGoo.Cast')
    t:AddNewModifier(c, self, 'modifier_enfos_bb_viscous_nasal_goo_debuff', { duration = 5.0 })
end

modifier_enfos_bb_viscous_nasal_goo_debuff=class({})
function modifier_enfos_bb_viscous_nasal_goo_debuff:IsDebuff() return true end
function modifier_enfos_bb_viscous_nasal_goo_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_bb_viscous_nasal_goo_debuff:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
end
function modifier_enfos_bb_viscous_nasal_goo_debuff:OnRefresh()
    if not IsServer() then return end
    self:SetStackCount(math.min(4, self:GetStackCount() + 1))
end
function modifier_enfos_bb_viscous_nasal_goo_debuff:GetModifierPhysicalArmorBonus()
    local red = (self.GetAbility and value(self:GetAbility(), 'armor_reduction')) or 3
    return -red * (self:GetStackCount() or 1)
end
function modifier_enfos_bb_viscous_nasal_goo_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -15 - ((self:GetStackCount() or 1) * 3)
end

enfos_bb_quill_spray=class({})
function enfos_bb_quill_spray:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Bristleback.QuillSpray.Cast')
    effect('particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf', c)

    local base_dmg = value(self, 'base_damage')
    if base_dmg <= 0 then base_dmg = 80 end
    local stack_dmg = value(self, 'stack_damage')
    if stack_dmg <= 0 then stack_dmg = 40 end
    local str = get_str(c)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 700)) do
        local mod = u:FindModifierByName('modifier_enfos_bb_quill_spray_debuff')
        local stacks = (mod and mod.GetStackCount and mod:GetStackCount()) or 0
        local total_dmg = base_dmg + (str * 0.4) + (stacks * (stack_dmg + (str * 0.15)))
        damage(self, u, total_dmg, DAMAGE_TYPE_PHYSICAL)

        if not mod then
            mod = u:AddNewModifier(c, self, 'modifier_enfos_bb_quill_spray_debuff', { duration = 14.0 })
        end
        if mod and mod.SetStackCount then
            local cur = (mod.GetStackCount and mod:GetStackCount()) or 0
            mod:SetStackCount(math.min(10, cur + 1))
        end
        if mod and mod.SetDuration then
            mod:SetDuration(14.0, true)
        end
    end

    local warpath = c:FindAbilityByName('enfos_bb_warpath')
    if warpath then
        local w_mod = c:FindModifierByName('modifier_enfos_bb_warpath_buff')
        if not w_mod then
            w_mod = c:AddNewModifier(c, warpath, 'modifier_enfos_bb_warpath_buff', { duration = 10.0 })
        end
        if w_mod and w_mod.SetStackCount then
            local cur = (w_mod.GetStackCount and w_mod:GetStackCount()) or 0
            w_mod:SetStackCount(math.min(10, cur + 1))
        end
        if w_mod and w_mod.SetDuration then
            w_mod:SetDuration(10.0, true)
        end
    end
end

modifier_enfos_bb_quill_spray_debuff=class({})
function modifier_enfos_bb_quill_spray_debuff:IsDebuff() return true end

enfos_bb_bristleback=class({})
function enfos_bb_bristleback:GetIntrinsicModifierName() return 'modifier_enfos_bb_bristleback_passive' end

modifier_enfos_bb_bristleback_passive=class({})
function modifier_enfos_bb_bristleback_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_bb_bristleback_passive:OnCreated()
    self.accumulated_damage = 0
end
function modifier_enfos_bb_bristleback_passive:GetModifierIncomingDamage_Percentage()
    return -25
end
function modifier_enfos_bb_bristleback_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c then return end

    self.accumulated_damage = (self.accumulated_damage or 0) + (params.damage or 0)
    if self.accumulated_damage >= 200 then
        self.accumulated_damage = 0
        local qs = c:FindAbilityByName('enfos_bb_quill_spray')
        if qs and qs:GetLevel() > 0 then
            qs:OnSpellStart()
        end
    end
end

enfos_bb_warpath=class({})
function enfos_bb_warpath:GetIntrinsicModifierName() return 'modifier_enfos_bb_warpath_passive' end

modifier_enfos_bb_warpath_passive=class({})
function modifier_enfos_bb_warpath_passive:IsHidden() return true end

modifier_enfos_bb_warpath_buff=class({})
function modifier_enfos_bb_warpath_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_bb_warpath_buff:GetModifierPreAttack_BonusDamage()
    return (self:GetStackCount() or 1) * 25
end
function modifier_enfos_bb_warpath_buff:GetModifierMoveSpeedBonus_Percentage()
    return (self:GetStackCount() or 1) * 3
end

enfos_bb_hairball=class({})
function enfos_bb_hairball:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_Bristleback.Hairball.Cast')

    local goo = c:FindAbilityByName('enfos_bb_viscous_nasal_goo')
    local qs = c:FindAbilityByName('enfos_bb_quill_spray')

    for _, u in ipairs(enemies(c, pos, 400)) do
        if goo then
            u:AddNewModifier(c, goo, 'modifier_enfos_bb_viscous_nasal_goo_debuff', { duration = 5.0 })
            local m = u:FindModifierByName('modifier_enfos_bb_viscous_nasal_goo_debuff')
            if m then m:SetStackCount(2) end
        end
    end
    if qs then qs:OnSpellStart() end
end

-- ----------------------------------------------------------------------------
-- TIDEHUNTER: GUSH, KRAKEN SHELL, ANCHOR SMASH, RAVAGE, COLOSSAL PRESENCE
-- ----------------------------------------------------------------------------

enfos_tide_gush=class({})
function enfos_tide_gush:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Tidehunter.Gush.Cast')
    effect('particles/units/heroes/hero_tidehunter/tidehunter_gush.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 220 end
    local str = get_str(c)
    local dmg = base + (str * 1.0)

    damage(self, t, dmg, DAMAGE_TYPE_MAGICAL)
    t:AddNewModifier(c, self, 'modifier_enfos_tide_gush_debuff', { duration = 4.5 })
end

modifier_enfos_tide_gush_debuff=class({})
function modifier_enfos_tide_gush_debuff:IsDebuff() return true end
function modifier_enfos_tide_gush_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_tide_gush_debuff:GetModifierPhysicalArmorBonus()
    return -((self.GetAbility and value(self:GetAbility(), 'armor_reduction')) or 5)
end
function modifier_enfos_tide_gush_debuff:GetModifierMoveSpeedBonus_Percentage() return -40 end

enfos_tide_kraken_shell=class({})
function enfos_tide_kraken_shell:GetIntrinsicModifierName() return 'modifier_enfos_tide_kraken_shell_passive' end

modifier_enfos_tide_kraken_shell_passive=class({})
function modifier_enfos_tide_kraken_shell_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_tide_kraken_shell_passive:OnCreated()
    self.damage_counter = 0
end
function modifier_enfos_tide_kraken_shell_passive:GetModifierPhysical_ConstantBlock()
    local c = self:GetParent()
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'damage_block')) or 50
    return base + (str * 0.05)
end
function modifier_enfos_tide_kraken_shell_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c then return end
    self.damage_counter = (self.damage_counter or 0) + (params.damage or 0)
    if self.damage_counter >= 450 then
        self.damage_counter = 0
        if c.Purge then c:Purge(false, true, false, true, true) end
    end
end

enfos_tide_anchor_smash=class({})
function enfos_tide_anchor_smash:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Tidehunter.AnchorSmash')

    local base = value(self, 'bonus_damage')
    if base <= 0 then base = 160 end
    local str = get_str(c)
    local dmg = (c.GetAverageTrueAttackDamage and c:GetAverageTrueAttackDamage() or 100) + base + (str * 0.75)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 400)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_tide_anchor_smash_debuff', { duration = 6.0 })
    end
end

modifier_enfos_tide_anchor_smash_debuff=class({})
function modifier_enfos_tide_anchor_smash_debuff:IsDebuff() return true end
function modifier_enfos_tide_anchor_smash_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end
function modifier_enfos_tide_anchor_smash_debuff:GetModifierBaseDamageOutgoing_Percentage()
    return -((self.GetAbility and value(self:GetAbility(), 'damage_reduction')) or 50)
end

enfos_tide_ravage=class({})
function enfos_tide_ravage:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Tidehunter.Ravage')
    effect('particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage.vpcf', c)

    local base = value(self, 'damage')
    if base <= 0 then base = 325 end
    local str = get_str(c)
    local dmg = base + (str * 2.0)
    local dur = value(self, 'stun_duration')
    if dur <= 0 then dur = 2.8 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 1000)) do
        local target_dur = is_boss(u) and 1.0 or dur
        u:AddNewModifier(c, self, 'modifier_enfos_tide_ravage_stun', { duration = target_dur })
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
    end
end

modifier_enfos_tide_ravage_stun=class({})
function modifier_enfos_tide_ravage_stun:IsDebuff() return true end
function modifier_enfos_tide_ravage_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_tide_colossal_presence=class({})
function enfos_tide_colossal_presence:GetIntrinsicModifierName() return 'modifier_enfos_tide_colossal_presence_aura' end

modifier_enfos_tide_colossal_presence_aura=class({})
function modifier_enfos_tide_colossal_presence_aura:IsHidden() return true end
function modifier_enfos_tide_colossal_presence_aura:IsAura() return true end
function modifier_enfos_tide_colossal_presence_aura:GetAuraRadius() return 900 end
function modifier_enfos_tide_colossal_presence_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_enfos_tide_colossal_presence_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_tide_colossal_presence_aura:GetModifierAura() return 'modifier_enfos_tide_colossal_presence_debuff' end
function modifier_enfos_tide_colossal_presence_aura:DeclareFunctions() return { MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE } end
function modifier_enfos_tide_colossal_presence_aura:GetModifierExtraHealthPercentage() return 25 end

modifier_enfos_tide_colossal_presence_debuff=class({})
function modifier_enfos_tide_colossal_presence_debuff:IsDebuff() return true end
function modifier_enfos_tide_colossal_presence_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end
function modifier_enfos_tide_colossal_presence_debuff:GetModifierMoveSpeedBonus_Percentage() return -15 end
function modifier_enfos_tide_colossal_presence_debuff:GetModifierBaseDamageOutgoing_Percentage() return -15 end

-- ----------------------------------------------------------------------------
-- WRAITH KING: WRAITHFIRE BLAST, VAMPIRIC AURA, MORTAL STRIKE, REINCARNATION, SKELETON ARMY
-- ----------------------------------------------------------------------------

enfos_wk_wraithfire_blast=class({})
function enfos_wk_wraithfire_blast:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_SkeletonKing.Hellfire_Blast')
    effect('particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 200 end
    local str = get_str(c)
    local dmg = base + (str * 1.2)

    damage(self, t, dmg, DAMAGE_TYPE_MAGICAL)
    local stun_dur = is_boss(t) and 0.6 or (value(self, 'stun_duration') or 1.5)
    t:AddNewModifier(c, self, 'modifier_enfos_wk_wraithfire_blast_stun', { duration = stun_dur })
    t:AddNewModifier(c, self, 'modifier_enfos_wk_wraithfire_blast_dot', { duration = 2.0 })
end

modifier_enfos_wk_wraithfire_blast_stun=class({})
function modifier_enfos_wk_wraithfire_blast_stun:IsDebuff() return true end
function modifier_enfos_wk_wraithfire_blast_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

modifier_enfos_wk_wraithfire_blast_dot=class({})
function modifier_enfos_wk_wraithfire_blast_dot:IsDebuff() return true end
function modifier_enfos_wk_wraithfire_blast_dot:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_wk_wraithfire_blast_dot:GetModifierMoveSpeedBonus_Percentage() return -20 end
function modifier_enfos_wk_wraithfire_blast_dot:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_wk_wraithfire_blast_dot:OnIntervalThink()
    local c = self:GetCaster()
    local p = self:GetParent()
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'dot_damage')) or 80
    damage(self:GetAbility(), p, base + (str * 0.3), DAMAGE_TYPE_MAGICAL)
end

enfos_wk_vampiric_aura=class({})
function enfos_wk_vampiric_aura:GetIntrinsicModifierName() return 'modifier_enfos_wk_vampiric_aura' end

modifier_enfos_wk_vampiric_aura=class({})
function modifier_enfos_wk_vampiric_aura:IsHidden() return true end
function modifier_enfos_wk_vampiric_aura:IsAura() return true end
function modifier_enfos_wk_vampiric_aura:GetAuraRadius() return 900 end
function modifier_enfos_wk_vampiric_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_wk_vampiric_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_wk_vampiric_aura:GetModifierAura() return 'modifier_enfos_wk_vampiric_aura_buff' end

modifier_enfos_wk_vampiric_aura_buff=class({})
function modifier_enfos_wk_vampiric_aura_buff:DeclareFunctions() return { MODIFIER_EVENT_ON_TAKEDAMAGE } end
function modifier_enfos_wk_vampiric_aura_buff:OnTakeDamage(params)
    if not IsServer() then return end
    local p = self:GetParent()
    if params.attacker == p and params.damage and params.damage > 0 then
        local pct = (p == self:GetCaster()) and 0.50 or 0.25
        p:Heal(params.damage * pct, self:GetAbility())
    end
end

enfos_wk_mortal_strike=class({})
function enfos_wk_mortal_strike:GetIntrinsicModifierName() return 'modifier_enfos_wk_mortal_strike_passive' end

modifier_enfos_wk_mortal_strike_passive=class({})
function modifier_enfos_wk_mortal_strike_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_wk_mortal_strike_passive:GetModifierPreAttack_CriticalStrike()
    if RollPercentage(20) then
        self.crit_proc = true
        return 260
    end
    self.crit_proc = false
    return 0
end
function modifier_enfos_wk_mortal_strike_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if self.crit_proc and t and t:IsAlive() then
        c:EmitSound('Hero_SkeletonKing.CriticalStrike')
        effect('particles/units/heroes/hero_skeletonking/skeletonking_mortalstrike.vpcf', t)
        local cleave_dmg = (params.damage or 200) * 0.5
        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 300)) do
            if u ~= t then damage(self:GetAbility(), u, cleave_dmg, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

enfos_wk_reincarnation=class({})
function enfos_wk_reincarnation:GetIntrinsicModifierName() return 'modifier_enfos_wk_reincarnation_passive' end

modifier_enfos_wk_reincarnation_passive=class({})
function modifier_enfos_wk_reincarnation_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_wk_reincarnation_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c then return end
    local a = self:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or not a:IsCooldownReady() then return end

    a:StartCooldown(60.0)
    c:EmitSound('Hero_SkeletonKing.Reincarnate')
    local str = get_str(c)
    local dmg = 500 + (str * 2.5)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 900)) do
        damage(a, u, dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_wk_skeleton_army=class({})
function enfos_wk_skeleton_army:GetIntrinsicModifierName() return 'modifier_enfos_wk_skeleton_army_passive' end
function enfos_wk_skeleton_army:OnSpellStart()
    local c = self:GetCaster()
    local mod = c:FindModifierByName('modifier_enfos_wk_skeleton_army_passive')
    local count = mod and mod:GetStackCount() or 0
    if count <= 0 then count = 4 end
    if mod then mod:SetStackCount(0) end

    c:EmitSound('Hero_SkeletonKing.Hellfire_Blast')
    local str = get_str(c)
    local dmg = 120 + (str * 0.8)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 600)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
    end
end

modifier_enfos_wk_skeleton_army_passive=class({})
function modifier_enfos_wk_skeleton_army_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_wk_skeleton_army_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and params.unit ~= c then
        self:SetStackCount(math.min(8, (self:GetStackCount() or 0) + 1))
    end
end

-- ----------------------------------------------------------------------------
-- PHANTOM ASSASSIN: STIFLING DAGGER, PHANTOM STRIKE, BLUR, COUP DE GRACE, FAN OF KNIVES
-- ----------------------------------------------------------------------------

enfos_pa_stifling_dagger=class({})
function enfos_pa_stifling_dagger:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_PhantomAssassin.Dagger.Cast')
    local base = value(self, 'base_damage')
    if base <= 0 then base = 120 end
    local agi = get_agi(c)
    local atk = c.GetAverageTrueAttackDamage and c:GetAverageTrueAttackDamage() or 100
    local dmg = base + (atk * 0.7) + (agi * 0.5)

    -- Pierces up to 3 targets in a line
    local dir = (t:GetAbsOrigin() - c:GetAbsOrigin()):Normalized()
    local hits = 0
    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 500), 500)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_pa_stifling_dagger_slow', { duration = 4.0 })
        effect('particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf', u)
        hits = hits + 1
        if hits >= 3 then break end
    end
end

modifier_enfos_pa_stifling_dagger_slow=class({})
function modifier_enfos_pa_stifling_dagger_slow:IsDebuff() return true end
function modifier_enfos_pa_stifling_dagger_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_pa_stifling_dagger_slow:GetModifierMoveSpeedBonus_Percentage() return -50 end

enfos_pa_phantom_strike=class({})
function enfos_pa_phantom_strike:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_PhantomAssassin.Strike.Start')
    FindClearSpaceForUnit(c, t:GetAbsOrigin() + Vector(-60, 0, 0), true)
    c:AddNewModifier(c, self, 'modifier_enfos_pa_phantom_strike_buff', { duration = 3.0 })
end

modifier_enfos_pa_phantom_strike_buff=class({})
function modifier_enfos_pa_phantom_strike_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_pa_phantom_strike_buff:GetModifierAttackSpeedBonus_Constant() return 150 end
function modifier_enfos_pa_phantom_strike_buff:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and params.damage and params.damage > 0 then
        c:Heal(params.damage * 0.15, self:GetAbility())
    end
end

enfos_pa_blur=class({})
function enfos_pa_blur:GetIntrinsicModifierName() return 'modifier_enfos_pa_blur_passive' end
function enfos_pa_blur:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_PhantomAssassin.Blur')
    c:AddNewModifier(c, self, 'modifier_enfos_pa_blur_active', { duration = 15.0 })
end

modifier_enfos_pa_blur_passive=class({})
function modifier_enfos_pa_blur_passive:DeclareFunctions() return { MODIFIER_PROPERTY_EVASION_CONSTANT } end
function modifier_enfos_pa_blur_passive:GetModifierEvasion_Constant()
    return (self.GetAbility and value(self:GetAbility(), 'evasion')) or 40
end

modifier_enfos_pa_blur_active=class({})
function modifier_enfos_pa_blur_active:CheckState() return { [MODIFIER_STATE_INVISIBLE] = true } end

enfos_pa_coup_de_grace=class({})
function enfos_pa_coup_de_grace:GetIntrinsicModifierName() return 'modifier_enfos_pa_coup_de_grace_passive' end

modifier_enfos_pa_coup_de_grace_passive=class({})
function modifier_enfos_pa_coup_de_grace_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_pa_coup_de_grace_passive:GetModifierPreAttack_CriticalStrike()
    local c = self:GetParent()
    local is_blur = c:HasModifier('modifier_enfos_pa_blur_active')
    if is_blur or RollPercentage(15) then
        if is_blur then c:RemoveModifierByName('modifier_enfos_pa_blur_active') end
        self.crit_proc = true
        return 425
    end
    self.crit_proc = false
    return 0
end
function modifier_enfos_pa_coup_de_grace_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if self.crit_proc and t and t:IsAlive() then
        c:EmitSound('Hero_PhantomAssassin.CoupDeGrace')
        effect('particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf', t)
        local aoe_dmg = (params.damage or 400) * 0.5
        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 250)) do
            if u ~= t then damage(self:GetAbility(), u, aoe_dmg, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

enfos_pa_fan_of_knives=class({})
function enfos_pa_fan_of_knives:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_PhantomAssassin.FanOfKnives')
    local r = value(self, 'radius')
    if r <= 0 then r = 550 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        local max_hp = u.GetMaxHealth and u:GetMaxHealth() or 1000
        local pct_dmg = max_hp * 0.12
        if is_boss(u) then pct_dmg = math.min(600, pct_dmg) end
        damage(self, u, 150 + pct_dmg, DAMAGE_TYPE_PURE)
    end
end

-- ----------------------------------------------------------------------------
-- ZEUS: ARC LIGHTNING, LIGHTNING BOLT, STATIC FIELD, THUNDERGOD'S WRATH, HEAVENLY JUMP
-- ----------------------------------------------------------------------------

enfos_zeus_arc_lightning=class({})
function enfos_zeus_arc_lightning:OnSpellStart()
    local c = self:GetCaster()
    local initial = self:GetCursorTarget()
    if not initial or not initial:IsAlive() then return end

    c:EmitSound('Hero_Zuus.ArcLightning.Cast')
    local base = value(self, 'damage')
    if base <= 0 then base = 90 end
    local int = get_int(c)
    local dmg = base + (int * 0.6)

    local hit = { [initial:entindex()] = true }
    local current = initial

    if ParticleManager then
        local p = ParticleManager:CreateParticle('particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf', PATTACH_CUSTOMORIGIN, c)
        ParticleManager:SetParticleControlEnt(p, 0, c, PATTACH_POINT_FOLLOW, "attach_attack1", c:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(p, 1, initial, PATTACH_POINT_FOLLOW, "attach_hitloc", initial:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(p)
    end
    initial:EmitSound('Hero_Zuus.ArcLightning.Target')
    damage(self, initial, dmg, DAMAGE_TYPE_MAGICAL)

    local jumps = value(self, 'jump_count')
    if jumps <= 0 then jumps = 9 end

    for i = 1, jumps do
        local candidates = enemies(c, current:GetAbsOrigin(), 500)
        local next_target = nil
        for _, u in ipairs(candidates) do
            if not hit[u:entindex()] and u:IsAlive() then next_target = u break end
        end
        if not next_target then break end
        hit[next_target:entindex()] = true

        if ParticleManager then
            local p = ParticleManager:CreateParticle('particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf', PATTACH_CUSTOMORIGIN, current)
            ParticleManager:SetParticleControlEnt(p, 0, current, PATTACH_POINT_FOLLOW, "attach_hitloc", current:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(p, 1, next_target, PATTACH_POINT_FOLLOW, "attach_hitloc", next_target:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(p)
        end
        next_target:EmitSound('Hero_Zuus.ArcLightning.Target')
        damage(self, next_target, dmg, DAMAGE_TYPE_MAGICAL)
        current = next_target
    end
end

enfos_zeus_lightning_bolt=class({})
function enfos_zeus_lightning_bolt:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Zuus.LightningBolt')
    effect('particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 300 end
    local int = get_int(c)
    local dmg = base + (int * 1.5)

    damage(self, t, dmg, DAMAGE_TYPE_MAGICAL)
end

enfos_zeus_static_field=class({})
function enfos_zeus_static_field:GetIntrinsicModifierName() return 'modifier_enfos_zeus_static_field_passive' end

modifier_enfos_zeus_static_field_passive=class({})
function modifier_enfos_zeus_static_field_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST } end
function modifier_enfos_zeus_static_field_passive:OnAbilityFullyCast(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c or params.ability == self:GetAbility() then return end

    local a = self:GetAbility()
    local pct = (a and value(a, 'damage_pct')) or 8
    if pct <= 0 then pct = 8 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 800)) do
        local cur_hp = u.GetHealth and u:GetHealth() or 500
        local dmg = cur_hp * (pct / 100)
        if is_boss(u) then dmg = math.min(500, dmg) end
        damage(a, u, dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_zeus_thundergods_wrath=class({})
function enfos_zeus_thundergods_wrath:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Zuus.GodsWrath')
    effect('particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf', c)

    local base = value(self, 'damage')
    if base <= 0 then base = 450 end
    local int = get_int(c)
    local dmg = base + (int * 2.0)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 99999)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        effect('particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf', u)
    end
end

enfos_zeus_heavenly_jump=class({})
function enfos_zeus_heavenly_jump:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Zuus.HeavenlyJump')
    c:AddNewModifier(c, self, 'modifier_enfos_zeus_heavenly_jump_buff', { duration = 3.0 })

    local int = get_int(c)
    local dmg = 150 + (int * 0.8)

    local count = 0
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 600)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_zeus_heavenly_jump_slow', { duration = 2.0 })
        count = count + 1
        if count >= 3 then break end
    end
end

modifier_enfos_zeus_heavenly_jump_buff=class({})
function modifier_enfos_zeus_heavenly_jump_buff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_zeus_heavenly_jump_buff:GetModifierMoveSpeedBonus_Percentage() return 25 end

modifier_enfos_zeus_heavenly_jump_slow=class({})
function modifier_enfos_zeus_heavenly_jump_slow:IsDebuff() return true end
function modifier_enfos_zeus_heavenly_jump_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_zeus_heavenly_jump_slow:GetModifierMoveSpeedBonus_Percentage() return -80 end

-- ----------------------------------------------------------------------------
-- WITCH DOCTOR: PARALYZING CASK, VOODOO RESTORATION, MALEDICT, DEATH WARD, VOODOO SWITCHEROO
-- ----------------------------------------------------------------------------

enfos_wd_paralyzing_cask=class({})
function enfos_wd_paralyzing_cask:OnSpellStart()
    local c = self:GetCaster()
    local initial = self:GetCursorTarget()
    if not initial or not initial:IsAlive() then return end

    c:EmitSound('Hero_WitchDoctor.Paralyzing_Cask_Cast')
    local base = value(self, 'damage')
    if base <= 0 then base = 100 end
    local int = get_int(c)
    local dmg = base + (int * 0.4)

    local current = initial
    local bounces = value(self, 'bounces')
    if bounces <= 0 then bounces = 10 end

    for i = 1, bounces do
        if not current or not current:IsAlive() then break end
        damage(self, current, dmg, DAMAGE_TYPE_MAGICAL)
        local stun_dur = is_boss(current) and 0.3 or 1.0
        current:AddNewModifier(c, self, 'modifier_enfos_wd_paralyzing_cask_stun', { duration = stun_dur })
        effect('particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf', current)

        local candidates = enemies(c, current:GetAbsOrigin(), 500)
        local next_target = nil
        for _, u in ipairs(candidates) do
            if u ~= current then next_target = u break end
        end
        current = next_target
    end
end

modifier_enfos_wd_paralyzing_cask_stun=class({})
function modifier_enfos_wd_paralyzing_cask_stun:IsDebuff() return true end
function modifier_enfos_wd_paralyzing_cask_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_wd_voodoo_restoration=class({})
function enfos_wd_voodoo_restoration:OnToggle()
    local c = self:GetCaster()
    if self:GetToggleState() then
        c:AddNewModifier(c, self, 'modifier_enfos_wd_voodoo_restoration_aura', {})
    else
        c:RemoveModifierByName('modifier_enfos_wd_voodoo_restoration_aura')
    end
end

modifier_enfos_wd_voodoo_restoration_aura=class({})
function modifier_enfos_wd_voodoo_restoration_aura:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_wd_voodoo_restoration_aura:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local int = get_int(c)
    local val = (a and value(a, 'heal_per_second')) or 50
    local amount = val + (int * 0.3)

    for _, u in ipairs(allies(c, c:GetAbsOrigin(), 500)) do
        u:Heal(amount, a)
    end
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 500)) do
        damage(a, u, amount, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_wd_maledict=class({})
function enfos_wd_maledict:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_WitchDoctor.Maledict_Cast')
    local r = value(self, 'radius')
    if r <= 0 then r = 200 end

    for _, u in ipairs(enemies(c, pos, r)) do
        u:AddNewModifier(c, self, 'modifier_enfos_wd_maledict_debuff', { duration = 12.0 })
        effect('particles/units/heroes/hero_witchdoctor/witchdoctor_maledict.vpcf', u)
    end
end

modifier_enfos_wd_maledict_debuff=class({})
function modifier_enfos_wd_maledict_debuff:IsDebuff() return true end
function modifier_enfos_wd_maledict_debuff:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent()
    self.start_hp = p.GetHealth and p:GetHealth() or 1000
    self.elapsed = 0
    self:StartIntervalThink(1.0)
end
function modifier_enfos_wd_maledict_debuff:OnIntervalThink()
    local p = self:GetParent()
    local a = self:GetAbility()
    local dps = (a and value(a, 'base_dps')) or 50
    damage(a, p, dps, DAMAGE_TYPE_MAGICAL)

    self.elapsed = (self.elapsed or 0) + 1
    if self.elapsed % 4 == 0 then
        local current_hp = p.GetHealth and p:GetHealth() or 0
        local lost_hp = math.max(0, self.start_hp - current_hp)
        local burst = lost_hp * 0.25
        damage(a, p, burst, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_wd_death_ward=class({})
function enfos_wd_death_ward:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_WitchDoctor.Death_Ward')
    c:AddNewModifier(c, self, 'modifier_enfos_wd_death_ward_channel', { duration = 8.0, x = pos.x, y = pos.y, z = pos.z })
end
function enfos_wd_death_ward:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_wd_death_ward_channel')
    c:StopSound('Hero_WitchDoctor.Death_Ward')
end

modifier_enfos_wd_death_ward_channel=class({})
function modifier_enfos_wd_death_ward_channel:OnCreated(kv)
    if not IsServer() then return end
    self.pos = Vector(kv.x or 0, kv.y or 0, kv.z or 0)
    self:StartIntervalThink(0.22)
end
function modifier_enfos_wd_death_ward_channel:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local int = get_int(c)
    local base = (a and value(a, 'damage')) or 150
    local dmg = base + (int * 0.75)

    local targets = enemies(c, self.pos, 700)
    if #targets > 0 then
        local t = targets[RandomInt(1, #targets)]
        damage(a, t, dmg, DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf', t)
    end
end

enfos_wd_voodoo_switcheroo=class({})
function enfos_wd_voodoo_switcheroo:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_WitchDoctor.Death_Ward')
    c:AddNewModifier(c, self, 'modifier_enfos_wd_voodoo_switcheroo_buff', { duration = 3.0 })
end

modifier_enfos_wd_voodoo_switcheroo_buff=class({})
function modifier_enfos_wd_voodoo_switcheroo_buff:CheckState()
    return { [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_DISARMED] = true }
end
function modifier_enfos_wd_voodoo_switcheroo_buff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.25)
end
function modifier_enfos_wd_voodoo_switcheroo_buff:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local int = get_int(c)
    local dmg = 120 + (int * 0.8)

    local targets = enemies(c, c:GetAbsOrigin(), 600)
    if #targets > 0 then
        local t = targets[RandomInt(1, #targets)]
        damage(a, t, dmg, DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf', t)
    end
end

-- ============================================================================
-- BATCH 4 PVE HERO KITS: DK, PUDGE, SLARK, URSA, MK, AM, VOID, SF, STORM, SS, LION
-- ============================================================================

-- ----------------------------------------------------------------------------
-- DRAGON KNIGHT: BREATHE FIRE, DRAGON TAIL, DRAGON BLOOD, ELDER DRAGON, WYRM VIGOR
-- ----------------------------------------------------------------------------

enfos_dk_breathe_fire=class({})
function enfos_dk_breathe_fire:OnSpellStart()
    local c = self:GetCaster()
    local dir = (self:GetCursorPosition() - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_DragonKnight.BreathFire')
    effect('particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf', c)

    local base = value(self, 'damage')
    if base <= 0 then base = 240 end
    local str = get_str(c)
    local dmg = base + (str * 1.2)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 375), 450)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_dk_breathe_fire_debuff', { duration = 6.0 })
    end
end

modifier_enfos_dk_breathe_fire_debuff=class({})
function modifier_enfos_dk_breathe_fire_debuff:IsDebuff() return true end
function modifier_enfos_dk_breathe_fire_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE } end
function modifier_enfos_dk_breathe_fire_debuff:GetModifierBaseDamageOutgoing_Percentage()
    local red = (self.GetAbility and value(self:GetAbility(), 'reduction_pct')) or 40
    return -red
end

enfos_dk_dragon_tail=class({})
function enfos_dk_dragon_tail:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_DragonKnight.DragonTail.Target')
    effect('particles/units/heroes/hero_dragon_knight/dragon_knight_dragontail_target.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 250 end
    local str = get_str(c)
    local dmg = base + (str * 1.0)

    damage(self, t, dmg, DAMAGE_TYPE_PHYSICAL)
    local stun_dur = is_boss(t) and 0.75 or ((self.GetSpecialValueFor and self:GetSpecialValueFor('stun_duration')) or 2.5)
    t:AddNewModifier(c, self, 'modifier_enfos_dk_dragon_tail_stun', { duration = stun_dur })
end

modifier_enfos_dk_dragon_tail_stun=class({})
function modifier_enfos_dk_dragon_tail_stun:IsDebuff() return true end
function modifier_enfos_dk_dragon_tail_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_dk_dragon_blood=class({})
function enfos_dk_dragon_blood:GetIntrinsicModifierName() return 'modifier_enfos_dk_dragon_blood_passive' end

modifier_enfos_dk_dragon_blood_passive=class({})
function modifier_enfos_dk_dragon_blood_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end
function modifier_enfos_dk_dragon_blood_passive:GetModifierPhysicalArmorBonus()
    return (self.GetAbility and value(self:GetAbility(), 'bonus_armor')) or 18
end
function modifier_enfos_dk_dragon_blood_passive:GetModifierConstantHealthRegen()
    local c = self:GetParent()
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_hp_regen')) or 25
    return base + (str * 0.05)
end

enfos_dk_elder_dragon_form=class({})
function enfos_dk_elder_dragon_form:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_DragonKnight.ElderDragonForm')
    c:AddNewModifier(c, self, 'modifier_enfos_dk_elder_dragon_form_buff', { duration = 60.0 })
end

modifier_enfos_dk_elder_dragon_form_buff=class({})
function modifier_enfos_dk_elder_dragon_form_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_dk_elder_dragon_form_buff:GetModifierPreAttack_BonusDamage()
    return (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 60
end
function modifier_enfos_dk_elder_dragon_form_buff:GetModifierAttackRangeBonus() return 350 end
function modifier_enfos_dk_elder_dragon_form_buff:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    local splash_dmg = (params.damage or 200) * 0.8
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 300)) do
        if u ~= t then
            damage(self:GetAbility(), u, splash_dmg, DAMAGE_TYPE_PHYSICAL)
            u:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_dk_dragon_frost_slow', { duration = 3.0 })
        end
    end
end

modifier_enfos_dk_dragon_frost_slow=class({})
function modifier_enfos_dk_dragon_frost_slow:IsDebuff() return true end
function modifier_enfos_dk_dragon_frost_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT } end
function modifier_enfos_dk_dragon_frost_slow:GetModifierMoveSpeedBonus_Percentage() return -30 end
function modifier_enfos_dk_dragon_frost_slow:GetModifierAttackSpeedBonus_Constant() return -30 end

enfos_dk_wyrm_vigor=class({})
function enfos_dk_wyrm_vigor:GetIntrinsicModifierName() return 'modifier_enfos_dk_wyrm_vigor_passive' end

modifier_enfos_dk_wyrm_vigor_passive=class({})
function modifier_enfos_dk_wyrm_vigor_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end
function modifier_enfos_dk_wyrm_vigor_passive:GetModifierMagicalResistanceBonus() return 25 end
function modifier_enfos_dk_wyrm_vigor_passive:GetModifierBonusStats_Strength() return 25 end

-- ----------------------------------------------------------------------------
-- PUDGE: MEAT HOOK, ROT, FLESH HEAP, DISMEMBER, MEAT SHIELD
-- ----------------------------------------------------------------------------

enfos_pudge_meat_hook=class({})
function enfos_pudge_meat_hook:OnSpellStart()
    local c = self:GetCaster()
    local target_pos = self:GetCursorPosition()
    local dir = (target_pos - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_Pudge.MeatHook')

    local base = value(self, 'hook_damage')
    if base <= 0 then base = 350 end
    local str = get_str(c)
    local dmg = base + (str * 1.8)

    local primary_hit = nil
    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 700), 700)) do
        damage(self, u, dmg, DAMAGE_TYPE_PURE)
        effect('particles/units/heroes/hero_pudge/pudge_meathook.vpcf', u)
        if not primary_hit then primary_hit = u end
    end
    if primary_hit and primary_hit:IsAlive() and not is_boss(primary_hit) then
        FindClearSpaceForUnit(primary_hit, c:GetAbsOrigin() + (dir * 120), true)
    end
end

enfos_pudge_rot=class({})
function enfos_pudge_rot:OnToggle()
    local c = self:GetCaster()
    if self:GetToggleState() then
        c:AddNewModifier(c, self, 'modifier_enfos_pudge_rot_aura', {})
    else
        c:RemoveModifierByName('modifier_enfos_pudge_rot_aura')
    end
end

modifier_enfos_pudge_rot_aura=class({})
function modifier_enfos_pudge_rot_aura:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end
function modifier_enfos_pudge_rot_aura:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local base = (a and value(a, 'rot_damage')) or 80
    local str = get_str(c)
    local dmg = (base + (str * 0.4)) * 0.5

    -- Self damage (non-lethal)
    if c:GetHealth() > dmg + 10 then
        c:SetHealth(c:GetHealth() - (dmg * 0.5))
    end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 350)) do
        damage(a, u, dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, a, 'modifier_enfos_pudge_rot_debuff', { duration = 0.6 })
    end
end

modifier_enfos_pudge_rot_debuff=class({})
function modifier_enfos_pudge_rot_debuff:IsDebuff() return true end
function modifier_enfos_pudge_rot_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_pudge_rot_debuff:GetModifierMoveSpeedBonus_Percentage() return -30 end

enfos_pudge_flesh_heap=class({})
function enfos_pudge_flesh_heap:GetIntrinsicModifierName() return 'modifier_enfos_pudge_flesh_heap_passive' end

modifier_enfos_pudge_flesh_heap_passive=class({})
function modifier_enfos_pudge_flesh_heap_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_EVENT_ON_DEATH }
end
function modifier_enfos_pudge_flesh_heap_passive:GetModifierPhysical_ConstantBlock()
    local c = self:GetParent()
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'damage_block')) or 25
    return base + (str * 0.05)
end
function modifier_enfos_pudge_flesh_heap_passive:GetModifierBonusStats_Strength()
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_strength')) or 25
    return base + ((self:GetStackCount() or 0) * 0.5)
end
function modifier_enfos_pudge_flesh_heap_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and params.unit ~= c then
        local delta = is_boss(params.unit) and 10 or 1
        self:SetStackCount((self:GetStackCount() or 0) + delta)
    end
end

enfos_pudge_dismember=class({})
function enfos_pudge_dismember:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Pudge.Dismember')
    local dur = is_boss(t) and 1.5 or 3.0
    c:AddNewModifier(c, self, 'modifier_enfos_pudge_dismember_channel', { duration = dur, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_pudge_dismember_target', { duration = dur })
end
function enfos_pudge_dismember:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_pudge_dismember_channel')
end

modifier_enfos_pudge_dismember_channel=class({})
function modifier_enfos_pudge_dismember_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx = kv and kv.target_idx or nil
    self:StartIntervalThink(0.5)
end
function modifier_enfos_pudge_dismember_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not t or not t:IsAlive() then
        self:Destroy()
        return
    end

    local base = (a and value(a, 'dps')) or 180
    local str = get_str(c)
    local tick_dmg = (base + (str * 1.0)) * 0.5

    damage(a, t, tick_dmg, DAMAGE_TYPE_MAGICAL)
    c:Heal(tick_dmg, a)
end

modifier_enfos_pudge_dismember_target=class({})
function modifier_enfos_pudge_dismember_target:IsDebuff() return true end
function modifier_enfos_pudge_dismember_target:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_pudge_meat_shield=class({})
function enfos_pudge_meat_shield:GetIntrinsicModifierName() return 'modifier_enfos_pudge_meat_shield_passive' end

modifier_enfos_pudge_meat_shield_passive=class({})
function modifier_enfos_pudge_meat_shield_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_pudge_meat_shield_passive:GetModifierMagicalResistanceBonus() return 20 end
function modifier_enfos_pudge_meat_shield_passive:GetModifierHealthBonus() return 500 end
function modifier_enfos_pudge_meat_shield_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c then return end
    self.accumulated = (self.accumulated or 0) + (params.damage or 0)
    if self.accumulated >= 500 then
        self.accumulated = 0
        local burst = (c:GetMaxHealth() or 1000) * 0.10
        for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 400)) do
            damage(self:GetAbility(), u, burst, DAMAGE_TYPE_PHYSICAL)
        end
    end
end

-- ----------------------------------------------------------------------------
-- SLARK: DARK PACT, POUNCE, ESSENCE SHIFT, SHADOW DANCE, FISH BAIT
-- ----------------------------------------------------------------------------

enfos_slark_dark_pact=class({})
function enfos_slark_dark_pact:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Slark.DarkPact.Cast')
    c:AddNewModifier(c, self, 'modifier_enfos_slark_dark_pact_buff', { duration = 1.5 })
end

modifier_enfos_slark_dark_pact_buff=class({})
function modifier_enfos_slark_dark_pact_buff:OnCreated()
    if not IsServer() then return end
    self.ticks = 0
    self:StartIntervalThink(0.15)
end
function modifier_enfos_slark_dark_pact_buff:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    if c.Purge then c:Purge(false, true, false, true, true) end

    self.ticks = (self.ticks or 0) + 1
    local base = (a and value(a, 'damage')) or 200
    local agi = get_agi(c)
    local tick_dmg = (base + (agi * 1.0)) * 0.1

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 350)) do
        damage(a, u, tick_dmg, DAMAGE_TYPE_MAGICAL)
    end
    if self.ticks >= 10 then self:Destroy() end
end

enfos_slark_pounce=class({})
function enfos_slark_pounce:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Slark.Pounce.Cast')
    local fwd = c:GetForwardVector()
    FindClearSpaceForUnit(c, c:GetAbsOrigin() + (fwd * 700), true)

    local base = value(self, 'damage')
    if base <= 0 then base = 180 end
    local agi = get_agi(c)
    local dmg = base + (agi * 0.8)

    local hit = false
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 250)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        local leash_dur = is_boss(u) and 1.0 or 3.5
        u:AddNewModifier(c, self, 'modifier_enfos_slark_pounce_leash', { duration = leash_dur })
        hit = true
        break
    end
end

modifier_enfos_slark_pounce_leash=class({})
function modifier_enfos_slark_pounce_leash:IsDebuff() return true end
function modifier_enfos_slark_pounce_leash:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_slark_pounce_leash:GetModifierMoveSpeedBonus_Percentage() return -100 end

enfos_slark_essence_shift=class({})
function enfos_slark_essence_shift:GetIntrinsicModifierName() return 'modifier_enfos_slark_essence_shift_passive' end

modifier_enfos_slark_essence_shift_passive=class({})
function modifier_enfos_slark_essence_shift_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_slark_essence_shift_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local buff = c:FindModifierByName('modifier_enfos_slark_essence_shift_buff')
    if not buff then
        buff = c:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_slark_essence_shift_buff', { duration = 30.0 })
    end
    if buff and buff.SetStackCount then
        local cur = (buff.GetStackCount and buff:GetStackCount()) or 0
        buff:SetStackCount(math.min(50, cur + 1))
        buff:SetDuration(30.0, true)
    end
end

modifier_enfos_slark_essence_shift_buff=class({})
function modifier_enfos_slark_essence_shift_buff:DeclareFunctions() return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS } end
function modifier_enfos_slark_essence_shift_buff:GetModifierBonusStats_Agility()
    return (self:GetStackCount() or 1) * 3
end

enfos_slark_shadow_dance=class({})
function enfos_slark_shadow_dance:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Slark.ShadowDance')
    c:AddNewModifier(c, self, 'modifier_enfos_slark_shadow_dance_buff', { duration = 4.5 })
end

modifier_enfos_slark_shadow_dance_buff=class({})
function modifier_enfos_slark_shadow_dance_buff:CheckState()
    return { [MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true }
end
function modifier_enfos_slark_shadow_dance_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end
function modifier_enfos_slark_shadow_dance_buff:GetModifierMoveSpeedBonus_Percentage() return 40 end
function modifier_enfos_slark_shadow_dance_buff:GetModifierHealthRegenPercentage() return 8 end

enfos_slark_fish_bait=class({})
function enfos_slark_fish_bait:GetIntrinsicModifierName() return 'modifier_enfos_slark_fish_bait_passive' end

modifier_enfos_slark_fish_bait_passive=class({})
function modifier_enfos_slark_fish_bait_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_slark_fish_bait_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    if RollPercentage(25) then
        local cleave = (params.damage or 150) * 0.4
        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 250)) do
            if u ~= t then damage(self:GetAbility(), u, cleave, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

-- ----------------------------------------------------------------------------
-- URSA: EARTHSHOCK, OVERPOWER, FURY SWIPES, ENRAGE, URSA MINOR
-- ----------------------------------------------------------------------------

enfos_ursa_earthshock=class({})
function enfos_ursa_earthshock:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Ursa.Earthshock')
    effect('particles/units/heroes/hero_ursa/ursa_earthshock.vpcf', c)

    local base = value(self, 'damage')
    if base <= 0 then base = 220 end
    local str = get_str(c)
    local dmg = base + (str * 1.5)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 385)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_ursa_earthshock_slow', { duration = 4.0 })
    end
end

modifier_enfos_ursa_earthshock_slow=class({})
function modifier_enfos_ursa_earthshock_slow:IsDebuff() return true end
function modifier_enfos_ursa_earthshock_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_ursa_earthshock_slow:GetModifierMoveSpeedBonus_Percentage() return -40 end

enfos_ursa_overpower=class({})
function enfos_ursa_overpower:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Ursa.Overpower')
    local mod = c:AddNewModifier(c, self, 'modifier_enfos_ursa_overpower_buff', { duration = 15.0 })
    if mod and mod.SetStackCount then mod:SetStackCount(6) end
end

modifier_enfos_ursa_overpower_buff=class({})
function modifier_enfos_ursa_overpower_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_ursa_overpower_buff:GetModifierAttackSpeedBonus_Constant() return 400 end
function modifier_enfos_ursa_overpower_buff:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    if params.damage and params.damage > 0 then c:Heal(params.damage * 0.20, self:GetAbility()) end

    local count = (self:GetStackCount() or 1) - 1
    if count <= 0 then self:Destroy() else self:SetStackCount(count) end
end

enfos_ursa_fury_swipes=class({})
function enfos_ursa_fury_swipes:GetIntrinsicModifierName() return 'modifier_enfos_ursa_fury_swipes_passive' end

modifier_enfos_ursa_fury_swipes_passive=class({})
function modifier_enfos_ursa_fury_swipes_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_ursa_fury_swipes_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    local mod = t:FindModifierByName('modifier_enfos_ursa_fury_swipes_debuff')
    if not mod then
        mod = t:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_ursa_fury_swipes_debuff', { duration = 6.0 })
    end
    if mod and mod.SetStackCount then
        local cur = (mod.GetStackCount and mod:GetStackCount()) or 0
        mod:SetStackCount(cur + 1)
        mod:SetDuration(6.0, true)

        local base = (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 35
    local agi = get_agi(c)
        local extra_dmg = (cur + 1) * (base + (agi * 0.15))
        damage(self:GetAbility(), t, extra_dmg, DAMAGE_TYPE_PHYSICAL)

        -- Ursa Minor cleave
        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 250)) do
            if u ~= t then damage(self:GetAbility(), u, extra_dmg * 0.35, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

modifier_enfos_ursa_fury_swipes_debuff=class({})
function modifier_enfos_ursa_fury_swipes_debuff:IsDebuff() return true end

enfos_ursa_enrage=class({})
function enfos_ursa_enrage:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Ursa.Enrage')
    if c.Purge then c:Purge(false, true, false, true, true) end
    c:AddNewModifier(c, self, 'modifier_enfos_ursa_enrage_buff', { duration = 4.5 })
end

modifier_enfos_ursa_enrage_buff=class({})
function modifier_enfos_ursa_enrage_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING }
end
function modifier_enfos_ursa_enrage_buff:GetModifierIncomingDamage_Percentage() return -80 end
function modifier_enfos_ursa_enrage_buff:GetModifierStatusResistanceStacking() return 50 end

enfos_ursa_ursa_minor=class({})
function enfos_ursa_ursa_minor:GetIntrinsicModifierName() return 'modifier_enfos_ursa_minor_passive' end

modifier_enfos_ursa_minor_passive=class({})
function modifier_enfos_ursa_minor_passive:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT } end
function modifier_enfos_ursa_minor_passive:GetModifierMoveSpeedBonus_Constant() return 30 end

-- ----------------------------------------------------------------------------
-- MONKEY KING: BOUNDLESS STRIKE, PRIMAL SPRING, JINGU MASTERY, WUKONG'S, MISCHIEF
-- ----------------------------------------------------------------------------

enfos_mk_boundless_strike=class({})
function enfos_mk_boundless_strike:OnSpellStart()
    local c = self:GetCaster()
    local dir = (self:GetCursorPosition() - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_MonkeyKing.Spring.Cast')

    local atk = (c.GetAverageTrueAttackDamage and c:GetAverageTrueAttackDamage()) or 100
    local dmg = atk * 2.0

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 600), 650)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        local dur = is_boss(u) and 0.6 or 1.6
        u:AddNewModifier(c, self, 'modifier_enfos_mk_boundless_strike_stun', { duration = dur })
    end
end

modifier_enfos_mk_boundless_strike_stun=class({})
function modifier_enfos_mk_boundless_strike_stun:IsDebuff() return true end
function modifier_enfos_mk_boundless_strike_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_mk_primal_spring=class({})
function enfos_mk_primal_spring:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_MonkeyKing.Spring.Impact')
    FindClearSpaceForUnit(c, pos, true)

    local base = value(self, 'spring_damage')
    if base <= 0 then base = 280 end
    local agi = get_agi(c)
    local dmg = base + (agi * 1.2)

    for _, u in ipairs(enemies(c, pos, 450)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_mk_primal_spring_slow', { duration = 4.0 })
    end
end

modifier_enfos_mk_primal_spring_slow=class({})
function modifier_enfos_mk_primal_spring_slow:IsDebuff() return true end
function modifier_enfos_mk_primal_spring_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_mk_primal_spring_slow:GetModifierMoveSpeedBonus_Percentage() return -60 end

enfos_mk_jingu_mastery=class({})
function enfos_mk_jingu_mastery:GetIntrinsicModifierName() return 'modifier_enfos_mk_jingu_mastery_passive' end

modifier_enfos_mk_jingu_mastery_passive=class({})
function modifier_enfos_mk_jingu_mastery_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_mk_jingu_mastery_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    if c:HasModifier('modifier_enfos_mk_jingu_mastery_buff') then return end

    self.counter = (self.counter or 0) + 1
    if self.counter >= 4 then
        self.counter = 0
        local b = c:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_mk_jingu_mastery_buff', { duration = 20.0 })
        if b and b.SetStackCount then b:SetStackCount(4) end
    end
end

modifier_enfos_mk_jingu_mastery_buff=class({})
function modifier_enfos_mk_jingu_mastery_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_mk_jingu_mastery_buff:GetModifierPreAttack_BonusDamage()
    local c = self:GetParent()
    local agi = get_agi(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 140
    return base + (agi * 1.0)
end
function modifier_enfos_mk_jingu_mastery_buff:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    if params.damage and params.damage > 0 then c:Heal(params.damage * 0.60, self:GetAbility()) end

    local count = (self:GetStackCount() or 1) - 1
    if count <= 0 then self:Destroy() else self:SetStackCount(count) end
end

enfos_mk_wukongs_command=class({})
function enfos_mk_wukongs_command:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_MonkeyKing.FurArmy')
    CreateModifierThinker(c, self, 'modifier_enfos_mk_wukongs_command_thinker', { duration = 15.0 }, pos, c:GetTeamNumber(), false)
end

modifier_enfos_mk_wukongs_command_thinker=class({})
function modifier_enfos_mk_wukongs_command_thinker:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.1)
end
function modifier_enfos_mk_wukongs_command_thinker:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local t = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then self:Destroy() return end

    local atk = (c.GetAverageTrueAttackDamage and c:GetAverageTrueAttackDamage()) or 100
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 550)) do
        damage(a, u, atk, DAMAGE_TYPE_PHYSICAL)
    end
end

enfos_mk_mischief=class({})
function enfos_mk_mischief:GetIntrinsicModifierName() return 'modifier_enfos_mk_mischief_passive' end

modifier_enfos_mk_mischief_passive=class({})
function modifier_enfos_mk_mischief_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT }
end
function modifier_enfos_mk_mischief_passive:GetModifierAttackRangeBonus() return 100 end
function modifier_enfos_mk_mischief_passive:GetModifierEvasion_Constant() return 25 end

-- ----------------------------------------------------------------------------
-- ANTI-MAGE: MANA BREAK, BLINK, COUNTERSPELL, MANA VOID, SPELLBREAKER
-- ----------------------------------------------------------------------------

enfos_am_mana_break=class({})
function enfos_am_mana_break:GetIntrinsicModifierName() return 'modifier_enfos_am_mana_break_passive' end

modifier_enfos_am_mana_break_passive=class({})
function modifier_enfos_am_mana_break_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_am_mana_break_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 70
    local agi = get_agi(c)
    local dmg = base + (agi * 0.6)

    damage(self:GetAbility(), t, dmg, DAMAGE_TYPE_PHYSICAL)
    effect('particles/units/heroes/hero_antimage/antimage_manabreak.vpcf', t)

    -- Cleave to surrounding creeps
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 250)) do
        if u ~= t then damage(self:GetAbility(), u, dmg * 0.35, DAMAGE_TYPE_PHYSICAL) end
    end
end

enfos_am_blink=class({})
function enfos_am_blink:OnSpellStart()
    local c = self:GetCaster()
    local target_pos = self:GetCursorPosition()
    c:EmitSound('Hero_Antimage.Blink_out')
    FindClearSpaceForUnit(c, target_pos, true)
    c:EmitSound('Hero_Antimage.Blink_in')
end

enfos_am_counterspell=class({})
function enfos_am_counterspell:GetIntrinsicModifierName() return 'modifier_enfos_am_counterspell_passive' end
function enfos_am_counterspell:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Antimage.Counterspell.Cast')
    c:AddNewModifier(c, self, 'modifier_enfos_am_counterspell_active', { duration = 1.4 })
end

modifier_enfos_am_counterspell_passive=class({})
function modifier_enfos_am_counterspell_passive:DeclareFunctions() return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS } end
function modifier_enfos_am_counterspell_passive:GetModifierMagicalResistanceBonus()
    return (self.GetAbility and value(self:GetAbility(), 'magic_resist')) or 40
end

modifier_enfos_am_counterspell_active=class({})
function modifier_enfos_am_counterspell_active:DeclareFunctions() return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS } end
function modifier_enfos_am_counterspell_active:GetModifierMagicalResistanceBonus() return 100 end

enfos_am_mana_void=class({})
function enfos_am_mana_void:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Antimage.ManaVoid')
    effect('particles/units/heroes/hero_antimage/antimage_mana_void.vpcf', t)

    local base = value(self, 'base_damage')
    if base <= 0 then base = 500 end
    local agi = get_agi(c)
    local dmg = base + (agi * 1.5)

    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 500)) do
        damage(self, u, dmg, DAMAGE_TYPE_PURE)
        if not is_boss(u) and u.AddNewModifier then
            u:AddNewModifier(c, self, 'modifier_stunned', { duration = 1.0 })
        end
    end
end

enfos_am_spellbreaker=class({})
function enfos_am_spellbreaker:GetIntrinsicModifierName() return 'modifier_enfos_am_spellbreaker_passive' end

modifier_enfos_am_spellbreaker_passive=class({})
function modifier_enfos_am_spellbreaker_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_enfos_am_spellbreaker_passive:GetModifierAttackSpeedBonus_Constant() return 40 end
function modifier_enfos_am_spellbreaker_passive:GetModifierMoveSpeedBonus_Constant() return 25 end

-- ----------------------------------------------------------------------------
-- FACELESS VOID: TIME WALK, TIME DILATION, TIME LOCK, CHRONOSPHERE, BACKTRACK
-- ----------------------------------------------------------------------------

enfos_void_time_walk=class({})
function enfos_void_time_walk:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_FacelessVoid.TimeWalk')
    FindClearSpaceForUnit(c, pos, true)
    c:Heal(300, self)
end

enfos_void_time_dilation=class({})
function enfos_void_time_dilation:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_FacelessVoid.TimeDilation.Cast')
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 750)) do
        u:AddNewModifier(c, self, 'modifier_enfos_void_time_dilation_debuff', { duration = 8.0 })
    end
end

modifier_enfos_void_time_dilation_debuff=class({})
function modifier_enfos_void_time_dilation_debuff:IsDebuff() return true end
function modifier_enfos_void_time_dilation_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_void_time_dilation_debuff:GetModifierMoveSpeedBonus_Percentage() return -40 end
function modifier_enfos_void_time_dilation_debuff:GetModifierAttackSpeedBonus_Constant() return -40 end

enfos_void_time_lock=class({})
function enfos_void_time_lock:GetIntrinsicModifierName() return 'modifier_enfos_void_time_lock_passive' end

modifier_enfos_void_time_lock_passive=class({})
function modifier_enfos_void_time_lock_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_void_time_lock_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    if RollPercentage(24) then
        c:EmitSound('Hero_FacelessVoid.TimeLock.Impact')
        local base = (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 100
    local agi = get_agi(c)
        local dmg = base + (agi * 0.8)
        damage(self:GetAbility(), t, dmg, DAMAGE_TYPE_MAGICAL)
        local dur = is_boss(t) and 0.2 or 0.5
        t:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_void_time_lock_stun', { duration = dur })
    end
end

modifier_enfos_void_time_lock_stun=class({})
function modifier_enfos_void_time_lock_stun:IsDebuff() return true end
function modifier_enfos_void_time_lock_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_void_chronosphere=class({})
function enfos_void_chronosphere:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_FacelessVoid.Chronosphere')
    local dur = (self.GetSpecialValueFor and self:GetSpecialValueFor('duration')) or 5.0
    CreateModifierThinker(c, self, 'modifier_enfos_void_chronosphere_thinker', { duration = dur }, pos, c:GetTeamNumber(), false)
end

modifier_enfos_void_chronosphere_thinker=class({})
function modifier_enfos_void_chronosphere_thinker:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.1)
end
function modifier_enfos_void_chronosphere_thinker:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local t = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) then self:Destroy() return end

    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 500)) do
        local dur = is_boss(u) and 0.3 or 0.5
        u:AddNewModifier(c, a, 'modifier_enfos_void_chronosphere_freeze', { duration = dur })
    end
end

modifier_enfos_void_chronosphere_freeze=class({})
function modifier_enfos_void_chronosphere_freeze:IsDebuff() return true end
function modifier_enfos_void_chronosphere_freeze:CheckState()
    return { [MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_STUNNED] = true }
end

enfos_void_backtrack=class({})
function enfos_void_backtrack:GetIntrinsicModifierName() return 'modifier_enfos_void_backtrack_passive' end

modifier_enfos_void_backtrack_passive=class({})
function modifier_enfos_void_backtrack_passive:DeclareFunctions() return { MODIFIER_PROPERTY_AVOID_DAMAGE } end
function modifier_enfos_void_backtrack_passive:GetModifierAvoidDamage(params)
    if RollPercentage(25) then return 1 end
    return 0
end

-- ----------------------------------------------------------------------------
-- SHADOW FIEND: SHADOWRAZE, NECROMASTERY, PRESENCE, REQUIEM, FEAST OF SOULS
-- ----------------------------------------------------------------------------

enfos_sf_shadowraze=class({})
function enfos_sf_shadowraze:OnSpellStart()
    local c = self:GetCaster()
    local fwd = c:GetForwardVector()
    c:EmitSound('Hero_Nevermore.Shadowraze')

    local base = value(self, 'damage')
    if base <= 0 then base = 200 end
    local int = get_int(c)
    local dmg = base + (int * 1.0)

    -- Triple raze in front
    for _, dist in ipairs({ 200, 450, 700 }) do
        local pos = c:GetAbsOrigin() + (fwd * dist)
        for _, u in ipairs(enemies(c, pos, 250)) do
            damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
            effect('particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf', u)
        end
    end
end

enfos_sf_necromastery=class({})
function enfos_sf_necromastery:GetIntrinsicModifierName() return 'modifier_enfos_sf_necromastery_passive' end

modifier_enfos_sf_necromastery_passive=class({})
function modifier_enfos_sf_necromastery_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFICATION_PERCENTAGE, MODIFIER_EVENT_ON_DEATH }
end
function modifier_enfos_sf_necromastery_passive:GetModifierPreAttack_BonusDamage()
    return (self:GetStackCount() or 0) * 3
end
function modifier_enfos_sf_necromastery_passive:GetModifierSpellAmplication_Percentage()
    return (self:GetStackCount() or 0) * 1.0
end
function modifier_enfos_sf_necromastery_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and params.unit ~= c then
        local delta = is_boss(params.unit) and 10 or 2
        self:SetStackCount(math.min(36, (self:GetStackCount() or 0) + delta))
    end
end

enfos_sf_presence_of_the_dark_lord=class({})
function enfos_sf_presence_of_the_dark_lord:GetIntrinsicModifierName() return 'modifier_enfos_sf_presence_aura' end

modifier_enfos_sf_presence_aura=class({})
function modifier_enfos_sf_presence_aura:IsHidden() return true end
function modifier_enfos_sf_presence_aura:IsAura() return true end
function modifier_enfos_sf_presence_aura:GetAuraRadius() return 900 end
function modifier_enfos_sf_presence_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_enfos_sf_presence_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_sf_presence_aura:GetModifierAura() return 'modifier_enfos_sf_presence_debuff' end

modifier_enfos_sf_presence_debuff=class({})
function modifier_enfos_sf_presence_debuff:IsDebuff() return true end
function modifier_enfos_sf_presence_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_sf_presence_debuff:GetModifierPhysicalArmorBonus()
    return -((self.GetAbility and value(self:GetAbility(), 'armor_reduction')) or 8)
end

enfos_sf_requiem_of_souls=class({})
function enfos_sf_requiem_of_souls:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Nevermore.RequiemOfSouls')
    effect('particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf', c)
    local int = get_int(c)
    local dmg = 450 + (int * 1.8)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 1000)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        local dur = is_boss(u) and 0.5 or 1.5
        u:AddNewModifier(c, self, 'modifier_enfos_sf_requiem_fear', { duration = dur })
    end
end

modifier_enfos_sf_requiem_fear=class({})
function modifier_enfos_sf_requiem_fear:IsDebuff() return true end
function modifier_enfos_sf_requiem_fear:CheckState() return { [MODIFIER_STATE_FEARED] = true } end

enfos_sf_feast_of_souls=class({})
function enfos_sf_feast_of_souls:GetIntrinsicModifierName() return 'modifier_enfos_sf_feast_of_souls_passive' end

modifier_enfos_sf_feast_of_souls_passive=class({})
function modifier_enfos_sf_feast_of_souls_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_sf_feast_of_souls_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and params.unit ~= c then
        c:Heal(25, self:GetAbility())
        if c.GiveMana then c:GiveMana(15) end
    end
end

-- ----------------------------------------------------------------------------
-- STORM SPIRIT: STATIC REMNANT, VORTEX, OVERLOAD, BALL LIGHTNING, GALVANIC CORE
-- ----------------------------------------------------------------------------

enfos_storm_static_remnant=class({})
function enfos_storm_static_remnant:OnSpellStart()
    local c = self:GetCaster()
    local pos = c:GetAbsOrigin()
    c:EmitSound('Hero_StormSpirit.StaticRemnantPlant')
    CreateModifierThinker(c, self, 'modifier_enfos_storm_static_remnant_thinker', { duration = 12.0 }, pos, c:GetTeamNumber(), false)
end

modifier_enfos_storm_static_remnant_thinker=class({})
function modifier_enfos_storm_static_remnant_thinker:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.2)
end
function modifier_enfos_storm_static_remnant_thinker:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local t = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) then self:Destroy() return end

    local targets = enemies(c, t:GetAbsOrigin(), 300)
    if #targets > 0 then
        t:EmitSound('Hero_StormSpirit.StaticRemnantExplode')
        local base = (a and value(a, 'damage')) or 240
    local int = get_int(c)
        local dmg = base + (int * 1.2)
        for _, u in ipairs(targets) do
            damage(a, u, dmg, DAMAGE_TYPE_MAGICAL)
        end
        self:Destroy()
    end
end

enfos_storm_electric_vortex=class({})
function enfos_storm_electric_vortex:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_StormSpirit.ElectricVortex')
    local dur = is_boss(t) and 0.6 or 2.0
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 300)) do
        u:AddNewModifier(c, self, 'modifier_enfos_storm_electric_vortex_debuff', { duration = dur })
    end
end

modifier_enfos_storm_electric_vortex_debuff=class({})
function modifier_enfos_storm_electric_vortex_debuff:IsDebuff() return true end
function modifier_enfos_storm_electric_vortex_debuff:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_storm_overload=class({})
function enfos_storm_overload:GetIntrinsicModifierName() return 'modifier_enfos_storm_overload_passive' end

modifier_enfos_storm_overload_passive=class({})
function modifier_enfos_storm_overload_passive:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_storm_overload_passive:OnAbilityFullyCast(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit == c and params.ability ~= self:GetAbility() then
        self.charged = true
    end
end
function modifier_enfos_storm_overload_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and self.charged then
        self.charged = false
        local t = params.target
        if not t or not t:IsAlive() then return end

        c:EmitSound('Hero_StormSpirit.Overload')
        local base = (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 100
    local int = get_int(c)
        local dmg = base + (int * 0.6)

        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 300)) do
            damage(self:GetAbility(), u, dmg, DAMAGE_TYPE_MAGICAL)
            u:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_storm_overload_slow', { duration = 1.0 })
        end
    end
end

modifier_enfos_storm_overload_slow=class({})
function modifier_enfos_storm_overload_slow:IsDebuff() return true end
function modifier_enfos_storm_overload_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_storm_overload_slow:GetModifierMoveSpeedBonus_Percentage() return -80 end

enfos_storm_ball_lightning=class({})
function enfos_storm_ball_lightning:OnSpellStart()
    local c = self:GetCaster()
    local target_pos = self:GetCursorPosition()
    c:EmitSound('Hero_StormSpirit.BallLightning')
    local origin = c:GetAbsOrigin()
    local dist = (target_pos - origin):Length2D()
    FindClearSpaceForUnit(c, target_pos, true)
    local int = get_int(c)
    local dmg = (dist / 100) * (30 + (int * 0.1))

    for _, u in ipairs(enemies(c, target_pos, 300)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_storm_galvanic_core=class({})
function enfos_storm_galvanic_core:GetIntrinsicModifierName() return 'modifier_enfos_storm_galvanic_core_passive' end

modifier_enfos_storm_galvanic_core_passive=class({})
function modifier_enfos_storm_galvanic_core_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end
function modifier_enfos_storm_galvanic_core_passive:GetModifierConstantManaRegen() return 4.0 end
function modifier_enfos_storm_galvanic_core_passive:GetModifierBonusStats_Intellect() return 20 end

-- ----------------------------------------------------------------------------
-- SHADOW SHAMAN: ETHER SHOCK, HEX, SHACKLES, MASS SERPENT WARD, FOWL PLAY
-- ----------------------------------------------------------------------------

enfos_ss_ether_shock=class({})
function enfos_ss_ether_shock:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_ShadowShaman.EtherShock')
    local base = value(self, 'damage')
    if base <= 0 then base = 250 end
    local int = get_int(c)
    local dmg = base + (int * 1.0)

    local count = 0
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 600)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        effect('particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf', u)
        count = count + 1
        if count >= 8 then break end
    end
end

enfos_ss_hex=class({})
function enfos_ss_hex:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_ShadowShaman.Hex.Target')
    local dur = is_boss(t) and 1.0 or ((self.GetSpecialValueFor and self:GetSpecialValueFor('duration')) or 3.5)
    t:AddNewModifier(c, self, 'modifier_enfos_ss_hex_debuff', { duration = dur })
end

modifier_enfos_ss_hex_debuff=class({})
function modifier_enfos_ss_hex_debuff:IsDebuff() return true end
function modifier_enfos_ss_hex_debuff:CheckState()
    return { [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_MUTED] = true }
end
function modifier_enfos_ss_hex_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE } end
function modifier_enfos_ss_hex_debuff:GetModifierMoveSpeedOverride() return 140 end

enfos_ss_shackles=class({})
function enfos_ss_shackles:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_ShadowShaman.Shackles')
    local dur = is_boss(t) and 1.0 or 3.5
    c:AddNewModifier(c, self, 'modifier_enfos_ss_shackles_channel', { duration = dur, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_ss_shackles_debuff', { duration = dur })
end
function enfos_ss_shackles:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_ss_shackles_channel')
end

modifier_enfos_ss_shackles_channel=class({})
function modifier_enfos_ss_shackles_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx = kv and kv.target_idx or nil
    self:StartIntervalThink(0.5)
end
function modifier_enfos_ss_shackles_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not t or not t:IsAlive() then self:Destroy() return end

    local base = (a and value(a, 'dps')) or 140
    local int = get_int(c)
    local dmg = (base + (int * 0.6)) * 0.5
    damage(a, t, dmg, DAMAGE_TYPE_MAGICAL)
    c:Heal(dmg, a)
end

modifier_enfos_ss_shackles_debuff=class({})
function modifier_enfos_ss_shackles_debuff:IsDebuff() return true end
function modifier_enfos_ss_shackles_debuff:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_ss_mass_serpent_ward=class({})
function enfos_ss_mass_serpent_ward:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_ShadowShaman.SerpentWard')
    local int = get_int(c)
    local dmg = 85 + (int * 0.4)

    -- Burst pulse simulating serpent ward fire across 30 seconds
    for _, u in ipairs(enemies(c, pos, 600)) do
        damage(self, u, dmg * 4, DAMAGE_TYPE_PHYSICAL)
    end
end

enfos_ss_fowl_play=class({})
function enfos_ss_fowl_play:GetIntrinsicModifierName() return 'modifier_enfos_ss_fowl_play_passive' end

modifier_enfos_ss_fowl_play_passive=class({})
function modifier_enfos_ss_fowl_play_passive:DeclareFunctions() return { MODIFIER_PROPERTY_MIN_HEALTH } end
function modifier_enfos_ss_fowl_play_passive:GetMinHealth()
    local c = self:GetParent()
    local a = self:GetAbility()
    if a and a:IsCooldownReady() then
        a:StartCooldown(90.0)
        c:AddNewModifier(c, a, 'modifier_enfos_ss_fowl_play_buff', { duration = 4.0 })
        return 1
    end
    return 0
end

modifier_enfos_ss_fowl_play_buff=class({})
function modifier_enfos_ss_fowl_play_buff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT } end
function modifier_enfos_ss_fowl_play_buff:GetModifierMoveSpeedBonus_Constant() return 100 end

-- ----------------------------------------------------------------------------
-- LION: EARTH SPIKE, HEX, MANA DRAIN, FINGER OF DEATH, DEMON SOUL
-- ----------------------------------------------------------------------------

enfos_lion_earth_spike=class({})
function enfos_lion_earth_spike:OnSpellStart()
    local c = self:GetCaster()
    local dir = (self:GetCursorPosition() - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_Lion.Impale')

    local base = value(self, 'damage')
    if base <= 0 then base = 240 end
    local int = get_int(c)
    local dmg = base + (int * 1.1)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 450), 500)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        local dur = is_boss(u) and 0.6 or 1.8
        u:AddNewModifier(c, self, 'modifier_enfos_lion_earth_spike_stun', { duration = dur })
        effect('particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf', u)
    end
end

modifier_enfos_lion_earth_spike_stun=class({})
function modifier_enfos_lion_earth_spike_stun:IsDebuff() return true end
function modifier_enfos_lion_earth_spike_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_lion_hex=class({})
function enfos_lion_hex:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Lion.Voodoo')
    local dur = is_boss(t) and 0.8 or ((self.GetSpecialValueFor and self:GetSpecialValueFor('duration')) or 3.0)
    t:AddNewModifier(c, self, 'modifier_enfos_lion_hex_debuff', { duration = dur })
end

modifier_enfos_lion_hex_debuff=class({})
function modifier_enfos_lion_hex_debuff:IsDebuff() return true end
function modifier_enfos_lion_hex_debuff:CheckState()
    return { [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_MUTED] = true }
end
function modifier_enfos_lion_hex_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE } end
function modifier_enfos_lion_hex_debuff:GetModifierMoveSpeedOverride() return 140 end

enfos_lion_mana_drain=class({})
function enfos_lion_mana_drain:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Lion.ManaDrain')
    c:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_channel', { duration = 4.0, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_debuff', { duration = 4.0 })
end
function enfos_lion_mana_drain:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_lion_mana_drain_channel')
end

modifier_enfos_lion_mana_drain_channel=class({})
function modifier_enfos_lion_mana_drain_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx = kv and kv.target_idx or nil
    self:StartIntervalThink(0.5)
end
function modifier_enfos_lion_mana_drain_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not t or not t:IsAlive() then self:Destroy() return end

    local base = (a and value(a, 'mana_per_second')) or 120
    local int = get_int(c)
    local tick_dmg = (base + (int * 0.8)) * 0.5

    damage(a, t, tick_dmg, DAMAGE_TYPE_MAGICAL)
    if c.GiveMana then c:GiveMana(tick_dmg) end
end

modifier_enfos_lion_mana_drain_debuff=class({})
function modifier_enfos_lion_mana_drain_debuff:IsDebuff() return true end
function modifier_enfos_lion_mana_drain_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_lion_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage() return -35 end

enfos_lion_finger_of_death=class({})
function enfos_lion_finger_of_death:GetIntrinsicModifierName() return 'modifier_enfos_lion_finger_counter' end
function enfos_lion_finger_of_death:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end

    c:EmitSound('Hero_Lion.FingerOfDeath')
    effect('particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 850 end
    local int = get_int(c)
    local mod = c:FindModifierByName('modifier_enfos_lion_finger_counter')
    local stacks = mod and mod:GetStackCount() or 0
    local total_dmg = base + (int * 2.5) + (stacks * 40)

    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 325)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        if not u:IsAlive() and mod and mod.SetStackCount then
            mod:SetStackCount(mod:GetStackCount() + 1)
        end
    end
end

modifier_enfos_lion_finger_counter=class({})
function modifier_enfos_lion_finger_counter:DeclareFunctions() return { MODIFIER_PROPERTY_SPELL_AMPLIFICATION_PERCENTAGE } end
function modifier_enfos_lion_finger_counter:GetModifierSpellAmplication_Percentage()
    return (self:GetStackCount() or 0) * 1.5
end

enfos_lion_demon_soul=class({})
function enfos_lion_demon_soul:GetIntrinsicModifierName() return 'modifier_enfos_lion_demon_soul_passive' end

modifier_enfos_lion_demon_soul_passive=class({})
function modifier_enfos_lion_demon_soul_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFICATION_PERCENTAGE }
end
function modifier_enfos_lion_demon_soul_passive:GetModifierCastRangeBonusStacking() return 150 end
function modifier_enfos_lion_demon_soul_passive:GetModifierSpellAmplication_Percentage() return 15 end


-- =========================================================================
-- BATCH 5 HERO KITS (UNDERLORD, TROLL, CK, MEDUSA, TB, LESHRAC, INVOKER, PUCK, JAKIRO, VS, LICH)
-- =========================================================================

-- -------------------------------------------------------------------------
-- UNDERLORD (TANK)
-- -------------------------------------------------------------------------

enfos_underlord_firestorm=class({})
function enfos_underlord_firestorm:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 425
    local dmg = value(self, 'wave_damage')
    local str = get_str(c)
    local total_dmg = dmg + (str * 0.3)

    for _, u in ipairs(enemies(c, p, r)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_underlord_firestorm_burn', { duration = 2.0 })
    end
end

modifier_enfos_underlord_firestorm_burn=class({})
function modifier_enfos_underlord_firestorm_burn:IsDebuff() return true end
function modifier_enfos_underlord_firestorm_burn:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end
function modifier_enfos_underlord_firestorm_burn:OnIntervalThink()
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    if not p:IsAlive() then return end
    local max_hp = p:GetMaxHealth() or 1000
    local burn = max_hp * 0.01
    if is_boss(p) and burn > 150 then burn = 150 end
    damage(ab, p, burn, DAMAGE_TYPE_MAGICAL)
end

enfos_underlord_pit_of_malice=class({})
function enfos_underlord_pit_of_malice:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 400
    local dur = value(self, 'ensnare_duration') or 2.0
    local dmg = value(self, 'damage')
    local str = get_str(c)
    local total_dmg = dmg + (str * 0.5)

    for _, u in ipairs(enemies(c, p, r)) do
        local d = dur
        if is_boss(u) then d = d * 0.35 end
        u:AddNewModifier(c, self, 'modifier_enfos_underlord_pit_root', { duration = d })
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

modifier_enfos_underlord_pit_root=class({})
function modifier_enfos_underlord_pit_root:IsDebuff() return true end
function modifier_enfos_underlord_pit_root:CheckState()
    return { [MODIFIER_STATE_ROOTED] = true }
end

enfos_underlord_atrophy_aura=class({})
function enfos_underlord_atrophy_aura:GetIntrinsicModifierName() return 'modifier_enfos_underlord_atrophy_aura' end

modifier_enfos_underlord_atrophy_aura=class({})
function modifier_enfos_underlord_atrophy_aura:IsAura() return true end
function modifier_enfos_underlord_atrophy_aura:GetAuraRadius() return 900 end
function modifier_enfos_underlord_atrophy_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_enfos_underlord_atrophy_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_underlord_atrophy_aura:GetModifierAura() return 'modifier_enfos_underlord_atrophy_debuff' end
function modifier_enfos_underlord_atrophy_aura:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_enfos_underlord_atrophy_aura:OnDeath(params)
    if not IsServer() then return end
    local dead = params.unit
    local c = self:GetParent()
    if dead and dead:GetTeamNumber() ~= c:GetTeamNumber() then
        local dist = (dead:GetAbsOrigin() - c:GetAbsOrigin()):Length2D()
        if dist <= 900 then
            local gain = is_boss(dead) and 5 or 1
            self:SetStackCount((self:GetStackCount() or 0) + gain)
        end
    end
end
function modifier_enfos_underlord_atrophy_aura:GetModifierPreAttack_BonusDamage()
    return (self:GetStackCount() or 0) * 3
end

modifier_enfos_underlord_atrophy_debuff=class({})
function modifier_enfos_underlord_atrophy_debuff:IsDebuff() return true end
function modifier_enfos_underlord_atrophy_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE } end
function modifier_enfos_underlord_atrophy_debuff:GetModifierBaseDamageOutgoing_Percentage()
    local ab = self:GetAbility()
    local red = ab and value(ab, 'reduction') or 25
    return -red
end

enfos_underlord_dark_rift=class({})
function enfos_underlord_dark_rift:OnSpellStart()
    local c = self:GetCaster()
    local p = c:GetAbsOrigin()
    local r = value(self, 'radius') or 750
    local dmg = value(self, 'burst_damage')
    local str = get_str(c)
    local total_dmg = dmg + (str * 1.5)

    for _, u in ipairs(enemies(c, p, r)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_underlord_abyssal_carapace=class({})
function enfos_underlord_abyssal_carapace:GetIntrinsicModifierName() return 'modifier_enfos_underlord_carapace' end

modifier_enfos_underlord_carapace=class({})
function modifier_enfos_underlord_carapace:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS }
end
function modifier_enfos_underlord_carapace:GetModifierPhysicalArmorBonus()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_armor') or 8
end
function modifier_enfos_underlord_carapace:GetModifierHealthBonus()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_hp') or 500
end

-- -------------------------------------------------------------------------
-- TROLL WARLORD (FIGHTER)
-- -------------------------------------------------------------------------

enfos_troll_berserkers_rage=class({})
function enfos_troll_berserkers_rage:OnToggle()
    local c = self:GetCaster()
    if self:GetToggleState() then
        c:AddNewModifier(c, self, 'modifier_enfos_troll_berserkers_rage', {})
    else
        c:RemoveModifierByName('modifier_enfos_troll_berserkers_rage')
    end
end

modifier_enfos_troll_berserkers_rage=class({})
function modifier_enfos_troll_berserkers_rage:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_troll_berserkers_rage:GetModifierPhysicalArmorBonus()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_armor') or 5
end
function modifier_enfos_troll_berserkers_rage:GetModifierMoveSpeedBonus_Constant()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_ms') or 25
end
function modifier_enfos_troll_berserkers_rage:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and RollPercentage(20) then
        local t = params.target
        local c = self:GetParent()
    local agi = get_agi(c)
        local stun_dur = is_boss(t) and 0.3 or 0.8
        t:AddNewModifier(c, self:GetAbility(), 'modifier_generic_stunned_lua', { duration = stun_dur })
        damage(self:GetAbility(), t, 75 + (agi * 0.5), DAMAGE_TYPE_PHYSICAL)
    end
end

enfos_troll_whirling_axes=class({})
function enfos_troll_whirling_axes:OnSpellStart()
    local c = self:GetCaster()
    local p = c:GetAbsOrigin()
    local r = value(self, 'radius') or 450
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.8)
    local dur = value(self, 'duration') or 4.0

    for _, u in ipairs(enemies(c, p, r)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_troll_whirling_axes_blind', { duration = dur })
    end
end

modifier_enfos_troll_whirling_axes_blind=class({})
function modifier_enfos_troll_whirling_axes_blind:IsDebuff() return true end
function modifier_enfos_troll_whirling_axes_blind:DeclareFunctions() return { MODIFIER_PROPERTY_MISS_PERCENTAGE } end
function modifier_enfos_troll_whirling_axes_blind:GetModifierMiss_Percentage() return 60 end

enfos_troll_fervor=class({})
function enfos_troll_fervor:GetIntrinsicModifierName() return 'modifier_enfos_troll_fervor' end

modifier_enfos_troll_fervor=class({})
function modifier_enfos_troll_fervor:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_troll_fervor:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        local max_s = value(self:GetAbility(), 'max_stacks') or 12
        local cur = self:GetStackCount() or 0
        if cur < max_s then self:SetStackCount(cur + 1) end
    end
end
function modifier_enfos_troll_fervor:GetModifierAttackSpeedBonus_Constant()
    local ab = self:GetAbility()
    local per_stack = ab and value(ab, 'attack_speed') or 15
    return (self:GetStackCount() or 0) * (per_stack / 4)
end

enfos_troll_battle_trance=class({})
function enfos_troll_battle_trance:OnSpellStart()
    local c = self:GetCaster()
    local dur = value(self, 'duration') or 5.0
    c:AddNewModifier(c, self, 'modifier_enfos_troll_battle_trance', { duration = dur })
end

modifier_enfos_troll_battle_trance=class({})
function modifier_enfos_troll_battle_trance:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MIN_HEALTH }
end
function modifier_enfos_troll_battle_trance:GetModifierAttackSpeedBonus_Constant()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_as') or 180
end
function modifier_enfos_troll_battle_trance:GetMinHealth() return 1 end

enfos_troll_rampage=class({})
function enfos_troll_rampage:GetIntrinsicModifierName() return 'modifier_enfos_troll_rampage' end

modifier_enfos_troll_rampage=class({})
function modifier_enfos_troll_rampage:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING }
end
function modifier_enfos_troll_rampage:GetModifierPreAttack_BonusDamage() return 25 end
function modifier_enfos_troll_rampage:GetModifierStatusResistanceStacking() return 20 end

-- -------------------------------------------------------------------------
-- CHAOS KNIGHT (FIGHTER)
-- -------------------------------------------------------------------------

enfos_ck_chaos_bolt=class({})
function enfos_ck_chaos_bolt:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local dmg = value(self, 'damage')
    local str = get_str(c)
    local total_dmg = dmg + (str * 0.9)
    local min_s = value(self, 'stun_min') or 1.25
    local max_s = value(self, 'stun_max') or 2.5
    local stun_dur = RandomFloat(min_s, max_s)
    if is_boss(t) then stun_dur = stun_dur * 0.4 end
    t:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = stun_dur })
    damage(self, t, total_dmg, DAMAGE_TYPE_MAGICAL)
end

enfos_ck_reality_rift=class({})
function enfos_ck_reality_rift:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local dur = value(self, 'duration') or 6.0
    t:AddNewModifier(c, self, 'modifier_enfos_ck_reality_rift_debuff', { duration = dur })
    local p_mid = (c:GetAbsOrigin() + t:GetAbsOrigin()) * 0.5
    c:SetAbsOrigin(p_mid)
    if not is_boss(t) then t:SetAbsOrigin(p_mid) end
    c:MoveToTargetToAttack(t)
end

modifier_enfos_ck_reality_rift_debuff=class({})
function modifier_enfos_ck_reality_rift_debuff:IsDebuff() return true end
function modifier_enfos_ck_reality_rift_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_ck_reality_rift_debuff:GetModifierPhysicalArmorBonus()
    local ab = self:GetAbility()
    local red = ab and value(ab, 'armor_reduction') or 6
    return -red
end

enfos_ck_chaos_strike=class({})
function enfos_ck_chaos_strike:GetIntrinsicModifierName() return 'modifier_enfos_ck_chaos_strike' end

modifier_enfos_ck_chaos_strike=class({})
function modifier_enfos_ck_chaos_strike:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_ck_chaos_strike:GetModifierPreAttack_BonusDamage()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_damage') or 20
end
function modifier_enfos_ck_chaos_strike:GetModifierPreAttack_CriticalStrike()
    local ab = self:GetAbility()
    local chance = ab and value(ab, 'crit_chance') or 33
    if RollPercentage(chance) then
        return ab and value(ab, 'crit_mult') or 180
    end
end
function modifier_enfos_ck_chaos_strike:OnTakeDamage(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() and (params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or params.damage_category == 1 or params.damage_category == nil) and params.damage and params.damage > 0 and params.unit then
        local c = self:GetParent()
        local heal = params.damage * 0.5
        c:Heal(heal, self:GetAbility())
        -- Cleave in 250 radius
        for _, u in ipairs(enemies(c, params.unit:GetAbsOrigin(), 250)) do
            if u ~= params.unit then
                damage(self:GetAbility(), u, params.damage * 0.4, DAMAGE_TYPE_PHYSICAL)
            end
        end
    end
end

enfos_ck_phantasm=class({})
function enfos_ck_phantasm:OnSpellStart()
    local c = self:GetCaster()
    local dur = value(self, 'duration') or 30.0
    c:AddNewModifier(c, self, 'modifier_enfos_ck_phantasm_buff', { duration = dur })
end

modifier_enfos_ck_phantasm_buff=class({})
function modifier_enfos_ck_phantasm_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_ck_phantasm_buff:GetModifierPreAttack_BonusDamage()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_damage') or 60
end
function modifier_enfos_ck_phantasm_buff:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        -- Phantasm echo hit
        damage(self:GetAbility(), params.target, params.damage * 0.6, DAMAGE_TYPE_PHYSICAL)
    end
end

enfos_ck_entropy=class({})
function enfos_ck_entropy:GetIntrinsicModifierName() return 'modifier_enfos_ck_entropy' end

modifier_enfos_ck_entropy=class({})
function modifier_enfos_ck_entropy:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_ck_entropy:GetModifierBonusStats_Strength() return 20 end
function modifier_enfos_ck_entropy:GetModifierAttackSpeedBonus_Constant() return 25 end

-- -------------------------------------------------------------------------
-- MEDUSA (CARRY)
-- -------------------------------------------------------------------------

enfos_medusa_split_shot=class({})
function enfos_medusa_split_shot:GetIntrinsicModifierName() return 'modifier_enfos_medusa_split_shot' end

modifier_enfos_medusa_split_shot=class({})
function modifier_enfos_medusa_split_shot:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK } end
function modifier_enfos_medusa_split_shot:OnAttack(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        local c = self:GetParent()
        local ab = self:GetAbility()
        local count = ab and value(ab, 'arrow_count') or 5
    local agi = get_agi(c)
        local base_dmg = (c.GetAverageTrueAttackDamage and c:GetAverageTrueAttackDamage(c)) or 100
        local arrow_dmg = (base_dmg * 0.75) + (agi * 0.5)
        local targets = enemies(c, c:GetAbsOrigin(), 700)
        local hits = 0
        for _, u in ipairs(targets) do
            if u ~= params.target and hits < count then
                damage(ab, u, arrow_dmg, DAMAGE_TYPE_PHYSICAL)
                hits = hits + 1
            end
        end
    end
end

enfos_medusa_mystic_snake=class({})
function enfos_medusa_mystic_snake:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local jumps = value(self, 'jump_count') or 5
    local base_dmg = value(self, 'base_damage')
    local agi = get_agi(c)
    local dmg = base_dmg + (agi * 0.8)
    local current = t
    local hit_count = 0
    local visited = {}

    while current and hit_count < jumps do
        visited[current] = true
        damage(self, current, dmg, DAMAGE_TYPE_MAGICAL)
        hit_count = hit_count + 1
        dmg = dmg * 1.2
        if c.GiveMana then c:GiveMana(30) end
        local next_t = nil
        for _, u in ipairs(enemies(c, current:GetAbsOrigin(), 500)) do
            if not visited[u] then
                next_t = u
                break
            end
        end
        current = next_t
    end
end

enfos_medusa_mana_shield=class({})
function enfos_medusa_mana_shield:GetIntrinsicModifierName() return 'modifier_enfos_medusa_mana_shield' end

modifier_enfos_medusa_mana_shield=class({})
function modifier_enfos_medusa_mana_shield:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end
function modifier_enfos_medusa_mana_shield:GetModifierManaBonus()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_mana') or 250
end
function modifier_enfos_medusa_mana_shield:GetModifierIncomingDamage_Percentage(params)
    if not IsServer() then return 0 end
    local c = self:GetParent()
    local mana = (c.GetMana and c:GetMana()) or 0
    if mana > 10 then
        if c.SpendMana then c:SpendMana(10, self:GetAbility()) end
        return -75
    end
    return 0
end

enfos_medusa_stone_gaze=class({})
function enfos_medusa_stone_gaze:OnSpellStart()
    local c = self:GetCaster()
    local r = value(self, 'radius') or 900
    local dur = value(self, 'duration') or 6.0
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        local petrify_dur = is_boss(u) and 0.8 or 2.5
        u:AddNewModifier(c, self, 'modifier_enfos_medusa_petrified', { duration = petrify_dur })
    end
end

modifier_enfos_medusa_petrified=class({})
function modifier_enfos_medusa_petrified:IsDebuff() return true end
function modifier_enfos_medusa_petrified:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true }
end
function modifier_enfos_medusa_petrified:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE } end
function modifier_enfos_medusa_petrified:GetModifierIncomingPhysicalDamage_Percentage() return 45 end

enfos_medusa_gorgon_gaze=class({})
function enfos_medusa_gorgon_gaze:GetIntrinsicModifierName() return 'modifier_enfos_medusa_gorgon_gaze' end

modifier_enfos_medusa_gorgon_gaze=class({})
function modifier_enfos_medusa_gorgon_gaze:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end
function modifier_enfos_medusa_gorgon_gaze:GetModifierPreAttack_BonusDamage() return 25 end
function modifier_enfos_medusa_gorgon_gaze:GetModifierAttackRangeBonus() return 75 end

-- -------------------------------------------------------------------------
-- TERRORBLADE (CARRY)
-- -------------------------------------------------------------------------

enfos_tb_reflection=class({})
function enfos_tb_reflection:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 500
    local dur = value(self, 'duration') or 5.0
    for _, u in ipairs(enemies(c, p, r)) do
        u:AddNewModifier(c, self, 'modifier_enfos_tb_reflection', { duration = dur })
    end
end

modifier_enfos_tb_reflection=class({})
function modifier_enfos_tb_reflection:IsDebuff() return true end
function modifier_enfos_tb_reflection:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_tb_reflection:OnIntervalThink()
    local p = self:GetParent()
    local c = self:GetCaster()
    local agi = get_agi(c)
    damage(self:GetAbility(), p, 70 + (agi * 0.4), DAMAGE_TYPE_PHYSICAL)
end
function modifier_enfos_tb_reflection:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_tb_reflection:GetModifierMoveSpeedBonus_Percentage() return -25 end

enfos_tb_conjure_image=class({})
function enfos_tb_conjure_image:OnSpellStart()
    local c = self:GetCaster()
    local dur = value(self, 'duration') or 30.0
    c:AddNewModifier(c, self, 'modifier_enfos_tb_conjure_image_buff', { duration = dur })
end

modifier_enfos_tb_conjure_image_buff=class({})
function modifier_enfos_tb_conjure_image_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_tb_conjure_image_buff:GetModifierPreAttack_BonusDamage()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_damage') or 35
end
function modifier_enfos_tb_conjure_image_buff:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        -- Conjured image echo
        damage(self:GetAbility(), params.target, params.damage * 0.5, DAMAGE_TYPE_PHYSICAL)
    end
end

enfos_tb_metamorphosis=class({})
function enfos_tb_metamorphosis:OnSpellStart()
    local c = self:GetCaster()
    local dur = value(self, 'duration') or 40.0
    c:AddNewModifier(c, self, 'modifier_enfos_tb_metamorphosis', { duration = dur })
end

modifier_enfos_tb_metamorphosis=class({})
function modifier_enfos_tb_metamorphosis:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_enfos_tb_metamorphosis:GetModifierAttackRangeBonus() return 400 end
function modifier_enfos_tb_metamorphosis:GetModifierPreAttack_BonusDamage()
    local ab = self:GetAbility()
    local base = ab and value(ab, 'bonus_damage') or 50
    local c = self:GetParent()
    local agi = get_agi(c)
    return base + (agi * 0.4)
end

enfos_tb_sunder=class({})
function enfos_tb_sunder:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local heal = value(self, 'heal_amount') or 700
    local agi = get_agi(c)
    local total_heal = heal + (agi * 1.5)
    c:Heal(total_heal, self)
    local dmg = total_heal
    if is_boss(t) and dmg > 1000 then dmg = 1000 end
    damage(self, t, dmg, DAMAGE_TYPE_PURE)
end

enfos_tb_demon_zeal=class({})
function enfos_tb_demon_zeal:GetIntrinsicModifierName() return 'modifier_enfos_tb_demon_zeal' end

modifier_enfos_tb_demon_zeal=class({})
function modifier_enfos_tb_demon_zeal:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_enfos_tb_demon_zeal:GetModifierAttackSpeedBonus_Constant() return 25 end
function modifier_enfos_tb_demon_zeal:GetModifierMoveSpeedBonus_Constant() return 20 end

-- -------------------------------------------------------------------------
-- LESHRAC (MAGE)
-- -------------------------------------------------------------------------

enfos_leshrac_split_earth=class({})
function enfos_leshrac_split_earth:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 250
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.9)
    local stun_dur = value(self, 'stun_duration') or 1.7

    for _, u in ipairs(enemies(c, p, r)) do
        local d = stun_dur
        if is_boss(u) then d = d * 0.4 end
        u:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = d })
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_leshrac_diabolic_edict=class({})
function enfos_leshrac_diabolic_edict:OnSpellStart()
    local c = self:GetCaster()
    c:AddNewModifier(c, self, 'modifier_enfos_leshrac_diabolic_edict', { duration = 10.0 })
end

modifier_enfos_leshrac_diabolic_edict=class({})
function modifier_enfos_leshrac_diabolic_edict:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.25)
end
function modifier_enfos_leshrac_diabolic_edict:OnIntervalThink()
    local c = self:GetParent()
    local ab = self:GetAbility()
    local r = ab and value(ab, 'radius') or 500
    local targets = enemies(c, c:GetAbsOrigin(), r)
    if #targets > 0 then
        local t = targets[RandomInt(1, #targets)]
        local base_d = ab and value(ab, 'damage_per_explosion') or 25
    local int = get_int(c)
        damage(ab, t, base_d + (int * 0.15), DAMAGE_TYPE_PURE)
    end
end

enfos_leshrac_lightning_storm=class({})
function enfos_leshrac_lightning_storm:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local jumps = value(self, 'jump_count') or 7
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local current = t
    local hit_count = 0
    local visited = {}

    while current and hit_count < jumps do
        visited[current] = true
        damage(self, current, total_dmg, DAMAGE_TYPE_MAGICAL)
        hit_count = hit_count + 1
        local next_t = nil
        for _, u in ipairs(enemies(c, current:GetAbsOrigin(), 650)) do
            if not visited[u] then
                next_t = u
                break
            end
        end
        current = next_t
    end
end

enfos_leshrac_pulse_nova=class({})
function enfos_leshrac_pulse_nova:OnToggle()
    local c = self:GetCaster()
    if self:GetToggleState() then
        c:AddNewModifier(c, self, 'modifier_enfos_leshrac_pulse_nova', {})
    else
        c:RemoveModifierByName('modifier_enfos_leshrac_pulse_nova')
    end
end

modifier_enfos_leshrac_pulse_nova=class({})
function modifier_enfos_leshrac_pulse_nova:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_leshrac_pulse_nova:OnIntervalThink()
    local c = self:GetParent()
    local ab = self:GetAbility()
    local cost = ab and value(ab, 'mana_cost_per_second') or 40
    local mana = (c.GetMana and c:GetMana()) or 0
    if mana < cost then
        ab:ToggleAbility()
        return
    end
    if c.SpendMana then c:SpendMana(cost, ab) end
    local r = ab and value(ab, 'radius') or 450
    local dmg = ab and value(ab, 'damage') or 160
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.75)
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        damage(ab, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_leshrac_defilement=class({})
function enfos_leshrac_defilement:GetIntrinsicModifierName() return 'modifier_enfos_leshrac_defilement' end

modifier_enfos_leshrac_defilement=class({})
function modifier_enfos_leshrac_defilement:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_SPELL_LIFESTEAL_PERCENTAGE }
end
function modifier_enfos_leshrac_defilement:GetModifierBonusStats_Intellect() return 20 end
function modifier_enfos_leshrac_defilement:GetModifierSpellLifestealPercentage() return 20 end

-- -------------------------------------------------------------------------
-- INVOKER (MAGE)
-- -------------------------------------------------------------------------

enfos_invoker_chaos_meteor=class({})
function enfos_invoker_chaos_meteor:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 275
    local dmg = value(self, 'impact_damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.2)
    for _, u in ipairs(enemies(c, p, r)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_invoker_meteor_burn', { duration = 3.0 })
    end
end

modifier_enfos_invoker_meteor_burn=class({})
function modifier_enfos_invoker_meteor_burn:IsDebuff() return true end
function modifier_enfos_invoker_meteor_burn:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end
function modifier_enfos_invoker_meteor_burn:OnIntervalThink()
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    local dps = ab and value(ab, 'burn_dps') or 65
    local int = get_int(c)
    damage(ab, p, (dps * 0.5) + (int * 0.1), DAMAGE_TYPE_MAGICAL)
end

enfos_invoker_sun_strike=class({})
function enfos_invoker_sun_strike:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 200
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.8)
    for _, u in ipairs(enemies(c, p, r)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_PURE)
    end
end

enfos_invoker_deafening_blast=class({})
function enfos_invoker_deafening_blast:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local r = value(self, 'radius') or 250
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local disarm_dur = value(self, 'disarm_duration') or 3.0

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 400), 500)) do
        local d = disarm_dur
        if is_boss(u) then d = d * 0.4 end
        u:AddNewModifier(c, self, 'modifier_enfos_invoker_disarm', { duration = d })
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

modifier_enfos_invoker_disarm=class({})
function modifier_enfos_invoker_disarm:IsDebuff() return true end
function modifier_enfos_invoker_disarm:CheckState() return { [MODIFIER_STATE_DISARMED] = true } end

enfos_invoker_emp=class({})
function enfos_invoker_emp:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 675
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.5)
    for _, u in ipairs(enemies(c, p, r)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_PURE)
    end
    if c.GiveMana then c:GiveMana(150) end
end

enfos_invoker_alacrity=class({})
function enfos_invoker_alacrity:GetIntrinsicModifierName() return 'modifier_enfos_invoker_alacrity' end

modifier_enfos_invoker_alacrity=class({})
function modifier_enfos_invoker_alacrity:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_enfos_invoker_alacrity:GetModifierAttackSpeedBonus_Constant() return 40 end
function modifier_enfos_invoker_alacrity:GetModifierPreAttack_BonusDamage() return 35 end

-- -------------------------------------------------------------------------
-- PUCK (MAGE)
-- -------------------------------------------------------------------------

enfos_puck_illusory_orb=class({})
function enfos_puck_illusory_orb:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.85)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 700), 750)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_puck_waning_rift=class({})
function enfos_puck_waning_rift:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    c:SetAbsOrigin(p)
    local r = value(self, 'radius') or 400
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.75)
    local sil_dur = value(self, 'silence_duration') or 2.5

    for _, u in ipairs(enemies(c, p, r)) do
        local d = sil_dur
        if is_boss(u) then d = d * 0.4 end
        u:AddNewModifier(c, self, 'modifier_enfos_puck_silence', { duration = d })
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

modifier_enfos_puck_silence=class({})
function modifier_enfos_puck_silence:IsDebuff() return true end
function modifier_enfos_puck_silence:CheckState() return { [MODIFIER_STATE_SILENCED] = true } end

enfos_puck_phase_shift=class({})
function enfos_puck_phase_shift:OnSpellStart()
    local c = self:GetCaster()
    local dur = value(self, 'duration') or 2.25
    c:AddNewModifier(c, self, 'modifier_enfos_puck_phase_shift', { duration = dur })
end

modifier_enfos_puck_phase_shift=class({})
function modifier_enfos_puck_phase_shift:CheckState()
    return { [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_OUT_OF_GAME] = true }
end

enfos_puck_dream_coil=class({})
function enfos_puck_dream_coil:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 375
    local dmg = value(self, 'break_damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.5)
    local stun_dur = value(self, 'stun_duration') or 2.5

    for _, u in ipairs(enemies(c, p, r)) do
        local d = stun_dur
        if is_boss(u) then d = d * 0.35 end
        u:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = d })
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_puck_faerie_magic=class({})
function enfos_puck_faerie_magic:GetIntrinsicModifierName() return 'modifier_enfos_puck_faerie_magic' end

modifier_enfos_puck_faerie_magic=class({})
function modifier_enfos_puck_faerie_magic:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFICATION_PERCENTAGE }
end
function modifier_enfos_puck_faerie_magic:GetModifierMoveSpeedBonus_Constant() return 25 end
function modifier_enfos_puck_faerie_magic:GetModifierSpellAmplication_Percentage() return 15 end

-- -------------------------------------------------------------------------
-- JAKIRO (SUPPORT)
-- -------------------------------------------------------------------------

enfos_jakiro_dual_breath=class({})
function enfos_jakiro_dual_breath:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local dur = value(self, 'duration') or 5.0

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 400), 500)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_jakiro_dual_breath_slow', { duration = dur })
    end
end

modifier_enfos_jakiro_dual_breath_slow=class({})
function modifier_enfos_jakiro_dual_breath_slow:IsDebuff() return true end
function modifier_enfos_jakiro_dual_breath_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierMoveSpeedBonus_Percentage() return -35 end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierAttackSpeedBonus_Constant() return -40 end

enfos_jakiro_ice_path=class({})
function enfos_jakiro_ice_path:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.6)
    local stun_dur = value(self, 'stun_duration') or 2.0

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 600), 700)) do
        local d = stun_dur
        if is_boss(u) then d = d * 0.35 end
        u:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = d })
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_jakiro_liquid_fire=class({})
function enfos_jakiro_liquid_fire:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_liquid_fire_passive' end

modifier_enfos_jakiro_liquid_fire_passive=class({})
function modifier_enfos_jakiro_liquid_fire_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_jakiro_liquid_fire_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if params.attacker == self:GetParent() then
        local c = self:GetParent()
        local ab = self:GetAbility()
        local r = ab and value(ab, 'radius') or 300
        local base_d = ab and value(ab, 'bonus_damage') or 50
    local int = get_int(c)
        local total_d = base_d + (int * 0.3)
        for _, u in ipairs(enemies(c, params.target:GetAbsOrigin(), r)) do
            damage(ab, u, total_d, DAMAGE_TYPE_MAGICAL)
        end
    end
end

enfos_jakiro_macropyre=class({})
function enfos_jakiro_macropyre:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local dmg = value(self, 'damage_per_sec')
    local int = get_int(c)
    local total_dmg = (dmg + (int * 0.7)) * 2.0 -- 2 second immediate burst + burn

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 700), 800)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_jakiro_double_trouble=class({})
function enfos_jakiro_double_trouble:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_double_trouble' end

modifier_enfos_jakiro_double_trouble=class({})
function modifier_enfos_jakiro_double_trouble:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_jakiro_double_trouble:GetModifierBonusStats_Intellect() return 20 end
function modifier_enfos_jakiro_double_trouble:GetModifierAttackSpeedBonus_Constant() return 30 end

-- -------------------------------------------------------------------------
-- VENGEFUL SPIRIT (SUPPORT)
-- -------------------------------------------------------------------------

enfos_vs_magic_missile=class({})
function enfos_vs_magic_missile:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.9)
    local stun_dur = value(self, 'stun_duration') or 1.6
    if is_boss(t) then stun_dur = stun_dur * 0.4 end
    t:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = stun_dur })
    damage(self, t, total_dmg, DAMAGE_TYPE_MAGICAL)
end

enfos_vs_wave_of_terror=class({})
function enfos_vs_wave_of_terror:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.6)
    local dur = value(self, 'duration') or 8.0

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 700), 800)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_vs_wave_debuff', { duration = dur })
    end
end

modifier_enfos_vs_wave_debuff=class({})
function modifier_enfos_vs_wave_debuff:IsDebuff() return true end
function modifier_enfos_vs_wave_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_vs_wave_debuff:GetModifierPhysicalArmorBonus()
    local ab = self:GetAbility()
    local red = ab and value(ab, 'armor_reduction') or 4
    return -red
end

enfos_vs_vengeance_aura=class({})
function enfos_vs_vengeance_aura:GetIntrinsicModifierName() return 'modifier_enfos_vs_vengeance_aura' end

modifier_enfos_vs_vengeance_aura=class({})
function modifier_enfos_vs_vengeance_aura:IsAura() return true end
function modifier_enfos_vs_vengeance_aura:GetAuraRadius() return 900 end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_vs_vengeance_aura:GetModifierAura() return 'modifier_enfos_vs_vengeance_aura_buff' end

modifier_enfos_vs_vengeance_aura_buff=class({})
function modifier_enfos_vs_vengeance_aura_buff:DeclareFunctions() return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE } end
function modifier_enfos_vs_vengeance_aura_buff:GetModifierBaseDamageOutgoing_Percentage()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_damage_pct') or 20
end

enfos_vs_nether_swap=class({})
function enfos_vs_nether_swap:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 1.2)
    local p_target = t:GetAbsOrigin()
    local p_caster = c:GetAbsOrigin()
    c:SetAbsOrigin(p_target)
    if not is_boss(t) then t:SetAbsOrigin(p_caster) end
    damage(self, t, total_dmg, DAMAGE_TYPE_MAGICAL)
    c:AddNewModifier(c, self, 'modifier_enfos_vs_nether_swap_buff', { duration = 4.0 })
end

modifier_enfos_vs_nether_swap_buff=class({})
function modifier_enfos_vs_nether_swap_buff:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE } end
function modifier_enfos_vs_nether_swap_buff:GetModifierIncomingDamage_Percentage() return -30 end

enfos_vs_retribution=class({})
function enfos_vs_retribution:GetIntrinsicModifierName() return 'modifier_enfos_vs_retribution' end

modifier_enfos_vs_retribution=class({})
function modifier_enfos_vs_retribution:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_vs_retribution:GetModifierBonusStats_Agility() return 20 end
function modifier_enfos_vs_retribution:GetModifierAttackSpeedBonus_Constant() return 25 end

-- -------------------------------------------------------------------------
-- LICH (SUPPORT)
-- -------------------------------------------------------------------------

enfos_lich_frost_blast=class({})
function enfos_lich_frost_blast:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local tdmg = value(self, 'target_damage')
    local rdmg = value(self, 'radius_damage')
    local int = get_int(c)
    damage(self, t, tdmg + (int * 0.8), DAMAGE_TYPE_MAGICAL)
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 250)) do
        damage(self, u, rdmg + (int * 0.5), DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_lich_frost_blast_slow', { duration = 4.0 })
    end
end

modifier_enfos_lich_frost_blast_slow=class({})
function modifier_enfos_lich_frost_blast_slow:IsDebuff() return true end
function modifier_enfos_lich_frost_blast_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_lich_frost_blast_slow:GetModifierMoveSpeedBonus_Percentage() return -35 end
function modifier_enfos_lich_frost_blast_slow:GetModifierAttackSpeedBonus_Constant() return -40 end

enfos_lich_frost_shield=class({})
function enfos_lich_frost_shield:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget() or c
    local dur = value(self, 'duration') or 6.0
    t:AddNewModifier(c, self, 'modifier_enfos_lich_frost_shield', { duration = dur })
end

modifier_enfos_lich_frost_shield=class({})
function modifier_enfos_lich_frost_shield:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_lich_frost_shield:OnIntervalThink()
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    local dps = ab and value(ab, 'dps') or 50
    local int = get_int(c)
    local total_dps = dps + (int * 0.25)
    for _, u in ipairs(enemies(c, p:GetAbsOrigin(), 600)) do
        damage(ab, u, total_dps, DAMAGE_TYPE_MAGICAL)
    end
end
function modifier_enfos_lich_frost_shield:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE } end
function modifier_enfos_lich_frost_shield:GetModifierIncomingPhysicalDamage_Percentage()
    local ab = self:GetAbility()
    local red = ab and value(ab, 'damage_reduction') or 40
    return -red
end

enfos_lich_sinister_gaze=class({})
function enfos_lich_sinister_gaze:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t then return end
    local dur = value(self, 'duration') or 2.0
    if is_boss(t) then dur = dur * 0.35 end
    t:AddNewModifier(c, self, 'modifier_enfos_lich_sinister_gaze_debuff', { duration = dur })
end

modifier_enfos_lich_sinister_gaze_debuff=class({})
function modifier_enfos_lich_sinister_gaze_debuff:IsDebuff() return true end
function modifier_enfos_lich_sinister_gaze_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end
function modifier_enfos_lich_sinister_gaze_debuff:OnIntervalThink()
    local p = self:GetParent()
    local c = self:GetCaster()
    local dir = (c:GetAbsOrigin() - p:GetAbsOrigin()):Normalized()
    if not is_boss(p) then p:SetAbsOrigin(p:GetAbsOrigin() + (dir * 40)) end
    if c.GiveMana then c:GiveMana(40) end
end

enfos_lich_chain_frost=class({})
function enfos_lich_chain_frost:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end
    local jumps = value(self, 'jump_count') or 10
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.0)
    local current = t

    for i = 1, jumps do
        if not current or not current:IsAlive() then break end
        damage(self, current, total_dmg, DAMAGE_TYPE_MAGICAL)
        local candidates = enemies(c, current:GetAbsOrigin(), 600)
        local next_target = nil
        for _, u in ipairs(candidates) do
            if u ~= current and u:IsAlive() then
                next_target = u
                break
            end
        end
        current = next_target
    end
end

enfos_lich_ice_aura=class({})
function enfos_lich_ice_aura:GetIntrinsicModifierName() return 'modifier_enfos_lich_ice_aura' end

modifier_enfos_lich_ice_aura=class({})
function modifier_enfos_lich_ice_aura:IsAura() return true end
function modifier_enfos_lich_ice_aura:GetAuraRadius() return 900 end
function modifier_enfos_lich_ice_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_lich_ice_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_lich_ice_aura:GetModifierAura() return 'modifier_enfos_lich_ice_aura_buff' end

modifier_enfos_lich_ice_aura_buff=class({})
function modifier_enfos_lich_ice_aura_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end
function modifier_enfos_lich_ice_aura_buff:GetModifierPhysicalArmorBonus()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_armor') or 8
end
function modifier_enfos_lich_ice_aura_buff:GetModifierConstantManaRegen()
    local ab = self:GetAbility()
    return ab and value(ab, 'mana_regen') or 4
end

-- Enfos Team Survival — SametC Edition: Authoritative PvE Hero Kits (Batch 1)
-- Implements complete, high-synergy PvE kits for 6 representative heroes:
-- Sven (Tank), Juggernaut (Fighter), Drow Ranger (Carry), Lina (Mage), Omniknight (Support), Luna (Carry)

local function value(a, k)
    if not a or (a.IsNull and a:IsNull()) then return 0 end
    return (a.GetSpecialValueFor and a:GetSpecialValueFor(k)) or 0
end

local function enemies(c, p, r, target_flags)
    if not c or (c.IsNull and c:IsNull()) then return {} end
    return FindUnitsInRadius(c:GetTeamNumber(), p, nil, r, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_flags or DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false) or {}
end

local function allies(c, p, r)
    if not c or (c.IsNull and c:IsNull()) then return {} end
    return FindUnitsInRadius(c:GetTeamNumber(), p, nil, r, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false) or {}
end

local function is_boss(target)
    if not target or (target.IsNull and target:IsNull()) then return false end
    if target.isBoss == true then return true end
    local name = (target.GetUnitName and target:GetUnitName()) or ""
    return name:find("enfos_boss_", 1, true) ~= nil
end

local function apply_dazzle_weave(caster, target)
    if not caster or not target or (target.IsNull and target:IsNull()) or not target:IsAlive() then return end
    if caster.PassivesDisabled and caster:PassivesDisabled() then return end
    if not caster.FindAbilityByName then return end
    local ability = caster:FindAbilityByName('enfos_dazzle_nothl_weave')
    if not ability or (ability.IsNull and ability:IsNull()) then return end

    local allied = caster:GetTeamNumber() == target:GetTeamNumber()
    local modifier_name = allied and 'modifier_enfos_dazzle_nothl_weave_buff' or 'modifier_enfos_dazzle_nothl_weave_debuff'
    local duration = value(ability, 'duration')
    if duration <= 0 then duration = 6.0 end
    local existing = target.FindModifierByNameAndCaster and target:FindModifierByNameAndCaster(modifier_name, caster) or nil
    if existing then
        local cap = value(ability, 'max_stacks')
        if cap <= 0 then cap = 5 end
        existing:SetStackCount(math.min(cap, existing:GetStackCount() + 1))
        existing:SetDuration(duration, true)
    else
        local modifier = target:AddNewModifier(caster, ability, modifier_name, { duration = duration })
        if modifier and modifier.SetStackCount then modifier:SetStackCount(1) end
    end
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

local function get_atk(c, target)
    if not c or (c.IsNull and c:IsNull()) then return 100 end
    if c.GetAverageTrueAttackDamage then
        local ok, val = pcall(c.GetAverageTrueAttackDamage, c, target or c)
        if ok and type(val) == "number" and val > 0 then return val end
        ok, val = pcall(c.GetAverageTrueAttackDamage, c, nil)
        if ok and type(val) == "number" and val > 0 then return val end
    end
    if c.GetAttackDamage then
        local ok, val = pcall(c.GetAttackDamage, c)
        if ok and type(val) == "number" and val > 0 then return val end
    end
    return 100
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

local function effect(path, target)
    if not target or (target.IsNull and target:IsNull()) or not ParticleManager then return end
    local p = ParticleManager:CreateParticle(path, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(p)
end

local function effect_at_position(path, position)
    if not path or not position or not ParticleManager then return end
    local p = ParticleManager:CreateParticle(path, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, position)
    ParticleManager:ReleaseParticleIndex(p)
end

-- Refreshers cannot leave an unbounded collection of invisible thinker entities.
local function ground_effect(caster, ability, modifier, params, position)
    local live = {}
    for _, entity in ipairs(ability.enfosGroundEffects or {}) do
        if entity and not entity:IsNull() then live[#live+1]=entity end
    end
    while #live >= 3 do UTIL_Remove(table.remove(live,1)) end
    local entity=CreateModifierThinker(caster,ability,modifier,params,position,caster:GetTeamNumber(),false)
    if entity then live[#live+1]=entity end
    ability.enfosGroundEffects=live
    return entity
end

local function remove_ground_effect(modifier)
    if not IsServer() then return end
    local entity=modifier:GetParent()
    if entity and not entity:IsNull() then UTIL_Remove(entity) end
end

-- Link all Lua modifiers
local modifier_list = {
    -- Sven
    'modifier_enfos_pve_warcry',
    'modifier_enfos_pve_taunt',
    'modifier_bulwark_iron_guard',
    'modifier_bulwark_fortress',
    'modifier_bulwark_unbreakable',
    'modifier_bulwark_fortress_scepter_ally',
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
    'modifier_enfos_pa_immaterial_passive',
    -- Zeus
    'modifier_enfos_zeus_static_field_passive',
    'modifier_enfos_zeus_heavenly_jump_buff',
    'modifier_enfos_zeus_heavenly_jump_slow',
    -- Witch Doctor
    'modifier_enfos_wd_paralyzing_cask_stun',
    'modifier_enfos_wd_voodoo_restoration_aura',
    'modifier_enfos_wd_maledict_debuff',
    'modifier_enfos_wd_death_ward_channel',
    'modifier_enfos_wd_death_ward_visual',
    'modifier_enfos_wd_voodoo_switcheroo_buff',
    'modifier_enfos_wd_gris_gris',
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
    'modifier_enfos_slark_pounce_dash',
    'modifier_enfos_slark_essence_shift_passive',
    'modifier_enfos_slark_essence_shift_buff',
    'modifier_enfos_slark_shadow_dance_buff',
    'modifier_enfos_slark_fish_bait_passive',
    'modifier_enfos_slark_fish_bait_debuff',
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
    'modifier_enfos_am_mana_void_stun',
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
    'modifier_enfos_troll_berserkers_rage_stun',
    -- Chaos Knight
    'modifier_enfos_ck_reality_rift_debuff',
    'modifier_enfos_ck_chaos_strike',
    'modifier_enfos_ck_chaos_bolt_stun',
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
    'modifier_enfos_leshrac_lightning_slow',
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
    'modifier_enfos_jakiro_macropyre_zone',
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
    'modifier_enfos_lich_chain_frost_slow',
    'modifier_enfos_lich_ice_aura',
    'modifier_enfos_lich_ice_aura_buff',
    'modifier_enfos_wk_rebirth_slow',
    'modifier_enfos_jakiro_liquid_fire_slow',
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
    local target = self:GetCursorTarget()
    local targetName = target and not target:IsNull() and target:GetUnitName() or "<none>"
    local level = self.GetLevel and self:GetLevel() or 0
    print(string.format("[SVEN_TRACE][Q] cast caster=%s target=%s level=%d",
        c and c:GetUnitName() or "<none>", targetName, level))
    if not c or not target or target:IsNull() or not target:IsAlive() then
        print("[SVEN_TRACE][Q] launch_cancelled reason=invalid_target")
        return
    end
    if target.TriggerSpellAbsorb and target:TriggerSpellAbsorb(self) then
        print("[SVEN_TRACE][Q] launch_cancelled reason=spell_absorb")
        return
    end

    if not ProjectileManager or not ProjectileManager.CreateTrackingProjectile then
        print("[SVEN_TRACE][Q] launch_cancelled reason=projectile_manager_unavailable")
        return
    end
    local projectile = ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = c,
        Ability = self,
        EffectName = 'particles/units/heroes/hero_sven/sven_storm_bolt_projectile_trail.vpcf',
        iMoveSpeed = value(self, 'bolt_speed'),
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false
    })
    print(string.format("[SVEN_TRACE][Q] projectile_created handle=%s speed=%s",
        tostring(projectile), tostring(value(self, 'bolt_speed'))))
end

function bulwark_shield_slam:OnProjectileHit(target, location)
    local c = self:GetCaster()
    if not c or c:IsNull() then
        print("[SVEN_TRACE][Q] impact_cancelled reason=missing_caster")
        return true
    end
    local origin = location or (target and not target:IsNull() and target:GetAbsOrigin())
    if not origin then
        print("[SVEN_TRACE][Q] impact_cancelled reason=missing_location")
        return true
    end

    -- A dodged projectile has no impact target and must not detonate at its last location.
    if not target or target:IsNull() or not target:IsAlive() then
        print("[SVEN_TRACE][Q] impact_cancelled reason=target_lost_or_dodged")
        return true
    end

    target:EmitSound('Hero_Sven.StormBoltImpact')
    local p = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf',
        PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(p)

    -- Preserve the existing Enfos Scepter mobility upgrade, applied on impact.
    if c.HasScepter and c:HasScepter() and c.HasModifier
        and c:HasModifier('modifier_bulwark_fortress') then
        FindClearSpaceForUnit(c, origin, true)
    end

    local radius = math.max(0, value(self, 'radius'))
    local stunDuration = math.max(0, value(self, 'stun_duration'))
    local totalDamage = math.max(0, value(self, 'damage'))
    local affected = 0
    for _, enemy in ipairs(enemies(c, origin, radius)) do
        affected = affected + 1
        damage(self, enemy, totalDamage, DAMAGE_TYPE_MAGICAL)
        local bossStunCap = math.max(0, value(self, 'boss_stun_cap'))
        local actualStun = is_boss(enemy) and math.min(stunDuration, bossStunCap) or stunDuration
        if actualStun > 0 then
            enemy:AddNewModifier(c, self, 'modifier_stunned', { duration = actualStun })
        end
    end
    print(string.format("[SVEN_TRACE][Q] impact target=%s affected=%d damage=%s stun=%s",
        target:GetUnitName(), affected, tostring(totalDamage), tostring(stunDuration)))
    return true
end

bulwark_challenge=class({})
function bulwark_challenge:Precache(context)
    PrecacheResource('particle', 'particles/units/heroes/hero_sven/sven_spell_warcry.vpcf', context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_sven.vsndevts', context)
end
function bulwark_challenge:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    if not c or c:IsNull() then return end
    -- The native cast root's mouth child reads CP2 as its head location.
    local castParticle = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_sven/sven_spell_warcry.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControlEnt(castParticle, 2, c, PATTACH_POINT_FOLLOW,
        'attach_head', c:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(castParticle)
    local dur = value(self, 'duration')
    local rad = value(self, 'radius')
    if rad <= 0 then rad = 500 end

    local allyCount = 1
    c:AddNewModifier(c, self, 'modifier_enfos_pve_warcry', { duration = dur })

    for _, a in ipairs(allies(c, c:GetAbsOrigin(), rad)) do
        if a~=c then
            allyCount = allyCount + 1
            a:AddNewModifier(c, self, 'modifier_enfos_pve_warcry', { duration = dur })
        end
    end

    local tauntCount = 0
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), rad)) do
        if u:GetUnitName() ~= 'enfos_creep_runner' then
            local tauntPct = is_boss(u) and value(self, 'boss_taunt_pct') or 100
            u:AddNewModifier(c, self, 'modifier_enfos_pve_taunt', { duration = dur * tauntPct / 100 })
            tauntCount = tauntCount + 1
        end
    end
    local level = self.GetLevel and self:GetLevel() or 0
    print(string.format("[SVEN_TRACE][W] cast caster=%s level=%d allies_buffed=%d enemies_taunted=%d radius=%s duration=%s",
        c:GetUnitName(), level, allyCount, tauntCount, tostring(rad), tostring(dur)))
end

function modifier_enfos_pve_warcry:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_TOOLTIP2,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end
function modifier_enfos_pve_warcry:OnCreated()
    local a = self:GetAbility()
    local c = self:GetCaster()
    local base_barrier = value(a, 'barrier_hp')

    self.barrier = base_barrier + (c and get_str(c) * 1.5 or 0)

    -- Aghanim's Shard: Grants barrier equal to 25% of Sven's max health
    if c and c.HasModifier and (c:HasModifier('modifier_item_aghanims_shard') or c:HasModifier('modifier_enfos_shard_upgrade')) then
        self.barrier = self.barrier + (c:GetMaxHealth() * 0.25)
    end
    if IsServer() and self.SetStackCount then self:SetStackCount(math.ceil(self.barrier)) end
    if IsServer() and c and SendOverheadEventMessage and OVERHEAD_ALERT_BLOCK then
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BLOCK, self:GetParent(), math.ceil(self.barrier), nil)
    end
end
function modifier_enfos_pve_warcry:OnTooltip() return value(self:GetAbility(), 'bonus_armor') end
function modifier_enfos_pve_warcry:OnTooltip2() return self:GetStackCount() end
function modifier_enfos_pve_warcry:OnRefresh() self:OnCreated() end
function modifier_enfos_pve_warcry:IsHidden() return false end
function modifier_enfos_pve_warcry:GetTexture() return 'sven_warcry' end
function modifier_enfos_pve_warcry:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'bonus_armor') end
function modifier_enfos_pve_warcry:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'bonus_ms_pct') or 25 end
function modifier_enfos_pve_warcry:GetModifierTotal_ConstantBlock(e)
    if not IsServer() or not self.barrier or self.barrier <= 0 then return 0 end
    local block = math.min(self.barrier, math.max(0,tonumber(e and e.damage) or 0))
    self.barrier = self.barrier - block
    if self.SetStackCount then self:SetStackCount(math.ceil(self.barrier)) end
    return block
end
function modifier_enfos_pve_warcry:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_pve_warcry:OnTakeDamage(e)
    if not IsServer() or e.unit ~= self:GetParent() or not e.attacker or e.attacker:IsNull() or e.attacker == e.unit then return end
    if not e.attacker:IsAlive() or e.attacker:GetTeamNumber() == e.unit:GetTeamNumber() then return end
    if e.damage_flags and bit and bit.band(e.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0 then return end
    -- Shard: 40% physical damage reflection during Warcry
    local c = self:GetCaster()
    if c and c.HasModifier and (c:HasModifier('modifier_item_aghanims_shard') or c:HasModifier('modifier_enfos_shard_upgrade')) then
        if e.damage_type~=DAMAGE_TYPE_PHYSICAL then return end
        local refl = (e.damage or 0) * 0.40
        if refl > 0 then damage(self:GetAbility(), e.attacker, refl, DAMAGE_TYPE_PHYSICAL, DOTA_DAMAGE_FLAG_REFLECTION) end
    end
end
function modifier_enfos_pve_warcry:GetEffectName() return 'particles/units/heroes/hero_sven/sven_warcry_buff.vpcf' end

function modifier_enfos_pve_taunt:IsDebuff() return true end
function modifier_enfos_pve_taunt:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_pve_taunt:CheckState() return { [MODIFIER_STATE_TAUNTED] = true } end
function modifier_enfos_pve_taunt:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent()
    if p and p.SetForceAttackTarget then p:SetForceAttackTarget(self:GetCaster()) end
    if p and p.MoveToTargetToAttack then p:MoveToTargetToAttack(self:GetCaster()) end
end
function modifier_enfos_pve_taunt:OnDeath(event)
    local c = self:GetCaster()
    if event and event.unit == c then self:Destroy() end
end
function modifier_enfos_pve_taunt:OnDestroy()
    if IsServer() then
        local p = self:GetParent()
        local c = self:GetCaster()
        if p and p.SetForceAttackTarget and p.GetForceAttackTarget
            and p:GetForceAttackTarget() == c then
            p:SetForceAttackTarget(nil)
        end
    end
end

bulwark_iron_guard=class({})
function bulwark_iron_guard:GetIntrinsicModifierName() return 'modifier_bulwark_iron_guard' end

modifier_bulwark_iron_guard=class({})
function modifier_bulwark_iron_guard:IsHidden() return false end
function modifier_bulwark_iron_guard:GetTexture() return 'sven_great_cleave' end
function modifier_bulwark_iron_guard:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_bulwark_iron_guard:OnAttackLanded(e)
    local c = self:GetParent()
    local primary = e and e.target
    if not IsServer() or not e or e.attacker ~= c or c:PassivesDisabled()
        or (c.IsIllusion and c:IsIllusion()) or not primary
        or (primary.IsNull and primary:IsNull())
        or primary:GetTeamNumber() == c:GetTeamNumber() then return end

    local distance = math.max(0, value(self:GetAbility(), 'cleave_distance'))
    local startWidth = math.max(0, value(self:GetAbility(), 'cleave_starting_width')) * 0.5
    local endWidth = math.max(0, value(self:GetAbility(), 'cleave_ending_width')) * 0.5
    local percent = math.max(0, value(self:GetAbility(), 'cleave_pct')) / 100
    local baseDamage = e.original_damage or get_atk(c, primary)
    local splashDamage = math.max(0, baseDamage * percent)
    local particle = 'particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf'
    if c.HasModifier and c:HasModifier('modifier_bulwark_fortress') then
        particle = 'particles/units/heroes/hero_sven/sven_spell_great_cleave_gods_strength.vpcf'
    end
    -- Use the engine's physical cleave and particle contract, not target-attached
    -- copies of a cleave root. Enfos KV widths remain full widths; API takes radii.
    DoCleaveAttack(c, primary, self:GetAbility(), splashDamage, startWidth, endWidth, distance, particle)
end

bulwark_fortress=class({})
function bulwark_fortress:OnSpellStart()
    local c = self:GetCaster()
    if not c then return end
    c:EmitSound('Hero_Sven.GodsStrength')
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 15.0 end

    if c and c.HasScepter and c:HasScepter() then
        dur = dur + value(self, 'scepter_duration_bonus')
    end

    c:AddNewModifier(c, self, 'modifier_bulwark_fortress', { duration = dur })

    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(p)
end

modifier_bulwark_fortress=class({})
function modifier_bulwark_fortress:IsHidden() return false end
function modifier_bulwark_fortress:IsPurgable() return false end
function modifier_bulwark_fortress:GetTexture() return 'sven_gods_strength' end
function modifier_bulwark_fortress:GetEffectName() return 'particles/units/heroes/hero_sven/sven_gods_strength_hero_effect.vpcf' end
function modifier_bulwark_fortress:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
    }
end
function modifier_bulwark_fortress:GetModifierBaseDamageOutgoing_Percentage()
    local bonus = value(self:GetAbility(), 'bonus_damage_pct')
    if bonus <= 0 then bonus = 150 end
    return bonus
end
function modifier_bulwark_fortress:GetModifierBonusStats_Strength() return value(self:GetAbility(), 'bonus_str') or 40 end
function modifier_bulwark_fortress:GetModifierIncomingDamage_Percentage() return -value(self:GetAbility(), 'damage_reduction_pct') end
function modifier_bulwark_fortress:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'move_speed_pct') end
function modifier_bulwark_fortress:GetModifierStatusResistanceStacking()
    local c = self:GetCaster()
    return (c and c.HasScepter and c:HasScepter()) and value(self:GetAbility(), 'scepter_status_resistance') or 0
end
function modifier_bulwark_fortress:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(value(self:GetAbility(), 'shockwave_interval'))
end
function modifier_bulwark_fortress:OnRefresh() self:OnCreated() end
function modifier_bulwark_fortress:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local str = get_str(c)
    local dmg = value(a, 'shockwave_damage') + (str * value(a, 'shockwave_strength_factor'))
    local targets = enemies(c, c:GetAbsOrigin(), value(a, 'radius'))
    local visualCount = 0
    for _, u in ipairs(targets) do
        damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL)
        -- The old Storm Hammer impact was drawn at Sven's feet. Attach the
        -- native impact feedback to affected units and cap particles per pulse.
        if visualCount < 6 then
            effect('particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf', u)
            visualCount = visualCount + 1
        end
    end
    if c and c.GetUnitName then
        print(string.format('[SVEN_TRACE][D] pulse targets=%d vfx_targets=%d damage=%.1f radius=%s',
            #targets, visualCount, dmg, tostring(value(a, 'radius'))))
    end

    -- Scepter: Aura granting 50% bonus damage to allies within 900 radius
    if c and c.HasScepter and c:HasScepter() then
        for _, ally in ipairs(allies(c, c:GetAbsOrigin(), value(a, 'scepter_ally_radius'))) do
            if ally ~= c and ally:IsHero() then
                ally:AddNewModifier(c, a, 'modifier_bulwark_fortress_scepter_ally', { duration = value(a, 'scepter_ally_duration') })
            end
        end
    end
end

modifier_bulwark_fortress_scepter_ally=class({})
function modifier_bulwark_fortress_scepter_ally:IsHidden() return false end
function modifier_bulwark_fortress_scepter_ally:GetTexture() return 'sven_gods_strength' end
function modifier_bulwark_fortress_scepter_ally:DeclareFunctions()
    return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_bulwark_fortress_scepter_ally:GetModifierBaseDamageOutgoing_Percentage() return value(self:GetAbility(), 'scepter_ally_bonus_damage_pct') end
function modifier_bulwark_fortress_scepter_ally:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'scepter_ally_bonus_armor') end

bulwark_unbreakable=class({})
function bulwark_unbreakable:GetIntrinsicModifierName() return 'modifier_bulwark_unbreakable' end

modifier_bulwark_unbreakable=class({})
function modifier_bulwark_unbreakable:IsHidden() return false end
function modifier_bulwark_unbreakable:GetTexture() return 'sven_wrath_of_god' end
function modifier_bulwark_unbreakable:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
    }
end
function modifier_bulwark_unbreakable:GetModifierConstantHealthRegen()
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    local regen = value(self:GetAbility(), 'bonus_hp_regen')
    -- Shard: doubles HP regen when below 40% health
    if c and c.GetHealthPercent and c:GetHealthPercent() < 40 then
        if c.HasModifier and (c:HasModifier('modifier_item_aghanims_shard') or c:HasModifier('modifier_enfos_shard_upgrade')) then
            regen = regen * 2.0
        end
    end
    return regen
end
function modifier_bulwark_unbreakable:GetModifierExtraHealthBonus()
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    return value(self:GetAbility(), 'bonus_max_hp') or 0
end
function modifier_bulwark_unbreakable:GetModifierStatusResistanceStacking()
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    return value(self:GetAbility(), 'status_resistance') or 0
end

-- =========================================================================
-- JUGGERNAUT (FIGHTER)
-- =========================================================================

enfos_juggernaut_blade_fury=class({})
function enfos_juggernaut_blade_fury:OnSpellStart()
    local c = self:GetCaster()
    c:AddNewModifier(c, self, 'modifier_enfos_pve_fury', { duration = value(self, 'duration') })
end

function modifier_enfos_pve_fury:OnCreated()
    if IsServer() then
        local parent = self:GetParent()
        parent:EmitSound('Hero_Juggernaut.BladeFuryStart')
        local spin = ParticleManager:CreateParticle(
            'particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf', PATTACH_ABSORIGIN_FOLLOW, parent)
        -- The installed root/children read CP5.x as their radius input.
        ParticleManager:SetParticleControl(spin, 5, Vector(value(self:GetAbility(), 'radius'), 0, 0))
        self:AddParticle(spin, false, false, -1, false, false)
        self:StartIntervalThink(value(self:GetAbility(), 'tick_interval'))
    end
end
function modifier_enfos_pve_fury:IsPurgable() return false end
function modifier_enfos_pve_fury:IsDebuff() return false end
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
function modifier_enfos_pve_fury:GetModifierMoveSpeedBonus_Constant() return value(self:GetAbility(), 'bonus_movespeed') end
function modifier_enfos_pve_fury:OnDestroy()
    if IsServer() then
        local c = self:GetParent()
        if c and not c:IsNull() then
            c:StopSound('Hero_Juggernaut.BladeFuryStart')
            c:EmitSound('Hero_Juggernaut.BladeFuryStop')
        end
    end
end

enfos_juggernaut_healing_ward=class({})
function enfos_juggernaut_healing_ward:OnSpellStart()
    local c = self:GetCaster()
    local point = self:GetCursorPosition()
    c:EmitSound('Hero_Juggernaut.HealingWard.Cast')
    ground_effect(c, self, 'modifier_enfos_juggernaut_healing_ward_thinker', { duration = value(self, 'duration') }, point)
end

modifier_enfos_juggernaut_healing_ward_thinker=class({})
function modifier_enfos_juggernaut_healing_ward_thinker:OnDestroy() remove_ground_effect(self) end
function modifier_enfos_juggernaut_healing_ward_thinker:IsAura() return true end
function modifier_enfos_juggernaut_healing_ward_thinker:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_juggernaut_healing_ward_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_juggernaut_healing_ward_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_juggernaut_healing_ward_thinker:GetModifierAura() return 'modifier_enfos_juggernaut_healing_ward_aura' end
function modifier_enfos_juggernaut_healing_ward_thinker:GetEffectName()
    return 'particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf'
end
function modifier_enfos_juggernaut_healing_ward_thinker:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_enfos_juggernaut_healing_ward_aura=class({})
function modifier_enfos_juggernaut_healing_ward_aura:DeclareFunctions() return { MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE } end
function modifier_enfos_juggernaut_healing_ward_aura:GetModifierHealthRegenPercentage() return value(self:GetAbility(), 'heal_pct') end

enfos_juggernaut_blade_dance=class({})
function enfos_juggernaut_blade_dance:GetIntrinsicModifierName() return 'modifier_enfos_pve_crit' end

function modifier_enfos_pve_crit:IsHidden() return true end
function modifier_enfos_pve_crit:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY }
end
function modifier_enfos_pve_crit:GetModifierPreAttack_CriticalStrike(event)
    if not IsServer() then return end
    local parent = self:GetParent()
    if not parent or parent:IsNull() or parent:PassivesDisabled() or not event or not event.target
        or (event.attacker and event.attacker ~= parent) or event.target:IsNull()
        or event.target:GetTeamNumber() == parent:GetTeamNumber() then return end
    self.critRecords = self.critRecords or {}
    local record = event.record
    local saved = record ~= nil and self.critRecords[record] or nil
    if saved then return saved.multiplier > 0 and saved.multiplier or nil end
    local multiplier = RollPercentage(value(self:GetAbility(), 'crit_chance')) and value(self:GetAbility(), 'crit_mult') or 0
    if record ~= nil then
        self.critRecords[record] = { target = event.target, multiplier = multiplier }
    end
    return multiplier > 0 and multiplier or nil
end
function modifier_enfos_pve_crit:OnAttackLanded(event)
    if not IsServer() then return end
    local c = self:GetParent()
    if not event or event.attacker ~= c or event.record == nil then return end
    local saved = self.critRecords and self.critRecords[event.record]
    if self.critRecords then self.critRecords[event.record] = nil end
    if not saved or saved.multiplier <= 0 or saved.target ~= event.target or c:PassivesDisabled() then return end
    local a = self:GetAbility()
    if not event.target or event.target:IsNull() then return end
    local dmg = get_atk(c, event.target) * value(a, 'crit_splash_pct') / 100
    for _, u in ipairs(enemies(c, event.target:GetAbsOrigin(), value(a, 'crit_splash_radius'))) do
        if u ~= event.target then damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL) end
    end
    effect('particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf', event.target)
end
function modifier_enfos_pve_crit:OnAttackRecordDestroy(event)
    if IsServer() and event and event.attacker == self:GetParent() and event.record ~= nil and self.critRecords then
        self.critRecords[event.record] = nil
    end
end
function modifier_enfos_pve_crit:OnDestroy() self.critRecords = nil end

enfos_juggernaut_omni_slash=class({})
function enfos_juggernaut_omni_slash:OnSpellStart()
    local t = self:GetCursorTarget()
    if not t or t:IsNull() or not t:IsAlive() or t:GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end
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
    self.visitedTargets = {}
    self:OnIntervalThink()
    self:StartIntervalThink(value(self:GetAbility(), 'slash_interval'))
end
function modifier_enfos_pve_slashes:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    if not c or not c:IsAlive() then self:Destroy(); return end
    local home = self.home or c:GetAbsOrigin()
    local t = self.target
    if not t or t:IsNull() or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber()
        or (t:GetAbsOrigin() - c:GetAbsOrigin()):Length2D() > value(a, 'radius') then
        t = nil
        local nearest, nearestDistance
        local candidates = enemies(c, c:GetAbsOrigin(), value(a, 'radius'), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
        for _, candidate in ipairs(candidates) do
            if candidate and not candidate:IsNull() and candidate:IsAlive()
                and candidate:GetTeamNumber() ~= c:GetTeamNumber() then
                local distance = (candidate:GetAbsOrigin() - c:GetAbsOrigin()):Length2D()
                if not nearestDistance or distance < nearestDistance then
                    nearest, nearestDistance = candidate, distance
                end
                if not self.visitedTargets[candidate:entindex()] then
                    t = candidate
                    break
                end
            end
        end
        if not t then
            -- If only one target remains, repeat it rather than ending the ultimate early.
            t = nearest
            if t then self.visitedTargets = {} end
        end
    end
    if not t or (t:GetAbsOrigin() - home):Length2D() > 1400 then self:Destroy(); return end
    self.visitedTargets[t:entindex()] = true
    local previousPosition = c:GetAbsOrigin()
    local hitPosition = t:GetAbsOrigin()
    local offset = t.GetForwardVector and t:GetForwardVector() or Vector(1, 0, 0)
    c:SetAbsOrigin(t:GetAbsOrigin() - offset * 64)
    damage(a, t, get_atk(c, t) + value(a, 'bonus_damage'), DAMAGE_TYPE_PHYSICAL)
    -- Native root draws a path between CP0 and CP1. Keep its impact children
    -- at the victim and bridge to the pre-jump position, even after a lethal hit.
    local slashParticle = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(slashParticle, 0, hitPosition)
    ParticleManager:SetParticleControl(slashParticle, 1, previousPosition)
    ParticleManager:ReleaseParticleIndex(slashParticle)
    self.target = nil
end
function modifier_enfos_pve_slashes:OnDestroy()
    local parent = self:GetParent()
    if IsServer() and self.home and parent and not parent:IsNull() and parent:IsAlive() then
        FindClearSpaceForUnit(parent, self.home, true)
    end
end

enfos_juggernaut_duelist=class({})
function enfos_juggernaut_duelist:GetIntrinsicModifierName() return 'modifier_enfos_juggernaut_duelist' end

modifier_enfos_juggernaut_duelist=class({})
function modifier_enfos_juggernaut_duelist:IsHidden() return true end
function modifier_enfos_juggernaut_duelist:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end
function modifier_enfos_juggernaut_duelist:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'bonus_attack_speed')
end
function modifier_enfos_juggernaut_duelist:GetModifierMoveSpeedBonus_Percentage()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'bonus_ms_pct')
end
function modifier_enfos_juggernaut_duelist:OnDeath(e)
    local c = self:GetParent()
    if not IsServer() or not e or not e.unit or e.attacker ~= c or e.unit:GetTeamNumber() == c:GetTeamNumber()
        or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    local ability = self:GetAbility()
    local stack_duration = value(ability, 'kill_stack_duration')
    if stack_duration <= 0 then stack_duration = 7.0 end
    local mod = c:FindModifierByName('modifier_enfos_juggernaut_duelist_stack')
    if not mod then
        mod = c:AddNewModifier(c, ability, 'modifier_enfos_juggernaut_duelist_stack', { duration = stack_duration })
    end
    if mod then
        local cap = value(ability, 'kill_stack_cap')
        if cap <= 0 then cap = 10 end
        mod:SetStackCount(math.min(mod:GetStackCount() + 1, cap))
        mod:SetDuration(stack_duration, true)
    end
end

modifier_enfos_juggernaut_duelist_stack=class({})
function modifier_enfos_juggernaut_duelist_stack:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
local function duelist_stack_count(self)
    local parent = self:GetParent()
    if not parent or (parent.PassivesDisabled and parent:PassivesDisabled()) then return 0 end
    return self:GetStackCount()
end
function modifier_enfos_juggernaut_duelist_stack:GetModifierAttackSpeedBonus_Constant() return duelist_stack_count(self) * value(self:GetAbility(), 'kill_stack_attack_speed') end
function modifier_enfos_juggernaut_duelist_stack:GetModifierPhysicalArmorBonus() return duelist_stack_count(self) * value(self:GetAbility(), 'kill_stack_armor') end
function modifier_enfos_juggernaut_duelist_stack:GetModifierMoveSpeedBonus_Percentage() return duelist_stack_count(self) * value(self:GetAbility(), 'kill_stack_movespeed_pct') end
function modifier_enfos_juggernaut_duelist_stack:OnAttackLanded(e)
    if not IsServer() or not e or e.attacker ~= self:GetParent() or duelist_stack_count(self) < value(self:GetAbility(), 'kill_stack_cap') then return end
    if not e.target or e.target:IsNull() or e.target:GetTeamNumber() == self:GetParent():GetTeamNumber() then return end
    local heal = (e.damage or 0) * value(self:GetAbility(), 'kill_stack_lifesteal_pct') / 100
    if heal > 0 then self:GetParent():Heal(heal, self:GetAbility()) end
end

-- =========================================================================
-- DROW RANGER (CARRY)
-- =========================================================================

local function drow_impact(path, position)
    local particle = ParticleManager:CreateParticle(path, PATTACH_WORLDORIGIN, nil)
    -- Native endcap impact roots/children emit at CP3; their attractors use CP0.
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 3, position)
    ParticleManager:ReleaseParticleIndex(particle)
end

enfos_drow_frost_arrows=class({})
function enfos_drow_frost_arrows:Precache(context)
    PrecacheResource('particle', 'particles/units/heroes/hero_drow/drow_frost_arrow_explosion.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_explode.vpcf', context)
end
function enfos_drow_frost_arrows:GetIntrinsicModifierName() return 'modifier_enfos_pve_frost' end

function modifier_enfos_pve_frost:IsPurgable() return false end
function modifier_enfos_pve_frost:IsDebuff() return false end
function modifier_enfos_pve_frost:IsHidden() return true end
function modifier_enfos_pve_frost:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_pve_frost:OnAttackLanded(e)
    local c = self:GetParent()
    local a = self:GetAbility()
    local target = e and e.target
    if not IsServer() or not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or e.attacker ~= c or c:PassivesDisabled() or c:IsIllusion() or target:GetTeamNumber() == c:GetTeamNumber() then return end
    local agi = get_agi(c)
    local hit_position = target:GetAbsOrigin()
    local status_res = target.GetStatusResistance and target:GetStatusResistance() or 0
    target:AddNewModifier(c, a, 'modifier_enfos_pve_slow', { duration = value(a, 'duration') * (1 - status_res) })
    target:EmitSound('Hero_DrowRanger.FrostArrows')
    -- A lethal bonus hit may dispatch OnDeath synchronously; establish ownership first.
    damage(a, target, value(a, 'bonus_damage') + (agi * value(a, 'agility_factor')), DAMAGE_TYPE_PHYSICAL)
    drow_impact('particles/units/heroes/hero_drow/drow_frost_arrow_explosion.vpcf', hit_position)
end
function modifier_enfos_pve_frost:OnDeath(e)
    if not IsServer() or not e or not e.unit or (e.unit.IsNull and e.unit:IsNull()) then return end
    local c = self:GetParent()
    local a = self:GetAbility()
    if c:PassivesDisabled() then return end
    local slow = e.unit.FindModifierByNameAndCaster
        and e.unit:FindModifierByNameAndCaster('modifier_enfos_pve_slow', c)
    if slow and slow:GetAbility() == a then
    local agi = get_agi(c)
        local shatter_dmg = value(a, 'shatter_base_damage') + (agi * value(a, 'shatter_agility_factor'))
        for _, u in ipairs(enemies(c, e.unit:GetAbsOrigin(), value(a, 'shatter_radius'))) do
            if u ~= e.unit then
                damage(a, u, shatter_dmg, DAMAGE_TYPE_MAGICAL)
                u:AddNewModifier(c, a, 'modifier_enfos_pve_slow', { duration = value(a, 'shatter_slow_duration') })
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
    local dir = self:GetCursorPosition() - origin
    dir.z = 0
    if dir:Length2D() < 1 then dir = c:GetForwardVector() end
    dir.z = 0
    local direction = dir:Normalized()
    self.gust_serial = (self.gust_serial or 0) + 1
    local cast_id = self.gust_serial
    self.gust_waves = self.gust_waves or {}
    self.gust_waves[cast_id] = { direction = direction, hit_targets = {} }
    c:EmitSound('Hero_DrowRanger.Silence')

    ProjectileManager:CreateLinearProjectile({
        Ability = self,
        EffectName = 'particles/units/heroes/hero_drow/drow_silence_wave.vpcf',
        vSpawnOrigin = origin,
        fDistance = value(self, 'wave_distance'),
        fStartRadius = value(self, 'wave_width'),
        fEndRadius = value(self, 'wave_width'),
        Source = c,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        bDeleteOnHit = false,
        vVelocity = direction * value(self, 'wave_speed'),
        bProvidesVision = false,
        ExtraData = { gust_cast = cast_id }
    })
end
function enfos_drow_gust:OnProjectileHit_ExtraData(t, location, data)
    local cast_id = data and tonumber(data.gust_cast)
    local wave = cast_id and self.gust_waves and self.gust_waves[cast_id]
    if not wave then return false end
    if not t then
        self.gust_waves[cast_id] = nil
        return false
    end
    if t and not (t.IsNull and t:IsNull()) and t:IsAlive() then
        local c = self:GetCaster()
        if not c or c:IsNull() or t:GetTeamNumber() == c:GetTeamNumber() then return false end
        local target_id = t.entindex and t:entindex() or t
        if wave.hit_targets[target_id] then return false end
        wave.hit_targets[target_id] = true
        if not is_boss(t) then
            t:SetAbsOrigin(t:GetAbsOrigin() + wave.direction * value(self, 'knockback_distance'))
            FindClearSpaceForUnit(t, t:GetAbsOrigin(), true)
        end
        local boss_pct = value(self, 'boss_control_duration_pct')
        local dur = value(self, 'silence_duration') * (is_boss(t) and boss_pct / 100 or 1.0)
        t:AddNewModifier(c, self, 'modifier_enfos_pve_gust_vulnerable', { duration = dur })
    end
    return false
end

modifier_enfos_pve_gust_vulnerable=class({})
function modifier_enfos_pve_gust_vulnerable:IsDebuff() return true end
function modifier_enfos_pve_gust_vulnerable:CheckState() return { [MODIFIER_STATE_SILENCED] = true } end
function modifier_enfos_pve_gust_vulnerable:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE } end
function modifier_enfos_pve_gust_vulnerable:GetModifierIncomingPhysicalDamage_Percentage()
    return value(self:GetAbility(), 'physical_vulnerability_pct')
end

enfos_drow_multishot=class({})
function enfos_drow_multishot:GetChannelTime() return value(self, 'channel_time') end
function enfos_drow_multishot:OnSpellStart()
    local c = self:GetCaster()
    self.direction = self:GetCursorPosition() - c:GetAbsOrigin()
    self.direction.z = 0
    if self.direction:Length2D() < 1 then self.direction = c:GetForwardVector() end
    self.direction.z = 0
    self.direction = self.direction:Normalized()
    self.elapsed = 0
    self.sent = 0
    c:EmitSound('Hero_DrowRanger.Multishot.Channel')
end
function enfos_drow_multishot:OnChannelThink(dt)
    local c = self:GetCaster()
    local channel_time = value(self, 'channel_time')
    if not c or (c.IsNull and c:IsNull()) or channel_time <= 0 then return end
    self.elapsed = self.elapsed + dt
    local count = value(self, 'arrow_count')
    local wanted = math.min(count, math.floor(self.elapsed / channel_time * count) + 1)
    while self.sent < wanted do
        local lane_count = math.max(1, value(self, 'lane_count'))
        local lane = self.sent % lane_count
        local angle = math.rad(value(self, 'spread_start_angle') + lane * value(self, 'spread_angle_step'))
        local d = self.direction
        local velocity = Vector(d.x * math.cos(angle) - d.y * math.sin(angle), d.x * math.sin(angle) + d.y * math.cos(angle), 0)
        ProjectileManager:CreateLinearProjectile({
            Ability = self,
            EffectName = 'particles/units/heroes/hero_drow/drow_multishot_proj_linear_proj.vpcf',
            vSpawnOrigin = c:GetAbsOrigin(),
            fDistance = value(self, 'arrow_range'),
            fStartRadius = value(self, 'arrow_width'),
            fEndRadius = value(self, 'arrow_width'),
            Source = c,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            bDeleteOnHit = false,
            vVelocity = velocity:Normalized() * value(self, 'arrow_speed'),
            bProvidesVision = false
        })
        self.sent = self.sent + 1
    end
end
function enfos_drow_multishot:OnProjectileHit(t)
    local c = self:GetCaster()
    if t and not (t.IsNull and t:IsNull()) and t:IsAlive() and c and not (c.IsNull and c:IsNull())
        and t:GetTeamNumber() ~= c:GetTeamNumber() then
        damage(self, t, get_atk(c, t) * value(self, 'arrow_damage_pct') / 100, DAMAGE_TYPE_PHYSICAL)
        local frost = c:FindAbilityByName('enfos_drow_frost_arrows')
        if frost and frost:GetLevel() > 0 then
            t:AddNewModifier(c, frost, 'modifier_enfos_pve_slow', { duration = value(self, 'frost_slow_duration') })
        end
    end
    return false
end
function enfos_drow_multishot:OnChannelFinish()
    local c = self:GetCaster()
    if c and not (c.IsNull and c:IsNull()) then c:StopSound('Hero_DrowRanger.Multishot.Channel') end
end

enfos_drow_marksmanship=class({})
function enfos_drow_marksmanship:Precache(context)
    PrecacheResource('particle', 'particles/units/heroes/hero_drow/drow_frost_arrow_explosion.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_drow/drow_base_attack_explosion_flash.vpcf', context)
end
function enfos_drow_marksmanship:GetIntrinsicModifierName() return 'modifier_enfos_pve_marksmanship' end

function modifier_enfos_pve_marksmanship:IsHidden() return true end
function modifier_enfos_pve_marksmanship:IsPurgable() return false end
function modifier_enfos_pve_marksmanship:IsDebuff() return false end
function modifier_enfos_pve_marksmanship:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_pve_marksmanship:OnAttackLanded(e)
    local c = self:GetParent()
    local target = e and e.target
    if not IsServer() or not target or (target.IsNull and target:IsNull())
        or e.attacker ~= c or c:PassivesDisabled() or c:IsIllusion() or target:GetTeamNumber() == c:GetTeamNumber() then return end
    if RollPercentage(value(self:GetAbility(), 'proc_chance')) then
    local agi = get_agi(c)
        local ability = self:GetAbility()
        local bonus_dmg = value(ability, 'bonus_damage') + (agi * value(ability, 'agility_factor'))
        local hit_position = target:GetAbsOrigin()
        damage(ability, target, bonus_dmg, DAMAGE_TYPE_PHYSICAL, DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR)
        drow_impact('particles/units/heroes/hero_drow/drow_frost_arrow_explosion.vpcf', hit_position)

        -- Arrow Splinters to up to 3 nearby creeps
        local count = 0
        for _, u in ipairs(enemies(c, hit_position, value(ability, 'splinter_radius'), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
            if u ~= target and count < value(ability, 'splinter_count') then
                local splinter_position = u:GetAbsOrigin()
                damage(ability, u, get_atk(c, u) * value(ability, 'splinter_damage_pct') / 100, DAMAGE_TYPE_PHYSICAL)
                drow_impact('particles/units/heroes/hero_drow/drow_base_attack_explosion_flash.vpcf', splinter_position)
                count = count + 1
            end
        end
    end
end

enfos_drow_precision_aura=class({})
function enfos_drow_precision_aura:GetIntrinsicModifierName() return 'modifier_enfos_pve_precision' end

function modifier_enfos_pve_precision:IsHidden() return true end
function modifier_enfos_pve_precision:IsPurgable() return false end
function modifier_enfos_pve_precision:IsDebuff() return false end
function modifier_enfos_pve_precision:IsAura()
    local c = self:GetParent()
    return c and not (c.PassivesDisabled and c:PassivesDisabled()) or false
end
function modifier_enfos_pve_precision:GetAuraRadius() return value(self:GetAbility(), 'aura_radius') end
function modifier_enfos_pve_precision:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_pve_precision:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_pve_precision:GetModifierAura() return 'modifier_enfos_pve_precision_buff' end

modifier_enfos_pve_precision_buff=class({})
function modifier_enfos_pve_precision_buff:IsPurgable() return false end
function modifier_enfos_pve_precision_buff:IsDebuff() return false end
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

local function lina_array_effect(position, radius)
    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p, 0, position)
    ParticleManager:SetParticleControl(p, 1, Vector(radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(p)
end

enfos_lina_dragon_slave=class({})
function enfos_lina_dragon_slave:OnSpellStart()
    local c = self:GetCaster()
    local origin = c:GetAbsOrigin()
    local dir = self:GetCursorPosition() - origin
    dir.z = 0
    if dir:Length2D() < 1 then dir = c:GetForwardVector() end
    dir.z = 0
    dir = dir:Normalized()
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
        vVelocity = dir * value(self, 'dragon_slave_speed'),
        bProvidesVision = false
    })
end
function enfos_lina_dragon_slave:OnProjectileHit(t)
    if t and not (t.IsNull and t:IsNull()) and t:IsAlive() then
        local c = self:GetCaster()
        if not c or (c.IsNull and c:IsNull()) or t:GetTeamNumber() == c:GetTeamNumber() then return false end
        local int = get_int(c)
        local dmg = value(self, 'damage') + (int * 1.2)
        damage(self, t, dmg, DAMAGE_TYPE_MAGICAL)
        local comb = c:FindAbilityByName('enfos_lina_combustion')
        if c.IsIllusion and c:IsIllusion() then comb = nil end
        if comb and not (comb.IsNull and comb:IsNull()) and comb:GetLevel() > 0
            and not c:PassivesDisabled() and not (t.IsNull and t:IsNull()) and t:IsAlive() then
            t:AddNewModifier(c, comb, 'modifier_enfos_pve_burn', { duration = value(comb, 'burn_duration') })
        end
    end
    return false
end

enfos_lina_light_strike_array=class({})
function enfos_lina_light_strike_array:GetAOERadius() return value(self, 'radius') end
function enfos_lina_light_strike_array:OnSpellStart()
    local c = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = value(self, 'radius')
    local stun_dur = value(self, 'stun_duration')
    local delay = value(self, 'light_strike_array_delay_time')
    local int = get_int(c)
    local dmg = value(self, 'damage') + (int * 1.0)

    c:EmitSound('Ability.LightStrikeArray')
    lina_array_effect(point, radius)

    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or (c.GetUnitName and c:GetUnitName()) or 'lina'
    local context_name = 'EnfosLinaLightStrike_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    local mode = GameRules:GetGameModeEntity()
    mode:SetContextThink(context_name, function()
        if not c or (c.IsNull and c:IsNull()) then return nil end
        for _, u in ipairs(enemies(c, point, radius)) do
            if u and not (u.IsNull and u:IsNull()) and u:IsAlive() then
                local dur = stun_dur * (is_boss(u) and 0.35 or 1.0)
                u:AddNewModifier(c, self, 'modifier_stunned', { duration = dur })
                damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
            end
        end
        return nil
    end, delay)
end

enfos_lina_fiery_soul=class({})
function enfos_lina_fiery_soul:GetIntrinsicModifierName() return 'modifier_enfos_pve_fiery' end

function modifier_enfos_pve_fiery:IsHidden() return true end
function modifier_enfos_pve_fiery:IsPurgable() return false end
function modifier_enfos_pve_fiery:IsDebuff() return false end
function modifier_enfos_pve_fiery:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_pve_fiery:OnAbilityFullyCast(e)
    if IsServer() and e and e.unit == self:GetParent() and e.ability
        and not (e.ability.IsNull and e.ability:IsNull())
        and not (e.ability.IsItem and e.ability:IsItem()) and not e.unit:PassivesDisabled()
        and not (e.unit.IsIllusion and e.unit:IsIllusion()) then
        e.unit:AddNewModifier(e.unit, self:GetAbility(), 'modifier_enfos_pve_fiery_stacks', { duration = value(self:GetAbility(), 'fiery_soul_stack_duration') })
    end
end
function modifier_enfos_pve_fiery:OnAttackLanded(e)
    local c = self:GetParent()
    local target = e and e.target
    local proc_chance = value(self:GetAbility(), 'fiery_soul_attack_proc_chance')
    if IsServer() and e and e.attacker == c and not c:PassivesDisabled() and not c:IsIllusion()
        and target and not (target.IsNull and target:IsNull()) and target:GetTeamNumber() ~= c:GetTeamNumber()
        and RollPercentage(proc_chance) then
        c:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_pve_fiery_stacks', { duration = value(self:GetAbility(), 'fiery_soul_stack_duration') })
    end
end

function modifier_enfos_pve_fiery_stacks:OnCreated()
    if not IsServer() then return end
    self:SetStackCount(1)
    self.flame_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_lina/lina_fiery_soul.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.flame_particle, 1, Vector(self:GetStackCount(), 0, 0))
    self:AddParticle(self.flame_particle, false, false, -1, false, false)
end
function modifier_enfos_pve_fiery_stacks:IsPurgable() return false end
function modifier_enfos_pve_fiery_stacks:IsDebuff() return false end
function modifier_enfos_pve_fiery_stacks:GetTexture() return 'lina_fiery_soul' end
function modifier_enfos_pve_fiery_stacks:OnRefresh()
    if not IsServer() then return end
    self:SetStackCount(math.min(self:GetStackCount() + 1, value(self:GetAbility(), 'fiery_soul_max_stacks')))
    if self.flame_particle then
        ParticleManager:SetParticleControl(self.flame_particle, 1, Vector(self:GetStackCount(), 0, 0))
    end
end
function modifier_enfos_pve_fiery_stacks:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
local function fiery_soul_stacks(self)
    local c = self.GetParent and self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    return self:GetStackCount()
end
function modifier_enfos_pve_fiery_stacks:GetModifierAttackSpeedBonus_Constant() return fiery_soul_stacks(self) * value(self:GetAbility(), 'fiery_soul_attack_speed_bonus') end
function modifier_enfos_pve_fiery_stacks:GetModifierMoveSpeedBonus_Percentage() return fiery_soul_stacks(self) * value(self:GetAbility(), 'fiery_soul_move_speed_bonus') end
function modifier_enfos_pve_fiery_stacks:GetModifierSpellAmplify_Percentage()
    return fiery_soul_stacks(self) * value(self:GetAbility(), 'fiery_soul_spell_amp_per_stack')
end

enfos_lina_laguna_blade=class({})
function enfos_lina_laguna_blade:OnSpellStart()
    local t = self:GetCursorTarget()
    local c = self:GetCaster()
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() or not c or (c.IsNull and c:IsNull())
        or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
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
function modifier_enfos_pve_combustion:IsPurgable() return false end
function modifier_enfos_pve_combustion:IsDebuff() return false end
function modifier_enfos_pve_combustion:DeclareFunctions() return { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_pve_combustion:GetModifierSpellAmplify_Percentage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'spell_amp')
end
function modifier_enfos_pve_combustion:OnTakeDamage(e)
    local a = self:GetAbility()
    local c = self:GetParent()
    local inflictor = e and e.inflictor
    local target = e and e.unit
    if IsServer() and e.attacker == c and inflictor and not (inflictor.IsNull and inflictor:IsNull())
        and inflictor ~= a and not (inflictor.IsItem and inflictor:IsItem())
        and not c:PassivesDisabled() and not (c.IsIllusion and c:IsIllusion())
        and target and not (target.IsNull and target:IsNull())
        and target:IsAlive() and target:GetTeamNumber() ~= c:GetTeamNumber() then
        target:AddNewModifier(c, a, 'modifier_enfos_pve_burn', { duration = value(a, 'burn_duration') })
    end
end
function modifier_enfos_pve_combustion:OnDeath(e)
    if not IsServer() or not e or not e.unit or (e.unit.IsNull and e.unit:IsNull()) then return end
    local c = self:GetParent()
    local a = self:GetAbility()
    if c:PassivesDisabled() or (c.IsIllusion and c:IsIllusion()) then return end
    if e.unit:GetTeamNumber() ~= c:GetTeamNumber() and e.unit.FindModifierByNameAndCaster and
        e.unit:FindModifierByNameAndCaster('modifier_enfos_pve_burn', c) then
        local max_hp = e.unit:GetMaxHealth() or 500
        local corpse_dmg = value(a, 'corpse_burst_base') + math.min(max_hp * value(a, 'corpse_burst_hp_pct') / 100, value(a, 'corpse_burst_hp_cap'))
        local position = e.unit:GetAbsOrigin()
        local radius = value(a, 'corpse_burst_radius')
        for _, u in ipairs(enemies(c, position, radius)) do
            if u ~= e.unit then damage(a, u, corpse_dmg, DAMAGE_TYPE_MAGICAL) end
        end
        lina_array_effect(position, radius)
    end
end

function modifier_enfos_pve_burn:IsDebuff() return true end
function modifier_enfos_pve_burn:GetTexture() return 'lina_flame_cloak' end
function modifier_enfos_pve_burn:GetEffectName() return 'particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf' end
function modifier_enfos_pve_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_pve_burn:OnCreated() if IsServer() then self:StartIntervalThink(0.5) end end
function modifier_enfos_pve_burn:OnIntervalThink()
    local c = self:GetCaster()
    local int = get_int(c)
    local dps = value(self:GetAbility(), 'burn_dps') + (int * value(self:GetAbility(), 'burn_int_pct') / 100)
    damage(self:GetAbility(), self:GetParent(), dps * 0.5, DAMAGE_TYPE_MAGICAL)
end

-- =========================================================================
-- OMNIKNIGHT (SUPPORT)
-- =========================================================================

enfos_omni_purification=class({})
function enfos_omni_purification:GetAOERadius() return value(self, 'radius') end
function enfos_omni_purification:OnSpellStart()
    local target = self:GetCursorTarget() or self:GetCaster()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or target:GetTeamNumber() ~= c:GetTeamNumber() then return end
    local str = get_str(c)
    local amount = value(self, 'heal_amount') + (str * value(self, 'strength_multiplier'))
    local radius = value(self, 'radius')

    target:EmitSound('Hero_Omniknight.Purification')
    if target.Heal then target:Heal(amount, self) end

    local p = ParticleManager:CreateParticle('particles/units/heroes/hero_omniknight/omniknight_purification.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(p, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(p)

    for _, u in ipairs(enemies(c, target:GetAbsOrigin(), radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        damage(self, u, amount, DAMAGE_TYPE_PURE)
    end
end

enfos_omni_repel=class({})
function enfos_omni_repel:OnSpellStart()
    local target = self:GetCursorTarget() or self:GetCaster()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or target:GetTeamNumber() ~= c:GetTeamNumber() then return end
    target:EmitSound('Hero_Omniknight.Repel')
    target:AddNewModifier(c, self, 'modifier_enfos_pve_repel', { duration = value(self, 'duration') })
end

modifier_enfos_pve_repel=class({})
function modifier_enfos_pve_repel:IsPurgable() return false end
function modifier_enfos_pve_repel:GetTexture() return 'omniknight_repel' end
function modifier_enfos_pve_repel:IsDebuff() return false end
function modifier_enfos_pve_repel:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_enfos_pve_repel:GetModifierConstantHealthRegen() return value(self:GetAbility(), 'bonus_hp_regen') end
function modifier_enfos_pve_repel:GetModifierBonusStats_Strength() return value(self:GetAbility(), 'bonus_strength') end
function modifier_enfos_pve_repel:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'bonus_armor') end
function modifier_enfos_pve_repel:CheckState() return { [MODIFIER_STATE_DEBUFF_IMMUNE] = true } end
function modifier_enfos_pve_repel:GetEffectName() return 'particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf' end

enfos_omni_degen_aura=class({})
function enfos_omni_degen_aura:GetIntrinsicModifierName() return 'modifier_enfos_pve_degen_aura' end

modifier_enfos_pve_degen_aura=class({})
function modifier_enfos_pve_degen_aura:IsHidden() return true end
function modifier_enfos_pve_degen_aura:IsPurgable() return false end
function modifier_enfos_pve_degen_aura:IsDebuff() return false end
function modifier_enfos_pve_degen_aura:IsAura()
    local c = self:GetParent()
    return c and not (c.IsNull and c:IsNull()) and not (c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_pve_degen_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_pve_degen_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_enfos_pve_degen_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_pve_degen_aura:GetModifierAura() return 'modifier_enfos_pve_degen_debuff' end
function modifier_enfos_pve_degen_aura:OnCreated()
    if not IsServer() then return end
    self.aura_particle = ParticleManager:CreateParticle('particles/units/heroes/hero_omniknight/omniknight_degen_aura.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.aura_particle, 1, Vector(self:GetAuraRadius(), 0, 0))
    self:AddParticle(self.aura_particle, false, false, -1, false, false)
end
function modifier_enfos_pve_degen_aura:OnRefresh()
    if IsServer() and self.aura_particle then
        ParticleManager:SetParticleControl(self.aura_particle, 1, Vector(self:GetAuraRadius(), 0, 0))
    end
end

modifier_enfos_pve_degen_debuff=class({})
function modifier_enfos_pve_degen_debuff:GetTexture() return 'omniknight_degen_aura' end
function modifier_enfos_pve_degen_debuff:IsDebuff() return true end
function modifier_enfos_pve_degen_debuff:IsPurgable() return true end
function modifier_enfos_pve_degen_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT } end
function modifier_enfos_pve_degen_debuff:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_pve_degen_debuff:GetModifierAttackSpeedBonus_Constant() return value(self:GetAbility(), 'attack_slow') end
function modifier_enfos_pve_degen_debuff:GetEffectName() return 'particles/units/heroes/hero_omniknight/omniknight_degen_aura_debuff.vpcf' end
function modifier_enfos_pve_degen_debuff:OnCreated() if IsServer() then self:StartIntervalThink(1.0) end end
function modifier_enfos_pve_degen_debuff:OnIntervalThink()
    local c = self:GetCaster()
    local str = get_str(c)
    local a = self:GetAbility()
    damage(a, self:GetParent(), value(a, 'damage_per_second') + (str * value(a, 'strength_damage_factor')), DAMAGE_TYPE_PURE)
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
function modifier_enfos_pve_angel:IsPurgable() return false end
function modifier_enfos_pve_angel:GetTexture() return 'omniknight_guardian_angel' end
function modifier_enfos_pve_angel:IsDebuff() return false end
function modifier_enfos_pve_angel:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_enfos_pve_angel:GetModifierConstantHealthRegen() return value(self:GetAbility(), 'bonus_hp_regen') end
function modifier_enfos_pve_angel:GetEffectName()
    if self:GetParent() == self:GetCaster() then
        return 'particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf'
    end
    return 'particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf'
end
function modifier_enfos_pve_angel:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

enfos_omni_hammer_of_purity=class({})
function enfos_omni_hammer_of_purity:GetIntrinsicModifierName() return 'modifier_enfos_pve_hammer' end

modifier_enfos_pve_hammer=class({})
function modifier_enfos_pve_hammer:IsHidden() return true end
function modifier_enfos_pve_hammer:IsPurgable() return false end
function modifier_enfos_pve_hammer:IsDebuff() return false end
function modifier_enfos_pve_hammer:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_pve_hammer:OnAttackLanded(e)
    local c = self:GetParent()
    local a = self:GetAbility()
    local target = e and e.target
    if not IsServer() or not e or not c or (c.IsNull and c:IsNull()) or e.attacker ~= c or c:PassivesDisabled()
        or not target or (target.IsNull and target:IsNull()) or target:GetTeamNumber() == c:GetTeamNumber() then return end
    local position = target:GetAbsOrigin()
    local str = get_str(c)
    local dmg = value(a, 'bonus_pure_damage') + (str * value(a, 'strength_multiplier'))
    damage(a, target, dmg, DAMAGE_TYPE_PURE)
    if not (target.IsNull and target:IsNull()) and target:IsAlive() then
        target:AddNewModifier(c, a, 'modifier_enfos_pve_slow', { duration = value(a, 'slow_duration') })
    end
    local particle = ParticleManager:CreateParticle('particles/units/heroes/hero_omniknight/omniknight_hammer_of_purity_detonation.vpcf', PATTACH_WORLDORIGIN, c)
    ParticleManager:SetParticleControl(particle, 0, position)
    ParticleManager:SetParticleControl(particle, 3, position)
    ParticleManager:ReleaseParticleIndex(particle)
    if c.Heal then c:Heal(dmg * value(a, 'lifesteal_pct') / 100, a) end
    for _, u in ipairs(enemies(c, position, value(a, 'splash_radius'))) do
        if u ~= target then damage(a, u, dmg * value(a, 'splash_damage_pct') / 100, DAMAGE_TYPE_PURE) end
    end
end

-- =========================================================================
-- LUNA (CARRY)
-- =========================================================================

enfos_luna_lucent_beam=class({})
function enfos_luna_lucent_beam:OnSpellStart()
    local target = self:GetCursorTarget()
    local c = self:GetCaster()
    if not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or not c or (c.IsNull and c:IsNull()) or not c:IsAlive()
        or target:GetTeamNumber() == c:GetTeamNumber() then return end
    if target.TriggerSpellAbsorb and target:TriggerSpellAbsorb(self) then return end
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
function enfos_luna_moon_glaives:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
    if not hTarget or (hTarget.IsNull and hTarget:IsNull()) or not hTarget:IsAlive() then return true end
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or hTarget:GetTeamNumber() == c:GetTeamNumber() then return true end
    local amount = tonumber(extraData and extraData.damage) or 0
    if amount > 0 then damage(self, hTarget, amount, DAMAGE_TYPE_PHYSICAL) end
    return true
end

modifier_enfos_luna_moon_glaives_passive=class({})
function modifier_enfos_luna_moon_glaives_passive:IsHidden() return true end
function modifier_enfos_luna_moon_glaives_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_luna_moon_glaives_passive:OnAttackLanded(e)
    local c = self:GetParent()
    local a = self:GetAbility()
    local primary = e and e.target
    if not IsServer() or not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) or not primary or (primary.IsNull and primary:IsNull())
        or not primary:IsAlive() or e.attacker ~= c or primary:GetTeamNumber() == c:GetTeamNumber() then return end
    local bounces = math.max(0, math.min(16, math.floor(value(a, 'bounce_count'))))
    local cur_target = e.target
    local cur_dmg = (get_atk(c, cur_target) * 0.85) + value(a, 'bonus_damage')
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
                bProvidesVision = false,
                ExtraData = { damage = cur_dmg }
            })
        else
            damage(a, next_target, cur_dmg, DAMAGE_TYPE_PHYSICAL)
        end
        cur_dmg = cur_dmg * 0.85
        cur_target = next_target
    end
end

enfos_luna_lunar_blessing=class({})
function enfos_luna_lunar_blessing:GetIntrinsicModifierName() return 'modifier_enfos_luna_lunar_blessing' end

modifier_enfos_luna_lunar_blessing=class({})
function modifier_enfos_luna_lunar_blessing:IsAura() return true end
function modifier_enfos_luna_lunar_blessing:GetAuraRadius() return value(self:GetAbility(), 'radius') or 1200 end
function modifier_enfos_luna_lunar_blessing:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_luna_lunar_blessing:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_luna_lunar_blessing:GetModifierAura() return 'modifier_enfos_luna_lunar_blessing_aura' end

modifier_enfos_luna_lunar_blessing_aura=class({})
function modifier_enfos_luna_lunar_blessing_aura:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_enfos_luna_lunar_blessing_aura:GetModifierPreAttack_BonusDamage() return value(self:GetAbility(), 'bonus_damage') end
function modifier_enfos_luna_lunar_blessing_aura:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'bonus_ms_pct') end
function modifier_enfos_luna_lunar_blessing_aura:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'bonus_armor') end

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
    self.boss_damage = {}
    self:StartIntervalThink(0.3)
end
function modifier_enfos_luna_eclipse_thinker:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not a or (a.IsNull and a:IsNull()) then
        self:Destroy()
        return
    end
    local targets = enemies(c, c:GetAbsOrigin(), value(a, 'radius'))
    if #targets == 0 then return end
    local valid_targets = {}
    for _, u in ipairs(targets) do
        local hits = self.hit_counts[u:entindex()] or 0
        if hits < value(a, 'max_hits_per_target') then table.insert(valid_targets, u) end
    end
    if #valid_targets == 0 then return end
    local target = valid_targets[RandomInt(1, #valid_targets)]
    self.hit_counts[target:entindex()] = (self.hit_counts[target:entindex()] or 0) + 1

    local dmg = value(a, 'beam_damage')
    if is_boss(target) then
        local id = target:entindex()
        dmg = math.min(dmg, math.max(0, target:GetMaxHealth() * value(a, 'boss_damage_pct') / 100 - (self.boss_damage[id] or 0)))
        self.boss_damage[id] = (self.boss_damage[id] or 0) + dmg
    end
    damage(a, target, dmg, DAMAGE_TYPE_MAGICAL)
    target:EmitSound('Hero_Luna.LucentBeam.Target')
    effect('particles/units/heroes/hero_luna/luna_lucent_beam.vpcf', target)
end

enfos_luna_lunar_orbit=class({})
function enfos_luna_lunar_orbit:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Luna.Eclipse.NoTarget')
    c:AddNewModifier(c, self, 'modifier_enfos_luna_lunar_orbit_buff', { duration = value(self, 'duration') })
end

modifier_enfos_luna_lunar_orbit_buff=class({})
function modifier_enfos_luna_lunar_orbit_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_enfos_luna_lunar_orbit_buff:GetModifierIncomingDamage_Percentage() return -value(self:GetAbility(), 'damage_reduction_pct') end
function modifier_enfos_luna_lunar_orbit_buff:GetModifierAttackRangeBonus() return value(self:GetAbility(), 'bonus_range') end
function modifier_enfos_luna_lunar_orbit_buff:GetModifierMoveSpeedBonus_Constant() return value(self:GetAbility(), 'bonus_ms') end
function modifier_enfos_luna_lunar_orbit_buff:OnCreated()
    if not IsServer() then return end
    local c = self:GetParent()
    if ParticleManager then
        self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_luna/luna_ambient_lunar_blessing.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    end
    if self.StartIntervalThink then self:StartIntervalThink(value(self:GetAbility(), 'pulse_interval')) end
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
    local a = self:GetAbility()
    local dmg = value(a, 'pulse_damage') + (agi * value(a, 'agility_multiplier'))
    local hit_any = false
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(a, 'pulse_radius'))) do
        damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL)
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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local r = value(self, 'radius')
    if r <= 0 then r = 400 end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 3.0 end
    local armor = value(self, 'bonus_armor')
    if armor <= 0 then armor = 30 end

    c:EmitSound('Hero_Axe.Berserkers_Call')
    local shout = ParticleManager:CreateParticle('particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControlEnt(shout, 1, c, PATTACH_POINT_FOLLOW, 'attach_mouth', c:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(shout)

    c:AddNewModifier(c, self, 'modifier_enfos_axe_call_buff', { duration = dur, bonus_armor = armor })

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        local target_dur = dur
        if is_boss(u) then
            local boss_pct = value(self, 'boss_taunt_pct')
            if boss_pct <= 0 then boss_pct = 25 end
            target_dur = dur * boss_pct / 100
        end
        u:AddNewModifier(c, self, 'modifier_enfos_axe_call_taunt', { duration = target_dur })
    end
end

modifier_enfos_axe_call_buff=class({})
function modifier_enfos_axe_call_buff:GetTexture() return 'axe_berserkers_call' end
function modifier_enfos_axe_call_buff:IsPurgable() return false end
function modifier_enfos_axe_call_buff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_axe_call_buff:OnCreated(kv)
    self.bonus_armor = (kv and kv.bonus_armor) or (self.GetAbility and value(self:GetAbility(), 'bonus_armor')) or 30
end
function modifier_enfos_axe_call_buff:OnRefresh(kv) self:OnCreated(kv) end
function modifier_enfos_axe_call_buff:GetModifierPhysicalArmorBonus() return self.bonus_armor end

modifier_enfos_axe_call_taunt=class({})
function modifier_enfos_axe_call_taunt:GetTexture() return 'axe_berserkers_call' end
function modifier_enfos_axe_call_taunt:IsDebuff() return true end
function modifier_enfos_axe_call_taunt:IsPurgable() return false end
function modifier_enfos_axe_call_taunt:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_axe_call_taunt:OnCreated()
    if not IsServer() then return end
    local p, c = self:GetParent(), self:GetCaster()
    if not p or p:IsNull() or not p:IsAlive() or not c or c:IsNull() or not c:IsAlive() then return end
    p:SetForceAttackTarget(c)
    p:MoveToTargetToAttack(c)
end
function modifier_enfos_axe_call_taunt:OnRefresh() self:OnCreated() end
function modifier_enfos_axe_call_taunt:OnDeath(event)
    if IsServer() and event and event.unit == self:GetCaster() then self:Destroy() end
end
function modifier_enfos_axe_call_taunt:OnDestroy()
    if not IsServer() then return end
    local p, c = self:GetParent(), self:GetCaster()
    if p and not p:IsNull() and p:GetForceAttackTarget() == c then p:SetForceAttackTarget(nil) end
end
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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 10.0 end
    c:EmitSound('Hero_Axe.Battle_Hunger')
    t:AddNewModifier(c, self, 'modifier_enfos_axe_battle_hunger_debuff', { duration = dur })
    c:AddNewModifier(c, self, 'modifier_enfos_axe_battle_hunger_speed', { duration = dur })
end

modifier_enfos_axe_battle_hunger_debuff=class({})
function modifier_enfos_axe_battle_hunger_debuff:GetTexture() return 'axe_battle_hunger' end
function modifier_enfos_axe_battle_hunger_debuff:GetEffectName() return 'particles/units/heroes/hero_axe/axe_battle_hunger.vpcf' end
function modifier_enfos_axe_battle_hunger_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_axe_battle_hunger_debuff:IsDebuff() return true end
function modifier_enfos_axe_battle_hunger_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_axe_battle_hunger_debuff:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
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
    local dmg = base + (str * value(a, 'strength_damage_factor'))
    damage(a, p, dmg, DAMAGE_TYPE_PHYSICAL)
end
function modifier_enfos_axe_battle_hunger_debuff:OnDeath(params)
    if not IsServer() then return end
    if params.unit == self:GetParent() then
        local p = self:GetParent()
        local a = self:GetAbility()
        local c = self:GetCaster()
        if c and not (c.IsNull and c:IsNull()) and a and not (a.IsNull and a:IsNull()) then
            local count = 0
            local radius = value(a, 'spread_radius')
            if radius <= 0 then radius = 400 end
            local target_count = value(a, 'spread_target_count')
            if target_count <= 0 then target_count = 2 end
            for _, u in ipairs(enemies(c, p:GetAbsOrigin(), radius)) do
                if u ~= p and not u:HasModifier('modifier_enfos_axe_battle_hunger_debuff') then
                    u:AddNewModifier(c, a, 'modifier_enfos_axe_battle_hunger_debuff', { duration = value(a, 'spread_duration') })
                    count = count + 1
                    if count >= target_count then break end
                end
            end
        end
    end
end

modifier_enfos_axe_battle_hunger_speed=class({})
function modifier_enfos_axe_battle_hunger_speed:GetTexture() return 'axe_battle_hunger' end
function modifier_enfos_axe_battle_hunger_speed:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_axe_battle_hunger_speed:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'caster_movespeed_pct') end

enfos_axe_counter_helix=class({})
function enfos_axe_counter_helix:GetIntrinsicModifierName() return 'modifier_enfos_axe_counter_helix_passive' end

modifier_enfos_axe_counter_helix_passive=class({})
function modifier_enfos_axe_counter_helix_passive:IsHidden() return false end
function modifier_enfos_axe_counter_helix_passive:GetTexture() return 'axe_counter_helix' end
function modifier_enfos_axe_counter_helix_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACKED } end
function modifier_enfos_axe_counter_helix_passive:OnCreated()
    self.last_boss_proc = self.last_boss_proc or 0
    self.attack_counter = self.attack_counter or 0
end
function modifier_enfos_axe_counter_helix_passive:OnAttacked(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if not params or params.target ~= c or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    local a = self:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or not c:IsAlive() then return end
    local attacker = params.attacker
    if not attacker or (attacker.IsNull and attacker:IsNull()) or not attacker:IsAlive() then return end
    if attacker.GetTeamNumber and c.GetTeamNumber and attacker:GetTeamNumber() == c:GetTeamNumber() then return end
    local required = math.max(1, math.floor(value(a, 'attacks_to_trigger') + 0.5))
    if required <= 0 then required = 7 end
    self.attack_counter = (self.attack_counter or 0) + 1
    if self.attack_counter < required then return end
    if is_boss(attacker) then
        local now = (GameRules and GameRules.GetGameTime) and GameRules:GetGameTime() or 0
        local interval = value(a, 'boss_proc_interval')
        if interval <= 0 then interval = 0.2 end
        if (now - self.last_boss_proc) < interval then self.attack_counter = required - 1; return end
        self.last_boss_proc = now
    end
    self.attack_counter = 0

    c:StartGesture(ACT_DOTA_CAST_ABILITY_3)
    c:EmitSound('Hero_Axe.CounterHelix')
    effect('particles/units/heroes/hero_axe/axe_counterhelix.vpcf', c)

    local base_dmg = value(a, 'helix_damage')
    if base_dmg <= 0 then base_dmg = 150 end
    local str = get_str(c)
    local dmg = base_dmg + (str * value(a, 'strength_damage_factor'))
    local r = value(a, 'radius')
    if r <= 0 then r = 300 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        damage(a, u, dmg, DAMAGE_TYPE_PURE)
    end
end

enfos_axe_culling_blade=class({})
function enfos_axe_culling_blade:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    local creep_pct = value(self, 'kill_threshold_pct')
    if creep_pct <= 0 then creep_pct = 35 end
    local boss_pct = value(self, 'boss_kill_threshold_pct')
    if boss_pct <= 0 then boss_pct = 15 end
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
        for _, u in ipairs(allies(c, c:GetAbsOrigin(), value(self, 'success_buff_radius'))) do
            u:AddNewModifier(c, self, 'modifier_enfos_axe_culling_blade_buff', { duration = value(self, 'speed_duration') })
        end
    else
        t:EmitSound('Hero_Axe.Culling_Blade_Fail')
        local hit_position = t:GetAbsOrigin()
        local sparks = ParticleManager:CreateParticle('particles/units/heroes/hero_axe/axe_culling_blade_hit_sparks.vpcf', PATTACH_WORLDORIGIN, c)
        ParticleManager:SetParticleControl(sparks, 0, hit_position)
        ParticleManager:SetParticleControl(sparks, 4, hit_position)
        ParticleManager:ReleaseParticleIndex(sparks)
        local base_dmg = value(self, 'damage')
        if base_dmg <= 0 then base_dmg = 350 end
    local str = get_str(c)
        local dmg = base_dmg + (str * value(self, 'strength_damage_factor'))
        damage(self, t, dmg, DAMAGE_TYPE_PURE)
    end
end

modifier_enfos_axe_culling_blade_buff=class({})
function modifier_enfos_axe_culling_blade_buff:GetTexture() return 'axe_culling_blade' end
function modifier_enfos_axe_culling_blade_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_axe_culling_blade_buff:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'success_bonus_movespeed_pct') end
function modifier_enfos_axe_culling_blade_buff:GetModifierAttackSpeedBonus_Constant() return value(self:GetAbility(), 'success_bonus_attack_speed') end

enfos_axe_blood_armor=class({})
function enfos_axe_blood_armor:GetIntrinsicModifierName() return 'modifier_enfos_axe_blood_armor_passive' end

modifier_enfos_axe_blood_armor_passive=class({})
function modifier_enfos_axe_blood_armor_passive:GetTexture() return 'axe_foreboding' end
function modifier_enfos_axe_blood_armor_passive:IsPurgable() return false end
function modifier_enfos_axe_blood_armor_passive:IsDebuff() return false end
function modifier_enfos_axe_blood_armor_passive:IsPermanent() return true end
function modifier_enfos_axe_blood_armor_passive:RemoveOnDeath() return false end
function modifier_enfos_axe_blood_armor_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end
function modifier_enfos_axe_blood_armor_passive:OnCreated()
    self.creep_kills = self.creep_kills or 0
    self.stacks = self.stacks or 0
end
function modifier_enfos_axe_blood_armor_passive:GetModifierPhysicalArmorBonus()
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_armor')) or 8
    return base + self:GetStackCount() * value(self:GetAbility(), 'armor_per_stack')
end
function modifier_enfos_axe_blood_armor_passive:GetModifierConstantHealthRegen()
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_health_regen')) or 20
    return base + self:GetStackCount() * value(self:GetAbility(), 'health_regen_per_stack')
end
function modifier_enfos_axe_blood_armor_passive:OnDeath(params)
    if not IsServer() then return end
    if not params then return end
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return end
    if params.attacker ~= c then return end
    local dead = params.unit
    if not dead then return end
    if dead.GetTeamNumber and dead:GetTeamNumber() == c:GetTeamNumber() then return end
    local ability = self:GetAbility()
    if not ability or (ability.IsNull and ability:IsNull()) then return end
    local cap = value(ability, 'stack_cap')
    if cap <= 0 then cap = 50 end
    local kills_per_stack = value(ability, 'creep_kills_per_stack')
    if kills_per_stack <= 0 then kills_per_stack = 10 end
    if is_boss(dead) then
        self.stacks = math.min(cap, (self.stacks or 0) + 1)
        self:SetStackCount(self.stacks)
    else
        self.creep_kills = (self.creep_kills or 0) + 1
        if self.creep_kills >= kills_per_stack then
            self.creep_kills = 0
            self.stacks = math.min(cap, (self.stacks or 0) + 1)
            self:SetStackCount(self.stacks)
        end
    end
end
function modifier_enfos_axe_blood_armor_passive:OnTakeDamage(params)
    if not IsServer() then return end
    if not params then return end
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return end
    if params.unit ~= c then return end
    local attacker = params.attacker
    if not attacker or attacker == c or (attacker.IsNull and attacker:IsNull()) or not attacker:IsAlive() then return end
    if attacker.GetTeamNumber and c.GetTeamNumber and attacker:GetTeamNumber() == c:GetTeamNumber() then return end
    if bit and bit.band and bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0 then return end
    local ability = self:GetAbility()
    if not ability or (ability.IsNull and ability:IsNull()) then return end
    if params.damage_type == DAMAGE_TYPE_PHYSICAL and params.original_damage and params.original_damage > 0 then
        local refl = params.original_damage * value(ability, 'physical_damage_reflect_pct') / 100
        ApplyDamage({
            victim = attacker,
            attacker = c,
            ability = ability,
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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local r = value(self, 'radius')
    if r <= 0 then r = 350 end
    local dur = value(self, 'stun_duration')
    if dur <= 0 then dur = 2.0 end
    local base_dmg = value(self, 'damage')
    if base_dmg <= 0 then base_dmg = 200 end
    local str = get_str(c)
    local boss_stun_pct = value(self, 'boss_stun_pct')
    if boss_stun_pct <= 0 then boss_stun_pct = 40 end
    local dmg = base_dmg + (str * value(self, 'strength_damage_factor'))

    c:EmitSound('Hero_Centaur.HoofStomp')
    effect('particles/units/heroes/hero_centaur/centaur_warstomp.vpcf', c)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        local target_dur = dur
        if is_boss(u) then target_dur = dur * boss_stun_pct / 100 end
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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    local base_dmg = value(self, 'edge_damage')
    if base_dmg <= 0 then base_dmg = 250 end
    local str = get_str(c)
    local hp = c.GetMaxHealth and c:GetMaxHealth() or 1000
    local dmg = base_dmg + (str * value(self, 'strength_damage_factor')) + (hp * value(self, 'max_health_damage_pct') / 100)

    c:EmitSound('Hero_Centaur.DoubleEdge')
    effect('particles/units/heroes/hero_centaur/centaur_double_edge.vpcf', t)

    local self_dmg = dmg * value(self, 'self_damage_pct') / 100
    local minimum_health = value(self, 'minimum_health')
    if minimum_health <= 0 then minimum_health = 1 end
    if c:GetHealth() - self_dmg >= minimum_health then
        c:SetHealth(c:GetHealth() - self_dmg)
    else
        c:SetHealth(minimum_health)
    end

    local radius = value(self, 'radius')
    if radius <= 0 then radius = 250 end
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        damage(self, u, dmg, DAMAGE_TYPE_PURE)
    end
end

enfos_centaur_return=class({})
function enfos_centaur_return:GetIntrinsicModifierName() return 'modifier_enfos_centaur_return_passive' end

modifier_enfos_centaur_return_passive=class({})
function modifier_enfos_centaur_return_passive:IsPurgable() return false end
function modifier_enfos_centaur_return_passive:IsDebuff() return false end
function modifier_enfos_centaur_return_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_TAKEDAMAGE } end
function modifier_enfos_centaur_return_passive:OnCreated()
    self.accumulated_damage = self.accumulated_damage or 0
end
function modifier_enfos_centaur_return_passive:OnTakeDamage(params)
    if not IsServer() then return end
    if not params then return end
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    if params.unit ~= c then return end
    local attacker = params.attacker
    if not attacker or attacker == c or (attacker.IsNull and attacker:IsNull()) or not attacker:IsAlive() then return end
    if attacker.GetTeamNumber and c.GetTeamNumber and attacker:GetTeamNumber() == c:GetTeamNumber() then return end
    if bit and bit.band and bit.band(params.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0 then return end

    local a = self:GetAbility()
    local flat = (a and value(a, 'return_damage')) or 40
    local str = get_str(c)
    local refl = flat + (str * value(a, 'strength_damage_factor'))

    ApplyDamage({
        victim = attacker,
        attacker = c,
        ability = a,
        damage = refl,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION or 16
    })

    self.accumulated_damage = (self.accumulated_damage or 0) + (params.damage or 0)
    local threshold = value(a, 'pulse_damage_threshold')
    if threshold <= 0 then threshold = 300 end
    if self.accumulated_damage >= threshold then
        self.accumulated_damage = 0
        effect('particles/units/heroes/hero_centaur/centaur_return.vpcf', c)
        local radius = value(a, 'pulse_radius')
        if radius <= 0 then radius = 250 end
        for _, u in ipairs(enemies(c, c:GetAbsOrigin(), radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
            damage(a, u, refl, DAMAGE_TYPE_PHYSICAL)
        end
    end
end

enfos_centaur_stampede=class({})
function enfos_centaur_stampede:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Centaur.Stampede.Cast')
    effect('particles/units/heroes/hero_centaur/centaur_stampede_cast.vpcf', c)
    for _, ally in ipairs(allies(c, c:GetAbsOrigin(), 99999)) do
        if ally:IsHero() then
            ally:AddNewModifier(c, self, 'modifier_enfos_centaur_stampede_buff', { duration = value(self, 'duration') })
        end
    end
end

modifier_enfos_centaur_stampede_buff=class({})
function modifier_enfos_centaur_stampede_buff:IsPurgable() return false end
function modifier_enfos_centaur_stampede_buff:GetEffectName() return 'particles/units/heroes/hero_centaur/centaur_stampede_haste.vpcf' end
function modifier_enfos_centaur_stampede_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end
function modifier_enfos_centaur_stampede_buff:GetModifierMoveSpeed_Absolute() return value(self:GetAbility(), 'movespeed') end
function modifier_enfos_centaur_stampede_buff:GetModifierIncomingDamage_Percentage() return value(self:GetAbility(), 'incoming_damage_pct') end
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
    local dmg = value(a, 'trample_damage') + (str * value(a, 'strength_damage_factor'))

    local radius = value(a, 'trample_radius')
    for _, u in ipairs(enemies(c, p:GetAbsOrigin(), radius)) do
        local id = u:entindex()
        if not self.trampled[id] then
            self.trampled[id] = true
            damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL)
            u:AddNewModifier(c, a, 'modifier_enfos_centaur_stampede_slow', { duration = value(a, 'slow_duration') })
        end
    end
end

modifier_enfos_centaur_stampede_slow=class({})
function modifier_enfos_centaur_stampede_slow:IsDebuff() return true end
function modifier_enfos_centaur_stampede_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_centaur_stampede_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

enfos_centaur_colossal_hide=class({})
function enfos_centaur_colossal_hide:GetIntrinsicModifierName() return 'modifier_enfos_centaur_colossal_hide_passive' end

modifier_enfos_centaur_colossal_hide_passive=class({})
function modifier_enfos_centaur_colossal_hide_passive:IsPurgable() return false end
function modifier_enfos_centaur_colossal_hide_passive:IsDebuff() return false end
function modifier_enfos_centaur_colossal_hide_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE }
end
function modifier_enfos_centaur_colossal_hide_passive:GetModifierPhysical_ConstantBlock()
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'damage_block')) or 40
    return base + (str * value(self:GetAbility(), 'strength_block_factor'))
end
function modifier_enfos_centaur_colossal_hide_passive:GetModifierExtraHealthPercentage()
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'bonus_health_pct')
end

-- ----------------------------------------------------------------------------
-- LEGION COMMANDER: OVERWHELMING ODDS, PRESS THE ATTACK, MOMENT OF COURAGE, DUEL, COMMANDER'S BANNER
-- ----------------------------------------------------------------------------

enfos_legion_overwhelming_odds=class({})
function enfos_legion_overwhelming_odds:OnSpellStart()
    local c = self:GetCaster()
    local point = self:GetCursorPosition()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not point then return end
    local r = value(self, 'radius')
    if r <= 0 then r = 600 end
    local base_dmg = value(self, 'damage')
    if base_dmg <= 0 then base_dmg = 180 end
    local creep_bonus = value(self, 'damage_per_unit')
    if creep_bonus <= 0 then creep_bonus = 35 end

    c:EmitSound('Hero_LegionCommander.Overwhelming.Cast')
    EmitSoundOnLocationWithCaster(point, 'Hero_LegionCommander.Overwhelming.Location', c)
    local odds_particle = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_legion_commander/legion_commander_odds.vpcf', PATTACH_WORLDORIGIN, c)
    ParticleManager:SetParticleControl(odds_particle, 0, point)
    -- The native rune children use CP4.x for radius; auxiliary components stay zero.
    ParticleManager:SetParticleControl(odds_particle, 4, Vector(r, 0, 0))
    ParticleManager:ReleaseParticleIndex(odds_particle)

    local hit_units = enemies(c, point, r)
    local creep_count = 0
    local hero_or_boss_count = 0
    for _, u in ipairs(hit_units) do
        if is_boss(u) or u:IsHero() then hero_or_boss_count = hero_or_boss_count + 1 else creep_count = creep_count + 1 end
    end

    local hero_or_boss_bonus = value(self, 'damage_per_hero_or_boss')
    if hero_or_boss_bonus <= 0 then hero_or_boss_bonus = 100 end
    local total_dmg = base_dmg + (creep_count * creep_bonus) + (hero_or_boss_count * hero_or_boss_bonus)
    for _, u in ipairs(hit_units) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end

    local total_as = (creep_count * value(self, 'attack_speed_per_creep'))
        + (hero_or_boss_count * value(self, 'attack_speed_per_hero_or_boss'))
    local total_ms = math.min(value(self, 'movespeed_cap'),
        (creep_count * value(self, 'movespeed_per_creep'))
        + (hero_or_boss_count * value(self, 'movespeed_per_hero_or_boss')))
    c:AddNewModifier(c, self, 'modifier_enfos_legion_overwhelming_odds_buff', {
        duration = value(self, 'buff_duration'),
        bonus_as = total_as,
        bonus_ms = total_ms
    })
end

modifier_enfos_legion_overwhelming_odds_buff=class({})
function modifier_enfos_legion_overwhelming_odds_buff:GetTexture() return 'legion_commander_overwhelming_odds' end
function modifier_enfos_legion_overwhelming_odds_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_legion_overwhelming_odds_buff:OnCreated(kv)
    self.bonus_as = 0
    self.bonus_ms = 0
    if not IsServer() then return end
    self:SetHasCustomTransmitterData(true)
    self.bonus_as = tonumber(kv and kv.bonus_as) or 0
    self.bonus_ms = tonumber(kv and kv.bonus_ms) or 0
end
function modifier_enfos_legion_overwhelming_odds_buff:OnRefresh(kv)
    if not IsServer() then return end
    self.bonus_as = tonumber(kv and kv.bonus_as) or 0
    self.bonus_ms = tonumber(kv and kv.bonus_ms) or 0
    self:SendBuffRefreshToClients()
end
function modifier_enfos_legion_overwhelming_odds_buff:AddCustomTransmitterData()
    return { bonus_as = self.bonus_as, bonus_ms = self.bonus_ms }
end
function modifier_enfos_legion_overwhelming_odds_buff:HandleCustomTransmitterData(data)
    self.bonus_as = data.bonus_as or 0
    self.bonus_ms = data.bonus_ms or 0
end
function modifier_enfos_legion_overwhelming_odds_buff:GetModifierAttackSpeedBonus_Constant() return self.bonus_as end
function modifier_enfos_legion_overwhelming_odds_buff:GetModifierMoveSpeedBonus_Percentage() return self.bonus_ms end

enfos_legion_press_the_attack=class({})
function enfos_legion_press_the_attack:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget() or c
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() ~= c:GetTeamNumber() then return end
    if t.Purge then t:Purge(false, true, false, true, true) end
    t:EmitSound('Hero_LegionCommander.PressTheAttack')
    t:AddNewModifier(c, self, 'modifier_enfos_legion_press_the_attack_buff', { duration = value(self, 'duration') })
end

modifier_enfos_legion_press_the_attack_buff=class({})
function modifier_enfos_legion_press_the_attack_buff:GetTexture() return 'legion_commander_press_the_attack' end
function modifier_enfos_legion_press_the_attack_buff:OnCreated()
    if not IsServer() or self.press_particle then return end
    local parent = self:GetParent()
    self.press_particle = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf', PATTACH_ABSORIGIN_FOLLOW, parent)
    for cp, name in ipairs({ 'attach_hitloc', 'attach_attack1', 'attach_attack2' }) do
        local has_attachment = parent.ScriptLookupAttachment and parent:ScriptLookupAttachment(name) > 0
        ParticleManager:SetParticleControlEnt(self.press_particle, cp, parent,
            has_attachment and PATTACH_POINT_FOLLOW or PATTACH_ABSORIGIN_FOLLOW,
            has_attachment and name or '', parent:GetAbsOrigin(), true)
    end
    self:AddParticle(self.press_particle, false, false, -1, false, false)
end
function modifier_enfos_legion_press_the_attack_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_legion_press_the_attack_buff:GetModifierConstantHealthRegen()
    local c = self:GetCaster()
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'hp_regen')) or 60
    return base + (str * value(self:GetAbility(), 'strength_regen_factor'))
end
function modifier_enfos_legion_press_the_attack_buff:GetModifierAttackSpeedBonus_Constant()
    return (self.GetAbility and value(self:GetAbility(), 'bonus_attack_speed')) or 80
end

enfos_legion_moment_of_courage=class({})
function enfos_legion_moment_of_courage:GetIntrinsicModifierName() return 'modifier_enfos_legion_moment_of_courage_passive' end

modifier_enfos_legion_moment_of_courage_passive=class({})
function modifier_enfos_legion_moment_of_courage_passive:GetTexture() return 'legion_commander_moment_of_courage' end
function modifier_enfos_legion_moment_of_courage_passive:IsPurgable() return false end
function modifier_enfos_legion_moment_of_courage_passive:IsDebuff() return false end
function modifier_enfos_legion_moment_of_courage_passive:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACKED, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_legion_moment_of_courage_passive:OnCreated()
    self.last_boss_proc = 0
    self.proc_active = false
end
function modifier_enfos_legion_moment_of_courage_passive:OnAttacked(params)
    if not IsServer() then return end
    if not params or self.proc_active then return end
    local c = self:GetParent()
    if params.target ~= c or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    local a = self:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or not c:IsAlive() then return end

    local chance = value(a, 'trigger_chance')
    if chance <= 0 then chance = 25 end
    if not RollPercentage(chance) then return end

    local attacker = params.attacker
    if not attacker or (attacker.IsNull and attacker:IsNull()) or not attacker:IsAlive() then return end
    if attacker.GetTeamNumber and c.GetTeamNumber and attacker:GetTeamNumber() == c:GetTeamNumber() then return end
    if attacker and is_boss(attacker) then
        local now = (GameRules and GameRules.GetGameTime) and GameRules:GetGameTime() or 0
        local interval = value(a, 'boss_proc_interval')
        if interval <= 0 then interval = 0.4 end
        if (now - self.last_boss_proc) < interval then return end
        self.last_boss_proc = now
    end

    c:EmitSound('Hero_LegionCommander.Courage')
    effect('particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf', c)

    if attacker and not attacker:IsNull() and attacker:IsAlive() then
        self.proc_active = true
        if c.PerformAttack then
            self.proc_target = attacker
            c:PerformAttack(attacker, true, true, true, false, false, false, true)
        end
        self.proc_active = false
        self.proc_target = nil
    end
end
function modifier_enfos_legion_moment_of_courage_passive:OnTakeDamage(params)
    if not IsServer() then return end
    if not params then return end
    local c = self:GetParent()
    if not (c.PassivesDisabled and c:PassivesDisabled()) and params.attacker == c
        and params.unit == self.proc_target and self.proc_active
        and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and params.damage and params.damage > 0 then
        local heal = params.damage * value(self:GetAbility(), 'proc_lifesteal_pct') / 100
        c:Heal(heal, self:GetAbility())
    end
end

enfos_legion_duel=class({})
function enfos_legion_duel:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 4.5 end

    c:EmitSound('Hero_LegionCommander.Duel.Cast')
    -- End any previous pair before replacing either participant's modifier.
    for _, participant in ipairs({ c, t }) do
        local old_duel = participant:FindModifierByName('modifier_enfos_legion_duel_buff')
        if old_duel then old_duel:Destroy() end
    end
    c:AddNewModifier(c, self, 'modifier_enfos_legion_duel_buff', { duration = dur, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_legion_duel_buff', { duration = dur, target_idx = c:entindex() })
end

modifier_enfos_legion_duel_buff=class({})
function modifier_enfos_legion_duel_buff:GetTexture() return 'legion_commander_duel' end
function modifier_enfos_legion_duel_buff:GetEffectName() return 'particles/units/heroes/hero_legion_commander/legion_commander_duel_buff.vpcf' end
function modifier_enfos_legion_duel_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_legion_duel_buff:IsPurgable() return false end
function modifier_enfos_legion_duel_buff:IsDebuff() return self:GetParent() ~= self:GetCaster() end
function modifier_enfos_legion_duel_buff:CheckState()
    return { [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_TAUNTED] = true, [MODIFIER_STATE_COMMAND_RESTRICTED] = true }
end
function modifier_enfos_legion_duel_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_TOOLTIP }
end
function modifier_enfos_legion_duel_buff:OnTooltip() return value(self:GetAbility(), 'outside_duel_damage_reduction_pct') end
function modifier_enfos_legion_duel_buff:OnCreated(kv)
    self.target_idx = kv and kv.target_idx
    if not IsServer() then return end
    local parent = self:GetParent()
    self.parent_idx = parent:entindex()
    self.target = self.target_idx and EntIndexToHScript(self.target_idx)
    if not self.target or self.target:IsNull() or not self.target:IsAlive() or not parent:IsAlive() then
        self:Destroy()
        return
    end
    parent:SetForceAttackTarget(self.target)
    parent:MoveToTargetToAttack(self.target)
    if parent == self:GetCaster() then
        local origin = parent:GetAbsOrigin()
        local ring = ParticleManager:CreateParticle(
            'particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf', PATTACH_WORLDORIGIN, parent)
        ParticleManager:SetParticleControl(ring, 0, origin)
        ParticleManager:SetParticleControl(ring, 7, origin)
        self:AddParticle(ring, false, false, -1, false, false)
    end
end
function modifier_enfos_legion_duel_buff:OnDestroy()
    if not IsServer() or self.ending then return end
    self.ending = true
    local parent = self:GetParent()
    if not parent:IsNull() and parent:GetForceAttackTarget() == self.target then
        parent:SetForceAttackTarget(nil)
    end
    local target = self.target
    if not target or target:IsNull() then return end
    local partner = target:FindModifierByNameAndCaster('modifier_enfos_legion_duel_buff', self:GetCaster())
    if partner and not partner.ending and partner.target_idx == self.parent_idx then
        partner:Destroy()
    end
end
function modifier_enfos_legion_duel_buff:GetModifierIncomingDamage_Percentage(params)
    if params.attacker and params.attacker:entindex() ~= self.target_idx then
        return -value(self:GetAbility(), 'outside_duel_damage_reduction_pct')
    end
    return 0
end
function modifier_enfos_legion_duel_buff:OnDeath(params)
    if not IsServer() or self.ending or not params or not params.unit then return end
    local parent = self:GetParent()
    if params.unit ~= parent and params.unit:entindex() ~= self.target_idx then return end
    local c = self:GetCaster()
    local owner_duel = c and not c:IsNull() and c:FindModifierByNameAndCaster('modifier_enfos_legion_duel_buff', c)
    if owner_duel and not owner_duel.ending and not owner_duel.rewarded and c:IsAlive()
        and params.unit:entindex() == owner_duel.target_idx and params.unit ~= c then
        owner_duel.rewarded = true
        local bonus = value(self:GetAbility(), is_boss(params.unit) and 'boss_victory_strength' or 'creep_victory_strength')
        c:EmitSound('Hero_LegionCommander.Duel.Victory')
        effect('particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf', c)
        if c.ModifyStrength then c:ModifyStrength(bonus) end
    end
    self:Destroy()
end

enfos_legion_commanders_banner=class({})
function enfos_legion_commanders_banner:GetIntrinsicModifierName() return 'modifier_enfos_legion_commanders_banner_aura' end

modifier_enfos_legion_commanders_banner_aura=class({})
function modifier_enfos_legion_commanders_banner_aura:IsHidden() return true end
function modifier_enfos_legion_commanders_banner_aura:IsPurgable() return false end
function modifier_enfos_legion_commanders_banner_aura:IsAura()
    local c = self:GetParent()
    return not (c and c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_legion_commanders_banner_aura:GetAuraRadius() return value(self:GetAbility(), 'aura_radius') end
function modifier_enfos_legion_commanders_banner_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_legion_commanders_banner_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_legion_commanders_banner_aura:GetModifierAura() return 'modifier_enfos_legion_commanders_banner_buff' end

modifier_enfos_legion_commanders_banner_buff=class({})
function modifier_enfos_legion_commanders_banner_buff:GetTexture() return 'legion_commander_press_the_attack' end
function modifier_enfos_legion_commanders_banner_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_legion_commanders_banner_buff:GetModifierBaseDamageOutgoing_Percentage()
    local c = self:GetCaster()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    local is_owner = self:GetParent() == self:GetCaster()
    local a = self:GetAbility()
    return value(a, is_owner and 'owner_bonus_damage_pct' or 'bonus_damage_pct')
end
function modifier_enfos_legion_commanders_banner_buff:OnAttackLanded(params)
    if not IsServer() then return end
    local p = self:GetParent()
    local c = self:GetCaster()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return end
    if params.attacker == p and params.target and params.target:GetTeamNumber() ~= p:GetTeamNumber()
        and params.damage and params.damage > 0 then
        local a = self:GetAbility()
        local pct = value(a, p == self:GetCaster() and 'owner_lifesteal_pct' or 'lifesteal_pct')
        p:Heal(params.damage * pct / 100, a)
    end
end

-- ----------------------------------------------------------------------------
-- SNIPER: SHRAPNEL, HEADSHOT, TAKE AIM, ASSASSINATE, KEEN EYE
-- ----------------------------------------------------------------------------

enfos_sniper_shrapnel=class({})
function enfos_sniper_shrapnel:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not pos then return end
    local r = value(self, 'radius')
    if r <= 0 then r = 450 end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 8.0 end

    c:EmitSound('Hero_Sniper.ShrapnelShoot')
    ground_effect(c, self, 'modifier_enfos_sniper_shrapnel_thinker', { duration = dur, radius = r }, pos)
end

modifier_enfos_sniper_shrapnel_thinker=class({})
function modifier_enfos_sniper_shrapnel_thinker:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() then parent:StopSound('Hero_Sniper.ShrapnelShatter') end
    remove_ground_effect(self)
end
function modifier_enfos_sniper_shrapnel_thinker:OnCreated(kv)
    if not IsServer() then return end
    self.radius = (kv and kv.radius) or 450
    self:StartIntervalThink(1.0)
    local origin = self:GetParent():GetAbsOrigin()
    local particle = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf', PATTACH_WORLDORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, 0, 0))
    ParticleManager:SetParticleControl(particle, 2, origin)
    self:AddParticle(particle, false, false, -1, false, false)
    self:GetParent():EmitSound('Hero_Sniper.ShrapnelShatter')
end
function modifier_enfos_sniper_shrapnel_thinker:OnIntervalThink()
    if not IsServer() then return end
    local c = self:GetCaster()
    local a = self:GetAbility()
    local p = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or not a or (a.IsNull and a:IsNull())
        or not p or (p.IsNull and p:IsNull()) then
        self:Destroy()
        return
    end
    local agi = get_agi(c)
    local base = (a and value(a, 'shrapnel_damage')) or 75
    local dmg = base + (agi * 0.35)

    for _, u in ipairs(enemies(c, p:GetAbsOrigin(), self.radius)) do
        damage(a, u, dmg, DAMAGE_TYPE_PHYSICAL)
        if u and not u:IsNull() and u:IsAlive() then
            u:AddNewModifier(c, a, 'modifier_enfos_sniper_shrapnel_slow', { duration = 1.0 })
        end
    end
end

modifier_enfos_sniper_shrapnel_slow=class({})
function modifier_enfos_sniper_shrapnel_slow:GetTexture() return 'sniper_shrapnel' end
function modifier_enfos_sniper_shrapnel_slow:IsDebuff() return true end
function modifier_enfos_sniper_shrapnel_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_sniper_shrapnel_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

enfos_sniper_headshot=class({})
function enfos_sniper_headshot:GetIntrinsicModifierName() return 'modifier_enfos_sniper_headshot_passive' end

modifier_enfos_sniper_headshot_passive=class({})
function modifier_enfos_sniper_headshot_passive:GetTexture() return 'sniper_headshot' end
function modifier_enfos_sniper_headshot_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_sniper_headshot_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if not params then return end
    local c = self:GetParent()
    if params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    local t = params.target
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end

    local a = self:GetAbility()
    local chance = value(a, 'proc_chance')
    if chance <= 0 then chance = 40 end
    if c:HasModifier('modifier_enfos_sniper_take_aim_buff') then
        chance = value(a, 'take_aim_proc_chance')
        if chance <= 0 then chance = 80 end
    end
    if not RollPercentage(chance) then return end

    c:EmitSound('Hero_Sniper.HeadShot')
    local base = (a and value(a, 'headshot_damage')) or 120
    local agi = get_agi(c)
    local dmg = base + (agi * 0.75)
    damage(a, t, dmg, DAMAGE_TYPE_PHYSICAL)

    if t:IsAlive() and not is_boss(t) and t.SetAbsOrigin then
        local fv = (t:GetAbsOrigin() - c:GetAbsOrigin()):Normalized()
        local destination = t:GetAbsOrigin() + fv * value(a, 'knockback_distance')
        if FindClearSpaceForUnit then FindClearSpaceForUnit(t, destination, true) else t:SetAbsOrigin(destination) end
    end
end

enfos_sniper_take_aim=class({})
function enfos_sniper_take_aim:GetIntrinsicModifierName() return 'modifier_enfos_sniper_take_aim_passive' end
function enfos_sniper_take_aim:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Sniper.TakeAim.Cast')
    c:AddNewModifier(c, self, 'modifier_enfos_sniper_take_aim_buff', { duration = value(self, 'duration') })
end

modifier_enfos_sniper_take_aim_passive=class({})
function modifier_enfos_sniper_take_aim_passive:GetTexture() return 'sniper_take_aim' end
function modifier_enfos_sniper_take_aim_passive:IsHidden() return true end
function modifier_enfos_sniper_take_aim_passive:DeclareFunctions() return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS } end
function modifier_enfos_sniper_take_aim_passive:GetModifierAttackRangeBonus()
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'bonus_range')) or 300
end

modifier_enfos_sniper_take_aim_buff=class({})
function modifier_enfos_sniper_take_aim_buff:IsPurgable() return true end
function modifier_enfos_sniper_take_aim_buff:GetTexture() return 'sniper_take_aim' end
function modifier_enfos_sniper_take_aim_buff:GetEffectName() return 'particles/units/heroes/hero_sniper/sniper_take_aim_overhead.vpcf' end
function modifier_enfos_sniper_take_aim_buff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_enfos_sniper_take_aim_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_sniper_take_aim_buff:CheckState() return { [MODIFIER_STATE_CANNOT_MISS] = true } end
function modifier_enfos_sniper_take_aim_buff:GetModifierMoveSpeedBonus_Percentage()
    return value(self:GetAbility(), 'bonus_movespeed_pct')
end

enfos_sniper_assassinate=class({})
function enfos_sniper_assassinate:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end

    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Ability.Assassinate')
    ProjectileManager:CreateTrackingProjectile({
        Target = t,
        Source = c,
        Ability = self,
        EffectName = 'particles/units/heroes/hero_sniper/sniper_assassinate.vpcf',
        iMoveSpeed = value(self, 'projectile_speed'),
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false
    })
end

function enfos_sniper_assassinate:OnProjectileHit(t, location)
    if not t or t:IsNull() or not t:IsAlive() then return true end
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return true end
    local origin = t:GetAbsOrigin()
    local particle = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_sniper/sniper_assassinate_impact_sparks.vpcf', PATTACH_WORLDORIGIN, c)
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, origin)
    ParticleManager:ReleaseParticleIndex(particle)
    t:EmitSound('Hero_Sniper.AssassinateDamage')
    local damage_amount = value(self, 'damage') + get_agi(c) * value(self, 'agility_damage_factor')
    damage(self, t, damage_amount, DAMAGE_TYPE_PHYSICAL)
    if not t:IsAlive() then
        self:EndCooldown()
        if c.GiveMana and self.GetManaCost then c:GiveMana(self:GetManaCost(-1) * 0.5) end
    end
    return true
end

enfos_sniper_keen_eye=class({})
function enfos_sniper_keen_eye:GetIntrinsicModifierName() return 'modifier_enfos_sniper_keen_eye_passive' end

modifier_enfos_sniper_keen_eye_passive=class({})
function modifier_enfos_sniper_keen_eye_passive:GetTexture() return 'sniper_take_aim' end
function modifier_enfos_sniper_keen_eye_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_sniper_keen_eye_passive:OnAttackLanded(params)
    if not IsServer() then return end
    if not params then return end
    local c = self:GetParent()
    if not c or params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) then return end
    local t = params.target
    -- A lethal landed attack still supplies a valid impact position for piercing.
    if not t or (t.IsNull and t:IsNull()) then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end

    local origin = t:GetAbsOrigin()
    local dir = (origin - c:GetAbsOrigin()):Normalized()
    if dir:Length2D() <= 0 and c.GetForwardVector then dir = c:GetForwardVector() end
    local a = self:GetAbility()
    if not a or (a.IsNull and a:IsNull()) then return end
    local distance = math.max(0, value(a, 'pierce_distance'))
    local width = math.max(0, value(a, 'pierce_width'))
    local max_targets = math.max(0, math.floor(value(a, 'max_pierced_targets')))
    if distance <= 0 or width <= 0 or max_targets <= 0 then return end
    local broadphase_radius = math.sqrt((distance * 0.5)^2 + (width * 0.5)^2)
    local candidates = enemies(c, origin + (dir * (distance * 0.5)), broadphase_radius,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
    local pierced = {}
    for _, u in ipairs(candidates) do
        if u ~= t and u and not (u.IsNull and u:IsNull()) and u:IsAlive() then
            local offset = u:GetAbsOrigin() - origin
            local along = offset.x * dir.x + offset.y * dir.y
            local lateral = (offset - (dir * along)):Length2D()
            if along > 0 and along <= distance and lateral <= width * 0.5 then
                table.insert(pierced, { unit = u, distance = along })
            end
        end
    end
    table.sort(pierced, function(left, right) return left.distance < right.distance end)
    local pierce_pct = value(a, 'pierce_damage_pct')
    local attack_dmg = (params.damage or 100) * (pierce_pct / 100)
    for index = 1, math.min(max_targets, #pierced) do
        damage(a, pierced[index].unit, attack_dmg, DAMAGE_TYPE_PHYSICAL)
    end
end

-- ----------------------------------------------------------------------------
-- CRYSTAL MAIDEN: CRYSTAL NOVA, FROSTBITE, ARCANE AURA, FREEZING FIELD, GLACIAL MASTERY
-- ----------------------------------------------------------------------------

enfos_cm_crystal_nova=class({})
function enfos_cm_crystal_nova:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not pos then return end
    local r = value(self, 'radius')
    if r <= 0 then r = 425 end
    local base = value(self, 'damage')
    if base <= 0 then base = 250 end
    local int = get_int(c)
    local dmg = base + (int * value(self, 'int_damage_factor'))

    c:EmitSound('Hero_Crystal.CrystalNova')
    effect_at_position('particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf', pos)

    for _, u in ipairs(enemies(c, pos, r)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_cm_crystal_nova_slow', { duration = value(self, 'duration') })
        local gm = c:FindAbilityByName('enfos_cm_glacial_mastery')
        if gm and not (c.PassivesDisabled and c:PassivesDisabled()) then
            u:AddNewModifier(c, gm, 'modifier_enfos_cm_frost_stack', { duration = value(gm, 'frost_stack_duration') })
        end
    end
end

modifier_enfos_cm_crystal_nova_slow=class({})
function modifier_enfos_cm_crystal_nova_slow:IsDebuff() return true end
function modifier_enfos_cm_crystal_nova_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_cm_crystal_nova_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_cm_crystal_nova_slow:GetModifierAttackSpeedBonus_Constant() return -value(self:GetAbility(), 'attack_slow') end

enfos_cm_frostbite=class({})
function enfos_cm_frostbite:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Crystal.Frostbite')
    t:AddNewModifier(c, self, 'modifier_enfos_cm_frostbite_debuff', { duration = value(self, 'duration') })
end

modifier_enfos_cm_frostbite_debuff=class({})
function modifier_enfos_cm_frostbite_debuff:GetEffectName() return 'particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf' end
function modifier_enfos_cm_frostbite_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_cm_frostbite_debuff:IsDebuff() return true end
function modifier_enfos_cm_frostbite_debuff:CheckState()
    return { [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true }
end
function modifier_enfos_cm_frostbite_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(value(self:GetAbility(), 'damage_interval'))
end
function modifier_enfos_cm_frostbite_debuff:OnIntervalThink()
    local p = self:GetParent()
    local a = self:GetAbility()
    local c = self:GetCaster()
    local int = get_int(c)
    local base = (a and value(a, 'damage_per_second')) or 120
    local interval = value(a, 'damage_interval')
    local dmg = (base + (int * value(a, 'int_damage_factor'))) * interval
    if not is_boss(p) and not p:IsHero() then
        dmg = dmg * value(a, 'creep_damage_multiplier')
    end
    damage(a, p, dmg, DAMAGE_TYPE_MAGICAL)
    local gm = c and c.FindAbilityByName and c:FindAbilityByName('enfos_cm_glacial_mastery')
    if c and c.PassivesDisabled and c:PassivesDisabled() then gm = nil end
    if gm then
        p:AddNewModifier(c, gm, 'modifier_enfos_cm_frost_stack', { duration = value(gm, 'frost_stack_duration') })
    end
end

enfos_cm_arcane_aura=class({})
function enfos_cm_arcane_aura:GetIntrinsicModifierName() return 'modifier_enfos_cm_arcane_aura' end

modifier_enfos_cm_arcane_aura=class({})
function modifier_enfos_cm_arcane_aura:IsHidden() return true end
function modifier_enfos_cm_arcane_aura:IsPurgable() return false end
function modifier_enfos_cm_arcane_aura:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_enfos_cm_arcane_aura:IsAura()
    local c = self:GetParent()
    return not (c and c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_cm_arcane_aura:GetAuraEntityReject(unit)
    return unit == self:GetParent()
end
function modifier_enfos_cm_arcane_aura:GetAuraRadius() return value(self:GetAbility(), 'aura_radius') end
function modifier_enfos_cm_arcane_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_cm_arcane_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_cm_arcane_aura:GetModifierAura() return 'modifier_enfos_cm_arcane_aura_buff' end
function modifier_enfos_cm_arcane_aura:GetModifierConstantManaRegen()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'mana_regen') * 3
end
function modifier_enfos_cm_arcane_aura:GetModifierSpellAmplify_Percentage()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'spell_amp')
end

modifier_enfos_cm_arcane_aura_buff=class({})
function modifier_enfos_cm_arcane_aura_buff:IsPurgable() return false end
function modifier_enfos_cm_arcane_aura_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_enfos_cm_arcane_aura_buff:GetModifierConstantManaRegen()
    local c = self:GetCaster()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    local base = (self.GetAbility and value(self:GetAbility(), 'mana_regen')) or 4.0
    return base
end
function modifier_enfos_cm_arcane_aura_buff:GetModifierSpellAmplify_Percentage()
    local c = self:GetCaster()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'spell_amp')) or 15
end

enfos_cm_freezing_field=class({})
function enfos_cm_freezing_field:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('hero_Crystal.freezingField.wind')
    c:AddNewModifier(c, self, 'modifier_enfos_cm_freezing_field_channel', { duration = value(self, 'duration') })
end
function enfos_cm_freezing_field:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    if c and not (c.IsNull and c:IsNull()) then c:RemoveModifierByName('modifier_enfos_cm_freezing_field_channel') end
end

modifier_enfos_cm_freezing_field_channel=class({})
function modifier_enfos_cm_freezing_field_channel:IsPurgable() return false end
function modifier_enfos_cm_freezing_field_channel:OnDestroy()
    if IsServer() then
        local c = self:GetParent()
        if c and not (c.IsNull and c:IsNull()) then c:StopSound('hero_Crystal.freezingField.wind') end
    end
end
function modifier_enfos_cm_freezing_field_channel:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end
function modifier_enfos_cm_freezing_field_channel:GetModifierPhysicalArmorBonus() return value(self:GetAbility(), 'bonus_armor') end
function modifier_enfos_cm_freezing_field_channel:GetModifierMagicalResistanceBonus() return value(self:GetAbility(), 'bonus_magic_resist') end
function modifier_enfos_cm_freezing_field_channel:OnCreated()
    if not IsServer() then return end
    local c = self:GetParent()
    local radius = value(self:GetAbility(), 'radius')
    if radius <= 0 then radius = 800 end
    local snow = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(snow, 1, Vector(radius, radius, 1))
    self:AddParticle(snow, false, false, -1, false, false)
    self:StartIntervalThink(value(self:GetAbility(), 'tick_interval'))
end
function modifier_enfos_cm_freezing_field_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local int = get_int(c)
    local base = (a and value(a, 'explosion_damage')) or 180
    local dmg = base + (int * value(a, 'int_damage_factor'))

    local radius = value(a, 'radius')
    if radius <= 0 then radius = 800 end
    local targets = enemies(c, c:GetAbsOrigin(), radius)
    if #targets > 0 then
        local t = targets[RandomInt(1, #targets)]
        damage(a, t, dmg, DAMAGE_TYPE_MAGICAL)
        t:AddNewModifier(c, a, 'modifier_enfos_cm_freezing_field_slow', { duration = value(a, 'slow_duration') })
        effect_at_position('particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf', t:GetAbsOrigin())
        local gm = c.FindAbilityByName and c:FindAbilityByName('enfos_cm_glacial_mastery')
        if gm and not (c.PassivesDisabled and c:PassivesDisabled()) then
            t:AddNewModifier(c, gm, 'modifier_enfos_cm_frost_stack', { duration = value(gm, 'frost_stack_duration') })
        end
    end
end

modifier_enfos_cm_freezing_field_slow=class({})
function modifier_enfos_cm_freezing_field_slow:IsDebuff() return true end
function modifier_enfos_cm_freezing_field_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_cm_freezing_field_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

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
    local p = self:GetParent()
    local c = self:GetCaster()
    local a = self:GetAbility()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    local count = self:GetStackCount() + 1
    local stack_limit = value(a, 'frost_stack_limit')
    if count >= stack_limit then
        self:Destroy()
        local duration = value(a, 'freeze_duration')
        if is_boss(p) then duration = duration * value(a, 'boss_freeze_duration_pct') / 100 end
        if duration > 0 then p:AddNewModifier(c, a, 'modifier_enfos_cm_frozen', { duration = duration }) end

        local max_hp = p.GetMaxHealth and p:GetMaxHealth() or 1000
        local hp_dmg = max_hp * value(a, 'max_hp_damage_pct') / 100
        if is_boss(p) then hp_dmg = math.min(value(a, 'boss_shatter_damage_cap'), hp_dmg) end
        local base = value(a, 'shatter_damage')
        if base <= 0 then base = 150 end
        local shatter_dmg = base + hp_dmg

        effect('particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf', p)
        for _, u in ipairs(enemies(c, p:GetAbsOrigin(), value(a, 'shatter_radius'))) do
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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local radius = value(self, 'radius')
    if radius <= 0 then radius = 700 end
    local max_targets = value(self, 'max_targets')
    if max_targets <= 0 then max_targets = 8 end
    local targets = enemies(c, c:GetAbsOrigin(), radius)
    c:EmitSound('Hero_Dazzle.Poison_Touch')

    local count = 0
    for _, u in ipairs(targets) do
        u:AddNewModifier(c, self, 'modifier_enfos_dazzle_poison_touch_debuff', { duration = value(self, 'duration') })
        apply_dazzle_weave(c, u)
        effect('particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf', u)
        count = count + 1
        if count >= max_targets then break end
    end
end

modifier_enfos_dazzle_poison_touch_debuff=class({})
function modifier_enfos_dazzle_poison_touch_debuff:IsDebuff() return true end
function modifier_enfos_dazzle_poison_touch_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_dazzle_poison_touch_debuff:GetModifierMoveSpeedBonus_Percentage()
    local ability = self:GetAbility()
    local slow = value(ability, 'slow_pct')
    if slow <= 0 then slow = 25 end
    return -slow - (self.bonus_slow or 0)
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
    local int_pct = value(a, 'int_damage_pct')
    if int_pct <= 0 then int_pct = 35 end
    local dmg = base + (int * int_pct / 100)
    damage(a, p, dmg, DAMAGE_TYPE_PHYSICAL)
end
function modifier_enfos_dazzle_poison_touch_debuff:OnAttackLanded(params)
    if not IsServer() then return end
    if not params then return end
    if params.target == self:GetParent() and params.attacker == self:GetCaster() then
        local duration = value(self:GetAbility(), 'duration')
        if duration <= 0 then duration = 6.0 end
        self:SetDuration(duration, true)
        local increase = value(self:GetAbility(), 'slow_per_attack')
        if increase <= 0 then increase = 2 end
        local cap = value(self:GetAbility(), 'max_bonus_slow')
        if cap <= 0 then cap = 35 end
        self.bonus_slow = math.min(cap, (self.bonus_slow or 0) + increase)
    end
end

enfos_dazzle_shallow_grave=class({})
function enfos_dazzle_shallow_grave:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget() or c
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() ~= c:GetTeamNumber() then return end
    c:EmitSound('Hero_Dazzle.Shallow_Grave')
    effect('particles/units/heroes/hero_dazzle/dazzle_shallow_grave.vpcf', t)
    t:AddNewModifier(c, self, 'modifier_enfos_dazzle_shallow_grave_buff', { duration = value(self, 'duration') })
    apply_dazzle_weave(c, t)
end

modifier_enfos_dazzle_shallow_grave_buff=class({})
function modifier_enfos_dazzle_shallow_grave_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET }
end
function modifier_enfos_dazzle_shallow_grave_buff:GetMinHealth() return 1 end
function modifier_enfos_dazzle_shallow_grave_buff:GetModifierHealAmplify_PercentageTarget()
    return value(self:GetAbility(), 'heal_amp_pct')
end

enfos_dazzle_shadow_wave=class({})
function enfos_dazzle_shadow_wave:OnSpellStart()
    local c = self:GetCaster()
    local initial = self:GetCursorTarget() or c
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not initial or (initial.IsNull and initial:IsNull()) or not initial:IsAlive() then return end
    if initial.GetTeamNumber and c.GetTeamNumber and initial:GetTeamNumber() ~= c:GetTeamNumber() then return end
    c:EmitSound('Hero_Dazzle.Shadow_Wave')
    local int = get_int(c)
    local base_heal = value(self, 'heal_amount')
    if base_heal <= 0 then base_heal = 170 end
    local heal = base_heal + (int * value(self, 'int_heal_factor'))

    local healed = { [initial:entindex()] = true }
    local current = initial
    local jump_targets = { initial }

    local max_bounces = math.max(0, math.floor(value(self, 'max_bounces')))
    local bounce_radius = value(self, 'bounce_radius')
    for i = 1, max_bounces do
        local candidates = allies(c, current:GetAbsOrigin(), bounce_radius)
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
        apply_dazzle_weave(c, target)
        effect('particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf', target)
        local radius = value(self, 'damage_radius')
        if radius <= 0 then radius = 200 end
        for _, enemy in ipairs(enemies(c, target:GetAbsOrigin(), radius)) do
            apply_dazzle_weave(c, enemy)
            damage(self, enemy, heal, DAMAGE_TYPE_PHYSICAL)
        end
    end
end

enfos_dazzle_bad_juju=class({})
function enfos_dazzle_bad_juju:GetIntrinsicModifierName() return 'modifier_enfos_dazzle_bad_juju_passive' end
function enfos_dazzle_bad_juju:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local cost_pct = value(self, 'self_health_cost_pct')
    local duration = value(self, 'effect_duration')
    if duration <= 0 then duration = 8.0 end
    local cost = c:GetHealth() * cost_pct / 100
    if c:GetHealth() > cost then c:SetHealth(c:GetHealth() - cost) end

    c:EmitSound('Hero_Dazzle.BadJuju.Cast')
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(self, 'radius'))) do
        u:AddNewModifier(c, self, 'modifier_enfos_dazzle_bad_juju_debuff', { duration = duration })
        apply_dazzle_weave(c, u)
    end
    for _, u in ipairs(allies(c, c:GetAbsOrigin(), value(self, 'radius'))) do
        u:AddNewModifier(c, self, 'modifier_enfos_dazzle_bad_juju_buff', { duration = duration })
        apply_dazzle_weave(c, u)
    end
end

modifier_enfos_dazzle_bad_juju_passive=class({})
function modifier_enfos_dazzle_bad_juju_passive:IsPurgable() return false end
function modifier_enfos_dazzle_bad_juju_passive:IsDebuff() return false end
function modifier_enfos_dazzle_bad_juju_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST } end
function modifier_enfos_dazzle_bad_juju_passive:OnAbilityFullyCast(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if not params or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    if params.unit ~= c or not params.ability or params.ability:IsItem() or params.ability == self:GetAbility() then return end

    for i = 0, 5 do
        local ab = c:GetAbilityByIndex(i)
        if ab and ab ~= params.ability and ab.GetCooldownTimeRemaining and ab:GetCooldownTimeRemaining() > 0 then
            local rem = ab:GetCooldownTimeRemaining() - value(self:GetAbility(), 'cooldown_reduction')
            ab:EndCooldown()
            if rem > 0 then ab:StartCooldown(rem) end
        end
    end
end

modifier_enfos_dazzle_bad_juju_buff=class({})
function modifier_enfos_dazzle_bad_juju_buff:GetEffectName() return 'particles/units/heroes/hero_dazzle/dazzle_armor_friend.vpcf' end
function modifier_enfos_dazzle_bad_juju_buff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_bad_juju_buff:GetModifierPhysicalArmorBonus()
    return value(self:GetAbility(), 'ally_armor')
end

modifier_enfos_dazzle_bad_juju_debuff=class({})
function modifier_enfos_dazzle_bad_juju_debuff:IsDebuff() return true end
function modifier_enfos_dazzle_bad_juju_debuff:GetEffectName() return 'particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf' end
function modifier_enfos_dazzle_bad_juju_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_bad_juju_debuff:GetModifierPhysicalArmorBonus()
    return -value(self:GetAbility(), 'enemy_armor_reduction')
end

enfos_dazzle_nothl_weave=class({})
function enfos_dazzle_nothl_weave:GetIntrinsicModifierName() return 'modifier_enfos_dazzle_nothl_weave_aura' end

modifier_enfos_dazzle_nothl_weave_aura=class({})
function modifier_enfos_dazzle_nothl_weave_aura:IsHidden() return true end
function modifier_enfos_dazzle_nothl_weave_aura:IsPurgable() return false end

modifier_enfos_dazzle_nothl_weave_buff=class({})
function modifier_enfos_dazzle_nothl_weave_buff:IsPurgable() return false end
function modifier_enfos_dazzle_nothl_weave_buff:GetEffectName() return 'particles/units/heroes/hero_dazzle/dazzle_armor_friend.vpcf' end
function modifier_enfos_dazzle_nothl_weave_buff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_nothl_weave_buff:GetModifierPhysicalArmorBonus()
    return (self:GetStackCount() or 1) * value(self:GetAbility(), 'armor_change')
end

modifier_enfos_dazzle_nothl_weave_debuff=class({})
function modifier_enfos_dazzle_nothl_weave_debuff:IsDebuff() return true end
function modifier_enfos_dazzle_nothl_weave_debuff:IsPurgable() return false end
function modifier_enfos_dazzle_nothl_weave_debuff:GetEffectName() return 'particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf' end
function modifier_enfos_dazzle_nothl_weave_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_dazzle_nothl_weave_debuff:GetModifierPhysicalArmorBonus()
    return (self:GetStackCount() or 1) * -value(self:GetAbility(), 'armor_change')
end


-- ============================================================================
-- BATCH 3 PVE HERO KITS: BRISTLEBACK, TIDEHUNTER, WRAITH KING, PA, ZEUS, WITCH DOCTOR
-- ============================================================================

-- ----------------------------------------------------------------------------
-- BRISTLEBACK: VISCOUS NASAL GOO, QUILL SPRAY, BRISTLEBACK, WARPATH, HAIRBALL
-- ----------------------------------------------------------------------------

local function apply_bristleback_goo(c, ability, target, stacks)
    if not c or (c.IsNull and c:IsNull()) or not target or (target.IsNull and target:IsNull()) or not target:IsAlive() then return end
    local duration = value(ability, 'duration')
    local modifier_name = 'modifier_enfos_bb_viscous_nasal_goo_debuff'
    for _ = 1, stacks or 1 do
        target:AddNewModifier(c, ability, modifier_name, { duration = duration })
    end
    effect('particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo.vpcf', target)
end

enfos_bb_viscous_nasal_goo=class({})
function enfos_bb_viscous_nasal_goo:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    if t.GetTeamNumber and c.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_Bristleback.ViscousGoo.Cast')
    apply_bristleback_goo(c, self, t, 1)
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
    local cap = value(self:GetAbility(), 'max_stacks')
    self:SetStackCount(math.min(cap, self:GetStackCount() + 1))
end
function modifier_enfos_bb_viscous_nasal_goo_debuff:GetModifierPhysicalArmorBonus()
    return -value(self:GetAbility(), 'armor_reduction') * self:GetStackCount()
end
function modifier_enfos_bb_viscous_nasal_goo_debuff:GetModifierMoveSpeedBonus_Percentage()
    local a = self:GetAbility()
    return -(value(a, 'base_slow_pct') + value(a, 'slow_per_stack') * self:GetStackCount())
end

local function bristleback_quill_spray(c, ability, center, origin_particle, config, emit_cast_sound, damage_ability)
    if emit_cast_sound then c:EmitSound('Hero_Bristleback.QuillSpray.Cast') end
    if origin_particle then
        effect_at_position('particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf', center)
    else
        effect('particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf', c)
    end
    local base_dmg = config and config.base_damage or value(ability, 'base_damage')
    local stack_dmg = config and config.stack_damage or value(ability, 'stack_damage')
    local strength = get_str(c)
    local radius = config and config.radius or value(ability, 'radius')
    local stack_cap = config and config.max_stacks or value(ability, 'max_stacks')
    local debuff_duration = config and config.debuff_duration or value(ability, 'debuff_duration')
    local strength_factor = config and config.strength_damage_factor or value(ability, 'strength_damage_factor')
    local stack_strength_factor = config and config.stack_strength_factor or value(ability, 'stack_strength_factor')
    for _, u in ipairs(enemies(c, center, radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        local mod = u:FindModifierByName('modifier_enfos_bb_quill_spray_debuff')
        local stacks = (mod and mod.GetStackCount and mod:GetStackCount()) or 0
        local total_dmg = base_dmg + (strength * strength_factor)
            + (stacks * (stack_dmg + (strength * stack_strength_factor)))
        damage(damage_ability or ability, u, total_dmg, DAMAGE_TYPE_PHYSICAL)
        if not mod then
            mod = u:AddNewModifier(c, ability, 'modifier_enfos_bb_quill_spray_debuff', { duration = debuff_duration })
        end
        if mod and mod.SetStackCount then
            mod:SetStackCount(math.min(stack_cap, ((mod.GetStackCount and mod:GetStackCount()) or 0) + 1))
        end
        if mod and mod.SetDuration then mod:SetDuration(debuff_duration, true) end
    end
end

enfos_bb_quill_spray=class({})
function enfos_bb_quill_spray:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Bristleback.QuillSpray.Cast')
    local config = {
        radius = value(self, 'radius'),
        base_damage = value(self, 'base_damage'),
        stack_damage = value(self, 'stack_damage'),
        strength_damage_factor = value(self, 'strength_damage_factor'),
        stack_strength_factor = value(self, 'stack_strength_factor'),
        max_stacks = value(self, 'max_stacks'),
        debuff_duration = value(self, 'debuff_duration')
    }
    bristleback_quill_spray(c, self, c:GetAbsOrigin(), false, config)
end

modifier_enfos_bb_quill_spray_debuff=class({})
function modifier_enfos_bb_quill_spray_debuff:IsDebuff() return true end

enfos_bb_bristleback=class({})
function enfos_bb_bristleback:GetIntrinsicModifierName() return 'modifier_enfos_bb_bristleback_passive' end

local function bristleback_attacker_dot(caster, attacker)
    if not attacker or not attacker.GetAbsOrigin or not caster.GetForwardVector then return 0 end
    local forward = caster:GetForwardVector()
    local toward = attacker:GetAbsOrigin() - caster:GetAbsOrigin()
    local length = toward:Length2D()
    if length <= 0 then return 0 end
    return (forward.x * toward.x + forward.y * toward.y) / length
end

modifier_enfos_bb_bristleback_passive=class({})
function modifier_enfos_bb_bristleback_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_bb_bristleback_passive:OnCreated()
    self.accumulated_damage = 0
end
function modifier_enfos_bb_bristleback_passive:GetModifierIncomingDamage_Percentage(params)
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    local dot = bristleback_attacker_dot(c, params and params.attacker)
    local a = self:GetAbility()
    local rear_threshold = math.cos(math.rad(180 - value(a, 'rear_angle') / 2))
    local side_threshold = math.cos(math.rad(180 - value(a, 'side_angle') / 2))
    if dot <= rear_threshold then return -value(a, 'back_damage_reduction') end
    if dot <= side_threshold then return -value(a, 'side_damage_reduction') end
    return 0
end
function modifier_enfos_bb_bristleback_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if not params then return end
    if params.unit ~= c or not params.attacker or params.attacker == c then return end
    if c.PassivesDisabled and c:PassivesDisabled() then return end
    if params.attacker.GetTeamNumber and c.GetTeamNumber and params.attacker:GetTeamNumber() == c:GetTeamNumber() then return end
    local dot = bristleback_attacker_dot(c, params.attacker)
    local rear_threshold = math.cos(math.rad(180 - value(self:GetAbility(), 'rear_angle') / 2))
    if dot > rear_threshold then return end
    local qs = c:FindAbilityByName('enfos_bb_quill_spray')
    if not qs or qs:GetLevel() <= 0 then return end
    self.accumulated_damage = (self.accumulated_damage or 0) + (params.damage or 0)
    local threshold = value(self:GetAbility(), 'quill_damage_threshold')
    if self.accumulated_damage >= threshold then
        self.accumulated_damage = self.accumulated_damage - threshold
        bristleback_quill_spray(c, qs, c:GetAbsOrigin(), false, nil, true)
    end
end

enfos_bb_warpath=class({})
function enfos_bb_warpath:GetIntrinsicModifierName() return 'modifier_enfos_bb_warpath_passive' end

modifier_enfos_bb_warpath_passive=class({})
function modifier_enfos_bb_warpath_passive:IsHidden() return true end
function modifier_enfos_bb_warpath_passive:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end
function modifier_enfos_bb_warpath_passive:OnAbilityFullyCast(params)
    if not IsServer() then return end
    if not params then return end
    local c = self:GetParent()
    if c.PassivesDisabled and c:PassivesDisabled() then return end
    local cast_ability = params and params.ability
    if params.unit ~= c or not cast_ability or (cast_ability.IsItem and cast_ability:IsItem()) then return end
    local a = self:GetAbility()
    local buff = c:FindModifierByName('modifier_enfos_bb_warpath_buff')
    local duration = value(a, 'stack_duration')
    if not buff then buff = c:AddNewModifier(c, a, 'modifier_enfos_bb_warpath_buff', { duration = duration }) end
    if not buff then return end
    buff:SetStackCount(math.min(value(a, 'max_stacks'), buff:GetStackCount() + 1))
    buff:SetDuration(duration, true)
end

modifier_enfos_bb_warpath_buff=class({})
function modifier_enfos_bb_warpath_buff:GetEffectName()
    return 'particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf'
end
function modifier_enfos_bb_warpath_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_bb_warpath_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_bb_warpath_buff:GetModifierPreAttack_BonusDamage()
    local c = self:GetCaster()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return self:GetStackCount() * value(self:GetAbility(), 'damage_per_stack')
end
function modifier_enfos_bb_warpath_buff:GetModifierMoveSpeedBonus_Percentage()
    local c = self:GetCaster()
    if c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return self:GetStackCount() * value(self:GetAbility(), 'ms_per_stack')
end

enfos_bb_hairball=class({})
function enfos_bb_hairball:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not pos then return end
    c:EmitSound('Hero_Bristleback.Hairball.Cast')
    local goo = c:FindAbilityByName('enfos_bb_viscous_nasal_goo')
    local qs = c:FindAbilityByName('enfos_bb_quill_spray')
    for _, u in ipairs(enemies(c, pos, value(self, 'radius'))) do
        if goo then apply_bristleback_goo(c, goo, u, value(self, 'goo_stacks')) end
    end
    if qs then bristleback_quill_spray(c, qs, pos, true, nil, true, self) end
end

-- ----------------------------------------------------------------------------
-- TIDEHUNTER: GUSH, KRAKEN SHELL, ANCHOR SMASH, RAVAGE, COLOSSAL PRESENCE
-- ----------------------------------------------------------------------------

enfos_tide_gush=class({})
function enfos_tide_gush:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Tidehunter.Gush.Cast')
    effect('particles/units/heroes/hero_tidehunter/tidehunter_gush.vpcf', t)

    local base = value(self, 'gush_damage')
    if base <= 0 then base = value(self, 'damage') end
    if base <= 0 then base = 220 end
    local str = get_str(c)
    local dmg = base + (str * value(self, 'strength_factor'))

    damage(self, t, dmg, DAMAGE_TYPE_MAGICAL)
    t:AddNewModifier(c, self, 'modifier_enfos_tide_gush_debuff', { duration = value(self, 'duration') })
end

modifier_enfos_tide_gush_debuff=class({})
function modifier_enfos_tide_gush_debuff:IsDebuff() return true end
function modifier_enfos_tide_gush_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_tide_gush_debuff:GetModifierPhysicalArmorBonus()
    return -((self.GetAbility and value(self:GetAbility(), 'armor_reduction')) or 5)
end
function modifier_enfos_tide_gush_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -((self.GetAbility and value(self:GetAbility(), 'slow_pct')) or 40)
end

enfos_tide_kraken_shell=class({})
function enfos_tide_kraken_shell:GetIntrinsicModifierName() return 'modifier_enfos_tide_kraken_shell_passive' end

modifier_enfos_tide_kraken_shell_passive=class({})
function modifier_enfos_tide_kraken_shell_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end
function modifier_enfos_tide_kraken_shell_passive:OnCreated()
    self.damage_counter = 0
end
function modifier_enfos_tide_kraken_shell_passive:GetModifierPhysical_ConstantBlock()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'damage_block')) or 50
    return base + (str * 0.05)
end
function modifier_enfos_tide_kraken_shell_passive:GetModifierConstantHealthRegen()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'bonus_hp_regen')) or 0
end
function modifier_enfos_tide_kraken_shell_passive:OnTakeDamage(params)
    if not IsServer() or not params then return end
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) or params.unit ~= c then return end
    self.damage_counter = (self.damage_counter or 0) + (params.damage or 0)
    local threshold = value(self:GetAbility(), 'purge_damage_threshold')
    if threshold <= 0 then threshold = 450 end
    if self.damage_counter >= threshold then
        self.damage_counter = self.damage_counter % threshold
        if c.Purge then c:Purge(false, true, false, true, true) end
    end
end

enfos_tide_anchor_smash=class({})
function enfos_tide_anchor_smash:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Tidehunter.AnchorSmash')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(fx)

    local base = value(self, 'attack_damage_bonus')
    if base <= 0 then base = 160 end
    local str = get_str(c)
    local dmg = get_atk(c) + base + (str * value(self, 'strength_factor'))

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(self, 'radius'), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_tide_anchor_smash_debuff', { duration = value(self, 'duration') })
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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Tidehunter.Ravage')
    effect('particles/units/heroes/hero_tidehunter/tidehunter_spell_ravage.vpcf', c)

    local base = value(self, 'damage')
    if base <= 0 then base = 325 end
    local str = get_str(c)
    local dmg = base + (str * 2.0)
    local dur = value(self, 'stun_duration')
    if dur <= 0 then dur = 2.8 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(self, 'radius'))) do
        local boss_dur = value(self, 'boss_stun_duration')
        if boss_dur <= 0 then boss_dur = 1.0 end
        local target_dur = is_boss(u) and math.min(dur, boss_dur) or dur
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
function modifier_enfos_tide_colossal_presence_aura:IsAura()
    local c = self:GetParent()
    return c and not (c.IsNull and c:IsNull()) and not (c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_tide_colossal_presence_aura:GetAuraRadius()
    return (self.GetAbility and value(self:GetAbility(), 'radius')) or 900
end
function modifier_enfos_tide_colossal_presence_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_enfos_tide_colossal_presence_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_tide_colossal_presence_aura:GetModifierAura() return 'modifier_enfos_tide_colossal_presence_debuff' end
function modifier_enfos_tide_colossal_presence_aura:DeclareFunctions()
    return { MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
function modifier_enfos_tide_colossal_presence_aura:GetModifierExtraHealthBonus()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'bonus_health')) or 0
end
function modifier_enfos_tide_colossal_presence_aura:GetModifierPhysicalArmorBonus()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'bonus_armor')) or 0
end

modifier_enfos_tide_colossal_presence_debuff=class({})
function modifier_enfos_tide_colossal_presence_debuff:IsDebuff() return true end
function modifier_enfos_tide_colossal_presence_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end
function modifier_enfos_tide_colossal_presence_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -((self.GetAbility and value(self:GetAbility(), 'enemy_slow_pct')) or 15)
end
function modifier_enfos_tide_colossal_presence_debuff:GetModifierBaseDamageOutgoing_Percentage()
    return -((self.GetAbility and value(self:GetAbility(), 'enemy_damage_reduction')) or 15)
end

-- ----------------------------------------------------------------------------
-- WRAITH KING: WRAITHFIRE BLAST, VAMPIRIC AURA, MORTAL STRIKE, REINCARNATION, SKELETON ARMY
-- ----------------------------------------------------------------------------

enfos_wk_wraithfire_blast=class({})
function enfos_wk_wraithfire_blast:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull()) or not t:IsAlive()
        or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_SkeletonKing.Hellfire_Blast')
    if ProjectileManager and ProjectileManager.CreateTrackingProjectile then
        ProjectileManager:CreateTrackingProjectile({
            Target = t,
            Source = c,
            Ability = self,
            EffectName = 'particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf',
            iMoveSpeed = value(self, 'projectile_speed'),
            bDodgeable = true,
            bVisibleToEnemies = true,
            bProvidesVision = false
        })
    else
        self:OnProjectileHit(t, t:GetAbsOrigin())
    end
end

function enfos_wk_wraithfire_blast:OnProjectileHit(target, location)
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not target or (target.IsNull and target:IsNull()) or not target:IsAlive() then
        return true
    end

    effect('particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_explosion.vpcf', target)
    local base = value(self, 'damage')
    if base <= 0 then base = 200 end
    local damage_amount = base + (get_str(c) * value(self, 'strength_damage_factor'))
    damage(self, target, damage_amount, DAMAGE_TYPE_MAGICAL)

    local stun_duration = value(self, 'stun_duration')
    if stun_duration <= 0 then stun_duration = 1.5 end
    if is_boss(target) then
        local boss_duration = value(self, 'boss_stun_duration')
        if boss_duration <= 0 then boss_duration = 0.6 end
        stun_duration = math.min(stun_duration, boss_duration)
    end
    target:AddNewModifier(c, self, 'modifier_enfos_wk_wraithfire_blast_stun', { duration = stun_duration })
    target:AddNewModifier(c, self, 'modifier_enfos_wk_wraithfire_blast_dot', { duration = value(self, 'dot_duration') })
    return true
end

modifier_enfos_wk_wraithfire_blast_stun=class({})
function modifier_enfos_wk_wraithfire_blast_stun:IsDebuff() return true end
function modifier_enfos_wk_wraithfire_blast_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

modifier_enfos_wk_wraithfire_blast_dot=class({})
function modifier_enfos_wk_wraithfire_blast_dot:IsDebuff() return true end
function modifier_enfos_wk_wraithfire_blast_dot:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_wk_wraithfire_blast_dot:GetEffectName()
    return 'particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf'
end
function modifier_enfos_wk_wraithfire_blast_dot:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_wk_wraithfire_blast_dot:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
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

local function apply_wk_lifesteal(ability, recipient, params)
    if not IsServer() or not params or not recipient then return end
    local caster = ability and ability.GetCaster and ability:GetCaster() or nil
    local target = params.target
    if not caster or (caster.IsNull and caster:IsNull()) or (caster.PassivesDisabled and caster:PassivesDisabled())
        or params.attacker ~= recipient or not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or (target.GetTeamNumber and recipient.GetTeamNumber and target:GetTeamNumber() == recipient:GetTeamNumber())
        or not params.damage or params.damage <= 0 then return end
    recipient:Heal(params.damage * value(ability, 'lifesteal_pct') / 100, ability)
    effect('particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf', recipient)
end

modifier_enfos_wk_vampiric_aura=class({})
function modifier_enfos_wk_vampiric_aura:IsHidden() return true end
function modifier_enfos_wk_vampiric_aura:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_wk_vampiric_aura:IsAura()
    local c = self:GetParent()
    return c and not (c.IsNull and c:IsNull()) and not (c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_wk_vampiric_aura:GetAuraEntityReject(unit) return unit == self:GetParent() end
function modifier_enfos_wk_vampiric_aura:GetAuraRadius() return value(self:GetAbility(), 'aura_radius') end
function modifier_enfos_wk_vampiric_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_wk_vampiric_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_wk_vampiric_aura:GetModifierAura() return 'modifier_enfos_wk_vampiric_aura_buff' end
function modifier_enfos_wk_vampiric_aura:OnAttackLanded(params)
    apply_wk_lifesteal(self:GetAbility(), self:GetParent(), params)
end

modifier_enfos_wk_vampiric_aura_buff=class({})
function modifier_enfos_wk_vampiric_aura_buff:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_wk_vampiric_aura_buff:OnAttackLanded(params)
    apply_wk_lifesteal(self:GetAbility(), self:GetParent(), params)
end

enfos_wk_mortal_strike=class({})
function enfos_wk_mortal_strike:GetIntrinsicModifierName() return 'modifier_enfos_wk_mortal_strike_passive' end

modifier_enfos_wk_mortal_strike_passive=class({})
function modifier_enfos_wk_mortal_strike_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_wk_mortal_strike_passive:GetModifierPreAttack_CriticalStrike()
    if not IsServer() then return end
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    if RollPercentage(value(self:GetAbility(), 'crit_chance')) then
        self.crit_proc = true
        return value(self:GetAbility(), 'crit_mult')
    end
    self.crit_proc = false
    return 0
end
function modifier_enfos_wk_mortal_strike_passive:OnAttackLanded(params)
    if not IsServer() or not params then return end
    local c = self:GetParent()
    if params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    local t = params.target
    if self.crit_proc and t and t:IsAlive() then
        c:EmitSound('Hero_SkeletonKing.CriticalStrike')
        effect('particles/units/heroes/hero_skeletonking/skeletonking_mortalstrike.vpcf', t)
        local cleave_dmg = (params.damage or 200) * value(self:GetAbility(), 'cleave_pct') / 100
        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), value(self:GetAbility(), 'cleave_radius'))) do
            if u ~= t then damage(self:GetAbility(), u, cleave_dmg, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

enfos_wk_reincarnation=class({})
function enfos_wk_reincarnation:GetIntrinsicModifierName() return 'modifier_enfos_wk_reincarnation_passive' end

modifier_enfos_wk_reincarnation_passive=class({})
function modifier_enfos_wk_reincarnation_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_REINCARNATION, MODIFIER_EVENT_ON_DEATH }
end
function modifier_enfos_wk_reincarnation_passive:ReincarnateTime()
    local a, c = self:GetAbility(), self:GetParent()
    if not a or a:IsNull() or a:GetLevel() < 1 or c:IsIllusion() or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    if a:IsCooldownReady() then
        local delay = value(a, 'reincarnation_time')
        if delay <= 0 then delay = 3 end
        return delay
    end
end
function modifier_enfos_wk_reincarnation_passive:OnDeath(params)
    if not IsServer() or not params then return end
    local c = self:GetParent()
    if params.unit ~= c then return end
    local a = self:GetAbility()
    if not a or a:IsNull() or not c:IsReincarnating() then return end
    a:UseResources(false, false, false, true)
    c:EmitSound('Hero_SkeletonKing.Reincarnate')
    effect('particles/units/heroes/hero_skeletonking/skeletonking_reincarnation.vpcf', c)
    local str = get_str(c)
    local dmg = value(a, 'damage') + (str * value(a, 'strength_damage_factor'))

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(a, 'slow_radius'))) do
        damage(a, u, dmg, DAMAGE_TYPE_MAGICAL)
        local slow_duration = value(a, 'slow_duration')
        if is_boss(u) then
            local boss_duration = value(a, 'boss_slow_duration')
            if boss_duration > 0 then slow_duration = boss_duration end
        end
        u:AddNewModifier(c, a, 'modifier_enfos_wk_rebirth_slow', {duration=slow_duration})
    end
end

modifier_enfos_wk_rebirth_slow=class({})
function modifier_enfos_wk_rebirth_slow:IsDebuff() return true end
function modifier_enfos_wk_rebirth_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_enfos_wk_rebirth_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

enfos_wk_skeleton_army=class({})
function enfos_wk_skeleton_army:GetIntrinsicModifierName() return 'modifier_enfos_wk_skeleton_army_passive' end
function enfos_wk_skeleton_army:OnSpellStart()
    local c=self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local mod=c:FindModifierByName('modifier_enfos_wk_skeleton_army_passive')
    local maxCount=value(self, 'max_skeletons')
    if maxCount <= 0 then maxCount = 8 end
    maxCount=math.max(1,math.min(20,math.floor(maxCount)))
    local minimum=value(self,'minimum_skeletons')
    if minimum<=0 then minimum=4 end
    local count=math.max(math.min(minimum,maxCount),math.min(maxCount,mod and mod:GetStackCount() or 0))
    if mod then mod:SetStackCount(0) end
    local str=get_str(c)
    require('heroes/summons'):Units(self,'enfos_creep_skeleton',c:GetAbsOrigin(),count,
        value(self,'summon_duration'),
        value(self,'skeleton_base_damage')+str*value(self,'skeleton_strength_damage_factor'),
        value(self,'skeleton_base_health')+str*value(self,'skeleton_strength_health_factor'),maxCount)
    c:EmitSound('Hero_SkeletonKing.Reincarnate')
end

modifier_enfos_wk_skeleton_army_passive=class({})
function modifier_enfos_wk_skeleton_army_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_enfos_wk_skeleton_army_passive:OnDeath(params)
    if not IsServer() or not params then return end
    local c = self:GetParent()
    local dead = params.unit
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    if params.attacker == c and dead and not (dead.IsNull and dead:IsNull()) and dead ~= c and dead:GetTeamNumber() ~= c:GetTeamNumber() then
        local cap = value(self:GetAbility(), 'max_skeletons')
        if cap <= 0 then cap = 8 end
        self:SetStackCount(math.min(cap, (self:GetStackCount() or 0) + 1))
    end
end

-- ----------------------------------------------------------------------------
-- PHANTOM ASSASSIN: STIFLING DAGGER, PHANTOM STRIKE, BLUR, COUP DE GRACE, FAN OF KNIVES
-- ----------------------------------------------------------------------------

enfos_pa_stifling_dagger=class({})
function enfos_pa_stifling_dagger:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_PhantomAssassin.Dagger.Cast')
    local base = value(self, 'base_damage')
    if base <= 0 then base = 120 end
    local agi = get_agi(c)
    local atk = get_atk(c, t)
    local dmg = base + (atk * value(self, 'attack_factor') / 100) + (agi * value(self, 'agility_factor'))

    if ProjectileManager and ProjectileManager.CreateTrackingProjectile then
        ProjectileManager:CreateTrackingProjectile({
            Target = t,
            Source = c,
            Ability = self,
            EffectName = 'particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf',
            iMoveSpeed = value(self, 'projectile_speed'),
            bDodgeable = false,
            bVisibleToEnemies = true,
            bProvidesVision = true,
            iVisionRadius = 300,
            iVisionTeamNumber = c:GetTeamNumber(),
            ExtraData = { damage = dmg }
        })
    else
        damage(self, t, dmg, DAMAGE_TYPE_PHYSICAL)
        t:AddNewModifier(c, self, 'modifier_enfos_pa_stifling_dagger_slow', { duration = value(self, 'slow_duration') })
    end

    local count = 0
    local chain_targets = math.max(0, math.min(5, math.floor(value(self, 'chain_targets'))))
    local chain_radius = value(self, 'chain_radius')
    if chain_radius <= 0 then chain_radius = 500 end
    local chain_damage_pct = value(self, 'chain_damage_pct')
    if chain_damage_pct <= 0 then chain_damage_pct = 75 end
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), chain_radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        if u ~= t and count < chain_targets then
            if ProjectileManager and ProjectileManager.CreateTrackingProjectile then
                ProjectileManager:CreateTrackingProjectile({
                    Target = u,
                    Source = c,
                    Ability = self,
                    EffectName = 'particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf',
                    iMoveSpeed = value(self, 'projectile_speed'),
                    bDodgeable = false,
                    bVisibleToEnemies = true,
                    bProvidesVision = false,
                    ExtraData = { damage = dmg * chain_damage_pct / 100 }
                })
            else
                damage(self, u, dmg * chain_damage_pct / 100, DAMAGE_TYPE_PHYSICAL)
                u:AddNewModifier(c, self, 'modifier_enfos_pa_stifling_dagger_slow', { duration = value(self, 'slow_duration') })
            end
            count = count + 1
        end
    end
end

function enfos_pa_stifling_dagger:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
    if not hTarget or hTarget:IsNull() or not hTarget:IsAlive() then return true end
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or hTarget:GetTeamNumber() == c:GetTeamNumber() then return true end
    local dmg = extraData and extraData.damage or 200
    effect('particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_explosion.vpcf', hTarget)
    damage(self, hTarget, dmg, DAMAGE_TYPE_PHYSICAL)
    hTarget:AddNewModifier(c, self, 'modifier_enfos_pa_stifling_dagger_slow', { duration = value(self, 'slow_duration') })
    hTarget:EmitSound('Hero_PhantomAssassin.Dagger.Target')
    return true
end

modifier_enfos_pa_stifling_dagger_slow=class({})
function modifier_enfos_pa_stifling_dagger_slow:IsDebuff() return true end
function modifier_enfos_pa_stifling_dagger_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_pa_stifling_dagger_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

enfos_pa_phantom_strike=class({})
function enfos_pa_phantom_strike:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_PhantomAssassin.Strike.Start')
    effect('particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_start.vpcf', c)
    local forward = t.GetForwardVector and t:GetForwardVector() or Vector(1, 0, 0)
    local dest = t:GetAbsOrigin() - (forward * 60)
    FindClearSpaceForUnit(c, dest, true)
    effect('particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf', c)
    c:EmitSound('Hero_PhantomAssassin.Strike.End')
    c:AddNewModifier(c, self, 'modifier_enfos_pa_phantom_strike_buff', { duration = value(self, 'buff_duration') })
end

modifier_enfos_pa_phantom_strike_buff=class({})
function modifier_enfos_pa_phantom_strike_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_pa_phantom_strike_buff:GetModifierAttackSpeedBonus_Constant() return value(self:GetAbility(), 'bonus_attack_speed') end
function modifier_enfos_pa_phantom_strike_buff:OnTakeDamage(params)
    if not IsServer() or not params then return end
    local c = self:GetParent()
    if params.attacker == c and params.unit and not (params.unit.IsNull and params.unit:IsNull())
        and params.unit:GetTeamNumber() ~= c:GetTeamNumber() and params.damage and params.damage > 0 then
        c:Heal(params.damage * value(self:GetAbility(), 'heal_pct') / 100, self:GetAbility())
    end
end

enfos_pa_blur=class({})
function enfos_pa_blur:GetIntrinsicModifierName() return 'modifier_enfos_pa_blur_passive' end
function enfos_pa_blur:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_PhantomAssassin.Blur')
    c:AddNewModifier(c, self, 'modifier_enfos_pa_blur_active', { duration = value(self, 'active_duration') })
end

modifier_enfos_pa_blur_passive=class({})
function modifier_enfos_pa_blur_passive:DeclareFunctions() return { MODIFIER_PROPERTY_EVASION_CONSTANT } end
function modifier_enfos_pa_blur_passive:GetModifierEvasion_Constant()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
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
    if not IsServer() then return end
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then self.crit_proc = false return 0 end
    local is_blur = c:HasModifier('modifier_enfos_pa_blur_active')
    if is_blur or RollPercentage(value(self:GetAbility(), 'crit_chance')) then
        if is_blur then c:RemoveModifierByName('modifier_enfos_pa_blur_active') end
        self.crit_proc = true
        return value(self:GetAbility(), 'crit_mult')
    end
    self.crit_proc = false
    return 0
end
function modifier_enfos_pa_coup_de_grace_passive:OnAttackLanded(params)
    if not IsServer() or not params then return end
    local c = self:GetParent()
    if params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    local t = params.target
    if self.crit_proc and t and t:IsAlive() then
        c:EmitSound('Hero_PhantomAssassin.CoupDeGrace')
        effect('particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf', t)
        local splash_radius = value(self:GetAbility(), 'splash_radius')
        if splash_radius <= 0 then splash_radius = 250 end
        local splash_pct = value(self:GetAbility(), 'splash_pct')
        if splash_pct <= 0 then splash_pct = 50 end
        local aoe_dmg = (params.damage or 400) * splash_pct / 100
        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), splash_radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
            if u ~= t then damage(self:GetAbility(), u, aoe_dmg, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

enfos_pa_immaterial=class({})
function enfos_pa_immaterial:GetIntrinsicModifierName() return 'modifier_enfos_pa_immaterial_passive' end

modifier_enfos_pa_immaterial_passive=class({})
function modifier_enfos_pa_immaterial_passive:DeclareFunctions() return { MODIFIER_PROPERTY_EVASION_CONSTANT } end
function modifier_enfos_pa_immaterial_passive:GetModifierEvasion_Constant()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'evasion')) or 10
end

-- ----------------------------------------------------------------------------
-- ZEUS: ARC LIGHTNING, LIGHTNING BOLT, STATIC FIELD, THUNDERGOD'S WRATH, HEAVENLY JUMP
-- ----------------------------------------------------------------------------

enfos_zeus_arc_lightning=class({})
function enfos_zeus_arc_lightning:OnSpellStart()
    local c = self:GetCaster()
    local initial = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not initial or (initial.IsNull and initial:IsNull())
        or not initial:IsAlive() or initial:GetTeamNumber() == c:GetTeamNumber() then return end
    if initial.TriggerSpellAbsorb and initial:TriggerSpellAbsorb(self) then return end

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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

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
function modifier_enfos_zeus_static_field_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_TAKEDAMAGE } end
function modifier_enfos_zeus_static_field_passive:OnTakeDamage(params)
    if not IsServer() or not params then return end
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return end
    if params.attacker ~= c or not params.unit or params.unit == c or not params.inflictor or params.inflictor == self:GetAbility() then return end
    if params.unit.IsNull and params.unit:IsNull() or not params.unit:IsAlive() then return end
    local a = self:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or (a.GetLevel and a:GetLevel() < 1) then return end
    if params.unit:GetTeamNumber() == c:GetTeamNumber() then return end
    local pct = (a and value(a, 'damage_pct')) or 4
    if pct <= 0 then return end
    local victim = params.unit
    local dmg = victim:GetHealth() * (pct / 100)
    if is_boss(victim) then dmg = math.min(value(a, 'boss_damage_cap'), dmg) end
    damage(a, victim, dmg, DAMAGE_TYPE_MAGICAL)
end

enfos_zeus_thundergods_wrath=class({})
function enfos_zeus_thundergods_wrath:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Zuus.HeavenlyJump')
    effect('particles/units/heroes/hero_zuus/zuus_shard_jump_launch_ring.vpcf', c)
    local forward = c.GetForwardVector and c:GetForwardVector() or Vector(1, 0, 0)
    FindClearSpaceForUnit(c, c:GetAbsOrigin() + (forward * 450), true)
    effect('particles/units/heroes/hero_zuus/zuus_shard_jump_landing_ring.vpcf', c)
    c:AddNewModifier(c, self, 'modifier_enfos_zeus_heavenly_jump_buff', { duration = value(self, 'buff_duration') })

    local int = get_int(c)
    local dmg = value(self, 'damage') + (int * 0.8)

    local count = 0
    local max_targets = math.max(1, math.min(20, math.floor(value(self, 'max_targets'))))
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), 600)) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_zeus_heavenly_jump_slow', { duration = value(self, 'slow_duration') })
        count = count + 1
        if count >= max_targets then break end
    end
end

modifier_enfos_zeus_heavenly_jump_buff=class({})
function modifier_enfos_zeus_heavenly_jump_buff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_zeus_heavenly_jump_buff:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'bonus_ms_pct') end

modifier_enfos_zeus_heavenly_jump_slow=class({})
function modifier_enfos_zeus_heavenly_jump_slow:IsDebuff() return true end
function modifier_enfos_zeus_heavenly_jump_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_zeus_heavenly_jump_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

-- ----------------------------------------------------------------------------
-- WITCH DOCTOR: PARALYZING CASK, VOODOO RESTORATION, MALEDICT, DEATH WARD, VOODOO SWITCHEROO
-- ----------------------------------------------------------------------------

enfos_wd_paralyzing_cask=class({})
function enfos_wd_paralyzing_cask:OnSpellStart()
    local c = self:GetCaster()
    local initial = self:GetCursorTarget()
    if not c or not initial or not initial:IsAlive() or initial.GetTeamNumber and initial:GetTeamNumber() == c:GetTeamNumber() then return end
    if initial.TriggerSpellAbsorb and initial:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_WitchDoctor.Paralyzing_Cask_Cast')
    local base = value(self, 'damage')
    if base <= 0 then base = 100 end
    local int = get_int(c)
    local dmg = base + (int * 0.4)

    local current = initial
    local bounces = value(self, 'bounces')
    if bounces <= 0 then bounces = 10 end
    local visited = {}

    for i = 1, bounces do
        if not current or not current:IsAlive() then break end
        local target_id = current.GetEntityIndex and current:GetEntityIndex() or current
        if visited[target_id] then break end
        visited[target_id] = true
        damage(self, current, dmg, DAMAGE_TYPE_MAGICAL)
        local stun_dur = value(self, 'stun_duration')
        if stun_dur <= 0 then stun_dur = 1.0 end
        if is_boss(current) then
            local boss_stun = value(self, 'boss_stun_duration')
            if boss_stun > 0 then stun_dur = math.min(stun_dur, boss_stun) end
        end
        current:AddNewModifier(c, self, 'modifier_enfos_wd_paralyzing_cask_stun', { duration = stun_dur })
        effect('particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf', current)

        local candidates = enemies(c, current:GetAbsOrigin(), 500)
        local next_target = nil
        for _, u in ipairs(candidates) do
            local candidate_id = u.GetEntityIndex and u:GetEntityIndex() or u
            if not visited[candidate_id] then next_target = u break end
        end
        current = next_target
    end
end

modifier_enfos_wd_paralyzing_cask_stun=class({})
function modifier_enfos_wd_paralyzing_cask_stun:IsDebuff() return true end
function modifier_enfos_wd_paralyzing_cask_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_wd_voodoo_restoration=class({})
function enfos_wd_voodoo_restoration:OnToggle()
    if not IsServer() then return end
    local c = self:GetCaster()
    if self:GetToggleState() then
        c:AddNewModifier(c, self, 'modifier_enfos_wd_voodoo_restoration_aura', {})
    else
        c:RemoveModifierByName('modifier_enfos_wd_voodoo_restoration_aura')
    end
end

modifier_enfos_wd_voodoo_restoration_aura=class({})
function modifier_enfos_wd_voodoo_restoration_aura:IsPurgable() return false end
function modifier_enfos_wd_voodoo_restoration_aura:OnCreated()
    if not IsServer() then return end
    self:GetParent():EmitSound('Hero_WitchDoctor.Voodoo_Restoration')
    self:GetParent():EmitSound('Hero_WitchDoctor.Voodoo_Restoration.Loop')
    if ParticleManager and self:GetParent() then
        self.particle = ParticleManager:CreateParticle('particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_aura.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        if self.particle then ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin()) end
    end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_wd_voodoo_restoration_aura:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() then
        parent:StopSound('Hero_WitchDoctor.Voodoo_Restoration.Loop')
        parent:EmitSound('Hero_WitchDoctor.Voodoo_Restoration.Off')
    end
    if self.particle and ParticleManager then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
end
function modifier_enfos_wd_voodoo_restoration_aura:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    if not a then self:Destroy(); return end
    local mana_cost = value(a, 'mana_per_second')
    if mana_cost > 0 and c.GetMana and c:GetMana() < mana_cost then
        self:Destroy()
        if a.ToggleAbility then a:ToggleAbility() end
        return
    end
    if mana_cost > 0 and c.SpendMana then c:SpendMana(mana_cost, a) end
    local int = get_int(c)
    local val = (a and value(a, 'heal_per_second')) or 50
    local amount = val + (int * 0.3)

    local radius = value(a, 'radius')
    if radius <= 0 then radius = 500 end
    for _, u in ipairs(allies(c, c:GetAbsOrigin(), radius)) do
        u:Heal(amount, a)
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
        u:AddNewModifier(c, self, 'modifier_enfos_wd_maledict_debuff', { duration = value(self, 'duration') > 0 and value(self, 'duration') or 12.0 })
        effect('particles/units/heroes/hero_witchdoctor/witchdoctor_maledict.vpcf', u)
    end
end

modifier_enfos_wd_maledict_debuff=class({})
function modifier_enfos_wd_maledict_debuff:IsDebuff() return true end
function modifier_enfos_wd_maledict_debuff:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent()
    self.last_burst_hp = p.GetHealth and p:GetHealth() or 1000
    self.elapsed = 0
    self:StartIntervalThink(1.0)
end
function modifier_enfos_wd_maledict_debuff:OnIntervalThink()
    local p = self:GetParent()
    local a = self:GetAbility()
    local dps = (a and value(a, 'base_dps')) or 50
    damage(a, p, dps, DAMAGE_TYPE_MAGICAL)

    self.elapsed = (self.elapsed or 0) + 1
    local burst_interval = a and value(a, 'burst_interval') or 4
    if burst_interval > 0 and self.elapsed % burst_interval == 0 then
        local current_hp = p.GetHealth and p:GetHealth() or 0
        local lost_hp = math.max(0, self.last_burst_hp - current_hp)
        self.last_burst_hp = current_hp
        local pct_key = is_boss(p) and 'boss_lost_health_pct' or 'lost_health_pct'
        local pct = a and value(a, pct_key) or 0
        local burst = lost_hp * pct / 100
        damage(a, p, burst, DAMAGE_TYPE_MAGICAL)
    end
end

-- The installed ward particle is a tracking projectile, not an impact effect.
-- Engine projectile ownership supplies travel/termination instead of leaving a
-- persistent parent particle at the target with an unset destination CP.
local function wd_launch_ward_attack(ability, source, target, amount)
    if not source or source:IsNull() or not target or target:IsNull() or not target:IsAlive() then return end
    source:EmitSound('Hero_WitchDoctor_Ward.Attack')
    ProjectileManager:CreateTrackingProjectile({
        Target = target, Source = source, Ability = ability,
        EffectName = 'particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf',
        iMoveSpeed = value(ability, 'projectile_speed'),
        bDodgeable = false, bVisibleToEnemies = true,
        ExtraData = { damage = amount },
    })
end

local function wd_ward_attack_impact(ability, target, extra)
    if not target or target:IsNull() or not target:IsAlive() then return true end
    local caster = ability:GetCaster()
    if not caster or caster:IsNull() or target:GetTeamNumber() == caster:GetTeamNumber() then return true end
    local amount = tonumber(extra and extra.damage) or 0
    if amount > 0 then
        damage(ability, target, amount, DAMAGE_TYPE_PHYSICAL)
        target:EmitSound('Hero_WitchDoctor_Ward.ProjectileImpact')
    end
    return true
end

enfos_wd_death_ward=class({})
function enfos_wd_death_ward:OnProjectileHit_ExtraData(target, location, extra)
    return wd_ward_attack_impact(self, target, extra)
end
function enfos_wd_death_ward:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_WitchDoctor.Death_WardBuild')
    local channel_duration = value(self, 'channel_duration')
    channel_duration = channel_duration > 0 and channel_duration or 8.0
    local ward = CreateUnitByName and CreateUnitByName('npc_dota_witch_doctor_death_ward', pos, true, c, c, c:GetTeamNumber()) or nil
    if ward and not ward:IsNull() then
        if ward.SetOwner then ward:SetOwner(c) end
        if ward.SetIdleAcquire then ward:SetIdleAcquire(false) end
        if ward.SetAcquisitionRange then ward:SetAcquisitionRange(0) end
        ward:AddNewModifier(c, self, 'modifier_enfos_wd_death_ward_visual', { duration = channel_duration })
        effect('particles/units/heroes/hero_witchdoctor/witchdoctor_ward_summon.vpcf', ward)
    end
    c:AddNewModifier(c, self, 'modifier_enfos_wd_death_ward_channel', {
        duration = channel_duration, x = pos.x, y = pos.y, z = pos.z,
        ward_idx = ward and not ward:IsNull() and ward:entindex() or nil,
    })
end
function enfos_wd_death_ward:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_wd_death_ward_channel')
    c:StopSound('Hero_WitchDoctor.Death_WardBuild')
end

modifier_enfos_wd_death_ward_channel=class({})
function modifier_enfos_wd_death_ward_channel:OnCreated(kv)
    if not IsServer() then return end
    self.pos = Vector(kv.x or 0, kv.y or 0, kv.z or 0)
    self.ward_idx = kv.ward_idx
    self:StartIntervalThink(0.22)
end
function modifier_enfos_wd_death_ward_channel:OnDestroy()
    if not IsServer() then return end
    local caster = self:GetCaster()
    if caster and not caster:IsNull() then caster:StopSound('Hero_WitchDoctor.Death_WardBuild') end
    local ward = self.ward_idx and EntIndexToHScript(self.ward_idx) or nil
    if ward and not ward:IsNull() then UTIL_Remove(ward) end
end
function modifier_enfos_wd_death_ward_channel:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local int = get_int(c)
    local base = (a and value(a, 'damage')) or 150
    local dmg = base + (int * 0.75)

    local targets = enemies(c, self.pos, 700, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
    if #targets > 0 then
        local t = targets[RandomInt(1, #targets)]
        local ward = self.ward_idx and EntIndexToHScript(self.ward_idx) or nil
        if ward and not ward:IsNull() then wd_launch_ward_attack(a, ward, t, dmg) end
    end
end

modifier_enfos_wd_death_ward_visual=class({})
function modifier_enfos_wd_death_ward_visual:IsHidden() return true end
function modifier_enfos_wd_death_ward_visual:IsPurgable() return false end
function modifier_enfos_wd_death_ward_visual:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    }
end

enfos_wd_voodoo_switcheroo=class({})
function enfos_wd_voodoo_switcheroo:OnProjectileHit_ExtraData(target, location, extra)
    return wd_ward_attack_impact(self, target, extra)
end
function enfos_wd_voodoo_switcheroo:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_WitchDoctor.Death_WardBuild')
    c:AddNewModifier(c, self, 'modifier_enfos_wd_voodoo_switcheroo_buff', { duration = 2.0 })
end

modifier_enfos_wd_voodoo_switcheroo_buff=class({})
function modifier_enfos_wd_voodoo_switcheroo_buff:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    if parent and not parent:IsNull() then parent:StopSound('Hero_WitchDoctor.Death_WardBuild') end
end
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
        wd_launch_ward_attack(a, c, t, dmg)
    end
end

enfos_wd_gris_gris=class({})
function enfos_wd_gris_gris:GetIntrinsicModifierName() return 'modifier_enfos_wd_gris_gris' end
modifier_enfos_wd_gris_gris=class({})
function modifier_enfos_wd_gris_gris:IsHidden() return false end
function modifier_enfos_wd_gris_gris:IsPurgable() return false end
function modifier_enfos_wd_gris_gris:RemoveOnDeath() return false end
function modifier_enfos_wd_gris_gris:OnCreated()
    if not IsServer() then return end
    local interval = value(self:GetAbility(), 'interval')
    self:StartIntervalThink(interval > 0 and interval or 3.0)
end
function modifier_enfos_wd_gris_gris:OnIntervalThink()
    local hero = self:GetParent()
    if not hero or (hero.IsNull and hero:IsNull())
        or (hero.PassivesDisabled and hero:PassivesDisabled())
        or (hero.IsIllusion and hero:IsIllusion()) then return end
    local player_id = hero.GetPlayerOwnerID and hero:GetPlayerOwnerID() or -1
    if player_id < 0 or not PlayerResource or not PlayerResource.IsValidPlayerID or not PlayerResource:IsValidPlayerID(player_id) then return end
    local amount = value(self:GetAbility(), 'gold_per_interval')
    if amount > 0 then PlayerResource:ModifyGold(player_id, amount, true, DOTA_ModifyGold_Unspecified) end
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
    if not c or (c.IsNull and c:IsNull()) then return end
    local origin = c:GetAbsOrigin()
    local dir = (self:GetCursorPosition() - origin):Normalized()
    if dir:Length2D() < 1 then dir = c:GetForwardVector() end
    c:EmitSound('Hero_DragonKnight.BreathFire')
    effect('particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf', c)

    local base = value(self, 'damage')
    if base <= 0 then base = 240 end
    local str = get_str(c)
    local dmg = base + (str * 1.2)
    local range = value(self, 'range')
    if range <= 0 then range = 750 end
    local width = value(self, 'width')
    if width <= 0 then width = 225 end
    local targets = FindUnitsInLine(c:GetTeamNumber(), origin, origin + (dir * range), nil, width,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE) or {}

    for _, u in ipairs(targets) do
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        effect('particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire_explosion.vpcf', u)
        u:AddNewModifier(c, self, 'modifier_enfos_dk_breathe_fire_debuff', { duration = value(self, 'duration') })
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
    if not c or not t or not t:IsAlive() or (t.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber()) then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_DragonKnight.DragonTail.Target')
    effect('particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_impact.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 250 end
    local str = get_str(c)
    local dmg = base + (str * 1.0)

    damage(self, t, dmg, DAMAGE_TYPE_PHYSICAL)
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 2.5 end
    if is_boss(t) then
        local boss_stun = value(self, 'boss_stun_duration')
        if boss_stun > 0 then stun_dur = math.min(stun_dur, boss_stun) end
    end
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
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'bonus_armor')) or 18
end
function modifier_enfos_dk_dragon_blood_passive:GetModifierConstantHealthRegen()
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_hp_regen')) or 25
    return base + (str * 0.05)
end

enfos_dk_elder_dragon_form=class({})
function enfos_dk_elder_dragon_form:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_DragonKnight.ElderDragonForm')
    effect('particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf', c)
    c:AddNewModifier(c, self, 'modifier_enfos_dk_elder_dragon_form_buff', { duration = value(self, 'duration') })
end

modifier_enfos_dk_elder_dragon_form_buff=class({})
function modifier_enfos_dk_elder_dragon_form_buff:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent()
    self.original_model = p and p.GetModelName and p:GetModelName() or nil
    if p and p.SetAttackCapability then
        p:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
        if p.SetRangedProjectileName then
            p:SetRangedProjectileName('particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf')
        end
    end
    if p and p.SetModel and p.SetOriginalModel then
        local dragon_model = 'models/heroes/dragon_knight/dragon_knight_dragon.vmdl'
        p:SetModel(dragon_model)
        p:SetOriginalModel(dragon_model)
    end
end
function modifier_enfos_dk_elder_dragon_form_buff:OnDestroy()
    if not IsServer() then return end
    local p = self:GetParent()
    if p and p.SetAttackCapability then
        p:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    end
    if p and self.original_model and p.SetModel and p.SetOriginalModel then
        p:SetModel(self.original_model)
        p:SetOriginalModel(self.original_model)
    end
end
function modifier_enfos_dk_elder_dragon_form_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_dk_elder_dragon_form_buff:GetModifierPreAttack_BonusDamage()
    return (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 60
end
function modifier_enfos_dk_elder_dragon_form_buff:GetModifierAttackRangeBonus()
    local bonus = self:GetAbility() and value(self:GetAbility(), 'attack_range_bonus') or 350
    return bonus > 0 and bonus or 350
end
function modifier_enfos_dk_elder_dragon_form_buff:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local t = params.target
    if not t or not t:IsAlive() then return end

    local ability = self:GetAbility()
    local splash_pct = value(ability, 'splash_damage_pct')
    if splash_pct <= 0 then splash_pct = 80 end
    local radius = value(ability, 'splash_radius')
    if radius <= 0 then radius = 300 end
    local splash_dmg = (params.damage or 200) * splash_pct / 100
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), radius)) do
        if u ~= t then
            damage(ability, u, splash_dmg, DAMAGE_TYPE_PHYSICAL)
            effect('particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire_explosion.vpcf', u)
            u:AddNewModifier(c, ability, 'modifier_enfos_dk_dragon_frost_slow', { duration = value(ability, 'splash_slow_duration') })
        end
    end
end

modifier_enfos_dk_dragon_frost_slow=class({})
function modifier_enfos_dk_dragon_frost_slow:IsDebuff() return true end
function modifier_enfos_dk_dragon_frost_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT } end
function modifier_enfos_dk_dragon_frost_slow:GetModifierMoveSpeedBonus_Percentage()
    local slow = self:GetAbility() and value(self:GetAbility(), 'splash_slow_pct') or 30
    return -slow
end
function modifier_enfos_dk_dragon_frost_slow:GetModifierAttackSpeedBonus_Constant()
    local slow = self:GetAbility() and value(self:GetAbility(), 'splash_attack_speed_slow') or 30
    return -slow
end

enfos_dk_wyrm_vigor=class({})
function enfos_dk_wyrm_vigor:GetIntrinsicModifierName() return 'modifier_enfos_dk_wyrm_vigor_passive' end

modifier_enfos_dk_wyrm_vigor_passive=class({})
function modifier_enfos_dk_wyrm_vigor_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end
function modifier_enfos_dk_wyrm_vigor_passive:GetModifierMagicalResistanceBonus()
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'magic_resist')
end
function modifier_enfos_dk_wyrm_vigor_passive:GetModifierBonusStats_Strength()
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'bonus_strength')
end

-- ----------------------------------------------------------------------------
-- PUDGE: MEAT HOOK, ROT, FLESH HEAP, DISMEMBER, MEAT SHIELD
-- ----------------------------------------------------------------------------

enfos_pudge_meat_hook=class({})
function enfos_pudge_meat_hook:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) then return end
    local origin = c:GetAbsOrigin()
    local dir = self:GetCursorPosition() - origin
    dir.z = 0
    if dir:Length2D() < 1 then dir = c:GetForwardVector() end
    dir.z = 0
    dir = dir:Normalized()
    c:EmitSound('Hero_Pudge.MeatHook')

    local base = value(self, 'hook_damage')
    if base <= 0 then base = 350 end
    self.hook_damage = base + (get_str(c) * 1.8)
    self.hook_direction = dir
    local range = value(self, 'hook_range')
    local width = value(self, 'hook_width')
    local speed = value(self, 'hook_speed')
    ProjectileManager:CreateLinearProjectile({
        Ability = self,
        EffectName = 'particles/units/heroes/hero_pudge/pudge_meathook.vpcf',
        vSpawnOrigin = origin,
        fDistance = range > 0 and range or 1400,
        fStartRadius = width > 0 and width or 100,
        fEndRadius = width > 0 and width or 100,
        Source = c,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        bDeleteOnHit = true,
        vVelocity = dir * (speed > 0 and speed or 1600),
        bProvidesVision = false,
    })
end
function enfos_pudge_meat_hook:OnProjectileHit(target, location)
    if not target or (target.IsNull and target:IsNull()) or not target:IsAlive() then return true end
    local c = self:GetCaster()
    if not c or (target.GetTeamNumber and target:GetTeamNumber() == c:GetTeamNumber()) then return true end
    damage(self, target, self.hook_damage or value(self, 'hook_damage'), DAMAGE_TYPE_PURE)
    effect('particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf', target)
    if not is_boss(target) then
        local pull_distance = 120
        local destination = c:GetAbsOrigin() + ((self.hook_direction or c:GetForwardVector()) * pull_distance)
        FindClearSpaceForUnit(target, destination, true)
    end
    self.hook_damage = nil
    return true
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
    local c = self:GetParent()
    c:EmitSound('Hero_Pudge.Rot')
    self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_pudge/pudge_rot.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    local radius = value(self:GetAbility(), 'rot_radius')
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(radius > 0 and radius or 350, 1, radius > 0 and radius or 350))
    self:StartIntervalThink(math.max(0.1, value(self:GetAbility(), 'tick_interval')))
end
function modifier_enfos_pudge_rot_aura:OnDestroy()
    if not IsServer() then return end
    local c = self:GetParent()
    if c and not c:IsNull() then c:StopSound('Hero_Pudge.Rot') end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
end
function modifier_enfos_pudge_rot_aura:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local interval = math.max(0.1, value(a, 'tick_interval'))
    local mana_per_second = value(a, 'mana_per_second')
    local mana_cost = mana_per_second * interval
    if mana_cost > 0 and c.GetMana and c:GetMana() < mana_cost then
        if a and a.ToggleAbility then a:ToggleAbility() else self:Destroy() end
        return
    end
    if mana_cost > 0 and c.SpendMana then c:SpendMana(mana_cost, a) end
    local base = (a and value(a, 'rot_damage')) or 80
    local str = get_str(c)
    local dmg = (base + (str * 0.4)) * interval
    local self_pct = value(a, 'self_damage_pct')
    if self_pct <= 0 then self_pct = 50 end
    local self_dmg = dmg * self_pct / 100

    -- Self damage (non-lethal)
    if c:GetHealth() > self_dmg + 10 then
        c:SetHealth(c:GetHealth() - self_dmg)
    end

    local radius = value(a, 'rot_radius')
    if radius <= 0 then radius = 350 end
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), radius)) do
        damage(a, u, dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, a, 'modifier_enfos_pudge_rot_debuff', { duration = value(a, 'debuff_duration') })
    end
end

modifier_enfos_pudge_rot_debuff=class({})
function modifier_enfos_pudge_rot_debuff:IsDebuff() return true end
function modifier_enfos_pudge_rot_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_pudge_rot_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -value(self:GetAbility(), 'slow_pct')
end

enfos_pudge_flesh_heap=class({})
function enfos_pudge_flesh_heap:GetIntrinsicModifierName() return 'modifier_enfos_pudge_flesh_heap_passive' end

modifier_enfos_pudge_flesh_heap_passive=class({})
function modifier_enfos_pudge_flesh_heap_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_EVENT_ON_DEATH }
end
function modifier_enfos_pudge_flesh_heap_passive:GetModifierPhysical_ConstantBlock()
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    local str = get_str(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'damage_block')) or 25
    return base + (str * 0.05)
end
function modifier_enfos_pudge_flesh_heap_passive:GetModifierBonusStats_Strength()
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_strength')) or 25
    local per_stack = self:GetAbility() and value(self:GetAbility(), 'strength_per_stack') or 0.5
    return base + ((self:GetStackCount() or 0) * per_stack)
end
function modifier_enfos_pudge_flesh_heap_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and params.unit ~= c then
        if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return end
        local a = self:GetAbility()
        local delta = value(a, is_boss(params.unit) and 'boss_kill_stacks' or 'normal_kill_stacks')
        local cap = value(a, 'max_stacks')
        if delta <= 0 then delta = is_boss(params.unit) and 5 or 1 end
        if cap <= 0 then cap = 100 end
        self:SetStackCount(math.min(cap, (self:GetStackCount() or 0) + delta))
    end
end

enfos_pudge_dismember=class({})
function enfos_pudge_dismember:GetChannelTime()
    return value(self, 'channel_duration') > 0 and value(self, 'channel_duration') or 3.0
end
function enfos_pudge_dismember:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or not t or not t:IsAlive() or (t.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber()) then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Pudge.Dismember')
    local dur = self:GetChannelTime()
    local target_control_duration = dur
    if is_boss(t) then
        local boss_cap = value(self, 'boss_control_duration')
        if boss_cap > 0 then target_control_duration = math.min(dur, boss_cap) end
    end
    c:AddNewModifier(c, self, 'modifier_enfos_pudge_dismember_channel', { duration = dur, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_pudge_dismember_target', { duration = target_control_duration })
end
function enfos_pudge_dismember:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_pudge_dismember_channel')
end

modifier_enfos_pudge_dismember_channel=class({})
function modifier_enfos_pudge_dismember_channel:OnDestroy()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local target=self.target_idx and EntIndexToHScript(self.target_idx)
    if target and not target:IsNull() then target:RemoveModifierByNameAndCaster('modifier_enfos_pudge_dismember_target',caster) end
    if caster and not caster:IsNull() then caster:StopSound('Hero_Pudge.Dismember') end
end
function modifier_enfos_pudge_dismember_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx = kv and kv.target_idx or nil
    local interval = value(self:GetAbility(), 'tick_interval')
    self:StartIntervalThink(interval > 0 and interval or 0.5)
end
function modifier_enfos_pudge_dismember_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive()
        or not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then
        if a and a.EndChannel then a:EndChannel(true) else self:Destroy() end
        return
    end

    local base = (a and value(a, 'dps')) or 180
    local str = get_str(c)
    local interval = value(a, 'tick_interval')
    if interval <= 0 then interval = 0.5 end
    local strength_factor = value(a, 'strength_factor')
    if strength_factor <= 0 then strength_factor = 1.0 end
    local tick_dmg = (base + (str * strength_factor)) * interval

    local dealt = damage(a, t, tick_dmg, DAMAGE_TYPE_MAGICAL)
    c:Heal(type(dealt) == 'number' and dealt or tick_dmg, a)
end

modifier_enfos_pudge_dismember_target=class({})
function modifier_enfos_pudge_dismember_target:IsDebuff() return true end
function modifier_enfos_pudge_dismember_target:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end
function modifier_enfos_pudge_dismember_target:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent()
    self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_pudge/pudge_dismember.vpcf', PATTACH_ABSORIGIN_FOLLOW, p)
end
function modifier_enfos_pudge_dismember_target:OnDestroy()
    if self.pfx and ParticleManager then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
end

enfos_pudge_meat_shield=class({})
function enfos_pudge_meat_shield:GetIntrinsicModifierName() return 'modifier_enfos_pudge_meat_shield_passive' end

modifier_enfos_pudge_meat_shield_passive=class({})
function modifier_enfos_pudge_meat_shield_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_pudge_meat_shield_passive:GetModifierMagicalResistanceBonus()
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'magic_resist')
end
function modifier_enfos_pudge_meat_shield_passive:GetModifierHealthBonus()
    local c = self:GetParent()
    if (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'bonus_hp')
end
function modifier_enfos_pudge_meat_shield_passive:OnTakeDamage(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.unit ~= c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return end
    self.accumulated = (self.accumulated or 0) + (params.damage or 0)
    local ability = self:GetAbility()
    local threshold = value(ability, 'damage_threshold')
    if threshold <= 0 then threshold = 500 end
    if self.accumulated >= threshold then
        local bursts = math.min(3, math.floor(self.accumulated / threshold))
        self.accumulated = self.accumulated - bursts * threshold
        local burst = (c:GetMaxHealth() or 1000) * value(ability, 'burst_hp_pct') / 100 * bursts
        local radius = value(ability, 'burst_radius')
        if radius <= 0 then radius = 400 end
        for _, u in ipairs(enemies(c, c:GetAbsOrigin(), radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
            damage(ability, u, burst, DAMAGE_TYPE_PHYSICAL)
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
    effect('particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf', c)
    local count = value(self, 'pulse_count')
    local interval = value(self, 'tick_interval')
    c:AddNewModifier(c, self, 'modifier_enfos_slark_dark_pact_buff', { duration = (count > 0 and count or 10) * (interval > 0 and interval or 0.15) })
end

modifier_enfos_slark_dark_pact_buff=class({})
function modifier_enfos_slark_dark_pact_buff:OnCreated()
    if not IsServer() then return end
    self.ticks = 0
    local interval = value(self:GetAbility(), 'tick_interval')
    self:StartIntervalThink(interval > 0 and interval or 0.15)
end
function modifier_enfos_slark_dark_pact_buff:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    if c.Purge then c:Purge(false, true, false, true, true) end

    self.ticks = (self.ticks or 0) + 1
    local base = (a and value(a, 'damage')) or 200
    local agi = get_agi(c)
    local interval = value(a, 'tick_interval')
    if interval <= 0 then interval = 0.15 end
    local pulse_count = value(a, 'pulse_count')
    if pulse_count <= 0 then pulse_count = 10 end
    local agility_factor = value(a, 'agility_factor')
    local tick_dmg = (base + (agi * agility_factor)) / pulse_count
    local radius = value(a, 'radius')
    if radius <= 0 then radius = 350 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), radius)) do
        damage(a, u, tick_dmg, DAMAGE_TYPE_MAGICAL)
    end
    if self.ticks >= pulse_count then self:Destroy() end
end

enfos_slark_pounce=class({})
function enfos_slark_pounce:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Slark.Pounce.Cast')
    local distance = value(self, 'pounce_distance')
    if distance <= 0 then distance = 700 end
    effect('particles/units/heroes/hero_slark/slark_pounce_start.vpcf', c)
    local speed = value(self, 'dash_speed')
    if speed <= 0 then speed = 1400 end
    c:AddNewModifier(c, self, 'modifier_enfos_slark_pounce_dash', { distance = distance, speed = speed })
end

modifier_enfos_slark_pounce_dash=class({})
function modifier_enfos_slark_pounce_dash:IsHidden() return true end
function modifier_enfos_slark_pounce_dash:IsPurgable() return false end
function modifier_enfos_slark_pounce_dash:OnCreated(kv)
    if not IsServer() then return end
    local c = self:GetParent()
    self.origin = c:GetAbsOrigin()
    self.direction = c.GetForwardVector and c:GetForwardVector() or Vector(1, 0, 0)
    self.distance = math.max(0, tonumber(kv and kv.distance) or value(self:GetAbility(), 'pounce_distance'))
    self.speed = math.max(1, tonumber(kv and kv.speed) or value(self:GetAbility(), 'dash_speed'))
    if self.distance <= 0 then self.distance = 700 end
    if self.speed <= 0 then self.speed = 1400 end
    self.elapsed = 0
    self:StartIntervalThink(0.03)
    self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_slark/slark_pounce_trail.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
end
function modifier_enfos_slark_pounce_dash:OnIntervalThink()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then self:Destroy(); return end
    self.elapsed = (self.elapsed or 0) + 0.03
    local fraction = math.min(1, self.elapsed * self.speed / self.distance)
    local position = self.origin + (self.direction * (self.distance * fraction))
    c:SetAbsOrigin(position)
    if fraction >= 1 then
        FindClearSpaceForUnit(c, position, true)
        effect('particles/units/heroes/hero_slark/slark_pounce_splash.vpcf', c)
        local ability = self:GetAbility()
        local radius = value(ability, 'impact_radius')
        if radius <= 0 then radius = 250 end
        local base = value(ability, 'damage')
        if base <= 0 then base = 180 end
        local dealt = base + (get_agi(c) * value(ability, 'agility_factor'))
        for _, u in ipairs(enemies(c, position, radius)) do
            damage(ability, u, dealt, DAMAGE_TYPE_PHYSICAL)
            effect('particles/units/heroes/hero_slark/slark_pounce_leash.vpcf', u)
            local duration = value(ability, 'leash_duration')
            if is_boss(u) then
                local boss_duration = value(ability, 'boss_leash_duration')
                if boss_duration > 0 then duration = boss_duration end
            end
            u:AddNewModifier(c, ability, 'modifier_enfos_slark_pounce_leash', { duration = duration })
            break
        end
        self:Destroy()
    end
end
function modifier_enfos_slark_pounce_dash:OnDestroy()
    if self.pfx and ParticleManager then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
end

modifier_enfos_slark_pounce_leash=class({})
function modifier_enfos_slark_pounce_leash:IsDebuff() return true end
function modifier_enfos_slark_pounce_leash:CheckState() return { [MODIFIER_STATE_TETHERED] = true } end
function modifier_enfos_slark_pounce_leash:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_slark_pounce_leash:GetModifierMoveSpeedBonus_Percentage() return -80 end

enfos_slark_essence_shift=class({})
function enfos_slark_essence_shift:GetIntrinsicModifierName() return 'modifier_enfos_slark_essence_shift_passive' end

modifier_enfos_slark_essence_shift_passive=class({})
function modifier_enfos_slark_essence_shift_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_slark_essence_shift_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) then return end
    if c.PassivesDisabled and c:PassivesDisabled() then return end
    local t = params.target
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() or (t.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber()) then return end
    local buff = c:FindModifierByName('modifier_enfos_slark_essence_shift_buff')
    local ability = self:GetAbility()
    if not buff then
        buff = c:AddNewModifier(c, ability, 'modifier_enfos_slark_essence_shift_buff', { duration = value(ability, 'duration') })
    end
    if buff and buff.SetStackCount then
        local cur = (buff.GetStackCount and buff:GetStackCount()) or 0
        local cap = value(ability, 'max_stacks')
        buff:SetStackCount(math.min(cap > 0 and cap or 50, cur + 1))
        buff:SetDuration(value(ability, 'duration'), true)
        effect('particles/units/heroes/hero_slark/slark_essence_shift_hit_glow.vpcf', t)
    end
end

modifier_enfos_slark_essence_shift_buff=class({})
function modifier_enfos_slark_essence_shift_buff:DeclareFunctions() return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS } end
function modifier_enfos_slark_essence_shift_buff:GetModifierBonusStats_Agility()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local ability = self:GetAbility()
    return (self:GetStackCount() or 0) * value(ability, 'bonus_agi')
end

enfos_slark_shadow_dance=class({})
function enfos_slark_shadow_dance:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Slark.ShadowDance')
    c:AddNewModifier(c, self, 'modifier_enfos_slark_shadow_dance_buff', { duration = value(self, 'duration') })
end

modifier_enfos_slark_shadow_dance_buff=class({})
function modifier_enfos_slark_shadow_dance_buff:OnCreated()
    if not IsServer() then return end
    self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_slark/slark_shadow_dance.vpcf', PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end
function modifier_enfos_slark_shadow_dance_buff:OnDestroy()
    if self.pfx and ParticleManager then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
end
function modifier_enfos_slark_shadow_dance_buff:CheckState()
    return { [MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true }
end
function modifier_enfos_slark_shadow_dance_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end
function modifier_enfos_slark_shadow_dance_buff:GetModifierMoveSpeedBonus_Percentage() return value(self:GetAbility(), 'bonus_ms') end
function modifier_enfos_slark_shadow_dance_buff:GetModifierHealthRegenPercentage() return value(self:GetAbility(), 'health_regen_pct') end

enfos_slark_fish_bait=class({})
function enfos_slark_fish_bait:GetIntrinsicModifierName() return 'modifier_enfos_slark_fish_bait_passive' end

modifier_enfos_slark_fish_bait_passive=class({})
function modifier_enfos_slark_fish_bait_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_slark_fish_bait_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) then return end
    local t = params.target
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() or (t.GetTeamNumber and t:GetTeamNumber() == c:GetTeamNumber()) then return end

    local ability = self:GetAbility()
    if RollPercentage(value(ability, 'proc_chance')) then
        effect('particles/units/heroes/hero_slark/slark_shard_fish_bait_impact_splash.vpcf', t)
        local existing = t.FindModifierByNameAndCaster and t:FindModifierByNameAndCaster('modifier_enfos_slark_fish_bait_debuff', c) or nil
        local cap = value(ability, 'max_armor_stacks')
        if cap <= 0 then cap = 5 end
        if existing then
            existing:SetStackCount(math.min(cap, existing:GetStackCount() + 1))
            existing:SetDuration(value(ability, 'debuff_duration'), true)
        else
            local debuff = t:AddNewModifier(c, ability, 'modifier_enfos_slark_fish_bait_debuff', { duration = value(ability, 'debuff_duration') })
            if debuff and debuff.SetStackCount then debuff:SetStackCount(1) end
        end
        local cleave = (params.damage or 150) * value(ability, 'cleave_pct') / 100
        local radius = value(ability, 'cleave_radius')
        if radius <= 0 then radius = 250 end
        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
            if u ~= t then damage(self:GetAbility(), u, cleave, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

modifier_enfos_slark_fish_bait_debuff=class({})
function modifier_enfos_slark_fish_bait_debuff:IsDebuff() return true end
function modifier_enfos_slark_fish_bait_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_slark_fish_bait_debuff:GetModifierPhysicalArmorBonus()
    return -value(self:GetAbility(), 'armor_reduction') * (self:GetStackCount() or 1)
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
    local dmg = base + (str * value(self, 'strength_factor'))
    local radius = value(self, 'radius')
    if radius <= 0 then radius = 385 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), radius)) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        local duration = value(self, 'slow_duration')
        if is_boss(u) then duration = math.min(duration, value(self, 'boss_slow_duration')) end
        u:AddNewModifier(c, self, 'modifier_enfos_ursa_earthshock_slow', {
            duration = duration, slow_pct = value(self, 'slow_pct')
        })
    end
end

modifier_enfos_ursa_earthshock_slow=class({})
function modifier_enfos_ursa_earthshock_slow:IsDebuff() return true end
function modifier_enfos_ursa_earthshock_slow:OnCreated(params) self.slow_pct = tonumber(params.slow_pct) or value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_ursa_earthshock_slow:OnRefresh(params) self:OnCreated(params) end
function modifier_enfos_ursa_earthshock_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_ursa_earthshock_slow:GetModifierMoveSpeedBonus_Percentage() return -(self.slow_pct or value(self:GetAbility(), 'slow_pct')) end

enfos_ursa_overpower=class({})
function enfos_ursa_overpower:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Ursa.Overpower')
    local mod = c:AddNewModifier(c, self, 'modifier_enfos_ursa_overpower_buff', { duration = value(self, 'buff_duration') })
    if mod and mod.SetStackCount then mod:SetStackCount(value(self, 'max_attacks')) end
end

modifier_enfos_ursa_overpower_buff=class({})
function modifier_enfos_ursa_overpower_buff:GetEffectName() return 'particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf' end
function modifier_enfos_ursa_overpower_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_ursa_overpower_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_ursa_overpower_buff:GetModifierAttackSpeedBonus_Constant() return value(self:GetAbility(), 'attack_speed') end
function modifier_enfos_ursa_overpower_buff:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c then return end
    local target = params.target
    if not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or target:GetTeamNumber() == c:GetTeamNumber() then return end
    if params.damage and params.damage > 0 then
        c:Heal(params.damage * value(self:GetAbility(), 'attack_heal_pct') / 100, self:GetAbility())
    end

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
    if params.attacker ~= c or c:PassivesDisabled() or (c.IsIllusion and c:IsIllusion()) then return end
    local t = params.target
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end

    local mod = t.FindModifierByNameAndCaster
        and t:FindModifierByNameAndCaster('modifier_enfos_ursa_fury_swipes_debuff', c) or nil
    if not mod then
        mod = t:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_ursa_fury_swipes_debuff', { duration = value(self:GetAbility(), 'debuff_duration') })
    end
    if mod and mod.SetStackCount then
        local cur = (mod.GetStackCount and mod:GetStackCount()) or 0
        local cap = value(self:GetAbility(), is_boss(t) and 'boss_max_stacks' or 'max_stacks')
        local nextStack = math.min(cap, cur + 1)
        mod:SetStackCount(nextStack)
        mod:SetDuration(value(self:GetAbility(), 'debuff_duration'), true)

        local ability = self:GetAbility()
        local base = value(ability, 'bonus_damage')
        local agi = get_agi(c)
        local extra_dmg = nextStack * (base + (agi * value(ability, 'agility_factor')))
        damage(self:GetAbility(), t, extra_dmg, DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_ursa/ursa_fury_swipes.vpcf', t)

        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), value(ability, 'cleave_radius'), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
            if u ~= t then damage(ability, u, extra_dmg * value(ability, 'cleave_pct') / 100, DAMAGE_TYPE_PHYSICAL) end
        end
    end
end

modifier_enfos_ursa_fury_swipes_debuff=class({})
function modifier_enfos_ursa_fury_swipes_debuff:IsDebuff() return true end
function modifier_enfos_ursa_fury_swipes_debuff:GetEffectName() return 'particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf' end
function modifier_enfos_ursa_fury_swipes_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

enfos_ursa_enrage=class({})
function enfos_ursa_enrage:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_Ursa.Enrage')
    if c.Purge then c:Purge(false, true, false, true, true) end
    c:AddNewModifier(c, self, 'modifier_enfos_ursa_enrage_buff', { duration = value(self, 'duration') })
end

modifier_enfos_ursa_enrage_buff=class({})
function modifier_enfos_ursa_enrage_buff:GetEffectName() return 'particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf' end
function modifier_enfos_ursa_enrage_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_ursa_enrage_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING }
end
function modifier_enfos_ursa_enrage_buff:GetModifierIncomingDamage_Percentage() return -value(self:GetAbility(), 'damage_reduction') end
function modifier_enfos_ursa_enrage_buff:GetModifierStatusResistanceStacking() return value(self:GetAbility(), 'status_resistance') end

enfos_ursa_ursa_minor=class({})
function enfos_ursa_ursa_minor:GetIntrinsicModifierName() return 'modifier_enfos_ursa_minor_passive' end

modifier_enfos_ursa_minor_passive=class({})
function modifier_enfos_ursa_minor_passive:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT } end
function modifier_enfos_ursa_minor_passive:GetModifierMoveSpeedBonus_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_ms')
end

-- ----------------------------------------------------------------------------
-- MONKEY KING: BOUNDLESS STRIKE, PRIMAL SPRING, JINGU MASTERY, WUKONG'S, MISCHIEF
-- ----------------------------------------------------------------------------

enfos_mk_boundless_strike=class({})
function enfos_mk_boundless_strike:OnSpellStart()
    local c = self:GetCaster()
    local origin = c:GetAbsOrigin()
    local direction = self:GetCursorPosition() - origin
    direction.z = 0
    if direction:Length2D() < 1 then direction = c:GetForwardVector() end
    direction.z = 0
    local dir = direction:Normalized()
    local range = value(self, 'range')
    if range <= 0 then range = 1200 end
    local width = value(self, 'radius')
    if width <= 0 then width = 150 end
    local endpoint = origin + (dir * range)
    c:EmitSound('Hero_MonkeyKing.Strike.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, endpoint)
    ParticleManager:ReleaseParticleIndex(fx)

    local dmg = get_atk(c) * value(self, 'strike_damage') / 100
    local targets = FindUnitsInLine(c:GetTeamNumber(), origin, endpoint, nil, width,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) or {}
    for _, u in ipairs(targets) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_monkey_king/mk_strike_path_pulse_hit.vpcf', u)
        local duration = value(self, 'stun_duration')
        if is_boss(u) then duration = math.min(duration, value(self, 'boss_stun_duration')) end
        if duration > 0 then u:AddNewModifier(c, self, 'modifier_enfos_mk_boundless_strike_stun', { duration = duration }) end
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
    effect('particles/units/heroes/hero_monkey_king/monkey_king_spring_cast.vpcf', c)
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_monkey_king/monkey_king_spring.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, pos)
    ParticleManager:ReleaseParticleIndex(fx)
    FindClearSpaceForUnit(c, pos, true)

    local base = value(self, 'spring_damage')
    if base <= 0 then base = 280 end
    local agi = get_agi(c)
    local dmg = base + (agi * value(self, 'agility_factor'))

    for _, u in ipairs(enemies(c, pos, value(self, 'radius'))) do
        damage(self, u, dmg, DAMAGE_TYPE_PHYSICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_mk_primal_spring_slow', {
            duration = value(self, 'slow_duration'), slow_pct = value(self, 'slow_pct')
        })
    end
end

modifier_enfos_mk_primal_spring_slow=class({})
function modifier_enfos_mk_primal_spring_slow:IsDebuff() return true end
function modifier_enfos_mk_primal_spring_slow:OnCreated(params) self.slow_pct = tonumber(params.slow_pct) or value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_mk_primal_spring_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_mk_primal_spring_slow:GetModifierMoveSpeedBonus_Percentage() return -(self.slow_pct or value(self:GetAbility(), 'slow_pct')) end

enfos_mk_jingu_mastery=class({})
function enfos_mk_jingu_mastery:GetIntrinsicModifierName() return 'modifier_enfos_mk_jingu_mastery_passive' end

modifier_enfos_mk_jingu_mastery_passive=class({})
function modifier_enfos_mk_jingu_mastery_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_mk_jingu_mastery_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker ~= c or c:PassivesDisabled() or (c.IsIllusion and c:IsIllusion()) then return end
    local target = params.target
    if not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or target:GetTeamNumber() == c:GetTeamNumber() then return end
    if c:HasModifier('modifier_enfos_mk_jingu_mastery_buff') then return end

    self.counter = (self.counter or 0) + 1
    if self.counter >= value(self:GetAbility(), 'charges_required') then
        self.counter = 0
        effect('particles/units/heroes/hero_monkey_king/monkey_king_furarmy_singlemonkey_attack_swipe.vpcf', target)
        local b = c:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_mk_jingu_mastery_buff', { duration = value(self:GetAbility(), 'buff_duration') })
        if b and b.SetStackCount then b:SetStackCount(value(self:GetAbility(), 'buff_attacks')) end
    end
end

modifier_enfos_mk_jingu_mastery_buff=class({})
function modifier_enfos_mk_jingu_mastery_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED }
end
function modifier_enfos_mk_jingu_mastery_buff:GetModifierPreAttack_BonusDamage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local agi = get_agi(c)
    local base = (self.GetAbility and value(self:GetAbility(), 'bonus_damage')) or 140
    return base + (agi * value(self:GetAbility(), 'agility_factor'))
end
function modifier_enfos_mk_jingu_mastery_buff:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    local target = params.target
    if params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())
        or not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or target:GetTeamNumber() == c:GetTeamNumber() then return end
    if params.damage and params.damage > 0 then c:Heal(params.damage * value(self:GetAbility(), 'lifesteal_pct') / 100, self:GetAbility()) end

    local count = (self:GetStackCount() or 1) - 1
    if count <= 0 then self:Destroy() else self:SetStackCount(count) end
end

enfos_mk_wukongs_command=class({})
function enfos_mk_wukongs_command:OnSpellStart()
    local c = self:GetCaster()
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_MonkeyKing.FurArmy')
    ground_effect(c, self, 'modifier_enfos_mk_wukongs_command_thinker', { duration = value(self, 'duration') }, pos)
end

modifier_enfos_mk_wukongs_command_thinker=class({})
function modifier_enfos_mk_wukongs_command_thinker:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent():GetAbsOrigin()
    self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_monkey_king/monkey_king_furarmy_aoe.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.pfx, 0, p)
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(value(self:GetAbility(), 'ring_radius'), 1, 1))
    self:StartIntervalThink(value(self:GetAbility(), 'attack_interval'))
end
function modifier_enfos_mk_wukongs_command_thinker:OnDestroy()
    if not IsServer() then return end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
    remove_ground_effect(self)
end
function modifier_enfos_mk_wukongs_command_thinker:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local t = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then self:Destroy() return end

    local atk = get_atk(c)
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), value(a, 'ring_radius'), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        damage(a, u, atk * value(a, 'soldier_damage') / 100, DAMAGE_TYPE_PHYSICAL)
        effect('particles/units/heroes/hero_monkey_king/monkey_king_fur_army_attack.vpcf', u)
    end
end

enfos_mk_mischief=class({})
function enfos_mk_mischief:GetIntrinsicModifierName() return 'modifier_enfos_mk_mischief_passive' end

modifier_enfos_mk_mischief_passive=class({})
function modifier_enfos_mk_mischief_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT }
end
function modifier_enfos_mk_mischief_passive:GetModifierAttackRangeBonus()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_range')
end
function modifier_enfos_mk_mischief_passive:GetModifierEvasion_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'evasion_pct')
end

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
    if not c or params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) then return end
    local t = params.target
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive()
        or t:GetTeamNumber() == c:GetTeamNumber() then return end

    local ab = self:GetAbility()
    local base = (ab and value(ab, 'bonus_damage')) or 70
    local agi = get_agi(c)
    local dmg = base + (agi * ((ab and value(ab, 'agility_factor')) or 0.6))

    damage(self:GetAbility(), t, dmg, DAMAGE_TYPE_PHYSICAL)
    effect('particles/units/heroes/hero_antimage/antimage_manabreak_enemy_debuff.vpcf', t)
    local radius = (ab and value(ab, 'cleave_radius')) or 250
    local cleave = (ab and value(ab, 'cleave_pct')) or 35
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), radius, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        if u ~= t then damage(ab, u, dmg * cleave / 100, DAMAGE_TYPE_PHYSICAL) end
    end
end

enfos_am_blink=class({})
function enfos_am_blink:GetCastRange() return value(self, 'blink_range') end
function enfos_am_blink:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local target_pos = self:GetCursorPosition()
    c:EmitSound('Hero_Antimage.Blink_out')
    local p1 = ParticleManager:CreateParticle('particles/units/heroes/hero_antimage/antimage_blink_start.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p1, 0, c:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(p1)

    FindClearSpaceForUnit(c, target_pos, true)

    local p2 = ParticleManager:CreateParticle('particles/units/heroes/hero_antimage/antimage_blink_end.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(p2, 0, target_pos)
    ParticleManager:ReleaseParticleIndex(p2)
    c:EmitSound('Hero_Antimage.Blink_in')
end

enfos_am_counterspell=class({})
function enfos_am_counterspell:GetIntrinsicModifierName() return 'modifier_enfos_am_counterspell_passive' end
function enfos_am_counterspell:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Antimage.Counterspell.Cast')
    effect('particles/units/heroes/hero_antimage/antimage_spellshield.vpcf', c)
    c:AddNewModifier(c, self, 'modifier_enfos_am_counterspell_active', { duration = value(self, 'active_duration') })
end

modifier_enfos_am_counterspell_passive=class({})
function modifier_enfos_am_counterspell_passive:DeclareFunctions() return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS } end
function modifier_enfos_am_counterspell_passive:GetModifierMagicalResistanceBonus()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return (self.GetAbility and value(self:GetAbility(), 'magic_resist')) or 40
end

modifier_enfos_am_counterspell_active=class({})
function modifier_enfos_am_counterspell_active:DeclareFunctions() return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS } end
function modifier_enfos_am_counterspell_active:GetModifierMagicalResistanceBonus()
    local ab = self:GetAbility()
    return ab and value(ab, 'active_resist') or 100
end
function modifier_enfos_am_counterspell_active:GetEffectName() return 'particles/units/heroes/hero_antimage/antimage_spellshield.vpcf' end
function modifier_enfos_am_counterspell_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

enfos_am_mana_void=class({})
function enfos_am_mana_void:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not t or (t.IsNull and t:IsNull()) or not t:IsAlive()
        or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Antimage.ManaVoid')
    effect('particles/units/heroes/hero_antimage/antimage_manavoid.vpcf', t)

    local missing_mana = 0
    if t.GetMaxMana and t.GetMana then
        missing_mana = math.max(0, t:GetMaxMana() - t:GetMana())
    end
    local dmg = value(self, 'base_damage')
        + (missing_mana * value(self, 'damage_per_missing_mana'))
        + (get_agi(c) * value(self, 'agility_factor'))

    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), value(self, 'radius'), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
        local unit_damage = dmg
        if is_boss(u) and u.GetMaxHealth then
            unit_damage = math.min(unit_damage, u:GetMaxHealth() * value(self, 'boss_damage_cap_pct') / 100)
        end
        damage(self, u, unit_damage, DAMAGE_TYPE_MAGICAL)
        if not is_boss(u) and u.AddNewModifier then
            u:AddNewModifier(c, self, 'modifier_enfos_am_mana_void_stun', { duration = value(self, 'stun_duration') })
        end
    end
end

modifier_enfos_am_mana_void_stun=class({})
function modifier_enfos_am_mana_void_stun:IsDebuff() return true end
function modifier_enfos_am_mana_void_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_am_spellbreaker=class({})
function enfos_am_spellbreaker:GetIntrinsicModifierName() return 'modifier_enfos_am_spellbreaker_passive' end

modifier_enfos_am_spellbreaker_passive=class({})
function modifier_enfos_am_spellbreaker_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_enfos_am_spellbreaker_passive:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_as')
end
function modifier_enfos_am_spellbreaker_passive:GetModifierMoveSpeedBonus_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_ms')
end

-- ----------------------------------------------------------------------------
-- FACELESS VOID: TIME WALK, TIME DILATION, TIME LOCK, CHRONOSPHERE, BACKTRACK
-- ----------------------------------------------------------------------------

enfos_void_time_walk=class({})
function enfos_void_time_walk:GetCastRange() return value(self, 'range') end
function enfos_void_time_walk:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_FacelessVoid.TimeWalk')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_faceless_void/faceless_void_time_walk.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, pos)
    ParticleManager:ReleaseParticleIndex(fx)
    FindClearSpaceForUnit(c, pos, true)
    c:Heal(value(self, 'heal'), self)
end

enfos_void_time_dilation=class({})
function enfos_void_time_dilation:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_FacelessVoid.TimeDilation.Cast')
    effect('particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf', c)
    local duration = value(self, 'duration')
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(self, 'radius'))) do
        local unit_duration = duration
        if is_boss(u) then unit_duration = math.min(unit_duration, value(self, 'boss_duration')) end
        u:AddNewModifier(c, self, 'modifier_enfos_void_time_dilation_debuff', { duration = unit_duration })
    end
end

modifier_enfos_void_time_dilation_debuff=class({})
function modifier_enfos_void_time_dilation_debuff:IsDebuff() return true end
function modifier_enfos_void_time_dilation_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_void_time_dilation_debuff:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'move_slow_pct') end
function modifier_enfos_void_time_dilation_debuff:GetModifierAttackSpeedBonus_Constant() return -value(self:GetAbility(), 'attack_slow') end
function modifier_enfos_void_time_dilation_debuff:GetEffectName() return 'particles/units/heroes/hero_faceless_void/faceless_void_dialatedebuf.vpcf' end
function modifier_enfos_void_time_dilation_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

enfos_void_time_lock=class({})
function enfos_void_time_lock:GetIntrinsicModifierName() return 'modifier_enfos_void_time_lock_passive' end

modifier_enfos_void_time_lock_passive=class({})
function modifier_enfos_void_time_lock_passive:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_void_time_lock_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if not c or params.attacker ~= c or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) then return end
    local t = params.target
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive()
        or t:GetTeamNumber() == c:GetTeamNumber() then return end

    local ab = self:GetAbility()
    if RollPercentage(value(ab, 'proc_chance')) then
        c:EmitSound('Hero_FacelessVoid.TimeLock.Impact')
        effect('particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf', t)
        local dmg = value(ab, 'bonus_damage') + (get_agi(c) * value(ab, 'agility_factor'))
        damage(self:GetAbility(), t, dmg, DAMAGE_TYPE_MAGICAL)
        local dur = value(ab, 'stun_duration')
        if is_boss(t) then dur = math.min(dur, value(ab, 'boss_stun_duration')) end
        t:AddNewModifier(c, ab, 'modifier_enfos_void_time_lock_stun', { duration = dur })
    end
end

modifier_enfos_void_time_lock_stun=class({})
function modifier_enfos_void_time_lock_stun:IsDebuff() return true end
function modifier_enfos_void_time_lock_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_void_chronosphere=class({})
function enfos_void_chronosphere:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local pos = self:GetCursorPosition()
    c:EmitSound('Hero_FacelessVoid.Chronosphere')
    local dur = (self.GetSpecialValueFor and self:GetSpecialValueFor('duration')) or 5.0
    ground_effect(c, self, 'modifier_enfos_void_chronosphere_thinker', { duration = dur }, pos)
end

modifier_enfos_void_chronosphere_thinker=class({})
function modifier_enfos_void_chronosphere_thinker:OnCreated()
    if not IsServer() then return end
    self.bossHits = {}
    local p = self:GetParent():GetAbsOrigin()
    self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.pfx, 0, p)
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(value(self:GetAbility(), 'radius'), value(self:GetAbility(), 'radius'), value(self:GetAbility(), 'radius')))
    self:StartIntervalThink(0.1)
end
function modifier_enfos_void_chronosphere_thinker:OnDestroy()
    if not IsServer() then return end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
    remove_ground_effect(self)
end
function modifier_enfos_void_chronosphere_thinker:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local t = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) then self:Destroy() return end

    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), value(a, 'radius'))) do
        if not is_boss(u) then
            u:AddNewModifier(c, a, 'modifier_enfos_void_chronosphere_freeze', { duration = 0.5 })
        elseif not self.bossHits[u:entindex()] then
            -- Refreshing a 0.3s stun every 0.1s used to freeze bosses for the entire sphere.
            self.bossHits[u:entindex()]=true
            u:AddNewModifier(c, a, 'modifier_enfos_void_chronosphere_freeze', { duration = value(a, 'boss_duration') })
        end
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
    local c = self:GetParent()
    if not IsServer() or not c or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) then return 0 end
    if RollPercentage(value(self:GetAbility(), 'dodge_pct')) then
        effect('particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf', c)
        return 1
    end
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
        for _, u in ipairs(enemies(c, pos, value(self, 'radius'))) do
            damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
            effect('particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf', u)
        end
    end
end

enfos_sf_necromastery=class({})
function enfos_sf_necromastery:GetIntrinsicModifierName() return 'modifier_enfos_sf_necromastery_passive' end

modifier_enfos_sf_necromastery_passive=class({})
function modifier_enfos_sf_necromastery_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_DEATH }
end
function modifier_enfos_sf_necromastery_passive:GetModifierPreAttack_BonusDamage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return (self:GetStackCount() or 0) * value(self:GetAbility(), 'damage_per_soul')
end
function modifier_enfos_sf_necromastery_passive:GetModifierSpellAmplify_Percentage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return (self:GetStackCount() or 0) * 1.0
end
function modifier_enfos_sf_necromastery_passive:OnDeath(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return end
    if not params or params.attacker ~= c or params.unit == c or not params.unit then return end
    local delta = is_boss(params.unit) and 10 or 2
    self:SetStackCount(math.min(value(self:GetAbility(), 'max_souls'), (self:GetStackCount() or 0) + delta))
end

enfos_sf_presence_of_the_dark_lord=class({})
function enfos_sf_presence_of_the_dark_lord:GetIntrinsicModifierName() return 'modifier_enfos_sf_presence_aura' end

modifier_enfos_sf_presence_aura=class({})
function modifier_enfos_sf_presence_aura:IsHidden() return true end
function modifier_enfos_sf_presence_aura:IsAura()
    local c = self:GetParent()
    return c and not (c.IsNull and c:IsNull()) and not (c.PassivesDisabled and c:PassivesDisabled())
        and not (c.IsIllusion and c:IsIllusion())
end
function modifier_enfos_sf_presence_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
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
    local dmg = value(self, 'damage_per_wave') + (int * 1.8)

    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), value(self, 'radius'))) do
        local hit = dmg
        if is_boss(u) then hit = math.min(hit, u:GetMaxHealth() * 0.1) end
        damage(self, u, hit, DAMAGE_TYPE_MAGICAL)
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
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return end
    if not params or params.attacker ~= c or params.unit == c or not params.unit then return end
    local a = self:GetAbility()
    c:Heal(value(a, 'hp_per_kill'), a)
    if c.GiveMana then c:GiveMana(value(a, 'mana_per_kill')) end
end

-- ----------------------------------------------------------------------------
-- STORM SPIRIT: STATIC REMNANT, VORTEX, OVERLOAD, BALL LIGHTNING, GALVANIC CORE
-- ----------------------------------------------------------------------------

enfos_storm_static_remnant=class({})
function enfos_storm_static_remnant:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local pos = c:GetAbsOrigin()
    c:EmitSound('Hero_StormSpirit.StaticRemnantPlant')
    ground_effect(c, self, 'modifier_enfos_storm_static_remnant_thinker', { duration = value(self, 'duration') }, pos)
end

modifier_enfos_storm_static_remnant_thinker=class({})
function modifier_enfos_storm_static_remnant_thinker:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local pos = parent:GetAbsOrigin()
    self.pfx = ParticleManager:CreateParticle('particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.pfx, 0, pos)
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(value(self:GetAbility(), 'trigger_radius'), 0, 0))
    self:StartIntervalThink(0.2)
end
function modifier_enfos_storm_static_remnant_thinker:OnDestroy()
    if not IsServer() then return end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
    remove_ground_effect(self)
end
function modifier_enfos_storm_static_remnant_thinker:OnIntervalThink()
    local c = self:GetCaster()
    local a = self:GetAbility()
    local t = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then self:Destroy() return end

    local targets = enemies(c, t:GetAbsOrigin(), value(a, 'trigger_radius'))
    if #targets > 0 then
        t:EmitSound('Hero_StormSpirit.StaticRemnantExplode')
        local base = (a and value(a, 'damage')) or 100
        local dmg = base + (get_int(c) * 1.2)
        for _, u in ipairs(targets) do
            damage(a, u, dmg, DAMAGE_TYPE_MAGICAL)
            effect('particles/units/heroes/hero_stormspirit/stormspirit_static_remnant_glow.vpcf', u)
        end
        self:Destroy()
    end
end

enfos_storm_electric_vortex=class({})
function enfos_storm_electric_vortex:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_StormSpirit.ElectricVortex')
    effect('particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf', t)
    local dur = is_boss(t) and value(self, 'boss_duration') or value(self, 'duration')
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), value(self, 'radius'))) do
        u:AddNewModifier(c, self, 'modifier_enfos_storm_electric_vortex_debuff', { duration = dur })
        effect('particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex_debuff.vpcf', u)
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
    if params.unit == c and params.ability ~= self:GetAbility()
        and not (c.PassivesDisabled and c:PassivesDisabled()) and not (c.IsIllusion and c:IsIllusion()) then
        self.charged = true
        self.chargedAt = (GameRules and GameRules.GetGameTime and GameRules:GetGameTime()) or 0
    end
end
function modifier_enfos_storm_overload_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    if params.attacker == c and self.charged and not (c.PassivesDisabled and c:PassivesDisabled())
        and not (c.IsIllusion and c:IsIllusion()) then
        local t = params.target
        if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
        local now = (GameRules and GameRules.GetGameTime and GameRules:GetGameTime()) or 0
        self.charged = false
        if now - (self.chargedAt or now) > 5 then return end

        c:EmitSound('Hero_StormSpirit.Overload')
        local ability = self:GetAbility()
        local base = value(ability, 'bonus_damage')
        local dmg = base + (get_int(c) * 0.6)

        for _, u in ipairs(enemies(c, t:GetAbsOrigin(), value(ability, 'radius'))) do
            damage(ability, u, dmg, DAMAGE_TYPE_MAGICAL)
            effect('particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf', u)
            u:AddNewModifier(c, ability, 'modifier_enfos_storm_overload_slow', { duration = value(ability, 'slow_duration') })
        end
    end
end

modifier_enfos_storm_overload_slow=class({})
function modifier_enfos_storm_overload_slow:IsDebuff() return true end
function modifier_enfos_storm_overload_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_storm_overload_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

enfos_storm_ball_lightning=class({})
function enfos_storm_ball_lightning:GetCastRange() return value(self, 'max_distance') end
function enfos_storm_ball_lightning:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local target_pos = self:GetCursorPosition()
    local origin = c:GetAbsOrigin()
    local offset = target_pos - origin
    local dist = offset:Length2D()
    local maxDistance = value(self, 'max_distance')
    if dist > maxDistance then
        target_pos = origin + (offset:Normalized() * maxDistance)
        dist = maxDistance
    end
    local manaCost = (dist / 100) * value(self, 'mana_per_100')
    if c.GetMana and c:GetMana() < manaCost then return end
    if c.SpendMana and manaCost > 0 then c:SpendMana(manaCost, self) end
    c:EmitSound('Hero_StormSpirit.BallLightning')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, target_pos)
    ParticleManager:ReleaseParticleIndex(fx)
    FindClearSpaceForUnit(c, target_pos, true)
    local int = get_int(c)
    local dmg = (dist / 100) * (value(self, 'damage_per_100') + (int * 0.1))

    for _, u in ipairs(enemies(c, target_pos, value(self, 'radius'))) do
        local hitDamage = dmg
        if is_boss(u) and u.GetMaxHealth then hitDamage = math.min(hitDamage, u:GetMaxHealth() * value(self, 'boss_damage_cap_pct') / 100) end
        damage(self, u, hitDamage, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_storm_galvanic_core=class({})
function enfos_storm_galvanic_core:GetIntrinsicModifierName() return 'modifier_enfos_storm_galvanic_core_passive' end

modifier_enfos_storm_galvanic_core_passive=class({})
function modifier_enfos_storm_galvanic_core_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end
function modifier_enfos_storm_galvanic_core_passive:GetModifierConstantManaRegen()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'mana_regen')
end
function modifier_enfos_storm_galvanic_core_passive:GetModifierBonusStats_Intellect()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_int')
end

-- ----------------------------------------------------------------------------
-- SHADOW SHAMAN: ETHER SHOCK, HEX, SHACKLES, MASS SERPENT WARD, FOWL PLAY
-- ----------------------------------------------------------------------------

enfos_ss_ether_shock=class({})
function enfos_ss_ether_shock:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_ShadowShaman.EtherShock')
    local base = value(self, 'damage')
    if base <= 0 then base = 250 end
    local int = get_int(c)
    local dmg = base + (int * 1.0)

    local count = 0
    local max_targets = math.max(1, math.floor(value(self, 'targets')))
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), 600)) do
        local hit = is_boss(u) and math.min(dmg, u:GetMaxHealth() * 0.06) or dmg
        damage(self, u, hit, DAMAGE_TYPE_MAGICAL)
        effect('particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf', u)
        count = count + 1
        if count >= max_targets then break end
    end
end

enfos_ss_hex=class({})
function enfos_ss_hex:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_ShadowShaman.Hex.Target')
    effect('particles/units/heroes/hero_shadowshaman/shadowshaman_voodoo.vpcf', t)
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 3.5 end
    if is_boss(t) then dur = dur * 0.35 end
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
function enfos_ss_shackles:GetChannelTime()
    local duration = value(self, 'duration')
    if duration <= 0 then duration = 3.5 end
    local target = self:GetCursorTarget()
    return target and not target:IsNull() and is_boss(target) and duration * 0.35 or duration
end
function enfos_ss_shackles:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_ShadowShaman.Shackles')
    local dur = self:GetChannelTime()
    c:AddNewModifier(c, self, 'modifier_enfos_ss_shackles_channel', { duration = dur, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_ss_shackles_debuff', { duration = dur })
end
function enfos_ss_shackles:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_ss_shackles_channel')
end

modifier_enfos_ss_shackles_channel=class({})
function modifier_enfos_ss_shackles_channel:OnDestroy()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local target=self.target_idx and EntIndexToHScript(self.target_idx)
    if target and not target:IsNull() then target:RemoveModifierByNameAndCaster('modifier_enfos_ss_shackles_debuff',caster) end
    if caster and not caster:IsNull() then caster:StopSound('Hero_ShadowShaman.Shackles') end
end
function modifier_enfos_ss_shackles_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx = kv and kv.target_idx or nil
    self:StartIntervalThink(0.5)
end
function modifier_enfos_ss_shackles_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then
        if a and a.EndChannel then a:EndChannel(true) else self:Destroy() end
        return
    end

    local base = (a and value(a, 'dps')) or 140
    local int = get_int(c)
    local dmg = (base + (int * 0.6)) * 0.5
    damage(a, t, dmg, DAMAGE_TYPE_MAGICAL)
    c:Heal(dmg, a)
    effect('particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf', t)
end

modifier_enfos_ss_shackles_debuff=class({})
function modifier_enfos_ss_shackles_debuff:IsDebuff() return true end
function modifier_enfos_ss_shackles_debuff:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_ss_mass_serpent_ward=class({})
function enfos_ss_mass_serpent_ward:OnSpellStart()
    local c=self:GetCaster()
    local wardDamage = value(self,'ward_damage') + get_int(c) * 0.4
    local ag = require('heroes/aghanim_manager')
    if ag:HasScepter(c) then wardDamage = wardDamage * (1 + ag.SCEPTER_BONUSES.ult_damage_amp_pct / 100) end
    require('heroes/summons'):Units(self,'npc_dota_shadow_shaman_ward_1',self:GetCursorPosition(),value(self,'ward_count'),value(self,'ward_duration'),wardDamage,value(self,'ward_health'))
    c:EmitSound('Hero_ShadowShaman.SerpentWard')
end

enfos_ss_fowl_play=class({})
function enfos_ss_fowl_play:GetIntrinsicModifierName() return 'modifier_enfos_ss_fowl_play_passive' end

modifier_enfos_ss_fowl_play_passive=class({})
function modifier_enfos_ss_fowl_play_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_ss_fowl_play_passive:GetMinHealth()
    local a = self:GetAbility()
    return a and a:IsCooldownReady() and 1 or 0
end
function modifier_enfos_ss_fowl_play_passive:OnTakeDamage(event)
    if not IsServer() or not event or event.unit ~= self:GetParent() or (event.damage or 0) <= 0 then return end
    local c = self:GetParent()
    local a = self:GetAbility()
    if not c or c:IsNull() or not c:IsAlive() or c:GetHealth() > 1 or not a or not a:IsCooldownReady() then return end

    -- Spend the once-per-cooldown save only after MIN_HEALTH actually kept a lethal hit at 1 HP.
    a:StartCooldown(value(a, 'cooldown'))
    c:AddNewModifier(c, a, 'modifier_enfos_ss_fowl_play_buff', { duration = value(a, 'duration') })
end

modifier_enfos_ss_fowl_play_buff=class({})
function modifier_enfos_ss_fowl_play_buff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT } end
function modifier_enfos_ss_fowl_play_buff:GetModifierMoveSpeedBonus_Constant() return value(self:GetAbility(), 'bonus_ms') end

-- ----------------------------------------------------------------------------
-- LION: EARTH SPIKE, HEX, MANA DRAIN, FINGER OF DEATH, DEMON SOUL
-- ----------------------------------------------------------------------------

enfos_lion_earth_spike=class({})
function enfos_lion_earth_spike:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local dir = (self:GetCursorPosition() - c:GetAbsOrigin()):Normalized()
    local distance = value(self, 'distance')
    if distance <= 0 then distance = 450 end
    local radius = value(self, 'radius')
    if radius <= 0 then radius = 500 end
    c:EmitSound('Hero_Lion.Impale')
    local base = value(self, 'damage')
    local int = get_int(c)
    local dmg = base + (int * value(self, 'int_scaling_pct') / 100)
    local stun_duration = value(self, 'stun_duration')
    if stun_duration <= 0 then stun_duration = 1.8 end
    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * distance), radius)) do
        if u and u:IsAlive() then
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        local dur = stun_duration
        if is_boss(u) then dur = dur * 0.35 end
        u:AddNewModifier(c, self, 'modifier_enfos_lion_earth_spike_stun', { duration = dur })
        effect('particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf', u)
        end
    end
end

modifier_enfos_lion_earth_spike_stun=class({})
function modifier_enfos_lion_earth_spike_stun:IsDebuff() return true end
function modifier_enfos_lion_earth_spike_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_lion_hex=class({})
function enfos_lion_hex:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Lion.Voodoo')
    effect('particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf', t)
    local dur = is_boss(t) and value(self, 'boss_duration') or value(self, 'duration')
    if dur <= 0 then dur = is_boss(t) and 0.8 or 3.0 end
    t:AddNewModifier(c, self, 'modifier_enfos_lion_hex_debuff', { duration = dur })
end

modifier_enfos_lion_hex_debuff=class({})
function modifier_enfos_lion_hex_debuff:IsDebuff() return true end
function modifier_enfos_lion_hex_debuff:CheckState()
    return { [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_MUTED] = true }
end
function modifier_enfos_lion_hex_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE } end
function modifier_enfos_lion_hex_debuff:GetModifierMoveSpeedOverride() return value(self:GetAbility(), 'base_move_speed') or 140 end

enfos_lion_mana_drain=class({})
function enfos_lion_mana_drain:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Lion.ManaDrain')
    local duration = value(self, 'channel_duration')
    if duration <= 0 then duration = 4.0 end
    c:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_channel', { duration = duration, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_debuff', { duration = duration })
end
function enfos_lion_mana_drain:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_lion_mana_drain_channel')
end

modifier_enfos_lion_mana_drain_channel=class({})
function modifier_enfos_lion_mana_drain_channel:OnDestroy()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local target=self.target_idx and EntIndexToHScript(self.target_idx)
    if target and not target:IsNull() then target:RemoveModifierByNameAndCaster('modifier_enfos_lion_mana_drain_debuff',caster) end
    if caster and not caster:IsNull() then caster:StopSound('Hero_Lion.ManaDrain') end
end
function modifier_enfos_lion_mana_drain_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx = kv and kv.target_idx or nil
    self:StartIntervalThink(0.5)
end
function modifier_enfos_lion_mana_drain_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not c or c:IsNull() or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then
        if a and a.EndChannel then a:EndChannel(true) else self:Destroy() end
        return
    end

    local base = (a and value(a, 'mana_per_second')) or 120
    local int = get_int(c)
    local tick_dmg = (base + (int * 0.8)) * 0.5

    damage(a, t, tick_dmg, DAMAGE_TYPE_MAGICAL)
    if c.GiveMana then c:GiveMana(tick_dmg) end
    effect('particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf', t)
end

modifier_enfos_lion_mana_drain_debuff=class({})
function modifier_enfos_lion_mana_drain_debuff:IsDebuff() return true end
function modifier_enfos_lion_mana_drain_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_lion_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end

enfos_lion_finger_of_death=class({})
function enfos_lion_finger_of_death:GetIntrinsicModifierName() return 'modifier_enfos_lion_finger_counter' end
function enfos_lion_finger_of_death:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Lion.FingerOfDeath')
    effect('particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 850 end
    local int = get_int(c)
    local mod = c:FindModifierByName('modifier_enfos_lion_finger_counter')
    local stacks = mod and mod:GetStackCount() or 0
    local cappedStacks = math.min(math.max(0, stacks), value(self, 'kill_stack_cap'))
    local total_dmg = base + (int * value(self, 'int_scaling_pct') / 100) + (cappedStacks * value(self, 'kill_stack_damage'))

    local splash_radius = value(self, 'splash_radius')
    if splash_radius <= 0 then splash_radius = 325 end
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), splash_radius)) do
        local hit = total_dmg
        if is_boss(u) then hit = math.min(hit, u:GetMaxHealth() * value(self, 'boss_damage_cap_pct') / 100) end
        damage(self, u, hit, DAMAGE_TYPE_MAGICAL)
        if not u:IsAlive() and mod and mod.SetStackCount then
            mod:SetStackCount(math.min(value(self, 'kill_stack_cap'), mod:GetStackCount() + 1))
        end
    end
end

modifier_enfos_lion_finger_counter=class({})
function modifier_enfos_lion_finger_counter:DeclareFunctions() return { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE } end
function modifier_enfos_lion_finger_counter:GetModifierSpellAmplify_Percentage()
    return math.min(math.max(0, self:GetStackCount() or 0), value(self:GetAbility(), 'kill_stack_cap'))
        * value(self:GetAbility(), 'kill_stack_spell_amp_pct')
end

enfos_lion_demon_soul=class({})
function enfos_lion_demon_soul:GetIntrinsicModifierName() return 'modifier_enfos_lion_demon_soul_passive' end

modifier_enfos_lion_demon_soul_passive=class({})
function modifier_enfos_lion_demon_soul_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_enfos_lion_demon_soul_passive:GetModifierCastRangeBonusStacking()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'cast_range_bonus')
end
function modifier_enfos_lion_demon_soul_passive:GetModifierSpellAmplify_Percentage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'spell_amp')
end


-- =========================================================================
-- BATCH 5 HERO KITS (UNDERLORD, TROLL, CK, MEDUSA, TB, LESHRAC, INVOKER, PUCK, JAKIRO, VS, LICH)
-- =========================================================================

-- -------------------------------------------------------------------------
-- UNDERLORD (TANK)
-- -------------------------------------------------------------------------

enfos_underlord_firestorm=class({})
function enfos_underlord_firestorm:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 425
    local dmg = value(self, 'wave_damage')
    local str = get_str(c)
    local total_dmg = dmg + (str * 0.3)
    local wave_count = math.max(1, math.floor(value(self, 'wave_count')))
    local wave_interval = math.max(0.1, value(self, 'wave_interval'))

    c:EmitSound('Hero_AbyssalUnderlord.Firestorm.Cast')
    local function fire_wave()
        local fx = ParticleManager:CreateParticle('particles/units/heroes/heroes_underlord/abyssal_underlord_firestorm_wave.vpcf', PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(fx, 0, p)
        ParticleManager:ReleaseParticleIndex(fx)

        for _, u in ipairs(enemies(c, p, r)) do
            damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
            local burn_duration = value(self, 'burn_duration')
            if burn_duration <= 0 then burn_duration = 2.0 end
            u:AddNewModifier(c, self, 'modifier_enfos_underlord_firestorm_burn', { duration = burn_duration })
        end
    end

    -- Native Firestorm's first wave is immediate; later waves follow at its
    -- configured interval. Keep each impact and burn owned by the same cast.
    fire_wave()
    if wave_count <= 1 then return end
    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or (c.GetUnitName and c:GetUnitName()) or 'underlord'
    local context_name = 'EnfosUnderlordFirestorm_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    local wave_index = 1
    GameRules:GetGameModeEntity():SetContextThink(context_name, function()
        if not c or (c.IsNull and c:IsNull()) then return nil end
        wave_index = wave_index + 1
        fire_wave()
        if wave_index < wave_count then return wave_interval end
        return nil
    end, wave_interval)
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
    local burn = max_hp * ((ab and value(ab, 'burn_pct') or 2) * 0.005)
    if is_boss(p) and burn > 150 then burn = 150 end
    damage(ab, p, burn, DAMAGE_TYPE_MAGICAL)
end

enfos_underlord_pit_of_malice=class({})
function enfos_underlord_pit_of_malice:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    local r = value(self, 'radius') or 400
    local dur = value(self, 'ensnare_duration') or 2.0
    local dmg = value(self, 'damage')
    local str = get_str(c)
    local total_dmg = dmg + (str * 0.5)

    c:EmitSound('Hero_AbyssalUnderlord.PitOfMalice')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/heroes_underlord/underlord_pitofmalice.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p)
    ParticleManager:SetParticleControl(fx, 1, Vector(r, 1, r))
    ParticleManager:ReleaseParticleIndex(fx)

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
function modifier_enfos_underlord_atrophy_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
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
    local radius = value(self:GetAbility(), 'radius')
    if dead and dead:GetTeamNumber() ~= c:GetTeamNumber() then
        local dist = (dead:GetAbsOrigin() - c:GetAbsOrigin()):Length2D()
        if dist <= radius then
            local gain_key = is_boss(dead) and 'boss_kill_stacks' or 'normal_kill_stacks'
            local gain = value(self:GetAbility(), gain_key)
            self:SetStackCount((self:GetStackCount() or 0) + gain)
        end
    end
end
function modifier_enfos_underlord_atrophy_aura:GetModifierPreAttack_BonusDamage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local a = self:GetAbility()
    local damage_per_stack = value(a, 'bonus_damage_per_stack')
    return value(a, 'bonus_damage') + ((self:GetStackCount() or 0) * damage_per_stack)
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

    c:EmitSound('Hero_AbyssalUnderlord.DarkRift.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient_end.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p)
    ParticleManager:ReleaseParticleIndex(fx)

    for _, u in ipairs(enemies(c, p, r)) do
        local hit = is_boss(u) and math.min(total_dmg, u:GetMaxHealth() * 0.1) or total_dmg
        damage(self, u, hit, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_underlord_abyssal_carapace=class({})
function enfos_underlord_abyssal_carapace:GetIntrinsicModifierName() return 'modifier_enfos_underlord_carapace' end

modifier_enfos_underlord_carapace=class({})
function modifier_enfos_underlord_carapace:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS }
end
function modifier_enfos_underlord_carapace:GetModifierPhysicalArmorBonus()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_armor') or 8
end
function modifier_enfos_underlord_carapace:GetModifierHealthBonus()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_hp') or 500
end

-- -------------------------------------------------------------------------
-- TROLL WARLORD (FIGHTER)
-- -------------------------------------------------------------------------

enfos_troll_berserkers_rage=class({})
function enfos_troll_berserkers_rage:OnToggle()
    if not IsServer() then return end
    local c = self:GetCaster()
    if self:GetToggleState() then
        c:EmitSound('Hero_TrollWarlord.BerserkersRage.Enter')
        c:AddNewModifier(c, self, 'modifier_enfos_troll_berserkers_rage', {})
    else
        c:EmitSound('Hero_TrollWarlord.BerserkersRage.Exit')
        c:RemoveModifierByName('modifier_enfos_troll_berserkers_rage')
    end
end

modifier_enfos_troll_berserkers_rage=class({})
function modifier_enfos_troll_berserkers_rage:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent()
    if p and p.SetAttackCapability then
        p:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    end
end
function modifier_enfos_troll_berserkers_rage:RemoveOnDeath() return false end
function modifier_enfos_troll_berserkers_rage:GetEffectName()
    return 'particles/units/heroes/hero_troll_warlord/troll_warlord_rampage_attack_speed_buff.vpcf'
end
function modifier_enfos_troll_berserkers_rage:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_troll_berserkers_rage:OnDestroy()
    if not IsServer() then return end
    local p = self:GetParent()
    if p and p.SetAttackCapability then
        p:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
    end
end
function modifier_enfos_troll_berserkers_rage:CheckState()
    local state = {}
    if MODIFIER_STATE_ATTACKS_ARE_MELEE ~= nil then
        state[MODIFIER_STATE_ATTACKS_ARE_MELEE] = true
    end
    return state
end
function modifier_enfos_troll_berserkers_rage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end
function modifier_enfos_troll_berserkers_rage:GetModifierAttackRangeBonus()
    return -value(self:GetAbility(), 'attack_range_penalty')
end
function modifier_enfos_troll_berserkers_rage:GetModifierPhysicalArmorBonus()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_armor') or 6
end
function modifier_enfos_troll_berserkers_rage:GetModifierMoveSpeedBonus_Constant()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_ms') or 35
end
function modifier_enfos_troll_berserkers_rage:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    local t = params.target
    if params.attacker == c and t and (not t.IsNull or not t:IsNull()) and t:IsAlive()
        and t:GetTeamNumber() ~= c:GetTeamNumber()
        and RollPercentage(value(self:GetAbility(), 'stun_chance_pct')) then
        local agi = get_agi(c)
        local stun_dur = value(self:GetAbility(), 'stun_duration')
        if is_boss(t) then stun_dur = math.min(stun_dur, value(self:GetAbility(), 'boss_stun_duration')) end
        t:AddNewModifier(c, self:GetAbility(), 'modifier_enfos_troll_berserkers_rage_stun', { duration = stun_dur })
        damage(self:GetAbility(), t, value(self:GetAbility(), 'bonus_damage') + (agi * value(self:GetAbility(), 'agility_factor')), DAMAGE_TYPE_PHYSICAL)
        t:EmitSound('Hero_TrollWarlord.BerserkersRage.Stun')
        effect('particles/generic_gameplay/generic_stunned.vpcf', t)
    end
end

modifier_enfos_troll_berserkers_rage_stun=class({})
function modifier_enfos_troll_berserkers_rage_stun:IsDebuff() return true end
function modifier_enfos_troll_berserkers_rage_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_troll_whirling_axes=class({})
function enfos_troll_whirling_axes:OnSpellStart()
    local c = self:GetCaster()
    local p = c:GetAbsOrigin()
    local r = value(self, 'radius')
    if r <= 0 then r = 550 end
    local dmg = value(self, 'damage')
    if dmg <= 0 then dmg = 180 end
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * value(self, 'agility_factor'))
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 4.0 end

    c:EmitSound('Hero_TrollWarlord.WhirlingAxes.Melee')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_melee.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(fx)

    for _, u in ipairs(enemies(c, p, r)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        local target_duration = is_boss(u) and math.min(dur, value(self, 'boss_duration')) or dur
        u:AddNewModifier(c, self, 'modifier_enfos_troll_whirling_axes_blind', {
            duration = target_duration, blind_pct = value(self, 'blind_pct')
        })
        u:EmitSound('Hero_TrollWarlord.WhirlingAxes.Target')
    end
end

modifier_enfos_troll_whirling_axes_blind=class({})
function modifier_enfos_troll_whirling_axes_blind:IsDebuff() return true end
function modifier_enfos_troll_whirling_axes_blind:OnCreated(params) self.blind_pct = tonumber(params.blind_pct) or value(self:GetAbility(), 'blind_pct') end
function modifier_enfos_troll_whirling_axes_blind:DeclareFunctions() return { MODIFIER_PROPERTY_MISS_PERCENTAGE } end
function modifier_enfos_troll_whirling_axes_blind:GetModifierMiss_Percentage() return self.blind_pct or value(self:GetAbility(), 'blind_pct') end

enfos_troll_fervor=class({})
function enfos_troll_fervor:GetIntrinsicModifierName() return 'modifier_enfos_troll_fervor' end

modifier_enfos_troll_fervor=class({})
function modifier_enfos_troll_fervor:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_troll_fervor:GetEffectName()
    if (self:GetStackCount() or 0) > 0 then return 'particles/units/heroes/hero_troll_warlord/troll_warlord_rampage_attack_speed_buff.vpcf' end
end
function modifier_enfos_troll_fervor:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_troll_fervor:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    local target = params.target
    if params.attacker ~= c or c:PassivesDisabled() or (c.IsIllusion and c:IsIllusion())
        or not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or target:GetTeamNumber() == c:GetTeamNumber() then return end
    local target_id = target.entindex and target:entindex() or target
    if self.target_id ~= target_id then self.target_id = target_id; self:SetStackCount(0) end
    local max_s = value(self:GetAbility(), 'max_stacks')
    local cur = self:GetStackCount() or 0
    if cur < max_s then self:SetStackCount(cur + 1) end
end
function modifier_enfos_troll_fervor:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    local ab = self:GetAbility()
    local per_stack = ab and value(ab, 'attack_speed_per_stack') or 5
    return (self:GetStackCount() or 0) * per_stack
end

enfos_troll_battle_trance=class({})
function enfos_troll_battle_trance:OnSpellStart()
    local c = self:GetCaster()
    local dur = value(self, 'duration') or 6.5
    c:EmitSound('Hero_TrollWarlord.BattleTrance.Cast')
    effect('particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf', c)
    c:AddNewModifier(c, self, 'modifier_enfos_troll_battle_trance', { duration = dur })
end

modifier_enfos_troll_battle_trance=class({})
function modifier_enfos_troll_battle_trance:GetEffectName()
    return 'particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf'
end
function modifier_enfos_troll_battle_trance:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_enfos_troll_battle_trance:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end
function modifier_enfos_troll_battle_trance:GetModifierAttackSpeedBonus_Constant()
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_as') or 200
end
function modifier_enfos_troll_battle_trance:GetModifierMoveSpeedBonus_Percentage()
    return value(self:GetAbility(), 'move_speed_pct')
end
function modifier_enfos_troll_battle_trance:GetMinHealth() return 1 end
function modifier_enfos_troll_battle_trance:OnAttackLanded(params)
    if not IsServer() then return end
    local c = self:GetParent()
    local target = params.target
    if params.attacker == c and target and (not target.IsNull or not target:IsNull()) and target:IsAlive()
        and target:GetTeamNumber() ~= c:GetTeamNumber() and params.damage and params.damage > 0 then
        c:Heal(params.damage * value(self:GetAbility(), 'heal_pct') / 100, self:GetAbility())
    end
end

enfos_troll_rampage=class({})
function enfos_troll_rampage:GetIntrinsicModifierName() return 'modifier_enfos_troll_rampage' end

modifier_enfos_troll_rampage=class({})
function modifier_enfos_troll_rampage:GetEffectName()
    return 'particles/units/heroes/hero_troll_warlord/troll_warlord_rampage_resistance_buff.vpcf'
end
function modifier_enfos_troll_rampage:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_troll_rampage:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING }
end
function modifier_enfos_troll_rampage:GetModifierPreAttack_BonusDamage()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'bonus_damage')
end
function modifier_enfos_troll_rampage:GetModifierStatusResistanceStacking()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'status_resistance')
end

-- -------------------------------------------------------------------------
-- CHAOS KNIGHT (FIGHTER)
-- -------------------------------------------------------------------------

enfos_ck_chaos_bolt=class({})
function enfos_ck_chaos_bolt:GetCastRange() return value(self, 'range') > 0 and value(self, 'range') or 600 end
function enfos_ck_chaos_bolt:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or not t or (t.IsNull and t:IsNull()) or not t:IsAlive()
        or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    if not ProjectileManager or not ProjectileManager.CreateTrackingProjectile then return end
    c:EmitSound('Hero_ChaosKnight.ChaosBolt.Cast')
    ProjectileManager:CreateTrackingProjectile({
        Target = t, Source = c, Ability = self,
        EffectName = 'particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf',
        iMoveSpeed = value(self, 'projectile_speed'), bDodgeable = true,
        bVisibleToEnemies = true, bProvidesVision = false
    })
end

function enfos_ck_chaos_bolt:OnProjectileHit(t, location)
    if not t or (t.IsNull and t:IsNull()) or not t:IsAlive() then return end
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) then return end
    local dmg = value(self, 'damage')
    local total_dmg = dmg + (get_str(c) * value(self, 'strength_factor'))
    local min_s, max_s = value(self, 'stun_min'), value(self, 'stun_max')
    local stun_dur = RandomFloat(min_s, max_s)
    if is_boss(t) then stun_dur = math.min(stun_dur, value(self, 'boss_stun_duration')) end
    effect('particles/units/heroes/hero_chaos_knight/chaos_knight_chaos_bolt.vpcf', t)
    t:EmitSound('Hero_ChaosKnight.ChaosBolt.Impact')
    t:AddNewModifier(c, self, 'modifier_enfos_ck_chaos_bolt_stun', { duration = stun_dur })
    damage(self, t, total_dmg, DAMAGE_TYPE_MAGICAL)
end

modifier_enfos_ck_chaos_bolt_stun=class({})
function modifier_enfos_ck_chaos_bolt_stun:IsDebuff() return true end
function modifier_enfos_ck_chaos_bolt_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end

enfos_ck_reality_rift=class({})
function enfos_ck_reality_rift:GetCastRange() return value(self, 'range') end
function enfos_ck_reality_rift:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or not t or (t.IsNull and t:IsNull()) or not t:IsAlive()
        or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_ChaosKnight.RealityRift')
    t:EmitSound('Hero_ChaosKnight.RealityRift.Target')
    local dur = value(self, 'duration') or 6.0
    if is_boss(t) then dur = math.min(dur, value(self, 'boss_duration')) end
    t:AddNewModifier(c, self, 'modifier_enfos_ck_reality_rift_debuff', { duration = dur })
    local p_mid = (c:GetAbsOrigin() + t:GetAbsOrigin()) * 0.5
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift.vpcf', PATTACH_CUSTOMORIGIN, c)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, t:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 2, p_mid)
    ParticleManager:ReleaseParticleIndex(fx)
    FindClearSpaceForUnit(c, p_mid, true)
    if not is_boss(t) then FindClearSpaceForUnit(t, p_mid, true) end
    c:MoveToTargetToAttack(t)
end

modifier_enfos_ck_reality_rift_debuff=class({})
function modifier_enfos_ck_reality_rift_debuff:IsDebuff() return true end
function modifier_enfos_ck_reality_rift_debuff:GetEffectName() return 'particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift_buff.vpcf' end
function modifier_enfos_ck_reality_rift_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_ck_reality_rift_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_ck_reality_rift_debuff:GetModifierPhysicalArmorBonus()
    local c = self:GetCaster()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
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
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_damage') or 20
end
function modifier_enfos_ck_chaos_strike:GetModifierPreAttack_CriticalStrike()
    if not IsServer() then return end
    local c = self:GetParent()
    self.crit_proc = false
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return end
    local ab = self:GetAbility()
    local chance = ab and value(ab, 'crit_chance') or 33
    if RollPercentage(chance) then
        self.crit_proc = true
        return ab and value(ab, 'crit_mult') or 180
    end
end
function modifier_enfos_ck_chaos_strike:OnTakeDamage(params)
    if not IsServer() then return end
    local didCrit = self.crit_proc
    self.crit_proc = false
    local c, target = self:GetParent(), params.unit
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())
        or params.attacker ~= c or params.inflictor ~= nil
        or params.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK
        or not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or target:GetTeamNumber() == c:GetTeamNumber() or not params.damage or params.damage <= 0 then return end
    if didCrit then
        c:EmitSound('Hero_ChaosKnight.ChaosStrike')
        effect('particles/units/heroes/hero_chaos_knight/chaos_knight_weapon_blur_critical.vpcf', c)
    end
    c:Heal(params.damage * value(self:GetAbility(), 'lifesteal') / 100, self:GetAbility())
    for _, u in ipairs(enemies(c, target:GetAbsOrigin(), value(self:GetAbility(), 'cleave_radius'))) do
        if u ~= target then
            damage(self:GetAbility(), u, params.damage * value(self:GetAbility(), 'cleave_pct') / 100, DAMAGE_TYPE_PHYSICAL)
        end
    end
end

enfos_ck_phantasm=class({})
function enfos_ck_phantasm:OnSpellStart()
    local c = self:GetCaster()
    c:EmitSound('Hero_ChaosKnight.Phantasm')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_chaos_knight/chaos_knight_phantasm.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(fx)
    c:AddNewModifier(c, self, 'modifier_enfos_ck_phantasm_buff', { duration = value(self, 'duration') })
    require('heroes/summons'):Illusions(self, value(self, 'illusion_count'), value(self, 'duration'), value(self, 'illusion_outgoing_pct'))
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
    local c, target = self:GetParent(), params.target
    if params.attacker == c and not (c.PassivesDisabled and c:PassivesDisabled())
        and not (c.IsIllusion and c:IsIllusion()) and target
        and (not target.IsNull or not target:IsNull()) and target:IsAlive()
        and target:GetTeamNumber() ~= c:GetTeamNumber() and params.damage and params.damage > 0 then
        -- Phantasm echo hit
        damage(self:GetAbility(), target, params.damage * value(self:GetAbility(), 'echo_damage_pct') / 100, DAMAGE_TYPE_PHYSICAL)
    end
end

enfos_ck_entropy=class({})
function enfos_ck_entropy:GetIntrinsicModifierName() return 'modifier_enfos_ck_entropy' end

modifier_enfos_ck_entropy=class({})
function modifier_enfos_ck_entropy:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_ck_entropy:GetModifierBonusStats_Strength()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'bonus_strength')
end
function modifier_enfos_ck_entropy:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if c and c.PassivesDisabled and c:PassivesDisabled() then return 0 end
    return value(self:GetAbility(), 'bonus_speed')
end

-- -------------------------------------------------------------------------
-- MEDUSA (CARRY)
-- -------------------------------------------------------------------------

enfos_medusa_split_shot=class({})
function enfos_medusa_split_shot:OnToggle()
    if not IsServer() then return end
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) then return end
    local modifier=c:FindModifierByName('modifier_enfos_medusa_split_shot')
    if modifier and modifier.SetStackCount then modifier:SetStackCount(self:GetToggleState() and 1 or 0) end
end
function enfos_medusa_split_shot:GetIntrinsicModifierName() return 'modifier_enfos_medusa_split_shot' end
function enfos_medusa_split_shot:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
    if not hTarget or (hTarget.IsNull and hTarget:IsNull()) or not hTarget:IsAlive() then return true end
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or hTarget:GetTeamNumber() == c:GetTeamNumber() then return true end
    damage(self, hTarget, tonumber(extraData and extraData.split_shot_damage) or 0, DAMAGE_TYPE_PHYSICAL)
    effect('particles/units/heroes/hero_medusa/medusa_base_attack_impact.vpcf', hTarget)
    return true
end

modifier_enfos_medusa_split_shot=class({})
function modifier_enfos_medusa_split_shot:DeclareFunctions() return { MODIFIER_EVENT_ON_ATTACK_LANDED } end
function modifier_enfos_medusa_split_shot:OnAttackLanded(params)
    if not IsServer() then return end
    local ability=self:GetAbility()
    local c = self:GetParent()
    if not ability or not c or not ability:GetToggleState() or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) or params.attacker ~= c then return end
    local primary = params.target
    if not primary or (primary.IsNull and primary:IsNull()) or not primary:IsAlive()
        or primary:GetTeamNumber() == c:GetTeamNumber() then return end
    local count = math.max(0, math.floor(value(ability, 'arrow_count')))
    local arrow_dmg = (get_atk(c, primary) * value(ability, 'damage_modifier') / 100)
        + (get_agi(c) * value(ability, 'agility_factor'))
    local targets = enemies(c, c:GetAbsOrigin(), value(ability, 'radius'))
    local hits = 0
    for _, u in ipairs(targets) do
        if u ~= primary and hits < count and u:IsAlive() and u:GetTeamNumber() ~= c:GetTeamNumber() then
            if ProjectileManager and ProjectileManager.CreateTrackingProjectile then
                ProjectileManager:CreateTrackingProjectile({
                    Target = u, Source = c, Ability = ability,
                    EffectName = 'particles/units/heroes/hero_medusa/medusa_base_attack.vpcf',
                    iMoveSpeed = value(ability, 'projectile_speed'), bDodgeable = true,
                    bVisibleToEnemies = true, bProvidesVision = false,
                    ExtraData = { split_shot_damage = arrow_dmg }
                })
                hits = hits + 1
            end
        end
    end
end

enfos_medusa_mystic_snake=class({})
function enfos_medusa_mystic_snake:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_Medusa.MysticSnake.Cast')
    self.snake_chains = self.snake_chains or {}
    self.snake_serial = (self.snake_serial or 0) + 1
    local id = self.snake_serial
    self.snake_chains[id] = {
        visited = {}, hit_count = 0, max_jumps = math.max(1, math.floor(value(self, 'jump_count'))),
        damage = value(self, 'base_damage') + get_agi(c) * value(self, 'agility_factor')
    }
    self:_LaunchSnake(t, id)
end

function enfos_medusa_mystic_snake:_LaunchSnake(target, id)
    if not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or not ProjectileManager or not ProjectileManager.CreateTrackingProjectile then
        if self.snake_chains then self.snake_chains[id] = nil end
        return
    end
    ProjectileManager:CreateTrackingProjectile({
        Target = target, Source = self:GetCaster(), Ability = self,
        EffectName = 'particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf',
        iMoveSpeed = value(self, 'projectile_speed') > 0 and value(self, 'projectile_speed') or 900,
        bDodgeable = true, bVisibleToEnemies = true, bProvidesVision = false,
        ExtraData = { snake_cast_id = id }
    })
end

function enfos_medusa_mystic_snake:OnProjectileHit_ExtraData(target, location, extraData)
    local id = tonumber(extraData and extraData.snake_cast_id)
    local chain = id and self.snake_chains and self.snake_chains[id]
    if not chain then return true end
    local c = self:GetCaster()
    if not target or (target.IsNull and target:IsNull()) or not target:IsAlive()
        or not c or target:GetTeamNumber() == c:GetTeamNumber() then
        self.snake_chains[id] = nil
        return true
    end
    local target_id = target.entindex and target:entindex() or target
    if chain.visited[target_id] then
        self.snake_chains[id] = nil
        return true
    end
    chain.visited[target_id] = true
    local hit_damage = chain.damage
    if is_boss(target) and target.GetMaxHealth then
        hit_damage = math.min(hit_damage, target:GetMaxHealth() * value(self, 'boss_damage_cap_pct') / 100)
    end
    damage(self, target, hit_damage, DAMAGE_TYPE_MAGICAL)
    effect('particles/units/heroes/hero_medusa/medusa_mystic_snake_impact.vpcf', target)
    target:EmitSound('Hero_Medusa.MysticSnake.Target')
    if c.GiveMana then c:GiveMana(value(self, 'mana_steal')) end
    chain.hit_count = chain.hit_count + 1
    if chain.hit_count >= chain.max_jumps then self.snake_chains[id] = nil return true end
    chain.damage = chain.damage * value(self, 'damage_per_jump_pct') / 100
    for _, nextTarget in ipairs(enemies(c, target:GetAbsOrigin(), 500)) do
        local next_id = nextTarget.entindex and nextTarget:entindex() or nextTarget
        if nextTarget ~= target and nextTarget:IsAlive() and not chain.visited[next_id] then
            self:_LaunchSnake(nextTarget, id)
            return true
        end
    end
    self.snake_chains[id] = nil
    return true
end

enfos_medusa_mana_shield=class({})
function enfos_medusa_mana_shield:GetIntrinsicModifierName() return 'modifier_enfos_medusa_mana_shield' end

modifier_enfos_medusa_mana_shield=class({})
function modifier_enfos_medusa_mana_shield:DeclareFunctions()
    return { MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT }
end
function modifier_enfos_medusa_mana_shield:GetModifierManaBonus()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_mana') or 250
end
function modifier_enfos_medusa_mana_shield:GetModifierIncomingDamageConstant(params)
    local c, a = self:GetParent(), self:GetAbility()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    local efficiency = value(a, 'damage_per_mana')
    if efficiency <= 0 then return 0 end
    if not IsServer() then return c:GetMana() * efficiency end
    local incoming = math.max(0, params and params.damage or 0)
    local blocked = math.min(incoming * value(a, 'absorption_pct') / 100, c:GetMana() * efficiency)
    if blocked > 0 then c:SpendMana(blocked / efficiency, a) end
    return -blocked
end

enfos_medusa_stone_gaze=class({})
function enfos_medusa_stone_gaze:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Medusa.StoneGaze.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_medusa/medusa_stone_gaze_active.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(fx)
    local r = value(self, 'radius') or 900
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        local petrify_dur = value(self, 'petrify_duration')
        if is_boss(u) then petrify_dur = math.min(petrify_dur, value(self, 'boss_duration')) end
        u:AddNewModifier(c, self, 'modifier_enfos_medusa_petrified', { duration = petrify_dur })
        effect('particles/units/heroes/hero_medusa/medusa_stone_gaze_debuff.vpcf', u)
    end
end

modifier_enfos_medusa_petrified=class({})
function modifier_enfos_medusa_petrified:IsDebuff() return true end
function modifier_enfos_medusa_petrified:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FROZEN] = true }
end
function modifier_enfos_medusa_petrified:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE } end
function modifier_enfos_medusa_petrified:GetModifierIncomingPhysicalDamage_Percentage() return value(self:GetAbility(), 'damage_amp') end

enfos_medusa_gorgon_gaze=class({})
function enfos_medusa_gorgon_gaze:GetIntrinsicModifierName() return 'modifier_enfos_medusa_gorgon_gaze' end

modifier_enfos_medusa_gorgon_gaze=class({})
function modifier_enfos_medusa_gorgon_gaze:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end
function modifier_enfos_medusa_gorgon_gaze:GetModifierPreAttack_BonusDamage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_damage')
end
function modifier_enfos_medusa_gorgon_gaze:GetModifierAttackRangeBonus()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_range')
end

-- -------------------------------------------------------------------------
-- TERRORBLADE (CARRY)
-- -------------------------------------------------------------------------

enfos_tb_reflection=class({})
function enfos_tb_reflection:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    local r = value(self, 'radius')
    local dur = value(self, 'duration')
    c:EmitSound('Hero_Terrorblade.Reflection')
    for _, u in ipairs(enemies(c, p, r)) do
        local unitDuration = dur
        if is_boss(u) then unitDuration = math.min(unitDuration, value(self, 'boss_duration')) end
        u:AddNewModifier(c, self, 'modifier_enfos_tb_reflection', { duration = unitDuration })
        effect('particles/units/heroes/hero_terrorblade/terrorblade_reflection_slow.vpcf', u)
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
    local a = self:GetAbility()
    if not p or (p.IsNull and p:IsNull()) or not p:IsAlive() or not c or (c.IsNull and c:IsNull()) then
        self:Destroy()
        return
    end
    local agi = get_agi(c)
    local tickDamage = value(a, 'damage_per_tick') + (agi * value(a, 'agility_factor'))
    if is_boss(p) and p.GetMaxHealth then
        tickDamage = math.min(tickDamage, p:GetMaxHealth() * value(a, 'boss_tick_cap_pct') / 100)
    end
    damage(a, p, tickDamage, DAMAGE_TYPE_PHYSICAL)
end
function modifier_enfos_tb_reflection:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_tb_reflection:GetModifierMoveSpeedBonus_Percentage()
    local a, p = self:GetAbility(), self:GetParent()
    if is_boss(p) then return -value(a, 'boss_slow_pct') end
    return -value(a, 'slow_pct')
end

enfos_tb_conjure_image=class({})
function enfos_tb_conjure_image:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Terrorblade.ConjureImage')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_terrorblade/terrorblade_mirror_image.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(fx)
    c:AddNewModifier(c, self, 'modifier_enfos_tb_conjure_image_buff', { duration = value(self, 'duration') })
    require('heroes/summons'):Illusions(self, value(self, 'illusion_count'), value(self, 'duration'), value(self, 'illusion_damage'))
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
    local c, t = self:GetParent(), params.target
    if params.attacker == c and not (c.PassivesDisabled and c:PassivesDisabled())
        and not (c.IsIllusion and c:IsIllusion()) and t and (not t.IsNull or not t:IsNull())
        and t:IsAlive() and t:GetTeamNumber() ~= c:GetTeamNumber() and params.damage and params.damage > 0 then
        -- Conjured image echo
        damage(self:GetAbility(), t, params.damage * value(self:GetAbility(), 'echo_damage_pct') / 100, DAMAGE_TYPE_PHYSICAL)
    end
end

enfos_tb_metamorphosis=class({})
function enfos_tb_metamorphosis:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local dur = value(self, 'duration') or 40.0
    c:EmitSound('Hero_Terrorblade.Metamorphosis')
    effect('particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf', c)
    c:AddNewModifier(c, self, 'modifier_enfos_tb_metamorphosis', { duration = dur })
end

modifier_enfos_tb_metamorphosis=class({})
function modifier_enfos_tb_metamorphosis:OnCreated()
    if not IsServer() then return end
    local p = self:GetParent()
    if p and p.SetAttackCapability then
        p:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
        if p.SetRangedProjectileName then
            p:SetRangedProjectileName('particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf')
        end
    end
end
function modifier_enfos_tb_metamorphosis:OnDestroy()
    if not IsServer() then return end
    local p = self:GetParent()
    if p and p.SetAttackCapability then
        p:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    end
end
function modifier_enfos_tb_metamorphosis:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_enfos_tb_metamorphosis:GetModifierAttackRangeBonus() return value(self:GetAbility(), 'bonus_range') end
function modifier_enfos_tb_metamorphosis:GetModifierPreAttack_BonusDamage()
    local ab = self:GetAbility()
    local base = ab and value(ab, 'bonus_damage') or 50
    local c = self:GetParent()
    local agi = get_agi(c)
    return base + (agi * value(ab, 'agility_factor'))
end

enfos_tb_sunder=class({})
function enfos_tb_sunder:GetCastRange() return value(self, 'cast_range') end
function enfos_tb_sunder:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_Terrorblade.Sunder.Cast')
    t:EmitSound('Hero_Terrorblade.Sunder.Target')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf', PATTACH_CUSTOMORIGIN, c)
    ParticleManager:SetParticleControlEnt(fx, 0, c, PATTACH_POINT_FOLLOW, 'attach_hitloc', c:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(fx, 1, t, PATTACH_POINT_FOLLOW, 'attach_hitloc', t:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(fx)

    local total_heal = value(self, 'heal_amount') + (get_agi(c) * value(self, 'agility_factor'))
    c:Heal(total_heal, self)
    local dmg = total_heal
    if is_boss(t) and t.GetMaxHealth then dmg = math.min(dmg, t:GetMaxHealth() * value(self, 'boss_damage_cap_pct') / 100) end
    damage(self, t, dmg, DAMAGE_TYPE_PURE)
end

enfos_tb_demon_zeal=class({})
function enfos_tb_demon_zeal:GetIntrinsicModifierName() return 'modifier_enfos_tb_demon_zeal' end

modifier_enfos_tb_demon_zeal=class({})
function modifier_enfos_tb_demon_zeal:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_enfos_tb_demon_zeal:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_as')
end
function modifier_enfos_tb_demon_zeal:GetModifierMoveSpeedBonus_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_ms')
end

-- -------------------------------------------------------------------------
-- LESHRAC (MAGE)
-- -------------------------------------------------------------------------

enfos_leshrac_split_earth=class({})
function enfos_leshrac_split_earth:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    local r = value(self, 'radius')
    if r <= 0 then r = 250 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.9)
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 1.7 end

    c:EmitSound('Hero_Leshrac.Split_Earth')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p)
    ParticleManager:SetParticleControl(fx, 1, Vector(r, r, r))
    ParticleManager:ReleaseParticleIndex(fx)

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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    c:EmitSound('Hero_Leshrac.Diabolic_Edict')
    c:AddNewModifier(c, self, 'modifier_enfos_leshrac_diabolic_edict', { duration = value(self, 'num_explosions') * 0.25 })
end

modifier_enfos_leshrac_diabolic_edict=class({})
function modifier_enfos_leshrac_diabolic_edict:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.25)
end
function modifier_enfos_leshrac_diabolic_edict:OnIntervalThink()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then self:Destroy(); return end
    local ab = self:GetAbility()
    local r = ab and value(ab, 'radius') or 500
    local targets = enemies(c, c:GetAbsOrigin(), r)
    if #targets > 0 then
        local t = targets[RandomInt(1, #targets)]
        local base_d = ab and value(ab, 'damage_per_explosion') or 25
        local int = get_int(c)
        t:EmitSound('Hero_Leshrac.Diabolic_Edict_explode')
        local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf', PATTACH_ABSORIGIN_FOLLOW, t)
        ParticleManager:ReleaseParticleIndex(fx)
        damage(ab, t, base_d + (int * 0.15), DAMAGE_TYPE_PURE)
    end
end

enfos_leshrac_lightning_storm=class({})
function enfos_leshrac_lightning_storm:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or (t.IsNull and t:IsNull())
        or not t:IsAlive() or t:GetTeamNumber() == c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_Leshrac.Lightning_Storm')
    local jumps = value(self, 'jump_count')
    if jumps <= 0 then jumps = 7 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local current = t
    local hit_count = 0
    local visited = {}

    while current and hit_count < jumps do
        visited[current] = true
        current:EmitSound('Hero_Leshrac.Lightning_Storm')
        local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf', PATTACH_ABSORIGIN_FOLLOW, current)
        ParticleManager:SetParticleControl(fx, 0, current:GetAbsOrigin() + Vector(0, 0, 800))
        ParticleManager:SetParticleControl(fx, 1, current:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(fx)
        local hitDamage = total_dmg
        if is_boss(current) then hitDamage = math.min(hitDamage, current:GetMaxHealth() * 0.03) end
        damage(self, current, hitDamage, DAMAGE_TYPE_MAGICAL)
        current:AddNewModifier(c, self, 'modifier_enfos_leshrac_lightning_slow', { duration = is_boss(current) and 0.25 or 0.5 })
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

modifier_enfos_leshrac_lightning_slow=class({})
function modifier_enfos_leshrac_lightning_slow:IsDebuff() return true end
function modifier_enfos_leshrac_lightning_slow:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_leshrac_lightning_slow:GetModifierMoveSpeedBonus_Percentage()
    local c = self:GetCaster()
    if c and is_boss(self:GetParent()) then return -math.min(20, value(self:GetAbility(), 'slow_pct')) end
    return -value(self:GetAbility(), 'slow_pct')
end

enfos_leshrac_pulse_nova=class({})
function enfos_leshrac_pulse_nova:OnToggle()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    if self:GetToggleState() then
        c:EmitSound('Hero_Leshrac.Pulse_Nova')
        c:AddNewModifier(c, self, 'modifier_enfos_leshrac_pulse_nova', {})
    else
        c:StopSound('Hero_Leshrac.Pulse_Nova')
        c:RemoveModifierByName('modifier_enfos_leshrac_pulse_nova')
    end
end

modifier_enfos_leshrac_pulse_nova=class({})
function modifier_enfos_leshrac_pulse_nova:OnDestroy()
    if not IsServer() then return end
    local c = self:GetParent()
    if c and not (c.IsNull and c:IsNull()) then c:StopSound('Hero_Leshrac.Pulse_Nova') end
end
function modifier_enfos_leshrac_pulse_nova:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_leshrac_pulse_nova:OnIntervalThink()
    local c = self:GetParent()
    local ab = self:GetAbility()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not ab or (ab.IsNull and ab:IsNull()) then self:Destroy(); return end
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
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, Vector(r, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    for _, u in ipairs(enemies(c, c:GetAbsOrigin(), r)) do
        damage(ab, u, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_leshrac_defilement=class({})
function enfos_leshrac_defilement:GetIntrinsicModifierName() return 'modifier_enfos_leshrac_defilement' end

modifier_enfos_leshrac_defilement=class({})
function modifier_enfos_leshrac_defilement:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_enfos_leshrac_defilement:GetModifierBonusStats_Intellect()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_int')
end
function modifier_enfos_leshrac_defilement:OnTakeDamage(e)
    if not IsServer() then return end
    local c=self:GetParent()
    local inflictor = e.inflictor
    local victim = e.unit
    if e.attacker~=c or not inflictor or (inflictor.IsNull and inflictor:IsNull())
        or not victim or (victim.IsNull and victim:IsNull()) or victim:GetTeamNumber()==c:GetTeamNumber()
        or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) or not c:IsAlive() then return end
    if bit.band(e.damage_flags or 0,DOTA_DAMAGE_FLAG_REFLECTION)~=0 then return end
    c:Heal(math.max(0,e.damage or 0)*value(self:GetAbility(),'spell_lifesteal')/100,self:GetAbility())
end

-- -------------------------------------------------------------------------
-- INVOKER (MAGE)
-- -------------------------------------------------------------------------

enfos_invoker_chaos_meteor=class({})
function enfos_invoker_chaos_meteor:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    c:EmitSound('Hero_Invoker.ChaosMeteor.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p + Vector(-200, -200, 1000))
    ParticleManager:SetParticleControl(fx, 1, p)
    ParticleManager:SetParticleControl(fx, 2, Vector(1.5, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    local r = value(self, 'radius')
    if r <= 0 then r = 275 end
    local dmg = value(self, 'impact_damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.2)
    local delay = value(self, 'impact_delay')
    if delay <= 0 then delay = 1.3 end
    local burn_duration = value(self, 'burn_duration')
    if burn_duration <= 0 then burn_duration = 3.0 end
    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or 'invoker'
    local context_name = 'EnfosInvokerMeteor_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    GameRules:GetGameModeEntity():SetContextThink(context_name, function()
        if not c or (c.IsNull and c:IsNull()) then return nil end
        c:EmitSound('Hero_Invoker.ChaosMeteor.Impact')
        for _, u in ipairs(enemies(c, p, r)) do
            local hit_damage = total_dmg
            if is_boss(u) then
                hit_damage = math.min(hit_damage, u:GetMaxHealth() * value(self, 'boss_impact_cap_pct') / 100)
            end
            damage(self, u, hit_damage, DAMAGE_TYPE_MAGICAL)
            u:AddNewModifier(c, self, 'modifier_enfos_invoker_meteor_burn', { duration = burn_duration })
        end
        return nil
    end, delay)
end

modifier_enfos_invoker_meteor_burn=class({})
function modifier_enfos_invoker_meteor_burn:IsDebuff() return true end
function modifier_enfos_invoker_meteor_burn:OnCreated()
    if not IsServer() then return end
    local interval = value(self:GetAbility(), 'burn_tick_interval')
    if interval <= 0 then interval = 0.5 end
    self:StartIntervalThink(interval)
end
function modifier_enfos_invoker_meteor_burn:OnIntervalThink()
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    if not p or (p.IsNull and p:IsNull()) or not p:IsAlive() or not c or (c.IsNull and c:IsNull()) then self:Destroy(); return end
    local dps = ab and value(ab, 'burn_dps') or 65
    local int = get_int(c)
    local interval = ab and value(ab, 'burn_tick_interval') or 0.5
    if interval <= 0 then interval = 0.5 end
    local int_factor = ab and value(ab, 'burn_int_factor') or 0.1
    local tick = (dps * interval) + (int * int_factor)
    if is_boss(p) then
        local cap_pct = ab and value(ab, 'boss_burn_tick_cap_pct') or 1
        tick = math.min(tick, p:GetMaxHealth() * cap_pct / 100)
    end
    damage(ab, p, tick, DAMAGE_TYPE_MAGICAL)
end

enfos_invoker_sun_strike=class({})
function enfos_invoker_sun_strike:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    c:EmitSound('Hero_Invoker.SunStrike.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p)
    ParticleManager:ReleaseParticleIndex(fx)
    local r = value(self, 'radius')
    if r <= 0 then r = 200 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.8)
    local delay = math.max(0, value(self, 'delay'))
    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or (c.GetUnitName and c:GetUnitName()) or 'invoker'
    local context_name = 'EnfosInvokerSunStrike_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    GameRules:GetGameModeEntity():SetContextThink(context_name, function()
        if not c or (c.IsNull and c:IsNull()) then return nil end
        c:EmitSound('Hero_Invoker.SunStrike.Ignite')
        for _, u in ipairs(enemies(c, p, r)) do
            local hitDamage = total_dmg
            if is_boss(u) then hitDamage = math.min(hitDamage, u:GetMaxHealth() * 0.1) end
            damage(self, u, hitDamage, DAMAGE_TYPE_PURE)
        end
        return nil
    end, delay)
end

enfos_invoker_deafening_blast=class({})
function enfos_invoker_deafening_blast:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_Invoker.DeafeningBlast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, dir * 1000)
    ParticleManager:ReleaseParticleIndex(fx)
    local r = value(self, 'radius')
    if r <= 0 then r = 250 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local disarm_dur = value(self, 'disarm_duration')
    if disarm_dur <= 0 then disarm_dur = 3.0 end

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
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    c:EmitSound('Hero_Invoker.EMP.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_invoker/invoker_emp.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p)
    ParticleManager:SetParticleControl(fx, 1, Vector(675, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    local r = value(self, 'radius')
    if r <= 0 then r = 675 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.5)
    local mana_burn = value(self, 'mana_burn')
    local delay = math.max(0, value(self, 'delay'))
    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or (c.GetUnitName and c:GetUnitName()) or 'invoker'
    local context_name = 'EnfosInvokerEMP_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    GameRules:GetGameModeEntity():SetContextThink(context_name, function()
        if not c or (c.IsNull and c:IsNull()) then return nil end
        c:EmitSound('Hero_Invoker.EMP.Discharge')
        local manaReturned = 0
        for _, u in ipairs(enemies(c, p, r)) do
            local hitDamage = total_dmg
            if is_boss(u) then hitDamage = math.min(hitDamage, u:GetMaxHealth() * 0.08) end
            damage(self, u, hitDamage, DAMAGE_TYPE_PURE)
            if u.GetMana and u.SpendMana then
                local burned = math.min(u:GetMana(), mana_burn)
                u:SpendMana(burned, self)
                manaReturned = manaReturned + burned
            end
        end
        if c.GiveMana then c:GiveMana(math.min(manaReturned, mana_burn)) end
        return nil
    end, delay)
end

enfos_invoker_alacrity=class({})
function enfos_invoker_alacrity:GetIntrinsicModifierName() return 'modifier_enfos_invoker_alacrity' end

modifier_enfos_invoker_alacrity=class({})
function modifier_enfos_invoker_alacrity:DeclareFunctions()
    return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end
function modifier_enfos_invoker_alacrity:GetModifierAttackSpeedBonus_Constant()
    local c=self:GetParent(); if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_as')
end
function modifier_enfos_invoker_alacrity:GetModifierPreAttack_BonusDamage()
    local c=self:GetParent(); if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_damage')
end

-- -------------------------------------------------------------------------
-- PUCK (MAGE)
-- -------------------------------------------------------------------------

enfos_puck_illusory_orb=class({})
function enfos_puck_illusory_orb:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local origin = c:GetAbsOrigin()
    local dir = self:GetCursorPosition() - origin
    dir.z = 0
    if dir:Length2D() < 1 then
        dir = c:GetForwardVector()
        dir.z = 0
    end
    dir = dir:Normalized()
    c:EmitSound('Hero_Puck.Illusory_Orb')
    ProjectileManager:CreateLinearProjectile({
        Ability=self, Source=c, vSpawnOrigin=origin, vVelocity=dir * value(self, 'speed'),
        fDistance=1500, fStartRadius=value(self, 'radius'), fEndRadius=value(self, 'radius'),
        iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType=DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_NONE, bDeleteOnHit=false, bProvidesVision=false,
        EffectName='particles/units/heroes/hero_puck/puck_illusory_orb.vpcf'
    })
end
function enfos_puck_illusory_orb:OnProjectileHit_ExtraData(target)
    if not target or (target.IsNull and target:IsNull()) or not target:IsAlive() then return false end
    local c = self:GetCaster()
    local hit = value(self, 'damage') + (get_int(c) * 0.85)
    if is_boss(target) then hit = math.min(hit, target:GetMaxHealth() * 0.04) end
    damage(self, target, hit, DAMAGE_TYPE_MAGICAL)
    return false
end

enfos_puck_waning_rift=class({})
function enfos_puck_waning_rift:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    c:EmitSound('Hero_Puck.Waning_Rift')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_puck/puck_waning_rift.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p)
    ParticleManager:SetParticleControl(fx, 1, Vector(400, 400, 400))
    ParticleManager:ReleaseParticleIndex(fx)
    local r = value(self, 'radius')
    if r <= 0 then r = 400 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.75)
    local sil_dur = value(self, 'silence_duration')
    if sil_dur <= 0 then sil_dur = 2.5 end

    for _, u in ipairs(enemies(c, p, r)) do
        local d = sil_dur
        if is_boss(u) then d = d * 0.4 end
        u:AddNewModifier(c, self, 'modifier_enfos_puck_silence', { duration = d })
        local hit = total_dmg
        if is_boss(u) then hit = math.min(hit, u:GetMaxHealth() * 0.05) end
        damage(self, u, hit, DAMAGE_TYPE_MAGICAL)
    end
end

modifier_enfos_puck_silence=class({})
function modifier_enfos_puck_silence:IsDebuff() return true end
function modifier_enfos_puck_silence:CheckState() return { [MODIFIER_STATE_SILENCED] = true } end

enfos_puck_phase_shift=class({})
function enfos_puck_phase_shift:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 2.25 end
    c:EmitSound('Hero_Puck.Phase_Shift')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_puck/puck_phase_shift.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(fx)
    c:AddNewModifier(c, self, 'modifier_enfos_puck_phase_shift', { duration = dur })
end

modifier_enfos_puck_phase_shift=class({})
function modifier_enfos_puck_phase_shift:CheckState()
    return { [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_OUT_OF_GAME] = true }
end

enfos_puck_dream_coil=class({})
function enfos_puck_dream_coil:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    c:EmitSound('Hero_Puck.Dream_Coil')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_puck/puck_dreamcoil.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, p)
    ParticleManager:ReleaseParticleIndex(fx)
    local r = value(self, 'radius')
    if r <= 0 then r = 375 end
    local dmg = value(self, 'break_damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.5)
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 2.5 end

    for _, u in ipairs(enemies(c, p, r)) do
        local d = stun_dur
        if is_boss(u) then d = d * 0.35 end
        u:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = d })
        local hit = total_dmg
        if is_boss(u) then hit = math.min(hit, u:GetMaxHealth() * 0.08) end
        damage(self, u, hit, DAMAGE_TYPE_MAGICAL)
    end
end

enfos_puck_faerie_magic=class({})
function enfos_puck_faerie_magic:GetIntrinsicModifierName() return 'modifier_enfos_puck_faerie_magic' end

modifier_enfos_puck_faerie_magic=class({})
function modifier_enfos_puck_faerie_magic:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_enfos_puck_faerie_magic:GetModifierMoveSpeedBonus_Constant()
    local c=self:GetParent(); if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_ms')
end
function modifier_enfos_puck_faerie_magic:GetModifierSpellAmplify_Percentage()
    local c=self:GetParent(); if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'spell_amp')
end

-- -------------------------------------------------------------------------
-- JAKIRO (SUPPORT)
-- -------------------------------------------------------------------------

enfos_jakiro_dual_breath=class({})
function enfos_jakiro_dual_breath:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_Jakiro.DualBreath.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, dir * 500)
    ParticleManager:ReleaseParticleIndex(fx)
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 5.0 end

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
function modifier_enfos_jakiro_dual_breath_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierAttackSpeedBonus_Constant() return -40 end

enfos_jakiro_ice_path=class({})
function enfos_jakiro_ice_path:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local origin = c:GetAbsOrigin()
    local p = self:GetCursorPosition()
    local dir = (p - origin):Normalized()
    c:EmitSound('Hero_Jakiro.IcePath.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, origin + (dir * 800))
    ParticleManager:SetParticleControl(fx, 2, Vector(2.0, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.6)
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 2.0 end
    local path_delay = math.max(0, value(self, 'path_delay'))
    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or (c.GetUnitName and c:GetUnitName()) or 'jakiro'
    local context_name = 'EnfosJakiroIcePath_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    GameRules:GetGameModeEntity():SetContextThink(context_name, function()
        if not c or (c.IsNull and c:IsNull()) then return nil end
        for _, u in ipairs(enemies(c, origin + (dir * 600), 700)) do
            local d = stun_dur
            if is_boss(u) then d = d * 0.35 end
            u:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = d })
            damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        end
        return nil
    end, path_delay)
end

enfos_jakiro_liquid_fire=class({})
function enfos_jakiro_liquid_fire:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_liquid_fire_passive' end
function enfos_jakiro_liquid_fire:OnSpellStart()
    local target=self:GetCursorTarget()
    if target and not target:IsNull() and not target:TriggerSpellAbsorb(self) then self:FireAt(target) end
end
function enfos_jakiro_liquid_fire:FireAt(target)
    if not IsServer() or not target or target:IsNull() then return end
    local c=self:GetCaster()
    if target:GetTeamNumber()==c:GetTeamNumber() then return end
    target:EmitSound('Hero_Jakiro.LiquidFire')
    effect('particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf', target)
    for _,u in ipairs(enemies(c,target:GetAbsOrigin(),value(self,'radius'))) do
        damage(self,u,value(self,'bonus_damage')+get_int(c)*0.3,DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c,self,'modifier_enfos_jakiro_liquid_fire_slow',{duration=4})
    end
end

modifier_enfos_jakiro_liquid_fire_slow=class({})
function modifier_enfos_jakiro_liquid_fire_slow:IsDebuff() return true end
function modifier_enfos_jakiro_liquid_fire_slow:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_enfos_jakiro_liquid_fire_slow:GetModifierAttackSpeedBonus_Constant() return -value(self:GetAbility(),'slow_as') end

modifier_enfos_jakiro_liquid_fire_passive=class({})
function modifier_enfos_jakiro_liquid_fire_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_enfos_jakiro_liquid_fire_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c,a=self:GetParent(),self:GetAbility()
    if params.attacker~=c or c:PassivesDisabled() or c:IsIllusion() or not params.target
        or params.target:GetTeamNumber()==c:GetTeamNumber() then return end
    if not a or a:GetLevel()<1 or not a:GetAutoCastState() or not a:IsCooldownReady() then return end
    a:UseResources(false,false,false,true)
    a:FireAt(params.target)
end

enfos_jakiro_macropyre=class({})
function enfos_jakiro_macropyre:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local length = value(self, 'length')
    if length <= 0 then length = 1200 end
    local duration = value(self, 'duration')
    if duration <= 0 then duration = 6 end
    c:EmitSound('Hero_Jakiro.Macropyre.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, c:GetAbsOrigin() + (dir * length))
    ParticleManager:SetParticleControl(fx, 2, Vector(duration, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    ground_effect(c, self, 'modifier_enfos_jakiro_macropyre_zone', {
        duration = duration, dir_x = dir.x, dir_y = dir.y, length = length
    }, c:GetAbsOrigin())
end

modifier_enfos_jakiro_macropyre_zone=class({})
function modifier_enfos_jakiro_macropyre_zone:IsHidden() return true end
function modifier_enfos_jakiro_macropyre_zone:IsPurgable() return false end
function modifier_enfos_jakiro_macropyre_zone:OnCreated(kv)
    if not IsServer() then return end
    self.dir = Vector(tonumber(kv.dir_x) or 1, tonumber(kv.dir_y) or 0, 0):Normalized()
    self.length = tonumber(kv.length) or 1200
    self.boss_damage = {}
    self:StartIntervalThink(0.5)
end
function modifier_enfos_jakiro_macropyre_zone:OnIntervalThink()
    local c, a, parent = self:GetCaster(), self:GetAbility(), self:GetParent()
    if not c or c:IsNull() or not c:IsAlive() or not a or (a.IsNull and a:IsNull()) or not parent or parent:IsNull() then self:Destroy() return end
    local origin = parent:GetAbsOrigin()
    local center = origin + (self.dir * (self.length * 0.5))
    local int = get_int(c)
    local pulse = (value(a, 'damage_per_sec') + (int * 0.7)) * 0.5
    for _, u in ipairs(enemies(c, center, (self.length * 0.5) + 180)) do
        local off = u:GetAbsOrigin() - origin
        local along = off.x * self.dir.x + off.y * self.dir.y
        local side = (off - (self.dir * along)):Length2D()
        if along >= 0 and along <= self.length and side <= 180 then
            local hit = pulse
            if is_boss(u) then
                local id = u:entindex()
                local limit = u:GetMaxHealth() * 0.1
                hit = math.min(hit, math.max(0, limit - (self.boss_damage[id] or 0)))
                self.boss_damage[id] = (self.boss_damage[id] or 0) + hit
            end
            damage(a, u, hit, DAMAGE_TYPE_MAGICAL)
        end
    end
end
function modifier_enfos_jakiro_macropyre_zone:OnDestroy() remove_ground_effect(self) end

enfos_jakiro_double_trouble=class({})
function enfos_jakiro_double_trouble:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_double_trouble' end

modifier_enfos_jakiro_double_trouble=class({})
function modifier_enfos_jakiro_double_trouble:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_jakiro_double_trouble:GetModifierBonusStats_Intellect()
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'bonus_int')
end
function modifier_enfos_jakiro_double_trouble:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'bonus_as')
end

-- -------------------------------------------------------------------------
-- VENGEFUL SPIRIT (SUPPORT)
-- -------------------------------------------------------------------------

enfos_vs_magic_missile=class({})
function enfos_vs_magic_missile:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_VengefulSpirit.MagicMissile')
    local proj = {
        Target = t,
        Source = c,
        Ability = self,
        EffectName = 'particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf',
        iMoveSpeed = 1250,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false
    }
    ProjectileManager:CreateTrackingProjectile(proj)
end
function enfos_vs_magic_missile:OnProjectileHit(target, loc)
    if not target or target:IsNull() or not target:IsAlive() then return true end
    local c = self:GetCaster()
    target:EmitSound('Hero_VengefulSpirit.MagicMissileImpact')
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.9)
    if is_boss(target) then total_dmg = math.min(total_dmg, target:GetMaxHealth() * 0.1) end
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 1.6 end
    if is_boss(target) then stun_dur = stun_dur * 0.4 end
    target:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = stun_dur })
    damage(self, target, total_dmg, DAMAGE_TYPE_MAGICAL)
    return true
end

enfos_vs_wave_of_terror=class({})
function enfos_vs_wave_of_terror:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local origin = c:GetAbsOrigin()
    local dir = p - origin
    dir.z = 0
    if dir:Length2D() < 1 then
        dir = c:GetForwardVector()
        dir.z = 0
    end
    dir = dir:Normalized()
    c:EmitSound('Hero_VengefulSpirit.WaveOfTerror')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, dir * 1400)
    ParticleManager:ReleaseParticleIndex(fx)
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.6)
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 8.0 end

    for _, u in ipairs(enemies(c, origin + (dir * 700), 800)) do
        local offset = u:GetAbsOrigin() - origin
        local along = offset.x * dir.x + offset.y * dir.y
        local side = (offset - (dir * along)):Length2D()
        if along >= 0 and along <= 1400 and side <= 140 then
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_vs_wave_debuff', { duration = dur })
        end
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
function modifier_enfos_vs_vengeance_aura:IsAura()
    local c = self:GetParent()
    return c and not (c.IsNull and c:IsNull()) and not (c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_vs_vengeance_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_vs_vengeance_aura:GetModifierAura() return 'modifier_enfos_vs_vengeance_aura_buff' end

modifier_enfos_vs_vengeance_aura_buff=class({})
function modifier_enfos_vs_vengeance_aura_buff:DeclareFunctions() return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE } end
function modifier_enfos_vs_vengeance_aura_buff:GetModifierBaseDamageOutgoing_Percentage()
    local p = self:GetParent()
    if p and ((p.PassivesDisabled and p:PassivesDisabled()) or (p.IsIllusion and p:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_damage_pct') or 20
end

enfos_vs_nether_swap=class({})
function enfos_vs_nether_swap:GetCastRange() return value(self, 'cast_range') end
function enfos_vs_nether_swap:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:GetTeamNumber() ~= c:GetTeamNumber() and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_VengefulSpirit.NetherSwap')
    t:EmitSound('Hero_VengefulSpirit.NetherSwap')
    local p_target = t:GetAbsOrigin()
    local p_caster = c:GetAbsOrigin()

    local fx1 = ParticleManager:CreateParticle('particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx1, 0, p_caster)
    ParticleManager:SetParticleControl(fx1, 1, p_target)
    ParticleManager:ReleaseParticleIndex(fx1)

    local fx2 = ParticleManager:CreateParticle('particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx2, 0, p_target)
    ParticleManager:SetParticleControl(fx2, 1, p_caster)
    ParticleManager:ReleaseParticleIndex(fx2)

    c:SetAbsOrigin(p_target)
    FindClearSpaceForUnit(c, p_target, true)
    if not is_boss(t) then
        t:SetAbsOrigin(p_caster)
        FindClearSpaceForUnit(t, p_caster, true)
    end
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 1.2)
    if t:GetTeamNumber() ~= c:GetTeamNumber() then
        if is_boss(t) then total_dmg = math.min(total_dmg, t:GetMaxHealth() * 0.1) end
        damage(self, t, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
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
function modifier_enfos_vs_retribution:GetModifierBonusStats_Agility()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_agi')
end
function modifier_enfos_vs_retribution:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_as')
end

-- -------------------------------------------------------------------------
-- LICH (SUPPORT)
-- -------------------------------------------------------------------------

enfos_lich_frost_blast=class({})
function enfos_lich_frost_blast:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Ability.FrostNova')
    t:EmitSound('Ability.FrostNova')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_lich/lich_frost_nova.vpcf', PATTACH_ABSORIGIN_FOLLOW, t)
    ParticleManager:SetParticleControl(fx, 0, t:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(fx)
    local tdmg = value(self, 'target_damage')
    local rdmg = value(self, 'radius_damage')
    local int = get_int(c)
    local primary = tdmg + (int * 0.8)
    if is_boss(t) then primary = math.min(primary, t:GetMaxHealth() * 0.1) end
    damage(self, t, primary, DAMAGE_TYPE_MAGICAL)
    local radius = value(self, 'radius')
    if radius <= 0 then radius = 250 end
    local slow_duration = value(self, 'duration')
    if slow_duration <= 0 then slow_duration = 4 end
    local primary_slow_duration = is_boss(t) and (slow_duration * 0.4) or slow_duration
    t:AddNewModifier(c, self, 'modifier_enfos_lich_frost_blast_slow', { duration = primary_slow_duration })
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), radius)) do
        if u ~= t then
        local splash = rdmg + (int * 0.5)
        if is_boss(u) then splash = math.min(splash, u:GetMaxHealth() * 0.06) end
        damage(self, u, splash, DAMAGE_TYPE_MAGICAL)
        local dur = is_boss(u) and (slow_duration * 0.4) or slow_duration
        u:AddNewModifier(c, self, 'modifier_enfos_lich_frost_blast_slow', { duration = dur })
        end
    end
end

modifier_enfos_lich_frost_blast_slow=class({})
function modifier_enfos_lich_frost_blast_slow:IsDebuff() return true end
function modifier_enfos_lich_frost_blast_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_lich_frost_blast_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_lich_frost_blast_slow:GetModifierAttackSpeedBonus_Constant()
    local slow = value(self:GetAbility(), 'slow_attack')
    return -(slow > 0 and slow or 40)
end

enfos_lich_frost_shield=class({})
function enfos_lich_frost_shield:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget() or c
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 6.0 end
    t:EmitSound('Hero_Lich.IceArmor')
    t:AddNewModifier(c, self, 'modifier_enfos_lich_frost_shield', { duration = dur })
end

modifier_enfos_lich_frost_shield=class({})
function modifier_enfos_lich_frost_shield:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_lich_frost_shield:GetEffectName()
    return 'particles/units/heroes/hero_lich/lich_frost_armor.vpcf'
end
function modifier_enfos_lich_frost_shield:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
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
function enfos_lich_sinister_gaze:GetChannelTime()
    local duration = value(self, 'duration')
    if duration <= 0 then duration = 2.0 end
    local target = self:GetCursorTarget()
    if target and not (target.IsNull and target:IsNull()) and is_boss(target) then
        return duration * 0.35
    end
    return duration
end
function enfos_lich_sinister_gaze:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_Lich.SinisterGaze.Cast')
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 2.0 end
    if is_boss(t) then dur = dur * 0.35 end
    self.gazeTarget = t
    t:AddNewModifier(c, self, 'modifier_enfos_lich_sinister_gaze_debuff', { duration = dur })
end
function enfos_lich_sinister_gaze:OnChannelFinish()
    local c = self:GetCaster()
    local t = self.gazeTarget
    self.gazeTarget = nil
    if t and not t:IsNull() and c and not c:IsNull() then
        t:RemoveModifierByNameAndCaster('modifier_enfos_lich_sinister_gaze_debuff', c)
    end
end

modifier_enfos_lich_sinister_gaze_debuff=class({})
function modifier_enfos_lich_sinister_gaze_debuff:IsDebuff() return true end
function modifier_enfos_lich_sinister_gaze_debuff:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true }
end
function modifier_enfos_lich_sinister_gaze_debuff:GetEffectName()
    return 'particles/units/heroes/hero_lich/lich_gaze.vpcf'
end
function modifier_enfos_lich_sinister_gaze_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_enfos_lich_sinister_gaze_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end
function modifier_enfos_lich_sinister_gaze_debuff:OnIntervalThink()
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    if not c or c:IsNull() or not c:IsAlive() or not p or p:IsNull() or not p:IsAlive() then
        if ab and ab.EndChannel then ab:EndChannel(true) else self:Destroy() end
        return
    end
    local drain = value(ab, 'mana_drain_pct')
    local drained = math.min(p:GetMana(), p:GetMaxMana() * drain * 0.01 * 0.5)
    if drained > 0 then
        if p.ReduceMana then
            p:ReduceMana(drained)
            if c.GiveMana then c:GiveMana(drained) end
        elseif p.SetMana and p.GetMana then
            local actual = math.min(drained, p:GetMana())
            p:SetMana(math.max(0, p:GetMana() - actual))
            if c.GiveMana then c:GiveMana(actual) end
        end
    end
    local dir = (c:GetAbsOrigin() - p:GetAbsOrigin()):Normalized()
    if not is_boss(p) and (p:GetAbsOrigin() - c:GetAbsOrigin()):Length2D() > 100 then
        p:SetAbsOrigin(p:GetAbsOrigin() + (dir * 40))
        FindClearSpaceForUnit(p, p:GetAbsOrigin(), true)
    end
end

enfos_lich_chain_frost=class({})
function enfos_lich_chain_frost:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not t or not t:IsAlive() then return end
    c:EmitSound('Hero_Lich.ChainFrost')
    local jumps = value(self, 'jump_count')
    if jumps <= 0 then jumps = 10 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.0)
    local current = t
    local hit_targets = {}
    local slow_duration = value(self, 'slow_duration')
    if slow_duration <= 0 then slow_duration = 2.5 end

    for i = 1, jumps do
        if not current or (current.IsNull and current:IsNull()) or not current:IsAlive() or hit_targets[current] then break end
        hit_targets[current] = true
        current:EmitSound('Hero_Lich.ChainFrost.Impact')
        local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_lich/lich_chain_frost.vpcf', PATTACH_ABSORIGIN_FOLLOW, current)
        ParticleManager:ReleaseParticleIndex(fx)
        damage(self, current, total_dmg, DAMAGE_TYPE_MAGICAL)
        local duration = is_boss(current) and (slow_duration * 0.35) or slow_duration
        current:AddNewModifier(c, self, 'modifier_enfos_lich_chain_frost_slow', { duration = duration })
        local candidates = enemies(c, current:GetAbsOrigin(), 600)
        local next_target = nil
        for _, u in ipairs(candidates) do
            if u ~= current and not hit_targets[u] and u:IsAlive() then
                next_target = u
                break
            end
        end
        current = next_target
    end
end

modifier_enfos_lich_chain_frost_slow=class({})
function modifier_enfos_lich_chain_frost_slow:IsDebuff() return true end
function modifier_enfos_lich_chain_frost_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_lich_chain_frost_slow:GetModifierMoveSpeedBonus_Percentage()
    local a = self:GetAbility()
    local slow = a and value(a, 'slow_pct') or 50
    if slow <= 0 then slow = 50 end
    return -slow
end
function modifier_enfos_lich_chain_frost_slow:GetModifierAttackSpeedBonus_Constant()
    local a = self:GetAbility()
    local slow = a and value(a, 'slow_attack_pct') or 50
    if slow <= 0 then slow = 50 end
    return -slow
end

enfos_lich_ice_aura=class({})
function enfos_lich_ice_aura:GetIntrinsicModifierName() return 'modifier_enfos_lich_ice_aura' end

modifier_enfos_lich_ice_aura=class({})
function modifier_enfos_lich_ice_aura:IsAura()
    local c = self:GetParent()
    return c and not (c.IsNull and c:IsNull()) and not (c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_lich_ice_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_lich_ice_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_lich_ice_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_lich_ice_aura:GetModifierAura() return 'modifier_enfos_lich_ice_aura_buff' end

modifier_enfos_lich_ice_aura_buff=class({})
function modifier_enfos_lich_ice_aura_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end
function modifier_enfos_lich_ice_aura_buff:GetModifierPhysicalArmorBonus()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_armor') or 8
end
function modifier_enfos_lich_ice_aura_buff:GetModifierConstantManaRegen()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'mana_regen') or 4
end

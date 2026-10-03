-- Vengeful Spirit W: traveling engine projectile with per-cast numeric snapshots.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_agi, damage = Helpers.value, Helpers.get_agi, Helpers.damage
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_vs_wave_debuff', 'abilities/heroes/vengefulspirit/w', LUA_MODIFIER_MOTION_NONE)
local function valid(entity) return entity and not (entity.IsNull and entity:IsNull()) end

enfos_vs_wave_of_terror=class({})
function enfos_vs_wave_of_terror:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c = self:GetCaster()
    if not valid(c) or not c:IsAlive() then return end
    local origin = c:GetAbsOrigin()
    local dir = self:GetCursorPosition() - origin
    dir.z = 0
    if dir:Length2D() < 1 then
        dir = c:GetForwardVector()
        dir.z = 0
    end
    if dir:Length2D() < 1 then return end
    dir = dir:Normalized()
    local distance, speed, width = value(self, 'wave_distance'), value(self, 'wave_speed'), value(self, 'wave_width')
    if distance <= 0 then distance = 1400 end
    if speed <= 0 then speed = 2000 end
    if width <= 0 then width = 325 end
    local duration = value(self, 'duration')
    if duration <= 0 then duration = 8 end
    local vision_radius, vision_duration = value(self, 'vision_aoe'), value(self, 'vision_duration')
    local data = { damage = value(self, 'damage') + get_agi(c) * 0.6,
        duration = duration, armor_reduction = value(self, 'armor_reduction'),
        attack_reduction = value(self, 'attack_reduction'),
        vision_radius = vision_radius, vision_duration = vision_duration, vision_team = c:GetTeamNumber() }
    c:EmitSound('Hero_VengefulSpirit.WaveOfTerror')
    local handle = ProjectileManager:CreateLinearProjectile({
        Ability = self, Source = c,
        EffectName = 'particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf',
        vSpawnOrigin = origin, vVelocity = dir * speed,
        fDistance = distance, fStartRadius = width, fEndRadius = width,
        bHasFrontalCone = false, bReplaceExisting = false, bDeleteOnHit = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE, bProvidesVision = vision_radius > 0,
        iVisionRadius = vision_radius, iVisionTeamNumber = data.vision_team,
        ExtraData = data,
    })
    HeroTrace:Log('VENGEFUL_SPIRIT','W','projectile_created handle=%s rank=%s origin=%s speed=%s distance=%s collision_radius=%s requested_damage=%s',
        tostring(handle),tostring(self.GetLevel and self:GetLevel() or 0),tostring(origin),tostring(speed),tostring(distance),tostring(width),tostring(data.damage))
end
function enfos_vs_wave_of_terror:OnProjectileThink_ExtraData(location, data)
    if not IsServer() or not valid(self) or not location or not data then return end
    local radius, duration, team = tonumber(data.vision_radius), tonumber(data.vision_duration), tonumber(data.vision_team)
    if not radius or radius <= 0 or not duration or duration <= 0 or not team then return end
    -- Local, temporary engine viewers; no scan, unit, retained cast table or timer.
    AddFOWViewer(team, location, radius, duration, false)
end
function enfos_vs_wave_of_terror:OnProjectileHit_ExtraData(target, location, data)
    if not IsServer() or not valid(self) then return true end
    if not target then
        self:OnProjectileThink_ExtraData(location, data)
        HeroTrace:Log('VENGEFUL_SPIRIT','W','projectile_finished position=%s cleanup=engine_projectile',tostring(location))
        return true
    end
    local c = self:GetCaster()
    if not valid(c) then return true end
    if not valid(target) or not target:IsAlive() or target:GetTeamNumber()==c:GetTeamNumber() then return false end
    if not data or not tonumber(data.damage) or not tonumber(data.duration) or not tonumber(data.armor_reduction) then return true end
    local dealt = damage(self, target, tonumber(data.damage), DAMAGE_TYPE_MAGICAL)
    if valid(c) and valid(self) and valid(target) and target:IsAlive() and target:GetTeamNumber()~=c:GetTeamNumber() then
        target:AddNewModifier(c, self, 'modifier_enfos_vs_wave_debuff', {
            duration = tonumber(data.duration), armor_reduction = tonumber(data.armor_reduction),
            attack_reduction = tonumber(data.attack_reduction) or 0 })
    end
    HeroTrace:Log('VENGEFUL_SPIRIT','W','impact target=%s requested_damage=%s actual_damage=%s armor_reduction=%s duration_requested=%s',
        HeroTrace:Name(target),tostring(data.damage),tostring(dealt),tostring(data.armor_reduction),tostring(data.duration))
    return false
end

modifier_enfos_vs_wave_debuff=class({})
function modifier_enfos_vs_wave_debuff:IsDebuff() return true end
function modifier_enfos_vs_wave_debuff:IsPurgable() return true end
function modifier_enfos_vs_wave_debuff:GetTexture() return 'vengefulspirit_wave_of_terror' end
function modifier_enfos_vs_wave_debuff:GetEffectName()
    return 'particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf'
end
function modifier_enfos_vs_wave_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_vs_wave_debuff:OnCreated(params)
    if not IsServer() then return end
    local armor = tonumber(params and params.armor_reduction) or value(self:GetAbility(), 'armor_reduction')
    self.attack_reduction = math.min(100, math.max(0, tonumber(params and params.attack_reduction) or value(self:GetAbility(), 'attack_reduction')))
    self:SetStackCount(math.max(0, math.floor(armor)))
    self:SetHasCustomTransmitterData(true)
    HeroTrace:Log('VENGEFUL_SPIRIT','W','modifier_applied target=%s armor_reduction=%s attack_reduction=%s',HeroTrace:Name(self:GetParent()),tostring(self:GetStackCount()),tostring(self.attack_reduction))
end
function modifier_enfos_vs_wave_debuff:OnRefresh(params)
    if not IsServer() then return end
    local armor = tonumber(params and params.armor_reduction) or value(self:GetAbility(), 'armor_reduction')
    self.attack_reduction = math.min(100, math.max(0, tonumber(params and params.attack_reduction) or value(self:GetAbility(), 'attack_reduction')))
    self:SetStackCount(math.max(0, math.floor(armor)))
    self:SendBuffRefreshToClients()
    HeroTrace:Log('VENGEFUL_SPIRIT','W','modifier_refreshed target=%s armor_reduction=%s attack_reduction=%s',HeroTrace:Name(self:GetParent()),tostring(self:GetStackCount()),tostring(self.attack_reduction))
end
function modifier_enfos_vs_wave_debuff:AddCustomTransmitterData()
    return { attack_reduction = self.attack_reduction or 0 }
end
function modifier_enfos_vs_wave_debuff:HandleCustomTransmitterData(data)
    self.attack_reduction = tonumber(data and data.attack_reduction) or 0
end
function modifier_enfos_vs_wave_debuff:OnDestroy()
    HeroTrace:Log('VENGEFUL_SPIRIT','W','modifier_removed target=%s',HeroTrace:Name(self:GetParent()))
end
function modifier_enfos_vs_wave_debuff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE }
end
function modifier_enfos_vs_wave_debuff:GetModifierDamageOutgoing_Percentage()
    return -(self.attack_reduction or 0)
end
function modifier_enfos_vs_wave_debuff:GetModifierPhysicalArmorBonus()
    return -self:GetStackCount()
end

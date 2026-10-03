-- Native-style Ice Spire controller. Acquisition/extra-slot exposure is separate.
local Helpers = require('abilities/shared/pve_helpers')
local HeroTrace = require('lib/hero_trace')
local Upgrades = require('abilities/heroes/lich/upgrades')
local Spire = { unitName='enfos_lich_ice_spire_unit' }
local function valid(entity) return entity and not entity:IsNull() end
local function live(entity) return valid(entity) and entity:IsAlive() end

function Spire.IsOwned(caster, unit)
    -- GetOwnerEntity is server-only in the current VScript API.
    return IsServer() and valid(caster) and live(unit) and unit.GetUnitName and unit:GetUnitName()==Spire.unitName
        and unit:GetTeamNumber()==caster:GetTeamNumber()
        and unit:GetOwnerEntity()==caster
end
function Spire.IsEnabled(caster, unit)
    return Spire.IsOwned(caster, unit) and Upgrades.HasShard(caster)
end
function Spire.TargetFilter(caster, unit, team)
    if not valid(caster) or not valid(unit) then return UF_FAIL_OTHER end
    if not unit:IsAlive() then return UF_FAIL_DEAD end
    if unit.GetUnitName and unit:GetUnitName()==Spire.unitName then
        -- Client can predict candidate selection; only the server checks owner.
        if unit:GetTeamNumber()==caster:GetTeamNumber() and (not IsServer() or Spire.IsEnabled(caster, unit)) then
            return UF_SUCCESS
        end
        return UF_FAIL_OTHER
    end
    return UnitFilter(unit, team, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, caster:GetTeamNumber())
end
function Spire.Get(caster)
    local unit = valid(caster) and caster.enfosLichSpire
    return Spire.IsOwned(caster, unit) and unit or nil
end
function Spire.Controller(caster, unit)
    if not Spire.IsOwned(caster, unit) then return nil end
    local controller = unit:FindModifierByName('modifier_enfos_lich_ice_spire')
    return valid(controller) and not controller.terminated and controller or nil
end
function Spire.Retire(caster, reason)
    local unit = Spire.Get(caster)
    if not unit then return end
    local controller = Spire.Controller(caster, unit)
    if controller then controller:Terminate(reason or 'retired', false)
    else
        caster.enfosLichSpire=nil
        unit:ForceKill(false)
    end
end
function Spire.HeroHit(caster, unit)
    if not Spire.IsEnabled(caster, unit) then return false end
    local controller = Spire.Controller(caster, unit)
    if controller then return controller:SpendHits(controller.heroCost, 'chain_frost') end
    return false
end
function Spire.Repair(caster, unit)
    if not Spire.IsEnabled(caster, unit) then return 0 end
    local controller = Spire.Controller(caster, unit)
    if controller then return controller:RepairHeroHit() end
    return 0
end

LinkLuaModifier('modifier_enfos_lich_ice_spire', 'abilities/heroes/lich/spire', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_lich_ice_spire_slow', 'abilities/heroes/lich/spire', LUA_MODIFIER_MOTION_NONE)

enfos_lich_ice_spire=class({})
function enfos_lich_ice_spire:GetBehavior()
    local base = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
        + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
    if self:GetLevel()<1 then base=base+DOTA_ABILITY_BEHAVIOR_HIDDEN end
    return Upgrades.CastBehavior(self, base)
end
function enfos_lich_ice_spire:Precache(context)
    PrecacheUnitByNameSync(Spire.unitName, context, nil)
    PrecacheResource('model', 'models/heroes/lich/ice_spire.vmdl', context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_lich.vsndevts', context)
    -- Q's death Nova is possible even if Q has not been manually cast this match.
    PrecacheResource('particle', 'particles/units/heroes/hero_lich/lich_frost_nova.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_lich/lich_ice_spire_outer_ring.vpcf', context)
end
function enfos_lich_ice_spire:GetAOERadius() return Helpers.value(self, 'aura_radius') end
function enfos_lich_ice_spire:OnSpellStart()
    if not IsServer() or self:IsNull() then return end
    local caster = self:GetCaster()
    if not live(caster) or self:GetLevel()<1 or not Upgrades.HasShard(caster) then return end
    local duration = Helpers.value(self, 'duration')
    if duration<=0 then
        HeroTrace:Log('LICH','D','spire_spawn_failed reason=invalid_lifetime')
        return
    end
    local origin = self:GetCursorPosition()
    -- Synchronous access is required to install hit-count protection immediately;
    -- this is one unit per cast, not mass spawning or a global scan.
    local unit = CreateUnitByName(Spire.unitName, origin, true, caster, caster, caster:GetTeamNumber())
    if not live(unit) then
        HeroTrace:Log('LICH','D','spire_spawn_failed position=%s',tostring(origin))
        return
    end
    if not live(caster) or self:IsNull() then unit:ForceKill(false); return end
    local controller = unit:AddNewModifier(caster, self, 'modifier_enfos_lich_ice_spire',
        {duration=duration})
    if not valid(controller) or controller.terminated or not live(unit)
        or not live(caster) or self:IsNull() then
        if valid(controller) then controller:Terminate('invalid_after_creation', false) end
        if live(unit) then unit:ForceKill(false) end
        HeroTrace:Log('LICH','D','spire_spawn_failed reason=controller_unavailable')
        return
    end
    -- A failed replacement leaves the prior valid Spire intact.
    Spire.Retire(caster, 'recast')
    caster.enfosLichSpire=unit
    EmitSoundOnLocationWithCaster(unit:GetAbsOrigin(), 'Ability.FrostNova', caster)
    HeroTrace:Log('LICH','D','spire_spawn unit=%s position=%s lifetime=%s hero_hits=%s creep_hits=%s',
        HeroTrace:Name(unit),tostring(unit:GetAbsOrigin()),tostring(Helpers.value(self,'duration')),
        tostring(Helpers.value(self,'max_hero_attacks')),tostring(Helpers.value(self,'max_creep_attacks')))
end

modifier_enfos_lich_ice_spire=class({})
function modifier_enfos_lich_ice_spire:IsHidden() return false end
function modifier_enfos_lich_ice_spire:IsPurgable() return false end
function modifier_enfos_lich_ice_spire:GetTexture() return 'lich_ice_spire' end
function modifier_enfos_lich_ice_spire:OnCreated()
    if not IsServer() then return end
    local ability, parent, caster = self:GetAbility(), self:GetParent(), self:GetCaster()
    local heroHits, creepHits = Helpers.value(ability,'max_hero_attacks'), Helpers.value(ability,'max_creep_attacks')
    if not valid(ability) or not Spire.IsOwned(caster, parent) or heroHits<=0 or creepHits<=0 then
        self:Terminate('invalid_creation', false); return
    end
    self.maxHits=creepHits;self.heroCost=creepHits/heroHits;self.remaining=creepHits
    -- Health communicates attack-count durability, independent of attack damage.
    parent:SetBaseMaxHealth(creepHits);parent:SetMaxHealth(creepHits);parent:SetHealth(creepHits)
    -- Decoded native child: RingWave uses CP5.y as radius and CP0 as centre.
    -- The immobile ward's modifier owns the continuous emitter and its teardown.
    local radius=Helpers.value(ability,'aura_radius')
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lich/lich_ice_spire_outer_ring.vpcf', PATTACH_WORLDORIGIN, parent)
    ParticleManager:SetParticleControl(fx, 0, parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 5, Vector(0, radius, 0))
    self:AddParticle(fx, false, false, -1, false, false)
    HeroTrace:Log('LICH','D','spire_ring_created particle=%s radius=%s particle_owner=modifier',tostring(fx),tostring(radius))
    self:StartIntervalThink(0.5)
end
function modifier_enfos_lich_ice_spire:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_DEATH}
end
function modifier_enfos_lich_ice_spire:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_enfos_lich_ice_spire:GetAbsoluteNoDamageMagical() return 1 end
function modifier_enfos_lich_ice_spire:GetAbsoluteNoDamagePure() return 1 end
function modifier_enfos_lich_ice_spire:OnAttackLanded(event)
    if not IsServer() or self.terminated or event.target~=self:GetParent() then return end
    local attacker, parent = event.attacker, self:GetParent()
    if not live(attacker) or not live(parent) or attacker:GetTeamNumber()==parent:GetTeamNumber() then return end
    self:SpendHits(attacker:IsHero() and self.heroCost or 1, 'attack')
end
function modifier_enfos_lich_ice_spire:SpendHits(amount, reason)
    if not IsServer() or self.terminated or not self.remaining or not live(self:GetParent()) then return false end
    self.remaining=math.max(0,self.remaining-amount)
    HeroTrace:Log('LICH','D','spire_hit reason=%s spent=%s remaining=%s',reason,tostring(amount),tostring(self.remaining))
    if self.remaining<=0 then self:Terminate('hits_exhausted', true)
    else self:GetParent():SetHealth(self.remaining) end
    return true
end
function modifier_enfos_lich_ice_spire:RepairHeroHit()
    if not IsServer() or self.terminated or not self.remaining or not live(self:GetParent()) then return 0 end
    local before=self.remaining
    self.remaining=math.min(self.maxHits,self.remaining+self.heroCost)
    self:GetParent():SetHealth(self.remaining)
    HeroTrace:Log('LICH','W','spire_repair restored=%s remaining=%s',tostring(self.remaining-before),tostring(self.remaining))
    return self.remaining-before
end
function modifier_enfos_lich_ice_spire:OnIntervalThink()
    if not IsServer() or self.terminated then return end
    if not valid(self:GetAbility()) or not Spire.IsEnabled(self:GetCaster(), self:GetParent()) then
        self:Terminate('source_or_ownership_lost', false)
    end
end
function modifier_enfos_lich_ice_spire:OnDeath(event)
    if IsServer() and event.unit==self:GetParent() then self:Terminate('death', true) end
end
function modifier_enfos_lich_ice_spire:OnDestroy()
    if IsServer() then self:Terminate('expiry_or_removal', true) end
end
function modifier_enfos_lich_ice_spire:Terminate(reason, blast)
    if not IsServer() or self.terminated then return end
    self.terminated=true -- Ownership detached before any reentrant kill/Nova callback.
    local parent, caster = self:GetParent(), self:GetCaster()
    local origin = valid(parent) and parent:GetAbsOrigin()
    if valid(caster) and caster.enfosLichSpire==parent then caster.enfosLichSpire=nil end
    local ability = self:GetAbility()
    -- Removed source/owner and deliberate retirement cannot grant a free Nova.
    if blast and origin and valid(caster) and valid(ability) and Upgrades.HasShard(caster)
        and valid(parent) and parent:GetOwnerEntity()==caster
        and parent:GetTeamNumber()==caster:GetTeamNumber() then
        EmitSoundOnLocationWithCaster(origin, 'Hero_Lich.IceSpire.Destroy', caster)
        local q = caster:FindAbilityByName('enfos_lich_frost_blast')
        if valid(q) and q:GetLevel()>0 then q:BlastAtPoint(origin) end
    end
    if live(parent) then parent:ForceKill(false) end
    HeroTrace:Log('LICH','D','spire_removed reason=%s nova_requested=%s cleanup=unit_and_modifier particle_cleanup=modifier_engine',reason,tostring(blast))
end
function modifier_enfos_lich_ice_spire:IsAura()
    return IsServer() and not self.terminated and valid(self:GetAbility()) and Spire.IsEnabled(self:GetCaster(), self:GetParent())
end
function modifier_enfos_lich_ice_spire:GetModifierAura() return 'modifier_enfos_lich_ice_spire_slow' end
function modifier_enfos_lich_ice_spire:GetAuraRadius() return Helpers.value(self:GetAbility(),'aura_radius') end
function modifier_enfos_lich_ice_spire:GetAuraDuration() return Helpers.value(self:GetAbility(),'slow_duration') end
function modifier_enfos_lich_ice_spire:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_enfos_lich_ice_spire:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_lich_ice_spire:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end

modifier_enfos_lich_ice_spire_slow=class({})
function modifier_enfos_lich_ice_spire_slow:IsDebuff() return true end
function modifier_enfos_lich_ice_spire_slow:IsPurgable() return false end
function modifier_enfos_lich_ice_spire_slow:GetTexture() return 'lich_ice_spire' end
function modifier_enfos_lich_ice_spire_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_enfos_lich_ice_spire_slow:GetModifierMoveSpeedBonus_Percentage()
    return Helpers.value(self:GetAbility(),'bonus_movespeed')
end
return Spire

local Helpers=require('abilities/shared/pve_helpers')
local Trace=require('lib/hero_trace')
local function live(entity) return entity and (not entity.IsNull or not entity:IsNull()) end
local function source(c,a)
    return live(c) and c:IsAlive() and live(a) and a:GetLevel()>0
end
enfos_slark_fish_bait=class({})
function enfos_slark_fish_bait:GetIntrinsicModifierName() return 'modifier_enfos_slark_fish_bait_passive' end

modifier_enfos_slark_fish_bait_passive=class({})
local D=modifier_enfos_slark_fish_bait_passive
function D:IsHidden() return true end
function D:IsPurgable() return false end
function D:RemoveOnDeath() return false end
function D:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function D:OnAttackLanded(params)
    if not IsServer() or not params then return end
    local c,a=self:GetParent(),self:GetAbility()
    if not source(c,a) or params.attacker~=c or c:IsIllusion() or c:PassivesDisabled() then return end
    local t=params.target
    if not live(t) or t:GetTeamNumber()==c:GetTeamNumber()
        or not ((t.IsHero and t:IsHero()) or (t.IsCreep and t:IsCreep()) or (t.IsCreature and t:IsCreature())) then return end
    local chance=a:GetSpecialValueFor('proc_chance')
    if chance<=0 or not RollPercentage(math.min(100,chance)) then return end
    local center=t:GetAbsOrigin()
    local duration,cap=a:GetSpecialValueFor('debuff_duration'),a:GetSpecialValueFor('max_armor_stacks')
    local radius=a:GetSpecialValueFor('cleave_radius')
    local hit=tonumber(params.damage) or 0
    if hit~=hit or hit==math.huge or hit<0 then hit=0 end
    local cleave=hit*a:GetSpecialValueFor('cleave_pct')/100
    if not source(c,a) or not live(t) then return end
    if t:IsAlive() and duration>0 and cap>0 then
        local debuff=t:FindModifierByNameAndCaster('modifier_enfos_slark_fish_bait_debuff',c)
        if not live(debuff) then
            debuff=t:AddNewModifier(c,a,'modifier_enfos_slark_fish_bait_debuff',{duration=duration})
        end
        if not source(c,a) or not live(t) then return end
        if live(debuff) then
            debuff:SetStackCount(math.min(cap,debuff:GetStackCount()+1))
            if not source(c,a) or not live(debuff) then return end
            debuff:SetDuration(duration,true)
        end
    end
    if not source(c,a) or not live(t) then return end
    Helpers.effect('particles/units/heroes/hero_slark/slark_shard_fish_bait_impact_splash.vpcf',t)
    local targets=0
    if cleave>0 and radius>0 then
        for _,u in ipairs(Helpers.enemies(c,center,radius,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)) do
            if not source(c,a) then break end
            if u~=t and live(u) and u:IsAlive() and u:GetTeamNumber()~=c:GetTeamNumber() then
                Helpers.damage(a,u,cleave,DAMAGE_TYPE_PHYSICAL)
                targets=targets+1
            end
        end
    end
    Trace:Log('SLARK','D','fish_bait_proc cleave=%s targets=%s',tostring(cleave),tostring(targets))
end

modifier_enfos_slark_fish_bait_debuff=class({})
local B=modifier_enfos_slark_fish_bait_debuff
function B:IsDebuff() return true end
function B:IsPurgable() return true end
function B:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function B:GetTexture() return 'slark_fish_bait' end
function B:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function B:GetModifierPhysicalArmorBonus()
    local a=self:GetAbility()
    if not live(a) or a:GetLevel()<1 then return 0 end
    return -a:GetSpecialValueFor('armor_reduction')*math.min(a:GetSpecialValueFor('max_armor_stacks'),math.max(0,self:GetStackCount()))
end

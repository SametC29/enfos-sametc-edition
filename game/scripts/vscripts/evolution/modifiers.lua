-- One persistent modifier per server-selected choice; no direct base-stat mutation.
local choices=require("evolution/choices")
local function valid(u) return u and not u:IsNull() end
local function hostile(parent,u) return valid(u) and u:GetTeamNumber()~=parent:GetTeamNumber() end
local function wave(u) return valid(u) and u.defendingTeam~=nil and not u.enfosNoReward end
local function elite(u) return wave(u) and (u.isBoss or u:GetUnitName():find("enfos_elite_",1,true)) end
local function make(choice)
    local m=class({})
    function m:IsHidden() return false end
    function m:IsPurgable() return false end
    function m:RemoveOnDeath() return false end
    function m:GetTexture() return choice.icon end
    function m:DeclareFunctions()
        return {MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_MANA_BONUS,
          MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
          MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
          MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
          MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
          MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
          MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
          MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
          MODIFIER_EVENT_ON_TAKEDAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED,
          MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,MODIFIER_EVENT_ON_DEATH}
    end
    function m:GetModifierHealthBonus() return choice.bonus_hp or 0 end
    function m:GetModifierManaBonus() return choice.bonus_mana or 0 end
    function m:GetModifierPhysicalArmorBonus() return choice.bonus_armor or 0 end
    function m:GetModifierConstantHealthRegen() return choice.bonus_hp_regen or 0 end
    function m:GetModifierConstantManaRegen() return choice.bonus_mana_regen or 0 end
    function m:GetModifierAttackSpeedBonus_Constant() return choice.bonus_as or 0 end
    function m:GetModifierMoveSpeedBonus_Constant() return choice.bonus_ms or 0 end
    function m:GetModifierStatusResistanceStacking() return choice.status_res or 0 end
    function m:GetModifierBonusStats_Strength() return choice.all_stats or 0 end
    function m:GetModifierBonusStats_Agility() return choice.all_stats or 0 end
    function m:GetModifierBonusStats_Intellect() return choice.all_stats or 0 end
    function m:GetModifierIncomingDamage_Percentage() return -(choice.damage_reduction or 0) end
    function m:GetModifierTotalDamageOutgoing_Percentage(e)
        if choice.boss_damage_pct and elite(e and e.target) then return choice.boss_damage_pct end
        return 0
    end
    function m:GetModifierSpellAmplify_Percentage(e)
        local a=e and e.inflictor
        if choice.bonus_damage_pct and a and (a:GetAOERadius()>0 or a:GetSpecialValueFor("radius")>0) then return choice.bonus_damage_pct end
        return choice.spell_amp or 0
    end
    function m:GetModifierPercentageCooldown(e)
        local a=e and e.ability
        if choice.ult_cdr and a and a:GetAbilityType()==DOTA_ABILITY_TYPE_ULTIMATE then return choice.ult_cdr end
        return choice.cdr_pct or 0
    end
    function m:GetModifierPreAttack_CriticalStrike(e)
        if IsServer() and choice.crit_chance and hostile(self:GetParent(),e.target) and RollPercentage(choice.crit_chance) then return 200 end
    end
    function m:AreaDamage(position,amount,excluded,damageType)
        if self.busy then return end
        self.busy=true
        local p=self:GetParent()
        for _,u in ipairs(FindUnitsInRadius(p:GetTeamNumber(),position,nil,350,DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)) do
            if u~=excluded and u:IsAlive() then
                ApplyDamage({attacker=p,victim=u,damage=amount,damage_type=damageType or DAMAGE_TYPE_MAGICAL,
                    damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION+DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL+DOTA_DAMAGE_FLAG_REFLECTION})
            end
        end
        self.busy=false
    end
    function m:CountAction()
        if not choice.trigger_count then return end
        self.actions=(self.actions or 0)+1
        if self.actions<choice.trigger_count then return end
        self.actions=0
        self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_enfos_evolution_burst",{duration=3})
    end
    function m:OnAttackLanded(e)
        if not IsServer() or e.attacker~=self:GetParent() or not hostile(e.attacker,e.target) then return end
        if choice.cleave_pct then self:AreaDamage(e.target:GetAbsOrigin(),e.damage*choice.cleave_pct/100,e.target,DAMAGE_TYPE_PHYSICAL) end
        if choice.armor_pierce and elite(e.target) then e.target:AddNewModifier(e.attacker,nil,"modifier_enfos_evolution_pierce",{duration=3}) end
        self:CountAction()
    end
    function m:OnAbilityFullyCast(e)
        if not IsServer() or e.unit~=self:GetParent() or not e.ability or e.ability:IsItem() or e.ability:IsToggle() then return end
        self:CountAction()
    end
    function m:OnTakeDamage(e)
        if not IsServer() then return end
        local p=self:GetParent()
        if choice.threshold and e.unit==p and p:IsAlive() and p:GetHealthPercent()<choice.threshold and GameRules:GetGameTime()>=(self.shieldReady or 0) then
            self.shieldReady=GameRules:GetGameTime()+60
            p:AddNewModifier(p,nil,"modifier_enfos_evolution_aegis",{duration=choice.shield_duration})
        end
        if e.attacker~=p or not hostile(p,e.unit) or (e.damage or 0)<=0 or self.busy then return end
        if bit.band(e.damage_flags or 0,DOTA_DAMAGE_FLAG_REFLECTION)~=0 then return end
        if choice.spell_lifesteal and e.inflictor and p:IsAlive() then p:Heal(e.damage*choice.spell_lifesteal/100,e.inflictor) end
        if choice.proc_chance and GameRules:GetGameTime()>=(self.procReady or 0) and RollPercentage(choice.proc_chance) then
            self.procReady=GameRules:GetGameTime()+1
            self:AreaDamage(e.unit:GetAbsOrigin(),choice.proc_damage)
        end
    end
    function m:OnDeath(e)
        if not IsServer() or not choice.explosion_pct or e.attacker~=self:GetParent() or not wave(e.unit) then return end
        self:AreaDamage(e.unit:GetAbsOrigin(),e.unit:GetMaxHealth()*choice.explosion_pct/100,e.unit)
    end
    return m
end
for _,pair in pairs(choices) do for _,choice in ipairs(pair) do
    local name="modifier_enfos_evolution_"..choice.id
    _G[name]=make(choice)
    if LinkLuaModifier then LinkLuaModifier(name,"evolution/modifiers",LUA_MODIFIER_MOTION_NONE) end
end end
modifier_enfos_evolution_pierce=class({})
function modifier_enfos_evolution_pierce:IsDebuff() return true end
function modifier_enfos_evolution_pierce:IsPurgable() return true end
function modifier_enfos_evolution_pierce:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_enfos_evolution_pierce:GetModifierPhysicalArmorBonus() return -5 end
modifier_enfos_evolution_burst=class({})
function modifier_enfos_evolution_burst:IsPurgable() return false end
function modifier_enfos_evolution_burst:DeclareFunctions() return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE} end
function modifier_enfos_evolution_burst:GetModifierPercentageCooldown(e) return e and e.ability and not e.ability:IsItem() and 50 or 0 end
modifier_enfos_evolution_aegis=class({})
function modifier_enfos_evolution_aegis:IsPurgable() return false end
function modifier_enfos_evolution_aegis:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_enfos_evolution_aegis:GetModifierIncomingDamage_Percentage() return -80 end
function modifier_enfos_evolution_aegis:GetModifierMoveSpeedBonus_Percentage() return 30 end
for _,name in ipairs({"pierce","burst","aegis"}) do
    if LinkLuaModifier then LinkLuaModifier("modifier_enfos_evolution_"..name,"evolution/modifiers",LUA_MODIFIER_MOTION_NONE) end
end
return true

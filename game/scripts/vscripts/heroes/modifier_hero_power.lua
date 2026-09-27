local Config=require("heroes/power_config")
modifier_enfos_hero_power=class({})
local M=modifier_enfos_hero_power
function M:IsHidden() return false end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:AllowIllusionDuplicate() return false end
function M:GetTexture() return "alchemist_chemical_rage" end
function M:Matches(values)
    for key in pairs(Config.BASE) do if not self.values or self.values[key]~=values[key] then return false end end
    return true
end
function M:OnCreated(kv)
    self.values={}
    if IsServer() then
        for key in pairs(Config.BASE) do self.values[key]=tonumber(kv[key]) or 0 end
        self:SetHasCustomTransmitterData(true)
    end
end
function M:OnRefresh(kv)
    if not IsServer() then return end
    for key in pairs(Config.BASE) do self.values[key]=tonumber(kv[key]) or 0 end
    self:SendBuffRefreshToClients()
end
function M:AddCustomTransmitterData() return self.values end
function M:HandleCustomTransmitterData(data) self.values=data end
function M:Value(key) return self.values and self.values[key] or 0 end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_HEALTH_BONUS,MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function M:GetModifierHealthBonus() return self:Value("health") end
function M:GetModifierManaBonus() return self:Value("mana") end
function M:GetModifierPreAttack_BonusDamage() return self:Value("damage") end
function M:GetModifierAttackSpeedBonus_Constant() return self:Value("attackSpeed") end
function M:GetModifierSpellAmplify_Percentage() return self:Value("spellAmp") end
function M:GetModifierConstantHealthRegen() return self:Value("healthRegen") end
function M:GetModifierConstantManaRegen() return self:Value("manaRegen") end
function M:GetModifierPercentageCooldown(event)
    -- Hero skills only: no multiplicative acceleration of items/Spellbringer.
    local ability=event and event.ability
    if not ability or ability:IsItem() or ability:GetCaster()~=self:GetParent() then return 0 end
    return self:Value("cooldown")
end

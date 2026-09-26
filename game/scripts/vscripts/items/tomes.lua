--------------------------------------------------------------------------------
-- tomes.lua
-- Consumable stat tomes for Enfos Team Survival — SametC Edition
-- Available from match start. Immediately consumed for permanent stats.
-- Reference: docs/GAME_DESIGN_MASTER.md § 22
--------------------------------------------------------------------------------

local function ConsumeTome(ability, statKey, amount)
	local caster = ability:GetCaster()
	if not caster or caster:IsNull() or not caster:IsRealHero() then return end

	if statKey == "str" then
		caster:ModifyStrength(amount)
	elseif statKey == "agi" then
		caster:ModifyAgility(amount)
	elseif statKey == "int" then
		caster:ModifyIntellect(amount)
	end

	-- Sound & visual effects
	caster:EmitSound("Item.TomeOfKnowledge")
	local fx = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(fx)

	-- Spend charge and remove item
	ability:SpendCharge()
	if ability:GetCurrentCharges() <= 0 then
		caster:RemoveItem(ability)
	end
end

--------------------------------------------------------------------------------
-- Strength Tome
--------------------------------------------------------------------------------
if item_enfos_tome_str == nil then
	item_enfos_tome_str = class({})
end

function item_enfos_tome_str:OnSpellStart()
	local bonus = self:GetSpecialValueFor("stat_bonus") or 2
	ConsumeTome(self, "str", bonus)
end

--------------------------------------------------------------------------------
-- Agility Tome
--------------------------------------------------------------------------------
if item_enfos_tome_agi == nil then
	item_enfos_tome_agi = class({})
end

function item_enfos_tome_agi:OnSpellStart()
	local bonus = self:GetSpecialValueFor("stat_bonus") or 2
	ConsumeTome(self, "agi", bonus)
end

--------------------------------------------------------------------------------
-- Intelligence Tome
--------------------------------------------------------------------------------
if item_enfos_tome_int == nil then
	item_enfos_tome_int = class({})
end

function item_enfos_tome_int:OnSpellStart()
	local bonus = self:GetSpecialValueFor("stat_bonus") or 2
	ConsumeTome(self, "int", bonus)
end

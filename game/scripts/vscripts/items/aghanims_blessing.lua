--------------------------------------------------------------------------------
-- aghanims_blessing.lua
-- Ascended Aghanim's Blessing Item (GAME_DESIGN_MASTER.md § 16, § 23)
-- Consumes Scepter + 40 Lumber to free inventory slot while retaining Scepter bonuses.
--------------------------------------------------------------------------------

local AghanimManager = require("heroes/aghanim_manager")

if item_ascended_aghanims_blessing == nil then
	item_ascended_aghanims_blessing = class({})
end

function item_ascended_aghanims_blessing:OnSpellStart()
	local caster = self:GetCaster()
	if not caster or caster:IsNull() or not caster:IsRealHero() then return end

	-- Apply consumed modifiers
	if caster.AddNewModifier then
		caster:AddNewModifier(caster, nil, "modifier_item_ascended_aghanims_blessing_consumed", {})
		caster:AddNewModifier(caster, nil, "modifier_item_ultimate_scepter_consumed", {})
	end

	-- Sound & particles
	caster:EmitSound("DOTA_Item.Refresher.Activate")
	if ParticleManager then
		local fx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_spotlight.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(fx)
	end

	local heroName = caster.GetUnitName and caster:GetUnitName() or ""
	local role = caster.heroRole or AghanimManager:DetectHeroRole(heroName)
	AghanimManager:UpdateHeroAghanimState(caster, role)

	caster:RemoveItem(self)
end

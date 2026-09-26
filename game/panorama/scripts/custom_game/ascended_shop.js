"use strict";

var g_AscendedShopOpen = false;
var g_CurrentRoleFilter = "ALL";

// Client copy of the 30 catalog items for instant responsive rendering
var ASCENDED_CATALOG = [
	{ id: "item_ascended_thornplate", base: "item_blade_mail", tier: 1, lumber: 55, role: "Tank" },
	{ id: "item_ascended_sacred_reliquary", base: "item_holy_locket", tier: 1, lumber: 55, role: "Support" },
	{ id: "item_ascended_sunward_crest", base: "item_solar_crest", tier: 1, lumber: 55, role: "Support" },
	{ id: "item_ascended_bastion_guard", base: "item_crimson_guard", tier: 2, lumber: 70, role: "Tank" },
	{ id: "item_ascended_aegis_of_insight", base: "item_pipe", tier: 2, lumber: 70, role: "Tank" },
	{ id: "item_ascended_leviathan_harpoon", base: "item_harpoon", tier: 2, lumber: 70, role: "Fighter" },
	{ id: "item_ascended_warstride", base: "item_sange_and_yasha", tier: 2, lumber: 70, role: "Fighter" },
	{ id: "item_ascended_seraphic_greaves", base: "item_guardian_greaves", tier: 2, lumber: 70, role: "Support" },
	{ id: "item_ascended_mirror_lotus", base: "item_lotus_orb", tier: 2, lumber: 70, role: "Support" },
	{ id: "item_ascended_war_drums", base: "item_boots_of_bearing", tier: 2, lumber: 70, role: "Support" },
	{ id: "item_ascended_sovereign_bkb", base: "item_black_king_bar", tier: 2, lumber: 70, role: "Fighter" },
	{ id: "item_ascended_chrono_disk", base: "item_aeon_disk", tier: 2, lumber: 70, role: "Mage" },
	{ id: "item_ascended_astral_sphere", base: "item_sphere", tier: 2, lumber: 70, role: "Mage" },
	{ id: "item_ascended_worldheart", base: "item_heart", tier: 3, lumber: 85, role: "Tank" },
	{ id: "item_ascended_abyssal_dominion", base: "item_abyssal_blade", tier: 3, lumber: 85, role: "Fighter" },
	{ id: "item_ascended_blood_oath", base: "item_satanic", tier: 3, lumber: 85, role: "Carry" },
	{ id: "item_ascended_starforged_daedalus", base: "item_greater_crit", tier: 3, lumber: 85, role: "Carry" },
	{ id: "item_ascended_phantomwing", base: "item_butterfly", tier: 3, lumber: 85, role: "Carry" },
	{ id: "item_ascended_heavenpiercer", base: "item_monkey_king_bar", tier: 3, lumber: 85, role: "Carry" },
	{ id: "item_ascended_stormfather", base: "item_mjollnir", tier: 3, lumber: 85, role: "Carry" },
	{ id: "item_ascended_chronocore", base: "item_octarine_core", tier: 3, lumber: 85, role: "Mage" },
	{ id: "item_ascended_arc_bloodstone", base: "item_bloodstone", tier: 3, lumber: 85, role: "Mage" },
	{ id: "item_ascended_eternity_orb", base: "item_refresher", tier: 3, lumber: 85, role: "Mage" },
	{ id: "item_ascended_grand_vyse", base: "item_sheepstick", tier: 3, lumber: 85, role: "Mage" },
	{ id: "item_ascended_legion_cuirass", base: "item_assault", tier: 3, lumber: 85, role: "Fighter" },
	{ id: "item_ascended_absolute_zero", base: "item_shivas_guard", tier: 3, lumber: 85, role: "Mage" },
	{ id: "item_ascended_eye_of_deep_winter", base: "item_skadi", tier: 3, lumber: 85, role: "Carry" },
	{ id: "item_ascended_world_chain", base: "item_gungir", tier: 3, lumber: 85, role: "Carry" },
	{ id: "item_ascended_tempest_waker", base: "item_wind_waker", tier: 3, lumber: 85, role: "Mage" },
	{ id: "item_ascended_soulpiercer", base: "item_bloodthorn", tier: 3, lumber: 85, role: "Carry" },
];

function ToggleAscendedShop() {
	var win = $("#AscendedShopWindow");
	if (!win) return;
	g_AscendedShopOpen = !g_AscendedShopOpen;
	win.SetHasClass("Hidden", !g_AscendedShopOpen);
	if (g_AscendedShopOpen) {
		RenderCatalog();
	}
}

function SetRoleFilter(role) {
	g_CurrentRoleFilter = role;
	var tabs = ["FilterAll", "FilterTank", "FilterFighter", "FilterCarry", "FilterMage", "FilterSupport"];
	for (var i = 0; i < tabs.length; ++i) {
		var tab = $("#" + tabs[i]);
		if (tab) {
			tab.SetHasClass("Active", tabs[i] === ("Filter" + (role === "ALL" ? "All" : role)));
		}
	}
	RenderCatalog();
}

function PurchaseAscended(ascendedId) {
	GameEvents.SendCustomGameEventToServer("enfos_buy_ascended_item", {
		ascended_id: ascendedId
	});
	// Re-render after a brief moment
	$.Schedule(0.2, RenderCatalog);
}

function RenderCatalog() {
	var container = $("#AscendedItemsContainer");
	if (!container) return;
	container.RemoveAndDeleteChildren();

	for (var i = 0; i < ASCENDED_CATALOG.length; ++i) {
		var item = ASCENDED_CATALOG[i];
		if (g_CurrentRoleFilter !== "ALL" && item.role !== g_CurrentRoleFilter) {
			continue;
		}

		var card = $.CreatePanel("Panel", container, "AscendedCard_" + item.id);
		card.AddClass("AscendedCard");
		card.AddClass("Tier" + item.tier);

		// Header row with icons
		var iconRow = $.CreatePanel("Panel", card, "");
		iconRow.AddClass("CardIconRow");

		var baseIcon = $.CreatePanel("DOTAItemImage", iconRow, "");
		baseIcon.itemname = item.base;
		baseIcon.AddClass("ItemIcon Base");

		var arrow = $.CreatePanel("Label", iconRow, "");
		arrow.AddClass("ArrowIcon");
		arrow.text = "➔";

		var ascIcon = $.CreatePanel("DOTAItemImage", iconRow, "");
		ascIcon.itemname = item.base;
		ascIcon.AddClass("ItemIcon Ascended");

		// Info Block
		var infoBlock = $.CreatePanel("Panel", card, "");
		infoBlock.AddClass("CardInfoBlock");

		var nameLabel = $.CreatePanel("Label", infoBlock, "");
		nameLabel.AddClass("CardTitle");
		nameLabel.text = $.Localize("#DOTA_Tooltip_Ability_" + item.id);

		var descLabel = $.CreatePanel("Label", infoBlock, "");
		descLabel.AddClass("CardDesc");
		descLabel.text = $.Localize("#DOTA_Tooltip_Ability_" + item.id + "_Description");

		// Bottom row: Badges and Upgrade Button
		var bottomRow = $.CreatePanel("Panel", card, "");
		bottomRow.AddClass("CardBottomRow");

		var badges = $.CreatePanel("Panel", bottomRow, "");
		badges.AddClass("BadgesBlock");

		var lumberBadge = $.CreatePanel("Label", badges, "");
		lumberBadge.AddClass("LumberBadge");
		lumberBadge.text = item.lumber + " Odun";

		var roleBadge = $.CreatePanel("Label", badges, "");
		roleBadge.AddClass("RoleBadge " + item.role);
		roleBadge.text = item.role;

		var upgradeBtn = $.CreatePanel("Button", bottomRow, "");
		upgradeBtn.AddClass("UpgradeBtn");
		var btnLabel = $.CreatePanel("Label", upgradeBtn, "");
		btnLabel.text = "Yükselt";

		(function(itemId) {
			upgradeBtn.SetPanelEvent("onactivate", function() {
				PurchaseAscended(itemId);
			});
		})(item.id);
	}
}

(function() {
	// Initial catalog render
	$.Schedule(1.0, RenderCatalog);
})();

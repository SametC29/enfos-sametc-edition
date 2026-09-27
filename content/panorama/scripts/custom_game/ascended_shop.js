"use strict";

var g_AscendedShopOpen = false;
var g_CurrentRoleFilter = "ALL";

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
	var catalog=CustomNetTables.GetTableValue("ascended_shop","catalog") || {};
	if (!Object.keys(catalog).some(function(k) { return catalog[k].id===ascendedId && Number(catalog[k].available)===1; })) return;
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

	var data = CustomNetTables.GetTableValue("ascended_shop", "catalog") || {};
	var catalog = Object.keys(data).sort(function(a,b) { return Number(a)-Number(b); }).map(function(k) { return data[k]; });
	for (var i = 0; i < catalog.length; ++i) {
		var item = catalog[i];
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
		baseIcon.itemname = item.base_item;
		baseIcon.AddClass("ItemIcon Base");

		var arrow = $.CreatePanel("Label", iconRow, "");
		arrow.AddClass("ArrowIcon");
		arrow.text = "➔";

		var ascIcon = $.CreatePanel("DOTAItemImage", iconRow, "");
		ascIcon.itemname = item.id;
		(function(base, asc, entry) {
			base.SetPanelEvent("onmouseover", function() { $.DispatchEvent("DOTAShowAbilityTooltip", base, entry.base_item); });
			asc.SetPanelEvent("onmouseover", function() { $.DispatchEvent("DOTAShowAbilityTooltip", asc, entry.id); });
			[base,asc].forEach(function(p) { p.SetPanelEvent("onmouseout", function() { $.DispatchEvent("DOTAHideAbilityTooltip",p); }); });
		})(baseIcon,ascIcon,item);
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
		lumberBadge.text = item.lumber + " " + $.Localize("#enfos_lumber");

		var roleBadge = $.CreatePanel("Label", badges, "");
		roleBadge.AddClass("RoleBadge " + item.role);
		roleBadge.text = $.Localize("#enfos_role_" + item.role.toLowerCase());

		var upgradeBtn = $.CreatePanel("Button", bottomRow, "");
		upgradeBtn.AddClass("UpgradeBtn");
		var btnLabel = $.CreatePanel("Label", upgradeBtn, "");
		upgradeBtn.enabled = Number(item.available) === 1;
		btnLabel.text = $.Localize(upgradeBtn.enabled ? "#enfos_ascended_upgrade" : "#enfos_ascended_unavailable");

		(function(itemId) {
			upgradeBtn.SetPanelEvent("onactivate", function() {
				PurchaseAscended(itemId);
			});
		})(item.id);
	}
}

(function() {
	CustomNetTables.SubscribeNetTableListener("ascended_shop", function() { if(g_AscendedShopOpen) RenderCatalog(); });
	// Initial catalog render
	$.Schedule(1.0, RenderCatalog);
})();

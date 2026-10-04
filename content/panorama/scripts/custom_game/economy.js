"use strict";

var g_EconomyPanelOpen = false;

function ToggleEconomyPanel() {
	var panel = $("#EconomyPanel");
	if (!panel) return;
	g_EconomyPanelOpen = !g_EconomyPanelOpen;
	panel.SetHasClass("Hidden", !g_EconomyPanelOpen);
}

function ConvertGoldToLumber(amount) {
	GameEvents.SendCustomGameEventToServer("enfos_convert_gold_to_lumber", {
		amount: amount || 1000
	});
}

function ConvertLumberToGold(amount) {
	GameEvents.SendCustomGameEventToServer("enfos_convert_lumber_to_gold", {
		amount: amount || 10
	});
}

function BuyTome(tomeType) {
	GameEvents.SendCustomGameEventToServer("enfos_buy_tome", {
		tome_type: tomeType
	});
}

function TransferGold(recipientId, amount) {
	GameEvents.SendCustomGameEventToServer("enfos_transfer_gold", {
		recipient_id: recipientId,
		amount: amount
	});
}

function TransferLumber(recipientId, amount) {
	GameEvents.SendCustomGameEventToServer("enfos_transfer_lumber", {
		recipient_id: recipientId,
		amount: amount
	});
}

function OnEconomyStateChanged(table_name, key, data) {
	var localPlayerId = Players.GetLocalPlayer();
	if (key !== localPlayerId.toString() || !data) return;

	// Update Lumber Counter
	var lumberLabel = $("#LumberAmount");
	if (lumberLabel) {
		lumberLabel.text = (data.lumber || 0).toString();
	}

	// Update Tome Labels with dynamic escalating costs
	var strLabel = $("#StrTomeLabel");
	if (strLabel && data.tome_str_cost) {
		strLabel.text = $.Localize("#enfos_economy_str") + " +2 (" + data.tome_str_cost + "g) [" + (data.tome_str_count || 0) + "]";
	}

	var agiLabel = $("#AgiTomeLabel");
	if (agiLabel && data.tome_agi_cost) {
		agiLabel.text = $.Localize("#enfos_economy_agi") + " +2 (" + data.tome_agi_cost + "g) [" + (data.tome_agi_count || 0) + "]";
	}

	var intLabel = $("#IntTomeLabel");
	if (intLabel && data.tome_int_cost) {
		intLabel.text = $.Localize("#enfos_economy_int") + " +2 (" + data.tome_int_cost + "g) [" + (data.tome_int_count || 0) + "]";
	}
}

function UpdateTeammateList() {
	var container = $("#TeammateList");
	if (!container) return;
	container.RemoveAndDeleteChildren();

	var localPlayerId = Players.GetLocalPlayer();
	var localTeam = Players.GetTeam(localPlayerId);

	var playerIds = Game.GetPlayerIDsOnTeam(localTeam);
	for (var i = 0; i < playerIds.length; ++i) {
		var pid = playerIds[i];
		if (pid === localPlayerId) continue;

		var row = $.CreatePanel("Panel", container, "TeammateRow_" + pid);
		row.AddClass("TeammateRow");

		var nameLabel = $.CreatePanel("Label", row, "");
		nameLabel.AddClass("TeammateName");
		nameLabel.text = Players.GetPlayerName(pid) || ($.Localize("#enfos_player") + " " + pid);

		// Gold send buttons
		var goldBtn500 = $.CreatePanel("Button", row, "");
		goldBtn500.AddClass("TransferBtn Gold");
		var g500Lbl = $.CreatePanel("Label", goldBtn500, "");
		g500Lbl.text = "+500 G";
		(function(targetId) {
			goldBtn500.SetPanelEvent("onactivate", function() {
				TransferGold(targetId, 500);
			});
		})(pid);

		// Lumber send buttons
		var lumBtn10 = $.CreatePanel("Button", row, "");
		lumBtn10.AddClass("TransferBtn Lumber");
		var l10Lbl = $.CreatePanel("Label", lumBtn10, "");
		l10Lbl.text = "+10 L";
		(function(targetId) {
			lumBtn10.SetPanelEvent("onactivate", function() {
				TransferLumber(targetId, 10);
			});
		})(pid);
	}
}

(function() {
	CustomNetTables.SubscribeNetTableListener("economy_state", OnEconomyStateChanged);

	// Read initial state
	var localPlayerId = Players.GetLocalPlayer();
	var initialData = CustomNetTables.GetTableValue("economy_state", localPlayerId.toString());
	if (initialData) {
		OnEconomyStateChanged("economy_state", localPlayerId.toString(), initialData);
	}

	$.Schedule(1.0, UpdateTeammateList);
})();

// Enfos Team Survival — SametC Edition: Evolution Milestone JS
// Manages in-match level milestone build choices (Levels 4, 7, 10, 13, 16, 19)

var EnfosEvolution = (function () {
	"use strict";

	var currentMilestone = 0;
	var currentChoices = [];
	var pendingCount = 0;
	var isModalVisible = false;

	function Init() {
		CustomNetTables.SubscribeNetTableListener("evolution_state", OnNetTableChanged);

		var playerId = Players.GetLocalPlayer();
		var state = CustomNetTables.GetTableValue("evolution_state", String(playerId));
		if (state) {
			UpdateUI(state);
		}
	}

	function OnNetTableChanged(table, key, data) {
		var localPlayerId = String(Players.GetLocalPlayer());
		if (key === localPlayerId && data) {
			UpdateUI(data);
		}
	}

	function UpdateUI(data) {
		pendingCount = data.pending_count || 0;
		currentMilestone = data.next_milestone || 0;
		currentChoices = [];

		if (data.active_choices) {
			// In Lua it may arrive as an array or object table with 1, 2
			for (var k in data.active_choices) {
				currentChoices.push(data.active_choices[k]);
			}
		}

		var badge = $("#EvoBadgeButton");
		var badgeText = $("#EvoBadgeText");
		var modal = $("#EvoModal");

		if (pendingCount > 0) {
			badge.RemoveClass("EvoBadgeHidden");
			badgeText.text = pendingCount + " " + $.Localize("#enfos_evolution_pending");

			// If modal was not manually deferred, automatically show it for the first milestone
			if (!isModalVisible && Number(data.deferred) !== 1 && currentChoices.length > 0) {
				ShowModal();
			}
		} else {
			badge.AddClass("EvoBadgeHidden");
			modal.AddClass("EvoModalHidden");
			isModalVisible = false;
		}

		RefreshCards();
	}

	function RefreshCards() {
		if (currentChoices.length < 2) return;

		var titleLabel = $("#EvoMilestoneTitle");
		if (titleLabel) {
			titleLabel.text = $.Localize("#enfos_evolution_level") + " " + currentMilestone;
		}

		var c1 = currentChoices[0];
		var c2 = currentChoices[1];

		if (c1) {
			$("#EvoCardIcon1").abilityname = c1.icon || "";
			$("#EvoCardTitle1").text = $.Localize("#" + c1.id);
			$("#EvoCardDesc1").text = $.Localize("#" + c1.id + "_desc");
		}

		if (c2) {
			$("#EvoCardIcon2").abilityname = c2.icon || "";
			$("#EvoCardTitle2").text = $.Localize("#" + c2.id);
			$("#EvoCardDesc2").text = $.Localize("#" + c2.id + "_desc");
		}
	}

	function ShowModal() {
		var modal = $("#EvoModal");
		if (modal && currentChoices.length >= 2) {
			modal.RemoveClass("EvoModalHidden");
			isModalVisible = true;
			RefreshCards();
		}
	}

	function ToggleModal() {
		var modal = $("#EvoModal");
		if (!modal) return;

		if (isModalVisible) {
            Defer();
		} else if (pendingCount > 0) {
			ShowModal();
		}
	}

	function SelectChoice(cardIndex) {
		var choice = currentChoices[cardIndex - 1];
		if (!choice || !currentMilestone) return;

		GameEvents.SendCustomGameEventToServer("enfos_select_evolution", {
			milestone_level: currentMilestone,
			choice_id: choice.id,
		});

		// Modal closes or transitions to next queued milestone automatically via NetTable sync
	}

	function Defer() {
		var modal = $("#EvoModal");
		if (modal) {
			modal.AddClass("EvoModalHidden");
			isModalVisible = false;
		}

		GameEvents.SendCustomGameEventToServer("enfos_defer_evolution", {});
	}

	return {
		Init: Init,
		ToggleModal: ToggleModal,
		SelectChoice: SelectChoice,
		Defer: Defer,
	};
})();

(function () {
	EnfosEvolution.Init();
})();

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
			badgeText.text = pendingCount + (pendingCount > 1 ? " Gelişim Seçimi Bekliyor!" : " Gelişim Seçimi!");

			// If modal was not manually deferred, automatically show it for the first milestone
			if (!isModalVisible && currentChoices.length > 0) {
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
			titleLabel.text = "KAHRAMAN GELİŞİMİ — SEVİYE " + currentMilestone;
		}

		var c1 = currentChoices[0];
		var c2 = currentChoices[1];

		if (c1) {
			$("#EvoCardIcon1").abilityname = c1.icon || "";
			$("#EvoCardTitle1").text = c1.title || "";
			$("#EvoCardDesc1").text = c1.desc || "";
		}

		if (c2) {
			$("#EvoCardIcon2").abilityname = c2.icon || "";
			$("#EvoCardTitle2").text = c2.title || "";
			$("#EvoCardDesc2").text = c2.desc || "";
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
			modal.AddClass("EvoModalHidden");
			isModalVisible = false;
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

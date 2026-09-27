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

        RenderChoice(c1, 1);
        RenderChoice(c2, 2);
	}

    function RenderChoice(choice, index) {
        if (!choice) return;
        $("#EvoCardIcon" + index).abilityname = choice.icon || "";
        if (choice.hero) {
            $("#EvoCardTitle" + index).text = $.Localize("#DOTA_Tooltip_Ability_" + choice.ability);
            var kind = choice.special === "cooldown" ? "cooldown" : choice.mode === "+" ? "add" : "percent";
            var message = $.Localize("#enfos_evo_" + kind);
            if (kind !== "cooldown") message = message.replace("{stat}", $.Localize("#enfos_evo_stat_" + choice.special));
            message = message.replace("{amount}", String(choice.amount));
            $("#EvoCardDesc" + index).text = message;
        } else {
            $("#EvoCardTitle" + index).text = $.Localize("#" + choice.id);
            $("#EvoCardDesc" + index).text = $.Localize("#" + choice.id + "_desc");
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

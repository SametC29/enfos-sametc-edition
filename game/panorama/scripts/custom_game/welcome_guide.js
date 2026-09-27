// Enfos Team Survival — SametC Edition: Welcome Guide JS

var EnfosWelcomeGuide = (function () {
	"use strict";

	var hasShownInitially = false;

	function Init() {
		GameEvents.Subscribe("game_rules_state_change", OnStateChange);
		GameEvents.Subscribe("enfos_toggle_welcome_guide", ToggleGuide);
		CheckInitialPopup();
	}

	function OnStateChange() {
		CheckInitialPopup();
	}

	function CheckInitialPopup() {
		if (hasShownInitially) return;
		var state = Game.GetState();
		// DOTA_GAMERULES_STATE_PRE_GAME is 7, GAME_IN_PROGRESS is 8
		if (state >= 7) {
			hasShownInitially = true;
			OpenGuide();
		}
	}

	function OpenGuide() {
		var root = $.GetContextPanel();
		if (root) {
			root.RemoveClass("WelcomeGuideHidden");
		}
	}

	function CloseGuide() {
		var root = $.GetContextPanel();
		if (root) {
			root.AddClass("WelcomeGuideHidden");
		}
	}

	function ToggleGuide() {
		var root = $.GetContextPanel();
		if (!root) return;
		if (root.BHasClass("WelcomeGuideHidden")) {
			OpenGuide();
		} else {
			CloseGuide();
		}
	}

	Init();

	return {
		OpenGuide: OpenGuide,
		CloseGuide: CloseGuide,
		ToggleGuide: ToggleGuide
	};
})();

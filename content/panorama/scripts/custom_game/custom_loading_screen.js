// Enfos Team Survival — SametC Edition: Custom Loading Screen JS

var EnfosLoading = (function () {
	"use strict";

	var tips = [
		{
			category: "#enfos_loading_tip_economy",
			text: "#enfos_loading_tip_economy_desc"
		},
		{
			category: "#enfos_loading_tip_spellbringer",
			text: "#enfos_loading_tip_spellbringer_desc"
		},
		{
			category: "#enfos_loading_tip_life",
			text: "#enfos_loading_tip_life_desc"
		},
		{
			category: "#enfos_loading_tip_waves",
			text: "#enfos_loading_tip_waves_desc"
		},
		{
			category: "#enfos_loading_tip_boss",
			text: "#enfos_loading_tip_boss_desc"
		}
	];

	var currentTipIndex = 0;

	function RotateTip() {
		currentTipIndex = (currentTipIndex + 1) % tips.length;
		var tip = tips[currentTipIndex];

		var catLabel = $("#TipCategory");
		var textLabel = $("#StrategyTipText");

		if (catLabel) catLabel.text = $.Localize(tip.category);
		if (textLabel) textLabel.text = $.Localize(tip.text);

		$.Schedule(4.5, RotateTip);
	}

	function Init() {
		// Start rotating strategy tips
		$.Schedule(4.0, RotateTip);
	}

	Init();

	return {};
})();

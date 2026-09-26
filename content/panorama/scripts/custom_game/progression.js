"use strict";

var g_IsPanelOpen = false;

function ToggleProgressionPanel() {
	var panel = $("#ProgressionPanel");
	if (!panel) return;
	g_IsPanelOpen = !g_IsPanelOpen;
	panel.SetHasClass("Hidden", !g_IsPanelOpen);
}

function AllocateRank(branch) {
	GameEvents.SendCustomGameEventToServer("enfos_allocate_legacy_rank", {
		branch: branch
	});
}

function RespecLegacy() {
	GameEvents.SendCustomGameEventToServer("enfos_respec_legacy", {});
}

function OnProgressionStateChanged(table_name, key, data) {
	var localPlayerId = Players.GetLocalPlayer();
	var expectedKey = "player_" + localPlayerId;

	if (key !== expectedKey || !data) return;

	// Level & XP
	var lvl = data.account_level || 1;
	var xp = data.account_xp || 0;
	var reqXp = data.account_xp_required || 500;
	$("#AccountLevelLabel").text = $.Localize("#enfos_account_level") + ": " + lvl;
	$("#AccountXpLabel").text = xp + " / " + reqXp + " XP";

	var pct = (reqXp > 0) ? Math.min(100, Math.floor((xp / reqXp) * 100)) : 100;
	$("#XpBarProgress").style.width = pct + "%";

	// Legacy Unspent
	var unspent = data.unspent_legacy || 0;
	$("#UnspentPointsLabel").text = $.Localize("#enfos_legacy_unspent") + ": " + unspent;

	// Branches
	var leg = data.legacy || {};
	var offRank = leg.offense || 0;
	var defRank = leg.defense || 0;
	var ecoRank = leg.economy || 0;
	var splRank = leg.spellbringer || 0;

	$("#OffenseRank").text = offRank + " / 12";
	$("#OffenseDesc").text = "+" + (offRank * 0.5).toFixed(1) + "% " + $.Localize("#enfos_legacy_offense_bonus");
	$("#OffensePlusBtn").SetHasClass("Disabled", unspent <= 0 || offRank >= 12);

	$("#DefenseRank").text = defRank + " / 12";
	$("#DefenseDesc").text = "+" + (defRank * 0.5).toFixed(1) + "% " + $.Localize("#enfos_legacy_defense_bonus");
	$("#DefensePlusBtn").SetHasClass("Disabled", unspent <= 0 || defRank >= 12);

	$("#EconomyRank").text = ecoRank + " / 12";
	$("#EconomyDesc").text = "+" + (ecoRank * 0.5).toFixed(1) + "% " + $.Localize("#enfos_legacy_economy_bonus");
	$("#EconomyPlusBtn").SetHasClass("Disabled", unspent <= 0 || ecoRank >= 12);

	$("#SpellbringerRank").text = splRank + " / 12";
	$("#SpellbringerDesc").text = "+" + (splRank * 0.5).toFixed(1) + "% " + $.Localize("#enfos_legacy_spellbringer_bonus");
	$("#SpellbringerPlusBtn").SetHasClass("Disabled", unspent <= 0 || splRank >= 12);

	// Difficulty & Hero Mastery
	var diff = data.highest_difficulty || "normal";
	$("#DifficultyLabel").text = $.Localize("#enfos_unlocked_difficulty") + ": " + diff.toUpperCase();

	var heroEnt = Players.GetPlayerHeroEntityIndex(localPlayerId);
	var heroName = (heroEnt !== -1) ? Entities.GetUnitName(heroEnt) : "unknown";
	var mastery = (data.hero_mastery && data.hero_mastery[heroName]) || { rank: 1, xp: 0 };
	$("#HeroMasteryLabel").text = $.Localize("#enfos_hero_mastery") + ": " + mastery.rank + " (" + mastery.xp + " XP)";
}

(function() {
	CustomNetTables.SubscribeNetTableListener("progression_state", OnProgressionStateChanged);

	var localPlayerId = Players.GetLocalPlayer();
	var initialData = CustomNetTables.GetTableValue("progression_state", "player_" + localPlayerId);
	if (initialData) {
		OnProgressionStateChanged("progression_state", "player_" + localPlayerId, initialData);
	}
})();

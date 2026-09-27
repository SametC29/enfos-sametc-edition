// Enfos Team Survival — SametC Edition: Hero Selection Screen JS

var EnfosHeroSelect = (function () {
	"use strict";

	var currentSelectedHero = null;
	var isLockedIn = false;
	var cardPanels = {};

	function Values(table) {
		return Object.keys(table || {}).sort(function(a,b) { return Number(a)-Number(b); }).map(function(k) { return table[k]; });
	}
	function RefreshRoster() {
		var roster=[];
		["Tank","Fighter","Carry","Mage","Support"].forEach(function(role) {
			var data=CustomNetTables.GetTableValue("hero_selection_state","roster_"+role);
			Values(data && data.heroes).forEach(function(hero) { hero.abilities=Values(hero.abilities);roster.push(hero); });
		});
		if (!roster.length) return;
		PopulateRoster(roster);
		var selected=roster.filter(function(h) { return currentSelectedHero && h.id===currentSelectedHero.id; })[0];
		SelectHero(selected || roster[0]);
	}

	function Init() {
		CustomNetTables.SubscribeNetTableListener("hero_selection_state", OnNetTableChanged);
		GameEvents.Subscribe("game_rules_state_change", OnStateChange);

		RefreshRoster();

		var state = CustomNetTables.GetTableValue("hero_selection_state", "state");
		if (state) {
			UpdateUI(state);
		}

		CheckVisibility();
	}

	function OnStateChange() {
		CheckVisibility();
	}

	function CheckVisibility() {
		var state = Game.GetState();
		var root = $.GetContextPanel();
		// DOTA_GAMERULES_STATE_HERO_SELECTION is 3, STRATEGY_TIME is 4
		if (state === 3 || state === 4) {
			root.RemoveClass("HeroSelectionHidden");
		} else {
			root.AddClass("HeroSelectionHidden");
		}
	}

	function OnNetTableChanged(table, key, data) {
		if (key.indexOf("roster_")===0) { RefreshRoster();return; }
		if (key === "state" && data) {
			UpdateUI(data);
		}
	}

	function UpdateUI(data) {
		if (data.remaining_time !== undefined) {
			var timer = $("#SelectTimerLabel");
			if (timer) timer.text = data.remaining_time.toString();
		}


		// Update pick indicators
		var picks = data.picks || {};
		var localId = Players.GetLocalPlayer();
		if (picks[localId]) {
			isLockedIn = true;
			var btn = $("#PickHeroBtn");
			var label = $("#PickHeroBtnLabel");
			if (btn && label) {
				btn.AddClass("LockedIn");
				label.text = "LOCKED IN";
			}
		}
	}

	function PopulateRoster(roster) {
		var topContainer = $("#TopRoleHeroes");
		var leftContainer = $("#LeftRoleHeroes");
		var rightContainer = $("#RightRoleHeroes");
		var bottomContainer = $("#BottomRoleHeroes");
		var carryContainer = $("#CarryRoleHeroes");

		if (!topContainer || !leftContainer) return;

		topContainer.RemoveAndDeleteChildren();
		leftContainer.RemoveAndDeleteChildren();
		rightContainer.RemoveAndDeleteChildren();
		bottomContainer.RemoveAndDeleteChildren();
		carryContainer.RemoveAndDeleteChildren();
		cardPanels = {};

		for (var i = 0; i < roster.length; i++) {
			var hero = roster[i];
			var targetContainer = null;

			if (hero.role === "Tank") targetContainer = topContainer;
			else if (hero.role === "Fighter") targetContainer = leftContainer;
			else if (hero.role === "Carry") targetContainer = carryContainer;
			else if (hero.role === "Mage") targetContainer = bottomContainer;
			else if (hero.role === "Support") targetContainer = rightContainer;

			if (!targetContainer) targetContainer = topContainer;

			CreateHeroCard(hero, targetContainer);
		}
	}

	function CreateHeroCard(hero, container) {
		var card = $.CreatePanel("Panel", container, "Card_" + hero.id);
		card.AddClass("HeroCard");

		var img = $.CreatePanel("DOTAHeroImage", card, "");
		img.AddClass("HeroCardImg");
		img.heroname = hero.id;
		img.heroimagestyle = "icon";

		var label = $.CreatePanel("Label", card, "");
		label.AddClass("HeroCardName");
		label.text = hero.name;

		card.SetPanelEvent("onactivate", (function (h) {
			return function () {
				SelectHero(h);
			};
		})(hero));

		cardPanels[hero.id] = card;
	}

	function SelectHero(hero) {
		currentSelectedHero = hero;

		// Highlight selected card
		for (var hid in cardPanels) {
			cardPanels[hid].RemoveClass("HeroCardSelected");
		}
		if (cardPanels[hero.id]) {
			cardPanels[hero.id].AddClass("HeroCardSelected");
		}

		// Update Center Showcase
		var heroImg = $("#ShowcaseHeroImage");
		if (heroImg) {
			heroImg.heroname = hero.id;
		}

		var title = $("#ShowcaseHeroTitle");
		if (title) {
			title.text = hero.name.toUpperCase();
		}

		var attrBadge = $("#AttrBadgeText");
		if (attrBadge) {
			if (hero.primary === "DOTA_ATTRIBUTE_STRENGTH") attrBadge.text = "STR";
			else if (hero.primary === "DOTA_ATTRIBUTE_AGILITY") attrBadge.text = "AGI";
			else attrBadge.text = "INT";
		}

		var roleBadge = $("#RoleBadgeText");
		if (roleBadge) {
			roleBadge.text = (hero.role || "HERO").toUpperCase();
		}

		// Render abilities
		var abilitiesRow = $("#ShowcaseAbilities");
		if (abilitiesRow) {
			abilitiesRow.RemoveAndDeleteChildren();
			for (var a = 0; a < (hero.abilities || []).length; a++) {
				var abName = hero.abilities[a];
				var abIcon = $.CreatePanel("DOTAAbilityImage", abilitiesRow, "AbilityIcon_" + a);
				abIcon.AddClass("ShowcaseAbilityIcon");
				abIcon.abilityname = abName;

				(function (icon, name) {
					icon.SetPanelEvent("onmouseover", function () {
						$.DispatchEvent("DOTAShowAbilityTooltip", icon, name);
					});
					icon.SetPanelEvent("onmouseout", function () {
						$.DispatchEvent("DOTAHideAbilityTooltip", icon);
					});
				})(abIcon, abName);
			}
		}
	}

	function PickCurrentHero() {
		if (!currentSelectedHero || isLockedIn) return;

		GameEvents.SendCustomGameEventToServer("enfos_lock_in_hero", {
			hero_name: currentSelectedHero.id
		});

		var btn = $("#PickHeroBtn");
		var label = $("#PickHeroBtnLabel");
		if (btn && label) {
			btn.AddClass("LockedIn");
			label.text = "LOCKED IN";
		}
		isLockedIn = true;
	}

	Init();

	return {
		PickCurrentHero: PickCurrentHero,
		SelectHero: SelectHero
	};
})();

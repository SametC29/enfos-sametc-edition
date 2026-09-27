// Enfos Team Survival — SametC Edition: Hero Selection Screen JS

var EnfosHeroSelect = (function () {
	"use strict";

	var currentSelectedHero = null;
	var isLockedIn = false;
	var cardPanels = {};

	var FALLBACK_ROSTER = [
		// Tank
		{ id: "npc_dota_hero_sven", name: "Sven", role: "Tank", primary: "DOTA_ATTRIBUTE_STRENGTH",
		  abilities: [ "bulwark_shield_slam", "bulwark_challenge", "bulwark_iron_guard", "bulwark_fortress", "bulwark_unbreakable" ] },
		{ id: "npc_dota_hero_axe", name: "Axe", role: "Tank", primary: "DOTA_ATTRIBUTE_STRENGTH",
		  abilities: [ "enfos_axe_berserkers_call", "enfos_axe_battle_hunger", "enfos_axe_counter_helix", "enfos_axe_culling_blade", "enfos_axe_blood_armor" ] },
		{ id: "npc_dota_hero_centaur", name: "Centaur", role: "Tank", primary: "DOTA_ATTRIBUTE_STRENGTH",
		  abilities: [ "enfos_centaur_hoof_stomp", "enfos_centaur_double_edge", "enfos_centaur_return", "enfos_centaur_stampede", "enfos_centaur_colossal_hide" ] },
		{ id: "npc_dota_hero_bristleback", name: "Bristleback", role: "Tank", primary: "DOTA_ATTRIBUTE_STRENGTH",
		  abilities: [ "enfos_bb_viscous_nasal_goo", "enfos_bb_quill_spray", "enfos_bb_bristleback", "enfos_bb_warpath", "enfos_bb_hairball" ] },

		// Fighter
		{ id: "npc_dota_hero_juggernaut", name: "Juggernaut", role: "Fighter", primary: "DOTA_ATTRIBUTE_AGILITY",
		  abilities: [ "enfos_juggernaut_blade_fury", "enfos_juggernaut_healing_ward", "enfos_juggernaut_blade_dance", "enfos_juggernaut_omni_slash", "enfos_juggernaut_duelist" ] },
		{ id: "npc_dota_hero_legion_commander", name: "Legion Commander", role: "Fighter", primary: "DOTA_ATTRIBUTE_STRENGTH",
		  abilities: [ "enfos_legion_overwhelming_odds", "enfos_legion_press_the_attack", "enfos_legion_moment_of_courage", "enfos_legion_duel", "enfos_legion_commanders_banner" ] },
		{ id: "npc_dota_hero_skeleton_king", name: "Wraith King", role: "Fighter", primary: "DOTA_ATTRIBUTE_STRENGTH",
		  abilities: [ "enfos_wk_wraithfire_blast", "enfos_wk_vampiric_aura", "enfos_wk_mortal_strike", "enfos_wk_reincarnation", "enfos_wk_skeleton_army" ] },
		{ id: "npc_dota_hero_slark", name: "Slark", role: "Fighter", primary: "DOTA_ATTRIBUTE_AGILITY",
		  abilities: [ "enfos_slark_dark_pact", "enfos_slark_pounce", "enfos_slark_essence_shift", "enfos_slark_shadow_dance", "enfos_slark_fish_bait" ] },

		// Carry
		{ id: "npc_dota_hero_drow_ranger", name: "Drow Ranger", role: "Carry", primary: "DOTA_ATTRIBUTE_AGILITY",
		  abilities: [ "enfos_drow_frost_arrows", "enfos_drow_gust", "enfos_drow_multishot", "enfos_drow_marksmanship", "enfos_drow_precision_aura" ] },
		{ id: "npc_dota_hero_sniper", name: "Sniper", role: "Carry", primary: "DOTA_ATTRIBUTE_AGILITY",
		  abilities: [ "enfos_sniper_shrapnel", "enfos_sniper_headshot", "enfos_sniper_take_aim", "enfos_sniper_assassinate", "enfos_sniper_keen_eye" ] },
		{ id: "npc_dota_hero_phantom_assassin", name: "Phantom Assassin", role: "Carry", primary: "DOTA_ATTRIBUTE_AGILITY",
		  abilities: [ "enfos_pa_stifling_dagger", "enfos_pa_phantom_strike", "enfos_pa_blur", "enfos_pa_coup_de_grace", "enfos_pa_fan_of_knives" ] },
		{ id: "npc_dota_hero_luna", name: "Luna", role: "Carry", primary: "DOTA_ATTRIBUTE_AGILITY",
		  abilities: [ "enfos_luna_lucent_beam", "enfos_luna_moon_glaives", "enfos_luna_lunar_blessing", "enfos_luna_eclipse", "enfos_luna_lunar_orbit" ] },

		// Mage
		{ id: "npc_dota_hero_lina", name: "Lina", role: "Mage", primary: "DOTA_ATTRIBUTE_INTELLECT",
		  abilities: [ "enfos_lina_dragon_slave", "enfos_lina_light_strike_array", "enfos_lina_fiery_soul", "enfos_lina_laguna_blade", "enfos_lina_combustion" ] },
		{ id: "npc_dota_hero_crystal_maiden", name: "Crystal Maiden", role: "Mage", primary: "DOTA_ATTRIBUTE_INTELLECT",
		  abilities: [ "enfos_cm_crystal_nova", "enfos_cm_frostbite", "enfos_cm_arcane_aura", "enfos_cm_freezing_field", "enfos_cm_glacial_mastery" ] },
		{ id: "npc_dota_hero_zuus", name: "Zeus", role: "Mage", primary: "DOTA_ATTRIBUTE_INTELLECT",
		  abilities: [ "enfos_zeus_arc_lightning", "enfos_zeus_lightning_bolt", "enfos_zeus_static_field", "enfos_zeus_thundergods_wrath", "enfos_zeus_heavenly_jump" ] },
		{ id: "npc_dota_hero_nevermore", name: "Shadow Fiend", role: "Mage", primary: "DOTA_ATTRIBUTE_INTELLECT",
		  abilities: [ "enfos_sf_shadowraze", "enfos_sf_necromastery", "enfos_sf_presence_of_the_dark_lord", "enfos_sf_requiem_of_souls", "enfos_sf_feast_of_souls" ] },

		// Support
		{ id: "npc_dota_hero_omniknight", name: "Omniknight", role: "Support", primary: "DOTA_ATTRIBUTE_STRENGTH",
		  abilities: [ "enfos_omni_purification", "enfos_omni_repel", "enfos_omni_degen_aura", "enfos_omni_guardian_angel", "enfos_omni_hammer_of_purity" ] },
		{ id: "npc_dota_hero_dazzle", name: "Dazzle", role: "Support", primary: "DOTA_ATTRIBUTE_INTELLECT",
		  abilities: [ "enfos_dazzle_poison_touch", "enfos_dazzle_shallow_grave", "enfos_dazzle_shadow_wave", "enfos_dazzle_bad_juju", "enfos_dazzle_nothl_weave" ] },
		{ id: "npc_dota_hero_witch_doctor", name: "Witch Doctor", role: "Support", primary: "DOTA_ATTRIBUTE_INTELLECT",
		  abilities: [ "enfos_wd_paralyzing_cask", "enfos_wd_voodoo_restoration", "enfos_wd_maledict", "enfos_wd_death_ward", "enfos_wd_voodoo_switcheroo" ] },
		{ id: "npc_dota_hero_shadow_shaman", name: "Shadow Shaman", role: "Support", primary: "DOTA_ATTRIBUTE_INTELLECT",
		  abilities: [ "enfos_ss_ether_shock", "enfos_ss_hex", "enfos_ss_shackles", "enfos_ss_mass_serpent_ward", "enfos_ss_fowl_play" ] },
	];

	function Init() {
		CustomNetTables.SubscribeNetTableListener("hero_selection_state", OnNetTableChanged);
		GameEvents.Subscribe("game_rules_state_change", OnStateChange);

		PopulateRoster(FALLBACK_ROSTER);
		SelectHero(FALLBACK_ROSTER[0]);

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
		if (key === "state" && data) {
			UpdateUI(data);
		}
	}

	function UpdateUI(data) {
		if (data.remaining_time !== undefined) {
			var timer = $("#SelectTimerLabel");
			if (timer) timer.text = data.remaining_time.toString();
		}

		if (data.roster && data.roster.length > 0) {
			PopulateRoster(data.roster);
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

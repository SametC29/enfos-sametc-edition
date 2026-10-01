// Enfos Team Survival — SametC Edition: Game Setup Screen JS

var EnfosSetup = (function () {
	"use strict";

	var selectedDifficulty = "normal";
	var isDropdownOpen = false;

	function Init() {
		CustomNetTables.SubscribeNetTableListener("game_setup", OnNetTableChanged);
		GameEvents.Subscribe("game_rules_state_change", OnStateChange);

		var state = CustomNetTables.GetTableValue("game_setup", "state");
		if (state) {
			UpdateUI(state);
		} else {
			RenderFallbackSlots();
		}

		CheckVisibility();
	}

	function OnStateChange() {
		CheckVisibility();
	}

	function CheckVisibility() {
		var state = Game.GetState();
		var root = $.GetContextPanel();
		// DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP is 2
		if (state > 2) {
			root.AddClass("GameSetupHidden");
		} else {
			root.RemoveClass("GameSetupHidden");
		}
	}

	function OnNetTableChanged(table, key, data) {
		if (key === "state" && data) {
			UpdateUI(data);
		}
	}

	function UpdateUI(data) {
		if (data.is_setup_complete) {
			CheckVisibility();
			return;
		}

		if (data.difficulty) {
			selectedDifficulty = data.difficulty;
			var diffLabel = $("#SelectedDifficultyText");
			if (diffLabel) {
				diffLabel.text = data.difficulty_name || data.difficulty.toUpperCase();
			}
			var detailLabel = $("#DifficultyDetail");
			if (detailLabel) {
				detailLabel.text = data.detail_label || ("Creature HP x" + (data.hp_multiplier || 1.0).toFixed(2));
			}
		}

		if (data.remaining_time !== undefined) {
			var timer = $("#AutoStartTimer");
			if (timer) {
				timer.text = "Auto-starting in " + data.remaining_time + "s...";
			}
		}

		RenderTeams(data.players || {});
	}

	function RenderTeams(players) {
		var radiantContainer = $("#RadiantSlots");
		var direContainer = $("#DireSlots");
		if (!radiantContainer || !direContainer) return;

		radiantContainer.RemoveAndDeleteChildren();
		direContainer.RemoveAndDeleteChildren();

		var radiantPlayers = [];
		var direPlayers = [];

		for (var pid in players) {
			var p = players[pid];
			var playerId = Number(p.player_id === undefined ? pid : p.player_id);
			var info = Game.GetPlayerInfo(playerId);
			p.player_id = playerId;
			p.name = (info && info.player_name) || Players.GetPlayerName(playerId) || p.name || ($.Localize("#enfos_player") + " " + (playerId + 1));
			if (Number(p.team) === 2) {
				radiantPlayers.push(p);
			} else if (Number(p.team) === 3) {
				direPlayers.push(p);
			}
		}

		// Always show exactly 5 slots per team (matching original Enfos screen)
		for (var r = 0; r < 5; r++) {
			var rSlot = $.CreatePanel("Panel", radiantContainer, "RadiantSlot_" + r);
			rSlot.hittest = false;
			rSlot.AddClass("PlayerSlot");
			if (r < radiantPlayers.length) {
				var rp = radiantPlayers[r];
				var rAvatar = $.CreatePanel("DOTAAvatarImage", rSlot, "");
				rAvatar.hittest = false;
				rAvatar.AddClass("PlayerAvatar");
				rAvatar.steamid = Game.GetPlayerInfo(rp.player_id) ? Game.GetPlayerInfo(rp.player_id).player_steamid : "";
				var rName = $.CreatePanel("Label", rSlot, "");
				rName.hittest = false;
				rName.AddClass("PlayerName");
				rName.text = rp.name;
			} else {
				var rEmpty = $.CreatePanel("Label", rSlot, "");
				rEmpty.hittest = false;
				rEmpty.AddClass("EmptySlotName");
				rEmpty.text = "---";
			}
		}

		for (var d = 0; d < 5; d++) {
			var dSlot = $.CreatePanel("Panel", direContainer, "DireSlot_" + d);
			dSlot.hittest = false;
			dSlot.AddClass("PlayerSlot");
			if (d < direPlayers.length) {
				var dp = direPlayers[d];
				var dAvatar = $.CreatePanel("DOTAAvatarImage", dSlot, "");
				dAvatar.hittest = false;
				dAvatar.AddClass("PlayerAvatar");
				dAvatar.steamid = Game.GetPlayerInfo(dp.player_id) ? Game.GetPlayerInfo(dp.player_id).player_steamid : "";
				var dName = $.CreatePanel("Label", dSlot, "");
				dName.hittest = false;
				dName.AddClass("PlayerName");
				dName.text = dp.name;
			} else {
				var dEmpty = $.CreatePanel("Label", dSlot, "");
				dEmpty.hittest = false;
				dEmpty.AddClass("EmptySlotName");
				dEmpty.text = "---";
			}
		}
	}

	function RenderFallbackSlots() {
		RenderTeams({
			"0": {
				player_id: 0,
				team: 2,
				name: Players.GetPlayerName(0) || "Player 1"
			}
		});
	}

	function ToggleDifficultyDropdown() {
		$.Msg("[SETUP_UI] difficulty dropdown click");
		var menu = $("#DifficultyOptions");
		if (!menu) return;
		isDropdownOpen = !isDropdownOpen;
		if (isDropdownOpen) {
			menu.AddClass("ShowMenu");
		} else {
			menu.RemoveClass("ShowMenu");
		}
	}

	function SelectDifficulty(diffKey) {
		$.Msg("[SETUP_UI] difficulty click: " + diffKey);
		isDropdownOpen = false;
		var menu = $("#DifficultyOptions");
		if (menu) menu.RemoveClass("ShowMenu");

		GameEvents.SendCustomGameEventToServer("enfos_setup_set_difficulty", {
			difficulty: diffKey
		});
	}

	function JoinTeam(teamId) {
		$.Msg("[SETUP_UI] team click: " + teamId);
		GameEvents.SendCustomGameEventToServer("enfos_setup_join_team", {
			team: teamId
		});
	}

	function StartGame() {
		$.Msg("[SETUP_UI] start click");
		GameEvents.SendCustomGameEventToServer("enfos_setup_start_game", {});
	}

	Init();

	return {
		ToggleDifficultyDropdown: ToggleDifficultyDropdown,
		SelectDifficulty: SelectDifficulty,
		JoinTeam: JoinTeam,
		StartGame: StartGame
	};
})();

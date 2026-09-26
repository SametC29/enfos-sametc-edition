"use strict";

var g_LocalPlayerVote = 0;
var g_ActiveVoteData = null;
var g_TimerHandle = null;

function VoteForCard(cardIndex) {
	g_LocalPlayerVote = cardIndex;
	GameEvents.SendCustomGameEventToServer("enfos_cast_boon_vote", {
		card_index: cardIndex
	});
	UpdateVoteButtons();
}

function UpdateVoteButtons() {
	var btn1 = $("#VoteBtn1");
	var btn2 = $("#VoteBtn2");
	var lbl1 = $("#VoteBtnLabel1");
	var lbl2 = $("#VoteBtnLabel2");

	if (btn1 && lbl1) {
		btn1.SetHasClass("Selected", g_LocalPlayerVote === 1);
		lbl1.text = (g_LocalPlayerVote === 1) ? "SEÇİLDİ ✓" : "OY VER";
	}
	if (btn2 && lbl2) {
		btn2.SetHasClass("Selected", g_LocalPlayerVote === 2);
		lbl2.text = (g_LocalPlayerVote === 2) ? "SEÇİLDİ ✓" : "OY VER";
	}
}

function OnBoonStateChanged(table_name, key, data) {
	var localPlayerId = Players.GetLocalPlayer();
	var localTeam = Players.GetTeam(localPlayerId);
	var expectedKey = "team_" + localTeam;

	if (key !== expectedKey || !data) return;

	var dialog = $("#BoonVoteDialog");
	if (!dialog) return;

	var activeVote = data.active_vote;
	if (!activeVote) {
		dialog.AddClass("Hidden");
		g_ActiveVoteData = null;
		g_LocalPlayerVote = 0;
		return;
	}

	g_ActiveVoteData = activeVote;
	dialog.RemoveClass("Hidden");

	// Update Card 1
	var c1Id = activeVote.card1_id;
	$("#Card1Title").text = $.Localize("#enfos_boon_" + c1Id);
	$("#Card1Desc").text = $.Localize("#enfos_boon_" + c1Id + "_desc");
	var c1Stacks = (data.stacks && data.stacks[c1Id]) || 0;
	$("#Card1Stacks").text = "Mevcut: " + c1Stacks + " / 3";

	// Update Card 2
	var c2Id = activeVote.card2_id;
	$("#Card2Title").text = $.Localize("#enfos_boon_" + c2Id);
	$("#Card2Desc").text = $.Localize("#enfos_boon_" + c2Id + "_desc");
	var c2Stacks = (data.stacks && data.stacks[c2Id]) || 0;
	$("#Card2Stacks").text = "Mevcut: " + c2Stacks + " / 3";

	// Tally votes
	var votes1 = 0;
	var votes2 = 0;
	if (activeVote.votes) {
		for (var pid in activeVote.votes) {
			var choice = activeVote.votes[pid];
			if (choice === 1) votes1++;
			else if (choice === 2) votes2++;
			if (Number(pid) === localPlayerId) {
				g_LocalPlayerVote = choice;
			}
		}
	}

	$("#Card1VoteTally").text = votes1 + " Oy";
	$("#Card2VoteTally").text = votes2 + " Oy";
	UpdateVoteButtons();
}

(function() {
	CustomNetTables.SubscribeNetTableListener("boon_state", OnBoonStateChanged);

	var localPlayerId = Players.GetLocalPlayer();
	var localTeam = Players.GetTeam(localPlayerId);
	var initialData = CustomNetTables.GetTableValue("boon_state", "team_" + localTeam);
	if (initialData) {
		OnBoonStateChanged("boon_state", "team_" + localTeam, initialData);
	}
})();

"use strict";

var isManuallyOpen = false;
var isEngineOpen = false;

function ToggleScoreboard() {
    isManuallyOpen = !isManuallyOpen;
    var container = $("#ScoreboardContainer");
    if (container) {
        container.SetHasClass("Visible", isManuallyOpen);
    }
}

function CloseScoreboard() {
    isManuallyOpen = false;
    var container = $("#ScoreboardContainer");
    if (container) {
        container.SetHasClass("Visible", false);
    }
}

// Allow external calls (e.g. from top bar button)
if (typeof GameUI !== "undefined" && GameUI.CustomUIConfig) {
    GameUI.CustomUIConfig().toggle_custom_scoreboard = ToggleScoreboard;
}

(function () {
    var playerRows = {};

    function formatNumber(num) {
        var n = Math.floor(Number(num) || 0);
        return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }

    function GetOrCreatePlayerRow(parent, playerId) {
        if (playerRows[playerId]) { playerRows[playerId].row.SetParent(parent); return playerRows[playerId]; }

        var row = $.CreatePanel("Panel", parent, "PlayerRow_" + playerId);
        row.AddClass("PlayerRow");

        // 1. Hero Icon with Level Badge
        var heroContainer = $.CreatePanel("Panel", row, "HeroContainer_" + playerId);
        heroContainer.AddClass("Col_Hero");
        var heroImg = $.CreatePanel("DOTAHeroImage", heroContainer, "HeroImg_" + playerId);
        heroImg.AddClass("HeroPortraitImg");
        heroImg.heroimagestyle = "landscape";

        // 2. Player Name & Subtitle
        var playerCol = $.CreatePanel("Panel", row, "PlayerCol_" + playerId);
        playerCol.AddClass("Col_Player");
        var nameLabel = $.CreatePanel("Label", playerCol, "PlayerName_" + playerId);
        nameLabel.AddClass("PlayerNameText");
        var heroSub = $.CreatePanel("Label", playerCol, "HeroSub_" + playerId);
        heroSub.AddClass("HeroSubText");

        // 3. Level (SV)
        var levelLabel = $.CreatePanel("Label", row, "Level_" + playerId);
        levelLabel.AddClass("Col_Level");

        // 4. Total Damage Dealt (Verilen Toplam Hasar + Damage Bar)
        var damageCol = $.CreatePanel("Panel", row, "DamageCol_" + playerId);
        damageCol.AddClass("Col_Damage");
        var damageVal = $.CreatePanel("Label", damageCol, "DamageVal_" + playerId);
        damageVal.AddClass("DamageNumberText");

        var damageBarTrack = $.CreatePanel("Panel", damageCol, "DamageTrack_" + playerId);
        damageBarTrack.AddClass("DamageBarTrack");
        var damageBarFill = $.CreatePanel("Panel", damageBarTrack, "DamageFill_" + playerId);
        damageBarFill.AddClass("DamageBarFill");
        var damagePctLabel = $.CreatePanel("Label", damageBarTrack, "DamagePct_" + playerId);
        damagePctLabel.AddClass("DamagePctText");

        // 5. Enemies Killed (Öldürülen Düşman / RET)
        var killsCol = $.CreatePanel("Panel", row, "KillsCol_" + playerId);
        killsCol.AddClass("Col_Kills");
        var killsLabel = $.CreatePanel("Label", killsCol, "Kills_" + playerId);
        killsLabel.AddClass("KillsNumberText");

        // 6. Gold Earned (Kazanılan Altın)
        var goldCol = $.CreatePanel("Panel", row, "GoldCol_" + playerId);
        goldCol.AddClass("Col_Gold");
        var goldLabel = $.CreatePanel("Label", goldCol, "Gold_" + playerId);
        goldLabel.AddClass("GoldNumberText");

        // 7. Lumber (Odun)
        var lumberCol = $.CreatePanel("Panel", row, "LumberCol_" + playerId);
        lumberCol.AddClass("Col_Lumber");
        var lumberLabel = $.CreatePanel("Label", lumberCol, "Lumber_" + playerId);
        lumberLabel.AddClass("LumberNumberText");

        // 8. Items Container (6 Slots)
        var itemsContainer = $.CreatePanel("Panel", row, "Items_" + playerId);
        itemsContainer.AddClass("Col_Items");
        var itemPanels = [];
        for (var i = 0; i < 6; i++) {
            var itemImg = $.CreatePanel("DOTAItemImage", itemsContainer, "Item_" + playerId + "_" + i);
            itemImg.AddClass("ScoreboardItemSlot");
            (function (img, slotIndex, pid) {
                img.SetPanelEvent("onmouseover", function () {
                    var heroIdx = (typeof Players !== "undefined" && Players.GetPlayerHeroEntityIndex) ? Players.GetPlayerHeroEntityIndex(pid) : null;
                    if (heroIdx && typeof Entities !== "undefined" && Entities.GetItemInSlot) {
                        var itemEnt = Entities.GetItemInSlot(heroIdx, slotIndex);
                        if (itemEnt && itemEnt !== -1 && Abilities.GetAbilityName) {
                            var itemName = Abilities.GetAbilityName(itemEnt);
                            if (itemName && typeof $.DispatchEvent === "function") {
                                $.DispatchEvent("DOTAShowAbilityTooltip", img, itemName);
                            }
                        }
                    }
                });
                img.SetPanelEvent("onmouseout", function () {
                    if (typeof $.DispatchEvent === "function") {
                        $.DispatchEvent("DOTAHideAbilityTooltip");
                    }
                });
            })(itemImg, i, playerId);
            itemPanels.push(itemImg);
        }

        playerRows[playerId] = {
            row: row,
            heroImg: heroImg,
            nameLabel: nameLabel,
            heroSub: heroSub,
            levelLabel: levelLabel,
            damageVal: damageVal,
            damageBarFill: damageBarFill,
            damagePctLabel: damagePctLabel,
            killsLabel: killsLabel,
            goldLabel: goldLabel,
            lumberLabel: lumberLabel,
            itemPanels: itemPanels
        };

        return playerRows[playerId];
    }

    function UpdateScoreboard() {
        if (typeof Players === "undefined") return;

        var localPid = Players.GetLocalPlayer ? Players.GetLocalPlayer() : 0;
        var radList = $("#RadiantPlayersList");
        var direList = $("#DirePlayersList");

        var allPids = [];
        if (typeof Game !== "undefined" && Game.GetAllPlayerIDs) {
            allPids = Game.GetAllPlayerIDs();
        } else {
            for (var p = 0; p < 24; p++) {
                if (Players.IsValidPlayerID && Players.IsValidPlayerID(p)) {
                    allPids.push(p);
                }
            }
        }

        // Calculate team totals first
        var teamDamage = { 2: 0, 3: 0 };
        var teamKills = { 2: 0, 3: 0 };

        for (var i = 0; i < allPids.length; i++) {
            var pId = allPids[i];
            var tm = Players.GetTeam ? Players.GetTeam(pId) : 2;
            var st = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("player_stats", String(pId)) : null;
            var d = (st && st.damage_dealt != null) ? Number(st.damage_dealt) : 0;
            var k = (st && st.kills != null) ? Number(st.kills) : ((Players.GetLastHits) ? Players.GetLastHits(pId) : 0);
            if (teamDamage[tm] !== undefined) teamDamage[tm] += d;
            if (teamKills[tm] !== undefined) teamKills[tm] += k;
        }

        // Update Team Summary Labels
        var radDmgLbl = $("#RadiantTotalDamage");
        if (radDmgLbl) radDmgLbl.text = ($.Localize("#enfos_score_team_damage")+": ") + formatNumber(teamDamage[2]);
        var radKillsLbl = $("#RadiantTotalKills");
        if (radKillsLbl) radKillsLbl.text = ($.Localize("#enfos_score_team_kills")+": ") + formatNumber(teamKills[2]);

        var direDmgLbl = $("#DireTotalDamage");
        if (direDmgLbl) direDmgLbl.text = ($.Localize("#enfos_score_team_damage")+": ") + formatNumber(teamDamage[3]);
        var direKillsLbl = $("#DireTotalKills");
        if (direKillsLbl) direKillsLbl.text = ($.Localize("#enfos_score_team_kills")+": ") + formatNumber(teamKills[3]);

        // Populate Player Rows
        for (var idx = 0; idx < allPids.length; idx++) {
            var pid = allPids[idx];
            var team = Players.GetTeam ? Players.GetTeam(pid) : 2;
            if (team !== 2 && team !== 3) continue;
            var parent = (team === 2) ? radList : direList;
            if (!parent) continue;

            var r = GetOrCreatePlayerRow(parent, pid);
            if (!r) continue;

            r.row.SetHasClass("IsLocalPlayer", pid === localPid);

            var heroName = Players.GetSelectedHeroName ? Players.GetSelectedHeroName(pid) : "";
            var heroIdx = Players.GetPlayerHeroEntityIndex ? Players.GetPlayerHeroEntityIndex(pid) : null;
            if (heroIdx && (!heroName || heroName === "")) {
                heroName = (typeof Entities !== "undefined" && Entities.GetUnitName) ? Entities.GetUnitName(heroIdx) : "";
            }
            if (heroName) {
                r.heroImg.heroname = heroName;
                var cleanHeroName = heroName.replace("npc_dota_hero_", "");
                r.heroSub.text = cleanHeroName.toUpperCase();
            }

            var pName = Players.GetPlayerName ? Players.GetPlayerName(pid) : ("Player " + pid);
            r.nameLabel.text = pName || ("Player " + pid);

            var stats = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("player_stats", String(pid)) : null;
            var econ = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("economy_state", String(pid)) : null;

            // Level (SV)
            var level = (heroIdx && typeof Entities !== "undefined" && Entities.GetLevel) ? Entities.GetLevel(heroIdx) : (stats && stats.level ? stats.level : 1);
            r.levelLabel.text = String(level);

            // Damage Dealt & Percentage Bar
            var dmg = (stats && stats.damage_dealt != null) ? stats.damage_dealt : 0;
            r.damageVal.text = formatNumber(dmg);

            var totalTmDmg = teamDamage[team] || 1;
            var pct = totalTmDmg > 0 ? Math.min(100, Math.max(0, Math.round((dmg / totalTmDmg) * 100))) : 0;
            r.damageBarFill.style.width = pct + "%";
            r.damagePctLabel.text = pct + "%";

            // Kills (RET)
            var kills = (stats && stats.kills != null) ? stats.kills : (Players.GetLastHits ? Players.GetLastHits(pid) : 0);
            r.killsLabel.text = formatNumber(kills);

            // Gold
            var gold = (stats && stats.gold_earned != null) ? stats.gold_earned : (Players.GetTotalEarnedGold ? Players.GetTotalEarnedGold(pid) : 0);
            r.goldLabel.text = formatNumber(gold);

            // Lumber
            var lumber = (econ && econ.lumber != null) ? econ.lumber : (stats && stats.lumber != null ? stats.lumber : 0);
            r.lumberLabel.text = formatNumber(lumber);

            // Items (6 Slots)
            for (var s = 0; s < 6; s++) {
                var itemPanel = r.itemPanels[s];
                if (!itemPanel) continue;
                var itemEnt = (heroIdx && typeof Entities !== "undefined" && Entities.GetItemInSlot) ? Entities.GetItemInSlot(heroIdx, s) : null;
                if (itemEnt && itemEnt !== -1 && Abilities.GetAbilityName) {
                    var itemName = Abilities.GetAbilityName(itemEnt);
                    itemPanel.itemname = itemName || "";
                    itemPanel.SetHasClass("HasItem", !!itemName && itemName !== "");
                } else {
                    itemPanel.itemname = "";
                    itemPanel.SetHasClass("HasItem", false);
                }
            }
        }

        // Update Team Life in Header
        if (typeof CustomNetTables !== "undefined") {
            var life = CustomNetTables.GetTableValue("wave_info", "team_life");
            if (life) {
                var radLife = life.goodguys !== undefined ? life.goodguys : 100;
                var direLife = life.badguys !== undefined ? life.badguys : 100;
                var radLifeLbl = $("#RadiantScoreboardLife");
                if (radLifeLbl) radLifeLbl.text = radLife + " / 100";
                var direLifeLbl = $("#DireScoreboardLife");
                if (direLifeLbl) direLifeLbl.text = direLife + " / 100";
            }
        }
    }

    // Engine FlyoutScoreboard contract, verified against Valve's installed sample.
    $.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), function(visible) {
        isEngineOpen = visible;
        $("#ScoreboardContainer").SetHasClass("Visible", visible || isManuallyOpen);
        if (visible) UpdateScoreboard();
    });

    function PeriodicDataTick() {
        UpdateScoreboard();
        if ($.Schedule) {
            $.Schedule(0.5, PeriodicDataTick);
        }
    }

    if (typeof CustomNetTables !== "undefined") {
        CustomNetTables.SubscribeNetTableListener("player_stats", UpdateScoreboard);
        CustomNetTables.SubscribeNetTableListener("wave_info", UpdateScoreboard);
        CustomNetTables.SubscribeNetTableListener("economy_state", UpdateScoreboard);
    }

    UpdateScoreboard();

    PeriodicDataTick();
})();

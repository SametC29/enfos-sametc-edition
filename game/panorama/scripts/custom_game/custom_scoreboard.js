"use strict";

(function () {
    var playerRows = {};

    function formatNumber(num) {
        var n = Math.floor(Number(num) || 0);
        return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }

    function GetOrCreatePlayerRow(parent, playerId) {
        if (playerRows[playerId]) return playerRows[playerId];

        var row = $.CreatePanel("Panel", parent, "PlayerRow_" + playerId);
        row.AddClass("PlayerRow");

        // 1. Hero Icon
        var heroImg = $.CreatePanel("DOTAHeroImage", row, "HeroImg_" + playerId);
        heroImg.AddClass("ScoreCol_Hero");
        heroImg.heroimagestyle = "landscape";

        // 2. Player Name
        var nameLabel = $.CreatePanel("Label", row, "PlayerName_" + playerId);
        nameLabel.AddClass("ScoreCol_Player");

        // 3. Level (SV)
        var levelLabel = $.CreatePanel("Label", row, "Level_" + playerId);
        levelLabel.AddClass("ScoreCol_Level");

        // 4. Total Damage Dealt (Verilen Toplam Hasar)
        var damageLabel = $.CreatePanel("Label", row, "Damage_" + playerId);
        damageLabel.AddClass("ScoreCol_Damage");

        // 5. Enemies Killed (Öldürülen Düşman / RET)
        var killsLabel = $.CreatePanel("Label", row, "Kills_" + playerId);
        killsLabel.AddClass("ScoreCol_Kills");

        // 6. Gold Earned (Kazanılan Altın)
        var goldLabel = $.CreatePanel("Label", row, "Gold_" + playerId);
        goldLabel.AddClass("ScoreCol_Gold");

        // 7. Lumber (Odun)
        var lumberLabel = $.CreatePanel("Label", row, "Lumber_" + playerId);
        lumberLabel.AddClass("ScoreCol_Lumber");

        // 8. Items Container (6 Slots)
        var itemsContainer = $.CreatePanel("Panel", row, "Items_" + playerId);
        itemsContainer.AddClass("ScoreCol_Items");
        var itemPanels = [];
        for (var i = 0; i < 6; i++) {
            var itemImg = $.CreatePanel("DOTAItemImage", itemsContainer, "Item_" + playerId + "_" + i);
            itemImg.AddClass("ScoreboardItemSlot");
            (function (img, slotIndex, pid) {
                img.SetPanelEvent("onmouseover", function () {
                    var heroIdx = (typeof Players !== "undefined" && Players.GetPlayerHeroEntityIndex) ? Players.GetPlayerHeroEntityIndex(pid) : null;
                    if (heroIdx && typeof Entities !== "undefined" && Entities.GetItemInSlot) {
                        var itemEnt = Entities.GetItemInSlot(heroIdx, slotIndex);
                        if (itemEnt && itemEnt !== -1 && Entities.GetAbilityName) {
                            var itemName = Entities.GetAbilityName(itemEnt);
                            if (itemName) {
                                $.DispatchEvent("DOTAShowAbilityTooltip", img, itemName);
                            }
                        }
                    }
                });
                img.SetPanelEvent("onmouseout", function () {
                    $.DispatchEvent("DOTAHideAbilityTooltip");
                });
            })(itemImg, i, playerId);
            itemPanels.push(itemImg);
        }

        playerRows[playerId] = {
            row: row,
            heroImg: heroImg,
            nameLabel: nameLabel,
            levelLabel: levelLabel,
            damageLabel: damageLabel,
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

        for (var idx = 0; idx < allPids.length; idx++) {
            var pid = allPids[idx];
            var team = Players.GetTeam ? Players.GetTeam(pid) : 2;
            var parent = (team === 2) ? radList : direList;
            if (!parent) continue;

            var r = GetOrCreatePlayerRow(parent, pid);
            if (!r) continue;

            // Highlight local player
            r.row.SetHasClass("IsLocalPlayer", pid === localPid);

            // Hero Name & Icon
            var heroName = Players.GetSelectedHeroName ? Players.GetSelectedHeroName(pid) : "";
            var heroIdx = Players.GetPlayerHeroEntityIndex ? Players.GetPlayerHeroEntityIndex(pid) : null;
            if (heroIdx && (!heroName || heroName === "")) {
                heroName = (typeof Entities !== "undefined" && Entities.GetUnitName) ? Entities.GetUnitName(heroIdx) : "";
            }
            if (heroName) {
                r.heroImg.heroname = heroName;
            }

            // Player Name
            var pName = Players.GetPlayerName ? Players.GetPlayerName(pid) : ("Player " + pid);
            r.nameLabel.text = pName || ("Player " + pid);

            // Fetch authoritative stats
            var stats = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("player_stats", String(pid)) : null;
            var econ = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("economy_state", String(pid)) : null;

            // SV (Level)
            var level = (heroIdx && typeof Entities !== "undefined" && Entities.GetLevel) ? Entities.GetLevel(heroIdx) : (stats && stats.level ? stats.level : 1);
            r.levelLabel.text = String(level);

            // Verilen Toplam Hasar (Total Damage Dealt)
            var dmg = (stats && stats.damage_dealt != null) ? stats.damage_dealt : 0;
            r.damageLabel.text = formatNumber(dmg);

            // Öldürülen Düşman (Enemies Killed / Retribution)
            var kills = (stats && stats.kills != null) ? stats.kills : (Players.GetLastHits ? Players.GetLastHits(pid) : 0);
            r.killsLabel.text = formatNumber(kills);

            // Kazanılan Altın (Gold Earned)
            var gold = (stats && stats.gold_earned != null) ? stats.gold_earned : (Players.GetTotalEarnedGold ? Players.GetTotalEarnedGold(pid) : 0);
            r.goldLabel.text = formatNumber(gold);

            // Odun (Lumber)
            var lumber = (econ && econ.lumber != null) ? econ.lumber : (stats && stats.lumber != null ? stats.lumber : 0);
            r.lumberLabel.text = formatNumber(lumber);

            // Items (6 Slots)
            for (var s = 0; s < 6; s++) {
                var itemPanel = r.itemPanels[s];
                if (!itemPanel) continue;
                var itemEnt = (heroIdx && typeof Entities !== "undefined" && Entities.GetItemInSlot) ? Entities.GetItemInSlot(heroIdx, s) : null;
                if (itemEnt && itemEnt !== -1 && Entities.GetAbilityName) {
                    var itemName = Entities.GetAbilityName(itemEnt);
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

        if ($.Schedule) {
            $.Schedule(0.5, UpdateScoreboard);
        }
    }

    if (typeof CustomNetTables !== "undefined") {
        CustomNetTables.SubscribeNetTableListener("player_stats", UpdateScoreboard);
        CustomNetTables.SubscribeNetTableListener("wave_info", UpdateScoreboard);
    }

    UpdateScoreboard();
})();

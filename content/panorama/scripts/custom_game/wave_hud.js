var currentHeroInnate = "";

function ToggleGuide() {
    GameEvents.SendEventClientSide("enfos_toggle_welcome_guide", {});
}

function OnPassiveMouseOver() {
    if (!currentHeroInnate || currentHeroInnate === "") return;
    var panel = $("#EnfosPassiveHud");
    if (panel && typeof $.DispatchEvent === "function") {
        $.DispatchEvent("DOTAShowAbilityTooltip", panel, currentHeroInnate);
    }
}

function OnPassiveMouseOut() {
    if (typeof $.DispatchEvent === "function") {
        $.DispatchEvent("DOTAHideAbilityTooltip");
    }
}

(function () {
    var HERO_INNATES = {
        npc_dota_hero_sven: "bulwark_unbreakable",
        npc_dota_hero_juggernaut: "enfos_juggernaut_duelist",
        npc_dota_hero_drow_ranger: "enfos_drow_precision_aura",
        npc_dota_hero_lina: "enfos_lina_combustion",
        npc_dota_hero_omniknight: "enfos_omni_hammer_of_purity",
        npc_dota_hero_axe: "enfos_axe_blood_armor",
        npc_dota_hero_legion_commander: "enfos_legion_commanders_banner",
        npc_dota_hero_sniper: "enfos_sniper_keen_eye",
        npc_dota_hero_crystal_maiden: "enfos_cm_glacial_mastery",
        npc_dota_hero_dazzle: "enfos_dazzle_nothl_weave",
        npc_dota_hero_centaur: "enfos_centaur_colossal_hide",
        npc_dota_hero_skeleton_king: "enfos_wk_skeleton_army",
        npc_dota_hero_phantom_assassin: "enfos_pa_fan_of_knives",
        npc_dota_hero_zuus: "enfos_zeus_heavenly_jump",
        npc_dota_hero_witch_doctor: "enfos_wd_voodoo_switcheroo",
        npc_dota_hero_bristleback: "enfos_bb_hairball",
        npc_dota_hero_slark: "enfos_slark_fish_bait",
        npc_dota_hero_luna: "enfos_luna_lunar_orbit",
        npc_dota_hero_nevermore: "enfos_sf_feast_of_souls",
        npc_dota_hero_shadow_shaman: "enfos_ss_fowl_play",
        npc_dota_hero_tidehunter: "enfos_tide_colossal_presence",
        npc_dota_hero_dragon_knight: "enfos_dk_wyrm_vigor",
        npc_dota_hero_pudge: "enfos_pudge_meat_shield",
        npc_dota_hero_abyssal_underlord: "enfos_underlord_abyssal_carapace",
        npc_dota_hero_ursa: "enfos_ursa_ursa_minor",
        npc_dota_hero_monkey_king: "enfos_mk_mischief",
        npc_dota_hero_troll_warlord: "enfos_troll_rampage",
        npc_dota_hero_chaos_knight: "enfos_ck_entropy",
        npc_dota_hero_antimage: "enfos_am_spellbreaker",
        npc_dota_hero_faceless_void: "enfos_void_backtrack",
        npc_dota_hero_medusa: "enfos_medusa_gorgon_gaze",
        npc_dota_hero_terrorblade: "enfos_tb_demon_zeal",
        npc_dota_hero_storm_spirit: "enfos_storm_galvanic_core",
        npc_dota_hero_leshrac: "enfos_leshrac_defilement",
        npc_dota_hero_invoker: "enfos_invoker_alacrity",
        npc_dota_hero_puck: "enfos_puck_faerie_magic",
        npc_dota_hero_lion: "enfos_lion_demon_soul",
        npc_dota_hero_jakiro: "enfos_jakiro_double_trouble",
        npc_dota_hero_vengefulspirit: "enfos_vs_retribution",
        npc_dota_hero_lich: "enfos_lich_ice_aura"
    };

    // Hide native Dota 2 top bar clutter (Day/Night sun/moon, default timer, 0-0 scores)
    function HideNativeTopBarClutter() {
        var hudRoot = ($.GetContextPanel && typeof $.GetContextPanel === "function") ? $.GetContextPanel().GetParent() : null;
        while (hudRoot && hudRoot.GetParent()) {
            hudRoot = hudRoot.GetParent();
        }
        if (!hudRoot) return;

        var nativeElementsToCollapse = [
            "TimeOfDay",
            "TimeOfDayBG",
            "DayGlow",
            "NightGlow",
            "GameTime",
            "TopBarRadiantScore",
            "TopBarDireScore",
            "RadiantScore",
            "DireScore",
            "RadiantScoreContainer",
            "DireScoreContainer"
        ];

        nativeElementsToCollapse.forEach(function (id) {
            var el = hudRoot.FindChildTraverse(id);
            if (el) {
                el.style.visibility = "collapse";
            }
        });
    }

    if ($.Schedule) {
        HideNativeTopBarClutter();
        $.Schedule(1.0, HideNativeTopBarClutter);
        $.Schedule(3.0, HideNativeTopBarClutter);
    }

    function formatTime(seconds) {
        var s = Math.max(0, Math.floor(seconds || 0));
        var m = Math.floor(s / 60);
        var rem = s % 60;
        return (m < 10 ? "0" : "") + m + ":" + (rem < 10 ? "0" : "") + rem;
    }

    function update() {
        var s = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("wave_info", "status") : null;
        var life = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("wave_info", "team_life") : null;

        // Update Wave Title & Timer
        if (s) {
            var waveNum = s.next_wave || s.current_wave || 1;
            var maxWaves = s.max_waves || 60;
            var isBoss = Boolean(s.is_boss);

            var titleLabel = $("#TopWaveTitle");
            var badgePanel = $("#WaveCenterBadge");
            if (titleLabel) {
                if (isBoss) {
                    titleLabel.text = "BOSS: " + $.Localize("#enfos_sametc_wave") + " " + waveNum;
                    if (badgePanel) badgePanel.SetHasClass("IsBossWave", true);
                } else {
                    titleLabel.text = $.Localize("#enfos_sametc_wave") + " " + waveNum + " / " + maxWaves;
                    if (badgePanel) badgePanel.SetHasClass("IsBossWave", false);
                }
            }

            var timerLabel = $("#TopWaveTimer");
            if (timerLabel) {
                var timerSec = Number(s.state_timer) || 0;
                if (timerSec > 0 && s.state !== "VICTORY") {
                    timerLabel.text = formatTime(timerSec);
                } else if (s.state === "VICTORY") {
                    timerLabel.text = $.Localize("#enfos_wave_state_victory");
                } else {
                    timerLabel.text = "00:00";
                }
            }
        }

        // Update Team Life (Starts at 100)
        if (life) {
            var radLife = Math.max(0, Number(life.goodguys !== undefined ? life.goodguys : 100));
            var direLife = Math.max(0, Number(life.badguys !== undefined ? life.badguys : 100));

            var radNum = $("#RadiantLifeNumber");
            var radFill = $("#RadiantLifeBarFill");
            var radBox = $("#RadiantLifeContainer");
            if (radNum) radNum.text = radLife;
            if (radFill) radFill.style.width = Math.min(100, radLife) + "%";
            if (radBox) radBox.SetHasClass("LowLife", radLife <= 25);

            var direNum = $("#DireLifeNumber");
            var direFill = $("#DireLifeBarFill");
            var direBox = $("#DireLifeContainer");
            if (direNum) direNum.text = direLife;
            if (direFill) direFill.style.width = Math.min(100, direLife) + "%";
            if (direBox) direBox.SetHasClass("LowLife", direLife <= 25);
        }
    }

    // Update Bottom-Left SV / RET display
    function UpdateEnfosQuickStats() {
        var localPlayerId = (typeof Players !== "undefined" && Players.GetLocalPlayer) ? Players.GetLocalPlayer() : 0;
        var heroIdx = (typeof Players !== "undefined" && Players.GetPlayerHeroEntityIndex) ? Players.GetPlayerHeroEntityIndex(localPlayerId) : null;
        var level = (heroIdx && typeof Entities !== "undefined" && Entities.GetLevel) ? Entities.GetLevel(heroIdx) : 1;

        var stats = (typeof CustomNetTables !== "undefined") ? CustomNetTables.GetTableValue("player_stats", String(localPlayerId)) : null;
        var retKills = (stats && stats.kills != null) ? stats.kills : ((typeof Players !== "undefined" && Players.GetLastHits) ? Players.GetLastHits(localPlayerId) : 0);

        var svLabel = $("#EnfosQuickStatSV");
        if (svLabel) svLabel.text = String(level);
        var retLabel = $("#EnfosQuickStatRET");
        if (retLabel) retLabel.text = String(retKills);

        // Augment / replace native Dota #quickstats
        var hudRoot = ($.GetContextPanel && typeof $.GetContextPanel === "function") ? $.GetContextPanel().GetParent() : null;
        while (hudRoot && hudRoot.GetParent()) {
            hudRoot = hudRoot.GetParent();
        }
        if (hudRoot) {
            var quickstats = hudRoot.FindChildTraverse("quickstats");
            if (quickstats) {
                var kda = quickstats.FindChildTraverse("KDAContainer");
                if (kda) kda.style.visibility = "collapse";
                var lasthit = quickstats.FindChildTraverse("LastHitContainer");
                if (lasthit) lasthit.style.visibility = "collapse";
                var indStats = quickstats.FindChildTraverse("IndividualStats");
                if (indStats) indStats.style.visibility = "collapse";

                var enfosStats = quickstats.FindChildTraverse("EnfosQuickStats");
                if (!enfosStats && $.CreatePanel) {
                    enfosStats = $.CreatePanel("Panel", quickstats, "EnfosQuickStats");
                    enfosStats.style.flowChildren = "down";
                    enfosStats.style.verticalAlign = "center";
                    enfosStats.style.horizontalAlign = "center";
                    enfosStats.style.padding = "2px 6px";

                    var rowSV = $.CreatePanel("Panel", enfosStats, "RowSV");
                    rowSV.style.flowChildren = "right";
                    var lblSVTitle = $.CreatePanel("Label", rowSV, "");
                    lblSVTitle.text = "SV: ";
                    lblSVTitle.style.color = "#64b5f6";
                    lblSVTitle.style.fontSize = "13px";
                    lblSVTitle.style.fontWeight = "bold";

                    var lblSVVal = $.CreatePanel("Label", rowSV, "EnfosValSV");
                    lblSVVal.text = "1";
                    lblSVVal.style.color = "#ffffff";
                    lblSVVal.style.fontSize = "13px";
                    lblSVVal.style.fontWeight = "bold";

                    var rowRET = $.CreatePanel("Panel", enfosStats, "RowRET");
                    rowRET.style.flowChildren = "right";
                    rowRET.style.marginTop = "2px";
                    var lblRETTitle = $.CreatePanel("Label", rowRET, "");
                    lblRETTitle.text = "RET: ";
                    lblRETTitle.style.color = "#f6c177";
                    lblRETTitle.style.fontSize = "13px";
                    lblRETTitle.style.fontWeight = "bold";

                    var lblRETVal = $.CreatePanel("Label", rowRET, "EnfosValRET");
                    lblRETVal.text = "0";
                    lblRETVal.style.color = "#ffffff";
                    lblRETVal.style.fontSize = "13px";
                    lblRETVal.style.fontWeight = "bold";
                }
                if (enfosStats) {
                    var vSV = enfosStats.FindChildTraverse("EnfosValSV");
                    if (vSV) vSV.text = String(level);
                    var vRET = enfosStats.FindChildTraverse("EnfosValRET");
                    if (vRET) vRET.text = String(retKills);

                    var fallback = $("#EnfosQuickStatsPanel");
                    if (fallback) fallback.style.visibility = "collapse";
                }
            }
        }
    }

    // Update Hero Passive / Innate Skill UI
    function UpdateInnatePassiveDisplay() {
        var localPlayerId = (typeof Players !== "undefined" && Players.GetLocalPlayer) ? Players.GetLocalPlayer() : 0;
        var heroIdx = (typeof Players !== "undefined" && Players.GetPlayerHeroEntityIndex) ? Players.GetPlayerHeroEntityIndex(localPlayerId) : null;
        var heroName = "";
        if (heroIdx && typeof Entities !== "undefined" && Entities.GetUnitName) {
            heroName = Entities.GetUnitName(heroIdx);
        } else if (typeof Players !== "undefined" && Players.GetSelectedHeroName) {
            heroName = Players.GetSelectedHeroName(localPlayerId);
        }

        var innate = HERO_INNATES[heroName] || "";
        currentHeroInnate = innate;

        var passivePanel = $("#EnfosPassiveHud");
        var passiveImg = $("#EnfosPassiveAbilityImage");
        if (passivePanel && passiveImg) {
            if (innate && innate !== "") {
                passiveImg.abilityname = innate;
                passivePanel.style.visibility = "visible";
            } else {
                passivePanel.style.visibility = "collapse";
            }
        }

        // Also check native Dota #InnateDisplay
        var hudRoot = ($.GetContextPanel && typeof $.GetContextPanel === "function") ? $.GetContextPanel().GetParent() : null;
        while (hudRoot && hudRoot.GetParent()) {
            hudRoot = hudRoot.GetParent();
        }
        if (hudRoot && innate) {
            var innateDisplay = hudRoot.FindChildTraverse("InnateDisplay");
            if (innateDisplay) {
                innateDisplay.RemoveClass("HasNothing");
                innateDisplay.style.visibility = "visible";
                var icon = innateDisplay.FindChildTraverse("InnateIcon");
                if (icon) {
                    icon.abilityname = innate;
                    (function (ic, inName) {
                        ic.SetPanelEvent("onmouseover", function () {
                            if (typeof $.DispatchEvent === "function") $.DispatchEvent("DOTAShowAbilityTooltip", ic, inName);
                        });
                        ic.SetPanelEvent("onmouseout", function () {
                            if (typeof $.DispatchEvent === "function") $.DispatchEvent("DOTAHideAbilityTooltip");
                        });
                    })(icon, innate);
                }
            }
        }
    }

    function PeriodicHudTick() {
        UpdateEnfosQuickStats();
        UpdateInnatePassiveDisplay();
        if ($.Schedule) {
            $.Schedule(0.5, PeriodicHudTick);
        }
    }

    if (typeof CustomNetTables !== "undefined") {
        CustomNetTables.SubscribeNetTableListener("wave_info", update);
        CustomNetTables.SubscribeNetTableListener("player_stats", UpdateEnfosQuickStats);
    }

    var bossTimer = null;
    if (typeof GameEvents !== "undefined" && GameEvents.Subscribe) {
        GameEvents.Subscribe("enfos_boss_incoming", function (data) {
            if (!data) return;
            var rawName = data.boss_name || "Boss";
            var bossName = $.Localize("#" + rawName);
            if (bossName === "#" + rawName) bossName = $.Localize(rawName);
            var wave = data.wave || "";
            var panel = $("#BossAlertPanel");
            var text = $("#BossAlertText");
            if (panel && text) {
                text.text = "! " + $.Localize("#enfos_sametc_boss_incoming") + ": " + bossName + " (" + $.Localize("#enfos_sametc_wave") + " " + wave + ")";
                panel.RemoveClass("Hidden");
                if (bossTimer && $.CancelScheduled) {
                    $.CancelScheduled(bossTimer);
                }
                if ($.Schedule) {
                    bossTimer = $.Schedule(6.0, function () {
                        panel.AddClass("Hidden");
                        bossTimer = null;
                    });
                }
            }
        });
    }

    update();
    PeriodicHudTick();
})();

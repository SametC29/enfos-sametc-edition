function ToggleGuide() {
    GameEvents.SendEventClientSide("enfos_toggle_welcome_guide", {});
}
(function () {
    function update() {
        var s = CustomNetTables.GetTableValue("wave_info", "status");
        var life = CustomNetTables.GetTableValue("wave_info", "team_life");
        var team = Players.GetTeam(Players.GetLocalPlayer());
        if (s) {
            $("#WaveNumber").text = $.Localize("#enfos_sametc_wave") + " " + (s.next_wave || s.current_wave) + " / " + s.max_waves;
            $("#WaveStatus").text = $.Localize("#enfos_wave_state_" + s.state.toLowerCase()) + (s.state_timer > 0 && s.state !== "VICTORY" ? " · " + Math.ceil(s.state_timer) + "s" : "");
        }
        if (s) {
            $("#SoloSupport").text = Number(s.solo_support) === 1 ? $.Localize('#enfos_solo_support') : '';
            var side = team === 3 ? 'badguys' : 'goodguys';
            if (Number(s['boss_phase_' + side]) > 0) $('#WaveStatus').text += ' · ' + $.Localize('#enfos_boss_phase') + ' ' + s['boss_phase_' + side] + '/3';
            $("#WaveBudget").text = $.Localize('#enfos_wave_planned') + ': ' + s['planned_' + side] + ' · ' + $.Localize('#enfos_wave_alive') + ': ' + s['active_' + side] + '/' + s['cap_' + side];
            $("#WaveGold").text = $.Localize('#enfos_wave_team_gold') + ': ' + s['gold_min_' + side] + '–' + s['gold_max_' + side];
        }
        if (life) {
            [ ["Radiant", life.goodguys], ["Dire", life.badguys] ].forEach(function (entry) {
                var amount = Math.max(0, Number(entry[1]) || 0);
                $("#" + entry[0] + "Life").text = (amount <= 25 ? "! " : "") + amount + " / 100";
                $("#" + entry[0] + "LifeFill").style.width = Math.min(100, amount) + "%";
                $("#" + entry[0] + "Life").GetParent().SetHasClass("LowLife", amount <= 25);
            });
        }
    }
    CustomNetTables.SubscribeNetTableListener("wave_info", update);
    var bossTimer = null;
    GameEvents.Subscribe("enfos_boss_incoming", function(data) {
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
            if (bossTimer) {
                $.CancelScheduled(bossTimer);
            }
            bossTimer = $.Schedule(6.0, function() {
                panel.AddClass("Hidden");
                bossTimer = null;
            });
        }
    });
    update();
})();

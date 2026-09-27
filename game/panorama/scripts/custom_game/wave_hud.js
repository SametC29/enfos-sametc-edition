function SendNextWave() {
    if (!$("#NextWave").enabled) return;
    $("#NextWave").enabled = false;
    GameEvents.SendCustomGameEventToServer("enfos_next_wave", {});
}
function ToggleGuide() {
    GameEvents.SendEventClientSide("enfos_toggle_welcome_guide", {});
}
(function () {
    function update() {
        var s = CustomNetTables.GetTableValue("wave_info", "status");
        var life = CustomNetTables.GetTableValue("wave_info", "team_life");
        var team = Players.GetTeam(Players.GetLocalPlayer());
        $("#NextWave").enabled = !!s && Number(s.can_send_next) === 1 && (team === 2 || team === 3);
        if (s) $("#WaveStatus").text = $.Localize("#enfos_sametc_wave") + " " + s.current_wave + "/" + s.max_waves + " · " + $.Localize("#enfos_wave_state_" + s.state.toLowerCase()) + (s.state_timer > 0 && (s.state === "PREPARATION" || s.state === "BOSS_INCOMING") ? " (" + s.state_timer + ")" : "");
        if (s) {
            var side = team === 3 ? 'badguys' : 'goodguys';
            $("#WaveBudget").text = $.Localize('#enfos_wave_planned') + ': ' + s['planned_' + side] + ' · ' + $.Localize('#enfos_wave_alive') + ': ' + s['active_' + side];
            $("#WaveGold").text = $.Localize('#enfos_wave_team_gold') + ': ' + s['gold_min_' + side] + '–' + s['gold_max_' + side] + ' · ' + $.Localize('#enfos_wave_clear_gold') + ': ' + s.clear_gold;
        }
        if (life) $("#WaveLife").text = $.Localize("#enfos_sametc_team_life") + "  " + life.goodguys + " / " + life.badguys;
    }
    CustomNetTables.SubscribeNetTableListener("wave_info", update);
    GameEvents.Subscribe("enfos_boss_incoming", function(data) {
        if (!data) return;
        var bossName = data.boss_name || "Boss";
        var wave = data.wave || "";
        GameEvents.SendEventClientSide("dota_hud_error_message", {
            splitscreenplayer: 0,
            reason: 80,
            message: "⚠️ " + $.Localize("#enfos_sametc_boss_incoming") + " (Wave " + wave + ": " + bossName + ")!"
        });
    });
    update();
})();

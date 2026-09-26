function SendNextWave() {
    if (!$("#NextWave").enabled) return;
    $("#NextWave").enabled = false;
    GameEvents.SendCustomGameEventToServer("enfos_next_wave", {});
}
(function () {
    function update() {
        var s = CustomNetTables.GetTableValue("wave_info", "status");
        var life = CustomNetTables.GetTableValue("wave_info", "team_life");
        var team = Players.GetTeam(Players.GetLocalPlayer());
        $("#NextWave").enabled = !!s && Number(s.can_send_next) === 1 && (team === 2 || team === 3);
        if (s) $("#WaveStatus").text = $.Localize("#enfos_sametc_wave") + " " + s.current_wave + "/" + s.max_waves + " · " + $.Localize("#enfos_wave_" + s.state) + (s.state_timer > 0 && (s.state === "PREPARATION" || s.state === "BOSS_INCOMING") ? " (" + s.state_timer + ")" : "");
        if (life) $("#WaveLife").text = $.Localize("#enfos_sametc_team_life") + "  " + life.goodguys + " / " + life.badguys;
    }
    CustomNetTables.SubscribeNetTableListener("wave_info", update);
    update();
})();

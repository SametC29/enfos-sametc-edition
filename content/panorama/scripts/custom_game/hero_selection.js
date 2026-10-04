// Selection visuals follow authoritative roster/picks; clicks never lock locally.
var EnfosHeroSelect = (function () {
    "use strict";
    var roles = ["Tank", "Fighter", "Carry", "Mage", "Support"];
    var containers = {Tank: "TopRoleHeroes", Fighter: "LeftRoleHeroes", Carry: "CarryRoleHeroes", Mage: "BottomRoleHeroes", Support: "RightRoleHeroes"};
    var roster = [], cards = {}, picks = {}, selected = null, pending = false, testOpen = false;
    var localId = Players.GetLocalPlayer();
    function tr(key) { return $.Localize("#" + key); }
    function values(table) { return Object.keys(table || {}).sort(function(a,b) { return Number(a)-Number(b); }).map(function(k) { return table[k]; }); }
    function displayName(hero) { var name = tr(hero.id); return name === "#" + hero.id || name === hero.id ? hero.name : name; }
    function sameTeamTaken(heroId) {
        var team = Players.GetTeam(localId);
        return Object.keys(picks).some(function(id) { return Number(id) !== localId && Players.GetTeam(Number(id)) === team && picks[id] === heroId; });
    }
    function updateControls() {
        localId = Players.GetLocalPlayer();
        Object.keys(cards).forEach(function(id) { cards[id].SetHasClass("HeroCardTaken", sameTeamTaken(id)); cards[id].SetHasClass("HeroCardSelected", !!selected && selected.id === id); });
        var locked = !testOpen && !!picks[String(localId)], taken = selected && sameTeamTaken(selected.id);
        var button = $("#PickHeroBtn");
        button.enabled = !!selected && !locked && !pending && !taken;
        button.SetHasClass("LockedIn", locked);
        $("#PickHeroBtnLabel").text = tr(locked ? "enfos_select_locked" : pending ? "enfos_select_waiting" : "enfos_select_pick");
        $("#PickStatus").text = tr(locked ? "enfos_select_confirmed" : taken ? "enfos_select_taken" : "enfos_select_hint");
    }
    function selectHero(hero) {
        selected = hero;
        $("#ShowcaseHeroImage").SetImage("file://{images}/heroes/" + hero.id + ".png");
        $("#ShowcaseHeroTitle").text = displayName(hero);
        $("#RoleBadgeText").text = tr("enfos_role_" + hero.role.toLowerCase());
        var attributes = {DOTA_ATTRIBUTE_STRENGTH:"strength", DOTA_ATTRIBUTE_AGILITY:"agility", DOTA_ATTRIBUTE_INTELLECT:"intellect", DOTA_ATTRIBUTE_ALL:"universal"};
        $("#AttrBadgeText").text = tr("enfos_attribute_" + (attributes[hero.primary] || "universal"));
        var row = $("#ShowcaseAbilities"); row.RemoveAndDeleteChildren();
        hero.abilities.forEach(function(name, i) {
            var icon = $.CreatePanel("DOTAAbilityImage", row, "SelectedAbility_" + i);
            icon.AddClass("ShowcaseAbilityIcon"); icon.abilityname = name;
            icon.SetPanelEvent("onmouseover", function() { $.DispatchEvent("DOTAShowAbilityTooltip", icon, name); });
            icon.SetPanelEvent("onmouseout", function() { $.DispatchEvent("DOTAHideAbilityTooltip", icon); });
        });
        updateControls();
    }
    function refreshRoster() {
        roster = [];
        roles.forEach(function(role) {
            var chunk = CustomNetTables.GetTableValue("hero_selection_state", "roster_" + role);
            values(chunk && chunk.heroes).forEach(function(hero) { hero.abilities = values(hero.abilities); roster.push(hero); });
            $("#" + containers[role]).RemoveAndDeleteChildren();
        });
        cards = {};
        roster.forEach(function(hero) {
            var card = $.CreatePanel("Button", $("#" + containers[hero.role]), "Card_" + hero.id);
            card.AddClass("HeroCard");
            var portrait = $.CreatePanel("Image", card, ""); portrait.AddClass("HeroCardImg");
            portrait.SetImage("file://{images}/heroes/" + hero.id + ".png");
            var label = $.CreatePanel("Label", card, ""); label.AddClass("HeroCardName"); label.text = displayName(hero);
            card.SetPanelEvent("onactivate", function() { if ((testOpen || !picks[String(localId)]) && !pending) selectHero(hero); });
            cards[hero.id] = card;
        });
        var id = picks[String(localId)] || (selected && selected.id);
        var candidate = roster.filter(function(hero) { return hero.id === id; })[0] || roster[0];
        if (candidate) selectHero(candidate);
    }
    function updateState(data) {
        localId = Players.GetLocalPlayer();
        picks = data.picks || {};
        if (picks[String(localId)]) pending = false;
        $("#SelectTimerLabel").text = String(data.remaining_time || 0);
        var own = roster.filter(function(hero) { return hero.id === picks[String(localId)]; })[0];
        if (own && (!selected || own.id !== selected.id)) selectHero(own);
        updateControls();
    }
    function checkVisibility() {
        var state = Game.GetState();
        var visible = state === DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION || state === DOTA_GameState.DOTA_GAMERULES_STATE_STRATEGY_TIME;
        $.GetContextPanel().SetHasClass("HeroSelectionHidden", !(visible || testOpen));
    }
    function pickCurrentHero() {
        localId = Players.GetLocalPlayer();
        if (!selected || pending || (!testOpen && picks[String(localId)]) || sameTeamTaken(selected.id)) return;
        pending = true; updateControls();
        // A rejected or lost request must not strand the screen in a fake locked state.
        $.Schedule(2, function() {
            if (testOpen || !picks[String(localId)]) { pending = false; updateControls(); $("#PickStatus").text = tr("enfos_select_retry"); }
        });
        $.Msg("[ENFOS selection] request ", selected.id, " phase=", Game.GetState());
        try {
            GameEvents.SendCustomGameEventToServer(testOpen ? "enfos_test_room_pick" : "enfos_lock_in_hero", {hero_name:selected.id});
        } catch (error) {
            pending = false; updateControls();
            $("#PickStatus").text = tr("enfos_select_retry");
            $.Msg("[ENFOS selection] send failed: ", String(error));
        }
    }
    CustomNetTables.SubscribeNetTableListener("hero_selection_state", function(table, key, data) {
        if (key.indexOf("roster_") === 0) refreshRoster();
        else if (key === "state" && data) updateState(data);
    });
    function updateTestSelection(data) {
        testOpen = !!(data && data.open);
        if (!testOpen) pending = false;
        updateControls(); checkVisibility();
    }
    CustomNetTables.SubscribeNetTableListener("hero_test_room", function(table, key, data) {
        if (key === "player_" + Players.GetLocalPlayer()) updateTestSelection(data);
    });
    GameEvents.Subscribe("game_rules_state_change", checkVisibility);
    refreshRoster();
    var state = CustomNetTables.GetTableValue("hero_selection_state", "state");
    if (state) updateState(state);
    updateTestSelection(CustomNetTables.GetTableValue("hero_test_room", "player_" + localId));
    checkVisibility();
    return {PickCurrentHero:pickCurrentHero};
})();

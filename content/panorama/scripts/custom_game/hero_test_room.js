var EnfosHeroTest = (function () {
    'use strict';
    function Update() {
        var data = CustomNetTables.GetTableValue('game_setup', 'hero_test_room');
        var selection = CustomNetTables.GetTableValue('hero_test_room', 'player_' + Players.GetLocalPlayer());
        $('#HeroTestRoom').visible = !!(data && data.enabled && !(selection && selection.open) && Game.GetState() >= 7 && Game.GetState() < 11);
    }
    CustomNetTables.SubscribeNetTableListener('game_setup', function(table, key) { if (key === 'hero_test_room') Update(); });
    CustomNetTables.SubscribeNetTableListener('hero_test_room', function(table, key) { if (key === 'player_' + Players.GetLocalPlayer()) Update(); });
    GameEvents.Subscribe('game_rules_state_change', Update);
    Update();
    return { Action: function(action) { GameEvents.SendCustomGameEventToServer('enfos_test_room_action', {action: action}); } };
})();

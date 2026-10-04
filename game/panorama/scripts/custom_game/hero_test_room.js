var EnfosHeroTest = (function () {
    'use strict';
    function Update() {
        var data = CustomNetTables.GetTableValue('game_setup', 'hero_test_room');
        $('#HeroTestRoom').visible = !!(data && data.enabled && Game.GetState() >= 7 && Game.GetState() < 11);
    }
    CustomNetTables.SubscribeNetTableListener('game_setup', function(table, key) { if (key === 'hero_test_room') Update(); });
    GameEvents.Subscribe('game_rules_state_change', Update);
    Update();
    return { Action: function(action) { GameEvents.SendCustomGameEventToServer('enfos_test_room_action', {action: action}); } };
})();

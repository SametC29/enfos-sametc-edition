"use strict";

var SPELL_COSTS = {
    spellbringer_arcane_barrier: 45,
    spellbringer_war_standard: 60,
    spellbringer_thorn_idol: 65,
    spellbringer_rift_surge: 75,
    spellbringer_whole_displacement: 80,
    spellbringer_reveal: 30,
    spellbringer_purification: 50,
    spellbringer_future_reinforcements: 100
};

var OFFENSIVE_SPELLS = {
    spellbringer_arcane_barrier: true,
    spellbringer_war_standard: true,
    spellbringer_thorn_idol: true,
    spellbringer_rift_surge: true
};
var targetingSpell = null;
var pointerOverSpell = false;
function SpellDefinition(name) {
    var metadata = CustomNetTables.GetTableValue("spellbringer_meta", "abilities") || {};
    return metadata[name] || { cost: SPELL_COSTS[name] || 0 };
}
function CancelSpellTarget() {
    targetingSpell = null;
    $("#SpellTargetHint").text = "";
    for (var name in SPELL_COSTS) $("#btn_" + name).SetHasClass("Targeting", false);
}
// Consume only the click used to cast/cancel. Normal hero and summon orders pass through.
GameUI.SetMouseCallback(function (event, button) {
    if (!targetingSpell || pointerOverSpell) return false;
    if (event !== "pressed") return false;
    if (button === 1) { CancelSpellTarget(); return true; }
    if (button !== 0) return false;
    var position = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
    if (!position) return true;
    var ability = targetingSpell;
    CancelSpellTarget();
    GameEvents.SendCustomGameEventToServer("enfos_spellbringer_cast", {
        ability_name: ability, target_x: position[0], target_y: position[1], target_z: position[2]
    });
    return true;
});

function CastSpell(abilityName) {
    var localPlayer = Players.GetLocalPlayer();
    var state = CustomNetTables.GetTableValue("spellbringer_state", String(localPlayer));
    var cost = Number(SpellDefinition(abilityName).cost);

    if (!state || (state.mana || 0) < cost) {
        GameEvents.SendEventClientSide("dota_hud_error_message", {
            splitscreenplayer: 0,
            reason: 80,
            message: "#enfos_error_insufficient_spellbringer_mana"
        });
        return;
    }

    if ((state.is_coop === 1 || state.is_coop === true) && OFFENSIVE_SPELLS[abilityName]) {
        return;
    }

    var remaining = (state.cooldowns && state.cooldowns[abilityName]) || 0;
    if (remaining > 0.1) {
        return;
    }

    var same = targetingSpell === abilityName;
    CancelSpellTarget();
    if (same) return;
    targetingSpell = abilityName;
    $("#btn_" + abilityName).SetHasClass("Targeting", true);
    $("#SpellTargetHint").text = $.Localize(OFFENSIVE_SPELLS[abilityName] ? "#enfos_spell_target_enemy" : "#enfos_spell_target_ally");
}

function ShowTooltip(abilityName) {
    pointerOverSpell = true;
    var btn = $("#btn_" + abilityName);
    if (!btn) return;
    var title = $.Localize("#DOTA_Tooltip_" + abilityName);
    var desc = $.Localize("#DOTA_Tooltip_" + abilityName + "_Description");
    var def = SpellDefinition(abilityName);
    var text = "<b>" + title + "</b><br>" + desc + "<br><font color='#82c0ff'>" + $.Localize("#enfos_spellbringer_mana") + ": " + def.cost + "</font>";
    text += "<br>" + $.Localize("#enfos_cooldown") + ": " + (def.cooldown || 0) + "s";
    if (def.radius) text += " · " + $.Localize("#enfos_radius") + ": " + def.radius;
    if (def.duration) text += " · " + $.Localize("#enfos_duration") + ": " + def.duration + "s";
    text += "<br>" + $.Localize(OFFENSIVE_SPELLS[abilityName] ? "#enfos_spell_target_enemy" : "#enfos_spell_target_ally");
    $.DispatchEvent("DOTAShowTextTooltip", btn, text);
}

function HideTooltip() {
    pointerOverSpell = false;
    $.DispatchEvent("DOTAHideTextTooltip");
}

(function () {
    function updateSpellbringerUI() {
        var localPlayer = Players.GetLocalPlayer();
        var state = CustomNetTables.GetTableValue("spellbringer_state", String(localPlayer));
        if (!state) return;

        var mana = state.mana || 0;
        var maxMana = state.max_mana || 200;
        var regen = state.regen || 2.5;
        var isCoop = state.is_coop === true || Number(state.is_coop) === 1;
        var cooldowns = state.cooldowns || {};

        // Update Mana bar
        var pct = Math.min(100, Math.max(0, (mana / maxMana) * 100));
        var progressBar = $("#ManaProgressBar");
        if (progressBar) {
            progressBar.style.width = pct + "%";
        }

        var manaLabel = $("#SpellbringerManaText");
        if (manaLabel) {
            manaLabel.text = Math.floor(mana) + " / " + maxMana + " (+" + regen.toFixed(1) + "/s)";
        }

        var coopNotice = $("#SpellbringerCoopNotice");
        if (coopNotice) {
            coopNotice.SetHasClass("Visible", isCoop);
        }

        // Update each ability button
        for (var name in SPELL_COSTS) {
            var btn = $("#btn_" + name);
            var sweep = $("#cd_" + name);
            var label = $("#lbl_" + name);
            if (!btn) continue;

            var def = SpellDefinition(name);
            var cost = Number(def.cost);
            var icon = $("#icon_" + name);
            if (icon && def.icon) icon.abilityname = def.icon;
            var cd = cooldowns[name] || 0;
            var isOffensive = !!OFFENSIVE_SPELLS[name];

            var disabled = (isCoop && isOffensive) || (mana < cost) || (cd > 0.1);
            btn.SetHasClass("Disabled", disabled);
            btn.SetHasClass("NotEnoughMana", mana < cost && cd <= 0.1);

            if (sweep && label) {
                if (cd > 0.1) {
                    sweep.SetHasClass("Active", true);
                    label.text = cd >= 10 ? Math.ceil(cd) : cd.toFixed(1);
                    label.visible = true;
                } else {
                    sweep.SetHasClass("Active", false);
                    label.visible = false;
                }
            }
        }
    }

    CustomNetTables.SubscribeNetTableListener("spellbringer_state", updateSpellbringerUI);
    GameEvents.Subscribe("enfos_spellbringer_error", function(data) {
        if (!data) return;
        var msg = data.reason || data.message || "#enfos_error_generic";
        GameEvents.SendEventClientSide("dota_hud_error_message", {
            splitscreenplayer: 0,
            reason: 80,
            message: $.Localize(msg)
        });
    });
    updateSpellbringerUI();
})();

function SendNextWave() {
    var button = $("#NextWave");
    if (!button.enabled) return;
    button.enabled = false;
    GameEvents.SendCustomGameEventToServer("enfos_next_wave", {});
}
(function () {
    function updateNextWave() {
        var status = CustomNetTables.GetTableValue("wave_info", "status");
        var team = Players.GetTeam(Players.GetLocalPlayer());
        $("#NextWave").enabled = !!status && Number(status.can_send_next) === 1 && (team === 2 || team === 3);
    }
    CustomNetTables.SubscribeNetTableListener("wave_info", updateNextWave);
    updateNextWave();
})();

// Dynamic alignment to minimap (adapts to left or right if HUD is flipped)
(function () {
    function UpdateMinimapPosition() {
        var isFlipped = false;
        try {
            if (typeof Game !== "undefined" && Game.IsHUDFlipped) {
                isFlipped = Game.IsHUDFlipped();
            }
        } catch (e) {
            isFlipped = false;
        }

        var hud = $("#SpellbringerHud");
        if (hud) {
            hud.SetHasClass("MinimapLeft", !isFlipped);
            hud.SetHasClass("MinimapRight", isFlipped);

            var hudRoot = ($.GetContextPanel && typeof $.GetContextPanel === "function") ? $.GetContextPanel().GetParent() : null;
            while (hudRoot && hudRoot.GetParent()) {
                hudRoot = hudRoot.GetParent();
            }

            var mapBlock = hudRoot ? (hudRoot.FindChildTraverse("minimap_container") || hudRoot.FindChildTraverse("minimap_block") || hudRoot.FindChildTraverse("minimap")) : null;
            var bottomMargin = 265;
            if (mapBlock && mapBlock.actuallayoutheight && mapBlock.actuallayoutheight > 100) {
                bottomMargin = mapBlock.actuallayoutheight + 12;
            }
            if(mapBlock && mapBlock.actuallayoutwidth>0) {
                var pos=mapBlock.GetPositionWithinWindow();
                var screenWidth=hudRoot.actuallayoutwidth*(hudRoot.actualuiscale_x||1);
                isFlipped=pos.x>screenWidth/2;
                hud.SetHasClass("MinimapLeft",!isFlipped);hud.SetHasClass("MinimapRight",isFlipped);
                var scale=hud.actualuiscale_y||1;
                bottomMargin=Math.max(0,(hudRoot.actuallayoutheight*(hudRoot.actualuiscale_y||1)-pos.y)/scale)+8;
            }
            hud.style.marginBottom = bottomMargin + "px";
        }

        if ($.Schedule) {
            $.Schedule(0.5, UpdateMinimapPosition);
        }
    }

    UpdateMinimapPosition();
})();

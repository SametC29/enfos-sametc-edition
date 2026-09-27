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

function CastSpell(abilityName) {
    var localPlayer = Players.GetLocalPlayer();
    var state = CustomNetTables.GetTableValue("spellbringer_state", String(localPlayer));
    var cost = SPELL_COSTS[abilityName] || 0;

    if (!state || (state.mana || 0) < cost) {
        GameEvents.SendEventClientSide("dota_hud_error_message", {
            splitscreenplayer: 0,
            reason: 80,
            message: "#enfos_error_insufficient_spellbringer_mana"
        });
        return;
    }

    if (state.is_coop && OFFENSIVE_SPELLS[abilityName]) {
        return;
    }

    var remaining = (state.cooldowns && state.cooldowns[abilityName]) || 0;
    if (remaining > 0.1) {
        return;
    }

    GameEvents.SendCustomGameEventToServer("enfos_spellbringer_cast", {
        player_id: localPlayer,
        ability_name: abilityName
    });
}

function ShowTooltip(abilityName) {
    var btn = $("#btn_" + abilityName);
    if (!btn) return;
    var title = $.Localize("#DOTA_Tooltip_" + abilityName);
    var desc = $.Localize("#DOTA_Tooltip_" + abilityName + "_Description");
    var cost = SPELL_COSTS[abilityName] || 0;
    var text = "<b>" + title + "</b><br>" + desc + "<br><font color='#82c0ff'>" + $.Localize("#enfos_spellbringer_mana") + ": " + cost + "</font>";
    $.DispatchEvent("DOTAShowTextTooltip", btn, text);
}

function HideTooltip() {
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
        var isCoop = !!state.is_coop;
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

            var cost = SPELL_COSTS[name];
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

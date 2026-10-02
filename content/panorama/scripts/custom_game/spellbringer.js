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
var targetParticle = null, targetGeneration = 0;
var activeCastEffects = [];
var RANGE_PARTICLE = "particles/ui_mouseactions/range_display.vpcf";
function DestroySpellParticle(id) {
    if (id === null || id === undefined) return;
    Particles.DestroyParticleEffect(id, true);
    Particles.ReleaseParticleIndex(id);
}
function SpellRadius(name) { return Number(SpellDefinition(name).radius) || (name === "spellbringer_rift_surge" ? 71 : 85); }
function CreateSpellParticle(name) {
    return Particles.CreateParticle(name, ParticleAttachment_t.PATTACH_WORLDORIGIN,
        Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()));
}
function StartSpellAreaPreview() {
    if (typeof Particles === "undefined" || !$.Schedule) return;
    var generation = targetGeneration;
    targetParticle = CreateSpellParticle(RANGE_PARTICLE);
    function update() {
        if (generation !== targetGeneration || !targetingSpell) return;
        var position = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
        Particles.SetParticleControl(targetParticle, 0, position || [0, 0, -10000]);
        Particles.SetParticleControl(targetParticle, 1, [position ? SpellRadius(targetingSpell) : 0, 0, 0]);
        $.Schedule(0.03, update);
    }
    update();
}
var pointerOverSpell = false;
function SpellDefinition(name) {
    var metadata = CustomNetTables.GetTableValue("spellbringer_meta", "abilities") || {};
    return metadata[name] || { cost: SPELL_COSTS[name] || 0 };
}
function CancelSpellTarget() {
    targetGeneration++;
    DestroySpellParticle(targetParticle);
    targetParticle = null;
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
    StartSpellAreaPreview();
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
    GameEvents.Subscribe("enfos_spellbringer_effect", function(data) {
        if (!data || Number(data.team) !== Players.GetTeam(Players.GetLocalPlayer()) || typeof Particles === "undefined") return;
        var position = [Number(data.x), Number(data.y), Number(data.z)];
        if (!position.every(isFinite) || !SPELL_COSTS[data.ability]) return;
        var effect = { ring: CreateSpellParticle(RANGE_PARTICLE), burst: null };
        Particles.SetParticleControl(effect.ring, 0, position);
        Particles.SetParticleControl(effect.ring, 1, [SpellRadius(data.ability), 0, 0]);
        var particle = data.ability === "spellbringer_reveal" ? "particles/items_fx/dust_of_appearance.vpcf"
            : data.ability === "spellbringer_purification" ? "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"
            : "particles/units/heroes/hero_enigma/enigma_demonic_conversion.vpcf";
        effect.burst = CreateSpellParticle(particle);
        Particles.SetParticleControl(effect.burst, 0, position);
        // Native Purification's RingWave also reads its radius from CP1.x.
        if (data.ability === "spellbringer_reveal" || data.ability === "spellbringer_purification") {
            Particles.SetParticleControl(effect.burst, 1, [SpellRadius(data.ability), 0, 0]);
        }
        function retire(value) {
            if (value.retired) return;
            value.retired = true;
            DestroySpellParticle(value.ring); DestroySpellParticle(value.burst);
            value.ring = null; value.burst = null;
            var index = activeCastEffects.indexOf(value);
            if (index >= 0) activeCastEffects.splice(index, 1);
        }
        activeCastEffects.push(effect);
        if (activeCastEffects.length > 16) retire(activeCastEffects[0]);
        $.Schedule(1.5, function() { DestroySpellParticle(effect.burst); effect.burst = null; });
        $.Schedule(data.ability === "spellbringer_reveal" ? 15 : 2, function() { retire(effect); });
    });
})();

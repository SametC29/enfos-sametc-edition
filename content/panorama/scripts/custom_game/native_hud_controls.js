"use strict";

// Small, guarded edits to Valve's HUD. These ids are internal Dota panel ids,
// so retry after HUD rebuilds and tolerate panels that are absent in a mode.
(function () {
    var spellbringerOpen = false;

    function FindHudRoot() {
        var panel = $.GetContextPanel();
        while (panel && panel.GetParent()) panel = panel.GetParent();
        return panel;
    }

    function FindHudElement(root, id) {
        return root ? root.FindChildTraverse(id) : null;
    }

    function HidePanel(root, id) {
        var panel = FindHudElement(root, id);
        if (!panel) return;
        panel.visible = false;
        panel.enabled = false;
        panel.hittest = false;
        panel.hittestchildren = false;
        panel.style.visibility = "collapse";
    }

    function ShowSpellbringer() {
        var panel = $("#SpellbringerHud");
        if (!panel) return;
        spellbringerOpen = !spellbringerOpen;
        panel.SetHasClass("Visible", spellbringerOpen);
        if (spellbringerOpen) PositionSpellbringer(FindHudElement(FindHudRoot(), "glyph"));
    }

    function PositionSpellbringer(glyph) {
        var panel = $("#SpellbringerHud");
        if (!panel || !glyph || !spellbringerOpen) return;

        var screenWidth = Game.GetScreenWidth();
        var screenHeight = Game.GetScreenHeight();
        var buttonPosition = glyph.GetPositionWithinWindow();
        if (!screenWidth || !screenHeight || !buttonPosition) return;

        panel.SetHasClass("ShieldPopup", true);
        var width = panel.actuallayoutwidth || 236;
        var height = panel.actuallayoutheight || 175;
        var buttonWidth = glyph.actuallayoutwidth || 44;
        var buttonHeight = glyph.actuallayoutheight || 44;
        var onRight = buttonPosition.x > screenWidth / 2;
        var x = onRight ? buttonPosition.x - width - 10 : buttonPosition.x + buttonWidth + 10;
        var y = buttonPosition.y + buttonHeight - height;
        x = Math.max(8, Math.min(x, screenWidth - width - 8));
        y = Math.max(8, Math.min(y, screenHeight - height - 8));

        // Panorama's position property uses screen-relative coordinates.
        panel.style.position = (x / screenWidth * 100) + "% " + (y / screenHeight * 100) + "% 0px";
    }

    function BindFortification(root) {
        var glyph = FindHudElement(root, "glyph");
        if (!glyph) return;

        // Valve's compiled dota_hud_glyph layout binds native activation to
        // NormalRoot, above GlyphButton. Bind once per root and let that root
        // own hit testing: binding both levels could toggle twice on one click.
        var buttons = [
            FindHudElement(glyph, "NormalRoot"),
            FindHudElement(glyph, "RadiantRoot"),
            FindHudElement(glyph, "DireRoot"),
        ].filter(function (button) { return !!button; });
        if (buttons.length === 0) buttons = [
            FindHudElement(root, "GlyphButton"),
            FindHudElement(root, "RadiantGlyphButton"),
            FindHudElement(root, "DireGlyphButton"),
        ].filter(function (button) { return !!button; });
        if (buttons.length === 0) buttons = [glyph];

        // Fortification's cooldown can disable the native control before the
        // replacement Spellbringer click handler receives input. This control
        // is only an opener now, so keep its hit target active regardless of
        // the native Glyph charge/cooldown state.
        glyph.enabled = true;
        glyph.hittest = true;
        glyph.hittestchildren = true;

        buttons.forEach(function (button) {
            button.enabled = true;
            button.hittest = true;
            button.hittestchildren = false;
            button.ClearPanelEvent("onactivate");
            button.ClearPanelEvent("onmouseover");
            button.ClearPanelEvent("onmouseout");
            button.SetPanelEvent("onactivate", ShowSpellbringer);
            button.SetPanelEvent("onmouseover", function () {
                $.DispatchEvent("DOTAShowTextTooltip", button, $.Localize("#enfos_spellbringer_title"));
            });
            button.SetPanelEvent("onmouseout", function () {
                $.DispatchEvent("DOTAHideTextTooltip", button);
            });
        });
    }

    function ApplyNativeHudChanges() {
        // Keep retrying when the engine has not built the HUD yet.
        $.Schedule(0.5, ApplyNativeHudChanges);
        var root = FindHudRoot();
        if (!root) return;

        HidePanel(root, "RoshanTimerContainer");
        HidePanel(root, "TormentorTimerContainer");
        HidePanel(root, "RadarButton");

        // Remove the native talent-tree/stat-branch button so it cannot show
        // an empty tooltip or occupy a dead slot beside the hero abilities.
        var talentButton = FindHudElement(root, "StatBranch");
        if (talentButton) {
            talentButton.ClearPanelEvent("onmouseover");
            talentButton.ClearPanelEvent("onmouseout");
            talentButton.ClearPanelEvent("onactivate");
            HidePanel(root, "StatBranch");
        }
        // Valve's level-stats frame owns a separate '+' tab which opens the
        // stat branch again when ordinary skill points are available. Hide its
        // tab, not the ability rank-up controls or their learn-mode button.
        var talentTab = FindHudElement(root, "LevelUpTab");
        if (talentTab) {
            talentTab.ClearPanelEvent("onactivate");
            HidePanel(root, "LevelUpTab");
        }
        // SkillUpgradable/CanLevelStats make the native frame visible again.
        // Suppress its parent and the drawer/hotkey as well as the child tab.
        // `levelup` is a separate DOTALevelUpButton and stays available.
        ["level_stats_frame", "StatBranch", "StatBranchDrawer", "StatBranchHotkey"].forEach(function (id) {
            var panel = FindHudElement(root, id);
            if (!panel) return;
            HidePanel(root, id);
            panel.style.opacity = "0";
        });

        // Keep the Town Portal Scroll control while removing only the neutral
        // item slot and its level-up affordance/label.
        HidePanel(root, "inventory_neutral_slot_container");
        HidePanel(root, "inventory_neutral_level_up");

        BindFortification(root);
        PositionSpellbringer(FindHudElement(root, "glyph"));
    }

    ApplyNativeHudChanges();
})();

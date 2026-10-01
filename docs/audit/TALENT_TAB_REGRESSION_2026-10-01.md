# Level-up talent tab regression — 2026-10-01

Status: IMPLEMENTED BUT NOT ENGINE-VERIFIED.

The owner screenshot shows the separate gold `+` tab returning when skill
points become available. The controller suppressed `StatBranch`, but did not
suppress the tab that opens it. Installed Valve VPK
`panorama/layout/hud/dota_hud_level_stats_frame.vxml_c`, decoded with Source 2
Viewer 19.2, defines `LevelUpTab` with
`onactivate="DOTAHUDToggleStatBranchVisibility()"`. It is a separate control
from ordinary ability rank-up/learn-mode controls.

The controller now clears that tab's activation and hides it on each existing
HUD refresh, including after a level-up or HUD rebuild. Gameplay points and
ability definitions are unaffected. Both game and content sources match.

Reference-only cross-check: dun1007/fateanother's custom UI manifest also
suppresses the native level-stats frame independently of StatBranch:
https://github.com/dun1007/fateanother/blob/master/content/dota_addons/fateanother/panorama/layout/custom_game/custom_ui_manifest.xml
No upstream code or assets were imported; the installed Valve layout is the
identifier/activation evidence.

Regression: the HUD mock restores tab visibility, runs the scheduled refresh,
and asserts the tab is hidden and inert while ordinary ability rank controls
remain visible. This does not prove Dota rendering. Owner acceptance: start a
fresh match, gain a level with unspent points, verify no talent `+` appears and
Q/W/E/R/passive ranks remain purchasable. Inspect VConsole for Panorama errors.

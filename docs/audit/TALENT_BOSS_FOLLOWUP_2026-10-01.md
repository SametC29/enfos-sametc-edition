# Talent tree and native Boss resurrection follow-up — 2026-10-01

Status: IMPLEMENTED / LOCAL ADDON DEPLOYED; engine acceptance remains PENDING.
Owner explicitly requested commit and live delivery without waiting for playtests.
This follow-up supersedes the talent UI completion assumptions in the earlier
four-regression delivery. Owner confirms Elite removal and Boss loading changes;
Reveal playtesting remains with the owner. No Dota launch/control was performed.

## Goal and evidence

Remove the returning talent-tree `+`, preserving normal skill learning and
match-only level 50; prevent dead wave Bosses from returning; commit/push and
deploy the focused changes without waiting for engine testing.

The goal service initially refused a second goal because the previous goal was
unfinished. Work continued under that goal; the new scope is recorded here.

The supplied `log1.txt` was read before it became unavailable at its original
Desktop path. Relevant evidence (no player/account identifiers retained):

- Wave 6 and Wave 12 start as `Type: normal`.
- Sven wave 5 precache completes at 103.5 before preparation at 108.8; Axe wave
  10 precache completes at 241.4 before preparation at 246.8.
- Both Bosses log `Attempted to create unknown modifier type modifier_enfos_boss_base!`.
- Boss clear rewards appear at 147.7 and 297.6. The log does not itself show
  resurrection timing or prove rendered model correctness.
- Separate TreeShop_OnStartTouch/OnEndTouch missing callback errors and missing
  localization/icon/sound warnings exist; these are outside this focused repair.

## Talent UI

Installed Valve VPK, decoded with Source2Viewer CLI 19.2:
`panorama/layout/hud/hud_reborn.vxml_c` places `level_stats_frame` separately
from `levelup` and `abilities`. Its `StatBranchDrawer` contains
`statbranchdialog`; `StatBranchHotkey` uses LearnStats.
`dota_hud_level_stats_frame.vcss_c` reveals the entire native frame when
SkillUpgradable/CanLevelStats changes. Hiding only StatBranch/LevelUpTab left
the native parent, drawer and hotkey untreated.

The controller now collapses/disables the entire frame, talent display, drawer
and hotkey, with persistent inline zero opacity, and retries across HUD rebuilds.
The visibility property uses the value `collapse` without a declaration
semicolon. The retry is scheduled even before a HUD root exists. The separate
normal `levelup` control and ability list stay available; points/XP/KV are unchanged.
No native panel is deleted and no hero/player ability kit is rewritten.

The previously compiled controller was decoded and still contained the earlier
child-only suppression. The changed controller was compiled with the installed
resourcecompiler: **1 compiled, 0 failed**. Decoding the resulting `.vjs_c`
confirms the new parent/drawer/hotkey suppression and valid visibility value.
This verifies the deployed artifact, not the engine's final rendering.

## Native Boss lifecycle

Confirmed code defect: CreateUnitByName now creates native hero entities, but
the wave pipeline never disabled their automatic hero respawn. No code was
found that deliberately wakes every earlier Boss on a later Boss spawn.
Installed VScript API documents
`CDOTA_BaseNPC_Hero:SetRespawnsDisabled(bool)` as preventing hero respawns.
The wave pipeline now calls it with true immediately after tagging each Boss,
before preparation or any failure cleanup. Player heroes retain normal respawn.

On death, existing wave reward handling remains authoritative and grants rewards
only while the entity is registered. Afterwards the Boss registry and AI state
are cleared; the existing thinker stops. Duplicate death events do not duplicate
rewards. A successive spawn registers only its new entity.

Player spawn initialization is now restricted to player-owned Radiant/Dire
heroes so neutral Boss heroes cannot receive the player passive/spawn lifecycle.
The Boss baseline modifier is linked on both Lua sides instead of being gated
by IsServer at module load. The supplied warning proves a registration failure;
the side-gating repair still needs engine confirmation of warning removal.
No native Boss spell/item/build/balance values changed.

## Validation and deployment

- Focused Node/Lua checks cover talent parent/HUD rebuild suppression, preserved
  normal learning, all twelve native Boss pipelines, disabled respawn, successive
  deaths/spawns, single rewards, modifier client linking and player/Boss spawn
  separation. Elite, resource-gate, Reveal and talent-point checks remain green.
- All twelve installed-data native kits and native toggle mock checks pass.
- Full current contributor worktree `npm run check` passes. Contributor changes
  remain separate; this is not a claim that every unrelated committed-tree
  inventory passes.
- Relevant diff whitespace and Lua/JS checks pass.
- Dota game/content addon paths are existing junctions to this repository's
  game/content folders. Updated Lua and the rebuilt HUD artifact are therefore
  deployed to the local live addon. A new match loads the new server lifecycle;
  an already running match was not restarted or altered by Codex.

Engine acceptance still requires owner observation: level up with unspent points
and verify no talent `+`/drawer while ordinary learning works; kill successive
Bosses, wait past their former respawn times, and confirm no return/extra reward
or modifier warning. Reveal remains owner-test pending. No ENGINE_PASS claimed.

Research: installed Valve HUD resources and mounted VScript API are primary
evidence. Reference-only comparison:
https://github.com/dun1007/fateanother/blob/master/content/dota_addons/fateanother/panorama/layout/custom_game/custom_ui_manifest.xml
also suppresses the native frame separately. No third-party code/assets imported.

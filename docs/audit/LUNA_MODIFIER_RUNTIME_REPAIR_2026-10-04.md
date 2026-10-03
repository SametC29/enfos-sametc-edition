# Luna modifier runtime failure and isolated loading repair — 2026-10-04

Result: **IMPLEMENTED BUT NOT ENGINE-VERIFIED**. Prior owner session failed
modifier loading. Post-change acceptance is **PENDING OWNER RETEST**.

## Evidence and cause boundary

Owner supplied VConsole log, SHA256 d3be3fa4e5eb5a50e84436560d26c64160836b4dec17749989078b0be7bc9026.
Observed server/build_version 6943, engine revision 11069754. Luna selection
appears at lines 1649–1662. Failures:

- native_scaling: lines 1706, 1719 (2 occurrences).
- blessing_extension: lines 1707, 1721 (2 occurrences).
- blessing_extension_buff: line 1722 (1 occurrence).

All three are unknown modifier type warnings. The installed scaling/e/integration
and innates sources matched repository sources after newline normalization;
stale files are not supported as the explanation. No LUNA_TRACE occurs in this
log. It proves creation failures, not damage totals or rank/upgrade coverage.

Confirmed integration defect: engine class loading and server restore services
shared self-linked files returning unrelated service tables. The previous mocks
made LinkLuaModifier a no-op and therefore did not exercise engine file scope.
That mixed loading boundary is the repair target. Whether the exact engine
failure was caused by export/scope resolution, self-link timing or client loading
is not isolated by this log; do not present the C++ cause as conclusively proven.

The installed scripts/vscripts/game/gameinit.lua lines 181–190 confirm the current
three-argument LinkLuaModifier wrapper. The installed-toolkit API confirms it is
available on both server and client. Research references:
[Valve source mirror](https://github.com/SteamTracking/GameTracking-Dota2/blob/master/game/dota/scripts/vscripts/game/gameinit.lua),
[API](https://docs.moddota.com/lua_server/).
The existing heroes/modifier_hero_power.lua + heroes/hero_power.lua arrangement
provides a local separate-class/separate-service reference. No external code was
imported, and no new assets, native KV changes or balance tuning were introduced.

## Changes

- luna/modifiers.lua: only the three existing modifier classes and their existing
  numeric behavior; no self-link or exported restore service. Engine loading does
  not traverse provider/spawn/upgrade setup code.
- luna/integration.lua: explicitly links each class to that dedicated script at
  existing bootstrap; runs both restores so a Q failure cannot suppress E setup.
- luna/scaling.lua and luna/e.lua: retain restore services, validate the returned
  AddNewModifier handle, emit missing/failure traces and return false on failure.
  Ready traces cannot certify a failed creation.
- luna_native_integration.test.mjs: isolated fresh file-scope loading of all three
  classes, plus nil/null creation failure and independent E-restore regressions.
- player_feedback_regressions.lua: progression-only fixture permits both Q and E
  lookups without pretending it supplies those abilities.

Pure modifier behavior, native mechanics, VFX/SFX, ranks, points, Shard/Scepter
routing and Boss systems are unchanged. Contributor Lich edits stay outside this
work. No push, deployment, Workshop publication or Dota control was performed.

## Validation and owner feedback

15 focused Luna tests pass. Full npm.cmd run check exits 0: 0 failed checks;
354 hero-kit and 22 audit mocks pass. Rank inventory remains 200/200, 195 Lua
passed, 5 native pending owner, 0 failed. These checks establish syntax, file-scope
class presence and failure handling, not Dota's C++ binding acceptance.

Owner explicitly reports no sound/visual problems in the tested session.
Record this as positive owner observation for that session; tested abilities,
ranks, upgrades and cold-start coverage were not specified. It must not be
changed into a complete all-rank VFX/SFX acceptance or dismissed because a
separate Lua extension failed. No effect/resource modification was warranted.

Separate log findings: TreeShop_OnStartTouch/OnEndTouch nil callbacks,
CourierZone_Enter/Leave missing callbacks, and modifier_enfos_boss_base unknown
at line 2108. Their causes and repairs are outside this Luna unit; unresolved.

## Owner retest

After the repository changes are transferred to the installed addon, fully
restart the test session. The installed addon was not updated by this repair.
Enable diagnostics before Luna spawn/restore:

    script require('lib/hero_trace'):SetEnabled(true)

Confirm the three unknown modifier warnings vanish. Q and E ready traces must
appear, with no native_scaling_modifier_missing,
native_blessing_extension_missing or native_beam_provider_missing. Check Q
actual damage with live Agility, R beams using paid Q, and E armor/movement at
ranks 1/10; then Break/death/respawn and no duplicate provider/modifiers/points.
A clean log alone cannot replace measured gameplay. Continue the original
pilot checklist for all ten ranks and native Shard/Scepter behaviors.

**OWNER ENGINE ACCEPTANCE: FAILED IN SUPPLIED SESSION; PATCH PENDING OWNER RETEST.**

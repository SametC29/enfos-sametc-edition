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


## Subsequent retest and command correction

Owner's second log (attachment 7553bd3b-0cc2-45b9-9bee-048982839bd6) still
reports all three unknown Luna modifier types, at lines 1706/1707/1717–1719.
The four installed Luna files match the post-change repository files. The
separate-script repair did not remove the observed warning; acceptance remains
FAIL. No further speculative gameplay patch is justified by that result.

The standalone script console command is unavailable on this installed build;
the earlier enable/restore instructions above are invalid for this host. The
repository already records this in docs/P0_RUNTIME_HEALTH.md. Owner successfully
ran script_reload_code tools/p0_health and reported state=10, map=enfos,
player=0, Luna level=6, alive=true, points=0. This confirms server game context,
not modifier registration or correct initial point spending. points=0 alone
does not identify a progression defect without the owner's spending history.

A new read-only tools/luna_health.lua probe uses that supported execution path.
After copying only this probe to the installed addon scripts/vscripts/tools,
run:

    script_reload_code tools/luna_health

It prints server context, visible Lua globals for the three classes, actual
modifier handles on selected Luna heroes and six current ability ranks including
the native Beam provider. It never requires the integration, repairs/relinks
classes, enables traces, restores ranks or creates modifiers/abilities. Global
class visibility and live modifier presence are separate observations; neither
alone certifies client binding. This probe is not attached to bootstrap or run
by a timer. No new deployment or game control was performed by the agent.

Next decision requires the owner probe output: server modifier absence supports
a server creation/registration failure; presence despite warnings calls for
client binding investigation. Do not infer either before the output arrives.

Probe validation: 16 focused Luna tests pass, including client-context rejection,
live/missing modifier inspection and absence of repair side effects. Full
npm.cmd run check exits0 with 0 failed checks. Engine execution of the new probe
remains pending owner output.

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

Observed pre-repair architecture: engine class loading and server restore services
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


## Owner server probe — 2026-10-04

Owner output confirms server=true/state10, all three class globals present,
all three live Luna modifier handles present, and the hidden native Beam
provider at rank1. Q/W/E/R ranks1 and D rank2 at hero level6/points0 are
consistent with five spent ordinary starting points plus the separate free D
rank. This is limited starting-budget evidence, not all-rank acceptance.

The hypothesis that these warnings indicate failed server modifier creation
is contradicted by this output and is withdrawn. Server class/handle presence
does not prove the property callbacks affect damage/armor/speed, nor identify
which side emitted the warnings. Client registry/loading is the next evidence
boundary; do not perform another speculative native gameplay rewrite.

The installed game/dota/bin/win64/client.dll contains the exact command
cl_script_reload_code. The read-only health probe now prints class visibility
before its server-context guard, so the same file can inspect the client:

    cl_script_reload_code tools/luna_health

Expected context is server=false; a trailing server_context_unavailable is
normal for this client run. Three lua_global fields are diagnostic observations,
not by themselves proof of engine registry ownership. This run does not import,
link, restore or create classes/modifiers. The probe and 16 focused Luna tests
pass after this change. No gameplay or asset source changed in this unit.

Filesystem correction: installed enfos_sametc is a junction targeting the
repository game directory. There is no separate copy step for these source
files; prior owner copying instructions were unnecessary. The owner explicitly
requested copying, and the attempted same-file copy was rejected without
changing the file. Its installed path already resolves to the current source.
No agent game-control command was sent.


## Client bootstrap repair — 2026-10-04

The owner client probe reports server=false and all three class globals false.
A subsequent user-authorized MCP command run reproduces the same split in the
current Enfos map session: all server globals/handles present, all client globals
absent. This map launch was not a certified full process restart. Missing client
import coverage is nevertheless established in the source: no client entry file
existed; Luna native aliases have no Lua ScriptFile; integration was imported
only through server bootstrap/innates. It is the narrow repair target, not a
claim that every prior warning was conclusively assigned to its emitting VM.

Per owner suggestion, Lich/Lion/Jakiro instructions and current inventories were
read, followed by init.lua and representative Q modules. Each has five Lua
ScriptFile paths that load the ability module's LinkLuaModifier calls; their
init maps also preserve explicit modifier ownership in the server bootstrap.
Luna's native slots cannot depend on those Lua ability load paths. No code or
dossier for those heroes was changed; existing contributor Lich edits remain
unstaged. Replacing Luna's native abilities with wrappers is unnecessary.

The current installed game/dota/bin/win64/client.dll contains the exact string
addon_game_mode_client. Together with the current both-context LinkLuaModifier
and IsClient APIs, this verifies the intended client entry identifier. Historical
Valve Diretide content also used the entry (secondary corroboration:
https://steamdb.info/patchnotes/5757124/); no reference code was imported.

Changes: new addon_game_mode_client.lua imports only Luna modifier_links when
IsClient is true. New Luna modifier_links.lua contains the three existing class
registrations and pure modifier import; existing server integration uses that
same module. It has no restore services, manager startup, entity creation,
point/rank changes, listeners or timers. Repeated require calls do not relink
within the same VM. Native ability mechanics, numerical curves, resources and
other heroes remain unchanged.

17 focused Luna tests pass, including fresh client registration without any
server gameplay modules and a server guard; full npm.cmd run check exits0 with
0 failed checks. Client engine execution remains **PENDING OWNER RETEST**.
Previously supplied logs still count as failed acceptance, not passes.

Files are already visible to the installed addon through its junction. Fully
close and reopen Dota/Workshop Tools for the new client entry, select Luna, run
script_reload_code tools/luna_health then cl_script_reload_code tools/luna_health.
Client expectation: all three lua_global fields true and no new unknown Luna
modifier warnings. A trailing server_context_unavailable on the client is normal.
Verify actual Q/R damage, E armor/speed, HUD and respawn separately. No publication,
remote push or additional hero rollout was performed; owner performs engine tests.


## Owner client bootstrap confirmation — 2026-10-04

After the client-bootstrap change, owner supplies:

    [LUNA_HEALTH] server=false
    [LUNA_HEALTH] class=modifier_enfos_luna_native_scaling lua_global=true
    [LUNA_HEALTH] class=modifier_enfos_luna_blessing_extension lua_global=true
    [LUNA_HEALTH] class=modifier_enfos_luna_blessing_extension_buff lua_global=true
    [LUNA_HEALTH] server_context_unavailable IsServer=false

**Client class visibility: PASS (owner engine evidence).** All three absent
client globals are now present. The final server-context line is the expected
guard in a client run, not a failure. This confirms the client import path;
it does not certify C++ modifier binding/property execution or all-rank native
behavior. Previously recorded server globals and handles were already present.

No full post-change VConsole log or measured Q/R damage and E armor/speed results
accompany this output. Unknown-modifier warning clearance, actual effects,
Break/death/respawn and ten-rank/upgrade acceptance remain PENDING OWNER TEST.
Do not carry forward the old all-loading-failed diagnosis as the current class
visibility status, or close the complete Luna pilot from this narrower pass.
No gameplay code changed while recording this evidence.


## Owner full log: loading cleared, client lifecycle API failure — 2026-10-04

New owner log e4f157d3-ca2e-42c2-904c-affd80e5d371, SHA256
231dfff29e111e3888ac82a30c7a89e755e869e177f3fee63839668bd5b63664,
contains **0 unknown Luna modifier warnings**. Client health probe at lines
1872–1876 confirms all three class globals present. Loading-warning clearance
passes for this supplied session; complete gameplay acceptance does not.

It contains **20 Luna Script Runtime Error records**, all IsAlive nil calls
from the E extension: modifiers.lua line41 (aura predicate) and line57 (recipient
armor/speed property). The current toolkit explicitly marks CDOTA_BaseNPC:IsAlive
server-only, while CBaseEntity:GetHealth and CDOTA_BaseNPC:PassivesDisabled are
both-context APIs. CDOTA_BaseNPC_Hero:GetAgility is also both-context; the Q
scaling helper needs no related change. Online API reference:
https://docs.moddota.com/lua_server/ (client page unavailable during research).
The engine log and API availability establish this source defect; no guessed
identifier, modifier replacement or pcall suppression is used.

Minimal repair: one local is_alive helper in Luna modifiers.lua keeps native
IsAlive on the server and uses replicated GetHealth>0 on the client. Aura and
recipient properties both use it. Break, null/untrained guards and authored
armor/speed/radius remain intact; client checks do not grant gameplay authority.
No network sender, timer, manager, particle/audio edit or other hero change.

Regression reproduces the actual client API surface by omitting IsAlive,
checking live/dead/Break/untrained E property and aura results. A second check
makes server GetHealth throw, proving server lifecycle still uses authoritative
IsAlive. All 19 focused Luna tests and full npm.cmd run check pass with 0 failed
checks; existing 354 hero-kit/22 audit mocks and inventory remain passing.

**IMPLEMENTED BUT NOT ENGINE-VERIFIED** for this lifecycle repair. Owner retest:
fully restart Dota/Workshop Tools, train E and observe armor/speed, death/respawn
and Break; confirm no Luna IsAlive runtime errors or unknown modifier warnings.
Continue Q/R damage, ten-rank and upgrades acceptance independently. Separate
TreeShop/CourierZone and native Boss base unknown-modifier errors remain in the
supplied log and are outside this focused Luna repair. Owner requested motor
tests be performed by the owner; no new game-control command was sent.

# Spellbringer eight-ability review — 2026-10-02

SOURCE_REVIEW: reviewed all eight service/UI paths; movement root cause unresolved.
AUTOMATED_VALIDATION: recorded below after checks. OWNER_RUNTIME: PENDING.
Result: PARTIAL / IMPLEMENTED BUT NOT ENGINE-VERIFIED.

## Reported movement failure

Owner confirmed reinforcement creeps stay still even after selection and a manual
order. This is not merely an absent automatic march. Production creates five
`enfos_wave_*` creatures on the player's team, assigns the selected hero as owner
and calls `SetControllableByPlayer(playerID, true)`. The Boolean means
`skipAdjustingPosition`, not enable/disable control. All selected normal profiles
have ground movement and positive speed. The native unit base has turn rate 0.5;
omitting it is not evidence of zero turning. The order filter rejects only custom
Ascended sell orders. The mouse callback returns false after casting/cancelling.
Future units do not receive hostile lane AI; adding that AI would overwrite
manual orders and introduce the wrong goal/leak behavior.

Installed addon is a junction to this repository's `game` directory; the service
hash matches. This rules out a separate stale disk copy, but not an older loaded
Lua/KV state. No game is running at inspection. Existing `game/dota/console.log`
(last write 01:04 on October 2) contains service initialization but no cast or
reinforcement movement evidence. Its old client-scope `p0_health` failure and
Compendium particle/localization errors cannot establish this bug's cause.

No speculative movement fix is applied. The owner-triggered server Tools probe
records team, owner, control, movement capability/speed, position/navigation,
root/stun/command restrictions, modifiers, abilities and accidental wave AI. It
observes orders in the existing filter for 30 game seconds and reads displacement
one second later. It never changes/creates orders, teleports, selects or spawns.
Repeated orders replace the one pending per-unit sample. Stop/hold, obstruction,
paused simulation or a superseding order can explain zero displacement; it is
an observation, not a failure classification. No received order can mean client
input or engine validation rejected it before the filter.

## Classification and source evidence before presentation repairs

These are original dedicated UI spells, not eight native hero abilities. Keep
their existing design and stable IDs. TUNE applies only to proven resource
loading, event spelling and control-point wiring; no replacement hero kit.

Installed Valve build 6943 / SourceRevision 11069754, read October 2. MCP native
unit/base reads, VScript method metadata, VPK searches and Source2Viewer CLI 19.2
decoded resources provide FILE_VERIFIED evidence, not rendered/audio acceptance.
[Unit KV reference](https://moddota.com/units/unit-keyvalues) consulted for
movement/base class; installed Valve defaults take priority. Workshop indexed
AGHANIM'S PATHFINDERS 2208582400 `scripts/vscripts/ai/boss_timbersaw.lua` shows
ownership/control and a separate initial goal. REFERENCE_ONLY: no code/assets
imported; downloaded source version/license not established. Exact API/asset
names below were verified from installed content, not inferred from icons.

- Rift Surge: TUNE SFX. Current event `Hero_Enigma.DemonicConversion` does not
  exist in the decoded Enigma bank; `Hero_Enigma.Demonic_Conversion` does.
- Arcane Barrier, War Standard, Thorn Idol, Whole Displacement, Reveal and Future
  Reinforcements: TUNE preload only. Silencer, Enigma, Chen, Legion Commander
  and item sound banks are not explicitly precached for these casts. Omniknight
  is already in the shared bank list. `glimmer_cape_initial.vpcf` exists but is
  absent from the explicit particle preload.
- Purification: TUNE VFX binding. Decoded root RingWave reads CP1.x as radius
  (multiplier 0.4) but the UI supplies only CP0. Bind authored radius to CP1;
  the separate range ring communicates the actual full gameplay area. Root
  PreEmission sets CP2 itself relative to CP0; do not override CP2 by guessing.

## Per-ability audit

All casts use server validated ground points, separate mana/cooldown, own arena
for defensive/opposing arena for offensive. Offensive spells are disabled in
co-op. No hero cast animation is authored because these are dedicated UI casts;
forcing a hero gesture would interrupt unrelated play. Summoned units' native
walk/attack/cast animations still require actual Dota verification.

| Stable suffix | Gameplay source review | VFX/SFX source review | Owner runtime |
| --- | --- | --- | --- |
| arcane_barrier | 800 area, 12s; 300 magical block and +40 resistance; physical damage excluded | Modifier-owned glimmer with destroy/release; Silencer.Curse.Cast; preload repair | PENDING block, recasts, visuals, sound |
| war_standard | Stationary neutral standard, 800 aura, 20s, +25% damage/+40 speed; defendingTeam filter | Healing-ward model, LegionCommander.Duel.Cast; generic Enigma acknowledgement | PENDING aura replication, model/idle, audio |
| thorn_idol | Stationary neutral idol, 800 aura, 15s; 25% physical reflection capped at 25% max HP, reflection-loop guard | Pugna-ward model, BladeMail.Activate; generic acknowledgement | PENDING reflects, aura, model/idle, audio |
| rift_surge | Two neutral attackers, nearest central route, 30s, no Life/rewards | Eidolon model, corrected Enigma event, generic acknowledgement | PENDING actual route/combat/walk/attack/expiry/audio |
| whole_displacement | 450 area; non-Boss registered hostiles to own route start, waypoint reset; stationary summons may also match | Chen.TeleportOut per affected unit; generic acknowledgement | PENDING route, stationary-summon eligibility, Boss exclusion, audio |
| reveal | 900 area, 15s; friendly-source thinker, FOW and native truesight aura filtered to own-arena hostiles; thinker removed | Dust radius CP1, own-team ring/event; DustOfAppearance.Activate | PENDING invisibility/immune/FOW, render, audio |
| purification | 600 area; removes three named buffs, 800 pure damage to hostile summons; strong allied hero purge | Omniknight root CP1 repair; Omniknight.Purification | PENDING damage/dispel, aura reapplication, render/audio |
| future_reinforcements | Five controllable +5 profiles, Boss fallback, campaign cap, match scaling, 30s, no gold/XP/Life; specials configured | Native creep model/projectile/SoundSet; Silencer.GlobalSilence.Effect; generic acknowledgement | PENDING reported manual movement, combat, ability commands, walk/attack/cast animations/expiry/audio |

Additional engine/design questions, not silently changed: most acknowledgement
bursts reuse a native Enigma **model-based** particle with a CP1 path and CP0
model initializer while UI only supplies a world CP0. It is not certified as a
ground-space burst. Own-team-only acknowledgements do not prove the opponent
sees critical danger clearly. War/Thorn buffs expose no custom icon. Shared special
creep `TryCast` runs from hostile AI, not allied reinforcement code; allied active
abilities are manually available, automatic casting is not implemented. Do not
claim every transferred special is automatically exercised against neutral PvE.

## Owner acceptance procedure

Use a fresh Tools match. Cast Future Reinforcements, then in **server** console:
`script require("tools/spellbringer_audit").Run(0)` (replace 0 with caster player ID).
Select one unit, move at least 300 traversable world units, attack a neutral wave
unit, stop, hold, and repeat using the group. Retain `[SPELLBRINGER_AUDIT]` and
`[SPELLBRINGER_ORDER]` lines, tested commit/build and cast wave. A client-scope
attempt prints `server Tools context required` and arms nothing.

PASS: correct owner/team, movable=true, positive speed, no unintended restrictions;
move order reaches filter and unit walks to destination; attack damages the
selected wave hostile; stop/hold are respected; five units expire at 30s and
grant no rewards/Life loss. Include early +5, Boss-slot fallback and late profiles,
both teams and terrain near edges. A movement failure remains OPEN until these
observations identify the cause and a focused repair passes retest.

For each of eight skills retain gameplay results, visual and audible observations
and VConsole warnings/errors. Include empty area/valid targets, selected location,
wrong arena/co-op rejection without spending, mana/CD, duration, recast/death/
cleanup, immunity/Boss interactions, reconnect and both-team visibility. Screen
images cannot certify sound. No Dota launch/control or Workshop publication by
Codex; owner performs runtime acceptance per repository workflow.

## Validation and delivery

`npm run check`: PASS, zero failed checks, including 318 hero-kit mock cases and
22 audit regression cases. Targeting, effect cleanup/Purification CP1, all-60-wave
+5 scaling/resource-failure refund and movement-probe tests PASS. The order
observer is protected so a diagnostic exception cannot cancel an ordinary order.
Installed Valve resourcecompiler: PASS, 1 JS compiled, zero failed; retains the
compiler's existing shutdown message `Leaked KeyValues blocks: 162`, not a Lua
runtime result. MCP addon audit: zero findings. No map rebuild/Workshop upload.

[Resource snapshot](SPELLBRINGER_RESOURCE_SNAPSHOT_2026-10-02.json): all five
literal particles, six decoded sound banks, eight sound events and 52 unit
models (48 normal profiles + four Spellbringer units), plus authored projectiles,
exist in installed 6943 VPK. Decoded bank hashes recorded. Source review and
mock regressions cover waves, Boss exclusion/routing, Life/no-reward flags,
economy, mana/CD, co-op, target validation and existing hero kits. No actual
VConsole session at this tested revision; old log warnings remain unclassified
outside this task. Static/mock PASS never promotes the movement report,
rendered effects, animations or audio to ENGINE_PASS.

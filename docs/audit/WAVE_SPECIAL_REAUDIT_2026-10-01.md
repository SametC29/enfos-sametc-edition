# Special-wave distribution and execution re-audit

Owner evidence: screenshot of wave 49 shows multiple visible Brewmaster Storm
creeps and an empty selected-unit ability bar. This is an observation, not proof
that every unit or native ability failed. No new Workshop publication authorized.

## Reproduction and causes before repair

Production Configure intentionally returned for every hostile after the first
two per team/wave, except waves 11/21 with one-quarter invisibility. Thus wave
49 had only two invisible units; the rest were genuinely ordinary visible
attackers. All 44 special normal-wave kits were similarly restricted, so most
creeps in the owner's special waves never received their authored mechanic.
Earlier mock tests explicitly asserted this limited distribution and therefore
did not certify the behavior the owner expected.

TryCast required missing health for every friendly-target ability, including
non-healing buffs, and searched only heroes for hostile casts despite normal
route AI also attacking summons. No-target spells without an exposed radius
used a 250-unit trigger, which can miss a ranged creep's actual engagement.

The invisible modifier chose its state from a raw custom creation field, with
no explicit client synchronization and no invisibility-level property. A client
that has no custom kind field returns an empty state table. This is a client
contract weakness, not proof from the screenshot that the server state failed.
ModDota documents stack counts as automatically synchronized to clients:
https://moddota.com/abilities/server-to-client . Installed MCP API documentation
and ModDota declarations establish stack/invisibility-property methods.

## Classification and intended repair

TUNE all 44 special kits: every authored creep receives its wave's kit; leave
the four introductory waves basic. Preserve native ability identifiers/ranks
and existing data-driven mechanics. Retain shared cast/control cooldowns so
distribution does not permit unlimited simultaneous control casts. Children
remain excluded from recursive kit assignment and capped/timed as before.

TUNE invisibility: synchronize the kind through modifier stacks and declare the
native invisibility-level property in addition to the invisible state. Keep
true-sight compatibility and avoid an undetectable visibility override.

PVE-CONVERT target selection: separate healing from buffs; use the actual caster
team for friendly searches, include hero/summon targets, and use an engagement
trigger for zero-radius no-target support abilities. Bound per-unit target
searches, retain shared team/wave/ability cast spacing, and validate native target
type filters. Add aggregate configuration evidence instead of per-unit log spam.

Native definitions/resources remain the installed Valve snapshots. There is no
copy of third-party game code and no change to playable hero skills.

## Acceptance status

Repair implemented; automated checks pass. Required checks: every unit in every special wave
receives exactly its authored kit; early waves remain basic; client-side modifier
state survives empty creation fields; full-health buff targeting, healing-only
injured targeting, hostile summons, shared cast gates and child caps are tested.
Actual Dota/VConsole behavior remains pending owner testing; do not claim
engine success from mock ability handles or native KV presence.

The complete static inventory is `WAVE_SPECIAL_CONTRACTS_2026-10-01.json`,
regenerated/checked by `node tools/wave_special_audit.mjs --check`: 48 normal
profiles, 44 special kits, four intentionally basic introductory waves. All
29 native ability definitions were re-read from the installed VPK with no
missing identifier. Existing data-driven passives have Passive modifier blocks.
Vhoul/spider native Envenomed Weapon at rank 1 has zero direct DPS and 75%
regeneration reduction; this is explicitly reported, not called damage-over-time.
Native numbers/identifiers are preserved in this repair.

`tests/wave_rework.lua` now exercises every unit in all 44 kits instead of
asserting the old two-specialist cap. It tests empty client creation parameters
with replicated stacks, invisibility level, full-health friendly buffs, injured
healing targets, native hero/basic target types, shared cast spacing, bounded
searches, no-target support activation, and existing child limits. Runtime audit
tests prove missing rank/modifier/invisibility state is reported rather than
hidden behind a successful configuration marker. Spellbringer +5 regression
tests still cover all 60 waves. Full working-tree checks pass; isolated-index
scoped checks pass, with the previously documented unrelated HEAD baseline
issues excluded from claims of engine/release acceptance.

For an owner-run, one-shot VConsole audit in the running server:

```
script require('waves/special_creeps').Audit(require('waves/wave_manager'))
```

It emits per-team alive/special counts, missing ability ranks or trait modifiers,
and expected/actual server invisibility counts. It performs no periodic global
scan. True sight can reveal an invisible unit, so the server invisibility count
alone does not prove what a particular player sees. The old desktop log1.txt
was no longer present at its supplied path during this re-audit; no runtime log
or screenshot beyond the owner-provided wave-49 image was treated as evidence.
Test a fresh local Tools match after this repair; no Workshop upload occurred.

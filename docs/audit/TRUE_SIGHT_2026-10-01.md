# Spellbringer True Sight reveal audit — 2026-10-01

Status: **IMPLEMENTED BUT NOT ENGINE-VERIFIED**.

Latest owner retest still failed. The manual tick application below is now
superseded by an engine-managed native aura. See
[Reveal native aura follow-up](REVEAL_NATIVE_AURA_2026-10-01.md) for current
implementation, evidence, tests and pending engine acceptance.

## Follow-up: confirmed defensive-team routing regression

The previous static conclusion below was incorrect. `CanCast` validates Reveal
as defensive and only accepts the caster's side, but `CastReveal` passed the
opposing defending-team ID. Neutral creeps are indexed by the team they attack,
so the thinker searched the wrong registry. The old test set thinker fields
manually and did not exercise `CastReveal`, masking this disagreement.

`CastReveal` now passes the caster's defending team; the thinker's omitted-KV
default does the same. `tests/reveal_defensive_team.lua`, run by
`tools/tests/reveal_defensive_team.test.mjs`, exercises both teams through the
cast, creation and tick path and the omitted-KV default. PASS in the mock.
This is a TUNE/bug repair of target routing; radius, duration, engine True Sight,
mana, cooldown and identity are unchanged. No reference code was imported.
The earlier opposing-team description and root-cause conclusion below are
historical and superseded. Actual visibility and targetability remain pending
owner Dota tests for both teams, expiry, outside-radius units and Fog of War.

## Request and expected behavior

Spellbringer Reveal should let the casting team see invisible wave units in a
900-unit area for 15 seconds. It must ignore the opposing team's neutral-hostile
units and should not grant detection outside the marked area.

## Current implementation and evidence

- `CastReveal` creates `modifier_spellbringer_reveal_thinker` at the selected
  world point with caster-team and opposing-defending-team IDs.
- On creation, the thinker calls `AddFOWViewer` for the caster's team at the
  reveal point for the full duration, then checks every 0.5 seconds.
- Each check asks the authoritative wave registry for alive hostiles belonging
  to the opposing defending team and within the radius. That registry includes
  neutral-team wave units and tracked Spellbringer summons; it does not rely on
  `DOTA_UNIT_TARGET_TEAM_ENEMY` relative to neutral units.
- A matching hostile receives engine `modifier_truesight` for 0.75 seconds,
  refreshed at 0.5-second intervals. The current Dota VPK lists sentry wards as
  `npc_dota_ward_base_truesight`; Dota's native Sentry/Gem True Sight uses the
  same hidden enemy aura debuff. The active reveal also grants team vision
  through `AddFOWViewer`.
- Current mocked regressions assert that an in-radius invisible-assassin unit
  and tracked hostile summon receive the modifier, while out-of-radius and
  opposite-defending-team units do not. They also verify that the reveal
  thinker grants the casting team its configured FOW viewer and refreshes
  detection at 0.5-second intervals for the intended defender team.
- The project does not assign `MODIFIER_STATE_TRUESIGHT_IMMUNE` to the Enfos
  Assassin creep. The only project usage found is a Phantom Assassin hero kit
  effect, so it does not explain this creep report.

## Root-cause status

Static inspection finds the expected reveal path and no obvious team/radius
filter error. The user's in-game report conflicts with that static result, so
the runtime root cause is not established. Possible remaining points to verify
are whether current Source 2 honors direct application of the engine-owned
`modifier_truesight` to these neutral custom units, whether their invisibility
modifier loads as expected, and whether the HUD's shown vision is limited by
Fog of War/team assignment.

## Verification

- `tests/audit_regressions.lua`: PASS (mocked unit registry and FOW call;
  does not simulate Fog of War or actual invisibility rendering).
- Current `npm run check`: PASS (includes the reveal regression; engine behavior
  remains uncertified).
- Current base-game sentry unit lookup: `npc_dota_ward_base_truesight`.
- Workshop Tools/VConsole test with an invisible `enfos_creep_assassin`,
  cast-position recording, team vision state, and `MODIFIER_STATE_INVISIBLE` /
  `MODIFIER_STATE_TRUESIGHT_IMMUNE` inspection: **PENDING OWNER TEST**. Per
  owner direction, Codex must not launch or interact with Dota.

Do not call this issue fixed until the invisible creep becomes visible and
targetable in an actual match, without revealing units outside the spell area.

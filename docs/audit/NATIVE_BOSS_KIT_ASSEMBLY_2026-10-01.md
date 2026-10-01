# Native Boss kit assembly — 2026-10-01

Scope: Desktop item 7. Classification: KEEP native hero Q/W/E/R behavior,
including passives. The owner explicitly chose original kits with passives on
2026-10-01. No player hero kit, ability KV, model, sound or particle changed.

## Installed-data failures

The previous builder indexed AbilityDraftAbilities.Ability1 through Ability4.
Installed Valve hero files contradict that assumption:

- Lina has Draft entries 1/2/3/6, so its ultimate was treated as missing.
- Crystal Maiden has three Draft entries. Its native Ability3 is Brilliance
  Aura, and its Bot.Build trains that aura; its ultimate remains native slot 6.
- Luna's Draft includes Lunar Orbit, while Bot.Build trains Lunar Blessing
  instead. Following that build alone never trained Orbit.

The [source snapshot](NATIVE_BOSS_KIT_SNAPSHOT.json) records all twelve selected
heroes' source path, SHA256, native slots, Draft entries and bot rank sequence.
Data came directly from the installed Valve VPK, without launching Dota or
importing another custom game's implementation. This snapshot is evidence of
that installed build, not an automatically current upstream cache.

## Repair

Sort actual numbered Draft entries rather than requiring consecutive keys.
If fewer than four exist, add only an omitted native hero slot that the same
Valve bot build trains. Order the result by native hero slots where available.
Reject kits that still do not resolve to exactly four unique abilities.

Apply Valve's rank order first. Allocate remaining ordinary level budget to the
verified kit, respecting native rank maxima and GetHeroLevelRequiredToUpgrade.
This avoids leaving current spells untrained because Valve's bot list still
references an omitted talent or a different ability. The allocation loop is
bounded by the level cap and stops when no rank can be upgraded. It does not
grant talent points, account progression or extra player power.

Current VScript metadata confirms GetHeroLevelRequiredToUpgrade. Related cast
guards use verified GetCurrentActiveAbility/IsInAbilityPhase; item mute uses
IsMuted. Native assets/behavior remain owned by the native ability implementation.

## Verification and limits

`tools/native_boss_kit_audit.mjs` runs production Prepare against all twelve
recorded native data shapes. Every kit resolves to four trained abilities at
level 50 and receives six native build item grants. Each ability must have
recorded Draft provenance or be both a native hero slot and a bot-trained
omission. The test deliberately reproduced the Luna zero-rank failure before
the fallback repair. It does not prove native cast legality or six occupied
inventory slots after consumable Shards resolve in the engine.

The 44-case Lua suite also covers Lina's slot-6 ultimate, CM's omitted aura,
and a next-rank hero-level gate blocking fallback upgrades. The standard check
now includes the twelve-kit audit. Mocks model rank maxima; they do not certify
actual engine ranks, innate/sub-ability dependencies, VFX/SFX, Shard/Scepter,
bot intelligence or item effects. Local runtime acceptance remains pending the
owner, particularly Boss waves 25, 40 and 55. No game launch or upload occurred.

## Native toggle AI follow-up

The generic AI used to skip every TOGGLE ability. It now issues one native
no-target toggle order when combat presence changes. A dedicated hostile lookup
prevents a friendly self-target from keeping a heal toggle on forever. Enabling
obeys IsFullyCastable; disabling an active toggle is still attempted with low
mana. This preserves the native spell's effect and resource behavior rather
than replacing it. Verified VScript metadata exposes GetToggleState.

The standard audit also runs tests/native_boss_toggles.lua: it verifies resource
gating, enable/stable/disable orders, and that a friendly spell's self-target is
not treated as a nearby defender. Actual Voodoo Restoration healing, animation,
sound and mana drain remain pending owner engine tests (Boss wave 50).

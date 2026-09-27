# Solo onboarding and Ascended correction — 2026-09-27

User live feedback: repeatedly dying in solo, duplicate-looking Ascended items,
and a Workshop Tools "Legacy Compiled Data" warning.

## Compatibility warning

The dialog reports legacy compiled map data and future removal of compatibility.
It is not the earlier NVIDIA access error. The restored map currently loads;
there is no proof it will remain compatible with future engine updates.
Do not use Fix Selected Assets against the retired flat VMAPs. They have been
archived outside `content/maps`. A durable fix requires the correct editable map
source and a tested rebuild, or an original replacement. This is still open.

## Solo balance seed

**Superseded later the same day:** user prefers powerful heroes over weakened
enemies. See [hero power](HERO_POWER_2026-09-27.md). Enemy solo multipliers and their
fade-out below are historical; preparation timing and difficulty factors remain.

`waves/balance_config.lua`, version `2026-09-27-solo-1`, snapshots difficulty and
whether exactly one playing-team member exists before the first preparation.
Spectators are not counted. A disconnect cannot toggle assistance mid-match.

- Waves 1–10 in solo: enemy HP ×0.65 and base attack damage ×0.60.
- Waves 11–19: these factors taper linearly; wave 20 onward uses normal factors.
- Bosses also receive these factors after their existing player-count HP scaling.
- Solo first preparation: 45s; preparations before waves 2–10: 20s; later: 15s.
- Early solo non-Boss batch intervals: at least 5s (four batches span 15s).
- Wave 1 still plans 20 enemies. Gold/XP, Life loss, caps and Boss-only count unchanged.
- A localized HUD line indicates solo assistance. PvEvP and multi-player co-op
  receive no solo assistance.

Difficulty factors are centralized in the snapshot: Casual HP 0.75 / attack 0.80,
Normal 1/1, Hard 1.25/1.10, Nightmare 1.5/1.20, Hell 2/1.35. Previously difficulty
scaled only HP (Casual 0.85). Setup Casual HP display now matches the new factor.
These are provisional seeds, not a claim that 60 waves are balanced. Spell damage
inside bespoke ability scripts is not normalized by the base-attack multiplier.

Example: Normal solo wave-1 soldier has 182 HP, 10–14 base damage instead of
280 HP, 18–24 damage. Ranged unit: 130 HP, 13–16 damage instead of 200 HP, 22–28.

## Ascended truth and purchase protection

The shop assigned `item.base` to BOTH pictures; both surfaces identified the base
item. The upgraded picture and hover tooltip now use the actual Ascended ID.
Stock art may still match deliberately; tooltip identity and stats are distinct.

The duplicate client catalog is removed. All 31 entries (30 planned Ascended plus
Blessing), prices and availability come from the authoritative server table.

29 entries contain passive numeric properties but lack their promised special
mechanics/base-item behavior. Their cards remain visible as unavailable and the
server rejects purchases before touching inventory or Lumber. Existing owned
copies can still use the pre-existing sellback path. Thornplate's working damage
reduction prototype and Aghanim's Blessing remain available; this is **not** a
completed launch catalog.

`tools/item_tooltips.mjs` generates exact implemented passive-stat descriptions
from KV for all four languages. The previous design text is preserved under
`_DesignDescription`; it is not shown as working behavior. Thornplate explicitly
describes 25% damage reduction for 5.5s and does not claim reflection. Missing
active mechanics are not implemented by this UI fix.

## Validation

- 49 existing Lua behavior tests, 9 runtime tests, 14 audit regressions: 72 total.
- 7 hero-selection, 2 shop interaction and 2 KV JavaScript tests: 11 total.
- Full repository checks: 0 failures; item text drift is now a checked invariant.
- Modified Panorama resources compiled with no failures; map integrity still matches.
- Latest solo balance and shop changes still require a fresh match playtest.
  The previous confirmed Luna pick and restored-map screenshot predate this balance seed.

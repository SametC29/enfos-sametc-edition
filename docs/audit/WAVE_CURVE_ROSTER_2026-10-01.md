# Wave curve and native roster foundation

Status: foundation committed in d14edc7; spawning and special mechanics integrated
in aca4251; Spellbringer, localization and effects completed in 9e14de5.
Automated contracts verified. The foundation commit alone does not activate the
new wave behavior; the subsequent integration commits do.
No Workshop publication or live promotion is authorized.

## Evidence and decisions

The owner desktop list is identified by its SHA-256 in
`NATIVE_WAVE_ROSTER_2026-10-01.json`. Every normal-wave model and inherited
attack/projectile presentation was read from the installed Valve `npc_units.txt`
and its compiled model/projectile presence checked against `pak01_dir.vpk`.
The owner authorized distinct verified native alternatives for unavailable or
duplicate models. Different creep names do not establish different models.
The authored campaign has 48 normal waves and 12 Boss-only waves; every fifth
slot is deliberately absent from the normal roster. Existing native hero Boss
identities remain separate.

## Mathematics

For wave w clamped to 1..60, L=max(0,(w-40)/20):

- HP=floor(120*1.055^(w-1)*(1+1.8*L^3)).
- Base attack=floor(10*1.037^(w-1)*(1+1.25*L^2)).
- Armor=floor(12*(w-1)/59), speed=floor(270+80*(w-1)/59).
- Magic resistance=floor(25*(w-1)/59).

Additional solo opening factors rise linearly from HP 0.75 and attack 0.70 at
wave 1 to 1.0 at wave 30. Existing difficulty and player-count factors remain
integration responsibilities. Boss HP multiplier rises from 0.80 at wave 5 to
2.50 at wave 60; base attack from 0.85 to 1.75, using powers 1.5 and 1.3 of
normalized Boss progress. These are base-stat multipliers, not a claim that
every native spell's damage changes by the same factor.

Spellbringer's future lookup uses current wave +5. A Boss slot uses the preceding
normal creep appearance, with stats from the numeric +5 wave; it does not summon
five hero Bosses. After campaign end, stats cap at 60 and appearance at 59.

## Acceptance evidence

`tests/wave_curve_roster.lua` exercises all 60 steps, monotonic stats, the late
acceleration, solo bounds, all 48 unique models, all Boss exclusions and every
future lookup including campaign-end handling. Its Node wrapper treats stderr
or a missing success marker as failure even if the Lua interpreter exits zero.

These checks prove data contracts. They do not certify engine loading, rendered
models, native skills, Reveal interaction, effects or gameplay balance. Actual
Dota/VConsole verification is pending owner testing. Special-wave preservation
(stun, invisibility, silence and related mechanics) is a required integration
gate, recorded in `WAVE_REWORK_GOAL_2026-10-01.md`.

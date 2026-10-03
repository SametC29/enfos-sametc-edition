# Bristleback native-first source review

Status: SOURCE REVIEW IN PROGRESS; all engine acceptance remains PENDING.
Owner defers live testing and authorizes sequential source work. This record
supersedes the older blanket PVE-CONVERT classification, not its historical tests.

## Evidence and dependency boundary

Installed build 6943, SourceRevision 11069754, Oct 01 2026. Exact
`scripts/npc/heroes/npc_dota_hero_bristleback.txt` SHA256:
`2d8ca6edbae9a580a2faa49f798848d7beef87109dbac8c00e59f34bd68f7a34`.
[Extracted ability definitions](BRISTLEBACK_NATIVE_SOURCE_2026-10-04.json)
were observed 2026-10-03T23:38:01.492Z. Duplicate bot-loadout keys prevent
parsing the whole hero file with the strict project parser; only the balanced
AbilityDefinitions subtree was parsed. Do not weaken production KV validation.

Production: `npc_heroes_custom.txt` assigns Q/W/E/R/D stable IDs; ability KV
and the Bristleback section of `abilities/pve_kits.lua` implement the kit.
E and R call the same local Quill helper; R calls the local Goo helper using Q.
Consequently migrating Q or W alone leaves R/E applying obsolete custom stacks.
Warpath listens to ordinary cast events and has no dependency on those helpers.
The existing spawn service owns free D rank and points; Health already reports
the selected hero after initialization. Neither needs a new manager or timer.

## Decision matrix, recorded before implementation

| Slot | Exact native counterpart | Class | Preferred final implementation and reason |
| --- | --- | --- | --- |
| Q `enfos_bb_viscous_nasal_goo` | `bristleback_viscous_nasal_goo` | TUNE | NATIVE with minimal Enfos rank integration only if required. Enemy hero/basic targeting and armor/slow stacks already fit waves. Preserve projectile, spell block and native impact. Keep ten authored ranks; translate current numerical intent into verified native keys rather than duplicate debuffs. |
| W `enfos_bb_quill_spray` | `bristleback_quill_spray` | TUNE | NATIVE plus a minimal strength-scaling extension only if justified by read-path evidence. Native physical area damage and quill stacks fit PvE. Source declares projectile_speed 2400 and max_damage 500; restoring native timing/cap must be explicit. No blanket custom spray rewrite. |
| E `enfos_bb_bristleback` | `bristleback_bristleback` | TUNE | NATIVE with the linked native W provider. Directional reduction and rear retaliation already serve PvE. Preserve native Scepter activation; verify native fixed-name lookup before choosing an alias versus hidden provider. |
| R `enfos_bb_hairball` | `bristleback_hairball` | TUNE | NATIVE with minimal Enfos controller if needed to keep the existing paid R at levels 5–50. Native Hairball is shard-granted, hidden, MaxLevel 1, with projectile_speed 1200. Visibility, unlock and linked Goo/Quill must be integrated coherently; never treat a rank-10 declaration as proof that shard ownership is overridden. |
| D `enfos_bb_warpath` | `bristleback_warpath` | TUNE | NATIVE alias. Preserve authored ten-rank damage/movement curves and Enfos D ownership; explicitly override the native ultimate type to BASIC. Engine owns stacks, Break, buff presentation and cleanup. No PvP-only component justifies a Lua replica. |

Native Prickly/Brawler's Grit definitions are present but are not new paid slots
or silently added level-scaling bonuses. Talents remain hidden. Bosses use ordinary
ability immunity/armor/Break rules; no new Boss exception or wave/AI change.

## Confirmed source differences and unresolved engine questions

- Q applies Goo immediately and attaches an effect to the target: no tracking
  projectile. Custom keys duration/armor_reduction/max_stacks/base_slow_pct differ
  from native goo_duration/base_armor/armor_per_stack/stack_limit/base_move_slow.
- W selects `FindModifierByName` without caster ownership, so its source can read
  another Bristleback's custom quill stack. It immediately damages a radius and
  refreshes the whole stack duration. Its cap is ten stacks; native exposes a
  damage cap rather than this max_stacks key. These are not native equivalents.
- W/E/R emit `Hero_Bristleback.QuillSpray.Cast`, while the installed native
  AbilitySound is `Hero_Bristleback.QuillSpray`. Sound-bank declaration must be
  checked before calling this a missing-event runtime failure.
- E subtracts one threshold and emits one spray per damage callback. Native
  source exposes quill_release_interval 0.1 and Scepter five-spray activation;
  these cannot be established by the existing single-proc mock.
- R has no Hairball projectile/travel and cannot inherit its native linked
  callbacks while Q/W remain custom. Existing generic ultimate Scepter amp/CD
  and Tank Shard health/reflection are Enfos deviations, not native upgrades.
- D custom buff refreshes the duration of all stacks on every cast. The native
  stack lifetime must be verified in Dota; do not retain the custom callback to
  fabricate native equivalence. Native key is move_speed_per_stack, not
  ms_per_stack. Native facet aspd_per_stack defaults to zero; pin zero for the
  damage/movement version rather than silently selecting Berserk.
- Existing R descriptions say two Goo stacks throughout, but KV grants three
  at ranks 6–10. Repair all four languages in the linked Q/W/E/R source unit.

## Staged implementation and acceptance

First source unit: independent native D alias; remove only its obsolete Lua
classes/links and their imitation-only tests. Use reviewed native exceptions
in audit tooling, with explicit rejection of ScriptFile/native-ID shadowing.
Preserve current generic Shard behavior until the linked kit's native upgrade
integration is implemented; record that temporary boundary, never certify the
whole hero from a D-only test. Q/W/E/R source migration remains open.

Then complete the linked Q/W/E/R providers, native upgrades and strength tuning,
matching four-language tooltips, cold-start resource ownership and client-safe
bootstrap. Do not advance past known actionable Bristleback source defects.

2026-10-04 D source implementation: `enfos_bb_warpath` now uses native
`bristleback_warpath`, explicit BASIC type, non-dispellable/Break metadata and
native `move_speed_per_stack`/`aspd_per_stack` keys. Authored damage/movement
curves, ten ranks, ten-stack cap and ten-second tuning are preserved. Removed
both custom modifiers and cast/buff implementation; generated obsolete modifier
tooltips disappear, while all four ability descriptions retain the same numerical
values using the native key. The installed archive confirms
`soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts_c`; its logical
bank is now included in the existing startup list. Explicit Warpath particle
precache remains; native code owns presentation and cleanup. These are source
changes, not proof of stack expiry, C++ rank indexing or sound playback.

Focused evidence: two native-source contracts pass; 351 current hero-kit Lua
regressions pass in the mock engine, including contributor Lich tests. Removed
two custom Warpath tests because they executed deleted Lua replicas, not native
C++. Source-contract tests check native ownership, verified fields, stable D/R
slots, ten-rank curves and rejection of unreviewed/ScriptFile aliases. Full
source checks at this unit's final validation boundary: `node tools/checks.mjs`
PASS, zero failed checks. This does not establish native runtime acceptance.

Pending owner tests: full restart after structural KV changes; ranks 1/10, D
free rank/points/HUD, cast stacks and expiry, Break/illusion/death/reconnect,
multiple Bristlebacks, native projectiles and target loss, R radius reticle,
Scepter/Blessing/Shard, normal creeps and bosses, VFX/SFX and clean VConsole.
Mocks and static source checks cannot close any of these engine cases.

## External references and imports

[ModDota ability KV](https://moddota.com/abilities/ability-keyvalues), accessed
2026-10-04: native BaseClass aliases inherit exposed fields; internal C++ code
is not editable. Its skeleton documents DOTA_ABILITY_TYPE_BASIC. This proves
the authoring pattern, not fixed-name dependencies or native ten-rank support.

Reference corpus search for bristleback_warpath found Aghanim's Pathfinders
(Workshop 2208582400), `scripts/npc/heroes/bristleback/npc_abilities_bristleback.txt`
lines 226/231 and `scripts/npc/heroes/bristleback/bristleback.txt` line 12:
it assigns a custom Lua Warpath. REFERENCE_ONLY; no license-verified import,
no copied code/assets and no claim that its implementation is current native.

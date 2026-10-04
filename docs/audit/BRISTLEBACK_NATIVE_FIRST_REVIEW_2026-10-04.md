# Bristleback native-first source review

Status: NATIVE SOURCE IMPLEMENTED; final validation recorded below.
All engine acceptance remains PENDING; this is not whole-hero runtime certification.
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

## Linked Q/W/E/R source implementation, 2026-10-04

The former instant damage/debuff/retaliation implementation is removed. Four
paid ten-rank controllers dispatch Q/W/E/R into native code; they do not call
ApplyDamage, FindUnitsInRadius, create particles or implement Goo/Quill modifiers.
Native Q/W/E use exact native IDs so linked callbacks can resolve them; engine
read-path and fixed-name behavior still require owner verification. Hairball has
one reviewed native alias `enfos_bb_native_hairball`, rank one, hidden and with
IsGrantedByShard explicitly zero. Hairball is already paid R, so buying Shard
must not expose another free active. Native R's linked Q/W providers remain
the exact Dota IDs. Native providers stay rank one (E zero until trained), while
a single server/client special-value bridge reads raw paid ranks 1–10. Direct
native callbacks retain ordinary targets, projectile/impact, immunity, armor,
stack ownership/lifetime, VFX/SFX and cleanup; none is ENGINE_PASS here.

Goo's base armor is zero and per-stack armor uses the prior authored curve;
slow/duration/cap preserve numerical intent. Quill damage and stack damage retain
the previous Strength coefficients through native special queries. Restored
native max_damage=500 replaces the custom ten-stack cap; this is an explicit
native-first balance change. Native projectile speeds remain untouched. Hairball
keeps authored radius/cooldown and correctly describes two then three Goo stacks.
Its GetAOERadius returns the paid radius for the cursor reticle. Native Snot
Rocket goo_radius is pinned to zero, and no new innate/talent/facet bonus is added.

E's dynamic native behavior exposes Scepter activation, with native five sprays,
24-second cooldown and 125 mana. Generic Hairball +40% damage/-25% cooldown is
removed only for the Enfos BB kit; unrelated heroes retain their existing rules.
The existing Tank Shard +350 health/15% reflection remains an explicit Enfos
extension: native Shard's sole Hairball unlock would duplicate the paid R slot.
See the provisional upgrade entry in DECISIONS_OPEN_ITEMS.md. No native Shard
bonus is advertised on Hairball; D retains the existing Tank Shard tooltip.

The current spawn/passive service restores these providers idempotently, without
new points, managers, listeners or timers. Rank-up refresh uses native intrinsic
names returned by the engine, not guessed modifier IDs. Client registration loads
classes and one link only; client special getters do not read server-only handles
or IsAlive. The existing order filter relays W autocast only for its owning
player; native cast events synchronize paid cooldown. Manual casts do not spend
native mana again or synthesize a second ability-cast event. Native autocast mana,
cooldown timing and Warpath interactions remain engine questions.

Installed VScript API evidence: CDOTA_BaseNPC:SetCursorCastTarget and
SetCursorPosition are server-only; CDOTABaseAbility:GetBehavior is both-context;
ToggleAutoCast is server-only; dotaunitorder_t includes CAST_TOGGLE_AUTO.
GetStrength belongs to CDOTA_BaseNPC_Hero and is both-context (the base-NPC
method lookup is absent). No guessed OnToggleAutoCast callback was used.
Additional corpus Hairball hits: Boss Survival Adventure, Workshop1571786267,
scripts/vscripts/abilities/bosses/bristleback/bristleback.lua:546.
REFERENCE_ONLY; no imported code/assets or engine proof.

Cold-start resource ownership: the previously verified Bristleback sound bank
and Goo/Quill/Warpath assets remain. Installed archive path search confirms the
Hairball, Hairball trail/splat/model and rear-damage parent particles; these six
are explicitly precached because providers are added after spawn. Engine owns
CPs and resource lifetime. Archive presence is not visual/audio acceptance.

Focused checks: seven native/integration tests pass; 346 existing Lua kit
regressions pass. Shared client test now covers all six Luna/SF/BB modifier links
once and rejects server services. Reviewed provider smoke dispatch passes ranks
1–10 without pretending to execute C++. Removed five obsolete custom BB tests;
replacement integration tests independently assert cursor identity, source curves,
zero untrained scaling, provider caps, autocast ownership and no local damage/search.
Structural audit now follows explicitly named native override-reader modules;
its unused-field hints are not proof that native code reads those specials.

Final source validation: general `tools/checks.mjs` passes gameplay, Lua smoke,
rank/point, localization, client registration and integration tests; its remaining
stale generated-dossier check was fixed by regeneration and independently passes
`node tools/hero_reference_docs.mjs --check`. Focused source/client/content
suite: 110 tests, zero failures. No Dota launch or gameplay MCP was used.

Remaining acceptance: owner full restart and Q/W/E/R/D visual/audio/VConsole,
native query versus actual damage at ranks 1/10, maximum Quill damage, multicasters,
Goo spell block/reflection, travel/target loss, Hairball without/with Shard,
Scepter/Blessing activation and interruption, Break, illusions, death/reconnect,
autocast mana/cooldown, dense waves and the rank/point HUD. Source work may proceed
to Slark after this unit's checks; none of these deferred cases is silently passed.

# Tidehunter individual review — source review complete / engine pending

## Current source-review conclusion — 2026-10-02

SOURCE_REVIEW: COMPLETE for the current authored five-slot implementation.
AUTOMATED_VALIDATION: PASS at gameplay revision `447084a` (312 hero behavior
mocks; full repository checks zero failures). OWNER_RUNTIME: PENDING. This is
not whole-hero DONE, native parity, final balance approval or release permission.
The early findings table below is historical; this conclusion and dated repair
sections supersede its generic upgrade and instant-Ravage descriptions.

| Slot | Current reviewed contract | Remaining engine acceptance |
|---|---|---|
| Q / Gush | PVE-CONVERT. Ordinary enemy hero/basic tracking projectile, speed2500, absorb on cast; impact validates living hostile target/source. Damage = ranked110–350 + Strength. Armor loss4–10, slow30–45%, duration4.5s. Scepter switches to point-target piercing range2200/radius260/speed1500; base cooldown at most7s, retains rank10's6s. Cast metadata owns native animation/sound; ProjectileManager owns travel. | Client behavior switch, dodge/reflect/absorb, immunity/resistance, hit presentation, cold-start audio and in-flight source/item loss. |
| W / Kraken Shell | PVE-CONVERT of native-theme defense, not installed active Kraken. Learned live source and Break gates; block20–80 +5% Strength, regen5–20. Positive received damage accumulates toward450, resets after7s inactivity; remainder survives cleanse. Strong purge, guarded re-entry. Shard triggers learned Anchor at50% damage at most once/5 game-time seconds. | Physical block event ordering, basic/strong purge, self/allied/reflected-damage policy in engine, pause/death/refresh, reactive gesture and cleanup. |
| E / Anchor Smash | PVE-CONVERT. Radius400; physical average attack damage + ranked80–230 +75% Strength. Base attack damage reduction40–70% for6s; query includes immune enemies by existing Enfos policy. Live handles revalidated after synchronous damage. Native anchor root receives the same radius in CP2; finite index released. | Actual spell-immunity and base-damage-property behavior, status resistance, active/reactive visual edge, sound/animation, movement during cast. |
| R / Ravage | PVE-CONVERT. Fixed-origin radius1000, five annular impacts at0/.35/.7/1.05/1.3s; one hit per unit per cast. Damage200–450 +2×Strength, stun2.4–3.2s with Boss cap1s before engine resistance. One finite game-time context per cast; invalid/dead source stops it. Five native particle CP radii match the same layout. | Real collision/visual synchronization, strong dispel/status resistance, immunity, movement/overlap/pause/lag/death and finite effect termination. Authored bands are not native continuous speed725 parity. |
| Fifth / Colossal Presence | REPLACE: distinct Enfos passive, not native Innate. Learned-source/Break gated health50–200 and armor1–10; enemy hero/basic aura radius900, slow/base-damage reduction5–15%. Values are read live per property callback; no cached rank-specific values, custom thinker or summon. Uses default engine aura search/purge/linger/multiple-caster semantics, without overriding them speculatively. | Aura fade/refresh under Break, immune targets, same/other caster overlap, death/respawn, health recalculation on rank changes, client property tooltips and reconnect. |

Shared audit boundaries: no talent/account grants added; ordinary match levels
and free fifth rank remain owned by the existing match-level/innate systems.
Tidehunter-specific Scepter and Shard replace the generic amplification/CDR and
tank HP/reflection hooks in `heroes/aghanim_manager.lua`; native item stats are
separate. No summon manager, new event listener or per-frame global scan is
introduced. Q/W/E/fifth use ten ranks with1/1 gates; R uses5/5 through level50.
Ten-rank HUD/49-point budget and real passive refresh remain owner tests.

The source review records existing self/allied/reflected-damage accumulation
and default aura/illusion eligibility instead of claiming unseen native engine
behavior. No further numerical/design change is made from those uncertainties.
Use [the focused owner checklist](TIDEHUNTER_RUNTIME_CHECKLIST.md) to supply
evidence; reopen specific repairs on a failure. Other heroes may proceed while
this engine acceptance remains explicitly pending.

## Anchor Smash radius-control decision — 2026-10-02

Decoded installed 6943 Anchor root and its five direct children from the existing
Source2Viewer 19.2 extraction. Rings and warp use C_INIT_InitFloat with
PF_TYPE_CONTROL_POINT_COMPONENT / PF_MAP_TYPE_DIRECT / CP2.x; wake, splash and
small ripples also consume CP2.x. Production ApplyAnchorSmash creates/releases
the root without setting CP2 at all. This is a proven missing resource input;
actual visible malfunction has not been owner-reproduced. Rings decoded SHA256:
010ab5ed522f55d3642a5e7dd97a20b8ad18290ca80a365c28473aa1506602fe.
TUNE presentation only: set CP2.x to the same named radius used by the damage
query, for both active and reactive Shard casts. Preserve finite effect ownership,
existing attachment, sound, damage/debuff and single shared implementation.
Search for the exact particle plus SetParticleControl returned no indexed web
example; decoded installed resources are stronger input evidence than guesses.
Add a pre-change regression to require radius wiring for normal and half-damage
calls. Actual render size, movement/attachment and lifetime remain OWNER_RUNTIME.

Result: the pre-change mock failed on missing CP2.x. ApplyAnchorSmash now reads
the named radius once, supplies it to CP2 and uses it for the enemy query. The
same path covers active 100% and reactive 50% damage casts; regression varies
450/850 radius and checks both finite roots release their indices. Full checks
pass with zero failures. No new particle, gesture, timer or numerical tuning.
Owner must compare visual edge versus actual hit edge at low/max rank and after
Shard cleanse, repeat while moving, then check cold-start VConsole/audio/cleanup.

## Visible modifier localization follow-up — 2026-10-02

Classification remains PVE-CONVERT for the existing kit; this follow-up changes
presentation only. Traced `tools/localization.mjs`: its intrinsic-name generator
already supplies Kraken Shell and the hidden Colossal aura, but does not supply
the four secondary visible modifiers (Gush, Anchor Smash, Ravage stun and
Colossal enemy aura). Their exact name/description tokens were absent from all
four source locales. Added explicit EN/TR/RU/zh-CN tokens and regenerated twelve
resource/Panorama mirrors. Gush/Anchor/Colossal descriptions use signed current
modifier-property placeholders instead of promising a fixed or all-rank value.
Ravage states its implemented strong-only dispel policy.

Added explicit GetTexture mappings to these four modifiers, reusing the native
icons already assigned/verified in the hero KV and dossier; no new assets or
precache ownership introduced. API and property-tooltip reference:
[ModDota modifier declarations](https://docs.moddota.com/lua_server/declaration)
and [modifier properties in tooltips](https://moddota.com/abilities/modifier-properties-in-tooltips).
No external implementation imported. This confirms missing text records and
explicit icon wiring, not a reproduced in-engine default-icon failure.

Validation: localization generation and full `node tools/checks.mjs` passed
with zero failures. Gameplay quantities, aura eligibility/linger, damage,
duration and upgrades are unchanged. OWNER_RUNTIME remains PENDING: inspect
all four recipient debuffs at low/max ranks, confirm signed property values
render and refresh after rank-up, verify native icons and four-language text,
then basic/strong dispel and aura leave/re-entry. No Dota launch, remote push
or Workshop publication was performed for this follow-up.

Scope: the five production abilities assigned to `npc_dota_hero_tidehunter`, their Lua, KV, rank gates, upgrade hooks, localization, presentation and precache. This is a static review plus Lua mocks; it is **not** a Dota runtime certification. No Dota process was launched or controlled.

## Evidence and decisions

- Read `docs/heroes/tidehunter/AGENTS.md`, `ABILITIES.md`, the shared hero contract, hero-development guidelines and `docs/RESEARCH_AND_RUNTIME_VERIFICATION.md` before editing.
- Re-read `scripts/npc/heroes/npc_dota_hero_tidehunter.txt` from the installed `pak01_dir.vpk`. Installed build: ClientVersion 6943 / SourceRevision 11069754 (Oct 01 2026); source SHA256 `8c96be768e85e8d845bc6ef04f99ad261c0f9bd5c0e45503aedb6ab4c5c78cda`, matching the prior dossier snapshot. Native explicit counterparts are Gush, Kraken Shell, Anchor Smash and Ravage; slot 5 is project-specific.
- Inspected live project Lua/KV, `heroes/aghanim_manager.lua`, bootstrap precache, four locale JSON files and the existing hero regressions. Dota particle paths exist in the installed VPK. Their visual composition/CP behavior was not decoded in this pass.
- The checked-in sound snapshot says `Hero_Tidehunter.AnchorSmash` is in the Tidehunter hero bank, while `Hero_Tidehunter.Gush.Cast` and `Hero_Tidehunter.Ravage` were not found in the decoded hero banks. Installed native ability definitions provide the intended exact event IDs (`Ability.GushCast`, `Hero_Tidehunter.AnchorSmash`, `Ability.Ravage`). Sound event presence is evidence of identifiers only, not audible playback.
- Classification: Q Gush = PVE-CONVERT; W Kraken Shell = PVE-CONVERT; E Anchor Smash = PVE-CONVERT; R Ravage = PVE-CONVERT; slot 5 Colossal Presence = REPLACE (custom Enfos passive, not Dota Innate). All retain recognizable Tidehunter themes. Values below remain a balance/design choice, not independently balance-certified.

## Findings by ability

| Slot / ability | Behavior in project | Defect repaired | Remaining review/test items |
|---|---|---|---|
| Q `enfos_tide_gush` | Single-target magical damage with Strength scaling, armor reduction and slow; enemy hero/basic target, 750 range, spell absorb guard; 10 ranks. Native source: `tidehunter_gush`. | Custom KV lacked native `ACT_DOTA_CAST_ABILITY_1`; prior `Hero_Tidehunter.Gush.Cast` sound literal was not present in the decoded hero-bank snapshot. Added exact native animation and `AbilitySound=Ability.GushCast`; removed the old Lua sound call to avoid duplicate playback. VPK particle inspection proved native Gush uses a travel trail; prior Lua attached it to target and dealt instant damage. Replaced with native-speed 2500 tracking projectile; damage/debuff now resolve on impact. | Regression covers launch, travel speed/effect, deferred impact, lost target, spell block and ally rejection. Native Gush declares Scepter modifiers for speed, AoE and range; Enfos instead uses generic Scepter spell amplification/ultimate cooldown. Do not claim native Scepter parity. Spell immunity/spell absorb engine behavior, dodge, range, VFX, audio and animation need owner test. |
| W `enfos_tide_kraken_shell` | Passive physical constant block plus flat HP regen; damage threshold triggers a strong purge; 10 ranks; Break gates block, regen and purge. Native source: `tidehunter_kraken_shell`. | Existing regressions cover declared regen property, block/regen values, damage threshold and Break. No new W code changed in this pass. | The Enfos W is passive, whereas installed native build 6943 defines Kraken Shell as a no-target immediate active with damage reduction and a timed effect. Keep this PvE conversion explicitly understood. Check whether damage accumulation should exclude self/allied/reflected damage, and whether counter reset/carry-over semantics match intended purge timing. Validate block ordering, regen, purge, Break, death/respawn and modifier lifetime in Dota. |
| E `enfos_tide_anchor_smash` | No-target physical AoE, attack damage + ranked bonus + Strength scaling; applies base attack damage reduction; includes magic-immune enemies in query; 10 ranks. Native source: `tidehunter_anchor_smash`. | Custom KV lacked native `ACT_DOTA_CAST_ABILITY_3`. Added it. The existing cast sound `Hero_Tidehunter.AnchorSmash` is confirmed in the hero-bank snapshot; native VPK uses the same event. | Current custom KV marks this ability as piercing spell immunity while the installed native definition explicitly excludes spell-immune enemies. This may be intentional PvE policy, but it needs a recorded product decision and runtime test. Confirm damage reduction property semantics, debuff purge/status resistance, particle scale/attachment, and that the custom immunity flag behaves as intended. |
| R `enfos_tide_ravage` | No-target magical AoE damage and stun; boss stun capped separately; 10 ranks, unlocks every five hero levels through level 50. Native source: `tidehunter_ravage`. | Custom KV lacked native `ACT_DOTA_CAST_ABILITY_4`; prior `Hero_Tidehunter.Ravage` event was not found in the decoded hero-bank snapshot. Added the native activity and `AbilitySound=Ability.Ravage`, removing Lua's old sound call. Tidehunter hero sound bank added to bootstrap precache. | Current stun 2.4–3.2s and boss cap 1.0s are materially different from native; test wave clear, boss status resistance, immunity and cast timing. Generic Scepter applies to ultimate inflictor damage and cooldown by design; verify actual scripted damage receives spell amplification in Dota. Sound/animation/VFX and cold-start precache remain pending. |
| Enfos passive `enfos_tide_colossal_presence` | Ten-rank aura grants flat health/armor and weakens nearby enemies' movement and base attack damage; Break disables aura and stat bonuses. | Existing regressions cover passive values and Break; no new passive mechanics changed. | Aura search's magic-immune behavior, debuff duration/purge and refresh, illusion behavior, max-health/life interactions, client icon/tooltip and aura performance remain untested in engine. Tank Shard role buff (350 HP/15% incoming-damage reflection) is generic in `aghanim_manager.lua`, not implemented by this ability; ensure item upgrade tooltip and team scoring account for reflection as intended. |

## Regression and presentation repair

Static comparison to installed native `AbilityDefinitions` confirmed the missing Q/E/R cast activities. The native event IDs for Gush and Ravage also resolve from those definitions, and the previous Lua event literals conflicted with the source-backed names. The custom KV now declares the matching cast animations and exact sound events; Lua no longer emits the two unverified events. Tidehunter's native sound bank is explicitly listed in `Precache`.

Added a content-contract regression for the three native activities, Q/R sound IDs, removal of obsolete Lua event strings, and sound-bank preload. Tidehunter mock regressions cover Gush projectile launch/travel/impact/lost target/spell block/ally rejection and Strength scaling; Kraken Shell block/regen/threshold/Break; Anchor Smash physical damage, debuff and immunity search flags; Ravage boss stun cap; and Colossal Presence stats/Break. Dota runtime remains pending.

## Acceptance status

| Area | Status | Evidence / limitation |
|---|---|---|
| Source identity, classification, Lua/KV mapping | PASS (static) | Installed Dota 6943 native definitions and project slot dossiers; not runtime acceptance. |
| Ten-rank curves and gates | PASS (static) | KV and repository content contracts; rank-up UI/point behavior remains owner runtime pending. |
| Q/E/R animation IDs and Q/R audio IDs | PASS (static wiring) | Installed native VPK definitions; engine presentation pending. |
| Anchor Smash audio ID | PASS (static wiring) | Tidehunter decoded bank snapshot plus native definition; playback pending. |
| Particle path existence | PASS (static existence only) | Installed VPK path inventory; appearance, attachment, control points and scale pending. |
| Precache | PASS (static declaration) | `addon_game_mode.lua`; cold-start runtime pending. |
| EN/TR/RU/zh-CN tooltips | PASS (static presence) | Localized strings and named KV values checked; in-client display pending. |
| Gameplay, bosses, immunity, Break, purge, death/reconnect, upgrades | PENDING | Existing mocks are partial and cannot establish engine semantics or game balance. |
| VFX/SFX/animation quality and VConsole | PENDING | Must be checked by owner in the live game; no launch/control occurred. |

Validation run and exact result are recorded in the associated commit turn. This hero remains in progress until owner engine tests resolve the pending rows and the remaining mechanics review is closed.

## Sol re-review: synchronous impact removal

## Kraken Shell inactivity window decision before implementation

PVE-CONVERT remains: retain authored block, Strength coefficient, regeneration and 450 cleanse threshold. Installed native hero KV explicitly sets `damage_reset_interval=7.0`; current custom passive accumulates damage indefinitely across out-of-combat intervals. Add named `purge_reset_interval=7` and reset the accumulated counter on the next positive damage event after at least seven game-time seconds without damage. Use event timestamps, not another interval thinker/global scan. Zero/negative events must not move the time window or counter. The existing pre-purge counter update remains to avoid callback re-entry. Tooltips in all four languages must state the inactivity window; actual paused-game timing/cleanse visuals and event ordering remain owner engine gates.

Result: pre-change regression failed on a removed Gush recipient reaching AddNewModifier. After repair, Gush and Anchor Smash skip removed/dead/switched-allied recipients after damage; deleted/dead source or deleted ability stops subsequent calls. Anchor Smash also validates later recipients before damage. Mocks cover target/source/ability removal for both skills; all 298 hero-kit regressions pass. Existing damage and control math remains unchanged. Current Dota death callback/particle/audio acceptance remains owner PENDING.

Native source and live Lua were reread on 2026-10-02. Gush impact and Anchor Smash call damage then apply a modifier without revalidating recipient/source/ability. ApplyDamage can synchronously trigger death/removal callbacks, leaving invalid handles for AddNewModifier. Reproduce through a targeted damage-callback regression and guard subsequent calls while preserving authored amounts, target flags, durations and timing. Ravage already applies its stun before damage and is not included in this particular defect. No new native animation, resource or blanket resistance policy is assumed. Other pending items in the existing ledger remain open.

## Kraken Shell inactivity repair result

Implemented the preceding decision with event timestamps using `GameRules:GetGameTime`; no new thinker or global scan. The targeted pre-change test failed because negative damage reduced the counter; the same test additionally exercises the previously missing seven-second reset. All 299 hero-kit mock regressions pass; `node tools/checks.mjs` reports zero failed checks. Locale generation reflects the named interval in EN/TR/RU/zh-CN. Native active Kraken Shell, block ordering and runtime event semantics are not certified by this repair. Owner checks: compare sustained damage versus a seven-second gap, pause during the gap, Break, death/respawn and strong-dispel effects. ENGINE_PENDING remains.

## Inactive passive-source decision before repair

Focused PVE-CONVERT correctness repair, not a hero redesign: Kraken Shell and Colossal Presence must require a live learned originating ability in addition to their existing Break gate. The shared value helper returns zero for missing/removed handles, but Kraken adds Strength block and falls back to a 450 purge threshold; Colossal still advertises an active aura. An explicit rank-zero mock reproduces the block leak before modification. Installed MCP `CDOTABaseAbility:GetLevel` and ModDota API document the rank query (https://docs.moddota.com/lua_server/); searched reference corpus for exact rank-zero guards returned no matches, so no reference code is imported. Guard the two Tidehunter intrinsic owners only; preserve learned ranks and all existing values. Actual unlearned intrinsic installation, ability removal, rank-up and free passive rank presentation remain owner Dota PENDING.

Inactive-source result: the pre-change rank-zero regression failed on Kraken block. Both intrinsic owners now use a Tidehunter-local live-source/rank check. Missing or removed ability handles and rank zero return no block/regen/cleanse or Colossal aura/health/armor; learned-rank and Break regressions remain passing. All 300 hero-kit mock regressions pass and full repository checks report zero failures. No other hero passive changed. Runtime source-removal/learning, aura fade and max-health recalculation remain PENDING; references establish API signatures, not those engine outcomes.

## Strength scaling / tooltip reconciliation decision

Installed native Ravage KV (build 6943, reread through VPK on 2026-10-02) has fixed magical damage and speed 725; the project's authored instant PvE Ravage instead adds Strength × 2 in Lua. Kraken likewise adds Strength × 0.05 to its block. Both bonuses are absent from their current four-language descriptions and are hard-coded rather than named KV values. TUNE the existing custom implementation: move the two unchanged coefficients into `strength_factor` and describe the actual formulas. No native parity, expanding-wave implementation or balance change is claimed. Regression will vary the named coefficient to distinguish a real KV lookup from preserving the hard-coded implementation. Ravage travel timing and actual modifier/damage ordering remain open engine/review gates.

Strength reconciliation result: Kraken block now reads named `strength_factor=0.05`; Ravage reads `strength_factor=2.0`. Production amounts are unchanged. Four locale descriptions and generated ability/summary/modifier text reflect the full formulas. Existing focused mocks deliberately use 0.08 and 1.5 and assert 74 block / 375 Ravage damage on 50 Strength, proving data-driven lookups. The 300 hero-kit mocks and full checks pass (0 failures). Tooltips in client and damage after engine amplification/resistance remain owner PENDING.

## Ravage synchronous multi-target lifetime decision

Focused correctness repair within PVE-CONVERT: unlike Gush/Anchor, Ravage already applies stun before damage, but its next recipient remains unchecked after the previous damage callback. The new two-target test reproduces an invalid recipient reaching AddNewModifier. A previous hit may remove another unit/source/ability or switch team through callbacks; guard each recipient and source before stun, and revalidate after modifier callbacks before damage. Preserve current instant timing, amounts, boss cap, immunity query and sound/particle ownership. Installed native Ravage source was reread this turn; ModDota event/API references establish callback interfaces (https://docs.moddota.com/lua_server/), while the mock establishes our control-flow defect, not engine reproduction. No external implementation is copied. Native expansion speed 725 remains a separately recorded gap.

Ravage lifetime result: pre-change two-target regression failed in the invalid second recipient's AddNewModifier. Later target/source/ability removal and team-switch cases now pass, plus a separate modifier-callback regression prevents damage after source/ability/recipient removal. All 302 hero-kit mocks and full repository checks pass (0 failures). This is safe control flow in mocks; owner engine tests still must verify ordinary waves, Boss cap, death-triggered callbacks, effects/audio and repeated casts. The current instant implementation remains distinct from native expanding Ravage.

## Unique Scepter decision before implementation

PVE-CONVERT Gush using source-backed native Scepter shape: point-target piercing wave, 2200 range, 260 collision radius, 1500 speed, fixed 7-second base cooldown. Retain Enfos Gush's ten damage ranks, Strength scaling, armor reduction/slow and ordinary tracking cast without Scepter. Replace Tidehunter's generic +40% ultimate damage / 25% ultimate cooldown bonus rather than stacking it on the new mechanic. Move HasScepterUpgrade and four tooltip keys from Ravage to Gush. Installed hero KV verifies the four upgrade numbers; exact native `particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf_c` exists. MCP confirms GetBehavior is both client/server and OnProjectileHit_ExtraData returning true destroys the projectile; use cast-time ExtraData to preserve piercing even if the item is removed during travel. Reference-only pattern: Boss Survival Adventure 1571786267 slardar.lua lines 246/271 uses this resource with a linear projectile. No custom code/assets copied. Native sound remains Ability.GushCast; bootstrap explicitly precaches the new wave resource. VFX composition/CP rendering, sound playback, dynamic targeting after purchase/drop and real collision/immunity remain owner ENGINE_PENDING.

Unique Scepter result: Gush now switches unit/point behavior, cast range and base cooldown from HasScepter on both realms; Scepter launches one engine-owned piercing linear projectile with cast metadata. It applies the existing Gush damage/debuff per living enemy impact; losing Scepter in flight does not stop penetration. Ordinary cast keeps tracking projectile, spell absorb and its original rank-dependent cooldown/range. Tidehunter alone loses generic ultimate amplification/cooldown reduction; Axe and other existing hero bonuses stay unchanged. Four locale upgrade keys, source-backed projectile precache and upgrade marker now belong to Gush. Shard remains the generic tank upgrade and is still an open review item. The native source also declares Arm of the Deep alongside legacy Dead in the Water; neither is claimed implemented here.

Mock checks cover zero-distance direction fallback, projectile parameters, two targets, item drop during flight, expired nil target, normal behavior/cooldown/range restoration, and shared modifier isolation. Static contract validates all four tooltip numbers and bootstrap precache. Owner runtime acceptance remains PENDING: acquire/drop Scepter and verify targeting cursor immediately changes; fire down a populated lane and measure collision width, multi-hit damage/slow/armor, boss response and 7s cooldown; compare normal single-target spell block/dodge before and after; inspect native wave appearance/sound and VConsole at cold start. No Dota launch/control or Workshop upload performed.

PvE cooldown adaptation before final commit: unlike native four-rank Gush, Enfos rank ten already has a 6-second cooldown. Scepter therefore caps base cooldown at 7 seconds (`min(normal rank cooldown, 7)`) rather than weakening high ranks. Four descriptions say "at most 7"; mock verifies rank ten remains 6. The earlier fixed-7 wording is superseded by this explicit TUNE decision. Final full checks: 304 hero-kit mocks, 0 failed repository checks; runtime gates above remain pending.

## Unique Shard decision before implementation

PVE-CONVERT authored Shard: Kraken Shell cleanse triggers a free Anchor Smash at 50% of its computed physical damage, retaining the learned Anchor debuff/radius. At most one reactive Smash per 5 game-time seconds; requires learned Anchor and live learned Kraken, respects Break. This is a native-theme adaptation of installed `smash_on_purge` / `special_bonus_unique_tidehunter_smash_on_blubber=50`, not a claim to implement current native Shard Arm of the Deep or Dead in the Water. Remove Tidehunter's generic +350 health/15% reflection instead of stacking systems. Reuse existing Anchor particle/sound and verified ability-3 gesture; no units/thinkers or extra per-frame scan. Reserve cooldown before damage callbacks and guard cleanse re-entry; post-purge removed/dead handles cannot trigger the effect. Normal active Anchor uses the same existing damage/debuff implementation at 100%, spending mana/cooldown through its normal engine cast. Four locales, upgrade markers and focused source/mock tests must move from Colossal Presence to Kraken Shell. Actual timing, cleanse callback semantics, reactive gesture/particle/audio, pause/respawn and item-drop remain owner runtime pending.

Unique Shard result: Kraken Shell owns reactive Anchor Smash (50% computed damage; 5s internal game-time cooldown), requiring a learned Anchor. Cooldown is reserved before Smash impacts; strong-purge re-entry is blocked and removed modifier/source handles cannot continue after purge callbacks. Existing active Anchor remains 100% with normal engine mana/cooldown; both paths share verified Anchor sound/particle and target/damage/debuff cleanup guards. Reactive gesture uses the native ability-3 activity (`StartGesture` signature verified via installed MCP). Tidehunter alone loses generic Shard health/reflection; other Tank modifiers remain unchanged. Four upgrade locale keys and marker moved from Colossal Presence to Kraken Shell. No current native Shard parity is claimed.

All 307 hero-kit mock regressions and full repository checks pass (0 failures). Tests cover half damage and inflictor identity, learned-rank gate, no item / Break, 4.9s vs exact-5s cooldown, no active mana/cooldown calls, cleanse re-entry, removed parent/ability/modifier, normal Anchor damage regressions and generic Tank bonus isolation. Owner runtime remains PENDING: confirm passive cleanse happens, reactive Anchor shows its gesture/particle/sound, hits creeps/Boss without changing active skill cooldown or mana, repeated damage does not flood effects, pause timing/item drop/death/respawn and VConsole. Upgrades' current latest notes supersede the early findings table's generic bonus descriptions. Remaining deep-review gaps include Ravage expansion/CPs, resistance/strong-dispel policies, aura refresh and in-engine acceptance across all five skills.

## Ravage particle decision from decoded resources

Source2Viewer-CLI 19.2 decompiled installed 6943 `particles/units/heroes/hero_tidehunter/` without launching Dota. Root Ravage uses children `_a`–`_e`; their C_INIT_RingWave reads CP1–5.x for initial radius, y for thickness (24/80 multipliers), z has zero speed multipliers. Their finite instantaneous emitters start at 0, 0.35, 0.7, 1.05, 1.3 seconds. Pool remaps CP5.x to overall radius. Generic effect() only creates/release and never supplies these controls, so rings have no authored radius. TUNE presentation: anchor CP0 at cast-world origin and set five evenly spaced radii to radius × i/5 with thickness factor 1 and zero initial speed. This is an explicit authored five-band layout based on decoded parameter meanings; no claim to have observed exact native C++ CP values. Particle stays finite engine-owned after release; no timer/thinker introduced. Searching indexed Workshop corpus and web for exact resource returned no matching Lua implementation; native decoded resources are the evidence. Existing instant damage remains a known difference from native speed-725 travel and from staggered visual emission; defer travel conversion to its own coherent unit, do not label gameplay/VFX synchronized or engine accepted.

Ravage CP repair result: one world-origin particle now receives CP0 cast origin and CP1–5 equal-band radii from the same KV radius used by the damage query. Native decoded root SHA256 `682c1fdd2efa9f97c3054fe069c6cefa00d1613a544c06079bc7f77f141210fc`; local decoded dependency evidence is under `%TEMP%/enfos-tide-assets-20261002/particles/units/heroes/hero_tidehunter/`. Regression varies radius to 900 and verifies 180/360/540/720/900, thickness/speed components, world anchoring and exactly one release. All 308 hero-kit mocks and full checks pass (0 failures). Actual rendered rings, finite termination and native fallback quality remain owner ENGINE_PENDING. This fixes missing parameter wiring; staggered visuals versus instant damage is still explicitly unresolved.

## Tidehunter dispel-policy decision before implementation

Installed native KV reread on 2026-10-02 explicitly says Gush / Anchor Smash `SPELL_DISPELLABLE_YES`, Ravage `SPELL_DISPELLABLE_YES_STRONG`, Kraken `SPELL_DISPELLABLE_NO`. The custom modifiers/KV omit this contract; Ravage has only IsDebuff and STUNNED, without strong-purge/stun classification. TUNE explicit metadata/callbacks: ordinary debuffs basic-purgable, Ravage basic=false / strong-exception=true / stun-debuff=true, intrinsic Kraken and authored Colossal nonpurgable (Break remains the disabling mechanism). Add matching custom KV metadata for native tooltip consistency. A pre-change mock fails on the first absent callback; this proves a declaration gap, not actual engine default behavior or observed dispel failure. MCP and ModDota (https://docs.moddota.com/lua_server/) verify meanings/signatures; indexed Boss Survival Adventure lich.lua:411 demonstrates explicit stun tagging, reference-only without code import. Do not alter damage, duration, status-resistance math, visuals or timing. Basic/strong dispels and Break in actual Dota remain owner ENGINE_PENDING.

Dispel declaration result: five custom KV metadata fields and the corresponding intrinsic/debuff callbacks are explicit. Regression checks basic/strong/stun categories and nonpurgable intrinsic owners; all 309 hero-kit mocks/full checks pass (0 failures). This does not simulate actual engine Purge, default native inheritance, status resistance or HUD text; owner tests must use basic and strong dispels on Q/E/R and enemy dispel/Break on W/passive. Runtime status remains ENGINE_PENDING.

## Ravage expanding-hit decision before implementation

PVE-CONVERT the current instant AoE to five bounded annular impacts aligned with decoded native particle emission starts (0 / 0.35 / 0.7 / 1.05 / 1.3s). Keep authored radius and full damage/Strength/Boss stun cap; hit each unit at most once per cast even if it moves outward. Use existing GameMode SetContextThink pattern (already used by Lina/Invoker); one finite cast context, game-time timestamp for pause safety, no spawned thinker or per-frame global query. Use independent cast serial names to preserve Refresher/overlap. Query only each expanding ring at its scheduled time; stop callbacks when ability/caster disappears or caster dies, preserving the existing source-alive policy. Snapshot damage, radius and stun duration at cast; origin remains fixed. This restores expansion/readability but is an authored five-band interpretation, not the native continuous C++ speed-725 simulation. MCP confirms SetContextThink; reviewed local existing patterns and ModDota timer/game-time references (https://docs.moddota.com/lua_server/), no library import. Source/mock regression must show no instant outer damage, once-per-cast hits, pause/no early damage, overlap isolation, movement/late targets and source deletion termination. Owner actual gameplay/animation/audio/VConsole remains PENDING.

Ravage expansion result: the previous instant loop is now five annular impact passes, with one finite GameMode context scheduled against pause-aware game time. Hits are cast-local; their table expires with the context. First ring is immediate; subsequent rings use native decoded VFX start times. Cast origin/damage/radius/durations are snapshotted; source invalidation terminates the context. Four descriptions state five rings / 1.3s / once per enemy. Existing source-removal and Boss-cap tests still pass; two new tests exercise delayed outer hits, moving previously hit units, fixed origin after caster movement, paused time, exact ring starts, overlap isolation and ability removal. All 311 hero-kit mocks and full repository checks pass (0 failures). Native continuous travel parity is not claimed; actual ring collision/telegraph synchronization, pause/death behavior, audio/render quality, Boss status resistance and VConsole remain owner ENGINE_PENDING. This supersedes prior notes that gameplay is instant.

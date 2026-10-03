# Jakiro individual review — 2026-10-03

Reverse roster: Lich → Vengeful Spirit → **Jakiro** → Lion. Current hero remains open.
Source review: **PENDING**. Isolation: source/fixture PASS. Traces: PENDING.
Owner Dota/VConsole, visual/audio, cold resources, rank HUD and actual engine acceptance: **NOT TESTED**.

## Evidence and native-first decisions before gameplay repair

Read all five current handlers, their ten-rank production KV, hero assignment, existing dossier and shared dependencies. Installed native source: scripts/npc/heroes/npc_dota_hero_jakiro.txt; ClientVersion/ServerVersion 6943, SourceRevision 11069754, VersionDate Oct 01 2026 15:53:48. Native C++ is closed; exposed KV is evidence of configured contracts, not proof of custom-Lua equivalence.

| Slot | Decision | Native evidence and current source defects |
| --- | --- | --- |
| Q Dual Breath | TUNE | Native point/unit projectile cone: start/end radius 150/275, speed 1050, fire delay 0.2, five-second burn. Authored instantaneous circular burst centered 400 forward with radius 500 differs from both cone and fire-only visual. No ice wave or burn. Missing server/handle/callback protection. Ten authored ranks and INT scaling justify retaining stable Lua ID while restoring recognizable behavior; native BaseClass ten-rank behavior is unproven. |
| W Ice Path | TUNE | Native radius 150, range 1100, delayed persistent path, damage 50, stun 1.25–2, path duration 3–4.5; sound key Hero_Jakiro.IcePath. Authored warning endpoint 800, circular scan centered 600 with radius 700, one-shot callback, undefined modifier_generic_stunned_lua and Boss duration ×0.35 are confirmed source defects. Configured ten-rank stun and damage remain authored tuning, not native numbers. |
| E Liquid Fire | TUNE | Native attack/autocast burn: five seconds, radius 300, tick 0.5, attack slow 30–60, DPS 12–48. Current shared manual/autocast FireAt is instantaneous burst plus four-second slow; handle/removal protections incomplete. Native Liquid Ice is a separate linked ability; current fifth slot is not Liquid Ice or native double attack. Native Shard modifies linked attacks/mana/shared cooldown; generic D healing amplification is unrelated. |
| R Macropyre | TUNE | Native path width 500, length/range 1400, tick 0.5, lingering burn; Scepter pure/piercing damage and icy edges/duration. Authored half-width 180, per-cast cumulative Boss maxHP ×0.1 cap and source-death cancellation require review/repair. Current generic Scepter amplifier does not reproduce native mechanics. Preserve ordinary damage resistance/immunity; remove authored Boss-only cap, not Boss AI/stats. |
| D Double Trouble | REPLACE | Current extra Enfos slot is INT 20–38 + AS 30–57, suppressed under Break/illusions. Native jakiro_double_trouble is a nonlearnable innate second attack (delay 0.2, damage reduction with hero level), not these stats. Keep this distinction explicit while auditing level-50/ten-rank extra passive. Missing removed-handle/learned-rank gates, explicit lifecycle/icon policy and traces. No native second-attack certification. |

Q/W/E/R fit creep combat natively: no evidence warrants generic PVE-CONVERT labels merely because the game has waves. D is a distinct authored fifth passive; its replacement classification does not imply importing native innate mechanics automatically.

## Dependency, asset and upgrade leads

Existing addon startup explicitly precaches dual-breath-fire, ice-path, liquid-fire-explosion and macropyre particles; mere path presence proves neither CP geometry nor visibility. Sound banks/particle CPs/animations require decoded installed-resource review. Shared Aghanim manager, evolution/Ascended hooks, damage telemetry and four-language descriptions must be reconciled per slot before closure. Verify exact behavior of current hero metadata rather than infer from slot order.

Current helpers value/enemies/get_int/damage are retained. effect, ground_effect and remove_ground_effect moved byte-identically to shared/pve_helpers; existing monolith callers use aliases. Ground thinkers retain max three per ability, prune removed handles and clean up on modifier destruction. No scheduled-wave population cap added.

Reference search: cached AGHANIM'S PATHFINDERS item 2208582400 contains Jakiro Lua/KV leads. Search snippets are discovery only; source version/license/compatibility must be read before code reuse. No external Jakiro code imported. [ModDota ability KV](https://moddota.com/abilities/ability-keyvalues) explains ScriptFile/native BaseClass routes; [API](https://docs.moddota.com/lua_server/) documents LinkLuaModifier and engine thinker APIs. These do not certify our runtime.

## Isolation unit and reproducible checks

Five Q/W/E/R/D modules plus compatibility init now own the five modifier classes. Production KV uses per-slot ScriptFile; monolith bootstrap imports init and cannot relink owned modifiers. Each original handler body was compared byte-for-byte during extraction: identical, including known defects. IDs, ranks, values, cooldowns, mana, target flags, sounds/particles and gameplay were not changed in this unit.

New tools/tests/jakiro_isolation.test.mjs checks unique class ownership across production routes, cold module loading without monolith, subsequent legacy bootstrap registration, and all five stable IDs. Shared helper regression executes 20 ground casts: only three retained, oldest 17 removed, already-removed handle pruned without double removal; destruction and finite particle release also exercised. These are fixtures, not a Dota cold-start/performance certificate.

Next units: independent reproductions and repair of Q/W geometry/timing; E burn/autocast; R Boss cap/native Scepter; D lifecycle; per-slot VFX/SFX/CP/precache/localization and bounded trace evidence. Do not advance to Lion with these known source defects open.

## Owner engine checklist (all NOT TESTED)

Ranks 1/10 and ordinary/free skill points; cast near/far/zero direction; units outside/entering/leaving paths; traveling ice/fire timing; repeated/Refresher casts and multiple casters; manual/autocast/Break/illusions/target loss; source/target death and removed ability; immunity/resistance/dispel and ordinary Boss interaction; Shard/Scepter/Blessing/evolution/Ascended hooks; visible CP sizes, audible cast/impact/loop cleanup, cold resources, reconnect and dense-wave VConsole/performance. No agent launch/control or publication authorized.

Isolation verification: full node tools/checks.mjs PASS (0 failed checks), including production Lua entrypoints, all-hero existing mocks, individual module/helper tests and dossier contracts. No Dota launch; known gameplay defects remain open.

## R focused repair — Boss-only damage cap

Confirmed before repair in an independent fixture: ordinary target received 2700 requested magical damage over 20 half-second pulses, but otherwise identical Boss metadata target received only 100 (10% of its mock 1000 maximum HP). The fixture failed on this mismatch against the unchanged extracted module.

Removed R's cumulative maxHP ceiling and its per-Boss damage table; every eligible target now receives the ordinary configured DPS/INT pulse through the existing ApplyDamage helper. No Boss immunity/armor/resistance/control/AI/stat override added, and existing path geometry is unchanged in this focused unit. Fixture exercises ordinary, isBoss=true and enfos_boss_ name targets plus an off-path target, checks magical type/ordinary flags and absence of retained boss table. The historical cap-preserving regression now asserts equal ordinary requested damage.

This is an authored policy/source repair, not a native Macropyre geometry or Scepter acceptance. Remaining R width, duration/linger, source-death behavior, immunity, Scepter icy-edge/pure/piercing, CP/sound and owner engine tests remain PENDING. Existing tooltip never advertised the removed cap; no player-visible string changes needed for this isolated removal.

R cap repair verification: targeted reproduction failed before / PASS after; full node tools/checks.mjs PASS with 0 failed checks. Owner runtime remains NOT TESTED.

# Hero and Ability Development Guidelines

Persistent working standard for ENFOS TEAM SURVIVAL SAMETC EDITION, distilled from the owner's hero/ability repair brief on 2026-09-28. Read before related implementation or audit work.

## Scope and source of truth

Systematically audit, repair and PvE-adapt the existing hero system while preserving recognizable Dota mechanics, visuals, audio and animation. Heroes primarily fight waves, elites and bosses within the project's established PvEvP design. Do not turn them into unrelated generic RPG classes or turn every spell into another AoE nuke.

This standard replaces blanket PvP-to-PvE rewrite assumptions. It does not change the product constraints in `../AGENTS.md` or silently approve a new roster, balance model or hero kit. Read `GAME_DESIGN_MASTER.md`, `TECHNICAL_ARCHITECTURE.md`, `QA_BALANCE_RELEASE.md` and `DECISIONS_OPEN_ITEMS.md` when relevant. Treat `HERO_PVE_REWORK_MATRIX.md` and existing `audit/` reports as inventory and historical evidence, not proof that runtime acceptance has passed or that every custom rewrite must be retained.

## Native first and classification

Before each skill task, use [the hero index](heroes/README.md) to read that hero's
`AGENTS.md` and `ABILITIES.md`, then the relevant sections of
[the technical reference](HERO_ABILITY_REFERENCE.md). This explicit reading rule
also applies when editing the shared `pve_kits.lua`, NPC KV, localization or
precache files; a documentation-directory AGENTS.md alone does not govern those
code paths automatically. Update the ability's evidence ledger when work changes
its classification, source provenance, behavior or acceptance status. Generated
inventory blocks come from production KV; do not overwrite hand-recorded evidence
when refreshing them. Never infer native counterparts from matching slot numbers
or icons alone.

Before changing any ability, record exactly one primary class and the reason:

| Class | Meaning | Preferred action |
| --- | --- | --- |
| A — KEEP | Native mechanic already serves PvE. | Keep the native ability. |
| B — TUNE | Mechanic fits; numerical balance needs adjustment. | Use a verified minimal native override, such as `npc_abilities_override.txt` where supported. Preserve engine behavior and assets. |
| C — PVE-CONVERT | A specific component loses value against creeps. | Change only that component, preserving cast, projectile, impact, audio, animation and theme where appropriate. |
| D — REPLACE | Native translation is not meaningful or creates bad gameplay. | Last resort; document why A–C fail and keep the replacement faithful to the hero. |

Prefer an additional Enfos modifier over a complete rewrite when it can provide the required behavior. Native suitability must be established from evidence, not assumed. A stat-steal or mana-burn conversion is a design choice, not an automatic mandate to add damage. Maintain distinct kit roles: tanking, sustain, healing, buffs, debuffs, control, summons, focused damage and wave clear need not all occur on every hero.

Define normal-creep, elite and boss behavior explicitly. Preserve useful boss interactions where practical while preventing permanent control loops, unrestricted executes and runaway scaling. Do not silently invent boss exceptions or radically redefine a hero. Record unresolved material choices in `DECISIONS_OPEN_ITEMS.md` before destructive changes. Restore correctness first; keep balance changes explicit and separate from technical repair where possible.

## Verified references and clean-room boundaries

Never guess native ability IDs, KV values or special-value keys, modifier names, particle/projectile paths, sound events, attachments, animation constants, API signatures, immunity, dispel or status-resistance behavior.

Use current installed Dota KV, localization, VPK resources, particles and sound-event definitions first. Consult Valve Workshop documentation and official examples for supported engine patterns. Versioned game-data mirrors such as GameTracking are secondary evidence; record provenance and date/build and cross-check current installed data when possible. Older community implementations do not establish current native behavior.

Use `REFERENCE_ANALYSIS_POLICY.md` for all external references. Other custom games, including hero-rework and PvE maps, remain design references only; a permissive license does not override this repository's prohibition on transplanting their code or custom assets. For otherwise permitted third-party libraries/examples, verify the exact license and attribution obligations before reuse. Unclear licensing means reference only; do not assume GPL code is interchangeable with permissively licensed code. Prefer valid native Valve resources for this Dota addon.

Record the source file/resource and build or revision for verified identifiers. Distinguish confirmed defects from static suspicions and unavailable evidence. If actual resources or engine access are unavailable, mark verification pending rather than fabricate paths or claim success.

## Discovery, audit and rollout

1. Inspect existing addon structure, NPC KV, hero assignments, native overrides, Lua abilities/modifiers, game-mode setup, shared helpers, precache, localization and developer tools. Reuse existing infrastructure.
2. Build or update a global inventory of enabled heroes and all assigned abilities, including ultimates, talents and passives. Record implementation, native counterpart, A–D classification and rationale, known defects, and separate VFX/SFX/modifier/precache evidence statuses.
3. Identify systemic causes first: native-ID shadowing, missing hero resources, invalid modifier links, faulty sound/particle helpers, broken precache or client/server mistakes. Repair shared causes before repeating fixes across heroes.
4. Select 2–4 representative pilots covering melee control/tanking, ranged casting, projectiles and complex modifier/summon behavior. Explain the selection from the audit.
5. Complete one pilot hero at a time, testing each ability and then the full kit and regressions. Improve shared checks and documentation from findings.
6. Expand hero by hero only after pilot acceptance. Never use one giant roster rewrite as a substitute for an audit.

For a new broad repair task, the initial output should explain the discovered architecture, evidence-backed systemic findings, ability inventory, recommended pilots and actionable repairs. For focused follow-ups, reuse and update existing evidence rather than restarting the entire program. Documentation-only work does not initiate implementation phases.

Improve existing audit tools where practical to report missing ScriptFile/Lua classes, invalid hero slots, duplicate IDs, accidental native shadowing, missing modifier definitions/links, KV/Lua special-value mismatches, unused values, missing localization, unverified particles/sounds/projectile EffectName, missing precache resources and probable particle/sound cleanup leaks. Static heuristics must label uncertainty; a missing local native definition is not proof that a native ability is invalid. Keep reports human-readable under `docs/audit/` and reference existing contracts rather than creating competing inventories.

## Implementation and resource lifecycle

- Use deliberate, verified native override mechanisms. Audit `npc_abilities_custom.txt` for accidental native-ID shadowing. New custom IDs should use `enfos_<hero>_<ability>`; preserve existing stable IDs unless a deliberate migration is necessary.
- Keep tuning in KV AbilityValues/AbilitySpecial or established data configuration. Verify every Lua special-value lookup matches the defined key. Avoid scattered gameplay constants.
- Verify cast flags, target team/type/flags, range, mana, cooldown, cast point, animation/gesture, cast particle and sound.
- For travel, verify tracking versus linear behavior, speed, distance, radius, source attachment, visible EffectName and applicable travel audio. For impact, verify hit/death handling, damage/heal type and scaling, multi-target rules, modifiers, particles and sound.
- For persistent effects, verify aura/thinker/interval logic, duration and ownership. Inspect LinkLuaModifier paths/classes, visibility, debuff/purge/death rules, attributes, declarations, states, callbacks, stacking, refresh, multiple casters and server/client boundaries.
- Verify particle paths against real resources, then verify attach type, relevant control points, entity/world positions and visual radius. Use the appropriate control-point APIs. Creation alone is not proof of correct display.
- Verify sound events against actual definitions, including cast, impact, loops and termination. Repeated casts must not accumulate endless audio.
- Audit existing precache ownership for particles, particle folders, sound files, models and supported KV precache. Include cross-hero resources that would not otherwise load; do not preload the entire Dota installation.
- Ensure particles are destroyed and indexes released where required, modifier-owned resources clean up correctly, looping sounds stop, thinkers expire and handles are checked. Cover expiry, interruption, caster/target death and recast paths.
- Preserve integrations with waves, teams, Life/leaks, scaling, XP/gold, bosses, difficulty, selection, talents, items, modifiers and scoreboard/UI. Restore authoritative reconnect state without duplication.
- Prefer bounded event-driven work. Avoid per-frame global/radius scans, unnecessary quadratic combat work, repeated listeners/timers and particle/thinker spam. Create persistent particles once and update their control points. Keep summons and effects bounded without imposing a population cap on scheduled hostile waves.
- Update player-facing tooltips in EN/TR/RU/zh-CN when behavior changes. Communicate meaningful scaling and elite/boss exceptions; keep strings localized and implementation details out of player text.

## Validation and definition of done

Reuse or improve developer tools for hero/ability leveling, cooldown/mana reset, enemy spawning/reset, teleport and debug output. Cover normal creeps, groups, elites, boss dummies, immune/high-resistance/high-armor targets and friendly/low-HP/high-HP targets where relevant. Existing Workshop automation may help inspect resources, launch/reload, capture visuals and inspect VConsole; inspect the environment before integrations and avoid making the project depend on one external tool.

For each changed ability, record pass, fail, pending or justified not-applicable for these acceptance areas:

- Identity, coherent PvE role, classification/rationale and justified use of custom Lua.
- Level 1 and maximum level: targeting, valid/invalid targets, point-blank/maximum range, mana, cooldown, damage/heal, damage type, radius, duration and scaling.
- Single/group creeps, elites and bosses; immunity, armor/resistance, dispel and status resistance as applicable.
- Caster/target death, invulnerability during effects, projectile target loss, repeated casts, refreshed cooldowns, modifier refresh and multiple casters.
- Visible cast, projectile, impact and persistent effects: correct attachment, position and size; correct animations and modifier/buff icons. Capture visual evidence where possible.
- Audible cast, hit and loop behavior, including loop termination. A screenshot cannot prove audio behavior.
- Correct precache and cleanup, with no accumulated particles, thinkers, leaked entities or stuck effects after repeated use.
- Actual Dota runtime and VConsole: no Lua errors, resource/particle/sound warnings, modifier errors, null handles, client/server misuse, infinite loops or continuous log spam.
- Tooltip/localization agreement and relevant automated/integration regressions, including dense-wave performance and existing Enfos system compatibility.

Damage being dealt, absence of Lua errors or passing automated tests alone never establishes DONE. Every applicable area must pass. If Dota/VConsole, visual or audio validation cannot be performed, report precisely what remains pending; do not promote code-tested abilities to fully verified status.

## Change records and delivery

For each modified ability, record its stable ID, native original, class and rationale, Enfos behavior, elite/boss rules, references with provenance, intentional numerical changes, engine limitations/native deviations, tests/evidence and remaining gaps. Update the existing matrix/contracts/reports where suitable instead of duplicating truth.

Follow `../AGENTS.md` for focused changes, checks, diff review and Git delivery. Inspect before replacing systems; preserve contributor work and compatibility. Routine inspections, clear bug repairs, native restoration, shared-helper fixes, audit/debug tooling and matching localization do not require repeated approval. Major unrelated design changes remain outside this mandate.

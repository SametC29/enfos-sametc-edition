# AGENTS.md — Repository Operating Contract

This file stays concise. Detailed truth is under `docs/`.

## Read contextually
- `docs/GAME_DESIGN_MASTER.md` — gameplay/product source of truth.
- `docs/TECHNICAL_ARCHITECTURE.md` — system boundaries, data, authority, performance, persistence.
- `docs/IMPLEMENTATION_ROADMAP.md` — phased execution and acceptance gates.
- `docs/QA_BALANCE_RELEASE.md` — tests, simulation, compatibility, release.
- `docs/DECISIONS_OPEN_ITEMS.md` — locked/provisional/blocked decisions.
- `docs/REFERENCE_ANALYSIS_POLICY.md` — external references, licensed reuse and provenance rules.
- `docs/HERO_ABILITY_DEVELOPMENT_GUIDELINES.md` — required before hero/ability audits, repairs, PvE conversions, VFX/SFX, modifiers or precache changes.
- `docs/heroes/README.md` — find the affected hero, then read its `AGENTS.md` and `ABILITIES.md`, plus `docs/HERO_ABILITY_REFERENCE.md`, before every skill change (including shared Lua/KV/precache changes). These dossiers are evidence ledgers, not runtime certification.

Do not load every doc for trivial work.

## Non-negotiable product constraints
- Dota 2 Custom Game; original modern Enfo-inspired PvEvP survival.
- 60 authored waves; normal run target ~30 minutes.
- Boss every 5th wave and Boss wave contains only the Boss.
- Elite every 6th wave except Boss overlaps.
- Two normal lanes per team plus one shorter central Boss lane.
- Team Life starts at 100.
- Scheduled hostile waves have no population cap; population alone never costs Life.
- Spellbringer remains core: separate mana, 8 initial abilities.
- Full normal Dota shop remains; custom Ascended Shop adds 30 launch Ascended items.
- Tomes remain available from match start.
- Release roster: 40 heroes (8 each Tank/Fighter/Carry/Mage/Support); long-term target 100 (20 each).
- No hero-ban phase.
- Prefer Dota-native hero-selection experience if technically viable; prove early.
- Localization from day one: EN/TR/RU/zh-CN.
- Other custom games may supply code after exact source/version, license, compatibility and attribution are verified under REFERENCE_ANALYSIS_POLICY.md. Unclear permission means reference only; custom asset rights are separate.

## Engineering rules
1. Server-authoritative state.
2. Data-driven content and stable internal IDs.
3. Reversible, focused changes; no gratuitous rewrites.
4. Inspect before adding duplicate managers/services.
5. Performance: no unbounded units/summons/thinkers or per-frame global scans.
6. Normal Dota items follow upstream Dota; audit patch compatibility instead of forking all items.
7. Persistent progression behind an adapter; match works even if backend/HTTP is unavailable.
8. No hard-coded visible strings.
9. Structured logs/telemetry for balance-critical systems, no unnecessary PII.
10. Critical danger is communicated with icon/shape/text/sound as well as color.
11. Match config is versioned/snapshotted at match start.
12. Reconnect must restore authoritative match state without duplication.

## Hero and ability work
- Native first: keep native behavior, then tune, then convert only the PvP-specific part; full replacement is the last resort. Preserve recognizable Dota hero identity.
- The owner permits replacing every skill if evidence warrants it; no existing custom implementation must be retained merely because it exists. Follow pilot/hero rollout and preserve hero identity.
- Classify each ability as KEEP / TUNE / PVE-CONVERT / REPLACE with evidence before changing it. Never guess Dota identifiers, assets or engine behavior.
- Audit globally, repair shared root causes, validate 2–4 representative pilot heroes, then proceed hero by hero. Do not perform blanket Lua rewrites.
- Gameplay, VFX, SFX, modifiers, precache, cleanup and tooltips are one acceptance unit. Automated checks alone do not establish DONE; record actual Dota/VConsole verification or explicitly mark it pending.
- Follow the detailed guideline contextually; its rollout workflow does not authorize unrelated hero changes during a documentation-only task.
- Current user-directed progression target: match hero level 50; Q/W/E/R and the fifth Enfos passive each have 10 total ranks. This is a migration target, not implemented behavior. Free passive rank/point distribution, XP and unlock curves must be recorded explicitly before implementation; do not silently claim the old 30-level files implement this target.

## Git workflow
For each coherent logical work unit:
- inspect `git status`,
- preserve contributor work,
- sync safely if possible,
- implement,
- run relevant checks,
- review diff,
- update docs if durable behavior changed,
- make one atomic commit,
- push validated commit.

Never force-push, rewrite published history, routinely `reset --hard`, delete others' work, or push knowingly failing code.

Rollback:
- unpushed agent-only error: repair or restore only agent changes;
- pushed regression: fix forward or `git revert`, test, push.

## If uncertain
- Inspect repo and tests.
- Verify current Valve/Dota Workshop behavior in official documentation when external facts matter.
- Prefer feature/config flags for risky behavior.
- Put unresolved material product decisions in `DECISIONS_OPEN_ITEMS.md`, not silent assumptions.

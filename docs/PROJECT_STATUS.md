# Local candidate — 2026-09-28

Scheduled hostile population is now uncapped, without overflow Life damage.
40 skill-specific Evolution trees replace generic global bonuses; see
[audit and acceptance](audit/HERO_TREES_2026-09-28.md). No engine acceptance or upload.

# Current audit — 2026-09-27

**Latest local hero repair candidate:** [all-hero review](audit/HERO_REVIEW_2026-09-27.md).
40/200 inventoried and rank-matrix checked; 74 ability sections across 32 heroes
changed. Reincarnation, mana shielding, toggle/autocast, channel interruption and
thinker lifecycle repaired. New content trees/upgrades remain open; 63 ability
sections retain unreferenced-field review candidates. No new upload or engine playtest.

**New local candidate after the user's 40-wave test:**
[changes, checks, remaining content and local acceptance](audit/PLAYTEST_40_WAVES_2026-09-27.md).
Not uploaded. Exact increasing unit counts, wave deadlines, true lane-head spawns,
boss phase gates, reduced baseline power/Boon frequency, on-kill-only payouts,
elevation-following native HOME access and strengthened hero smoke checks.
Unique hero trees/Aghanim upgrades and 30 distinct Ascended PvE mechanics remain open.

V1.0.1 startup fix: removed the unsupported shop-trigger `SetSize` call
that can abort activation before team/hero setup. Corrected the mock API regression.
Only the canonical `enfos` map remains; the identical `enfos_sametc` map alias was
removed. The user accepted the local fix and authorized publication. SteamCMD
accepted the update; public metadata shows V1.0.1. Download verification is pending:
SteamCMD currently still returns the V1.0.0 archive, including with the author login.
See [startup fix and local test](audit/SETUP_STARTUP_2026-09-27.md).

**Prototype; engine gameplay acceptance is incomplete.** Current findings and player test sequence:
[Player feedback audit](audit/PLAYER_FEEDBACK_2026-09-27.md).

- 40 heroes / 200 authored abilities exist. Mock execution does not prove all gameplay behavior.
- Fixed player-name fallback, point-targeted Spellbringer, controllable bounded summons,
  boss resource paths/precache, four particle paths and seven missing ability icons.
- Replaced overlapping shops with a universal HOME volume spanning elevated platforms;
  actual recipe purchase still needs the user's engine test.
- All 40 fifth skills are tagged as innates and get an initial free rank. 23 missing
  ultimate types were corrected; Scepter/Shard metadata now describes existing effects.
- Twelve shared Evolution choices now have real modifiers and reliable deferral/reapplication.
  A hero-specific Watcher-inspired tree and unique Shard/Scepter mechanics are not complete.
- 30 Ascended definitions now derive from current native item classes with starred names,
  selected flat bonuses +20%, charge/cooldown preservation and current sale costs.
  Native behavior requires engine acceptance; 30 unique designed PvE extensions remain open.
- Top Wave/Life and Spellbringer UI updated; only changed Panorama resources compiled.
  The 11 protected map/theme files remain unchanged.
- Hand-entered DPS simulations cannot establish solo or 60-wave balance. The desktop
  Antigravity report and zero-warning MCP structural audit are not gameplay acceptance.

User instruction: local commits only; no push. Live testing belongs to the user.
Steam Workshop item **3809160125** is **public**, titled
**Enfos Team Survival - SametC Edition V1.0.1**, with the **Custom Game** tag.
On 2026-09-27 Steam accepted the V1.0.1 upload and anonymous metadata confirmed its
title, public visibility, new manifest and size. Download delivery is not yet verified;
do not mistake the successful V1.0.0 download check for a V1.0.1 check. Gameplay code
was unchanged after the user's local acceptance.
See [Workshop release record](WORKSHOP_YAYINLAMA.md); Arcade search and remote live
gameplay acceptance remain separate user tests.

---

# Verified project status — 2026-09-26

The desktop handoff report is historical context, not acceptance evidence or a
replacement for GAME_DESIGN_MASTER / DECISIONS_OPEN_ITEMS / IMPLEMENTATION_ROADMAP.

## Evidence and current scope

Latest playtest fixes and current validation: see [RUNTIME_FIXES.md](RUNTIME_FIXES.md).
The historical inventory below predates the five-hero and Wave/Life implementation.

- Main entry point, logging and seeded RNG exist. One Sven/Bulwark prototype has
  five abilities; this does not prove native selection for 40–100 custom heroes.
- Two Ascended item prototypes exist. Lumber purchase, base-item consumption,
  uniqueness, sellback and the designed shield/reflect-heal effects are absent.
- Challenge currently applies armor only. Its taunt remains an incomplete gameplay
  feature; localized descriptions describe the armor effect without claiming taunt.
- Four language sources generate both runtime copies. Numeric tooltip values come
  from KV specials. Earlier handoff claims of complete numeric accuracy were false.
- Source and compiled maps exist. Routing, leak triggers, arena isolation against
  flight/Blink/TP and multiplayer navigation require engine acceptance tests.
- No implemented Wave/Life/cap, Spellbringer, economy, progression, Boons or HUD yet.
- The MCP server initializes and exposes 111 tools. Dota/Workshop Tools/project
  installation detection passed. Dota was closed during the initial audit;
  screenshots and runtime claims in the handoff were not reproduced.

## Foundation corrections

- Replaced the broken batch checks with a small CRLF launcher and a portable Node
  validation command. Added pinned Lua syntax/runtime test dependencies and lockfile.
- Real KV parsing rejects malformed/duplicate entries; coverage, hero references,
  generated translations and production map allowlisting are checked.
- Removed reference/test maps from addoninfo. Local untracked reference/test VPKs
  were preserved under `references/enfo_map/quarantined-builds/`, outside `game/`.
  `enfos_reborn.vpk` and `enfos_sametc_reborn.vpk` matched the external reference
  byte-for-byte. They are not project-authored distributable maps.
- Map generator still contains reference-derived exact coordinate claims and
  machine-specific imports. Its provenance/build reproducibility needs a separate
  review before map replacement or release; do not regenerate blindly.

## Remaining gates, in priority order

Courier hardening now checks destination capacity before detaching items, restores
rejected transfers to the source slot, validates command ownership/team, consumes
handled native commands, and cancels delivery on Stop. Unknown owners use a bounded
retry queue; the engine alone creates couriers. Ten mock-engine tests pass. Actual
engine delivery remains unverified: a test launch reached VConsole but returned no
fresh gameplay assertion, and the process later became unavailable. The optional
`tools/dota.mjs` bridge drains replayed console history before querying.

User direction: local commits only, no GitHub push (2026-09-26).

Map direction (2026-09-26): preserve Enfos survival (Workshop 3591082091)'s layout and
elevations; change its theme to autumn forest and stone roads. The user explicitly
authorized map geometry reuse for this work, superseding the earlier geometry
prohibition. Other reference gameplay code/custom assets remain excluded.

1. Courier capacity/ownership/reconnect behavior and item conservation.
2. Complete Phase 1 proofs: selection, six-slot delivery design, shop integration,
   authoritative events and unavailable persistence behavior.
3. Phase 2: original map layout, bounded arena movement, authored routes, stuck
   recovery and exactly-once Core leaks. Then Phase 3 Wave/Life/cap.
4. First playable five-wave slice, then accelerated 30+ wave stability tests.
5. Follow the repository roadmap for heroes, Spellbringer, economy and full content.

The 2026-09-28 user revision removes the scheduled-hostile population cap and
its Life penalty. Preserve temporary-summon rules and eight named Spellbringer abilities.
Reference analysis reports exist, but blocked decisions are not automatically
unblocked by their existence; a concrete decision/proof is still required.

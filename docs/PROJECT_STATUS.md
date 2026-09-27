# Current audit — 2026-09-27

Latest changes: [hero power instead of solo enemy reductions](audit/HERO_POWER_2026-09-27.md),
[native team spawn markers](RUNTIME_FIXES.md), and [Batch 1 Hero PvE Kits Rework](HERO_PVE_REWORK_MATRIX.md).
Batch 1 provides authoritative PvE kits for 6 representative heroes across all 5 roles:
Sven (Tank), Juggernaut (Fighter), Drow Ranger (Carry), Lina (Mage), Omniknight (Support), and Luna (Carry)
covering 30 complete abilities with attribute scaling, boss diminish/caps, and crowd clearing.
All 109 automated behavior tests and repository checks pass (11 dedicated hero kit regressions,
14 audit regressions, 9 hero power regressions, 6 spawn regressions, 6 runtime wave regressions,
49 core behavior tests, 11 JavaScript/validator tests, 3 tool validation checks).
29 unfinished Ascended upgrades remain purchase-gated; launch target stays 30.
Live testing belongs to the user; offline validation and simulation complete.

**Release status: prototype; gameplay acceptance incomplete.** See [Codex audit](audit/CODEX_AUDIT_2026-09-27.md) for corrected defects, verified evidence, production economy arithmetic, and remaining release blockers. The desktop Antigravity report is not acceptance evidence.

For the next development pass, follow [Antigravity continuation plan (TR)](ANTIGRAVITY_DEVAM_PLANI.md) and [Antigravity Hero Overhaul (TR)](ANTIGRAVITY_KAHRAMAN_YENILEME_PROMPTU.md). Current user instruction: local commits only; no push. Live testing performed by user.

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

Do not replace the documented cap seed (30 × active players), Boss exemption,
temporary-summon rules or eight named Spellbringer abilities with handoff examples.
Reference analysis reports exist, but blocked decisions are not automatically
unblocked by their existence; a concrete decision/proof is still required.

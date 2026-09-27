# Codex code and design audit — 27 September 2026

## Verdict

The repository is a substantial Dota 2 Custom Game prototype, **not a completed or
release-validated game**. The intended structure is recognizable: 40 heroes, five
roles, 60 wave definitions, Life, Spellbringer, economy and HUD services exist.
Several advertised mechanics are only data, UI or empty handlers. Passing the
old tests and MCP addon audit did not establish that those mechanics worked.

Reviewed baseline: `2434f75`, branch `codex/project-hardening`. The desktop report
was read from `C:/Users/samet/Desktop/ENFOS_SAMETC_PROJE_DURUMU_VE_CODEX_GECIS_RAPORU.txt`
(file modified 27 September 2026, 03:41; its internal header still said 02:45).
That report is an implementation claim, not a test result. Its publishing section
does not override the user's **local commits only** instruction.

Ten pre-existing content CSS modifications were preserved and mirrored into the
runtime tree. No map geometry rebuild or remote publication was performed.

## Corrections in this audit

| Area | Defect | Correction |
|---|---|---|
| Tests | Fengari can emit an exception without a nonzero process exit; the runner accepted this | Require clean stderr and the suite completion marker as well as exit status |
| Roster | Server selection allowed 20 heroes while UI and KV claimed 40; Aghanim roles included heroes outside the actual roster | Generate one server roster from production hero KV; share it with selection and Aghanim |
| Selection | Client could change difficulty/team after setup, repeat picks or act with a missing identity defaulting to player 0 | Validate player, phase, host permission, team size and one locked pick per player |
| Selection UI | Lua net-table arrays were treated as JavaScript arrays; fallback data could hide server mismatch | Consume authoritative role chunks and normalize arrays; stop resending the full roster every second |
| Difficulty | Selection changed a string but not creep HP | Apply the displayed HP multiplier at spawn, including after multiplayer Boss scaling |
| Economy | Costs checked total gold but deducted only reliable gold | Use the engine SpendGold API for conversion, transfer and Tomes |
| Economy | Nonfinite/unbounded values could reach resource mutations | Reject NaN, infinity, invalid and excessive amounts before mutation |
| Ascended purchase | Base item was destroyed before replacement; rollback recreated a different item and lost slot/state | Preserve the original handle, confirm replacement in inventory, restore exact handle/slot on failure, preserve cooldown |
| Ascended sale | Direct calls could refund an item not held by the hero; native sale bypassed the Lumber refund | Validate exact inventory membership and route native Ascended sale through the service |
| Ascended purchase bypass | Native item purchases could avoid parent-item/Lumber checks | Mark Ascended definitions non-purchasable through the native shop |
| Spellbringer | No initial player state meant the HUD could refuse its first cast | Initialize eligible players from the match thinker and snapshot single-team/co-op mode |
| Spellbringer | Arcane Barrier iterated an entity-index map with ipairs, often applying no buff | Iterate keyed entries |
| Spellbringer | Offensive summons belonged to the defending players; Rift Surge called a nonexistent AI method and had no expiry | Spawn neutrals, attach real route AI, and enforce a bounded lifetime |
| Spellbringer | Client fallback identity and arbitrary coordinates; failed execution still reported success | Accept engine PlayerID only, validate phase/arena/finite coordinates, refund failed execution |
| Spellbringer | Displacement reset a nonexistent waypoint field | Store the AI state on the unit and reset its real waypoint index |
| Aghanim | Ultimate-only bonuses applied to every spell; some heroes had the wrong role; reflect could reflect itself | Scope bonuses to ultimate abilities, correct the shared roles, reject reflected damage; retain permanent modifiers through death |
| Ability metadata | Many slot-four ultimates lacked the ultimate type | Set the type from the authoritative hero roster |
| First five hero kits | Twelve Lua implementations existed but **none was connected to its ability KV** | Wire the implementations and remove conflicting data-driven handlers |
| Assets | 16 ability icon references and 11 particle references did not exist in installed Valve content | Use verified stock icons; repair used particle paths and remove invalid unused precache entries |
| Progression | Profiles were not loaded on actual hero spawn; current-schema malformed profiles bypassed migration | Load once on spawn and normalize required fields for every schema load |
| Persistence honesty | An in-memory adapter appeared as a durable progression system | Publish storage capability and show localized session-only status |
| Participation | Confirmed abandoned heroes still counted just because an entity remained | Exclude confirmed abandoners from future wave and shared bounty counts; retain temporary disconnects |

The first-five-hero wiring restores actual taunt, chance-based crit, repeated
Omnislash damage, Drow attack procs/projectiles, Lina cast stacks/burn/splash and
Guardian Angel physical immunity. Drow Frost Arrows is a mana-free passive PvE
adaptation. Numerical descriptions were updated. These are project-owned
implementations using Valve assets; no Watcher source code was imported.

## Production economy arithmetic

The old `tools/economy_simulator.mjs` estimated wave compositions and difficulty
rewards instead of running production definitions; its unit KV lookup also used
the wrong root. Its green balance gates are not acceptance evidence. It remains
explicitly marked as an exploratory model and is no longer a release check.

`tools/wave_economy.mjs` executes the actual Lua planner and joins the actual unit
KV bounties. [wave-economy.csv](wave-economy.csv) covers all 60 waves for teams of
1–5 players (300 configurations).

Wave 1, solo: 12 soldiers + 8 archers = 20 scheduled enemies. Their base bounty
totals 216–296 Gold and 256 XP. Clear reward is 60 Gold + 80 XP. With every last hit
credited to that player, expected Gold is 367.2 including the killer bonus and
clear reward; XP is 336. Fractional Gold is carried between awards, so the visible
integer payment for a particular kill can differ by one. Gold range displayed in
the wave HUD is the team's **base** creep bounty, before the killer bonus.

For P players, the killer receives +20% of their equal share, not +20% of the whole
bounty. The CSV's mean assumes equal last hits. Leaks are excluded from creep
bounty. This proves arithmetic, **not combat balance, clear speed or 30-minute
completion**. Special/Elite units spend more threat; 20 equivalents is not always
20 physical units. Boss waves schedule one Boss per occupied team.

## Remaining release blockers — do not mark DONE

| Priority | Evidence | Required completion |
|---|---|---|
| P1 | `evolution/evolution_manager.lua` calls undefined `modifier_enfos_evolution_*` names under pcall; only a few direct stats change | Implement all twelve advertised choices, persist through death, restore on reconnect; test actual effects rather than queue length |
| P1 | `boons/boon_manager.lua` stores stacks/history; Emergency Seal is the only immediate effect, and no other service consumes most stacks | Implement all advertised Boon/Pact effects and risk costs; test combat/economy consequences |
| P1 | Content audit finds 21 non-passive Ascended items with no cast handler (including BKB, Satanic, Refresher, Vyse) | Restore parent functionality and implement each custom effect; verify exact current parent-item stats/costs and refunds |
| P1 | Six abilities have no detectable gameplay implementation: Wraith King Reincarnation, Anti-Mage Blink/Counterspell, Void Time Walk, creep Reflector/Bloodbeast | Implement and playtest; presence of a name/icon is not completion |
| P1 | Other skills can have partial behavior despite nonempty handlers: Medusa Mana Shield only grants mana; several crit properties are unconditional | Audit all 200 hero skills against descriptions and native behavior; add feature-specific tests |
| P1 | `progression_manager.lua` has no match-end caller for AwardMatchRewards; HTTP adapter delegates to memory; Legacy and Mastery bonuses are not integrated into gameplay | Wire authoritative match results, gameplay bonuses and a real durable backend; keep session-only status until durable save is confirmed |
| P1 | Wave 61 sets VICTORY without a match result or Endless transition; match config has no real versioned snapshot | Complete the agreed result/Endless flow and snapshot rules before release |
| P1 | Boss AI dispatches unique behavior for only the first three Bosses; the max-stun constant is unused; the supposed percent-HP cap clamps all large hits | Finish all 12 Boss kits and enforce correctly scoped CC/percent-HP/reflect rules |
| P1 | Brood spiderlings are untracked and have no timed cleanup; the Boss-only policy needs enforcement | Remove or explicitly resolve the Boss-add design conflict; ensure bounded lifetime, no bounty and transition cleanup |
| P1 | Evolution defer response resends pending choices and the client immediately reopens the modal | Preserve defer state across updates/reconnect; implement actual choice effects together |
| P2 | Difficulty unlocks are not checked by setup; UI and persistent XP difficulty coefficients differ | Centralize difficulty data and enforce the selected progression policy |
| P2 | Many visible strings remain hardcoded; RU/zh-CN files contain fallback text | Complete real translations and localized errors/tooltips; file/key coverage alone is insufficient |
| P2 | Native hero selection preference was replaced with a custom screen without documented POC acceptance | Record the user's accepted choice and verify 1–5 per team, reconnect and timeout behavior |
| P2 | Map isolation against Blink/flight/TP, minimap movement, portals, AI route reachability and HUD overlap remain unproven in engine | Run both aliases and multiplayer acceptance scenarios; keep existing geometry intact |

The JSON inventory [content-audit.json](content-audit.json) enumerates all 216
ability definitions and Ascended cast-handler gaps. Its empty-handler heuristic
is a lower bound: it cannot certify that nonempty handlers do everything promised.
Asset existence also does not certify correct control points, sound playback or
particle lifetime. No "100% working" claim is justified by this inventory.

## Verification evidence

- Repository checks: 49 existing behavior tests + 6 runtime regression tests +
  13 new audit regressions; all mocked-engine tests. Two KV parser tests also pass.
- New tests cover real generated roster/role alignment, host and phase validation,
  locked picks, nonfinite economy input, all 300 wave plans, attack-order stability,
  sparse Spellbringer targets, arena rejection, Scepter scope, reflection recursion,
  damaged profile migration, exact Ascended rollback and crit/Fiery Soul/Angel behavior.
- Installed Valve VPK audit: no missing referenced particle or ability-icon paths
  after repairs. Hero precache and stock soundfile precache added for the connected kits.
- MCP addon_audit baseline: 0 warnings. This tool checks structural conventions,
  not gameplay semantics; it missed the defects above.
- MCP Lua API lookup confirmed SpendGold, SetSelectedHero, host privilege checks,
  modifier cooldown/amplification callbacks and state-transition query availability.
- Source 2 resourcecompiler: 34 Panorama resources compiled, 0 failed.
- Live launch requested through MCP; the process terminated and subsequent
  dota_diagnose reported no running Dota process. No fresh live gameplay assertions
  were obtained. Do not count this as a successful map/playtest.

## Historical conversation

The accessible conversation **Dota 2 Harita Yenileme** was found with ID
`6ab52a26-f024-83ed-8c5b-c2c6d314e564`. Its returned history explicitly described
Watcher/Enfos mechanics as references to independently reproduce and adapt, and
named the project Enfos Team Survival SametC Edition. This audit preserves those
decisions. The conversation was not moved or modified, and the accessible excerpt
is not a claim to have recovered every historical message. Current user decisions
and the design documents take precedence over historical automation/push requests.

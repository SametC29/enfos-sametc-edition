# Reference Analysis: Enfo's Team Survival

- **Mod References Inspected**: Workshop IDs `3694146502` (Enfos Team Survival: Reborn) & `3591082091` (EnfosSurvival)
- **Role in Project Hierarchy**: Rank 1 — Primary Core Blueprint & Arena Skeleton

---

## 1. System Inventory & Mechanics Extracted

### 1.1 Map Topology & Lane Structure
- **Arena Division**: 2 distinct, mirrored arenas separated by impassable boundary.
- **Lane Paths**:
  - Two primary outer/inner creep lanes converging towards an objective (Life Core / Spire).
  - Central lane reserved for heavy/boss units.
  - Waypoint tracking (`path_track` / `point_template`) enforcing strict route following without wandering across arenas.

### 1.2 Wave & Spawning Rhythm
- **Batching Strategy**: Waves spawn in sub-batches (typically 3 batches spaced ~1-2 seconds apart) rather than dumping 30+ units in a single tick.
- **Inter-Wave Interval**: 15s to 20s transition gap containing clear phase signals (warning sound, incoming visual telegraph).
- **Life Penalty on Leak**:
  - Creeps reaching the Life Core trigger removal and deduct life immediately.
  - Special bonus/flying waves (e.g. Spirit Hawk/Owl) test burst DPS and reward bonus lives without penalizing if leaked.

### 1.3 Spellbringer / Indirect Interference
- Dedicated entity/building with separate Mana pool.
- Allows sending buff totems, armor boosts, and hostile summons into the opponent's arena without directly attacking enemy heroes.

---

## 2. Concept Classification

| Concept / Mechanic | Classification | Rationale & Action Plan |
|---|---|---|
| **Mirrored 2-Lane Arena + Central Boss Lane** | `ADAPT_CONCEPT` | Core to our project identity. Reimplement cleanly with modern Dota 2 mesh & navigation grid. |
| **Batched Wave Spawner (3-batch burst)** | `ADAPT_CONCEPT` | Essential for server tick stability and creep readability; prevents instant unit-cap overflow. |
| **Separate Spellbringer Mana & 8 Abilities** | `ADAPT_CONCEPT` | Server-authoritative `SpellbringerService` in Lua with dedicated Panorama HUD. |
| **Hardcoded WC3 Ability Replicas** | `REJECT` | Outdated, clunky WC3 ported Lua. We design native Dota 2 mechanics and modern particle telegraphs. |
| **Bonus Flying Life-Gain Waves** | `REFERENCE_ONLY` | Keep as balance reference; our primary wave skeleton follows the 60 authored waves (Boss every 5th, Elite every 6th). |

---

## 3. Architecture Impact for Enfos SametC Edition
- **`WaveDirector`**: Incorporate the 3-sub-batch spawning sequence with configurable delays.
- **`UnitCapService`**: Connect batch checks directly to threat budget and overflow leaks.
- **`CreepAIService`**: Ensure waypoints cannot be path-blocked permanently by heroes or summons.

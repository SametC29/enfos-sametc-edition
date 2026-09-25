# Reference Analysis: Watcher of Samsara & Custom Hero Clash

- **Mod References Inspected**:
  - `3164617180` (Watcher of Saṃsāra)
  - `2141071809` (Custom Hero Clash)
- **Role in Project Hierarchy**:
  - Rank 2: Watcher of Samsara (Hero Ability & In-match Progression)
  - Rank 3: Custom Hero Clash (100 Hero Roster Scaling, Ability Overhauls, Mastery & Wave Scaling)

---

## 1. System Inventory & Mechanics Extracted

### 1.1 In-Match Progression & Evolution (Watcher of Samsara)
- **Draw / Choice Cards**: Rather than traditional passive stat allocation, choices appear at key milestones giving heroes tailored power spikes (damage branch vs utility branch).
- **Hero-Specific Synergies**: Skills interact cohesively (e.g. passive triggers amplified by active casts).
- **Elite Affixes & Modifiers**: Elites carry explicit single-focus auras (magic drain, gallop, barrier, shield) that visibly change how a player prioritizes targets.

### 1.2 100-Hero Roster & Ability Scaling (Custom Hero Clash)
- **Extensive Ability Rewrites**: Custom Hero Clash overrides vanilla Dota abilities to function cleanly in PvE/PvEvP environments (adding wave clear scaling, max HP caps on percentage damage).
- **Mastery Tree & Innate Hooks**:
  - Innate traits define core playstyle before selecting items.
  - Mastery progression gives alternate ability choices rather than purely inflated raw numbers.
- **Boss Phase Design**:
  - Telegraphed attacks (`jump_smash`, `mouth_beam`, `temporal_shock`) with clear ground particles and cast-time windows.
  - Dynamic enrage phases (`boss_berserking`, `boss_rage`) when reaching specific HP thresholds.

---

## 2. Concept Classification

| Concept / Mechanic | Classification | Rationale & Action Plan |
|---|---|---|
| **Milestone In-Match Evolution Cards (6 Milestones)** | `ADAPT_CONCEPT` | Adopt a unified 2-card milestone choice system at levels 4/7/10/13/16/19. Queueable without pausing game. |
| **Elite Single-Modifier Framework** | `ADAPT_CONCEPT` | Reusable elite modifier scripts (Shield, Reflector, Mindstealer) with readable nameplates. |
| **Boss Enrage & Telegraphed Skill Sequence** | `ADAPT_CONCEPT` | Telegraphed attacks with strict CC & percentage-damage caps to keep tanks and control builds viable. |
| **RNG Gacha Draw for Heroes/Towers (Watcher)** | `REJECT` | Unsuitable for competitive PvEvP. We use native Dota hero selection with deterministic hero kits. |
| **Unbounded Stat Inflation (CHC Deep Late-Game)** | `REJECT` | Our target is a structured ~30 minute run with capped power escalation. |

---

## 3. Architecture Impact for Enfos SametC Edition
- **`HeroBuildService`**: Unify card choices and talent progression into a single clean in-match choice queue.
- **`BossDirector`**: Implement phase triggers, ground warning telegraphs, and hard CC reduction rules.
- **`EliteService`**: Data-driven affix definitions attached dynamically to wave spawns.

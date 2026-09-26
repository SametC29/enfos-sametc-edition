# Enfos Team Survival — SametC Edition

A modern Enfo-inspired PvEvP survival custom game for Dota 2.

## Overview

- **60 authored waves** with Boss/Elite encounters
- **PvEvP via Spellbringer** — interfere with opponent's PvE without direct hero grief
- **40 heroes at launch** (8 per role: Tank/Fighter/Carry/Mage/Support), scaling to 100
- **Full Dota shop** + 30 custom Ascended items
- **Team Boons, Pacts**, and deep hero progression
- **4 languages**: English, Turkish, Russian, Simplified Chinese

## Project Structure

```
├── AGENTS.md                  # AI agent operating contract
├── CODEX_START_HERE.txt       # Agent bootstrap instructions
├── docs/                      # Game design, architecture, roadmap
├── game/                      # Dota 2 addon (game logic, scripts, UI)
│   ├── scripts/vscripts/      # Lua game logic
│   ├── scripts/npc/           # KV data definitions
│   ├── resource/              # Localization files
│   ├── panorama/              # Custom UI (Panorama)
│   └── addoninfo.txt          # Addon metadata
├── content/                   # Workshop Tools source assets (maps, particles)
├── tools/                     # Validators, checks, build scripts
└── references/                # Reference game analysis (gitignored ZIPs)
```

## Setup

### Prerequisites
- [Dota 2](https://store.steampowered.com/app/570/Dota_2/)
- [Dota 2 Workshop Tools DLC](https://store.steampowered.com/app/316570/)
- [Git](https://git-scm.com/)

### Installation

1. Clone this repository:
   ```
   git clone <repo-url> "c:\Enfos Team Survival SametC Edition"
   ```

2. Create symlinks to Dota 2 addon directories (Admin PowerShell):
   ```powershell
   $dota = "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta"
   $repo = "c:\Enfos Team Survival SametC Edition"

   New-Item -ItemType Junction -Path "$dota\game\dota_addons\enfos_sametc" -Target "$repo\game"
   New-Item -ItemType Junction -Path "$dota\content\dota_addons\enfos_sametc" -Target "$repo\content"
   ```

3. Launch Dota 2 Workshop Tools and select "enfos_sametc"

### Running Checks
Install the pinned development tools once with `npm ci`, then run:
```
tools\checks.bat
```

`npm run check` runs the same checks cross-platform. It parses authored KeyValues,
checks Lua 5.1 syntax, verifies content references, localization parity/generated
values and the production map allowlist, and runs regression tests. These checks
do not replace Dota engine playtests.

Edit translation sources in `localization/*.json`, then run `npm run localize`.
Numeric `{{special_name}}` fields are expanded from ability/item definitions into
both runtime localization directories. Do not edit generated language files.

Current implementation is an early prototype, not the complete feature list above.
See [verified project status](docs/PROJECT_STATUS.md) for implemented scope and gates.

## Documentation

| Document | Purpose |
|---|---|
| [GAME_DESIGN_MASTER.md](docs/GAME_DESIGN_MASTER.md) | Product/game design source of truth |
| [TECHNICAL_ARCHITECTURE.md](docs/TECHNICAL_ARCHITECTURE.md) | Engineering architecture |
| [IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) | Phased execution plan |
| [DECISIONS_OPEN_ITEMS.md](docs/DECISIONS_OPEN_ITEMS.md) | Locked/provisional/blocked decisions |
| [QA_BALANCE_RELEASE.md](docs/QA_BALANCE_RELEASE.md) | Testing, balance, release process |
| [REFERENCE_ANALYSIS_POLICY.md](docs/REFERENCE_ANALYSIS_POLICY.md) | Clean-room reference rules |

## License

Private project. All rights reserved.

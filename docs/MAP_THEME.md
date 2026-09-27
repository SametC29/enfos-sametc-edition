# Map Theme Build & Material Transformation

This document describes the automated map theme pipeline for Enfos Team Survival — SametC Edition.

## Purpose & Strategy

Following user direction, the map layout, navigation hulls, and walkable elevations of authentic Enfos Survival (Workshop ID `3591082091`) are strictly preserved. To avoid decompiler incompatibilities (`VCS file version 71`) and ensure 100% bug-free pathing without broken ramps or cliffs, the geometry VPK is preserved byte-identical while visual materials, road blends, and tree foliage are transformed to the **Autumn Forest & Stone Paths** theme.

## Architecture

1. **Configuration**: `content/map-theme.json`
   - Defines target materials and color tints:
     - Mines/destruction roads mapped to `mod_radiant_autumn_path_000.vmat_c`.
     - Jungle blends mapped to `mod_radiant_autumn_000.vmat_c`.
     - Dire rockwalls mapped to `rockwalls_radiant_fall.vmat_c`.
     - Ground overlays mapped to `leaves_fall000.vmat_c`.
     - Tree leaves tinted with warm autumn golden vector `[1.8, 0.65, 0.12]`.
2. **Material Patcher**: `tools/lib/material-tint.mjs`
   - Modifies the `g_vColorTint` vector directly inside Valve's NTRO material `DATA` block without re-encoding, preserving normal maps, alpha channels, UVs, and wind animation flags.
3. **Build Tool**: `tools/build_map_theme.mjs`
   - Reads the reference VPK from Steam workshop content.
   - Extracts base map geometry only as `maps/enfos.vpk`. The duplicate
     `enfos_sametc.vpk` was removed on 2026-09-27; the addon remains `enfos_sametc`.
   - Copies overview assets and applies autumn materials and color tints.
   - Writes atomic manifest to `game/map-theme-build.json`.

## Usage

```powershell
node tools/build_map_theme.mjs
```

All generated assets are placed under `game/` and verified with `node tools/checks.mjs`.

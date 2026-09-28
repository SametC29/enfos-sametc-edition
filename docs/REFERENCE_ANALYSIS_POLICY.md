# REFERENCE ANALYSIS AND LICENSED REUSE POLICY

## Owner update — 2026-09-29

The owner removed the blanket prohibition on taking code from other custom games.
Watcher, Enfo, hero-rework and PvE projects may be implementation sources when
their exact license or explicit permission allows the intended reuse and the
project can meet the conditions. Public visibility or Workshop availability
alone is not permission. Unclear permission remains reference only.

The owner also permits changing all hero skills if needed. No existing custom
implementation is mandatory. Preserve recognizable Dota hero identity, document
KEEP/TUNE/PVE-CONVERT/REPLACE decisions and validate pilots before roster rollout.
This update permits necessary replacement; it does not initiate 200 rewrites.

## Before incorporating code or data

Record in the affected hero dossier or docs/reference-analysis/:
1. upstream repository, exact commit/tag, file paths and intended use;
2. exact license text or explicit permission and its scope;
3. compatibility with this project's intended distribution, including applicable
   attribution, notices, source-distribution or other conditions;
4. dependencies: helper libraries, modifiers, KV, upgrades and resources;
5. adaptations, intentional native deviations and regression/runtime evidence.

Preserve required license/copyright notices alongside reused material and maintain
an import inventory when reuse occurs. Do not label modified upstream code as
independently written. Do not assume all files share one license or that GPL and
exception terms are interchangeable with permissive licenses. Resolve material
compatibility uncertainty before importing affected material; continue unaffected work.

Prefer small, understood integrations over transplanting entire addons. Reuse
Enfos managers and stable IDs; reconcile authority, cleanup, performance,
localization, boss rules, level50/rank10 and upgrade dependencies. Working in
another game is not evidence of acceptance in this build of Enfos.

## Code and asset permissions are separate

Models, textures, icons, particles, audio/music/voice, maps, names/lore and text
require rights covering those files and the intended use. A code license does
not automatically cover third-party art or Valve resources bundled by another
author. Prefer valid Valve/Dota resources for this addon or original assets.
Without established permission, study behavior and implement independently;
do not import proprietary dumps.

## Reference-only workflow

For sources without reuse permission: describe behavior neutrally, identify its
purpose, decide fit, write an Enfos design, implement independently and use
permitted resources. Classify each source/use as REFERENCE_ONLY, ADAPT_CONCEPT,
LICENSED_REUSE or REJECT, with evidence. Cross-check familiar Dota abilities
against the installed build regardless of reference type.

Reports include useful/rejected concepts, production impact and an honest
import/provenance inventory. No import means recording that fact; licensed reuse
means recording imported files and conditions.

## Existing map exception — 2026-09-26

The user authorized the same Enfos survival (Workshop3591082091) layout with an
autumn forest/stone-road theme, including geometry, elevations, paths and placement.
That specific map authorization remains. Code reuse now follows the update above;
unrelated asset permission is not implied. Work remains local only: the user
declined public GitHub push. This update does not authorize publication.

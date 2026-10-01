# Enfos unit model VPK audit — 2026-10-01

Status: **STATIC MODEL-PATH CHECK PASS; IN-ENGINE VISUAL CHECK PENDING**.

## Question and result

The update list reports some wave units rendering as the Dota “ERROR” placeholder. The current authored NPC roster contains 37 Enfos unit definitions and 35 unique model paths. MCP VPK path lookup resolved every unique path below to its compiled model asset in the installed base-game archive. No authored Enfos unit uses an “ERROR” model path or lacks a Model field. This rules out a missing VPK path in the current roster; it does **not** prove the model/material loads on a spawned unit in the engine or identify a stale Workshop/map package mismatch.

## Current authored unit model references

| Unit ID | Model path |
|---|---|
| `enfos_creep_soldier` | `models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl` |
| `enfos_creep_archer` | `models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl` |
| `enfos_creep_runner` | `models/creeps/neutral_creeps/n_creep_kobold/kobold_b/n_creep_kobold_b.vmdl` |
| `enfos_creep_frostguard` | `models/creeps/neutral_creeps/n_creep_ghost_a/n_creep_ghost_a.vmdl` |
| `enfos_creep_venomous` | `models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll.vmdl` |
| `enfos_creep_healer` | `models/creeps/neutral_creeps/n_creep_forest_trolls/n_creep_forest_troll_high_priest.vmdl` |
| `enfos_creep_shieldbearer` | `models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl` |
| `enfos_creep_mindstealer` | `models/creeps/neutral_creeps/n_creep_satyr_a/n_creep_satyr_a.vmdl` |
| `enfos_creep_skyraker` | `models/creeps/neutral_creeps/n_creep_harpy_a/n_creep_harpy_a.vmdl` |
| `enfos_creep_silencer` | `models/creeps/neutral_creeps/n_creep_vulture_b/n_creep_vulture_b.vmdl` |
| `enfos_creep_conqueror` | `models/creeps/neutral_creeps/n_creep_golem_a/neutral_creep_golem_a.vmdl` |
| `enfos_creep_assassin` | `models/creeps/neutral_creeps/n_creep_harpy_a/n_creep_harpy_a.vmdl` |
| `enfos_creep_summoner` | `models/creeps/neutral_creeps/n_creep_troll_dark_a/n_creep_troll_dark_a.vmdl` |
| `enfos_creep_spellguard` | `models/creeps/neutral_creeps/n_creep_gargoyle/n_creep_gargoyle.vmdl` |
| `enfos_creep_reflector` | `models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl` |
| `enfos_creep_exploder` | `models/creeps/neutral_creeps/n_creep_ogre_med/n_creep_ogre_med.vmdl` |
| `enfos_creep_splitter` | `models/creeps/neutral_creeps/n_creep_tadpole/n_creep_tadpole_v2.vmdl` |
| `enfos_creep_bloodbeast` | `models/creeps/neutral_creeps/n_creep_worg_large/n_creep_worg_large.vmdl` |
| `enfos_creep_cursecaster` | `models/creeps/neutral_creeps/n_creep_vulture_a/n_creep_vulture_a.vmdl` |
| `enfos_boss_stonebreaker` | `models/heroes/tiny/tiny_01/tiny_01.vmdl` |
| `enfos_boss_brood_matron` | `models/heroes/broodmother/broodmother.vmdl` |
| `enfos_boss_bloodfang_alpha` | `models/heroes/lycan/lycan.vmdl` |
| `enfos_boss_frost_warden` | `models/heroes/ancient_apparition/ancient_apparition.vmdl` |
| `enfos_boss_mind_devourer` | `models/heroes/invoker/invoker.vmdl` |
| `enfos_boss_iron_colossus` | `models/heroes/earthshaker/earthshaker.vmdl` |
| `enfos_boss_gravecaller` | `models/heroes/undying/undying.vmdl` |
| `enfos_boss_storm_tyrant` | `models/heroes/razor/razor.vmdl` |
| `enfos_boss_shadow_huntress` | `models/heroes/phantom_assassin/phantom_assassin.vmdl` |
| `enfos_boss_plague_behemoth` | `models/heroes/venomancer/venomancer.vmdl` |
| `enfos_boss_rift_lord` | `models/heroes/enigma/enigma.vmdl` |
| `enfos_boss_ascendant_gatekeeper` | `models/heroes/faceless_void/faceless_void.vmdl` |
| `enfos_creep_spiderling` | `models/heroes/broodmother/spiderling.vmdl` |
| `enfos_creep_skeleton` | `models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl` |
| `enfos_spellbringer_war_standard` | `models/heroes/juggernaut/jugg_healing_ward.vmdl` |
| `enfos_spellbringer_thorn_idol` | `models/heroes/pugna/pugna_ward.vmdl` |
| `enfos_spellbringer_void_stalker` | `models/heroes/enigma/eidelon.vmdl` |
| `enfos_spellbringer_reinforcement` | `models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl` |

## Verification and remaining evidence

- MCP VPK lookup: 35 unique exact source paths resolved to compiled model assets.
- Content regression: all Enfos NPC definitions must carry a .vmdl path and reject an ERROR placeholder.
- npm run check: record the automated result after the rest of the change batch.
- Dota Tools was not running during this audit. Spawn a sample of every creep archetype and Boss in a fresh Tools match, capture the model and inspect VConsole for resource load failures before calling the visual issue resolved.

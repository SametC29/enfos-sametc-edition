# Hero passive Break metadata audit — 2026-09-30

Static review found 35 passive ability definitions whose linked Lua callbacks checked `PassivesDisabled()` while their KV omitted `IsBreakable 1`. Added the missing metadata for the IDs below. This aligns the ability definitions with the existing Lua Break guards; it does not certify actual Dota engine Break behavior.

| Hero | Ability |
| --- | --- |
| `npc_dota_hero_sven` | `bulwark_iron_guard` |
| `npc_dota_hero_omniknight` | `enfos_omni_degen_aura` |
| `npc_dota_hero_omniknight` | `enfos_omni_hammer_of_purity` |
| `npc_dota_hero_axe` | `enfos_axe_counter_helix` |
| `npc_dota_hero_legion_commander` | `enfos_legion_moment_of_courage` |
| `npc_dota_hero_sniper` | `enfos_sniper_headshot` |
| `npc_dota_hero_crystal_maiden` | `enfos_cm_arcane_aura` |
| `npc_dota_hero_centaur` | `enfos_centaur_return` |
| `npc_dota_hero_bristleback` | `enfos_bb_bristleback` |
| `npc_dota_hero_bristleback` | `enfos_bb_warpath` |
| `npc_dota_hero_nevermore` | `enfos_sf_necromastery` |
| `npc_dota_hero_nevermore` | `enfos_sf_presence_of_the_dark_lord` |
| `npc_dota_hero_nevermore` | `enfos_sf_feast_of_souls` |
| `npc_dota_hero_tidehunter` | `enfos_tide_kraken_shell` |
| `npc_dota_hero_tidehunter` | `enfos_tide_colossal_presence` |
| `npc_dota_hero_abyssal_underlord` | `enfos_underlord_atrophy_aura` |
| `npc_dota_hero_abyssal_underlord` | `enfos_underlord_abyssal_carapace` |
| `npc_dota_hero_troll_warlord` | `enfos_troll_fervor` |
| `npc_dota_hero_troll_warlord` | `enfos_troll_rampage` |
| `npc_dota_hero_chaos_knight` | `enfos_ck_chaos_strike` |
| `npc_dota_hero_chaos_knight` | `enfos_ck_entropy` |
| `npc_dota_hero_faceless_void` | `enfos_void_time_lock` |
| `npc_dota_hero_faceless_void` | `enfos_void_backtrack` |
| `npc_dota_hero_medusa` | `enfos_medusa_mana_shield` |
| `npc_dota_hero_medusa` | `enfos_medusa_gorgon_gaze` |
| `npc_dota_hero_terrorblade` | `enfos_tb_demon_zeal` |
| `npc_dota_hero_storm_spirit` | `enfos_storm_overload` |
| `npc_dota_hero_storm_spirit` | `enfos_storm_galvanic_core` |
| `npc_dota_hero_leshrac` | `enfos_leshrac_defilement` |
| `npc_dota_hero_invoker` | `enfos_invoker_alacrity` |
| `npc_dota_hero_puck` | `enfos_puck_faerie_magic` |
| `npc_dota_hero_lion` | `enfos_lion_demon_soul` |
| `npc_dota_hero_vengefulspirit` | `enfos_vs_vengeance_aura` |
| `npc_dota_hero_vengefulspirit` | `enfos_vs_retribution` |
| `npc_dota_hero_lich` | `enfos_lich_ice_aura` |

The structural audit now checks linked passive/modifier source and fails if a passive that checks `PassivesDisabled()` lacks `IsBreakable 1`. `npm run check` passes the content contract and mocked regressions. Runtime Break tests remain pending.

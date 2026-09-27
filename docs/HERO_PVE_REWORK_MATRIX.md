# HERO PVE REWORK MATRIX — 40 HEROES (200 ABILITIES)

Authoritative inventory and PvE redesign matrix for **Enfos Team Survival — SametC Edition**.
Complies with clean-room reference policy (clean design concepts from Enfo / Watcher of Samsara / Custom Hero Clash without direct code/asset copying).

## Summary Statistics
- **Total Heroes**: 40 (8 Tank, 8 Fighter, 8 Carry, 8 Mage, 8 Support)
- **Total Abilities**: 200 (5 per hero)
- **Active Batch 1 & 2 (Implemented & Tested)**: Sven, Axe, Centaur, Juggernaut, Legion Commander, Drow Ranger, Luna, Sniper, Lina, Crystal Maiden, Omniknight, Dazzle (12 heroes / 60 abilities)
- **Remaining Batches (Batches 3-5)**: 28 heroes (140 abilities)

| Role | Heroes Count | Core Archetype & PvE Philosophy |
|---|---|---|
| **Tank** | 8 | Frontline sustain, crowd aggregation/taunt, armor/reflect scaling, wave stalling without infinite CC loops on bosses. |
| **Fighter** | 8 | Cleave/swipes, burst survivability, on-kill resets, attack-speed scaling, close-range wave annihilation. |
| **Carry** | 8 | Multi-shot, ricochet, bounce glaives, piercing projectiles, critical splinters, hyper scaling with Agility/Items. |
| **Mage** | 8 | Screen-wide AoE waves, spell amp synergies, burst combinations, cast triggers, mana sustainability. |
| **Support** | 8 | Viable solo wave clearing (via pulsing halos/consecration/bouncing spells) + irreplaceable team auras, heals, and boss vulnerability debuffs. |

## Role: Tank (8 Heroes)

### SVEN (`npc_dota_hero_sven`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `bulwark_shield_slam` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Tank archetype. | Standard damage |
| Ability2 | `bulwark_challenge` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Tank archetype. | Standard damage |
| Ability3 | `bulwark_iron_guard` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Tank archetype. | Standard damage |
| Ability4 | `bulwark_fortress` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Tank archetype. | Standard damage |
| Ability5 | `bulwark_unbreakable` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Tank archetype. | Standard damage |

### AXE (`npc_dota_hero_axe`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_axe_berserkers_call` | Lua (Active) | `KOD + OTOMATIK TEST` | 400 AoE taunt + 30-60 armor. Creeps forced to attack Axe. | 75% duration reduction on bosses |
| Ability2 | `enfos_axe_battle_hunger` | Lua (Active) | `KOD + OTOMATIK TEST` | DoT scaling with 25% Str + 25% slow. Spreads to 2 foes on death. | Normal damage & slow |
| Ability3 | `enfos_axe_counter_helix` | Lua (Active) | `KOD + OTOMATIK TEST` | 20% spin on hit dealing 100-250 + 100% Str Pure AoE. Uncapped on creeps. | 0.2s cooldown on bosses |
| Ability4 | `enfos_axe_culling_blade` | Lua (Active) | `KOD + OTOMATIK TEST` | True execute <35% HP (creeps) / <15% (boss). Resets CD and buffs team AS/MS. | 15% execute threshold on bosses |
| Ability5 | `enfos_axe_blood_armor` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +1 Armor/Regen per 10 creeps / 1 boss (up to 50). Reflects 15% phys dmg. | Standard reflect |

### CENTAUR (`npc_dota_hero_centaur`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_centaur_hoof_stomp` | Lua (Active) | `KOD + OTOMATIK TEST` | 350 AoE stomp stun (2.0s) + 120-300 + 150% Str physical damage. | 0.8s stun duration on bosses |
| Ability2 | `enfos_centaur_double_edge` | Lua (Active) | `KOD + OTOMATIK TEST` | 250 AoE Pure burst: 150-375 + 60% Str + 15% Max HP. 30% non-lethal self damage. | Normal pure damage |
| Ability3 | `enfos_centaur_return` | Lua (Active) | `KOD + OTOMATIK TEST` | Reflects 20-65 + 50% Str physical to attackers. Pulses in 250 AoE per 300 damage. | Standard reflect |
| Ability4 | `enfos_centaur_stampede` | Lua (Active) | `KOD + OTOMATIK TEST` | Team 550 MS, phased, 40% dmg reduction. Trampled enemies take 200 + 200% Str & 100% slow. | Standard trample |
| Ability5 | `enfos_centaur_colossal_hide` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Flat 40 + 5% Str damage block + +20% Max Health. | Standard block |

### BRISTLEBACK (`npc_dota_hero_bristleback`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_bb_viscous_nasal_goo` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_bb_quill_spray` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_bb_bristleback` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_bb_warpath` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_bb_hairball` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### TIDEHUNTER (`npc_dota_hero_tidehunter`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_tide_gush` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_tide_kraken_shell` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_tide_anchor_smash` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_tide_ravage` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_tide_colossal_presence` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### DRAGON KNIGHT (`npc_dota_hero_dragon_knight`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_dk_breathe_fire` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_dk_dragon_tail` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_dk_dragon_blood` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_dk_elder_dragon_form` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_dk_wyrm_vigor` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### PUDGE (`npc_dota_hero_pudge`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_pudge_meat_hook` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_pudge_rot` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_pudge_flesh_heap` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_pudge_dismember` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_pudge_meat_shield` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### ABYSSAL UNDERLORD (`npc_dota_hero_abyssal_underlord`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_underlord_firestorm` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_underlord_pit_of_malice` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_underlord_atrophy_aura` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_underlord_dark_rift` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_underlord_abyssal_carapace` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

## Role: Fighter (8 Heroes)

### JUGGERNAUT (`npc_dota_hero_juggernaut`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_juggernaut_blade_fury` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Fighter archetype. | Standard damage |
| Ability2 | `enfos_juggernaut_healing_ward` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Fighter archetype. | Standard damage |
| Ability3 | `enfos_juggernaut_blade_dance` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Fighter archetype. | Standard damage |
| Ability4 | `enfos_juggernaut_omni_slash` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Fighter archetype. | Standard damage |
| Ability5 | `enfos_juggernaut_duelist` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Fighter archetype. | Standard damage |

### LEGION COMMANDER (`npc_dota_hero_legion_commander`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_legion_overwhelming_odds` | Lua (Active) | `KOD + OTOMATIK TEST` | 600 AoE burst: 120-300 + 25-55 per creep + 100 per boss. Grants AS/MS buff. | 100 bonus dmg per boss |
| Ability2 | `enfos_legion_press_the_attack` | Lua (Active) | `KOD + OTOMATIK TEST` | Strong dispel + 40-100 + 50% Str HP regen/s + 60-120 AS for 5s. | Normal target buff |
| Ability3 | `enfos_legion_moment_of_courage` | Lua (Active) | `KOD + OTOMATIK TEST` | 25% counter-attack with +1000 AS and 75% lifesteal. No CD on creeps. | 0.4s cooldown on bosses |
| Ability4 | `enfos_legion_duel` | Lua (Active) | `KOD + OTOMATIK TEST` | 4.0-5.5s duel. LC takes 40% less external dmg. Winner gains permanent bonus damage. | +30 bonus damage on boss kill |
| Ability5 | `enfos_legion_commanders_banner` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive Aura: 900 radius +20% phys damage & 12% lifesteal (+40% dmg & 24% steal for LC). | Standard aura |

### SKELETON KING (`npc_dota_hero_skeleton_king`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_wk_wraithfire_blast` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_wk_vampiric_aura` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_wk_mortal_strike` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_wk_reincarnation` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_wk_skeleton_army` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### SLARK (`npc_dota_hero_slark`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_slark_dark_pact` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_slark_pounce` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_slark_essence_shift` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_slark_shadow_dance` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_slark_fish_bait` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### URSA (`npc_dota_hero_ursa`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_ursa_earthshock` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_ursa_overpower` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_ursa_fury_swipes` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_ursa_enrage` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_ursa_ursa_minor` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### MONKEY KING (`npc_dota_hero_monkey_king`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_mk_boundless_strike` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_mk_primal_spring` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_mk_jingu_mastery` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_mk_wukongs_command` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_mk_mischief` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### TROLL WARLORD (`npc_dota_hero_troll_warlord`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_troll_berserkers_rage` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_troll_whirling_axes` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_troll_fervor` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_troll_battle_trance` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_troll_rampage` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### CHAOS KNIGHT (`npc_dota_hero_chaos_knight`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_ck_chaos_bolt` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_ck_reality_rift` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_ck_chaos_strike` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_ck_phantasm` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_ck_entropy` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

## Role: Carry (8 Heroes)

### DROW RANGER (`npc_dota_hero_drow_ranger`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_drow_frost_arrows` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability2 | `enfos_drow_gust` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability3 | `enfos_drow_multishot` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability4 | `enfos_drow_marksmanship` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability5 | `enfos_drow_precision_aura` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |

### SNIPER (`npc_dota_hero_sniper`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_sniper_shrapnel` | Lua (Active) | `KOD + OTOMATIK TEST` | 450 AoE shrapnel: 40-115 + 35% Agi physical DPS + 30% slow for 8s. | Standard DPS & slow |
| Ability2 | `enfos_sniper_headshot` | Lua (Active) | `KOD + OTOMATIK TEST` | 40% proc: 60-180 + 75% Agi bonus physical damage + 60 unit knockback. | Bosses immune to knockback |
| Ability3 | `enfos_sniper_take_aim` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +150-450 attack range. Active: 100% True Strike, 80% Headshot chance, +15% MS. | Standard active |
| Ability4 | `enfos_sniper_assassinate` | Lua (Active) | `KOD + OTOMATIK TEST` | 2500 range sniper: 400-900 + 300% Agi physical damage. On kill: resets CD & 50% mana. | Standard single target |
| Ability5 | `enfos_sniper_keen_eye` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Basic attacks pierce 500 line behind target for 60% attack damage. | Standard piercing |

### PHANTOM ASSASSIN (`npc_dota_hero_phantom_assassin`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_pa_stifling_dagger` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_pa_phantom_strike` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_pa_blur` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_pa_coup_de_grace` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_pa_fan_of_knives` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### LUNA (`npc_dota_hero_luna`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_luna_lucent_beam` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability2 | `enfos_luna_moon_glaives` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability3 | `enfos_luna_lunar_blessing` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability4 | `enfos_luna_eclipse` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |
| Ability5 | `enfos_luna_lunar_orbit` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Carry archetype. | Standard damage |

### ANTIMAGE (`npc_dota_hero_antimage`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_am_mana_break` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_am_blink` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_am_counterspell` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_am_mana_void` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_am_spellbreaker` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### FACELESS VOID (`npc_dota_hero_faceless_void`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_void_time_walk` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_void_time_dilation` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_void_time_lock` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_void_chronosphere` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_void_backtrack` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### MEDUSA (`npc_dota_hero_medusa`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_medusa_split_shot` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_medusa_mystic_snake` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_medusa_mana_shield` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_medusa_stone_gaze` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_medusa_gorgon_gaze` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### TERRORBLADE (`npc_dota_hero_terrorblade`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_tb_reflection` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_tb_conjure_image` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_tb_metamorphosis` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_tb_sunder` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_tb_demon_zeal` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

## Role: Mage (8 Heroes)

### LINA (`npc_dota_hero_lina`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_lina_dragon_slave` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Mage archetype. | Standard damage |
| Ability2 | `enfos_lina_light_strike_array` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Mage archetype. | Standard damage |
| Ability3 | `enfos_lina_fiery_soul` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Mage archetype. | Standard damage |
| Ability4 | `enfos_lina_laguna_blade` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Mage archetype. | Standard damage |
| Ability5 | `enfos_lina_combustion` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Mage archetype. | Standard damage |

### CRYSTAL MAIDEN (`npc_dota_hero_crystal_maiden`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_cm_crystal_nova` | Lua (Active) | `KOD + OTOMATIK TEST` | 425 AoE frost burst: 130-340 + 120% Int magic damage + 40% MS / 50 AS slow for 4.5s. | Standard damage & slow |
| Ability2 | `enfos_cm_frostbite` | Lua (Active) | `KOD + OTOMATIK TEST` | Roots & disarms 3.0s. Deals 80-260 + 50% Int/s. Deals 300% damage to creeps. | Normal 100% damage on bosses |
| Ability3 | `enfos_cm_arcane_aura` | Lua (Active) | `KOD + OTOMATIK TEST` | Global Aura: +2-5 mana regen (+6-15 for CM) + +15% Spell Amplification for allies. | Global team aura |
| Ability4 | `enfos_cm_freezing_field` | Lua (Active) | `KOD + OTOMATIK TEST` | Channeled 800 AoE blizzard: 120-240 + 60% Int explosions every 0.2s. +20 armor, +50% magic resist. | Standard channel |
| Ability5 | `enfos_cm_glacial_mastery` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Cold damage applies Frost. At 5 stacks: 1.5s Freeze + 150 + 10% Max HP AoE shatter. | 600 HP dmg cap on bosses |

### ZUUS (`npc_dota_hero_zuus`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_zeus_arc_lightning` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_zeus_lightning_bolt` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_zeus_static_field` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_zeus_thundergods_wrath` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_zeus_heavenly_jump` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### NEVERMORE (`npc_dota_hero_nevermore`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_sf_shadowraze` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_sf_necromastery` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_sf_presence_of_the_dark_lord` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_sf_requiem_of_souls` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_sf_feast_of_souls` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### STORM SPIRIT (`npc_dota_hero_storm_spirit`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_storm_static_remnant` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_storm_electric_vortex` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_storm_overload` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_storm_ball_lightning` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_storm_galvanic_core` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### LESHRAC (`npc_dota_hero_leshrac`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_leshrac_split_earth` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_leshrac_diabolic_edict` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_leshrac_lightning_storm` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_leshrac_pulse_nova` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_leshrac_defilement` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### INVOKER (`npc_dota_hero_invoker`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_invoker_chaos_meteor` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_invoker_sun_strike` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_invoker_deafening_blast` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_invoker_emp` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_invoker_alacrity` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### PUCK (`npc_dota_hero_puck`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_puck_illusory_orb` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_puck_waning_rift` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_puck_phase_shift` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_puck_dream_coil` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_puck_faerie_magic` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

## Role: Support (8 Heroes)

### OMNIKNIGHT (`npc_dota_hero_omniknight`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_omni_purification` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Support archetype. | Standard damage |
| Ability2 | `enfos_omni_repel` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Support archetype. | Standard damage |
| Ability3 | `enfos_omni_degen_aura` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Support archetype. | Standard damage |
| Ability4 | `enfos_omni_guardian_angel` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Support archetype. | Standard damage |
| Ability5 | `enfos_omni_hammer_of_purity` | Lua (Active) | `KOD + OTOMATIK TEST` | High-impact PvE kit overhaul for core Support archetype. | Standard damage |

### DAZZLE (`npc_dota_hero_dazzle`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_dazzle_poison_touch` | Lua (Active) | `KOD + OTOMATIK TEST` | Cone hits up to 8 foes: 30-90 + 35% Int phys DPS + 25% slow. Attacks refresh & add 2% slow. | Normal physical DoT |
| Ability2 | `enfos_dazzle_shallow_grave` | Lua (Active) | `KOD + OTOMATIK TEST` | Target health cannot fall below 1 HP for 4.5-6.0s + 40% heal amp. | Life-saving clutch |
| Ability3 | `enfos_dazzle_shadow_wave` | Lua (Active) | `KOD + OTOMATIK TEST` | Jumps 7 allies: heals 90-210 + 100% Int. Deals matching physical damage around EACH ally (200 AoE). | Overlapping swarm clear |
| Ability4 | `enfos_dazzle_bad_juju` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: -1.5s cooldown on all spells when casting. Active: -5 enemy armor / +5 ally armor for 8s. | Standard CDR & armor |
| Ability5 | `enfos_dazzle_nothl_weave` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive Aura: Every 3s, enemies lose 2 armor (up to -10), allies gain 2 armor (up to +10). | Stacking armor shred |

### WITCH DOCTOR (`npc_dota_hero_witch_doctor`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_wd_paralyzing_cask` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_wd_voodoo_restoration` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_wd_maledict` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_wd_death_ward` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_wd_voodoo_switcheroo` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### SHADOW SHAMAN (`npc_dota_hero_shadow_shaman`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_ss_ether_shock` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_ss_hex` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_ss_shackles` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_ss_mass_serpent_ward` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_ss_fowl_play` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### LION (`npc_dota_hero_lion`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_lion_earth_spike` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_lion_hex` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_lion_mana_drain` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_lion_finger_of_death` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_lion_demon_soul` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### JAKIRO (`npc_dota_hero_jakiro`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_jakiro_dual_breath` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_jakiro_ice_path` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_jakiro_liquid_fire` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_jakiro_macropyre` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_jakiro_double_trouble` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### VENGEFULSPIRIT (`npc_dota_hero_vengefulspirit`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_vs_magic_missile` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_vs_wave_of_terror` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_vs_vengeance_aura` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_vs_nether_swap` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_vs_retribution` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### LICH (`npc_dota_hero_lich`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_lich_frost_blast` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_lich_frost_shield` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_lich_sinister_gaze` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_lich_chain_frost` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_lich_ice_aura` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |


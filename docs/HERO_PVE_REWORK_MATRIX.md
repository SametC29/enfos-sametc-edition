# HERO PVE REWORK MATRIX — 40 HEROES (200 ABILITIES)

Authoritative inventory and PvE redesign matrix for **Enfos Team Survival — SametC Edition**.
Complies with clean-room reference policy (clean design concepts from Enfo / Watcher of Samsara / Custom Hero Clash without direct code/asset copying).

## Summary Statistics
- **Total Heroes**: 40 (8 Tank, 8 Fighter, 8 Carry, 8 Mage, 8 Support)
- **Total Abilities**: 200 (5 per hero)
- **Active Batch 1 (Core Foundations)**: Drow Ranger, Luna, Juggernaut, Lina, Sven, Omniknight (30 abilities)
- **Remaining Batches**: 34 heroes (170 abilities)

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
| Ability1 | `enfos_axe_berserkers_call` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_axe_battle_hunger` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_axe_counter_helix` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_axe_culling_blade` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_axe_blood_armor` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

### CENTAUR (`npc_dota_hero_centaur`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_centaur_hoof_stomp` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_centaur_double_edge` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_centaur_return` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_centaur_stampede` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_centaur_colossal_hide` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

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
| Ability1 | `enfos_legion_overwhelming_odds` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_legion_press_the_attack` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_legion_moment_of_courage` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_legion_duel` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_legion_commanders_banner` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

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
| Ability1 | `enfos_sniper_shrapnel` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_sniper_headshot` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_sniper_take_aim` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_sniper_assassinate` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_sniper_keen_eye` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

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
| Ability1 | `enfos_cm_crystal_nova` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_cm_frostbite` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_cm_arcane_aura` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_cm_freezing_field` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_cm_glacial_mastery` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

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
| Ability1 | `enfos_dazzle_poison_touch` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability2 | `enfos_dazzle_shallow_grave` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability3 | `enfos_dazzle_shadow_wave` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability4 | `enfos_dazzle_bad_juju` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |
| Ability5 | `enfos_dazzle_nothl_weave` | Datadriven (Mock) | `EKSİK` | Custom PvE wave clear adaptation with scaling | Standard damage |

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


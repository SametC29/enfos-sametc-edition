# HERO PVE REWORK MATRIX — 40 HEROES (200 ABILITIES)

Authoritative inventory and PvE redesign matrix for **Enfos Team Survival — SametC Edition**.
Complies with clean-room reference policy (clean design concepts from Enfo / Watcher of Samsara / Custom Hero Clash without direct code/asset copying).

## Summary Statistics
- **Total Heroes**: 40 (8 Tank, 8 Fighter, 8 Carry, 8 Mage, 8 Support)
- **Total Abilities**: 200 (5 per hero)
- **Active Batches 1, 2, 3 & 4 (Implemented & Tested)**: Sven, Axe, Centaur, Bristleback, Tidehunter, Dragon Knight, Pudge, Juggernaut, Legion Commander, Wraith King, Slark, Ursa, Monkey King, Drow Ranger, Luna, Sniper, Phantom Assassin, Anti-Mage, Faceless Void, Lina, Crystal Maiden, Zeus, Shadow Fiend, Storm Spirit, Omniknight, Dazzle, Witch Doctor, Shadow Shaman, Lion (29 heroes / 145 abilities)
- **Remaining Batch (Batch 5)**: Underlord, Troll Warlord, Chaos Knight, Medusa, Terrorblade, Leshrac, Invoker, Puck, Jakiro, Vengeful Spirit, Lich (11 heroes / 55 abilities)

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
| Ability1 | `enfos_bb_viscous_nasal_goo` | Lua (Active) | `KOD + OTOMATIK TEST` | Stacking snot: reduces 3-12 armor and slows by 15-27%, stacking up to 4 times. | Standard debuff |
| Ability2 | `enfos_bb_quill_spray` | Lua (Active) | `KOD + OTOMATIK TEST` | 700 AoE physical quills: (80 + 40% Str) + stacks * (40 + 15% Str) up to 10 stacks. Grants Warpath. | Normal physical AoE |
| Ability3 | `enfos_bb_bristleback` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: 25% damage reduction from all angles. Triggers automatic Quill Spray per 200 damage taken. | Passive damage mitigation |
| Ability4 | `enfos_bb_warpath` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Casting spells stacks +25 attack damage & +3% move speed up to 10 stacks (10s duration). | Stacking self-buff |
| Ability5 | `enfos_bb_hairball` | Lua (Active) | `KOD + OTOMATIK TEST` | Spits a 400 AoE hairball applying 2 Goo stacks and unleashing an instant Quill Spray. | Standard AoE projectile |

### TIDEHUNTER (`npc_dota_hero_tidehunter`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_tide_gush` | Lua (Active) | `KOD + OTOMATIK TEST` | 750 range water spout: 110-320 + 100% Str magic damage, -4 to -7 armor shred & 40% slow for 4.5s. | Standard debuff |
| Ability2 | `enfos_tide_kraken_shell` | Lua (Active) | `KOD + OTOMATIK TEST` | Blocks 20-80 + 5% Str damage, +5-20 HP regen. Strong purge when taking 450 damage within 6s. | Defensive purge & block |
| Ability3 | `enfos_tide_anchor_smash` | Lua (Active) | `KOD + OTOMATIK TEST` | 400 AoE 100% attack + 80-230 + 75% Str phys dmg. Reduces enemy attack damage by 40-70% for 6s. | Standard AoE physical |
| Ability4 | `enfos_tide_ravage` | Lua (Active) | `KOD + OTOMATIK TEST` | 1000 AoE tentacle shockwave: 200-450 magic damage + 2.4-3.2s stun. | Standard AoE disable |
| Ability5 | `enfos_tide_colossal_presence` | Lua (Active) | `KOD + OTOMATIK TEST` | Innate: +500 Max HP, +10 Armor, and 900 aura reducing enemy move speed by 15% and base attack damage by 15%. | Standard debuff aura |

### DRAGON KNIGHT (`npc_dota_hero_dragon_knight`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_dk_breathe_fire` | Lua (Active) | `KOD + OTOMATIK TEST` | 650 cone fire breath: 120-300 + 100% Str magic dmg + reduces enemy attack damage by 30-45% for 8s. | Standard damage & reduction |
| Ability2 | `enfos_dk_dragon_tail` | Lua (Active) | `KOD + OTOMATIK TEST` | Melee/Ranged shield bash: 100-250 + 80% Str physical dmg + 2.0-3.0s stun (longer in dragon form). | 65% stun duration reduction on bosses |
| Ability3 | `enfos_dk_dragon_blood` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +4-16 armor & +5-20 HP regen, multiplied by up to 2x when below 50% health. | Passive defensive scaling |
| Ability4 | `enfos_dk_elder_dragon_form` | Lua (Active) | `KOD + OTOMATIK TEST` | Transforms into an Elder Dragon: gains 400 attack range, Corrosive/Splash/Frost breath with Str scaling. | Full splash & slow |
| Ability5 | `enfos_dk_wyrm_vigor` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Basic attacks and abilities burn enemies for 25 + 20% Str magic damage over 3 seconds. | Continuous DoT |

### PUDGE (`npc_dota_hero_pudge`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_STRENGTH`
- **Role**: `Tank`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_pudge_meat_hook` | Lua (Active) | `KOD + OTOMATIK TEST` | 1300 range hook: pulls target dealing 150-360 + 120% Str pure damage. Does not displace bosses. | Pure damage without displacement |
| Ability2 | `enfos_pudge_rot` | Lua (Active) | `KOD + OTOMATIK TEST` | 275 AoE toxic gas: 40-120 + 35% Str magic DPS + 20-35% slow. Harms Pudge for 50% reduced amount. | Constant magic AoE |
| Ability3 | `enfos_pudge_flesh_heap` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +1.5-3.0 Str per kill (uncapped). Active: 35-70 damage block for 6s. | Uncapped PvE Str scaling |
| Ability4 | `enfos_pudge_dismember` | Lua (Active) | `KOD + OTOMATIK TEST` | Channeled dismember: 80-160 + 80% Str magic DPS + heals Pudge for 100% of damage dealt for 3s. | 60% channel duration on bosses |
| Ability5 | `enfos_pudge_meat_shield` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +15% Magic Resistance and converts 10% of damage taken into temporary health shield. | Defensive absorption |

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
| Ability1 | `enfos_wk_wraithfire_blast` | Lua (Active) | `KOD + OTOMATIK TEST` | Single-target blast: 200 + 120% Str magic damage, 1.5s stun + 80 + 30% Str/s DoT for 2s. | 0.6s stun on bosses |
| Ability2 | `enfos_wk_vampiric_aura` | Lua (Active) | `KOD + OTOMATIK TEST` | 900 radius aura: 50% physical lifesteal for WK, 25% lifesteal for friendly heroes/creeps. | Sustained team lifesteal |
| Ability3 | `enfos_wk_mortal_strike` | Lua (Active) | `KOD + OTOMATIK TEST` | 20% proc for 260% critical strike; splashes 50% of dealt crit damage in 300 AoE cleave. | Normal physical crit & cleave |
| Ability4 | `enfos_wk_reincarnation` | Lua (Active) | `KOD + OTOMATIK TEST` | Revives upon fatal damage (60s CD) releasing 900 AoE wave dealing 500 + 250% Str magic damage. | Life recovery & death burst |
| Ability5 | `enfos_wk_skeleton_army` | Lua (Active) | `KOD + OTOMATIK TEST` | Stores up to 8 souls on kill. Active releases army dealing 120 + 80% Str phys damage in 600 AoE. | Standard burst damage |

### SLARK (`npc_dota_hero_slark`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_slark_dark_pact` | Lua (Active) | `KOD + OTOMATIK TEST` | 1.5s delay purge + 10 waves dealing 120-300 + 75% Agi magic AoE (325 radius). 30% self damage. | Full cleansing & magic AoE |
| Ability2 | `enfos_slark_pounce` | Lua (Active) | `KOD + OTOMATIK TEST` | Leaps 700 units; leashes first enemy hit for 2.5-3.5s dealing 100-250 + 60% Agi damage. | Leash duration reduced 60% on bosses |
| Ability3 | `enfos_slark_essence_shift` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Basic attacks steal 1-3 Agi for 30-60s (+1 permanent Agi on hero/boss kill). | Uncapped stack scaling |
| Ability4 | `enfos_slark_shadow_dance` | Lua (Active) | `KOD + OTOMATIK TEST` | 4.0-5.0s cloud of shadows: untargetable, +30-50% MS, and massive passive regen when unseen. | Immune to detection |
| Ability5 | `enfos_slark_fish_bait` | Lua (Active) | `KOD + OTOMATIK TEST` | Casts chum on target reducing armor by 4-8 and dealing 30-60 bonus damage per attack for 6s. | Focus fire shred |

### URSA (`npc_dota_hero_ursa`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_ursa_earthshock` | Lua (Active) | `KOD + OTOMATIK TEST` | 385 AoE slam: 100-250 + 80% Agi phys dmg + 25-40% slow for 4s + grants 20% damage block. | Standard AoE & slow |
| Ability2 | `enfos_ursa_overpower` | Lua (Active) | `KOD + OTOMATIK TEST` | Maximum attack speed (+400-700) for next 4-7 attacks with 20% status resistance. | Rapid attack burst |
| Ability3 | `enfos_ursa_fury_swipes` | Lua (Active) | `KOD + OTOMATIK TEST` | Consecutive attacks deal +12-36 + 10% Agi bonus damage per stack, splashing 40% in 250 AoE cleave. | Hyper scaling single/cleave |
| Ability4 | `enfos_ursa_enrage` | Lua (Active) | `KOD + OTOMATIK TEST` | 80% damage reduction, 50% status resistance, and +50% Fury Swipes damage multiplier for 4-6s. | Boss tanking clutch |
| Ability5 | `enfos_ursa_ursa_minor` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +15% Move Speed and basic attacks grant 10% movement speed steal for 3 seconds. | Chasing sustain |

### MONKEY KING (`npc_dota_hero_monkey_king`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Fighter`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_mk_boundless_strike` | Lua (Active) | `KOD + OTOMATIK TEST` | 1100 length staff slam: 150-350% crit + 100-250 + 100% Agi phys dmg + 1.0-1.6s stun. | 65% stun duration reduction on bosses |
| Ability2 | `enfos_mk_primal_spring` | Lua (Active) | `KOD + OTOMATIK TEST` | Ground slam leap: 140-350 + 100% Agi magic damage + 40-70% slow in 400 AoE. | Standard AoE burst & slow |
| Ability3 | `enfos_mk_jingu_mastery` | Lua (Active) | `KOD + OTOMATIK TEST` | After 4 hits on enemies, next 4 attacks gain +50-140 damage and 30-60% lifesteal. | High burst lifesteal |
| Ability4 | `enfos_mk_wukongs_command` | Lua (Active) | `KOD + OTOMATIK TEST` | Circular formation (750 AoE) of monkey soldiers striking every 1.2s for MK attack damage. | Sustained circle DPS |
| Ability5 | `enfos_mk_mischief` | Lua (Active) | `KOD + OTOMATIK TEST` | Transforms into local foliage/object, gaining invulnerability frame (0.2s) and 15% evasion. | Evasion and dodge frame |

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
| Ability1 | `enfos_pa_stifling_dagger` | Lua (Active) | `KOD + OTOMATIK TEST` | Pierces up to 3 enemies in a line: 120 + 70% Atk + 50% Agi phys dmg + 50% slow for 4s. | Standard piercing projectile |
| Ability2 | `enfos_pa_phantom_strike` | Lua (Active) | `KOD + OTOMATIK TEST` | Teleports to target gaining +150 attack speed and 15% lifesteal for 3 seconds. | Standard gap close |
| Ability3 | `enfos_pa_blur` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: 40% evasion. Active: Grants 15s true invisibility to drop creep aggro. | Normal aggro drop |
| Ability4 | `enfos_pa_coup_de_grace` | Lua (Active) | `KOD + OTOMATIK TEST` | 15% chance (guaranteed on breaking Blur) for 425% crit, splashing 50% crit damage in 250 AoE. | Normal critical splash |
| Ability5 | `enfos_pa_fan_of_knives` | Lua (Active) | `KOD + OTOMATIK TEST` | 550 AoE pure knives dealing 150 + 12% Max HP pure damage. | 600 damage cap on bosses |

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
| Ability1 | `enfos_am_mana_break` | Lua (Active) | `KOD + OTOMATIK TEST` | Burns 28-64 mana, dealing 80% burned mana as physical dmg + 25-50% Agi scaling, cleaving 40% in 250 AoE. | Full scaling & cleave |
| Ability2 | `enfos_am_blink` | Lua (Active) | `KOD + OTOMATIK TEST` | 900-1200 range teleport; disjoints projectiles and grants +25-40 AS for 3s upon arrival. | Mobility & attack speed |
| Ability3 | `enfos_am_counterspell` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +15-45% magic resistance. Active: 1.2s magic shield reflecting targeted spells. | Defensive mitigation |
| Ability4 | `enfos_am_mana_void` | Lua (Active) | `KOD + OTOMATIK TEST` | Target blast: 0.6-1.1 dmg per missing mana (min 300-600) + 100% Agi in 500 AoE + 0.3s mini-stun. | 600 damage floor on bosses |
| Ability5 | `enfos_am_spellbreaker` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Whenever AM burns mana or hits a spellcaster, gains +15% spell resistance and +10% MS for 4s. | Anti-caster stacking |

### FACELESS VOID (`npc_dota_hero_faceless_void`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_AGILITY`
- **Role**: `Carry`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_void_time_walk` | Lua (Active) | `KOD + OTOMATIK TEST` | Rushes 650-800 distance, backtracks all damage taken in the last 2.0s, and gains 2.0s phase. | Time reversal sustain |
| Ability2 | `enfos_void_time_dilation` | Lua (Active) | `KOD + OTOMATIK TEST` | Traps enemies in 775 AoE: slows MS/AS by 10% per cooldown + deals 20-50 + 20% Agi DPS for 8-11s. | AoE slow & time dilation |
| Ability3 | `enfos_void_time_lock` | Lua (Active) | `KOD + OTOMATIK TEST` | 24% chance on attack to freeze target in time, dealing 40-100 + 40% Agi bonus magic damage and striking twice. | 60% bash duration on bosses |
| Ability4 | `enfos_void_chronosphere` | Lua (Active) | `KOD + OTOMATIK TEST` | 500 AoE dome freezing all enemies and creeps for 4.0-5.0s. Void moves at 1000 MS inside. | Bosses slowed 80% instead of frozen |
| Ability5 | `enfos_void_backtrack` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: 20% chance to completely backtrack (negate) any physical or magical damage instance. | Full mitigation chance |

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
| Ability1 | `enfos_zeus_arc_lightning` | Lua (Active) | `KOD + OTOMATIK TEST` | Bounces up to 12 enemies dealing 150 + 60% Int magic damage per jump. | Standard bouncing magic |
| Ability2 | `enfos_zeus_lightning_bolt` | Lua (Active) | `KOD + OTOMATIK TEST` | Calls down bolt on single target for 300 + 150% Int magic damage. | Standard burst damage |
| Ability3 | `enfos_zeus_static_field` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Any spell cast shocks all enemies within 800 for 8% current HP magic damage. | 500 damage cap on bosses |
| Ability4 | `enfos_zeus_thundergods_wrath` | Lua (Active) | `KOD + OTOMATIK TEST` | Global ultimate striking all hostile units on the map for 450 + 200% Int magic damage. | Full map clear |
| Ability5 | `enfos_zeus_heavenly_jump` | Lua (Active) | `KOD + OTOMATIK TEST` | Hops forward, gaining +25% MS and hitting up to 3 closest enemies for 150 + 80% Int & 80% slow. | Standard mobility & kite |

### NEVERMORE (`npc_dota_hero_nevermore`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_sf_shadowraze` | Lua (Active) | `KOD + OTOMATIK TEST` | 275 AoE blast at 450 range: 100-280 + 75% Int magic dmg + stacks +50-100 bonus damage per hit (8s). | Stacking raze combo |
| Ability2 | `enfos_sf_necromastery` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Captures souls on kill (up to 20-50). Each soul grants +2-5 damage and +1% Spell Amp. | Soul counter scaling |
| Ability3 | `enfos_sf_presence_of_the_dark_lord` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive Aura: 1000 radius armor reduction (-4 to -10) + +10% magic vulnerability on enemies. | Dual armor/magic shred |
| Ability4 | `enfos_sf_requiem_of_souls` | Lua (Active) | `KOD + OTOMATIK TEST` | Channeled soul explosion releasing 1 wave per 2 souls: 160-240 + 50% Int per wave + 2.0s fear. | Fear duration reduced 65% on bosses |
| Ability5 | `enfos_sf_feast_of_souls` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Killing an enemy heals SF for 30 + 30% Int and restores 15 mana. | Wave sustain & mana |

### STORM SPIRIT (`npc_dota_hero_storm_spirit`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Mage`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_storm_static_remnant` | Lua (Active) | `KOD + OTOMATIK TEST` | Creates an explosive remnant in place detonating for 120-300 + 100% Int magic damage in 260 AoE. | Rapid trigger AoE |
| Ability2 | `enfos_storm_electric_vortex` | Lua (Active) | `KOD + OTOMATIK TEST` | Pulls target toward Storm for 1.4-2.2s and deals 50-150 + 40% Int magic damage. | 60% pull duration reduction on bosses |
| Ability3 | `enfos_storm_overload` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Spell cast charges attack: next hit deals 40-120 + 50% Int AoE magic damage + 50% slow. | Constant weaving burst |
| Ability4 | `enfos_storm_ball_lightning` | Lua (Active) | `KOD + OTOMATIK TEST` | Invulnerable zip through enemies dealing 8-16 + 8% Int per 100 units traveled in 200 AoE. | High mobility wave clear |
| Ability5 | `enfos_storm_galvanic_core` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: +25% Max Mana and restores 1.5% Max Mana whenever an ability damages an enemy. | Self-sustaining mana engine |

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
| Ability1 | `enfos_wd_paralyzing_cask` | Lua (Active) | `KOD + OTOMATIK TEST` | Bounces 10 times: 100 + 40% Int magic dmg + 1.0s stun per bounce. | 0.3s stun on bosses |
| Ability2 | `enfos_wd_voodoo_restoration` | Lua (Active) | `KOD + OTOMATIK TEST` | Toggle aura (500 AoE): heals allies for 50 + 30% Int/s and damages enemies for same amount. | Dual heal / damage aura |
| Ability3 | `enfos_wd_maledict` | Lua (Active) | `KOD + OTOMATIK TEST` | 200 AoE curse: 50 base dps + burst every 4s dealing 25% of health lost since cast. | Boss burst scaling |
| Ability4 | `enfos_wd_death_ward` | Lua (Active) | `KOD + OTOMATIK TEST` | Channeled ward attacking nearest enemy every 0.22s for 150 + 75% Int physical damage. | Sustained physical DPS |
| Ability5 | `enfos_wd_voodoo_switcheroo` | Lua (Active) | `KOD + OTOMATIK TEST` | Becomes invulnerable for 3s while firing ward strikes every 0.25s for 120 + 80% Int physical damage. | Clutch defense & burst |

### SHADOW SHAMAN (`npc_dota_hero_shadow_shaman`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_ss_ether_shock` | Lua (Active) | `KOD + OTOMATIK TEST` | Hits up to 8 enemies for 140-350 + 90% Int magic damage. | Multi-target wave burst |
| Ability2 | `enfos_ss_hex` | Lua (Active) | `KOD + OTOMATIK TEST` | Morphs target into chicken for 2.5-4.0s, reducing magic resistance by 15-30% and move speed to 140. | 65% duration reduction on bosses |
| Ability3 | `enfos_ss_shackles` | Lua (Active) | `KOD + OTOMATIK TEST` | Channeled bind: roots/disarms for up to 3.0-5.0s, dealing 60-150 + 50% Int/s magic damage. | 65% duration reduction on bosses |
| Ability4 | `enfos_ss_mass_serpent_ward` | Lua (Active) | `KOD + OTOMATIK TEST` | Summons 6 serpent wards attacking for 50-110 + 40% Int piercing damage for 30s. | Sustained ward DPS |
| Ability5 | `enfos_ss_fowl_play` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Fatal damage turns SS into chicken for 4s with 1 HP surviving (60s CD) + drops 2 Serpent Wards. | Clutch survival & ward trigger |

### LION (`npc_dota_hero_lion`)
- **Primary Attribute**: `DOTA_ATTRIBUTE_INTELLECT`
- **Role**: `Support`

| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |
|---|---|---|---|---|---|
| Ability1 | `enfos_lion_earth_spike` | Lua (Active) | `KOD + OTOMATIK TEST` | 825 line of earth spikes: 110-290 + 90% Int magic damage + 1.4-2.2s stun. | 60% stun duration reduction on bosses |
| Ability2 | `enfos_lion_hex` | Lua (Active) | `KOD + OTOMATIK TEST` | Transforms enemy into frog for 2.5-4.0s, reducing armor by 4-8. | 65% duration reduction on bosses |
| Ability3 | `enfos_lion_mana_drain` | Lua (Active) | `KOD + OTOMATIK TEST` | Channeled beam draining 40-120 + 50% Int mana/s (or dealing matching magic damage to creeps). | Steady mana sustain |
| Ability4 | `enfos_lion_finger_of_death` | Lua (Active) | `KOD + OTOMATIK TEST` | 600-1000 + 200% Int magic blast splashing in 325 AoE. Permanently gains +40 dmg per kill. | Uncapped kill stacks & AoE splash |
| Ability5 | `enfos_lion_demon_soul` | Lua (Active) | `KOD + OTOMATIK TEST` | Passive: Every 5 spell casts grants an instant free Finger of Death charge (deals 50% damage). | Passive nuke proc |

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


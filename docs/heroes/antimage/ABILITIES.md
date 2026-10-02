# Anti-Mage: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_antimage`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_am_mana_break` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | antimage_mana_break |
| 2 | `enfos_am_blink` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | antimage_blink |
| 3 | `enfos_am_counterspell` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | antimage_counterspell |
| 4 | `enfos_am_mana_void` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | antimage_mana_void |
| 5 | `enfos_am_spellbreaker` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | antimage_mana_overload |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_antimage.txt`; status: FILE_VERIFIED; SHA256: `b70ba50c837db7379329dc1c515847dfa25a256b6252a115f39d2d7530579b11`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/antimage/antimage.vmdl` |
| SoundSet | `Hero_Antimage` |
| Ability1 | `antimage_mana_break` |
| Ability2 | `antimage_blink` |
| Ability3 | `antimage_counterspell` |
| Ability4 | `generic_hidden` |
| Ability5 | `antimage_persectur` |
| Ability6 | `antimage_mana_void` |
| Ability10 | `special_bonus_hp_regen_3` |
| Ability11 | `special_bonus_unique_antimage_manavoid_aoe` |
| Ability12 | `special_bonus_unique_antimage_5` |
| Ability13 | `special_bonus_unique_antimage_6` |
| Ability14 | `special_bonus_unique_antimage_3` |
| Ability15 | `special_bonus_unique_antimage_8` |
| Ability16 | `special_bonus_unique_antimage` |
| Ability17 | `special_bonus_unique_antimage_2` |
| AttributeStrengthGain | `1.600000` |
| AttributeAgilityGain | `2.8` |
| AttributeIntelligenceGain | `1.800000` |

### Per-ability review leads

- `enfos_am_mana_break`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_am_blink`: world position, travel/impact timing and radius alignment.
- `enfos_am_counterspell`: cast/impact/modifier contract and lifetime.
- `enfos_am_mana_void`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_am_spellbreaker`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-02 source review: installed native AbilityDefinitions specify Blink `ACT_DOTA_CAST_ABILITY_2`, Counterspell `ACT_DOTA_CAST_ABILITY_3`, and Mana Void `ACT_DOTA_CAST_ABILITY_4`; these custom KV animation fields were absent and are now explicit. Native hero data points to `soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts`; the bank was missing from startup precache even though the kit emits Anti-Mage events, so it is now included. Mana Break remains passive and has no added cast animation. Static checks cover the native presentation and bank list; Dota gestures/cold-client sound remain PENDING owner test.

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 static special-value repair: migrated all five Anti-Mage abilities to named `AbilityValues`, preserving the defined 10-rank arrays/scalars and adding a content contract. Native ability identity and the hero's separate Enfos passive remain as documented. The change follows Sven's verified Lua special-value failure; Counterspell, Blink, Mana Void and proc behavior/audio/visuals remain for the user's in-game verification.

2026-09-30 targeting correction: Mana Void's KV declares `SPELL_IMMUNITY_ENEMIES_YES`, but its scripted radius query used the default target flags, which omit spell-immune enemies. The AoE query now passes `DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`, and its regression asserts the flag. Damage/control interactions against actual spell-immune units remain pending in-engine verification.

2026-09-30 Mana Break cleave correction: the passive's secondary-target query
used default radius flags, excluding spell-immune enemies despite dealing
physical attack-derived damage and documenting no immunity exception. The
query now includes `DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`; its mock
regression asserts that flag. Actual in-engine attack and immunity behavior
remains PENDING for owner testing.

Rank record correction (2026-09-30): replaced malformed copied rank descriptions
with each Anti-Mage slot's actual level gates: Q/W/E levels 1–10, R levels 5–50
in five-level steps, and the separate Enfos passive grant at rank 1 followed by
levels 2–10. Counterspell's duplicated placeholder resource rows were removed.
The Aghanim review confirms the generic Carry Shard grants +15% movement speed
and 12% attack damage as Pure damage through `heroes/aghanim_manager.lua`; live
application and death/reconnect behavior remain PENDING.

## Slot 1: `enfos_am_mana_break`

Classification: PVE-CONVERT
Native counterpart: `antimage_mana_break` (native Ability1, installed ClientVersion 6941 snapshot).
Decision and PvE identity rationale: mana burn loses most value against PvE creeps; preserve the anti-mana strike identity through Agility-scaled physical damage and bounded cleave.
Expected cast/travel/impact/ongoing/cleanup behavior: real enemy attack adds physical bonus damage and cleave with the native enemy debuff particle; no thinker or persistent modifier.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy hits only; Break and illusions disable; damage is reduced by physical armor; boss receives ordinary attack damage.
Current versus target rank curve; free rank / point cost: Mana Break slot 1 ranks 1–10 are gated at hero levels 1–10, one rank per level; engine point/HUD behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: existing shard flag retained; the shard effect was not changed or runtime certified.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed snapshot SHA256 `b70ba50c837db7379329dc1c515847dfa25a256b6252a115f39d2d7530579b11`.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: `antimage_manabreak_enemy_debuff.vpcf` follows target origin; path exists in installed VPK and is precached. Runtime display pending.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock hit/cleave, Break, illusion and ally checks pass; particle path verified in installed VPK. Dota/VConsole, SFX and visual acceptance remain PENDING.

## Slot 2: `enfos_am_blink`

Classification: TUNE
Native counterpart: `antimage_blink` (native Ability2).
Decision and PvE identity rationale: preserve instant repositioning; tune only range and cooldown by rank.
Expected cast/travel/impact/ongoing/cleanup behavior: cast/out sound and native start/end world particles around `FindClearSpaceForUnit`; no ongoing effect.
Normal creep / elite / boss, immunity / dispel / resistance rules: self-target point cast with no enemy interaction.
Current versus target rank curve; free rank / point cost: Blink slot 2 ranks 1–10 are gated at hero levels 1–10, one rank per level; engine point/HUD behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: no new hook; current upgrade behavior needs engine audit.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed ClientVersion 6941 snapshot SHA256 above.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: `antimage_blink_start.vpcf` and `_end.vpcf` exist in installed VPK and are precached; CP0 receives source/destination world positions. Runtime scene pending.
- Sound events + declaring banks + emission target + loop termination: existing `Hero_Antimage.Blink_out` / `.Blink_in`; runtime playback pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock rank-range/relocation check and VPK lookup pass. Dota/VConsole cast range, animation, sound and visuals remain PENDING.

## Slot 3: `enfos_am_counterspell`

Classification: PVE-CONVERT
Native counterpart: `antimage_counterspell` (native Ability3).
Decision and PvE identity rationale: retain passive magical defense and add a short active protection window for PvE encounters where enemy spell behavior differs from player spell reflection.
Expected cast/travel/impact/ongoing/cleanup behavior: intrinsic rank-scaled resistance; active cast sound/particle and timed self-buff whose attached particle ends with the modifier.
Normal creep / elite / boss, immunity / dispel / resistance rules: self-only; Break suppresses passive resistance; active buff remains independently applied.
Current versus target rank curve; free rank / point cost: Counterspell slot 3 ranks 1–10 are gated at hero levels 1–10, one rank per level. Passive resistance, active resistance and active duration are rank-scaled; engine point/HUD behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: shard flag retained; actual shard behavior not changed or engine-certified.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed ClientVersion 6941 snapshot SHA256 above.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: `antimage_spellshield.vpcf` exists in installed VPK and is precached/attached during buff; live visibility pending.
- Sound events + declaring banks + emission target + loop termination: existing `Hero_Antimage.Counterspell.Cast`; live playback pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock verifies passive/active rank values, duration and Break behavior. Dota/VConsole defense, dispel, sound and visuals remain PENDING.

## Slot 4: `enfos_am_mana_void`

Classification: PVE-CONVERT
Native counterpart: `antimage_mana_void` (native Ability6).
Decision and PvE identity rationale: restore native missing-mana burst, adapt it to area PvE impact, and cap boss burst so large boss mana pools cannot produce runaway damage.
Expected cast/travel/impact/ongoing/cleanup behavior: blockable enemy target; compute base + missing-mana coefficient + Agility scaling; play target impact and apply magical AoE, normal-creep stun and per-boss health cap.
Normal creep / elite / boss, immunity / dispel / resistance rules: spell block honored; status-resistance-scaled stun excludes bosses; boss damage is capped by max-health percentage. Spell-immunity behavior still needs engine verification.
Current versus target rank curve; free rank / point cost: Mana Void slot 4 ranks 1–10 are gated at hero levels 5, 10, …, 50, one rank every five levels; engine ultimate HUD/point behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: Scepter flag retained; actual upgrade hook remains to be tested.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed ClientVersion 6941 snapshot SHA256 above.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: `antimage_manavoid.vpcf` on the target; path verified in VPK and added to precache. Runtime impact pending.
- Sound events + declaring banks + emission target + loop termination: existing `Hero_Antimage.ManaVoid`; playback pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | KV permits enemy spell-immune targets; Lua radius query now explicitly includes them and a regression checks the query flag. Actual Dota immunity, damage and control behavior remains PENDING. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock verifies missing mana, magical damage type, stun and boss cap. Dota/VConsole, spell-immunity interaction and upgrade acceptance remain PENDING.

## Slot 5: `enfos_am_spellbreaker`

Classification: TUNE
Native counterpart: none; native Ability5 is `antimage_persectur`; this Enfos fifth-slot passive is separate and is not marked Dota Innate.
Decision and PvE identity rationale: rank-scaled attack/movement speed supports Anti-Mage’s Carry role.
Expected cast/travel/impact/ongoing/cleanup behavior: intrinsic modifier supplies attack and movement speed; no cast, particle or timer.
Normal creep / elite / boss, immunity / dispel / resistance rules: self-only; Break disables both bonuses.
Current versus target rank curve; free rank / point cost: Enfos passive rank 1 is granted separately; Spellbreaker ranks 2–10 are gated at hero levels 2–10. Engine passive grant, points and HUD behavior remain PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: shard flag retained; effect needs separate runtime review.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed snapshot shows native Ability5 `antimage_persectur`, ClientVersion 6941; SHA256 above.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock verifies rank stats and Break. No cast/VFX/SFX is expected for passive; Dota point-grant, reconnect and shard acceptance remain PENDING.

2026-09-30 follow-up audit: Mana Break, Counterspell and Spellbreaker declare
KV `IsBreakable 1`, matching their passive `PassivesDisabled` behavior.
Counterspell's passive resistance and Spellbreaker's attack/movement bonuses
also suppress on illusions; Mana Break already rejected illusion attacks. New
content and mock checks cover the metadata and stat suppression. Active
Counterspell remains an active buff after Break by design; runtime verification
of passive behavior remains pending.

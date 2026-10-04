# Slark: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_slark`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_slark_dark_pact` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IMMEDIATE | NOT_EXPLICIT | slark_dark_pact |
| 2 | `enfos_slark_pounce` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES | NOT_EXPLICIT | slark_pounce |
| 3 | `enfos_slark_essence_shift` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/slark/essence_shift | slark_essence_shift |
| 4 | `enfos_slark_shadow_dance` | 10 | DOTA_ABILITY_BEHAVIOR_IMMEDIATE \| DOTA_ABILITY_BEHAVIOR_NO_TARGET | NOT_EXPLICIT | slark_shadow_dance |
| 5 | `enfos_slark_fish_bait` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/slark/d | slark_fish_bait |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/slark/essence_shift](../../../game/scripts/vscripts/abilities/heroes/slark/essence_shift.lua), [abilities/heroes/slark/d](../../../game/scripts/vscripts/abilities/heroes/slark/d.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_slark.txt`; status: FILE_VERIFIED; SHA256: `c3bf34ff95deb386eaa918b14920ecd76b5a2a6060d7c07868ac39b8047cc752`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/slark/slark.vmdl` |
| SoundSet | `Hero_Slark` |
| Ability1 | `slark_dark_pact` |
| Ability2 | `slark_pounce` |
| Ability3 | `slark_saltwater_shiv` |
| Ability4 | `slark_depth_shroud` |
| Ability5 | `slark_essence_shift` |
| Ability6 | `slark_shadow_dance` |
| Ability10 | `special_bonus_unique_slark_6` |
| Ability11 | `special_bonus_unique_slark` |
| Ability12 | `special_bonus_unique_slark_2` |
| Ability13 | `special_bonus_unique_slark_8` |
| Ability14 | `special_bonus_unique_slark_4` |
| Ability15 | `special_bonus_unique_slark_7` |
| Ability16 | `special_bonus_unique_slark_3` |
| Ability17 | `special_bonus_unique_slark_5` |
| AttributeStrengthGain | `2.100000` |
| AttributeAgilityGain | `1.500000` |
| AttributeIntelligenceGain | `1.900000` |

### Per-ability review leads

- `enfos_slark_dark_pact`: cast/impact/modifier contract and lifetime.
- `enfos_slark_pounce`: cast/impact/modifier contract and lifetime.
- `enfos_slark_essence_shift`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_slark_shadow_dance`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_slark_fish_bait`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-04 native-first reopening: use the [current slot matrix/source
review](../../audit/SLARK_NATIVE_FIRST_REVIEW_2026-10-04.md) and [installed
build6943 ability/localization snapshot](../../audit/SLARK_NATIVE_SOURCE_2026-10-04.json).
Historical custom implementations and mocks below do not certify native behavior.
Q is classified TUNE and now delegates to native slark_dark_pact, with one
AGI special-value modifier rather than a custom pulse/dispelling loop. It preserves
authored ten-rank totals/radius/cost/CD, restores the native1.5-second delay and
30% blood cost, and tunes native pulses to the existing0.15-second interval.
The shared spawn service restores only the scaler; no points or native providers
are added. Both client/server register the class separately from server services.
EN/TR/RU/zh-CN descriptions include delay, blood cost and configured total.
Three native/source/scaling tests pass; actual C++ ten-rank reads, damage, purge,
VFX/SFX and lifecycle remain PENDING OWNER TEST. Q/W/E/R/D source work is implemented; all engine acceptance remains pending owner testing.

R source implementation2026-10-04: Shadow Dance now delegates to native
slark_shadow_dance through its stable ten-rank alias. The custom invisibility,
percentage-heal modifier and manual particle lifecycle are removed. Native owns
visibility-dependent passive bonuses, neutral-hit suppression and active cloud
concealment. Movement speed/duration/cost/CD retain authored curves; flat regen
uses native60–120 endpoints over ten ranks, replacing the prior8–18% healing.
Four-language tooltips describe this explicit balance change. Generic Scepter
CD reduction remains provisional until the coherent W/upgrade source unit.
Five focused Slark contracts and the full source checks pass (zero failed).
Native ten-rank reads, actual healing under the existing full-map vision policy,
concealment/detection, audio/visuals, upgrades and lifecycle remain PENDING OWNER TEST.

2026-09-30 implementation record: all five Enfos abilities now have ten KV ranks; Fish Bait is separated from Dota `Innate`. Installed source mapping: Dark Pact=`slark_dark_pact` (Ability1), Pounce=`slark_pounce` (Ability2), Essence Shift=`slark_essence_shift` (Ability5), Shadow Dance=`slark_shadow_dance` (Ability6), Fish Bait adapts `slark_saltwater_shiv` (Ability3). Dark Pact now uses KV pulse count/timing/radius and a verified Dota particle; Pounce now moves over timed 0.03-second steps instead of teleporting, uses start/trail/landing/leash effects and a true `MODIFIER_STATE_TETHERED` debuff; Essence Shift reads stack/agi/duration values and honors Break; Shadow Dance owns and cleans its persistent VFX; Fish Bait now reads its proc/cleave/armor values and applies capped armor stacks. Mock coverage passes for Q/W/Essence/Fish Bait. Eight used Slark particles are present in installed ClientVersion 6941 VPK. Live dash collision, particle CP/size, audio and PvE/boss balance remain PENDING.

2026-09-30 static special-value repair: migrated all five abilities' Lua-read values from legacy numbered `AbilitySpecial` rows to named `AbilityValues`, preserving each ten-rank curve and scalar. This follows the project-specific ClientVersion 6941 Sven finding: legacy values returned zero in live Lua callbacks and the named layout returned configured values after migration. Added a roster contract preventing the Slark values from reverting to the legacy layout. `node tools/checks.mjs` validates KV, ten-rank values, mocks and localization; this is not a Slark engine playtest. User-owned gameplay/audio/VFX checks remain pending.

2026-09-30 follow-up audit: Essence Shift's existing Agility stacks now stop
granting stats under Break, and neither Essence Shift nor Fish Bait can proc
from illusions. Both passive KV abilities now declare `IsBreakable 1`. Fish
Bait's physical cleave includes magic-immune units, and EN/TR/RU/zh-CN
descriptions now accurately describe the self-only Agility gain and Fish Bait
proc chance/cleave/armor stack values. Mock regressions cover Break, illusion
suppression and the target flag. In-engine behavior remains pending.

## Slot 1: `enfos_slark_dark_pact`

Classification: TUNE
Native counterpart: `slark_dark_pact` (installed Ability1).
Decision: native Dark Pact owns delay/pulses/self-damage/purge/targets/effects. Only total_damage receives authored rank damage plus live AGI via the shared query bridge.
Expected: native1.5s delay,10 pulses at0.15s within350,30% blood cost, strong dispel and native cleanup. Actual engine behavior remains pending.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Dark Pact Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Current installed build6943/rev11069754 and source hashes in SLARK_NATIVE_SOURCE_2026-10-04.json; see exact slot matrix and source review.
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
| Gameplay | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Targeting | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Ranks | PENDING | Q gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| SFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Animation | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Modifiers | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Precache | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Cleanup | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Boss | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Upgrades | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Localization | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Performance | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Reconnect | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| VConsole | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |

2026-10-04 source/native metadata and focused regressions recorded in SLARK_NATIVE_FIRST_REVIEW_2026-10-04.md. Runtime/VFX/SFX/cleanup/rank HUD and clean VConsole remain PENDING OWNER TEST.

## Slot 2: `enfos_slark_pounce`

Classification: TUNE
2026-10-04 full-kit native-first review supersedes provisional creep conversion.
Native counterpart: `slark_pounce` (installed Ability2).
Decision and PvE identity rationale: preserve native mobility to position Dark Pact and engage/disengage around waves. Native first-hero contact controls heroes; Q/E already provide wave offense. Remove the custom endpoint blast/slow/boss exception rather than invent a new root or an unverified built-in modifier constructor.
Expected behavior: native directional leap (face direction), first-hero latch, leash and learned Essence Shift stacks. Engine owns motion/landing/tree handling/targets/feedback/cleanup. Creeps are passed over; no direct damage. This intentionally removes the former100–550+0.8AGI physical endpoint blast.
Targets: native hero-only latch; ordinary creep/boss movement remains possible. No Elite units or boss-specific leash compensation. Root disables cast start; native non-dispellability/immune metadata retained. Actual native target/resistance rules remain owner engine gates.
Current versus target rank curve: Pounce W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Scepter: native2 charges, restore12s, distance900; replaces generic R amp/CD. Shard role extension remains until D source unit. Scepter/Blessing/HUD/Refresher behavior remains PENDING OWNER TEST.

### Resource and implementation evidence

- Native source: SLARK_NATIVE_SOURCE_2026-10-04.json build6943/rev11069754 hero SHA c3bf34ff95deb386eaa918b14920ecd76b5a2a6060d7c07868ac39b8047cc752. Exact native keys retained; scalar native speed/radius/distance/acceleration/leash radius and zero damage.
- Engine owns native W particles and CPs. Removed manual start/trail/splash/leash particle creation and custom motion modifier. Existing Slark precache retained; actual display/cleanup remains pending.
- Verified native Hero_Slark.Pounce.Cast and existing verified Slark soundbank; native engine emits/cleans sound. Actual audible cold-start remains pending.
- Model/animation/gesture/icon evidence: PENDING.
- Removed custom dash/leash classes and links. Native owns casting/motion/leash/cleanup; exact native Essence Shift provider from E integration supports linked lookup, with engine behavior pending.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- EN/TR/RU/zh-CN descriptions disclose directional hero-only contact, zero damage and root restriction; native Scepter text uses2/12/900.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Targeting | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Ranks | PENDING | W gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| SFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Animation | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Modifiers | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Precache | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Cleanup | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Boss | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Upgrades | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Localization | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Performance | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Reconnect | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| VConsole | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |

Source checks recorded in SLARK_NATIVE_FIRST_REVIEW_2026-10-04.md; native metadata, ten-rank arrays, no custom motion, native Scepter keys and suppression of generic bonuses are covered. C++ rank acceptance, actual movement/contact/charges/points, effects/audio, upgrades/lifecycle and VConsole remain PENDING OWNER TEST.

## Slot 3: `enfos_slark_essence_shift`

Classification: PVE-CONVERT
Native counterpart: `slark_essence_shift` (installed Ability5).
Decision and PvE identity rationale2026-10-04: native rank1 hidden provider owns hero stat stealing, native temporary-stack expiry and match-local permanent hero-death AGI. Paid ten-rank E bridges authored gain/duration. A capped creep-only extension preserves wave utility without double hero gains. Break stops new temporary gains and preserves existing bonuses (installed native Note4); the former benefit-suppression mock is superseded.
Expected behavior: passive landed attacks; native owns hero effects/lifetimes. Creeps grant capped self-only temporary AGI with shared30-second refresh and no per-target modifier/timer. Killing attacks count. Extension buff is nonpurgable and expires/dies through modifier lifecycle; listener is intrinsic/nonpurgable. No extra direct damage or permanent creep stats.
Target rules: enemy IsCreep or IsCreature, and not IsHero, including creep bosses under the same rule; no boss-only duration adjustment. No Elite units. Heroes/hero illusions use native engine rules. Actual wave/boss IsCreep classification and magic-immune/native interactions remain PENDING OWNER TEST.
Current versus target rank curve: Essence Shift E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native source: current build6943/rev11069754 and SHA in SLARK_NATIVE_SOURCE_2026-10-04.json; four queried specials verified. Indexed GetIntrinsicModifierName server-only; client bridge uses ability/rank getters only.
- Native hero particles owned by C++. Preserve existing creep hit glow via shared effect helper with ABSORIGIN_FOLLOW and released handle; VPK particles/units/heroes/hero_slark/slark_essence_shift_hit_glow.vpcf_c SHA f20ecca6f983e67c232168161ee56b66b74bd69365005664f3815f1e70e2ee98. CPs, one-shot completion and visual behavior remain PENDING OWNER TEST.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Client/server links for scaler/listener/buff in slark/modifier_links.lua; paid class under essence_shift.lua. Native intrinsic refresh resolves engine-provided name, no guessed constructors. Focused tests cover cap/Break/illusions/invalid sources/untrained ranks/client guards/idempotent restore.
- Existing addon precache includes glow and Slark bank. Cold-start remains PENDING OWNER TEST.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- EN/TR/RU/zh-CN E descriptions and generated mirrors updated with native hero/creep split, match-only AGI and Break behavior.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Targeting | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Ranks | PENDING | E gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| SFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Animation | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Modifiers | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Precache | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Cleanup | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Boss | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Upgrades | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Localization | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Performance | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Reconnect | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| VConsole | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |

Source validation2026-10-04: seven focused Slark tests and shared client bootstrap pass; all native gameplay/VFX/SFX/lifecycle acceptance remains pending. Full-source check result recorded in the review; no engine acceptance from mocks.

## Slot 4: `enfos_slark_shadow_dance`

Classification: TUNE
Native counterpart: `slark_shadow_dance` (installed Ability6).
Decision: native Shadow Dance owns visibility-dependent passive movement/flat regen and active cloud concealment. Custom invisibility/percentage-heal/particle replica removed. Flat60–120 health/sec replaces authored8–18% healing; see provisional balance record.
Expected: native passive unseen/neutral-hit conditions, active cloud concealment and native effects/lifecycle. Actual healing under full-map vision, ten-rank reads and detection remain pending.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Shadow Dance R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
Scepter now belongs to native Pounce W2/12/900; generic R amp/CD is removed. Fighter Shard remains explicit Enfos extension; engine upgrades/Blessing remain pending.

### Resource and implementation evidence

- Current installed build6943/rev11069754 and source hashes in SLARK_NATIVE_SOURCE_2026-10-04.json; see exact slot matrix and source review.
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
| Gameplay | PENDING | Mock verifies the ranked duration, invisibility/truesight states, movement speed and regeneration; engine invisibility and regen behavior remain unverified. |
| Targeting | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Ranks | PENDING | R gates levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
| VFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| SFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Animation | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Modifiers | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Precache | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Cleanup | PENDING | Mock verifies modifier destruction destroys/releases the persistent particle; repeated live casts and engine cleanup remain unverified. |
| Boss | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Upgrades | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Localization | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Performance | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Reconnect | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| VConsole | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |

2026-10-04 source/native metadata and focused regressions recorded in SLARK_NATIVE_FIRST_REVIEW_2026-10-04.md. Runtime/VFX/SFX/cleanup/rank HUD and clean VConsole remain PENDING OWNER TEST.

## Slot 5: `enfos_slark_fish_bait`

Classification: REPLACE
Native counterpart: `slark_saltwater_shiv` (installed Ability3).
Decision: dedicated Enfos passive because native Saltwater Shiv and actual Fish Bait are active casts, incompatible with the free-rank passive slot. No native proc/attack transaction is guessed. Preserve capped attack armor/cleave; native counterpart is historical design context only.
Expected:25% landed-hit proc; per-caster5 armor stacks refreshed4s, rank1–5 armor each; circular physical cleave20–60% of actual hit damage at250. Killing hits can cleave but place no armor on dead targets; missing damage never invents damage.
Hero/creep/Creature NPC targets only; authored wave BaseClass npc_dota_creature is explicitly supported; no special boss rule. Physical cleave includes magic-immune units. Debuff is purgable, source-specific and capped; Break/illusions/untrained/invalid sources block new procs. Existing armor persists independently. Actual mitigation/tenacity remains owner testing.
Current versus target rank curve; free rank / point cost: ten ranks are defined; the Enfos passive rank 1 grant is separate from Dota innate metadata, ranks 2–10 are gated at levels 2–10; in-engine points remain pending.
Retain Fighter Shard35AS plus3s attack slow as an explicit Enfos extension; no native active Depth Shroud is added. Scepter native W; upgrades/item interactions remain pending.

### Resource and implementation evidence

- Current installed build6943/rev11069754 and source hashes in SLARK_NATIVE_SOURCE_2026-10-04.json; see exact slot matrix and source review.
- Existing Fish Bait splash/helper and precache retained; VPK SHA1d1a127ccd1833e8268fd1f46db8b40515906976e27f5b1bcaef044366522c91. ABSORIGIN_FOLLOW/released handle; actual one-shot completion/CP display remain pending.
- No added cast/proc sound: normal Slark attack audio remains native, bank precached. Actual attack/proc feedback/audio remains owner testing.
- Model/animation/gesture/icon evidence: PENDING.
- Isolated d.lua classes registered client/server by existing modifier_links. Intrinsic permanent listener; debuff MULTIPLE with matching-caster refresh, purge/death cleanup and client-safe armor getter.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Ability/buff text in EN/TR/RU/zh-CN now states per-caster cap, actual-hit damage fraction, radius/duration, killing-hit spread and Break/illusion restriction.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Targeting | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; in-game HUD/point behavior remains PENDING. |
| VFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| SFX | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Animation | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Modifiers | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Precache | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Cleanup | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Boss | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Upgrades | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Localization | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Performance | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| Reconnect | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |
| VConsole | PENDING | Source reviewed2026-10-04; owner engine evidence pending; see native-first review. |

2026-10-04 source/native metadata and focused regressions recorded in SLARK_NATIVE_FIRST_REVIEW_2026-10-04.md. Runtime/VFX/SFX/cleanup/rank HUD and clean VConsole remain PENDING OWNER TEST.

2026-09-30 level-cap integration: all five Slark abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Shadow Dance ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 static regression follow-up: Shadow Dance now has mock coverage for its ranked timed modifier, invisibility/truesight states, movement/regen values, and persistent-particle destruction/release. Actual Dota state semantics, visibility, audio and repeated-cast cleanup remain PENDING owner testing.

# Crystal Maiden individual review — source complete / owner engine pending

Own hero instructions/full dossier, shared hero/research/reference contract read. Five current Lua/KV implementations individually read; installed native definitions freshly extracted from Dota ClientVersion6943 / SourceRevision11069754 / Oct01 2026. Historical6941 dossier is not patch certification. Owner alone runs Dota; local commits only, no remote push/Workshop.

| Skill | Primary classification and current comparison |
| --- | --- |
| Q Crystal Nova | PVE-CONVERT: native425radius110→260magical damage,4sec20→50%MS/30→75AS slow; Enfos425radius130→340+1.2INT damage,4.5sec40%MS/50AS slow plus fifth frost stack. Native burst/slow identity retained; effect controls and lethal-target lifecycle under review. |
| W Frostbite | PVE-CONVERT: native100DPS,0.25sec ticks,1.5→3sec root/disarm,4xcreep multiplier; Enfos80→260+0.5INT DPS,0.5sec tick/3sec duration/3xnormal-creep multiplier plus fifth frost stack. Boss excluded from multiplier. Native root identity retained, ownership/DoT/stack lifecycle under review. |
| E Arcane Aura | PVE-CONVERT: native0.4→1base mana regen/20→80%regen amplification,3xproximity1200; Enfos global99999friendlyhero/basic aura,2→5regen/15→25%spell amp, CM triple regen with explicit self exclusion. Current ally/owner/Break rules reviewed; modifier presentation/real aura behavior pending. |
| R Freezing Field | PVE-CONVERT: native10sec channel/810radius,0.1sec random320radius explosions110→250damage, physical defenses/slow; Enfos8sec channel/800radius,0.2sec one random target120→240+0.6INTdamage,20armor/50%magic resistance/35%MS slow plus fifth stack. Single-target pulse is an existing substantive deviation, not native AoE explosion parity; visuals/cleanup under review. |
| Fifth Glacial Mastery | REPLACE: separate from native Glacial Guard mana-based barrier. Enfos five5sec frost stacks,1.5→1.8freeze (Boss25%duration),150→250+10%primarymaxHP300radius shatter, Boss percentage component cap600→800. Source/recipient cap and removed/kill callback ordering under review. |

## Frostbite persistent feedback ownership

Decoded installed6943 root and child chain with VRF19.2. Root is instantaneous128model-bound ice particles with endcap decay, but mist child has continuous emission without finite duration. Old generic helper released the index without any modifier cleanup owner. Lifetime of an individual particle is not termination of that emitter.

MCP ref_search/ref_get of Boss Survival1571786267 addition_bosses/golden_queen.lua directly shows its field-freeze modifier using this exact root in GetEffectName with ABSORIGIN_FOLLOW. Source revision/license/runtime of that external example are unverified; reference only, no code/assets imported. Primary [particle attachment guide](https://moddota.com/scripting/particle-attachment) documents modifier-owned ambient lifetime. Move native root into Frostbite modifier effect/attachment callbacks; remove standalone allocation. Existing precache owns its dependency chain. No damage, duration, control, targeting or timer change.

Extended existing positive creep-DPS regression first fails on standalone allocation, then checks zero manual allocations, exact owned root/attachment and existing0.5sec/187.5magical damage tick. Actual expiry/purge/death/recast, model-bound ice on doubled Boss models, cold start, audio and VConsole remain OWNER ENGINE PENDING. Source/mock cannot prove visible cleanup.

Frostbite validation:242behavior regressions,200/200abilities and223/223modifiers across ranks1–10; full checks0failed. OWNER ENGINE PENDING.

## Freezing Field ambient versus finite pulse effects

Confirmed high-frequency lifetime fault: each0.2sec damage tick allocated/released a persistent snow root at its target. Installed snow root has400/sec continuous emission, no finite duration, CP1.x ring radius0.6 and CP1.y thickness0.6; child chain includes the native caster effect. The standalone caster GetEffectName added another caster emitter while accumulating unowned snow per pulse. An eight-second channel could allocate up to40ongoing snow roots, not forty finite bursts.

MCP reference-only review of Boss Survival1571786267 heroes/hero_crystal_maiden/hero_crystal_maiden.lua demonstrates one owned snow root with CP1(radius,radius,1), and a different WORLDORIGIN explosion per impact. Decoded installed root corroborates inputs; explosion children are instantaneous or finite0.2sec emitters/Decay, with root PreEmissionOperators providing authored CP1/2. No guessed CP1 position override and no import of unverified-licensed reference code.

Focused repair owns one following snow root per channel with configured CP1(radius,radius,1), removes standalone caster callback (already a child), and uses a finite native explosion at each selected target. Existing eight-second0.2sec single-target damage, defenses, stack synergy and wind-stop path unchanged. Added exact explosion root to existing precache; one extra finite per pulse replaces one unbounded ambient allocation rather than adding a timer/global service.

Extended positive pulse regression first fails because no owned snow exists on creation; afterward checks one owner/radius controls and21ticks yielding21released finite explosions and still one owned ambient root.242behavior regressions/full checks0failed,200abilities/223modifiers across ranks1–10;219icons/259literal paths verified in installed VPK. Real channel interruption/death/recast cleanup, radius/endcaps/finite explosion positioning, cold-start resources/audio and VConsole remain OWNER ENGINE PENDING.

## Lethal callback ordering

Q, W and R applied slow/frost-stack modifiers after their damage had killed or removed the target. R additionally read its position after damage; a removed unit could throw before feedback/cleanup. New regression models immediate lethal removal for each of the three callbacks; it first fails on Q adding modifiers to a removed target. Each now gates post-damage modifiers on a valid living recipient; R captures impact position before damage and still renders its finite explosion there. No damage, tick, radius or stack threshold change.243behavior/full checks0failed,200abilities/223modifiers across ranks1–10. Real Dota death/removal/stack callback order and Boss interactions remain OWNER ENGINE PENDING.

## Secondary Boss shatter cap

Confirmed cap bypass: percentage-of-primary-HP damage was capped only when the stacked primary was a Boss, then shared unchanged to every AoE recipient. A20000HP normal creep therefore sent2000percentage damage to a neighboring Boss despite its600cap. Overlapping scheduled waves make secondary Boss recipients possible; Boss-only authored wave does not imply no surviving earlier normal units.

Extended existing five-stack regression with a normal20000HP primary plus neighboring Boss; before repair Boss receives2200total instead of800. Enforce the existing percentage-component cap on each Boss recipient while preserving original primary-Boss capping, normal recipient damage, base200 and freeze duration. After repair normal primary remains2200 and Boss800; original Boss-primary/neighbor800 case remains. No general nerf/new cap/rank change: enforce the existing advertised Boss safety cap on secondary recipients.243behavior/full checks0failed,200abilities/223modifiers. Owner live mixed-wave/phase mitigation and displayed tooltip values remain pending.

## Nova and shatter native radius/duration inputs

Decoded Nova root/children individually: CP1.x controls ring/flash scale (b child remaps radius into1.25visual scale); CP1.y controls b child's duration; root radial speed uses CP1.z*0.75 and other frost children use its radial component. Root/children are instantaneous or finite-emission/Decay chains. Generic position helper previously set onlyCP0; shatter generic entity helper set neither actual300radius nor duration.

MCP reference-only Boss Survival1571786267 CM source PlayEffects(point,radius,duration) independently supplies CP1(radius,duration,radius). No external licensed code copied; the current decoded inputs establish the small CM-local feedback helper. Both Q425/4.5 and fifth300/actual freeze duration now supply their own ground center and CP1, release finite index and retain existing native root precache. Fifth captures center before stack modifier destruction and rejects invalid/dead parent/removed ability before refresh processing. No shared/global helper or other hero changed.

Extended existing Q placement test first fails missingCP1, then checks point plus425/4.5/425and release; all243behavior/full checks0failed. Real authored visual scale, cold-start duration/center, Boss25%freeze visual, repeated shatters/audio and VConsole remain OWNER ENGINE PENDING.

## Tick termination guards

Frostbite interval could pass a removed caster into damage/stack calls; channel interval could continue target queries after the engine channel ended, until separate modifier cleanup arrived. New regression first fails on ended channel not stopping, then checks safe destruction for ended channel and removed Frostbite caster. Added server/valid owner/ability/target guards and live/channeling checks for R. Frostbite still survives a valid dead caster; removed caster/ability or dead recipient ends its debuff. MCP verifies CDOTA_BaseNPC:IsChanneling; owner must validate first-tick/interruption order in actual Dota.244behavior/full checks0failed,200abilities/223modifiers; modifier-owned effects and existing wind-stop cleanup retained, no timer or balance change.

## Modifier presentation and native audio

Nine CM modifiers now identify their verified native ability icons. Seven visible modifiers have EN/TR/RU/zh-CN names and descriptions in the source JSON and all twelve generated mirrors. Frost stacks expose the configured threshold through MODIFIER_PROPERTY_TOOLTIP; displayed property values remain engine pending. The short fifth-skill freeze now owns the already precached Frostbite model-bound ice/mist root for its lifetime instead of having no persistent frozen feedback.

Installed6943 sound bank declares `hero_Crystal.frostbite` (finite4.937483sec) and `hero_Crystal.freezingField.explosion` (finite1.329705sec, delay0.5sec, limiter disabled). W now uses exact bank spelling; case sensitivity of the earlier spelling is not established. R emits the finite explosion at its captured impact position, at most once per existing0.2sec pulse. No extra timer or ongoing sound allocation. Existing wind stops on modifier destruction; the bank's12.251429sec wind duration does not itself establish looping. Pulse visual child delay0.4sec, bank audio delay0.5sec and instant gameplay damage require actual owner timing/overlap evaluation.

Validation:244behavior regressions and full checks0failed;200abilities/223modifiers across ranks1–10. No Dota launch or Workshop upload. Actual icon/property rendering, frozen effect cleanup, audible events and VConsole are OWNER ENGINE PENDING.

## Animation declarations

Installed6943 native Q/W/R declare ACT_DOTA_CAST_ABILITY_1/2/4; native R additionally declares ACT_DOTA_CHANNEL_ABILITY_4. Custom Q/W/R omitted these declarations. Omission alone does not establish a broken engine default, but explicitly carrying the verified native cast/channel contract avoids depending on an unspecified fallback. Added these four fields only, with no gesture timer or animation-rate override. [KV documentation](https://moddota.com/abilities/ability-keyvalues) documents explicit activity selection.

Decoded current `models/heroes/crystal_maiden/crystal_maiden.vmdl_c` with VRF19.2. Model declares casts1/2/4 including freezing_field_anim_10s and cosmetic variants. It does not explicitly list CHANNEL_ABILITY_4, despite the current native R declaring it; engine mapping/fallback is unresolved. The native channel declaration is retained rather than inventing a different gesture. Eight-second custom channel versus ten-second authored animation, cosmetic variants and interruption remain OWNER ENGINE PENDING.

Frostbite tooltip had a separate numerical error in all four languages: it advertised the configured DPS as damage on each0.5sec tick, implying twice the actual damage. Lua correctly multiplies DPS by interval; four source descriptions and twelve mirrors now explicitly distinguish damage per second from tick frequency. Existing187.5damage tick regression establishes the calculation; no gameplay damage was changed.

## Source closure and owner acceptance

Five implementations, fresh6943 native counterparts, hero mapping/rank gates, shared upgrades, source translations/mirrors, native effects/sound bank/model and regression paths individually reviewed. This closes source investigation, not live acceptance. No external code imported, new progression/talent system, global thinker or unbounded effect service added.

| Area | Source findings / unresolved runtime gate |
| --- | --- |
| Gameplay/targeting | Q area slow, W enemy/spell-block/DoT/normal-creep multiplier, E global ally-basic/self-reject/triple-owner/Break, R single-target pulses and channel defenses, fifth stack/shatter/secondary Boss cap reviewed. Enemy immunity is non-piercing in KV/shared query. Actual block/reflect/immune targeting and slow/root/stun/status resistance remain pending. |
| Ranks/progression | Five stable slots/ten ranks, Q/W/E/fifth1/1 and R5/5, shared free fifth rank, level50 and49 ordinary points preserved. Engine rank-up/innate area, client properties on upgrade, death and reconnect pending. |
| VFX/SFX/animation | Nova CP0/1 finite feedback; Frostbite/frozen modifier-owned ice; one channel-owned snow and finite impact bursts; exact native audio declarations; explicit current native animation fields. Audio pulse overlap/delay, model channel fallback/cosmetic variants, radius and lifetime require actual Dota. |
| Modifiers/cleanup | W stale owner and R ended channel terminate; Q/W/R no modifiers on killed/removed targets. Aura/fifth Break rules, source self rejection and icons/text reviewed. Purge/strong purge defaults, illusion copies, different-caster stack ownership, aura lifetime after source death/removal, finite endcaps and real channel order remain pending. No assumption that a mock Destroy invokes engine cleanup. |
| Boss/upgrades | Fifth percentage component capped for primary and secondary Boss; freeze25%normal duration. Generic Mage Shard only15%spell amplification; configured unused mana_restore_pct is not implemented or promised. Generic Scepter40%ultimate-inflictor amplification/25%ultimate cooldown applies to R damage, not fifth-inflictor shatter; no native move-while-channeling, automatic Frostbite or Crystal Clone promised. Native/consumed/Ascended Blessing recognition, amplification and cooldown getters, Boss phase/control interactions remain pending. |
| Performance/reconnect | No extra timer/global scan; one snow root per channel, finite pulse root, bounded radius/tick queries. Existing99999aura includes friendly basics, potentially many summoned units; dense-wave cost, same-team buff transport/stacking and multiplayer restore remain pending. |
| Localization/resources | Four language descriptions/icons and twelve mirrors synchronized. Existing precache roots/bank plus newly added finite explosion root;219icons/259literal paths verified earlier in installed archive. Rendered intrinsic/visible modifier values, cold start and wrapping pending. |
| VConsole | Agent did not launch/control Dota. No owner runtime capture for these repairs; PENDING. |

Latest full checks:244behavior regressions,200/200abilities and223/223modifiers across ranks1–10,0failed checks. Expected mocked negative-path ERROR lines are deliberate fixture tests, not actual VConsole evidence. Queue may advance on source closure; balance/feedback are not certified.

Owner evening checklist: fresh local match; Q425ground radius/slow/Break-stack and lethal hit; W normal creep versus Boss DPS, spell block/immune/purge, repeated root/expiry/caster removal; E ally hero/basic versus own triple regen, Break/death/respawn and rank10 values; R eight-second channel, moving/interruption/death/recast, one snow field/finite burst/audio overlap, selected target loss/lethal hit and cleanup; fifth five stacks/expiry/Break, Boss25%freeze and normal-primary/neighbor-Boss cap; Scepter/Blessing R damage/CDR and Shard15%amp versus absent native movement/Clone, four-language icons/property display, free fifth skill/rank/point HUD, dense waves/reconnect and fresh VConsole. All ENGINE PENDING.

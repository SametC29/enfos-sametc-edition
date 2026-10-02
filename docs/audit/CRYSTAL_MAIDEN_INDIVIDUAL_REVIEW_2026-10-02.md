# Crystal Maiden individual review — in progress / owner engine pending

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

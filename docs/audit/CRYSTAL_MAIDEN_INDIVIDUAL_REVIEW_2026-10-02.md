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

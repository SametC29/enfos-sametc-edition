# Axe individual review — in progress

Full hero instructions and complete dossier read. Current installed native definitions extracted from scripts/npc/heroes/npc_dota_hero_axe.txt, ClientVersion6942/SourceRevision11055158, rather than historical6941 snapshot. Temporary extraction enfos-axe-inspect.mjs / enfos-axe-values.jsonl; full Axe particle folder decoded with VRF19.2 in enfos-axe-assets-20261001. All five custom implementations/KV and existing tests read individually. No engine launch or remote publication.

| Skill | Classification and comparison |
| --- | --- |
| Q Call | PVE-CONVERT: native area taunt/armor315radius12–15armor2.1–3sec versus Enfos400radius30–60armor3sec. Boss taunt25% custom. Native NO_TARGET and override animation1; custom has no forced animation key. Current taunt states do not explicitly assign a forced attack target, an investigation candidate. Custom sound identifier absent in decoded bank/native KV. |
| W Hunger | PVE-CONVERT: native nonpiercing enemy curse pure12–24DPS12sec, slow18–30; custom physical30–90+0.25STR10sec slow25, caster speed15 and on-death spread2targets400radius8sec. Physical change is explicit existing PvE behavior, not mistaken native damage. Native override animation2. |
| E Helix | PVE-CONVERT: recognizable reactive pure spin, native7→4 incoming attacks/100–160damage275radius0.3CD; custom7→3/100–250+STR300radius and0.2Boss-only proc throttle. Enemy/alive/Break guards and immune search explicit. Native Scepter counter/offensive-attack/damage-reduction upgrades differ from generic Enfos ultimate upgrade. |
| R Culling | PVE-CONVERT: native275–475pure finisher/20–30speed/armor reward versus custom35%normal/15%Boss execute threshold and failure300–600+2.5STRpure,40speed60ASreward900radius6sec. Successful Kill resets cooldown. Stable R is customslot4/native6; native activity4 supports its presentation. |
| Fifth Blood Armor | REPLACE: independent Enfos passive, not native One Man Army (native armor-to-STR50% with700radius ally condition). Custom8–17armor20–29regen, one stack per10kills/Boss kill up to50, physical15%reflection. Kill state retained over death, Break suppresses outputs/reflection. No talent/profile state. |

## Reproduced Hunger continuous effect allocation and repair

Native axe_battle_hunger root contains ContinuousEmitter/CreateOnModel/LockToBone and six children; script previously called generic CreateParticle+ReleaseParticleIndex every one-second damage tick. Releasing script index does not stop a persistent emitter and no owning modifier held these allocations. Regression performs two damage ticks and fails under old source because it creates two independent continuous effects.

Moved the verified native root to modifier GetEffectName with ABSORIGIN_FOLLOW; engine modifier lifetime now owns effect creation/cleanup. Removed tick allocation; physical damage amount/interval/spread unchanged, root already precached. Test retains two55damage applications while asserting zero tick allocations and native modifier effect binding.227 hero behavior regressions and full checks pass with0failures. Modifier effect API/lifetime pattern previously checked against https://docs.moddota.com/lua_server/declaration; no imported third-party code. Actual rendering, expiry/purge/death/multiple caster refresh and dense-wave/VConsole performance remain ENGINE PENDING.

## Berserker Call exact sound event repair

Custom Q emitted Hero_Axe.BerserkersCall, which is absent from the128-bank installed sound audit. Native6942 axe_berserkers_call AbilitySound is Hero_Axe.Berserkers_Call; the decoded Axe bank declares that exact event at line103 with Weapons mixgroup, sounds/weapons/hero/axe/berserkers_call.vsnd and finite2.619sec duration. BerserkersCall.Start is a separate voice event and was not substituted. Replaced only the Q emission identifier; no numerical/taunt/particle change. Installed hero-bank precache already present through roster resources. Sound audit now resolves this Q exact event; actual audible cast and overlap remain ENGINE PENDING.

Post-sound repair full checks0failed;227 hero behavior regressions. Refreshed bank audit records exact native Call sound and current source locations; unrelated missing/case-only events remain queued for their individual hero reviews.

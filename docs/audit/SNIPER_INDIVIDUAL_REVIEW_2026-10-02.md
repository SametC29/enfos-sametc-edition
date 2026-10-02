# Sniper individual review — in progress / owner engine pending

Own instructions/dossier and shared hero/research/reference contracts read. All five current Lua/KV implementations read individually; native definitions freshly extracted from installed Dota ClientVersion6943 / SourceRevision11069754 / Oct01 2026. Historical6941 dossier snapshot is not current patch evidence. Owner alone tests Dota; local commits only, no remote push or Workshop upload.

| Skill | Classification and current comparison |
| --- | --- |
| Q Shrapnel | PVE-CONVERT: native400→475radius,30→75magical damage,10sec,1.2sec delay, three charges/35sec restore; Enfos450radius,40→115+0.35AGIphysical damage each second,8sec,15→7sec cooldown/1200range. Persistent field identity retained; particle ownership/radius and resource feedback under review. |
| W Headshot | TUNE / PVE-CONVERT: native40%chance20→110physical bonus,50push and0.2→0.5sec slow; Enfos40%chance60→180+0.75AGIphysical bonus,60clear-space push except Boss,80%chance during E. No native slow implemented; feedback/event semantics under review. |
| E Take Aim | PVE-CONVERT: native160→400passive range,3sec100%Headshot active with65%self slow/extra range/vision; Enfos150→450passive range,5secTrue Strike/+15%MS, W80%chance. Deliberate mobile PvE variant, not native parity. Owned overhead attachment under review. |
| R Assassinate | PVE-CONVERT: native300→500magical,2500projectile speed,2sec cast, native Scepter shortens cast/adds stun; Enfos400→900+3AGIphysical,3000speed,1.5sec cast, kill resets cooldown/refunds half mana. Existing3000 is a custom setting, not current native speed; targeting/impact/upgrade/resource audit pending. |
| Fifth Keen Eye | REPLACE: Enfos forward550length/300width lane, nearest three secondary targets,60→100%landed-hit damage, Break/illusion suppression; separate from native Keen Scope distance damage innate. |

## Keen Eye lethal primary attack

Confirmed root cause: OnAttackLanded rejected an otherwise valid primary entity solely because its lethal attack had already killed it. The passive therefore failed exactly when wave clearing secured a kill. Existing nearest-three lane and live-secondary rules are retained. Extended existing positive regression with a valid dead primary and living enemy behind it; it fails before repair with no secondary damage, then passes when only the primary alive requirement is removed. Removed/null primary remains rejected; living secondaries, friendly rejection, Break, illusion and target cap remain unchanged. This is the same event/impact distinction already repaired individually for other heroes, not a blanket passive rewrite.

Installed current native innate is a different mechanic and does not establish this custom piercing event policy. MCP reference search finds Pathfinders2208582400 Sniper Shrapnel KV; no external code imported or license/runtime acceptance inferred. Engine attack callback/corpse lifetime and actual pierce damage/feedback remain PENDING owner testing. All subsequent acceptance entries must distinguish SOURCE/MOCK from ENGINE.

Keen Eye validation:238 hero behavior regressions,200/200abilities and223/223modifiers across ranks1–10; full checks0failed. Real Dota/VConsole pending.

## Shrapnel persistent field ownership and exact controls

Decoded installed6943 Sniper particle folder with VRF19.2. Root and impacts children contain continuous emitters without finite emission duration. The old generic effect helper released the index without a modifier cleanup owner and supplied neither configured radius nor secondary ground point. Root sphere radius uses CP1.x*0.8 and ground projection children use CP1.x; impacts_e position/velocity consume CP2. Root editor configuration separately corroborates CP1=(450,0,0), CP2 ground origin. Actual operators, rather than preview alone, establish the inputs.

Focused repair creates one WORLDORIGIN native root attributed to caster, supplies thinker origin CP0/CP2 and actual radius CP1, then attaches cleanup through CDOTA_Buff:AddParticle. Existing eight-second thinker expiry/removal and at-most-three live ground entities remain the owners/bound; no extra timer/service or damage/timing change. Native child dependencies are covered by existing root precache. [ModDota particle attachment guide](https://moddota.com/scripting/particle-attachment) supports explicit control inputs and modifier lifecycle; MCP lua_api_search resolves AddParticle's six arguments on CDOTA_Buff. Exact path search in Watcher3164617180 finds cosmetic replacement mappings only, not a lifecycle implementation; no imported code or rights/runtime claim.

Regression fails before repair on wrong attachment/owner, then checks one modifier-owned allocation, ground CP0/CP2,450radius CP1 and no standalone release.239behavior regressions,200/200abilities/223/223modifiers across ranks1–10 and full checks0failed. Source ownership is proved; actual eight-second cessation, fourth-cast eviction, child endcaps, cold-start circle placement, sounds and VConsole remain OWNER ENGINE PENDING.

## Assassinate exact shot/impact feedback

Decoded current native Sniper sound bank: Hero_Sniper.AssassinateShot is absent; Ability.Assassinate is declared and is the current native ability's AbilitySound. It is finite4.130998sec. Hero_Sniper.AssassinateDamage is a separate finite0.530431sec target impact event. Replaced missing shot identifier and restored this exact impact event. MCP reference search independently finds Ability.Assassinate in Pathfinders2208582400 KV and Boss Survival1571786267 zone12 projectile source; no external code imported or license/runtime claim.

Decoded impact sparks CreateWithinSphere uses CP1, while the prior generic helper supplied only the target attachment/defaultCP0. Native root is instantaneous128particles with0.1–0.7sec lifetime/Decay; no child emitter. Bind finite WORLDORIGIN impact CP0/CP1 at captured target origin, release index, then apply existing damage/refund logic. No projectile speed/rank/cast timing/balance change; configured3000speed remains a custom deviation from installed2500.

Extended projectile regression first fails on missing native shot event, then verifies deferred physical damage, exact shot/target impact sounds, both position CPs and one release.239behavior/full checks0failed,200abilities/223modifiers across ranks1–10. Actual projectile/body impact location, audibility, cold start, target loss/dodge, spellblock timing and kill refund remain OWNER ENGINE PENDING.

## Take Aim owned overhead attachment

Current root contains model glow/ring/embers/icon/burst children; model variants requiring extra model CPs are disabled. Active children PositionLock follow the default point; icon adds only40height, not a hero-height placement. Existing GetEffectName owns the persistent chain but no GetEffectAttachType selected overhead. Explicitly use PATTACH_OVERHEAD_FOLLOW (documented in the primary particle attachment guide), keeping modifier-owned lifetime and all active values. No secondary CP/model name is guessed.

New regression fails before repair on missing attachment method; afterward verifies overhead selection, rank10 passive450range,5secactive duration, and Break suppressing passive range while active True Strike/+15%MS persists. Fixture gives the verified CANNOT_MISS state a distinct constant rather than allowing a nil-key false test.240behavior regressions,200/200abilities/223/223modifiers and full checks0failed. Owner must inspect actual height/moving hero/expiry/death/recast/purge/cold-start/audio/VConsole; source attachment does not establish visual acceptance.

## Shrapnel tick lifecycle

Confirmed source faults: interval callback accessed removed caster/ability/thinker methods without validation, and unconditionally applied slow after damage had killed the queried unit. New regression first fails on corpse slow. Added server/valid-owner guards that end the thinker on removal, and living-target guard after damage; cast rejects invalid/dead caster or absent point. A valid dead caster intentionally does not cancel an already active area: test checks its existing57.5physical tick (40+35%of50AGI), no slow on the killed enemy, then safe ending when caster is removed. Damage/rank/tick/duration/immunity policy unchanged.241behavior regressions,200abilities/223modifiers/full checks0failed. Real death-versus-removal, thinker destruction/endcaps, final tick timing and VConsole remain OWNER ENGINE PENDING.

## Shrapnel ground sound lifetime

The existing cast Shoot event0.891202sec remains at Sniper. Native ShrapnelShatter defines delayed1.2sec ground sound lasting11.338594sec, while custom field lasts8sec. Restored this exact event at the thinker and explicitly StopSound before normal expiry/eviction/removal. No repeating loop/timer or extra sound resource; existing hero bank precache retained. MCP verifies CBaseEntity:StopSound. Expanded field regression first fails on absent ground sound, then verifies thinker emission and stopping before entity removal.241behavior/full checks0failed. Source uses bank's authored1.2sec delay while current damage ticks start1sec; actual timing/stop/fade audibility and VConsole must be tested by owner, not certified from mocks.

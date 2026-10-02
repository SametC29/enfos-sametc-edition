# Dazzle individual review — source complete / owner engine pending

Own AGENTS/full ABILITIES, shared research/hero/reference contracts read. All five current Lua/KV slots and Weave helper read; native definitions freshly extracted from installed ClientVersion6943 / SourceRevision11069754 / Oct01 2026. Historical6941 dossier does not certify the current patch. Local commits only; agent does not launch Dota or upload Workshop.

| Ability | Classification and installed native comparison |
| --- | --- |
| Q Poison Touch | PVE-CONVERT: native enemy-target cone,1300speed projectiles,2→8targets16→52physical DPS/3.5→8duration/13→22%slow,own-attack refresh/ramp. Enfos immediate no-target700radial8targets30→90+0.35INTphysical DPS/6sec/25%slow plus2per own attack up to35extra. Cone/projectile deviation retained for evidence-led review, not called native parity. |
| W Shallow Grave | PVE-CONVERT: native friendly heroes900range4→5.5sec,non-dispellable/ally-immune. Enfos friendly heroes/basic700range4.5→6sec,40%fixed heal amplification and one-health floor. Native heal_amplify3→9 is not the same scalar policy as this custom40%. Protection visual/dispel lifetime audited below. |
| E Shadow Wave | PVE-CONVERT: native475bounce185damage radius85→145physical damage/healing,3→6targets plus Dazzle, Scepter upgraded mode. Enfos six jumps plus initial500bounce200damage radius90→210+1INT heal/physical damage per recipient. Shared enemy query currently omits immune flag despite piercing KV; targeting and link effect under review. |
| R Bad Juju | REPLACE: current roster ultimate is Nothl Projection; installed archive also retains legacy bad_juju definition (3secCD/75flatHP/4→6CDR). Enfos uses10%current HP,600ally/enemy armor±5/8sec,passive1→2sec other-ability CDR. No projection/body/spirit mechanics; current generic Scepter damage wording needs review because R deals no direct damage. |
| Fifth Nothl Weave | PVE-CONVERT: native innate armor1/6.9sec+0.1perlevel and ally/enemy ability triggers,Shard ally heal60. Enfos2→4armor per stack,5stackcap/6sec/Break suppression; helper called on affected Q/W/E/R recipients. Rank/free grant, different-caster stacking/refresh, owned armor feedback and passive wording remain under review. |

## Grave protection effect and dispel policy

Old cast allocated/released native Grave root without a modifier lifetime owner. Installed6943 decoded root includes playerglow child with endcap-only alpha termination; other children have finite3.5sec emissions. A finite sub-emitter does not establish termination of the whole root. Native modifier lifetime must own ongoing protection feedback, especially for custom4.5→6sec duration, target death/recast and early removal.

MCP reference-only review of Boss Survival1571786267 `heroes/hero_dazzle/hero_dazzle.lua` directly shows GetEffectName/ABSORIGIN_FOLLOW and non-purgable Grave modifier. External revision/license/current runtime unknown: no code/assets imported. Installed native W independently declares SPELL_DISPELLABLE_NO and SPELL_IMMUNITY_ALLIES_YES; [particle attachment guide](https://moddota.com/scripting/particle-attachment) explains modifier-owned cleanup.

Focused repair moves the already precached root into the protection modifier's effect/attachment callbacks, explicitly makes it non-purgable and aligns W KV with native ally-immunity/non-dispellable policy. Keep expanded friendly-basic targeting, health floor, configured healing amplification and duration. No guessed CP1 halo-height override: current root has authored PreEmission control positions and actual height remains an owner visual gate.

Extended existing positive save/heal regression first fails on standalone particle allocation, then requires no manual allocation, exact owned root/attachment and non-purgability while preserving1HPfloor/configured30%mock heal amplification. Actual lethal Boss damage/kill exceptions, immune allied targets, dispel, halo height, death/recast/expiry and cold-start VConsole remain OWNER ENGINE PENDING.

Grave repair full checks:244behavior regressions,200abilities/223modifiers across ranks1–10,0failed checks. Source/mock only.

## Shadow Wave piercing query

Installed6943 native E and existing custom KV both declare physical damage with SPELL_IMMUNITY_ENEMIES_YES. Its shared radius query nevertheless used FLAG_NONE, excluding immune enemies before physical damage was applied. MCP current enum index confirms MAGIC_IMMUNE_ENEMIES; [KV targeting guide](https://moddota.com/abilities/ability-keyvalues) distinguishes targeting flags from damage/immunity metadata. No new piercing balance policy: align radius selection with the existing native/custom policy.

Expanded existing heal/bounce regression with one immune and two ordinary enemies, using a flag-aware query fixture. Before repair the immune unit is omitted; after the E-local query flag it receives the same configured250physical damage while the ally still heals250 and receives first Weave armor stack. Other abilities/global query defaults unchanged. Actual debuff immunity and armor-stack behavior on immune Bosses remain owner engine pending.

## Shadow Wave finite link endpoints

Generic entity effect helper supplied no CP0/1 endpoints to the native rope root. Installed6943 decoded root uses sequential paths/percentage-between-CPs from0to1, with finite b/c child emissions0.25/0.5sec and decay. A single entity-follow root without the previous bounce endpoint cannot describe the intended chain. MCP reference-only Aghanim's Pathfinders2208582400 creature_shadow_wave.lua confirms separate source0/recipient1 controls and releasing finite links; version/license unknown, no code imported.

Each existing selected recipient now gets one finite WORLDORIGIN link from the previous recipient's captured origin (caster for first link) to its captured origin. Both CPs supplied; release index retained. No guessed model attachment or unsupported CP2 override. Existing heal/count/order/damage unchanged, no projectile/timer added; point snapshots versus moving units and vertical alignment remain owner visual gates. Extended heal regression first fails missing link endpoints; afterward proves caster→initial ally→next recipient and two finite releases alongside original heal and immune damage checks. Full checks244behavior/200abilities/223modifiers0failed before removal of an unnecessary CP2 assignment; final equivalent check pending.

Final Shadow Wave link check after removing unnecessary CP2:244behavior/200abilities/223modifiers,0failed.

## Poison Touch slow transport

Additional slow was stored only in server Lua `bonus_slow`, while its shared property getter also runs on clients. A client without that server field displayed only the base25% despite actual27→60%slow. [Server-to-client documentation](https://moddota.com/abilities/server-to-client) documents engine-replicated modifier stack counts and their integer limitation; MCP confirms SetStackCount(int). Current KV uses integer2increment/35cap for all ten ranks, so one replicated count can encode bonus slow without a custom transmitter/timer. Future fractional configuration would need a different transport.

Replace the unreplicated field with native stack count, preserve refresh and cap. Visible count denotes added slow percentage points, not attack count. Expanded own-attack regression first fails missing replicated2bonus; separate client getter with no server field then receives27%slow, repeated attacks cap at35bonus/60total and another ally still adds nothing. Actual engine replication/property tooltip, purge/recast reset and reconnect remain pending.

## Poison ongoing feedback and stale tick lifetime

Installed native Poison Touch root is a projectile effect with MAXVelocity CP2 and endcap-only RadiusDecay/oscillation children. Custom Q creates no projectile at all: generic helper attached/released that projectile root on each immediate radial recipient without any endcap owner. Replace that mismatched standalone allocation with modifier-owned native `dazzle_poison_debuff.vpcf`/ABSORIGIN_FOLLOW. Decoded poison debuff emits20/sec on the recipient model; it intentionally requires duration ownership. MCP reference-only Boss Survival1571786267 Dazzle modifier uses that exact owned root/attachment. Current radial cap/damage/slow remain unchanged; native cone/projectile gameplay is not silently restored.

Add verified debuff root to existing addon precache. Preserve existing projectile precache because unrelated native/reference use may depend on it. Tick now stops for removed ability/caster or invalid/dead recipient before damage; a valid dead caster's already-applied poison remains. Extended positive own-attack test first fails standalone allocation, then checks exact owned feedback and existing slow behavior. New removed-ability regression checks destruction without a damage call.245behavior/200abilities/223modifiers, full checks0failed. Recast/death/purge/endcaps, model positioning, poison sounds and cold-start VConsole remain owner pending.

## Bad Juju minimum health input

At1HP the percentage cost passed0.9HP to SetHealth, whose current MCP signature accepts an integer. That sub-one fractional input cannot safely express a living1HP result; actual engine conversion/crash/death was not observed. Added an explicit integer floor with minimum1 while preserving the configured current-health percentage and existing insufficient-health branch. Extended current cost/CDR regression first fails on sub-one HP, then passes both1000→800HP and1→1HP. This is a source input-boundary repair, not evidence of an observed runtime death.

## Presentation, animation and upgrades

Decoded installed6943 Dazzle model explicitly lists ACT_DOTA_CAST_ABILITY_1, ACT_DOTA_SHALLOW_GRAVE, ACT_DOTA_CAST_ABILITY_3 and ACT_DOTA_CAST_ABILITY_4, including cosmetic variants. Fresh native definitions agree for Q/W/E and retained legacy Bad Juju R. Custom slots omitted explicit animations; carry the verified four activity declarations rather than assuming a slot fallback. R zero cast point versus native0.2sec is retained; gesture visibility at zero cast point remains owner pending. No guessed animation rate, resume-attack suppression or channel added.

Installed Dazzle sound bank has finite Poison_Touch3.29297sec, Shallow_Grave5.348458sec, Shadow_Wave2.821633sec and BadJuJu.Cast2.703605sec. R now uses exact event spelling; case sensitivity of prior BadJuju spelling is unproven. No new looping sound/timer. Q remains cast audio plus owned poison feedback; no fabricated projectile travel or periodic Poison_Tick emission. Real audible timing/Grave sound exceeding low-rank duration and cold-start bank loading remain pending.

Eight modifiers have native texture IDs; six visible statuses have four-language names/property descriptions, twelve mirrors regenerated. Armor effects explicitly follow recipients and remain modifier-owned. Hidden Bad Juju intrinsic no longer adds an unexplained separate buff icon; its passive is described on R. Visible Poison count describes bonus slow percentage points, not number of attacks. Source currently initializes first Weave stack at1 and caps/refreshes same-caster stacks; real different-caster and hostile/friendly coexistence pending.

Shared Support Shard supplies25%outgoing heal amplification, not native Weave60heal. Generic Scepter supplies25%R cooldown reduction; its40%ultimate spell amplifier has no direct R damage here and does not amplify Q/E/fifth. Four-language R Scepter descriptions now state this limitation rather than promise damage. R description distinguishes active armor swing from another-non-item-cast passive CDR, excludes its own cast and describes Break suppression. Native Nothl Projection, native E Scepter mode and native Weave Shard are not implemented/promised. Inventory/consumed/Ascended Blessing recognition and actual cooldown/heal getters remain owner gates.

## Source closure / owner acceptance

All five current implementations and fresh native counterparts, Weave helper, roster/ten-rank gates, shared upgrade manager, translations and decoded native particles/bank/model reviewed individually. No external code imported, full hero replacement, permanent progression/talent system or new global service. Final checks245behavior regressions,200/200abilities and223/223modifiers across ranks1–10,0failed checks. No Dota launch or Workshop upload; source closure permits the next queued hero, not an ENGINE PASS.

| Area | Source evidence / remaining owner gate |
| --- | --- |
| Gameplay/targeting | Q radial8cap/own-attack refresh/replicated slow and stale tick, W friendly save/nonpurge, E selected bounded chain/immune physical radius, R percentage cost/armor/other-cast CDR, fifth per-recipient armor/Break reviewed. Native cone/travel deviation retained. Spell block/reflect/immune, actual healing and corpse/reflection callbacks pending. |
| Ranks/progression | Five stable slots/ten ranks Q/W/E/fifth1/1 and R5/5; free fifth rank, level50 and49ordinary points preserved. Actual unlock buttons, point budget, intrinsic area, rank refresh/death/reconnect pending. |
| VFX/SFX/animation | Owned poison/Grave/armor roots, finite E CP0/1 links, exact finite event names, native model activities and precache verified from installed resources. Moving recipients, link vertical alignment, Grave halo height, poison/endcap cleanup, cosmetic variants and cast visibility pending. |
| Modifiers/cleanup | No unowned immediate radial projectile or Grave root; poison invalid owner/ability stops; integer bonus slow replicated. Native nonpurge Grave explicitly enforced. Strong purge/kill exceptions, Weave different-caster refresh, actual property sync, lost owner and death cleanup pending. |
| Boss/upgrades | E immune physical selection aligned; Q/R retain nonpiercing query. Generic Support Shard25%healing and Scepter25%R cooldown documented, no R direct-damage amp promised. Actual Boss armor/control/phase/health-floor exceptions, healing/category getters and native/consumed upgrade state pending. |
| Performance/reconnect | Eight Q recipients, six E jumps plus initial, existing R600queries/ability6slot CDR remain bounded; no new timers/global scan. Dense overlapping waves, same-caster refresh, particle endcaps, shared manager respawn/reconnect restoration pending. |
| Localization/VConsole | Four source languages/twelve mirrors synchronized; decoded new native poison root added to existing precache. Rendered modifier/ability numeric values, all languages, cold start and owner VConsole capture pending. |

Owner evening checklist: fresh local Dazzle match; Q capped radial targets versus immunity, own/ally attacks,27→60%slow/visible stack values,6sec refresh/purge/caster death/removal; W self/ally/basic/immune target,1HPsurvival,heal amplification,expiry/dispel/recast/native kill exceptions and halo/audio; E targeted heal/six jumps/no duplicate recipients, two moving endpoints/finite cleanup, physical damage around each ally including immune Boss and Weave stacks; R10%cost at normal/1HP,±5armor8sec, another spell versus own cast/item/Break CDR, Scepter/Blessing25%R cooldown and Shard25%heal; fifth stack1→5/6sec refresh/Break/different casters, ten-rank HUD/free passive/points/reconnect, all translations/effects/audio and fresh VConsole. All ENGINE PENDING.

# Anti-Mage native-first discovery

Status: Q/W/E/D SOURCE IMPLEMENTED / R NATIVE_COMPOSITION_PENDING / OWNER_RUNTIME PENDING.
This follows Ursa in the owner-directed rollout.

## Evidence

Installed build6943/revision11069754 Oct01 2026; source
scripts/npc/heroes/npc_dota_hero_antimage.txt SHA256
b70ba50c837db7379329dc1c515847dfa25a256b6252a115f39d2d7530579b11.
Fresh hash matches the older6941 dossier. Full nine definitions, header/facets,
English token source hash and six verified resource hashes are captured in
[installed snapshot](ANTIMAGE_NATIVE_SOURCE_2026-10-04.json).
Source/resource presence is not C++ lookup, modifier or engine certification.
[ModDota native alias limitations](https://moddota.com/abilities/ability-keyvalues):
exposed numeric variables can be inherited; internal C++ cannot be rewritten
by attaching a ScriptFile. No empty wrapper or native-ID shadow is planned.

Existing five slots are all Lua in abilities/pve_kits, ten ranks, standard
1/1 gates except R5/5. Native sound bank and five current particle paths are
already precached in addon_game_mode.lua; preserve verified resources.
Current Q never burns mana; it copies a physical flat/AGI proc and radial
cleave. W teleports to raw cursor position with no native ROOT_DISABLES or
OVERSHOOT flag or explicit projectile-dodge call; actual disjoint behavior
of FindClearSpaceForUnit has not been engine-tested. Native min-distance/
range/overshoot construction is not delegated.
E has resistance only, no spell block/reflect, and duplicates shield visuals.
R computes flat+missingmana+AGI AoE with custom stun on every non-Boss unit,
Boss-only maxHP damage cap/no stun and wrong native immunity declaration.
D is AS/MS only; installed Persecutor innate is absent.

## Pre-mutation classification and ownership

| Slot / stable ID | Class | Preferred ownership | Decision / next evidence |
| --- | --- | --- | --- |
| Q enfos_am_mana_break | PVE-CONVERT | NATIVE + minimal Enfos attack bonus | Exact antimage_mana_break provider owns burn/physical mana-derived damage, Break, illusion25% and Scepter. Paid ten ranks tune exposed values. Preserve authored40..150 +AGI.4..9 as separate real-hero PvE attack bonus; retire radial cleave to restore focused anti-magic attacks. This adds native mana damage where mana exists; numerical change explicit, not alleged parity. Verify combined native/custom proc and magic immunity behavior before source closure. |
| W enfos_am_blink | TUNE | NATIVE | Native point/root-disabled/overshoot blink, projectile dodge and min_range200; retain authored700..1150 range,9..3.5CD/mana50. Restore native castpoint.4 instead of.3. Scepter5s empowered next Mana Break/20%maxmana/6s denial needs exact Q identity; Q provider is the first source dependency. No custom teleport/VFX/SFX. |
| E enfos_am_counterspell | TUNE | NATIVE | Native immediate self block/reflect and passive magic resistance20..50, duration1.4..3/CD12..6/mana40. Retire active60..100 additional resistance to restore actual Counterspell instead of broad AoE immunity. Preserve native Shard reflected-spell fragment, no copied reflection/illusion logic. Inspect internal linked lookups before exposing Shard. |
| R enfos_am_mana_void | PVE-CONVERT | NATIVE + minimal PvE damage extension, construction unresolved | Native missing-mana AoE, main-target ministun only, target/immunity/block/reflection, feedback and cleanup; tune coefficient.35..95/radius450..800/stun.7..1.6/CD70..40/costs. Keep authored flat100..650+AGI.4..1.5 as separately justified PvE component if a validated path preserves block/reflect and one cast. Do not assume AbilityDamage header is read by C++. No Boss-only cap/no-stun branch. Prove native cast/controller/extension sequencing before implementation; source gate unresolved, not a product approval blocker. |
| D enfos_am_spellbreaker | TUNE | NATIVE Persecutor + minimal paid AS/MS | Separate exact rank1 antimage_persectur innate owns missing-mana slow/native illusion and level scaling; preserve paidAS10..100/MS5..50/freeD1/tenranks. Verify max-level50 native hero_levelup and zero-maxmana behavior; no cloned slow, aura or old facet grant. |

These are decisions before mutation, not migrated-kit acceptance. Native
identity takes priority over retaining copies. Q damage addition and cleave
retirement, E active-resistance retirement and R Boss-exception retirement
are explicit migration decisions. Existing authored costs/rank gates and
five paid IDs stay fixed. Do not alter Boss/wave AI/stats or grant enemy mana.

## Mana and linked abilities

Production npc_units_custom.txt explicitly sets StatusMana0 on soldier,
archer, runner and48 numbered normal-wave definitions. Caster archetypes
include frostguard200/healer400/silencer100 and others with mana. Actual wave
spawn uses creepEntry.unit_name through SpawnCreepEntity/CreateUnitByName;
KV alone does not establish every live unit's max mana or final spawn config.
This evidence warrants a small PvE component rather than deleting native
mana mechanics or silently assuming every creep carries mana. GetMana and
GetMaxMana are BOTH; associated-primary-ability query is SERVER only.

Q uses mana_per_hit25..40, maxmana1.8..4.5%, damage_per_burn65%, illusion25%;
Scepter adds1.5%maxmana and empowered20%maxmana/6s denial. W grants next-hit
window5s. Ten-rank interpolation/default tuning must be specified at Q's
source boundary; KV MaxLevel10 alone cannot certify native C++ acceptance.
Persecutor exact ID is antimage_persectur (installed spelling), not inferred
from English name. Rank1/Innate/NOT_LEARNABLE/Break, slow12..24 at low mana,
hero_levelup+.5/+1, mana_threshold60/duration.75; actual50-level scaling needs
owner test. Do not grant deprecated Mana Thirst or Magebane's Mirror facets.
Counterspell Ally grant is commented in installed data; old Mana Overload
IsGrantedByScepter definition exists but native header does not assign it.
Current installed Scepter English text describes empowered Mana Break/Blink.
Do not grant a legacy extra button from the icon/name or stale definitions.
Native E Shard creates4s fragment on reflection; use native construction and
cleanup, not copied CreateIllusions or a new manager. C++ linked ability IDs
and ownership of copied illusion abilities are not proven by KV alone.
Generic Carry Shard AS/MS/Pure proc and generic Scepter ultimate amp/CDR
must be reviewed against native Q/W Scepter and E Shard before migration;
no duplicate upgrade grants and no unrelated hero-wide changes.

## Reference-only comparison

Boss Survival Adventure1571786267 scripts/vscripts/heroes/hero_antimage/
hero_antimage.lua copies mana burn with MANA_ONLY filtering and Script_ReduceMana;
its Blink is a target/illusion ability, not current native point Blink.
WORLD OF DOTA2880603428 scripts/vscripts/heroes/npc_dota_hero_antimage_custom/
antimage_counterspell_custom.lua copies reflect/talent/illusion layers;
its additional custom talents and global illusion scan are not adopted.
Exact upstream version/license/distribution permission are unestablished.
Both REFERENCE_ONLY; zero code/asset imports. Neither proves current C++.

## Validation / progression

Source sequence: Q native linked provider and minimal PvE proc, then W,
E, R (prove extension/block path first), D. Finish this hero before Storm
Spirit. Shared health already selects every roster hero automatically; add
read-only native-provider queries within it as needed, no manual console
script, new logging timer or live gameplay probe. Preserve shared restore,
level6/fivepoints/freeD1/49ordinarypoints/level50/no talents/profile.
Client links/classes/paths and server live handles must be tested separately.
No native modifier ID or server-only getter can be guessed on the client.
Full restart required when owner resumes structural-KV/bootstrap testing.

Owner pending: Q burn/actual bonus damage/mana depletion/zero maxmana,
Break/illusions25%/Scepter empowered hit; W short/long/overshoot/root/projectile
dodge/Scepter; E targeted block/reflect/AoE non-block/Shard/Break/purge;
R primary-only ministun/secondary targets/immunity/block/reflect/zero missing
mana/native+PvE total/no Boss cap; Persecutor level50/zero maxmana/illusions;
all10paidranks/HUD/points/upgrades/respawn/reconnect/repeated-use/coldVFX/SFX
and VConsole. SOURCE_PENDING and OWNER_RUNTIME_PENDING are separate gates.
No live test requested now; owner defers gameplay tests. No push/deploy.

## Q source construction decision before mutation

Paid controller keeps ten ranks and installs one tuning/attack-bonus modifier;
exact hidden antimage_mana_break provider is rank0 until trained, then rank1.
Existing shared free-D restore hook creates/tunes provider before starting XP.
No second native alias/intrinsic, native-ID shadow or copied mana reduction.
Only mana_per_hit and mana_per_hit_pct are overridden by raw paid arrays:
25/26.7/28.3/30/31.7/33.3/35/36.7/38.3/40 mana and1.8/2.1/2.4/2.7/3/3.3/
3.6/3.9/4.2/4.5% are explicit ten-rank interpolations of installed endpoints.
Native damage_per_burn65%, illusion25%, Scepter empowered20% and6s denial
remain engine-owned/unoverridden. The mana-percent bridge adds verified
Scepter1.5 only via HasScepter (BOTH) and a plain paid metadata field; it does
not assume GetLevelSpecialValueNoOverride includes special_bonus_scepter.
Native own modifier still constructs empowered attacks/Break/feedback.
Minimal real-hero enemy hero/basic/creature proc bonus uses the physical
attack property, raw40..150+liveAGI.4..9, no ApplyDamage, scans, particles
or native burn copy. Native and extra proc composition is engine pending.
Client getter returns0 before loading server diagnostics. Existing modifier
link/bootstrap pattern gains one class; no server services on client.
Rank-up refresh only the native caster intrinsic, not target effects or
Blink empowerment; actual cache/state behavior remains owner pending.
GetAgility is on CDOTA_BaseNPC_Hero (BOTH), not the base NPC class.
Restore/lifecycle preserves points/handles/rank and adds no timers.

## Q source validation

116 affected checks,319 hero mock regressions and full source checks pass
with0failures. Seven focused Q checks cover source ownership/tuning,
idempotent provider/rank-up restore without points or target writes, both
client/server raw getter/Scepter math, physical PvE proc/all10ranks/liveAGI/
Break/illusions/invalid targets/killing hits, client rank-hook guards, all
fourlocales/12mirrors and read-only native Health. Bootstrap registers17
classes once; source only loads Antimage classes on client, not restoration.
Existing passive/free-rank hook used, shared point/lifecycle managers unchanged.
Header/key matching now renders Scepter/Shard description placeholders from
canonical KV; generated mirrors pass. Native burn/65% damage/illusion25%/
empowered20%/6s deny/VFX/SFX remain native with no extra ApplyDamage or burn.
Old radial cleave and particle emission/attack-landed copy removed.
OWNER_RUNTIME PENDING: actual native burn/zero-mana and immunity eligibility,
combined native+extra proc/crit/sustain, paid rank cache refresh preserving
empowerment, Scepter bridge readpath (including no double bonus), illusion
copying and native25% component only, Break/points/HUD/respawn/reconnect/
coldVFX/SFX. Health queries are not actual damage certification and initial
rank0/query0 are expected until Q training. W empowerment not yet migrated.
Next source unit: W native Blink and Scepter link, then E/R/D.

## W construction decision before mutation

TUNE / pure NATIVE alias enfos_am_blink -> antimage_blink. Fresh installed
build6943/revision11069754 and hero SHA256 b70ba50c837db7379329dc1c515847dfa25a256b6252a115f39d2d7530579b11
match discovery. Explicit native POINT/ROOT_DISABLES/OVERSHOOT, min200,
castpoint.4, animation2, Blink_out sound and HasScepterUpgrade1 retained.
Keep authored range700..1150/CD9..3.5/mana50/ten paid ranks/1-1 gates;
range and cooldown both have header and native AbilityValues value arrays.
No talent bonuses. Copy installed Scepter base0 plus5s/20%/6s metadata,
not unconditional empowerment. Exact Q provider already restored separately;
no second provider, wrapper, manual teleport, projectile dodge, VFX/SFX or
empowerment writes. Retire manual W and its raw-cursor mock. Keep verified
startup assets. Native linked-Q lookup, short/overshoot/cliff placement, root,
projectile dodge, ten-rank HUD/costs and actual Scepter consumption pending
owner engine test. Boss Survival1571786267 hero_antimage.lua re-read: its
unit-target illusion Blink differs from installed point Blink; reference-only,
no import/license claim. ModDota ability-keyvalues re-read (no trailing slash),
confirms BaseClass aliases only inherit exposed variables, not internal C++.
Scepter tooltip uses verified fixed native5/20/6 facts, avoiding raw base0
placeholder substitution; all four languages updated.

## W source validation

119 affected source checks and318 hero mock regressions pass. Three focused
W contracts compare targeting/Scepter special objects with installed snapshot,
independently authored ten-rank range/CD/mana/gates, native alias ownership,
no manual W code/native-ID shadow, retained precache and four translated
tooltips/twelve mirrors. Old raw-cursor teleport mock removed: it cannot
verify native C++ movement. Existing Q provider restore remains unchanged;
no new modifier/client class, spellcast callback, logging timer or point grant.
All engine gates remain PENDING OWNER TEST: ten native ranks, placement/
short/maximum/overshoot, rooted rejection, incoming projectile dodge,
Scepter next-hit Q lookup/5s expiry/additional20%/6s undispellable mana gain
denial, upgrades on/off, cleanup/repeated use, cold VFX/SFX, HUD/points and
respawn/reconnect. Full restart required when owner resumes. Next source E.

Full source checks:0 failed check(s). Engine playtests remain separate.

## E construction decision before mutation

TUNE / NATIVE alias enfos_am_counterspell -> antimage_counterspell.
Installed hero hash/build reverified unchanged. Native NO_TARGET/IMMEDIATE,
Break/passive MR, dispellable shell, animation3/default gesture, Shard flag,
does_reflect1, reflectedamp0/healpct0, illusion4s/outgoing0/incoming100
retained. Keep authored MR20..50, shell duration1.4..3/CD12..6/mana40 and
ten paid ranks/gates1-1. Retire broad active resistance60..100 and manual
feedback/modifiers. Native owns block/reflect/fragment construction/cleanup;
no extra ally Counterspell/Mana Overload/facet spell or hidden E provider.
WORLD OF DOTA2880603428 counterspell_custom.lua re-read: manually copies
ABSORB/REFLECT/stolen spells and per-frame cleanup/global illusion search,
with custom talents. REFERENCE_ONLY, no imports; does not prove native
linked lookups. AssociatedPrimary API SERVER verified; query actual result
only, no guessed linked ID. Two reference-suggested native resource paths
counter.vpcf_c and spellshield_reflect.vpcf_c verified directly in installed
VPK (hashes in snapshot eResearch); preload in existing startup owner,
no manual CP/particle recreation. Presence is not presentation certification.
Native Shard replaces generic Carry15%MS/12%pure attack proc for this
owned Anti-Mage kit, following Luna suppression pattern; no other hero
changes. New ownership predicate is client-safe and imports no services;
no new client modifier. Scepter generic ultimate remains for R unit review.
All native spell/illusion/Shard/ten-rank/lifecycle/Break engine gates pending.

## E source validation

123 affected checks and317 hero mock regressions PASS. Four focused E tests
compare installed native fields, independently authored ten-rank curves,
absence of local duplicate modifiers/native-ID shadow, two verified startup
assets, four translations/twelve mirrors, client-safe ownership and selective
generic Carry Shard suppression with unchanged other Carry output. Existing
client bootstrap17classes remains; no new modifier/class/restoration/timer.
Retired old broad-active-resistance mock cannot certify native reflection.
Native Break/illusion passive resistance and reflected-spell/Shard internal
lookup remain owner pending. No hardcoded legacy or extra provider grant.
Full restart before owner test: targeted unit spell block+reflection versus
AoE, reflection recursion/block/immune/channel/target-death, native Shard
4s fragment/copy abilities/no generic15%MS/12%pure and expiry/death cleanup,
Break/passive MR/ten ranks/HUD/points/cold VFX/SFX/respawn/reconnect/VConsole.
Source unit E only; generic Scepter review and R extension unresolved next.

Full source checks:0 failed check(s). Engine verification remains pending.

## R focused corrections before native construction

Fresh installed build6943/rev11069754 hero hash unchanged. Native R
UNIT_TARGET|AOE, SPELL_IMMUNITY_ENEMIES_NO, magical,600range/.3castpoint;
ministun main target only; no HasScepterUpgrade or Boss exception. Current
custom R contradicts all three, and generic Scepter incorrectly boosts R
although installed upgrade belongs to Q/W. Correct these independent source
defects now: ordinary flags/UnitFilter validation and AoE targeting radius,
remove Boss cap/non-stun branch, one primary status-resistance-scaled stun,
suppress generic40%amp/25%CD only owned Anti-Mage W kit; remove obsolete
R Scepter claim/flag. Preserve flat/AGI/missingmana/rank/cost curves.
This is NOT native R migration completion. Installed R only exposes mana
coefficient/ministun/radius, not confirmed flat damage input. Neither extra
AbilityDamage header nor zero-native-damage outgoing property establishes
flat100..650+AGI.4..1.5 at full/zero maxmana. Executed-cast events do not
prove spell-block success; custom first absorb plus native OnSpellStart
may duplicate checks/reflection. Reject these unproved composition shortcuts.
Native controller pattern SF is untargeted and cannot prove R block path.
SetCursorCastTarget and OnSpellStart APIs SERVER reverified; UnitFilter
BOTH. WORLD OF DOTA2880603428 mana_void_custom.lua re-read: custom
primary stun then missing-mana-only AoE, no current native flat-extension
example. REFERENCE_ONLY/no import; license/version not established.
ModDota current ability-keyvalues re-read: exposed variables only, locked
C++ composition; engine-only zero-damage/absorbed/reflected cases remain
a technical open gate. No native grant/cast, no temporary enemy mana,
new global filter/manager, or duplicate damage introduced to evade this gate.

Upgrade metadata follow-through: retire D HasShardUpgrade and its generic
Carry tooltip; current native E owns Shard. D gameplay unchanged in this
unit, awaiting separate Persecutor/paid stats migration. Shared contracts
now check Anti-Mage Q/W Scepter and E Shard instead of generic R/D flags.

R focused validation:125 affected checks/317 mocks PASS. Existing R mock
now covers ordinary filter/invalid and absorbed casts/client guard, normal
and Boss primary/secondary distinction/status resistance, uncapped shared
formula and zero maxmana flat+AGI. Two focused contracts compare actual
native metadata/retained authored values and selectively suppress generic
Scepter for owned Q/W kit without changing other Carry ultimate outputs.
All observed outputs are mocks/source. R stays SOURCE_PENDING for native
composition, D source pending; do not mark kit complete or move hero yet.

Full checks initially exposed a missing UnitFilter mock API in the all200
dispatch fixture, not a missing installed API. Added signature/team smoke
fixture without claiming engine immunity acceptance; focused dispatch PASS,
full source checks then0failures. R native composition remains unresolved.

## D construction decision before mutation

TUNE / NATIVE Persecutor + minimal paid AS/MS. Fresh installed6943/
rev11069754 hero SHA256 unchanged. Exact spelling antimage_persectur,
MaxLevel1/Innate1/passive-INNATE_UI-NOT_LEARNABLE/Break; native missing-mana
slow12/24, hero_levelup+.5/+1, threshold60/duration.75. Native owns slow,
illusion full effect, eligibility and level scaling. Add exact provider once
rank1/hidden/activated through existing pre-XP restore, only real owned hero,
no native-ID shadow/special override/copied slow or target writes. Paid D
ten ranks retains AS10..100/MS5..50/freeD1/49points/gates1-1; module d.lua
plus persistent hidden nonpurge stat modifier, one client-registered class.
Rank-up ensures native provider without changing points or other ranks.
Do not force-refresh native innate/cache/targets each rank; native rank1
stays fixed. Native50-level scaling and zero maxmana behavior remain owner
pending. WORLD OF DOTA2880603428 persectur_custom.lua re-read: custom
attack-landed/slow explicitly rejects zero maxmana and scales own talents;
REFERENCE_ONLY/no import, does not certify installed C++ behavior.
Reference icon antimage_persectur_png.vtex_c NOT FOUND in installed VPK;
do not adopt guessed texture. Preserve paid D existing independent stat
icon; native presentation remains engine-owned. No new particles/sounds.
EN/TR/RU/zh-CN describe native mana-based slow without guessing level50
formula; no grant obsolete Mana Thirst/Magebane/Mana Overload/extra ally.

## D source validation

131 affected checks/317 hero mock regressions PASS. Six D checks cover
ten-rank ownership/curves/no slow copy, native innate once/idempotent through
pre-XP and paid rank-up with no point/cache/target writes, both-context stat
getters/Break/illusion/untrained/null paths, client upgrade hook, automatic
read-only native Health and four locales/twelve mirrors. Shared bootstrap
registers18classes once with no server integration imports. Existing Q
restore extends with D native provider only when paid D is present; Q-only
fixtures remain supported. Existing shared point/respawn lifecycle unchanged.
Native innate rank1 stays activated/hidden, paidDfree1 stays separate; no
restore on illusions. Engine-generated copies/innate level50/zeroMaxMana
behavior and native/caster modifier ownership remain owner pending.
Health reports actual intrinsic name/provider rank/min-max queries; these
are not slow damage or native auto-level acceptance. No native D ID shadow,
new slow modifier/timer/particle/sound. Paid stat icon retained because
reference Persecutor texture path could not be verified.
OWNER_RUNTIME_PENDING: D stats all10ranks/points/free1/49/level6start,
Persecutor slow at above/below60%/zero/full mana and zero maxmana, hero
level6..50/illusion full slow versus no custom stats, Break/target immunity,
repeated restore/death/reconnect and native modifier cleanup/VConsole.
R still NATIVE_COMPOSITION_PENDING; no Anti-Mage completion is claimed.
The existing flat/AGI R component is not an explicit owner preservation
requirement. Owner preference between full native R and retaining that
component remains pending. Independent Storm discovery may continue under
the owner's deferred-live-test rollout instruction.

D full source checks:0 failed check(s). Engine playtests remain separate.

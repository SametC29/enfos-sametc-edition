# Dragon Knight native-first source review

Discovery is recorded below; Q now uses native alias plus raw STR scaling.
W/E/R/D remain CUSTOM Lua pending their focused source units. SOURCE_REVIEW in progress,
AUTOMATED_VALIDATION not a runtime certificate, OWNER_RUNTIME PENDING for every
native migration. Existing lifecycle/target-validity fixes stay until their
copied mechanics are deliberately retired. No Dota launch/control, remote push,
deployment or publication.

## Installed evidence

Re-read installed `scripts/npc/heroes/npc_dota_hero_dragon_knight.txt` from Valve
VPK on2026-10-04. Client/ServerVersion6943, SourceRevision11069754, Oct01;
SHA256 `3dcfc11fbe634effac91207ead048537ffdda6b22ad030c7c097c1d43b3b2043`.
Six definitions, exact English source tokens and eleven compiled resource
hashes are in [native snapshot](DRAGON_KNIGHT_NATIVE_SOURCE_2026-10-04.json).
Repeated header precache entries are preserved in headerRaw, not renamed or
dropped. Strict project parser reads only extracted definition/facet blocks;
primitive header fields exclude nested AbilityDraft assignments.

Native slots: Q Breathe Fire, W Dragon Tail, E Wyrm's Wrath, hidden Shard
Fireball, innate Dragon Blood, R Elder Dragon Form. Project slots instead put
paid Dragon Blood at E and authored Wyrm Vigor at D. Icon equality does not
make Wyrm Vigor an implementation of Wyrm's Wrath. Three old dragon-color
facets are explicitly Deprecated=true. Old facet localization remains in the
installed file; it cannot override current KV or authorize granting facets.

## Pre-mutation five-slot matrix

| Slot / stable ID | Existing implementation | Verified native counterpart | Class / intended ownership | Decision and source gap |
| --- | --- | --- | --- | --- |
| Q enfos_dk_breathe_fire | Instant fixed-width line, manual damage/attack reduction/particles; damage120..660+STR1.2 | dragon_knight_breathe_fire | TUNE / NATIVE+MINIMAL EXT | Native traveling cone speed1050/start150/end250/range750; point+unit+direction targeting, magical damage, dispellable reduction. Retain authored damage/cost/CD/duration/reduction through exact exposed keys and minimal raw STR bridge. Retire instant line and copied debuff/feedback. |
| W enfos_dk_dragon_tail | Instant physical150..600+STR1, copied stun, immunity piercing, Boss cap | dragon_knight_dragon_tail | TUNE / NATIVE+MINIMAL EXT | Restore magical/non-piercing/strong-dispel native target rules, projectile1600/form-range linkage and AoE50 metadata; authored costs/damage/duration with minimal STR. Retire Boss-only cap and copied stun/absorb/impact. No independent status-resistance calculation. |
| E enfos_dk_dragon_blood | Armor6..24/regen10..40+STR.05, copied passive; no form multiplier | dragon_knight_dragon_blood | TUNE / NATIVE+MINIMAL EXT | Exact innate identity separate from ten paid E ranks; raw armor/health_regen bridge owns authored stats without duplicate native armor/regen. Native50% form bonus stays native. Inspect hero-levelup/cache before implementation; no extra default2+.5/level silently stacked. |
| R enfos_dk_elder_dragon_form | Manual red-model/projectile/ranged swap; damage30..120, all-rank80%splash+frost, no corrosive/black form | dragon_knight_elder_dragon_form | TUNE / NATIVE+MINIMAL EXT | Native cumulative green/red/blue and Scepter black forms own transform/attacks/cleanup. Ten paid numeric ranks must not send unsupported form tiers to C++; exact native provider capped to its three ordinary ranks is the candidate. First three paid ranks should retain native tier relation; later paid ranks tune numbers. Final provider/scaling/cast-cache design requires source/API review. No model/splash/frost rewrite. |
| D enfos_dk_wyrm_vigor | Magic resistance10..25/Strength10..55 only; generic Tank Shard | dragon_knight_wyrms_wrath | TUNE / NATIVE+MINIMAL EXT | Restore native attack magic_damage10..40 and bonus_aoe30..120 via ten-rank paid integration, retaining authored resistance/STR as separate minimal stats. Native provider owns attack/Break/illusion/AoE; don't copy an OnAttackLanded proc. D remains free1 then paid ranks2..10, not innate. |

All rows are source decisions for focused implementation, not claims that the
current production kit is migrated. Q/W/E/D gates1/1, R5/5, level50, level6
start, five ordinary points and separate freeD1 remain. No talents, persistent
progression, shared Boss AI/stats/waves changes or new respawn manager.

## Native details that affect architecture

Q native reduction key is `reduction`, not current `reduction_pct`. Native
AbilityCastRange is1000 in AbilityValues while travel range is750; these are
different quantities. Current fixed width225 cannot replace cone endpoints.
English note says no spell block/reflect even though unit targeting is allowed;
native owns this. Current width/range behavior is not proven native.

W native `dragon_cast_range=150`, projectile_speed1600, aoe50 and damage_pct0.
Do not use the450 field from an older reference. Elder Dragon Form supplies
bonus_ability_cast_range350; actual linked range/read path needs Dota. Normal
target rules apply to Bosses, no compensating Boss exemption or special cap.

Dragon Blood is Innate1/NOT_LEARNABLE with armor2/health_regen2 and
hero_levelup+.5; both get50% more during native form. Authored paid E and exact
innate must be separate so automatic innate leveling cannot consume E ranks or
duplicate stats. Native modifier name will be queried from live ability, never
guessed. Break/illusion behavior and stat cache need engine evidence.

R native MaxLevel3/RestrictValuesToMaxLevel1; four-entry arrays account for
Scepter bonus_levels1. Green corrosive25DPS, red splash75%/275, blue frost
movement30/attack50/3s, black corrosive35/splash100%/350/frost45/65,
free-pathing/magic-resistance20 are source values. Existing authored flat
splash/slow at rank1 contradict cumulative native identity. Prefer exact native
R identity for E/W linkage; paid10-rank wrapper would delegate one cast and
numeric overrides, not recreate form states. Provider-tier behavior, Shard
linkage and all C++ read paths remain unresolved until inspected/tested.

Shard grants `dragon_knight_fireball` (MaxLevel1/IsGrantedByShard1) with
radius275/damage85/duration6/interval.5/linger2, cost80/CD20/base range600.
Native R AbilityDraftExtraAbilities explicitly associates Fireball with Shard;
production hero slot4 is currently overwritten by paid R. Must preserve the
native Shard grant through an exact provider/verified grant path, no guessed
slot, unconditional grant or duplicate Fireball. Replace generic Tank health/
reflect only when native Fireball integration is implemented. Native Scepter
form tier replaces generic R40%amp/25%CDR; suppress only owned DK kit.

## References and resources

[ModDota native BaseClass guidance](https://moddota.com/abilities/ability-keyvalues)
re-read: native aliases inherit exposed KV, not arbitrary C++ internals.
Offline reference search/get inspected AGHANIM'S PATHFINDERS2208582400
`scripts/npc/heroes/dragon_knight/npc_abilities_dragon_knight.txt`: ability_lua
form, separate inherited-vigor and facet-dependent Dragon Blood/old450 W
range. That schema differs from installed deprecated facets/current innate.
Boss Survival1571786267 search found Lua form includes; WorldofDota2880603428
found native Wyrm's Wrath assignment. Those searches do not prove execution.
All are REFERENCE_ONLY: version/license/distribution compatibility unknown,
no code/assets imported. Read relevant Lua if needed in the focused slot unit.

Existing startup precache owns six copied-Q/W/R particles, dragon model and
DragonKnight sound bank; native hero precache also lists corrosive/fire/frost
projectiles. Eleven compiled paths hashed, file presence only. No CP semantics,
actual cold-load/audio/visual/purge/cleanup acceptance from that evidence.
Retire copied resources only when usage is removed; native-required resources
stay under verified ownership. Native form owns cosmetics and restoration.

## Next source and engine gates

Next focused unit: Q native cone, exact fields, raw STR bridge and localization;
then E/D native identity prerequisites and W/R linked behavior. Before each unit,
recheck installed hash/build and actual affected API/ownership. Restore native
providers through existing pre-XP/passive and reconnect service, no new scans,
timers or counter setters. Client registration must load only reviewed classes.

Owner later performs full restart, selected-hero Health, rank1/10+points,
sideways/uphill/point/unit Q and cone/travel/reduction/block-reflect, W AoE/
projectile/block-reflect/immunity/strong-dispel/range/form, E level+form/cache/
Break, D attack magic/AoE/Break/illusion, all R tiers/Scepter/Shard acquisition
and removal, death/respawn/reconnect/recast/cleanup, model/projectile/animation/
VFX/SFX/cold-load/VConsole. Source fixtures are not substitute acceptance.

Discovery validation: snapshot SHA256 matches the freshly read VPK bytes;
six definitions/eleven compiled-resource records, actual hero slots, deprecated
facets, innate metadata and three+Scepter form metadata checked. Existing
40-dossier/200-slot reference checker passes. No production source changed,
so no new full gameplay regression run is claimed for this documentation unit.
All material C++ behavior remains source/runtime pending as stated above.

## Q pre-mutation decision

TUNE / NATIVE+MINIMAL EXT. Pure native alias, no ScriptFile/empty wrapper:
native point/unit/directional targeting, ordinary enemy hero/basic, immunity
NO, magical damage/dispellable reduction, cast.2/animation1/sound, cone150..250,
speed1050/travel750/cast-range1000 metadata. Retain authored damage120..660,
CD11..7, mana90..170, reduction35..62 and duration6..9. Map reduction_pct to
native reduction and retire fixed width225. Numeric values tune native data;
no projectile/debuff/absorb/particle/sound copy. Minimal raw damage override
adds STR1.2 at current paid rank; GetStrength() is BOTH with no arguments,
not GetIntellect's signature. Break must not disable this active spell.

Existing free-D/pre-XP restore gets one owned scaling modifier; existing
client bootstrap gets one reviewed path/class. No provider ability, timers,
points, stacks, casts or extra damage events. Health reads native cone/damage
inputs only. Native C++ raw query/cache and actual travel/targeting/damage
are owner-pending. Reference KV already inspected; its referenced Pathfinder
breathe_fire Lua file is absent from extracted corpus (ref_get verified), so
no working implementation or import is claimed. Current installed hash/build
revalidated unchanged; existing primary native-alias guidance still applies.

Q source implementation: pure native alias supplies exact target/dispel/animation/sound, cone/range/speed and native metadata, with authored10-rank damage/reduction/duration/cost/CD. Cast-range1000 now matches native exposed field rather than previous750 header; travel remains750, old width225 retired. Header/value cost-range data agree. No native ID shadow, ScriptFile/empty Q wrapper, additional provider or manual hit/debuff/feedback remains. Native talents metadata copied but no talent is granted.

One owned raw modifier supplies current paid-rank damage+STR1.2 on both contexts without IsAlive/Break suppression of an active spell or recursive special reads. Existing pre-XP free-D hook restores it idempotently, existing client bootstrap registers21 reviewed classes. Native Q remains sole cast/damage owner; no restoration timers/points/rank/cooldown writes. Default-off bounded Q trace reports query, not actual damage. Automatic Health is read-only. Native verified Q particles/bank remain precached for the retained native mechanism; copied Q class/link/debuff and two obsolete line/terrain mocks removed; W lifetime tests retained.

Four locale descriptions/summaries and twelve mirrors describe widening travel and native reduction key.115 affected checks/311 hero mocks PASS. Five focused contracts cover exact fields/tuning, ten live raw ranks and dynamic STR/both contexts/scoped guards, idempotent server restoration,21-class client registration/read-only Health, locales/precache. A fixture Lua declaration typo was corrected before passing. OWNER_RUNTIME PENDING: point/unit/directional/terrain/cast-range/travel geometry, actual damage/STR/cache/rank10, reduction duration/dispel/immune targets/block-reflect, death/recast/cleanup, native form/Wyrm AoE linkage after those source units, VFX/SFX/animation/cold-load and VConsole. Full restart is required later for KV/bootstrap. E/D/W/R source work remains; no DK completion.

Q full source boundary:0 failed check(s). The first full run exposed only a progression fixture allowlist missing the new DK Q lookup; it now accepts that known integration read while retaining all40 free-rank/respawn/point assertions. Targeted feedback checks and the repaired full suite pass. No owner engine session, remote push, deployment or publication. Existing contributor hunks remain outside this atomic source unit.

## E pre-mutation decision

TUNE / NATIVE+MINIMAL EXT. Exact native `dragon_knight_dragon_blood` supplies
the sole armor/regen intrinsic and native50% Elder Dragon Form multiplier.
Paid stable E remains a learnable ten-rank controller, not Innate/NOT_LEARNABLE.
Retain authored armor6..24, regen10..40+STR.05 via raw `armor`/`health_regen`
override, including zero before E training or during Break/on illusions.
Do not add a second stat modifier or native2+.5/hero-level bonus on top.
The native form multiplier key stays untouched. Current custom R does not yet
establish native form linkage: that remains a dependent R source/engine gate.

Existing owned scaling modifier and pre-XP/restore hook provide one hidden
rank1 exact native innate, activated only while paid E is learned. Ordinary
restore never refreshes its intrinsic. Paid rank-up alone queries the live
native intrinsic name and refreshes it on the server; no guessed modifier,
timer, extra points, copied form detection or counter reset. Installed API
`CDOTA_Buff:ForceRefresh` is BOTH, but this call is deliberately server-only.
GetStrength() and PassivesDisabled() are both-context. Raw override replaces
the query; actual C++ hero-level arithmetic/cache/live STR/HUD remain pending.
Zero override, not activation alone, is the guard against free innate stats.

Fresh VPK hash/build matches the installed snapshot above. WorldofDota2880603428
`scripts/vscripts/heroes/npc_dota_hero_dragon_knight_custom/dragon_knight_dragon_blood_custom.lua`
was read: caches stats in OnCreated/OnRefresh and checks custom form modifiers,
with extra talent poison. REFERENCE_ONLY, version/license unknown, no import.
Its cache is not proof of native C++ caching; its custom forms/procs are rejected.
[ModDota exposed-variable guidance](https://moddota.com/abilities/ability-keyvalues)
re-read; it does not certify native internal read paths. Retire only copied E
class/link/stats; retain dk_passive_sources while D still uses it. Four locales,
read-only Health, raw ten-rank/source/both-context and bounded rank-refresh
regressions accompany the source unit; all owner runtime gates stay pending.

E source implementation2026-10-04: paid controller isolated under
abilities/heroes/dragon_knight/e, ten authored curves preserved under native
stat keys; one existing both-context scaling class supplies raw overrides.
Copied armor/regen properties and class/link/tooltip aliases retired. Exact
native innate restored at rank1, hidden and training-activated; no default
stats through intended zero raw query at E0. No native ID shadow, form checks,
extra stat owner, scan, timer, points mutation or proc. Native multiplier50
untouched; current custom R linkage is not certified. Only server paid upgrade
refreshes live queried intrinsic; respawn/reconnect restore does not. Native
innate auto-level interaction and cached stat/live STR changes remain pending.

Read-only automatic Health now includes exact native rank/intrinsic presence,
armor/regen/form multiplier queries. These are not actual character stats.
Four-language descriptions/summaries and12mirrors regenerated; obsolete E
copymocks replaced by native raw/restore fixtures, D guard mocks preserved.
106 affected checks,311 hero mocks and full source suite pass with0 failures;
full native/integration set136 checks. No engine session or owner E acceptance.
Owner later restarts fully, compares E0/rank1/rank10 armor and regen, hero-level/
STR changes, Break/illusion, native R form50% after R migration, death/respawn/
reconnect/freeD+ordinarypoints and VConsole. Next source prerequisite: D Wyrm's
Wrath, followed by W/R native linkage. No DK kit completion, remote push or
publication; contributor work excluded from commit.

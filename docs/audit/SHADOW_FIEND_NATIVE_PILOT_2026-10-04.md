# Shadow Fiend native-first pilot — source investigation

Scope: only npc_dota_hero_nevermore, Mage. Owner selected this hero after
confirming Luna working. Native-first pilot source is now implemented locally.
SOURCE_REVIEW: COMPLETE FOR CURRENT CANDIDATE. OWNER ENGINE ACCEPTANCE: NOT TESTED.

## Authoritative source

[Installed ability snapshot](SHADOW_FIEND_NATIVE_SOURCE_2026-10-04.json) records
the full seven AbilityDefinitions from scripts/npc/heroes/npc_dota_hero_nevermore.txt.
Installed ClientVersion6943 / SourceRevision11069754 / Oct01 2026.
Raw archive resource SHA256:
67de2fc73b3bddf8c2b3bf7943aa1c9c10d3de5e8c9e219a6762cbe37dae3371.
The hero resource is unchanged from the previous 6941 dossier snapshot, despite
the newer installed build. The older dossier did not archive ability definitions;
this record fills that gap. KV does not expose C++ internal name lookups or
prove ten-rank support.

## Decision matrix before migration

These are evidence-backed architecture choices; implementation feasibility
gates below must pass before claiming that a native candidate is operational.

| Slot / stable ID | Current implementation | Native counterpart | Classification / architecture | Reason and gate |
| --- | --- | --- | --- | --- |
| Q / enfos_sf_shadowraze | Lua triple-radius damage; hardcoded INT multiplier; particles attached to targets | nevermore_shadowraze1/2/3 | PVE-CONVERT / NATIVE + MINIMAL EXTENSION candidate | Keep the existing one-Q triple-range intent. A small cast controller may delegate each blast to its native provider; do not silently reduce Q to one blast or add paid slots. Verify native OnSpellStart delegation, soul damage, stacking, resource ownership and linked providers first. |
| W / enfos_sf_necromastery | Custom souls, attack bonus, 1% spell amp per soul; Boss kill adds 10 versus ordinary kill 2 | nevermore_necromastery | TUNE / NATIVE + MINIMAL EXTENSION candidate | Native soul collection/loss should own the state. Its installed hidden innate has MaxLevel1; paid W must drive authored ten-rank values without duplicate native soul modifiers or extra skill points. Retain justified ENFOS spell amplification through a minimal extension, reading native state rather than duplicating collection. |
| E / enfos_sf_presence_of_the_dark_lord | Custom enemy armor aura/debuff | nevermore_dark_lord | TUNE / NATIVE | Independent native aura exposes armor/radius values. Use a stable-ID native alias with authored ten-rank tuning; native owns aura, Break and immunity. Ten-rank runtime remains pending. |
| R / enfos_sf_requiem_of_souls | Lua circle hit unrelated to souls; custom fear; Boss maxHP cap and shorter fear | nevermore_requiem | REPLACE / NATIVE + MINIMAL EXTENSION candidate | Native owns soul-generated lines, fear/resistance effects, death release and Scepter return/heal. Integration must supply authoritative native soul dependency. Remove SF-only Boss compensation; do not modify native Boss SF definitions. |
| D / enfos_sf_feast_of_souls | Passive kill healing/mana sustain | none; nevermore_frenzy is an active, not this passive | TUNE / CUSTOM | Preserve the fifth ENFOS passive/free D1. Frenzy cannot substitute without changing passive product intent. Isolate the small sustain module with valid hostile kill, Break, illusion and lifecycle guards. Its icon is not counterpart proof. |

## Confirmed source differences and risks

- Native Razes expose ranges200/450/700, radius250, LinkedAbility cycle,
  four-rank damage85/150/215/280 and stacking35/50/65/80. Installed Shard
  adds slowing and hero-hit cooldown interaction. ENFOS Q currently has no
  native stack/dependency lifecycle. Do not copy those mechanics into Lua.
- Native Necromastery is hidden/not-learnable/innate, one rank, with
  hero-level scaling +0.8 every six levels. It exposes max souls20,
  ordinary/hero kill gains1/4 and release fields. Remove unintended innate
  automatic scaling when applying paid ten-rank ENFOS values. Release timing
  and alias dependencies require actual Dota observations.
- Native Presence uses signed negative armor values and radius1200; the
  custom aura returns the negative of a positive armor_reduction value.
  Correct key names/signs when tuning; icon matching alone is insufficient.
- Native Requiem exposes three-rank damage80/120/160, mana150/175/200,
  cooldown120/110/100, line widths/speed, soul conversion, death release and
  Scepter heal/return damage. The current custom circle is a different mechanic.
- Generic Mage Scepter currently amplifies ultimate damage/reduces cooldown;
  generic Mage Shard adds spell amplification. Native R/Q upgrades must opt out
  of conflicting generic bonuses at SF-specific integration points, preserving
  all other heroes and ordinary Boss abilities.
- Existing shared respawn service and passive D grant stay intact. SF's native
  death release/soul loss is an ability lifecycle test, not a new respawn service.

## Implementation gates and Luna lessons

1. Verify native provider dispatch and linked/soul dependencies before replacing
   Q/W/R. Current Workshop API metadata exposes CDOTABaseAbility:OnSpellStart
   and GetIntrinsicModifierName server-side; this verifies API availability,
   not native execution, resource handling or ten-rank correctness.
2. Keep paid slots at ten ranks; hidden native dependency providers must not
   consume skill points or duplicate intrinsic modifiers. Native special-value
   overrides must avoid recursion and keep server/client availability explicit.
3. Put SF-only custom modules under abilities/heroes/nevermore. Reuse the Luna
   minimal shared modifier registration/client bootstrap pattern; no server
   managers in the client. Client globals and server live handles are separate.
4. Remove old SF ability/modifier implementations and unused precache only after
   replacements and remaining usages are identified. Keep stable IDs, four
   languages, bounded existing trace and unrelated contributor work.
5. Focused tests first; broader checks at final source delivery. Full restart
   after structural/bootstrap changes. Owner alone runs the engine. The addon
   game directory is a junction to repo game; no copy step is required.

## Research and pending validation

[Ability KV reference](https://moddota.com/abilities/ability-keyvalues) documents
native BaseClass inheritance. Current Workshop API metadata verified the two
provider methods above. Reference-only searches found Aghanim's Pathfinders
(Workshop2208582400) custom linked Raze and Necromastery files; these show a
custom approach, not proof of native delegate compatibility. No code imported,
no license assumption and no reference-game runtime certification claimed.

Historical pre-implementation next step: implement and test the native provider/progression integration and
independent native E alias, then isolate D and remove old SF duplicates. Provide
owner a short, supported probe/test checklist once the build is ready. Runtime
cases: Q all three ranges/overlap/stacking/costs, W collection/limits/loss/Break,
E armor/rank/Break, R souls/lines/death/Scepter, D valid kills/sustain, rank10,
death/respawn/reconnect, dense-wave performance, VFX/SFX and clean SF VConsole.
Do not request gameplay acceptance of an unimplemented migration.

## Native E source delivery checkpoint

Presence now uses native nevermore_dark_lord through the stable ENFOS ID.
Removed the custom ability class, aura/debuff classes and their two modifier
links; no wrapper/client registration is necessary for this fully native slot.
Authored armor magnitudes4/6/8/10/11/12/13/14/15/16 and radii900–1350 are
preserved with signed native presence_armor_reduction/presence_radius keys.
Native AoE scaling metadata, aura behavior, Break metadata, immunity behavior
and animation are retained. Old deprecated facet bonus fields remain zero.
Four-language descriptions now reference actual values; the previous Turkish
%armor_shred% placeholder did not resolve to any declared special value.

Three focused native-contract tests pass, independently tying behavior and
metadata to the installed snapshot, checking authored numeric preservation,
no duplicate aura code, no ordinary native-ID override and localization.
Existing354 hero-kit mocks pass; their obsolete Lua Presence test was removed,
not replaced by simulated certification of the C++ aura. Structural200-slot
inventory and40-hero dossier checks pass. Full checks deferred to final pilot
source delivery as requested. Q/W/R/D remain their prior implementation until
their integration is ready; this is not whole-hero acceptance.

E: **IMPLEMENTED BUT NOT ENGINE-VERIFIED**. Owner tests after the complete build:
rank1/10 enemy armor and radius, Break and recovery, death/respawn/reconnect,
multiple casters and native immunity interactions. No engine command, remote
push or publication performed.

## D isolation and valid-kill repair

Feast of Souls now lives under abilities/heroes/nevermore/d.lua with separate
modifier_links registration shared by server and client bootstraps. It retains
the stable ID, ten-rank healing/mana curves and the existing free D1 grant. No
Frenzy active, extra innate rank, timers or respawn service is added. The former
monolithic class and modifier link are removed.

Root cause: the old passive accepted friendly/illusion kills and a dead source,
and did not revalidate after healing. The isolated server event now rejects
invalid/untrained/dead/Broken/illusion sources, friendly/self/illusion/removed
victims and unrelated attackers. Healing callbacks that invalidate the source
stop the subsequent mana grant. The intrinsic is hidden and non-purgable;
values are read at the current rank, without a cached rank or custom stacks.
Default-off SF D trace records valid sustain events through the shared bound.
Current Workshop API confirms IsAlive server-only, GetTeamNumber both-context,
and IsIllusion both-context; client OnDeath returns before any source lookup.

Three sustain tests pass, covering current rank1/10, invalid sources/victims,
post-heal invalidation, idempotent linking and inert client events. Existing354
hero-kit mocks and12 Luna integration tests pass. The shared bootstrap test now
expects the three Luna classes plus the single SF passive class, still without
server services or gameplay context. No Luna gameplay implementation changed.
Runtime sustain/respawn/HUD acceptance remains PENDING OWNER TEST. Q/W/R native
provider integration is still outstanding; do not call the full hero migrated.

## Q/W/R final source delivery (2026-10-04)

Q uses one ENFOS cast and three exact native providers at ranges200/450/700.
Native damage stacking, soul bonus, immunity, VFX/SFX and Shard remain native;
the controller mirrors the paid cooldown and relays only native reductions.
W uses one native Necromastery intrinsic, never an extra Lua soul counter.
Raw-value overrides preserve max souls36–54, attack damage3–7.5 per soul,
2 souls/unit and4/hero; the existing1% amplification/soul reads the same native
stack count. W upgrade refreshes the same modifier without replacing its handle.
R replaces custom lines/fear/Boss logic with one exact native Requiem provider.
The visible cast delegates phase/interruption/cast. The provider alone owns
native death release and Scepter returning lines; it stays active when trained.
Installed Scepter subtracts30 seconds; the authored rank10 cooldown23 therefore
clamps to1 second. This explicit tuning remains subject to owner balance review.
No old Boss-specific soul yield/fear compensation survives this SF migration.

Ten paid ranks live in the stable ENFOS slots. Five hidden providers stay within
native C++ rank range1 (Requiem0 until trained); the scaler is installed before
the native soul intrinsic reads values. Exact provider reuse preserves souls.
The existing innate restoration invokes this bounded integration; no extra
respawn listener, global scan, timer, unit or thinker is created. Native soul
modifier ID was separately verified in installed
resource/localization/abilities_english.txt (DOTA_Tooltip_modifier_nevermore_necromastery).
Pure modifier registration is shared by server/client. Generic Mage upgrades
are skipped only for ENFOS SF, not the native Boss. Shard now belongs to Q.
Four-language descriptions and twelve generated mirrors match current values.

Removed obsolete monolithic Q/W/R ability classes, custom souls and fear. D
remains isolated custom kill sustain; E remains the native alias. Static audit
unreferenced-special candidates persist for table-routed values: focused tests
exercise rank1/10 raw lookups; no runtime certification is inferred from them.

Focused checks:117 pass across SF native/sustain/integration, shared Luna and
content contracts. Six native-integration mocks cover idempotence, native rank
bounds, untrained slots, triple cast/cooldown forwarding, phase interruption,
raw scaling, W refresh, client safety, upgrade ownership and read-only probe.
Existing353 hero-kit mocks previously passed after obsolete SF mocks removal.
Final full source checks are recorded below when complete.

**All five slots: IMPLEMENTED BUT NOT ENGINE-VERIFIED.** Native C++ may read
AbilityDamage through a getter that bypasses a special override. The read-only
probe prints both special query and GetAbilityDamage; owner must confirm actual
Requiem damage as well. Calling native phase/cast helpers and the native death
path also require real engine evidence. A mock passing does not resolve these.

### Owner test protocol

Structural KV/bootstrap changes require a full Dota restart. Launch Enfos and
select Shadow Fiend. First small test: train Q/W/R, kill a few wave units, cast Q
and R, then provide VConsole and whether animations, sounds, three Raze ranges
and soul display work. Run the read-only supported command:

```text
script_reload_code tools/sf_health
```

A client-only server=false response is expected diagnostic scope, not a broken
hero and not proof of server readiness. Do not suggest the unsupported script
command. No probe restores, trains, spawns, enables trace or edits state.

After initial success, record rank1/10 damage/radius/armor, costs/cooldowns and
HUD points; souls collection/limit/death loss; Break/recovery; one death release
and respawn restoration; manual R cancellation; Shard slowing/hero-hit cooldown
and Scepter return/heal; repeated casts and persistent cleanup; Boss native
immunity rules; reconnect without duplicate stacks/ranks/points; dense-wave
performance and clean SF errors. Owner sees/hears VFX/SFX. Complete only after
these required cases are confirmed or explicitly recorded as pending.

Owner-expanded rollout order and Necrophos addition are tracked in
[NATIVE_FIRST_HERO_ROLLOUT_GOAL_2026-10-04.md](NATIVE_FIRST_HERO_ROLLOUT_GOAL_2026-10-04.md).
Shadow Fiend acceptance is the next gate; no publication or remote push.

Final source validation: the full check runner passed all gates except two old mock fixtures lacking native-integration APIs. Those fixtures were repaired and rerun successfully (player feedback and all200 abilities/all219 modifiers at ranks1–10). The remaining npm-chain wave-pressure and installed-native Boss gates were run separately and pass. No gameplay edit was required to hide mock failures; no full-suite repeat. Diff whitespace check passes. Native runtime acceptance remains pending.

## Final resource/restore audit (2026-10-04)

Current installed build remains6943/revision11069754. Native SF sound bank is
now explicitly included in the existing startup soundfile loop, avoiding reliance
on selected-hero implicit loading for hidden providers. Existing native Raze and
Requiem particle precaches are retained: custom creation is removed, but native
providers still consume these resources. No new synchronous hero preload is
added; the prior setup-stall safeguard remains. Compiled VPK evidence:

| Resource | Bytes | SHA256 |
| --- | --- | --- |
| soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts_c | 3160 | 509e928f5f77b86ec090a1c9a4dc3feddee50a80179d0dfc92041ccad1cc8824 |
| particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf_c | 4122 | 5c576f6be06cc56a7f38876c3a25ac8b34898f3579018f4ebd90f39970eaa83f |
| particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf_c | 2441 | aa36b7e445ef77c241ad3ff15dd93e5b5437e3984024b782fd7904a7f16e07d7 |

This proves resource existence, not audible/visual or cold-start acceptance.
Shared respawn.lua remains unchanged and only sets the player death timer.
SF native death release/soul loss and existing restoration must be observed
after owner restart; no engine test was run by the agent. The remaining
completion blocker is owner runtime evidence, not a failing source gate.

## Owner runtime evidence and client getter repair (2026-10-04)

Owner VConsole attachment87152181-966c-41ff-abd9-9788bcc19f3d,
SHA256 d816a99aa035234f8ea79da2d79434de4dad08224471f403c93ba65239397725,
contains two server=true probes. At level6: visible ranks1/1/1/1/2,
zero remaining points, all five providers rank1, scaler/sustain/native soul
modifiers present, soul stacks36. At level9: ranks2/2/1/1/3, points0, native
providers still rank1 and soul stacks38. This establishes server installation
and observed rank-dependent native soul counts; not collection rate/death loss
or complete lifecycle acceptance. Q special query moves155 ->221.600006.

The log has10 Script Runtime Error reports of one defect: modifiers.lua:47
FindModifierByName is unavailable in the amplification getter's client context.
API metadata confirms FindModifierByName server-only; GetModifierStackCount
is both-context with (modifierName,caster). Replaced handle lookup with direct
native stack-count reading using hero as the native intrinsic caster. No client
services, timer, copied soul count, or zero-amplification workaround is added.
Client regression now makes modifier-handle lookup throw, and checks missing
native modifier, Break, illusions and untrained W.21 focused SF/Luna tests pass.
The prior permissive client fixture masked this API error; superseded by this
strict regression. Actual client retest remains PENDING OWNER TEST.

Requiem query/getter disagreement is confirmed:183 versus80 at level6, then
194.880004 versus80 at level9. Native tuning via AbilityDamage special override
does not change GetAbilityDamage in this engine. Actual outgoing-line damage
is still unmeasured; do not claim authored R damage or add speculative damage
compensation. Next evidence must establish actual native damage read path.

There are415 invalid-order26 reports (target unseen by unit team). They do not
identify the issuing ability/unit, so attribution to SF or solo play is not
established. No Boss AI change is made under the SF-only pilot. One Q order15
cooldown rejection also occurs; it does not alone establish a cast defect.
VFX/SFX, manual R damage, death/respawn, upgrades and rank10 still require owner
observations. No launch/console control, push or publication by the agent.

Owner follow-up confirms Q's three blasts and R's waves appeared, their sounds
were audible, and R reduced enemy health (answer: 'evet çalıştı'). Record
Q/R visual/audio and basic cast damage effect as OWNER CONFIRMED for this run.
This does not measure authored damage numbers, rank10, death release, Scepter,
Shard or post-fix client getter behavior. The client-safe repair was committed
after the submitted run; its engine acceptance remains pending a new run.

## Automatic selected-hero health snapshot (2026-10-04)

Owner requests replacing repeated manual console entry with automatic health
reports for whichever hero was selected. The existing npc_spawned handler now
invokes heroes/health.OnSpawn after normal hero configuration, free passive
restoration and initial skill-point initialization. Selected real roster heroes
emit once per hero entity; repeated spawn notifications/respawns do not duplicate
the report. The hero-local flag controls diagnostics only, never progression.
No extra listener, timer, global scan, native helper restoration or state mutation
is added. Client, illusions, ownerless, unselected and non-roster units return.

SF automatic reports retain SF_HEALTH paid/provider ranks, modifiers/souls and
both R damage queries. Other heroes emit HERO_HEALTH with their five authored
ranks and existing intrinsic handles. Server-only intrinsic/handle APIs run only
inside the server guard. Manual tools/sf_health remains a read-only refresh for
later rank/death snapshots, delegating to the same reporter.21 targeted shared
health/SF/Luna tests pass, including all roster heroes, once-only emission,
no gameplay writes and hook order after the five initial points. Real automatic
emission remains pending owner testing. A fresh match loads the new spawn hook.

Owner now defers live validation and authorizes continuing the ordered source
rollout while sleeping. Pending engine acceptance is preserved; do not call a
hero engine-complete or stop all source work for missing owner tests.

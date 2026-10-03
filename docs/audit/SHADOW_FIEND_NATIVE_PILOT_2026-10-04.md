# Shadow Fiend native-first pilot — source investigation

Scope: only npc_dota_hero_nevermore, Mage. Owner selected this hero after
confirming Luna working. No gameplay migration has shipped at this checkpoint.
SOURCE_REVIEW: IN PROGRESS. OWNER ENGINE ACCEPTANCE: NOT TESTED.

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

Next: implement and test the native provider/progression integration and
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

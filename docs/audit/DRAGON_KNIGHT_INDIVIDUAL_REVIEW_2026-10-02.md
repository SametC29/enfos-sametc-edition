# Dragon Knight individual review — 2026-10-02

## Q/W synchronous impact lifetime decision — 2026-10-02

Keep the existing PVE-CONVERT casts, damage formulas, target flags, immediate
timing and Boss cap. Breathe Fire and Dragon Tail both call damage then apply
modifiers without revalidating target/source/ability. A death/removal callback
can invalidate those handles. Q also traverses remaining recipients without
checking whether earlier damage removed/switched them. Reproduce these branches
with focused mock callbacks and guard post-damage follow-ups plus subsequent Q
recipients. Invalid/null/dead source and null target must be rejected before
cast effects; a removed/dead/now-friendly recipient gets no new debuff.
Shared damage helper already checks recipients before ApplyDamage but does not
own caller continuation; fix these two Dragon Knight call sites only.
Installed native definitions and current ModDota API evidence from preceding
review apply; no new API/asset, external import, numerical or immunity change.
Actual death/kill event timing, spell-block/reflect and VConsole remain owner
runtime tests; mocks certify only these control-flow branches.

Result: pre-change mock failed on a removed recipient still reaching modifier
application. Q/W now revalidate owner/ability/recipient after damage; Q also
validates each remaining recipient. Q preserves an impact burst on a valid
hostile corpse but gives it no new debuff. Tests cover removed/dead/friendly
recipient, removed/dead owner, deleted ability and removed later Q target.
All317 hero mocks and full checks pass with zero failures. Actual engine callback
ordering, presentation and native immunity/reflect remain owner PENDING.

## Form cleanup restoration decision — 2026-10-02

PVE-CONVERT unchanged. OnCreated saves model/projectile but not attack capability;
OnDestroy always sets melee. That does not restore a pre-existing ranged state.
Installed MCP verifies server GetAttackCapability/SetAttackCapability signatures;
the native form remains no-target/non-dispellable/ACT_INVALID. Save the actual
pre-cast attack capability once in OnCreated and restore it on removal; keep a
melee fallback only for absent getter in legacy test contexts. Null/removed
parent on creation/removal must produce no handle calls. No refresh re-snapshot
that would overwrite the original baseline. Regression must fail before repair
on an originally ranged owner, then cover melee/ranged restoration and removed
parent safely. Model/projectile behavior and statistics unchanged; simultaneous
external transformation ownership and actual death/expiry remain engine tests.

Result: pre-change test failed when an originally ranged owner was forced to
melee; a separate pre-change run also reached a removed parent's setter.
OnCreated now captures GetAttackCapability before the ranged swap; OnDestroy
restores that snapshot and ignores removed/null parents. No OnRefresh snapshot
was introduced. The regression explicitly defines distinct mock capabilities
and exercises both cases (no empty ipairs over undefined constants); old model/
projectile restoration tests remain passing. Full checks zero failures,316
hero behavior mocks passing. Actual death/expiry, Refresher refresh, cosmetics,
external transformations and reconnect/VConsole remain OWNER_RUNTIME PENDING.

## Passive source-eligibility decision — 2026-10-02

Installed build remains6943 / SourceRevision11069754, verified from steam.inf.
Keep both existing PVE-CONVERT passives: Dragon Blood sustain and Wyrm Vigor's
authored defensive fifth slot. Their property callbacks check Break/illusion,
but not owner/source validity or learned rank. Dragon Blood still adds5% Strength
regen after a removed ability makes the shared value helper return zero; rank0
can also expose KV bonuses. Add a Dragon Knight-local source guard reused by
these two modifiers, rejecting missing/null owner or ability and unlearned rank,
while preserving Break/illusion exclusions. No all-hero helper rewrite, rank
curve, numerical balance, death persistence or tooltip change. MCP GetLevel is
available both realms; ModDota's declaration documents it. A mock must reproduce
the old rank0/missing-source leak before repair, then cover both source owners
and live rank restoration. Actual rank0 intrinsic installation, engine rank-up
stat recalculation, free fifth rank and respawn remain owner tests.

Result: targeted pre-change rank0 regression failed on residual stats. Both
intrinsic owners now share a hero-local live learned source guard. Missing/null
ability or parent returns zero for armor/regen/resistance/Strength; learned rank
restores the existing numbers. Dragon Blood's5% Strength regeneration no longer
survives source removal. Existing Break/illusion tests remain passing; all315
hero mocks and full checks pass with zero failures. Engine stat recalculation,
free starting passive rank, removal/relearning/death/reconnect remain PENDING.

## Sol re-review: Elder Dragon splash decision

Re-read the installed hero definition via MCP vpk_read(maxChars60000), including
the full native Elder Dragon Form definition (no partial-file inference). Native
R retains ranged splash, non-dispellable transformation and ACT_INVALID. Keep
the existing PVE-CONVERT authored form/splash rather than a new mechanic. The
custom OnAttackLanded rejects a primary already dead after the attack, dropping
all splash on lethal hits. It also lacks friendly-primary and source/recipient
lifetime guards around synchronous splash-damage callbacks. Fix eligibility
for a valid hostile primary whether alive or dead, while damage/slow recipients
must be living enemies. Reject deleted/inactive ability, null/dead owner and
nonpositive attack damage; revalidate handles before/after each damage callback.
Do not change immunity flags, radius, percentage, slow duration or form model.
MCP and https://docs.moddota.com/lua_server/declaration establish the callback
and handle APIs, not actual engine event ordering. Use targeted pre-change
mocks; owner lethal splash, visual/audio and collision acceptance stays pending.

Result: pre-change regression failed on a dead primary producing no splash.
The repaired callback accepts a valid hostile dead primary, rejects nil events,
friendly primaries, nonpositive damage and inactive/removed ability sources,
and checks each enemy and owner/ability again after damage. Removed/dead enemy
receives no follow-up effect/slow; removal of owner/ability stops later impacts.
Two focused regressions cover lethal attack and invalid-context cases, plus
synchronous recipient/source/ability/next-recipient removal. All314 hero mocks
and full repository checks pass (zero failures). No balance values or native
immunity/purge/model policy changed. Actual OnAttackLanded ordering, kill splash,
slow/visual/audio, high-density fights and VConsole remain OWNER_RUNTIME PENDING.

## Scope of this pass

This pass repaired user-visible localization and tooltip accuracy. It is not a full runtime certification of Dragon Knight's kit.

## Verified findings and changes

- Compared the five project abilities with their stable IDs, generated inventory, native installed hero KV snapshot, and current project KV/Lua definitions.
- English, Russian, and Simplified Chinese were missing Dragon Knight's project ability tooltip tokens. The localization generator filled those gaps with Turkish source text, so the localized client showed Turkish skill descriptions. Added translated names and full descriptions for Q/W/E/R and the Enfos passive in all three locales, including the compact tooltip aliases generated from those descriptions.
- Replaced the generic Tank Scepter/Shard wording for Dragon Knight with explicit upgrade labels in English, Russian, and Simplified Chinese. Behavior remains the shared Tank Scepter/Shard behavior; no upgrade mechanics changed.
- Dragon Blood Lua adds `Strength * 0.05` to its constant health regeneration in addition to the KV regeneration. Updated the skill and passive-modifier descriptions in all four locales to disclose the extra 5% Strength-based regeneration.
- Fixed the localization generator's modifier-owner lookup so it resolves Dragon Blood's `{{bonus_armor}}` and `{{bonus_hp_regen}}` placeholders for the passive modifier tooltip as well as the ability tooltip.
- Added a content-contract regression test for all five localized skill descriptions and the Dragon Blood Strength scaling.
- The fifth Enfos passive `enfos_dk_wyrm_vigor` was using the Dragon Blood icon. The exact installed VPK contains `panorama/images/spellicons/dragon_knight_wyrms_wrath_png.vtex_c`, which matches its documented native counterpart (`dragon_knight_wyrms_wrath`, installed Ability3). Changed its `AbilityTextureName` and added a regression asserting the distinct icon mapping. The other four assigned icon files were also found in the installed VPK.
- Q/W/R emit the installed bank's `Hero_DragonKnight.BreathFire`, `Hero_DragonKnight.DragonTail.Target`, and `Hero_DragonKnight.ElderDragonForm` events. The native hero KV names `soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts`, and the recorded sound-event scan confirms all three event definitions. The addon's shared explicit sound-bank precache list omitted `dragon_knight`; added it using the same established path rule as the other heroes and added a regression. Event reachability is statically verified; audible playback and timing remain an engine test.
- Native `dragon_knight_elder_dragon_form` explicitly sets `AbilityCastAnimation` to `ACT_INVALID`; the custom R slot had no explicit override. Because the Enfos ability occupies slot 4 while the native ability is slot 6, relying on the engine's slot-based cast animation default could produce a cast gesture before the scripted model swap. Set `ACT_INVALID` explicitly to retain the native transform presentation and added a KV regression. Confirm actual gesture/model transition in-game.
- Elder Dragon Form sets its ranged attack projectile to `dragon_knight_elder_dragon_fire.vpcf`. The particle exists in the installed VPK but was missing from the addon precache list; the analogous Terrorblade form projectile is explicitly precached. Added the missing Dragon Knight particle precache and a regression. Projectile rendering remains an engine test.
- All six distinct particle paths referenced by Dragon Knight's Lua kit were checked against the installed VPK; the missing ranged projectile precache is now included. The regression inventories the six script paths and requires each in the match precache routine.
- The Elder Dragon Form modifier previously restored model and attack capability on expiry but left its temporary ranged projectile name assigned. Confirmed server API getters/setters are available in the installed VScript API catalog; it now saves/restores the previous projectile along with the model. The Dragon Knight form mock regression checks both apply and cleanup. Actual model/projectile transitions remain owner runtime validation.
- Dragon Tail's custom KV allows piercing spell immunity while native Ability2 does not. The project version applies physical damage and caps Boss stun duration. This may be a deliberate PvE conversion, but there is no explicit design record; documented it as unresolved and left runtime/design acceptance pending rather than silently normalizing the native difference.

## Verification

- `node tools/localization.mjs` — PASS; all four language outputs regenerated across resource and Panorama targets.
- `node tools/checks.mjs` — PASS; 0 failed checks. This includes mock Lua execution and static content checks, not a Dota engine playtest.
- `node tools/hero_reference_docs.mjs --check` — PASS.
- `node --test tools/tests/content_contracts.test.mjs` — PASS; all 91 tests, including icon, sound-bank, transformation-animation, and projectile-precache regressions.
- `git diff --check` — PASS.
- Dota runtime, VConsole, icon presentation, particles, animation, and audio were not tested in this pass. Owner live test is pending.

## Remaining individual audit

All five skills remain pending for full cast/targeting, rank-up UI, gameplay balance, boss effects, modifiers and dispels, visual/audio presentation, precache, cleanup, reconnect, and in-engine validation. Icon path existence is verified, but actual HUD presentation is not. The native reference snapshot is build 6941 / source revision 11041083 from 2026-09-29; re-verify against the current installed build before drawing new engine-behavior conclusions.

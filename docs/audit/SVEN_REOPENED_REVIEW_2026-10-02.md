# Sven full-kit reopened review — 2026-10-02

Owner reported Sven broken in local Workshop Tools testing and requested the entire
hero be rechecked against the existing goal, not a single inferred symptom.
This reopens the prior source review; it does not revoke or manufacture historical
runtime evidence. **Current engine acceptance is PENDING.**

## Evidence and scope

- Installed `steam.inf`: ClientVersion/ServerVersion 6943, SourceRevision 11069754.
- Re-read full native `scripts/npc/heroes/npc_dota_hero_sven.txt` through Workshop MCP.
  Native Storm Hammer/Great Cleave/Warcry/God's Strength identifiers, target rules,
  animations, sound events and AbilityValues agree with the recorded counterparts.
- Read hero KV, all five ability KV/Lua classes, linked modifiers, bootstrap,
  precache, roster, match levels, innates and Aghanim manager. All five still use
  modern AbilityValues, ten ranks and the intended gates. No talent/profile system
  was restored. Match level 50, initial level 6/five spendable points and free fifth
  rank remain owned by existing match/innate managers.
- Local addon directory is a junction to this repository's `game` directory.
  There is no separate stale copied Lua directory at that local path. A running
  match still needs a full restart to load changed scripts/resources.
- Git diff from published source `90ac68d` to the starting review tree contains
  no Sven kit changes. The owner's suspected model-switch origin is **unproven**;
  changing an assistant model is not itself evidence of a gameplay regression.
- Read-only live MCP console buffer was empty. Disk console.log last modified
  2026-10-02 23:25:15 contains TreeShop_OnStartTouch/EndTouch errors, but no matching
  Sven traces or pve_kits traceback in the inspected filter. Those map-shop errors
  are separate findings; absence of a Sven traceback is not a gameplay pass.
- Reference-only comparison: Workshop 1571786267,
  `scripts/vscripts/heroes/hero_sven/sven_warcry_lua/sven_warcry_lua.lua` read again.
  Its cast head binding matches the independently decoded native cast evidence.
  Version/license unresolved; no external code imported.
- [Current cleave API declaration](https://docs.moddota.com/lua_server/declaration)
  confirms eight arguments. No guessed API signature or manual cone replacement.
- [Modifier tooltip documentation](https://moddota.com/abilities/modifier-properties-in-tooltips)
  supports live modifier properties and TOOLTIP2. W's remaining barrier uses its
  replicated stack count, not a server-only client variable.

## Full-kit decisions and repairs

| Slot | Classification retained | Source review / repair | Engine gate |
| --- | --- | --- | --- |
| Q Storm Hammer | TUNE | Tracking travel, magical AoE, boss stun cap, ten ranks, KV cast animation/sound preserved. Stop after damage invalidates source; never stun a killed/removed victim. Snapshot trace name before damage; reject primary that became friendly in flight. Bind native impact CP1/CP3 to hit position. | Dodge/loss, absorb/reflect timing, magic/debuff immunity, resistance, Scepter landing, rank1/10 VFX/audio pending. |
| W Warcry | PVE-CONVERT | Existing armor/speed/barrier/taunt/runner exclusion/boss25% retained. Replace unconfigured legacy persistent root with decoded native armor child and glow, overhead CP1 bound to each recipient. Modifier owns cleanup; refresh creates no extra particle. Refresh taunt orders to current caster; invalid/dead/friendly sources cannot start taunt. Add actual taunt name/icon and current armor/speed/remaining-barrier tooltip in four locales. | Actual shield visibility/height, purge/death, multi-caster overwrite, barrier mitigation and Shard reflection pending. |
| E Great Cleave | TUNE | Verified native DoCleaveAttack still owns damage/VFX. Ten-rank curves, half-width API convention, lethal-primary dispatch, normal/R particles preserved. No dispatch from removed/unlearned sources, invalid parent, Break or illusions. | Native collision/geometry, armor/immunity, buildings/wards and lethal hits in real packs pending. |
| R God's Strength | TUNE | Existing base damage/STR/defense and1.5s physical pulses preserved, non-dispellable primary modifier. Remove undocumented +150% fallback from removed ability. Invalid interval stops, invalid/dead sources destroy modifier, source removal during damage stops traversal. Pulse impact uses decoded CP1/CP3 binding, still max six visual victims. | Transform appearance, cast/expiry, refreshed STR stats, boss behavior and Scepter ally duration/removal/Blessing pending. |
| Fifth Unbreakable | PVE-CONVERT | Authored tank sustain remains distinct from native innate/facet. No bonuses from unlearned/removed source, invalid parent, Break or illusions. Existing live rank KV reads and strict below40% Shard regen threshold preserved. | Free rank presentation, rank refresh, maxHP recalculation, death/reconnect and client stats pending. |

### Native particle evidence

Source2Viewer-CLI 19.2 decoded the installed native files into an external temporary
review directory; no native assets were copied into the addon.

- `sven_warcry_buff.vpcf`: root CP1.x remaps0..1000 to a radius multiplier0..32.
  Its `sven_warcry_armor_buff_model.vpcf` child and glow both position-lock and
  initialize at CP1. The old GetEffectName supplied neither contract. A guessed
  numeric CP1 radius would move the armor child to a bogus world location.
- Use the independently decoded armor child directly, with CP1 entity-bound to
  the recipient's `PATTACH_OVERHEAD_FOLLOW` (current MCP enum7), one AddParticle
  owner. Armor model SHA256:
  `64706e1b84c46061f0332f76b2e59a9f4a68f65015365335e1f693680a795205`.
- `sven_storm_bolt_projectile_explosion.vpcf` root and flash/trail initializers
  use CP3; wave child PositionLock uses CP1. Both were unset in Q and R pulses.
  A Sven-only helper sets CP0/1/3 to impact position and releases the finite index.
- God's Strength cast root was decoded: finite burst, own CP-position setup and
  children. No arbitrary head/weapon binding was added based on unrelated ambient
  particles; sustained transformation/cosmetic composition is an engine gate.
- Warcry head cast burst, cleave resources and God's Strength resources keep their
  existing precache owners. New armor-child resource has explicit W precache.
  Names/paths and declarations alone do not prove visible or audible playback.

## Verification

Baseline:318 mock hero tests passed before edits. Added seven meaningful cases:
removed Q victim; inactive passive sources; W CP1/ownership/refresh; multi-caster
taunt refresh; removed-R fallback/interval; removed caster during R pulse; Q/R
impact CP coordinates away from world origin. The removed-Q, removed-R and impact
coordinate tests were each observed failing before their corresponding repairs.
After repairs: **325 mock hero tests pass**. Full project checks are recorded after
the final validation below. Tests do not render particles, simulate native cleave
collision or certify current engine event/point behavior.

Final validation: `npm run check` passed with0 failures (project contracts,
behavior suites, localization mirrors, progression,48 normal-wave pressure checks,
12 native boss preparation/activation mocks). `git diff --check` passed. Generated
localization diff is limited to W's live modifier text and the missing taunt labels.
An unrelated untracked `game/panorama_debugger.cfg` appeared during review; it was
left untouched and excluded from this work unit.

No Dota launch, NVIDIA changes, Workshop upload or remote publication in this work
unit. Owner retains runtime testing. See [owner checklist](SVEN_RUNTIME_CHECKLIST.md).

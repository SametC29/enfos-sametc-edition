# Sven individual review — in progress

This is a focused extension of `docs/heroes/sven/ABILITIES.md`, preserving its historical ClientVersion 6941 live evidence. Current source comparison: installed ClientVersion **6942**, SourceRevision **11055158**. Current native hero/source hash is in `HERO_NATIVE_PRESENTATION_2026-10-01.json`. No Dota launch or current-build engine acceptance.

## Sources and reproduction

- Read hero/shared AGENTS, full Sven ability dossier, hero development guidelines, technical reference and research/runtime protocol.
- Read production Sven section in `abilities/pve_kits.lua`, all five ability KV blocks, `heroes/aghanim_manager.lua`, Sven localization entries and native precache ownership in `addon_game_mode.lua`.
- Read installed `scripts/npc/heroes/npc_dota_hero_sven.txt` AbilityDefinitions directly from VPK. Native Storm Bolt, Warcry, Great Cleave and God's Strength resolve. Native God's Strength declares `SpellDispellableType=SPELL_DISPELLABLE_NO`.
- Decoded native Sven particles with ValveResourceFormat CLI 19.2; no engine launch. Warcry buff root reads CP1.x for radius scaling; its armor-model child positions at CP1. Current modifier supplies only `GetEffectName`/origin attachment: required native binding is not established. Do not invent a CP1 value or call VFX accepted.
- Read decoded native `game_sounds_sven.vsndevts`: `Hero_Sven.StormBolt`, `StormBoltImpact`, `WarCry`, `GodsStrength` all declared. Event presence does not establish audibility or cold-start precache.
- Current MCP `DoCleaveAttack` signature confirms start/end parameters are radii. Existing custom cone uses half of its tooltip widths; retain that deliberate contract until geometry/native conversion is evaluated. Native `Great Cleave` declares immunity piercing; current custom enemy helper defaults to no special flags. This difference needs explicit gameplay review, not a guessed blanket helper change.
- [ModDota API](https://docs.moddota.com/lua_server/declaration) and [ability KV](https://moddota.com/abilities/ability-keyvalues) reviewed. MCP reference search found Boss Survival Adventure's Sven Lua kit; discovery is reference-only, no source/version/license verified and no code imported.

## Per-slot conclusions so far

| Slot | Classification | Reviewed behavior and outstanding concerns |
| --- | --- | --- |
| Q `bulwark_shield_slam` | TUNE | Tracking projectile speed1000, dodgeable; lost/dead target cancels explosion; magical AoE, boss stun cap0.6; Scepter during R teleports on impact. Spell absorb is checked at cast rather than impact; full native timing/reflect policy and target team change require follow-up. Cast/impact event IDs and icon verified; CP fit, cosmetic models and engine target-loss remain pending. |
| W `bulwark_challenge` | PVE-CONVERT | Native Warcry identity plus ally barrier and enemy taunt; runners excluded, boss duration25%. Barrier = KV + Sven STR×1.5; Shard adds25% maxHP and reflects40% physical damage actually taken. Barrier refresh replenishes; stack reports remaining barrier; taunt expiry preserves another forced target. Fixed reflection guard and overhead recipient below. Native cast burst is absent; current persistent particle's CP bindings are unresolved. Multi-caster refresh/ownership and client tooltip remain engine-pending. |
| E `bulwark_iron_guard` | TUNE | Attack-landed widening cone; physical damage based on original attack damage, primary excluded, honors Break and rejects Sven illusions; at most six effects per attack. **Proven lethal-hit bug fixed** below. Native immunity/geometry comparison, ward/building primary filtering and decoded particle orientation remain under review. |
| R `bulwark_fortress` | TUNE | Native God's Strength identity, Enfos STR/defense and1.5s physical pulses; bounded six visual targets per pulse. Scepter adds5s and50% status resistance, applies900-radius ally buff50% base damage/+10 armor for1.8s. Fixed non-dispellable identity. Tooltip Scepter phrase “50% of Sven's bonus attack damage” conflicts with modifier's50% of recipient base damage; localization repair remains outstanding. Ally modifier purge/expiry, intrinsic refresh and sustained engine VFX pending. |
| Fifth `bulwark_unbreakable` | PVE-CONVERT | Separate Enfos durability passive, not native Vanquisher/facet. Ten ranks of HP regen/maxHP/status resistance; all three honor Break, Shard doubles regen strictly below40%. No second cleave. Free rank and level50 point allocation come from match-level/innate systems; engine rank HUD and respawn remain pending. |

All five have explicit ten-rank values. Q/W/E/fifth gates1/interval1; R gate5/interval5. No talent gate or account progression is reintroduced. Sven skips generic Scepter ultimate amplification/cooldown and generic tank-Shard HP/reflection; its specific kit owns the documented upgrades. Native item stats are separate.

## Proven fixes in this work unit

1. **Lethal attack lost cleave:** E rejected primary targets already dead during `OnAttackLanded`. A lethal primary hit must still splash living secondaries. Removed the alive requirement while preserving null, team, Break and illusion checks. Regression with a dead primary and a live in-cone secondary fails against the before-edit production snapshot and passes after repair.
2. **Warcry reflected onto friendly/dead attackers:** W checked only self/null/reflection flags. It now requires a living hostile attacker. No numerical reflection buff; existing40% physical-only policy preserved.
3. **Ally barrier shown above Sven:** every ally modifier creation sent its overhead barrier number to caster. It now sends to the modifier recipient.
4. **God's Strength dispel mismatch:** custom R modifier inherited default purgability, conflicting with installed native non-dispellable ultimate. Added explicit `IsPurgable=false`; ally buff remains separately reviewed.

Mock regressions now206 passing. Added lethal-hit/Break and friendly/dead-reflection cases to existing behavioral tests, plus recipient/non-dispellability regression. `npm run check` passed with0 failed checks, including all200 abilities/223 modifiers through ranks1–10 and native Boss preparation mocks. These tests do not certify engine event order or visuals/audio.

## Required next steps before closing this hero

- Verify native Warcry cast and persistent particle bindings using exact asset/control-point behavior; owner must confirm appearance and sound. Current W visuals are **not accepted**.
- Resolve cleave native geometry/immunity and primary-type behavior, avoiding unrelated hero/helper rewrites.
- Correct Scepter recipient-base-damage text in all four locales and generated mirrors; audit actual modifier-name localization rather than stale legacy modifier keys.
- Check repeated casts, multiple Svens, death/purge, item removal/Blessing, passive rank refresh and no duplicated state after reconnect.
- Owner test: rank1/maxrank casts, lethal E attack in a pack and Break, W on Sven+ally with Shard, R attempted dispel/Scepter ally stats, normal/immune/boss targets; record current-build VConsole plus visible/audio feedback.

Status: **IN PROGRESS**, not whole-hero DONE and not ENGINE_PASS.

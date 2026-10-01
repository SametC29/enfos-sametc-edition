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

## Cast presentation and upgrade localization follow-up

2026-10-01: read Boss Survival Adventure Workshop1571786267 `scripts/vscripts/heroes/hero_sven/sven_warcry_lua/sven_warcry_lua.lua` through `workshop_read` after `ref_get` failed. Reference-only: version/license unresolved, no code imported. Its head-bound cast behavior was cross-checked independently against current native particles/model/API. Decoded native `sven_spell_warcry_mouth.vpcf` pre-emission operator uses `m_nHeadLocation=2`; decoded native Sven model declares `attach_head`. [Particle attachment guide](https://moddota.com/scripting/particle-attachment) documents entity attachment control points.

W now creates one native `sven_spell_warcry.vpcf` cast root on Sven, binds CP2 to his `attach_head`, and releases the finite-lived particle index. Server-only cast path; explicit ability precache covers the cast particle and Sven sound bank. KV already owns WarCry cast sound, so no duplicate sound or gesture was added. Existing modifier-owned persistent buff remains, with no extra persistent particle. Its CP1 root/child interpretation still needs native engine evidence and owner visual testing; the cast fix does **not** close persistent VFX acceptance.

Corrected Scepter description in EN/TR/RU/zh-CN to recipient's own base damage, matching the ally modifier; added the missing actual `modifier_bulwark_fortress_scepter_ally` name/description in all four languages. Regenerated all twelve resource/Panorama localization mirrors. Numerical upgrades unchanged.

Added cast ownership/control-point/release and precache regression. **207 mock hero behavior tests pass**. Full checks pass after refreshing the structural inventory; the first run correctly detected stale inventory, not a gameplay failure. Particle existence checks include the new cast root. Audio, animation, particle composition/expiry and cosmetic head binding remain owner engine tests.

Status: **IN PROGRESS**, not whole-hero DONE and not ENGINE_PASS. Scepter text/ally modifier labels and absent W cast burst are repaired at code level; remaining geometry/targeting/persistent VFX checks above are still open.

## Native cleave dispatch follow-up

2026-10-01: retained **TUNE** classification and ten-rank KV curves, but replaced Sven E's handwritten radius search/cone/physical ApplyDamage and up-to-six target-attached particle copies with the verified server `DoCleaveAttack(attacker,target,ability,damage,startRadius,endRadius,distance,effectName)` API. Current MCP declaration and [ModDota declaration](https://docs.moddota.com/lua_server/declaration) agree on this eight-argument signature. Older six-argument online dumps are not used. Native cleave now owns collision, secondary damage and particle CP/lifetime. No external implementation imported.

The explicit Enfos full-width tooltip convention is preserved: half of each KV width is passed as radius. Original attack damage × cleave percentage, distance curve, Break/illusion/null/friendly guard, lethal primary dispatch and normal/R-specific particle choice are preserved. Native geometry may differ from the former custom primary-centered cone; it requires owner comparison. No copied cone simulator is presented as proof of engine behavior. Per-attack trace spam removed together with custom traversal.

Updated regression checks exact native-call ownership,100 damage/75 start radius/135 end radius/300 distance for the fixture, normal versus God's Strength particle, lethal target dispatch and blocked/illusion/friendly/null rejection. Global rank smoke includes an explicitly dispatch-only native API mock; it does not simulate cleave damage or certify engine filtering. **207 hero behavior tests and full project checks pass.**

This completes the first individual **source/code review** of Sven's five slots and upgrade paths, with proven code faults repaired. **Runtime acceptance remains PENDING**, including W persistent CP1 visual composition, Q absorb/reflect timing/team-change cases, native cleave geometry/immunity/primary unit types, R ally buff expiry/purge/item removal, max-rank HUD, multiple casters/death/reconnect, cosmetics and cold-start sounds. These are engine verification questions, not recorded passes. Future owner evidence can reopen focused repairs without blocking source review of the next hero.

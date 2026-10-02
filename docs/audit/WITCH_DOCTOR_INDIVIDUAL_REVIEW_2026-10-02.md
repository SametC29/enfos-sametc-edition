# Witch Doctor individual review — 2026-10-02

Status: IN PROGRESS / ENGINE PENDING. Order 15 of 40. This record does not certify the complete kit.

## Sources and classifications before implementation

Installed Dota build 6943 / client 11069754: direct VPK scripts/npc/heroes/npc_dota_hero_witch_doctor.txt, freshly extracted AbilityDefinitions. Current production KV and pve_kits.lua, hero dossier and shared reference were read. ModDota Ability KeyValues (https://moddota.com/abilities/ability-keyvalues), accessed 2026-10-02, supplements the installed source; it does not expose native C++ behavior. MCP reference search found Pathfinders 2208582400 Witch Doctor KV; no external code/assets imported.

| Ability | Classification | Native/current comparison and review disposition |
| --- | --- | --- |
| Paralyzing Cask Q | PVE-CONVERT | Native projectile speed 1200, delay 0.1, radius 575, escalating bounce damage; custom uses a bounded instant unique-target chain, flat rank damage + 0.4 INT, radius 500 and shortened Boss stun. Preserve current authored balance during lifetime repair. Projectile/presentation parity remains under review. |
| Voodoo Restoration W | PVE-CONVERT | Native radius 650 and 0.33-second interval; custom friendly heal radius 500, 1-second mana/heal tick, rank healing + 0.3 INT. Existing toggle/audio cleanup fixes require renewed lifetime and resource review. |
| Maledict E | PVE-CONVERT | Preserve damage-over-time/health-loss burst identity with explicit custom Boss percentage and per-window health baseline. Deleted tick recipient handling and persistent effect ownership require inspection. |
| Death Ward R | PVE-CONVERT | Native current damage type PURE, hero targeting and native Scepter bounce/lifesteal; custom physical random hero/basic attacks from a native stationary ward during eight-second channel. Explicit adaptation, not native equivalence; projectile callback lifetime and cleanup under review. |
| Gris-Gris fifth passive | PVE-CONVERT | Custom ten-rank periodic match-local reliable gold; native one-rank innate has death-loss/accumulation behavior unavailable in exposed C++. No account progression. Dead-parent payment policy and tooltip/rank lifecycle require review. |
| Voodoo Switcheroo Shard | PVE-CONVERT | Native duration 2.5 and attack-speed reduction; custom two-second hero-origin ward projectiles and invulnerable/disarmed buff. Transformation presentation and unique upgrade acceptance pending. |

## Proven Q lifetime defect and planned focused repair

Current Q deals damage before calling is_boss, AddNewModifier and GetAbsOrigin on its victim. A synchronous damage/death callback can delete that entity, producing a stale access and terminating the remaining chain. Capture each valid victim's position and Boss stun calculation before damage; apply stun only to a surviving valid victim; select subsequent valid hostile unvisited recipients around the captured position. Stop if caster or ability is deleted. Do not change damage, radius, hit cap, timings or Boss stun balance.

Regression will delete two consecutive victims during ApplyDamage and reject stale position/modifier calls. A third living victim must still take the same damage and receive its normal stun; a fourth must remain outside the hit cap. Existing Boss shortened-stun regression remains relevant. Engine visual/audio and actual death callbacks remain owner testing pending.

## Remaining acceptance gates

Q particle travel/CPs/lifetime, impact and animation; W mana/toggle/recipient lifecycle; E DPS/burst/refreshed modifier/particle ownership; R and Shard projectile impact/deletion/ward removal; passive rank/Break/death payout; every icon, four-language tooltip, precache, Shard/Scepter truth and reconnect. No next-hero transition until this individual source review closes. Owner alone runs Dota and supplies VConsole evidence. Local commits only.

## Q focused repair result

The new regression first failed with 'Deleted Cask victim must not receive a stun' against the prior implementation. After the captured-position/living-recipient repair, full npm run check passed: 261 hero behavior regressions; all 200 abilities and 223 owned modifier sweeps across ranks 1–10; zero failed checks. Damage remains 120 in this 100 + 0.4 × 50 INT scenario; three unique hits, living third stun and fourth-target exclusion are asserted. Existing Boss stun test still passes. Caster/ability deletion stops the chain; no deleted victim position is read. Particle helper skips invalid owners but Q travel/impact presentation is not certified by this repair. ENGINE/VConsole/visual/audio acceptance remains pending owner evening testing.

## R/Shard shared impact lifetime diagnosis before repair

Both Death Ward and Switcheroo call wd_ward_attack_impact. It emits ProjectileImpact on the victim after ApplyDamage and dereferences the ability before checking whether it was deleted. A lethal callback deleting the victim therefore reaches an invalid entity; a removed Shard ability can leave an invalid pending projectile callback. Planned repair: reject an invalid ability before GetCaster; emit the existing native impact sound while the hostile living target is valid, then deal the same configured physical damage. Keep ordinary dead-but-valid caster projectiles valid; no damage or travel balance change.

Fresh installed build 6943 / revision 11069754 soundevents/game_sounds_heroes/game_sounds_witchdoctor.vsndevts_c decoded with Source2Viewer 19.2 on 2026-10-02: Hero_WitchDoctor_Ward.Attack and Hero_WitchDoctor_Ward.ProjectileImpact are present. MCP CEntityInstance.IsNull documents deletion of the underlying C++ entity. These verify identifiers/lifetime semantics, not actual audio playback. ModDota Lua API (https://docs.moddota.com/lua_server/docs) was also consulted; it does not establish native C++ mechanics.

R/Shard result: new lethal-impact regression failed before the repair ('Audio must precede lethal damage'), then passed for both abilities. Deleted-ability callbacks return without GetCaster or damage. Dead-but-valid caster projectiles retain their existing behavior. Full npm run check: 263 hero behavior regressions, 200/200 ability sweeps, zero failures. Native impact playback/engine removal behavior remains PENDING owner Dota/VConsole.

## E periodic damage lifetime diagnosis before repair

Maledict OnIntervalThink deals its DPS before reading victim GetHealth/is_boss on a burst tick. A lethal DPS callback deleting the parent therefore performs a stale health access. It also evaluates special values on an already removed ability. Planned focused fix: destroy the modifier and return for invalid/dead parents or invalid ability/caster; revalidate after DPS before computing any health-loss burst. Preserve the configured per-window baseline, DPS, interval and normal/Boss burst percentages. Regression reproduces deletion at a burst boundary and verifies no second burst or stale health read. Reapplication/particle/purge acceptance remains separately pending.

E focused result: the new test first reproduced 'Deleted Maledict victim health must not be read' at the four-second burst boundary. Guarding invalid parent/ability/caster before DPS and revalidating after it now terminates safely with exactly one 30-magic DPS hit and no post-lethal burst. Removed-ability regression also passes; the existing nonlethal two-window burst regression remains green. Full npm run check: 265 hero behavior regressions, all 200 ability sweeps, zero failed checks. Per-window baseline/Boss percentages are unchanged; visuals, refresh policy, actual modifier destruction and Dota/VConsole remain pending.

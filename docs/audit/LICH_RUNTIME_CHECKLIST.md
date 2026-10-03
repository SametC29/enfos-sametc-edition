# Lich — owner runtime checklist

Status: **NOT RUN**. Native comparison build6943 / SourceRevision11069754.
Current source work is incomplete; this checklist does not certify the hero.
Use [the ordinary-target follow-up](LICH_ORDINARY_TARGETS_POLICY_2026-10-03.md)
alongside the historical individual review. Its Q/R Boss-cap and D source-Break
repairs supersede the old ledger's contrary historical descriptions.

## Record the actual local version

The owner starts a fresh local match. Record date, installed Dota build, current
Git commit, uncommitted changes, ranks and Shard/Scepter/Blessing state.
E/KV/tests/main-ledger/dossier currently contain contributor changes not included
in the isolated review commits. A commit ID alone does not reproduce that E.
An older Workshop package is a separate version and cannot validate local fixes.

For trace capture use `enfos_hero_trace 1`; restore `enfos_hero_trace 0` afterwards.
This is the existing default-off diagnostic convar, capped at100 lines across
all heroes per game-clock second. Missing lines during saturation are inconclusive.
Never equate requested damage with observed health loss. Actual trace numbers
come from ApplyDamage returns; unavailable results are explicitly labelled.

## Basic checks (each NOT TESTED)

| ID | Owner action / observation | Trace evidence to retain |
| --- | --- | --- |
| L01 | Cold start/select Lich; five slots, free passive rank, level6 start/five spendable points; no talent/profile UI. Verify ordinary points/ranks up to level50 separately. | Import/modifier/resource warnings, actual rank/point HUD |
| Q01 | Rank1 and10 Q on a live enemy with nearby enemies. Primary and other recipients take their distinct formulas; each living victim is slowed. One target-centered nova/audio; ranked ring follows impact position. | Q cast, nova_particle, damage_result, primary, impact_summary, slow_created |
| Q02 | Lethal primary still produces splash at captured origin. Allied target cannot consume hostile spell absorption or create feedback. Absorbed hostile cast does not damage/slow. | Q cancellation or normal summary; no Lua traceback |
| W01 | W on self and moving ally: one visible shield, one cast sound,600-radius damage pulses once/sec for configured6s. Compare physical damage with/without shield. | W cast, shield_created, pulse requested/actual totals |
| W02 | Refresh shield: no duplicate ring/pulse interval. Recipient changes allegiance/death or ability removal: protection/pulses stop. Caster death alone retains existing finite shield; test this independently from removed caster. | W shield_refreshed/removed or pulse_cancelled |
| E01 | Normal enemy channel: control, actual mana removed/gained, pull, animation, caster/recipient effect positions and audio. Empty-mana enemy still receives control/pull. | E channel_start, control_created, control_tick, channel_finish/control_removed |
| E02 | Absorb, interruption, recipient/caster death and stale recast: only the matching channel/recipient ends; no mana credit without actual removal. | E cast_cancelled, control_cancel, channel_detach; requested/removed/gained mana |
| R01 | Orb visibly travels caster→target and then between different enemies. Initial1050/next850 speeds; appropriate hero/creep impact sound; ordinary damage/slow on each living recipient. | R cast, projectile_launch/impact, damage_result, slow_created |
| R02 | Primary absorb prevents launch. Lethal impact can continue from captured origin. Concurrent chains preserve independent history; no duplicate target within a chain; hit limit or no eligible next target ends it. | R chain_end reason, projectile IDs/hit indices, no traceback |
| D01 | Ally inside/outside ranked radius: flat8 armor, mana4 at rank1 and9.4 at rank10. Live rank change updates bonuses. Enemy/illusion gets no bonus. | D source/recipient lifecycle plus HUD before/after values |
| D02 | Break the source Lich: aura benefits stop. Break only an allied recipient: external benefits remain. Restore source/remove ability/respawn and observe no orphan/duplicate bonuses. | D lifecycle plus actual source/recipient state; live Break has no dedicated transition trace yet |

E ordinary Boss duration/pull is now implemented in source: both use the full
ranked duration and the existing40-unit pull beyond100 distance. Owner parity
verification remains NOT TESTED. Gaze CPs/audio remain open. Earlier35% duration
and no-pull observations describe superseded source, not intended policy.

## Advanced checks (each NOT TESTED)

- Q/R normal and Boss recipients with equivalent relevant properties use ordinary
  formulas; differences in armor/resistance/status resistance are recorded.
- Basic dispel removes allied Q/R slow; enemy dispel removes W buff and its
  particle/pulses. Observe actual strong dispel, debuff immunity and status
  resistance independently; source IsPurgable declarations are not these tests.
- Switch immunity during R travel; loss/removal/movement of source/recipients;
  two Lich casters, same/different-target refresh and ownership after expiry.
- D death/linger, overlapping auras, source illusions and allegiance changes.
- W pulses: observe half-second movement slow on surviving normal/Boss units,
  recovery between one-second pulses, basic dispel and no application after a
  lethal pulse. Verify status resistance, debuff immunity and the slow icon/text.
- E basic dispel must remove hypnosis and end only its matching channel; strong
  dispel, recast and another active ability are separate owner tests. The authored
  action lock is explicitly not classified as a stun for purge purposes.
- EN/TR/RU/zh-CN skill/modifier names/icons/live values. D must show its radius,
  allied recipients and source Break; actual decimal/signed formatting is pending.
- Current Shard is generic healing25%, Scepter ultimate40% amplification/25%
  cooldown. Unique Lich upgrades remain unimplemented; buying the items or
  seeing these generic descriptions must not certify the unique-upgrade gate.
- Reconnect preserves ranks/cooldowns/effects without duplication; dense-wave
  performance, repeated casts and all10 ranks remain separate observations.

## Evidence and acceptance

For every ID record PASS/FAIL/NOT TESTED, rank, expected/observed behavior,
VConsole excerpt and visual/audio observation. A screenshot cannot prove sound,
duration, cleanup or correct damage. Preserve first failure and reproduction
steps rather than retrying until it looks right. No traceback is only one check.
Basic gameplay, advanced cases, trace evidence, visuals/audio and overall engine
acceptance are separate gates. Do not advance any gate based on this checklist's
existence or the automatic regression result.

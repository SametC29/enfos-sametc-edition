# HUD / Sven repair candidate — V1.0.2, 2026-09-28

## Scope and evidence

Reviewed Antigravity commits cb77f96, ebc2563 and 0f06145 and the desktop handoff
report. Their structural/mock checks do not certify engine gameplay. Only Sven's
mechanics received this focused review; the remaining roster is not certified.
The user's reported W/talent/scoreboard issues drove the fixes below.

## Changes

- Scoreboard uses the engine FlyoutScoreboard visibility event and the SKOR button.
  Item images use Abilities.GetAbilityName, not a nonexistent Entities method.
  Authoritative damage, unique enemy kills and positive earned gold synchronize
  every 0.5 seconds. Gold comes from the ModifyGold filter; purchases and sale
  refunds do not count as income. Summon ownership resolution is bounded.
- Top portrait bar shows Life, wave, elapsed match time and next-wave timer.
  Spellbringer/next-wave controls use actual minimap position, with side fallback.
  The invalid Spellbringer XML root ID was removed so its current source compiles.
  Innate icons use a DOTAAbilityImage in the native innate slot with tooltips.
- Six-tier Evolution preview is available before the first choice, with two
  skill-specific alternatives at levels 4/7/10/13/16/19. The native talent button
  opens this tree; a separate badge remains available if Valve changes that panel.
  These are custom Evolution choices, not native level 10/15/20/25 talents.
  Replacement/reconnect restores milestone state; the server validates choices.
- Sven Q is an instant point strike, with Strength/armor scaling read from KV.
  Its descriptions no longer promise a travelling projectile.
- W applies Warcry once to Sven, refreshes barrier, exposes remaining barrier
  through modifier stack count, and issues an attack order for taunted units.
  Shard gives an additional 25% caster max-HP barrier and reflects 40% of received
  physical damage with reflection-loop protection.
- E's passive armor/block/reflection respects Break; physical attack block does
  not also block spells. Cleave is circular around the target, as described.
- R's Scepter ally modifier is linked. Refresh restarts its periodic effect.
  Scepter's real extra duration, status resistance, ally damage/armor and Q
  teleport during R are described. Generic role-based Aghanim bonuses and their
  misleading icons are suppressed for Sven, avoiding duplicate upgrades.
- Innate no longer adds a second, undocumented cleave or an obsolete active cast.
  Shard doubles regeneration below 40% HP. Sven ability/buff/upgrade descriptions
  are updated in EN/TR/RU/zh-CN and generated localization mirrors.

## Verification

- Full tools/checks.mjs: **0 failures**, including 48 hero-kit regression cases,
  behavioral scoreboard tests and Panorama JS visibility/tree tests.
- 13 Panorama XML resources compiled successfully using the installed Valve
  compiler; wave_hud recompiled after the final innate-image change.
- All 10 protected map/theme files retain their recorded hashes. No map compiled.
- Resource inventory: 216 icons and 151 literal resource references found in
  installed Valve assets. This proves resource availability, not visual quality.
- No reachable VConsole channel; no new engine playtest was performed. Engine
  Flyout event contract was checked against the installed Valve sample script.
- The contract inventory still has 64 ability sections with unreferenced-field
  review candidates across the roster; this is not a claim of 64 gameplay bugs.

## User acceptance still required

Start a fresh match on enfos and select Sven. Test W on nearby enemies: armor,
barrier depletion/refresh, taunt and visual/audio feedback. Preview the tree at
level 2, choose at level 4, and confirm the server applies the chosen skill value.
Check Q/E/R, passive tooltip, Shard and Scepter, including ally aura and Break.
Open scoreboard with the configured score key and SKOR; confirm damage/kills/gold
advance and purchases/sales do not inflate earned gold. Flip minimap side and
verify Spellbringer follows it. Reconnect must retain choices and scoreboard data.

## Local follow-up after the supplied screenshots

- Removed the extra bottom-left Evolution badge. Both the native StatBranch and
  LevelUpTab open the custom tree and clear Valve's blank built-in popup handler.
- The tree renderer accepts both Panorama's zero-based JS arrays and keyed
  net-table objects, fixing the screenshot where only tier numbers appeared.
- Disabled Valve's duplicate native top scoreboard; the custom SKOR flyout remains
  available from Tab and the in-game SKOR button.
- Sven W now starts Sven's cast gesture, shows an overhead barrier number, and
  explicitly plays its stock Warcry particle on affected allies. Its persistent
  buff particle, sound, armor/speed, shield and taunt remain active.
- Recompiled the Evolution and custom scoreboard Panorama XML successfully. The
  user asked to hold publication; these follow-up edits are local only and are not
  in the Workshop package.

Git remains local only by user instruction. Further Workshop publication requires
the user's new explicit request; delivery and engine playtesting are separate checks.

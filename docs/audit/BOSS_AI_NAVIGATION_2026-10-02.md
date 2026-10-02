# Boss AI and Life Core navigation — 2026-10-02

Result: PARTIAL — IMPLEMENTED BUT NOT ENGINE-VERIFIED. Native-kit assembly,
resource existence and mock order tests pass. Actual Boss navigation, combat,
VFX, audible SFX and animation remain PENDING.

## Problem and evidence

Owner reports random skill use and Bosses failing to advance toward Life Core.
Scheduled Bosses are ownerless neutral hero entities created by WaveManager;
they receive native QWER and Valve build items, not Valve match-bot control.
BossThinker and CreepAI_Think issue orders to the same entity.

Confirmed source defects: no-target skills with NONE/FRIENDLY target-team
metadata could cast with no defender; no-target items had no combat gate.
Friendly targeting returned self on an empty lane. Cast searches accepted
targets up to 96 units outside cast range. After a cast consumed attack-move,
the route thinker could wait four seconds for stuck recovery before resuming.
Installed Axe Call explicitly declares DONT_RESUME_MOVEMENT; Freezing Field
declares DONT_RESUME_ATTACK. These are source evidence, not an observed complete
reproduction of the owner's engine symptom.

## Research and native bot feasibility

Installed Dota: ClientVersion/ServerVersion 6943, SourceRevision 11069754,
VersionDate Oct 01 2026. Re-read all twelve mapped hero files under
`scripts/npc/heroes/` in `game/dota/pak01_dir.vpk`; their hashes match the
existing NATIVE_BOSS_KIT_SNAPSHOT records. The scheduled twelve native models
exist in the installed archive (verify_boss_resources).

MCP API lookup confirms GameRules.AddBotPlayerWithEntityScript with five
arguments, including a final boolean, creates a bot player with an entity
script. Installed Valve `npx_2019/scripts/vscripts/spawner.lua:69` demonstrates
it. Its `ai/glimmer_cape/ai_sniper.lua` implements explicit INTRO/IDLE/ATTACK
states, movement, target selection and conditional Satanic use. Read as
reference only; no external code or assets imported.

Internet research: [Valve bot scripting entry](https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting)
was inaccessible through web fetch (403). The bot author's
[OpenHyperAI API reference](https://github.com/forest0xia/dota2bot-OpenHyperAI/blob/main/docs/BOT_API_REFERENCE.md)
describes team/mode/action thinking; no library imported or compatibility
assumed. [Valve tracker #13919](https://github.com/ValveSoftware/Dota2-Gameplay/issues/13919)
reports local-addon versus Workshop-ID bot-thinking differences. This is a
historical report, not proof that build 6943 still has that defect.

Conclusion: a native bot-player creation path exists, but it does not establish
that default match bots understand this custom route/Core objective, neutral
team, one-life Boss lifecycle or repeated waves. Do not switch production
spawns to bot players without proving player-slot cleanup, roster separation,
two-team routing and local/Workshop behavior. This remains a possible future
pilot, not a completed native-AI conversion.

## Focused correction

Native QWER classification: KEEP for all twelve Boss kits. No skill, model,
sound, animation, rank, native effect or player-kit implementation changed.
The controller now requires combat for self/friendly and no-target actives;
local damage spells use verified native radius keys (Axe Call radius,
Juggernaut blade_fury_radius, CM radius, Luna Eclipse radius, Luna Orbit
movement_radius + hit_radius). Other combat buffs use the existing 750-unit
lane acquisition window. Hostile targeted casts preserve their native range
within the existing bounded 1400-unit search; invisible/invulnerable defenders
are rejected. Toggle-off outside combat remains supported.

Each issued Boss cast marks a route handoff. Once cast phase/channel ends and
combat acquisition finds no target, CreepAI resumes the existing waypoint once.
The callback, route index, Boss-only spawn and -5 Life leak contract are retained.
No new manager, per-frame scan or custom VFX/SFX added.

## Tests and remaining acceptance

- Pre-change production mock fails on empty-lane NONE-team no-target cast.
- New boss_combat_navigation test covers empty skills/items/friendly self casts,
  native radius even with zero cursor radius, exact cast range, long-range
  target preservation, invisibility/invulnerability rejection, uninterrupted
  cast/channel, immediate one-shot route resumption and ordinary-creep isolation.
- Native Boss pipeline/resource gate tests cover twelve identities, rewards,
  -5 Life, spawn failure cleanup, respawn separation and asynchronous loading.
  Resource fixture updated for existing normal-wave prewarming and isolated
  stale callbacks; production resource loading is unchanged.
- Full npm run check: zero failed checks. Twelve installed-data Boss kit
  preparations and toggle activation/deactivation audit pass. Twelve models
  FILE_VERIFIED. These results are not engine presentation certification.

Local Tools launch on enfos succeeded and VConsole connected. DebugSDK was
temporarily attached, loaded and removed. Runtime query reached hero selection
(state 4), before a player hero/Boss test was available. The test process exited
with normal application shutdown before Boss reproduction. Startup/reload logs
include missing legacy map scripts (wood_system, teleport, courier_safe_zone),
TreeShop_OnEndTouch nil errors and native localization/resource warnings.
Do not claim an error-free VConsole or Boss ENGINE_PASS from this session.

Required engine pilots: Axe (short radius/taunt), Crystal Maiden (channel) and
Dragon Knight (buff/transformation); then all twelve. On both defending teams:
observe empty-lane advancement through every center waypoint, meaningful casts
in range, visible native effect and animation, audible sound, uninterrupted
channels, post-combat advancement and exactly one -5 Core leak. Inspect new
Lua/resource errors, cast order failures, target loss, pause and multiplayer.
The generic controller still lacks hero-specific heal/execute/combination
decisions; this correction is not a claim of full Valve bot intelligence.

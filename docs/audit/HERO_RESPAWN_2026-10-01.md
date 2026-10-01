# Player respawn and publication policy — 2026-10-01

Owner revokes previous standing deployment authority: no live/Workshop upload
without a new explicit request, even after successful tests. No upload performed.

Player normal death timer: 30 seconds at starting level 6, linear progression
to 50 seconds at level 50, rounded to the nearest second and clamped to 30–50.
Examples: level 6 = 30, level 17 = 35, level 28 = 40, level 39 = 45, level 50 = 50.
This supersedes the old provisional 5–20 second seed.

Previously there was no custom player death timer; native Dota calculated it.
The existing level-50/start-level-6 configuration is reused. A server death
listener sets SetTimeUntilRespawn on the selected real player hero only. Neutral
Bosses, illusions, secondary heroes/clones and native Aegis/Reincarnation are
excluded. Existing player spawn positions, resurrection abilities, buyback and
Boss respawn-disabled flags are retained. No per-frame scans or duplicate timers.

Current installed VScript API confirms SetTimeUntilRespawn, IsReincarnating and
WillReincarnate. Internet API reference:
https://docs.moddota.com/lua_server/
Global SetFixedRespawnTime would affect all players equally and was not chosen
for the requested level-based rule. No third-party code/assets were imported.

Automated regression checks the curve, all levels through 100, both teams,
listener idempotence, selected-hero ownership and exclusions. Runtime pending:
owner Dota tests for levels 6/28/50, HUD countdown, both teams, buyback and Aegis/
Wraith King revival. No engine PASS is inferred from mocks; Dota was not launched.

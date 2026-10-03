# Player match logs for hero runtime review

Owner request2026-10-04: use logs from real players to reduce repetitive manual
hero testing. Existing structured Log utility writes to console, not a remote
collector or persistent disk service. Automatic selected-hero health snapshots
are now emitted from the authoritative server after initialization. A local
host/dedicated-server capture or a player-shared VConsole export is still needed.
No access to remote player machines, HTTP upload, account profile or telemetry
backend has been introduced. Distribution/publication remains separately gated.

Use the existing server log first for authoritative abilities/ranks/modifiers,
Lua failures and match events. Client VConsole is useful for unavailable client
APIs, HUD and resource errors. Preserve which side produced the evidence.
Players can voluntarily provide logs; owner host capture settings and retention
location still need selection before claiming automated file collection.

The offline analyzer accepts a shared log and writes a structured local report:

```text
node tools/hero_runtime_log_report.mjs <log-path> <report-json-path>
```

It extracts selected heroes, paid/helper ranks, modifier presence/stacks, native
SF damage queries, deduplicated Script Runtime Error messages and invalid-order
counts. It does not retain chat, Steam/account messages or the raw log; absolute
user-directory segments in error messages are redacted. The output contains
match-local player slots and source hash, not persistent player profiles.
Each report explicitly says NOT_ESTABLISHED_BY_LOG. An absence of errors never
certifies gameplay/VFX/SFX/rank10/upgrades/death/reconnect coverage. Skill-use
trace remains separately bounded/default-off; automatic initial snapshots do
not establish that the player trained or used every skill.

Two parser regression tests pass. The existing owner SF log produces two
server snapshots and10 repeated instances of one Lua error plus415 rejected
unseen-target orders. These reproduce the manually inspected findings in
SHADOW_FIEND_OWNER_LOG_REPORT_2026-10-04.json. No automatic code fixing or native
Boss attribution follows from order counts alone.

Owner correction2026-10-04: automatic external collection is cancelled. Owner
will save console logs and share them manually. The loopback collector/sender
pilot was reverted; retain only automatic console Health reporting and offline
analysis of supplied files. No future endpoint/retention decision is pending
for the current scope.

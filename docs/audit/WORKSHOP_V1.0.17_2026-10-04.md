# V1.0.17 Rally crash quarantine and opening balance publication

Owner explicitly requested GitHub upload and live publication after the crash
repair. Committed publication source: `b3a70c4`. Existing isolated detached
release worktree was clean before checkout. Concurrent Lich edits and local
debugger configuration were excluded.

Includes wave 37 native Rally quarantine (two matching crash dumps), normal
creature HP bonus 50%, reduced opening XP requirements and the existing
multiplayer team-selection fix. Known Future Reinforcements movement issue
remains disclosed. Two-client waves 35–40 runtime acceptance is PENDING.

Full `npm run check` passed both in the shared workspace and in the isolated
committed release tree (zero failures). Package verification passed: 210 files,
ten protected map files and PNG preview. VPK size 24,658,621 bytes; SHA-256
`acc4ff1e620b62b839823950cb6c0d443d5148ff896eac6592a99d6ac364dabd`.

Existing Steam desktop session upload via `tools/workshop_upload.ps1 -Apply
-MakePublic` returned Content update SUCCESS, Workshop ID 3809160125,
public requested True, legal agreement action False. Official
GetPublishedFileDetails returned result 1, V1.0.17 title, visibility 0,
time_updated 1791125050, file_size 24658809 and
hcontent_file 8284292459656473120.

Clean anonymous SteamCMD download into `release/verify-v1.0.17` succeeded but
returned V1.0.16 publish_data and its prior VPK hash
`6807a8a6c03c2db60a78a5d344d5ed9a31887da5552615c4d3ba0b7c4f6b76ec`.
Steam accepted the public update; delivery of V1.0.17 bytes remains PENDING.
Do not claim subscriber installation or a successful live crash playtest from
metadata alone. No specific moderation/CDN cause or delivery ETA is certified.

Primary `release/workshop` refreshed from the isolated verified candidate.
Previous V1.0.16 candidate preserved under
`release/rollback/V1.0.16-pre-v1.0.17/workshop`. Raw API/download evidence remains
local in ignored release directories. No engine was launched by the agent.

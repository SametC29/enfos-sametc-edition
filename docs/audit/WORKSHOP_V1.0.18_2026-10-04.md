# V1.0.18 Future Reinforcements formation publication

Owner explicitly requested live publication on 2026-10-04 after the focused
formation fix. Publication source: `fe51242` (implementation `ab35807`). The
release used a clean isolated detached worktree; concurrent Lich contributor
changes were excluded.

The package retains V1.0.17's wave 37 Rally crash quarantine, +50% normal-creep
health, faster opening XP curve and multiplayer setup fix. Future Reinforcements
now request a centered five-point ring (radius 128; neighboring requested spawn
points are over 150 units apart) rather than random points in a 120×120 square.
The all-60-wave regression checks center and pairwise distances. That test and
the full `npm run check` passed. Engine movement acceptance remains pending.

Package verification passed: 210 archived files, ten protected map files and
PNG preview. VPK size 24,659,203 bytes; SHA-256
`3489b223f4ff107a82520121e7c96c914190b39fb6fa9bf184ab576c02aadab0`.

Upload via `tools/workshop_upload.ps1 -Apply -MakePublic` returned Content update
SUCCESS for Workshop ID 3809160125, public requested True, legal agreement action
False. Official GetPublishedFileDetails returned result 1, V1.0.18 title,
visibility 0, time_updated 1791131386, file_size 24659391 and
hcontent_file 672579153448106340.

Two clean anonymous SteamCMD downloads (including one repeated download after
the item metadata showed V1.0.18) returned the V1.0.17 archive: 24,658,809 bytes
including publish_data; its VPK SHA-256 is
`acc4ff1e620b62b839823950cb6c0d443d5148ff896eac6592a99d6ac364dabd`, exactly
the recorded V1.0.17 package hash. Steam accepted and publicly lists V1.0.18,
but delivery of its bytes is still PENDING. Do not tell subscribers that the
formation change has reached their client, and do not infer a CDN/moderation
cause or ETA. No Dota runtime was launched by the agent.

Primary `release/workshop` now contains the V1.0.18 candidate. The prior
V1.0.17 candidate is retained in
`release/rollback/V1.0.17-pre-v1.0.18/workshop`; local manifests, API details,
and SteamCMD downloads are ignored release artifacts.

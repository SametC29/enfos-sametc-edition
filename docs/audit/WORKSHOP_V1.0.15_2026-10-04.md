# Workshop V1.0.15 publication — 2026-10-04

Owner explicitly requested GitHub and live publication, then repeated that the game should be published in its current state after supplying the failing reinforcement runtime capture. This checkpoint does not authorize future publications.

- Committed source/release tooling: `e282ec3`, pushed to `origin/codex/project-hardening`.
- Full `npm run check` on the isolated committed checkout: PASS. Source/runtime UI mirrors synchronized and two Russian Anti-Mage names restored from existing translated aliases. Panorama force compile: 35 compiled, zero failed. No map recompile or game launch.
- Concurrent uncommitted Lich work and debugger configuration excluded and preserved.
- Independent VPK verification: 210 files, ten protected map files and PNG preview. Production manifest excludes the Tools-only `enfos_test` arena; verifier compares the same normalized manifest.
- Candidate VPK: 24,657,909 bytes, SHA256 `dbeca248d7fdc0216a9980611f28f57c6c0c83425878dfea7005c1da662972a7`.
- Steamworks desktop-session content update: SUCCESS for existing item `3809160125`; public requested, no legal agreement action. No credentials read.
- Public Steam API: result 1, V1.0.15 title, visibility 0, banned 0, update time `1791111826`, content handle `8336815386785119033`, combined payload 24,658,097 bytes.
- Clean anonymous SteamCMD download: OK, but returned V1.0.14 (`publish_data.txt`), manifest `928663488362746773`, VPK 24,339,687 bytes and SHA256 `616f99ee041661c6f8fa4cab63b981f90f7ec18dc06c386c85d26784a5a4a922`. Upload acceptance and public metadata confirmed; delivery of V1.0.15 bytes to players remains PENDING. Cause not established; do not repeatedly upload as a workaround.
- Known issue disclosed in the public changenote: actual Future Reinforcements units remain stationary in owner Tools tests despite received and dispatched commands. Fresh comparison units move. The latest bridge is runtime FAIL; no movement-fix certification. Hero gameplay, VFX/audio and balance acceptance remain pending.
- Previous local V1.0.13 package preserved at `release/rollback/V1.0.13-pre-v1.0.15/`. Candidate and public API receipt copied to ignored `release/workshop/`. Isolated source/package/download evidence retained at `%TEMP%/enfos-release-v1.0.15`; primary working-tree package verification will reject ongoing contributor differences.

Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125

# Workshop V1.0.9 publication — 2026-10-01

Owner explicitly requested Workshop publication following the talent/Boss
follow-up and delivery without waiting for owner gameplay tests. This overrides
the older wait-for-playtest publication rule for this upload. It does not grant
ENGINE_PASS or change the no-Dota-control instruction.

- Updated the existing public item
  [3809160125](https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125).
- Title: Enfos Team Survival - SametC Edition V1.0.9.
- Includes committed talent parent/drawer/hotkey suppression, one-life native
  Boss respawn/death cleanup, player/Boss spawn separation and modifier links
  from `4ef983a`, plus the current working addon and preceding hero fixes.
  As with preceding releases, this is a working-tree payload, not HEAD alone.
  Contributor work was preserved and not committed wholesale.
- Existing V1.0.8 package/metadata preserved in
  `release/rollback/V1.0.8-pre-v1.0.9-talent-boss` before package preparation.
- Current worktree check: zero failures; focused follow-up tests: 11 PASS;
  isolated staged tree: 42 Lua behavior checks and native-kit audit PASS.
  Engine tests remain pending. No Dota or map was launched/recompiled.
- Package verification: 99 archived files, 10 protected map files and preview
  checked with the independent VPK reader. All existing Panorama source files
  have current compiled counterparts; the native HUD controller was rebuilt.
- Archive SHA256:
  `73841203eb538dbcdc99401dfa2f9faa4ef1b3962b348ef5f3eeaf7248f2a8fa`.
- Archive size 23403330 bytes; archive + publish_data = 23403517 bytes.
- SteamCMD cached-account upload returned `Committing update...Success`.
  Upload log reports manifest `3528614255205768168` at 20:25 Istanbul.
- Official public Steam API reports result 1, visibility 0, title V1.0.9,
  time_updated 1790875560 and hcontent_file `3528614255205768168`, with
  file_size 23403517, matching the upload manifest and combined payload size.
- Public anonymous download still returned V1.0.7, archive SHA256
  `ef8b2ad67634c339dd3e5f4dc1fe17a67b848292e41b1359b9b593a994f43011`.
  Upload acceptance/public metadata are confirmed; download propagation and
  owner gameplay acceptance remain pending. Do not claim fresh download equality.

Local upload/public API/package records are under `release/workshop`; account
credentials and runtime auth cache are not source-controlled.
Official publishing procedure reference:
https://partner.steamgames.com/doc/features/workshop/implementation

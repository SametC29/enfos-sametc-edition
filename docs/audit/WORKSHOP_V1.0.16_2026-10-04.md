# V1.0.16 multiplayer setup hotfix publication

Owner explicitly requested live publication after the guest team selection fix. Publication source: 12d8507, containing fix 7b53076. Existing isolated release worktree was clean and checked out at that commit; concurrent Lich edits and local debugger configuration were excluded.

Full npm run check passed on the isolated committed tree. Package verification passed: 210 archived files, ten protected map files, PNG preview. Candidate VPK: 24,658,105 bytes, SHA-256 6807a8a6c03c2db60a78a5d344d5ed9a31887da5552615c4d3ba0b7c4f6b76ec. No gameplay or map changes beyond the committed setup fix were introduced for publication.

Existing Steam desktop session upload through tools/workshop_upload.ps1 -Apply -MakePublic returned Content update SUCCESS, Workshop ID 3809160125, public requested True, legal agreement action False. Official GetPublishedFileDetails returned result 1, title V1.0.16, visibility 0, time_updated 1791113171, file_size 24658293 and hcontent_file 5578829403783886507.

Clean anonymous SteamCMD download into release/verify-v1.0.16 succeeded but delivered V1.0.15 publish_data and VPK hash dbeca248d7fdc0216a9980611f28f57c6c0c83425878dfea7005c1da662972a7. Therefore Steam accepted the public V1.0.16 update, but delivery of the fixed bytes is PENDING. Do not claim subscribers have the new fix until download matches the candidate. No speculative cause for Steam's old-content delivery is certified.

The primary release/workshop package was refreshed from the isolated verified candidate. Prior V1.0.15 package preserved under release/rollback/V1.0.15-pre-v1.0.16/workshop. Two-player Dota runtime acceptance remains pending on V1.0.16. Known reinforcement movement issue remains disclosed in release notes.

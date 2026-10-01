# Workshop V1.0.6 publication — 2026-10-01

Owner explicitly requested publication of the current working snapshot and postponement of the all-hero goal. Goal status is PAUSED; no hero audit work continued during publication. Prior no-publication instruction was superseded for this upload only. No Dota launch/control or remote Git push.

- Existing public Workshop item: [3809160125](https://steamcommunity.com/sharedfiles/filedetails/?id=3809160125).
- Title: Enfos Team Survival - SametC Edition V1.0.6.
- Publication includes current working game files, including previously uncommitted contributor changes. It is not represented by HEAD alone. Release manifest records98 payload file hashes; archive SHA256: c3f86bb71ab37d4e6d5758c1a3caaf3a4c0f6ff0db3de70d3323a9585eaab946.
- Previous V1.0.5 package preserved at release/rollback/V1.0.5-pre-2026-10-01. Protected10 map files checked; no map recompilation.
- Two stale Panorama resources rebuilt using Valve resourcecompiler: loading layout and native HUD controls script. No failed compile. Deleted talent/progression source assets have no orphan compiled Panorama entries in the package.
- npm run check: zero failed checks;200 ability/223 modifier mock smokes passed. Installed VPK verification: all unit models,218 icons and203 literal runtime resource paths passed. These are not engine playtests.
- Independent VPK reader verified98 payload entries against working files plus map hashes/preview before upload.
- SteamCMD cached account upload returned Committing update Success / Upload finished OK at14:47 Istanbul; uploaded manifest4766617110520442910.
- Official public Steam API then returned result1, titleV1.0.6, visibility0, file_size23378536, time_updated1790855232 and hcontent_file4766617110520442910, matching the uploaded manifest and archive+publish_data byte size.
- Distribution verification remains pending: both fresh signed-in and anonymous SteamCMD downloads still returned older manifest9127350215101945582, V1.0.5,25663242bytes. Public page HTML also cachedV1.0.5 while the official API reportsV1.0.6. Do not claim downloaded archive equality or full distribution propagation. No unnecessary second upload was made.

Source review complete for Sven/Juggernaut/Drow; remaining individual hero review and owner runtime acceptance pending. Publishing this owner-requested snapshot does not certify all heroes or release balance.

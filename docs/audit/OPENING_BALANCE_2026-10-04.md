# Opening balance — 2026-10-04

Owner reports remaining at level 1 through wave 6, then sudden easing at level 2. The old first-level cost was 900 XP; a full wave one grants only 460 XP/player (20 creatures/player, 23 XP each, shared among defenders). Timed wave advancement does not guarantee kills. Exact owner kill counts are unavailable; an engine XP-loss bug is not claimed.

First five transition costs now are 150 / 300 / 450 / 650 / 850 XP. Cumulative levels 2..6 require 150 / 450 / 900 / 1550 / 2400 XP. Original transition costs resume from level 6. Level 50 requires 94,470 XP instead of 97,020. Normal start remains level 1 with zero paid points and the free passive; test-map start remains level 6.

Regular creature HP gains a snapshotted 1.50 multiplier: normal wave-one HP is 180 for multiplayer and 135 for solo, previously 120 and 90. Damage and Boss pressure stay unchanged. Older snapshots without regularHP retain previous tuning. No hero skills or native wave KV were changed.

Research: inspected production progression, rewards, spawn and snapshot paths. Valve custom XP API record: https://store.steampowered.com/news/21435/ . Primary author cumulative-table reference: https://github.com/tontyoutoure/DOTA2-AI-Fun/blob/master/game/dota_addons/dota2_ai_fun/scripts/vscripts/gamemode.lua . Reference only; no copied code or new API usage.

Production OnKill mock replay uses actual wave-one KV and spawn plans. Teams 1..5 unlock the first skill by 7/14/20/27/33 total kills respectively, within the first 35% of wave one. Full clear gives 460 XP/player regardless of team size. Tests cover no killer, duplicate payout prevention, solo/coop/PvPvE HP, Boss equivalence and old snapshots. Level tests cover early milestones, later costs, 50 thresholds and normal/test point budgets. Full npm run check passed with zero failures, including opening-balance regressions, wave-pressure and installed-data Boss checks. Engine playtests remain separate.

Runtime acceptance PENDING: new solo and two-player matches; actual XP, skill points and creature HP, followed by wave 1..6 clear times, deaths and Life. Tuning is provisional. Workshop publication requires a new owner request for this balance change.

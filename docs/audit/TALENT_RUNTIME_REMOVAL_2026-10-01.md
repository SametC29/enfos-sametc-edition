# Talent runtime removal — 2026-10-01

Status: IMPLEMENTED BUT NOT ENGINE-VERIFIED.

The owner's no-talent decision requires both native HUD suppression and removal
of gameplay grants. Suppressing StatBranch/LevelUpTab alone leaves the talent
slots, point listener and reconnect restore code available. Contributor changes
already present in the candidate are now delivered as a focused runtime unit:
all forty heroes hide Ability10..17, Ability19 and Ability25; custom talent KV
entries are removed; startup no longer initializes evolution/profile managers;
hero spawn/reconnect no longer restores or loads them; setup no longer depends
on progression curves; related HUD manifests and net tables are unloaded.

The shared match-only XP curve and level-6 initialization remain unchanged:
level 50, five initial spendable points, 49 ordinary points over levels 2..50,
and the separate free fifth-passive rank. No gameplay ability or rank tuning is
introduced here. Disabled legacy files and unrelated contributor changes are
preserved outside this focused commit; no manager hook may activate them.

`tools/tests/talent_removal.test.mjs` checks the forty-hero slot/definition
contract, absence of active startup/spawn/setup hooks and HUD manifests, and
runs the production match-level regression suite. These are static/mock checks.
Native frame identifiers were verified in the installed Valve layout as
recorded in `TALENT_TAB_REGRESSION_2026-10-01.md`.

Owner acceptance on a full fresh-map restart: gain levels with unspent points,
including 10/15/20/25/50; no tree, attribute branch or talent bonus points;
Q/W/E/R/fifth passive remain trainable, total paid budget is 49, free passive
rank is separate. Respawn/reconnect must not duplicate points/ranks. Verify
no old profile HUD or backend/profile loads and no new VConsole errors.

# Guest team selection — 2026-10-04

## Evidence and root cause
Owner reports that a second player cannot join either team during setup; screenshot shows one Radiant member and empty remaining slots. Panorama sends enfos_setup_join_team with the requested team; the server reads the engine-supplied PlayerID. OnJoinTeam incorrectly called CanConfigure, which requires PlayerHasCustomGameHostPrivileges. Every non-host request was therefore rejected before SetCustomTeamAssignment.

## Repair
Separate personal team selection validation (valid PlayerID, active setup, setup not completed) from host-only configuration. OnJoinTeam uses the personal guard; difficulty and start continue to require lobby host privileges. Existing team IDs and five-player capacity remain enforced. No client-supplied identity fallback or new team assignment implementation was added.

## Research
Reviewed Valve's shipped Overthrow setup implementation, including SetCustomGameTeamMaxPlayers and GetCustomTeamAssignment, through the current GameTracking source: https://github.com/SteamTracking/GameTracking-Dota2/blob/master/game/dota_addons/overthrow/scripts/vscripts/addon_game_mode.lua . Official Valve API pages for PlayerHasCustomGameHostPrivileges and SetCustomTeamAssignment returned HTTP 403 during this audit. The defect is in our explicit authorization guard, rather than an inferred engine API change. No external code was copied.

## Validation
A mock regression with host 0 and guest 1 initially reproduced the rejection (guest must be able to join the host). After repair, guest 1 can join Radiant from unassigned and switch to Dire. Missing/invalid identity, invalid team, completed setup, mid-match changes, sixth team member and guest start requests remain denied. Audit suite: 23 tests pass. Full npm run check passed with zero failures, including wave-pressure and installed-data Boss checks. Engine playtests remain separate.

## Runtime acceptance
PENDING owner two-player Dota session on the repaired build: guest joins host, switches to opposite team, switches back; both names appear, host starts and both players reach hero selection. No actual multiplayer runtime success is claimed. Workshop publication requires a new explicit owner request; this source fix alone does not change the installed public Workshop build.

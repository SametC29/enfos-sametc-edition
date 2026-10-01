# Active owner goal — progressive waves and Spellbringer

Implementation record: curve/roster foundation in d14edc7 and wave integration
in aca4251. Spellbringer final integration is documented in
`SPELLBRINGER_FUTURE_EFFECTS_2026-10-01.md`. Engine acceptance remains pending;
publication remains prohibited without a new explicit owner instruction.

Updated scope, including owner steering:
Latest owner update (2026-10-01): preserve stun, invisibility, silence and other
special-wave identities when assigning distinct native creep models. This is a
required acceptance condition of the current goal, not an optional follow-up.

1. Weaken the opening, increase normal-creep pressure throughout 60 waves,
   accelerate the ending, and separately tune Boss difficulty.
2. One distinct native model per authored wave: 48 normal identities and 12
   existing distinct native hero Bosses. Owner approves verified native
   alternatives for missing or duplicate desktop-list models.
3. Preserve special waves: stun, invisibility, silence and related mechanics
   must be assigned to suitable native creeps. Native abilities first;
   bounded custom adaptation where native behavior lacks the required mechanic.
   Do not flatten special waves into basic attackers or allow mass chain-control.
4. Allied Spellbringer reinforcements use current wave +5 appearance and stats;
   define Boss-slot and campaign-end handling explicitly.
5. Spellbringer shows a cursor area before cast and a confirmed skill effect/
   area at the accepted world position, with resource and particle cleanup.
6. Verify current Dota resources/APIs through MCP, run appropriate checks,
   document evidence and make focused commits/pushes preserving contributor work.
7. No live deployment/Workshop upload without a new explicit owner instruction.
   Actual Dota/VConsole visual/gameplay verification remains owner-pending.

This file is the durable execution scope. The goal API available to this agent
only changes status; it cannot edit the sidebar objective text. The additional
special-wave requirement applies to the active work despite that UI limitation.

# Wave 37 native Rally client crash

## Owner evidence and binary analysis

Owner reports simultaneous desktop exits around waves 35–40 with Drow Ranger,
Zeus, Juggernaut and Lina. Two local dumps from 2026-10-04 (16:08:20 and
16:28:18) independently show the same signature:

- Files: `dota2_2026_1004_160820_0_accessviolation.mdmp` and
  `dota2_2026_1004_162818_0_accessviolation.mdmp` in Dota's `game/bin/win64`.
- Exception `0xc0000005`, read at address `0x57`.
- Fault `client.dll + 0x14f8605`; installed PE timestamp `1790890377` matches
  the dump module timestamp (ASLR module bases differ).
- Fault instruction `cmp byte ptr [rax + 0x58], dil`; RAX is `-1`.
- RSI points to the modifier instance. Its vtable RVA is `0x47a2088` in both
  dumps. Resolving the PE's MSVC RTTI locator and type descriptor identifies
  `CDOTA_Modifier_HillTroll_Rally` in both cases.

This directly identifies the active native modifier at the crash. It does not
prove why the engine's global pointer became invalid or certify that no other
crashes exist. Stack memory was inspected as candidate addresses, not presented
as a symbolized/unwound stack. Dump contents and player identifiers are not
committed. Analysis used Python struct parsing, pefile and Capstone in a temporary
directory; these are not game dependencies.

## Production path and source decision

`waves/special_creeps.lua` formerly assigned `hill_troll_rally` to every wave-37
skeleton. `Configure` adds it and calls `SetLevel(1)`, instantiating the native
passive. The same configuration path applies to Future Reinforcements, so this
could also trigger before scheduled wave 37. The installed Valve ability KV,
queried on 2026-10-04, confirms PASSIVE, MaxLevel 1, radius 1200 and damage_bonus 2.
The creature KV itself does not assign Rally. No other production reference was
found. Disabling active casting alone cannot prevent a passive modifier.

Class D — REPLACE/quarantine: native Rally has direct crash evidence in this
addon. Remove the added passive rather than introduce an unverified replacement.
Wave 37 retains its skeleton model, scheduled units, routes, HP/damage scaling,
gold/XP and Life behavior. Its Rally bonus is intentionally absent. Bosses and
hero skills are unchanged; no population cap is introduced.

The historical manual-test inventory of 2026-10-01 is a baseline, not permission
to restore Rally. The current special-wave contract is regenerated from production.
Keep Rally disabled until a separate engine reproduction establishes a safe fix.

An older developer report about removed-unit modifiers crashing custom games
exists in [Valve's issue tracker](https://github.com/ValveSoftware/Dota2-Gameplay/issues/13266).
That report is contextual only: it is not proof of this Rally failure's mechanism.
No matching public Rally crash fix was found; no external code was imported.

## Acceptance

- SOURCE_REVIEW: PASS — two matching dumps identify Rally and production assigns it.
- AUTOMATED_VALIDATION: PASS — hostile/allied Configure regression,
  all-kit quarantine guard, regenerated contract and `npm run check` (zero failures).
- OWNER_RUNTIME: PENDING — start a new match with the patched build; play waves
  35–40 (especially 37), with repeated kills and the reported heroes. Also test
  Future Reinforcements whose selected unit is wave 37. Confirm both clients stay
  running and collect a new dump if either exits.
- Publication: owner explicitly requested GitHub and live Workshop publication
  after the repair on 2026-10-04. V1.0.17 packaging/upload is a separate release gate.

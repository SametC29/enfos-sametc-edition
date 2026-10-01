# Spellbringer future profiles and cast areas

Implementation and automated verification complete; actual Dota/VConsole visual
and gameplay acceptance is pending owner testing. No Workshop upload or live
promotion was performed or authorized.

## Cause and behavior

Future Reinforcements previously spawned one generic model with additive HP and
attack bonuses derived from wave +4. It now selects the verified normal-wave
profile at current wave +5, uses that profile's native appearance and special
kit, and applies the shared numeric curve plus the authoritative match difficulty
and solo multipliers. Exactly five successful spawns retain player control and
30-second lifetime, with native bounty and death XP explicitly cleared.
Boss slots use the preceding normal profile while retaining numeric +5 strength.
Beyond the campaign, strength caps at 60 and appearance at normal wave 59.

This ability is TUNE: its five-unit, mana/cooldown, duration and match-local
identity are preserved. Its obsolete generic-profile/+4 implementation is
replaced by the authored roster lookup. Resource callbacks must be ready before
creation; failure restores mana/cooldown and sends no accepted-cast effect.

All eight Spellbringer buttons now show one world-space cursor range indicator
while targeting. Cancel, switching spells or clicking the cast position retires
the indicator and its scheduled loop. Confirmed server casts emit the accepted
ability, team and position; only the casting team's clients show an effect there.
Reveal uses native Dust, Purification uses Omniknight's native purification and
the remaining casts use native Enigma conversion. A range ring marks the actual
area, including 71/85-unit envelopes for the existing square spawn offsets.
Reveal's ring lasts 15 seconds; other acknowledgement rings last two seconds.
Burst effects retire after 1.5 seconds. At most 16 cast-effect pairs are retained;
destroy/release calls are idempotent after timer expiry or early eviction.

## Native evidence and checks

Installed VPK contains all four particle resources.
The final installed-data model audit also establishes 60 distinct compiled
model paths across all 48 normal profiles and 12 native hero Bosses; the sorted
records are in `ALL_WAVE_MODELS_2026-10-01.json`.
MCP Panorama docs verify
CreateParticle(name, attachment, owning entity), control-point updates, destroy
and release, and Players.GetPlayerHeroEntityIndex. The selected player hero is
the owning entity for client particle creation. Resources are added to startup
precache. Only `spellbringer.js` was passed to the installed resource compiler:
the compiler reported 1 compiled, 0 failed, 0 skipped. Maps were not rebuilt.
The generated `.vjs_c` is an ignored local build artifact; source files remain
the committed deliverable.

`tests/spellbringer_future.lua` tests all 60 current waves against the production
service, including solo/hard multipliers, appearance, HP, attack, armor, speed,
magic resistance, ownership, lifetime, zero rewards, accepted server event and
resource-not-ready rollback. The Node wrapper rejects stderr and missing success
markers as well as nonzero exit. Panorama VM tests verify preview cancellation,
radius controls, team filtering, timer cleanup, the effect cap and no duplicate
destroy/release. Existing targeting VM tests remain passing. Four-language
descriptions now explain +5, Boss-slot fallback and campaign caps.

Full working-tree checks pass. The isolated index has the previously documented
unrelated HEAD hero/schema/inventory and local-map baseline failures; scoped
Spellbringer/wave tests run against the exact staged files and pass. This is not
full release certification.

## Owner runtime verification pending

In a fresh match, test each of the eight ground-target casts, cursor rings and
right-click cancellation. Check native particle rendering/control points,
accepted area location and lifetime, sound, resource callbacks and cleanup in
VConsole. Compare +5 reinforcements at early, Boss-adjacent and campaign-end
waves against corresponding enemy stats. Confirm special mechanics and Reveal
visibility using Ghost/Lycan wave units. Automated checks do not certify these
engine observations. Publication requires a new explicit owner instruction.

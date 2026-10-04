# Slark native-first review

SOURCE WORK IN PROGRESS; all engine acceptance remains pending owner testing.
This supersedes the old blanket PVE-CONVERT entries for the next implementation
units; their prior mock results are historical evidence only.

## Installed evidence

[Native snapshot](SLARK_NATIVE_SOURCE_2026-10-04.json): current build 6943,
SourceRevision11069754, Oct01 2026; exact hero and English ability-localization
source hashes and observation time are recorded there. The balanced
AbilityDefinitions subtree was parsed, preserving strict project KV validation.
The native dossier's older slot mapping is still useful, but not enough: current
Essence Shift is hidden innate MaxLevel1; Saltwater Shiv is a hero-targeted active
attack, and both Fish Bait and Depth Shroud definitions are shard-granted.

Source reviewed: five production KV definitions, the Slark section and modifier
links in pve_kits.lua, current addon precache, progression/Health hooks and the
four-language descriptions. Existing native alias/value-bridge patterns from
Luna/SF/BB are reused; no new hero manager or spawn listener is needed.

## Matrix recorded before implementation

| Slot | Exact native counterpart | Class | Preferred implementation and evidence boundary |
| --- | --- | --- | --- |
| Q enfos_slark_dark_pact | slark_dark_pact | TUNE | NATIVE plus one AGI special-value bridge. Self-purge and radial damage already fit waves. Restore native delay, self-damage, strong dispel, effects and cleanup; preserve authored damage/cost/CD/radius and AGI scaling. No Lua pulse replica. |
| W enfos_slark_pounce | slark_pounce | PVE-CONVERT | NATIVE leap/Scepter charges first; convert only hero-only contact to useful creep contact if necessary. Installed description explicitly names first hero, while current Lua only checks an endpoint circle, not the travelled path. A tether state/slow alone does not prove native leash-radius enforcement. Verify the native modifier/API constructor before adding an extension; no guessed motion or CPs. |
| E enfos_slark_essence_shift | slark_essence_shift | PVE-CONVERT | NATIVE hero essence/attribute interactions with minimal bounded creep AGI extension. Native is hidden, nonlearnable, innate rank1 and supports hero kill AGI within the match. Paid ten-rank E must remain separate from innate auto-scaling. Creeps lack the hero attributes assumed by native stealing; avoid duplicating the native hero attack bonus. Existing whole-buff refresh/cap is an authored creep conversion, not proof of native per-stack expiry. |
| R enfos_slark_shadow_dance | slark_shadow_dance | TUNE | NATIVE concealment/passive visibility rules and native regen, with minimal authored rank integration. Source bonus_regen is flat 60/90/120, not the current custom health_regen_pct=8..18; do not silently route percentages into that field. Native passive works while not visible to enemy team and has neutral damage suppression. Current custom invisibility/truesight states do not prove those rules. |
| D enfos_slark_fish_bait | slark_saltwater_shiv (historical design counterpart); slark_fish_bait is a different shard active | PVE-CONVERT | Resolve native attack-proc integration first. Saltwater Shiv steals movement, regen and health-restoration from heroes; this is not the current random physical cleave/armor stacks. Native active hero-only targeting and limited creep healing make a direct passive alias invalid. Preserve five-slot passive/10-rank contract; document any necessary custom portion instead of calling the old rewrite native. |

## Confirmed source differences

Q custom starts immediate purges/pulses with no blood cost. Native declares
delay1.5, pulse_duration1, total_pulses10, pulse_interval0.1 and
self_damage_pct30. Its current English description explicitly identifies strong
dispel and self-damage. The authored tick interval is0.15; tune native pulse
duration to1.5 when preserving that interval, while retaining the native delay.
Native total_damage is the verified key; damage/pulse_count/tick_interval are
custom names. Merely setting the texture does not make those engine-readable.

W custom sets absolute position every0.03 seconds, lacks a native motion-controller
claim and tests only its final point; it can miss a unit passed along the path.
Its damage is physical and applies a fixed80% slow. Native Pounce is ROOT_DISABLES,
non-dispellable, magical metadata, pounce_damage0, radius120, leash_radius400,
and applies Essence Shift stacks. Scepter belongs to W charges/range, not the
current generic R amp/CD bonus. Existing boss-only duration compensation is an
Enfos deviation; normal native resistance rules must be reviewed before retaining it.

R custom has no passive visibility detection, applies percentage regen during its
timed buff and manually owns a particle. Native attack/item/spell use does not
reveal the active concealment, although the cloud remains visible. Exact native
bonus_regen units and modifier state must be checked before numeric conversion.

E/D existing callbacks lack some removed-handle/source guards and refresh all
stacks together. These known source issues must be repaired before Slark source
closure, whether through native ownership or the justified minimal extension.

## First source unit: native Q

Use the stable alias enfos_slark_dark_pact with BaseClass slark_dark_pact,
verified native special keys and an additive AGI query modifier. Preserve ten
rank arrays and ordinary rank gates. Remove the Q Lua class/custom pulse modifier
and its links; replace imitation-only tests with native-source/rank/registration
contracts. Engine owns timing, purge, targets, particles, sound and cleanup.
MaxLevel10 and a passing special-value mock do not prove native C++ rank acceptance.
W/E/R/D remain open until their coherent source units are completed.

## References and resource evidence

[ModDota ability KV](https://moddota.com/abilities/ability-keyvalues), accessed
2026-10-04, documents native BaseClass aliases and the limit of exposed fields.
[Valve Slark page](https://www.dota2.com/hero/slark) was checked, but its fetched
body yielded no ability text; installed localization is the behavior evidence.
Reference-only corpus: Aghanim's Pathfinders Workshop2208582400,
scripts/npc/heroes/slark/slark.txt:6 and scripts/npc/npc_abilities_override.txt:2975.
No imported code/assets and no claim of license-verified reuse or engine proof.

Archive verifies soundevents/game_sounds_heroes/game_sounds_slark.vsndevts_c and
particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf_c. The latter is
already explicitly precached; add the verified sound bank to the existing list.
Native owns particle attachments/CPs; no manual attachment is inferred here.

Pending owner Q tests after a full restart: ranks1/10, actual damage versus raw
query/AGI, delay/pulses, self-damage, strong dispel, caster death during delay,
recasts, immune/boss/ordinary targets, mana/cooldown, VFX/SFX/cold-start, clean
client/server VConsole and progression/respawn. All other Slark engine areas
remain pending, with no engine launch or gameplay-control tool authorization.

Q source implementation2026-10-04: native stable alias and one additive AGI
special-value modifier are installed. Removed the custom Q class, pulse modifier
and link; one obsolete pulse-loop mock is replaced with three native contracts.
No ApplyDamage, target scans, purge loop, manual particles or pulse timer remains
for Q. The existing free-passive service restores the scaler idempotently;
Q's native ten-rank metadata and ordinary point schedule are unchanged. Existing
particle precache remains and the verified Slark bank is added. Source tests
cover native fields, raw paid ranks1–10, AGI addition on client/server, untrained
zero, no native providers/point grants and idempotent restore. Shared client test
now covers seven Luna/SF/BB/Slark links once and rejects server integrations.

Final Q source boundary: `node tools/checks.mjs` passes with zero failed checks;
three focused native/source/AGI tests pass. This closes only the Q source unit,
not its engine gates or Slark's remaining four source units. No game launch,
console command, remote push or publication occurred.

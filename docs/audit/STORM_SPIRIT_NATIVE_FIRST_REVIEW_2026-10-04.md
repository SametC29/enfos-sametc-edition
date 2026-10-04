# Storm Spirit native-first discovery

SOURCE_REVIEW: discovery complete, implementation pending. OWNER_RUNTIME:
PENDING for every slot. This report precedes production changes; historical
mock PASS entries in the dossier do not certify the proposed native kit.

## Evidence

Installed Dota build6943 / revision11069754 / Oct01 2026. Re-read native
`scripts/npc/heroes/npc_dota_hero_storm_spirit.txt`; SHA256
`02996ee5b413c86b193d109253e723ed3dabe87cbbe5002362f863b1b02c823c`
matches the [fresh snapshot](STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json).
It records six definitions, native English localization and seven verified
resource hashes. Repeated native header `resource` keys are preserved in
headerRaw; only AbilityDefinitions uses the strict project KV parser.
AbilityDraft's nested slots are not the native hero's assigned slots.

Production inspected: Storm's five KV blocks in npc_abilities_custom.txt,
all five Lua implementations in abilities/pve_kits.lua, hero dossier,
heroes/innates.lua restore dispatch and addon_game_mode.lua precache.
All five are currently CUSTOM Lua. No Storm-specific native restore branch
exists. Six Storm particles are registered, but the explicit sound-bank
list lacks `stormspirit`; native bank existence alone does not prove audible
playback. No new engine session was launched.

[ModDota's BaseClass reference](https://moddota.com/abilities/ability-keyvalues)
supports native aliases with exposed KV values; it does not establish their
internal linked-name lookups or ten-rank C++ behavior. Those remain test gates.

## Pre-mutation slot matrix

| Slot / stable ID | Existing authored behavior | Verified native counterpart | Class / planned ownership |
| --- | --- | --- | --- |
| Q `enfos_storm_static_remnant` | Self-planted thinker; trigger and damage share240..330 radius; damage100..390 + INT1.2; lifetime8..12; manual feedback | `storm_spirit_static_remnant`: trigger235, damage300, delay.75; point-target field1/range800/travel300; native remnant and cleanup | TUNE; NATIVE preferred, NATIVE+MINIMAL EXT only if preserving INT needs a verified damage bridge. Preserve authored damage/CD/cost/lifetime, keep trigger and damage keys distinct. |
| W `enfos_storm_electric_vortex` | Target-centered AoE stun, no pull; duration.8..2.6; main target Boss flag changes everyone's duration | `storm_spirit_electric_vortex`: native single-target pull, tether1200, strong dispel; Scepter radius475 conditional | TUNE; NATIVE alias restores pull and Scepter. Retire ordinary-cast custom AoE stun/Boss duration. Preserve authored ten-rank duration/CD/cost/range; use verified native pull keys. |
| E `enfos_storm_overload` | One boolean charge; items can charge; five-second expiry; excludes killing target; damage25..190 + INT.6; movement slow only | `storm_spirit_overload`: native charges/discharge, attack and movement slow, Shard activation3 charges/12s/40AS | TUNE; NATIVE preferred, minimal raw INT scaling bridge only if verified. Preserve authored damage/radius; native owns charging, slows, Shard and feedback. No second Lua proc. |
| R `enfos_storm_ball_lightning` | Instant teleport clamped900..1800; arrival-only damage35..80 + INT.1 per100; flat travel mana18..9; Boss cap | `storm_spirit_ball_lightning`: continuous flight1400/1850/2300, root restriction, path damage, native mana exhaustion; initial25+7.5% and travel10+.65% per100 described in native text | TUNE; NATIVE preferred. Retire teleport/arrival damage/Boss cap. Damage header6/10/14 differs from tooltip per100 units: verify native interpretation before translating authored35..80. Preserve native percentage mana component; record flat-cost tuning explicitly. |
| D `enfos_storm_galvanic_core` | Independent paid ten-rank mana regen1..4.2/INT4..24, Break/illusion suppressed; no native innate | `storm_spirit_galvanized`: rank1 innate, charge every3 levels/kills, lose2 on death, regen.2 plus match-local permanent.1 per gained charge | TUNE; exact native innate plus separate CUSTOM paid stat modifier, NATIVE+MINIMAL EXT overall. No cloned charge/death logic. Creep credit remains unproven; PVE-CONVERT only if evidence establishes the missing component. |

These are implementation targets, not assertions that a native alias already
works. Every stable paid slot remains10 ranks; Q/W/E/D gates1/1, R5/5;
level50, level6 start, five ordinary starting points and free D1 stay in the
existing shared service. Exact native helper ranks must not consume points.
No talent or persistent profile progression is introduced.

## Specific source findings and unresolved read paths

Q's native header says NO_TARGET, while `is_point_targeted=+1` and the current
English description specify a remnant walking to the chosen point, including
self-cast. Preserve those exact native fields and inspect the real targeting
HUD before adding behavior overrides. Do not assume a facet grant. Current
Lua deletes its thinker on caster death and scans every.2s; migration should
delegate actual remnant lifetime, arming, vision and cleanup to C++.

W currently never pulls. Ordinary native targeting, block/reflection, immunity,
status resistance, target death and Scepter transition belong to native code.
The conditional radius object has no base `value`; adding475 unconditionally
would change ordinary casts. Native enemy_overload_duration is0; no invented
extra Overload buff or blanket Boss control exemption.

E must precede linked casts in the migration. Exact native Overload identity
may be necessary for Q/W/R C++ charge lookups; an alias-only lookup has not
been proven. Native modifier names must be queried rather than guessed.
Current code accepts items as charge events, skips killing hits and lacks
native attack slow. Preserve engine charging and attack resolution instead
of patching the copied proc. `storm_spirit_electric_rave` is defined but not
assigned in the native hero header. Definition existence does not authorize
an additional button; verify whether native E handles Shard activation.

R has AbilityManaCost30 alongside initial25+7.5% keys: do not add both manually
or claim their actual C++ arithmetic from KV alone. Damage header6/10/14 also
requires actual read-path/unit verification. scepter_remnant_interval300
exists without HasScepterUpgrade on R; do not assign ownership from its name.
Native flight/path damage/untargetability/arrival/exhaustion/recast remain
owner tests, including behavior when rooted and when mana runs out mid-flight.

D's native permanent regen refers to the current match, not account storage.
Kill eligibility, level50 charge increments, Break and death/respawn behavior
remain unverified. Do not manually write native stacks or ForceRefresh the
innate on restore. Keep paid stats separate from native level-based charges.

Installed W owns Scepter and E owns Shard. Current custom R/D flags and generic
Mage upgrade bonuses must be reviewed against the existing scoped ownership
patterns before migration. Suppression must apply only to the migrated Storm
kit and preserve every other Mage. No facet/talent/legacy button restoration.

## Other-game references and imports

WORLD OF DOTA2880603428 has no searched native remnant implementation;
Boss Survival1571786267 has no searched Storm match; Watcher3164617180
matches native headers/cosmetic mappings, not a five-slot conversion.
AGHANIM'S PATHFINDERS2208582400 `scripts/npc/npc_abilities_override.txt`
remnant block uses native NO_TARGET with separate235 trigger/260 damage radii,
delay1, mana25 and damage100. Its Brewmaster encounter precaches the native
Storm bank/remnant. This is an older native override example, not proof of
current point targeting, hero INT composition or linked charge behavior.
Exact upstream version/license not established: REFERENCE_ONLY, no imports.
All proposed code remains independent and uses verified Valve resources.

## Implementation sequence and owner acceptance

Establish E native identity/raw rank bridge first, then Q linked charging/
targeting, W pull/Scepter, R flight/mana/damage, and D innate/stat separation.
Use existing restore/client registration/automatic Health and bounded trace;
no new manager, per-frame scan, console command or gameplay probe for logging.
Only custom modules need ScriptFile; pure native aliases have no empty wrapper.
Read-only Health queries do not prove actual damage or cached scaling.

Focused meaningful fixtures cover raw value lookup, context availability,
untrained/ten-rank/Break/illusion guards, native identity restoration without
point or stack duplication, scoped upgrades, locales and removal of duplicate
casts/damage. Full checks belong at a production source boundary; this unit
only validates discovery records and makes no new gameplay-test claim.

Owner runtime later: full restart after structural KV/bootstrap changes;
select Storm and obtain automatic Health. Test Q point/self placement and
separate trigger/damage rings; E spell/item/miss/killing-hit charging; W pull,
block/reflect, Scepter groups; R path hits, mana exhaustion, root and recast;
D level milestones, Break, death/respawn and creep/hero kill credit. Cover
rank1/10, points/HUD, dense waves, visual/audio loops, cleanup and reconnect.
VConsole must be correlated to the tested revision. No engine PASS until
actual observations establish each applicable acceptance field.

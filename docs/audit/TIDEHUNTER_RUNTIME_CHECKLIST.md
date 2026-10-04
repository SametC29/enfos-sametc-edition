# Tidehunter owner runtime checklist

Status: OWNER_RUNTIME PENDING. Current source: native-first Q/W/E/R and paid
Catch extension; record exact tested commit from the native-first review/log.
Installed reference: build6943/revision11069754. Owner alone launches/controls
Dota. Full restart required after structural KV/client-bootstrap/provider changes.
Automatic Health reports selected hero, native Catch rank/intrinsic presence and
wave stacks; diagnostics/query values do not establish actual engine acceptance.

| Test | Measurable expected result | Result |
| --- | --- | --- |
| Progression | Level6 start, five ordinary starting points, separate free D1,49 ordinary points through level50; Q/W/E/D ten ranks, R levels5/10/…/50; no talents/profile. Hidden Catch rank1 never consumes ordinary points or exposes another paid slot. | PENDING |
| Q | Native projectile/armor/slow, authored damage+STR, targeting/block/reflect/dodge; ranks1/10 and actual HP change. | PENDING |
| Q Scepter/Blessing | Native point wave2200/260/1500 and cooldown7 including ranks9/10 before other modifiers; dropping item restores normal targeting. | PENDING |
| W defense | Authored20..80+0.05STR, native creep50% penalty/item-block stacking; active doubles effectiveness4s with40% move penalty,45 mana/CD30; flat5..20 regen. | PENDING |
| W cleanse | Actual strong dispel450/reset7, pause/death/lethal/reflect and neutral-wave versus player-owned damage eligibility. No duplicate Lua Purge. Separate Blubber dependency remains a question. | PENDING |
| Shard | Independent450 received-damage counter/reset7/cap5; learned E half average attack plus tuned bonus as reflected damage. No lifesteal/attack item procs; no generic350HP/15% reflection. Native radius/debuff reused; actual construction/read/refresh test. | PENDING |
| E | Native actual attacks/item effects, bonus80..230+0.75STR, attack range+225 radius, cast0.4, non-piercing immunity, signed40..70 reduction/duration6. Native and reactive recipient overlap refresh without double reduction. | PENDING |
| R damage | Native header200..450 plus intended live2STR outgoing factor; measure actual HP at ranks1/10 with STR and spell amp/outgoing modifiers, mitigation and reflect. Debug outgoing query is not final damage evidence. | PENDING |
| R control/lifetime | Native expanding wave speed725/authored radius1000, stun2.4..3.2 with ordinary immunity/resistance/dispel; no Boss-only cap. Repeated/Refresher casts, paused time, caster/target death/removal and cleanup. | PENDING |
| Native Catch | Exact hidden rank1 provider/intrinsic exists at startup. Observe free fish for even levels2/4/6 once, then8..50; native hero-kill fish pickup/expiry and HP/range/conditional block. No Lua backfill/grant duplicates. | PENDING |
| Wave growth | Only own enemy Creep/Creature last hits, no hero/illusion/friendly/ally/summon-attacker credit; cap25, maxhealth50..200 by current paid rank, range2 per load/cap50. No wave fish entities. | PENDING |
| Passive lifecycle | Break suspends wave collection/bonuses but preserves loads; death/respawn/reconnect and rank changes retain loads and correctly recalculate HP/range; no duplicate native provider or points. Native Catch Break behavior separately observed. | PENDING |
| Presentation | Native Q/W/E/R/fish effects, icons and audio/cold start; Shard gesture/CP2 radius; all four locales and modifier tooltips, no raw keys. | PENDING |
| Performance/VConsole | Dense waves/repeated casts/reconnect without timers/entities/modifier accumulation, Lua/API/precache errors or repetitive warnings. Record Health plus exact session/revision. | PENDING |

Source checks are tracked in the native-first review. Earlier custom-band/aura
checklist expectations are superseded; no historical mock pass certifies this kit.

# Centaur Warrunner individual review — in progress / owner engine pending

Own AGENTS/full ABILITIES and shared research/reference contracts read. All five current Lua/KV implementations individually read; fresh installed ClientVersion6943 native hero definitions extracted. Historical6941 discovery dossier does not certify current patch. Local commits only; no Dota launch, remote push or Workshop upload.

| Slot | Classification and current native/custom comparison |
| --- | --- |
| Q Hoof Stomp | PVE-CONVERT: native325radius70→280magical/1.6→2.2stun/0.5windup/IMMEDIATE and strong dispel. Enfos350radius120→300+1.5STRphysical/2secstun/Boss40%duration/0.3cast. Native windup/animation, radius controls and stun/dispel feedback under review. |
| W Double Edge | PVE-CONVERT: native175range220radius120→300magic+60→150%STR,3.5CD and native Shard temporary STR/slow. Enfos200range250radius150→375+0.6STR+15%maxHPpure,30%computed damage direct health cost/min1. Spell-block cancellation and immune radius present; native cast/impact/audio/target flag under review. |
| E Return | PVE-CONVERT: native attack return15→45+14→35%STRphysical, optional1200aura. Enfos OnTakeDamage retaliates20→65+0.5STR and300accumulated-damage250radius pulse. Ally/reflection/Break guards present, immunity query already repaired. Non-attack/spell event conversion and pulse effect lifetime under review. |
| R Stampede | PVE-CONVERT: native3.5→4.5secglobalhaste/trample2→3STRmagical/105radius/3sec100slow; native Scepterduration/work-horse. Enfos5sec550speed/-40%incoming damage,150radius200+2STRphysicalonce-per-enemy-per-ally/1.5sec100slow. Owner/recipient and lethal callback repair below; native effect/audio/refresh contract under review. |
| Fifth Colossal Hide | REPLACE: distinct from native Horsepower40%STR-to-MS and mount/work-horse abilities. Enfos40→85+0.05STRphysicalblock and20→38%extraHP/Break. Client STR/property getters, illusion/health recomputation and icons/text under review. |

## Stampede stale owner and lethal recipient

Root cause: interval read parent position without lifetime guards and unconditionally added slow after its damage. Immediate kill/removal could leave an invalid recipient. Current MCP IsNull documentation explicitly checks whether the underlying C++ entity was deleted. [KV behavior guide](https://moddota.com/abilities/ability-keyvalues) distinguishes immunity/target flags; existing nonpiercing radius is retained, not widened from physical damage alone. Native/custom comparison above preserves intentional physical conversion.

New regression models lethal target deletion and removed caster; before repair it fails applying post-lethal control. Add server/valid caster/ability/alive recipient guards before radius processing, and require valid living enemy after damage before slow. A valid dead caster is still allowed to own another living ally's existing buff; removed caster/ability or dead buff recipient ends the modifier. No duration/damage/radius/once-per-recipient change. Modifier-owned haste effect is retained.

MCP reference-only Boss Survival1571786267 heroes/hero_centaur/hero_centaur.lua reviewed around its haste particle ownership: separate cast/haste effects, AddParticle ownership and movement event are visible source patterns. Its exact revision/license/live result unknown; no code/audio policy imported. Native resource/control-point and bank decoding is still pending in this individual audit.

Checks:246behavior regressions,200abilities/223modifiers across ranks1–10,full checks0failed. Actual kill/corpse callback order, slow duration/resistance, other-ally continuation after caster death/removal, haste cleanup and VConsole remain OWNER ENGINE PENDING. This first repair does not close the whole hero.

## Current resource investigation

Decoded installed6943 full hero_centaur particle folder and `game_sounds_centaur.vsndevts_c` with VRF19.2. Exact existing HoofStomp2.078231sec, DoubleEdge1.612426sec and Stampede.Cast3.569002sec events exist; Movement6.003242sec and Stun1.718753sec are available but their use/termination has not yet been changed. Bank source does not itself certify audible emission or looping.

Return root is a finite CP0→CP1 rope with sequential path/rope distance scale; current threshold-pulse generic helper supplies no endpoints, so its use as an AoE pulse needs a focused feedback decision after child/control review. Warstomp root is a container for dust/projected/warp/progressive ring/shockwave/weapon contact children. CP1 components drive child scale/speed and CP2 positions weapon contact; they are not interchangeable with a guessed radius vector. Shared helper changes are not authorized from these findings. Radius/time/location mapping and current model/animation must be resolved before a Q visual repair. Neither finding has been claimed engine confirmed or source closed.

## Return feedback repair (source checked; owner visual acceptance pending)

Replace the endpoint-free rope formerly used as a threshold AoE with one finite Warstomp ground burst. Every accepted retaliation now creates its native Return link with CP0 at Centaur and CP1 at the attacker, captured before ApplyDamage. No damage/count/threshold/Break/reflection policy changed. Both roots are already explicitly startup-precached. Each instance releases its index; no persistent buff root, thinker or global scan added.

Current6943 decoded Return rope/arc/thin/body flash/dust use finite emission/decay; arc's continuous emitter has an authored 0.1sec emission duration. Warstomp children have instantaneous emitters; CP1.x scales ring radius, CP1.y thickness and CP1.z speed. Its progressive-ring child supplies its own CP3–6 pre-emission constants. Independent implementation supplies CP0/CP2 ground position and CP1(radius,radius,radius), consistent with the decoded controls and reference-only Tiny PlayEffects in Boss Survival1571786267. CP2 is deliberately a world ground contact rather than an unverified hoof attachment. The particle's decorative rings are not asserted to precisely delineate the damaging radius. Source/version/license of that external custom game remain unknown; no external code/assets copied. [Attachment semantics](https://moddota.com/scripting/particle-attachment) and installed compiled resources underpin this mapping; actual appearance, scale, endpoint height and cleanup still require owner Dota/VConsole testing.

Extended existing threshold regression first fails because only the old endpoint-free pulse exists. After repair it verifies two CP0→CP1 links, one configured-radius ground pulse, all indices released, unchanged physical/reflection damage and threshold consumption. Full check:246behavior regressions,200ability/223modifier rank1–10 execution,0failed. This is source/mock evidence only; Centaur remains IN PROGRESS.

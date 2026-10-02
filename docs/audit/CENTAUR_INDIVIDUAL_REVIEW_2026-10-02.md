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

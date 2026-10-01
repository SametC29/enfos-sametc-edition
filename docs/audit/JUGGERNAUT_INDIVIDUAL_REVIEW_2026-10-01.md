# Juggernaut individual review — in progress

Read the affected hero instructions and complete dossier, shared hero contracts and research protocol. This record extends that dossier; its placeholder rows are not acceptance. Current installed build6942; current native source/hash and four explicit counterpart mappings are in `HERO_NATIVE_PRESENTATION_2026-10-01.json`. No live Dota launch/test.

## Review findings

All five production implementations were traced: Blade Fury's timed magical AoE and immunity/rotation feedback; Healing Ward's bounded stationary ground aura; Blade Dance's crit plus physical splash; Omni Slash's bounded target sequence, immunity and return position; Duelist's Break-sensitive base stats, timed capped kill stacks and full-stack healing. All five have ten ranks; Q/W/E/fifth gates1/1, R gates5/5. Free passive rank remains separate from native innate. No talents/persistent progression added.

| Slot | Classification | Current disposition |
| --- | --- | --- |
| Q | PVE-CONVERT | Native spin identity retained. Existing loop event is stopped by modifier teardown. Decoded current Juggernaut bank declares BladeFuryStart using `bladefury_start_loop.vsnd`, and separate BladeFuryStop. End sting, refreshed casts, spin activity, native debuff-immunity comparison and cold-start audio still under review. |
| W | PVE-CONVERT | Healing Ward is a stationary invisible thinker/particle rather than native movable attackable unit. Three-live-thinker cap and teardown helper exist. Heal percentage/radius derive from KV. Particle composition, aura linger and native model versus intentional ground aura remain under review. |
| E | PVE-CONVERT | Crit identity plus Enfos physical splash. Proven cross-attack state defect repaired below. VFX attachment, immunity and real attack-record callback ordering remain owner engine checks. |
| R | PVE-CONVERT | Existing direct physical damage sequence differs from native real attacks/procs; target-loss search and1400 home tether keep lifetime bounded. Generic Scepter amplification/cooldown must be checked against actual physical spell category. Source/animation/particle/audio and boss interaction audit continues. |
| Fifth | REPLACE | Project-specific base stats and kill momentum; not native Face to Face/Bladeform. Base and stack stats honor Break; full-stack heal and friendly/illusion/ward eligibility need further review. |

Native Sven work is not used as a blanket Juggernaut rewrite. Existing shared Fighter Shard (+35 AS/attack slow) and generic Scepter ultimate amplification/cooldown are traced through `heroes/aghanim_manager.lua`; no specific new upgrade silently invented.

## Blade Dance root cause and repair

Before: `GetModifierPreAttack_CriticalStrike` stored one `self.is_crit` boolean. `OnAttackLanded` cleared it **before** checking attacker. Another unit's landed attack erased Juggernaut's pending critical splash; overlapping own attacks overwrote one another. Existing regression incorrectly expected this deletion as stale-state cleanup.

After: cache each result (including failed rolls) by the engine attack record, with its intended target. Only Juggernaut's matching landed record consumes it. Repeated property reads do not reroll. Record destruction removes cancelled/missed attacks; modifier destruction clears remaining state. Break at impact consumes without splash. Unknown/record-less impacts cannot borrow another attack's critical flag. No polling/thinker or persistent match state added; live records are owned by engine callbacks.

API evidence: MCP `CDOTA_Modifier_Lua:OnAttackRecordDestroy(event: ModifierAttackEvent)` resolves. [ModDota callback declaration](https://docs.moddota.com/lua_server/declaration) confirms the callback; [published ModDota types4.35.0](https://app.unpkg.com/%40moddota/dota-lua-types%404.35.0/files/types/enums.generated.d.ts) identifies the symbolic event. Numeric enum IDs differ across published/current sources; production uses the symbolic engine constant, never a copied number. Actual current-build event record field/order remains an explicit owner-runtime check.

Reproducer: the revised critical-splash regression, with an unrelated landed attack between critical roll and own impact, fails against the before-edit production snapshot and passes after repair. Added overlap, false-roll caching, cancellation, duplicate landing, Break-at-impact and modifier cleanup tests. Updated an old minimal audit mock to include the engine target's IsNull method. **208 hero behavior regressions and full project checks pass**; mocks establish state logic, not engine critical resolution, visual/audio or damage compatibility.

Status: **IN PROGRESS**. Per-slot native asset/upgrades/localization/presentation evidence and owner runtime checklist must be completed before whole-hero source review closes. No imported third-party code, remote push or Workshop publication.

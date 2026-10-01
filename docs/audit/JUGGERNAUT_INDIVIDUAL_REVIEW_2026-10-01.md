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

## Native presentation/targeting follow-up

Read current build6942 native AbilityDefinitions directly from VPK, including all four native active/passive originals and Face to Face; exact source/hash remains in the native snapshot. Decoded the installed hero_juggernaut particle folder through VRF19.2. Omni Slash root uses `C_INIT_CreateSequentialPath` with ending control point1 and finite2s particle lifetime; its impact child roots default to CP0. The old generic target attachment supplied neither endpoint. Production now creates one world-space slash root with CP0 at the victim and CP1 at the pre-jump caster position, captured before movement/damage. Index is released; native finite particle lifecycle owns expiry. This is a sourced bridge/impact adaptation, not a claim of exact native renderer acceptance. [Particle API](https://docs.moddota.com/lua_server/declaration) supports explicit control-point positions.

Native Omni Slash declares `DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`, matching custom R KV, but the custom follow-up search used default flags. Added that flag to this R search only. No shared enemy helper changed. Tests check policy dispatch; actual immune target selection is owner-runtime pending.

Blade Fury loop now starts only when its modifier is created, rather than on every cast/refresh. Teardown stops the loop and emits verified `Hero_Juggernaut.BladeFuryStop` from a valid parent. Current decoded native bank confirms the start loop and stop event; audibility remains pending. Existing addon precache already includes the hero sound bank and all four particle roots. No per-tick sound emission added.

Duelist full-stack healing previously accepted friendly/deny attacks; it now requires a valid hostile target. Existing20% amount and Break behavior unchanged. Test fixture now supplies a real target and asserts friendly attacks cannot heal.

Current source comparison: native Q has5s duration/0.2s tick/260radius and80 immunity resistance value; Enfos deliberately has5s/0.5s/425radius,140–380 base DPS plus AGI×1.5,70 status resistance and40 movement speed. Its legacy MAGIC_IMMUNE state versus modern native debuff-immunity remains an explicit compatibility question. Native W is a movable attackable ward (2–5% regen/400radius/18–24s); custom W is intentionally a bounded stationary area (3–6%/500radius/12s). Native E35% chance/140–200% multiplier contrasts with tuned25–40%/200–300% plus60% attack splash. Native R uses attack-rate multiplier1.4; custom R deliberately uses direct physical spell damage at0.3s cadence plus50–110 bonus over3–4s. This differs from native attack procs; shared Scepter40% spell amp is attached to the correct ultimate inflictor in the ApplyDamage helper, but engine amplification/cooldown remains pending. Shared Fighter Shard35AS/25% movement slow/25AS slow for3s agrees with current English upgrade text. Fifth remains a separate Enfos kill passive rather than native12% frontal damage innate.

**210 behavior regressions and full project checks pass.** New tests check slash endpoints captured before lethal damage, release, native follow-up search flags, Fury start/stop ownership and friendly-heal rejection. Sound snapshot refreshed successfully from the actual128 decoded hero banks (164 literal events); an initial wrong-directory input was rejected and corrected. VFX/SFX/animation, native attack-record fields, immunity and max-rank HUD remain **ENGINE PENDING**. Source review continues with animation/tooltip and modern immunity comparison before marking this hero reviewed.

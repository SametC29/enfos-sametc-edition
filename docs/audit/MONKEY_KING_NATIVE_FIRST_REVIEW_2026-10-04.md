# Monkey King native-first discovery and pre-mutation matrix

SOURCE_REVIEW: discovery recorded; production migration NOT IMPLEMENTED.
AUTOMATED_VALIDATION: existing dossier validator only, not engine behavior.
OWNER_RUNTIME: PENDING, owner deferred live acceptance. Do not control Dota.

Installed Workshop build6943/revision11069754/Oct01 freshly read. Source:
`scripts/npc/heroes/npc_dota_hero_monkey_king.txt`, SHA256
`6d7a10c3601871804fe1a69420f26192f09ff2267e138eb9799371bd448313a6`.
Unchanged from old6941 snapshot; current build still revalidated. Strict full
hero parse succeeds. Nine definitions, three deprecated facets, native English
tokens and ten compiled model/bank/particle hashes are recorded in
[current snapshot](MONKEY_KING_NATIVE_SOURCE_2026-10-04.json).
Source/localization prove exposed data and described mechanics, not C++ calls.

## Existing connections and deficiencies

Five stable paid abilities use abilities/pve_kits.lua. Q applies spell physical
damage with a copied stun and Boss cap; no native attack/Jingu/True Strike flow.
W teleports then applies physical AoE; no tree perch, channel or motion arc.
E counts consecutive qualifying attacks globally across recipients, without a
per-target timeout, and copies charge damage/healing. R uses a periodic radial
spell-damage thinker; no soldiers, formation, native armor or leave-area expiry.
D is authored attack range/evasion, not the native active Mischief innate.
Several active/target paths lack current handle/server guards; retire only when
replaced by native ownership, otherwise repair focused lifetime defects.

hero KV overrides all native slots including auxiliary slots with generic_hidden;
native Tree Dance/Spring/Early/Mischief/Untransform/Transfiguration cannot be
assumed present. Existing heroes/innates.lua owns pre-XP free passive restore;
addon_game_mode_client.lua imports reviewed modifier_links only. Health is
read-only and the existing Aghanim manager owns periodic upgrade reconciliation.
Reuse those services; no new respawn loop, timer or global search. Existing
MonkeyKing bank and custom particles are precached; missing native roots must
be verified and added only in their implementation unit. English W/Q/E/D text
currently includes Turkish fallback; each changed unit must author four locales.

## Five-slot pre-mutation matrix

| Slot / stable ID | Native evidence and classification | Intended ownership / prerequisite |
| --- | --- | --- |
| Q enfos_mk_boundless_strike | TUNE; exact native Boundless Strike physical attack crit+flat damage/True Strike, point targeting/non-piercing/strong dispel, gesture ACT_DOTA_MK_STRIKE; current Q damage and Boss cap differ. | Prefer pure NATIVE alias with all explicit metadata/keys and ten-rank tuning; retire spell damage/stun/VFX/SFX copies and Boss cap. Linked native Jingu and Spring/Shard identities must be restored; actual native rank10/item/Jingu/Shard flow pending. |
| W enfos_mk_primal_spring | REPLACE copied teleport; native Tree Dance and dependent Primal Spring/early release restore recognizable tree/channel/leap identity. Spring magical/non-piercing/dispellable,1.75s channel, damage/slow proportional to channel. | NATIVE+MINIMAL EXT paid-rank/link controller candidate; keep stable paid ID/ten points, exact Tree Dance/Spring/Early providers and live tuning. Prove lookup/swap/cost/channel ordering before implementation; no copied motion/particles. Paid W may present Tree Dance with Spring while perched; no second paid skill. |
| E enfos_mk_jingu_mastery | PVE-CONVERT only native same-enemy-HERO acquisition restriction; native four charged attacks/damage/lifesteal preserved where viable. | Prefer NATIVE+MINIMAL EXT creep-acquisition bridge after native modifier/callback evidence. Do not assume target KV or global counter makes native Jingu creep-compatible. If C++ restriction is inaccessible, document evidence before a scoped custom acquisition fallback; no blind buff/heal reproduction. |
| R enfos_mk_wukongs_command | PVE-CONVERT native soldiers' HERO-only targeting; restore native formation/armor/leave-area expiry and Scepter rather than radial damage pulses. | Prefer NATIVE+MINIMAL EXT target conversion with bounded native5+9 soldiers, no extra manual spawn loop. Native AbilityUnitTargetType HERO is exposed but BASIC flag alone is not proof of C++ creep acquisition. Actual target filter/commands/Jingu/soldier ownership require evidence; no false native PvE PASS. |
| D enfos_mk_mischief | KEEP authored ten-rank range/evasion as match-local Enfos passive; separate native Mischief is innate active/not-learnable1, not a passive counterpart. | NATIVE+MINIMAL EXT kit composition: reviewed live defensive stat class, Break/illusion/source guards and free D1 unchanged; restore exact native Mischief/Untransform auxiliary abilities without extra points. Do not rename authored range/evasion to native effects. Native innate HUD/swap/level50 cooldown and auxiliary slot budget pending. |

These decisions supersede older copied implementation descriptions only when
their focused source unit lands. Preserve current five paid IDs, rank10 gates,
level50/level6 start/five points/freeD1/49 ordinary points; no talents/profiles.
Do not send native ten-rank linked providers unsupported ranks: paid rank bridges
and native caps need per-unit evidence. All former color/stride/faithful facets
are Deprecated=true; do not activate them from old descriptions. Native
Transfiguration is explicitly assigned Ability9 and described in current R,
despite its old deprecated facet: it needs current dependency/HUD inspection,
not automatic exclusion or silent extra paid rank.

## Native upgrades and technical gates

Shard belongs to Q, not generic Fighter D: current token says native35% Primal
Spring effects along/end of staff and optional leap. Native Q data contains
spring_channel_pct35 and leap constants; exact Spring provider is required.
Scepter belongs to native R: spawn interval4/duration15, independent soldier
Jingu charges and invisible/tree exclusions. Native R data also declares
cast_range_scepter1550 and cooldown_scepter90/70/50. Generic40% ultimate amp/
25%CDR and Fighter35AS/slow must be replaced only when respective native upgrade
unit is ready. No unsupported claims of native soldier creep targeting.

Native Jingu token explicitly requires four hits on the same enemy hero;
counter_duration5.5/7/8.5/10, charges4, max_duration35, bonus_damage30/80/130/180,
lifesteal20/40/60/80. Preserve per-target ownership and timeout; already-earned
buff Break/dispel behavior needs engine evidence instead of retaining the old
custom assumption. Native R regular formation5+9 and finite duration14 are
bounded, but dense-wave/permanent Scepter and cleanup still need owner tests.

## References and provenance

[ModDota native BaseClass/exposed KV guidance](https://moddota.com/abilities/ability-keyvalues)
re-read2026-10-04: exposed values can be inherited/tuned; internal C++ structure
is inaccessible. Installed source remains authoritative; guide is not runtime
certification. WORLD OF DOTA2880603428 exact extracted files fully read:
`scripts/vscripts/heroes/npc_dota_hero_monkey_king_custom/monkey_king_boundless_strike_custom.lua`
and `monkey_king_primal_spring_custom.lua`. REFERENCE_ONLY, license/version
unverified, NO imports. They reproduce attacks/motion/channel/particles and
depend on custom talent modifiers/generic arc/Jingu; reject wholesale transplant.
Their interrupt cleanup, target-bound attack flow and Spring early-release
dependency are useful review leads, not proof native C++ does the same.
Boss Survival1571786267 search exposes a Jingu #base declaration; ref_get and
ref_inspect confirm that source was not harvested. It is not a read/working
Jingu reference and cannot substantiate implementation or license claims.

## Source rollout and acceptance

Discovery changes docs/snapshot only. Next focused unit Q plus linked identity
research, then W/E/R/D according to dependency evidence; no blanket Lua rewrite.
For each unit record all acceptance rows, four-language tooltips, exact verified
assets/APIs, focused regressions and full suite at coherent delivery boundary.
Runtime tests: Q rank1/10/Jingu/items/Shard, W tree destruction/root/damage cooldown/
channel/early release, E same/different creeps/timeout/Break/charges/lifesteal,
R creep/Boss soldier attacks/armor/leave-area/Scepter/Jingu/Transfiguration,
D free rank/points/innate disguise/Untransform, then death/respawn/reconnect,
cold-load/animation/VFX/SFX/HUD/VConsole. Actual acceptance remains PENDING.
No changes to waves/Boss AI/global rules/Luna/contributors; local commits only.

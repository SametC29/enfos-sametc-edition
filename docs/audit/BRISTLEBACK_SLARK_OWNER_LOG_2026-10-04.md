# Owner Bristleback / Slark VConsole review

Source: owner attachment `c78f9275-4e38-4e9f-8975-f53470143474`,
SHA256 `45626b520714a7588f983e7e4c37c91c6c18a8051bcdb1dbe32bbd594e37fc2e`.
5634 lines including both matches and surrounding dashboard/load/unload traffic.
Observed server revision11069754. No chat/account identifiers are copied here.
Source at review: BB commits21600b3/a2506f7, Slark through0799e0c;
log does not contain a commit stamp, so exact loaded revision is not proven.

## Gameplay evidence

Owner clarification: W circular Quill Spray deals damage; the ground-targeted
Hairball does not. Aghanim/Scepter was not tested. This reopens Hairball's
engine gate; do not label W broken or claim the E error explains Hairball.
Warpath is the fifth authored passive; the owner's D key refers to Hairball
in this test. Distinguish physical keyboard binding from dossier slot names.

Bristleback selection is at lines1644–1657; Slark selection3793–3806.
Both matches progress through gameplay. Ten Script Runtime Error entries
occur, all the same BB controller GetCastRange failure, first line1814.
No additional Script Runtime Error entry identifies Slark. Absence of an
exception is not Slark gameplay/VFX/SFX/ten-rank acceptance.
No HERO_HEALTH/SF_HEALTH snapshot is present; neither initial ranks, native
provider existence nor actual/query damage can be certified from this log.

## Confirmed source repairs

1. E controller calls native `GetCastRange` from a HUD callback. The queried
   installed VScript API marks GetCastRange server-only (GetBehavior and
   FindAbilityByName are both-context). Log reports a nil method at line53.
   Client E range now returns0, matching its native self-origin cone/no explicit
   base range; server preserves native delegation. A fixture with the client
   method absent reproduces the condition and passes after the guard.
2. Hairball native alias declared only BaseClass/level/grant/behavior. It omitted
   installed target team/type, immunity/dispel, travel speed and all AbilityValues.
   Native C++ inheritance must not substitute for explicit KV data. The alias
   now supplies the exact installed target/cast fields, speed1200, default
   radius700/AoE metadata and1 Quill/2 Goo values. Existing paid-rank bridge
   continues to override authored radius400–500 and Goo2–3. Shard grant stays0.
   A source contract failed before repair on missing target-team data and now
   checks every copied field. This fixes a verified contract gap; causal
   confirmation of Hairball's reported zero damage remains OWNER TEST PENDING.
3. Health only attempted on npc_spawned and rejected a hero if authoritative
   selection was not ready. Keep that guard, retry through the already existing
   registered-hero loop, and stop after its once-per-entity marker. No new timer,
   global scan or gameplay mutation. A delayed-selection fixture now passes.
   BB reports native provider ranks and Quill/Hairball value queries. These
   queries do not prove actual native damage and may be0 before paid training.

## Other warnings reviewed

| Finding | Count | Interpretation / next evidence |
| --- | --- | --- |
| Invalid order26, target cannot be seen by the unit team |1543| Real repeated gameplay warning; first1891. Need producing caller/engine enum evidence; do not infer type from stale documentation numbers. |
| Invalid order27, target invisible and not allied |340| First3972, during Slark match. Native concealment and current wave acquisition must be examined together. |
| Missing `scripts/vscripts/teleport.lua` |16| Repeated map/load script reference, not a Slark ability exception. Locate compiled-map/source ownership before repair. |
| `underlord_portal_custom3.vpcf` blocking-load precache warning |6| Map/portal resource ownership needs review. Not evidence Hairball failed. |
| Compendium2023 teleport model missing sequences |56+56| Named native cosmetic teleport children; engine/resource warnings, no proven hero-code cause. |
| DOTANeutralItems/custom neutral KV load diagnostics |10 pairs| Inspect the neutral-item config before asserting harmlessness. |

Additional missing Underlord custom particle variants, miniboss reflection
particle and cosmetic/material/shader/localization/resource warnings appear
across startup and matches. Native cosmetic warnings should not be “fixed” by
inventing local replacements. Old retired TreeShop/CourierZone triggers are
reported removed successfully; no new TreeShop Lua exception is observed.

Current wave acquisition in `waves/creep_ai.lua` queries the defending team's
FRIENDLY units with FLAG_NONE, then orders attacks without attacker-side sight
or invisibility eligibility. This is a concrete source candidate for the
visibility spam, but the log lacks a caller trace. Record it for a focused
shared AI review; no boss/wave behavior changes are part of the Hairball repair.

## Retest

Full Dota restart is required for the Hairball provider KV update. Select BB,
train W and Hairball, then cast Hairball at a compact group within its aiming
circle. Compare enemy HP before/after, ordinary W, Goo application and Hairball
projectile/impact; supply the new console log. New automatic Health output should
appear without manual console code. Scepter/E, death/respawn, rank10 and Slark
full acceptance remain separate pending cases. Never replace this retest with
the source contract or positive special-value query.

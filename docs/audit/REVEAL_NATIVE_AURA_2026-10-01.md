# Reveal native aura follow-up — 2026-10-01

Status: IMPLEMENTED; AUTOMATED_PASS; ENGINE_PENDING.

Owner reports Reveal still fails to expose invisible creeps after the previous
defending-team correction. Owner separately confirms talent '+' is gone and
Boss death no longer causes resurrection; those issues are outside this repair.

The previous tests proved a direct `modifier_truesight` application call, not
actual visibility. The timer applied an engine-owned aura debuff without an
engine aura source. The runtime reason it failed remains unconfirmed: current
CreateModifierThinker API allows nil caster, so nil alone is not an API error.
An additional confirmed defect was reporting success even if no thinker existed.

TUNE: replace the manual application timer with an engine-managed aura returning
the same native `modifier_truesight`. The source uses the selected player hero,
links on both Lua sides, searches heroes/basic units including magic-immune and
invisible neutral hostiles, and rejects units outside the caster's defending
arena. Engine aura distance and lifecycle replace the module-local registry
poll. Team FOW, radius 900, duration 15, linger 0.75, cost and cooldown are retained.
Source/creation failure returns false through the existing mana/cooldown rollback;
expired thinkers are removed. No stealth modifier is globally removed.

Evidence reviewed: installed item_gem KV (native radius 900), installed VScript
CreateModifierThinker/aura APIs, Assassin permanent-invisibility KV (no True
Sight immunity), existing project aura patterns and Valve Overthrow visibility
reference. No third-party code/assets were imported. Earlier direct-application
and wrong-opposing-team conclusions in TRUE_SIGHT_2026-10-01.md are historical.

Validation: full working-tree `npm run check` passed; focused Reveal mock verifies
both teams, aura contract/filter, client registration, expiry, missing hero,
missing thinker/modifier and actual dispatch rollback. Contributor event test
fixtures were adapted in place and remain with their existing unstaged work.
These checks do not simulate native True Sight rendering or certify visibility.

Owner engine checks pending: Assassin begins on wave 11; cast on its position
for both teams, confirm visibility/targetability inside 900 units for 15 seconds,
no opposite-arena/outside-radius reveal, and loss of detection after expiry/linger.
No Dota was launched/controlled. Release without awaiting owner testing remains
authorized; runtime acceptance must not be claimed from package or mock checks.

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

## Native comparison requested by owner

Internet/API research refreshed after the owner's request. The installed API
explicitly defines GetAuraOwner as the emitter that applied an aura modifier;
it is nil on the client. GetModifierAura delegates the secondary modifier to
the engine. This supports choosing an emitter over manually attaching an aura
debuff, but does not prove that the old missing aura owner caused the failure.

| Aspect | Installed native Gem | Enfos Reveal |
| --- | --- | --- |
| Passive detection radius | 900 | Fixed ground aura, radius 900 |
| Active radius / duration | 300 / 4 seconds | 900 / 15 seconds by product design |
| Target relationship | Native engine team relationship | Neutral hostiles plus authoritative defendingTeam filter |
| Before this repair | Engine-managed source | Direct debuff refresh every 0.5 seconds |
| After this repair | Engine-managed source | Engine-managed secondary modifier with selected hero source |

Assassin uses MODIFIER_STATE_INVISIBLE, not AddNoDraw/model hiding or True Sight
immunity. Increasing FOW alone would not establish detection, and forcibly
disabling invisibility would reveal it beyond the intended team's detection.
Both shortcuts were excluded. No additional speculative fallback was shipped.

Primary API sources consulted:
- https://docs.moddota.com/lua_server/declaration
- https://github.com/TypeScriptToLua/Dota2Declarations/blob/master/dota-modifier-properties.d.ts

Valve Developer Community's data-driven ability page returned an internal
error during this web lookup; installed VPK/API values were used for current
engine identifiers and numeric values. Native C++ True Sight implementation
is not exposed by the inspected KV, so its complete internals are not claimed.

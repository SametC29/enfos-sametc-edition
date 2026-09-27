# Hero-specific Evolution candidate — 2026-09-28

40 hero profiles now provide six distinct ability-specific focuses across the
existing level 4/7/10/13/16/19 milestones. Each tier offers two choices (480 offered
choices overall); focuses repeat at two tiers, not twelve unique mechanics per hero.
The previous shared 750-HP/35-all-stat style bonuses are no longer selectable.

Choices modify live consumed ability values or a specific ability's cooldown.
Examples: Drow arrow count/range, Sven radius/armor, Medusa shield efficiency/jumps.
A single death-persistent replicated modifier encodes selections. Server selection
validates hero, milestone, level and choice ID. Reapplying history is idempotent;
client stat queries use the same encoded values and the engine no-override accessor.
Already-running cooldowns and snapshotted active buffs are not retroactively reset.
Some existing prose tooltips contain fixed generated values: cards state exact
bonuses, but full dynamic prose conversion remains a separate UI improvement.

Validation: all 480 choices, wrong hero/caster, duplicate and replacement rejection,
six-tier persistence and flat/percentage calculations under a mock engine. Generator
rejects unknown or unconsumed special fields. Four language token sets generated.
Full checks pass; engine behavior and balance still require local acceptance.

Local test: start a NEW match, reach level 4, check two skill-specific options;
choose one and test its actual radius/count/effect. Check next tiers, death and
reconnect do not double the bonus. Compare server effect with the displayed card.

Also: scheduled hostile cap and overflow Life damage removed at the user's request.
Crowded-lane mock test starts with 1,000 live enemies and delivers all wave-59
spawns for one/five players without population damage. Physical leaks and Boss
transition/deadline penalties remain. Engine performance at high counts unmeasured.

Remaining content: original Shard/Scepter upgrades, 30 distinct Ascended PvE
mechanics, remaining ability semantic discrepancies and distinct later Boss fights.
No Workshop upload and no engine playtest performed by this change.

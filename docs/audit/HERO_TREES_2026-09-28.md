# Historical: Hero-specific Evolution candidate — 2026-09-28

> Historical design and validation record. Superseded on 2026-09-30 by the
> user-directed native four-tier tree at levels 10/15/20/25. The current
> implementation no longer loads this document's custom six-tier drawer.
> See `DECISIONS_OPEN_ITEMS.md` for the active contract.

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

2026-09-30 HUD integration: all six Enfos tiers stay in their own server-authoritative
Evolution flow. The compact Panorama drawer opens from the native `StatBranch`
talent control when its click handler can be safely rebound; a separate Enfos button
is retained as fallback. This puts Enfos choices in the native talent-area flow,
but does not inject six rows into the engine-owned talent-tree panel. This distinction
matters: Sven's installed hero KV has eight native talent ability slots
(`Ability10`–`Ability17`, four pairs), while Enfos has six milestones at
4/7/10/13/16/19. Installed Dota Panorama assets include native stat-branch pips
for levels 10/15/20/25; `LevelUpTab` belongs to the separate ability-point control,
so only `StatBranch` is used as the trigger, with an independent HUD fallback if that
internal ID changes. The hook deliberately replaces the stock `StatBranch`
activation to open the Enfos drawer; it preserves native hover callbacks and does
not touch `LevelUpTab`. Thus the engine-owned talent popup is not opened by that
trigger while the Enfos hook is active. Panorama source compiled and automated
tree/HUD checks passed. Native
panel IDs remain undocumented and current-client placement, native-tree coexistence,
and click behavior still need an in-game owner test and remain PENDING.

Installed `pak01_dir.vpk` inspection on 2026-09-30: the compiled
`panorama/styles/hud/dota_hud_stat_branch.vcss_c` positions and styles the native
`DOTAStatBranch` popup and its four-pair branch controls; it exposes presentation
selectors such as `BranchPair` and `BranchChoice`, not a documented custom-tier
data hook. `panorama/layout/hud/dota_hud_stat_branch.vxml_c` and
`panorama/layout/ui_stat_branch.vxml_c` are compiled engine UI resources. This
supports the custom-drawer decision but does not prove the live panel can accept
injected children; runtime placement and interaction remain pending.

The same installed VPK's `scripts/npc/heroes/npc_dota_hero_sven.txt` assigns the
eight native talent abilities in `Ability10`–`Ability17`. Enfos' Sven override
sets those slots to `generic_hidden` and keeps six Evolution tiers in the separate
server-authoritative system. Replacing those eight native slots with six Enfos
tiers would discard four native talent pairs and still would not reproduce the
Enfos level-4/7/10/13/16/19 schedule; the custom drawer keeps both progress models
separate and intact.

Local runtime acceptance (still PENDING): start a fresh match with the rebuilt
addon and open the native talent control. Expected behavior while the Enfos hook
is active: that control opens the six-tier Enfos drawer in the talent area instead
of the stock popup; the separate Enfos launcher remains available until this
native click has been observed. At level 4, verify the first tier offers two
Sven-specific choices and later locked tiers cannot be selected. Select one,
confirm the row becomes selected and its displayed effect matches the actual
ability behavior, then try a duplicate and an out-of-order/locked selection.
Confirm `LevelUpTab` still spends normal ability points. Defer and reopen the
drawer, then check level 7 and later tiers, death/reconnect idempotency, and the
VConsole for Panorama, Lua, localization or native-panel errors. Capture the
opened tree and console output; mock tests are not engine evidence.

Also: scheduled hostile cap and overflow Life damage removed at the user's request.
Crowded-lane mock test starts with 1,000 live enemies and delivers all wave-59
spawns for one/five players without population damage. Physical leaks and Boss
transition/deadline penalties remain. Engine performance at high counts unmeasured.

Remaining content: original Shard/Scepter upgrades, 30 distinct Ascended PvE
mechanics, remaining ability semantic discrepancies and distinct later Boss fights.
No Workshop upload and no engine playtest performed by this change.

Reference-only UI study — Watcher of Samsara (Workshop 3164617180): inspected
`panorama/layout/custom_game/elements/stat_branch/stat_branch.js` and
`panorama/layout/custom_game/elements/stat_branch_drawer/stat_branch_drawer.js`,
plus the drawer stylesheet and `panorama/styles/custom_game/hud_main.css`.
Watcher wires its own stat-branch control to local Panorama events, then renders
a separate drawer with four pairs of `special_bonus_` abilities and sends its
own `LearningTalent` request after checking the chosen branch. This is evidence
that a custom game can give a custom drawer the native talent-tree visual role;
it does not show that six Enfos milestones can be inserted into Dota's engine
talent popup. Its code and bundled assets were not imported; the game's license
and compatibility for reuse were not established. Classification:
`REFERENCE_ONLY`.
Its drawer also takes input focus while open and binds Escape to close; Enfos
now follows that interaction pattern and releases focus on close.

## Superseding native-tree implementation — 2026-09-30

Each of the 40 heroes now maps four Enfos pairs to Dota's native talent slots
`Ability10`–`Ability17`: profile pairs `[0,1]`, `[2,3]`, `[4,5]`, `[3,4]` at
levels 10/15/20/25. Thus each tree presents eight choices and allows four picks,
while retaining all six unique skill-focus effects per hero. The data generator
creates 320 `special_bonus_base` abilities, localizes their titles and
descriptions in EN/TR/RU/zh-CN, and hides legacy `Ability19` and current
`Ability25` attribute slots. The custom drawer is no longer in the active
Panorama manifest; Dota owns the visible selection panel.

The server listens for `dota_player_learned_ability`, verifies the hero, level,
and canonical talent ID, then applies the matching choice through the existing
replicated Evolution modifier. A one-time extra ability point at each native
gate funds the four talent selections. The total is 53 points by level 50:
49 paid skill ranks (the passive's first rank is free) plus four talents. Source
checks, mocks, and content compilation do not establish native runtime behavior;
selection, point timing, hidden attribute slot, and all four ability effects
remain PENDING owner Dota testing.

Owner screenshots from the V1.0.3 playtest later showed talent icons in the
regular ability bar and blank native tree labels. The installed Dota base
`npc_abilities.txt` documents `PASSIVE` as visible on the HUD and
`PASSIVE | HIDDEN` as hidden; the native `special_bonus_attributes` definition
uses that hidden combination. The generated Enfos talent definitions had only
`PASSIVE`. The generator now emits `PASSIVE | HIDDEN` and `MaxLevel 1` for every
talent, and a 40-hero contract asserts both fields. Full automated checks and
Source 2 content compilation pass. The `+2` control comes from Dota's newer
`Ability25` attribute ability; the old implementation suppressed only
`Ability19`. The generator now sets both slots to `generic_hidden` across all 40
heroes. Valve's 7.29 patch notes identify `Ability25` as the
`special_bonus_attributes` slot ([patch record](https://steamdb.info/patchnotes/6517216/)).
The installed VPK's English ability localization uses the lowercase
`DOTA_Tooltip_ability_` prefix. All 320 talent title/description pairs are now
checked for that exact key in all four `resource` and Panorama localization
files, in addition to the project aliases.
The blank labels and actual attribute suppression still need the owner's live
retest; no Dota runtime acceptance or Workshop upload is claimed.

Additional `REFERENCE_ONLY` code-pattern study — AvondaleZPR/talent_tree on
GitHub: its README describes arbitrary talent branches, per-hero hidden talent
abilities and configurable point issuance. Its documented setup mounts a custom
HUD `CustomUIElement` and has a separately positioned `TalentTreeWindowButton`;
it is a custom Panorama talent tree, not an extension of the engine-owned popup.
This supports keeping Enfos' six choices data-driven and custom-rendered while
preserving server-side validation. No source or assets were imported; a reuse
license and compatibility scope were not established.

Enfos design consequence: keep the six server-authoritative Evolution tiers in a
custom Panorama drawer
that is visually and spatially integrated with the native talent area. The
Enfos drawer now binds its toggle to the native `StatBranch` activation when the
panel and `ClearPanelEvent`/`SetPanelEvent` methods exist, so the native talent-area
trigger opens the six-tier Enfos tree in place of the engine-owned popup. The
native `StatBranch` activation is replaced; `LevelUpTab` remains untouched so
ability-point spending is preserved, and native hover handlers remain intact.
If the expected branch panel or methods are absent, the clearly branded Enfos
launcher remains visible beside the talent area. Even when the hook is installed,
the fallback stays visible until the native control actually invokes it once; a
matching panel ID alone is not runtime evidence. This uses an undocumented,
patch-sensitive HUD hook (as do the shipping-game examples), not an engine API.
The hook is reapplied by a low-frequency HUD poll so a replaced panel or reset
native activation handler can be rebound; the HUD mock simulates that reset.
This is offline coverage only and does not establish that the live client keeps
the hook or positions the drawer correctly.
The VPK's `#StatBranchOuter` centers the native popup; Enfos' drawer is now
screen-centered while only the fallback launcher follows the native icon.
Responsive layout coverage caught and fixed a max-height/position mismatch at
800×600; HUD mocks now check centered placement and in-bounds geometry at
640×480, 800×600, 1280×720 and 1920×1080.
The installed VPK's `#DOTAStatBranch` CSS selector styles the popup drawer, so
the hook deliberately targets only the `StatBranch` trigger and never the popup
container.
Current-client placement, handler behavior, and native-tree coexistence remain
PENDING until tested in Dota.

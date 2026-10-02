# Dazzle individual review — in progress / owner engine pending

Own AGENTS/full ABILITIES, shared research/hero/reference contracts read. All five current Lua/KV slots and Weave helper read; native definitions freshly extracted from installed ClientVersion6943 / SourceRevision11069754 / Oct01 2026. Historical6941 dossier does not certify the current patch. Local commits only; agent does not launch Dota or upload Workshop.

| Ability | Classification and installed native comparison |
| --- | --- |
| Q Poison Touch | PVE-CONVERT: native enemy-target cone,1300speed projectiles,2→8targets16→52physical DPS/3.5→8duration/13→22%slow,own-attack refresh/ramp. Enfos immediate no-target700radial8targets30→90+0.35INTphysical DPS/6sec/25%slow plus2per own attack up to35extra. Cone/projectile deviation retained for evidence-led review, not called native parity. |
| W Shallow Grave | PVE-CONVERT: native friendly heroes900range4→5.5sec,non-dispellable/ally-immune. Enfos friendly heroes/basic700range4.5→6sec,40%fixed heal amplification and one-health floor. Native heal_amplify3→9 is not the same scalar policy as this custom40%. Protection visual/dispel lifetime audited below. |
| E Shadow Wave | PVE-CONVERT: native475bounce185damage radius85→145physical damage/healing,3→6targets plus Dazzle, Scepter upgraded mode. Enfos six jumps plus initial500bounce200damage radius90→210+1INT heal/physical damage per recipient. Shared enemy query currently omits immune flag despite piercing KV; targeting and link effect under review. |
| R Bad Juju | REPLACE: current roster ultimate is Nothl Projection; installed archive also retains legacy bad_juju definition (3secCD/75flatHP/4→6CDR). Enfos uses10%current HP,600ally/enemy armor±5/8sec,passive1→2sec other-ability CDR. No projection/body/spirit mechanics; current generic Scepter damage wording needs review because R deals no direct damage. |
| Fifth Nothl Weave | PVE-CONVERT: native innate armor1/6.9sec+0.1perlevel and ally/enemy ability triggers,Shard ally heal60. Enfos2→4armor per stack,5stackcap/6sec/Break suppression; helper called on affected Q/W/E/R recipients. Rank/free grant, different-caster stacking/refresh, owned armor feedback and passive wording remain under review. |

## Grave protection effect and dispel policy

Old cast allocated/released native Grave root without a modifier lifetime owner. Installed6943 decoded root includes playerglow child with endcap-only alpha termination; other children have finite3.5sec emissions. A finite sub-emitter does not establish termination of the whole root. Native modifier lifetime must own ongoing protection feedback, especially for custom4.5→6sec duration, target death/recast and early removal.

MCP reference-only review of Boss Survival1571786267 `heroes/hero_dazzle/hero_dazzle.lua` directly shows GetEffectName/ABSORIGIN_FOLLOW and non-purgable Grave modifier. External revision/license/current runtime unknown: no code/assets imported. Installed native W independently declares SPELL_DISPELLABLE_NO and SPELL_IMMUNITY_ALLIES_YES; [particle attachment guide](https://moddota.com/scripting/particle-attachment) explains modifier-owned cleanup.

Focused repair moves the already precached root into the protection modifier's effect/attachment callbacks, explicitly makes it non-purgable and aligns W KV with native ally-immunity/non-dispellable policy. Keep expanded friendly-basic targeting, health floor, configured healing amplification and duration. No guessed CP1 halo-height override: current root has authored PreEmission control positions and actual height remains an owner visual gate.

Extended existing positive save/heal regression first fails on standalone particle allocation, then requires no manual allocation, exact owned root/attachment and non-purgability while preserving1HPfloor/configured30%mock heal amplification. Actual lethal Boss damage/kill exceptions, immune allied targets, dispel, halo height, death/recast/expiry and cold-start VConsole remain OWNER ENGINE PENDING.

Grave repair full checks:244behavior regressions,200abilities/223modifiers across ranks1–10,0failed checks. Source/mock only.

## Shadow Wave piercing query

Installed6943 native E and existing custom KV both declare physical damage with SPELL_IMMUNITY_ENEMIES_YES. Its shared radius query nevertheless used FLAG_NONE, excluding immune enemies before physical damage was applied. MCP current enum index confirms MAGIC_IMMUNE_ENEMIES; [KV targeting guide](https://moddota.com/abilities/ability-keyvalues) distinguishes targeting flags from damage/immunity metadata. No new piercing balance policy: align radius selection with the existing native/custom policy.

Expanded existing heal/bounce regression with one immune and two ordinary enemies, using a flag-aware query fixture. Before repair the immune unit is omitted; after the E-local query flag it receives the same configured250physical damage while the ally still heals250 and receives first Weave armor stack. Other abilities/global query defaults unchanged. Actual debuff immunity and armor-stack behavior on immune Bosses remain owner engine pending.

# Native Boss dependency delivery — 2026-10-01

Status: IMPLEMENTED BUT NOT ENGINE-VERIFIED.

The owner's candidate already replaces themed Boss units with twelve native
roster heroes. The resource fix must load those exact IDs, while the themed
template remains the source of rewards and balance. These dependencies are now
delivered together: authored mapping, native kit preparation/registration,
reward-template aliases, Boss Life penalty independent of unit name, and route
AI recognition/cast preservation. This delivers the existing candidate's Boss
behavior; it does not introduce new player hero skill changes or new Boss kits.

The all-twelve model verifier reads the installed native hero files and confirms
their actual Model fields resolve in the VPK. Unit-level asynchronous precache
owns the full resource load; base-model existence alone does not certify
wearables/materials/rendering. See `BOSS_RESOURCE_GATE_2026-10-01.md`.

`tools/tests/native_boss_pipeline.test.mjs` exercises the production spawn,
reward and leak pipeline with explicit preparation/registration/route stubs.
For every mapped hero it asserts one Boss, template identity, preparation before
balance/registration/route, preserved bounty/XP and five-Life leak, plus cleanup
when preparation fails. The production native kit implementation is tested
separately by `tools/native_boss_kit_audit.mjs` against the installed-data
snapshot for all twelve heroes. These complementary mocks do not certify live
casts or resource rendering. No external code/assets were imported here.

Owner runtime test remains all twelve Boss waves, both arenas/second client,
cold resource load, visible native models at intended scale, no ERROR/resource
warnings, ordinary kill/leak rewards and preserved casts/movement. The pending
status applies to gameplay, VFX/SFX, modifiers, precache and cleanup; none is
promoted to ENGINE_PASS by these automated results.

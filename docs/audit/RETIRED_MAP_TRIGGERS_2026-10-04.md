# Retired TreeShop / CourierZone map I/O — 2026-10-04

Problem: owner removed wood TreeShop and couriers, but their trigger bindings
remain embedded in the approved compiled Survival VPK. Latest owner attachment
86de2921-3b0e-45d5-8a6a-6232a6d6ca6e contains missing wood_system.lua and
courier_safe_zone.lua loads before addon Activate, then nil TreeShop touch
callbacks. Earlier supplied logs also contain CourierZone_Enter/Leave faults.
Solo play is not the cause; obsolete map I/O calls removed scripts.

Evidence: [entity ledger](RETIRED_MAP_TRIGGERS.json) records the approved map
SHA256 and decoded entity resource SHA256, matching the existing healing-map
extraction. Source IDs 22/140/141 are obsolete trigger_dota areas; source ID 20
is a native trigger_shop and is preserved. Runtime names omit the authored
[PR#] prefix, so exact lookups cover both forms. The compiled VPK and its
ten-file theme manifest remain unchanged. No missing VMAP is reconstructed.

Research: [Valve trigger script documentation](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Simple_Trigger_that_calls_Lua)
establishes entity script paths and CallScriptFunction bindings. Current
Workshop MCP API metadata verifies CEntities:FindAllByName, CEntityInstance
GetName/GetClassname and UTIL_Remove; [API reference](https://docs.moddota.com/lua_server/)
provides corroboration. No external gameplay source imported.

Implementation: small retirement adapters occupy the two exact map script
paths, resolving startup loads and old I/O callbacks. They only request removal
of an exact-name trigger_dota; they grant no resources, shop access, courier
protection or units. InitGameMode calls map/retired_triggers once before native
shop initialization, removing both courier triggers and the wood trigger.
Callbacks use the trigger/scope entity, never the entering hero. An entity
flag prevents repeated queued removals. No timer, event listener or recurring
entity scan is added. Native trigger_shop, native shop and Ascended purchasing
are preserved.

Tests: three focused regressions pass: both courier instances, prefix handling,
native shop/unrelated entity preservation, client authority guard, duplicate
init/callback idempotence, pre-Activate script loading, missing callback handles,
map hash and startup ordering. Approved map/theme integrity also passes.
Full `npm.cmd run check` passes with 0 failed checks, including native shop,
Ascended shop, hero regressions, wave pressure and native Boss kit mock checks.

Result: **IMPLEMENTED BUT NOT ENGINE-VERIFIED**. Owner should fully restart
Dota/Workshop Tools, start Enfos, walk through the old wood/courier areas, buy
an ordinary item and check Ascended access. Supply VConsole: no missing script
loads or TreeShop/CourierZone nil callbacks should remain; startup should show
`[INFO][map] Retired legacy TreeShop/CourierZone triggers: removed=3` for this
map. The exact native removal timing and entity script scope are engine tests,
not established by mocks. No new engine-control command, remote push, deployment
or Workshop publication is performed. Independent Boss modifier errors are
outside this change.

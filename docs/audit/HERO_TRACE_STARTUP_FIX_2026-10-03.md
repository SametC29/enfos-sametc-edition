# Hero trace startup fatal — owner evidence, 2026-10-03

Owner screenshot while testing Lich/Venge reports: FATAL ERROR: RegisterConVar: Unknown error registering convar "enfos_hero_trace".

Confirmed call site: lib/hero_trace.lua previously invoked Convars:RegisterConvar at module import unconditionally whenever the API existed. Shared module is imported by monolith bootstrap, isolated Lich/Venge skills and Aghanim manager; abilities load in client/server contexts and across reload/match lifecycle. Whether the actual C++ rejection was duplicate registration, client context or another engine restriction is not established by the screenshot. A successful API mock never proved engine registration support. Native fatal dialogs are not safely recoverable with Lua pcall, so merely wrapping or renaming the registration is insufficient evidence of repair.

[ModDota Convars API](https://docs.moddota.com/lua_server/) plus current MCP API document RegisterConvar/GetBool and nil for a missing variable; they do not promise import/reload idempotence or recovery from fatal C++ registration.

## Focused repair

Remove registration entirely. Server-only explicit boolean Trace:SetEnabled controls diagnostics via existing server script command:

- Enable: script require('lib/hero_trace'):SetEnabled(true)
- Disable: script require('lib/hero_trace'):SetEnabled(false)

Fresh module default is off. For compatibility, only when no explicit Lua override exists, read an optional already-owned old convar via protected GetBool; no create/reset/set operation occurs. SetEnabled(false) explicitly disables even if a legacy variable is enabled. No gameplay timers/entities/modifiers/damage/state changed. Shared 100-lines/game-second cap and safe entity labels are preserved.

Independent regression rejects ANY registration call, imports repeatedly in alternating client/server context, verifies default-off, server toggle, rejected client/nonboolean toggles and no disabled output. Before change fixture failed at the production import's registration call; after change PASS. Existing old tests were amended to forbid registration instead of treating a stub accepting it as engine proof.

Owner local addon is a junction to this workspace game directory, so fresh local startup uses the changed file; no Workshop publication. A fresh local match/Tools restart is needed to eliminate already-loaded old Lua. Actual owner restart and VConsole absence of the fatal remain PENDING. Lich/Venge gameplay, resource and visual/audio gates remain NOT TESTED; startup repair does not certify their kits.

Validation: full node tools/checks.mjs PASS, 0 failed checks. SHA256 of repository and installed junction hero_trace.lua both 00CA8F2EAD7C84342838EBA7BB25974E36DE90FB440B08858333A41044EF0DDD. Targeted regression also covers missing/erroring legacy cvar, explicit-off precedence and retained shared output cap. Engine restart remains owner PENDING.

# P0 runtime health probe

Use `script_reload_code tools/p0_health` in the local Workshop Tools console.
This read-only probe reports the engine state, map and each connected player's
selected hero, level, alive state and spendable skill points. It does not start
waves, change hero ranks, grant resources or alter gameplay.

The installed Dota build tested on 2026-10-02 does not register the standalone
`script` console command. An empty response to that command is not a passing
Lua test. The supported `script_reload_code` command executes the probe.

Keep one live VConsole reader attached before loading the custom map and save
the complete PRNT stream. A TCP connection with no echo response cannot certify
an error-free run. Wait through the requested capture interval: client echo
sentinels may precede delayed server diagnostics. Include unknown commands,
invalid orders and resource-load failures when reviewing error output.

P0 certifies the development/test toolchain. Gameplay acceptance remains a
separate gate; preserve nonfatal resource and AI diagnostics for that gate.

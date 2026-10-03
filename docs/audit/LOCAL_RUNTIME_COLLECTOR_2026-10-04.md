# Local runtime collector pilot

Owner2026-10-04 explicitly chooses local preparation because no server/domain
is available. This is an optional diagnostic collector, not a profile/backend
required for gameplay and not a full remote VConsole file uploader.

## Run locally

```text
node tools/runtime_collector.mjs
```

This binds ONLY127.0.0.1:18765. Validated records append to daily JSONL files
under .runtime-collection (Git ignored). Optional first argument selects another
output folder. Stop with Ctrl+C. No service was left running by the agent.

After starting the receiver, set enabled=true in
`game/scripts/vscripts/heroes/runtime_collection_config.lua` and start a new
local Dota test match. Defaults remain disabled; no HTTP traffic is sent until
explicitly enabled. The sender uses verified CreateHTTPRequestScriptVM,
SetHTTPRequestGetOrPostParameter, SetHTTPRequestAbsoluteTimeoutMS and Send APIs.
Installed metadata confirms availability. Dota HTTP delivery is pending owner
engine verification; Node HTTP integration and sender mocks are not engine proof.

Loopback means the computer RUNNING THE DOTA GAME SERVER, not necessarily the
owner player's PC. If the game server runs locally, all heroes in that local
match can be sampled. A Valve-hosted or another player's remote match cannot
reach the owner's collector at127.0.0.1. Public automatic collection later
requires an accessible hosted endpoint, appropriate deployment/security and
separate game distribution. No tunnel, public exposure, Workshop upload or
remote publication is performed or authorized by this local pilot.

## Scope and failure behavior

Version1 receives hero ID, level, points and five paid ranks. The receiver derives
ability IDs from production roster KV; unknown heroes, unknown/duplicate fields,
invalid ranks and oversized bodies are rejected. No account IDs, player names,
chat, raw console files, paths or IP addresses are stored in the event. These
are initial state observations; they cannot establish all skill-use/death/VFX
coverage or classify unobserved gameplay as passing.

Server health reports trigger optional HTTP sends. At most10 attempts per VM,
one per hero entity, at most10 pending and1.5-second total timeout. No retries,
periodic scan, gameplay timers, persistent progression or dependency on HTTP
success. Collector absence/transport exceptions do not escape into spawning.
Disk failure returns503 rather than claiming receipt. Loopback receiver body
limit4KiB, request/header timeout5s and max16 connections. Public deployment
needs additional protection and retention; this local service must not simply
be exposed to the internet as-is.

Three collector checks pass: strict field/rank validation; actual local HTTP
acceptance plus disk failure response; disabled/client/bounded/failed sender.
Nine shared health/SF integration checks also pass. Engine delivery and any
remote collection remain pending.

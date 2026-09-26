// Optional local MCP bridge for repeatable engine checks. No bundled/private server path.
import path from 'node:path';
import { pathToFileURL } from 'node:url';
const serverRoot = process.env.DOTA2_WORKSHOP_MCP_DIR;
if (!serverRoot) throw new Error('Set DOTA2_WORKSHOP_MCP_DIR to your built Dota2_Workshop_MCP directory.');
const sdk = path.join(serverRoot, 'node_modules/@modelcontextprotocol/sdk/dist/esm/client');
const { Client } = await import(pathToFileURL(path.join(sdk, 'index.js')));
const { StdioClientTransport } = await import(pathToFileURL(path.join(sdk, 'stdio.js')));
const client = new Client({ name: 'enfos-local-validation', version: '1.0.0' });
try {
  await client.connect(new StdioClientTransport({
    command: process.execPath, args: [path.join(serverRoot, 'dist/index.js')],
    env: { ...process.env, DOTA2_ADDON_DIR: process.cwd() },
  }));
  const command = process.argv.slice(2).join(' ');
  // A fresh VConsole connection replays its log, including old MCP sentinels.
  // Drain that replay before sending the command so it cannot masquerade as a reply.
  if (command) await client.callTool({ name: 'dota_status', arguments: {} });
  const result = await client.callTool(command ? {
    name: 'dota_send_console_command', arguments: { command, waitMs: 2500 },
  } : { name: 'dota_status', arguments: {} });
  if (result.isError) { console.error(JSON.stringify(result)); process.exitCode = 1; }
  else if (command) {
    // Exclude unrelated engine startup account/network diagnostics.
    const lines = result.structuredContent?.output ?? [];
    const relevant = lines.filter(line => /ENFOS_TEST|CODEX_|enfos|script error|stack traceback|\.lua:\d+|unknown command/i.test(line));
    console.log(relevant.join('\n') || '(No matching validation output; this is not a pass.)');
  } else console.log(JSON.stringify(result.structuredContent));
} finally { await client.close(); }

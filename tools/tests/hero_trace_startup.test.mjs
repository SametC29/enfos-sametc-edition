import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Diagnostic import never registers an engine ConVar across server, client or reload',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true;function IsServer()return server end
local registrations=0
Convars={RegisterConvar=function()registrations=registrations+1;error('FATAL RegisterConVar must never be entered')end,
 GetBool=function()return nil end}
local lines={};local realprint=print;function print(s)lines[#lines+1]=s end
GameRules={GetGameTime=function()return 100 end}
for i=1,4 do
 server=i%2==1;package.loaded['lib/hero_trace']=nil
 local t=require('lib/hero_trace')
 assert(not t:Enabled(),'Fresh diagnostics must be disabled')
 t:Log('LICH','E','disabled');assert(#lines==0)
end
assert(registrations==0)
server=true;local t=require('lib/hero_trace')
assert(t:SetEnabled(true)==true and t:Enabled())
t:Log('VENGEFUL_SPIRIT','W','cast');assert(#lines==1)
server=false;assert(t:SetEnabled(true)==false and not t:Enabled())
t:Log('LICH','E','client');assert(#lines==1)
server=true;t:SetEnabled(false);assert(not t:Enabled())
t:Log('LICH','E','disabled');assert(#lines==1)
assert(t:SetEnabled('1')==false,'Only explicit boolean can enable diagnostics')
Convars.GetBool=function()return true end
assert(not t:Enabled(),'Explicit off overrides an older enabled host cvar')
package.loaded['lib/hero_trace']=nil;local legacy=require('lib/hero_trace')
assert(legacy:Enabled(),'Read-only existing host flag compatibility')
Convars.GetBool=function()error('Missing host cvar')end
assert(not legacy:Enabled(),'Missing/erroring optional cvar is disabled')
Convars=nil;assert(not legacy:Enabled())
legacy:SetEnabled(true)
for i=1,150 do legacy:Log('LICH','E','bounded')end
assert(#lines==101,'Lua toggle must retain 100 lines per clock second cap')
realprint('Trace startup without ConVar registration PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Trace startup without ConVar registration PASS/,r.stderr);
});

import test from 'node:test';
import assert from 'node:assert/strict';
import {createCollector,loadRoster,validateSnapshot}from'../runtime_collector.mjs';
import {spawnSync}from'node:child_process';
const roster=await loadRoster();
const body=new URLSearchParams({schema_version:'1',hero:'npc_dota_hero_nevermore',level:'6',points:'5',ranks:'0,0,0,0,1'});
test('snapshot whitelist rejects identity fields, duplicate parameters and invalid ranks',()=>{
assert.equal(validateSnapshot(body,roster).abilities.length,5);
for(const field of ['steam_id','chat','raw_log']){const f=new URLSearchParams(body);f.set(field,'secret');assert.throws(()=>validateSnapshot(f,roster));}
const duplicate=new URLSearchParams(body);duplicate.append('hero','npc_dota_hero_luna');assert.throws(()=>validateSnapshot(duplicate,roster));
const bad=new URLSearchParams(body);bad.set('ranks','0,0,0,0,99');assert.throws(()=>validateSnapshot(bad,roster));
});
test('local receiver stores validated snapshots and storage failures return503 without acknowledging success',async()=>{
const events=[];let fail=false;
const s=createCollector({roster,store:async event=>{if(fail)throw Error('disk failure');events.push(event);}});
await new Promise(resolve=>s.listen(0,'127.0.0.1',resolve));
try{
const url=`http://127.0.0.1:${s.address().port}/v1/hero-snapshots`;
assert.equal((await fetch(url,{method:'POST',body})).status,202);assert.equal(events.length,1);
assert.equal(events[0].hero,'npc_dota_hero_nevermore');assert.ok(events[0].receivedAt);
fail=true;assert.equal((await fetch(url,{method:'POST',body})).status,503);
assert.equal((await fetch(url)).status,404);
assert.equal((await fetch(url,{method:'POST',body:'not a form'})).status,415);
}finally{await new Promise(resolve=>s.close(resolve));}
});
test('Dota sender is opt-in, bounded, one-attempt per entity and safe when transport fails',()=>{
const input=`package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true
function IsServer()return server end
local config=require('heroes/runtime_collection_config')
local C=require('heroes/runtime_collection')
local calls=0
local entry={id='npc_dota_hero_nevermore',abilities={'q','w','e','r','d'}}
local function hero()return {GetLevel=function()return 6 end,GetAbilityPoints=function()return 5 end,
FindAbilityByName=function()return {IsNull=function()return false end,GetLevel=function()return 1 end}end}end
local sentFields={}
CreateHTTPRequestScriptVM=function(method,url)
calls=calls+1;assert(method=='POST' and url==config.endpoint)
return {SetHTTPRequestAbsoluteTimeoutMS=function(_,v)assert(v==1500)end,
SetHTTPRequestGetOrPostParameter=function(_,key,value)sentFields[key]=value end,
Send=function()error('transport failure')end}
end
assert(not C.RecordHero(hero(),entry) and calls==0)
config.enabled=true
local h=hero();assert(not C.RecordHero(h,entry) and calls==1 and C.pending==0)
assert(not C.RecordHero(h,entry) and calls==1)
for i=1,30 do C.RecordHero(hero(),entry)end
assert(calls==10 and C.pending==0)
assert(sentFields.hero==entry.id and sentFields.ranks=='1,1,1,1,1' and sentFields.steam_id==nil)
server=false;assert(not C.RecordHero(hero(),entry))
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});

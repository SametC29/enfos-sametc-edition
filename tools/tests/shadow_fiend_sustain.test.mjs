import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
const a=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_sf_feast_of_souls;

function lua(body){
 const script=`package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true
function IsServer()return server end
MODIFIER_EVENT_ON_DEATH=1
local links=0
function LinkLuaModifier(name,path)
 assert((name=='modifier_enfos_sf_feast_of_souls_passive' and path=='abilities/heroes/nevermore/d')
 or (name=='modifier_enfos_sf_native_scaling' and path=='abilities/heroes/nevermore/modifiers'));links=links+1
end
require('abilities/heroes/nevermore/modifier_links')
local rank=1
local ability={IsNull=function()return false end,GetLevel=function()return rank end,
 GetSpecialValueFor=function(_,key)
 if key=='hp_per_kill' then return ({${a.AbilityValues.hp_per_kill.split(' ').join(',')}})[rank] end
 assert(key=='mana_per_kill');return ({${a.AbilityValues.mana_per_kill.split(' ').join(',')}})[rank]
 end}
local dead,broken,illusion,deleted=false,false,false,false
local heals,mana=0,0
local caster={IsNull=function()return deleted end,IsAlive=function()return not dead end,
 PassivesDisabled=function()return broken end,IsIllusion=function()return illusion end,
 GetTeamNumber=function()return 2 end,Heal=function(_,amount)heals=heals+amount end,
 GiveMana=function(_,amount)mana=mana+amount end}
local victim={IsNull=function()return false end,GetTeamNumber=function()return 3 end,IsIllusion=function()return false end}
local d=setmetatable({GetParent=function()return caster end,GetAbility=function()return ability end},modifier_enfos_sf_feast_of_souls_passive)
local event={attacker=caster,unit=victim}
${body}`;
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:script});
 assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
}

test('SF sustain uses current paid ranks and rejects dead/Broken/illusion/untrained or removed sources',()=>lua(`
d:OnDeath(event);assert(heals==25 and mana==15)
rank=10;d:OnDeath(event);assert(heals==95 and mana==57)
for _,state in ipairs({'dead','broken','illusion','deleted','untrained'})do
 dead=state=='dead';broken=state=='broken';illusion=state=='illusion';deleted=state=='deleted';rank=state=='untrained' and 0 or 10
 d:OnDeath(event);assert(heals==95 and mana==57,state)
end
`));

test('SF sustain rejects friendly, illusion, removed, self and unrelated kills; heal invalidation stops mana',()=>lua(`
victim.GetTeamNumber=function()return 2 end;d:OnDeath(event)
victim.GetTeamNumber=function()return 3 end;victim.IsIllusion=function()return true end;d:OnDeath(event)
victim.IsIllusion=function()return false end;victim.IsNull=function()return true end;d:OnDeath(event)
victim.IsNull=function()return false end;d:OnDeath({attacker=caster,unit=caster})
d:OnDeath({attacker=victim,unit=victim});d:OnDeath(nil)
assert(heals==0 and mana==0)
caster.Heal=function(_,amount)heals=heals+amount;deleted=true end
d:OnDeath(event);assert(heals==25 and mana==0)
`));

test('SF class registration is idempotent and client events never call server-only APIs',()=>lua(`
require('abilities/heroes/nevermore/modifier_links');assert(links==2)
server=false;caster.IsAlive=function()error('server-only API')end
d.GetParent=function()error('client event must be inert before any handle lookup')end
d:OnDeath(event);assert(heals==0 and mana==0)
assert(d:IsHidden() and not d:IsPurgable())
`));

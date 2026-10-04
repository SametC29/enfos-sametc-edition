import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Tidehunter damage callback uses the shared Shard check on engine hero handles',()=>{
  const script=`package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)return t end
MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL=1;MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE=2
MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE=3;MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT=4
MODIFIER_EVENT_ON_TAKEDAMAGE=5;MODIFIER_EVENT_ON_DEATH=6
local shard=false;local calls=0
package.loaded['heroes/aghanim_manager']={HasShard=function(_,hero)calls=calls+1;return shard end}
function IsServer()return true end
GameRules={GetGameTime=function()return 1 end}
dofile('game/scripts/vscripts/abilities/heroes/tidehunter/modifiers.lua')
local hero={IsNull=function()return false end,IsIllusion=function()return false end,
PassivesDisabled=function()return false end,IsAlive=function()return true end}
local ability={IsNull=function()return false end,GetLevel=function()return 1 end,
GetSpecialValueFor=function(_,key)if key=='shard_damage_threshold'then return 100 end;return 5 end}
local mod=setmetatable({damage_counter=50,GetParent=function()return hero end,GetAbility=function()return ability end},{__index=modifier_enfos_tide_shell_extension})
mod:OnTakeDamage({unit=hero,damage=40});assert(mod.damage_counter==0 and calls==1)
shard=true;mod:OnTakeDamage({unit=hero,damage=40});assert(mod.damage_counter==40 and calls==2)
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});

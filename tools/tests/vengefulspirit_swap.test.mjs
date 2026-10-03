import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Nether Swap rejects self, delegates ordinary filtering and clears both endpoints before placement',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
UF_FAIL_CUSTOM=-1;UF_SUCCESS=0;PATTACH_ABSORIGIN_FOLLOW=7;DAMAGE_TYPE_MAGICAL=2
require('abilities/heroes/vengefulspirit/r')
for _,mode in ipairs({'ordinary','boss','ally','absorbed','client','tree_removes_caster','tree_removes_target','tree_removes_ability'})do
 local clears={};local moves=0;local effects=0;local filterCalls=0
 local function unit(team,x)
  local u={team=team,pos={x=x},removed=false,isBoss=mode=='boss'}
  function u:IsNull()return self.removed end
  function u:IsAlive()assert(not self.removed);return true end
  function u:GetTeamNumber()assert(not self.removed);return self.team end
  function u:GetAbsOrigin()assert(not self.removed);return self.pos end
  function u:SetAbsOrigin(p)assert(#clears==2,'Clear both tree endpoints before placement');self.pos=p;moves=moves+1 end
  function u:Interrupt()end
  function u:EmitSound()end
  function u:TriggerSpellAbsorb()return mode=='absorbed' end
  function u:AddNewModifier()return {} end
  function u:GetAgility()return 0 end
  return u
 end
 local c,t=unit(2,10),unit(mode=='ally' and 2 or 3,90)
 local a=setmetatable({removed=false,GetCaster=function()return c end,GetCursorTarget=function()return t end,
 GetLevel=function()return 1 end,GetSpecialValueFor=function(_,k)return k=='tree_clear_radius' and 300 or 0 end,
 GetAbilityTargetTeam=function()return 3 end,GetAbilityTargetType=function()return 3 end,GetAbilityTargetFlags=function()return 16 end},enfos_vs_nether_swap)
 function a:IsNull()return self.removed end
 function UnitFilter(unit,team,kind,flags,ownTeam)
  assert(unit==t and team==3 and kind==3 and flags==16 and ownTeam==2,'Use actual ability KV filters, including enemy immunity')
  filterCalls=filterCalls+1;return unit.filterResult or UF_SUCCESS
 end
 assert(a:CastFilterResultTarget(c)==UF_FAIL_CUSTOM and filterCalls==0)
 assert(a:GetCustomCastErrorTarget(c)=='#dota_hud_error_cant_cast_on_self')
 assert(a:CastFilterResultTarget(nil)==UF_FAIL_CUSTOM and filterCalls==0)
 assert(a:CastFilterResultTarget(t)==UF_SUCCESS)
 t.filterResult=23;assert(a:CastFilterResultTarget(t)==23,'Engine rejection result must be preserved');t.filterResult=nil
 server=false;assert(a:CastFilterResultTarget(t)==UF_SUCCESS,'Client filter uses replicated native API');server=mode~='client'
 GridNav={DestroyTreesAroundPoint=function(_,p,radius,full)
  assert(radius==300 and full==false and moves==0)
  clears[#clears+1]=p.x
  if #clears==1 then
   if mode=='tree_removes_caster' then c.removed=true elseif mode=='tree_removes_target' then t.removed=true
   elseif mode=='tree_removes_ability' then a.removed=true end
  end
 end}
 function FindClearSpaceForUnit()end
 ParticleManager={CreateParticle=function()effects=effects+1;return effects end,SetParticleControlEnt=function()end,ReleaseParticleIndex=function()end}
 function ApplyDamage()error('Zero damage fixture should not apply damage')end
 a:OnSpellStart()
 if mode=='absorbed' or mode=='client' then assert(#clears==0 and moves==0 and effects==0)
 elseif mode:find('tree_removes') then assert(#clears==1 and moves==0 and effects==0,'Tree callbacks must not permit stale subsequent operations')
 else assert(#clears==2 and clears[1]==10 and clears[2]==90 and moves==2 and effects==2,'Normal/Boss/ally share endpoint clearance')end
end
print('Nether Swap target and trees PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Nether Swap target and trees PASS/,r.stderr);
});

test('Nether Swap declares authored tree radius and native immunity-piercing target flags',()=>{
 const a=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_vs_nether_swap;
 assert.equal(a.AbilityValues.tree_clear_radius,'300');
 assert.equal(a.AbilityUnitTargetFlags,'DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES');
 assert.equal(a.AbilityUnitTargetTeam,'DOTA_UNIT_TARGET_TEAM_BOTH');
 assert.equal(a.AbilityUnitTargetType,'DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC');
});

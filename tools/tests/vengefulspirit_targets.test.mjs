import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Venge Q/R use ordinary Boss formulas, native stun, safe absorb and impact boundaries',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
DAMAGE_TYPE_MAGICAL=2;PATTACH_WORLDORIGIN=1
require('abilities/heroes/vengefulspirit/q');require('abilities/heroes/vengefulspirit/r')
local classes={enfos_vs_magic_missile,enfos_vs_nether_swap}
for slot,cls in ipairs(classes) do
 for _,mode in ipairs({'ordinary','boss','ally','removed_absorb','caster_removed_absorb','ability_removed_absorb','absorbed','client','impact_removed','impact_ally','removed_interrupt','caster_removed_interrupt','ability_removed_interrupt'}) do
  local calls={damage=0,projectiles=0,mods=0,sounds=0,moves=0,particles=0,interrupts=0}
  local function unit(team,x)
   local u={team=team,removed=false,pos={x=x},isBoss=mode=='boss'}
   function u:IsNull()return self.removed end
   function u:IsAlive()assert(not self.removed);return true end
   function u:GetTeamNumber()assert(not self.removed);return self.team end
   function u:GetAbsOrigin()assert(not self.removed);return self.pos end
   function u:SetAbsOrigin(v)assert(not self.removed);self.pos=v;calls.moves=calls.moves+1 end
   function u:GetAgility()return 100 end
   function u:GetMaxHealth()return 100 end
   function u:EmitSound()assert(not self.removed);calls.sounds=calls.sounds+1 end
   function u:AddNewModifier(c,a,name,p)
    assert(not self.removed);calls.mods=calls.mods+1
    if slot==1 then assert(name=='modifier_stunned','Native stun must replace undefined Lua modifier');assert(p.duration==2,'Boss cannot shorten ordinary stun') end
    return {GetDuration=function()return p.duration end}
   end
   return u
  end
  local c=unit(2,10);local t=unit(mode=='ally' and 2 or 3,90)
  local a=setmetatable({removed=false,GetCaster=function()return c end,GetCursorTarget=function()return t end,
   GetLevel=function()return 1 end},cls)
  function a:IsNull()return self.removed end
  function t:Interrupt()
   assert(not self.removed);calls.interrupts=calls.interrupts+1
   if mode=='removed_interrupt' then self.removed=true elseif mode=='caster_removed_interrupt' then c.removed=true
   elseif mode=='ability_removed_interrupt' then a.removed=true end
  end
  function a:GetSpecialValueFor(k)assert(not self.removed);return k=='magic_missile_speed' and 1350 or k=='stun_duration' and 2 or 200 end
  function t:TriggerSpellAbsorb()
   if mode=='removed_absorb' then self.removed=true elseif mode=='caster_removed_absorb' then c.removed=true
   elseif mode=='ability_removed_absorb' then a.removed=true end
   return mode=='absorbed'
  end
  ParticleManager={CreateParticle=function()calls.particles=calls.particles+1;return 1 end,
   SetParticleControl=function()end,ReleaseParticleIndex=function()end}
  ProjectileManager={CreateTrackingProjectile=function(_,p)assert(p.iMoveSpeed==1350);calls.projectiles=calls.projectiles+1;return 9 end}
  function FindClearSpaceForUnit()end
  function ApplyDamage(e)calls.damage=calls.damage+1;assert(e.damage==(slot==1 and 290 or 320),'Boss/normal formula changed');return e.damage end
  server=mode~='client'
  local ok,err=pcall(function()
   a:OnSpellStart()
   if slot==1 and calls.projectiles>0 then
    if mode=='impact_removed' then t.removed=true elseif mode=='impact_ally' then t.team=2 end
    a:OnProjectileHit(t,nil)
   end
  end)
  assert(ok,'slot '..slot..' '..mode..': '..tostring(err))
  local interrupted_invalid=slot==2 and (mode=='removed_interrupt' or mode=='caster_removed_interrupt' or mode=='ability_removed_interrupt')
  local cancelled=mode=='removed_absorb' or mode=='caster_removed_absorb' or mode=='ability_removed_absorb' or mode=='absorbed' or mode=='client' or interrupted_invalid
  if cancelled then assert(calls.damage==0 and calls.projectiles==0 and calls.mods==0 and calls.sounds==0 and calls.moves==0 and calls.particles==0,'Rejected cast must have no gameplay/feedback')
  elseif slot==1 and (mode=='ally' or mode=='impact_removed' or mode=='impact_ally') then assert(calls.damage==0 and calls.mods==0)
  elseif slot==2 and mode=='ally' then assert(calls.damage==0 and calls.moves==2 and calls.mods==1)
  else assert(calls.damage==1 and calls.mods==1);if slot==2 then assert(calls.moves==2,'Boss must be swapped like ordinary valid target');assert(c.pos.x==90 and t.pos.x==10) end end
  if slot==2 then assert(calls.interrupts==((not cancelled or interrupted_invalid) and 1 or 0),'Valid swap must interrupt exactly once; rejected swap must not interrupt') end
 end
end
print('Vengeful Spirit ordinary targets PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Vengeful Spirit ordinary targets PASS/,r.stderr);
});

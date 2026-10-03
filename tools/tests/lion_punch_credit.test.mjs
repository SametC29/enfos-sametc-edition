import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';

test('Lion empowered melee and synchronous cleave kills share bounded Finger attribution',()=>{
 const baseline=process.env.LION_CREDIT_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/r.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
Convars={GetBool=function()return false end};DOTA_DAMAGE_CATEGORY_ATTACK=1;DOTA_DAMAGE_CATEGORY_SPELL=0
GameRules={GetGameTime=function()return 10 end,GetGameModeEntity=function()return {SetContextThink=function()end}end}
function DoUniqueString()return 'test'end
local Punch=require('abilities/heroes/lion/r_punch')
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/r')`}
local function unit()
 local u={alive=true,team=3}
 function u:IsNull()return self.removed end;function u:IsAlive()return self.alive end
 function u:IsBuilding()return self.building end;function u:IsIllusion()return self.illusion end
 function u:GetTeamNumber()return self.team end;function u:EmitSound()end
 return u
end
local c=unit();c.team=2
local a={rank=1};function a:IsNull()return self.removed end
function a:GetCaster()return c end;function a:GetLevel()return self.rank end
function a:GetSpecialValueFor(k)return k=='kill_stack_cap' and 20 or k=='kill_stack_damage' and 40 or 0 end
local m,punch
function c:FindModifierByName(n)return n=='modifier_enfos_lion_finger_counter' and m or n=='modifier_enfos_lion_finger_punch' and punch or nil end
local function reset()
 m=setmetatable({stacks=0},modifier_enfos_lion_finger_counter)
 function m:IsNull()return self.removed end;function m:GetParent()return c end;function m:GetAbility()return self.foreign or a end
 function m:GetStackCount()return self.stacks end
 function m:SetStackCount(n)self.stacks=n;if self.reenter then self:OnDeath(self.reenter)end end
 m:OnCreated()
 punch=setmetatable({},modifier_enfos_lion_finger_punch)
 function punch:IsNull()return self.removed end;function punch:GetParent()return c end;function punch:GetAbility()return a end
 function punch:SendBuffRefreshToClients()end
 return m
end
local function packet(u)return {unit=u,attacker=c,damage_category=1,ranged_attack=false}end
for rank=1,10 do
 reset();a.rank=rank;local u=unit();u.alive=false;local e=packet(u)
 m.reenter=e;m:OnDeath(e);m.reenter=nil
 assert(m.stacks==1,'Empowered melee kills must credit exactly once, including reentrant callbacks')
 m:OnDeath(e);assert(m.stacks==1,'Repeated death notification cannot duplicate')
 u.alive=true;punch:OnAttackStart({attacker=c,target=u});u.alive=false;m:OnDeath(e)
 assert(m.stacks==2,'A resurrected unit may credit a distinct new life')
end
for _,mode in ipairs({'ranged','spell','item','missing ranged','missing category','foreign attacker','live','ally','building','illusion','removed','no punch','closed punch','dead caster','illusion caster','rank zero','foreign counter','client'})do
 reset();a.rank=1;local u=unit();u.alive=false;local e=packet(u)
 if mode=='ranged' then e.ranged_attack=true elseif mode=='spell' then e.damage_category=0;e.inflictor=a
 elseif mode=='item' then e.inflictor={} elseif mode=='missing ranged' then e.ranged_attack=nil
 elseif mode=='missing category' then e.damage_category=nil elseif mode=='foreign attacker' then e.attacker={}
 elseif mode=='live' then u.alive=true elseif mode=='ally' then u.team=2 elseif mode=='building' then u.building=true
 elseif mode=='illusion' then u.illusion=true elseif mode=='removed' then u.removed=true elseif mode=='no punch' then punch=nil
 elseif mode=='closed punch' then punch.closed=true elseif mode=='dead caster' then c.alive=false
 elseif mode=='illusion caster' then c.illusion=true elseif mode=='rank zero' then a.rank=0
 elseif mode=='foreign counter' then m.foreign={GetCaster=function()return c end,GetLevel=function()return 1 end}
 else server=false end
 m:OnDeath(e);assert(m.stacks==0,mode)
 c.alive=true;c.illusion=false;server=true;a.rank=1
end
reset();local u=unit();u.alive=false;local e=packet(u);e.damage_category=0;e.inflictor=a
m:OnDeath(e);assert(m.stacks==0,'Unrelated R spell damage cannot masquerade as fist cleave')
punch.cleaving=true;m:OnDeath(e);assert(m.stacks==1,'Only the owned synchronous cleave context credits spell packets')
m:OnDeath(e);assert(m.stacks==1);e.unit=unit();e.unit.alive=false;e.inflictor={};m:OnDeath(e);assert(m.stacks==1)
reset();u=unit();m:MarkFingerTarget(u,3,a);u.alive=false;e=packet(u);m:OnDeath(e)
assert(m.stacks==1 and not m.pendingFingerHits[u],'Finger grace has first claim');m:OnDeath(e);assert(m.stacks==1)
u.alive=true;m:MarkFingerTarget(u,3,a);u.alive=false;m:OnDeath(e);assert(m.stacks==2)
reset();for i=1,50 do u=unit();u.alive=false;m:OnDeath(packet(u))end
assert(m.stacks==20,'Shared native kill bonus cap must remain enforced')
local entries=0;for _ in pairs(m.creditedVictims)do entries=entries+1 end;assert(entries<=20,'Cap cannot accumulate unused death claims')
assert(getmetatable(m.creditedVictims).__mode=='k');m:OnDestroy();assert(m.creditedVictims==nil)
print('Lion fist credit PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion fist credit PASS/);
});

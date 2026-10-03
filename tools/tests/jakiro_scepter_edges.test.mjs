import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Macropyre owns two finite icy flanks with movement-only lingering slow',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
DAMAGE_TYPE_MAGICAL=2;DAMAGE_TYPE_PURE=4;PATTACH_WORLDORIGIN=0;DOTA_UNIT_TARGET_TEAM_ENEMY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0;DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES=16;MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE=1;MODIFIER_PROPERTY_TOOLTIP=2
local mt={};function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},mt)end
mt.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end;mt.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end;mt.__mul=function(a,b)return Vector(a.x*b,a.y*b,a.z*b)end
mt.__index={Length2D=function(v)return math.sqrt(v.x*v.x+v.y*v.y)end,Normalized=function(v)local n=math.sqrt(v.x*v.x+v.y*v.y);return Vector(v.x/n,v.y/n,0)end}
require('abilities/heroes/jakiro/r')
assert(modifier_enfos_jakiro_macropyre_ice_slow,'Missing icy flank recipient')
local now=0;local c={removed=false,IsNull=function(self)return self.removed end,GetTeamNumber=function()return 2 end}
local a={IsNull=function()return false end,GetCaster=function()return c end,GetSpecialValueFor=function()return 0 end}
local p={removed=false,IsNull=function(self)return self.removed end,GetAbsOrigin=function()return Vector(100,200,30)end}
local function unit(y,boss)local u={pos=Vector(600,y,30),isBoss=boss,slow=0,burn=0,removed=false}
function u:IsNull()return self.removed end;function u:IsAlive()return true end;function u:GetTeamNumber()return 3 end;function u:IsDebuffImmune()return true end
function u:AddNewModifier(caster,ability,name,params)
 if name=='modifier_enfos_jakiro_macropyre_burn' then self.burn=self.burn+1;return end
 assert(name=='modifier_enfos_jakiro_macropyre_ice_slow' and params.duration==0.4 and params.slow==60)
 self.slow=self.slow+1;self.expiry=now+params.duration
 local m=self.mod or setmetatable({GetParent=function()return u end,GetCaster=function()return c end,GetAbility=function()return a end,SetHasCustomTransmitterData=function()end,SendBuffRefreshToClients=function()end},_G[name]);local exists=self.mod~=nil;self.mod=m
 if exists then m:OnRefresh(params)else m:OnCreated(params)end
end
return u end
local top=unit(470,false);local bottom=unit(-70,true);local center=unit(200,false);local outside=unit(600,false);local units={top,bottom,center,outside}
local queries,fireQueries=0,0
function FindUnitsInLine(team,start,last,cache,radius,tt,types,flags)
 queries=queries+1;assert(last.x==1500 and start.x==100 and start.z==30 and last.z==30 and flags==16)
 if radius==250 then fireQueries=fireQueries+1 else assert(radius==50 and (start.y==470 or start.y==-70) and last.y==start.y)end
 local result={};for _,u in ipairs(units)do if math.abs(u.pos.y-start.y)<=radius then result[#result+1]=u end end;return result
end
local count,controls,destroyed,released=0,{},{},{}
ParticleManager={CreateParticle=function(_,path,attach)count=count+1;assert(attach==0);if (count-1)%3~=0 then assert(path=='particles/units/heroes/hero_jakiro/jakiro_macropyre_ice_edge.vpcf')end;controls[count]={};return count end,SetParticleControl=function(_,id,cp,v)controls[id][cp]=v end,DestroyParticle=function(_,id)destroyed[id]=(destroyed[id]or 0)+1 end,ReleaseParticleIndex=function(_,id)released[id]=(released[id]or 0)+1 end}
function UTIL_Remove(u)u.removed=true end
local zone=setmetatable({GetCaster=function()return c end,GetAbility=function()return a end,GetParent=function()return p end,GetElapsedTime=function()return now end,StartIntervalThink=function(self,t)self.interval=t end,Destroy=function(self)self:OnDestroy()end},modifier_enfos_jakiro_macropyre_zone)
zone:OnCreated({dir_x=1,dir_y=0,length=1400,radius=250,duration=15,interval=0.5,dps=270,pierce=1,damage_type=4,edge_radius=50,edge_offset=20,edge_linger=0.4,edge_slow=60})
assert(zone.interval==0.1 and count==3 and top.slow==1 and bottom.slow==1 and center.slow==0 and outside.slow==0)
assert(controls[2][0].y==470 and controls[3][0].y==-70 and controls[2][2].x==15)
for i=1,5 do now=i*0.1;zone:OnIntervalThink();assert(top.expiry>now and bottom.expiry>now)end
assert(top.slow==6 and bottom.slow==6 and fireQueries==2,'Fast edge sampling must not multiply center burn refreshes')
assert(top.mod:GetModifierMoveSpeedBonus_Percentage()==-60 and bottom.mod:GetModifierMoveSpeedBonus_Percentage()==-60 and top.burn==0 and bottom.burn==0,'Edges slow ordinary/Boss equally but add no damage')
local client=setmetatable({},modifier_enfos_jakiro_macropyre_ice_slow);client:HandleCustomTransmitterData(top.mod:AddCustomTransmitterData());assert(client:OnTooltip()==60)
now=0.6;c.removed=true;zone:OnIntervalThink();zone:OnDestroy();assert(zone.closed and zone.interval==-1 and p.removed)
for id=1,3 do assert(destroyed[id]==1 and released[id]==1)end
assert(top.mod:GetModifierMoveSpeedBonus_Percentage()==0,'Removed source grants no lingering gameplay bonus')
c.removed=false;p.removed=false;now=0;zone:OnCreated({dir_x=1,dir_y=0,length=1400,radius=250,duration=15,interval=0.5,dps=270,pierce=1,damage_type=4,edge_radius=50,edge_offset=20,edge_linger=0.4,edge_slow=60})
now=15;local before=queries;zone:OnIntervalThink();zone:OnDestroy();assert(queries==before and zone.closed,'Natural expiry performs no late edge or damage refresh')
for id=4,6 do assert(destroyed[id]==1 and released[id]==1)end
c.removed=false;p.removed=false;now=0;local original=top.AddNewModifier;top.AddNewModifier=function(self,...)original(self,...);c.removed=true end
zone:OnCreated({dir_x=1,dir_y=0,length=1400,radius=250,duration=15,interval=0.5,dps=270,pierce=1,damage_type=4,edge_radius=50,edge_offset=20,edge_linger=0.4,edge_slow=60});assert(zone.closed,'Reentrant source loss during edge application closes field')
for id=7,9 do assert(destroyed[id]==1 and released[id]==1)end
server=false;local before=count;zone:OnCreated({});assert(count==before,'Client cannot create edge particles');server=true
print('Jakiro R icy flanks PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro R icy flanks PASS/,r.stderr);
});

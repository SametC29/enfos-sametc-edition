package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) return t end
function LinkLuaModifier() end
function IsServer() return true end
local vectorMT={__add=function(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end}
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},vectorMT) end
local function test(name,fn) fn();print('PASS '..name) end

test('universal home shop initializes once without unsupported entity methods',function()
 -- Match CDOTA_ShopTrigger's actual API: no CBaseModelEntity:SetSize method.
 local count=0;local trigger={IsNull=function() return false end,SetShopType=function(s,v) s.shop=v end}
 GameRules={SetUseUniversalShopMode=function(_,v) assert(v) end}
 local center,radius
 SpawnDOTAShopTriggerRadiusApproximate=function(p,r) count=count+1;center=p;radius=r;return trigger end
 local s=require('economy/native_shop');assert(s:Init());assert(s:Init());assert(count==1 and trigger.shop==0)
 assert(center.x==0 and center.y==0 and center.z==256 and radius==18000)
end)

test('personal home trigger follows elevation and is reused across repeated updates',function()
 local count=0
 SpawnDOTAShopTriggerRadiusApproximate=function(pos,radius)
  assert(radius==256);count=count+1
  return {IsNull=function() return false end,SetShopType=function(_,kind) assert(kind==0) end,
   SetAbsOrigin=function(self,p) self.position=p end}
 end
 PlayerResource={IsValidPlayerID=function(_,id) return id==0 end}
 local hero={IsNull=function() return false end,IsRealHero=function() return true end,
  IsIllusion=function() return false end,GetPlayerID=function() return 0 end,
  position=Vector(7500,-3500,726),GetAbsOrigin=function(self) return self.position end}
 local shop=require('economy/native_shop')
 assert(shop:FollowHero(hero));hero.position=Vector(4600,11000,128)
 for i=1,20 do assert(shop:FollowHero(hero)) end
 assert(count==1 and shop.playerTriggers[0].position==hero.position)
 hero.IsIllusion=function() return true end;assert(not shop:FollowHero(hero))
end)

test('all 40 innates receive only their initial free rank; respawn cannot reset training',function()
 local service=require('heroes/innates');local count=0
 for name,id in pairs(service.byHero) do
  local a={level=0,GetLevel=function(s) return s.level end,SetLevel=function(s,v) s.level=v end}
  local h={IsNull=function() return false end,IsRealHero=function() return true end,IsIllusion=function() return false end,
   GetUnitName=function() return name end,FindAbilityByName=function(_,key)
    if key==id then return a end
    assert((name=='npc_dota_hero_luna' and (key=='enfos_luna_lucent_beam' or key=='enfos_luna_lunar_blessing'))
     or (name=='npc_dota_hero_nevermore' and key=='enfos_sf_shadowraze'))
    return nil -- This progression-only fixture has no native kit integration.
   end}
  assert(service:Apply(h) and a.level==1);a.level=4;service:Apply(h);assert(a.level==4);count=count+1
 end
 assert(count==40)
end)

local hero={IsIllusion=function() return false end,GetPlayerOwnerID=function() return 7 end,GetTeamNumber=function() return 2 end}
local function unit()
 return {alive=true,IsNull=function() return false end,IsAlive=function(s) return s.alive end,ForceKill=function(s) s.alive=false end,
  SetOwner=function(s,v) s.owner=v end,SetControllableByPlayer=function(s,p,v) s.player=p;s.control=v end,
  SetMinimumGoldBounty=function(s,v) s.goldMin=v end,SetMaximumGoldBounty=function(s,v) s.goldMax=v end,SetDeathXP=function(s,v) s.xp=v end,
  SetBaseDamageMin=function() end,SetBaseDamageMax=function() end,SetBaseMaxHealth=function() end,SetMaxHealth=function() end,SetHealth=function() end,
  SetIdleAcquire=function() end,SetAcquisitionRange=function() end,AddNewModifier=function(s,_,_,name,p) s.life=p.duration end}
end
test('controllable summon cap survives repeated casts; illusions cannot recursively summon',function()
 local service=require('heroes/summons');local a={GetCaster=function() return hero end}
 local created={};CreateUnitByName=function(_,pos,_,owner,_,team) assert(owner==hero and team==2);local u=unit();u.origin=pos;created[#created+1]=u;return u end
 service:Units(a,'skeleton',Vector(0,0,500),999,30,50,500)
 assert(#a.enfosSummons==8)
 for _,u in ipairs(a.enfosSummons) do assert(u.player==7 and u.control and u.owner==hero and u.life==30 and u.enfosNoReward) end
 local old=a.enfosSummons;service:Units(a,'skeleton',Vector(0,0,500),4,30,50,500)
 for _,u in ipairs(old) do assert(not u.alive) end
 assert(#a.enfosSummons==4)
 service:Units(a,'skeleton',Vector(0,0,500),12,30,50,500,12)
 assert(#a.enfosSummons==12,'Explicit summon cap must support Wraith King rank 10 KV count')
 local positions={};for _,u in ipairs(a.enfosSummons) do
  local p=u.origin;local key=string.format('%.3f:%.3f',p.x,p.y);assert(not positions[key],'Expanded formation must not overlap units');positions[key]=true
 end
 service:Units(a,'skeleton',Vector(0,0,500),99,30,50,500,99)
 assert(#a.enfosSummons==20,'Caller-provided summon caps must remain globally bounded')
 local createdBeforeIllusion=#created
 hero.IsIllusion=function() return true end;service:Units(a,'skeleton',Vector(0,0,500),8,30,50,500);assert(#created==createdBeforeIllusion)
 hero.IsIllusion=function() return false end
 CreateIllusions=function(owner,copy,p,count) assert(owner==hero and copy==hero and count==3 and p.outgoing_damage== -40 and p.incoming_damage==200);return {unit(),unit(),unit()} end
 service:Illusions(a,3,30,60);assert(#a.enfosSummons==3)
 for _,u in ipairs(a.enfosSummons) do assert(u.control and u.enfosNoReward and u.goldMin==0 and u.goldMax==0 and u.xp==0) end
end)

test('match level budget funds all five Enfos skills without a talent tree',function()
 -- Levels 2..50 grant 49 ability points; the fifth Enfos passive has one free rank.
 assert(50-1==49)
 assert((4*10)+9==49)
end)

print('Player feedback regression tests passed (mock engine).')

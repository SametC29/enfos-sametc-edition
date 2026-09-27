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
   GetUnitName=function() return name end,FindAbilityByName=function(_,key) assert(key==id);return a end}
  assert(service:Apply(h) and a.level==1);a.level=4;service:Apply(h);assert(a.level==4);count=count+1
 end
 assert(count==40)
end)

local hero={IsIllusion=function() return false end,GetPlayerOwnerID=function() return 7 end,GetTeamNumber=function() return 2 end}
local function unit()
 return {alive=true,IsNull=function() return false end,IsAlive=function(s) return s.alive end,ForceKill=function(s) s.alive=false end,
  SetOwner=function(s,v) s.owner=v end,SetControllableByPlayer=function(s,p,v) s.player=p;s.control=v end,
  SetBaseDamageMin=function() end,SetBaseDamageMax=function() end,SetBaseMaxHealth=function() end,SetMaxHealth=function() end,SetHealth=function() end,
  SetIdleAcquire=function() end,SetAcquisitionRange=function() end,AddNewModifier=function(s,_,_,name,p) s.life=p.duration end}
end
test('controllable summon cap survives repeated casts; illusions cannot recursively summon',function()
 local service=require('heroes/summons');local a={GetCaster=function() return hero end}
 local created={};CreateUnitByName=function(_,_,_,owner,_,team) assert(owner==hero and team==2);local u=unit();created[#created+1]=u;return u end
 service:Units(a,'skeleton',Vector(0,0,500),999,30,50,500)
 assert(#a.enfosSummons==8)
 for _,u in ipairs(a.enfosSummons) do assert(u.player==7 and u.control and u.owner==hero and u.life==30 and u.enfosNoReward) end
 local old=a.enfosSummons;service:Units(a,'skeleton',Vector(0,0,500),4,30,50,500)
 for _,u in ipairs(old) do assert(not u.alive) end
 assert(#a.enfosSummons==4)
 hero.IsIllusion=function() return true end;service:Units(a,'skeleton',Vector(0,0,500),8,30,50,500);assert(#created==12)
 hero.IsIllusion=function() return false end
 CreateIllusions=function(owner,copy,p,count) assert(owner==hero and copy==hero and count==3 and p.outgoing_damage== -40 and p.incoming_damage==200);return {unit(),unit(),unit()} end
 service:Illusions(a,3,30,60);assert(#a.enfosSummons==3)
 for _,u in ipairs(a.enfosSummons) do assert(u.control and u.enfosNoReward) end
end)

test('legacy global evolution choices are no longer exposed',function()
 local manager=require('evolution/evolution_manager')
 assert(manager.MILESTONE_CHOICES==nil)
 local trees=require('evolution/hero_trees')
 assert(#trees:GetChoices(nil,4)==0)
end)
print('Player feedback regression tests passed (mock engine).')

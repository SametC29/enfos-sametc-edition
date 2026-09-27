package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) return t end
function LinkLuaModifier() end
function IsServer() return true end
local vectorMT={__add=function(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end}
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},vectorMT) end
local function test(name,fn) fn();print('PASS '..name) end

test('one universal home shop spans both platform elevations and initializes once',function()
 local count=0;local trigger={IsNull=function() return false end,SetShopType=function(s,v) s.shop=v end,SetSize=function(s,a,b) s.lo=a;s.hi=b end}
 GameRules={SetUseUniversalShopMode=function(_,v) assert(v) end}
 SpawnDOTAShopTriggerRadiusApproximate=function() count=count+1;return trigger end
 local s=require('economy/native_shop');assert(s:Init());assert(s:Init());assert(count==1 and trigger.shop==0)
 assert(trigger.lo.z<0 and trigger.hi.z>520 and trigger.hi.x>8000 and trigger.lo.x< -8000)
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

test('all evolution choices have real persistent modifiers and duplicate selections do not stack',function()
 local manager=require('evolution/evolution_manager');local mods={};local h={IsNull=function() return false end,
 HasModifier=function(_,n) return mods[n]~=nil end,AddNewModifier=function(_,_,_,n) assert(_G[n]);mods[n]=(mods[n] or 0)+1;return {} end}
 local count=0
 for _,pair in pairs(manager.MILESTONE_CHOICES) do for _,c in ipairs(pair) do
  assert(manager:ApplyChoiceBonus(h,c));assert(manager:ApplyChoiceBonus(h,c));assert(mods['modifier_enfos_evolution_'..c.id]==1);count=count+1
 end end
 assert(count==12)
 local hp=modifier_enfos_evolution_evo_iron_bulwark
 assert(hp:GetModifierHealthBonus()==750 and hp:GetModifierPhysicalArmorBonus()==10 and hp:RemoveOnDeath()==false)
 local stats=modifier_enfos_evolution_evo_transcendence
 assert(stats:GetModifierBonusStats_Strength()==35 and stats:GetModifierBonusStats_Agility()==35 and stats:GetModifierBonusStats_Intellect()==35)
 local armor=modifier_enfos_evolution_evo_titan_carapace
 assert(armor:GetModifierIncomingDamage_Percentage()== -20 and armor:GetModifierStatusResistanceStacking()==25)
end)
print('Player feedback regression tests passed (mock engine).')

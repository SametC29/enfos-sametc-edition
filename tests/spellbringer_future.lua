package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) return t end
function LinkLuaModifier() end
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},{__add=function(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end}) end
function RandomFloat() return 0 end
function EmitGlobalSound() end
PlayerResource={IsValidPlayerID=function() return true end,GetSelectedHeroEntity=function() return {} end,GetTeam=function() return 2 end}
local service=require('spellbringer/spellbringer_service')
local Curve=require('waves/difficulty_curve')
local Roster=require('waves/native_roster')
local Balance=require('waves/balance_config')
local events={}
CustomGameEventManager={Send_ServerToAllClients=function(_,name,data) events[#events+1]={name=name,data=data} end}
service.SyncNetTable=function() end
service.CanCast=function() return true end
local spawned={}
function CreateUnitByName(name,pos,_,owner,_,team)
 local u={name=name,pos=pos,team=team}
 function u:SetOwner(v) self.owner=v end
 function u:SetControllableByPlayer(id) self.controller=id end
 function u:SetBaseMaxHealth(v) self.hp=v end
 function u:GetBaseMaxHealth() return self.hp end
 function u:GetMaxHealth() return self.hp end
 function u:SetMaxHealth(v) self.hp=v end
 function u:SetHealth(v) self.health=v end
 function u:SetBaseDamageMin(v) self.lo=v end
 function u:SetBaseDamageMax(v) self.hi=v end
 function u:GetBaseDamageMin() return self.lo end
 function u:GetBaseDamageMax() return self.hi end
 function u:SetPhysicalArmorBaseValue(v) self.armor=v end
 function u:SetBaseMagicalResistanceValue(v) self.resistance=v end
 function u:SetBaseMoveSpeed(v) self.speed=v end
 function u:SetMinimumGoldBounty(v) assert(v==0) end
 function u:SetMaximumGoldBounty(v) assert(v==0) end
 function u:SetDeathXP(v) assert(v==0) end
 function u:SetIdleAcquire() end
 function u:SetAcquisitionRange() end
 function u:AddAbility() return {SetLevel=function() end} end
 function u:SetMaxMana() end
 function u:SetMana() end
 function u:SetBaseManaRegen() end
 function u:AddNewModifier(_,_,name,kv) if name=='modifier_kill' then self.life=kv.duration end end
 spawned[#spawned+1]=u;return u
end
local ready=true
local snapshot=Balance.Snapshot('hard',1,0)
service.waveManager={EnsureMatchConfig=function() return snapshot end,bossResources={RequestPlan=function() end,IsPlanReady=function() return ready end}}
for wave=1,60 do
 spawned={};service.waveManager.currentWave=wave
 service.playerState={[0]={mana=200,max_mana=200,cooldowns={}}}
 local position=Vector(7500,0,128)
 assert(service:CastSpell(0,'spellbringer_future_reinforcements',position,nil))
 assert(#spawned==5)
 local profile,power=Roster.Future(wave);local stats=Curve.Normal(power)
 local hp,dmg=Balance.Multipliers(snapshot,power)
 for _,u in ipairs(spawned) do
  assert(u.name==profile.unit and u.waveNumber==power)
  assert(u.hp==math.floor(stats.hp*hp*(snapshot.regularHP or 1)) and u.lo==math.floor(stats.damage*dmg))
  assert(u.armor==stats.armor and u.speed==stats.speed and u.resistance==stats.magicResistance)
  assert(u.life==30 and u.controller==0 and u.enfosNoReward and u.is_allied_reinforcement)
 end
 for i=1,#spawned do
  for j=i+1,#spawned do
   local dx,dy=spawned[i].pos.x-spawned[j].pos.x,spawned[i].pos.y-spawned[j].pos.y
   assert(dx*dx+dy*dy>=149*149,
    'reinforcements must spawn in a collision-free formation, not the old tight cluster')
  end
 end
 local centerX,centerY=0,0
 for _,u in ipairs(spawned) do centerX=centerX+u.pos.x;centerY=centerY+u.pos.y end
 assert(math.abs(centerX/#spawned-position.x)<1e-6 and math.abs(centerY/#spawned-position.y)<1e-6,
  'the formation must remain centered on the selected target')
 assert(events[#events].name=='enfos_spellbringer_effect' and events[#events].data.x==7500)
end
local before=#events
ready=false;spawned={};service.playerState={[0]={mana=200,max_mana=200,cooldowns={}}}
local ok=service:CastSpell(0,'spellbringer_future_reinforcements',Vector(7500,0,128),nil)
assert(not ok and #spawned==0 and #events==before)
assert(service.playerState[0].mana==200 and service.playerState[0].cooldowns.spellbringer_future_reinforcements==nil)
-- Tools casts must arm movement evidence automatically with exactly this group.
ready=true
local observations=0
package.loaded['tools/spellbringer_audit']={Run=function(player,group)
 assert(player==0 and #group==5)
 for i,u in ipairs(group) do assert(u==spawned[i]) end
 observations=observations+1
end}
IsInToolsMode=function() return false end
spawned={};assert(service:CastFutureReinforcements(2,service.ABILITY_DEFS.spellbringer_future_reinforcements,Vector(7500,0,128),0))
assert(observations==0,'no automatic diagnostic outside Tools mode')
IsInToolsMode=function() return true end
spawned={};assert(service:CastFutureReinforcements(2,service.ABILITY_DEFS.spellbringer_future_reinforcements,Vector(7500,0,128),0))
assert(observations==1)
package.loaded['tools/spellbringer_audit'].Run=function() error('simulated diagnostic failure') end
spawned={};assert(service:CastFutureReinforcements(2,service.ABILITY_DEFS.spellbringer_future_reinforcements,Vector(7500,0,128),0))
assert(#spawned==5,'a diagnostic failure must not invalidate an otherwise successful cast')
print('spellbringer future tests passed')

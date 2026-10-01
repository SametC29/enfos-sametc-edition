package.path = "game/scripts/vscripts/?.lua;" .. package.path
local Curve=require("waves/difficulty_curve")
local Roster=require("waves/native_roster")
local seen,count={},0
local previous=Curve.Normal(1)
assert(previous.hp==120 and previous.damage==10)
for wave=1,60 do
 local stats=Curve.Normal(wave)
 assert(stats.hp>=previous.hp and stats.damage>=previous.damage)
 assert(stats.speed>=previous.speed and stats.magicResistance>=previous.magicResistance)
 previous=stats
 local entry=Roster.Get(wave)
 if wave%5==0 then assert(entry==nil,"Boss slot must not become a normal wave")
 else
  assert(entry and entry.wave==wave)
  assert(not seen[entry.model],"Duplicate model at wave "..wave)
  seen[entry.model]=true;count=count+1
 end
 local future,power=Roster.Future(wave)
 assert(power==math.min(60,wave+5))
 local expected=math.min(59,wave+5)
 if expected%5==0 then expected=expected-1 end
 assert(future.wave==expected)
 local plan=Roster.ResourcePlan(wave)
 local names={}
 for _,resource in ipairs(plan) do
  assert(not names[resource.unit_name]);names[resource.unit_name]=true
 end
 assert(names[future.unit] and names[future.native])
 if entry then assert(names[entry.unit] and names[entry.native]) end
end
assert(count==48)
local hp,damage=Curve.Solo(1);assert(hp==0.75 and damage==0.70)
hp,damage=Curve.Solo(30);assert(hp==1 and damage==1)
local earlyHp,earlyDamage=Curve.Boss(5)
local lateHp,lateDamage=Curve.Boss(60)
assert(lateHp>earlyHp and lateDamage>earlyDamage)
assert(Curve.Normal(60).hp>Curve.Normal(40).hp*3,"Ending must accelerate")
print("wave curve and roster tests passed")

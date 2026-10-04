package.path='game/scripts/vscripts/?.lua;'..package.path
local B=require('waves/balance_config')
local Curve=require('waves/difficulty_curve')
local function unit(boss)
 return {isBoss=boss,hp=10000,damage=1000,
 GetMaxHealth=function(u) return u.hp end,SetMaxHealth=function(u,hp) u.hp=hp end,
 SetBaseMaxHealth=function() end,SetHealth=function(u,hp) u.current=hp end,
 GetBaseDamageMin=function(u) return u.damage end,GetBaseDamageMax=function(u) return u.damage end,
 SetBaseDamageMin=function(u,d) u.lo=d end,SetBaseDamageMax=function(u,d) u.hi=d end}
end
for _,difficulty in ipairs({'casual','normal','hard','nightmare','hell'}) do
 for _,counts in ipairs({{1,0},{0,1},{1,1}}) do
  local cfg=B.Snapshot(difficulty,counts[1],counts[2])
  assert(cfg.bossHP==1.20 and cfg.bossDamage==1.15)
  for wave=5,60,5 do
   local hp,damage=B.Multipliers(cfg,wave)
   local bh,bd=Curve.Boss(wave)
   local boss=unit(true);B.Apply(boss,cfg,wave)
   assert(math.abs(boss.hp-10000*hp*bh*1.20)<1.01 and boss.current==boss.hp)
   assert(math.abs(boss.lo-1000*damage*bd*1.15)<1.01 and boss.hi==boss.lo)
   local normal=unit(false);B.Apply(normal,cfg,wave)
   assert(normal.hp==math.floor(10000*hp) and normal.lo==math.floor(1000*damage),'normal wave tuning must stay unchanged')
   cfg.bossHP=nil;cfg.bossDamage=nil
   local legacy=unit(true);B.Apply(legacy,cfg,wave)
   assert(math.abs(legacy.hp-10000*hp*bh)<1.01 and math.abs(legacy.lo-1000*damage*bd)<1.01,'legacy snapshots must retain original tuning')
   cfg.bossHP=1.20;cfg.bossDamage=1.15
  end
 end
end
print('PASS Boss pressure snapshot across difficulties, sides and all Boss waves (mock)')

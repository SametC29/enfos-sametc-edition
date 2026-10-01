dofile('tests/runtime_regressions.lua')
local W=require('waves/wave_manager')
local D=require('waves/wave_definitions')
local B=require('bosses/boss_framework')
local R=require('waves/rewards')
local L=require('waves/life_core')
L.PlayLeakEffects=function() end -- Presentation is an engine acceptance gate.
local AI=require('waves/creep_ai')
local Balance=require('waves/balance_config')
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},
 {__add=function(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end}) end
function RandomVector() return Vector(0,0,0) end
function RandomFloat(a) return a end
function RandomInt(a) return a end
function UTIL_Remove(u) u.removed=true end
local sequence,lastUnit={},nil
function CreateUnitByName(name,_,_,_,_,team)
 assert(name:match('^npc_dota_hero_') and team==4)
 local u={name=name,id=9000+#sequence}
 function u:IsNull() return false end
 function u:IsAlive() return not self.killed end
 function u:entindex() return self.id end
 function u:GetUnitName() return self.name end
 function u:SetMinimumGoldBounty(v) assert(v==0) end
 function u:SetMaximumGoldBounty(v) assert(v==0) end
 function u:SetDeathXP(v) assert(v==0) end
 function u:SetRespawnsDisabled(v) assert(v==true); self.respawnsDisabled=v end
 function u:SetIdleAcquire() end
 function u:SetAcquisitionRange() end
 function u:ForceKill() self.killed=true end
 lastUnit=u;sequence[#sequence+1]='create';return u
end
local prepare,register,attach,apply=B.PrepareBoss,B.RegisterBoss,AI.Attach,Balance.Apply
B.PrepareBoss=function(_,u,name,wave,team)
 assert(u.bossRewardName==D:GetWave(wave).boss_name and team==2)
 u.nativeBossHero=name;sequence[#sequence+1]='prepare';return true
end
B.RegisterBoss=function(_,u,alias,wave,_,team)
 assert(u.nativeBossHero and alias==u.bossRewardName and team==2)
 sequence[#sequence+1]='register';return true
end
Balance.Apply=function() sequence[#sequence+1]='balance' end
AI.Attach=function(_,u,team,lane)
 assert(W.activeCreeps[team][u:entindex()]==u and lane=='center')
 sequence[#sequence+1]='route'
end
local selected={}
W:Init();R.units=assert(ENFOS_TEST_UNITS)
for wave=5,60,5 do
 W.currentWave=wave;sequence={}
 local plan=D:GetSpawnPlan(wave,1)
 local entry=plan[1]
 assert(#plan==1 and entry.count==1 and not selected[entry.unit_name])
 selected[entry.unit_name]=true
 local u=W:SpawnCreepEntity(entry.unit_name,2,'center',true,1,entry.boss_reward_name)
 assert(table.concat(sequence,',')=='create,prepare,balance,register,route')
 assert(u.respawnsDisabled,'wave Bosses must never enter native automatic respawn')
 local kv=R.units[entry.boss_reward_name]
 assert(u.enfosGold==tonumber(kv.BountyGoldMin) and u.enfosXP==tonumber(kv.BountyXP))
 assert(R:Estimate(plan).goldMin==tonumber(kv.BountyGoldMin))
 local before=L:GetLife(2)
 L:ProcessLeak(u,2)
 assert(L:GetLife(2)==before-5,'native Boss identity must retain Boss Life penalty')
end
B.PrepareBoss=function() return false end
sequence={};W.currentWave=5
assert(W:SpawnCreepEntity('npc_dota_hero_sven',2,'center',true,1,'enfos_boss_stonebreaker')==nil)
assert(lastUnit.killed and lastUnit.removed and #sequence==1)
B.PrepareBoss,B.RegisterBoss,AI.Attach,Balance.Apply=prepare,register,attach,apply

-- Exercise actual registration/death handling across two successive Bosses.
-- A simulated engine respawn timer checks the disabled flag; this is not a
-- claim that Dota's actual timer was observed in this test.
local E=require('economy/economy_manager')
local Boons=require('boons/boon_manager')
local rewardKill,award,vote=R.OnKill,E.AwardBossLumber,Boons.StartVote
local rewards,lumber=0,0
R.OnKill=function() rewards=rewards+1 end
E.AwardBossLumber=function() lumber=lumber+1 end
Boons.StartVote=function() end
W:Init();B:Init()
local entities={}
function EntIndexToHScript(id) return entities[id] end
local function liveBoss(name,id,wave)
 local u=CreateUnitByName(name,nil,nil,nil,nil,4)
 u.id=id;u.isBoss=true;u.waveNumber=wave;u.defendingTeam=2
 u.nativeBossHero=name;u.bossAbilityNames={};u:SetRespawnsDisabled(true)
 function u:AddNewModifier() return {} end
 function u:SetContextThink(_,callback) self.thinker=callback end
 entities[id]=u;W.activeCreeps[2][id]=u
 assert(B:RegisterBoss(u,name,wave,1,2))
 return u
end
local first=liveBoss('npc_dota_hero_sven',101,5)
first.killed=true
W:OnEntityKilled({entindex_killed=101})
assert(not W.activeCreeps[2][101] and not B.activeBosses[101] and first.bossState==nil)
assert(first.thinker()==nil and first.respawnsDisabled)
W:OnEntityKilled({entindex_killed=101})
assert(rewards==1 and lumber==1,'duplicate death must not grant another Boss reward')
local second=liveBoss('npc_dota_hero_axe',102,10)
assert(first.killed and first.respawnsDisabled and not B.activeBosses[101])
assert(B.activeBosses[102]==second and second:IsAlive(),'next spawn must only activate the new Boss')
second.killed=true;W:OnEntityKilled({entindex_killed=102})
assert(rewards==2 and lumber==2 and next(B.activeBosses)==nil)
assert(second.thinker()==nil and second.respawnsDisabled)
R.OnKill,E.AwardBossLumber,Boons.StartVote=rewardKill,award,vote
print('PASS one-life Boss death cleanup, successive spawns and single reward (mock)')
print('PASS twelve native Boss plan/spawn/reward/Life pipelines and preparation-failure cleanup (mock)')

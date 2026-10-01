package.path='game/scripts/vscripts/?.lua;'..package.path
local W=require('waves/wave_definitions')
local former={6,12,18,24,36,42,48,54}
for _,wave in ipairs(former) do
 assert(W:GetWave(wave).wave_type=='normal','former Elite slot must be normal: '..wave)
end
for players=1,5 do
 local normal,boss=0,0
 for wave=1,60 do
  local def=W:GetWave(wave)
  assert(def.wave_type=='normal' or def.wave_type=='boss')
  if def.wave_type=='boss' then boss=boss+1 else normal=normal+1 end
  local plan=W:GetSpawnPlan(wave,players)
  for _,entry in ipairs(plan) do
   assert(not entry.unit_name:find('enfos_elite_',1,true))
   assert(not entry.is_elite and entry.count>0)
   if def.wave_type=='normal' then assert(W:GetLeakPenalty(entry.unit_name)==1) end
  end
  if def.wave_type=='boss' then assert(#plan==1 and plan[1].count==1) end
 end
 assert(normal==48 and boss==12)
end
assert(W.IsEliteWave==nil and W.LEAK_PENALTIES.elite==nil)
print('PASS all 60 waves for 1..5 players: 48 normal, 12 Boss-only, zero Elite spawns (mock planner)')

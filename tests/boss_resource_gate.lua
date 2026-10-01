-- Run existing wave fixtures first, then test the production asynchronous gate.
dofile('tests/runtime_regressions.lua')
local W=require('waves/wave_manager')
local pending,requests={},0
function PrecacheUnitByNameAsync(name,callback)
 requests=requests+1;pending[name]=callback
end
W:Init()
W.currentWave=4
W:StartBossIncoming()
assert(requests==1,'warning must request only the selected Boss once')
W:StartWave(5)
assert(requests==1,'both defending teams and wave start must share the request')
local timer,batches=W.stateTimer,#W.pendingBatches
local spawned=0
local original=W.SpawnCreepEntity
W.SpawnCreepEntity=function() spawned=spawned+1 end
W:OnThink()
W:SpawnNextBatch()
assert(spawned==0 and #W.pendingBatches==batches and W.stateTimer==timer,
 'pending resources must preserve the Boss batch and combat deadline')
for _,callback in pairs(pending) do callback() end
W:OnThink()
assert(spawned==1 and #W.pendingBatches==0,'loaded Boss must spawn once for active team')
W.SpawnCreepEntity=original
-- A late callback from a previous match must not mark the new match ready.
W:Init();W:StartWave(10)
local oldCallback
for _,callback in pairs(pending) do oldCallback=callback end
W:Init();W:StartWave(10)
oldCallback()
assert(not W.bossResources:IsPlanReady(W.bossResourcePlan))
-- Normal waves never wait for Boss loading.
W:StartWave(6)
assert(W.bossResourcePlan==nil)
local Gate=require('bosses/resource_gate')
local failed=Gate.New()
function PrecacheUnitByNameAsync() error('mock resource failure') end
failed:RequestPlan({{unit_name='npc_dota_hero_sven'}})
assert(not failed:IsPlanReady({{unit_name='npc_dota_hero_sven'}}),
 'failed resource loads must not authorize an ERROR-model spawn')
print('PASS Boss resource loading gates spawn and deadline, deduplicates requests, isolates match resets (mock)')

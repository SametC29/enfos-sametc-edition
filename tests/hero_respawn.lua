package.path='game/scripts/vscripts/?.lua;'..package.path
local R=require('heroes/respawn')
assert(R:SecondsForLevel(1)==30 and R:SecondsForLevel(6)==30)
assert(R:SecondsForLevel(28)==40 and R:SecondsForLevel(50)==50 and R:SecondsForLevel(100)==50)
local previous=30
for level=1,100 do
 local seconds=R:SecondsForLevel(level)
 assert(seconds>=previous and seconds>=30 and seconds<=50 and seconds==math.floor(seconds))
 previous=seconds
end
function GetMapName() return "enfos_test" end
assert(R:SecondsForLevel(6)==30 and R:SecondsForLevel(28)==40 and R:SecondsForLevel(50)==50,
 "test arena keeps the previous respawn curve")
GetMapName=nil
local selected,entity
PlayerResource={IsValidPlayerID=function(_,id) return id==0 end,GetSelectedHeroEntity=function() return selected end}
function EntIndexToHScript(id) assert(id==10);return entity end
local function hero(team,level)
 local h={team=team,level=level,playerID=0}
 function h:IsNull() return self.null or false end
 function h:IsRealHero() return not self.creep end
 function h:IsIllusion() return self.illusion or false end
 function h:IsAlive() return self.alive or false end
 function h:GetTeamNumber() return self.team end
 function h:GetPlayerID() return self.playerID end
 function h:GetLevel() return self.level end
 function h:IsClone() return self.clone or false end
 function h:IsTempestDouble() return self.double or false end
 function h:IsReincarnating() return self.reincarnating or false end
 function h:WillReincarnate() return self.aegis or false end
 function h:SetTimeUntilRespawn(seconds) self.timer=seconds end
 return h
end
local registered,callback=0
function ListenToGameEvent(name,fn) assert(name=='entity_killed');registered=registered+1;callback=fn;return 1 end
R:Init();R:Init();assert(registered==1,'only one death listener')
for _,team in ipairs({2,3}) do
 entity=hero(team,28);selected=entity;callback({entindex_killed=10});assert(entity.timer==40)
end
for _,flag in ipairs({'null','creep','illusion','alive','isBoss','clone','double','reincarnating','aegis'}) do
 entity=hero(2,50);selected=entity;entity[flag]=true
 assert(not R:OnDeath({entindex_killed=10}) and entity.timer==nil,flag..' must not get a normal timer')
end
entity=hero(4,50);selected=entity;assert(not R:OnDeath({entindex_killed=10}))
entity=hero(2,50);selected=hero(2,50);assert(not R:OnDeath({entindex_killed=10}),'exclude secondary owned hero')
selected=entity;entity.playerID=-1;assert(not R:OnDeath({entindex_killed=10}))
entity=nil;assert(not R:OnDeath({entindex_killed=10}) and not R:OnDeath({}))
print('PASS hero respawn curve, both teams, event registration and reincarnation/Boss exclusions (mock; engine pending)')

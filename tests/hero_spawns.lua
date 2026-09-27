package.path='game/scripts/vscripts/?.lua;'..package.path
local passed=0
local function test(name,fn) fn();passed=passed+1;print('PASS '..name) end
function Vector(x,y,z) return {x=x,y=y,z=z} end
function GetGroundPosition(p) return p end
local blocked=false
GridNav={IsTraversable=function() return not blocked end,IsBlocked=function() return blocked end}
local created={}
function SpawnEntityFromTableSynchronous(class,data)
    local e={class=class,data=data,IsNull=function() return false end,SetTeam=function(self,t) self.team=t end}
    created[#created+1]=e;return e
end
local moves=0
function FindClearSpaceForUnit(h,p) assert(math.abs(p.x)>1000);moves=moves+1;h.pos=p end
local S=require('map/hero_spawns')
test('native team spawn markers exist before heroes and are never at origin',function()
    S:Init();assert(#created==6)
    for _,e in ipairs(created) do
        assert(e.class==(e.team==2 and 'info_player_start_goodguys' or 'info_player_start_badguys'))
        assert(e.data.Disabled==false and e.data.origin.y < -4000)
        assert((e.data.origin.x>0)==(e.team==2))
    end
end)
test('repeated initialization creates no duplicate start entities',function() S:Init();assert(#created==6) end)
local function hero(team,id)
    return {pos=Vector(0,0,0),IsNull=function() return false end,IsRealHero=function() return true end,
        IsIllusion=function() return false end,GetPlayerID=function() return id end,
        GetTeamNumber=function() return team end,GetAbsOrigin=function(self) return self.pos end,
        SetRespawnPosition=function(self,p) self.respawn=p end}
end
test('both teams recover to their own base and receive a nonzero respawn position',function()
    for _,team in ipairs({2,3}) do
        local h=hero(team,0);assert(S:ConfigureHero(h));assert(h.respawn==h.pos)
        assert((h.pos.x>0)==(team==2))
    end
    assert(moves==2)
end)
test('repeated spawn event does not move a hero fighting in a lane',function()
    local h=hero(2,0);h.pos=Vector(7500,1600,128);local p=h.pos
    S:ConfigureHero(h);S:ConfigureHero(h);assert(h.pos==p and moves==2)
end)
test('illusions, neutral units and ownerless heroes are excluded',function()
    local illusion=hero(2,0);illusion.IsIllusion=function() return true end
    assert(not S:ConfigureHero(illusion));assert(not S:ConfigureHero(hero(4,0)))
    assert(not S:ConfigureHero(hero(2,-1)));assert(moves==2)
end)
test('invalid navigation never registers an unsafe or origin start',function()
    blocked=true;S.points={};S.entities={};S:Init();assert(#created==6)
    assert(not S:ConfigureHero(hero(2,0)));assert(moves==2)
end)
print(passed..' hero spawn tests passed (mock engine).')

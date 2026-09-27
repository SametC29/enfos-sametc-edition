-- Runtime spawn markers for the approved Survival geometry. Never rebuild the
-- retired flat VMAP to fix spawn entities. Coordinates are existing base starts.
require("lib/log")
local Spawns = {points={}, entities={}}
local BASES = {
    [2]={{9611,-4547,555},{8961,-4515,555},{9286,-4544,555}},
    [3]={{-5936,-4289,400},{-6245,-4308,404},{-6568,-4261,389}},
}
local CLASSES = {[2]="info_player_start_goodguys",[3]="info_player_start_badguys"}

local function clearGround(position)
    -- Bounded search around the authored start, never around world origin.
    for _,radius in ipairs({0,64,128,256}) do
        for step=0,(radius==0 and 0 or 7) do
            local angle=step*math.pi/4
            local p=GetGroundPosition(Vector(position[1]+math.cos(angle)*radius,
                position[2]+math.sin(angle)*radius,position[3]),nil)
            if GridNav:IsTraversable(p) and not GridNav:IsBlocked(p) then return p end
        end
    end
end

function Spawns:Init()
    for _,team in ipairs({2,3}) do
        self.points[team]=self.points[team] or {}
        self.entities[team]=self.entities[team] or {}
        for slot,position in ipairs(BASES[team]) do
            local entity=self.entities[team][slot]
            if not entity or entity:IsNull() then
                local p=clearGround(position)
                if p then
                    entity=SpawnEntityFromTableSynchronous(CLASSES[team],{
                        targetname="enfos_hero_start_"..team.."_"..slot,
                        origin=p,angles="0 90 0",teamnumber=team,Disabled=false})
                    if entity and not entity:IsNull() then
                        entity:SetTeam(team)
                        self.entities[team][slot]=entity
                        self.points[team][slot]=p
                        Log:Info("hero_spawn","Registered team=%d slot=%d at %.0f %.0f %.0f",team,slot,p.x,p.y,p.z)
                    else
                        Log:Error("hero_spawn","Could not create start team=%d slot=%d",team,slot)
                    end
                else
                    Log:Error("hero_spawn","No traversable base start team=%d slot=%d; map navigation needs inspection",team,slot)
                end
            end
        end
    end
end

function Spawns:ConfigureHero(hero)
    if not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion() then return false end
    local id=hero:GetPlayerID()
    if not id or id<0 then return false end
    local points=self.points[hero:GetTeamNumber()]
    if not points then return false end
    local p=points[id%3+1] or points[1] or points[2] or points[3]
    if not p then return false end
    hero:SetRespawnPosition(p)
    -- Recovery only for an origin fallback. A repeated spawn/reconnect event
    -- must not pull a hero already fighting in its lane back to base.
    local current=hero:GetAbsOrigin()
    if math.abs(current.x)<1024 and math.abs(current.y)<1024 then
        FindClearSpaceForUnit(hero,p,true)
        Log:Warn("hero_spawn","Recovered origin fallback player=%d team=%d",id,hero:GetTeamNumber())
    end
    return true
end
return Spawns

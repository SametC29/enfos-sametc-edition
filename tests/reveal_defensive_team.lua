package.path = 'game/scripts/vscripts/?.lua;' .. package.path
function class(t) t.__index=t; return t end
function IsServer() return true end
function LinkLuaModifier() end
function EmitGlobalSound() end
local B=require('spellbringer/spellbringer_service')
local center={x=100,y=100}
local captured
function CreateModifierThinker(_,_,name,kv,pos,team)
 assert(name=='modifier_spellbringer_reveal_thinker' and pos==center)
 captured={kv=kv,team=team}
end
for _,team in ipairs({2,3}) do
 assert(B.ABILITY_DEFS.spellbringer_reveal.is_offensive==false)
 assert(B:CastReveal(team,{radius=900,duration=15},center))
 assert(captured.kv.defending_team==team,'defensive Reveal must target incoming hostiles on own lanes')
 assert(captured.team==team and captured.kv.team==team)
 local searched,revealed
 local previous=B.GetActiveHostiles
 B.GetActiveHostiles=function(_,defendingTeam,pos,radius)
  searched=defendingTeam
  assert(pos==center and radius==900)
  return {{AddNewModifier=function(_,caster,_,name,kv)
   assert(caster==parent and name=='modifier_truesight' and kv.duration==0.75)
   revealed=true
  end}}
 end
 parent={GetAbsOrigin=function() return center end}
 local thinker=setmetatable({GetParent=function() return parent end,StartIntervalThink=function() end},
  {__index=modifier_spellbringer_reveal_thinker})
 thinker:OnCreated(captured.kv)
 thinker:OnIntervalThink()
 assert(searched==team and revealed)
 -- The optional KV defaults must also select the caster's defending team.
 thinker:OnCreated({team=team,radius=900})
 assert(thinker.defendingTeam==team)
 B.GetActiveHostiles=previous
end
print('PASS defensive Reveal selects own defending team for both teams (mock; engine pending)')

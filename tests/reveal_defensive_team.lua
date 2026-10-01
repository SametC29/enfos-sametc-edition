package.path = 'game/scripts/vscripts/?.lua;' .. package.path
function class(t) t.__index=t; return t end
local server=true
function IsServer() return server end
function LinkLuaModifier() end
function EmitGlobalSound() end
local B=require('spellbringer/spellbringer_service')
local center={x=100,y=100}
local captured,owner,creationFailure,missingModifier
local removed,fow=0,{}
function UTIL_Remove(unit) unit.removed=true; removed=removed+1 end
PlayerResource={GetSelectedHeroEntity=function(_,id) assert(id==0);return owner end}
function AddFOWViewer(team,pos,radius,duration) fow={team=team,pos=pos,radius=radius,duration=duration} end
function CreateModifierThinker(caster,_,name,kv,pos,team)
 assert(caster==owner and name=='modifier_spellbringer_reveal_thinker' and pos==center)
 captured={kv=kv,team=team}
 if creationFailure then return nil end
 local parent={GetAbsOrigin=function() return center end,GetTeamNumber=function() return team end,IsNull=function() return false end}
 local modifier=setmetatable({GetParent=function() return parent end},{__index=modifier_spellbringer_reveal_thinker})
 function parent:FindModifierByName(id) assert(id==name); return not missingModifier and modifier or nil end
 modifier:OnCreated(kv)
 captured.parent=parent;captured.modifier=modifier
 return parent
end
DOTA_UNIT_TARGET_TEAM_BOTH=3;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES=16
for _,team in ipairs({2,3}) do
 owner={IsNull=function() return false end,GetTeamNumber=function() return team end}
 assert(B:CastReveal(team,{radius=900,duration=15},center,0))
 local aura=captured.modifier
 assert(captured.team==team and aura.defendingTeam==team)
 assert(fow.team==team and fow.pos==center and fow.radius==900 and fow.duration==15)
 assert(aura:IsAura() and aura:GetAuraRadius()==900 and aura:GetAuraDuration()==0.75)
 assert(aura:GetModifierAura()=='modifier_truesight','use engine-managed True Sight with an aura source')
 assert(aura:GetAuraSearchTeam()==3 and aura:GetAuraSearchType()==3 and aura:GetAuraSearchFlags()==16)
 local hostile={defendingTeam=team,IsNull=function() return false end,IsAlive=function() return true end}
 assert(not aura:GetAuraEntityReject(hostile),'accept own-lane invisible neutral, without a visibility prerequisite')
 hostile.defendingTeam=team==2 and 3 or 2
 assert(aura:GetAuraEntityReject(hostile),'never reveal the opposite defending arena')
 hostile.defendingTeam=nil;assert(aura:GetAuraEntityReject(hostile),'exclude player heroes and ambient units')
 hostile.defendingTeam=team;hostile.IsAlive=function() return false end
 assert(aura:GetAuraEntityReject(hostile) and aura:GetAuraEntityReject(nil))
 aura:OnCreated({team=tostring(team),radius='900',duration='15'})
 assert(aura.defendingTeam==team,'default metadata and numeric-string KV remain valid')
 server=false;aura:OnCreated(captured.kv)
 assert(aura:GetAuraRadius()==900 and aura.defendingTeam==team,'client initializes aura metadata')
 server=true;aura:OnDestroy();assert(captured.parent.removed,'expiry must retire the thinker entity')
end
owner=nil;assert(not B:CastReveal(2,{radius=900,duration=15},center,0))
owner={IsNull=function() return false end,GetTeamNumber=function() return 2 end}
creationFailure=true;assert(not B:CastReveal(2,{radius=900,duration=15},center,0))
creationFailure=false;missingModifier=true
local before=removed;assert(not B:CastReveal(2,{radius=900,duration=15},center,0));assert(removed==before+1)
-- Actual dispatch/rollback, not only CastReveal's result.
B.playerState={[0]={mana=100,max_mana=200,cooldowns={}}}
B.CanCast=function() return true end
B.SyncNetTable=function() end
PlayerResource.IsValidPlayerID=function(_,id) return id==0 end
PlayerResource.GetTeam=function() return 2 end
assert(not B:CastSpell(0,'spellbringer_reveal',center))
assert(B.playerState[0].mana==100 and B.playerState[0].cooldowns.spellbringer_reveal==nil)
server=false
local clientLinked=false
function LinkLuaModifier(name) if name=='modifier_spellbringer_reveal_thinker' then clientLinked=true end end
package.loaded['spellbringer/spellbringer_service']=nil
require('spellbringer/spellbringer_service')
assert(clientLinked,'register the aura source on the actual client module path')
print('PASS defensive Reveal source, native aura, team filters, expiry and failed-cast rollback (mock; engine pending)')

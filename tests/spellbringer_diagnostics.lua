package.path = 'game/scripts/vscripts/?.lua;' .. package.path
local lines, timers, sample, server, tools, now = {}, {}, {}, true, true, 0
print = function(line) lines[#lines + 1] = line end
IsServer = function() return server end
IsInToolsMode = function() return tools end
GameRules = {GetGameTime=function() return now end, GetGameModeEntity=function()
    return {SetContextThink=function(_,name,fn,delay) assert(delay==1 or delay==2 or delay==3); timers[name]=fn end}
end}
PlayerResource = {IsValidPlayerID=function(_,id) return id==0 end}
local reachable=true
GridNav = {IsTraversable=function() return true end, IsBlocked=function() return false end,
    CanFindPath=function() return reachable end}
DOTA_UNIT_ORDER_MOVE_TO_POSITION=1;DOTA_UNIT_ORDER_ATTACK_MOVE=3
function Vector(x,y,z)
    return setmetatable({x=x,y=y,z=z},{__add=function(p,q) return Vector(p.x+q.x,p.y+q.y,p.z+q.z) end})
end
local function unit(id, name, owner)
    return {is_allied_reinforcement=true, pos={x=100,y=100,z=0},
        IsNull=function(self) return self.removed or false end, IsAlive=function() return true end,
        GetUnitName=function() return name end, entindex=function() return id end,
        GetPlayerOwnerID=function() return owner end, GetTeamNumber=function() return 2 end,
        GetModifierCount=function() return 1 end, GetModifierNameByIndex=function() return 'modifier_kill' end,
        GetAbilityCount=function() return 0 end, GetAbsOrigin=function(self) return self.pos end,
        IsControllableByAnyPlayer=function() return true end, HasMovementCapability=function() return true end,
        GetIdealSpeed=function() return 276 end, IsRooted=function(self) return self.rooted or false end,
        GetCurrentActiveAbility=function(self) return self.active end,
        IsMoving=function() return false end, IsIdle=function() return true end, IsFrozen=function() return false end,
        IsStunned=function() return false end, IsCommandRestricted=function() return false end}
end
local a=unit(1,'enfos_wave_06',0)
local b=unit(2,'enfos_wave_06',1)
local unrelated=unit(3,'npc_dota_furion_treant',0)
Entities={FindAllByClassname=function(_,name) assert(name=='npc_dota_creature'); return {a,b,unrelated} end}
EntIndexToHScript=function(index) return ({a,b,unrelated})[index] end
local audit=require('tools/spellbringer_audit')
local registered, registrations
Convars={RegisterCommand=function(_,name,callback,description,flags)
    assert(name=='enfos_spellbringer_compare' and flags==0 and description)
    registered=callback;registrations=(registrations or 0)+1
end}
server=false; assert(audit.Run(0)==nil and EnfosSpellbringerOrderAudit==nil)
server=true;tools=false;assert(audit.Run(0)==nil and EnfosSpellbringerOrderAudit==nil)
tools=true;assert(audit.Run(7)==nil and EnfosSpellbringerOrderAudit==nil)
local rows=audit.Run(0)
assert(#rows==1 and rows[1].owner==0 and rows[1].movable and rows[1].modifiers=='modifier_kill')
assert(registered and registrations==1, 'Tools comparison command registered once after a valid spawn')
local order={issuer_player_id_const=0,order_type=1,units={['0']='1',['1']=2,['2']=3},position_x=300,position_y=100}
local watch=EnfosSpellbringerOrderAudit
watch({issuer_player_id_const=1,units={['0']=1}});assert(next(timers)==nil)
watch(order);assert(timers.SpellbringerOrderAudit_1 and not timers.SpellbringerOrderAudit_2)
assert(order.units['0']=='1' and order.order_type==1, 'audit must not change the order')
a.pos.x=250;a.rooted=true
assert(timers.SpellbringerOrderAudit_1()==nil)
assert(lines[#lines]:find('displacement=150.0',1,true))
assert(lines[#lines-2]:find('rooted=true',1,true), 'capture immobilization at observation time')
assert(lines[#lines-1]:find('active=none',1,true))
watch(order);a.removed=true;assert(timers.SpellbringerOrderAudit_1()==nil)
assert(lines[#lines]:find('removed before sample',1,true))
now=30;watch(order);assert(EnfosSpellbringerOrderAudit==nil, 'watch expires without looping')
function class(t) return t end
require('enfos_sametc')
DOTA_UNIT_ORDER_SELL_ITEM=33
EnfosSpellbringerOrderAudit=function() error('simulated stale diagnostic handle') end
assert(EnfosSametC:OrderFilter(order)==true, 'a diagnostic error must never reject movement')
assert(EnfosSpellbringerOrderAudit==nil)
-- Explicit spawn handles must report even an incorrect player assignment.
a.removed=false;now=0
Entities.FindAllByClassname=function() error('spawn diagnostics must not scan global units') end
rows=audit.Run(0,{b})
assert(#rows==1 and rows[1].owner==1, 'report wrong ownership instead of filtering it out')
assert(registrations==1, 'repeated spawns must not re-register the command')
timers={}
EnfosSpellbringerOrderAudit({issuer_player_id_const=0,order_type=1,units={['0']=2}})
assert(timers.SpellbringerOrderAudit_2, 'observe orders to the supplied spawn despite ownership mismatch')
-- Explicit comparison must never run in production, without a current group,
-- without a meaningful destination, on a disconnected path, or twice at once.
local spawned, orders, configured={}, {}, {}
PlayerResource.GetSelectedHeroEntity=function() return a end
package.loaded['waves/special_creeps']={Configure=function(u,wave,team,allied)
    assert(wave==6 and team==2 and allied);configured[#configured+1]=u
end}
CreateUnitByName=function(name,pos,clear,owner,npcOwner,team)
    assert(clear and owner==a and npcOwner==a and team==2)
    local u=unit(10+#spawned,name,0);u.is_allied_reinforcement=nil;u.pos=pos
    for _,method in ipairs({'SetMinimumGoldBounty','SetMaximumGoldBounty','SetDeathXP','SetOwner',
        'SetControllableByPlayer','SetBaseMoveSpeed','SetMaxMana','SetMana','SetBaseManaRegen','SetIdleAcquire','SetAcquisitionRange'}) do
        u[method]=function(self,...) self[method..'Args']={...} end
    end
    u.AddNewModifier=function(self,_,_,name,kv) assert(name=='modifier_kill' and kv.duration==8) end
    u.MoveToPosition=function(self,destination) self.directDestination=destination end
    spawned[#spawned+1]=u;return u
end
ExecuteOrderFromTable=function(order) orders[#orders+1]=order end
tools=false;assert(not audit.Compare(0));tools=true
audit.Run(0,{a});assert(not audit.Compare(0) and #spawned==0)
local move={issuer_player_id_const=0,order_type=1,units={['0']=1},position_x=700,position_y=100,queue=0}
local lineCount=#lines
EnfosSpellbringerOrderAudit(move)
local pathLine=lines[lineCount+3]
assert(pathLine:find('[SPELLBRINGER_PATH]',1,true) and pathLine:find('reachable=true',1,true)
    and pathLine:find('queued=0',1,true))
reachable=false;assert(not audit.Compare(0) and #spawned==0);reachable=true
registered(nil,'0')
assert(#spawned==3 and #orders==4 and #configured==1)
assert(spawned[1]:GetUnitName()=='enfos_wave_06' and configured[1]==spawned[2])
assert(spawned[3]:GetUnitName()=='npc_dota_neutral_forest_troll_high_priest')
for _,u in ipairs(spawned) do assert(u.enfosNoReward and u.SetDeathXPArgs[1]==0) end
assert(not audit.Compare(0) and #spawned==3,'repeated calls cannot accumulate fixtures')
spawned[1].pos.x=spawned[1].pos.x+150
timers.SpellbringerCompare_10()
assert(lines[#lines]:find('case=custom_bare',1,true) and lines[#lines]:find('displacement=150.0',1,true))
assert(spawned[1].directDestination and timers.SpellbringerDirect_10,
    'bare fixture should receive a direct-motor order after the normal order sample')
spawned[1].pos.x=spawned[1].pos.x+120
assert(timers.SpellbringerDirect_10()==nil)
assert(lines[#lines]:find('case=custom_bare',1,true) and lines[#lines]:find('direct_displacement=120.0',1,true))
spawned[2].removed=true;timers.SpellbringerCompare_11()
assert(lines[#lines]:find('inconclusive=removed_or_dead',1,true))
timers.SpellbringerCompare_12()
assert(spawned[3].directDestination and timers.SpellbringerDirect_12,
    'native control should also receive a direct-motor order')
spawned[3].removed=true;timers.SpellbringerDirect_12()
assert(lines[#lines]:find('direct=inconclusive_removed_or_dead',1,true))
io.write('PASS Spellbringer read-only movement diagnostics\n')

package.path = 'game/scripts/vscripts/?.lua;' .. package.path
local lines, timers, sample, server, tools, now = {}, {}, {}, true, true, 0
print = function(line) lines[#lines + 1] = line end
IsServer = function() return server end
IsInToolsMode = function() return tools end
GameRules = {GetGameTime=function() return now end, GetGameModeEntity=function()
    return {SetContextThink=function(_,name,fn,delay) assert(delay==1); timers[name]=fn end}
end}
PlayerResource = {IsValidPlayerID=function(_,id) return id==0 end}
GridNav = {IsTraversable=function() return true end, IsBlocked=function() return false end}
local function unit(id, name, owner)
    return {is_allied_reinforcement=true, pos={x=100,y=100,z=0},
        IsNull=function(self) return self.removed or false end, IsAlive=function() return true end,
        GetUnitName=function() return name end, entindex=function() return id end,
        GetPlayerOwnerID=function() return owner end, GetTeamNumber=function() return 2 end,
        GetModifierCount=function() return 1 end, GetModifierNameByIndex=function() return 'modifier_kill' end,
        GetAbilityCount=function() return 0 end, GetAbsOrigin=function(self) return self.pos end,
        IsControllableByAnyPlayer=function() return true end, HasMovementCapability=function() return true end,
        GetIdealSpeed=function() return 276 end, IsRooted=function(self) return self.rooted or false end,
        IsStunned=function() return false end, IsCommandRestricted=function() return false end}
end
local a=unit(1,'enfos_wave_06',0)
local b=unit(2,'enfos_wave_06',1)
local unrelated=unit(3,'npc_dota_furion_treant',0)
Entities={FindAllByClassname=function(_,name) assert(name=='npc_dota_creature'); return {a,b,unrelated} end}
EntIndexToHScript=function(index) return ({a,b,unrelated})[index] end
local audit=require('tools/spellbringer_audit')
server=false; assert(audit.Run(0)==nil and EnfosSpellbringerOrderAudit==nil)
server=true;tools=false;assert(audit.Run(0)==nil and EnfosSpellbringerOrderAudit==nil)
tools=true;assert(audit.Run(7)==nil and EnfosSpellbringerOrderAudit==nil)
local rows=audit.Run(0)
assert(#rows==1 and rows[1].owner==0 and rows[1].movable and rows[1].modifiers=='modifier_kill')
local order={issuer_player_id_const=0,order_type=1,units={['0']='1',['1']=2,['2']=3},position_x=300,position_y=100}
local watch=EnfosSpellbringerOrderAudit
watch({issuer_player_id_const=1,units={['0']=1}});assert(next(timers)==nil)
watch(order);assert(timers.SpellbringerOrderAudit_1 and not timers.SpellbringerOrderAudit_2)
assert(order.units['0']=='1' and order.order_type==1, 'audit must not change the order')
a.pos.x=250;a.rooted=true
assert(timers.SpellbringerOrderAudit_1()==nil)
assert(lines[#lines]:find('displacement=150.0',1,true))
assert(lines[#lines-1]:find('rooted=true',1,true), 'capture immobilization at observation time')
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
timers={}
EnfosSpellbringerOrderAudit({issuer_player_id_const=0,order_type=1,units={['0']=2}})
assert(timers.SpellbringerOrderAudit_2, 'observe orders to the supplied spawn despite ownership mismatch')
io.write('PASS Spellbringer read-only movement diagnostics\n')

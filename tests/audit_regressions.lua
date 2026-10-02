package.path='game/scripts/vscripts/?.lua;'..package.path
local passed=0
local function test(name,fn) fn();passed=passed+1;print('PASS '..name) end
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
function IsServer() return true end
function EmitGlobalSound() end
function Vector(x,y,z)
 local mt={__sub=function(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end,
  __add=function(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end}
 local v={x=x,y=y,z=z};function v:Length2D() return math.sqrt(self.x^2+self.y^2) end
 return setmetatable(v,mt)
end
DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP=2;DOTA_GAMERULES_STATE_HERO_SELECTION=3
DOTA_GAMERULES_STATE_GAME_IN_PROGRESS=7;DOTA_GAMERULES_STATE_POST_GAME=8
DOTA_CONNECTION_STATE_CONNECTED=2;DOTA_ABILITY_TYPE_ULTIMATE=1
DOTA_DAMAGE_FLAG_REFLECTION=16;DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION=1024
bit={band=function(a,b) return math.floor(a/b)%2==1 and b or 0 end}
local phase=2
local players={[0]=2,[1]=2,[2]=3,[11]=2}
PlayerResource={heroes={},IsValidPlayerID=function(_,id) return players[id]~=nil end,
 GetTeam=function(_,id) return players[id] end,GetConnectionState=function() return 2 end,
 GetSelectedHeroEntity=function(self,id) return self.heroes[id] end,
 GetPlayer=function(_,id) return {id=id,SetSelectedHero=function() end} end}
GameRules={State_Get=function() return phase end,IsGamePaused=function() return false end,
 GetGameModeEntity=function() return {SetContextThink=function() end} end,
 PlayerHasCustomGameHostPrivileges=function(_,p) return p.id==0 end}
CustomGameEventManager={RegisterListener=function() end}
CustomNetTables={SetTableValue=function() end}
local S=require('setup/enfos_setup_manager')
test('server roster and Aghanim roles cover all 40 real heroes',function()
 local A=require('heroes/aghanim_manager');local counts={}
 assert(#S.HERO_ROSTER==40)
 for _,h in ipairs(S.HERO_ROSTER) do counts[h.role]=(counts[h.role] or 0)+1;assert(A:DetectHeroRole(h.id)==h.role) end
 for _,n in pairs(counts) do assert(n==8) end
end)
test('setup denies non-host, missing identity and mid-match mutation',function()
 S:Init(nil,nil);S:OnSetDifficulty({difficulty='hell'});assert(S.selectedDifficulty=='normal')
 S:OnSetDifficulty({PlayerID=1,difficulty='hell'});assert(S.selectedDifficulty=='normal')
 S:OnSetDifficulty({PlayerID=0,difficulty='hard'});assert(S.selectedDifficulty=='hard')
 phase=7;S:OnSetDifficulty({PlayerID=0,difficulty='hell'});assert(S.selectedDifficulty=='hard')
end)
test('picks accept new roster heroes, reject repeated and invalid-phase picks',function()
 phase=3;S:OnLockInHero({PlayerID=0,hero_name='npc_dota_hero_puck'});assert(S.playerPicks[0]=='npc_dota_hero_puck')
 S:OnLockInHero({PlayerID=0,hero_name='npc_dota_hero_sven'});assert(not S.teamPicks[2].npc_dota_hero_sven)
 S:OnLockInHero({PlayerID=1,hero_name='npc_dota_hero_puck'});assert(not S.playerPicks[1])
 S:OnLockInHero({PlayerID=2,hero_name='npc_dota_hero_puck'});assert(S.playerPicks[2])
 phase=7;S:OnLockInHero({PlayerID=11,hero_name='npc_dota_hero_jakiro'});assert(not S.playerPicks[11])
end)
local V=require('lib/validation')
test('economy rejects NaN, infinity, negative and excessive amounts',function()
 for _,n in ipairs({0/0,math.huge,-math.huge,-1,100000001,'bad'}) do assert(V.Amount(n)==nil) end
 assert(V.Amount('1000')==1000)
 local E=require('economy/economy_manager');E:Init()
 for _,n in ipairs({0/0,math.huge,-math.huge}) do
  assert(not E:ConvertGoldToLumber(0,n));assert(not E:ConvertLumberToGold(0,n))
  assert(not E:TransferGold(0,1,n));assert(not E:TransferLumber(0,1,n))
 end
 assert(E:GetLumber(0)==0)
end)
test('all 60 wave plans conserve player threat budget and boss-only count',function()
 local W=require('waves/wave_definitions')
 for wave=1,60 do for players=0,5 do
  local plan,spent,budget=W:GetSpawnPlan(wave,players);local count=0
  for _,e in ipairs(plan) do assert(e.count>=0 and e.count==math.floor(e.count));count=count+e.count end
  if players==0 then assert(count==0)
  elseif W:IsBossWave(wave) then assert(count==1)
  else assert(spent<=budget and budget-spent<2.5) end
  if wave==1 then assert(count==20*players) end
 end end
end)
test('stationary attacking creep does not cancel attacks on a long route',function()
 local AI=require('waves/creep_ai');local orders=0
 ExecuteOrderFromTable=function() orders=orders+1 end
 local target={IsNull=function() return false end,IsAlive=function() return true end}
 local unit={IsNull=function() return false end,IsAlive=function() return true end,
  GetAbsOrigin=function() return Vector(2000,0,0) end,IsStunned=function() return false end,
  IsRooted=function() return false end,IsChanneling=function() return false end,
  HasModifier=function() return false end,GetAttackTarget=function() return target end}
 local state={unit=unit,route={Vector(0,0,0),Vector(6000,0,0)},waypointIndex=2,lastPos=Vector(2000,0,0),stuckTimer=0}
 for i=1,30 do AI:OnThink(state) end
 assert(orders==0 and state.stuckTimer==0)
end)
test('route AI preserves an active Boss cast even at waypoint arrival',function()
 local AI=require('waves/creep_ai');local orders,leaks=0,0
 ExecuteOrderFromTable=function() orders=orders+1 end
 local casting=true
 local ability={IsNull=function() return false end,IsInAbilityPhase=function() return casting end}
 local unit={IsNull=function() return false end,IsAlive=function() return true end,
  GetAbsOrigin=function() return Vector(6000,0,0) end,IsStunned=function() return false end,
  IsRooted=function() return false end,IsChanneling=function() return false end,
  HasModifier=function() return false end,GetCurrentActiveAbility=function() return ability end}
 local state={unit=unit,route={Vector(0,0,0),Vector(6000,0,0)},waypointIndex=2,
  lastPos=Vector(6000,0,0),stuckTimer=5,onLeakCallback=function() leaks=leaks+1 end}
 AI:OnThink(state)
 assert(orders==0 and leaks==0 and state.waypointIndex==2 and state.stuckTimer==0,
  'active native cast must survive route/stuck/leak handling')
 casting=false;AI:OnThink(state)
 assert(leaks==1,'route completion must resume when the cast finishes')
end)

test('Axe Call prevents route orders and leaks for normal creeps and runners until it expires',function()
 local AI=require('waves/creep_ai');local orders,leaks=0,0;local taunted=true
 ExecuteOrderFromTable=function() orders=orders+1 end
 local unit={IsNull=function() return false end,IsAlive=function() return true end,
  GetAbsOrigin=function() return Vector(6000,0,0) end,IsStunned=function() return false end,
  IsRooted=function() return false end,IsChanneling=function() return false end,
  HasModifier=function(_,name) return taunted and name=='modifier_enfos_axe_call_taunt' end}
 for _,runner in ipairs({false,true}) do
  local state={unit=unit,route={Vector(0,0,0),Vector(6000,0,0)},waypointIndex=2,isRunner=runner,
   lastPos=Vector(6000,0,0),stuckTimer=5,onLeakCallback=function() leaks=leaks+1 end}
  taunted=true;AI:OnThink(state)
  assert(orders==0 and leaks==0 and state.waypointIndex==2 and state.stuckTimer==0,
   'Call must suspend route progression even at the Life Core waypoint')
  taunted=false;AI:OnThink(state);assert(leaks==1, 'Route resumes after taunt expiry')
  leaks=0
 end
end)

test('Legion Duel suspends normal and runner route progress until it ends',function()
 local AI=require('waves/creep_ai');local orders,leaks=0,0;local dueling=true
 ExecuteOrderFromTable=function() orders=orders+1 end
 local unit={IsNull=function() return false end,IsAlive=function() return true end,
  GetAbsOrigin=function() return Vector(6000,0,0) end,IsStunned=function() return false end,
  IsRooted=function() return false end,IsChanneling=function() return false end,
  HasModifier=function(_,name) return dueling and name=='modifier_enfos_legion_duel_buff' end}
 for _,runner in ipairs({false,true}) do
  local state={unit=unit,route={Vector(0,0,0),Vector(6000,0,0)},waypointIndex=2,isRunner=runner,
   lastPos=Vector(6000,0,0),stuckTimer=5,onLeakCallback=function() leaks=leaks+1 end}
  dueling=true;AI:OnThink(state)
  assert(orders==0 and leaks==0 and state.waypointIndex==2 and state.stuckTimer==0,
   'A Duel participant must not leak at the Life Core while forced to fight')
  dueling=false;AI:OnThink(state);assert(leaks==1,'Route resumes after Duel ends')
  leaks=0
 end
end)

test('point-targeted Spellbringer summons continue from the selected location',function()
 local AI=require('waves/creep_ai')
 local base=AI.ROUTES[3].center
 local selected=Vector(base[3].x+12,base[3].y-9,136)
 local route=AI:RouteFromPosition(3,'center',selected)
 assert(route and route[1].x==selected.x and route[1].y==selected.y,
  'route must begin at the player-selected spawn point')
 assert(route[2]==base[4],
  'route must continue after the nearest lane waypoint, not return to waypoint 1')
end)
test('Spellbringer barrier visits sparse entity-index tables and rejects opposite arena',function()
 local B=require('spellbringer/spellbringer_service');local count=0
	local function makeCreep(id)
	 return {defendingTeam=3,IsNull=function() return false end,IsAlive=function() return true end,entindex=function() return id end,
	  GetAbsOrigin=function() return Vector(7500,-2000,136) end,AddNewModifier=function() count=count+1 end}
	end
	B.waveManager={activeCreeps={[3]={[187]=makeCreep(187),[922]=makeCreep(922)}}}
 B:CastArcaneBarrier(2,3,{duration=10});assert(count==2)
 B.playerState={};B.isCoop=false
 assert(not B:CanCast(0,'spellbringer_reveal',Vector(-7500,-1300,136)))
 assert(B:CanCast(0,'spellbringer_reveal',Vector(4697,11364,128)),
  'valid Radiant lane-start targets near y=11,000 must not be rejected by a stale screen-space bound')
 assert(B:CanCast(0,'spellbringer_reveal',Vector(2500,0,128)),
  'navigable terrain near the center must not be rejected by an arbitrary x dead zone')
 assert(not B:CanCast(0,'spellbringer_reveal',Vector(4697,13000,128)),
  'targets outside the map safety envelope remain rejected')
 assert(not B:CanCast(90,'spellbringer_reveal'))
end)
test('Spellbringer server event accepts a clicked lane start beyond the old y limit',function()
 local B=require('spellbringer/spellbringer_service')
 local oldGround=GetGroundPosition
 local oldThinker=CreateModifierThinker
 local oldHero=PlayerResource.heroes[0]
 PlayerResource.heroes[0]={IsNull=function() return false end,GetTeamNumber=function() return 2 end}
 CreateModifierThinker=function(_,_,name)
  return {IsNull=function() return false end,FindModifierByName=function(_,id) return id==name and {} or nil end}
 end
 GetGroundPosition=function(pos) return pos end
 B.playerState={};B.summons={[2]={},[3]={}};B.isCoop=false
 B:OnCastRequest(0,{PlayerID=0,ability_name='spellbringer_reveal',target_x=4697,target_y=11364,target_z=128})
 GetGroundPosition=oldGround
 CreateModifierThinker=oldThinker;PlayerResource.heroes[0]=oldHero
 assert(B:GetMana(0)==70,'accepted click should spend the reveal cost')
 assert(B:GetCooldownRemaining(0,'spellbringer_reveal')==15,
  'accepted click should execute the targeted spell instead of being dropped by the old y bound')
end)
test('Spellbringer point-target summons use the selected world position',function()
 local B=require('spellbringer/spellbringer_service')
 local center=Vector(7500,-2000,136)
 local originalCreate=CreateUnitByName
 local spawned={}
 local function entity(name,pos,team)
  local u={name=name,pos=pos,team=team,modifiers={},id=#spawned+1001}
  function u:IsNull() return false end
  function u:IsAlive() return true end
  function u:GetUnitName() return self.name end
  function u:GetAbsOrigin() return self.pos end
  function u:GetTeamNumber() return self.team end
  function u:entindex() return self.id end
  function u:AddNewModifier(_,_,mod,kv) self.modifiers[mod]=kv or {} end
  function u:EmitSound(sound) self.sound=sound end
  function u:SetIdleAcquire(v) self.idleAcquire=v end
  function u:SetAcquisitionRange(v) self.acquisitionRange=v end
  spawned[#spawned+1]=u
  return u
 end
 CreateUnitByName=function(name,pos,_,_,_,team) return entity(name,pos,team) end
 B.summons={[2]={},[3]={}}
 assert(B:CastWarStandard(2,3,B.ABILITY_DEFS.spellbringer_war_standard,center))
 assert(spawned[1].pos==center and spawned[1].team==4)
 assert(spawned[1].modifiers.modifier_spellbringer_war_standard_aura~=nil)
 assert(spawned[1].modifiers.modifier_kill.duration==20)
 assert(spawned[1].defendingTeam==3 and spawned[1].is_spellbringer_summon)
 assert(B:CastThornIdol(2,3,B.ABILITY_DEFS.spellbringer_thorn_idol,center))
 assert(spawned[2].pos==center and spawned[2].team==4)
 assert(spawned[2].modifiers.modifier_spellbringer_thorn_idol_aura~=nil)
 assert(spawned[2].modifiers.modifier_kill.duration==15)
 local oldAI=package.loaded['waves/creep_ai']
 local attached=0
 package.loaded['waves/creep_ai']={
  RouteFromPosition=function(_,team,lane,pos) assert(team==3 and lane=='center');return {pos,Vector(8000,-2000,136)} end,
  Attach=function(_,unit,team,lane,onLeak,route) attached=attached+1;unit.route=route;assert(team==3 and lane=='center' and type(onLeak)=='function') end,
 }
 B.waveManager={SPAWN_LOCATIONS={[3]={center=center}}}
 local before=#spawned
 assert(B:CastRiftSurge(2,3,B.ABILITY_DEFS.spellbringer_rift_surge,center))
 assert(#spawned==before+2 and attached==2,'Rift Surge should create and route both units')
 for i=before+1,#spawned do
  local u=spawned[i]
  local delta=u.pos-center
  assert(math.abs(delta.x)<=50 and math.abs(delta.y)<=50,
   'Rift Surge spawn must remain within 50 units on each axis of the cursor')
  assert(u.defendingTeam==3 and u.is_spellbringer_summon and u.enfosNoReward)
  assert(u.idleAcquire and u.acquisitionRange==650 and u.modifiers.modifier_kill.duration==30)
 end
 CreateUnitByName=originalCreate
 package.loaded['waves/creep_ai']=oldAI
end)
test('Spellbringer barrier, standards and Thorn Idol apply bounded effects to the defended wave',function()
 local oldMagic,oldPhysical=DAMAGE_TYPE_MAGICAL,DAMAGE_TYPE_PHYSICAL
 local oldFriendly,oldBarrierProp,oldDamageProp,oldMoveProp,oldTakeDamage=
  DOTA_UNIT_TARGET_TEAM_FRIENDLY,MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
  MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
  MODIFIER_EVENT_ON_TAKEDAMAGE
 DAMAGE_TYPE_MAGICAL,DAMAGE_TYPE_PHYSICAL=2,1
 DOTA_UNIT_TARGET_TEAM_FRIENDLY=1
 MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE=1,2
 MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_EVENT_ON_TAKEDAMAGE=3,4

 local barrier=setmetatable({},{__index=modifier_spellbringer_arcane_barrier})
 local destroyed=0;barrier.Destroy=function() destroyed=destroyed+1 end
 assert(barrier:GetModifierMagicalResistanceBonus()==40)
 assert(barrier:GetModifierTotal_ConstantBlock({damage_type=DAMAGE_TYPE_MAGICAL,damage=200})==200)
 assert(barrier:GetModifierTotal_ConstantBlock({damage_type=DAMAGE_TYPE_PHYSICAL,damage=80})==0)
 assert(barrier:GetModifierTotal_ConstantBlock({damage_type=DAMAGE_TYPE_MAGICAL,damage=200})==100)
 assert(destroyed==1,'Arcane Barrier must consume its 300-point shield and destroy at zero')

 local defendingWave={defendingTeam=3,GetMaxHealth=function() return 400 end}
 local standardAura=setmetatable({GetParent=function() return defendingWave end},{__index=modifier_spellbringer_war_standard_aura})
 local idolAura=setmetatable({GetParent=function() return defendingWave end},{__index=modifier_spellbringer_thorn_idol_aura})
 assert(standardAura:IsAura() and standardAura:GetAuraRadius()==800)
 assert(standardAura:GetAuraSearchTeam()==DOTA_UNIT_TARGET_TEAM_FRIENDLY)
 assert(not standardAura:GetAuraEntityReject({defendingTeam=3}) and standardAura:GetAuraEntityReject({defendingTeam=2}))
 assert(idolAura:IsAura() and idolAura:GetAuraEntityReject({defendingTeam=2}))
 local standardBuff=setmetatable({},{__index=modifier_spellbringer_war_standard_buff})
 assert(standardBuff:GetModifierBaseDamageOutgoing_Percentage()==25 and standardBuff:GetModifierMoveSpeedBonus_Constant()==40)

 local attacker={IsNull=function() return false end}
 local reflected={};local oldApply=ApplyDamage
 ApplyDamage=function(kv) reflected[#reflected+1]=kv end
 local idolBuff=setmetatable({GetParent=function() return defendingWave end},{__index=modifier_spellbringer_thorn_idol_buff})
 idolBuff:OnTakeDamage({unit=defendingWave,attacker=attacker,damage=120,damage_flags=0})
 idolBuff:OnTakeDamage({unit=defendingWave,attacker=attacker,damage=30,damage_flags=DOTA_DAMAGE_FLAG_REFLECTION})
 assert(#reflected==1 and reflected[1].victim==attacker and reflected[1].damage==30)
 assert(reflected[1].damage_type==DAMAGE_TYPE_PHYSICAL
  and bit.band(reflected[1].damage_flags,DOTA_DAMAGE_FLAG_REFLECTION)~=0,
  'Thorn Idol reflect must be flagged so reflection cannot recurse')
 ApplyDamage=oldApply
 DAMAGE_TYPE_MAGICAL,DAMAGE_TYPE_PHYSICAL=oldMagic,oldPhysical
 DOTA_UNIT_TARGET_TEAM_FRIENDLY=oldFriendly
 MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE=oldBarrierProp,oldDamageProp
 MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,MODIFIER_EVENT_ON_TAKEDAMAGE=oldMoveProp,oldTakeDamage
end)
test('Spellbringer displacement returns only nearby regular hostile creeps to their route start',function()
 local B=require('spellbringer/spellbringer_service')
 local center=Vector(7500,-2000,136)
 local start=Vector(7000,-2000,136)
 local moved={}
 local oldAI=package.loaded['waves/creep_ai']
 package.loaded['waves/creep_ai']={ROUTES={[2]={left={start}}},OrderMoveToWaypoint=function(_,state) state.ordered=true end}
 local function creep(id,name,x,isBoss)
  local state={route={start,Vector(7600,-2000,136)},waypointIndex=2}
  local u={defendingTeam=2,isBoss=isBoss,creepState=state,name=name,pos=Vector(x,-2000,136),id=id}
  function u:IsNull() return false end
  function u:IsAlive() return true end
  function u:entindex() return self.id end
  function u:GetUnitName() return self.name end
  function u:GetAbsOrigin() return self.pos end
  function u:EmitSound(sound) self.sound=sound end
  return u
 end
 local regular=creep(1101,'enfos_creep_soldier',7520,false)
 local boss=creep(1102,'npc_dota_hero_sven',7525,true)
 local outside=creep(1103,'enfos_creep_soldier',8100,false)
 B.waveManager={activeCreeps={[2]={regular,boss,outside}}}
 local oldClear=FindClearSpaceForUnit
 FindClearSpaceForUnit=function(unit,pos) moved[#moved+1]={unit=unit,pos=pos};unit.pos=pos end
 assert(B:CastWholeDisplacement(2,B.ABILITY_DEFS.spellbringer_whole_displacement,center))
 assert(#moved==1 and moved[1].unit==regular and moved[1].pos==start)
 assert(regular.creepState.waypointIndex==1 and regular.creepState.lastPos==start and regular.creepState.ordered)
 assert(regular.sound=='Hero_Chen.TeleportOut')
 FindClearSpaceForUnit=oldClear
 package.loaded['waves/creep_ai']=oldAI
end)
test('Scepter only buffs ultimate abilities and reflection cannot recurse',function()
 local ult={GetAbilityType=function() return 1 end};local basic={GetAbilityType=function() return 0 end}
 assert(modifier_enfos_scepter_upgrade:GetModifierSpellAmplify_Percentage({inflictor=ult})==40)
 assert(modifier_enfos_scepter_upgrade:GetModifierSpellAmplify_Percentage({inflictor=basic})==0)
 assert(modifier_enfos_scepter_upgrade:GetModifierPercentageCooldown({ability=basic})==0)
 local parent={};local m=setmetatable({role='Tank',GetParent=function() return parent end},{__index=modifier_enfos_shard_upgrade})
 ApplyDamage=function() error('reflection recursed') end
 m:OnTakeDamage({unit=parent,damage_flags=16,original_damage=100})
end)
require('abilities/pve_kits')
test('Ascended failure restores the same charged item and stash slot without charging lumber',function()
 local shop=require('economy/ascended_shop')
 local base={charges=17,IsNull=function() return false end,GetAbilityName=function() return 'item_blade_mail' end}
 local hero={slots={[12]=base},IsNull=function() return false end,IsAlive=function() return true end}
 function hero:GetItemInSlot(i) return self.slots[i] end
 function hero:TakeItem(it) for i,v in pairs(self.slots) do if v==it then self.slots[i]=nil end end end
 function hero:AddItem(it) if it~=base then return nil end;self.slots[0]=it;return it end
 function hero:SwapItems(a,b) self.slots[a],self.slots[b]=self.slots[b],self.slots[a] end
 PlayerResource.heroes[0]=hero
 local lumber=85;shop.economyManager={GetLumber=function() return lumber end,ModifyLumber=function(_,_,n) lumber=lumber+n end}
 CreateItem=function() return {} end;UTIL_Remove=function(it) assert(it~=base) end
 local ok=shop:PurchaseUpgrade(0,'item_ascended_thornplate')
 assert(not ok and lumber==85 and hero.slots[12]==base and base.charges==17)
 assert(not shop:Sellback(0,{IsNull=function() return false end,GetAbilityName=function() return 'item_ascended_thornplate' end}))
end)
test('gold conversions spend both reliable and unreliable gold via the engine spend API',function()
 local E=require('economy/economy_manager');E:Init()
 local reliable,unreliable=50,950
 PlayerResource.GetGold=function() return reliable+unreliable end
 PlayerResource.SpendGold=function(_,_,n)
  local use=math.min(unreliable,n);unreliable=unreliable-use;reliable=reliable-(n-use)
 end
 assert(E:ConvertGoldToLumber(0,1000))
 assert(reliable==0 and unreliable==0 and E:GetLumber(0)==10)
end)
test('Juggernaut crit chance can fail and succeeds with configured multiplier',function()
 local a={GetSpecialValueFor=function(_,k) return k=='crit_chance' and 25 or 200 end}
 local p={IsNull=function() return false end,PassivesDisabled=function() return false end,GetTeamNumber=function() return 2 end}
 local m=setmetatable({GetParent=function() return p end,GetAbility=function() return a end},{__index=modifier_enfos_pve_crit})
 local e={target={IsNull=function() return false end,GetTeamNumber=function() return 4 end}}
 RollPercentage=function() return false end;assert(m:GetModifierPreAttack_CriticalStrike(e)==nil)
 RollPercentage=function() return true end;assert(m:GetModifierPreAttack_CriticalStrike(e)==200)
end)
test('Fiery Soul stack cap and Guardian Angel physical immunity are real properties',function()
 local m=setmetatable({stack=1,GetStackCount=function(self) return self.stack end,SetStackCount=function(self,n) self.stack=n end,
  GetParent=function() return {PassivesDisabled=function() return false end} end,
  GetAbility=function() return {GetSpecialValueFor=function(_,k) return k=='fiery_soul_max_stacks' and 4 or 30 end} end},{__index=modifier_enfos_pve_fiery_stacks})
 for i=1,20 do m:OnRefresh() end
 assert(m.stack==4 and m:GetModifierAttackSpeedBonus_Constant()==120)
 assert(modifier_enfos_pve_angel:GetAbsoluteNoDamagePhysical()==1)
end)
test('all native-derived Ascended upgrades are exposed',function()
 local shop=require('economy/ascended_shop');local available=0
 for _,entry in ipairs(shop.ITEMS) do
  if entry.available then available=available+1 else
   local ok,reason=shop:PurchaseUpgrade(0,entry.id)
   assert(not ok and reason=='not_available')
  end
 end
 assert(available==31)
end)
test('Spellbringer reveal and purification select neutral hostiles by defending team',function()
 local B=require('spellbringer/spellbringer_service')
 local center=Vector(7500,-2000,136)
 local revealed,removed,damage=0,0,0
 local function creep(id,team,x,isSummon)
  return {defendingTeam=team,is_spellbringer_summon=isSummon,IsNull=function() return false end,IsAlive=function() return true end,
   entindex=function() return id end,GetAbsOrigin=function() return Vector(x,-2000,136) end,
   GetUnitName=function() return isSummon and 'enfos_spellbringer_war_standard' or 'enfos_creep_assassin' end,
   AddNewModifier=function(_,_,_,name,kv) if name=='modifier_truesight' and kv.duration>0 then revealed=revealed+1 end end,
   RemoveModifierByName=function() removed=removed+1 end}
 end
 local incoming=creep(301,2,7510,false)
 local opposing=creep(302,3,7510,false)
 local outside=creep(303,2,9000,false)
 local summon=creep(304,2,7520,true)
 B.waveManager={activeCreeps={[2]={[301]=incoming,[303]=outside},[3]={[302]=opposing}}}
 B.summons={[2]={[304]=summon},[3]={}}

	local reveal=setmetatable({}, {__index=modifier_spellbringer_reveal_thinker})
 reveal.team=3;reveal.defendingTeam=2;reveal.radius=300
 reveal.GetParent=function() return {GetAbsOrigin=function() return center end} end
 assert(reveal:IsAura() and reveal:GetModifierAura()=='modifier_truesight')
 assert(not reveal:GetAuraEntityReject(incoming) and not reveal:GetAuraEntityReject(summon))
 assert(reveal:GetAuraEntityReject(opposing) and reveal:GetAuraRadius()==300,
  'Reveal must filter by defending arena; the engine aura owns distance and visibility')

 local oldFind,oldDamage,oldFOW=FindUnitsInRadius,ApplyDamage,AddFOWViewer
 local fow={}
 AddFOWViewer=function(team,pos,radius,duration,obstructed) fow={team=team,pos=pos,radius=radius,duration=duration,obstructed=obstructed} end
 local parent={GetAbsOrigin=function() return center end}
 local thinker=setmetatable({GetParent=function() return parent end,StartIntervalThink=function(self,n) self.interval=n end},{__index=modifier_spellbringer_reveal_thinker})
 thinker:OnCreated({team=3,defending_team=2,radius=300,duration=15})
 assert(fow.team==3 and fow.pos==center and fow.radius==300 and fow.duration==15 and fow.obstructed==false)
 assert(thinker:IsAura() and thinker.defendingTeam==2)
 FindUnitsInRadius=function(_,_,_,_,teamFilter)
  assert(teamFilter==DOTA_UNIT_TARGET_TEAM_FRIENDLY,'only allied hero cleanse should use a player team filter')
  return {}
 end
 ApplyDamage=function(data) damage=damage+data.damage end
 B:CastPurification(2,{radius=300,summon_damage=800},center)
 FindUnitsInRadius,ApplyDamage,AddFOWViewer=oldFind,oldDamage,oldFOW
 assert(removed==6,'Purification should dispel all three Spellbringer modifiers from the hostile wave and summon')
 assert(damage==800,'Purification should damage the tracked hostile Spellbringer summon')
end)
print(passed..' audit regression tests passed (mock engine).')

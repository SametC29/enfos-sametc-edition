package.path='game/scripts/vscripts/?.lua;'..package.path
local passed=0
local function test(name,fn) fn();passed=passed+1;print('PASS '..name) end
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
function IsServer() return true end
function EmitGlobalSound() end
function Vector(x,y,z)
 local mt={__sub=function(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end}
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
test('Spellbringer barrier visits sparse entity-index tables and rejects opposite arena',function()
 local B=require('spellbringer/spellbringer_service');local count=0
 local c={IsNull=function() return false end,IsAlive=function() return true end,AddNewModifier=function() count=count+1 end}
 B.waveManager={activeCreeps={[3]={[187]=c,[922]=c}}}
 B:CastArcaneBarrier(2,3,{duration=10});assert(count==2)
 B.playerState={};B.isCoop=false
 assert(not B:CanCast(0,'spellbringer_reveal',Vector(-7500,-1300,136)))
 assert(not B:CanCast(90,'spellbringer_reveal'))
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
test('current-schema damaged profiles are repaired, not just old schemas',function()
 local storage=require('progression/storage_adapter')
 for _,p in ipairs({{}, {schemaVersion=1,legacy={offense=math.huge},accountLevel=0/0}, {schemaVersion=1,accountLevel=10,legacy={offense=12,defense=12}}}) do
  local fixed=storage.MigrateProfile(p)
  assert(type(fixed.matchHistory)=='table' and type(fixed.heroMastery)=='table')
  assert(fixed.accountLevel>=1 and fixed.unspentLegacyPoints<=24)
 end
 assert(storage.LocalStorageAdapter.New().durable==false)
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
print(passed..' audit regression tests passed (mock engine).')

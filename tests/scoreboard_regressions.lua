package.path='game/scripts/vscripts/?.lua;'..package.path
function Dynamic_Wrap(t,k) return t[k] end
local listeners={};function ListenToGameEvent(n,f) assert(not listeners[n]);listeners[n]=f end
local units={};function EntIndexToHScript(i) return units[i] end
DOTA_ModifyGold_SellItem=13;DOTA_ModifyGold_PurchaseItem=14
local data={};CustomNetTables={SetTableValue=function(_,n,k,v) data[k]=v end}
PlayerResource={IsValidPlayerID=function(_,id) return id==0 end,GetSelectedHeroEntity=function() return nil end}
GameRules={GetGameModeEntity=function() return {SetContextThink=function() end} end}
package.loaded['economy/economy_manager']={playerLumber={},GetLumber=function() return 17 end}
local S=require('stats/scoreboard_manager');S:Init();S:Init()
local attacker={IsNull=function() return false end,GetPlayerOwnerID=function() return 0 end,GetTeamNumber=function() return 2 end}
local enemy={IsNull=function() return false end,GetTeamNumber=function() return 4 end}
units[1]=attacker;units[2]=enemy
S:OnEntityHurt({entindex_attacker=1,entindex_killed=2,damage=120.5});S:OnEntityKilled({entindex_attacker=1,entindex_killed=2});S:OnEntityKilled({entindex_attacker=1,entindex_killed=2})
assert(S:GetDamageDealt(0)==120.5 and S:GetKills(0)==1)
enemy.enfosStatsKilled=nil;enemy.enfosLeaked=true;S:OnEntityKilled({entindex_attacker=1,entindex_killed=2});assert(S:GetKills(0)==1)
assert(S:GoldFilter({player_id_const=0,gold=50,reason_const=1}));S:GoldFilter({player_id_const=0,gold=-25,reason_const=14});S:GoldFilter({player_id_const=0,gold=25,reason_const=13});S:SyncPlayer(0)
assert(data['0'].gold_earned==50 and data['0'].lumber==17 and data['0'].damage_dealt==120)
local a={IsNull=function() return false end};local b={IsNull=a.IsNull};a.GetOwner=function() return b end;b.GetOwner=function() return a end;assert(S:ResolvePlayerID(a)==-1)
local callback=Dynamic_Wrap(S,'GoldFilter');assert(callback(S,{player_id_const=0,gold=5,reason_const=1}));assert(S.stats[0].goldEarned==55)
print('Scoreboard regression tests passed')

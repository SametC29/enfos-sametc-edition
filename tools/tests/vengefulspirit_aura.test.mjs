import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Vengeance Aura follows its source during linger, not a recipient Break',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
require('abilities/heroes/vengefulspirit/e')
local function unit()
 local u={removed=false,broken=false,illusion=false}
 function u:IsNull()return self.removed end
 function u:PassivesDisabled()assert(not self.removed,'removed passive query');return self.broken end
 function u:IsIllusion()assert(not self.removed,'removed illusion query');return self.illusion end
 return u
end
local source,recipient=unit(),unit()
local ab={removed=false,rank=1}
function ab:IsNull()return self.removed end
function ab:GetLevel()assert(not self.removed);return self.rank end
function ab:GetSpecialValueFor(k)assert(not self.removed);assert(k=='bonus_damage_pct');return 15+(self.rank-1)*2 end
local buff=setmetatable({GetCaster=function()return source end,GetParent=function()return recipient end,
 GetAbility=function()return ab end},modifier_enfos_vs_vengeance_aura_buff)
assert(buff:GetModifierBaseDamageOutgoing_Percentage()==15)
source.broken=true
assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0,'Source Break must suppress already attached/lingering buff')
source.broken=false;recipient.broken=true
assert(buff:GetModifierBaseDamageOutgoing_Percentage()==15,'External aura is not recipient-owned passive')
recipient.broken=false;recipient.illusion=true
assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0,'Preserve current illusion-recipient exclusion')
recipient.illusion=false;ab.rank=10
assert(buff:GetModifierBaseDamageOutgoing_Percentage()==33,'Rank changes must update live aura value')
ab.rank=0;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0,'Unlearned ability cannot grant lingering bonus')
ab.rank=1;ab.removed=true;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0)
ab.removed=false;source.removed=true;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0)
source.removed=false;recipient.removed=true;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0)
recipient.removed=false;source=nil;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0)
print('Vengeance Aura source ownership PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Vengeance Aura source ownership PASS/,r.stderr);
});

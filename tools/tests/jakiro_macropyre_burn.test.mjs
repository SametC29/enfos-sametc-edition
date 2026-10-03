import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Macropyre recipient burn lingers without refresh bursts or tick starvation',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
DAMAGE_TYPE_MAGICAL=2;MODIFIER_PROPERTY_TOOLTIP=1;PATTACH_ABSORIGIN_FOLLOW=0;Convars={GetBool=function()return false end}
require('abilities/heroes/jakiro/r')
local now=0;local c={removed=false,alive=true,IsNull=function(self)return self.removed end,GetTeamNumber=function()return 2 end};local a={removed=false,IsNull=function(self)return self.removed end,GetCaster=function()return c end}
local function victim()return {removed=false,alive=true,immune=false,total=0,IsNull=function(self)return self.removed end,IsAlive=function(self)return self.alive end,IsMagicImmune=function(self)return self.immune end,GetTeamNumber=function()return 3 end}end
function ApplyDamage(info)assert(info.damage_type==DAMAGE_TYPE_MAGICAL);info.victim.total=info.victim.total+info.damage;return info.damage end
local function modifier(p,duration,dps)
 local m=setmetatable({created=now,expiry=now+duration},modifier_enfos_jakiro_macropyre_burn)
 function m:GetParent()return p end;function m:GetCaster()return c end;function m:GetAbility()return a end;function m:GetElapsedTime()return now-self.created end;function m:GetRemainingTime()return self.expiry-now end
 function m:StartIntervalThink(t)self.interval=t;self.starts=(self.starts or 0)+1 end;function m:SetHasCustomTransmitterData()end;function m:SendBuffRefreshToClients()end;function m:Destroy()self:OnDestroy()end
 m:OnCreated({duration=duration,dps=dps,interval=0.5});return m
end
local p=victim();local m=modifier(p,1,100);assert(p.total==0 and m.interval==0.5 and not m:IsPurgable())
now=0.25;m.expiry=1.25;m:OnRefresh({duration=1,dps=100});assert(p.total==0 and m.starts==1,'Refresh cannot deal a burst or restart burn ticks')
now=0.5;m:OnIntervalThink();assert(p.total==50)
c.alive=false;now=1;m:OnIntervalThink();assert(p.total==100,'Exit burn survives ground removal and valid dead caster')
now=1.25;m:OnDestroy();m:OnDestroy();assert(p.total==125 and m.interval==-1,'Natural expiry final slice exactly once')
now=10;p=victim();m=modifier(p,1,100);now=10.75;m.expiry=11.75;m:OnRefresh({duration=1,dps=200});assert(p.total==75,'Changed DPS settles old elapsed contribution');now=11.25;m:OnIntervalThink();assert(p.total==175)
p.immune=true;now=11.5;m:OnIntervalThink();assert(p.total==175);p.immune=false;now=11.75;m:OnDestroy();assert(p.total==225,'Immune time is not paid later')
for _,mode in ipairs({'dead_target','removed_target','removed_caster','removed_ability','client','early_cancel'})do
 now=20;p=victim();m=modifier(p,1,100);now=20.5
 if mode=='dead_target' then p.alive=false elseif mode=='removed_target' then p.removed=true elseif mode=='removed_caster' then c.removed=true elseif mode=='removed_ability' then a.removed=true elseif mode=='client' then server=false else m:OnDestroy()end
 m:OnIntervalThink();assert(p.total==0);if mode~='client' then assert(m.closed and m.interval==-1)end
 c.removed=false;a.removed=false;server=true
end
now=30;p=victim();m=modifier(p,1,100);assert(m:AddCustomTransmitterData().dps==100 and m:OnTooltip()==100)
server=false;local client=setmetatable({},modifier_enfos_jakiro_macropyre_burn);client:HandleCustomTransmitterData({dps=123});assert(client:OnTooltip()==123);server=true
local apply=ApplyDamage;ApplyDamage=function(info)local actual=apply(info);m:OnDestroy();return actual end
now=30.5;m:OnIntervalThink();m:OnIntervalThink();assert(p.total==50 and m.closed,'Damage callback removal prevents duplicate or future payout');ApplyDamage=apply
assert(m:GetEffectName()=='particles/units/heroes/hero_jakiro/jakiro_macropyre_firehit.vpcf')
print('Jakiro R recipient linger PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro R recipient linger PASS/,r.stderr);
});

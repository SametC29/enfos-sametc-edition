package.path='game/scripts/vscripts/?.lua;'..package.path
local passed=0
local function test(name,fn) fn();passed=passed+1;print('PASS '..name) end
function class(t) return t end
local server=true
function IsServer() return server end
function LinkLuaModifier() end
require('heroes/modifier_hero_power')
local P=require('heroes/hero_power')
local B=require('waves/balance_config')
local C=require('heroes/power_config')
local roster=require('heroes/roster')
PlayerResource={heroes={},IsValidPlayerID=function(_,id) return id==0 or id==1 end,
    GetSelectedHeroEntity=function(self,id) return self.heroes[id] end}
local function hero(team,id)
    local h={health=500,mana=250,alive=true,added=0}
    function h:IsNull() return false end
    function h:IsRealHero() return true end
    function h:IsIllusion() return false end
    function h:IsClone() return false end
    function h:IsTempestDouble() return false end
    function h:IsAlive() return self.alive end
    function h:GetPlayerID() return id or 0 end
    function h:GetTeamNumber() return team or 2 end
    function h:GetHealth() return self.health end
    function h:GetMana() return self.mana end
    function h:GetMaxHealth() return 500+(self.modifier and self.modifier:GetModifierHealthBonus() or 0) end
    function h:GetMaxMana() return 250+(self.modifier and self.modifier:GetModifierManaBonus() or 0) end
    function h:SetHealth(v) self.health=v end
    function h:SetMana(v) self.mana=v end
    function h:CalculateStatBonus() end
    function h:FindModifierByName() return self.modifier end
    function h:AddNewModifier(_,_,name,values)
        assert(name=='modifier_enfos_hero_power');self.added=self.added+1
        self.modifier=setmetatable({GetParent=function() return h end,
            SetHasCustomTransmitterData=function() end,SendBuffRefreshToClients=function() end},
            {__index=modifier_enfos_hero_power})
        self.modifier:OnCreated(values);return self.modifier
    end
    return h
end
test('all 40 heroes receive baseline power without changing hero identity',function()
    P.snapshot=nil
    for _,entry in ipairs(roster) do
        local h=hero();h.name=entry.id;assert(P:Apply(h))
        assert(h.name==entry.id and h:GetMaxHealth()==750 and h:GetMaxMana()==325)
        assert(h.health==750 and h.mana==325 and h.modifier:GetModifierPreAttack_BonusDamage()==15)
    end
end)
test('solo snapshot upgrades an already spawned hero once and fills added capacity only',function()
    P.snapshot=nil;local h=hero();P:Apply(h);h.health=400;h.mana=100
    PlayerResource.heroes={[0]=h};P:SetSnapshot(B.Snapshot('normal',1,0))
    assert(h:GetMaxHealth()==1100 and h:GetMaxMana()==475)
    assert(h.health==750 and h.mana==250 and h.added==1)
    assert(h.modifier:GetModifierAttackSpeedBonus_Constant()==25)
    assert(h.modifier:GetModifierSpellAmplify_Percentage()==15)
    assert(h.modifier:GetModifierConstantHealthRegen()==8 and h.modifier:GetModifierConstantManaRegen()==4)
end)
test('reconnect and repeated spawn events cannot stack stats or heal damage',function()
    local h=PlayerResource.heroes[0];h.health=300;h.mana=40
    for i=1,10 do assert(not P:Apply(h)) end
    assert(h.health==300 and h.mana==40 and h.added==1 and h:GetMaxHealth()==1100)
    assert(not h.modifier:RemoveOnDeath() and not h.modifier:IsPurgable())
end)
test('heroes created after the match snapshot inherit the same solo strength',function()
    local h=hero(3);P:SetSnapshot(B.Snapshot('hard',0,1));assert(P:Apply(h))
    assert(h.modifier:GetModifierPreAttack_BonusDamage()==25 and h.health==1100)
end)
test('multiplayer teams get equal baseline power without solo bonus',function()
    local a,b=hero(2,0),hero(3,1);PlayerResource.heroes={[0]=a,[1]=b}
    P:SetSnapshot(B.Snapshot('normal',1,1))
    assert(a.health==750 and b.health==750)
    assert(a.modifier:GetModifierSpellAmplify_Percentage()==10 and b.modifier:GetModifierSpellAmplify_Percentage()==10)
end)
test('clones, illusions, spectators and ownerless units cannot gain empowerment',function()
    for _,method in ipairs({'IsIllusion','IsClone','IsTempestDouble'}) do
        local h=hero();h[method]=function() return true end;assert(not P:Apply(h) and h.added==0)
    end
    assert(not P:Apply(hero(1)));assert(not P:Apply(hero(2,-1)))
    assert(not modifier_enfos_hero_power:AllowIllusionDuplicate())
end)
test('cooldown benefit applies to hero skills but excludes items and external casters',function()
    P.snapshot=B.Snapshot('normal',1,0);local h=hero();P:Apply(h)
    local ability={IsItem=function() return false end,GetCaster=function() return h end}
    assert(h.modifier:GetModifierPercentageCooldown({ability=ability})==10)
    ability.IsItem=function() return true end
    assert(h.modifier:GetModifierPercentageCooldown({ability=ability})==0)
    ability.IsItem=function() return false end;ability.GetCaster=function() return {} end
    assert(h.modifier:GetModifierPercentageCooldown({ability=ability})==0)
    assert(h.modifier:GetModifierPercentageCooldown({})==0)
end)
test('client display receives the authoritative stat values',function()
    local h=hero();P:Apply(h);local client=setmetatable({},{__index=modifier_enfos_hero_power})
    server=false;client:OnCreated({});assert(client:GetModifierHealthBonus()==0)
    client:HandleCustomTransmitterData(h.modifier:AddCustomTransmitterData())
    assert(client:GetModifierHealthBonus()==600 and client:GetModifierPreAttack_BonusDamage()==25)
    server=true
end)
test('match power is copied into snapshot and dead heroes cannot be revived by applying it',function()
    local snapshot=B.Snapshot('normal',1,0);local saved=C.SOLO.health
    C.SOLO.health=999;assert(snapshot.heroPower.health==600);C.SOLO.health=saved
    P.snapshot=snapshot;local h=hero();h.alive=false;h.health=0;h.mana=0
    P:Apply(h);assert(h.health==0 and h.mana==0)
end)
print(passed..' hero power tests passed (mock engine).')

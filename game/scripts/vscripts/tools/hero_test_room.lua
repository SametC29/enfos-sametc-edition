-- Explicit Tools-only match mode; uses existing progression/upgrade/Boss services.
local Room={enabled=false,rooms={},lastAction={}}
local Log=require('lib/log')
function Room:IsEnabled() return self.enabled and IsInToolsMode() and GetMapName()=='enfos_test' end
function Room:Publish()
    CustomNetTables:SetTableValue('game_setup','hero_test_room',{enabled=self:IsEnabled(),available=IsInToolsMode()})
end
function Room:Init()
    self.enabled=false;self.rooms={};self.lastAction={}
    CustomGameEventManager:RegisterListener('enfos_test_room_action',function(_,e)self:Action(e)end)
    self:Publish()
    if IsInToolsMode() and GetMapName()=='enfos_test' then self:Enable() end
end
function Room:Plan()
    local waves=require('waves/wave_definitions')
    local reward=waves:GetWave(5).boss_name
    return require('waves/native_roster').Get(1).unit,waves.BOSS_HEROES[reward],reward
end
function Room:Enable()
    if not IsInToolsMode() or GetMapName()~='enfos_test' then return false end
    local creep,boss=self:Plan()
    self.plan={{unit_name=creep},{unit_name=boss}}
    self.resources=require('bosses/resource_gate').New()
    self.resources:RequestPlan(self.plan)
    self.enabled=true;self:Publish();return true
end
function Room:Hero(id)
    if type(id)~='number' or id~=math.floor(id) or not PlayerResource:IsValidPlayerID(id) then return end
    local h=PlayerResource:GetSelectedHeroEntity(id)
    if h and not h:IsNull() and h:IsRealHero() and not h:IsIllusion() and h:GetPlayerID()==id
        and (h:GetTeamNumber()==2 or h:GetTeamNumber()==3) then return h end
end
function Room:Clear(state)
    for _,u in ipairs(state.units or {}) do
        if u and not u:IsNull() then
            if u.isBoss then require('bosses/boss_framework'):OnBossKilled(u) end
            UTIL_Remove(u)
        end
    end
    state.units={}
end
function Room:Position(hero,index)
    local origin=hero:GetAbsOrigin()
    for _,radius in ipairs({420,560,700}) do
        local angle=(index-1)*math.pi*2/11
        local p=GetGroundPosition(origin+Vector(math.cos(angle)*radius,math.sin(angle)*radius,0),hero)
        if GridNav:IsTraversable(p) and not GridNav:IsBlocked(p) and GridNav:CanFindPath(origin,p) then return p end
    end
end
function Room:Spawn(hero,state)
    self:Clear(state)
    local creepName,bossName,rewardName=self:Plan()
    for index=1,11 do
        local p=self:Position(hero,index)
        if not p then self:Clear(state);Log:Warn('hero_test','spawn_failed reason=navigation index=%d',index);return false end
        local boss=index==11
        local u=CreateUnitByName(boss and bossName or creepName,p,true,nil,nil,DOTA_TEAM_NEUTRALS)
        if not u or u:IsNull() then self:Clear(state);Log:Warn('hero_test','spawn_failed reason=unit index=%d',index);return false end
        state.units[#state.units+1]=u
        u.enfosNoReward=true;u.enfosTestTarget=true;u.isBoss=boss
        if boss then
            u.bossRewardName=rewardName
            u:SetRespawnsDisabled(true)
            local framework=require('bosses/boss_framework')
            if not framework:PrepareBoss(u,bossName,5,hero:GetTeamNumber())
                or not framework:RegisterBoss(u,bossName,5,1,hero:GetTeamNumber()) then
                self:Clear(state);Log:Warn('hero_test','spawn_failed reason=boss_setup');return false
            end
        end
        u:SetDeathXP(0);u:SetMinimumGoldBounty(0);u:SetMaximumGoldBounty(0)
        u:SetIdleAcquire(true);u:SetAcquisitionRange(650)
    end
    Log:Info('hero_test','targets_ready player=%d creeps=10 boss=%s',hero:GetPlayerID(),bossName)
    return true
end
function Room:Refresh(hero)
    if not hero:IsAlive() then hero:RespawnHero(false,false) end
    hero:SetHealth(hero:GetMaxHealth());hero:SetMana(hero:GetMaxMana())
    for index=0,31 do local a=hero:GetAbilityByIndex(index);if a and not a:IsNull() then a:EndCooldown() end end
    for index=0,8 do local a=hero:GetItemInSlot(index);if a and not a:IsNull() then a:EndCooldown() end end
end
function Room:Prepare(hero,state)
    -- Level-up normally. Never SetLevel/UpgradeAbility/SetAbilityPoints here.
    local levels=require('heroes/match_levels')
    local xp=levels:BuildXPThresholds()[10]
    if hero:GetLevel()<10 then hero:AddExperience(math.max(0,xp-hero:GetCurrentXP()),DOTA_ModifyXP_Unspecified,false,true) end
    if hero:GetLevel()~=10 then Log:Warn('hero_test','prepare_failed reason=level actual=%d',hero:GetLevel());return false end
    if not state.center then
        local anchor=Vector(0,0,128)
        local p=GetGroundPosition(anchor,hero)
        if not GridNav:IsTraversable(p) or GridNav:IsBlocked(p) then
            Log:Warn('hero_test','prepare_failed reason=arena_navigation');return false
        end
        state.center=p
    end
    FindClearSpaceForUnit(hero,state.center,true);hero:SetRespawnPosition(state.center)
    local upgrades=require('heroes/aghanim_manager')
    if not upgrades:HasScepter(hero) then
        local item=hero:AddItemByName('item_ultimate_scepter')
        if not item or item:IsNull() then return false end
    end
    if not upgrades:HasShard(hero) then
        local item=hero:AddItemByName('item_aghanims_shard')
        if not item or item:IsNull() then return false end
        -- Native item owns the permanent upgrade and item consumption.
        item:OnSpellStart()
    end
    upgrades:UpdateHeroAghanimState(hero)
    if not upgrades:HasScepter(hero) or not upgrades:HasShard(hero) then
        Log:Warn('hero_test','prepare_failed reason=native_upgrade');return false
    end
    self:Refresh(hero)
    if not self:Spawn(hero,state) then return false end
    state.ready=true
    Log:Info('hero_test','hero_ready player=%d hero=%s level=%d points=%d scepter=%s shard=%s',
        hero:GetPlayerID(),hero:GetUnitName(),hero:GetLevel(),hero:GetAbilityPoints(),tostring(upgrades:HasScepter(hero)),tostring(upgrades:HasShard(hero)))
    require('heroes/health').Report(hero,hero:GetPlayerID())
    return true
end
function Room:Tick()
    if not self:IsEnabled() or GameRules:State_Get()<DOTA_GAMERULES_STATE_PRE_GAME then return end
    if not self.resources or not self.resources:IsPlanReady(self.plan) then return end
    for id=0,(DOTA_MAX_TEAM_PLAYERS or 24)-1 do
        local h=self:Hero(id)
        if h and h:IsAlive() and h:GetLevel()>=6 then
            local state=self.rooms[id]
            if not state or state.hero~=h then
                if state then self:Clear(state) end
                state={hero=h,units={}};self.rooms[id]=state
            end
            if not state.attempted then state.attempted=true;self:Prepare(h,state) end
        end
    end
end
function Room:Action(event)
    if not self:IsEnabled() or not event then return false end
    local id=event.PlayerID;local hero=self:Hero(id);local state=self.rooms[id]
    if not hero or not state or state.hero~=hero then return false end
    local now=GameRules:GetGameTime()
    if now-(self.lastAction[id] or -10)<0.5 then return false end
    if event.action~='reset' and event.action~='refresh' and event.action~='health' then return false end
    self.lastAction[id]=now
    if not state.ready and event.action=='reset' then state.attempted=true;return self:Prepare(hero,state) end
    if event.action=='refresh' then self:Refresh(hero)
    elseif event.action=='health' then require('heroes/health').Report(hero,id)
    else self:Refresh(hero);FindClearSpaceForUnit(hero,state.center,true);self:Spawn(hero,state) end
    return true
end
function Room:OnSpawn(hero)
    if not self:IsEnabled() then return end
    local state=self.rooms[hero:GetPlayerID()]
    if state and state.hero==hero and state.ready and state.center then
        hero:SetRespawnPosition(state.center);FindClearSpaceForUnit(hero,state.center,true)
    end
end
return Room

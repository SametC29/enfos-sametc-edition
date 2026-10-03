-- Authored Shard selection: nearest two at cast, no mid-channel replacements.
-- Existing channel owns all resources and supplies its primary target predicate.
local H = require('abilities/shared/pve_helpers')
local Upgrades = require('abilities/heroes/lion/upgrades')
local Trace = require('lib/hero_trace')
local Economy = require('abilities/heroes/lion/drain_economy')
local Extras = {}
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function current(m,revision)
    if m.closed or m.revision~=revision then return false end
    local c,a=m:GetParent(),m:GetAbility()
    return valid(c) and c:IsAlive() and valid(a) and a:GetLevel()>0 and a:GetCaster()==c and a:IsChanneling()
end
local function within(c,t,r)
    local p,q=c:GetAbsOrigin(),t:GetAbsOrigin()
    local x,y=p.x-q.x,p.y-q.y
    return r>0 and x*x+y*y<=r*r
end
local function retained(m,slow,old)
    if slow.enfosLionExtraDrainEntry and slow.enfosLionExtraDrainEntry~=old then return true end
    for _,entry in ipairs(m.extra_drains or {}) do
        if entry~=old and not entry.closed and entry.slow==slow then return true end
    end
    return false
end
local function close(m,entry,deferred)
    if entry.closed then return end
    entry.closed=true
    local slow,fx=entry.slow,entry.fx
    entry.slow,entry.fx=nil,nil
    if valid(slow) and not retained(m,slow,entry) then
        slow.enfosLionExtraDrainEntry=nil
        slow:Destroy()
    end
    if fx~=nil and deferred then deferred[#deferred+1]=fx
    elseif fx~=nil then
        ParticleManager:DestroyParticle(fx,true)
        ParticleManager:ReleaseParticleIndex(fx)
    end
end
function Extras.Clear(m)
    local entries=m.extra_drains or {}
    m.extra_drains={} -- Disown before engine callbacks can refresh the channel.
    local particles={}
    -- Remove all old slows before a particle callback can start a fresh channel.
    for _,entry in ipairs(entries) do close(m,entry,particles) end
    for _,fx in ipairs(particles) do
        ParticleManager:DestroyParticle(fx,true)
        ParticleManager:ReleaseParticleIndex(fx)
    end
end
function Extras.Start(m,eligible,requested_count)
    if not IsServer() then return end
    local revision=m.revision
    Extras.Clear(m)
    if not current(m,revision) then return end
    local c,a=m:GetParent(),m:GetAbility()
    if not eligible(c,m.drain_target) or not Upgrades.HasShard(c) then return end
    local count=math.min(2,math.max(0,math.floor(requested_count or 0)))
    if count==0 then return end
    local radius=a:GetDrainBreakDistance()
    if radius<=0 then return end
    local entries=m.extra_drains
    local candidates=FindUnitsInRadius(c:GetTeamNumber(),c:GetAbsOrigin(),nil,radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS,FIND_CLOSEST,false) or {}
    local seen={[m.drain_target]=true}
    for _,t in ipairs(candidates) do
        if not current(m,revision) or m.extra_drains~=entries then return end
        if #entries>=count then break end
        if not seen[t] and eligible(c,t) and within(c,t,radius) then
            seen[t]=true
            local entry={target=t}
            entries[#entries+1]=entry -- Own before AddNewModifier can reenter.
            local slow=t:AddNewModifier(c,a,'modifier_enfos_lion_mana_drain_debuff',{duration=H.value(a,'channel_duration')})
            if not current(m,revision) or entry.closed or m.extra_drains~=entries then
                if valid(slow) and not retained(m,slow,entry) then slow:Destroy() end
                return
            end
            entry.slow=slow
            if valid(slow) then slow.enfosLionExtraDrainEntry=entry end
            if not eligible(c,t) then close(m,entry) else
                local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf',PATTACH_ABSORIGIN_FOLLOW,c)
                local function active() return current(m,revision) and not entry.closed and m.extra_drains==entries and eligible(c,t) end
                if active() then ParticleManager:SetParticleControlEnt(fx,0,c,PATTACH_ABSORIGIN_FOLLOW,'',c:GetAbsOrigin(),false) end
                if active() then ParticleManager:SetParticleControlEnt(fx,1,t,PATTACH_ABSORIGIN_FOLLOW,'',t:GetAbsOrigin(),false) end
                if not active() then
                    ParticleManager:DestroyParticle(fx,true)
                    ParticleManager:ReleaseParticleIndex(fx)
                    close(m,entry)
                    if not current(m,revision) then return end
                else entry.fx=fx end
            end
        end
    end
    Trace:Log('LION','E','Shard additional recipients selected=%d',#entries)
end
function Extras.Tick(m,revision,amount,eligible)
    if not IsServer() or not current(m,revision) then return end
    local c,a=m:GetParent(),m:GetAbility()
    if not Upgrades.HasShard(c) then Extras.Clear(m);return end
    local entries=m.extra_drains or {}
    local radius=a:GetDrainBreakDistance()
    for _,entry in ipairs(entries) do
        if not current(m,revision) or m.extra_drains~=entries then return end
        local t=entry.target
        if not entry.closed then
            if not eligible(c,t) or not within(c,t,radius) then close(m,entry) else
                local gained,mode=Economy.Take(a,t,amount)
                if not current(m,revision) or m.extra_drains~=entries then return end
                if not valid(t) or (t:IsAlive() and not eligible(c,t)) then close(m,entry) else
                    if gained>0 then c:GiveMana(gained) end
                    if not current(m,revision) or m.extra_drains~=entries then return end
                    if not eligible(c,t) then close(m,entry) end
                    Trace:Log('LION','E','Shard recipient tick mode=%s requested=%.2f mana=%.2f',mode,amount,gained)
                end
            end
        end
    end
end
return Extras

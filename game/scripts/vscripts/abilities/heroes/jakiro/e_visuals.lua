-- Local ready-mouth and projectile queries. Never changes attack funding or resources.
local Visuals = {}
local Trace = require('lib/hero_trace')
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
function Visuals.ProjectileTarget(m)
    if not IsServer() or m.closed then return end
    local c,a=m:GetParent(),m:GetAbility()
    if not valid(c) or not valid(a) or not c:IsAlive() or c:IsIllusion() or a:GetLevel()<1 then return end
    if (c.IsSilenced and c:IsSilenced()) or (c.IsDisarmed and c:IsDisarmed()) then return end
    local t=a.manual_target or (c.GetAggroTarget and c:GetAggroTarget())
    if not valid(t) or not t:IsAlive() or t:GetTeamNumber()==c:GetTeamNumber() then return end
    if a.manual_target==t or (a:GetAutoCastState() and a.IsFullyCastable and a:IsFullyCastable()) then return t end
end
function Visuals.Clear(m)
    if not IsServer() then return end
    local p=m.ready_particle
    m.ready_particle=nil -- Detach before particle callbacks; teardown is idempotent.
    if p~=nil then
        ParticleManager:DestroyParticle(p,false)
        ParticleManager:ReleaseParticleIndex(p)
        Trace:Log('JAKIRO','E','ready_effect_removed')
    end
end
function Visuals.Update(m)
    if not IsServer() then return end
    local c,a=m:GetParent(),m:GetAbility()
    local ready=not m.closed and valid(c) and valid(a) and c:IsAlive() and not c:IsIllusion()
        and a:GetLevel()>0 and a.IsFullyCastable and a:IsFullyCastable()
        and not (c.IsSilenced and c:IsSilenced()) and not (c.IsDisarmed and c:IsDisarmed())
    local path,attachment=m:GetReadyEffect()
    if not ready or not c.ScriptLookupAttachment or c:ScriptLookupAttachment(attachment)<=0 then
        Visuals.Clear(m);return
    end
    if m.ready_particle~=nil then return end
    local origin=c:GetAbsOrigin()
    local p=ParticleManager:CreateParticle(path,PATTACH_POINT_FOLLOW,c)
    m.ready_particle=p
    if m.closed or not valid(c) or not valid(a) then Visuals.Clear(m);return end
    ParticleManager:SetParticleControlEnt(p,0,c,PATTACH_POINT_FOLLOW,attachment,origin,true)
    if m.closed or not valid(c) or not valid(a) then Visuals.Clear(m) end
    if m.ready_particle~=nil then Trace:Log('JAKIRO','E','ready_effect_created mouth=%s effect=%s',attachment,path) end
end
function Visuals.Start(m)
    if not IsServer() then return end
    local c=m:GetParent()
    if not valid(c) or not c.ScriptLookupAttachment then return end
    m.visual_polling=true
    m:StartIntervalThink(0.1)
    Visuals.Update(m)
end
function Visuals.Stop(m)
    if not IsServer() then return end
    if m.visual_polling then m.visual_polling=nil;m:StartIntervalThink(-1) end
    Visuals.Clear(m)
end
return Visuals

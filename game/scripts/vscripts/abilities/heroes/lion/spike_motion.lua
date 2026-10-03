-- One finite flight per owned stun; exact native C++ height/time are not exposed.
local H=require('abilities/shared/pve_helpers')
local Trace=require('lib/hero_trace')
local Motion={}
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function eligible(e)
    local a,c,t=e.ability,e.caster,e.target
    return valid(a) and valid(c) and a:GetCaster()==c and valid(t) and t:IsAlive()
        and t:GetTeamNumber()~=c:GetTeamNumber() and not t:IsBuilding()
        and not t:IsMagicImmune() and not t:IsDebuffImmune()
end
function Motion.Finish(m,e,expectedRevision)
    if not e or e.closed or not IsServer() then return end
    e.closed=true -- Claim settlement before engine/audio/damage callbacks can reenter.
    if m.flight==e then m.flight=nil end
    local t=e.target
    if e.controller then
        e.controller=false
        if valid(t) then
            t:RemoveVerticalMotionController(m)
        end
    end
    if e.wasController and valid(t) and m.revision==(expectedRevision or e.revision) and not t:IsCurrentlyVerticalMotionControlled() then
        local p=t:GetAbsOrigin();t:SetAbsOrigin(Vector(p.x,p.y,GetGroundHeight(p,t)))
    end
    if not eligible(e) then return end
    t:EmitSound('Hero_Lion.ImpaleTargetLand')
    if not eligible(e) then return end
    local dealt=H.damage(e.ability,t,e.damage,DAMAGE_TYPE_MAGICAL) or 0
    Trace:Log('LION','Q','landing requested=%.1f actual=%.1f',e.damage,dealt)
end
function Motion.Start(m,kv)
    if not IsServer() or m.closed then return end
    m.revision=(m.revision or 0)+1
    local revision=m.revision
    Motion.Finish(m,m.flight,revision)
    if m.closed or m.revision~=revision then return end
    local amount=tonumber(kv and kv.damage)
    if not amount then return end -- Standalone/control-only modifier has no damage receipt.
    local e={ability=m:GetAbility(),caster=m:GetCaster(),target=m:GetParent(),damage=math.max(0,amount),
        height=math.max(0,tonumber(kv.launch_height) or 0),elapsed=0,revision=revision}
    m.flight=e
    if not eligible(e) then m:Destroy();return end
    e.duration=math.min(math.max(0,tonumber(kv.launch_duration) or 0),math.max(0,m:GetDuration()))
    if e.height<=0 or e.duration<=0 then Motion.Finish(m,e);return end
    -- Acquisition failure leaves the other controller and ordinary stun intact.
    local acquired=m:ApplyVerticalMotionController()
    if m.closed or m.revision~=revision or m.flight~=e then
        if acquired and valid(e.target) and not m.flight then e.target:RemoveVerticalMotionController(m) end
        return
    end
    e.controller=acquired
    e.wasController=acquired
    if not acquired then Motion.Finish(m,e);return end
    Trace:Log('LION','Q','launched height=%.1f duration=%.2f',e.height,e.duration)
end
function Motion.Update(m,me,dt)
    if not IsServer() or m.closed then return end
    local e=m.flight
    if not e or e.closed or not e.controller or me~=e.target then return end
    if not eligible(e) then m:Destroy();return end
    e.elapsed=math.min(e.duration,e.elapsed+math.max(0,dt or 0))
    local progress=e.elapsed/e.duration
    local p=me:GetAbsOrigin()
    me:SetAbsOrigin(Vector(p.x,p.y,GetGroundHeight(p,me)+4*e.height*progress*(1-progress)))
    if m.closed or m.flight~=e or e.closed then return end
    if progress>=1 then Motion.Finish(m,e) end
end
function Motion.Interrupt(m)
    if not IsServer() then return end
    local e=m.flight
    -- Engine has revoked our motion ownership; never remove a replacement controller.
    if e then e.controller=false end
    Motion.Finish(m,e)
end
return Motion

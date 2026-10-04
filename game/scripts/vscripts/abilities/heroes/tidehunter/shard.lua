-- Bounded reactive Enfos utility only; manual Anchor attacks remain native.
local Shard={}
local function live(c,e)
    return c and not c:IsNull() and c:IsAlive() and e and not e:IsNull() and e:GetLevel()>0
end
function Shard.Smash(c,e,scale)
    if not IsServer() or not live(c,e) or not scale or scale<=0 then return end
    local radius=e:GetAOERadius()
    if radius<=0 then return end
    local bonus=e:GetSpecialValueFor('attack_damage')
    local duration=e:GetSpecialValueFor('reduction_duration')
    c:EmitSound('Hero_Tidehunter.AnchorSmash')
    if not live(c,e) then return end
    local fx=ParticleManager:CreateParticle('particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf',PATTACH_ABSORIGIN_FOLLOW,c)
    ParticleManager:SetParticleControl(fx,2,Vector(radius,0,0))
    ParticleManager:ReleaseParticleIndex(fx)
    if not live(c,e) then return end
    local targets=FindUnitsInRadius(c:GetTeamNumber(),c:GetAbsOrigin(),nil,radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false) or {}
    for _,u in ipairs(targets) do
        if not live(c,e) then return end
        if u and not u:IsNull() and u:IsAlive() and u:GetTeamNumber()~=c:GetTeamNumber() and not u:IsAttackImmune() then
            local amount=(c:GetAverageTrueAttackDamage(u)+bonus)*scale
            ApplyDamage({attacker=c,victim=u,ability=e,damage=amount,
                damage_type=DAMAGE_TYPE_PHYSICAL,damage_flags=DOTA_DAMAGE_FLAG_REFLECTION})
            if not live(c,e) then return end
            if not u:IsNull() and u:IsAlive() and u:GetTeamNumber()~=c:GetTeamNumber() then
                u:AddNewModifier(c,e,'modifier_tidehunter_anchor_smash',{duration=duration})
            end
        end
    end
end
return Shard

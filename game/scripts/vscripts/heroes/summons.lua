-- Per-ability caps also apply when cooldowns are refreshed. Summons never pay
-- wave rewards or count as scheduled hostile wave units.
local Summons={}
function Summons:Clear(ability)
    for _,unit in ipairs(ability.enfosSummons or {}) do
        if unit and not unit:IsNull() and unit:IsAlive() then unit:ForceKill(false) end
    end
    ability.enfosSummons={}
end
function Summons:Own(ability,unit)
    local hero=ability:GetCaster()
    unit:SetOwner(hero)
    unit:SetControllableByPlayer(hero:GetPlayerOwnerID(),true)
    unit.enfosNoReward=true
    unit.is_allied_reinforcement=true
    table.insert(ability.enfosSummons,unit)
end
function Summons:Units(ability,name,position,count,duration,damage,health)
    local hero=ability:GetCaster()
    if hero:IsIllusion() then return end
    self:Clear(ability)
    for i=1,math.min(8,math.max(0,count)) do
        local angle=i*2*math.pi/math.min(8,count)
        local pos=position+Vector(math.cos(angle)*140,math.sin(angle)*140,0)
        local unit=CreateUnitByName(name,pos,true,hero,hero,hero:GetTeamNumber())
        if unit then
            self:Own(ability,unit)
            unit:SetBaseDamageMin(damage);unit:SetBaseDamageMax(damage)
            unit:SetBaseMaxHealth(health);unit:SetMaxHealth(health);unit:SetHealth(health)
            unit:SetIdleAcquire(true);unit:SetAcquisitionRange(700)
            unit:AddNewModifier(hero,ability,"modifier_kill",{duration=duration})
        end
    end
end
function Summons:Illusions(ability,count,duration,outgoing)
    local hero=ability:GetCaster()
    if hero:IsIllusion() then return end
    self:Clear(ability)
    local copies=CreateIllusions(hero,hero,{duration=duration,outgoing_damage=outgoing-100,incoming_damage=200,
        bounty_base=0,bounty_growth=0},math.min(4,math.max(0,count)),80,false,true)
    for _,unit in ipairs(copies or {}) do self:Own(ability,unit) end
end
return Summons

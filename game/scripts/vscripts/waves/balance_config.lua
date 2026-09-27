-- Versioned onboarding seed; snapshot once before the first wave.
local Config = {VERSION="2026-09-27-solo-1"}
local DIFFICULTY = {
    casual={hp=0.75,damage=0.80}, normal={hp=1,damage=1},
    hard={hp=1.25,damage=1.10}, nightmare={hp=1.5,damage=1.20}, hell={hp=2,damage=1.35},
}
function Config.Snapshot(difficulty, radiant, dire)
    local d=DIFFICULTY[difficulty] or DIFFICULTY.normal
    return {version=Config.VERSION,difficulty=difficulty,hp=d.hp,damage=d.damage,
        solo=radiant+dire==1 and (radiant==1 or dire==1),
        soloHP=0.65,soloDamage=0.60,fullSupportThrough=10,fadeEnds=20,
        firstPreparation=45,soloPreparation=20,normalPreparation=15,soloBatchInterval=5}
end
function Config.Multipliers(snapshot,wave)
    local support=0
    if snapshot.solo then
        support=math.max(0,math.min(1,(snapshot.fadeEnds-wave)/(snapshot.fadeEnds-snapshot.fullSupportThrough)))
    end
    return snapshot.hp*(1-(1-snapshot.soloHP)*support),
        snapshot.damage*(1-(1-snapshot.soloDamage)*support)
end
function Config.Apply(unit,snapshot,wave)
    local hpMult,damageMult=Config.Multipliers(snapshot,wave)
    local hp=math.max(1,math.floor(unit:GetMaxHealth()*hpMult))
    unit:SetBaseMaxHealth(hp);unit:SetMaxHealth(hp);unit:SetHealth(hp)
    unit:SetBaseDamageMin(math.max(1,math.floor(unit:GetBaseDamageMin()*damageMult)))
    unit:SetBaseDamageMax(math.max(1,math.floor(unit:GetBaseDamageMax()*damageMult)))
end
return Config

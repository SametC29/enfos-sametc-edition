-- Versioned onboarding seed; snapshot once before the first wave.
local Power = require("heroes/power_config")
local Config = {VERSION="2026-09-28-uncapped-hostiles-1"}
local DIFFICULTY = {
    casual={hp=0.75,damage=0.80}, normal={hp=1,damage=1},
    hard={hp=1.25,damage=1.10}, nightmare={hp=1.5,damage=1.20}, hell={hp=2,damage=1.35},
}
function Config.Snapshot(difficulty, radiant, dire)
    local d=DIFFICULTY[difficulty] or DIFFICULTY.normal
    local solo=radiant+dire==1 and (radiant==1 or dire==1)
    return {version=Config.VERSION,difficulty=difficulty,hp=d.hp,damage=d.damage,
        solo=solo,heroPower=Power.Values(solo),heroPowerVersion=Power.VERSION,
        fullSupportThrough=10,boonEvery=10,hostileCapEnabled=false,heroEvolutionVersion="hero-evolution-1",
        soloPreparation=20,normalPreparation=15,soloBatchInterval=5}
end
function Config.Multipliers(snapshot,wave)
    -- Difficulty still affects enemies. Solo empowerment lives on the hero.
    return snapshot.hp,snapshot.damage
end
function Config.Apply(unit,snapshot,wave)
    local hpMult,damageMult=Config.Multipliers(snapshot,wave)
    local hp=math.max(1,math.floor(unit:GetMaxHealth()*hpMult))
    unit:SetBaseMaxHealth(hp);unit:SetMaxHealth(hp);unit:SetHealth(hp)
    unit:SetBaseDamageMin(math.max(1,math.floor(unit:GetBaseDamageMin()*damageMult)))
    unit:SetBaseDamageMax(math.max(1,math.floor(unit:GetBaseDamageMax()*damageMult)))
end
return Config

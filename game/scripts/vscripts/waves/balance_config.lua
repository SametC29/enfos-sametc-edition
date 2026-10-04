-- Versioned onboarding seed; snapshot once before the first wave.
local Power = require("heroes/power_config")
local Curve = require("waves/difficulty_curve")
local Config = {VERSION="2026-10-04-opening-balance-6"}
local DIFFICULTY = {
    casual={hp=0.75,damage=0.80}, normal={hp=1,damage=1},
    hard={hp=1.25,damage=1.10}, nightmare={hp=1.5,damage=1.20}, hell={hp=2,damage=1.35},
}
function Config.Snapshot(difficulty, radiant, dire)
    local d=DIFFICULTY[difficulty] or DIFFICULTY.normal
    local solo=radiant+dire==1 and (radiant==1 or dire==1)
    return {version=Config.VERSION,difficulty=difficulty,hp=d.hp,damage=d.damage,
        solo=solo,heroPower=Power.Values(solo),heroPowerVersion=Power.VERSION,
        regularHP=1.50,matchXPVersion=require("heroes/match_levels").VERSION,
        fullSupportThrough=10,boonEvery=5,hostileCapEnabled=false,heroEvolutionVersion="hero-evolution-1",
        soloPreparation=20,normalPreparation=15,soloBatchInterval=5,bossHP=1.20,bossDamage=1.15}
end
function Config.Multipliers(snapshot,wave)
    local hp,damage=1,1
    if snapshot.solo then hp,damage=Curve.Solo(wave) end
    return snapshot.hp*hp,snapshot.damage*damage
end
function Config.Apply(unit,snapshot,wave)
    local hpMult,damageMult=Config.Multipliers(snapshot,wave)
    if unit.isBoss then
        local bossHP,bossDamage=Curve.Boss(wave)
        -- Snapshot the boss-only pressure adjustment; older match snapshots
        -- retain their original tuning when these fields are absent.
        hpMult,damageMult=hpMult*bossHP*(snapshot.bossHP or 1),damageMult*bossDamage*(snapshot.bossDamage or 1)
    else
        hpMult=hpMult*(snapshot.regularHP or 1)
    end
    local hp=math.max(1,math.floor(unit:GetMaxHealth()*hpMult))
    unit:SetBaseMaxHealth(hp);unit:SetMaxHealth(hp);unit:SetHealth(hp)
    unit:SetBaseDamageMin(math.max(1,math.floor(unit:GetBaseDamageMin()*damageMult)))
    unit:SetBaseDamageMax(math.max(1,math.floor(unit:GetBaseDamageMax()*damageMult)))
end
return Config

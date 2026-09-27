-- Provisional Enfo power-fantasy seed. No automatic late-wave removal.
local Config={VERSION="2026-09-27-hero-power-1"}
Config.BASE={health=250,mana=75,damage=25,attackSpeed=25,spellAmp=20,
    healthRegen=4,manaRegen=2,cooldown=15}
Config.SOLO={health=350,mana=150,damage=20,attackSpeed=20,spellAmp=15,
    healthRegen=4,manaRegen=2,cooldown=10}
function Config.Values(solo)
    local values={}
    for key,value in pairs(Config.BASE) do values[key]=value+(solo and Config.SOLO[key] or 0) end
    return values
end
return Config

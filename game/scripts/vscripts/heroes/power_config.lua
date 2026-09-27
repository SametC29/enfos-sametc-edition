-- Provisional Enfo power-fantasy seed. No automatic late-wave removal.
local Config={VERSION="2026-09-27-hero-power-2"}
Config.BASE={health=250,mana=75,damage=15,attackSpeed=15,spellAmp=10,
    healthRegen=4,manaRegen=2,cooldown=5}
Config.SOLO={health=350,mana=150,damage=10,attackSpeed=10,spellAmp=5,
    healthRegen=4,manaRegen=2,cooldown=5}
function Config.Values(solo)
    local values={}
    for key,value in pairs(Config.BASE) do values[key]=value+(solo and Config.SOLO[key] or 0) end
    return values
end
return Config

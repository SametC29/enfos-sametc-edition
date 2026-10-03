-- Lion uses the existing authoritative acquisition logic, including consumed Shard.
local Upgrades={}
function Upgrades.HasShard(caster)
    return require('heroes/aghanim_manager'):HasShard(caster)
end
function Upgrades.HasScepter(caster)
    return require('heroes/aghanim_manager'):HasScepter(caster)
end
return Upgrades

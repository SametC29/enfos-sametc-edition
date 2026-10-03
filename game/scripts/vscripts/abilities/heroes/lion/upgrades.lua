-- Lion uses the existing authoritative acquisition logic, including consumed Shard.
local Upgrades={}
function Upgrades.HasShard(caster)
    return require('heroes/aghanim_manager'):HasShard(caster)
end
return Upgrades

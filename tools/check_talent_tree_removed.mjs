import fs from 'node:fs';
import {parseKV} from './lib/kv.mjs';
const heroes=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;
const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
for(const [id,h] of Object.entries(heroes)){
 for(let slot=10;slot<=17;slot++)if(h['Ability'+slot]!=='generic_hidden')throw Error(id+' Ability'+slot+' must remain disabled');
 if(h.Ability19!=='generic_hidden'||h.Ability25!=='generic_hidden')throw Error(id+' native attribute slots must remain disabled');
}
if(Object.keys(abilities).some(id=>id.startsWith('special_bonus_enfos_')))throw Error('Removed custom talent abilities remain in KV');
console.log('PASS talent tree disabled for '+Object.keys(heroes).length+' heroes');

import fs from 'node:fs';
import {parseKV} from './lib/kv.mjs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const server = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp';
const dota = 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta';
const { Vpk } = await import(pathToFileURL(path.join(server, 'dist/dota/vpk.js')));
const valve = await Vpk.open(path.join(dota, 'game/dota/pak01_dir.vpk'));

const units = parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt','utf8')).DOTAUnits;
const unitModels = Object.fromEntries(Object.entries(units).filter(([,u])=>u.Model).map(([id,u])=>[id,u.Model+'_c']));

let allOk = true;
for (const [k, v] of Object.entries(unitModels)) {
  const has = valve.entries.has(v);
  console.log(`${k.padEnd(24)}: ${has ? 'OK' : 'MISSING (' + v + ')'}`);
  if (!has) allOk = false;
}
if (!allOk) process.exit(1);
console.log('ALL MODELS VERIFIED IN VALVE PAK01 VPK!');

const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
let icons=0,resources=new Set();
for(const [id,a] of Object.entries(abilities)) if(a.AbilityTextureName){
  if(!valve.entries.has('panorama/images/spellicons/'+a.AbilityTextureName+'_png.vtex_c')) throw new Error(id+': missing icon '+a.AbilityTextureName);
  icons++;
}
function walk(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);}
for(const file of walk('game/scripts/vscripts')){
  for(const m of fs.readFileSync(file,'utf8').matchAll(/["']((?:particles|models|soundevents)\/[^"']+\.(?:vpcf|vmdl|vsndevts))["']/g)){
    if(!valve.entries.has(m[1]+'_c')&&!fs.existsSync('game/'+m[1]+'_c'))throw new Error(file+': missing resource '+m[1]);
    resources.add(m[1]);
  }
}
console.log(`${icons} ability icons and ${resources.size} literal runtime resource paths verified. Rendering is an engine acceptance check.`);

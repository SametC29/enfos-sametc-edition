// Inspect installed Valve recipes without replacing native items or purchasing anything.
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {parseKV} from './lib/kv.mjs';
const mcp=process.env.ENFOS_WORKSHOP_MCP||'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp';
const dota=process.env.ENFOS_DOTA_ROOT||'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta';
const {Vpk}=await import(pathToFileURL(mcp+'/dist/dota/vpk.js'));
const pak=await Vpk.open(dota+'/game/dota/pak01_dir.vpk');
const source=await pak.readText('scripts/npc/items.txt');
const items=parseKV(source).DOTAAbilities;
const custom=parseKV(fs.readFileSync('game/scripts/npc/npc_items_custom.txt','utf8')).DOTAItems;
const rows=Object.entries(items).filter(([,v])=>v.ItemResult&&v.ItemRequirements).map(([id,v])=>({
  recipe:id,result:v.ItemResult,cost:Number(v.ItemCost||0),
  requirements:v.ItemRequirements,
  locallyOverridden:!!custom[id]||!!custom[v.ItemResult],
  missingComponents:Object.values(v.ItemRequirements).flatMap(x=>x.split(';'))
    .map(x=>x.trim().replace(/\*\d*$/,'')).filter(x=>x&&!items[x]&&!custom[x]),
}));
const report={source:'Installed Valve scripts/npc/items.txt',
  sourceSHA256:createHash('sha256').update(source).digest('hex'),
  limitation:'Ingredient/override audit only; native shop interaction needs engine testing.',recipes:rows};
fs.writeFileSync('docs/audit/NATIVE_RECIPES.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({recipes:rows.length,paid:rows.filter(x=>x.cost>0).length,
  localOverrides:rows.filter(x=>x.locallyOverridden).length,
  unresolved:rows.filter(x=>x.missingComponents.length).map(x=>({id:x.recipe,missing:x.missingComponents})),
  examples:rows.filter(x=>['item_greater_crit','item_butterfly'].includes(x.result))}));

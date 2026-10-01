// Verify actual scheduled native Boss hero models, not old reward templates.
// Archive existence is FILE_VERIFIED; rendered models still require Dota.
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const {Vpk}=await import(pathToFileURL('C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/vpk.js'));
const vpk=await Vpk.open('C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta/game/dota/pak01_dir.vpk');
const waves=fs.readFileSync('game/scripts/vscripts/waves/wave_definitions.lua','utf8');
const mapping=waves.match(/WaveDefinitions\.BOSS_HEROES\s*=\s*\{([\s\S]*?)\}/)?.[1];
if(!mapping) throw Error('Missing authoritative Boss mapping');
const names=[...mapping.matchAll(/"(npc_dota_hero_[^"]+)"/g)].map(m=>m[1]);
if(names.length!==12 || new Set(names).size!==12) throw Error('Expected twelve distinct scheduled Boss heroes');
for(const name of names){
 const source='scripts/npc/heroes/'+name+'.txt';
 // Native Bot blocks repeat keys legally. Inspect only direct hero scalars,
 // as hero_reference_sources.mjs does; the custom-KV strict parser rejects them.
 const tokens=[...(await vpk.readText(source)).matchAll(/\/\/[^\r\n]*|"((?:\\.|[^"\\])*)"|([{}])/g)]
  .filter(m=>!m[0].startsWith('//')).map(m=>({value:m[1]??m[2],quoted:m[1]!==undefined}));
 if(tokens[0]?.value!=='DOTAHeroes' || tokens[2]?.value!==name) throw Error('Unexpected hero root: '+name);
 let depth=0,model;
 for(let i=0;i<tokens.length;i++){
  const token=tokens[i];
  if(!token.quoted){depth+=token.value==='{'?1:-1;continue;}
  if(depth===2 && tokens[i+1]?.quoted){
   const value=tokens[++i].value;
   if(token.value==='Model'){if(model)throw Error('Duplicate native Model: '+name);model=value;}
  }
 }
 if(!model || !vpk.entries.has(model+'_c')) throw Error(name+': native model missing from installed VPK');
 console.log('FILE_VERIFIED '+name+' -> '+model);
}
console.log('PASS 12 scheduled native Boss base models exist; unit precache callback and visual acceptance require Dota.');

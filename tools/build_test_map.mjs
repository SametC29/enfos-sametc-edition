// Offline authoring only: shrink Valve's installed addon template into a test arena.
// Never reads or writes the canonical Enfos playable map.
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
const root=process.cwd();
const dota=process.env.DOTA_TEST_ROOT || 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta';
const converter=path.join(dota,'game/bin/win64/dmxconvert.exe');
const template=path.join(dota,'content/dota_addons/addon_template/maps/template_map.vmap');
const output=path.join(root,'content/maps/enfos_test.vmap');
const scratch=path.join(root,'.codex-test-map-authoring.kv2');
function convert(args){const r=spawnSync(converter,args,{encoding:'utf8'});if(r.status!==0)throw Error(r.stderr||r.stdout);}
convert(['-i',template,'-o',scratch,'-oe','keyvalues2']);
let text=fs.readFileSync(scratch,'utf8');
const width=12;
text=text.replace(/("gridWidth" "int" ")64"/,'$1'+width+'"').replace(/("gridHeight" "int" ")64"/,'$1'+width+'"');
text=text.replace(/("CMapDotaTileGrid"[\s\S]*?"origin" "vector3" ")[^"]+"/,'$1-1536 -1536 128"');
const expected={cellConfiguration:12288,cellsTileSet:4096,cellsHidden:4096,cellsOrientation:4096,verticesHeight:4225,verticesWater:4225,edgesPath:8320};
text=text.replace(/"(cellConfiguration|cells\w+|vertices\w+|edgesPath|objectConfiguration|objects\w+)" "(int_array|bool_array)"\s*\[([\s\S]*?)\]/g,(block,key,type,body)=>{
 const old=[...body.matchAll(/"([^"]+)"/g)].map(m=>Number(m[1]));
 if(old.length!==(expected[key]??66049))throw Error('Unexpected template array '+key);
 const count=key==='cellConfiguration'?width*width*3:key.startsWith('cells')?width*width:key.startsWith('vertices')?(width+1)**2:key==='edgesPath'?2*width*(width+1):(width*4+1)**2;
 const values=Array.from({length:count},(_,i)=>key==='cellConfiguration'?old[i%3]:0);
 if(key==='verticesHeight')for(let y=0;y<=width;y++)for(let x=0;x<=width;x++)values[y*(width+1)+x]=(x===0||y===0||x===width||y===width)?2:0;
 // Four template-native trees away from the combat ring for tree-dependent skills.
 if(key==='objectsTreeType')for(const [x,y]of [[8,8],[40,8],[8,40],[40,40]])values[y*(width*4+1)+x]=1;
 return '"'+key+'" "'+type+'"\n[\n'+values.map(v=>'"'+v+'"').join(',\n')+'\n]';
});
fs.writeFileSync(scratch,text);fs.mkdirSync(path.dirname(output),{recursive:true});
convert(['-i',scratch,'-o',output,'-oe','binary']);
const installed=path.join(dota,'content/dota_addons/enfos_sametc/maps/enfos_test.vmap');
fs.copyFileSync(output,installed);fs.unlinkSync(scratch);
console.log('enfos_test: 12 × 12 tiles, 3072 × 3072 units; centered flat arena, perimeter cliffs, four native trees.');

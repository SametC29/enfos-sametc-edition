import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {parseKV} from './lib/kv.mjs';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
export async function loadRoster(){
 const heroes=parseKV(await fs.readFile(path.join(root,'game/scripts/npc/npc_heroes_custom.txt'),'utf8')).DOTAHeroes;
 return new Map(Object.entries(heroes).filter(([id,h])=>id.startsWith('npc_dota_hero_')&&h.Ability1)
  .map(([id,h])=>[id,Array.from({length:5},(_,i)=>h['Ability'+(i+1)])]));
}
export function validateSnapshot(form,roster){
 const allowed=new Set(['schema_version','hero','level','points','ranks']);
 for(const key of form.keys())if(!allowed.has(key)||form.getAll(key).length!==1)throw Error('Unexpected field');
 if(form.get('schema_version')!=='1'||!roster.has(form.get('hero')))throw Error('Unknown schema or hero');
 const integer=(value,min,max)=>{if(!/^\d+$/.test(value??''))throw Error('Invalid integer');const n=Number(value);if(n<min||n>max)throw Error('Out of range');return n;};
 const ranks=(form.get('ranks')??'').split(',');if(ranks.length!==5)throw Error('Five ranks required');
 return {schemaVersion:1,event:'hero_snapshot',hero:form.get('hero'),level:integer(form.get('level'),1,50),
  points:integer(form.get('points'),0,49),abilities:roster.get(form.get('hero')).map((id,i)=>({id,rank:integer(ranks[i],0,10)}))};
}
export function createCollector({roster,store}){
 return http.createServer(async(req,res)=>{
  const finish=(code)=>{res.writeHead(code,{'Content-Type':'text/plain'});res.end(code===202?'accepted':'rejected');};
  if(req.method!=='POST'||req.url!=='/v1/hero-snapshots')return finish(404);
  if(!req.headers['content-type']?.startsWith('application/x-www-form-urlencoded'))return finish(415);
  let bytes=0,chunks=[];
  try{
   for await(const chunk of req){bytes+=chunk.length;if(bytes>4096){finish(413);req.destroy();return;}chunks.push(chunk);}
   let event;try{event=validateSnapshot(new URLSearchParams(Buffer.concat(chunks).toString('utf8')),roster);}catch{return finish(400);}
   try{await store({...event,receivedAt:new Date().toISOString()});}catch{return finish(503);}
   finish(202);
  }catch{if(!res.headersSent)finish(400);}
 });
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
 const directory=path.resolve(root,process.argv[2]??'.runtime-collection');
 await fs.mkdir(directory,{recursive:true});
 const roster=await loadRoster();let writes=Promise.resolve();
 const server=createCollector({roster,store:event=>{
  const file=path.join(directory,event.receivedAt.slice(0,10)+'.jsonl');
  const next=writes.then(()=>fs.appendFile(file,JSON.stringify(event)+'\n'));
  writes=next.catch(()=>{});return next;
 }});
 server.requestTimeout=5000;server.headersTimeout=5000;server.maxConnections=16;
 server.listen(18765,'127.0.0.1',()=>console.log('Local collector: http://127.0.0.1:18765/v1/hero-snapshots'));
}

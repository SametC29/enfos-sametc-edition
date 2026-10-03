import fs from 'node:fs';
import crypto from 'node:crypto';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
export function analyzeHeroLog(text){
 const report={schemaVersion:1,sourceSha256:crypto.createHash('sha256').update(text).digest('hex'),
  engineAcceptance:'NOT_ESTABLISHED_BY_LOG',snapshots:[],runtimeErrors:[],invalidOrderCounts:{}};
 const errors=new Map();let current=null;
 for(const [index,line]of text.split(/\r?\n/).entries()){
  const error=line.match(/Script Runtime Error:\s*(.+)/);
  if(error){const message=error[1].replace(/C:\\Users\\[^\\]+/gi,'<user>').replace(/\[U:\d+:\d+\]/g,'<account>');
   const item=errors.get(message)??{message,count:0,firstLine:index+1};item.count++;errors.set(message,item);}
  const order=line.match(/invalid order \((\d+)\)/);if(order)report.invalidOrderCounts[order[1]]=(report.invalidOrderCounts[order[1]]??0)+1;
  const health=line.match(/\[(SF_HEALTH|HERO_HEALTH)\]\s*(.*)/);if(!health)continue;
  const value=health[2];
  const header=value.match(/^player=(\d+) (?:hero=(npc_dota_hero_\w+) )?level=(\d+) points=(\d+) alive=(true|false)/);
  if(header){current={playerSlot:Number(header[1]),hero:header[2]??'npc_dota_hero_nevermore',level:Number(header[3]),
   points:Number(header[4]),alive:header[5]==='true',line:index+1,abilities:[],modifiers:[],queries:{}};
   report.snapshots.push(current);continue;}
  if(!current)continue;
  const ability=value.match(/^ability=(\w+) rank=(\d+|missing)$/);
  if(ability)current.abilities.push({id:ability[1],rank:ability[2]==='missing'?null:Number(ability[2])});
  const modifier=value.match(/^modifier=(\w+) present=(true|false)(?: stacks=(\d+|missing))?$/);
  if(modifier)current.modifiers.push({id:modifier[1],present:modifier[2]==='true',stacks:modifier[3]&&modifier[3]!=='missing'?Number(modifier[3]):null});
  const query=value.match(/^native_raze_damage_query=([\d.]+)$/);
  if(query)current.queries.razeSpecial=Number(query[1]);
  const requiem=value.match(/^native_requiem_damage_query=([\d.]+) ability_damage_getter=([\d.]+)$/);
  if(requiem){current.queries.requiemSpecial=Number(requiem[1]);current.queries.requiemGetter=Number(requiem[2]);
   current.queries.requiemSurfacesDiffer=Number(requiem[1])!==Number(requiem[2]);}
 }
 report.runtimeErrors=[...errors.values()];
 return report;
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
 const input=process.argv[2],output=process.argv[3];
 if(!input)throw new Error('Usage: node tools/hero_runtime_log_report.mjs <log-path> [report-json-path]');
 const report=analyzeHeroLog(fs.readFileSync(input,'utf8')),json=JSON.stringify(report,null,2)+'\n';
 if(output)fs.writeFileSync(output,json);else process.stdout.write(json);
}

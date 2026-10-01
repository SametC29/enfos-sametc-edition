import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('all authored normal-creep KV stats and models match the shared curve and verified snapshot',()=>{
 const units=parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt','utf8')).DOTAUnits;
 const records=JSON.parse(fs.readFileSync('docs/audit/NATIVE_WAVE_ROSTER_2026-10-01.json','utf8')).records;
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',`package.path='game/scripts/vscripts/?.lua;'..package.path
 local C=require('waves/difficulty_curve')
 for w=1,60 do local s=C.Normal(w);print(table.concat({w,s.hp,s.damage,s.armor,s.speed,s.magicResistance},',')) end`],{encoding:'utf8'});
 assert.equal(result.status,0);assert.equal(result.stderr,'');
 const stats=new Map(result.stdout.trim().split(/\r?\n/).map(line=>{const [w,...values]=line.split(',').map(Number);return [w,values];}));
 assert.equal(stats.size,60);assert.equal(records.length,48);
 for(const record of records){
  const unit=units[record.unit];assert(unit,record.unit);
  assert.equal(unit.Model,record.model);
  const [hp,damage,armor,speed,resistance]=stats.get(record.wave);
  assert.equal(Number(unit.StatusHealth),hp);
  assert.equal(Number(unit.AttackDamageMin),damage);
  assert.equal(Number(unit.AttackDamageMax),Math.ceil(damage*1.1));
  assert.equal(Number(unit.ArmorPhysical),armor);
  assert.equal(Number(unit.MovementSpeed),speed);
  assert.equal(Number(unit.MagicalResistance),resistance);
 }
});
test('wave names and summoner tooltip exist in all four languages and generated resource mirrors',()=>{
 for(const lang of ['english','turkish','russian','schinese']){
  const data=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8'));
  const mirrors=['content/panorama/localization','game/panorama/localization','game/resource'].map(dir=>parseKV(fs.readFileSync(`${dir}/addon_${lang}.txt`,'utf8').replace(/^\uFEFF/,'')).lang.Tokens);
  for(let w=1;w<=60;w++) if(w%5){
   const key=`enfos_wave_${String(w).padStart(2,'0')}`;
   assert(data.Tokens[key]);for(const mirror of mirrors)assert.equal(mirror[key],data.Tokens[key]);
  }
  for(const prefix of ['DOTA_Tooltip_','DOTA_Tooltip_Ability_','DOTA_Tooltip_ability_']){
   const key=prefix+'enfos_wave_raise_Description';assert(data.Tokens[key]);
   for(const mirror of mirrors)assert.equal(mirror[key],data.Tokens[key]);
  }
 }
});

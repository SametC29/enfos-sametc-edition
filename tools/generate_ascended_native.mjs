// Builds only custom Ascended derivatives. Never overrides normal Dota items.
// Re-run after Dota patches and review native ABI/special-value changes.
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
import {parseKV} from './lib/kv.mjs';
const server=process.env.ENFOS_WORKSHOP_MCP || 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp';
const dota=process.env.ENFOS_DOTA_ROOT || 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta';
const {Vpk}=await import(pathToFileURL(server+'/dist/dota/vpk.js'));
const pak=await Vpk.open(dota+'/game/dota/pak01_dir.vpk');
const native=parseKV(await pak.readText('scripts/npc/items.txt')).DOTAAbilities;
const itemPath='game/scripts/npc/npc_items_custom.txt';
const custom=parseKV(fs.readFileSync(itemPath,'utf8')).DOTAItems;
const shopPath='game/scripts/vscripts/economy/ascended_shop.lua';
let shop=fs.readFileSync(shopPath,'utf8');
const entries=[...shop.matchAll(/id = "(item_ascended_[^"]+)", baseItem = "([^"]+)"/g)].map(m=>({id:m[1],base:m[2]})).filter(x=>!x.id.endsWith('aghanims_blessing'));
if(entries.length!==30) throw new Error('Expected exactly 30 Ascended derivatives');
const boosted=/^(bonus_(damage|armor|health|mana|strength|agility|intellect|all_stats|attack_speed|health_regen|mana_regen)|health_regen|mana_regen)$/;
const audit=[];
for(const {id,base} of entries){
  if(!native[base]) throw new Error('Native base unavailable: '+base);
  const item=structuredClone(native[base]);
  item.BaseClass=base; item.ItemPurchasable='0'; item.AbilityTextureName=base;
  // The native implementation provides active, passive, sounds and particles.
  // Retain its shared cooldown, targeting, charges and non-stacking rules.
  for(const k of ['ID','ItemRequirements','ItemResult','ItemStockMax','ItemStockTime','ItemInitialStock','ItemStockInitial','ItemDeclarations']) delete item[k];
  const changes={};
  for(const [key,value] of Object.entries(item.AbilityValues || {})){
    if(!boosted.test(key) || typeof value!=='string' || !/^\d+(\.\d+)?$/.test(value) || Number(value)<=0) continue;
    item.AbilityValues[key]=String(Math.round(Number(value)*1.2*100)/100);
    changes[key]={base:Number(value),ascended:Number(item.AbilityValues[key])};
  }
  if(Object.keys(changes).length===0) throw new Error('No upgrade stats for '+id);
  custom[id]=item;
  audit.push({id,base,nativeCost:Number(item.ItemCost),changes});
  const re=new RegExp('(id = "'+id+'"[^\\n]*?gold = )\\d+');
  shop=shop.replace(re,'$1'+item.ItemCost);
}
function writeKV(obj,depth=0){const indent='\t'.repeat(depth);return Object.entries(obj).map(([key,value])=>typeof value==='object'?`${indent}"${key}"\n${indent}{\n${writeKV(value,depth+1)}${indent}}\n`:`${indent}"${key}" "${String(value).replaceAll('"','\\"')}"\n`).join('');}
fs.writeFileSync(itemPath,'// Generated Ascended derivatives: tools/generate_ascended_native.mjs. Normal Dota items are untouched.\n'+writeKV({DOTAItems:custom}));
fs.writeFileSync(shopPath,shop);
fs.mkdirSync('docs/audit',{recursive:true});
fs.writeFileSync('docs/audit/ASCENDED_NATIVE_SNAPSHOT.json',JSON.stringify({schema:1,source:'Installed Valve scripts/npc/items.txt',items:audit},null,2)+'\n');
const suffixes={turkish:'Ascended: temel eşyanın düz özellik bonusları %20 güçlendirilmiştir. Aktif yetenek, hedefleme ve ortak bekleme süresi temel eşyanın kurallarını kullanır.',english:'Ascended: flat attribute bonuses are increased by 20%. Active effects, targeting and shared cooldowns follow the base item.',russian:'Ascended: постоянные бонусы характеристик увеличены на 20%. Активные эффекты, цели и общая перезарядка соответствуют базовому предмету.',schinese:'升阶：固定属性加成提高20%。主动效果、目标规则和共享冷却沿用基础物品。'};
for(const lang of Object.keys(suffixes)){
  const source=await pak.readText(`resource/localization/abilities_${lang}.txt`);
  const nativeTokens={};
  for(const m of source.matchAll(/"([^"\r\n]+)"\s*"((?:\\.|[^"\\])*)"/g)) nativeTokens[m[1]]=m[2].replaceAll('\\"','"');
  const file=`localization/${lang}.json`,data=JSON.parse(fs.readFileSync(file,'utf8'));
  for(const {id,base} of entries){
    const prefix=`DOTA_Tooltip_Ability_${base}`,out=`DOTA_Tooltip_Ability_${id}`;
    for(const [key,value] of Object.entries(nativeTokens)) if(key.toLowerCase().startsWith(prefix.toLowerCase()+'_')) data.Tokens[out+key.slice(prefix.length)]=value;
    const name=Object.entries(nativeTokens).find(([k])=>k.toLowerCase()===prefix.toLowerCase())?.[1];
    if(!name) throw new Error('Missing Valve name '+lang+'/'+base);
    data.Tokens[out]='★ '+name;
    const desc=Object.entries(nativeTokens).find(([k])=>k.toLowerCase()===(prefix+'_Description').toLowerCase())?.[1] || name;
    data.Tokens[out+'_Description']=desc+'<br><br>'+suffixes[lang];
    data.Tokens[out+'_SummaryDescription']=data.Tokens[out+'_Description'];
    delete data.Tokens[out+'_DesignDescription'];
    delete data.Tokens[out.replace('_Ability_','_ability_')+'_DesignDescription'];
    const record=audit.find(x=>x.id===id);
    data.Tokens['enfos_ascended_card_'+id]=Object.entries(record.changes).map(([key,v])=>
      (data.Tokens['enfos_stat_'+key.replace(/^bonus_/,'')] || key)+': '+v.base+' → '+v.ascended).join(' · ');
  }
  data.Tokens.enfos_ascended_card_item_ascended_aghanims_blessing=data.Tokens.DOTA_Tooltip_Ability_item_ascended_aghanims_blessing_Description;
  fs.writeFileSync(file,JSON.stringify(data,null,2)+'\n');
}
console.log('30 native Ascended derivatives and four localized starred catalogs generated. Engine acceptance is separate.');

// Describe implemented passive properties, not unimplemented design promises.
import fs from 'node:fs';
import { parseKV } from './lib/kv.mjs';
const items = parseKV(fs.readFileSync('game/scripts/npc/npc_items_custom.txt','utf8')).DOTAItems;
const properties = {
  PHYSICAL_ARMOR_BONUS:'armor', PREATTACK_BONUS_DAMAGE:'damage', HEALTH_BONUS:'health', MANA_BONUS:'mana',
  STATS_STRENGTH_BONUS:'strength', STATS_AGILITY_BONUS:'agility', STATS_INTELLECT_BONUS:'intellect',
  HEALTH_REGEN_CONSTANT:'health_regen', MANA_REGEN_CONSTANT:'mana_regen', HEALTH_REGEN_PERCENTAGE:'health_regen_pct',
  MAGICAL_RESISTANCE_BONUS:'magic_resist', STATUS_RESISTANCE_STACKING:'status_resist',
  MOVESPEED_BONUS_PERCENTAGE:'move_pct', MOVESPEED_BONUS_UNIQUE:'move', EVASION_CONSTANT:'evasion',
  ATTACKSPEED_BONUS_CONSTANT:'attack_speed', COOLDOWN_PERCENTAGE:'cooldown', SPELL_AMPLIFY_PERCENTAGE:'spell_amp'
};
for (const language of ['turkish','english','russian','schinese']) {
  const file='localization/'+language+'.json', data=JSON.parse(fs.readFileSync(file,'utf8')), t=data.Tokens;
  for (const [id,item] of Object.entries(items)) {
    if (!id.startsWith('item_ascended_') || id==='item_ascended_aghanims_blessing') continue;
    if (item.BaseClass !== 'item_datadriven') {
      if (!t['DOTA_Tooltip_Ability_'+id].startsWith('★ ') || !t['DOTA_Tooltip_Ability_'+id+'_Description']) throw new Error('Missing native Ascended tooltip '+id);
      continue;
    }
    const special=Object.assign({},...Object.values(item.AbilitySpecial||{}));
    const stats=[];
    for (const modifier of Object.values(item.Modifiers||{})) if (modifier.Passive==='1') {
      for (const [property,value] of Object.entries(modifier.Properties||{})) {
        const label=t['enfos_stat_'+properties[property.replace('MODIFIER_PROPERTY_','')]];
        const number=value.startsWith('%')?special[value.slice(1)]:value;
        if (!label || number===undefined) throw new Error('Missing property description: '+id+'/'+property);
        stats.push('+'+number+' '+label);
      }
    }
    let description=stats.join(', ')+'. ';
    description+=id==='item_ascended_thornplate'
      ? t.enfos_thornplate_active.replace('{duration}',special.duration).replace('{reduction}',String(-Number(special.damage_reduction_pct)))
      : t.enfos_ascended_unfinished;
    const key='DOTA_Tooltip_Ability_'+id+'_Description';
    if(process.argv.includes('--check')) {
      if(t[key]!==description) throw new Error('Stale item description: '+language+'/'+id);
    } else {
      t['DOTA_Tooltip_Ability_'+id+'_DesignDescription']??=t[key];
      t[key]=description;
      t['DOTA_Tooltip_Ability_'+id+'_SummaryDescription']=description;
    }
  }
  if(!process.argv.includes('--check')) fs.writeFileSync(file,JSON.stringify(data,null,2)+'\n');
}

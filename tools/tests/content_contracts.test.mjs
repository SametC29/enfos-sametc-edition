import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';
const read=p=>parseKV(fs.readFileSync('game/scripts/npc/'+p,'utf8'));
test('every hero exposes an innate, correct ultimate type and only the unified evolution tree',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  assert.equal(Object.keys(heroes).length,40);
  for(const [id,h] of Object.entries(heroes)){
    assert.equal(abilities[h.Ability5].Innate,'1',id);
    assert.equal(abilities[h.Ability4].AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE',id);
    assert.equal(abilities[h.Ability4].HasScepterUpgrade,'1',id);
    assert.equal(abilities[h.Ability5].HasShardUpgrade,'1',id);
    for(let i=7;i<=17;i++)assert.equal(h['Ability'+i],'generic_hidden',id+': stale native talent');
    for(const lang of ['turkish','english','russian','schinese']){
      const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
      assert.ok(tokens['DOTA_Tooltip_Ability_'+h.Ability4+'_scepter_description']);
      assert.ok(tokens['DOTA_Tooltip_Ability_'+h.Ability5+'_shard_description']);
    }
  }
});
test('30 Ascended items use native implementations, meaningful upgraded values and matching sale costs',()=>{
  const items=read('npc_items_custom.txt').DOTAItems;
  const records=JSON.parse(fs.readFileSync('docs/audit/ASCENDED_NATIVE_SNAPSHOT.json','utf8')).items;
  assert.equal(records.length,30);
  for(const r of records){
    const item=items[r.id];assert.equal(item.BaseClass,r.base);assert.equal(item.ItemPurchasable,'0');
    assert.equal(Number(item.ItemCost),r.nativeCost);assert.ok(Object.keys(r.changes).length);
    for(const [key,v] of Object.entries(r.changes)){
      assert.ok(v.ascended>v.base);assert.equal(Number(item.AbilityValues[key]),v.ascended);
    }
    assert.ok(!item.Modifiers,'A passive placeholder must never replace the native active');
  }
});

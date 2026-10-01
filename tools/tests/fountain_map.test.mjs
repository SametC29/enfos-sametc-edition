import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {parseKV} from '../lib/kv.mjs';
const read=p=>parseKV(fs.readFileSync('game/scripts/npc/'+p,'utf8'));

test('compiled map recovery points resolve to a localized non-attacking native fountain',()=>{
  const evidence=JSON.parse(fs.readFileSync('docs/audit/HEALING_MAP_ENTITIES.json','utf8'));
  const hash=crypto.createHash('sha256').update(fs.readFileSync(evidence.map)).digest('hex');
  assert.equal(hash,evidence.mapSha256,'map changed: re-extract recovery entities before relying on this evidence');
  assert.equal(evidence.entities.length,2);
  assert.deepEqual(evidence.entities.map(e=>e.team).sort(),[2,3]);
  const units=read('npc_units_custom.txt').DOTAUnits;
  for(const entity of evidence.entities){
    assert.equal(entity.classname,'npc_dota_base');
    const unit=units[entity.unit];
    assert.ok(unit,`compiled map references undefined ${entity.unit}`);
    assert.equal(unit.BaseClass,'ent_dota_fountain');
    assert.equal(unit.Model,'models/props_structures/muerta_minigame_effigy.vmdl');
    assert.equal(unit.AttackCapabilities,'DOTA_UNIT_CAP_NO_ATTACK');
    assert.equal(unit.MovementCapabilities,'DOTA_UNIT_CAP_MOVE_NONE');
    assert.equal(unit.BountyXP,'0');
    assert.equal(unit.BountyGoldMax,'0');
    assert.equal(unit.Ability1,undefined,'do not depend on the reference game custom fountain_aura');
    for(const lang of ['english','turkish','russian','schinese']){
      assert.ok(JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens[entity.unit]);
    }
  }
});

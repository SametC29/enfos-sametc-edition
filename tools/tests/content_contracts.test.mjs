import './fountain_map.test.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';
const read=p=>parseKV(fs.readFileSync('game/scripts/npc/'+p,'utf8'));

test('Dragon Knight release skill tooltips are localized and match Enfos values',()=>{
  const abilities=['breathe_fire','dragon_tail','dragon_blood','elder_dragon_form','wyrm_vigor'];
  const expected={english:/[A-Za-z]/,russian:/[А-Яа-яЁё]/,schinese:/[\u3400-\u9fff]/};
  for(const [lang,script] of Object.entries(expected)){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    for(const id of abilities){
      const text=tokens[`DOTA_Tooltip_Ability_enfos_dk_${id}_Description`];
      assert.ok(text,`${lang}: missing Dragon Knight ${id} description`);
      assert.match(text,script,`${lang}: Dragon Knight ${id} is not translated`);
      assert.doesNotMatch(text,/[ıİşğüöç]/,`${lang}: Turkish fallback leaked into ${id}`);
    }
    assert.match(tokens.DOTA_Tooltip_Ability_enfos_dk_dragon_blood_Description,/5%/,
      `${lang}: Dragon Blood tooltip must include the Strength-based regeneration implemented in Lua`);
  }
  const turkish=JSON.parse(fs.readFileSync('localization/turkish.json','utf8')).Tokens;
  assert.match(turkish.DOTA_Tooltip_Ability_enfos_dk_dragon_blood_Description,/Gücünün %5/,
    'Turkish Dragon Blood tooltip must expose its Strength-based regeneration');
});

test('Dragon Knight Enfos passive uses the distinct verified Wyrm’s Wrath icon',()=>{
  const abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  assert.equal(abilities.enfos_dk_wyrm_vigor.AbilityTextureName,'dragon_knight_wyrms_wrath',
    'Wyrm Vigor must not reuse the Dragon Blood passive icon');
});

test('Dragon Knight native sound bank is included in the addon precache list',()=>{
  const mode=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  assert.match(mode,/["']dragon_knight["']/,
    'Dragon Knight Lua abilities emit Hero_DragonKnight events and need its native sound bank precached');
});

test('Dragon Knight Elder Dragon Form keeps its native no-cast-animation behavior',()=>{
  const abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  assert.equal(abilities.enfos_dk_elder_dragon_form.AbilityCastAnimation,'ACT_INVALID',
    'native Elder Dragon Form explicitly suppresses a cast gesture during transformation');
});

test('Dragon Knight skill particles are all present in the addon precache list',()=>{
  const mode=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  const kits=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  const start=kits.indexOf('enfos_dk_breathe_fire=class({})');
  const end=kits.indexOf('-- PUDGE: MEAT HOOK',start);
  assert.ok(start>=0&&end>start,'Dragon Knight ability implementation region must be found');
  const assets=[...new Set(kits.slice(start,end).match(/particles\/units\/heroes\/hero_dragon_knight\/[\w/.-]+\.vpcf/g)||[])];
  assert.equal(assets.length,6,'all six Dragon Knight ability particle assets should be inventoried');
  for(const asset of assets){
    assert.ok(mode.includes(asset),`missing Dragon Knight particle precache: ${asset}`);
  }
});


test('Elites are fully retired from the NPC roster and wave runtime',()=>{
  const units=read('npc_units_custom.txt').DOTAUnits;
  assert.deepEqual(Object.keys(units).filter(id=>id.startsWith('enfos_elite_')),[],'no retired Elite unit definitions may ship');
  const wave=fs.readFileSync('game/scripts/vscripts/waves/wave_manager.lua','utf8');
  const defs=fs.readFileSync('game/scripts/vscripts/waves/wave_definitions.lua','utf8');
  const boon=fs.readFileSync('game/scripts/vscripts/boons/boon_manager.lua','utf8');
  assert.doesNotMatch(wave,/EliteFramework|is_elite|elite_framework/);
  assert.doesNotMatch(defs,/IsEliteWave|enfos_elite_/);
  assert.doesNotMatch(boon,/elite_hunters/);
  assert.equal(fs.existsSync('game/scripts/vscripts/bosses/elite_framework.lua'),false,'retired Elite framework must not ship');
  const loading=fs.readFileSync('game/panorama/layout/custom_game/custom_loading_screen.xml','utf8');
  assert.match(loading,/enfos_loading_wave_format/);
  assert.match(loading,/enfos_loading_core_format/);
  assert.doesNotMatch(loading,/40 Normal, 8 Elite|lane caps/);
  for(const lang of ['turkish','english','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    assert.ok(tokens.enfos_loading_wave_format,`${lang}: missing wave schedule text`);
    assert.ok(tokens.enfos_loading_core_format,`${lang}: missing Core rules text`);
  }
});
test('every authored Enfos unit has a concrete model path rather than an ERROR placeholder',()=>{
  const units=read('npc_units_custom.txt').DOTAUnits;
  const authored=Object.entries(units).filter(([id])=>id.startsWith('enfos_'));
  assert.ok(authored.length>0);
  for(const [id,unit] of authored){
    assert.ok(unit.Model,`${id}: missing Model field`);
    assert.match(unit.Model,/\.vmdl$/i,`${id}: expected a Source 2 model path`);
    assert.doesNotMatch(unit.Model,/error/i,`${id}: ERROR model placeholder`);
  }
});
test('silencer wave creep uses a model path confirmed in the installed base-game VPK',()=>{
  const units=read('npc_units_custom.txt').DOTAUnits;
  assert.equal(units.enfos_creep_silencer.Model,'models/creeps/neutral_creeps/n_creep_vulture_b/n_creep_vulture_b.vmdl');
});
test('every hero exposes correct ultimate/evolution contracts and migrated Enfos passives stay distinct from Dota innates',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const separatedEnfosPassives=new Set(['npc_dota_hero_sven','npc_dota_hero_juggernaut','npc_dota_hero_axe','npc_dota_hero_bristleback','npc_dota_hero_centaur','npc_dota_hero_crystal_maiden','npc_dota_hero_dazzle','npc_dota_hero_drow_ranger','npc_dota_hero_legion_commander','npc_dota_hero_lina','npc_dota_hero_omniknight','npc_dota_hero_phantom_assassin','npc_dota_hero_sniper','npc_dota_hero_skeleton_king','npc_dota_hero_tidehunter','npc_dota_hero_zuus','npc_dota_hero_witch_doctor','npc_dota_hero_dragon_knight','npc_dota_hero_pudge','npc_dota_hero_slark','npc_dota_hero_ursa','npc_dota_hero_monkey_king','npc_dota_hero_troll_warlord','npc_dota_hero_chaos_knight','npc_dota_hero_antimage','npc_dota_hero_faceless_void','npc_dota_hero_medusa','npc_dota_hero_terrorblade','npc_dota_hero_storm_spirit','npc_dota_hero_leshrac','npc_dota_hero_invoker','npc_dota_hero_puck','npc_dota_hero_lion','npc_dota_hero_jakiro','npc_dota_hero_vengefulspirit','npc_dota_hero_lich','npc_dota_hero_luna','npc_dota_hero_nevermore','npc_dota_hero_shadow_shaman','npc_dota_hero_abyssal_underlord']);
  assert.equal(Object.keys(heroes).length,40);
  assert.equal(separatedEnfosPassives.size,Object.keys(heroes).length,'every roster hero needs an Enfos passive separate from Dota innate metadata');
  for(const [id,h] of Object.entries(heroes)){
    for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10',`${id} ${slot} must expose ten total ranks`);
    if(id==='npc_dota_hero_tidehunter')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Tidehunter Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_antimage')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Anti-Mage Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_faceless_void')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Faceless Void Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_medusa')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Medusa Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_terrorblade')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Terrorblade Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_storm_spirit')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Storm Spirit Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_leshrac')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Leshrac Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_invoker')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Invoker Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_puck')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Puck Enfos slots must have ten ranks');
    if(['npc_dota_hero_lion','npc_dota_hero_jakiro','npc_dota_hero_vengefulspirit','npc_dota_hero_lich'].includes(id))for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10',`${id} Enfos slots must have ten ranks`);
    if(id==='npc_dota_hero_skeleton_king')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Wraith King Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_phantom_assassin')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Phantom Assassin Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_zuus')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Zeus Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_witch_doctor')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Witch Doctor Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_dragon_knight')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Dragon Knight Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_pudge')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Pudge Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_slark')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Slark Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_ursa')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Ursa Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_monkey_king')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Monkey King Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_troll_warlord')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Troll Warlord Enfos slots must have ten ranks');
    if(id==='npc_dota_hero_chaos_knight')for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5'])assert.equal(abilities[h[slot]].MaxLevel,'10','Chaos Knight Enfos slots must have ten ranks');
    assert.ok(separatedEnfosPassives.has(id),id+': missing from separate Enfos passive contract');
    assert.equal(abilities[h.Ability5].Innate,undefined,id+': Enfos passive must not be marked as Dota innate');
    assert.ok(abilities[h.Ability5].AbilityBehavior?.includes('DOTA_ABILITY_BEHAVIOR_PASSIVE'),id+': fifth Enfos ability must be passive');
    assert.equal(abilities[h.Ability4].AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE',id);
    const scepterAbility=id==='npc_dota_hero_tidehunter'?h.Ability1:id==='npc_dota_hero_lich'?h.Ability3:h.Ability4;
    assert.equal(abilities[scepterAbility].HasScepterUpgrade,'1',id);
    if(id==='npc_dota_hero_tidehunter') assert.equal(abilities[h.Ability4].HasScepterUpgrade,undefined,'Ravage must not advertise the removed generic Scepter');
    if(id==='npc_dota_hero_lich') assert.equal(abilities[h.Ability4].HasScepterUpgrade,undefined,'Chain Frost must not advertise the replaced generic Scepter');
    const shardAbility=id==='npc_dota_hero_vengefulspirit'?h.Ability1:id==='npc_dota_hero_lich'?h.Ability6:['npc_dota_hero_shadow_shaman','npc_dota_hero_tidehunter'].includes(id)?h.Ability2:h.Ability5;
    assert.equal(abilities[shardAbility].HasShardUpgrade,'1',id);
    if(id==='npc_dota_hero_vengefulspirit'){
      assert.equal(abilities[h.Ability5].HasShardUpgrade,undefined,'Retribution must not advertise unrelated healing');
      assert.equal(abilities[h.Ability1].AbilityValues.bounce_range_pct,'75','Magic Missile uses native Shard bounce range');
    }
    if(id==='npc_dota_hero_lich'){
      assert.equal(h.Ability6,'enfos_lich_ice_spire');
      assert.equal(abilities[h.Ability5].HasShardUpgrade,undefined,'Aura must not advertise the replaced generic Shard');
    }
    if(id==='npc_dota_hero_shadow_shaman') assert.equal(abilities[h.Ability5].HasShardUpgrade,undefined,'Fowl Play must not advertise the replaced generic Shard');
    if(id==='npc_dota_hero_tidehunter') assert.equal(abilities[h.Ability5].HasShardUpgrade,undefined,'Colossal Presence must not advertise the replaced generic Shard');
    for(let i=7;i<=9;i++)assert.equal(h['Ability'+i],'generic_hidden',id+': unused ability slot');
    for(let i=10;i<=17;i++)assert.equal(h['Ability'+i],'generic_hidden',id+': talent slot must stay disabled');
    assert.equal(h.Ability19,'generic_hidden',id+': native attribute bonus must be hidden');
    assert.equal(h.Ability25,'generic_hidden',id+': native Ability25 bonus must be hidden');
    for(const lang of ['turkish','english','russian','schinese']){
      const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
      assert.ok(tokens['DOTA_Tooltip_Ability_'+scepterAbility+'_scepter_description']);
      assert.ok(tokens['DOTA_Tooltip_Ability_'+shardAbility+'_shard_description']);
    }
  }
  assert.equal(Object.keys(abilities).filter(id=>id.startsWith('special_bonus_enfos_')).length,0,'removed talent abilities must not remain in KV');
});
test('Centaur rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_centaur;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10');
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} first rank unlocks at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} ranks can unlock each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50,
    'The tenth ultimate rank must be available by the level-50 cap');
  assert.equal(abilities[hero.Ability5].Innate,undefined,'The Enfos free passive remains separate from Dota Innate metadata');
});
test('Wraith King rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_skeleton_king;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
  for(const slot of ['Ability2','Ability3','Ability4','Ability5']){
    assert.equal(abilities[hero[slot]].IsBreakable,'1',`${hero[slot]} has a passive component that must be breakable`);
  }
});
test('Phantom Assassin rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_phantom_assassin;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
  for(const slot of ['Ability3','Ability4','Ability5']){
    assert.equal(abilities[hero[slot]].IsBreakable,'1',`${hero[slot]} passive must be breakable`);
  }
});
test('Sven rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_sven;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Lina rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_lina;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Juggernaut rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_juggernaut;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Drow Ranger rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_drow_ranger;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Dazzle rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_dazzle;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Tidehunter rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_tidehunter;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Tidehunter active abilities preserve verified native cast presentation metadata',()=>{
  const abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  for(const name of ['enfos_tide_gush','enfos_tide_anchor_smash'])assert.equal(abilities[name].SpellDispellableType,'SPELL_DISPELLABLE_YES');
  assert.equal(abilities.enfos_tide_ravage.SpellDispellableType,'SPELL_DISPELLABLE_YES_STRONG');
  for(const name of ['enfos_tide_kraken_shell','enfos_tide_colossal_presence'])assert.equal(abilities[name].SpellDispellableType,'SPELL_DISPELLABLE_NO');
  assert.equal(abilities.enfos_tide_gush.AbilityCastAnimation,'ACT_DOTA_CAST_ABILITY_1');
  assert.equal(abilities.enfos_tide_gush.AbilitySound,'Ability.GushCast');
  assert.equal(abilities.enfos_tide_anchor_smash.AbilityCastAnimation,'ACT_DOTA_CAST_ABILITY_3');
  assert.equal(abilities.enfos_tide_ravage.AbilityCastAnimation,'ACT_DOTA_CAST_ABILITY_4');
  assert.equal(abilities.enfos_tide_ravage.AbilitySound,'Ability.Ravage');
  const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  assert.doesNotMatch(lua,/Hero_Tidehunter\.(?:Gush\.Cast|Ravage)/,
    'Gush and Ravage use installed native sound events through AbilitySound, not unverified EmitSound names');
  const bootstrap=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  assert.match(bootstrap,/"zuus","tidehunter"/,
    'the native Tidehunter event bank must be explicitly included in hero sound precache');
});
test('Tidehunter Scepter metadata and localized values belong to the piercing Gush upgrade',()=>{
  const abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const gush=abilities.enfos_tide_gush;
  assert.equal(gush.HasScepterUpgrade,'1');
  assert.equal(abilities.enfos_tide_ravage.HasScepterUpgrade,undefined);
  const fields={scepter_range:'2200',scepter_radius:'260',scepter_speed:'1500',scepter_cooldown:'7'};
  for(const [key,value] of Object.entries(fields)) assert.equal(gush.AbilityValues[key],value);
  for(const lang of ['english','turkish','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
    const desc=tokens.DOTA_Tooltip_Ability_enfos_tide_gush_scepter_description;
    assert.ok(desc && Object.values(fields).every(value=>desc.includes(value)),lang+': upgrade tooltip values must match KV');
    assert.equal(tokens.DOTA_Tooltip_Ability_enfos_tide_ravage_scepter_description,undefined);
  }
  const bootstrap=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  assert.ok(bootstrap.includes('"particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf"'));
});

test('Tidehunter Shard metadata and localized values belong to reactive Kraken Shell',()=>{
  const abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  assert.equal(abilities.enfos_tide_kraken_shell.HasShardUpgrade,'1');
  assert.equal(abilities.enfos_tide_colossal_presence.HasShardUpgrade,undefined);
  assert.equal(abilities.enfos_tide_kraken_shell.AbilityValues.shard_smash_damage_pct,'50');
  assert.equal(abilities.enfos_tide_kraken_shell.AbilityValues.shard_smash_cooldown,'5');
  for(const lang of ['english','turkish','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
    assert.ok(tokens.DOTA_Tooltip_Ability_enfos_tide_kraken_shell_shard_description.includes('50'));
    assert.ok(tokens.DOTA_Tooltip_Ability_enfos_tide_kraken_shell_shard_description.includes('5'));
    assert.equal(tokens.DOTA_Tooltip_Ability_enfos_tide_colossal_presence_shard_description,undefined);
  }
});

test('Dragon Knight rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_dragon_knight;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Pudge rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_pudge;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Axe rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_axe;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Omniknight rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_omniknight;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Legion Commander rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_legion_commander;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Sniper rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_sniper;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Sniper Keen Eye uses explicit bounded piercing values',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const keen=abilities[heroes.npc_dota_hero_sniper.Ability5];
  assert.equal(keen.AbilityValues.pierce_distance,'550');
  assert.equal(keen.AbilityValues.pierce_width,'300');
  assert.equal(keen.AbilityValues.max_pierced_targets,'3');
  assert.match(keen.AbilityValues.pierce_damage_pct,/^60 64 69 73 78 82 87 91 96 100$/);
});
test('Crystal Maiden rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_crystal_maiden;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Zeus rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_zuus;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
  assert.equal(abilities[hero.Ability5].IsBreakable,'1','Static Field must be breakable because its Lua passive gates on PassivesDisabled');
});
test('Witch Doctor rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_witch_doctor;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Slark rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_slark;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Luna rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_luna;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Shadow Fiend rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_nevermore;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Shadow Fiend Requiem resolves after its cast point without a dead channel',()=>{
  const abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const requiem=abilities.enfos_sf_requiem_of_souls;
  assert.equal(requiem.AbilityBehavior,'DOTA_ABILITY_BEHAVIOR_NO_TARGET');
  assert.equal(requiem.AbilityCastPoint,'1.67');
  assert.equal(requiem.AbilityChannelTime,undefined);
});
test('Shadow Shaman rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_shadow_shaman;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Underlord rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_abyssal_underlord;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Ursa rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_ursa;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Monkey King rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_monkey_king;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Troll Warlord rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_troll_warlord;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Chaos Knight rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_chaos_knight;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Anti-Mage rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_antimage;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Faceless Void rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_faceless_void;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} starts at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} unlocks each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Medusa rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_medusa;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Terrorblade rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_terrorblade;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Storm Spirit rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_storm_spirit;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Leshrac rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_leshrac;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Invoker rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_invoker;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Puck rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_puck;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Lion rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_lion;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Jakiro rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_jakiro;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Vengeful Spirit rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_vengefulspirit;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Lich rank gates fit all ten ability ranks inside the match level cap',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_lich;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10'); assert.equal(ability.RequiredLevel,'1'); assert.equal(ability.LevelsBetweenUpgrades,'1');
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE'); assert.equal(ultimate.MaxLevel,'10');
  assert.equal(ultimate.RequiredLevel,'5'); assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Zeus Heavenly Jump uses VPK-verified native leap particles and precaches both',()=>{
  const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  const mode=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  for(const path of ['zuus_shard_jump_launch_ring','zuus_shard_jump_landing_ring']){
    const resource=`particles/units/heroes/hero_zuus/${path}.vpcf`;
    assert.ok(lua.includes(resource),`${path} must be used by Heavenly Jump`);
    assert.ok(mode.includes(resource),`${path} must be precached`);
  }
});
test('every Enfos modifier class in pve_kits.lua is registered with LinkLuaModifier',()=>{
  const source=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  const list=source.match(/local modifier_list = \{([\s\S]*?)\n\}/);
  assert.ok(list,'shared hero modifier registry exists');
  const linked=new Set([...list[1].matchAll(/'(modifier_enfos_[A-Za-z0-9_]+)'/g)].map(match=>match[1]));
  const defined=new Set([...source.matchAll(/^(modifier_enfos_[A-Za-z0-9_]+)\s*=\s*class\(\{\}\)/gm)].map(match=>match[1]));
  const missing=[...defined].filter(name=>!linked.has(name));
  assert.deepEqual(missing,[],'all locally defined Enfos modifiers must be linked before Dota attaches them');
});
test('Sven Gods Strength uses AbilityValues for every Lua-read special and retains ten-rank curves',()=>{
  const ability=read('npc_abilities_custom.txt').DOTAAbilities.bulwark_fortress;
  assert.equal(ability.MaxLevel,'10');
  assert.equal(ability.AbilitySpecial,undefined,'legacy numbered AbilitySpecial is known to return zero for this Lua kit');
  const values=ability.AbilityValues;
  const ranked=['duration','damage_reduction_pct','shockwave_damage','bonus_damage_pct','bonus_str'];
  const scalars=['radius','shockwave_interval','shockwave_strength_factor','move_speed_pct','scepter_duration_bonus','scepter_status_resistance','scepter_ally_radius','scepter_ally_duration','scepter_ally_bonus_damage_pct','scepter_ally_bonus_armor'];
  for(const key of ranked)assert.equal(values[key].trim().split(/\s+/).length,10,`${key} must have ten values`);
  for(const key of scalars)assert.ok(values[key]!==undefined,`${key} must be defined in AbilityValues`);
});
test('Slark Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_slark;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  assert.equal(all.enfos_slark_essence_shift.IsBreakable,'1');
  assert.equal(all.enfos_slark_fish_bait.IsBreakable,'1');
});
test('Witch Doctor Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_witch_doctor;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Witch Doctor Death Ward precaches its verified native unit and summon particle',()=>{
  const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  const mode=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  const particle='particles/units/heroes/hero_witchdoctor/witchdoctor_ward_summon.vpcf';
  assert.match(lua,/CreateUnitByName\('npc_dota_witch_doctor_death_ward'/);
  assert.ok(lua.includes(particle),'Death Ward summon must use the verified native summon particle');
  assert.ok(lua.includes("'modifier_enfos_wd_death_ward_visual'"));
  assert.ok(lua.includes('UTIL_Remove(ward)'), 'The channel owner must clean up its spawned ward');
  assert.ok(mode.includes(`PrecacheResource("particle", "${particle}"`));
  assert.ok(mode.includes('PrecacheUnitByNameSync("npc_dota_witch_doctor_death_ward"'));
});
test('Bristleback Warpath uses and precaches its native buff particle',()=>{
  const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  const mode=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  const particle='particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf';
  assert.ok(lua.includes(`return '${particle}'`));
  assert.ok(lua.includes('function modifier_enfos_bb_warpath_buff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end'));
  assert.ok(mode.includes(`PrecacheResource("particle", "${particle}"`));
});
test('Bristleback rank gates fit the level-50 cap and preserve its current R/Scepter pairing',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,abilities=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_bristleback;
  for(const slot of ['Ability1','Ability2','Ability3','Ability5']){
    const ability=abilities[hero[slot]];
    assert.equal(ability.MaxLevel,'10',`${hero[slot]} exposes ten ranks`);
    assert.equal(ability.RequiredLevel,'1',`${hero[slot]} gate begins at level 1`);
    assert.equal(ability.LevelsBetweenUpgrades,'1',`${hero[slot]} gate advances each level`);
  }
  const ultimate=abilities[hero.Ability4];
  assert.equal(ultimate.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
  assert.equal(ultimate.HasScepterUpgrade,'1');
  assert.equal(ultimate.RequiredLevel,'5');
  assert.equal(ultimate.LevelsBetweenUpgrades,'5');
  assert.equal(Number(ultimate.RequiredLevel)+9*Number(ultimate.LevelsBetweenUpgrades),50);
  assert.equal(abilities[hero.Ability5].Innate,undefined);
});
test('Witch Doctor Gris-Gris tooltip exposes its configured interval and rank-scaled gold',()=>{
  const ability=read('npc_abilities_custom.txt').DOTAAbilities.enfos_wd_gris_gris;
  assert.equal(ability.IsBreakable,'1','Gris-Gris checks PassivesDisabled and must advertise Break support');
  assert.equal(ability.AbilityValues.gold_per_interval.trim(),'1 1 1 1 2 2 2 2 3 3');
  assert.equal(ability.AbilityValues.interval,'3.0');
  for(const lang of ['turkish','english','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    const description=tokens.DOTA_Tooltip_Ability_enfos_wd_gris_gris_Description;
    assert.ok(description.includes('{{gold_per_interval}}')&&description.includes('{{interval}}'),`${lang} tooltip must use the configured values`);
  }
});
test('Axe ability tooltips have authored English, Russian and Chinese instead of Turkish fallback',()=>{
  const tr=JSON.parse(fs.readFileSync('localization/turkish.json','utf8')).Tokens;
  const abilityNames=['enfos_axe_berserkers_call','enfos_axe_battle_hunger','enfos_axe_counter_helix','enfos_axe_culling_blade','enfos_axe_blood_armor'];
  for(const lang of ['english','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    for(const id of abilityNames){
      const title=`DOTA_Tooltip_Ability_${id}`,description=`${title}_Description`;
      assert.ok(tokens[title]&&tokens[description],`${lang} ${id} must have title and description`);
      assert.notEqual(tokens[title],tr[title],`${lang} ${id} title must not inherit Turkish`);
      assert.notEqual(tokens[description],tr[description],`${lang} ${id} description must not inherit Turkish`);
      const placeholderKeys=text=>[...text.matchAll(/\{\{(\w+)(?:\|\w+)?\}\}/g)].map(match=>match[1]).sort();
      assert.deepEqual(placeholderKeys(tokens[description]),placeholderKeys(tr[description]),`${lang} ${id} must preserve the configured special values`);
    }
  }
});
test('Centaur Double Edge selects immune enemies consistently and retains its native cast animation',()=>{
  const ability=read('npc_abilities_custom.txt').DOTAAbilities.enfos_centaur_double_edge;
  assert.equal(ability.SpellImmunityType,'SPELL_IMMUNITY_ENEMIES_YES');
  assert.equal(ability.AbilityUnitTargetFlags,'DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES');
  assert.equal(ability.AbilityCastAnimation,'ACT_DOTA_CAST_ABILITY_2');
});

test('Centaur ability tooltips have authored English, Russian and Chinese and preserve special values',()=>{
  const tr=JSON.parse(fs.readFileSync('localization/turkish.json','utf8')).Tokens;
  const abilityNames=['enfos_centaur_hoof_stomp','enfos_centaur_double_edge','enfos_centaur_return','enfos_centaur_stampede','enfos_centaur_colossal_hide'];
  const placeholderKeys=text=>[...text.matchAll(/\{\{(\w+)(?:\|\w+)?\}\}/g)].map(match=>match[1]).sort();
  for(const lang of ['english','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    for(const id of abilityNames){
      const title=`DOTA_Tooltip_Ability_${id}`,description=`${title}_Description`;
      assert.ok(tokens[title]&&tokens[description],`${lang} ${id} must have title and description`);
      assert.notEqual(tokens[title],tr[title],`${lang} ${id} title must not inherit Turkish`);
      assert.notEqual(tokens[description],tr[description],`${lang} ${id} description must not inherit Turkish`);
      assert.deepEqual(placeholderKeys(tokens[description]),placeholderKeys(tr[description]),`${lang} ${id} must preserve the configured special values`);
    }
  }
});
test('Luna Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_luna;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  assert.equal(all.enfos_luna_moon_glaives.IsBreakable,'1');
  assert.equal(all.enfos_luna_lunar_blessing.IsBreakable,'1');
  assert.equal(all.enfos_luna_eclipse.AbilityValues.max_hits_per_target,'6');
  assert.equal(all.enfos_luna_eclipse.AbilityValues.boss_damage_pct,'10');
  assert.equal(all.enfos_luna_lunar_orbit.AbilityValues.pulse_interval,'0.5');
  assert.equal(all.enfos_luna_lunar_orbit.AbilityValues.pulse_radius,'320');
});
test('Shadow Fiend Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_nevermore;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Shadow Shaman Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_shadow_shaman;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Tidehunter Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_tidehunter;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Dragon Knight Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_dragon_knight;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  assert.equal(all.enfos_dk_dragon_blood.IsBreakable,'1');
  assert.equal(all.enfos_dk_wyrm_vigor.IsBreakable,'1');
});
test('Pudge Lua-read specials use named AbilityValues and audit conditional stack keys',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_pudge;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  assert.equal(all.enfos_pudge_flesh_heap.IsBreakable,'1');
  assert.equal(all.enfos_pudge_meat_shield.IsBreakable,'1');
  const contracts=JSON.parse(fs.readFileSync('docs/audit/HERO_ABILITY_CONTRACTS.json','utf8'));
  const heap=contracts.heroes.find(x=>x.id==='npc_dota_hero_pudge').abilities.find(x=>x.id==='enfos_pudge_flesh_heap');
  assert.ok(!heap.unreferencedSpecials.includes('normal_kill_stacks'));
  assert.ok(!heap.unreferencedSpecials.includes('boss_kill_stacks'));
});
test('Underlord Lua-read specials use named AbilityValues and consume Firestorm wave_count',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_abyssal_underlord;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  const contracts=JSON.parse(fs.readFileSync('docs/audit/HERO_ABILITY_CONTRACTS.json','utf8'));
  const firestorm=contracts.heroes.find(x=>x.id==='npc_dota_hero_abyssal_underlord').abilities.find(x=>x.id==='enfos_underlord_firestorm');
  assert.ok(!firestorm.unreferencedSpecials.includes('wave_count'));
  assert.ok(!firestorm.unreferencedSpecials.includes('wave_interval'));
});
test('deep special audit follows modifier and shared-helper readers',()=>{
  const contracts=JSON.parse(fs.readFileSync('docs/audit/HERO_ABILITY_CONTRACTS.json','utf8'));
  const ability=(heroId,abilityId)=>contracts.heroes.find(h=>h.id===heroId).abilities.find(a=>a.id===abilityId);
  for(const [hero,id,key] of [
    ['npc_dota_hero_omniknight','enfos_omni_hammer_of_purity','slow_pct'],
    ['npc_dota_hero_crystal_maiden','enfos_cm_glacial_mastery','frost_stack_duration'],
    ['npc_dota_hero_dazzle','enfos_dazzle_nothl_weave','max_stacks'],
    ['npc_dota_hero_bristleback','enfos_bb_viscous_nasal_goo','duration'],
    ['npc_dota_hero_jakiro','enfos_jakiro_ice_path','path_delay'],
    ['npc_dota_hero_abyssal_underlord','enfos_underlord_firestorm','wave_count'],
  ]) assert.ok(!ability(hero,id).unreferencedSpecials.includes(key),`${id}.${key} is read through a linked modifier/helper`);
  assert.ok(!ability('npc_dota_hero_shadow_shaman','enfos_ss_fowl_play').specials.shield_hp);
  assert.ok(!ability('npc_dota_hero_lich','enfos_lich_chain_frost').unreferencedSpecials.includes('slow_pct'));
});
test('Shadow Shaman tooltips use live specials and the Scepter tooltip matches ward attack behavior',()=>{
  const tokens=JSON.parse(fs.readFileSync('localization/turkish.json','utf8')).Tokens;
  assert.match(tokens.DOTA_Tooltip_Ability_enfos_ss_ether_shock_Description,/\{\{damage\}\}/);
  assert.match(tokens.DOTA_Tooltip_Ability_enfos_ss_ether_shock_Description,/\{\{targets\}\}/);
  assert.doesNotMatch(tokens.DOTA_Tooltip_Ability_enfos_ss_ether_shock_Description,/%(radius|shock_damage)%/);
  assert.match(tokens.DOTA_Tooltip_Ability_enfos_ss_shackles_Description,/\{\{dps\}\}/);
  assert.doesNotMatch(tokens.DOTA_Tooltip_Ability_enfos_ss_shackles_Description,/%(duration|shackle_damage)%/);
  assert.match(tokens.DOTA_Tooltip_Ability_enfos_ss_mass_serpent_ward_scepter_description,/mega totem/i);
  assert.match(tokens.DOTA_Tooltip_Ability_enfos_ss_mass_serpent_ward_Description,/\{\{scepter_mega_damage_multiplier\}\}/);
});
test('Storm Spirit Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_storm_spirit;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Leshrac Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_leshrac;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Invoker Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_invoker;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Puck Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_puck;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Lion Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_lion;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Lion Impale hit particle is precached by the owning addon startup',()=>{
  const startup=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  assert.match(startup,/PrecacheResource\("particle",\s*"particles\/units\/heroes\/hero_lion\/lion_spell_impale_hit_spikes\.vpcf"/);
});
test('Jakiro Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_jakiro;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  const contracts=JSON.parse(fs.readFileSync('docs/audit/HERO_ABILITY_CONTRACTS.json','utf8'));
  const icePath=contracts.heroes.find(x=>x.id==='npc_dota_hero_jakiro').abilities.find(x=>x.id==='enfos_jakiro_ice_path');
  assert.ok(!icePath.unreferencedSpecials.includes('path_delay'));
});
test('Vengeful Spirit Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_vengefulspirit;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Lich Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_lich;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  const chain=all.enfos_lich_chain_frost.AbilityValues;
  assert.equal(chain.slow_pct,'50');
  assert.equal(chain.slow_attack_pct,'50');
  assert.equal(chain.slow_duration,'2.5');
});
test('Ursa Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_ursa;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  assert.equal(all.enfos_ursa_fury_swipes.IsBreakable,'1','Fury Swipes checks PassivesDisabled and must advertise Break support');
  assert.equal(all.enfos_ursa_ursa_minor.IsBreakable,'1','Ursa Minor checks PassivesDisabled and must advertise Break support');
});
test('Monkey King Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_monkey_king;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  assert.equal(all.enfos_mk_jingu_mastery.IsBreakable,'1');
  assert.equal(all.enfos_mk_mischief.IsBreakable,'1');
});
test('Troll Warlord Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_troll_warlord;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Chaos Knight Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_chaos_knight;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Anti-Mage Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_antimage;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
  for(const id of ['enfos_am_mana_break','enfos_am_counterspell','enfos_am_spellbreaker'])
    assert.equal(all[id].IsBreakable,'1',`${id} checks PassivesDisabled and must advertise Break support`);
});
test('Faceless Void Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_faceless_void;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Medusa Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_medusa;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
  }
});
test('Terrorblade Lua-read specials use named AbilityValues and retain ten-rank curves',()=>{
  const heroes=read('npc_heroes_custom.txt').DOTAHeroes,all=read('npc_abilities_custom.txt').DOTAAbilities;
  const hero=heroes.npc_dota_hero_terrorblade;
  for(const slot of ['Ability1','Ability2','Ability3','Ability4','Ability5']){
    const id=hero[slot],ability=all[id];
    assert.equal(ability.MaxLevel,'10',`${id} must expose ten total ranks`);
    assert.equal(ability.AbilitySpecial,undefined,`${id} Lua values must not use the broken legacy layout`);
    assert.ok(Object.keys(ability.AbilityValues||{}).length,`${id} must define its Lua values`);
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

import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';

function runtime(file){
 const nodes=new Map(),events={},config={};
 function panel(id=''){const n={id,style:{},classes:new Set(),children:[],text:'',AddClass(c){this.classes.add(c)},SetHasClass(c,on){on?this.classes.add(c):this.classes.delete(c)},SetPanelEvent(k,f){this[k]=f},ClearPanelEvent(k){delete this[k]},SetAcceptsFocus(v){this.acceptsFocus=v},SetPositionInPixels(x,y,z){this.position={x,y,z}},GetPositionWithinWindow(){return {x:500,y:400}},SetParent(){},GetParent(){return null},FindChildTraverse(id){return nodes.get(id)||null},RemoveAndDeleteChildren(){this.children=[]}};nodes.set(id,n);return n;}
 const root=panel('root'),$=id=>nodes.get(id.slice(1))||panel(id.slice(1));
 Object.assign($,{GetContextPanel:()=>root,CreatePanel:(type,parent,id)=>{const p=panel(id);p.type=type;parent.children.push(p);return p},Schedule:()=>{},RegisterEventHandler:(e,p,f)=>{events[e]=f},RegisterKeyBind:()=>{},DispatchEvent:()=>{},Localize:s=>s});
 const tables={player_stats:{'0':{damage_dealt:120,kills:2,gold_earned:40}},wave_info:{team_life:{goodguys:99,badguys:100}},economy_state:{}};
 const ctx={$,GameUI:{CustomUIConfig:()=>config},Players:{GetLocalPlayer:()=>0,GetTeam:()=>2,GetPlayerHeroEntityIndex:()=>10,GetPlayerName:()=>"Samet"},Game:{GetAllPlayerIDs:()=>[0],GetScreenWidth:()=>1280,GetScreenHeight:()=>720},Entities:{GetUnitName:()=>"npc_dota_hero_sven",GetLevel:()=>2,GetItemInSlot:(_,i)=>i===0?20:-1},Abilities:{GetAbilityName:()=>"item_branches"},CustomNetTables:{GetTableValue:(n,k)=>(tables[n]||{})[k],SubscribeNetTableListener:(n,f)=>{events[n]=f}},GameEvents:{SendCustomGameEventToServer:()=>{}}};
 vm.runInNewContext(fs.readFileSync(file,'utf8'),ctx);
 return {nodes,events,config};
}

test('scoreboard uses engine visibility events and real item API',()=>{
 const r=runtime('content/panorama/scripts/custom_game/custom_scoreboard.js');
 r.events.DOTACustomUI_SetFlyoutScoreboardVisible(true);assert(r.nodes.get('ScoreboardContainer').classes.has('Visible'));
 assert.equal(r.nodes.get('Item_0_0').itemname,'item_branches');assert.equal(r.nodes.get('DamageVal_0').text,'120');
 r.events.DOTACustomUI_SetFlyoutScoreboardVisible(false);assert(!r.nodes.get('ScoreboardContainer').classes.has('Visible'));
 r.config.toggle_custom_scoreboard();assert(r.nodes.get('ScoreboardContainer').classes.has('Visible'));
 assert.match(fs.readFileSync('content/panorama/layout/custom_game/custom_ui_manifest.xml','utf8'),/type="FlyoutScoreboard" layoutfile="[^"\n]*custom_scoreboard/);
});

test('removed progression and talent systems are absent from the shipped HUD',()=>{
 for(const file of ['content/panorama/layout/custom_game/custom_ui_manifest.xml','game/panorama/layout/custom_game/custom_ui_manifest.xml']){
  const manifest=fs.readFileSync(file,'utf8');
  assert.doesNotMatch(manifest,/progression\.xml|evolution\.xml/);
 }
 const heroes=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;
 for(const [id,hero] of Object.entries(heroes)){
  for(let slot=10;slot<=17;slot++)assert.equal(hero['Ability'+slot],'generic_hidden',id+' talent slot '+slot);
  assert.equal(hero.Ability19,'generic_hidden');assert.equal(hero.Ability25,'generic_hidden');
 }
 assert.doesNotMatch(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8'),/special_bonus_enfos_/);
});

test('removed persistent systems have no server bootstrap or network state',()=>{
 for(const file of ['game/scripts/vscripts/addon_game_mode.lua','game/scripts/vscripts/enfos_sametc.lua','game/scripts/vscripts/setup/enfos_setup_manager.lua'])
  assert.doesNotMatch(fs.readFileSync(file,'utf8'),/progression\/|evolution\//,file);
 assert.doesNotMatch(fs.readFileSync('game/scripts/custom_net_tables.txt','utf8'),/progression_state|evolution_state/);
 for(const locale of ['turkish','english','russian','schinese']){
  const tokens=JSON.parse(fs.readFileSync(`localization/${locale}.json`,'utf8')).Tokens;
  assert.equal(Object.keys(tokens).filter(key=>/enfos_(legacy|account_|hero_mastery|progression_|evolution_)|special_bonus_enfos_/i.test(key)).length,0,locale+' removed progression tokens');
 }
});

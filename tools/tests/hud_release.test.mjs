import test from 'node:test';import assert from 'node:assert/strict';import vm from 'node:vm';import fs from 'node:fs';
function runtime(file){
 const nodes=new Map(),events={},config={},sent=[];
 function panel(id=''){const n={id,style:{},classes:new Set(),children:[],text:'',AddClass(c){this.classes.add(c)},SetHasClass(c,on){on?this.classes.add(c):this.classes.delete(c)},SetPanelEvent(k,f){this[k]=f},SetParent(){},GetParent(){return null},FindChildTraverse(){return null},RemoveAndDeleteChildren(){this.children=[]}};nodes.set(id,n);return n;}
 const root=panel('root');const $=id=>nodes.get(id.slice(1))||panel(id.slice(1));
 Object.assign($,{GetContextPanel:()=>root,CreatePanel:(type,parent,id)=>{const p=panel(id);p.type=type;parent.children.push(p);return p},Schedule(){},RegisterEventHandler:(e,p,f)=>{events[e]=f},DispatchEvent(){},Localize:s=>s});
 const tables={player_stats:{'0':{damage_dealt:120,kills:2,gold_earned:40}},wave_info:{team_life:{goodguys:99,badguys:100}},economy_state:{}};
 const ctx={$,GameUI:{CustomUIConfig:()=>config},Players:{GetLocalPlayer:()=>0,GetTeam:()=>2,GetPlayerHeroEntityIndex:()=>10,GetPlayerName:()=>"Samet"},Game:{GetAllPlayerIDs:()=>[0]},Entities:{GetUnitName:()=>"npc_dota_hero_sven",GetLevel:()=>2,GetItemInSlot:(_,i)=>i===0?20:-1},Abilities:{GetAbilityName:()=>"item_branches"},CustomNetTables:{GetTableValue:(n,k)=>(tables[n]||{})[k],SubscribeNetTableListener:(n,f)=>{events[n]=f}},GameEvents:{SendCustomGameEventToServer:(n,d)=>sent.push({n,d})}};
 vm.runInNewContext(fs.readFileSync(file,'utf8'),ctx);
 return {nodes,events,config,ctx,tables,sent};
}
test('scoreboard uses engine visibility events and real item API',()=>{
 const r=runtime('content/panorama/scripts/custom_game/custom_scoreboard.js');
 r.events.DOTACustomUI_SetFlyoutScoreboardVisible(true);assert(r.nodes.get('ScoreboardContainer').classes.has('Visible'));
 assert.equal(r.nodes.get('Item_0_0').itemname,'item_branches');assert.equal(r.nodes.get('DamageVal_0').text,'120');
 r.events.DOTACustomUI_SetFlyoutScoreboardVisible(false);assert(!r.nodes.get('ScoreboardContainer').classes.has('Visible'));
 r.config.toggle_custom_scoreboard();assert(r.nodes.get('ScoreboardContainer').classes.has('Visible'));
 assert.match(fs.readFileSync('content/panorama/layout/custom_game/custom_ui_manifest.xml','utf8'),/type="FlyoutScoreboard" layoutfile="[^"\n]*custom_scoreboard/);
});
test('tree previews locked choices and submits only unlocked selections',()=>{
 const r=runtime('content/panorama/scripts/custom_game/evolution.js');
 const pair={1:{id:'a',ability:'bulwark_challenge',special:'duration',mode:'+',amount:0.5},2:{id:'b',ability:'bulwark_fortress',special:'cooldown',mode:'*',amount:8}};
 const state={hero_level:2,tree:{4:pair},pending_count:0,chosen_history:{}};
 r.events.evolution_state('', '0',state);let tier=r.nodes.get('EvoTreeRows').children[0];assert.equal(tier.children[1].enabled,false);
 r.config.toggle_evolution_tree();assert(!r.nodes.get('EvoModal').classes.has('EvoModalHidden'));
 state.hero_level=4;state.pending_count=1;r.events.evolution_state('','0',state);tier=r.nodes.get('EvoTreeRows').children[0];assert.equal(tier.children[1].enabled,true);
 tier.children[1].onactivate();assert.equal(r.sent[0].d.choice_id,'a');
 state.chosen_history={4:'a'};r.events.evolution_state('','0',state);tier=r.nodes.get('EvoTreeRows').children[0];assert(tier.children[1].classes.has('Selected'));assert.equal(tier.children[2].enabled,false);
});

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

function shop(available) {
  const panels=[],sent=[],tooltips=[];
  const root={children:[],RemoveAndDeleteChildren(){this.children=[];}};
  const $=()=>root;
  $.Localize=k=>k;
  $.Schedule=()=>{};
  $.DispatchEvent=(...args)=>tooltips.push(args);
  $.CreatePanel=(type,parent,id)=>{
    const p={type,id,children:[],handlers:{},AddClass(){},SetPanelEvent(k,v){this.handlers[k]=v;}};
    parent.children.push(p);panels.push(p);return p;
  };
  const context={$,CustomNetTables:{SubscribeNetTableListener(){},GetTableValue:()=>({1:{
    id:'item_ascended_worldheart',base_item:'item_heart',role:'Tank',lumber:85,tier:3,available
  }})},GameEvents:{SendCustomGameEventToServer:(...args)=>sent.push(args)}};
  vm.runInNewContext(fs.readFileSync('content/panorama/scripts/custom_game/ascended_shop.js','utf8'),context);
  context.RenderCatalog();
  return {panels,sent,tooltips,context,root};
}
test('shop uses server catalog and distinct base/upgrade tooltip identities',()=>{
  const s=shop(1);
  assert.equal(s.root.children.length,1);
  const icons=s.panels.filter(p=>p.type==='DOTAItemImage');
  assert.equal(icons[0].itemname,'item_heart');assert.equal(icons[1].itemname,'item_ascended_worldheart');
  icons[0].handlers.onmouseover();icons[1].handlers.onmouseover();
  assert.equal(s.tooltips[0][2],'item_heart');assert.equal(s.tooltips[1][2],'item_ascended_worldheart');
});
test('unavailable upgrades are disabled and cannot send a purchase request',()=>{
  const s=shop(0);assert.equal(s.panels.find(p=>p.type==='Button').enabled,false);
  s.context.PurchaseAscended('item_ascended_worldheart');assert.equal(s.sent.length,0);
  const live=shop(1);live.context.PurchaseAscended('item_ascended_worldheart');assert.equal(live.sent.length,1);
  live.context.PurchaseAscended('unknown');assert.equal(live.sent.length,1);
});

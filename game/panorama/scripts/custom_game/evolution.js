var EnfosEvolution=(function(){
 "use strict";
 var data={}, open=false, lastPending=0;
 var levels=[4,7,10,13,16,19];
 function indexed(value,index){
  if(!value)return null;
  if(Array.isArray(value))return value[index-1]||null;
  if(value[String(index)]!==undefined)return value[String(index)];
  return value[index-1]||null;
 }
 function show(value){open=value;$('#EvoModal').SetHasClass('EvoModalHidden',!value);}
 function description(c){
  var kind=c.special==='cooldown'?'cooldown':c.mode==='+'?'add':'percent';
  return $.Localize('#enfos_evo_'+kind).replace('{amount}',String(c.amount)).replace('{stat}',kind==='cooldown'?'':$.Localize('#enfos_evo_stat_'+c.special));
 }
 function render(){
  var root=$('#EvoTreeRows');root.RemoveAndDeleteChildren();
  levels.forEach(function(level){
   var tier=$.CreatePanel('Panel',root,'');tier.AddClass('EvoTier');
   var number=$.CreatePanel('Label',tier,'');number.AddClass('EvoLevel');number.text=String(level);
   var pair=(data.tree||{})[String(level)]||indexed(data.tree,level)||{};
   [1,2].forEach(function(side){
    var c=indexed(pair,side);if(!c)return;
    var chosen=(data.chosen_history||{})[String(level)];
    var b=$.CreatePanel('Button',tier,'');b.AddClass('EvoChoice');b.SetHasClass('Selected',chosen===c.id);
    b.enabled=!chosen && Number(data.hero_level)>=level;
    var icon=$.CreatePanel('DOTAAbilityImage',b,'');icon.abilityname=c.ability;
    var words=$.CreatePanel('Panel',b,'');words.AddClass('EvoChoiceText');
    var title=$.CreatePanel('Label',words,'');title.text=$.Localize('#DOTA_Tooltip_Ability_'+c.ability);
    var desc=$.CreatePanel('Label',words,'');desc.AddClass('EvoDescription');desc.text=description(c);
    b.SetPanelEvent('onactivate',function(){GameEvents.SendCustomGameEventToServer('enfos_select_evolution',{milestone_level:level,choice_id:c.id});});
    icon.SetPanelEvent('onmouseover',function(){ $.DispatchEvent('DOTAShowAbilityTooltip',icon,c.ability); });
    icon.SetPanelEvent('onmouseout',function(){ $.DispatchEvent('DOTAHideAbilityTooltip'); });
   });
  });
 }
 function update(_,key,value){if(String(key)!==String(Players.GetLocalPlayer()))return;
  data=value||{};render();
  if(Number(data.pending_count)>lastPending && Number(data.deferred)!==1)show(true);
  lastPending=Number(data.pending_count)||0;
 }
 function toggle(){show(!open);}
 function defer(){show(false);GameEvents.SendCustomGameEventToServer('enfos_defer_evolution',{});}
 function bindNative(){
  var root=$.GetContextPanel();while(root.GetParent())root=root.GetParent();
  var branch=root.FindChildTraverse('StatBranch');
  if(branch){
   if(branch.ClearPanelEvent)branch.ClearPanelEvent('onactivate');
   branch.SetPanelEvent('onactivate',toggle);
   if(branch.ClearPanelEvent){branch.ClearPanelEvent('onmouseover');branch.ClearPanelEvent('onmouseout');}
   branch.SetPanelEvent('onmouseover',function(){});branch.SetPanelEvent('onmouseout',function(){});
  }
  var levelTab=root.FindChildTraverse('LevelUpTab');
  if(levelTab){
   if(levelTab.ClearPanelEvent){levelTab.ClearPanelEvent('onactivate');levelTab.ClearPanelEvent('onmouseover');levelTab.ClearPanelEvent('onmouseout');}
   levelTab.SetPanelEvent('onactivate',toggle);
   levelTab.SetPanelEvent('onmouseover',function(){});levelTab.SetPanelEvent('onmouseout',function(){});
  }
  $.Schedule(1,bindNative);
 }
 CustomNetTables.SubscribeNetTableListener('evolution_state',update);
 update('',String(Players.GetLocalPlayer()),CustomNetTables.GetTableValue('evolution_state',String(Players.GetLocalPlayer())));
 GameUI.CustomUIConfig().toggle_evolution_tree=toggle;
 bindNative();
 return {ToggleModal:toggle,Defer:defer};
})();

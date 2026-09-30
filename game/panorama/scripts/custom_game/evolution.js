var EnfosEvolution=(function(){
 "use strict";
 var data={}, open=false, lastPending=0, nativeAnchor=null, hookedAnchor=null, nativeClickObserved=false;
 var levels=[4,7,10,13,16,19];
 function indexed(value,index){
  if(!value)return null;
  if(Array.isArray(value))return value[index-1]||null;
  if(value[String(index)]!==undefined)return value[String(index)];
  return value[index-1]||null;
 }
 function positionInTalentArea(){
  var modal=$('#EvoModal');
  var toggleButton=$('#EvoToggle');
  var sw=(Game.GetScreenWidth&&Game.GetScreenWidth())||1280;
  var sh=(Game.GetScreenHeight&&Game.GetScreenHeight())||720;
  var width=Math.min(500,Math.max(320,sw-24));
  var height=Math.min(420,Math.max(300,sh-24));
  modal.style.width=width+'px';
  var maxHeight=Math.min(height,sh-24,Math.round(sh*.86));
  modal.style.maxHeight=maxHeight+'px';
  var modalX=Math.max(12,Math.round((sw-width)/2));
  var modalY=Math.max(12,Math.round((sh-maxHeight)/2));
  modal.style.position=modalX+'px '+modalY+'px 0px';
  if(!nativeAnchor||!nativeAnchor.GetPositionWithinWindow||(nativeAnchor.IsValid&&!nativeAnchor.IsValid())){
   var fallbackX=Math.max(8,Math.round((sw-120)/2));
   var fallbackY=Math.max(8,sh-280);
   if(toggleButton.SetPositionInPixels)toggleButton.SetPositionInPixels(fallbackX,fallbackY,0);
   return;
  }
  var p=nativeAnchor.GetPositionWithinWindow();if(!p)return;
  var aw=nativeAnchor.actuallayoutwidth||nativeAnchor.contentwidth||40;
  var toggleWidth=120;
  var toggleLeft=p.x+aw+8;
  if(toggleLeft+toggleWidth>sw-8)toggleLeft=p.x-toggleWidth-8;
  toggleLeft=Math.max(8,Math.min(toggleLeft,sw-toggleWidth-8));
  var toggleTop=Math.max(8,Math.min(p.y,sh-48));
  if(toggleButton.SetPositionInPixels)toggleButton.SetPositionInPixels(toggleLeft,toggleTop,0);
 }
 function show(value){
  var wasOpen=open;
  open=value;
  var modal=$('#EvoModal');
  modal.SetHasClass('EvoModalHidden',!value);
  if(value){
   if(modal.SetAcceptsFocus)modal.SetAcceptsFocus(true);
   $.DispatchEvent('SetInputFocus',modal);
   positionInTalentArea();
  }else if(wasOpen){
   if(modal.SetAcceptsFocus)modal.SetAcceptsFocus(false);
   $.DispatchEvent('DropInputFocus',modal);
  }
 }
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
   var chosen=(data.chosen_history||{})[String(level)];
   tier.SetHasClass('EvoTierUnlocked',Number(data.hero_level)>=level);
   tier.SetHasClass('EvoTierCurrent',Number(data.next_milestone)===level);
   tier.SetHasClass('EvoTierComplete',!!chosen);
   [1,2].forEach(function(side){
    var c=indexed(pair,side);if(!c)return;
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
 function nativeToggle(){nativeClickObserved=true;show(!open);$('#EvoToggle').SetHasClass('EvoToggleHidden',true);}
 function hide(){show(false);}
 function defer(){show(false);GameEvents.SendCustomGameEventToServer('enfos_defer_evolution',{});}
 function bindNative(){
  var root=$.GetContextPanel();while(root.GetParent())root=root.GetParent();
  // Dota exposes no documented six-tier talent API. Reuse the native talent
  // branch entry point for Enfos' six-tier drawer. This deliberately replaces
  // the native talent-popup activation; LevelUpTab (ability-point spending)
  // and native hover handlers remain untouched.
  // DOTAStatBranch is the popup container itself; only StatBranch is the
  // clickable native HUD entry point. Never bind the popup body as a button.
  var branch=root.FindChildTraverse('StatBranch');
  nativeAnchor=branch||null;
  var canHook=branch&&branch.ClearPanelEvent&&branch.SetPanelEvent&&(!branch.IsValid||branch.IsValid());
  if(canHook){
   if(hookedAnchor!==branch)nativeClickObserved=false;
   // Native HUD rebuilds can restore event handlers on an existing panel.
   // Reapply only this entry-point handler during the low-frequency HUD poll.
   branch.ClearPanelEvent('onactivate');
   branch.SetPanelEvent('onactivate',nativeToggle);
   hookedAnchor=branch;
  }
  positionInTalentArea();
  var launcher=$('#EvoToggle');
  // Keep the fallback visible until the native panel actually invokes our
  // callback at least once; finding a panel ID alone is not runtime proof.
  launcher.SetHasClass('EvoToggleHidden',!!(canHook&&nativeClickObserved));
  $.Schedule(1,bindNative);
 }
 CustomNetTables.SubscribeNetTableListener('evolution_state',update);
 update('',String(Players.GetLocalPlayer()),CustomNetTables.GetTableValue('evolution_state',String(Players.GetLocalPlayer())));
 if($.RegisterKeyBind)$.RegisterKeyBind($('#EvoModal'),'key_escape',hide);
 GameUI.CustomUIConfig().toggle_evolution_tree=toggle;
 bindNative();
 return {ToggleModal:toggle,Defer:defer};
})();

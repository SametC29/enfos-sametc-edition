-- Every authored creep receives its wave kit; casts/control remain bounded.
local S = {counts={},castAfter={}}
local class = _G.class or function(t) return t end
local KITS = {
 [6]={"forest_troll_high_priest_heal"},[7]={"berserker_troll_break"},[8]={"gnoll_assassin_envenomed_weapon"},
 [9]={"fel_beast_haunt"},[11]={"invisible"},[12]={"silence"},[13]={"harpy_storm_chain_lightning"},
 [14]={"necronomicon_archer_mana_burn"},[16]={"gnoll_assassin_envenomed_weapon"},[17]={"enfos_creep_shieldbearer_carapace"},[18]={"giant_wolf_intimidate"},
 [19]={"alpha_wolf_critical_strike","alpha_wolf_command_aura"},[21]={"invisible"},
 [22]={"satyr_trickster_purge"},[23]={"satyr_soulstealer_mana_burn"},[24]={"ogre_bruiser_ogre_smash"},
 [26]={"enfos_creep_frostguard_aura"},[27]={"enfos_creep_spellguard_ward"},[28]={"enfos_creep_mindstealer_burn"},[29]={"mudgolem_cloak_aura"},
 [31]={"centaur_khan_war_stomp"},[32]={"satyr_hellcaller_shockwave"},[33]={"warpine_raider_seed_shot"},
 [34]={"root"},[36]={"root","enfos_wave_raise"},[37]={"hill_troll_rally"},
 [38]={"mud_golem_hurl_boulder"},[39]={"necronomicon_warrior_mana_burn"},
 [41]={"furbolg_enrage_attack_speed"},[42]={"polar_furbolg_ursa_warrior_thunder_clap"},
 [43]={"enfos_creep_spellguard_ward"},[44]={"enraged_wildkin_tornado"},
 [46]={"enfos_creep_venomous_poison"},[47]={"centaur_khan_war_stomp"},
 [48]={"mud_golem_hurl_boulder"},[49]={"invisible"},
 [51]={"enfos_creep_exploder_burst"},[52]={"black_drake_magic_amplification_aura"},
 [53]={"ancient_rock_golem_weakening_aura"},[54]={"big_thunder_lizard_slam"},
 [56]={"frostbitten_golem_time_warp_aura"},[57]={"spawnlord_aura","reflect"},
 [58]={"black_dragon_splash_attack"},[59]={"ice_shaman_incendiary_bomb"},
}
S.KITS=KITS
-- Explicit, on-demand runtime audit. Never scans all units from a thinker.
function S.Audit(manager)
 local report={}
 for team,units in pairs(manager.activeCreeps or {}) do
  local row={alive=0,special=0,invisibleExpected=0,invisibleActual=0,missing=0}
  report[team]=row
  for _,unit in pairs(units) do
   if not unit:IsNull() and unit:IsAlive() and not unit.is_wave_child then
    row.alive=row.alive+1
    local kit=KITS[unit.waveNumber]
    if kit then
     row.special=row.special+1
     for _,name in ipairs(kit) do
      local kind=name=="invisible" and 1 or name=="silence" and 2 or name=="root" and 3 or name=="reflect" and 4
      if kind then
       local modifier=unit:FindModifierByName("modifier_enfos_wave_special")
       if not modifier or modifier:IsNull() or modifier:GetStackCount()~=kind then row.missing=row.missing+1 end
       if kind==1 then
        row.invisibleExpected=row.invisibleExpected+1
        if unit:IsInvisible() then row.invisibleActual=row.invisibleActual+1 end
       end
      else
       local ability=unit:FindAbilityByName(name)
       if not ability or ability:IsNull() or ability:GetLevel()<1 then row.missing=row.missing+1 end
      end
     end
    end
   end
  end
  if Log then Log:Info("wave_specials_audit","team=%d alive=%d special=%d missing=%d invisible_expected=%d invisible_actual=%d",team,row.alive,row.special,row.missing,row.invisibleExpected,row.invisibleActual) end
 end
 return report
end
function S.SpawnMinions(caster)
 if caster.is_wave_child then return end
 caster.enfosWaveChildren=caster.enfosWaveChildren or {}
 local live={}
 for _,child in ipairs(caster.enfosWaveChildren) do
  if not child:IsNull() and child:IsAlive() then live[#live+1]=child end
 end
 caster.enfosWaveChildren=live
 local team=caster.defendingTeam or caster:GetTeamNumber()
 local manager=require("waves/wave_manager")
 for i=1,math.min(2,4-#live) do
  local child=CreateUnitByName(caster:GetUnitName(),caster:GetAbsOrigin()+RandomVector(40),true,caster,caster,caster:GetTeamNumber())
  if child then
   child.is_wave_child=true;child.enfosNoReward=true;child.defendingTeam=team;child.waveNumber=caster.waveNumber
   child.is_allied_reinforcement=caster.is_allied_reinforcement
   local hp=math.max(1,math.floor(caster:GetMaxHealth()*0.30))
   child:SetBaseMaxHealth(hp);child:SetMaxHealth(hp);child:SetHealth(hp)
   child:SetBaseDamageMin(math.max(1,math.floor(caster:GetBaseDamageMin()*0.30)))
   child:SetBaseDamageMax(math.max(1,math.floor(caster:GetBaseDamageMax()*0.30)))
   child:SetMinimumGoldBounty(0);child:SetMaximumGoldBounty(0);child:SetDeathXP(0)
   child:AddNewModifier(caster,nil,"modifier_kill",{duration=20})
   child:SetIdleAcquire(true);child:SetAcquisitionRange(650)
   live[#live+1]=child
   if caster.is_allied_reinforcement then
    local owner=caster:GetPlayerOwnerID()
    if owner and owner>=0 then child:SetControllableByPlayer(owner,true) end
   else
    if manager.activeCreeps and manager.activeCreeps[team] then manager.activeCreeps[team][child:entindex()]=child end
    local AI=require("waves/creep_ai")
    AI:Attach(child,team,"center",function(u) u:ForceKill(false) end,AI:RouteFromPosition(team,"center",child:GetAbsOrigin()))
   end
  end
 end
end
enfos_wave_raise=class({})
function enfos_wave_raise:GetAOERadius() return 450 end
function enfos_wave_raise:OnSpellStart() S.SpawnMinions(self:GetCaster()) end
if LinkLuaModifier then LinkLuaModifier("modifier_enfos_wave_special","waves/special_creeps",LUA_MODIFIER_MOTION_NONE) end
function S.Reset() S.counts={};S.castAfter={} end
function S.Configure(unit,wave,team,allied)
 local kit=KITS[wave];if not kit then return end
 local key=tostring(team)..":"..tostring(wave)
 S.counts[key]=(S.counts[key] or 0)+ (allied and 0 or 1)
 unit.enfosSpecials={};unit.enfosSpecialWave=wave
 for _,name in ipairs(kit) do
  if name=="invisible" or name=="silence" or name=="root" or name=="reflect" then
   unit:AddNewModifier(unit,nil,"modifier_enfos_wave_special",{kind=name=="invisible" and 1 or name=="silence" and 2 or name=="root" and 3 or 4})
  else
   local a=unit:AddAbility(name)
   if a then a:SetLevel(1);unit.enfosSpecials[#unit.enfosSpecials+1]=a
   elseif Log then Log:Error("wave_specials","Wave %d could not load %s",wave,name) end
  end
 end
 if #unit.enfosSpecials>0 then unit:SetMaxMana(300);unit:SetMana(300);unit:SetBaseManaRegen(3) end
end
function S.TryCast(unit,team)
 if not unit.enfosSpecials or #unit.enfosSpecials==0 or unit:IsSilenced() or unit:IsReincarnating() then return false end
 local now=GameRules:GetGameTime()
 if now<(unit.enfosSpecialSearchAfter or 0) then return false end
 unit.enfosSpecialSearchAfter=now+0.75
 for _,a in ipairs(unit.enfosSpecials) do
  local key=tostring(team)..":"..unit.enfosSpecialWave..":"..a:GetAbilityName()
  if not a:IsNull() and a:IsFullyCastable() and not a:IsPassive() and now>=(S.castAfter[key] or 0) then
   local behavior=a:GetBehaviorInt()
   local isTarget=bit.band(behavior,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET)~=0
   local isPoint=bit.band(behavior,DOTA_ABILITY_BEHAVIOR_POINT)~=0
   local castRange=a:GetCastRange(unit:GetAbsOrigin(),nil)
   local range=castRange
   if not isTarget and not isPoint then
    range=a:GetAOERadius()
    if range<=0 and a.GetSpecialValueFor then range=a:GetSpecialValueFor('radius') end
    if range<=0 then range=750 end -- Support summons have no impact radius.
   elseif isPoint and castRange<=0 and a.GetSpecialValueFor then
    -- Native self-centered point casts (Ogre Smash) expose impact radius as a special.
    range=a:GetSpecialValueFor('radius')
   end
   range=math.max(128,math.min(1200,range))
   local friendly=a:GetAbilityTargetTeam()==DOTA_UNIT_TARGET_TEAM_FRIENDLY
   local targets=FindUnitsInRadius(friendly and unit:GetTeamNumber() or team,unit:GetAbsOrigin(),nil,range,
    DOTA_UNIT_TARGET_TEAM_FRIENDLY,a:GetAbilityTargetType()==DOTA_UNIT_TARGET_NONE and
     (DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC) or a:GetAbilityTargetType(),
    DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
   local target
   for _,candidate in ipairs(targets) do
    if candidate:IsAlive() and not candidate:IsInvulnerable()
     and (not friendly or candidate==unit or candidate.defendingTeam==team or (unit.is_allied_reinforcement and candidate:GetTeamNumber()==unit:GetTeamNumber()))
     and (a:GetAbilityName()~="forest_troll_high_priest_heal" or candidate:GetHealth()<candidate:GetMaxHealth()) then target=candidate;break end
   end
   if target then
    local order={UnitIndex=unit:entindex(),AbilityIndex=a:entindex(),Queue=false}
    if isTarget then order.OrderType=DOTA_UNIT_ORDER_CAST_TARGET;order.TargetIndex=target:entindex()
    elseif isPoint then
     order.OrderType=DOTA_UNIT_ORDER_CAST_POSITION
     order.Position=castRange<=0 and unit:GetAbsOrigin() or target:GetAbsOrigin()
    else order.OrderType=DOTA_UNIT_ORDER_CAST_NO_TARGET end
    ExecuteOrderFromTable(order);S.castAfter[key]=now+3;return true
   end
  end
 end
 return false
end

modifier_enfos_wave_special=class({})
function modifier_enfos_wave_special:IsHidden() return true end
function modifier_enfos_wave_special:IsPurgable() return false end
function modifier_enfos_wave_special:OnCreated(kv)
 if IsServer() then self:SetStackCount(tonumber(kv and kv.kind) or self:GetStackCount()) end
end
function modifier_enfos_wave_special:OnRefresh(kv) self:OnCreated(kv) end
function modifier_enfos_wave_special:CheckState()
 if self:GetStackCount()==1 then return {[MODIFIER_STATE_INVISIBLE]=true} end
 return {}
end
function modifier_enfos_wave_special:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_EVENT_ON_TAKEDAMAGE,MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_enfos_wave_special:GetModifierInvisibilityLevel() return self:GetStackCount()==1 and 1 or 0 end
function modifier_enfos_wave_special:OnTakeDamage(event)
 if not IsServer() or self:GetStackCount()~=4 or event.unit~=self:GetParent() then return end
 local attacker=event.attacker
 if not attacker or attacker:IsNull() or attacker:GetTeamNumber()==self:GetParent():GetTeamNumber()
  or bit.band(event.damage_flags or 0,DOTA_DAMAGE_FLAG_REFLECTION)~=0 then return end
 ApplyDamage({victim=attacker,attacker=self:GetParent(),damage=math.min(75,(event.damage or 0)*0.20),
  damage_type=DAMAGE_TYPE_PHYSICAL,damage_flags=DOTA_DAMAGE_FLAG_REFLECTION+DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
end
function modifier_enfos_wave_special:OnAttackLanded(event)
 local kind=self:GetStackCount()
 if not IsServer() or (kind~=2 and kind~=3) or event.attacker~=self:GetParent() then return end
 local target=event.target
 if not target or target:IsNull() or not target:IsRealHero() or target:IsMagicImmune() then return end
 local now=GameRules:GetGameTime()
 local key=kind==2 and "enfosWaveSilenceAfter" or "enfosWaveRootAfter"
 if now<(target[key] or 0) then return end
 target[key]=now+7
 target:AddNewModifier(self:GetParent(),nil,kind==2 and "modifier_silence" or "modifier_rooted",{duration=1.5})
end
return S

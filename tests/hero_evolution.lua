package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) return t end
function LinkLuaModifier() end
local T=require('evolution/hero_trees')
local function hero(name)
 local h={GetUnitName=function() return name end,IsNull=function() return false end}
 function h:FindModifierByName() return self.mod end
 function h:AddNewModifier()
  self.mod=setmetatable({stack=0,GetParent=function() return h end,GetStackCount=function(s) return s.stack end,
   SetStackCount=function(s,v) s.stack=v end},{__index=modifier_enfos_hero_evolution})
  return self.mod
 end
 return h
end
local count=0
for name,tree in pairs(T.choices) do
 for level,pair in pairs(tree) do for side,c in ipairs(pair) do
  local h=hero(name);assert(T:Apply(h,c));local m=h.mod;local code=m.stack
  assert(T:Apply(h,c) and code==m.stack)
  assert(not T:Apply(h,pair[3-side]) and code==m.stack)
  local a={IsNull=function() return false end,GetCaster=function() return h end,GetAbilityName=function() return c.ability end,
   GetLevelSpecialValueNoOverride=function(_,key,rank) assert(key==c.special and rank==2);return 200 end,
   GetSpecialValueFor=function() error('recursive override') end}
  if c.special=='cooldown' then
   assert(m:GetModifierPercentageCooldown({ability=a})==c.amount)
  else
   local e={ability=a,ability_special_value=c.special,ability_special_level=2}
   assert(m:GetModifierOverrideAbilitySpecial(e)==1)
   assert(math.abs(m:GetModifierOverrideAbilitySpecialValue(e)-(200+(c.mode=='+' and c.amount or c.amount*2)))<0.0001)
   assert(m:GetModifierOverrideAbilitySpecial({ability=a,ability_special_value='unrelated'})==0)
  end
  assert(m:RemoveOnDeath()==false and m:AllowIllusionDuplicate()==false)
  a.GetCaster=function() return {} end
  assert(m:GetModifierPercentageCooldown({ability=a})==0)
  assert(m:GetModifierOverrideAbilitySpecial({ability=a,ability_special_value=c.special})==0)
  assert(not T:Apply(hero('npc_dota_hero_invalid'),c))
  count=count+1
 end end
 -- Six choices survive repeated restore without doubling their encoded state.
 local h=hero(name)
 for _,level in ipairs({4,7,10,13,16,19}) do assert(T:Apply(h,tree[level][2])) end
 assert(h.mod.stack==728)
 for _,level in ipairs({4,7,10,13,16,19}) do assert(T:Apply(h,tree[level][2])) end
 assert(h.mod.stack==728)
end
assert(count==480)
-- Flat radius and repeated percentage cooldown choices sum only for the matching skill.
local s=hero('npc_dota_hero_sven')
for _,level in ipairs({4,7,10,13,16,19}) do
 for _,c in ipairs(T.choices.npc_dota_hero_sven[level]) do
  if c.special=='radius' or c.special=='cooldown' then T:Apply(s,c);break end
 end
end
local a={IsNull=function() return false end,GetCaster=function() return s end,GetAbilityName=function() return 'bulwark_shield_slam' end}
local flat=s.mod:GetBonuses(a,'radius');assert(flat==120)
print('Hero evolution tests passed: 480 choices, persistence, ownership, duplicates and ability overrides (mock engine).')

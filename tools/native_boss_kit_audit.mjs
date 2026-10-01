// Run the production Boss preparation against recorded installed Valve data.
// This validates KV shape/assembly only, never engine casts or asset rendering.
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';

const snapshot=JSON.parse(fs.readFileSync('docs/audit/NATIVE_BOSS_KIT_SNAPSHOT.json','utf8'));
if(snapshot.records.length!==12) throw new Error('Expected twelve authored Boss kits');
const luaValue=value=>typeof value==='object'
  ? '{'+Object.entries(value).map(([k,v])=>'['+JSON.stringify(k)+']='+luaValue(v)).join(',')+'}'
  : JSON.stringify(value);
const records=Object.fromEntries(snapshot.records.map(r=>[r.hero,{
  ...r.nativeSlots,AbilityDraftAbilities:r.abilityDraft,Bot:{Build:r.botBuild}
}]));
const lua=`package.path='game/scripts/vscripts/?.lua;'..package.path
local records=${luaValue(records)}
function LoadKeyValues(path)
 local name=path:match('heroes/(.+)%.txt$')
 return {DOTAHeroes={[name or '']=records[name]}}
end
local Native=require('bosses/native_hero_bosses')
local total=0
for name,record in pairs(records) do
 local unit={level=1,abilities={},items={}}
 function unit:IsNull() return false end
 function unit:IsHero() return true end
 function unit:GetModelScale() return self.modelScale or 1 end
 function unit:SetModelScale(value) self.modelScale=value end
 function unit:GetAbilityCount() return #self.abilities end
 function unit:GetAbilityByIndex(i) return self.abilities[i+1] end
 function unit:RemoveAbility() error('fresh audit unit has no custom kit') end
 function unit:AddAbility(id)
  local a={name=id,level=0}
  function a:IsNull() return false end
  function a:GetLevel() return self.level end
  function a:GetMaxLevel() return 4 end
  function a:SetLevel(n) self.level=n end
  self.abilities[#self.abilities+1]=a;return a
 end
 function unit:FindAbilityByName(id)
  for _,a in ipairs(self.abilities) do if a.name==id then return a end end
 end
 function unit:GetLevel() return self.level end
 function unit:HeroLevelUp() self.level=self.level+1 end
 function unit:SetAbilityPoints(n) self.points=n end
 function unit:AddItemByName(id) self.items[#self.items+1]=id;return {} end
 assert(Native:Prepare(unit,name,60,2,nil),name..': native kit failed preparation')
 assert(#unit.abilities==4 and unit.level==50 and #unit.items==6,name..': missing final kit/build')
 assert(unit.modelScale==2,name..': Boss size must be double its normal model scale')
 for _,a in ipairs(unit.abilities) do
  assert(a.level>0,name..': untrained native ability '..a.name)
  local native=false
  for _,id in pairs(record.AbilityDraftAbilities) do if id==a.name then native=true end end
  if not native then
   local trained=false
   for _,id in pairs(record.Bot.Build) do if id==a.name then trained=true end end
   for key,id in pairs(record) do
    if key:match('^Ability%d+$') and id==a.name and trained then native=true end
   end
  end
  assert(native,name..': injected ability has no recorded native/Draft provenance '..a.name)
 end
 total=total+1
end
assert(total==12)
print('PASS: all 12 installed-data native Boss kits prepare and train four abilities; runtime remains pending.')
`;
const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',lua],{encoding:'utf8'});
if(result.status!==0 || result.stderr || !result.stdout.includes('PASS: all 12'))
  throw new Error(result.stderr || result.stdout || 'Native Boss kit audit failed');
console.log(result.stdout.trim().split(/\r?\n/).at(-1));
const toggles=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/native_boss_toggles.lua'],{encoding:'utf8'});
if(toggles.status!==0 || toggles.stderr || !toggles.stdout.includes('PASS: native Boss toggle'))
  throw new Error(toggles.stderr || toggles.stdout || 'Native Boss toggle audit failed');
console.log(toggles.stdout.trim());

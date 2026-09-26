import fs from 'fs';

const filePath = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dump_ents/maps/enfos_reborn/entities/default_ents.vents';
const content = fs.readFileSync(filePath, 'utf8');

const blocks = content.split(/^====\d+====$/m);
console.log(`Found ${blocks.length} entity blocks.`);

const ents = [];
const classCounts = {};

for (const b of blocks) {
  const lines = b.split('\n');
  const ent = {};
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    const m = trimmed.match(/^([a-zA-Z0-9_]+)\s+"?([^"\n\r]*)"?$/);
    if (m) {
      ent[m[1]] = m[2];
    }
  }
  if (ent.classname) {
    classCounts[ent.classname] = (classCounts[ent.classname] || 0) + 1;
    ents.push(ent);
  }
}

console.log("Class counts:");
const sorted = Object.entries(classCounts).sort((a,b) => b[1] - a[1]);
for (const [cls, cnt] of sorted) {
  console.log(`  ${cls}: ${cnt}`);
}

// Find key entities
const keyClasses = [
  'info_player_start_goodguys',
  'info_player_start_badguys',
  'info_player_start_dota',
  'info_courier_spawn_radiant',
  'info_courier_spawn_dire',
  'ent_dota_fountain',
  'ent_dota_shop',
  'trigger_shop',
  'path_track',
  'dota_item_spawner',
  'npc_dota_spawner',
  'env_global_light',
  'worldspawn'
];

console.log("\n=== KEY ENTITIES ===");
for (const ent of ents) {
  if (keyClasses.includes(ent.classname) || (ent.targetname && ent.targetname.includes('spawn'))) {
    console.log(`Class: ${ent.classname} | Target: ${ent.targetname || ''} | Origin: ${ent.origin} | Angles: ${ent.angles || ''}`);
  }
}

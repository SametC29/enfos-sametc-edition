import fs from 'fs';

const filePath = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dump_ents_ref_enfos/maps/enfos/entities/default_ents.vents';
const content = fs.readFileSync(filePath, 'utf8');

const blocks = content.split(/^====\d+====$/m);
console.log(`Found ${blocks.length} entity blocks in ref_enfos.`);

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

console.log("\n=== ALL NON-PROP / NON-TREE ENTITIES ===");
for (const ent of ents) {
  if (ent.classname !== 'prop_dynamic' && ent.classname !== 'ent_dota_tree' && ent.classname !== 'dota_world_particle_system' && ent.classname !== 'prop_dynamic_client_fadeout') {
    console.log(`Class: ${ent.classname} | Target: ${ent.targetname || ''} | Origin: ${ent.origin} | Angles: ${ent.angles || ''}`);
  }
}

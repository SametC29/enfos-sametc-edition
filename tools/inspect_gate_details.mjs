import fs from 'fs';

const filePath = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dump_ents_ref_enfos/maps/enfos/entities/default_ents.vents';
const content = fs.readFileSync(filePath, 'utf8');
const blocks = content.split(/^====\d+====$/m);

for (const b of blocks) {
  if (b.includes('info_player_start') || b.includes('dota_fountain') || b.includes('ent_dota_shop')) {
    console.log("------------------------");
    console.log(b.trim());
  }
}

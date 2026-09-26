import fs from 'fs';

const filePath = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dump_ents_ref_enfos/maps/enfos/entities/default_ents.vents';
const content = fs.readFileSync(filePath, 'utf8');
const blocks = content.split(/^====\d+====$/m);

for (const b of blocks) {
  const mCls = b.match(/classname\s+"?([^"\n\r]+)"?/);
  const mTarget = b.match(/targetname\s+"?([^"\n\r]+)"?/);
  const mOrigin = b.match(/origin\s+"?([^"\n\r]+)"?/);
  if (mCls) {
    const cls = mCls[1];
    if (['prop_dynamic', 'ent_dota_tree', 'dota_world_particle_system', 'prop_dynamic_client_fadeout', 'info_particle_system'].includes(cls)) {
      continue;
    }
    const target = mTarget ? mTarget[1] : '';
    const origin = mOrigin ? mOrigin[1] : '';
    console.log(`${cls.padEnd(30)} | ${target.padEnd(32)} | ${origin}`);
  }
}

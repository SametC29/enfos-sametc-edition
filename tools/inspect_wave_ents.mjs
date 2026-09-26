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
    const target = mTarget ? mTarget[1] : '';
    const origin = mOrigin ? mOrigin[1] : '';
    if (
      target.includes('spawn') || target.includes('mob') || target.includes('goal') || 
      target.includes('wave') || target.includes('lane') || target.includes('point') ||
      cls.includes('spawner') || cls.includes('trigger') || cls.includes('building')
    ) {
      console.log(`${cls.padEnd(25)} | ${target.padEnd(28)} | ${origin}`);
    }
  }
}

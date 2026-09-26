import fs from 'fs';

const filePath = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dump_ents_ref_enfos/maps/enfos/entities/default_ents.vents';
const content = fs.readFileSync(filePath, 'utf8');
const blocks = content.split(/^====\d+====$/m);

const pathCorners = [];
for (const b of blocks) {
  if (b.includes('"path_corner"')) {
    const mName = b.match(/targetname\s+"?\[PR#\]?([^"\n\r]+)"?/);
    const mTarget = b.match(/target\s+"?\[PR#\]?([^"\n\r]+)"?/);
    const mOrigin = b.match(/origin\s+\[\s*([-\d.]+),\s*([-\d.]+),\s*([-\d.]+)\s*\]/);
    if (mName && mOrigin) {
      pathCorners.push({
        name: mName[1],
        target: mTarget ? mTarget[1] : null,
        pos: [parseFloat(mOrigin[1]), parseFloat(mOrigin[2]), parseFloat(mOrigin[3])]
      });
    }
  }
}

console.log(`Found ${pathCorners.length} path corners:`);
pathCorners.sort((a,b) => a.name.localeCompare(b.name, undefined, {numeric: true}));
for (const pc of pathCorners) {
  console.log(`${pc.name.padEnd(12)} -> ${(pc.target || 'END').padEnd(12)} at [${pc.pos.map(n => Math.round(n)).join(', ')}]`);
}

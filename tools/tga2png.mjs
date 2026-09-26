import fs from 'node:fs/promises';
import path from 'node:path';
import { encodeRgbaPng } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/util/png.js';

async function convert() {
    const dir = 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta/game/dota/screenshots';
    const files = (await fs.readdir(dir)).filter(f => f.endsWith('.tga')).sort();
    const latest = files[files.length - 1];
    console.log('Converting latest screenshot:', latest);
    const buf = await fs.readFile(path.join(dir, latest));
    const width = buf.readUInt16LE(12);
    const height = buf.readUInt16LE(14);
    const bpp = buf[16];
    const desc = buf[17];
    const topDown = (desc & 0x20) !== 0;

    console.log(`TGA: ${width}x${height}, ${bpp} bpp, topDown=${topDown}`);

    const rgba = Buffer.alloc(width * height * 4);
    const offset = 18;
    const bytesPerPix = bpp / 8;

    for (let y = 0; y < height; y++) {
        const srcY = topDown ? y : (height - 1 - y);
        for (let x = 0; x < width; x++) {
            const srcIdx = offset + (srcY * width + x) * bytesPerPix;
            const dstIdx = (y * width + x) * 4;
            rgba[dstIdx] = buf[srcIdx + 2];     // R
            rgba[dstIdx + 1] = buf[srcIdx + 1]; // G
            rgba[dstIdx + 2] = buf[srcIdx];     // B
            rgba[dstIdx + 3] = bytesPerPix === 4 ? buf[srcIdx + 3] : 255; // A
        }
    }

    const png = encodeRgbaPng(width, height, rgba);
    const outPath = 'C:/Users/samet/.gemini/antigravity/brain/661edf0a-0dba-487c-8c5f-b49446e9b83e/in_game_shot.png';
    await fs.writeFile(outPath, png);
    console.log('Saved to', outPath);
}
convert();

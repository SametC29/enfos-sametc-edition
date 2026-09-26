import { requireDotaPaths } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/paths.js';
import { cloneVmap, vmapToText, textToVmap, compileVmap, buildEntityBlock, insertEntity, maxNodeId } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/vmap.js';
import { parseTileGrid, applyTileGrid, setHeight, setTileset, fill, tileToWorld, vIndex, cIndex } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/tilegrid.js';
import { encodeRgbaPng } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/util/png.js';
import fs from 'node:fs/promises';
import path from 'node:path';

async function buildMasterMap() {
    console.log("==================================================");
    console.log("  BUILDING ENFOS MASTER MIRRORED SURVIVAL MAP   ");
    console.log("==================================================");

    const dota = await requireDotaPaths();
    const contentVmap = path.join(dota.contentDotaAddons, 'enfos_sametc', 'maps', 'enfos.vmap');
    const gameVpk = path.join(dota.gameDotaAddons, 'enfos_sametc', 'maps', 'enfos.vpk');
    const baseTemplate = path.join(dota.contentDotaAddons, 'addon_template', 'maps', 'template_map.vmap');

    // 1. Clone fresh template
    await cloneVmap(baseTemplate, contentVmap);
    let txt = await vmapToText(dota.dmxconvertExe, contentVmap);

    // 2. Set Tileset Themes: Radiant Autumn (Team 1) & Dire Autumn (Team 2)
    // Both tilesets compile cleanly and provide rich autumn foliage, stone roads, and cliffs!
    txt = txt.replaceAll('maps/tilesets/radiant_basic.vmap', 'maps/tilesets/radiant_autumn_basic.vmap');
    txt = txt.replaceAll('maps/tilesets/dire_basic.vmap', 'maps/tilesets/dire_autumn_basic.vmap');

    // 3. Parse and shape the TileGrid
    const g = parseTileGrid(txt);

    // Step A: Base terrain height = 1 (Arena Ground Level)
    // Left arena gets tileset 0 (Radiant Autumn), Right arena gets tileset 1 (Dire Autumn)
    for (let cy = 0; cy < g.height; cy++) {
        for (let cx = 0; cx < g.width; cx++) {
            g.tileset[cIndex(g, cx, cy)] = cx >= 32 ? 1 : 0;
        }
    }
    // Baseline heights
    g.heights.fill(1);

    // Step B: Outer impassable cliff boundaries (Height 3)
    // Outer 4 tiles on all 4 borders
    setHeight(g, { kind: "rect", x0: 0, y0: 0, x1: 64, y1: 3 }, 3);
    setHeight(g, { kind: "rect", x0: 0, y0: 61, x1: 64, y1: 64 }, 3);
    setHeight(g, { kind: "rect", x0: 0, y0: 0, x1: 3, y1: 64 }, 3);
    setHeight(g, { kind: "rect", x0: 61, y0: 0, x1: 64, y1: 64 }, 3);

    // Step C: Towering central dividing mountain (Height 3) between the two arenas: X: 29..35
    setHeight(g, { kind: "rect", x0: 29, y0: 0, x1: 35, y1: 64 }, 3);
    setTileset(g, { kind: "rect", x0: 29, y0: 0, x1: 35, y1: 64 }, 1);

    // Step D: Raised Base Sanctums (Height 2)
    // Goodguys base: X: 11..21, Y: 4..11
    setHeight(g, { kind: "rect", x0: 11, y0: 4, x1: 21, y1: 11 }, 2);
    // Badguys base: X: 43..53, Y: 4..11
    setHeight(g, { kind: "rect", x0: 43, y0: 4, x1: 53, y1: 11 }, 2);

    // Base ramps: smoothly sloping or connecting to arena floor
    // In Dota tilegrid, height 1 is arena floor, height 2 is base platform.
    // Ramp gap at Y: 11..12, X: 15..17 (Goodguys) and X: 47..49 (Badguys)
    setHeight(g, { kind: "rect", x0: 15, y0: 11, x1: 17, y1: 12 }, 1);
    setHeight(g, { kind: "rect", x0: 47, y0: 11, x1: 49, y1: 12 }, 1);

    // Step E: Decorative Central Islands in each arena (Height 2)
    // Goodguys monument island: X: 15..17, Y: 21..23
    setHeight(g, { kind: "rect", x0: 15, y0: 21, x1: 17, y1: 23 }, 2);
    // Badguys monument island: X: 47..49, Y: 21..23
    setHeight(g, { kind: "rect", x0: 47, y0: 21, x1: 49, y1: 23 }, 2);

    // Step F: Distinct paved stone roads for lanes
    // In Radiant Autumn, tileset 1 provides high-contrast stone pavement!
    // In Dire Autumn, tileset 0 provides contrasting road pavement!
    // Goodguys lanes:
    // Left Lane: (8, 56) -> (8, 38) -> (14, 30) -> (14, 18) -> (16, 13)
    setTileset(g, { kind: "path", points: [[8, 56], [8, 38], [14, 30], [14, 18], [16, 13]], width: 3 }, 1);
    // Right Lane: (24, 56) -> (24, 38) -> (18, 30) -> (18, 18) -> (16, 13)
    setTileset(g, { kind: "path", points: [[24, 56], [24, 38], [18, 30], [18, 18], [16, 13]], width: 3 }, 1);
    // Boss Lane: (16, 58) -> (16, 30)
    setTileset(g, { kind: "path", points: [[16, 58], [16, 30]], width: 3 }, 1);
    // Shared Combat Plaza: X: 13..19, Y: 28..32
    setTileset(g, { kind: "rect", x0: 13, y0: 28, x1: 19, y1: 32 }, 1);
    // Base Courtyard: X: 13..19, Y: 6..10
    setTileset(g, { kind: "rect", x0: 13, y0: 6, x1: 19, y1: 10 }, 1);

    // Badguys lanes (Mirrored, using tileset 0 as contrasting road on Dire):
    // Left Lane: (40, 56) -> (40, 38) -> (46, 30) -> (46, 18) -> (48, 13)
    setTileset(g, { kind: "path", points: [[40, 56], [40, 38], [46, 30], [46, 18], [48, 13]], width: 3 }, 0);
    // Right Lane: (56, 56) -> (56, 38) -> (50, 30) -> (50, 18) -> (48, 13)
    setTileset(g, { kind: "path", points: [[56, 56], [56, 38], [50, 30], [50, 18], [48, 13]], width: 3 }, 0);
    // Boss Lane: (48, 58) -> (48, 30)
    setTileset(g, { kind: "path", points: [[48, 58], [48, 30]], width: 3 }, 0);
    // Shared Combat Plaza: X: 45..51, Y: 28..32
    setTileset(g, { kind: "rect", x0: 45, y0: 28, x1: 51, y1: 32 }, 0);
    // Base Courtyard: X: 45..51, Y: 6..10
    setTileset(g, { kind: "rect", x0: 45, y0: 6, x1: 51, y1: 10 }, 0);

    txt = applyTileGrid(txt, g);

    // 4. Update env_global_light with beautiful warm radiant sunlight
    txt = txt.replace(/"color"\s+"string"\s+"[^"]+"/, '"color" "string" "245 220 185 0"');
    txt = txt.replace(/"ambientcolor1"\s+"string"\s+"[^"]+"/, '"ambientcolor1" "string" "105 140 210 0"');
    txt = txt.replace(/"ambientscale1"\s+"string"\s+"[^"]+"/, '"ambientscale1" "string" "2.200000"');
    txt = txt.replace(/"ambientcolor2"\s+"string"\s+"[^"]+"/, '"ambientcolor2" "string" "165 145 115 0"');
    txt = txt.replace(/"ambientscale2"\s+"string"\s+"[^"]+"/, '"ambientscale2" "string" "0.800000"');
    txt = txt.replace(/"specularangles"\s+"string"\s+"[^"]+"/, '"specularangles" "string" "55 315 0"');
    txt = txt.replace(/"specularcolor"\s+"string"\s+"[^"]+"/, '"specularcolor" "string" "255 240 215 0"');
    txt = txt.replace(/"lightscale"\s+"string"\s+"[^"]+"/, '"lightscale" "string" "5.500000"');

    // 5. Place Entities (Spawns, Fountains, Shops, Couriers, Trees, Props)
    let node = maxNodeId(txt);
    function addEnt(classname, origin, properties = {}) {
        txt = insertEntity(txt, buildEntityBlock({ classname, origin, properties }, ++node));
    }

    // World bounds & Minimap boundaries
    addEnt("dota_minimap_boundary", "-8192 -8192 128", {});
    addEnt("dota_minimap_boundary", "8192 8192 128", {});

    // Team Fountains
    addEnt("ent_dota_fountain", "-4096 -6144 260", { teamnumber: "2" });
    addEnt("ent_dota_fountain", "4096 -6144 260", { teamnumber: "3" });

    // Team Shops
    addEnt("ent_dota_shop", "-3700 -6144 260", { shoptype: "0", teamnumber: "2" });
    addEnt("ent_dota_shop", "3700 -6144 260", { shoptype: "0", teamnumber: "3" });

    // Courier Spawns
    addEnt("info_courier_spawn_radiant", "-4300 -6144 260", {});
    addEnt("info_courier_spawn_dire", "4300 -6144 260", {});

    // Player Starts (5 on each elevated base)
    for (let i = 0; i < 5; i++) {
        const offset = (i - 2) * 150;
        addEnt("info_player_start_goodguys", `${-4096 + offset} -6400 260`, {});
        addEnt("info_player_start_badguys", `${4096 + offset} -6400 260`, {});
    }

    // Life Cores (Anchors at the entrance of each base)
    addEnt("info_target", "-4096 -4864 130", { targetname: "path_good_end" });
    addEnt("info_target", "4096 -4864 130", { targetname: "path_bad_end" });

    // Creep Lane Spawners
    // Goodguys arena spawners
    addEnt("info_target", "-6144 6144 130", { targetname: "path_good_left_start" });
    addEnt("info_target", "-2048 6144 130", { targetname: "path_good_right_start" });
    addEnt("info_target", "-4096 6656 130", { targetname: "path_good_boss_start" });
    // Badguys arena spawners
    addEnt("info_target", "2048 6144 130", { targetname: "path_bad_left_start" });
    addEnt("info_target", "6144 6144 130", { targetname: "path_bad_right_start" });
    addEnt("info_target", "4096 6656 130", { targetname: "path_bad_boss_start" });

    // Decorative Columns & Statues at Base & Central Monument
    // Goodguys base portal pillars
    addEnt("prop_static", "-4400 -4864 130", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    addEnt("prop_static", "-3792 -4864 130", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    // Badguys base portal pillars
    addEnt("prop_static", "3792 -4864 130", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    addEnt("prop_static", "4400 -4864 130", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });

    // Central Monument Pillars on the elevated island (X: 16 -> -4096, Y: 22 -> -2560)
    addEnt("prop_static", "-4200 -2560 260", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    addEnt("prop_static", "-3992 -2560 260", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    addEnt("prop_static", "3992 -2560 260", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    addEnt("prop_static", "4200 -2560 260", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });

    // Step G: Place Trees (ent_dota_tree) along cliffs and dividing mountain
    // Dividing mountain trees (X: 31, 32, 33; Y: 4..60 step 2)
    for (let ty = 6; ty <= 58; ty += 3) {
        const [wx1, wy1] = tileToWorld(g, 31, ty);
        const [wx2, wy2] = tileToWorld(g, 33, ty);
        addEnt("ent_dota_tree", `${wx1} ${wy1} 512`, {});
        addEnt("ent_dota_tree", `${wx2} ${wy2} 512`, {});
    }

    // Outer perimeter trees
    for (let tx = 4; tx <= 60; tx += 4) {
        const [wxTop, wyTop] = tileToWorld(g, tx, 62);
        const [wxBot, wyBot] = tileToWorld(g, tx, 2);
        addEnt("ent_dota_tree", `${wxTop} ${wyTop} 512`, {});
        addEnt("ent_dota_tree", `${wxBot} ${wyBot} 512`, {});
    }
    for (let ty = 4; ty <= 60; ty += 4) {
        const [wxLeft, wyLeft] = tileToWorld(g, 2, ty);
        const [wxRight, wyRight] = tileToWorld(g, 62, ty);
        addEnt("ent_dota_tree", `${wxLeft} ${wyLeft} 512`, {});
        addEnt("ent_dota_tree", `${wxRight} ${wyRight} 512`, {});
    }

    // Grove trees between lanes in each arena
    // Goodguys left grove: X: 11..12, Y: 44..48
    for (let gy = 42; gy <= 48; gy += 2) {
        const [wx, wy] = tileToWorld(g, 12, gy);
        addEnt("ent_dota_tree", `${wx} ${wy} 130`, {});
    }
    // Goodguys right grove: X: 20..21, Y: 44..48
    for (let gy = 42; gy <= 48; gy += 2) {
        const [wx, wy] = tileToWorld(g, 20, gy);
        addEnt("ent_dota_tree", `${wx} ${wy} 130`, {});
    }
    // Badguys left grove: X: 44, Y: 42..48
    for (let gy = 42; gy <= 48; gy += 2) {
        const [wx, wy] = tileToWorld(g, 44, gy);
        addEnt("ent_dota_tree", `${wx} ${wy} 130`, {});
    }
    // Badguys right grove: X: 52, Y: 42..48
    for (let gy = 42; gy <= 48; gy += 2) {
        const [wx, wy] = tileToWorld(g, 52, gy);
        addEnt("ent_dota_tree", `${wx} ${wy} 130`, {});
    }

    console.log(`Writing modified vmap with ${node} nodes...`);
    await textToVmap(dota.dmxconvertExe, txt, contentVmap);

    console.log("Compiling master map with resourcecompiler...");
    const res = await compileVmap(dota.resourceCompilerExe, dota.dotaGameDir, contentVmap, gameVpk);
    console.log("Compilation result code:", res.code);
    if (res.code !== 0) {
        console.error("Compile error output:\n", res.stdout.slice(-1500));
        throw new Error("Map compilation failed");
    }

    // ==================================================
    // 6. Generate High-Res 1024x1024 Minimap Overview
    // ==================================================
    console.log("Generating high-res minimap overview (1024x1024)...");
    const px = 16;
    const W = g.width * px; // 64 * 16 = 1024
    const H = g.height * px; // 64 * 16 = 1024
    const img = Buffer.alloc(W * H * 4);

    const put = (x, y, r, gg, b) => {
        const i = (y * W + x) * 4;
        img[i] = r; img[i + 1] = gg; img[i + 2] = b; img[i + 3] = 255;
    };

    for (let cy = 0; cy < g.height; cy++) {
        for (let cx = 0; cx < g.width; cx++) {
            const corners = [
                vIndex(g, cx, cy),
                vIndex(g, cx + 1, cy),
                vIndex(g, cx, cy + 1),
                vIndex(g, cx + 1, cy + 1)
            ];
            const hAvg = corners.reduce((s, i) => s + g.heights[i], 0) / 4;
            const tile = g.tileset[cIndex(g, cx, cy)];
            const isDividingMountain = cx >= 29 && cx <= 35;
            const isBorder = cx <= 3 || cx >= 61 || cy <= 3 || cy >= 61;

            let r, gg, b;
            if (isBorder || isDividingMountain) {
                // Towering mountain rock
                r = 65; gg = 60; b = 55;
            } else if (cx < 32) {
                // Team 1: Radiant Autumn Arena
                if (tile !== 0) {
                    // Paved stone road / plaza / courtyard
                    r = 175; gg = 160; b = 135;
                } else {
                    // Golden-amber autumn meadow
                    r = 165; gg = 120; b = 45;
                }
            } else {
                // Team 2: Dire Autumn Arena
                if (tile === 0) {
                    // Paved dark stone road / plaza / courtyard
                    r = 155; gg = 125; b = 105;
                } else {
                    // Dark gothic autumn earth
                    r = 85; gg = 65; b = 60;
                }
            }

            // Height-based ambient occlusion / elevation highlight
            const shade = 1 + Math.max(-0.35, Math.min(0.55, (hAvg - 1) * 0.22));
            r = Math.min(255, Math.max(0, (r * shade) | 0));
            gg = Math.min(255, Math.max(0, (gg * shade) | 0));
            b = Math.min(255, Math.max(0, (b * shade) | 0));

            // Origin Y is at bottom in Dota world, invert for image top-down
            const oy = (g.height - 1 - cy) * px;
            const ox = cx * px;
            for (let yy = 0; yy < px; yy++) {
                for (let xx = 0; xx < px; xx++) {
                    // Subtle stone border edge shading
                    const edge = (xx === 0 || xx === px - 1 || yy === 0 || yy === px - 1) ? 0.92 : 1.0;
                    put(ox + xx, oy + yy, (r * edge) | 0, (gg * edge) | 0, (b * edge) | 0);
                }
            }
        }
    }

    const png = encodeRgbaPng(W, H, img);
    const contentOverviewPng = path.join(dota.contentDotaAddons, 'enfos_sametc', 'materials', 'overviews', 'enfos.png');
    const contentOverviewTga = path.join(dota.contentDotaAddons, 'enfos_sametc', 'materials', 'overviews', 'enfos.tga');
    const gameOverviewPng = path.join(dota.gameDotaAddons, 'enfos_sametc', 'materials', 'overviews', 'enfos.png');

    await fs.mkdir(path.dirname(contentOverviewPng), { recursive: true });
    await fs.mkdir(path.dirname(gameOverviewPng), { recursive: true });
    await fs.writeFile(contentOverviewPng, png);
    await fs.writeFile(gameOverviewPng, png);
    console.log("Minimap overview PNG saved:", contentOverviewPng);

    // Write Overview TXT with exact world alignment (-8192..8192 -> 16384u, scale 16.0)
    const overviewTxt = `"enfos"\n{\n\t"material"\t"materials/overviews/enfos.vmat"\n\t"pos_x"\t"-8192"\n\t"pos_y"\t"8192"\n\t"scale"\t"16.0"\n}\n`;

    const repoOverviewTxt = path.join(process.cwd(), 'game', 'resource', 'overviews', 'enfos.txt');
    const gameOverviewTxt = path.join(dota.gameDotaAddons, 'enfos_sametc', 'resource', 'overviews', 'enfos.txt');
    const rootDotaOverviewTxt = path.join(dota.dotaGameDir, 'dota', 'resource', 'overviews', 'enfos.txt');

    await fs.mkdir(path.dirname(repoOverviewTxt), { recursive: true });
    await fs.mkdir(path.dirname(gameOverviewTxt), { recursive: true });
    await fs.mkdir(path.dirname(rootDotaOverviewTxt), { recursive: true });

    await fs.writeFile(repoOverviewTxt, overviewTxt, 'utf8');
    await fs.writeFile(gameOverviewTxt, overviewTxt, 'utf8');
    await fs.writeFile(rootDotaOverviewTxt, overviewTxt, 'utf8');
    console.log("Minimap overview TXT deployed with 1:1 world alignment (scale 16.0).");

    // Recompile materials/overviews/enfos.vmat
    const contentVmat = path.join(dota.contentDotaAddons, 'enfos_sametc', 'materials', 'overviews', 'enfos.vmat');
    const gameVmat = path.join(dota.gameDotaAddons, 'enfos_sametc', 'materials', 'overviews', 'enfos.vmat_c');
    const vmatRes = await compileVmap(dota.resourceCompilerExe, dota.dotaGameDir, contentVmat, gameVmat);
    console.log("Overview VMAT compilation result:", vmatRes.code);

    console.log("==================================================");
    console.log("  SUCCESS! Master map & overview built completely!");
    console.log("==================================================");
}

buildMasterMap().catch(err => {
    console.error("FATAL ERROR:", err);
    process.exit(1);
});

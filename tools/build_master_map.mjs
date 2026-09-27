// tools/build_master_map.mjs
// Generates, builds, compiles, and renders the master Enfos map:
// - Authentic Enfos coordinate layout: Radiant centered at X = -3712, Dire at X = +3712.
// - 100% FLAT, continuous, walkable playing field (Height 1 / Z = 128) across base, lanes, and combat plazas.
// - ZERO isolated cliff traps or impassable plateaus.
// - Towering central dividing mountain (Height 3) between Radiant and Dire.
// - Outer impassable perimeter mountain barriers (Height 3).
// - Paved stone roads for Left, Center Boss, and Right lanes in each arena.
// - Authentic Enfos spawn points, fountains, shops, and lane waypoints.
// - 1024x1024 sharp minimap overview with 1:1 world alignment.

import { requireDotaPaths } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/paths.js';
import { cloneVmap, vmapToText, textToVmap, compileVmap, buildEntityBlock, insertEntity, maxNodeId } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/vmap.js';
import { parseTileGrid, applyTileGrid, setHeight, setTileset, fill, tileToWorld, vIndex, cIndex } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/tilegrid.js';
import { encodeRgbaPng } from 'file:///C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/util/png.js';
import fs from 'node:fs/promises';
import path from 'node:path';

if (!process.argv.includes('--allow-placeholder-map')) {
    throw new Error('This generator replaces the playable Survival map with an old flat prototype. Use --allow-placeholder-map only for an intentional isolated prototype build.');
}

async function buildMasterMap() {
    console.log("=== Building Authentic Enfos Master Map (Flat Walkable Arenas + Autumn Theme) ===");

    const dota = await requireDotaPaths();
    const contentVmap = path.join(dota.contentDotaAddons, 'enfos_sametc', 'maps', 'enfos.vmap');
    const gameVpk = path.join(dota.gameDotaAddons, 'enfos_sametc', 'maps', 'enfos.vpk');

    const baseTemplate = path.join(dota.contentDotaAddons, 'addon_template', 'maps', 'template_map.vmap');
    await cloneVmap(baseTemplate, contentVmap);
    let txt = await vmapToText(dota.dmxconvertExe, contentVmap);

    // 2. Set Tilesets:
    // Tileset 0: Radiant Autumn (rich golden amber autumn foliage & light stone roads)
    // Tileset 1: Dire Autumn (dark slate corrupted earth & dark paved roads)
    txt = txt.replaceAll('maps/tilesets/radiant_basic.vmap', 'maps/tilesets/radiant_autumn_basic.vmap');
    txt = txt.replaceAll('maps/tilesets/dire_basic.vmap', 'maps/tilesets/dire_autumn_basic.vmap');

    // 3. Parse and shape the TileGrid
    const g = parseTileGrid(txt);

    // Step A: Base terrain height = 1 across the ENTIRE arena floor (Z = 128)
    // 100% FLAT AND WALKABLE - No cliffs or hills between base, shop, and lanes!
    fill(g.heights, 1);
    fill(g.water, 0);

    // Base tilesets: Left arena = Tileset 0 (Radiant), Right arena = Tileset 1 (Dire)
    for (let cy = 0; cy < 64; cy++) {
        for (let cx = 0; cx < 32; cx++) {
            g.tileset[cIndex(g, cx, cy)] = 0;
        }
        for (let cx = 32; cx < 64; cx++) {
            g.tileset[cIndex(g, cx, cy)] = 1;
        }
    }

    // Step B: Outer impassable cliff boundaries (Height 3 / Z = 384)
    // 4 tiles around all outer borders
    setHeight(g, { kind: "rect", x0: 0, y0: 0, x1: 64, y1: 3 }, 3);
    setHeight(g, { kind: "rect", x0: 0, y0: 61, x1: 64, y1: 64 }, 3);
    setHeight(g, { kind: "rect", x0: 0, y0: 0, x1: 3, y1: 64 }, 3);
    setHeight(g, { kind: "rect", x0: 61, y0: 0, x1: 64, y1: 64 }, 3);

    // Step C: Towering central dividing mountain (Height 3 / Z = 384)
    // Between X: 29 and X: 35 (World X: -768 to +768)
    setHeight(g, { kind: "rect", x0: 29, y0: 0, x1: 35, y1: 64 }, 3);
    setTileset(g, { kind: "rect", x0: 29, y0: 0, x1: 35, y1: 64 }, 1);

    // Step D: Distinct paved stone roads for the 3 lanes in each arena
    // In Radiant (Tileset 0 base), Tileset 1 provides high-contrast stone road:
    // Base courtyard: around tile (17, 19) -> World (-3712, -3200)
    setTileset(g, { kind: "rect", x0: 15, y0: 16, x1: 20, y1: 24 }, 1);
    // Left Lane road: (17, 24) -> (11, 34) -> (11, 52)
    setTileset(g, { kind: "path", points: [[17, 24], [11, 34], [11, 52]], width: 3 }, 1);
    // Center Boss Lane road: (17, 24) -> (17, 52)
    setTileset(g, { kind: "path", points: [[17, 24], [17, 52]], width: 3 }, 1);
    // Right Lane road: (17, 24) -> (24, 34) -> (24, 52)
    setTileset(g, { kind: "path", points: [[17, 24], [24, 34], [24, 52]], width: 3 }, 1);
    // Mid combat plaza: X: 14..21, Y: 34..38
    setTileset(g, { kind: "rect", x0: 14, y0: 34, x1: 21, y1: 38 }, 1);

    // In Dire (Tileset 1 base), Tileset 0 provides high-contrast dark stone road:
    // Base courtyard: around tile (47, 19) -> World (+3712, -3200)
    setTileset(g, { kind: "rect", x0: 44, y0: 16, x1: 49, y1: 24 }, 0);
    // Left Lane road: (47, 24) -> (40, 34) -> (40, 52)
    setTileset(g, { kind: "path", points: [[47, 24], [40, 34], [40, 52]], width: 3 }, 0);
    // Center Boss Lane road: (47, 24) -> (47, 52)
    setTileset(g, { kind: "path", points: [[47, 24], [47, 52]], width: 3 }, 0);
    // Right Lane road: (47, 24) -> (53, 34) -> (53, 52)
    setTileset(g, { kind: "path", points: [[47, 24], [53, 34], [53, 52]], width: 3 }, 0);
    // Mid combat plaza: X: 43..50, Y: 34..38
    setTileset(g, { kind: "rect", x0: 43, y0: 34, x1: 50, y1: 38 }, 0);

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

    // 5. Place Entities (Exact Authentic Enfos Coordinates on Flat Floor Z = 128)
    let node = maxNodeId(txt);
    function addEnt(classname, origin, properties = {}) {
        txt = insertEntity(txt, buildEntityBlock({ classname, origin, properties }, ++node));
    }

    // Minimap boundaries
    addEnt("dota_minimap_boundary", "-8192 -8192 128", {});
    addEnt("dota_minimap_boundary", "8192 8192 128", {});

    // --- Goodguys (Radiant Arena, centered at X = -3712) ---
    // Fountain
    addEnt("ent_dota_fountain", "-3712 -3600 128", { teamnumber: "2" });
    // Home Shop
    addEnt("ent_dota_shop", "-3712 -2600 128", { shoptype: "0", teamnumber: "2" });
    // Courier Spawn
    addEnt("info_courier_spawn_radiant", "-3850 -3200 128", {});
    // Player Starts (5 players on flat courtyard floor)
    for (let i = 0; i < 5; i++) {
        const offset = (i - 2) * 120;
        addEnt("info_player_start_goodguys", `${-3712 + offset} -3200 128`, { angles: "0 90 0" });
    }
    // Base Life Core / Creep Goal Anchor
    addEnt("info_target", "-3712 -2400 128", { targetname: "path_good_end" });

    // Creep Lane Spawners (Y = 5120)
    addEnt("info_target", "-5504 5120 128", { targetname: "path_good_left_start" });
    addEnt("info_target", "-3712 5120 128", { targetname: "path_good_boss_start" });
    addEnt("info_target", "-1920 5120 128", { targetname: "path_good_right_start" });

    // Base decorative columns
    addEnt("prop_static", "-4050 -2600 128", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    addEnt("prop_static", "-3374 -2600 128", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });

    // --- Badguys (Dire Arena, centered at X = +3712) ---
    // Fountain
    addEnt("ent_dota_fountain", "3712 -3600 128", { teamnumber: "3" });
    // Home Shop
    addEnt("ent_dota_shop", "3712 -2600 128", { shoptype: "0", teamnumber: "3" });
    // Courier Spawn
    addEnt("info_courier_spawn_dire", "3850 -3200 128", {});
    // Player Starts (5 players on flat courtyard floor)
    for (let i = 0; i < 5; i++) {
        const offset = (i - 2) * 120;
        addEnt("info_player_start_badguys", `${3712 + offset} -3200 128`, { angles: "0 90 0" });
    }
    // Base Life Core / Creep Goal Anchor
    addEnt("info_target", "3712 -2400 128", { targetname: "path_bad_end" });

    // Creep Lane Spawners (Y = 5120)
    addEnt("info_target", "1920 5120 128", { targetname: "path_bad_left_start" });
    addEnt("info_target", "3712 5120 128", { targetname: "path_bad_boss_start" });
    addEnt("info_target", "5504 5120 128", { targetname: "path_bad_right_start" });

    // Base decorative columns
    addEnt("prop_static", "3374 -2600 128", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });
    addEnt("prop_static", "4050 -2600 128", { model: "models/props_stone/column/classical_column001.vmdl", solid: "6" });

    // Dividing mountain trees (X: 31, 32, 33; Y: 4..60 step 3)
    for (let ty = 6; ty <= 58; ty += 3) {
        const [wx1, wy1] = tileToWorld(g, 31, ty);
        const [wx2, wy2] = tileToWorld(g, 33, ty);
        addEnt("ent_dota_tree", `${wx1} ${wy1} 384`, {});
        addEnt("ent_dota_tree", `${wx2} ${wy2} 384`, {});
    }

    // Outer perimeter trees
    for (let tx = 4; tx <= 60; tx += 4) {
        const [wxTop, wyTop] = tileToWorld(g, tx, 62);
        const [wxBot, wyBot] = tileToWorld(g, tx, 2);
        addEnt("ent_dota_tree", `${wxTop} ${wyTop} 384`, {});
        addEnt("ent_dota_tree", `${wxBot} ${wyBot} 384`, {});
    }
    for (let ty = 4; ty <= 60; ty += 4) {
        const [wxLeft, wyLeft] = tileToWorld(g, 2, ty);
        const [wxRight, wyRight] = tileToWorld(g, 62, ty);
        addEnt("ent_dota_tree", `${wxLeft} ${wyLeft} 384`, {});
        addEnt("ent_dota_tree", `${wxRight} ${wyRight} 384`, {});
    }

    console.log(`Writing modified vmap with ${node} nodes...`);
    await textToVmap(dota.dmxconvertExe, txt, contentVmap);

    // Also replicate as enfos_sametc.vmap
    const sametcContentVmap = path.join(dota.contentDotaAddons, 'enfos_sametc', 'maps', 'enfos_sametc.vmap');
    await fs.copyFile(contentVmap, sametcContentVmap);

    // Copy to repository content directory
    const repoContentVmap = path.join(process.cwd(), 'content', 'maps', 'enfos.vmap');
    const repoSametcVmap = path.join(process.cwd(), 'content', 'maps', 'enfos_sametc.vmap');
    await fs.copyFile(contentVmap, repoContentVmap);
    await fs.copyFile(contentVmap, repoSametcVmap);

    console.log("Compiling master map with resourcecompiler...");
    const res = await compileVmap(dota.resourceCompilerExe, dota.dotaGameDir, contentVmap, gameVpk);
    console.log("Compilation result code:", res.code);
    if (res.code !== 0) {
        console.error("Compile error output:\n", res.stdout.slice(-1500));
        throw new Error("Map compilation failed");
    }

    // Copy compiled game vpk to enfos_sametc.vpk and repo game/maps
    const sametcGameVpk = path.join(dota.gameDotaAddons, 'enfos_sametc', 'maps', 'enfos_sametc.vpk');
    await fs.copyFile(gameVpk, sametcGameVpk);

    const repoGameVpk = path.join(process.cwd(), 'game', 'maps', 'enfos.vpk');
    const repoSametcGameVpk = path.join(process.cwd(), 'game', 'maps', 'enfos_sametc.vpk');
    await fs.mkdir(path.dirname(repoGameVpk), { recursive: true });
    await fs.copyFile(gameVpk, repoGameVpk);
    await fs.copyFile(gameVpk, repoSametcGameVpk);

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
                    const edge = (xx === 0 || xx === px - 1 || yy === 0 || yy === px - 1) ? 0.92 : 1.0;
                    put(ox + xx, oy + yy, (r * edge) | 0, (gg * edge) | 0, (b * edge) | 0);
                }
            }
        }
    }

    const png = encodeRgbaPng(W, H, img);
    const contentOverviewPng = path.join(dota.contentDotaAddons, 'enfos_sametc', 'materials', 'overviews', 'enfos.png');
    const gameOverviewPng = path.join(dota.gameDotaAddons, 'enfos_sametc', 'materials', 'overviews', 'enfos.png');
    const repoContentOverviewPng = path.join(process.cwd(), 'content', 'materials', 'overviews', 'enfos.png');
    const repoGameOveriewPng = path.join(process.cwd(), 'game', 'materials', 'overviews', 'enfos.png');

    await fs.mkdir(path.dirname(contentOverviewPng), { recursive: true });
    await fs.mkdir(path.dirname(gameOverviewPng), { recursive: true });
    await fs.mkdir(path.dirname(repoContentOverviewPng), { recursive: true });
    await fs.mkdir(path.dirname(repoGameOveriewPng), { recursive: true });

    await fs.writeFile(contentOverviewPng, png);
    await fs.writeFile(gameOverviewPng, png);
    await fs.writeFile(repoContentOverviewPng, png);
    await fs.writeFile(repoGameOveriewPng, png);
    console.log("Minimap overview PNG saved and synced across all directories.");

    // Write Overview TXT with exact world alignment (-8192..8192 -> 16384u, scale 16.0)
    const overviewTxt = `"enfos"\n{\n\t"material"\t"materials/overviews/enfos.vmat"\n\t"pos_x"\t"-8192"\n\t"pos_y"\t"8192"\n\t"scale"\t"16.0"\n}\n`;

    const repoOverviewTxt = path.join(process.cwd(), 'game', 'resource', 'overviews', 'enfos.txt');
    const repoSametcOverviewTxt = path.join(process.cwd(), 'game', 'resource', 'overviews', 'enfos_sametc.txt');
    const gameOverviewTxt = path.join(dota.gameDotaAddons, 'enfos_sametc', 'resource', 'overviews', 'enfos.txt');
    const rootDotaOverviewTxt = path.join(dota.dotaGameDir, 'dota', 'resource', 'overviews', 'enfos.txt');

    await fs.mkdir(path.dirname(repoOverviewTxt), { recursive: true });
    await fs.mkdir(path.dirname(gameOverviewTxt), { recursive: true });
    await fs.mkdir(path.dirname(rootDotaOverviewTxt), { recursive: true });

    await fs.writeFile(repoOverviewTxt, overviewTxt, 'utf8');
    await fs.writeFile(repoSametcOverviewTxt, overviewTxt, 'utf8');
    await fs.writeFile(gameOverviewTxt, overviewTxt, 'utf8');
    await fs.writeFile(rootDotaOverviewTxt, overviewTxt, 'utf8');

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

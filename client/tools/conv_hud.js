// FV-NG — HUD asset pipeline (Track A / milestone M-HUD-0).
//
// Converts the original Farmville HUD assets into runtime scenes + bitmaps the Canvas2D client
// renders without Flash:
//   * per-world HUD skin SWFs  (hud/hudSkin_*.swf)     -> fvng/hud/hudskin_<world>.scene.json
//   * separate HUD widget SWFs (coin/water meters, home, search, message, stats, travel, ...)
//   * embedded HUD art in FarmGame.swf (action-menu icons, currency/fuel, home/message buttons,
//     gift/storage/search icons, multi-contextual backgrounds, ...) -> fvng/hud/embed/<name>.png
//   * HUD PNGs from the asset set (level sign, XP bar) -> fvng/hud/embed/<name>.png
//   * a manifest fvng/hud/hud.json (skin/widget symbol tables + embed index + layout constants).
//
// Usage:
//   node conv_hud.js                 # convert scenes + copy embedded art (extracts via FFdec if needed)
//   node conv_hud.js --force         # re-run FFdec extraction and reconvert all scenes
//   node conv_hud.js --embed-only    # only extract/copy the embedded art
//
// Outputs (deployed + a copy of the manifest under client/web for tests/dev):
//   <webroot>/farmville/fvng/hud/*.scene.json
//   <webroot>/farmville/fvng/hud/embed/*.png
//   <webroot>/farmville/fvng/hud/hud.json
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const { parseSwf } = require('swf-parser');
const { swfToScene } = require('./swf2scene.js');

const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets';
const FVNG = 'C:/Farmville/xampp/htdocs/public/farmville/fvng';
const OUT = path.join(FVNG, 'hud');
const EMBED_OUT = path.join(OUT, 'embed');
const DEV = 'C:/Users/Remote/Desktop/FV-NG/client/web';
const HASH = 'C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json';
const FARM_SWF = 'C:/Farmville/xampp/htdocs/public/farmville/embeds/Flash/v855037.855026/FarmGame.855037.855026.swf';
const EMBED_CACHE = 'C:/Users/Remote/Desktop/FV-NG/build/hud_embed_export';
const DECOMP_CLASSES = 'C:/Users/Remote/Desktop/FV-NG/decompiled/farmgame/scripts/Classes';
const FFDEC = 'C:/Program Files (x86)/FFdec/ffdec.jar';

const FORCE = process.argv.includes('--force');
const EMBED_ONLY = process.argv.includes('--embed-only');

const hash = JSON.parse(fs.readFileSync(HASH, 'utf8'));

// asset path ("hud/hudSkin_Chat.swf" | "dialogs/Angler/zoom_Angler.swf") -> hashed SWF/PNG file
function resolveAsset(rel) {
  const slash = rel.indexOf('/');
  const cat = rel.slice(0, slash), key = rel.slice(slash + 1);
  const h = hash[cat] && hash[cat][key];
  return h ? path.join(ASSETS, cat, h + path.extname(rel)) : null;
}

// ---- HUD widget scenes (separate SWFs) ----
const WIDGETS = [
  { key: 'coin_meter', asset: 'hud/coin_HUD_Meter.swf', stem: 'hud_coin_meter' },
  { key: 'water_meter', asset: 'hud/water_HUD_Meter.swf', stem: 'hud_water_meter' },
  { key: 'search_bar', asset: 'hud/FV_SearchBar.swf', stem: 'hud_search_bar' },
  { key: 'home', asset: 'hud/FV_TackleBoxHomeHUD.swf', stem: 'hud_home' },
  { key: 'zoom', asset: 'dialogs/Angler/zoom_Angler.swf', stem: 'hud_zoom' },
  { key: 'message', asset: 'hud/FV_Message.swf', stem: 'hud_message' },
  { key: 'message_center', asset: 'hud/social/FV_Message_Center_lrg.swf', stem: 'hud_message_center' },
  { key: 'animation_toggle', asset: 'hud/animation_toggle.swf', stem: 'hud_animation_toggle' },
  { key: 'stats_friends', asset: 'hud/Status_Shelf/FV_statsFriends.swf', stem: 'hud_stats_friends' },
  { key: 'stats_tray', asset: 'hud/Status_Shelf/FV_statsTray.swf', stem: 'hud_stats_tray' },
  { key: 'travel_dropdown', asset: 'hud/TravelDropdown_Default.swf', stem: 'hud_travel_dropdown' },
  { key: 'add_coins', asset: 'hud/FV_addCoins_bt.swf', stem: 'hud_add_coins' },
  { key: 'cash_icon', asset: 'hud/FV_Cash_Icon.swf', stem: 'hud_cash_icon' },
];

// ---- HUD PNGs already in the asset set (no SWF conversion) ----
const EMBED_PNGS = [
  'hud/FV_Main_LevelSign_loaded.png',
  'hud/FV_XP_WhiteBar_loaded.png',
];

// ---- EmbeddedArt names (in FarmGame.swf) needed by the HUD ----
// Matched against `Classes.EmbeddedArt_<name>`; the class -> /_assets file mapping comes from the
// decompiled `[Embed(source=...)]` metadata (some embeds have no class name, e.g. 601.png).
const EMBED_RE = /Classes\.EmbeddedArt_(hud_act_|hud_|FV_Cash_Icon|FV_Main_Fuel_|FV_Home_Button_|FV_Message_|FV_Fertilizer|bouncing_arrow|emptyAvatar|multi_contextual_background_|questProgressBar|hud_contextual_arrow|plot_plowed|plot_withered)/;

function run(cmd, args) {
  const r = cp.spawnSync(cmd, args, { stdio: 'inherit' });
  return r.status === 0;
}

function extractEmbed() {
  if (FORCE && fs.existsSync(EMBED_CACHE)) fs.rmSync(EMBED_CACHE, { recursive: true, force: true });
  const imgDir = path.join(EMBED_CACHE, 'images');
  const done = fs.existsSync(EMBED_CACHE) &&
    ((fs.existsSync(imgDir) && fs.readdirSync(imgDir).some(f => f.endsWith('.png'))) ||
      fs.readdirSync(EMBED_CACHE).some(f => f.endsWith('.png'))) &&
    fs.existsSync(path.join(EMBED_CACHE, 'fonts'));
  if (done) return true;
  fs.mkdirSync(EMBED_CACHE, { recursive: true });
  console.log('==> extracting FarmGame.swf embedded art + fonts via FFdec');
  const ok = run('java', ['-Xmx4g', '-jar', FFDEC, '-format', 'image:png,font:ttf', '-exportembed',
    '-onerror', 'ignore', '-export', 'image,font', EMBED_CACHE, FARM_SWF]);
  if (!ok) throw new Error('FFdec export failed');
  return true;
}

// Merkin (title) + Merkin2 (resources/level/xp) — HUDFonts.as. Exported TTF is served directly.
function copyFonts() {
  const fonts = {};
  const dir = path.join(OUT, 'fonts');
  fs.mkdirSync(dir, { recursive: true });
  const src = path.join(EMBED_CACHE, 'fonts');
  for (const f of (fs.existsSync(src) ? fs.readdirSync(src) : [])) {
    if (!f.endsWith('.ttf')) continue;
    let name = null;
    if (/_Merkin2\.ttf$/.test(f)) name = 'Merkin2';
    else if (/_Merkin\.ttf$/.test(f)) name = 'Merkin';
    if (!name) continue;
    fs.copyFileSync(path.join(src, f), path.join(dir, name + '.ttf'));
    fonts[name] = 'hud/fonts/' + name + '.ttf';
  }
  return fonts;
}

function copyEmbed() {
  fs.mkdirSync(EMBED_OUT, { recursive: true });
  const embed = {};
  // map: EmbeddedArt class suffix -> /_assets source basename (from the decompiled [Embed] metadata)
  const classMap = {};
  for (const f of fs.readdirSync(DECOMP_CLASSES)) {
    if (!/^EmbeddedArt_.+\.as$/.test(f)) continue;
    const cls = f.replace(/\.as$/, '').replace(/^EmbeddedArt_/, '');
    if (!EMBED_RE.test('Classes.EmbeddedArt_' + cls)) continue;
    const m = fs.readFileSync(path.join(DECOMP_CLASSES, f), 'utf8').match(/\[Embed\(source="\/_assets\/([^"]+)"\)\]/);
    if (m) classMap[cls] = path.basename(m[1]);
  }
  // 1) copy the extracted embedded bitmaps under their class name
  const imgDir = fs.existsSync(path.join(EMBED_CACHE, 'images')) ? path.join(EMBED_CACHE, 'images') : EMBED_CACHE;
  for (const cls of Object.keys(classMap)) {
    const src = path.join(imgDir, classMap[cls]);
    if (!fs.existsSync(src)) continue;
    fs.copyFileSync(src, path.join(EMBED_OUT, cls + '.png'));
    embed[cls] = 'hud/embed/' + cls + '.png';
  }
  // 2) HUD PNGs already in the asset set
  for (const rel of EMBED_PNGS) {
    const src = resolveAsset(rel);
    if (!src || !fs.existsSync(src)) continue;
    const file = path.basename(rel);
    const key = file.replace(/\.png$/i, '');
    fs.copyFileSync(src, path.join(EMBED_OUT, file));
    embed[key] = 'hud/embed/' + file;
  }
  return embed;
}

function convertScenes() {
  fs.mkdirSync(OUT, { recursive: true });
  const skins = {}, scenes = {};
  const seen = new Set();

  const convert = (srcFile, stem, bucket, key) => {
    if (!srcFile || !fs.existsSync(srcFile)) { console.log('  !! missing asset for ' + key + ' -> ' + srcFile); return null; }
    const outFile = path.join(OUT, stem + '.scene.json');
    let scene;
    if (fs.existsSync(outFile) && !FORCE) {
      scene = JSON.parse(fs.readFileSync(outFile, 'utf8'));
    } else {
      scene = swfToScene(parseSwf(fs.readFileSync(srcFile)), { source: path.basename(srcFile) });
      fs.writeFileSync(outFile, JSON.stringify(scene));
    }
    const entry = { scene: 'hud/' + stem, symbols: Object.keys(scene.exports).sort(), source: path.basename(srcFile) };
    bucket[key] = entry;
    return scene;
  };

  // per-world skins
  const hudCat = hash.hud || {};
  for (const fn of Object.keys(hudCat).filter(n => /^hudSkin_.+\.swf$/i.test(n))) {
    const world = fn.replace(/^hudSkin_/i, '').replace(/\.swf$/i, '');
    const stem = 'hudskin_' + world.replace(/[^A-Za-z0-9]+/g, '').toLowerCase();
    if (seen.has(stem)) continue;
    seen.add(stem);
    convert(path.join(ASSETS, 'hud', hudCat[fn] + '.swf'), stem, skins, world);
  }

  // HUD widget scenes
  for (const w of WIDGETS) convert(resolveAsset(w.asset), w.stem, scenes, w.key);

  return { skins, scenes };
}

// ---- main ----
if (!EMBED_ONLY) {
  const { skins, scenes } = convertScenes();
  const embed = (extractEmbed() && copyEmbed()) || {};
  const fonts = copyFonts();
  const manifest = {
    generated: new Date().toISOString(),
    layout: { DEFAULT_WIDTH: 760, DEFAULT_HEIGHT: 590, STAGE_W: 1018, STAGE_H: 600 },
    skins, scenes, embed, fonts,
  };
  fs.writeFileSync(path.join(OUT, 'hud.json'), JSON.stringify(manifest));
  fs.mkdirSync(DEV, { recursive: true });
  fs.writeFileSync(path.join(DEV, 'hud.json'), JSON.stringify(manifest));
  console.log(JSON.stringify({
    skins: Object.keys(skins).length, scenes: Object.keys(scenes).length,
    embed: Object.keys(embed).length, fonts: Object.keys(fonts).length,
  }, null, 1));
} else {
  const embed = (extractEmbed() && copyEmbed()) || {};
  const fonts = copyFonts();
  console.log(JSON.stringify({ embed: Object.keys(embed).length, fonts: Object.keys(fonts).length }, null, 1));
}

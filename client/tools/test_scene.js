#!/usr/bin/env node
// FV-NG — scene pipeline tests (Track A / M1). Verifies the SWF->scene exporter + runtime renderer
// model: matrix math, shape flattening, and conversion of real assets (shapes, sprites, bitmaps,
// symbol exports). Exit 0 = pass.
'use strict';
const fs = require('fs');
const path = require('path');
const { parseSwf } = require('swf-parser');
const { swfToScene, flattenShape } = require('./swf2scene.js');
const { sceneToSvg } = require('./scene2svg.js');
const { mul, IDENT } = require('../web/scene2d.js');

let passed = 0; const fails = [];
function ok(name, cond, detail) { if (cond) { passed++; console.log('  PASS  ' + name); } else { fails.push(name + (detail ? ' [' + detail + ']' : '')); console.log('  FAIL  ' + name + (detail ? ' [' + detail + ']' : '')); } }

const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets';
const CROP = path.join(ASSETS, 'crops', 'e24433553d1dadf6ce1825878d238a7e.swf');
const DECOR_DIR = path.join(ASSETS, 'decorations');

function approx(a, b) { return Math.abs(a - b) < 1e-6; }

console.log('== matrix math ==');
ok('mul(IDENT, M) == M', JSON.stringify(mul(IDENT, [2, 0, 0, 3, 5, 7])) === JSON.stringify([2, 0, 0, 3, 5, 7]));
// parent translate (10,20) * child translate (5,5) => (15,25)
const t = mul([1, 0, 0, 1, 10, 20], [1, 0, 0, 1, 5, 5]);
ok('translate compose', approx(t[4], 15) && approx(t[5], 25), t.join(','));

console.log('== shape flattening ==');
const square = {
  initialStyles: { fill: [{ color: { r: 255, g: 0, b: 0, a: 255 } }], line: [] },
  records: [
    { type: 1, moveTo: { x: 0, y: 0 }, rightFill: 1 },
    { type: 0, delta: { x: 200, y: 0 } }, { type: 0, delta: { x: 0, y: 200 } },
    { type: 0, delta: { x: -200, y: 0 } }, { type: 0, delta: { x: 0, y: -200 } },
  ],
};
const prims = flattenShape(square);
ok('square -> 1 primitive', prims.length === 1, 'n=' + prims.length);
ok('square fill is solid red', prims[0] && prims[0].fill && prims[0].fill.kind === 'solid' && prims[0].fill.color === '#ff0000', prims[0] && JSON.stringify(prims[0].fill));
ok('square has M + 4 edges (twips/20)', prims[0] && prims[0].d.length === 5 && prims[0].d[1][1] === 10 && prims[0].d[2][2] === 10, JSON.stringify(prims[0] && prims[0].d));

console.log('== gradient fill descriptor ==');
const gradShape = {
  initialStyles: {
    fill: [{ type: 2, matrix: { scaleX: { epsilons: 65536 }, scaleY: { epsilons: 65536 }, rotateSkew0: { epsilons: 0 }, rotateSkew1: { epsilons: 0 }, translateX: 0, translateY: 0 },
      gradient: { spread: 0, colorSpace: 0, colors: [{ ratio: 0, color: { r: 255, g: 0, b: 0, a: 255 } }, { ratio: 255, color: { r: 0, g: 0, b: 255, a: 128 } }] } }],
    line: [],
  },
  records: [{ type: 1, moveTo: { x: 0, y: 0 }, rightFill: 1 }, { type: 0, delta: { x: 200, y: 0 } }, { type: 0, delta: { x: 0, y: 200 } }, { type: 0, delta: { x: -200, y: 0 } }, { type: 0, delta: { x: 0, y: -200 } }],
};
const gprim = flattenShape(gradShape)[0];
ok('gradient fill -> kind grad', gprim && gprim.fill && gprim.fill.kind === 'grad' && gprim.fill.gt === 'linear', JSON.stringify(gprim && gprim.fill && gprim.fill.gt));
ok('gradient has 2 stops with alpha', gprim && gprim.fill.stops.length === 2 && Math.abs(gprim.fill.stops[1].alpha - 128 / 255) < 1e-6, JSON.stringify(gprim && gprim.fill.stops));

console.log('== real asset: crop SWF ==');
if (fs.existsSync(CROP)) {
  const scene = swfToScene(parseSwf(fs.readFileSync(CROP)), {});
  const kinds = {}; for (const id in scene.characters) { const c = scene.characters[id]; kinds[c.type] = (kinds[c.type] || 0) + 1; }
  ok('crop has shapes', (kinds.shape || 0) > 0, JSON.stringify(kinds));
  ok('crop has sprites', (kinds.sprite || 0) > 0);
  ok('crop has bitmaps', (kinds.bitmap || 0) > 0);
  const bmpErr = Object.values(scene.characters).filter(c => c.type === 'bitmap' && c.error).length;
  ok('crop bitmaps all decode', bmpErr === 0, 'errors=' + bmpErr);
  const { stats } = sceneToSvg(scene, 0);
  ok('crop renders vector prims', stats.paths > 0, 'paths=' + stats.paths);
} else ok('crop fixture exists', false, CROP);

console.log('== real assets: decorations (symbol libraries) ==');
if (fs.existsSync(DECOR_DIR)) {
  const files = fs.readdirSync(DECOR_DIR).filter(f => f.endsWith('.swf')).slice(0, 30);
  let conv = 0, withExport = 0, rendered = 0, withImage = 0;
  for (const f of files) {
    try {
      const scene = swfToScene(parseSwf(fs.readFileSync(path.join(DECOR_DIR, f))), {});
      conv++;
      if (Object.keys(scene.exports).length) withExport++;
      const { stats } = sceneToSvg(scene, 0);
      if (stats.paths + stats.images > 0) rendered++;
      if (stats.images > 0) withImage++;
    } catch (e) { /* counted as not converted */ }
  }
  ok('all decorations convert', conv === files.length, conv + '/' + files.length);
  ok('decorations mostly expose symbols', withExport >= Math.ceil(files.length * 0.6), withExport + '/' + files.length + ' (rest render via root timeline)');
  ok('all decorations render', rendered === files.length, rendered + '/' + files.length);
  ok('bitmap decorations render images', withImage > 0, withImage + ' with images');
} else ok('decorations dir exists', false, DECOR_DIR);

console.log('== dynamic text (DefineEditText) ==');
{
  const hudDir = path.join(ASSETS, 'hud');
  let textScene = null;
  if (fs.existsSync(hudDir)) {
    for (const f of fs.readdirSync(hudDir).filter(x => x.endsWith('.swf')).slice(0, 120)) {
      try { const s = swfToScene(parseSwf(fs.readFileSync(path.join(hudDir, f))), {}); if (Object.values(s.characters).some(c => c.type === 'text' && c.text)) { textScene = s; break; } } catch (e) {}
    }
  }
  ok('a HUD asset has a text character', !!textScene);
  if (textScene) {
    const t = Object.values(textScene.characters).find(c => c.type === 'text' && c.text);
    ok('text char has bounds+size', !!t.bounds && t.fontSize > 0, 'size=' + t.fontSize);
    const synth = { characters: { 1: t }, fonts: textScene.fonts, exports: {}, meta: { frameRate: 24 }, frames: [[{ depth: 1, char: 1, m: IDENT }]] };
    const { stats } = sceneToSvg(synth, 0);
    ok('scene SVG emits <text>', stats.texts > 0, 'texts=' + stats.texts);
  }
}

console.log('== clip masks (clipDepth) ==');
{
  let maskScene = null;
  for (const cat of ['decorations', 'buildings', 'hud']) {
    const dir = path.join(ASSETS, cat);
    if (!fs.existsSync(dir)) continue;
    for (const f of fs.readdirSync(dir).filter(x => x.endsWith('.swf')).slice(0, 120)) {
      try {
        const swf = parseSwf(fs.readFileSync(path.join(dir, f)));
        let has = false; const walk = t => { for (const x of t) { if (x.tags) walk(x.tags); if (x.depth !== undefined && x.clipDepth != null) has = true; } };
        walk(swf.tags);
        if (has) { maskScene = swfToScene(swf, {}); break; }
      } catch (e) {}
    }
    if (maskScene) break;
  }
  ok('found an asset using clipDepth', !!maskScene);
  if (maskScene) {
    const { stats, svg } = sceneToSvg(maskScene, 0);
    ok('scene SVG emits a clipPath', stats.clips > 0 && /<clipPath/.test(svg), 'clips=' + stats.clips);
  }
}

console.log('== animation (frame advancement) ==');
{
  const synth = { characters: { 1: { type: 'shape', bounds: { xMin: 0, yMin: 0, xMax: 200, yMax: 200 }, prims: [] } },
    exports: {}, meta: { frameRate: 10 },
    frames: [ [{ depth: 1, char: 1, m: [1, 0, 0, 1, 0, 0] }] ] };
  const s = new FVScene(synth);
  ok('frameRate parsed', s.frameRate === 10, 'fr=' + s.frameRate);
  const sprite = { frames: [['A'], ['B'], ['C']] };
  ok('sprite frame advances at frameRate', s._frameOf(sprite, 0)[0] === 'A' && s._frameOf(sprite, 100)[0] === 'B' && s._frameOf(sprite, 300)[0] === 'A');
}

console.log('== fills emitted in SVG ==');
{
  const sq = [['M', 0, 0], ['L', 10, 0], ['L', 10, 10], ['L', 0, 10]];
  const synthScene = {
    characters: {
      '1': { type: 'shape', bounds: { xMin: 0, yMin: 0, xMax: 200, yMax: 200 }, prims: [{ fill: { kind: 'grad', gt: 'linear', m: [1, 0, 0, 1, 0, 0], stops: [{ r: 0, color: '#ff0000', alpha: 1 }, { r: 255, color: '#0000ff', alpha: 1 }] }, stroke: null, d: sq }] },
      '2': { type: 'shape', bounds: { xMin: 0, yMin: 0, xMax: 200, yMax: 200 }, prims: [{ fill: { kind: 'bitmap', id: 9, m: [20, 0, 0, 20, 0, 0], repeating: true }, stroke: null, d: sq }] },
      '9': { type: 'bitmap', w: 4, h: 4, png: 'data:image/png;base64,iVBORw0KGgo=' },
    },
    exports: {}, meta: { frameRate: 24 },
    frames: [[{ depth: 1, char: 1, m: IDENT }, { depth: 2, char: 2, m: IDENT }]],
  };
  const svg = sceneToSvg(synthScene, 0).svg;
  ok('SVG emits linearGradient', /linearGradient/.test(svg));
  ok('SVG emits bitmap pattern', /<pattern/.test(svg));
}

console.log('== blend modes + filters ==');
{
  const sq = [['M', 0, 0], ['L', 10, 0], ['L', 10, 10], ['L', 0, 10]];
  const synth = {
    characters: { '1': { type: 'shape', bounds: { xMin: 0, yMin: 0, xMax: 200, yMax: 200 }, prims: [{ fill: { kind: 'solid', color: '#ff0000', alpha: 1 }, stroke: null, d: sq }] } },
    exports: {}, meta: { frameRate: 24 },
    frames: [[{ depth: 1, char: 1, m: IDENT, blend: 2, filters: [{ t: 'glow', bx: 6, by: 6, color: '#66ff66', alpha: 1, strength: 1 }] }]],
  };
  const svg = sceneToSvg(synth, 0).svg;
  ok('SVG emits mix-blend-mode', /mix-blend-mode:multiply/.test(svg));
  ok('SVG emits filter def', /<filter /.test(svg) && /feDropShadow/.test(svg));
  const s = new FVScene(synth);
  ok('canvas _fxString builds drop-shadow', /drop-shadow/.test(s._fxString(synth.frames[0][0].filters)), s._fxString(synth.frames[0][0].filters));
}
{
  // real asset: confirm blend/filter descriptors are captured and rendered
  let hit = null;
  for (const cat of ['decorations', 'buildings', 'hud']) {
    const dir = path.join(ASSETS, cat);
    if (!fs.existsSync(dir)) continue;
    for (const f of fs.readdirSync(dir).filter(x => x.endsWith('.swf')).slice(0, 80)) {
      try {
        const scene = swfToScene(parseSwf(fs.readFileSync(path.join(dir, f))), {});
        const walk = list => { for (const p of list) { if ((p.filters && p.filters.length) || (p.blend && p.blend !== 0 && p.blend !== 1)) return true; const c = scene.characters[p.char]; if (c && c.type === 'sprite' && walk(c.frames[0])) return true; } return false; };
        if (walk(scene.frames[0])) { hit = scene; break; }
      } catch (e) {}
    }
    if (hit) break;
  }
  ok('a real asset carries a filter or blend', !!hit);
  if (hit) { const { stats, svg } = sceneToSvg(hit, 0); ok('real asset SVG emits <filter>', /<filter /.test(svg)); }
}

console.log('== embedded-font glyph text ==');
{
  const fp = path.join(ASSETS, 'dialogs', '003a419d34deb53a7dd760aa5e7fcb11.swf');
  if (fs.existsSync(fp)) {
    const scene = swfToScene(parseSwf(fs.readFileSync(fp)), {});
    ok('dialog scene has fonts', Object.keys(scene.fonts).length > 0, 'fonts=' + Object.keys(scene.fonts).length);
    const tc = Object.values(scene.characters).find(c => c.type === 'text' && c.fontId != null && scene.fonts[c.fontId]);
    ok('text char references an embedded font', !!tc);
    if (tc) {
      const font = scene.fonts[tc.fontId];
      ok('font has glyph outlines', font.glyphs.length > 0 && font.glyphs.some(g => g.prims.length > 0), 'glyphs=' + font.glyphs.length);
    }
    const { svg, stats } = sceneToSvg(scene, 0);
    ok('glyph text emits scaled glyph paths', stats.texts > 0 && /scale\(0\./.test(svg), 'texts=' + stats.texts);
  } else ok('dialog fixture exists', false, fp);
}

console.log('== world scene map + sounds (M2/M8a) ==');
{
  const mapPath = path.join(__dirname, '..', 'web', 'scenesbyname.json');
  const sndPath = path.join(__dirname, '..', 'web', 'sounds.json');
  if (fs.existsSync(mapPath)) { const m = JSON.parse(fs.readFileSync(mapPath, 'utf8')); ok('scenesbyname map non-empty', Object.keys(m).length > 0, Object.keys(m).length + ' items'); }
  else ok('scenesbyname map exists', false, mapPath);
  if (fs.existsSync(sndPath)) {
    const s = JSON.parse(fs.readFileSync(sndPath, 'utf8'));
    ok('sounds map has action sfx', !!s['actions/sfx_plow_01.mp3'] && !!s['actions/sfx_plant_01.mp3'] && !!s['actions/sfx_harvest_crop_01.mp3'], Object.keys(s).length + ' sounds');
  } else ok('sounds map exists', false, sndPath);
  const grassPath = path.join(__dirname, '..', 'web', 'grasstiles.json');
  if (fs.existsSync(grassPath)) {
    const g = JSON.parse(fs.readFileSync(grassPath, 'utf8'));
    ok('grass tile map has variants', Array.isArray(g.variants) && g.variants.length >= 1 && g.w > 0 && g.h > 0, g.variants.length + ' variants ' + g.w + 'x' + g.h);
    const webroot = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/grasstiles';
    const present = g.variants.filter(v => fs.existsSync(path.join(webroot, v))).length;
    ok('grass tile files deployed', present === g.variants.length, present + '/' + g.variants.length);
  } else ok('grasstiles.json exists', false, grassPath);
  const plotArt = ['plot_plowed.png', 'plot_withered.png'];
  const plotDeployed = plotArt.filter(f => fs.existsSync('C:/Farmville/xampp/htdocs/public/farmville/fvng/' + f)).length;
  ok('plot base art deployed (fallow/plowed)', plotDeployed === plotArt.length, plotDeployed + '/' + plotArt.length);
}

console.log('== buttons (interactivity) ==');
{
  const fp = path.join(ASSETS, 'dialogs', '003a419d34deb53a7dd760aa5e7fcb11.swf');
  if (fs.existsSync(fp)) {
    const scene = swfToScene(parseSwf(fs.readFileSync(fp)), {});
    const btns = Object.values(scene.characters).filter(c => c.type === 'button');
    ok('scene has button characters', btns.length > 0, 'buttons=' + btns.length);
    ok('button has up/over/down states', !!btns[0] && btns[0].states.up.length > 0 && btns[0].states.over.length > 0);
    const { stats } = sceneToSvg(scene, 0);
    ok('SVG renders buttons', stats.buttons > 0, 'buttons=' + stats.buttons);
    const s = new FVScene(scene);
    const boxes = s.buttonBoxes(0, '');
    ok('buttonBoxes returns hit areas', boxes.length > 0, 'boxes=' + boxes.length);
    s._buttonState = 'down';
    let drew = false;
    const ctx = new Proxy({}, { get: (t, k) => (typeof k === 'string') ? (...a) => { if (k === 'fill' || k === 'drawImage' || k === 'stroke') drew = true; } : undefined });
    s.render(ctx, 0);
    ok('renders in down state', drew);
  } else ok('button fixture exists', false, fp);
}

console.log('== localization (M8b) ==');
{
  const lp = path.join(__dirname, '..', 'web', 'locales.json');
  if (fs.existsSync(lp)) {
    const loc = JSON.parse(fs.readFileSync(lp, 'utf8'));
    ok('locales has 6 languages', Object.keys(loc).length >= 6, Object.keys(loc).join(','));
    ok('locales have core keys', !!loc.en && !!loc.en.gold && !!loc.de_DE && !!loc.de_DE.subtitle && loc.de_DE.subtitle !== loc.en.subtitle, 'de subtitle=' + (loc.de_DE && loc.de_DE.subtitle));
  } else ok('locales.json exists', false, lp);
}

console.log('== UI dialogs (#3) ==');
{
  const mapPath = path.join(__dirname, '..', 'web', 'dialogsbyname.json');
  if (fs.existsSync(mapPath)) { const m = JSON.parse(fs.readFileSync(mapPath, 'utf8')); ok('dialogsbyname map non-empty', Object.keys(m).length > 0, Object.keys(m).length + ' entries'); }
  else ok('dialogsbyname map exists', false, mapPath);
  const hash = require('../assets/assethash.json').dialogs['FV_motd_idealvacation.swf'];
  const fp = hash ? path.join(ASSETS, 'dialogs', hash + '.swf') : null;
  if (fp && fs.existsSync(fp)) {
    const scene = swfToScene(parseSwf(fs.readFileSync(fp)), {});
    ok('dialog converts with content', Object.keys(scene.characters).length > 0, 'chars=' + Object.keys(scene.characters).length);
    const s = new FVScene(scene);
    const cands = [{ b: s.measure(0, '') }]; for (const n of s.symbols()) cands.push({ b: s.measure(0, n) });
    const maxB = cands.reduce((a, c) => (c.b.w * c.b.h > a.b.w * a.b.h) ? c : a);
    ok('dialog has a non-empty render target', maxB.b.w > 0 && maxB.b.h > 0, JSON.stringify(maxB.b));
    const { stats } = sceneToSvg(scene, 0, s.symbols()[0] || undefined);
    ok('dialog SVG renders content', stats.paths + stats.images + stats.texts + stats.buttons > 0, JSON.stringify(stats));
  } else ok('dialog fixture exists', false, String(fp));
}

console.log('== HUD assets (M-HUD-0) ==');
{
  const hp = path.join(__dirname, '..', 'web', 'hud.json');
  const webHud = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/hud';
  if (fs.existsSync(hp)) {
    const m = JSON.parse(fs.readFileSync(hp, 'utf8'));
    ok('hud manifest has skins', !!m.skins && Object.keys(m.skins).length > 10, Object.keys(m.skins || {}).length + ' skins');
    ok('hud manifest has widget scenes', !!m.scenes && Object.keys(m.scenes).length >= 6, Object.keys(m.scenes || {}).join(','));
    ok('hud manifest has embedded art', !!m.embed && Object.keys(m.embed).length > 100, Object.keys(m.embed || {}).length + ' embeds');
    ok('hud layout constants', m.layout && m.layout.DEFAULT_WIDTH === 760 && m.layout.DEFAULT_HEIGHT === 590, JSON.stringify(m.layout));
    // Farm world skin (hudSkin_Chat) must expose the core button/background symbols
    const chat = m.skins && m.skins.Chat;
    const need = ['zoomIn_normal_farm', 'zoomOut_normal_farm', 'camera_normal_farm', 'fullScreen_normal_farm',
      'zcache_normal_farm', 'optionsBackground_farm', 'friendBar_normal_farm', 'singleArrow_normal_farm'];
    ok('chat skin has core symbols', !!chat && need.every(s => chat.symbols.includes(s)),
      chat ? need.filter(s => !chat.symbols.includes(s)).join(',') : 'no Chat skin');
    // embedded chrome that the HUD renders
    const chrome = ['FV_Cash_Icon', 'FV_Main_Fuel_Gauge', 'FV_Home_Button_Normal', 'FV_Message_Center_Button',
      'hud_act_walk', 'hud_act_plow', 'hud_act_bttn_top', 'hud_act_bttn_bottom', 'hud_gift', 'hud_storage'];
    const embedPresent = chrome.filter(n => m.embed && m.embed[n]);
    ok('core HUD embedded art indexed', embedPresent.length === chrome.length, chrome.filter(n => !(m.embed && m.embed[n])).join(','));
    const deployedEmbed = chrome.filter(n => fs.existsSync(path.join(webHud, 'embed', n + '.png')));
    ok('core HUD embedded art deployed', deployedEmbed.length === chrome.length, deployedEmbed.length + '/' + chrome.length);
    // action-menu chrome + popup art (M-HUD-3)
    const actArt = ['hud_act_bttn_top', 'hud_act_bttn_bottom', 'hud_contextual_arrow', 'hud_act_move',
      'hud_act_mastery', 'hud_collections', 'hud_achievements', 'hud_act_tractor_ground',
      'multi_contextual_background_3h1w', 'multi_contextual_background_5h1w'];
    ok('action-menu art indexed', actArt.every(n => m.embed && m.embed[n]), actArt.filter(n => !(m.embed && m.embed[n])).join(','));
    ok('action-menu art deployed', actArt.every(n => fs.existsSync(path.join(webHud, 'embed', n + '.png'))), actArt.filter(n => !fs.existsSync(path.join(webHud, 'embed', n + '.png'))).join(','));
    // XP level curve (build/gen_levels.php)
    const lpath = path.join(webHud, '..', 'levels.json');
    if (fs.existsSync(lpath)) {
      const l = JSON.parse(fs.readFileSync(lpath, 'utf8'));
      ok('level curve present', Array.isArray(l.startXP) && l.startXP.length > 50 && l.startXP[2] === 15 && l.higherLevelXp === 1500000, JSON.stringify({ n: l.startXP && l.startXP.length, l2: l.startXP && l.startXP[2] }));
    } else ok('levels.json deployed', false, lpath);
    // widget scenes deployed
    const deployedScenes = ['hudskin_chat', 'hud_coin_meter', 'hud_home', 'hud_search_bar', 'hud_travel_dropdown']
      .filter(s => fs.existsSync(path.join(webHud, s + '.scene.json')));
    ok('HUD scenes deployed', deployedScenes.length === 5, deployedScenes.join(','));
    // coin meter scene converts with the currency text + graphics
    const cpath = path.join(webHud, 'hud_coin_meter.scene.json');
    if (fs.existsSync(cpath)) {
      const sc = new FVScene(JSON.parse(fs.readFileSync(cpath, 'utf8')));
      const b = sc.measure(0, '');
      ok('coin meter scene has content', b.w > 20 && b.h > 5, b.w + 'x' + b.h);
      // glyph-scale regression: embedded-font outlines are stored ÷20 but metrics are raw, so the
      // outline scale must be fontSize/em (~0.0137), not fontSize/em/20 (~0.00068 → invisible).
      const { svg } = sceneToSvg(JSON.parse(fs.readFileSync(cpath, 'utf8')), 0);
      const m = svg.match(/scale\((0\.\d+)\)/);
      const sc0 = m ? parseFloat(m[1]) : 0;
      ok('glyph text scale is correct (not 20x too small)', sc0 > 0.005 && sc0 < 0.05, 'scale=' + sc0);
    } else ok('coin meter scene deployed', false, cpath);
    // button-only scenes must measure via button state bounds (scene2d _bboxOf button case)
    const ap = path.join(webHud, 'hud_add_coins.scene.json');
    if (fs.existsSync(ap)) {
      const sc = new FVScene(JSON.parse(fs.readFileSync(ap, 'utf8')));
      const b = sc.measure(0, '');
      ok('button-only scene measures via hit/up state', b.w > 50 && b.h > 10, b.w.toFixed(1) + 'x' + b.h.toFixed(1));
    } else ok('add-coins scene deployed', false, ap);
  } else ok('hud.json manifest exists', false, hp);
}

console.log('== instance stage (FVStage/Zw) ==');
const { FVStage } = require('../web/fvstage.js');
require('../web/zw.js');
const synth = {
  meta: { scale: 20, frameRate: 24, frameCount: 1, bounds: { xMin: 0, xMax: 1000, yMin: 0, yMax: 600 } },
  characters: {
    '1': { type: 'sprite', frameCount: 1, frames: [[{ depth: 1, char: 2, m: [1, 0, 0, 1, 0, 0], name: 'title_tf', visible: true }]] },
    '2': { type: 'text', fontSize: 200, color: { color: '#000000', alpha: 1 }, align: 0, bounds: { xMin: 0, yMin: 0, xMax: 1200, yMax: 400 }, text: 'A' },
  },
  fonts: {}, exports: {},
  frames: [[
    { depth: 1, char: 1, m: [1, 0, 0, 1, 10, 20], name: 'card_0', visible: true },
    { depth: 2, char: 1, m: [1, 0, 0, 1, 100, 20], name: 'card_1', visible: true },
  ]],
};
const scn = new FVScene(synth);
const st = new FVStage(scn); st.instantiate(0);
const c0 = st.find('card_0'), c1 = st.find('card_1');
ok('stage finds named instances', !!c0 && !!c1 && c0 !== c1);
ok('sibling instances are independent', c0.child('title_tf') !== c1.child('title_tf'));
c0.child('title_tf').setText('HELLO');
ok('setText affects only its instance', c0.child('title_tf').text === 'HELLO' && c1.child('title_tf').text === 'A');
const absm = c1.child('title_tf').abs();
ok('absolute matrix accumulates parents', Math.abs(absm[4] - 100) < 1e-6 && Math.abs(absm[5] - 20) < 1e-6, absm.join(','));
const calls = [];
const stub = { save() {}, restore() {}, transform() {}, setTransform() {}, beginPath() {}, moveTo() {}, lineTo() {}, quadraticCurveTo() {}, bezierCurveTo() {}, fill() {}, stroke() {}, clip() {}, fillRect() {}, drawImage() {}, createLinearGradient() { return { addColorStop() {} }; }, createRadialGradient() { return { addColorStop() {} }; }, createPattern() { return null; }, fillText(t) { calls.push(t); }, set font(v) {}, set fillStyle(v) {}, set globalAlpha(v) {}, set textAlign(v) {}, set textBaseline(v) {}, set lineWidth(v) {}, set strokeStyle(v) {}, set globalCompositeOperation(v) {}, set filter(v) {} };
st.render(stub);
ok('stage renders each instance text', calls.includes('HELLO') && calls.includes('A'), JSON.stringify(calls));
const zframe = new Zw.ZwFrame(st.root);
ok('ZwFrame hides its children by default', c0.visible === false && c1.visible === false);

console.log('');
console.log(passed + ' passed, ' + fails.length + ' failed');
if (fails.length) { fails.forEach(f => console.log('  - ' + f)); process.exitCode = 1; }

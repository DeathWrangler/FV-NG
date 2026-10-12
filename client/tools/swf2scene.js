// FV-NG — SWF -> runtime "scene" exporter (Track A / milestone M1).
//
// Converts a SWF into a compact, renderer-agnostic scene description so the JS client can draw
// and animate it WITHOUT a Flash runtime. Preserves the display-list + timeline model:
//   - characters: shapes (flattened path primitives w/ fills & strokes), sprites (nested timelines),
//     bitmaps (decoded to PNG data-URIs)
//   - timelines: per frame, a display list built from PlaceObject/RemoveObject, carrying the full
//     matrix + color transform + ratio + clipDepth — exactly what the original AVM2 renderer used.
//
// Units: Flash twips (1 px = 20 twips). Shape coords, matrix translates and stroke widths are
// divided by SCALE (default 20) to yield pixels; matrix scales are unitless.
//
// Usage:  node swf2scene.js <in.swf> [out.scene.json]
// API:    const { swfToScene } = require('./swf2scene.js');
const fs = require('fs');
const zlib = require('zlib');
const jpeg = require('jpeg-js');
const { parseSwf } = require('swf-parser');

const SCALE = 20;          // twips per pixel
const FP = 65536;          // Sfixed16P16 (matrix scale 1.0)
function eps(v) { return v ? (v.epsilons / FP) : 0; }
function frNum(fr) { return (fr && typeof fr === 'object' && fr.epsilons !== undefined) ? fr.epsilons / 256 : fr; } // SWF Fixed8 frame rate

// ---------- matrix (column-major affine [a,b,c,d,tx,ty]) ----------
// SWF MATRIX 2x2 = [[scaleX, rotateSkew0], [rotateSkew1, scaleY]] (raw components, NOT an
// angle decomposition) — verified against FFdec SVG output. a=scaleX, b=rotateSkew0,
// c=rotateSkew1, d=scaleY.
function matFromM(m) {
  if (!m) return [1, 0, 0, 1, 0, 0];
  return [eps(m.scaleX), eps(m.rotateSkew0), eps(m.rotateSkew1), eps(m.scaleY), (m.translateX || 0) / SCALE, (m.translateY || 0) / SCALE];
}
// like matFromM but keeps translate in TWIPS (needed for gradient/bitmap fill space, which is in twips)
function rawMat(m) {
  if (!m) return [1, 0, 0, 1, 0, 0];
  return [eps(m.scaleX), eps(m.rotateSkew0), eps(m.rotateSkew1), eps(m.scaleY), m.translateX || 0, m.translateY || 0];
}

// ---------- colour + fill helpers ----------
function hexOf(c) { return '#' + [c.r, c.g, c.b].map(x => (x | 0).toString(16).padStart(2, '0')).join(''); }
function alphaOf(c) { return (c && c.a !== undefined ? c.a : 255) / 255; }
function strokeOf(line) {
  const c = line && line.color;
  if (!c) return null;
  return { color: hexOf(c), alpha: alphaOf(c), width: (line.width || 0) / SCALE };
}
// FillStyle = Solid | LinearGradient | RadialGradient | FocalGradient | Bitmap
// (FillStyleType: Bitmap 0, Focal 1, Linear 2, Radial 3, Solid 4)
function fillDescriptor(fill) {
  if (!fill) return null;
  if (fill.color) return { kind: 'solid', color: hexOf(fill.color), alpha: alphaOf(fill.color) };
  if (fill.bitmapId !== undefined) return { kind: 'bitmap', id: fill.bitmapId, m: rawMat(fill.matrix), repeating: !!fill.repeating, smoothed: !!fill.smoothed };
  if (fill.gradient) {
    const gt = fill.type === 2 ? 'linear' : fill.type === 1 ? 'focal' : 'radial';
    return {
      kind: 'grad', gt,
      m: rawMat(fill.matrix),
      spread: fill.gradient.spread,
      stops: (fill.gradient.colors || []).map(c => ({ r: c.ratio, color: hexOf(c.color), alpha: alphaOf(c.color) })),
      focal: fill.focalPoint !== undefined ? (fill.focalPoint / 256) : 0,
    };
  }
  return null;
}
function colorTransformOf(ct) {
  if (!ct) return null;
  // swf-parser exposes CXFORM terms as fixed8.8 objects ({ epsilons }) — 256 == 1.0.
  // NOTE: matrix scale uses fixed16.16 (FP); colour terms use fixed8.8, so divide by 256.
  const E = v => (v && v.epsilons !== undefined) ? v.epsilons / 256 : (typeof v === 'number' ? v : 1);
  const out = { alphaMul: ct.alphaMult !== undefined ? E(ct.alphaMult) : 1 };
  const rm = ct.redMult !== undefined ? E(ct.redMult) : 1;
  const gm = ct.greenMult !== undefined ? E(ct.greenMult) : 1;
  const bm = ct.blueMult !== undefined ? E(ct.blueMult) : 1;
  if (rm !== 1 || gm !== 1 || bm !== 1) { out.rMul = rm; out.gMul = gm; out.bMul = bm; }
  const ra = ct.redAdd || 0, ga = ct.greenAdd || 0, ba = ct.blueAdd || 0, aa = ct.alphaAdd || 0;
  if (ra || ga || ba || aa) { out.rAdd = ra / 256; out.gAdd = ga / 256; out.bAdd = ba / 256; out.aAdd = aa / 256; }
  return out;
}

// Filter = DropShadow(0) | Blur(1) | Glow(2) | Bevel(3) | GradientGlow(4) | Convolution(5) | ColorMatrix(6) | GradientBevel(7)
// blurX/blurY are fixed16.16 PIXELS; strength is fixed8.8; angle is radians.
function filterDesc(f) {
  if (!f) return null;
  const E = v => (v && v.epsilons !== undefined) ? v.epsilons / FP : 0;
  const col = f.color ? { color: hexOf(f.color), alpha: alphaOf(f.color) } : { color: '#000000', alpha: 1 };
  switch (f.filter) {
    case 1: return { t: 'blur', bx: E(f.blurX), by: E(f.blurY) };
    case 2: return { t: 'glow', bx: E(f.blurX), by: E(f.blurY), ...col, strength: E(f.strength) || 1, inner: !!f.inner, knockout: !!f.knockout };
    case 0: { const a = E(f.angle), d = E(f.distance); return { t: 'shadow', bx: E(f.blurX), by: E(f.blurY), dx: Math.cos(a) * d, dy: Math.sin(a) * d, ...col, strength: E(f.strength) || 1, inner: !!f.inner, knockout: !!f.knockout }; }
    case 6: return { t: 'colormatrix', m: f.matrix };
    default: return null;   // bevel / gradient / convolution not yet mapped
  }
}

// ---------- shape flattening -> drawable primitives ----------
// swf-types ShapeRecord = Edge { type:0, delta, controlDelta? } | StyleChange { type:1, moveTo?,
// leftFill?, rightFill?, lineStyle?, newStyles? }. Fill/line indices are 1-based (0 = none).
function flattenShape(shape) {
  let fills = (shape.initialStyles && shape.initialStyles.fill) || [];
  let lines = (shape.initialStyles && shape.initialStyles.line) || [];
  const prims = [];
  let cx = 0, cy = 0, cur = null, fillIdx = 0, lineIdx = 0;
  const P = (x, y) => [+(x / SCALE).toFixed(2), +(y / SCALE).toFixed(2)];
  const start = () => {
    cur = {
      fill: (fillIdx > 0 && fills[fillIdx - 1]) ? fillDescriptor(fills[fillIdx - 1]) : null,
      stroke: (lineIdx > 0 && lines[lineIdx - 1]) ? strokeOf(lines[lineIdx - 1]) : null,
      d: [['M', ...P(cx, cy)]],
      _fi: fillIdx, _li: lineIdx,
    };
    prims.push(cur);
  };
  // A filled region can have several subpaths (e.g. a ring = outer + inner). Those must live in ONE
  // prim so the renderer's fill rule punches the holes — splitting them into separate solid fills
  // loses the holes (e.g. the cash bar's dark inner border then covered the light body).
  for (const r of shape.records || []) {
    if (r.type === 1) {                    // StyleChange
      if (r.newStyles) { fills = r.newStyles.fill || []; lines = r.newStyles.line || []; }
      if (r.rightFill !== undefined) fillIdx = r.rightFill; else if (r.leftFill !== undefined) fillIdx = r.leftFill;
      if (r.lineStyle !== undefined) lineIdx = r.lineStyle;
      if (r.moveTo) {
        cx = r.moveTo.x; cy = r.moveTo.y;
        if (!cur || cur._fi !== fillIdx || cur._li !== lineIdx) start();
        else cur.d.push(['M', ...P(cx, cy)]);   // new subpath in the same filled region
      } else if (!cur || cur._fi !== fillIdx || cur._li !== lineIdx) {
        start();
      }
    } else {                               // Edge (straight or quadratic)
      const endX = cx + r.delta.x, endY = cy + r.delta.y;
      if (!cur) start();
      if (r.controlDelta) {
        cur.d.push(['Q', ...P(cx + r.controlDelta.x, cy + r.controlDelta.y), ...P(endX, endY)]);
      } else {
        cur.d.push(['L', ...P(endX, endY)]);
      }
      cx = endX; cy = endY;
    }
  }
  return prims.filter(p => p.d.length > 1).map(p => ({ fill: p.fill, stroke: p.stroke, d: p.d }));
}

// ---------- bitmap decoding -> PNG data-uri ----------
function crc32(buf) { let t = []; for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; t[n] = c; } let crc = 0xFFFFFFFF; for (const b of buf) crc = t[(crc ^ b) & 0xFF] ^ (crc >>> 8); return (crc ^ 0xFFFFFFFF) >>> 0; }
function chunk(type, data) { const len = Buffer.alloc(4); len.writeUInt32BE(data.length); const t = Buffer.from(type); const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(Buffer.concat([t, data]))); return Buffer.concat([len, t, data, crc]); }
function encodePNG(w, h, rgba) {
  const sig = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  const ihdr = Buffer.alloc(13); ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4); ihdr[8] = 8; ihdr[9] = 6;
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y++) { raw[y * (w * 4 + 1)] = 0; rgba.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4); }
  return Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw, { level: 5 })), chunk('IEND', Buffer.alloc(0))]);
}
function dataToBuf(d) { return Buffer.isBuffer(d) ? d : Buffer.from(Object.values(d)); }
function decodeLossless(data, w, h, hasAlpha) {
  const buf = dataToBuf(data);
  let zoff = -1;
  for (let o = 1; o < 9 && o + 1 < buf.length; o++) if (buf[o] === 0x78 && (buf[o + 1] === 0x01 || buf[o + 1] === 0x9c || buf[o + 1] === 0xda)) { zoff = o; break; }
  if (zoff < 0) throw new Error('no zlib');
  const raw = zlib.inflateSync(buf.subarray(zoff));
  const out = Buffer.alloc(w * h * 4);
  if (hasAlpha) {
    // DefineBitsLossless2 stores PREMULTIPLIED ARGB (in memory order A,R,G,B) — swizzle to RGBA and
    // un-premultiply so the colour is correct (otherwise e.g. a gold coin decodes as white).
    for (let i = 0; i < w * h; i++) {
      const a = raw[i * 4], r = raw[i * 4 + 1], g = raw[i * 4 + 2], b = raw[i * 4 + 3];
      if (a === 0) { out[i * 4] = 0; out[i * 4 + 1] = 0; out[i * 4 + 2] = 0; out[i * 4 + 3] = 0; }
      else {
        const inv = 255 / a;
        out[i * 4] = Math.min(255, Math.round(r * inv));
        out[i * 4 + 1] = Math.min(255, Math.round(g * inv));
        out[i * 4 + 2] = Math.min(255, Math.round(b * inv));
        out[i * 4 + 3] = a;
      }
    }
  } else { for (let i = 0; i < w * h; i++) { out[i * 4] = raw[i * 3]; out[i * 4 + 1] = raw[i * 3 + 1]; out[i * 4 + 2] = raw[i * 3 + 2]; out[i * 4 + 3] = 255; } }
  return out;
}
function luminanceAlpha(rgb, w, h, lo = 12, hi = 72) {
  const out = Buffer.alloc(w * h * 4);
  for (let i = 0; i < w * h; i++) {
    const r = rgb[i * 3], g = rgb[i * 3 + 1], b = rgb[i * 3 + 2];
    let a = (Math.max(r, g, b) - lo) / (hi - lo); a = a < 0 ? 0 : a > 1 ? 1 : a;
    out[i * 4] = r; out[i * 4 + 1] = g; out[i * 4 + 2] = b; out[i * 4 + 3] = (a * 255) | 0;
  }
  return out;
}
function decodeBitmap(t, jpegTables) {
  const w = t.width, h = t.height;
  const mt = t.mediaType || '';
  let buf = dataToBuf(t.data);
  if (/lossless/.test(mt)) return { w, h, png: encodePNG(w, h, decodeLossless(t.data, w, h, /lossless2/.test(mt))) };
  // JPEG path: DefineBits (raw/partial) or DefineBitsJPEG3 (u32 length prefix)
  let jpg = buf;
  if (!(buf[0] === 0xFF && buf[1] === 0xD8)) {
    const len = buf.readUInt32LE(0);
    if (len > 0 && len + 4 <= buf.length) jpg = buf.subarray(4, 4 + len);
  }
  if (jpegTables && jpegTables.length > 4 && !(jpg[0] === 0xFF && jpg[1] === 0xD8)) jpg = Buffer.concat([jpegTables, jpg]);
  const dec = jpeg.decode(jpg, { useTArray: true });
  const rgb = Buffer.alloc(dec.width * dec.height * 3);
  for (let p = 0; p < dec.width * dec.height; p++) { rgb[p * 3] = dec.data[p * 4]; rgb[p * 3 + 1] = dec.data[p * 4 + 1]; rgb[p * 3 + 2] = dec.data[p * 4 + 2]; }
  return { w: dec.width, h: dec.height, png: encodePNG(dec.width, dec.height, luminanceAlpha(rgb, dec.width, dec.height)) };
}

// ---------- tag classification (swf-parser keys, not numeric codes) ----------
const isShape = t => t.shape !== undefined;
const isSprite = t => t.frameCount !== undefined && Array.isArray(t.tags);
const isBitmap = t => t.width !== undefined && t.height !== undefined && t.data !== undefined;
const isText = t => t.id !== undefined && t.bounds !== undefined && t.fontSize !== undefined && t.text !== undefined && t.glyphs === undefined;
const isFont = t => t.id !== undefined && t.glyphs !== undefined && t.codeUnits !== undefined;
const isButton = t => t.id !== undefined && Array.isArray(t.records) && t.records.length > 0 && t.records[0].stateUp !== undefined;
const isPlace = t => t.characterId !== undefined && t.depth !== undefined;
const isRemove = t => t.depth !== undefined && t.characterId === undefined && t.tags === undefined;
const isShowFrame = t => Object.keys(t).filter(k => k !== 'type').length === 0;

function textChar(t) {
  return {
    type: 'text',
    bounds: t.bounds,
    fontSize: t.fontSize || 0,          // twips
    color: t.color ? { color: hexOf(t.color), alpha: alphaOf(t.color) } : null,
    align: t.align | 0,                  // 0 left, 1 right, 2 center, 3 justify
    html: !!t.html,
    text: t.text || '',
    fontClass: t.fontClass || null,
    fontId: t.fontId !== undefined ? t.fontId : null,   // -> scene.fonts (glyph outlines)
    multiline: !!t.multiline,
    wordWrap: !!t.wordWrap,
    leading: t.leading | 0,
  };
}

// DefineButton/DefineButton2 -> per-state display lists (up/over/down/hit). Interactive.
function buttonChar(t) {
  const states = { up: [], over: [], down: [], hit: [] };
  for (const r of t.records) {
    const p = {
      depth: r.depth, char: r.characterId, m: matFromM(r.matrix), ct: colorTransformOf(r.colorTransform),
      filters: (r.filters || []).map(filterDesc).filter(Boolean), blend: r.blendMode | 0, visible: true,
    };
    if (r.stateUp) states.up.push(p);
    if (r.stateOver) states.over.push(p);
    if (r.stateDown) states.down.push(p);
    if (r.stateHitTest) states.hit.push(p);
  }
  for (const k in states) states[k].sort((a, b) => a.depth - b.depth);
  return { type: 'button', trackAsMenu: !!t.trackAsMenu, states };
}

// DefineFont2/3 -> glyph outlines + metrics. Glyph records carry no fill style; the text colour
// is applied by the renderer. `codeUnits[i]` is the character code for `glyphs[i]`.
function fontDesc(t) {
  const adv = (t.layout && t.layout.advances) || [];
  const glyphs = (t.glyphs || []).map((g, i) => ({
    prims: flattenShape({ initialStyles: { fill: [], line: [] }, records: g.records || [] }),
    adv: adv[i] || 0,
  }));
  return {
    em: t.emSquareSize || 1024,
    ascent: (t.layout && t.layout.ascent) || 0,
    descent: (t.layout && t.layout.descent) || 0,
    codeUnits: t.codeUnits || [],
    glyphs,
  };
}

function placementFrom(t, prev) {
  const p = {
    depth: t.depth,
    char: t.characterId !== undefined ? t.characterId : (prev && prev.char),
    m: t.matrix !== undefined ? matFromM(t.matrix) : (prev ? prev.m : [1, 0, 0, 1, 0, 0]),
    ct: t.colorTransform !== undefined ? colorTransformOf(t.colorTransform) : (prev ? prev.ct : null),
    ratio: t.ratio !== undefined ? t.ratio : (prev ? prev.ratio : 0),
    clipDepth: t.clipDepth !== undefined ? t.clipDepth : (prev ? prev.clipDepth : null),
    visible: t.visible !== undefined ? t.visible : (prev ? prev.visible : true),
    blend: t.blendMode !== undefined ? (t.blendMode | 0) : (prev ? prev.blend : 0),
    filters: t.filters !== undefined ? (t.filters || []).map(filterDesc).filter(Boolean) : (prev ? prev.filters : null),
    name: t.name !== undefined ? t.name : (prev ? prev.name : null),   // instance name (for binding)
  };
  return p;
}
function buildTimeline(tags) {
  const frames = [];
  const list = new Map();
  for (const t of tags) {
    if (isPlace(t)) list.set(t.depth, placementFrom(t, list.get(t.depth)));
    else if (isRemove(t)) list.delete(t.depth);
    else if (isShowFrame(t)) frames.push([...list.values()].map(p => ({ ...p, m: p.m.slice(), ct: p.ct ? { ...p.ct } : null })));
  }
  if (!frames.length) frames.push([...list.values()]);
  return frames;
}

// ---------- main export ----------
function swfToScene(swf, meta) {
  const chars = {};
  const fonts = {};     // fontId -> glyph outlines + metrics (for 1:1 text)
  const exports = {};   // className -> characterId (SymbolClass): how the client instantiates assets
  let jpegTables = null;
  // first pass: bitmaps may need JPEGTables (DefineBits before/after) — collect tables first
  for (const t of swf.tags) if (isBitmap(t) && /partial-jpeg/.test(t.mediaType || '') && t.id === undefined) jpegTables = dataToBuf(t.data);

  for (const t of swf.tags) {
    if (t.symbols !== undefined) {                       // SymbolClass
      for (const s of (t.symbols || [])) if (s && s.name) exports[s.name] = s.id;
    } else if (isFont(t)) {
      fonts[t.id] = fontDesc(t);
    } else if (isShape(t)) {
      chars[t.id] = { type: 'shape', bounds: t.bounds, prims: flattenShape(t.shape) };
    } else if (isSprite(t)) {
      chars[t.id] = { type: 'sprite', frameCount: t.frameCount, frames: buildTimeline(t.tags) };
    } else if (isText(t)) {
      chars[t.id] = textChar(t);
    } else if (isButton(t)) {
      chars[t.id] = buttonChar(t);
    } else if (isBitmap(t) && t.id !== undefined) {
      try { const b = decodeBitmap(t, jpegTables); chars[t.id] = { type: 'bitmap', w: b.w, h: b.h, png: 'data:image/png;base64,' + b.png.toString('base64') }; }
      catch (e) { chars[t.id] = { type: 'bitmap', w: t.width, h: t.height, error: String(e.message || e) }; }
    }
  }

  const scene = {
    meta: Object.assign({ scale: SCALE, frameRate: swf.header ? frNum(swf.header.frameRate) : null,
      frameCount: swf.header ? (swf.header.frameCount) : null, bounds: swf.header ? swf.header.frameSize : null }, meta || {}),
    characters: chars,
    fonts: fonts,
    exports: exports,
    frames: buildTimeline(swf.tags),
  };
  return scene;
}

module.exports = { swfToScene, flattenShape, buildTimeline, matFromM };

if (require.main === module) {
  const [, , inFile, outFile] = process.argv;
  const swf = parseSwf(fs.readFileSync(inFile));
  const scene = swfToScene(swf, { source: inFile.replace(/\\/g, '/').split('/').pop() });
  const byType = {};
  for (const id in scene.characters) { const c = scene.characters[id]; byType[c.type] = (byType[c.type] || 0) + 1; }
  if (outFile) fs.writeFileSync(outFile, JSON.stringify(scene));
  console.log(JSON.stringify({ characters: byType, fonts: Object.keys(scene.fonts).length, symbols: Object.keys(scene.exports).length, frames: scene.frames.length,
    bytes: outFile ? fs.statSync(outFile).size : JSON.stringify(scene).length }, null, 1));
}

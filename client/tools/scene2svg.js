// FV-NG — scene -> SVG (Node-side visual verification for the M1 renderer).
// Mirrors client/web/scene2d.js: display-list traversal with depth sorting, nested timelines,
// affine matrices, alpha, solid/gradient/bitmap fills, strokes, dynamic text and clipDepth masks.
//
// Usage: node scene2svg.js <scene.json> <out.svg> [frameIndex] [symbol]
const fs = require('fs');
const { mul, IDENT } = require('../web/scene2d.js');

function esc(s) { return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); }
function pathD(d) {
  let s = '';
  for (const c of d) {
    if (c[0] === 'M') s += `M${c[1]} ${c[2]} `;
    else if (c[0] === 'L') s += `L${c[1]} ${c[2]} `;
    else if (c[0] === 'Q') s += `Q${c[1]} ${c[2]} ${c[3]} ${c[4]} `;
    else if (c[0] === 'C') s += `C${c[1]} ${c[2]} ${c[3]} ${c[4]} ${c[5]} ${c[6]} `;
  }
  return s.trim();
}
function plainText(html) {
  if (!html) return '';
  return String(html).replace(/<br\s*\/?>/gi, '\n').replace(/<\/p>/gi, '\n').replace(/<[^>]+>/g, '')
    .replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
    .replace(/&#(\d+);/g, (_, d) => String.fromCharCode(+d)).trim();
}
function fontFace(html) { const m = html && String(html).match(/face="([^"]+)"/i); return m ? m[1] : null; }
// SWF BlendMode -> SVG mix-blend-mode
const BLEND_CSS = { 2: 'multiply', 3: 'screen', 4: 'lighten', 5: 'darken', 6: 'difference', 7: 'plus-lighter', 12: 'overlay', 13: 'hard-light' };

function filterId(ctxObj, filters) {
  if (!filters || !filters.length) return null;
  const id = 'fx' + (ctxObj.idc.n++);
  const prims = [];
  for (const f of filters) {
    if (f.t === 'blur') prims.push(`<feGaussianBlur stdDeviation="${(Math.max(f.bx, f.by) / 2).toFixed(2)}"/>`);
    else if (f.t === 'glow') prims.push(`<feDropShadow dx="0" dy="0" stdDeviation="${(Math.max(f.bx, f.by) / 2).toFixed(2)}" flood-color="${f.color}" flood-opacity="${f.alpha.toFixed(3)}"/>`);
    else if (f.t === 'shadow') prims.push(`<feDropShadow dx="${f.dx.toFixed(2)}" dy="${f.dy.toFixed(2)}" stdDeviation="${(Math.max(f.bx, f.by) / 2).toFixed(2)}" flood-color="${f.color}" flood-opacity="${f.alpha.toFixed(3)}"/>`);
    else if (f.t === 'colormatrix' && f.m) prims.push(`<feColorMatrix type="matrix" values="${f.m.map(v => (+v).toFixed(4)).join(' ')}"/>`);
  }
  if (!prims.length) return null;
  ctxObj.defs.push(`<filter id="${id}" x="-50%" y="-50%" width="200%" height="200%">${prims.join('')}</filter>`);
  return id;
}

function charBBox(chars, id, depth, seen) {
  const c = chars[id];
  if (!c || depth > 32 || seen.has(id)) return null;
  seen = new Set(seen); seen.add(id);
  if (c.type === 'shape' && c.bounds) return { x0: c.bounds.xMin / 20, y0: c.bounds.yMin / 20, x1: c.bounds.xMax / 20, y1: c.bounds.yMax / 20 };
  if (c.type === 'bitmap') return { x0: 0, y0: 0, x1: c.w, y1: c.h };
  if (c.type === 'text' && c.bounds) return { x0: c.bounds.xMin / 20, y0: c.bounds.yMin / 20, x1: c.bounds.xMax / 20, y1: c.bounds.yMax / 20 };
  if (c.type === 'sprite') return listBBox(chars, c.frames[0], depth + 1, seen);
  return null;
}
function listBBox(chars, list, depth, seen) {
  let bb = null;
  for (const p of list) {
    const b = charBBox(chars, p.char, depth, seen || new Set());
    if (!b) continue;
    const m = p.m || IDENT;
    const pts = [[b.x0, b.y0], [b.x1, b.y0], [b.x0, b.y1], [b.x1, b.y1]].map(([x, y]) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]]);
    const x0 = Math.min(...pts.map(q => q[0])), y0 = Math.min(...pts.map(q => q[1]));
    const x1 = Math.max(...pts.map(q => q[0])), y1 = Math.max(...pts.map(q => q[1]));
    bb = bb ? { x0: Math.min(bb.x0, x0), y0: Math.min(bb.y0, y0), x1: Math.max(bb.x1, x1), y1: Math.max(bb.y1, y1) } : { x0, y0, x1, y1 };
  }
  return bb;
}

function fillPaint(ctxObj, fill, alpha) {
  // ctxObj = { defs, idc }
  if (!fill) return { paint: 'none', opacity: 1 };
  if (fill.kind === 'solid') return { paint: fill.color, opacity: (alpha * fill.alpha).toFixed(3) };
  if (fill.kind === 'grad') {
    const id = 'g' + (ctxObj.idc.n++);
    const M = fill.m;
    const P = (x, y) => [(M[0] * x + M[2] * y + M[4]) / 20, (M[1] * x + M[3] * y + M[5]) / 20];
    const gs = 16384;
    const stops = fill.stops.map(s => `<stop offset="${(Math.max(0, Math.min(255, s.r)) / 255).toFixed(4)}" stop-color="${s.color}" stop-opacity="${s.alpha.toFixed(3)}"/>`).join('');
    if (fill.gt === 'linear') {
      const a = P(-gs, 0), b = P(gs, 0);
      ctxObj.defs.push(`<linearGradient id="${id}" gradientUnits="userSpaceOnUse" x1="${a[0].toFixed(2)}" y1="${a[1].toFixed(2)}" x2="${b[0].toFixed(2)}" y2="${b[1].toFixed(2)}">${stops}</linearGradient>`);
    } else {
      const c = P(0, 0), e = P(gs, 0), r = Math.hypot(e[0] - c[0], e[1] - c[1]) || 1;
      let fx = c[0], fy = c[1];
      if (fill.gt === 'focal' && fill.focal) { const f = P(fill.focal * gs, 0); fx = f[0]; fy = f[1]; }
      ctxObj.defs.push(`<radialGradient id="${id}" gradientUnits="userSpaceOnUse" cx="${c[0].toFixed(2)}" cy="${c[1].toFixed(2)}" r="${r.toFixed(2)}" fx="${fx.toFixed(2)}" fy="${fy.toFixed(2)}">${stops}</radialGradient>`);
    }
    return { paint: `url(#${id})`, opacity: alpha.toFixed(3) };
  }
  if (fill.kind === 'bitmap') {
    const id = 'p' + (ctxObj.idc.n++);
    const M = fill.m;
    const tf = `matrix(${(M[0] / 20).toFixed(6)} ${(M[1] / 20).toFixed(6)} ${(M[2] / 20).toFixed(6)} ${(M[3] / 20).toFixed(6)} ${(M[4] / 20).toFixed(3)} ${(M[5] / 20).toFixed(3)})`;
    // bitmap dimensions unknown here without chars; caller passes via fill.__wh (set by exporter consumer)
    const w = fill.__w || 1, h = fill.__h || 1;
    const img = fill.__png ? `<image href="${esc(fill.__png)}" width="${w}" height="${h}"/>` : '';
    ctxObj.defs.push(`<pattern id="${id}" patternUnits="userSpaceOnUse" width="${w}" height="${h}" patternTransform="${tf}">${img}</pattern>`);
    return { paint: `url(#${id})`, opacity: alpha.toFixed(3) };
  }
  return { paint: 'none', opacity: 1 };
}

function glyphD(glyph) {
  let d = '';
  for (const prim of glyph.prims) for (const cmd of prim.d) {
    if (cmd[0] === 'M') d += `M${cmd[1]} ${cmd[2]} `;
    else if (cmd[0] === 'L') d += `L${cmd[1]} ${cmd[2]} `;
    else if (cmd[0] === 'Q') d += `Q${cmd[1]} ${cmd[2]} ${cmd[3]} ${cmd[4]} `;
    else if (cmd[0] === 'C') d += `C${cmd[1]} ${cmd[2]} ${cmd[3]} ${cmd[4]} ${cmd[5]} ${cmd[6]} `;
  }
  return d.trim();
}

function renderList(chars, fonts, list, parentM, alpha, depth, out, ctxObj, stats) {
  if (depth > 32) return;
  const sorted = list.slice().sort((x, y) => (x.depth || 0) - (y.depth || 0));
  const clips = [];
  for (const p of sorted) {
    while (clips.length && (p.depth || 0) > clips[clips.length - 1]) { out.push('</g>'); clips.pop(); }
    if (p.visible === false) continue;
    const m = mul(parentM, p.m || IDENT);
    const a = alpha * (p.ct && p.ct.alphaMul != null ? p.ct.alphaMul : 1);
    if (a <= 0) continue;
    const c = chars[p.char];
    if (!c) continue;
    const tf = `matrix(${m[0].toFixed(6)} ${m[1].toFixed(6)} ${m[2].toFixed(6)} ${m[3].toFixed(6)} ${m[4].toFixed(3)} ${m[5].toFixed(3)})`;
    if (p.clipDepth != null) {
      const id = 'clip' + (ctxObj.idc.n++);
      const d = clipPathD(chars, p.char, m);
      ctxObj.defs.push(`<clipPath id="${id}"><path d="${d}"/></clipPath>`);
      out.push(`<g clip-path="url(#${id})">`); clips.push(p.clipDepth);
      stats.clips++;
      continue;
    }
    const fxAttrs = [];
    const bmc = BLEND_CSS[p.blend]; if (bmc) fxAttrs.push(`style="mix-blend-mode:${bmc}"`);
    const fid = filterId(ctxObj, p.filters); if (fid) fxAttrs.push(`filter="url(#${fid})"`);
    if (fxAttrs.length) out.push(`<g ${fxAttrs.join(' ')}>`);
    if (c.type === 'shape') {
      for (const prim of c.prims) {
        const d = pathD(prim.d);
        if (!d) continue;
        const fp = fillPaint(ctxObj, prim.fill, a);
        const stroke = prim.stroke ? ` stroke="${prim.stroke.color}" stroke-opacity="${(a * prim.stroke.alpha).toFixed(3)}" stroke-width="${prim.stroke.width}"` : '';
        out.push(`<path transform="${tf}" d="${d}" fill="${fp.paint}" fill-opacity="${fp.opacity}"${stroke}/>`);
        stats.paths++;
      }
    } else if (c.type === 'bitmap') {
      if (!c.png) { stats.missingBitmaps++; continue; }
      out.push(`<image transform="${tf}" x="0" y="0" width="${c.w}" height="${c.h}" opacity="${a.toFixed(3)}" href="${esc(c.png)}"/>`);
      stats.images++;
    } else if (c.type === 'text') {
      const txt = plainText(c.text);
      if (!txt) continue;
      const col = c.color || { color: '#000000', alpha: 1 };
      const font = (c.fontId != null) ? fonts[c.fontId] : null;
      if (font && font.glyphs && font.glyphs.length) {
        // glyph outlines stored at ÷20 scale; advances + ascent/descent are raw font units
        const Sglyph = ((c.fontSize || 0) / font.em);
        const Smet = Sglyph / 20;
        const cmap = {}; for (let i = 0; i < font.codeUnits.length; i++) cmap[font.codeUnits[i]] = i;
        const b = c.bounds || { xMin: 0, yMin: 0, xMax: 100, yMax: font.ascent + font.descent };
        const bx0 = b.xMin / 20, bx1 = b.xMax / 20, baseline = b.yMin / 20 + font.ascent * Smet;
        const lines = txt.split(/\r\n|\r|\n/);
        for (let li = 0; li < lines.length; li++) {
          const line = lines[li];
          let w = 0; for (const ch of line) { const gi = cmap[ch.codePointAt(0)]; if (gi !== undefined) w += font.glyphs[gi].adv * Smet; }
          let x = bx0; if (c.align === 1) x = bx1 - w; else if (c.align === 2) x = (bx0 + bx1) / 2 - w / 2;
          const y = baseline + li * ((font.ascent + font.descent) * Smet);
          for (const ch of line) {
            const gi = cmap[ch.codePointAt(0)]; if (gi === undefined) continue;
            const g = font.glyphs[gi]; const d = glyphD(g);
            if (d) out.push(`<path transform="${tf} translate(${x.toFixed(2)} ${y.toFixed(2)}) scale(${Sglyph.toFixed(6)})" d="${d}" fill="${col.color}" fill-opacity="${(a * col.alpha).toFixed(3)}"/>`);
            x += g.adv * Smet;
          }
        }
        stats.texts++;
      } else {
        const size = (c.fontSize || 0) / 20, b = c.bounds || { xMin: 0, yMin: 0, xMax: 100, yMax: size * 20 };
        const anchor = c.align === 1 ? 'end' : c.align === 2 ? 'middle' : 'start';
        const x = c.align === 1 ? b.xMax / 20 : c.align === 2 ? (b.xMin + b.xMax) / 40 : b.xMin / 20;
        const y = b.yMin / 20 + size * 0.9;
        const fam = c.fontClass || fontFace(c.text) || 'sans-serif';
        out.push(`<text transform="${tf}" x="${x.toFixed(2)}" y="${y.toFixed(2)}" font-size="${size.toFixed(2)}" font-family="${esc(fam)},sans-serif" fill="${col.color}" fill-opacity="${(a * col.alpha).toFixed(3)}" text-anchor="${anchor}">${esc(txt)}</text>`);
        stats.texts++;
      }
    } else if (c.type === 'button') {
      stats.buttons++;
      renderList(chars, fonts, c.states.up || [], m, a, depth + 1, out, ctxObj, stats);
    } else if (c.type === 'sprite') {
      stats.sprites++;
      renderList(chars, fonts, c.frames[0], m, a, depth + 1, out, ctxObj, stats);
    }
    if (fxAttrs.length) out.push('</g>');
  }
  while (clips.length) { out.push('</g>'); clips.pop(); }
}

function clipPathD(chars, id, m) {
  const c = chars[id];
  const parts = [];
  const add = (shape, mm) => {
    const X = (x, y) => [mm[0] * x + mm[2] * y + mm[4], mm[1] * x + mm[3] * y + mm[5]];
    let d = '';
    for (const prim of shape.prims) for (const cmd of prim.d) {
      if (cmd[0] === 'M') { const q = X(cmd[1], cmd[2]); d += `M${q[0].toFixed(2)} ${q[1].toFixed(2)} `; }
      else if (cmd[0] === 'L') { const q = X(cmd[1], cmd[2]); d += `L${q[0].toFixed(2)} ${q[1].toFixed(2)} `; }
      else if (cmd[0] === 'Q') { const a = X(cmd[1], cmd[2]), b = X(cmd[3], cmd[4]); d += `Q${a[0].toFixed(2)} ${a[1].toFixed(2)} ${b[0].toFixed(2)} ${b[1].toFixed(2)} `; }
      else if (cmd[0] === 'C') { const a = X(cmd[1], cmd[2]), b = X(cmd[3], cmd[4]), e = X(cmd[5], cmd[6]); d += `C${a[0].toFixed(2)} ${a[1].toFixed(2)} ${b[0].toFixed(2)} ${b[1].toFixed(2)} ${e[0].toFixed(2)} ${e[1].toFixed(2)} `; }
    }
    parts.push(d.trim());
  };
  if (!c) return '';
  if (c.type === 'shape') add(c, m);
  else if (c.type === 'sprite') for (const pp of c.frames[0]) { const cc = chars[pp.char]; if (cc && cc.type === 'shape') add(cc, mul(m, pp.m || IDENT)); }
  return parts.join(' ');
}

// attach bitmap png/dims onto bitmap-fill descriptors so the SVG pattern can embed the image
function decorateBitmaps(chars) {
  for (const id in chars) {
    const c = chars[id];
    if (c.type !== 'shape') continue;
    for (const prim of c.prims) {
      const f = prim.fill;
      if (f && f.kind === 'bitmap') {
        const bm = chars[f.id];
        if (bm && bm.type === 'bitmap') { f.__png = bm.png; f.__w = bm.w; f.__h = bm.h; }
      }
    }
  }
}

function sceneToSvg(scene, frameIndex, symbol) {
  const chars = scene.characters || {};
  decorateBitmaps(chars);
  const frames = scene.frames || [[]];
  const fi = Math.max(0, Math.min(frameIndex | 0, frames.length - 1));
  let list = frames[fi], usedSymbol = null;
  if (symbol) { const id = (scene.exports || {})[symbol]; if (id !== undefined) { list = [{ depth: 1, char: id, m: IDENT, visible: true }]; usedSymbol = symbol; } }
  const stats = { paths: 0, images: 0, sprites: 0, texts: 0, clips: 0, buttons: 0, missingBitmaps: 0 };
  const out = [], defs = [], ctxObj = { defs, idc: { n: 0 } };
  const fonts = scene.fonts || {};
  renderList(chars, fonts, list, IDENT, 1, 0, out, ctxObj, stats);
  if (stats.paths + stats.images + stats.texts === 0 && !symbol) {
    const names = Object.keys(scene.exports || {});
    if (names.length) { const l2 = [{ depth: 1, char: scene.exports[names[0]], m: IDENT, visible: true }]; renderList(chars, fonts, l2, IDENT, 1, 0, out, ctxObj, stats); list = l2; usedSymbol = names[0]; }
  }
  const bb = listBBox(chars, list, 0, new Set()) || { x0: 0, y0: 0, x1: 1, y1: 1 };
  const pad = 2, W = Math.max(1, bb.x1 - bb.x0), H = Math.max(1, bb.y1 - bb.y0);
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${(bb.x0 - pad).toFixed(2)} ${(bb.y0 - pad).toFixed(2)} ${(W + 2 * pad).toFixed(2)} ${(H + 2 * pad).toFixed(2)}" width="${W.toFixed(1)}" height="${H.toFixed(1)}">` +
    (defs.length ? `<defs>${defs.join('')}</defs>` : '') + out.join('') + '</svg>';
  return { svg, stats, bbox: bb, frame: fi, symbol: usedSymbol };
}

module.exports = { sceneToSvg };

if (require.main === module) {
  const [, , inFile, outFile, frame, symbol] = process.argv;
  const scene = JSON.parse(fs.readFileSync(inFile, 'utf8'));
  const { svg, stats, bbox, symbol: used } = sceneToSvg(scene, parseInt(frame || '0', 10), symbol);
  if (outFile) fs.writeFileSync(outFile, svg);
  console.log(JSON.stringify({ stats, symbol: used, bbox: { x0: +bbox.x0.toFixed(1), y0: +bbox.y0.toFixed(1), x1: +bbox.x1.toFixed(1), y1: +bbox.y1.toFixed(1) }, svgBytes: svg.length }, null, 1));
}

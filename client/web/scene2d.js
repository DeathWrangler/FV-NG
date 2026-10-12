/* FV-NG — runtime scene renderer (Track A / M1).
 *
 * Renders a scene produced by client/tools/swf2scene.js onto a Canvas2D context with no Flash
 * runtime. Faithful to the AVM2 display-list model: nested timelines, per-placement affine matrix,
 * colour transform (alpha), bitmap draws, and vector shape primitives (solid fills + strokes).
 *
 * Usage (browser):
 *   const scene = await (await fetch('scenes/foo.scene.json')).json();
 *   const s = new FVScene(scene);
 *   await s.load();                 // decode embedded bitmaps
 *   s.render(ctx, frameIndex);      // draw root timeline frame
 */
(function (global) {
  'use strict';

  function mul(P, C) { // P * C (apply C first, then P); both [a,b,c,d,tx,ty]
    return [
      P[0] * C[0] + P[2] * C[1],
      P[1] * C[0] + P[3] * C[1],
      P[0] * C[2] + P[2] * C[3],
      P[1] * C[2] + P[3] * C[3],
      P[0] * C[4] + P[2] * C[5] + P[4],
      P[1] * C[4] + P[3] * C[5] + P[5],
    ];
  }
  const IDENT = [1, 0, 0, 1, 0, 0];

  // ---------- helpers ----------
  function rgba(hex, alpha) {
    const h = (hex || '#000000').replace('#', '');
    const r = parseInt(h.slice(0, 2), 16) || 0, g = parseInt(h.slice(2, 4), 16) || 0, b = parseInt(h.slice(4, 6), 16) || 0;
    return 'rgba(' + r + ',' + g + ',' + b + ',' + (alpha == null ? 1 : alpha).toFixed(3) + ')';
  }
  function plainText(html) {
    if (!html) return '';
    return String(html)
      .replace(/<br\s*\/?>/gi, '\n').replace(/<\/p>/gi, '\n')
      .replace(/<[^>]+>/g, '')
      .replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
      .replace(/&#(\d+);/g, (_, d) => String.fromCharCode(+d))
      .trim();
  }
  function fontFace(html) {
    const m = html && String(html).match(/face="([^"]+)"/i);
    return m ? m[1] : null;
  }
  // SWF BlendMode -> canvas globalCompositeOperation (Layer/Alpha/Invert have no direct equivalent)
  const BLEND = { 0: 'source-over', 1: 'source-over', 2: 'multiply', 3: 'screen', 4: 'lighten', 5: 'darken', 6: 'difference', 7: 'lighter', 8: 'source-over', 9: 'source-over', 10: 'source-over', 11: 'destination-out', 12: 'overlay', 13: 'hard-light' };

  class FVScene {
    constructor(scene) {
      this.scene = scene;
      this.chars = scene.characters || {};
      this.fonts = scene.fonts || {};
      this.frames = scene.frames || [[]];
      this._buttonState = 'up';   // current interaction state for all buttons ('up'|'over'|'down')
      this.images = {};   // charId -> HTMLImageElement
      this.ready = false;
      let fr = scene.meta && scene.meta.frameRate;
      if (fr && typeof fr === 'object' && fr.epsilons !== undefined) fr = fr.epsilons / 256; // SWF Fixed8 frame rate
      if (fr > 120) fr = fr / 256;
      this.frameRate = fr || 24;
      this.bounds = this._bounds();
    }

    /** decode every embedded bitmap; resolves when all are loaded (or failed) */
    load() {
      const jobs = [];
      for (const id in this.chars) {
        const c = this.chars[id];
        if (c.type === 'bitmap' && c.png) {
          jobs.push(new Promise((res) => {
            const im = new Image();
            im.onload = () => { this.images[id] = im; res(); };
            im.onerror = () => res();
            im.src = c.png;
          }));
        }
      }
      return Promise.all(jobs).then(() => { this.ready = true; return this; });
    }

    /** union bounds (px) of all shape/bitmap characters, for fitting */
    _bounds() {
      let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
      for (const id in this.chars) {
        const c = this.chars[id];
        if (c.type === 'shape' && c.bounds) {
          const b = c.bounds;
          x0 = Math.min(x0, b.xMin / 20); y0 = Math.min(y0, b.yMin / 20);
          x1 = Math.max(x1, b.xMax / 20); y1 = Math.max(y1, b.yMax / 20);
        } else if (c.type === 'bitmap') {
          x0 = Math.min(x0, 0); y0 = Math.min(y0, 0);
          x1 = Math.max(x1, c.w); y1 = Math.max(y1, c.h);
        }
      }
      if (!isFinite(x0)) return { x: 0, y: 0, w: 1, h: 1 };
      return { x: x0, y: y0, w: Math.max(1, x1 - x0), h: Math.max(1, y1 - y0) };
    }

    frameCount() { return this.frames.length; }

    /** convenience accessors (scene JSON shape) */
    get characters() { return this.chars; }
    get exports() { return this.scene.exports || {}; }

    /** symbol (exported class) names this scene can instantiate */
    symbols() { return Object.keys(this.exports); }

    /** find display-list placements whose instance name matches, with absolute matrices (for data
        binding into the original SWF windows, e.g. market item slots / storage slots). */
    findNamed(name, frameIndex) {
      const out = [];
      const walk = (list, parentM, depth) => {
        if (depth > 32) return;
        for (const p of list || []) {
          const m = mul(parentM, p.m || IDENT);
          if (p.name === name) out.push({ placement: p, m });
          const c = this.chars[p.char];
          if (c && c.type === 'sprite') walk(c.frames[0], m, depth + 1);
        }
      };
      walk(this.frames[Math.max(0, Math.min(frameIndex | 0, this.frames.length - 1))] || [], IDENT, 0);
      return out;
    }
    /** all named placements in a frame: name -> [absolute matrix, ...] */
    namedMap(frameIndex) {
      const map = {};
      const walk = (list, parentM, depth) => {
        if (depth > 32) return;
        for (const p of list || []) {
          const m = mul(parentM, p.m || IDENT);
          if (p.name) (map[p.name] = map[p.name] || []).push(m);
          const c = this.chars[p.char];
          if (c && c.type === 'sprite') walk(c.frames[0], m, depth + 1);
        }
      };
      walk(this.frames[Math.max(0, Math.min(frameIndex | 0, this.frames.length - 1))] || [], IDENT, 0);
      return map;
    }
    /** all named placements in a frame as a flat list: [{name, char, m, ref}, ...] (display order). */
    namedList(frameIndex) {
      const out = [];
      const walk = (list, parentM, depth) => {
        if (depth > 32) return;
        for (const p of list || []) {
          const m = mul(parentM, p.m || IDENT);
          if (p.name) out.push({ name: p.name, char: p.char, m, ref: p });
          const c = this.chars[p.char];
          if (c && c.type === 'sprite') walk(c.frames[0], m, depth + 1);
        }
      };
      walk(this.frames[Math.max(0, Math.min(frameIndex | 0, this.frames.length - 1))] || [], IDENT, 0);
      return out;
    }

    /** rendered content bounds (px) for a frame or symbol — used to fit the view. */
    measure(frameIndex, symbol) {
      let list;
      if (symbol) { const id = this.exports[symbol]; list = (id != null) ? [{ char: id, m: IDENT }] : []; }
      else { const fi = Math.max(0, Math.min((frameIndex | 0), this.frames.length - 1)); list = this.frames[fi]; }
      const bb = this._bboxList(list, 0, new Set());
      return bb ? { x: bb.x0, y: bb.y0, w: Math.max(1, bb.x1 - bb.x0), h: Math.max(1, bb.y1 - bb.y0) } : { x: 0, y: 0, w: 1, h: 1 };
    }
    _bboxOf(id, depth, seen) {
      const c = this.chars[id];
      if (!c || depth > 32 || seen.has(id)) return null;
      seen = new Set(seen); seen.add(id);
      if (c.type === 'shape' && c.bounds) return { x0: c.bounds.xMin / 20, y0: c.bounds.yMin / 20, x1: c.bounds.xMax / 20, y1: c.bounds.yMax / 20 };
      if (c.type === 'bitmap') return { x0: 0, y0: 0, x1: c.w, y1: c.h };
      if (c.type === 'sprite') return this._bboxList(c.frames[0], depth + 1, seen);
      if (c.type === 'button') {
        const src = (c.states.hit && c.states.hit.length) ? c.states.hit : (c.states.up || []);
        return this._bboxList(src, depth + 1, seen);
      }
      return null;
    }
    _bboxList(list, depth, seen) {
      let bb = null;
      for (const p of (list || [])) {
        const b = this._bboxOf(p.char, depth, seen || new Set());
        if (!b) continue;
        const m = p.m || IDENT;
        const pts = [[b.x0, b.y0], [b.x1, b.y0], [b.x0, b.y1], [b.x1, b.y1]].map(([x, y]) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]]);
        const x0 = Math.min(...pts.map(q => q[0])), y0 = Math.min(...pts.map(q => q[1]));
        const x1 = Math.max(...pts.map(q => q[0])), y1 = Math.max(...pts.map(q => q[1]));
        bb = bb ? { x0: Math.min(bb.x0, x0), y0: Math.min(bb.y0, y0), x1: Math.max(bb.x1, x1), y1: Math.max(bb.y1, y1) } : { x0, y0, x1, y1 };
      }
      return bb;
    }

    render(ctx, frameIndex, timeMs) {
      frameIndex = Math.max(0, Math.min(frameIndex | 0, this.frames.length - 1));
      this._drawList(ctx, this.frames[frameIndex], IDENT, 1, 0, timeMs == null ? null : timeMs);
    }

    /** time-driven playback: advances the root + nested sprite timelines from elapsed ms */
    renderAt(ctx, timeMs) {
      const fr = this.frameRate || 24;
      const fi = Math.floor(timeMs / 1000 * fr) % Math.max(1, this.frames.length);
      this._drawList(ctx, this.frames[fi], IDENT, 1, 0, timeMs);
    }

    /** draw an exported symbol (character) directly — Farmville assets are symbol libraries. */
    renderSymbol(ctx, name, matrix, timeMs) {
      const id = this.exports[name];
      const c = this.chars[id];
      if (!c) return false;
      const m = matrix || IDENT;
      if (c.type === 'shape') this._drawShape(ctx, c, m, 1);
      else if (c.type === 'bitmap') this._drawBitmap(ctx, c, id, m, 1);
      else if (c.type === 'text') this._drawText(ctx, c, m, 1);
      else if (c.type === 'button') this._drawButton(ctx, c, m, 1, 0, timeMs);
      else if (c.type === 'sprite') this._drawList(ctx, this._frameOf(c, timeMs), m, 1, 0, timeMs);
      return true;
    }

    _frameOf(sprite, timeMs) {
      if (timeMs == null) return sprite.frames[0];
      const fr = this.frameRate || 24;
      const n = Math.max(1, sprite.frames.length);
      return sprite.frames[Math.floor(timeMs / 1000 * fr) % n];
    }

    _drawList(ctx, list, parentM, alpha, depth, timeMs) {
      if (depth > 32) return; // guard runaway nesting
      const sorted = list.slice().sort((x, y) => (x.depth || 0) - (y.depth || 0)); // lower depth = behind
      const clips = [];  // active clip depths (ascending)
      for (const p of sorted) {
        while (clips.length && (p.depth || 0) > clips[clips.length - 1]) { ctx.restore(); clips.pop(); }
        if (p.visible === false) continue;
        const m = mul(parentM, p.m || IDENT);
        const a = alpha * (p.ct && p.ct.alphaMul != null ? p.ct.alphaMul : 1);
        if (a <= 0) continue;
        const c = this.chars[p.char];
        if (!c) continue;
        if (p.clipDepth != null) {                 // masks deeper objects; the clip object is not drawn
          ctx.save();
          const path = this._clipPath(c, m);
          if (path) ctx.clip(path);
          clips.push(p.clipDepth);
          continue;
        }
        const op = BLEND[p.blend] || 'source-over';
        const filter = this._fxString(p.filters);
        const needFx = (op !== 'source-over') || !!filter;
        if (needFx) { ctx.save(); if (op !== 'source-over') ctx.globalCompositeOperation = op; if (filter) ctx.filter = filter; }
        if (c.type === 'shape') this._drawShape(ctx, c, m, a);
        else if (c.type === 'bitmap') this._drawBitmap(ctx, c, p.char, m, a);
        else if (c.type === 'text') this._drawText(ctx, c, m, a);
        else if (c.type === 'button') this._drawButton(ctx, c, m, a, depth, timeMs);
        else if (c.type === 'sprite') this._drawList(ctx, this._frameOf(c, timeMs), m, a, depth + 1, timeMs);
        if (needFx) ctx.restore();
      }
      while (clips.length) { ctx.restore(); clips.pop(); }
    }

    /** buttons render their current interaction state (up/over/down); falls back to up. */
    _drawButton(ctx, c, m, alpha, depth, timeMs) {
      const st = this._buttonState;
      const list = (c.states && (c.states[st] || c.states.up)) || [];
      if (list.length) this._drawList(ctx, list, m, alpha, depth + 1, timeMs);
    }

    /** button hit-boxes (scene space) for a frame/symbol — for pointer interaction. */
    buttonBoxes(frameIndex, symbol) {
      let list;
      if (symbol) { const id = this.exports[symbol]; list = (id != null) ? [{ char: id, m: IDENT }] : []; }
      else { const fi = Math.max(0, Math.min((frameIndex | 0), this.frames.length - 1)); list = this.frames[fi]; }
      const out = [];
      this._collectButtons(list, IDENT, 0, new Set(), out);
      return out;
    }
    _collectButtons(list, parentM, depth, seen, out) {
      if (depth > 32) return;
      for (const p of (list || [])) {
        const m = mul(parentM, p.m || IDENT);
        const c = this.chars[p.char];
        if (!c) continue;
        if (c.type === 'button') {
          const src = (c.states.hit && c.states.hit.length) ? c.states.hit : (c.states.up || []);
          const bb = this._bboxList(src, depth + 1, seen);
          if (bb) {
            const pts = [[bb.x0, bb.y0], [bb.x1, bb.y0], [bb.x0, bb.y1], [bb.x1, bb.y1]].map(([x, y]) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]]);
            out.push({ x0: Math.min(...pts.map(q => q[0])), y0: Math.min(...pts.map(q => q[1])), x1: Math.max(...pts.map(q => q[0])), y1: Math.max(...pts.map(q => q[1])), char: p.char, name: this._nameOf(p.char) });
          }
        } else if (c.type === 'sprite') {
          this._collectButtons(this._frameOf(c, null), m, depth + 1, seen, out);
        }
      }
    }

    /** first export (class) name for a character id, or null. */
    _nameOf(id) {
      if (!this._nameById) { this._nameById = {}; for (const n in this.exports) { const i = this.exports[n]; if (this._nameById[i] === undefined) this._nameById[i] = n; } }
      return this._nameById[id] || null;
    }

    /** CSS filter string from a placement's SWF filters (blur / glow / drop shadow). */
    _fxString(filters) {
      if (!filters || !filters.length) return '';
      const parts = [];
      for (const f of filters) {
        if (f.t === 'blur') parts.push('blur(' + Math.max(f.bx, f.by).toFixed(1) + 'px)');
        else if (f.t === 'glow') {
          const c = rgba(f.color, f.alpha), n = Math.min(4, Math.max(1, Math.round(f.strength)));
          for (let i = 0; i < n; i++) parts.push('drop-shadow(0 0 ' + Math.max(f.bx, f.by).toFixed(1) + 'px ' + c + ')');
        } else if (f.t === 'shadow') {
          parts.push('drop-shadow(' + f.dx.toFixed(1) + 'px ' + f.dy.toFixed(1) + 'px ' + Math.max(f.bx, f.by).toFixed(1) + 'px ' + rgba(f.color, f.alpha) + ')');
        }
        // colormatrix / bevel: not yet approximated
      }
      return parts.join(' ');
    }

    _clipPath(c, m) {
      if (typeof Path2D === 'undefined') return null;
      const p = new Path2D();
      const add = (shape, mm) => {
        const X = (x, y) => [mm[0] * x + mm[2] * y + mm[4], mm[1] * x + mm[3] * y + mm[5]];
        for (const prim of shape.prims) for (const cmd of prim.d) {
          if (cmd[0] === 'M') { const q = X(cmd[1], cmd[2]); p.moveTo(q[0], q[1]); }
          else if (cmd[0] === 'L') { const q = X(cmd[1], cmd[2]); p.lineTo(q[0], q[1]); }
          else if (cmd[0] === 'Q') { const a = X(cmd[1], cmd[2]), b = X(cmd[3], cmd[4]); p.quadraticCurveTo(a[0], a[1], b[0], b[1]); }
          else if (cmd[0] === 'C') { const a = X(cmd[1], cmd[2]), b = X(cmd[3], cmd[4]), d = X(cmd[5], cmd[6]); p.bezierCurveTo(a[0], a[1], b[0], b[1], d[0], d[1]); }
        }
      };
      if (c.type === 'shape') add(c, m);
      else if (c.type === 'sprite') for (const pp of c.frames[0]) { const cc = this.chars[pp.char]; if (cc && cc.type === 'shape') add(cc, mul(m, pp.m || IDENT)); }
      return p;
    }

    _fillStyle(ctx, fill, alpha) {
      if (!fill) return null;
      if (fill.kind === 'solid') { ctx.globalAlpha = alpha * fill.alpha; return fill.color; }
      if (fill.kind === 'grad') return this._gradStyle(ctx, fill, alpha);
      if (fill.kind === 'bitmap') return this._bitmapStyle(ctx, fill, alpha);
      if (fill.color) { ctx.globalAlpha = alpha * (fill.alpha == null ? 1 : fill.alpha); return fill.color; } // legacy
      return null;
    }

    _gradStyle(ctx, fill, alpha) {
      const M = fill.m;                                   // twips
      const P = (x, y) => [(M[0] * x + M[2] * y + M[4]) / 20, (M[1] * x + M[3] * y + M[5]) / 20];
      const gs = 16384;                                   // gradient square half-extent (twips)
      let g;
      if (fill.gt === 'linear') { const a = P(-gs, 0), b = P(gs, 0); g = ctx.createLinearGradient(a[0], a[1], b[0], b[1]); }
      else {
        const c = P(0, 0), e = P(gs, 0), r = Math.hypot(e[0] - c[0], e[1] - c[1]) || 1;
        if (fill.gt === 'focal' && fill.focal) { const f = P(fill.focal * gs, 0); g = ctx.createRadialGradient(f[0], f[1], 0, c[0], c[1], r); }
        else g = ctx.createRadialGradient(c[0], c[1], 0, c[0], c[1], r);
      }
      ctx.globalAlpha = alpha;
      for (const s of fill.stops) g.addColorStop(Math.max(0, Math.min(1, s.r / 255)), rgba(s.color, s.alpha));
      return g;
    }

    _bitmapStyle(ctx, fill, alpha) {
      const im = this.images[fill.id];
      if (!im || !ctx.createPattern) return null;
      // Cache the CanvasPattern per (context, fill): re-creating (and re-transforming) it on every draw
      // leaks native pattern objects and can wedge the context on repeated renders of pattern-heavy scenes.
      if (!this._patCache) this._patCache = new WeakMap();
      let byFill = this._patCache.get(ctx);
      if (!byFill) { byFill = new WeakMap(); this._patCache.set(ctx, byFill); }
      let pat = byFill.get(fill);
      if (pat === undefined) {
        pat = ctx.createPattern(im, fill.repeating ? 'repeat' : 'no-repeat');
        if (pat && pat.setTransform && typeof DOMMatrix !== 'undefined') {
          const M = fill.m;
          try { pat.setTransform(new DOMMatrix([M[0] / 20, M[1] / 20, M[2] / 20, M[3] / 20, M[4] / 20, M[5] / 20])); } catch (e) { /* pattern transform unsupported */ }
        }
        byFill.set(fill, pat || null);
      }
      if (!pat) return null;
      ctx.globalAlpha = alpha;
      return pat;
    }

    _drawShape(ctx, c, m, alpha) {
      for (const prim of c.prims) {
        if (!prim.fill && !prim.stroke) continue;
        ctx.save();
        ctx.transform(m[0], m[1], m[2], m[3], m[4], m[5]);
        ctx.beginPath();
        for (const cmd of prim.d) {
          if (cmd[0] === 'M') ctx.moveTo(cmd[1], cmd[2]);
          else if (cmd[0] === 'L') ctx.lineTo(cmd[1], cmd[2]);
          else if (cmd[0] === 'Q') ctx.quadraticCurveTo(cmd[1], cmd[2], cmd[3], cmd[4]);
          else if (cmd[0] === 'C') ctx.bezierCurveTo(cmd[1], cmd[2], cmd[3], cmd[4], cmd[5], cmd[6]);
        }
        const style = this._fillStyle(ctx, prim.fill, alpha);
        if (style) { ctx.fillStyle = style; ctx.fill(); }
        if (prim.stroke && prim.stroke.width > 0) {
          ctx.globalAlpha = alpha * prim.stroke.alpha; ctx.strokeStyle = prim.stroke.color; ctx.lineWidth = prim.stroke.width; ctx.stroke();
        }
        ctx.restore();
      }
    }

    _drawBitmap(ctx, c, id, m, alpha) {
      const im = this.images[id];
      if (!im) return;
      ctx.save();
      ctx.globalAlpha = alpha;
      ctx.transform(m[0], m[1], m[2], m[3], m[4], m[5]);
      ctx.drawImage(im, 0, 0, c.w, c.h);
      ctx.restore();
    }

    /** best-effort dynamic text (DefineEditText): embedded glyph outlines when a font is present,
        else system-font draw from bounds/align/colour. */
    _drawText(ctx, c, m, alpha) {
      const font = (c.fontId != null) ? this.fonts[c.fontId] : null;
      if (font && font.glyphs && font.glyphs.length) { this._glyphText(ctx, c, m, alpha, font); return; }
      const size = (c.fontSize || 0) / 20;
      const txt = plainText(c.text);
      if (!size || !txt) return;
      const b = c.bounds || { xMin: 0, yMin: 0, xMax: 100, yMax: size * 20 };
      const col = c.color || { color: '#000000', alpha: 1 };
      ctx.save();
      ctx.globalAlpha = alpha * col.alpha;
      ctx.transform(m[0], m[1], m[2], m[3], m[4], m[5]);
      ctx.fillStyle = col.color;
      const family = c.fontClass || fontFace(c.text) || 'sans-serif';
      ctx.font = size + 'px "' + family + '", sans-serif';
      ctx.textBaseline = 'alphabetic';
      const bx0 = b.xMin / 20, bx1 = b.xMax / 20, by = b.yMin / 20 + size * 0.9;
      let x = bx0;
      if (c.align === 1) { ctx.textAlign = 'right'; x = bx1; }
      else if (c.align === 2) { ctx.textAlign = 'center'; x = (bx0 + bx1) / 2; }
      else { ctx.textAlign = 'left'; x = bx0; }
      const lines = txt.split(/\r\n|\r|\n/);
      for (let i = 0; i < lines.length; i++) ctx.fillText(lines[i], x, by + i * (size * 1.2));
      ctx.restore();
    }

    /** 1:1 text: lay out embedded-font glyph outlines at the text's size/align/colour. */
    _glyphText(ctx, c, m, alpha, font) {
      const txt = plainText(c.text);
      if (!txt) return;
      // Glyph outlines are stored at 1/twips (÷20) scale; advances + ascent/descent are raw font
      // units. Scale each accordingly.
      const Sglyph = ((c.fontSize || 0) / font.em);
      const Smet = Sglyph / 20;
      if (!font._codeMap) { const map = {}; for (let i = 0; i < font.codeUnits.length; i++) map[font.codeUnits[i]] = i; font._codeMap = map; }
      const col = c.color || { color: '#000000', alpha: 1 };
      const b = c.bounds || { xMin: 0, yMin: 0, xMax: 100, yMax: (font.ascent + font.descent) };
      const bx0 = b.xMin / 20, bx1 = b.xMax / 20;
      const baseline = b.yMin / 20 + font.ascent * Smet;
      const lineH = (font.ascent + font.descent) * Smet + (c.leading || 0) / 20;
      const lines = txt.split(/\r\n|\r|\n/);
      ctx.save();
      ctx.globalAlpha = alpha * col.alpha;
      ctx.fillStyle = col.color;
      for (let li = 0; li < lines.length; li++) {
        const line = lines[li];
        let w = 0;
        for (const ch of line) { const gi = font._codeMap[ch.codePointAt(0)]; if (gi !== undefined) w += font.glyphs[gi].adv * Smet; }
        let x = bx0;
        if (c.align === 1) x = bx1 - w; else if (c.align === 2) x = (bx0 + bx1) / 2 - w / 2;
        const y = baseline + li * lineH;
        for (const ch of line) {
          const gi = font._codeMap[ch.codePointAt(0)];
          if (gi === undefined) continue;
          const g = font.glyphs[gi];
          if (g.prims && g.prims.length) {
            ctx.save();
            ctx.transform(m[0], m[1], m[2], m[3], m[4], m[5]);
            ctx.translate(x, y);
            ctx.scale(Sglyph, Sglyph);
            ctx.beginPath();
            for (const prim of g.prims) for (const cmd of prim.d) {
              if (cmd[0] === 'M') ctx.moveTo(cmd[1], cmd[2]);
              else if (cmd[0] === 'L') ctx.lineTo(cmd[1], cmd[2]);
              else if (cmd[0] === 'Q') ctx.quadraticCurveTo(cmd[1], cmd[2], cmd[3], cmd[4]);
              else if (cmd[0] === 'C') ctx.bezierCurveTo(cmd[1], cmd[2], cmd[3], cmd[4], cmd[5], cmd[6]);
            }
            ctx.fill();
            ctx.restore();
          }
          x += g.adv * Smet;
        }
      }
      ctx.restore();
    }
  }

  global.FVScene = FVScene;
  global.FVScene_mul = mul;
  if (typeof module !== 'undefined' && module.exports) module.exports = { FVScene, mul, IDENT };
})(typeof window !== 'undefined' ? window : globalThis);

/* FV-NG — instance-based display runtime (Zw widget-layer foundation).
 *
 * FVScene renders shared character *definitions*; that is fine for static farms/intro screens, but the
 * game's window layer (Widgets.Core.*, FarmWindow, MarketWindow, …) mutates individual *instances* —
 * e.g. each market card's own `title_tf`. In Flash every timeline placement is a distinct DisplayObject
 * with its own children, so we must instantiate the display list as a tree (clone the symbol's frame per
 * placement) rather than walk shared defs.
 *
 * FVStage turns an FVScene into that mutable tree and renders it with the same primitive routines, so a
 * port of the AS3 widget classes can show/hide, retext, restate and hit-test named instances.
 *
 * Usage:
 *   const stage = new FVStage(scene);
 *   stage.instantiate(0);                 // build from root frame 0
 *   stage.render(ctx);
 *   const n = stage.find('slot_0_mc');    // node with name
 *   n.child('title_tf').setText('12drumtree');
 */
(function (global) {
  'use strict';

  const IDENT = [1, 0, 0, 1, 0, 0];
  function mul(P, C) {
    return [
      P[0] * C[0] + P[2] * C[1],
      P[1] * C[0] + P[3] * C[1],
      P[0] * C[2] + P[2] * C[3],
      P[1] * C[2] + P[3] * C[3],
      P[0] * C[4] + P[2] * C[5] + P[4],
      P[1] * C[4] + P[3] * C[5] + P[5],
    ];
  }
  const BLEND = { 0: 'source-over', 1: 'source-over', 2: 'multiply', 3: 'screen', 4: 'lighten', 5: 'darken', 6: 'difference', 7: 'lighter', 8: 'source-over', 9: 'source-over', 10: 'source-over', 11: 'destination-out', 12: 'overlay', 13: 'hard-light' };

  let UID = 0;

  /** A display-list instance: independent of every other placement of the same symbol. */
  class FVNode {
    constructor(stage, char, m, name, pl, parent) {
      this.stage = stage; this.scene = stage.scene;
      this.uid = ++UID; this.char = char; this.def = this.scene.chars[char];
      this.m = (m || IDENT).slice(); this.name = name || null; this.parent = parent || null;
      this.visible = pl ? pl.visible !== false : true;
      this.alpha = 1; this.state = 'up';
      this.blend = pl && pl.blend || 0; this.filters = (pl && pl.filters) || null;
      this.clipDepth = pl && pl.clipDepth != null ? pl.clipDepth : null;
      this.ct = (pl && pl.ct) || null;
      this.depth = pl && pl.depth != null ? pl.depth : 0;
      this.children = null; this.states = null;
      const d = this.def;
      if (!d) return;
      if (d.type === 'text') this.def = Object.assign({}, d);            // own text per instance
      else if (d.type === 'sprite') this.children = (d.frames[0] || []).map(p => new FVNode(stage, p.char, p.m, p.name, p, this));
      else if (d.type === 'button') { this.states = {}; for (const k in d.states) this.states[k] = (d.states[k] || []).map(p => new FVNode(stage, p.char, p.m, p.name, p, this)); }
    }
    get type() { return this.def && this.def.type; }
    setText(s) { if (this.def && this.def.type === 'text') this.def.text = s == null ? '' : String(s); return this; }
    get text() { return this.def && this.def.text; }
    show(on) { this.visible = on !== false; return this; }
    setMatrix(m) { this.m = (m || IDENT).slice(); return this; }
    child(name) { return this.children ? this.children.find(c => c.name === name) || null : null; }
    walk(fn) { fn(this); if (this.children) for (const c of this.children) c.walk(fn); return this; }
    /** absolute matrix (accumulated from the root). */
    abs() { let m = this.m.slice(), p = this.parent; while (p) { m = mul(p.m, m); p = p.parent; } return m; }
    localBox() { if (this._lb === undefined) this._lb = this.scene._bboxOf(this.char, 0, new Set()); return this._lb; }
    /** content bbox in scene space (for hit-testing), or null. */
    box() {
      const b = this.localBox(); if (!b) return null;
      const m = this.abs();
      const pts = [[b.x0, b.y0], [b.x1, b.y0], [b.x0, b.y1], [b.x1, b.y1]].map(([x, y]) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]]);
      return { x0: Math.min(...pts.map(q => q[0])), y0: Math.min(...pts.map(q => q[1])), x1: Math.max(...pts.map(q => q[0])), y1: Math.max(...pts.map(q => q[1])) };
    }
  }

  class FVStage {
    constructor(scene) { this.scene = scene; this.root = null; }
    instantiate(frameIndex) {
      const fi = Math.max(0, Math.min((frameIndex | 0), this.scene.frames.length - 1));
      this.root = new FVNode(this, -1, IDENT, null, null, null);   // synthetic container
      this.root.def = { type: 'sprite' };
      this.root.children = (this.scene.frames[fi] || []).map(p => new FVNode(this, p.char, p.m, p.name, p, this.root));
      return this.root;
    }
    /** depth-first first node with the given instance name. */
    find(name) {
      let hit = null;
      this._walk(this.root, n => { if (!hit && n.name === name) hit = n; });
      return hit;
    }
    findAll(name) { const out = []; this._walk(this.root, n => { if (n.name === name) out.push(n); }); return out; }
    _walk(n, fn) { if (!n) return; fn(n); if (n.children) for (const c of n.children) this._walk(c, fn); if (n.states) for (const k in n.states) for (const c of n.states[k]) this._walk(c, fn); }

    /** true if this node and all ancestors are visible. */
    static visible(n) { while (n) { if (n.visible === false) return false; n = n.parent; } return true; }
    /** smallest named, effectively-visible node whose content box contains (x,y) in scene space. */
    hitTest(x, y) {
      let best = null, area = Infinity;
      const scan = n => {
        if (!n) return;
        if (n.name && FVStage.visible(n)) {
          const b = n.box();
          if (b && x >= b.x0 && x <= b.x1 && y >= b.y0 && y <= b.y1) {
            const a = (b.x1 - b.x0) * (b.y1 - b.y0);
            if (a < area) { area = a; best = n; }
          }
        }
        if (n.children) for (const c of n.children) scan(c);
        if (n.states) for (const k in n.states) for (const c of n.states[k]) scan(c);
      };
      scan(this.root);
      return best;
    }

    render(ctx) { this._children(ctx, this.root.children, IDENT, 1); }

    _nodeList(n) { return n.type === 'button' ? (n.states[n.state] || n.states.up || []) : (n.children || []); }

    _children(ctx, list, parentM, parentAlpha) {
      if (!list) return;
      const sorted = list.slice().sort((a, b) => (a.depth || 0) - (b.depth || 0));
      const clips = [];
      for (const n of sorted) {
        while (clips.length && (n.depth || 0) > clips[clips.length - 1]) { ctx.restore(); clips.pop(); }
        if (n.visible === false) continue;
        const a = parentAlpha * (n.alpha == null ? 1 : n.alpha) * (n.ct && n.ct.alphaMul != null ? n.ct.alphaMul : 1);
        if (a <= 0) continue;
        const m = mul(parentM, n.m);
        const def = n.def; if (!def) continue;
        if (n.clipDepth != null) { ctx.save(); const path = this.scene._clipPath(def, m); if (path) ctx.clip(path); clips.push(n.clipDepth); continue; }
        const op = BLEND[n.blend] || 'source-over';
        const filter = this.scene._fxString(n.filters);
        const needFx = (op !== 'source-over') || !!filter;
        if (needFx) { ctx.save(); if (op !== 'source-over') ctx.globalCompositeOperation = op; if (filter) ctx.filter = filter; }
        const t = def.type;
        if (t === 'shape') this.scene._drawShape(ctx, def, m, a);
        else if (t === 'bitmap') this.scene._drawBitmap(ctx, def, n.char, m, a);
        else if (t === 'text') this.scene._drawText(ctx, def, m, a);
        else if (t === 'button') this._children(ctx, n.states[n.state] || n.states.up || [], m, a);
        else if (t === 'sprite') this._children(ctx, n.children, m, a);
        if (needFx) ctx.restore();
      }
      while (clips.length) { ctx.restore(); clips.pop(); }
    }
  }

  global.FVStage = FVStage;
  global.FVNode = FVNode;
  if (typeof module !== 'undefined' && module.exports) module.exports = { FVStage, FVNode };
})(typeof window !== 'undefined' ? window : globalThis);

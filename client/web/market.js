/* FV-NG — Market window (1:1): renders the original market SWF window and populates its named item
 * slots (`slot_0_mc`..) with real catalog items. Uses the scene engine's `namedMap` to locate the slots
 * so the original chrome (frame, tabs, search) is reproduced, with real cards drawn into the grid.
 *
 * Usage:
 *   const mkt = new FVMarket(canvas, { build, onBuy, artResolver });
 *   await mkt.open('dlg_FV_Market_7_organic');
 *   mkt.setItems(items, tab);       // items: [{name,type,cost,cash,grow_time,required_level}]
 *   // in the render loop or on change: mkt.render();
 *   // pointer: mkt.onMove(e) / mkt.onUp(e)  -> BUY
 */
(function (global) {
  'use strict';
  const sql = (h) => h; // no-op

  class FVMarket {
    constructor(canvas, opts) {
      opts = opts || {};
      this.canvas = canvas;
      this.ctx = canvas.getContext('2d');
      this.build = opts.build || '1';
      this.onBuy = opts.onBuy || null;
      this.artFor = opts.artFor || null;   // (name) -> {canvas,ready} original item art
      this.scene = null;
      this.items = [];
      this.tab = '';
      this.rects = [];       // BUY hit regions (canvas px)
      this.hover = -1;
      this.dpr = Math.min(global.devicePixelRatio || 1, 2);
      this._art = {};        // name -> HTMLCanvasElement
    }

    async open(stem) {
      const raw = await fetch('scenes/' + stem + '.scene.json?v=' + this.build).then(r => r.json());
      const sc = new FVScene(raw);
      await sc.load();
      this.scene = sc;
      this._layout();
      // The market window is a composite: the card container renders every purchase state at once and the
      // main/sub nav duplicate our own tab bar. Hide those so only the frame shows through the overlay.
      this._hide(['marketCards_mc', 'mainNav_mc', 'subNav_mc', 'noResults_tf']);
      this.baked = bakeScene(sc, this.bounds, this.dpr);
      return this;
    }
    _hide(names) {
      const set = {}; for (const n of names) set[n] = 1;
      for (const p of this.scene.namedList(0)) if (set[p.name] && p.ref) p.ref.visible = false;
    }

    _layout() {
      const sc = this.scene;
      // the live item grid is `marketCards_mc` (4 columns × 2 rows); absolute slot origins taken from
      // the converted scene (the many other `slot_N_mc` are promo/mini/charity card containers).
      this.colX = [18, 261, 504, 747];
      this.rowY0 = 119; this.rowH = 171; this.colW = 243;
      this.cardW = this.colW + 8; this.cardH = this.rowH;   // native card art spills ~8px left of origin
      this.bounds = sc.measure(0, '');
    }

    _fit(W, H) {
      const b = this.bounds;
      const s = Math.min(W / b.w, H / b.h);
      return { s, tx: (W - b.w * s) / 2 - b.x * s, ty: (H - b.h * s) / 2 - b.y * s };
    }

    setItems(items, tab) { this.items = items || []; this.tab = tab || ''; this.render(); }

    render() {
      const cv = this.canvas, ctx = this.ctx;
      const W = cv.clientWidth || 960, H = cv.clientHeight || 560;
      if (cv.width !== Math.round(W * this.dpr) || cv.height !== Math.round(H * this.dpr)) {
        cv.width = Math.round(W * this.dpr); cv.height = Math.round(H * this.dpr);
      }
      ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0);
      ctx.clearRect(0, 0, W, H);
      if (!this.scene) return;
      const f = this._fit(W, H);
      // 1) the original window chrome (frame, tabs, search, nav) — blitted from the one-time bake
      ctx.save();
      ctx.translate(f.tx, f.ty); ctx.scale(f.s, f.s);
      if (this.baked) ctx.drawImage(this.baked, this.bounds.x, this.bounds.y, this.bounds.w, this.bounds.h);
      ctx.restore();
      // 2) mask the SWF's placeholder grid, then draw real item cards into the native card slots
      const X = x => f.tx + x * f.s, Y = y => f.ty + y * f.s;
      const gx0 = this.colX[0] - 12, gy0 = this.rowY0 - 4, gx1 = this.colX[this.colX.length - 1] + this.cardW + 6, gy1 = this.rowY0 + 2 * this.rowH + 4;
      ctx.fillStyle = '#f2ead2';
      ctx.fillRect(X(gx0), Y(gy0), (gx1 - gx0) * f.s, (gy1 - gy0) * f.s);
      this.rects = [];
      const perPage = this.colX.length * 2;
      for (let i = 0; i < Math.min(this.items.length, perPage); i++) {
        const col = i % this.colX.length, row = Math.floor(i / this.colX.length);
        const sx = this.colX[col], sy = this.rowY0 + row * this.rowH;
        this._drawCard(ctx, X(sx - 8), Y(sy), this.cardW * f.s, this.cardH * f.s, this.items[i], i);
      }
      this.perPage = perPage;
    }

    _drawCard(ctx, x, y, w, h, it, idx) {
      // parchment card matching the original card look
      const r = Math.min(10, w * 0.06);
      ctx.save();
      roundRect(ctx, x, y, w, h, r);
      const grad = ctx.createLinearGradient(x, y, x, y + h);
      grad.addColorStop(0, '#f9efd6'); grad.addColorStop(1, '#e7d4a6');
      ctx.fillStyle = grad; ctx.fill();
      ctx.lineWidth = 2; ctx.strokeStyle = '#b98f3e'; ctx.stroke();
      // art
      const art = this._art[it.name];
      const pad = 6, artH = h * 0.5;
      if (art && art.ready) {
        const sc = Math.min((w - pad * 2) / art.width, artH / art.height);
        ctx.drawImage(art, x + (w - art.width * sc) / 2, y + pad + (artH - art.height * sc) / 2, art.width * sc, art.height * sc);
      } else if (art === undefined && this.artFor) {
        this._loadArt(it.name);
      }
      // name
      ctx.fillStyle = '#4a3512'; ctx.textAlign = 'center'; ctx.textBaseline = 'top';
      ctx.font = '600 ' + Math.max(10, h * 0.11) + 'px system-ui,sans-serif';
      const nm = it.name.length > 18 ? it.name.slice(0, 17) + '…' : it.name;
      ctx.fillText(nm, x + w / 2, y + artH + 8);
      // meta (grow / level) + price + BUY
      ctx.font = Math.max(9, h * 0.09) + 'px system-ui,sans-serif'; ctx.fillStyle = '#2a6e2a';
      let meta = '';
      if (it.grow_time) meta += (it.grow_time >= 1 ? (Math.round(it.grow_time * 10) / 10) + 'd' : Math.round(it.grow_time * 24) + 'h') + ' ';
      if (it.required_level) meta += 'Lv ' + it.required_level;
      if (meta) ctx.fillText(meta, x + w / 2, y + artH + 8 + h * 0.13);
      ctx.fillStyle = '#7a5a18'; ctx.textAlign = 'left';
      ctx.fillText(it.cost != null ? it.cost.toLocaleString() + 'g' : '', x + pad + 2, y + h - h * 0.16);
      // BUY button
      if (it.cost != null) {
        const bw = w * 0.32, bh = h * 0.15, bx = x + w - bw - pad, by = y + h - bh - pad;
        const bg = ctx.createLinearGradient(bx, by, bx, by + bh);
        bg.addColorStop(0, '#e8c256'); bg.addColorStop(1, '#a9842a');
        ctx.fillStyle = bg; roundRect(ctx, bx, by, bw, bh, 5); ctx.fill();
        ctx.strokeStyle = '#8a6a26'; ctx.lineWidth = 1; ctx.stroke();
        ctx.fillStyle = '#2a1e06'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
        ctx.font = '700 ' + Math.max(9, h * 0.1) + 'px system-ui,sans-serif';
        ctx.fillText('BUY', bx + bw / 2, by + bh / 2 + 1);
        this.rects.push({ x: bx, y: by, w: bw, h: bh, name: it.name, idx });
      }
      ctx.restore();
    }

    _loadArt(name) {
      if (this._art[name] === 'loading') return;
      this._art[name] = 'loading';
      Promise.resolve(this.artFor(name)).then(c => { if (c) { this._art[name] = c; this.render(); } else this._art[name] = null; });
    }

    hit(x, y) { for (let i = this.rects.length - 1; i >= 0; i--) { const r = this.rects[i]; if (x >= r.x && x <= r.x + r.w && y >= r.y && y <= r.y + r.h) return r; } return null; }
    onMove(e) { const r = this.canvas.getBoundingClientRect(); this.canvas.style.cursor = this.hit(e.clientX - r.left, e.clientY - r.top) ? 'pointer' : 'default'; }
    onUp(e) { const r = this.canvas.getBoundingClientRect(); const b = this.hit(e.clientX - r.left, e.clientY - r.top); if (b && this.onBuy) this.onBuy(b.name, b.idx); return !!b; }
  }

  function roundRect(ctx, x, y, w, h, r) {
    r = Math.min(r, w / 2, h / 2);
    ctx.beginPath();
    ctx.moveTo(x + r, y); ctx.arcTo(x + w, y, x + w, y + h, r); ctx.arcTo(x + w, y + h, x, y + h, r);
    ctx.arcTo(x, y + h, x, y, r); ctx.arcTo(x, y, x + w, y, r); ctx.closePath();
  }

  // Render the window scene ONCE into an offscreen bitmap. Re-rendering these scenes on a live 2D
  // canvas each frame is unsafe: SWF bitmap-fill patterns re-created per draw can wedge the context.
  function bakeScene(sc, b, dpr) {
    const c = document.createElement('canvas');
    c.width = Math.max(1, Math.round(b.w * dpr)); c.height = Math.max(1, Math.round(b.h * dpr));
    const cx = c.getContext('2d');
    cx.setTransform(dpr, 0, 0, dpr, -b.x * dpr, -b.y * dpr);
    sc.render(cx, 0);
    return c;
  }

  /** Storage window binder (3×2 slots: slot_0_mc..slot_5_mc) — renders the original window and fills its
   * native item-card fields (title_tf / icon_mc / itemCount_tf / desc_tf) with the player's inventory,
   * using the window's own Sell/Use buttons. Placeholder data fields are blanked at bake time. */
  class FVStorage {
    constructor(canvas, opts) {
      opts = opts || {};
      this.canvas = canvas; this.ctx = canvas.getContext('2d');
      this.build = opts.build || '1'; this.onAction = opts.onAction || null; this.artFor = opts.artFor || null; this.hasScene = opts.hasScene || null;
      this.dpr = Math.min(global.devicePixelRatio || 1, 2);
      this.scene = null; this.items = []; this.rects = []; this._art = {};
      this.capacity = ''; this.current = ''; this.page = 0; this.pageSize = 6;
      this._slotFieldNames = ['title_tf', 'icon_mc', 'itemCount_tf', 'desc_tf', 'extra_tf', 'sell_bt', 'use_bt'];
      this._dataFields = { title_tf: 1, itemCount_tf: 1, desc_tf: 1, extra_tf: 1 };
      this._winFields = { capacity_tf: 1, current_tf: 1, noResults_tf: 1, page_tf: 1 };
    }
    async open(stem) {
      const raw = await fetch('scenes/' + stem + '.scene.json?v=' + this.build).then(r => r.json());
      const sc = new FVScene(raw); await sc.load(); this.scene = sc;
      this._layout();
      this._blank(this._dataFields, true); this._blank(this._winFields, false);
      this._bakedCount = -1;
      return this;
    }
    get pages() { return Math.max(1, Math.ceil(this.items.length / this.pageSize)); }
    _layout() {
      const m = this.scene.namedMap(0);
      const nl = this.scene.namedList(0);
      this.slots = []; this.slotRefs = [];
      for (const p of nl) { const mt = p.name.match(/^slot_(\d+)_mc$/); if (mt) { this.slots[+mt[1]] = p.m; this.slotRefs[+mt[1]] = p.ref; } }
      const s0 = this.slots[0] || [1, 0, 0, 1, 52, 288.95], s1 = this.slots[1] || [1, 0, 0, 1, 270.7, 288.95], s3 = this.slots[3] || [1, 0, 0, 1, 52, 400.45];
      this.colX = [s0[4], s1[4], (this.slots[2] || [0, 0, 0, 0, s1[4] + (s1[4] - s0[4]), 0])[4]];
      this.rowY = [s0[5], s3[5]];
      this.colW = this.colX[1] - this.colX[0]; this.rowH = this.rowY[1] - this.rowY[0];
      this.bounds = this.scene.measure(0, '');
      this.slotFields = this.slots.map(s => s ? this._fieldsInCell(nl, s[4], s[5]) : null);
      const pick = n => { let best = null, bd = 1e9; for (const p of nl) if (p.name === n) { const d = p.m[4] * p.m[4] + p.m[5] * p.m[5]; if (d < bd) { bd = d; best = p; } } return best; };
      this.capP = pick('capacity_tf'); this.curP = pick('current_tf');
      this.pageP = pick('page_tf');
      this.closeP = pick('close_bt'); this.expandP = pick('expand_bt');
      this.arrowP = { prev: pick('leftArrow_bt'), next: pick('rightArrow_bt') };
    }
    _rebake(used) {
      for (let i = 0; i < this.slotRefs.length; i++) { const r = this.slotRefs[i]; if (r) r.visible = (i < used); }
      this.baked = bakeScene(this.scene, this.bounds, this.dpr);
      this._bakedCount = used;
    }
    _fieldsInCell(nl, sx, sy) {
      const f = {};
      for (const p of nl) {
        if (this._slotFieldNames.indexOf(p.name) < 0) continue;
        if (p.m[4] >= sx - 8 && p.m[4] <= sx + this.colW + 4 && p.m[5] >= sy - 14 && p.m[5] <= sy + this.rowH + 4) {
          const d = Math.abs(p.m[4] - sx) + Math.abs(p.m[5] - sy);
          if (!f[p.name] || d < f[p.name].d) f[p.name] = { m: p.m, char: p.char, d };
        }
      }
      return f;
    }
    _blank(fields, inCell) {
      const seen = {};
      for (const p of this.scene.namedList(0)) {
        if (!fields[p.name] || seen[p.char]) continue;
        if (inCell) {
          const inside = this.slots.some(s => s && p.m[4] >= s[4] - 8 && p.m[4] <= s[4] + this.colW + 4 && p.m[5] >= s[5] - 14 && p.m[5] <= s[5] + this.rowH + 4);
          if (!inside) continue;
        }
        const c = this.scene.chars[p.char];
        if (c && c.type === 'text') { c.text = ''; seen[p.char] = 1; }
      }
    }
    _fit(W, H) { const b = this.bounds; const s = Math.min(W / b.w, H / b.h) * 0.98; return { s, tx: (W - b.w * s) / 2 - b.x * s, ty: (H - b.h * s) / 2 - b.y * s }; }
    setState(st) { this.items = (st && st.items) || []; this.capacity = (st && st.capacity) || ''; this.current = (st && st.current) || ''; this.page = 0; this.render(); }
    render() {
      const cv = this.canvas, ctx = this.ctx; const W = cv.clientWidth || 800, H = cv.clientHeight || 620;
      if (cv.width !== Math.round(W * this.dpr) || cv.height !== Math.round(H * this.dpr)) { cv.width = Math.round(W * this.dpr); cv.height = Math.round(H * this.dpr); }
      ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0); ctx.clearRect(0, 0, W, H);
      if (!this.scene) return;
      const f = this._fit(W, H);
      const X = x => f.tx + x * f.s, Y = y => f.ty + y * f.s;
      const base = this.page * this.pageSize;
      const used = Math.max(0, Math.min(this.pageSize, this.items.length - base));
      if (used !== this._bakedCount) this._rebake(used);
      ctx.save(); ctx.translate(f.tx, f.ty); ctx.scale(f.s, f.s);
      if (this.baked) ctx.drawImage(this.baked, this.bounds.x, this.bounds.y, this.bounds.w, this.bounds.h);
      ctx.restore();
      this.rects = [];
      for (let i = 0; i < used; i++) {
        const it = this.items[base + i], fl = this.slotFields[i];
        if (!it || !fl) continue;
        ctx.save(); ctx.translate(f.tx, f.ty); ctx.scale(f.s, f.s);
        this._fillSlot(ctx, fl, it);
        ctx.restore();
        this._slotButtons(X, Y, f, fl, it);
      }
      ctx.save(); ctx.translate(f.tx, f.ty); ctx.scale(f.s, f.s);
      this._value(ctx, this.capP, this.capacity); this._value(ctx, this.curP, this.current);
      if (this.pageP) this._field(ctx, this.pageP, 'Page ' + (this.page + 1) + ' of ' + this.pages);
      ctx.restore();
      this._hot(X, Y, f, this.closeP, 'close', 30, 30);
      this._hot(X, Y, f, this.expandP, 'expand', 200, 40);
      if (this.pages > 1) { this._hot(X, Y, f, this.arrowP.prev, 'prev', 44, 90); this._hot(X, Y, f, this.arrowP.next, 'next', 44, 90); }
    }
    _fillSlot(ctx, fl, it) {
      const ic = fl.icon_mc && fl.icon_mc.m, tt = fl.title_tf && fl.title_tf.m;
      if (ic && this.artFor) {
        const bw = (tt ? tt[4] : ic[4] + 58) - ic[4] - 4, bh = 58;
        const art = this._art[it.name];
        if (art && art.ready) { const sc = Math.min(bw / art.width, bh / art.height); ctx.drawImage(art, ic[4] + (bw - art.width * sc) / 2, ic[5] + (bh - art.height * sc) / 2, art.width * sc, art.height * sc); }
        else if (art === undefined) this._loadArt(it.name);
      }
      if (fl.title_tf) this._field(ctx, fl.title_tf, it.name);
      if (fl.desc_tf) this._field(ctx, fl.desc_tf, it.category || it.type || '');
      if (fl.itemCount_tf) this._field(ctx, fl.itemCount_tf, 'x' + (it.quantity || 1));
    }
    _slotButtons(X, Y, f, fl, it) {
      const S = f.s;
      const sb = fl.sell_bt && fl.sell_bt.m;
      if (sb) this.rects.push({ action: 'sell', name: it.name, x: X(sb[4] - 1), y: Y(sb[5] - 1), w: 48 * S, h: 22 * S });
      const ub = fl.use_bt && fl.use_bt.m;
      if (ub && this.hasScene && this.hasScene(it.name)) this.rects.push({ action: 'place', name: it.name, x: X(ub[4] - 1), y: Y(ub[5] - 1), w: 67 * S, h: 24 * S });
    }
    _hot(X, Y, f, p, action, w, h) { if (!p) return; this.rects.push({ action, x: X(p.m[4] - w / 2), y: Y(p.m[5] - h / 2), w: w * f.s, h: h * f.s }); }
    _value(ctx, p, val) { if (p) this._field(ctx, p, String(val == null ? '' : val)); }
    // draw text at the SWF field's own origin/size/colour/align (matches scene2d._drawText)
    _field(ctx, field, str) {
      const c = this.scene.chars[field.char]; if (!c || c.type !== 'text') return;
      const size = (c.fontSize || 0) / 20; if (!size || !str) return;
      const b = c.bounds || { xMin: 0, yMin: 0, xMax: 100, yMax: size * 20 };
      const bx0 = b.xMin / 20, bx1 = b.xMax / 20, by = b.yMin / 20 + size * 0.9;
      ctx.save(); ctx.translate(field.m[4], field.m[5]);
      ctx.fillStyle = (c.color && c.color.color) || '#50948b';
      ctx.font = size + 'px Merkin,Georgia,serif';
      ctx.textBaseline = 'alphabetic';
      let x = bx0;
      if (c.align === 1) { ctx.textAlign = 'right'; x = bx1; }
      else if (c.align === 2) { ctx.textAlign = 'center'; x = (bx0 + bx1) / 2; }
      else { ctx.textAlign = 'left'; }
      ctx.fillText(str, x, by);
      ctx.restore();
    }
    _loadArt(name) { if (this._art[name] === 'loading') return; this._art[name] = 'loading'; Promise.resolve(this.artFor(name)).then(c => { this._art[name] = c; this.render(); }); }
    hit(x, y) { for (let i = this.rects.length - 1; i >= 0; i--) { const r = this.rects[i]; if (x >= r.x && x <= r.x + r.w && y >= r.y && y <= r.y + r.h) return r; } return null; }
    onMove(e) { const r = this.canvas.getBoundingClientRect(); this.canvas.style.cursor = this.hit(e.clientX - r.left, e.clientY - r.top) ? 'pointer' : 'default'; }
    onUp(e) {
      const r = this.canvas.getBoundingClientRect(); const b = this.hit(e.clientX - r.left, e.clientY - r.top);
      if (!b) return false;
      if (b.action === 'prev' || b.action === 'next') { this.page = Math.max(0, Math.min(this.pages - 1, this.page + (b.action === 'next' ? 1 : -1))); this.render(); return true; }
      if (this.onAction) this.onAction(b.action, b.name);
      return true;
    }
  }

  global.FVMarket = FVMarket;
  global.FVStorage = FVStorage;
  if (typeof module !== 'undefined' && module.exports) module.exports = { FVMarket, FVStorage };
})(typeof window !== 'undefined' ? window : globalThis);

/* FV-NG — port of the game's widget layer (Widgets.Core.* / Widgets.Frames.*) over FVStage nodes.
 *
 * Mirrors the AS3 classes the Market/Storage/etc. windows are built from, so window logic can be ported
 * nearly verbatim:
 *   ZwBaseWidget / ZwWidget  — wrap a named instance (visible / alpha / x / y / enabled)
 *   ZwFrame                  — hides all its child instances up front; widgets then show what they use
 *   ZwTextField              — text/html setter for a text instance
 *   ZwButton                 — a clickable instance (callback)
 *   ZwSlotFrame              — a card; populate(data) / clearView()
 *   ZwAbstractSlotContainerFrame / ZwPagableSlotContainerFrame — the slot grid + paging
 *   ZwWindow                 — scene-backed window (fit, render, pointer hit/click dispatch)
 *
 * A click is dispatched by walking up from the hit node to the nearest ancestor that a ZwButton bound.
 */
(function (global) {
  'use strict';

  function hideDescendants(node) { node.walk(n => { if (n !== node) n.visible = false; }); }
  function bindClick(node, cb) { if (!cb) return; (node._clicks = node._clicks || []).push(cb); }

  class ZwBaseWidget {
    constructor(node) { this.node = node; }
    get name() { return this.node.name; }
    get visible() { return this.node.visible; } set visible(v) { this.node.show(v); }
    get alpha() { return this.node.alpha; } set alpha(v) { this.node.alpha = v; }
    get x() { return this.node.m[4]; } set x(v) { this.node.m[4] = v; }
    get y() { return this.node.m[5]; } set y(v) { this.node.m[5] = v; }
    get enabled() { return this._enabled !== false; } set enabled(v) { this._enabled = v; }
  }

  class ZwWidget extends ZwBaseWidget {}

  class ZwFrame extends ZwWidget {
    constructor(node) {
      super(node);
      this.widgets = [];
      // ZwFrame hides the child *elements* it can manage (named instances); unnamed timeline art (card
      // paper, window frame graphics) stays visible.
      if (node.children) for (const c of node.children) if (c.name) c.visible = false;
    }
    addWidget(w, visible = true) { (this.widgets = this.widgets || []).push(w); if (w && w.node) w.node.show(visible !== false); return w; }
    getWidget(node) { return (this.widgets || []).find(w => w.node === node) || null; }
    hideAllWidgets() { for (const w of (this.widgets || [])) if (w.node) w.node.show(false); }
    child(name) { return this.node.child(name); }
  }

  class ZwTextField extends ZwWidget {
    constructor(node, text) { super(node); if (text != null) this.text = text; }
    set text(v) { this.node.setText(v); }
    get text() { return this.node.text; }
    set color(hex) { if (this.node.def) this.node.def.color = { color: hex, alpha: 1 }; }
    get color() { return this.node.def && this.node.def.color && this.node.def.color.color; }
  }

  class ZwButton extends ZwWidget {
    constructor(node, callback) { super(node); this._cb = callback || null; if (callback) bindClick(node, callback); }
    set callback(cb) { this._cb = cb; }
    get callback() { return this._cb; }
  }

  /** a card instance: clearView() hides every child; populate() fills by name (subclass override). */
  class ZwSlotFrame extends ZwFrame {
    populate(data) { this.clearView(); }
    // AS3 clearView() hides only the registered *widgets*, not the card's timeline art, so we hide named
    // instances only (the card background/among unnamed graphics stay visible).
    clearView() { this.node.walk(n => { if (n !== this.node && n.name) n.visible = false; }); }
  }

  /** FarmTabMenu: a tab strip (mainNav_mc / subNav_mc / bottomTabs_mc). Populates tab_<i>_bt from items. */
  class FarmTabMenu extends ZwFrame {
    constructor(node, onSelect, items, wrap, perRow) { super(node); this.onSelect = onSelect || null; this.perRow = perRow || items.length || 99; this.setItems(items || []); }
    get numItems() { return this._items.length; }
    getItem(i) { return this._items[i]; }
    setItems(items) {
      this._items = items || [];
      let i = 0;
      while (true) {
        const el = this.node.child('tab_' + i + '_bt');
        if (!el) break;
        const it = this._items[i];
        if (it) {
          el.show(true);
          const t = el.child('tabTitle_tf') || el.child('tabTitleLight_tf');
          if (t) { t.show(true); t.setText(it.label != null ? it.label : (it.data || '')); }
          for (const d of ['tabTitleDisabled_tf', 'tabTitleLight_tf', 'expiration_mc', 'saleMainTabNav_mc', 'vipMainTabNav_mc']) { const x = el.child(d); if (x && x !== t) x.show(false); }
          bindClick(el, () => { if (this.onSelect) this.onSelect(it, i); });
        } else el.show(false);
        i++;
      }
      return this;
    }
    selectTab(i) { this.selected = i; return this; }
    setTabVisibility(data, on) { const i = this._items.findIndex(x => x.data === data); const el = this.node.child('tab_' + i + '_bt'); if (el && i >= 0) el.show(on !== false); return this; }
  }

  class ZwAbstractSlotContainerFrame extends ZwFrame {
    constructor(node, opts) {
      opts = opts || {};
      super(node);
      this._prefix = opts.slotPrefix || 'slot_';
      this._postfix = opts.slotPostfix || '_mc';
      this._createSlot = opts.createSlot;
      this.slotData = [];
      this.slots = [];
      this._last = 0;
      let i = 0;
      while (true) {
        const el = node.child(this._prefix + i + this._postfix);
        if (!el) break;
        const s = this._createSlot(el, this, i);
        this.addWidget(s, false);
        this.slots.push(s);
        i++;
      }
    }
    clearSlots() { for (const s of this.slots) { s.node.show(false); s.clearView(); } }
    populateSlots(start = 0) {
      this.clearSlots();
      let si = 0, di = start;
      while (si < this.slots.length && this.slotData[di] != null) { this.slots[si].populate(this.slotData[di]); this.slots[si].node.show(true); si++; di++; }
      this._last = di;
    }
    refresh() { this.populateSlots(this._last); }
    get items() { return this.slotData; }
    set items(a) { this.slotData = a || []; this._last = 0; this.refresh(); }
  }

  /** paging: maxPage = ceil(items/slots)-1; arrows leftArrow_bt / rightArrow_bt; label pageCount_tf. */
  class ZwPagableSlotContainerFrame extends ZwAbstractSlotContainerFrame {
    constructor(node, opts) {
      super(node, opts);
      this.page = 0;
      const back = node.child('leftArrow_bt'), fwd = node.child('rightArrow_bt');
      if (back) bindClick(back, () => { if (this.page > 0) { this.page--; this.refresh(); } });
      if (fwd) bindClick(fwd, () => { if (this.page < this.maxPage) { this.page++; this.refresh(); } });
      this.setLabelFwd = node.child('rightArrow_bt');
      this.setLabelBack = node.child('leftArrow_bt');
      this.label = node.child('pageCount_tf');
    }
    get maxPage() { return this.slots.length ? Math.max(0, Math.ceil(this.slotData.length / this.slots.length) - 1) : 0; }
    get onFirst() { return this.page === 0; }
    get onLast() { return this.page === this.maxPage; }
    refresh() {
      this.page = Math.min(this.page, this.maxPage);
      this.populateSlots(this.slots.length * this.page);
      if (this.setLabelBack) this.setLabelBack.show(!this.onFirst);
      if (this.setLabelFwd) this.setLabelFwd.show(!this.onLast);
      if (this.label) this.label.setText(this.maxPage ? 'Page ' + (this.page + 1) + ' of ' + (this.maxPage + 1) : '');
    }
    set items(a) { this.slotData = a || []; this.page = 0; this.refresh(); }
  }

  /** scene-backed window: fit + render + pointer hit/click dispatch (callbacks bound on nodes). */
  class ZwWindow {
    constructor(scene, opts) {
      opts = opts || {};
      this.scene = scene; this.opts = opts; this.stage = new FVStage(scene);
      this.instantiate(opts.frame || 0);
    }
    instantiate(frameIndex) { this.root = this.stage.instantiate(frameIndex); this.frame = new ZwFrame(this.root); this._fit = null; return this; }
    find(name) { return this.stage.find(name); }
    findAll(name) { return this.stage.findAll(name); }
    show(name, on) { const n = this.find(name); if (n) n.show(on); return this; }
    text(name, str) { const n = this.find(name); if (n) n.setText(str); return this; }
    fit(W, H) { const b = this.scene.measure(this.opts.frame || 0, ''); const s = Math.min(W / b.w, H / b.h); return { s, tx: (W - b.w * s) / 2 - b.x * s, ty: (H - b.h * s) / 2 - b.y * s }; }
    render(ctx, W, H) {
      const f = (this._f0 = this.fit(W, H)); this._fit = f;
      ctx.save(); ctx.translate(f.tx, f.ty); ctx.scale(f.s, f.s); this.stage.render(ctx); ctx.restore();
    }
    toScene(cx, cy) { const f = this._fit || { s: 1, tx: 0, ty: 0 }; return { x: (cx - f.tx) / f.s, y: (cy - f.ty) / f.s }; }
    hit(cx, cy) { const p = this.toScene(cx, cy); return this.stage.hitTest(p.x, p.y); }
    /** dispatch a click at canvas coords: walks up from the hit node to the nearest bound callback. */
    up(cx, cy) {
      let n = this.hit(cx, cy);
      while (n) { if (n._clicks) { for (const cb of n._clicks) cb(n); return n; } n = n.parent; }
      return null;
    }
    move(cx, cy) { return !!this.hit(cx, cy); }
  }

  global.Zw = { ZwBaseWidget, ZwWidget, ZwFrame, ZwTextField, ZwButton, ZwSlotFrame, FarmTabMenu, ZwAbstractSlotContainerFrame, ZwPagableSlotContainerFrame, ZwWindow, bindClick };
  if (typeof module !== 'undefined' && module.exports) module.exports = global.Zw;
})(typeof window !== 'undefined' ? window : globalThis);

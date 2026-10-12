/* FV-NG — UI overlay: render original Farmville dialog/panel SWFs as modal screens (Track A / #3).
 *
 * Wraps an FVScene (from client/web/scene2d.js) into an interactive modal: centered + fitted,
 * dimmed backdrop, live button states (up/over/down) and click routing via buttonBoxes().
 *
 * Usage:
 *   const dlg = new FVDialog(canvas, ctx);
 *   await dlg.open('scenes/dlg_...scene.json', { onButton: (name) => {...} });
 *   // in the render loop: if (dlg.isOpen()) dlg.render(now);
 *   // route pointer events: dlg.onMove(e) / dlg.onDown(e) / dlg.onUp(e)
 */
(function (global) {
  'use strict';

  class FVDialog {
    constructor(canvas, ctx) {
      this.canvas = canvas;
      this.ctx = ctx;
      this.scene = null;
      this.name = null;
      this.sym = null;
      this.scale = 1;
      this.offX = 0;
      this.offY = 0;
      this.pressed = false;
      this._pressedBox = null;
      this.onButton = null;
      this.onClose = null;
      this._t0 = 0;
    }

    /** load and open a dialog scene (url -> .scene.json). */
    async open(url, opts) {
      opts = opts || {};
      const raw = await fetch(url).then(r => r.json());
      const scene = new FVScene(raw);
      await scene.load();
      this.scene = scene;
      this.name = opts.name || (raw.meta && raw.meta.source) || url;
      // pick the largest render target: the root timeline vs each exported symbol
      const cands = [{ sym: null, b: scene.measure(0, '') }];
      for (const s of scene.symbols()) cands.push({ sym: s, b: scene.measure(0, s) });
      cands.sort((a, b) => (b.b.w * b.b.h) - (a.b.w * a.b.h));
      this.sym = cands[0].sym;
      this._bbox = cands[0].b;
      this.onButton = opts.onButton || null;
      this.onClose = opts.onClose || null;
      this._t0 = performance.now();
      this._fit();
      this._dirty = true;
      return this;
    }

    _fit() {
      const b = this._bbox || (this.sym ? this.scene.measure(0, this.sym) : this.scene.measure(0, ''));
      const W = this.canvas.clientWidth || window.innerWidth;
      const H = this.canvas.clientHeight || window.innerHeight;
      const pad = 60;
      this.scale = Math.max(0.2, Math.min(1.8, Math.min((W - pad * 2) / b.w, (H - pad * 2) / b.h)));
      this.offX = (W - b.w * this.scale) / 2 - b.x * this.scale;
      this.offY = (H - b.h * this.scale) / 2 - b.y * this.scale;
    }

    render(timeMs) {
      if (!this.scene) return;
      const ctx = this.ctx;
      const W = this.canvas.clientWidth || window.innerWidth;
      const H = this.canvas.clientHeight || window.innerHeight;
      ctx.save();
      ctx.fillStyle = 'rgba(0,0,0,0.55)';
      ctx.fillRect(0, 0, W, H);
      ctx.restore();
      // bake the (potentially heavy) scene once and blit — re-bake only when a button state changes
      if (!this._baked || this._bakedW !== W || this._bakedH !== H || this._dirty) this._rebake(W, H);
      ctx.drawImage(this._baked, 0, 0, W, H);
    }

    _rebake(W, H) {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      const c = document.createElement('canvas');
      c.width = Math.round(W * dpr); c.height = Math.round(H * dpr);
      const g = c.getContext('2d');
      g.scale(dpr, dpr);
      g.translate(this.offX, this.offY);
      g.scale(this.scale, this.scale);
      if (this.sym) this.scene.renderSymbol(g, this.sym, [1, 0, 0, 1, 0, 0], 0);
      else this.scene.renderAt(g, 0);
      this._baked = c; this._bakedW = W; this._bakedH = H; this._dirty = false;
    }

    _pt(e) { return { x: (e.clientX - this.offX) / this.scale, y: (e.clientY - this.offY) / this.scale }; }
    _hitBox(e) {
      if (!this.scene) return null;
      const p = this._pt(e);
      return this.scene.buttonBoxes(0, this.sym || '').find(b => p.x >= b.x0 && p.x <= b.x1 && p.y >= b.y0 && p.y <= b.y1) || null;
    }

    onMove(e) {
      if (!this.scene) return;
      const hit = !!this._hitBox(e);
      const st = hit ? (this.pressed ? 'down' : 'over') : 'up';
      if (this.scene._buttonState !== st) { this.scene._buttonState = st; this._dirty = true; }
      this.canvas.style.cursor = hit ? 'pointer' : 'default';
    }
    onDown(e) {
      if (!this.scene) return;
      this._pressedBox = this._hitBox(e);
      this.pressed = !!this._pressedBox;
      if (this.pressed) { this.scene._buttonState = 'down'; this._dirty = true; }
    }
    onUp(e) {
      if (!this.scene) return;
      const box = this._pressedBox;
      this.pressed = false;
      this._pressedBox = null;
      if (box) {
        this.scene._buttonState = 'over'; this._dirty = true;
        if (this.onButton) this.onButton(box.name, box, this.name);
        else this.close();     // default: any button closes
      }
    }

    close() {
      this.scene = null;
      this.canvas.style.cursor = 'default';
      if (this.onClose) this.onClose();
    }
    isOpen() { return !!this.scene; }
  }

  global.FVDialog = FVDialog;
  if (typeof module !== 'undefined' && module.exports) module.exports = { FVDialog };
})(typeof window !== 'undefined' ? window : globalThis);

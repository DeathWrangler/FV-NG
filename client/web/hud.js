/* FV-NG — HUD overlay (Track A / milestone M-HUD).
 *
 * Renders the original Farmville HUD chrome 1:1 on its own canvas above the farm: the per-world HUD
 * skin SWF (zoom/camera/fullscreen/zcache buttons), the currency meter (coin_HUD_Meter.swf), the
 * XP level sign + bar, the cash display, the fuel gauge and the home button. Art comes from the
 * converted scenes/bitmaps in `hud.json` (client/tools/conv_hud.js) — no Flash runtime.
 *
 * Coordinate system matches the original (UI.as): the bottom HUD is a 760x590 virtual canvas anchored
 * at ((stageWidth-760)/2, stageHeight-590); the top-right container at stageWidth-760; the XP meter
 * centre at stageWidth/2+10.
 *
 * Usage:
 *   const hud = new FVDHud(canvas, ctx, { build });
 *   await hud.load({ world: 'Chat', onAction: (name) => {...} });
 *   // render loop: hud.render(now);
 *   // pointer: hud.onMove(e) / hud.onDown(e) / hud.onUp(e)
 */
(function (global) {
  'use strict';

  const FONT_STYLE_ID = 'fvng-hud-fonts';

  class FVDHud {
    constructor(canvas, ctx, opts) {
      opts = opts || {};
      this.canvas = canvas;
      this.ctx = ctx;
      this.build = opts.build || '1';
      this.manifest = null;
      this.layout = { DEFAULT_WIDTH: 760, DEFAULT_HEIGHT: 590, STAGE_W: 1018, STAGE_H: 600 };
      this.scenes = {};       // key -> FVScene
      this.imgs = {};         // name -> HTMLImageElement
      this.skinWorld = 'Chat';
      this.state = { gold: null, cash: null, level: null, xpPct: 0, xp: null, energy: null, energyMax: null, visiting: false, showWater: true, water: null, worldName: 'Welcome' };
      this.onAction = null;
      this.ready = false;
      this.hover = null;
      this.pressed = null;
      this._buttons = [];
      this._coinTextId = null;
      this._openMenu = null;   // id of the action-menu button whose popup is open
      this._menuRects = [];    // popup item hit regions (drawn last => checked first)
      this._fbScroll = 0;      // friend/neighbor bar horizontal scroll (px)
      this._dpr = Math.min(global.devicePixelRatio || 1, 2);
      // count-up animation (HUD.as updateCounter: COUNT_RATE=30 ticks @ 50ms)
      this._anim = { gold: { cur: null, target: null, rate: 0, next: 0 }, cash: { cur: null, target: null, rate: 0, next: 0 }, energy: { cur: null, target: null, rate: 0, next: 0 } };
    }

    get W() { return this.canvas.clientWidth || this.layout.STAGE_W; }
    get H() { return this.canvas.clientHeight || this.layout.STAGE_H; }

    // original UI.as onResize(): m_bottomUI at ((stageWidth-760)/2, stageHeight-590)
    bottom() { return { x: (this.W - this.layout.DEFAULT_WIDTH) / 2, y: this.H - this.layout.DEFAULT_HEIGHT }; }
    topX() { return this.W - this.layout.DEFAULT_WIDTH; }
    xpCenter() { return this.W / 2 + 10; }

    async load(opts) {
      opts = opts || {};
      this.onAction = opts.onAction || null;
      this.skinWorld = opts.world || 'Chat';
      const man = this.manifest = await fetch('hud/hud.json?v=' + this.build).then(r => r.json());
      if (man.layout) this.layout = Object.assign(this.layout, man.layout);
      this._installFonts();
      const jobs = [];
      const skin = man.skins[this.skinWorld] || man.skins.Chat;
      if (skin) jobs.push(this._loadScene('skin', skin.scene));
      for (const k of ['coin_meter', 'water_meter', 'home', 'search_bar', 'travel_dropdown', 'message', 'add_coins', 'cash_icon']) {
        if (man.scenes[k]) jobs.push(this._loadScene(k, man.scenes[k].scene));
      }
      const emb = ['FV_Main_LevelSign_loaded', 'FV_XP_WhiteBar_loaded', 'FV_Cash_Icon',
        'FV_Main_Fuel_Gauge_noBar', 'FV_Home_Button_Normal', 'FV_Home_Button_Over',
        'FV_Message_Center_Button', 'FV_Message_Center_Over', 'emptyAvatar', 'hud_nghbr_slot_norm'];
      for (const n of emb) if (man.embed[n]) jobs.push(this._loadImg(n));
      // action-menu chrome + item icons
      const act = ['hud_act_bttn_top', 'hud_act_bttn_bottom', 'hud_contextual_arrow', 'hud_act_walk',
        'hud_act_plow', 'hud_act_clear', 'hud_act_move', 'hud_act_market', 'hud_newCraftShop',
        'hud_gift', 'hud_storage', 'hud_search', 'hud_act_mastery', 'hud_collections', 'hud_achievements',
        'hud_act_tractor_buy_ground', 'hud_act_harvester_buy_ground',
        'multi_contextual_background_2h1w', 'multi_contextual_background_3h1w', 'multi_contextual_background_5h1w'];
      for (const n of act) if (man.embed[n]) jobs.push(this._loadImg(n));
      await Promise.all(jobs);
      // static widget scenes rendered per-frame would recreate bitmap-fill patterns each frame
      // (pathological for water_HUD_Meter) — bake them once to an offscreen canvas and blit.
      if (this.scenes.water_meter) { this._hookWaterText(); this._rebakeWater(); }
      if (this.scenes.add_coins) this._addCoinsBaked = this._bakeScene(this.scenes.add_coins);
      if (this.scenes.search_bar) this._searchBaked = this._bakeScene(this.scenes.search_bar);
      this._hookCoinText();
      this._hookTravelText();
      if (this.scenes.travel_dropdown) this._bakeTravel();
      this.ready = true;
      return this;
    }

    _bakeScene(sc, opts) {
      opts = opts || {};
      const pad = opts.pad != null ? opts.pad : 8;        // room for drop-shadow / glow filters
      const scale = this._dpr;                             // supersample so text stays crisp on HiDPI
      const b = sc.measure(0, '');
      const w = Math.max(1, Math.ceil(b.w) + pad * 2), h = Math.max(1, Math.ceil(b.h) + pad * 2);
      const c = document.createElement('canvas');
      c.width = Math.round(w * scale); c.height = Math.round(h * scale);
      const g = c.getContext('2d');
      g.scale(scale, scale);
      g.translate(-b.x + pad, -b.y + pad);
      sc.render(g, 0, null);
      return { canvas: c, x: b.x - pad, y: b.y - pad, w: w, h: h };
    }
    _blitBaked(ctx, baked, x, y) {
      if (!baked) return;
      ctx.drawImage(baked.canvas, x + baked.x, y + baked.y, baked.w, baked.h);
    }

    _loadScene(key, stem) {
      return fetch(stem + '.scene.json?v=' + this.build).then(r => r.json()).then(raw => {
        const s = new FVScene(raw);
        return s.load().then(() => { this.scenes[key] = s; });
      });
    }
    _loadImg(name) {
      const url = this.manifest.embed[name];
      return new Promise(res => {
        const im = new Image();
        im.onload = () => { this.imgs[name] = im; res(); };
        im.onerror = () => res();
        im.src = url;
      });
    }

    /** register the exported Merkin / Merkin2 HUD fonts (HUDFonts.as) for crisp numeric text. */
    _installFonts() {
      if (!this.manifest.fonts || document.getElementById(FONT_STYLE_ID)) return;
      const faces = Object.keys(this.manifest.fonts).map(n =>
        '@font-face{font-family:"' + n + '";src:url("' + this.manifest.fonts[n] + '") format("truetype");}').join('');
      const st = document.createElement('style');
      st.id = FONT_STYLE_ID; st.textContent = faces;
      document.head.appendChild(st);
    }

    /** locate the currency meter's value text field so we can drive it from live balance. */
    _hookCoinText() {
      const sc = this.scenes.coin_meter;
      if (!sc) return;
      for (const id in sc.characters) { if (sc.characters[id].type === 'text') { this._coinTextId = id; break; } }
    }

    /** locate the travel-name bar's text field (nameBar_mc.generic_tf — the 13px Merkin text). */
    _hookTravelText() {
      const sc = this.scenes.travel_dropdown;
      if (!sc) return;
      let fallback = null;
      for (const id in sc.characters) {
        const c = sc.characters[id];
        if (c.type !== 'text') continue;
        if (c.fontSize === 260) { this._travelTextId = id; return; }
        if (fallback == null) fallback = id;
      }
      this._travelTextId = fallback;
    }

    /** locate the water meter's amount text (WaterHudButton water_tf) so we can drive it. */
    _hookWaterText() {
      const sc = this.scenes.water_meter;
      if (!sc) return;
      for (const id in sc.characters) {
        const c = sc.characters[id];
        if (c.type === 'text' && /\d/.test(c.text || '')) { this._waterTextId = id; this._waterTextTmpl = c.text; break; }
      }
    }
    /** set the water amount on the meter and re-bake it (baked once; only re-baked on change). */
    _rebakeWater() {
      const sc = this.scenes.water_meter;
      if (!sc) return;
      if (this._waterTextId != null && this.state.water != null) {
        sc.characters[this._waterTextId].text = String(this._waterTextTmpl || '').replace(/>([^<]+)</, '>' + this.state.water + '<');
      }
      this._waterBaked = this._bakeScene(sc);
    }

    setState(s) {
      Object.assign(this.state, s);
      for (const k of ['gold', 'cash', 'energy']) if (s[k] !== undefined) this._setAnimTarget(k, s[k]);
      if (s.water !== undefined && s.water !== this._waterValue) { this._waterValue = s.water; this._rebakeWater(); }
    }
    _setAnimTarget(k, target) {
      const a = this._anim[k];
      if (a.target === target) return;
      a.rate = (a.cur == null || target == null) ? 0 : (target > a.cur ? Math.ceil((target - a.cur) / 30) : Math.floor((target - a.cur) / 30));
      a.target = target;
      if (a.cur == null) a.cur = target;   // first value appears immediately
      a.next = 0;
    }
    /** advance the coin/cash/energy count-up toward their targets (50ms ticks). */
    _updateAnim(now) {
      for (const k of ['gold', 'cash', 'energy']) {
        const a = this._anim[k];
        if (a.cur == null || a.target == null || a.cur === a.target) continue;
        if (a.next === 0) a.next = now + 50;
        let guard = 0;
        while (now >= a.next && a.cur !== a.target && guard++ < 240) {
          a.cur += a.rate;
          if ((a.rate > 0 && a.cur > a.target) || (a.rate < 0 && a.cur < a.target)) a.cur = a.target;
          a.next += 50;
        }
      }
    }
    _disp(k) { return this._anim[k].cur; }
    /** Utilities.formatNumber: floor + thousands separators (gold/cash are formatted in the original). */
    _fmt(n) { return Math.floor(n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ','); }

    // ---------- layout constants (UI.as) ----------
    static get ZOOM_OUT() { return { x: 656, y: 442 }; }
    static get ZOOM_IN() { return { x: 627, y: 442 }; }
    static get FULLSCREEN() { return { x: 685, y: 442 }; }
    static get CAMERA() { return { x: 714, y: 442 }; }
    static get CASH() { return { x: 180, y: 3 }; }
    static get COIN() { return { x: 48, y: 9 }; }
    static get ENERGY_OFFSET() { return 150; }
    static get HOME_DX() { return 500; }

    // ---------- rendering ----------
    render(timeMs) {
      const ctx = this.ctx;
      const dpr = Math.min(global.devicePixelRatio || 1, 2);
      const W = this.W, H = this.H;
      if (this.canvas.width !== Math.round(W * dpr) || this.canvas.height !== Math.round(H * dpr)) {
        this.canvas.width = Math.round(W * dpr); this.canvas.height = Math.round(H * dpr);
        this.canvas.style.width = W + 'px'; this.canvas.style.height = H + 'px';
      }
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      ctx.clearRect(0, 0, W, H);
      this._buttons = [];
      if (!this.ready) return;
      this._updateAnim(timeMs);

      this._drawCoinMeter(ctx);
      this._drawXpMeter(ctx);
      this._drawCash(ctx);
      this._drawAddCoins(ctx);
      this._drawFriendBar(ctx);
      this._drawNeighborSearch(ctx);
      this._drawEnergy(ctx);
      this._drawBottomWidgets(ctx);
      this._drawHome(ctx);
      if (this.state.showWater) this._drawWater(ctx);
      this._drawTravelName(ctx);
      this._drawMessageCenter(ctx);
      this._drawOptionsMenu(ctx);
      this._drawActionMenu(ctx);
    }

    _reg(action, x, y, w, h, symbol) {
      this._buttons.push({ action, x, y, w, h, symbol });
    }
    _renderSkinSymbol(ctx, baseSymbol, x, y, action, w, h) {
      const sc = this.scenes.skin;
      if (!sc) return;
      let state = 'normal';
      if (this.pressed === action) state = 'down';
      else if (this.hover === action) state = 'over';
      const name = baseSymbol.replace(/_normal_/, '_' + state + '_');
      const sym = sc.symbols().includes(name) ? name : baseSymbol;
      const b = sc.measure(0, sym);
      ctx.save();
      ctx.translate(x, y);
      sc.renderSymbol(ctx, sym, [1, 0, 0, 1, 0, 0], state === 'normal' ? null : 0);
      ctx.restore();
      this._reg(action, x, y, w || b.w, h || b.h, baseSymbol);
    }

    _drawCoinMeter(ctx) {
      const sc = this.scenes.coin_meter;
      if (!sc) return;
      // The value is drawn with browser text (crisp) rather than the scene's vector glyph outlines
      // (which rasterise softly under the sprite's shadow filter). Bake the static chrome once.
      if (this._coinTextId != null) sc.characters[this._coinTextId].text = '';
      if (!this._coinBaked) this._coinBaked = this._bakeScene(sc);
      const o = FVDHud.COIN;
      this._blitBaked(ctx, this._coinBaked, o.x, o.y);
      const gold = this._disp('gold');
      if (gold != null) {
        ctx.save();
        ctx.font = '14px "Merkin", Georgia, serif';
        ctx.fillStyle = '#ffffff';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'alphabetic';
        ctx.shadowColor = 'rgba(0,0,0,.5)'; ctx.shadowBlur = 1.5; ctx.shadowOffsetY = 1;
        ctx.fillText(this._fmt(gold), o.x + 34, o.y + 15.5);
        ctx.restore();
      }
      this._reg('coin', o.x, o.y, 140, 30, null);
    }

    _drawXpMeter(ctx) {
      const sign = this.imgs['FV_Main_LevelSign_loaded'];
      const bar = this.imgs['FV_XP_WhiteBar_loaded'];
      if (!sign) return;
      const w = sign.naturalWidth || 160, h = sign.naturalHeight || 46;
      const x = this.xpCenter() - w / 2;
      const y = 5;               // m_xpMeter.y
      const frameY = -6;         // ScoreMeterConfig.frameY
      ctx.drawImage(sign, x, y + frameY);
      // XP progress fill: the level sign's track window (cap + bar) spans x≈8..106, y≈12..36
      if (bar) {
        const winX = 8, winY = 12, winW = 98, winH = 24;
        const pct = Math.max(0, Math.min(1, this.state.xpPct || 0));
        ctx.save();
        ctx.beginPath();
        ctx.rect(x + winX, y + frameY + winY, winW, winH);
        ctx.clip();
        ctx.drawImage(bar, x + winX, y + frameY + winY, winW * pct, winH);
        ctx.restore();
      }
      // level number centered on the star badge (HUDFonts.LevelText: Merkin2 14, 0x764D1F)
      if (this.state.level != null) {
        ctx.save();
        // HUDFonts: LevelText (14px) normally, SmallLevelText (11px) above level 99
        ctx.font = (this.state.level > 99 ? '11px' : '14px') + ' "Merkin2", Georgia, serif';
        ctx.fillStyle = '#764d1f';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(String(this.state.level).padStart(2, '0'), x + w - 24, y + frameY + 24);
        ctx.restore();
      }
      this._reg('xp', x, y + frameY, w, h, null);
    }

    _drawCash(ctx) {
      // NOTE: the FV_Cash_Icon.swf scene renders dark in our Canvas2D renderer (a gradient-over-fill
      // discrepancy vs FFdec/SVG); fall back to the PNG embed until that's resolved.
      const o = FVDHud.CASH;
      const icon = this.imgs['FV_Cash_Icon'];
      if (!icon) return;
      ctx.drawImage(icon, o.x, o.y);
      const cash = this._disp('cash');
      if (cash != null) {
        ctx.save();
        ctx.font = 'bold 15px "Merkin2", Georgia, serif';
        ctx.fillStyle = '#ffffff';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'middle';
        ctx.shadowColor = 'rgba(0,0,0,.6)'; ctx.shadowBlur = 2; ctx.shadowOffsetY = 1;
        ctx.fillText(this._fmt(cash), o.x + 50, o.y + 23);
        ctx.restore();
      }
      this._reg('cash', o.x, o.y, 140, 42, null);
    }

    /** "Add Coins & Cash" button (HUD.as placeGetCoinButton: 58,45). */
    _drawAddCoins(ctx) {
      if (!this._addCoinsBaked) return;
      const x = 58, y = 45;
      this._blitBaked(ctx, this._addCoinsBaked, x, y);
      this._reg('addcoins', x, y, this._addCoinsBaked.w, this._addCoinsBaked.h, null);
    }

    _drawEnergy(ctx) {
      const tank = this.imgs['FV_Main_Fuel_Gauge_noBar'];
      if (!tank) return;
      const x = this.bottom().x, y = this.H - FVDHud.ENERGY_OFFSET;
      ctx.drawImage(tank, x, y);
      const energy = this._disp('energy');
      if (energy != null) {
        ctx.save();
        ctx.font = '10px "Merkin2", Georgia, serif';
        ctx.fillStyle = '#ffffff';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';
        ctx.fillText(String(energy), x + 18, y + 27);
        ctx.restore();
      }
      this._reg('energy', x, y, tank.naturalWidth, tank.naturalHeight, null);
    }

    _drawBottomWidgets(ctx) {
      const bx = this.bottom().x, by = this.bottom().y;
      const zo = FVDHud.ZOOM_OUT, zi = FVDHud.ZOOM_IN, fs = FVDHud.FULLSCREEN, cm = FVDHud.CAMERA;
      this._renderSkinSymbol(ctx, 'zoomOut_normal_farm', bx + zo.x, by + zo.y, 'zoomOut');
      this._renderSkinSymbol(ctx, 'zoomIn_normal_farm', bx + zi.x, by + zi.y, 'zoomIn');
      this._renderSkinSymbol(ctx, 'fullScreen_normal_farm', bx + fs.x, by + fs.y, 'fullscreen');
      this._renderSkinSymbol(ctx, 'camera_normal_farm', bx + cm.x, by + cm.y, 'camera');
    }

    _drawHome(ctx) {
      if (!this.state.visiting) return;   // home widget only shows while visiting a neighbor
      const o = { x: this.topX() + FVDHud.HOME_DX, y: 20 };
      const img = (this.hover === 'home' && this.imgs['FV_Home_Button_Over']) ? this.imgs['FV_Home_Button_Over'] : this.imgs['FV_Home_Button_Normal'];
      if (!img) return;
      ctx.drawImage(img, o.x, o.y);
      this._reg('home', o.x, o.y, img.naturalWidth, img.naturalHeight, null);
    }

    /** water meter button (WaterHudButton.as: at 410,5 inside the top-right container). */
    _drawWater(ctx) {
      if (!this._waterBaked) return;
      const x = this.topX() + 410, y = 5;
      this._blitBaked(ctx, this._waterBaked, x, y);
      this._reg('water', x, y, 60, 60, null);
    }

    /** farm-name / travel dropdown (FarmNameDisplay at 524,7 + ADDITIONAL_Y_OFFSET 2). */
    _bakeTravel() {
      const sc = this.scenes.travel_dropdown;
      if (!sc) return;
      if (this._travelTextId != null) sc.characters[this._travelTextId].text = String(this.state.worldName || '');
      this._travelBaked = this._bakeScene(sc);
      this._travelBakedName = String(this.state.worldName || '');
    }
    _drawTravelName(ctx) {
      if (!this.scenes.travel_dropdown) return;
      if (!this._travelBaked || this._travelBakedName !== String(this.state.worldName || '')) this._bakeTravel();
      const x = this.topX() + 524, y = 9;
      this._blitBaked(ctx, this._travelBaked, x, y);
      this._reg('travel', x, y, 140, 30, null);
    }

    /** message-center button (MessageCenterButton at 692,80 inside the top-right container). */
    _drawMessageCenter(ctx) {
      const img = (this.hover === 'messages' && this.imgs['FV_Message_Center_Over']) ? this.imgs['FV_Message_Center_Over'] : this.imgs['FV_Message_Center_Button'];
      if (!img) return;
      const x = this.topX() + 692, y = 80;
      ctx.drawImage(img, x, y);
      this._reg('messages', x, y, img.naturalWidth, img.naturalHeight, null);
    }

    // ---------- friend / neighbor bar (FriendBar.as: bar y=130, slots at y=345, interval 66) ----------
    _drawFriendBar(ctx) {
      if (this.state.showFriendBar === false) return;
      const sc = this.scenes.skin;
      if (!sc) return;
      const bx = this.bottom().x, by = this.bottom().y;
      if (sc.symbols().includes('neighborBackground_farm')) {
        ctx.save(); ctx.translate(bx, by + 439); sc.renderSymbol(ctx, 'neighborBackground_farm', [1, 0, 0, 1, 0, 0], null); ctx.restore();
      }
      const avatar = this.imgs['emptyAvatar'];
      const neighbors = this.state.neighbors || [];
      const total = Math.max(8, neighbors.length);   // populateNeighbors always keeps >= 8 slots
      const maxScroll = Math.max(0, total * 66 - 528);   // slotMask width 528
      this._fbScroll = Math.max(0, Math.min(maxScroll, this._fbScroll));
      // slots clipped to the original slotMask (43,462 528x230 in the bottom canvas; -2,-30 local)
      ctx.save();
      ctx.beginPath(); ctx.rect(bx + 41, by + 432, 528, 230); ctx.clip();
      for (let i = 0; i < total; i++) {
        const sx = bx + 43 + i * 66 - this._fbScroll, sy = by + 484;   // slot (i*66, 345) + bar.y 130
        if (sc.symbols().includes('friendBar_normal_farm')) {
          ctx.save(); ctx.translate(sx, sy); sc.renderSymbol(ctx, 'friendBar_normal_farm', [1, 0, 0, 1, 0, 0], null); ctx.restore();
        } else {
          const slot = this.imgs['hud_nghbr_slot_norm'];
          if (slot) ctx.drawImage(slot, sx, sy);
        }
        if (avatar) ctx.drawImage(avatar, sx + (62 - 47) / 2, sy + 6);
        const nb = neighbors[i];
        if (nb) {
          ctx.save();
          ctx.textAlign = 'center';
          ctx.font = 'bold 10px "Merkin2", Georgia, serif';
          ctx.fillStyle = '#ffffff';
          ctx.shadowColor = 'rgba(0,0,0,.75)'; ctx.shadowBlur = 3;
          ctx.fillText(String(nb.name || '').slice(0, 10), sx + 31, sy + 62);
          ctx.fillStyle = '#ffe58a';
          ctx.fillText('Lv ' + nb.level, sx + 31, sy + 74);
          ctx.restore();
        }
        this._reg('neighbor:' + (nb ? nb.uid : 'empty'), sx, sy, 62, 90, null);
      }
      ctx.restore();
      // nav: a vertical column at each end of the masked list (left rot180): single step
      // (singleArrow), page (doubleArrow) and skip-to-end (doubleArrow), vertically centred on the slots.
      const canPrev = this._fbScroll > 0, canNext = this._fbScroll < maxScroll;
      const ny = by + 489;
      this._navButton(ctx, 'singleArrow_normal_farm', bx + 10, ny, true, canPrev, 'fbPrevStep');
      this._navButton(ctx, 'doubleArrow_normal_farm', bx + 5, ny + 32, true, canPrev, 'fbPrevPage');
      this._navButton(ctx, 'doubleArrow_normal_farm', bx + 5, ny + 64, true, canPrev, 'fbPrevEnd');
      this._navButton(ctx, 'singleArrow_normal_farm', bx + 578, ny, false, canNext, 'fbNextStep');
      this._navButton(ctx, 'doubleArrow_normal_farm', bx + 573, ny + 32, false, canNext, 'fbNextPage');
      this._navButton(ctx, 'doubleArrow_normal_farm', bx + 573, ny + 64, false, canNext, 'fbNextEnd');
    }
    _navButton(ctx, sym, x, y, flip, enabled, action) {
      const sc = this.scenes.skin;
      if (!sc || !sc.symbols().includes(sym)) return;
      const b = sc.measure(0, sym);
      ctx.save();
      if (!enabled) ctx.globalAlpha = 0.4;
      ctx.translate(x, y);
      if (flip) { ctx.translate(b.w, 0); ctx.scale(-1, 1); }
      sc.renderSymbol(ctx, sym, [1, 0, 0, 1, 0, 0], null);
      ctx.restore();
      this._reg(action, x, y, b.w, b.h, null);
    }
    /** neighbor search bar (HUD.as: (stageWidth-760)/2+43, stageHeight-138) — FV_SearchBar.swf. */
    _drawNeighborSearch(ctx) {
      if (!this._searchBaked) return;
      const x = this.bottom().x + 43, y = this.H - 138;
      this._blitBaked(ctx, this._searchBaked, x, y);
      this._reg('search', x, y, this._searchBaked.w, this._searchBaked.h, null);
    }

    // ---------- options menu (OptionMenu.as: background at 1,26 + graphics/sfx/music buttons) ----------
    _drawOptionsMenu(ctx) {
      const sc = this.scenes.skin;
      if (!sc) return;
      const OX = 1, OY = 26;
      if (sc.symbols().includes('optionsBackground_farm')) {
        ctx.save();
        ctx.translate(OX, OY);
        sc.renderSymbol(ctx, 'optionsBackground_farm', [1, 0, 0, 1, 0, 0], null);
        ctx.restore();
      }
      this._renderSkinSymbol(ctx, 'graphics_normal_farm', OX + 6, OY + 32, 'graphics');
      this._renderSkinSymbol(ctx, 'sfx_normal_farm', OX + 6, OY + 54, 'sfx');
      this._renderSkinSymbol(ctx, 'music_normal_farm', OX + 6, OY + 76, 'music');
    }

    // ---------- bottom action menu (ActionMenu.as, origin 614,470 in the bottom canvas) ----------
    static get ACTION() {
      return {
        ox: 614, oy: 470, stepX: 48, stepY: 58, bw: 45, bh: 55, iw: 52, ih: 63,
        buttons: [
          { id: 'walk', x: 0, y: 0, bg: 'hud_act_bttn_top', icon: 'hud_act_walk', menu: 'walk' },
          { id: 'plow', x: 48, y: 0, bg: 'hud_act_bttn_top', icon: 'hud_act_plow', menu: 'plow' },
          { id: 'clear', x: 96, y: 0, bg: 'hud_act_bttn_top', icon: 'hud_act_clear', menu: 'clear' },
          { id: 'bottomleft', x: 0, y: 58, bg: 'hud_act_bttn_bottom', icon: 'hud_newCraftShop', menu: 'bottomleft' },
          { id: 'market', x: 48, y: 58, bg: 'hud_act_bttn_bottom', icon: 'hud_act_market', action: 'market' },
          { id: 'gifts', x: 96, y: 58, bg: 'hud_act_bttn_bottom', icon: 'hud_gift', menu: 'gifts' },
        ],
        menus: {
          walk: [{ text: 'Move Tool', icon: 'hud_act_move', action: 'deco' },
            { text: 'Multi Tool', icon: 'hud_act_walk', action: 'walk' }],
          plow: [{ text: 'Buy Now!', icon: 'hud_act_tractor_buy_ground', action: 'tractor' },
            { text: 'Buy Now!', icon: 'hud_act_harvester_buy_ground', action: 'harvester' },
            { text: 'Plow Tool', icon: 'hud_act_plow', action: 'plow' }],
          clear: [{ text: 'Clear', icon: 'hud_act_clear', action: 'clear' }],
          bottomleft: [{ text: 'Mastery', icon: 'hud_act_mastery', action: 'mastery' },
            { text: 'Collections', icon: 'hud_collections', action: 'collections' },
            { text: 'Achievements', icon: 'hud_achievements', action: 'achievements' }],
          gifts: [{ text: 'Search', icon: 'hud_search', action: 'search' },
            { text: 'Gifts', icon: 'hud_gift', action: 'gifts' }],
        },
      };
    }
    _actionBtnAbs(b) { const bx = this.bottom().x, by = this.bottom().y; return { x: bx + FVDHud.ACTION.ox + b.x, y: by + FVDHud.ACTION.oy + b.y }; }
    _btnDown(b) {
      if (this._openMenu === b.id) return true;
      return this.hover === b.id && this.pressed === b.id;
    }
    _drawActionMenu(ctx) {
      const A = FVDHud.ACTION;
      // popup first-class: draw after buttons so it is on top
      this._menuRects = [];
      for (const b of A.buttons) this._drawActionButton(ctx, b);
      if (this._openMenu) {
        const b = A.buttons.find(x => x.id === this._openMenu);
        if (b && A.menus[b.menu] && A.menus[b.menu].length > 1) this._drawMenuPopup(ctx, b, A.menus[b.menu]);
      }
    }
    _drawActionButton(ctx, b) {
      const A = FVDHud.ACTION;
      const p = this._actionBtnAbs(b);
      const shift = this._btnDown(b) ? 2 : 0;
      const icon = this.imgs[b.icon], bg = this.imgs[b.bg];
      const hot = (this.hover === b.id) || (this._openMenu === b.id);
      ctx.save();
      if (hot) ctx.filter = 'drop-shadow(0 0 2px #ecc9ac)';
      if (bg) ctx.drawImage(bg, p.x + shift, p.y + shift);
      if (icon) ctx.drawImage(icon, p.x + (A.bw - A.iw) / 2 + shift, p.y + (A.bh - A.ih) / 2 + shift);
      ctx.restore();
      const arrow = this.imgs['hud_contextual_arrow'];
      const menu = b.menu && A.menus[b.menu];
      if (arrow && menu && menu.length > 1) ctx.drawImage(arrow, p.x + A.iw - 24, p.y + 2);
      this._reg(b.id, p.x - 3, p.y - 4, A.iw, A.ih, null);
    }
    _drawMenuPopup(ctx, b, items) {
      const A = FVDHud.ACTION;
      const bgName = 'multi_contextual_background_' + items.length + 'h1w';
      const bg = this.imgs[bgName];
      const bp = this._actionBtnAbs(b);
      const menuX = bp.x + (A.iw - (bg ? bg.naturalWidth : 74)) / 2;
      const menuY = bp.y - (bg ? bg.naturalHeight : 74 * (items.length + 1)) + 10;
      const bgW = bg ? bg.naturalWidth : 74, bgH = bg ? bg.naturalHeight : 74 * (items.length + 1);
      if (bg) ctx.drawImage(bg, menuX, menuY);
      const cellH = bgH / items.length;
      for (let i = 0; i < items.length; i++) {
        const it = items[i];
        const cellY = menuY + i * cellH;
        ctx.save();
        ctx.font = 'bold 11px "Merkin2", Georgia, serif';
        ctx.fillStyle = '#5b3a1a';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';
        ctx.fillText(it.text, menuX + bgW / 2, cellY + 8);
        ctx.restore();
        const icon = this.imgs[it.icon];
        const ih = 48, iw2 = icon ? Math.round(48 * (icon.naturalWidth / icon.naturalHeight)) : 48;
        if (icon) ctx.drawImage(icon, menuX + (bgW - iw2) / 2, cellY + 24, iw2, ih);
        this._menuRects.push({ x: menuX, y: cellY, w: bgW, h: cellH, action: 'menu:' + it.action });
      }
    }

    // ---------- interaction ----------
    _hit(mx, my) {
      for (let i = this._menuRects.length - 1; i >= 0; i--) {
        const r = this._menuRects[i];
        if (mx >= r.x && mx <= r.x + r.w && my >= r.y && my <= r.y + r.h) return r;
      }
      for (let i = this._buttons.length - 1; i >= 0; i--) {
        const b = this._buttons[i];
        if (mx >= b.x && mx <= b.x + b.w && my >= b.y && my <= b.y + b.h) return b;
      }
      return null;
    }
    onMove(e) {
      if (!this.ready) return;
      const r = this.canvas.getBoundingClientRect();
      const b = this._hit(e.clientX - r.left, e.clientY - r.top);
      this.hover = b ? b.action : null;
      this.canvas.style.cursor = b ? 'pointer' : 'default';
    }
    onDown(e) {
      if (!this.ready) return false;
      const r = this.canvas.getBoundingClientRect();
      const b = this._hit(e.clientX - r.left, e.clientY - r.top);
      this.pressed = b ? b.action : null;
      // clicking outside an open popup closes it (and swallows the click, like ActionMultiButton.onStageClick)
      if (this._openMenu && !b) { this._openMenu = null; return true; }
      return !!b;
    }
    onUp(e) {
      if (!this.ready) return false;
      const r = this.canvas.getBoundingClientRect();
      const b = this._hit(e.clientX - r.left, e.clientY - r.top);
      const act = this.pressed;
      this.pressed = null;
      if (!b || b.action !== act) return false;
      // friend-bar nav scroll (self-contained)
      const nav = {
        fbPrevStep: () => { this._fbScroll = Math.max(0, this._fbScroll - 66); },
        fbPrevPage: () => { this._fbScroll = Math.max(0, this._fbScroll - 528); },
        fbPrevEnd: () => { this._fbScroll = 0; },
        fbNextStep: () => { this._fbScroll += 66; },
        fbNextPage: () => { this._fbScroll += 528; },
        fbNextEnd: () => { this._fbScroll = 1e9; },
      };
      if (nav[b.action]) { nav[b.action](); return true; }
      // popup menu item
      if (b.action.indexOf('menu:') === 0) {
        this._openMenu = null;
        if (this.onAction) this.onAction(b.action);
        return true;
      }
      // action-menu button: toggle popup / execute single-item / panel action
      const A = FVDHud.ACTION;
      const btn = A.buttons.find(x => x.id === b.action);
      if (btn) {
        const menu = btn.menu && A.menus[btn.menu];
        if (menu && menu.length > 1) { this._openMenu = (this._openMenu === btn.id) ? null : btn.id; return true; }
        if (menu && menu.length === 1) { if (this.onAction) this.onAction('menu:' + menu[0].action); return true; }
        if (btn.action && this.onAction) this.onAction(btn.action);
        return true;
      }
      if (this.onAction) this.onAction(b.action);
      return true;
    }
    hoverAction() { return this.hover; }
  }

  global.FVDHud = FVDHud;
  if (typeof module !== 'undefined' && module.exports) module.exports = { FVDHud };
})(typeof window !== 'undefined' ? window : globalThis);

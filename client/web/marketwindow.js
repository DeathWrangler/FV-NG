/* FV-NG — MarketWindow port (Widgets.Windows.Market.MarketWindow) over the Zw widget layer.
 *
 * Mirrors the AS3 postLoadComplete(): the window scene's instances are all hidden by ZwFrame, then the
 * pieces the window actually uses are shown and populated — title, level, search bar, main/sub tab
 * menus, the paging slot grid (MarketSlotFrame), close button. Each grid cell is a MarketSlot that
 * fills the SWF card's own fields (title_tf / icon_mc / buyCoin_mc / stat_*_mc …) for the coin-buy state.
 */
(function (global) {
  'use strict';
  const Z = global.Zw;
  const fmt = n => (n == null ? '' : Number(n).toLocaleString());

  // getMainMenuItems() with the default visibility flags applied (managed_sale/vault/village/vip/bobsFarm off)
  const MAIN_TABS = [
    { data: 'special', label: 'Special' }, { data: 'limited', label: 'Limited' },
    { data: 'seed', label: 'Seeds' }, { data: 'tree', label: 'Trees' },
    { data: 'animal', label: 'Animals' }, { data: 'building', label: 'Buildings' },
    { data: 'decoration', label: 'Decorations' }, { data: 'aide', label: 'Farm Aides' },
    { data: 'landExpansion', label: 'Land Expansion' }, { data: 'vault', label: 'Vault' },
  ];
  const SUB_TABS = ['All', 'Seeds', 'Fruits', 'Trees', 'Animals', 'Buildings', 'Decorations', 'Aides']
    .map((l, i) => ({ data: i === 0 ? 'all' : l.toLowerCase(), label: l }));

  function setText(node, name, str) { const t = node && node.child(name); if (t && t.type === 'text') t.setText(str); }

  /** a market grid card (Widgets.Slots.Market.Market3Slot/MarketSlot) — coin-buy presentation. */
  class MarketSlot extends Z.ZwSlotFrame {
    constructor(node, container, i) {
      super(node);
      this.container = container; this.index = i; this.data = null;
      const coin = node.child('buyCoin_mc');
      const buy = coin && coin.child('buy_bt');
      if (buy) Z.bindClick(buy, () => { if (this.container.onBuy && this.data) this.container.onBuy(this.data); });
      this.icon = node.child('icon_mc');
    }
    populate(it) {
      this.clearView();
      this.data = it;
      this.node.show(true);
      const t = this.node.child('title_tf'); if (t) { t.show(true); t.setText(it.name); }
      if (this.icon) this.icon.show(true);
      const coin = this.node.child('buyCoin_mc');
      if (coin) {
        coin.show(true);
        const ct = coin.child('cost_tf'); if (ct) { ct.show(true); ct.setText(it.cost != null ? fmt(it.cost) : ''); }
        const b = coin.child('buy_bt'); if (b) b.show(true);
        const ci = coin.child('icon_mc'); if (ci) ci.show(true);
        const a = coin.child('action_bt'), r = coin.child('redeem_bt'), l = coin.child('locked_bt'), u = coin.child('unlock_bt');
        for (const x of [a, r, l, u]) if (x) x.show(false);
      }
      // stats (MarketSlotItemStatFrame): 0 = harvest time, 1 = XP
      const stats = [
        it.grow_time != null && it.grow_time > 0 ? (it.grow_time >= 1 ? Math.round(it.grow_time * 10) / 10 + ' days' : Math.round(it.grow_time * 24) + ' hrs') : '',
        it.xp != null && it.xp > 0 ? it.xp + ' XP' : '',
        it.coin_yield != null && it.coin_yield > 0 ? fmt(it.coin_yield) + ' coins' : '',
      ];
      stats.forEach((s, i) => {
        const st = this.node.child('stat_' + i + '_mc');
        if (!st) return;
        if (s) { st.show(true); const tf = st.child('statInfo_tf'); if (tf) { tf.show(true); tf.setText(s); } const ic = st.child('statIcon_mc'); if (ic) ic.show(true); }
        else st.show(false);
      });
      const theme = this.node.child('theme_tf'); if (theme) theme.show(false);
      const info = this.node.child('info_tf'); if (info) info.show(false);
      for (const nm of ['timer_tf', 'saletimer_tf', 'sale_mc', 'expiration_mc', 'newIcon_mc', 'new_bt', 'preview_bt', 'mc_treemasterylvl', 'bloomSingle_mc', 'bloomFull_mc']) { const x = this.node.child(nm); if (x) x.show(false); }
    }
  }

  class FVMarketWindow extends Z.ZwWindow {
    constructor(scene, opts) {
      opts = opts || {};
      if (opts.frame == null) opts.frame = 0;
      super(scene, opts);
      this.opts = opts;
      this.onBuy = opts.onBuy || null;
      this.artFor = opts.artFor || null;
      this.type = opts.type || 'special';
      this._build();
    }
    _build() {
      if (this.find('marketCardsLE_mc')) return this._buildLE();
      // The SWF's wide layout (internal frame 2) adds `bgMed_mc` (char 655, 1011×610); our scene only
      // keeps it in root frame 1, so inject it behind the frame-0 content and drop the small frame.
      const scene = this.stage.scene;
      if (scene.chars[655]) {
        const bg = new global.FVNode(this.stage, 655, [1, 0, 0, 1, 53, 1], 'bgMed_mc', null, this.stage.root);
        this.stage.root.children.unshift(bg);
        this.bgWide = bg;
      }
      this.title();
      setText(this.root, 'level_tf', this.opts.level != null ? String(this.opts.level) : '');
      const s = this.find('searchBar_mc'); if (s) { s.show(true); setText(s, 'searchField_tf', 'Search'); }
      const t = this.find('title_tf'); if (t) t.show(true);
      const lv = this.find('level_tf'); if (lv) lv.show(true);
      const close = this.find('close_bt'); if (close) { close.show(true); Z.bindClick(close, () => { if (this.opts.onClose) this.opts.onClose(); }); }
      for (const m of ['sortBy_bt', 'subNav_mc', 'bgMed_mc', 'searchBar_mc', 'mainNav_mc']) { const n = this.find(m); if (n) n.show(true); }
      for (const m of ['coinMeter_mc', 'fcMeter_mc', 'addCoins_bt', 'bgSmall_mc', 'size_mc', 'miniCards_mc', 'miniRewardCards_mc', 'miniSale_mc', 'charitySale_mc', 'promoCards3_mc', 'promoCards3Wide_mc', 'bottomTabs_mc', 'frame_subNav1_mc', 'frame_subNav2_mc', 'ftueSmall_mc', 'ftueSmall_sale_mc', 'ftueMedium_mc', 'ftueMedium_sale_mc']) { const n = this.find(m); if (n) n.show(false); }

      this.mainMenu = this.find('mainNav_mc') ? new Z.FarmTabMenu(this.find('mainNav_mc'), (it, i) => this._selectMain(it, i), MAIN_TABS) : null;
      if (this.find('mainNav_mc')) this.find('mainNav_mc').show(true);
      this.subMenu = this.find('subNav_mc') ? new Z.FarmTabMenu(this.find('subNav_mc'), null, SUB_TABS) : null;
      const cards = this.find('marketCards_mc');
      this.grid = cards ? new Z.ZwPagableSlotContainerFrame(cards, {
        slotPrefix: 'slot_', slotPostfix: '_mc', createSlot: (n, c, i) => new MarketSlot(n, c, i),
      }) : null;
      if (this.grid) {
        this.grid.onBuy = it => { if (this.onBuy) this.onBuy(it); };
        this.grid.artFor = this.artFor;
        cards.show(true);
      }
      if (this.mainMenu) { this.mainMenu.selectTab(0); this._selectMain(MAIN_TABS[0], 0); }
    }
    /** LE-revamp market (FV_Market_11_organic): LE frame + header + icon tabs + left LE theme nav + LE grid + promo. */
    _buildLE() {
      const S = this.stage.scene;
      // frame 0 only carries the *small* LE frame; inject the wide LE frame + bottom bg (kept in frame 1).
      const inject = (chr, name, m) => { if (!S.chars[chr]) return null; const n = new global.FVNode(this.stage, chr, m, name, null, this.stage.root); return n; };
      const wide = [inject(759, 'bgLEMed_mc', [1, 0, 0, 1, 53.25, 1.05]), inject(764, 'bottomMedBG_mc', [1, 0, 0, 1, 7, 489])].filter(Boolean);
      if (wide.length) this.stage.root.children.unshift.apply(this.stage.root.children, wide);
      for (const m of ['level_tf', 'coinMeter_mc', 'fcMeter_mc', 'searchBar_mc', 'close_bt', 'LE_header_mc', 'LE_subtitle_mc', 'mainNav_mc', 'subNavLE_mc', 'marketCardsLE_mc', 'promoCardsLE_mc']) { const n = this.find(m); if (n) n.show(true); }
      for (const m of ['title_tf', 'marketCards_mc', 'subNav_mc', 'bgSmall_mc', 'bgLESmall_mc', 'bgLEDefaultSmall_mc', 'size_mc', 'miniCards_mc', 'miniRewardCards_mc', 'miniSale_mc', 'charitySale_mc', 'promoCards3_mc', 'promoCards3Wide_mc', 'bottomTabs_mc', 'bottomSmallBG_mc', 'subNavBG_mc', 'frame_subNav1_mc', 'frame_subNav2_mc', 'ftueSmall_mc', 'ftueSmall_sale_mc', 'ftueMedium_mc', 'ftueMedium_sale_mc', 'ftueSmall_LE_mc', 'ftueMedium_LE_mc', 'VIPOnlyBanner_mc', 'VIPFTUE_mc']) { const n = this.find(m); if (n) n.show(false); }
      const lv = this.find('level_tf'); if (lv) lv.setText(String(this.opts.level != null ? this.opts.level : 1));
      const cm = this.find('coinMeter_mc'); if (cm) setText(cm, 'coinValue_tf', Number(this.opts.gold || 0).toLocaleString());
      const fm = this.find('fcMeter_mc'); if (fm) setText(fm, 'fcValue_tf', Number(this.opts.cash || 0).toLocaleString());
      const h = this.find('LE_header_mc'); if (h) { const t = h.child('title_tf'); if (t) t.setText('LIMITED EDITION!'); }
      const sub = this.find('LE_subtitle_mc'); if (sub) { const t = sub.child('body_tf'); if (t) t.setText('Grab them while they last'); }
      const sb = this.find('searchBar_mc'); if (sb) setText(sb, 'searchField_tf', 'Search');
      const close = this.find('close_bt'); if (close) Z.bindClick(close, () => { if (this.opts.onClose) this.opts.onClose(); });
      const nav = this.find('mainNav_mc');
      const CAT8 = [['special', 'Featured'], ['seed', 'Seeds'], ['tree', 'Trees'], ['animal', 'Animals'], ['building', 'Buildings'], ['decoration', 'Decorations'], ['vehicle', 'Vehicles'], ['plot', 'Plots']];
      this.mainMenu = nav ? new Z.FarmTabMenu(nav, (it, i) => this._selectMain(it, i), CAT8.map(c => ({ data: c[0], label: '' }))) : null;
      this.navTabs = nav ? (nav.children || []).filter(c => /^tab_\d+_bt$/.test(c.name || '')).sort((a, b) => a.abs()[4] - b.abs()[4]) : null;
      this.leMenu = this.find('subNavLE_mc') ? new Z.FarmTabMenu(this.find('subNavLE_mc'), null, [
        { data: 'featured', label: 'Featured LE Theme' }, { data: 'crop', label: 'Limited Edition Theme' },
      ]) : null;
      const cards = this.find('marketCardsLE_mc');
      this.grid = cards ? new Z.ZwPagableSlotContainerFrame(cards, { slotPrefix: 'slot_', slotPostfix: '_mc', createSlot: (n, c, i) => new MarketSlot(n, c, i) }) : null;
      if (this.grid) { this.grid.onBuy = it => { if (this.onBuy) this.onBuy(it); }; this.grid.artFor = this.artFor; }
      const showView = which => {
        const promo = this.find('promoCardsLE_mc'), hdr = this.find('LE_header_mc'), sub = this.find('LE_subtitle_mc');
        const isPromo = which === 'featured';
        if (promo) promo.show(isPromo);
        if (hdr) hdr.show(isPromo);
        if (sub) sub.show(isPromo);
        if (cards) cards.show(!isPromo);
        if (this.opts.onRender) this.opts.onRender();
      };
      this.leMenu = this.find('subNavLE_mc') ? new Z.FarmTabMenu(this.find('subNavLE_mc'), it => showView(it.data), [
        { data: 'featured', label: 'Featured LE' }, { data: 'crop', label: 'LE Crop' },
      ]) : null;
      showView('featured');   // live default = LE promo landing
    }
    title() { const t = this.find('title_tf'); if (t) t.setText('Market'); }
    _selectMain(it, i) { this.type = it.data; const sec = this.find('sectionTitle_mc'); if (sec && sec.type === 'text') sec.setText(it.label); if (this.opts.onTab) this.opts.onTab(it, i); }
    setItems(items) { if (this.grid) this.grid.items = items; }
    fit(W, H) { const b = this.scene.measure(this.opts.frame || 0, ''); const s = Math.min(W / b.w, H / b.h) * 0.97; return { s, tx: (W - b.w * s) / 2 - b.x * s, ty: (H - b.h * s) / 2 - b.y * s }; }
    get perPage() { return this.grid ? this.grid.slots.length : 0; }
    /** draw item art over each visible slot's icon_mc (art comes from the item's own scene). */
    render(ctx, W, H) {
      const f = this._fit = this.fit(W, H);
      ctx.save(); ctx.translate(f.tx, f.ty); ctx.scale(f.s, f.s);
      this.stage.render(ctx);
      this._drawArt(ctx);
      this._drawTabs(ctx);
      ctx.restore();
    }
    /** draw main-nav tab icons (loaded from market/tabN.png) over the icon tabs. */
    _drawTabs(ctx) {
      if (!this._tabIcons || !this.navTabs) return;
      const vis = this.navTabs.filter(t => t.visible);
      for (let i = 0; i < vis.length && i < this._tabIcons.length; i++) {
        const ic = this._tabIcons[i]; if (!ic) continue;
        const b = vis[i].box(); if (!b) continue;
        const bw = b.x1 - b.x0, bh = b.y1 - b.y0;
        const sc = Math.min(bw * 0.72 / ic.width, bh * 0.72 / ic.height);
        ctx.drawImage(ic, b.x0 + (bw - ic.width * sc) / 2, b.y0 + (bh - ic.height * sc) / 2, ic.width * sc, ic.height * sc);
      }
    }
    setIcons(arr) { this._tabIcons = arr; }
    _drawArt(ctx) {
      if (!this._art) return;
      for (const slot of (this.grid ? this.grid.slots : [])) {
        if (!slot.node.visible || !slot.data) continue;
        const art = this._art[slot.data.name]; if (!art || !art.ready) continue;
        const ic = slot.icon; if (!ic || !ic.visible) continue;
        const a = ic.abs();
        const S = 110;
        const sc = Math.min(S / art.width, S / art.height);
        ctx.drawImage(art, a[4] + (S - art.width * sc) / 2, a[5] + (S - art.height * sc) / 2, art.width * sc, art.height * sc);
      }
    }
    setArt(map) { this._art = map; }
  }

  global.FVMarketWindow = FVMarketWindow;
  if (typeof module !== 'undefined' && module.exports) module.exports = { FVMarketWindow, MarketSlot };
})(typeof window !== 'undefined' ? window : globalThis);

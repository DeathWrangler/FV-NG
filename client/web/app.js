/* FV-NG browser client — boot + iso renderer + core farm loop (Phase 3).
   Depends on amf3.browser.js (global FVConnection). Same-origin with gateway + assets. */
(function () {
  'use strict';

  // ---------- config ----------
  const BASE = location.origin + '/farmville';
  const ASSET_ROOT = BASE + '/assets/hashed/assets';
  const UID = new URLSearchParams(location.search).get('uid') || '9614740829';
  const BUILD = '13';                        // cache-bust for scene JSON (bump when scenes are regenerated)
  const TILE_W = 25, TILE_H = 12;            // iso tile footprint. FarmGame.as sets ZEngineOptions tileWidth=25, tileHeight=12, tileScale=2 (Constants.TILE_WIDTH/HEIGHT at runtime)
  const PLANE_CENTER_Y = 0.5;                // vertical position of the farm plane's centre (IsoViewport.centerOnTilePos centres the field in the stage)
  const GROW_UNIT_MS = 60 * 1000;            // grow_time is fractional MINUTES
  const TEMP_ID_START = 63000;               // server assigns real ids for temp ids >= this

  // The custom HUD is not present (the original Farmville HUD will be implemented later), so make
  // element lookups null-safe: any missing element resolves to a no-op stub the game logic can
  // still assign to / call without throwing.
  const NULL_EL = new Proxy(function () {}, {
    get: (t, k) => (k === 'textContent' || k === 'innerHTML' || k === 'value' || k === 'id' || k === 'className') ? ''
      : (k === 'hidden' || k === 'disabled' || k === 'checked') ? false : NULL_EL,
    set: () => true,
    apply: () => NULL_EL,
    has: () => true,
  });
  const $ = id => document.getElementById(id) || NULL_EL;
  const logEl = $('bootlog');
  const DEBUG = new URLSearchParams(location.search).has('debug');
  const STOP = parseInt(new URLSearchParams(location.search).get('stop') || '0', 10);   // dev: halt after N frames
  function bootLog(msg, cls) {
    if (DEBUG) console.log('FVNG ' + msg);
    const line = document.createElement('div');
    if (cls) line.className = cls;
    line.textContent = msg;
    logEl.appendChild(line); logEl.scrollTop = logEl.scrollHeight;
  }

  // ---------- state ----------
  let conn = null;
  let serverTime = Math.floor(Date.now() / 1000);
  let player = {};
  let world = null;
  let objects = [];          // normalized render objects
  let cropsMap = {};         // name -> hash (crops category)
  let seeds = {};            // name -> {code,grow_time,size,coin_yield,cost}
  let cropTiles = {};        // item name -> tile stem (from croptiles manifest)
  let scenesByName = {};     // item name -> scene stem (M2 world objects)
  let itemMeta = {};         // item name -> [sizeX, sizeY, imageScale, cost] (M2c placement fidelity)
  let avatarMap = null;      // avatar clothing map (avatarmap.json): parts -> containerClip slots
  let dialogsByName = {};    // dialog name -> scene stem (#3 UI)
  let dialog = null;         // FVDialog overlay (#3)
  let hud = null;            // FVDHud overlay (original Farmville HUD, M-HUD)
  let hudCanvas = null;
  let hudCaptured = false;   // true while a HUD widget has captured the pointer
  let levelsData = null;      // XP level curve (build/gen_levels.php -> levels.json)
  const sceneCache = new Map(); // scene stem -> FVScene | 'loading'
  let groundImg = null;      // original vector farm backdrop (SVG) — 1:1 art
  let groundMeta = null;     // {bounds, anchor, fieldHalfWpx, unitPx} from swf2svg sidecar
  let grassTiles = null;     // {w,h,imgs:[Image]} grass tile variants (base terrain)
  let grassCanvas = null;    // baked grass field (native iso space)
  let grassOrigin = null;    // {x,y} iso-space origin of grassCanvas
  let grassScale = 1;        // native tile -> grid tile scale (TILE_W / grassTileWidth)
  let horizonScene = null;   // FVScene for the theme background (full engine: shapes/sprites/fills)
  let horizonCanvas = null;  // baked horizon (environment) layer
  let horizonCenter = null;  // {x,y} field-centre in horizonCanvas px
  let stripScene = null;     // far sky/horizon strip (clouds)
  let stripCanvas = null;
  let stripBleed = null;     // stripCanvas + wrapped edge columns (seamless tiling without edge bleed)
  const imgCache = new Map();// url -> HTMLImageElement
  let selected = null;
  let busy = false;          // action in flight
  let placeMode = null;      // item name armed for placement on next empty-ground click (M2)
  let moveObj = null;        // object armed for move on next empty-ground click (M2)
  let visitingUid = null;    // non-null while viewing a neighbor's farm (read-only visit mode)
  let placeConsume = false;  // when placing from storage, consume an inventory item
  let inventory = [];        // stored items [{name,quantity}] (M3b)
  let market = null;         // FVMarket (original market window binder)
  let storageWin = null;     // FVStorage (original storage window binder)
  let soundsMap = {};        // sound name -> hash (M8a)
  let audioOn = true;
  const audioCache = new Map();

  // ---------- settings persistence + localization (M8b) ----------
  const STORE = 'fvng.settings';
  function loadSettings() { try { return JSON.parse(localStorage.getItem(STORE)) || {}; } catch (e) { return {}; } }
  function saveSettings() { try { localStorage.setItem(STORE, JSON.stringify({ audioOn: audioOn, locale: locale, uid: UID, cam: { x: cam.x, y: cam.y, zoom: cam.zoom } })); } catch (e) { /* storage disabled */ } }
  let locales = {}, locale = 'en';
  function t(k) { return (locales[locale] && locales[locale][k]) || (locales.en && locales.en[k]) || k; }
  function applyLocale() {
    document.querySelectorAll('[data-i18n]').forEach(el => { el.textContent = t(el.dataset.i18n); });
    const q = $('mkt-q'); if (q) q.placeholder = t('search');
  }
  const __st = loadSettings();
  if (__st.audioOn !== undefined) audioOn = __st.audioOn;
  if (__st.locale) locale = __st.locale;

  // camera
  const cam = { x: 0, y: 0, zoom: 1 };
  let dragging = false, lastX = 0, lastY = 0, moved = 0;

  const canvas = $('stage');
  const ctx = canvas.getContext('2d');
  let W = 0, H = 0, DPR = 1;

  // ---------- original cursors (assets/hashed/.../cursors) ----------
  const CUR = ASSET_ROOT + '/cursors/';
  const CURSOR_IMG = {
    handClosed: CUR + '9861ab970208ce094f2cc5912c070c01.png', // FV_main_hand_icon_closed_41x49
    hoe: CUR + 'c0360540b5324ffc9281e54bd3dbbe90.png',        // FV_Main_Hoe_Icon_wArrow
    scythe: CUR + '4b85800966f974c4bfb37d926f90ab67.png',     // FV_Main_Scythe_Icon_wArrow
    shovel: CUR + 'aeb8eca21bfb5818b5363ae6235b21e1.png',     // FV_Main_Shovel_Icon_wArrow
    water: CUR + 'e77088f306165e9e4dda426c863851c3.png',      // FV_wateringcan_cursor
    blob: CUR + '347106e0f89078896e7e779bc50ce3d1.png',       // shadow_blob (avatar shadow)
  };
  const _imgCache = {};
  function img(url) { if (!_imgCache[url]) { const im = new Image(); im.crossOrigin = 'anonymous'; im.src = url; _imgCache[url] = im; } return _imgCache[url]; }
  for (const url of Object.values(CURSOR_IMG)) img(url);
  let avatarScene = null, avatarPos = null;

  const AVATAR_SYM = 'MyLife.Assets.Avatar.Avatar_standFront';   // default standing avatar (avatar2.swf)
  const AVATAR_BASE = 'MyLife.Assets.Avatar.Avatar_standFront';
  // gameSettingsCMS.xml avatarScale is 0.5, but avatar2.swf's Avatar_standFront art is the (larger)
  // character-creation preview; the in-world avatar is sized to the live client relative to a 1x1
  // world tree (12drumtree renders at boxWidth*imageScale = 25*3 = 75 wide / ~94 tall).
  const AVATAR_SCALE = 0.15;
  let hoveredObject = null; // object under the pointer (gets the original glow highlight)
  let cursorTool = null;    // active tool cursor key; null = default (system) cursor
  function applyCursor() {
    const url = CURSOR_IMG[cursorTool];
    canvas.style.cursor = url ? 'url("' + url + '") 12 20, auto' : 'default';
  }

  // Original Flash stage size (game.blade.php embeds the SWF at 1018x600). Rendering at the same
  // stage size makes zoom / scroll / horizon behaviour match the original client.
  const STAGE_W = 1018, STAGE_H = 600;

  function resize() {
    DPR = Math.min(window.devicePixelRatio || 1, 2);
    const game = document.getElementById('game');
    W = game ? game.clientWidth : STAGE_W;
    H = game ? game.clientHeight : STAGE_H;
    canvas.width = W * DPR; canvas.height = H * DPR;
    canvas.style.width = W + 'px'; canvas.style.height = H + 'px';
    ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
  }
  window.addEventListener('resize', () => { resize(); if (typeof STOP !== 'undefined' && STOP) frame(); });

  // ---------- asset loading ----------
  function loadJSON(url) { return fetch(url).then(r => { if (!r.ok) throw new Error(url + ' -> HTTP ' + r.status); return r.json(); }); }

  /** decode the server's compressed arrays (GeneralFunctions.compressArray: base64(zlib(JSON))). */
  async function gunzipB64(b64) {
    if (!b64) return null;
    const bin = atob(b64);
    const bytes = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
    if (typeof DecompressionStream === 'undefined') return null;
    const stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream('deflate'));
    return JSON.parse(await new Response(stream).text());
  }
  function imgFor(name) {
    const candidates = ['crop_' + name + '_icon.png', name + '_icon.png', 'crop_' + name + '.swf', name + '.swf'];
    for (const c of candidates) { if (cropsMap[c]) return ASSET_ROOT + '/crops/' + cropsMap[c] + ext(c); }
    return null;
  }
  function ext(n) { return n.endsWith('.png') ? '.png' : n.endsWith('.swf') ? '.swf' : ''; }
  function getImg(url) {
    if (!url) return null;
    if (imgCache.has(url)) return imgCache.get(url);
    const im = new Image();
    im.src = url;
    imgCache.set(url, im);
    return im;
  }

  // ---------- audio (M8a): play original extracted SFX by name ----------
  function sfx(name, vol) {
    if (!audioOn) return;
    const h = soundsMap[name];
    if (!h) return;
    const url = ASSET_ROOT + '/sounds/' + h + '.mp3';
    let a = audioCache.get(url);
    if (!a) { a = new Audio(url); a.volume = vol == null ? 0.7 : vol; audioCache.set(url, a); }
    try { a.currentTime = 0; a.play(); } catch (e) { /* autoplay blocked until first gesture */ }
  }

  // ---------- original stage-tile rendering (1:1 art) ----------
  // Each converted crop SWF produced a full isometric plot tile (soil + plant) per stage.
  const STAGE_ORDER = ['seeds', 'growing1', 'growing2', 'grown'];
  // Crop withering (HarvestableResource.getWitherTime / Plot.getWitherPercentage): a planted crop
  // withers at plantTime + growTime * (witherMultiplier + randomRange*rand). Values from
  // gameSettingsCMS.xml: witherMultiplier=2.2, witherRandomRange=0.5.
  const WITHER_MULTIPLIER = 2.2, WITHER_RANDOM_RANGE = 0.5;
  function witherMs(o) {
    const seed = seeds[o.itemName];
    if (!seed || !seed.grow_time || o.plantTime == null) return Infinity;
    const growMs = seed.grow_time * GROW_UNIT_MS;
    const rf = ((Math.abs(Math.floor(Math.sin(o.pos.x * 131 + o.pos.y * 17) * 214013)) % 100) + 1) / 100 * WITHER_RANDOM_RANGE;
    return o.plantTime + growMs * (WITHER_MULTIPLIER + rf);
  }
  function isWithered(o) {
    return o.plantTime != null && (serverTime * 1000) >= witherMs(o);
  }
  function stageFor(o) {
    if (!o.itemName) return null;
    if (o.state === 'withered') return 'withered';
    if (isWithered(o)) return 'withered';
    if (o.state === 'grown' || o.isJumbo) return o.isJumbo ? 'super' : 'grown';
    if (o.state !== 'planted') return 'seeds';
    const gi = growInfo(o);
    if (!gi) return 'seeds';
    if (gi.ready) return 'grown';
    const f = 1 - gi.rem / ((seeds[o.itemName].grow_time * GROW_UNIT_MS));
    if (f < 0.25) return 'seeds';
    if (f < 0.6) return 'growing1';
    return 'growing2';
  }
  function tileUrl(o) {
    const stem = cropTiles[o.itemName];
    if (!stem) return null;
    const st = stageFor(o);
    if (!st) return null;
    return BASE + '/fvng/croptiles/' + stem + '_' + st + '.png';
  }
  // Plot base art for plots with no crop: the original uses EmbeddedArt["plot_withered"] for the
  // FALLOW state and EmbeddedArt["plot_plowed"] for PLOWED (Classes/Plot.as setDisplayStatesForPlots).
  function plotBaseUrl(o) {
    if (o.className !== 'Plot') return null;
    if (o.state === 'plowed') return BASE + '/fvng/plot_plowed.png';
    if (o.state === 'fallow') return BASE + '/fvng/plot_withered.png';
    return null;
  }

  // ---------- isometric projection ----------
  // Matches the original IsoMath.tilePosToPixelPos (ROTATION_0): increasing tile x moves right+UP,
  // increasing tile y moves left+UP, so grid (0,0) is at the FRONT (bottom) and high coords at the
  // BACK (top, toward the horizon). (Previously the y sign was positive, mirroring the whole farm.)
  function iso(gx, gy) { return { x: (gx - gy) * TILE_W / 2, y: -(gx + gy) * TILE_H / 2 }; }
  function worldToScreen(p) { const s = iso(p.x, p.y); return { x: W / 2 + cam.x + s.x * cam.zoom, y: H * 0.46 + cam.y + s.y * cam.zoom }; }
  function screenToWorld(sx, sy) {
    const a = (sx - W / 2 - cam.x) / cam.zoom;
    const b = (sy - H * 0.46 - cam.y) / cam.zoom;
    // a = (gx-gy)*TILE_W/2, b = -(gx+gy)*TILE_H/2  =>  gx = (u+v)/2, gy = (v-u)/2 with u=a/(TW/2), v=-b/(TH/2)
    const u = a / (TILE_W / 2), v = -b / (TILE_H / 2);
    return { x: Math.round((u + v) / 2), y: Math.round((v - u) / 2) };
  }

  // ---------- boot ----------
  async function boot() {
    try {
      conn = new FVConnection(BASE, { masterId: UID, uid: UID, token: 'fvng', sigTime: Math.floor(Date.now() / 1000) });
      bootLog('uid=' + UID + '  base=' + BASE, 'dim');

      const [assets, seedCat] = await Promise.all([loadJSON('assethash.crops.json'), loadJSON('seeds.json')]);
      cropsMap = assets.crops || {};
      seeds = seedCat;
      try { levelsData = await loadJSON('levels.json'); } catch (e) { bootLog('no level curve (' + e.message + ')', 'dim'); }
      bootLog('assets: ' + Object.keys(cropsMap).length + ' crop sprites, ' + Object.keys(seeds).length + ' seed defs' +
        (levelsData ? ', ' + (levelsData.startXP.length - 1) + ' levels' : ''), 'ok');

      // original stage tiles (1:1 art) — best-effort, not fatal if absent
      try { cropTiles = await loadJSON('cropsbyname.json'); bootLog('stage tiles: ' + Object.keys(cropTiles).length + ' crops mapped', 'ok'); }
      catch (e) { bootLog('no stage-tile map (' + e.message + ') — falling back to icons', 'dim'); }

      // world-object scenes (M2) — decorations/trees/buildings/animals
      try { scenesByName = await loadJSON('scenesbyname.json'); bootLog('object scenes: ' + Object.keys(scenesByName).length + ' items mapped', 'ok'); }
      catch (e) { bootLog('no object-scene map (' + e.message + ')', 'dim'); }
      try { itemMeta = await loadJSON('itemmeta.json'); bootLog('item meta: ' + Object.keys(itemMeta).length + ' items', 'ok'); }
      catch (e) { bootLog('no item meta (' + e.message + ')', 'dim'); }
      try { avatarMap = await loadJSON('avatarmap.json'); bootLog('avatar map: ' + avatarMap.parts.length + ' parts', 'ok'); }
      catch (e) { bootLog('no avatar map (' + e.message + ')', 'dim'); }

      // original UI dialogs (#3)
      dialog = new FVDialog(canvas, ctx);
      try { dialogsByName = await loadJSON('dialogsbyname.json'); bootLog('dialogs: ' + Object.keys(dialogsByName).length + ' mapped', 'ok'); }
      catch (e) { bootLog('no dialogs map (' + e.message + ')', 'dim'); }

      // original Farmville HUD (M-HUD) — constructed here, loaded after the world
      hudCanvas = $('hud');
      if (hudCanvas && hudCanvas.getContext) hud = new FVDHud(hudCanvas, hudCanvas.getContext('2d'), { build: BUILD });
      const dl2 = $('decolist');
      if (dl2) dl2.innerHTML = Object.keys(scenesByName).slice(0, 500).map(n => '<option value="' + n + '">').join('');

      // audio name map (M8a)
      try { soundsMap = await loadJSON('sounds.json'); bootLog('audio: ' + Object.keys(soundsMap).length + ' sounds', 'ok'); }
      catch (e) { bootLog('no sound map (' + e.message + ')', 'dim'); }

      // localization (M8b)
      try {
        locales = await loadJSON('locales.json');
        const sel = $('locale');
        const ql = new URLSearchParams(location.search).get('locale');
        if (ql && locales[ql]) locale = ql;
        if (sel) { sel.innerHTML = Object.keys(locales).map(l => '<option value="' + l + '">' + l + '</option>').join(''); sel.value = locale; }
        applyLocale();
        bootLog('locale: ' + locale, 'ok');
      } catch (e) { bootLog('no locales (' + e.message + ')', 'dim'); }

      // original vector farm backdrop (1:1 art) — best-effort, not fatal if absent
      try {
        groundMeta = await loadJSON('ground.json');
        groundImg = new Image();
        await new Promise((res, rej) => { groundImg.onload = res; groundImg.onerror = () => rej(new Error('svg decode')); groundImg.src = 'ground.svg'; });
        bakeGround();
        bootLog('backdrop: original ground SVG (' + Math.round(groundImg.naturalWidth) + 'x' + Math.round(groundImg.naturalHeight) + ')', 'ok');
      } catch (e) { groundImg = null; groundMeta = null; bootLog('no ground backdrop (' + e.message + ') — gradient fallback', 'dim'); }

      // base grass terrain (tile map from the original FarmGame embed)
      try {
        const gm = await loadJSON('grasstiles.json');
        const imgs = await Promise.all(gm.variants.map(v => new Promise((res) => { const im = new Image(); im.onload = () => res(im); im.onerror = () => res(null); im.src = 'grasstiles/' + v; })));
        grassTiles = { w: gm.w, h: gm.h, imgs: imgs.filter(Boolean) };
        bootLog('grass: ' + grassTiles.imgs.length + ' tile variants', 'ok');
      } catch (e) { bootLog('no grass tiles (' + e.message + ')', 'dim'); }

      const t0 = performance.now();
      await refreshWorld();
      bakeGrass();
      await loadHorizon();
      await loadStrip();
      bootLog('boot world ' + Math.round(performance.now() - t0) + 'ms  ' + world.sizeX + 'x' + world.sizeY + ' · ' + objects.length + ' objects', 'ok');

      const tp = performance.now();
      await conn.call('UserService.postInit', []);
      bootLog('postInit ' + Math.round(performance.now() - tp) + 'ms', 'ok');

      // player level/xp/energy (original boot calls initUser; getBalance only returns gold/cash).
      // initUser data.player carries gold/cash/xp/energy/energyMax.
      try {
        const u = await conn.call('UserService.initUser', ['farmer', -420, true, false, 'flashControllerInit']);
        const d = (u && u.data) || u || {};
        const p = (d.userInfo && d.userInfo.player) || d.player || d;
        if (p.gold != null) player.gold = p.gold;
        if (p.cash != null) player.cash = p.cash;
        if (p.xp != null) player.xp = p.xp;
        if (p.energy != null) player.energy = p.energy;
        if (p.energyMax != null) player.energyMax = p.energyMax;
        player.avatar = (d.userInfo && d.userInfo.avatar) || p.avatar || d.avatar || player.avatar;   // {gender, items:{body,hair,shirt,...}}
        // irrigation water (TInitUser -> FeatureOptionsManager.loadObject(userInfo.featureOptions);
        // IrrigationManager.getWaterAmount("waterPlots") = featureOptions.irrigation.irrigation.waterPlots.farm.amount;
        // IrrigationManager.getFeatureData() falls back to {"waterPlots":{"farm":{"amount":20}}} when the
        // server sends no irrigation data — which is what the live client shows (20).
        const fo = (d.userInfo && d.userInfo.featureOptions) || {};
        const wp = fo.irrigation && fo.irrigation.irrigation && fo.irrigation.irrigation.waterPlots;
        player.water = (wp && wp.farm && wp.farm.amount != null) ? Number(wp.farm.amount) : 20;
        // neighbors (compressed) → friend/neighbor bar
        try {
          const nb = await gunzipB64(d.neighbors);
          if (Array.isArray(nb)) { player.neighbors = nb.map(n => ({ uid: n.uid, name: n.name || n.first_name || ('#' + n.uid), level: levelForXp(n.xp || 0) })); bootLog('neighbors: ' + player.neighbors.length, 'ok'); }
        } catch (e) { bootLog('neighbors decode skipped (' + e.message + ')', 'dim'); }
        updateHUD();
        bootLog('player: level=' + player.level + ' xp=' + player.xp + ' energy=' + player.energy + '/' + player.energyMax, 'ok');
      } catch (e) { bootLog('initUser skipped (' + e.message + ')', 'dim'); }

      const zq = parseFloat(new URLSearchParams(location.search).get('zoom'));
      // Original WorldSettingsManager.zoomCenterViewportPostWorldLoad sets the on-load default zoom
      // and centres the field (we have no avatar to centre on, so centre the field itself).
      if (zq) centerOnField(zq); else centerOnField(ZOOM_DEFAULT);
      if (__st.cam) { cam.x = __st.cam.x; cam.y = __st.cam.y; cam.zoom = __st.cam.zoom || 1; }  // restore saved view
      clampCamera();

      // original Farmville HUD overlay (per-world skin; farm uses hudSkin_Chat)
      if (hud) {
        try {
          const skinWorld = ($('skinworld') && $('skinworld').value) || 'Chat';
          await hud.load({ world: skinWorld, onAction: hudAction });
          const hm = new URLSearchParams(location.search).get('hudmenu');
          if (hm) hud._openMenu = hm;   // dev: open an action-menu popup for screenshots
          updateHUD();
          bootLog('hud: skin ' + skinWorld + ' (' + Object.keys(hud.scenes).join(',') + ')', 'ok');
        } catch (e) { bootLog('no HUD (' + e.message + ')', 'dim'); }
      }

      $('boot').style.display = 'none';
      loadSceneAsync('avatar2').then(s => { if (s) { avatarScene = s; applyCursor(); loadAvatarClothes(); } });   // player avatar base + outfit
      const vq = new URLSearchParams(location.search).get('visit');
      if (vq) visitNeighbor(vq);
      if (new URLSearchParams(location.search).get('market')) openMarket();
      if (new URLSearchParams(location.search).get('storage')) openStorage();
      const dq = new URLSearchParams(location.search).get('dialog');
      if (dq) openDialog(dq);
      // dev aids: ?hover=<objId|first> / ?sel=<objId|first> force the original highlight for screenshots
      const hlObj = (q) => (q === 'first' ? objects[0] : objects.find(o => String(o.id) === q)) || null;
      const hq = new URLSearchParams(location.search).get('hover');
      if (hq) hoveredObject = hlObj(hq);
      const sq = new URLSearchParams(location.search).get('sel');
      if (sq) { const so = hlObj(sq); if (so) { selected = so; if ($('panel')) $('panel').hidden = false; rebuildPanel(); } }

      requestAnimationFrame(frame);
      // Hidden/headless tabs never fire the first rAF; arm a fallback so frame() runs.
      groundFallbackT = setTimeout(() => { if (!rafFiredRecently()) frame(); }, 300);
    } catch (e) {
      bootLog('BOOT FAILED: ' + e.message, 'err');
    }
  }

  /** Re-fetch world + balance; rebuild objects; keep selection by id (temp->real adoption). */
  async function refreshWorld(adoptId) {
    const [wres, bal] = await Promise.all([
      conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]),
      conn.call('UserService.getBalance', []),
    ]);
    serverTime = conn.serverTime;
    world = wres && wres.world;
    const raw = world && world.objectsArray;
    objects = (Array.isArray(raw) ? raw : Object.values(raw || {})).map(normalizeObject);
    if (bal && bal.gold != null) player.gold = bal.gold;
    if (bal && bal.cash != null) player.cash = bal.cash;
    if (selected) {
      const prevSig = selected.id + '|' + selected.state + '|' + (selected.itemName || '');
      const targetId = (adoptId && selected.id >= TEMP_ID_START) ? adoptId : selected.id;
      selected = objects.find(o => o.id === targetId) || null;
      if (!selected) $('panel').hidden = true;
      else {
        // rebuild only when identity/state changed — keeps seed input alive across polls
        const sig = selected.id + '|' + selected.state + '|' + (selected.itemName || '');
        if (sig !== prevSig) rebuildPanel();
      }
    }
    updateHUD();
  }

  /** Visit a neighbor: load their farm read-only (WorldService.loadNeighborWorld) and re-bake the world. */
  async function visitNeighbor(uid) {
    const nb = (player.neighbors || []).find(n => String(n.uid) === String(uid));
    await runAction('visit', async () => {
      const r = await conn.call('WorldService.loadNeighborWorld', [String(uid)]);
      if (!r || !r.world) { toast('No farm for ' + uid); return; }
      visitingUid = String(uid);
      world = r.world;
      const raw = world.objectsArray;
      objects = (Array.isArray(raw) ? raw : Object.values(raw || {})).map(normalizeObject);
      selected = null; if ($('panel')) $('panel').hidden = true;
      bakeGrass(); await loadHorizon(); await loadStrip();
      centerOnField(ZOOM_DEFAULT);
      updateHUD();
      if (hud) hud.setState({ visiting: true, worldName: nb ? nb.name : ('#' + uid) });
      sfx('ui/sfx_ui_click_1.mp3', 0.4);
      toast('🚶 Visiting ' + (nb ? nb.name : uid));
    });
  }

  /** Return to the player's own farm. */
  async function goHome() {
    visitingUid = null;
    await refreshWorld();
    centerOnField(ZOOM_DEFAULT);
    sfx('ui/sfx_ui_click_2.mp3', 0.4);
    toast('🏡 Home');
  }
  function normalizeObject(o) {
    const m = itemMeta[o.itemName];
    // Plot.SIZE_X/SIZE_Y = 4 (Classes/Plot.as): a crop plot occupies a 4x4 tile footprint.
    const size = m ? [m[0], m[1]] : (o.className === 'Plot' ? [4, 4] : [1, 1]);
    const scale = m ? (m[2] || 1) : 1;
    const px = o.position ? o.position.x : 0, py = o.position ? o.position.y : 0, pz = o.position ? o.position.z : 0;
    return {
      id: o.id, className: o.className, state: o.state, itemName: o.itemName,
      pos: o.position || { x: 0, y: 0, z: 0 }, plantTime: o.plantTime || null,
      isJumbo: !!o.isJumbo, direction: o.direction || 0, size: size, scale: scale,
      // depth sorts by the object's base (front-bottom of its footprint). With the corrected
      // projection (grid (0,0) at the FRONT), the front is LOW x+y, so negate to draw the back first.
      depth: -(px + py + (size[0] + size[1]) * 0.5 + pz * 0.01),
    };
  }
  function centerOnWorld(zoomOverride) {
    if (!objects.length) return;
    // bounds over every object's footprint (not just its origin)
    let minx = Infinity, miny = Infinity, maxx = -Infinity, maxy = -Infinity;
    for (const o of objects) {
      const [fx, fy] = o.size || [1, 1];
      minx = Math.min(minx, o.pos.x); miny = Math.min(miny, o.pos.y);
      maxx = Math.max(maxx, o.pos.x + fx); maxy = Math.max(maxy, o.pos.y + fy);
    }
    minx -= 2; miny -= 2; maxx += 2; maxy += 2;
    const cx = (minx + maxx) / 2, cy = (miny + maxy) / 2;
    const isoW = ((maxx - minx) + (maxy - miny)) * TILE_W / 2;
    const isoH = ((maxx - minx) + (maxy - miny)) * TILE_H / 2;
    cam.zoom = Math.max(ZOOM_OUT_LIMIT, Math.min(ZOOM_IN_LIMIT, zoomOverride ? zoomOverride : Math.min((W - 140) / isoW, (H - 200) / isoH)));
    const c = iso(cx, cy);
    cam.x = -c.x * cam.zoom;
    cam.y = (H * PLANE_CENTER_Y) - (H * 0.46) - c.y * cam.zoom;
    clampCamera();
  }

  // Original WorldSettingsManager.zoomCenterViewportPostWorldLoad: set the on-load default zoom and
  // centre the FIELD (IsoViewport.centerViewport → centerOnTilePos(width/2, height/2)).
  function centerOnField(zoom) {
    cam.zoom = Math.max(ZOOM_OUT_LIMIT, Math.min(ZOOM_IN_LIMIT, zoom || ZOOM_DEFAULT));
    const c = iso((world.sizeX - 1) / 2, (world.sizeY - 1) / 2);
    cam.x = -c.x * cam.zoom;
    cam.y = (H * PLANE_CENTER_Y) - (H * 0.46) - c.y * cam.zoom;
  }

  // Original FarmTileMap.getFarmScrollBoundaries / FarmIsoViewport.setScrollPosition: the view is
  // clamped so you can't pan the farm off-screen. Bounds are expressed around the field-centred cam.
  const HORIZONTAL_EXTRA_BOUNDARY_PAD = 600;
  const VERTICAL_LOWER_EXTRA_BOUNDARY_PAD = 500;
  const VERTICAL_UPPER_EXTRA_BOUNDARY_PAD = 800;
  function clampCamera() {
    if (!world) return;
    const z = cam.zoom;
    const c = iso((world.sizeX - 1) / 2, (world.sizeY - 1) / 2);
    const camCx = -c.x * z;
    const camCy = (H * PLANE_CENTER_Y) - (H * 0.46) - c.y * z;
    // field diamond extents in screen px
    const fieldW = (world.sizeX + world.sizeY) * TILE_W / 2 * z;
    const fieldH = (world.sizeX + world.sizeY) * TILE_H / 2 * z;
    const hs = Math.max(0, fieldW / 2 - W / 2 + HORIZONTAL_EXTRA_BOUNDARY_PAD * z);
    const vs = fieldH / 2 - H / 2;
    const up = Math.max(0, vs + VERTICAL_UPPER_EXTRA_BOUNDARY_PAD * z);
    const lo = Math.max(-up, vs + VERTICAL_LOWER_EXTRA_BOUNDARY_PAD * z);
    cam.x = Math.max(camCx - hs, Math.min(camCx + hs, cam.x));
    cam.y = Math.max(camCy - lo, Math.min(camCy + up, cam.y));
  }

  // ---------- HUD ----------
  // XP level curve (FarmGameSettingsManager.getXPForLevel / getLevelForXP / getLevelProgressForXP).
  function xpForLevel(l) {
    if (!levelsData) return 0;
    const s = levelsData.startXP;
    if (l < s.length) return s[l];
    if (l >= levelsData.higherLevelBegin) return levelsData.higherLevelXp + (l - levelsData.higherLevelBegin) * levelsData.higherLevelStep;
    return s[s.length - 1];
  }
  function levelForXp(xp) {
    if (!levelsData) return 1;
    const s = levelsData.startXP, H = levelsData.higherLevelXp, step = levelsData.higherLevelStep, B = levelsData.higherLevelBegin;
    if (xp >= H) return (xp < H + step) ? B : B + Math.floor((xp - H) / step);
    let r = 1;
    for (let i = 1; i < s.length; i++) if (xp >= s[i]) r = i;
    return r;
  }
  function progressForXp(xp) {
    if (!levelsData) return 0;
    const l = levelForXp(xp), a = xpForLevel(l), b = xpForLevel(l + 1);
    return b > a ? Math.max(0, Math.min(1, (xp - a) / (b - a))) : 0;
  }

  function updateHUD() {
    $('h-gold').textContent = player.gold != null ? player.gold.toLocaleString() : '–';
    $('h-cash').textContent = player.cash != null ? player.cash.toLocaleString() : '–';
    $('h-energy').textContent = player.energy != null ? player.energy : '–';
    if (player.xp != null && levelsData) { player.level = levelForXp(player.xp); player.xpPct = progressForXp(player.xp); }
    $('h-level').textContent = player.level != null ? player.level : (player.xp != null ? '?' : '–');
    $('h-world').textContent = world ? (world.type + ' ' + world.sizeX + '×' + world.sizeY) : '–';
    if (hud) hud.setState({ gold: player.gold, cash: player.cash, level: player.level, energy: player.energy,
      energyMax: player.energyMax, xp: player.xp, xpPct: player.xpPct, water: player.water,
      worldName: (world && (world.name || world.farmName)) || player.name || 'Welcome',
      neighbors: player.neighbors || [] });
  }

  // HUD widget actions (original UI.as bottom-right cluster + home). Called by FVDHud.onAction.
  function hudAction(name) {
    if (name.indexOf('menu:') === 0) {
      const act = name.slice(5);
      sfx('ui/sfx_ui_click_1.mp3', 0.4);
      if (act === 'storage') { openStorage(); return; }
      if (act === 'market') { openMarket(); return; }
      toast('▸ ' + act.charAt(0).toUpperCase() + act.slice(1));
      return;
    }
    if (name.indexOf('neighbor:') === 0) {
      const uid = name.slice(9);
      if (uid !== 'empty') visitNeighbor(uid);
      return;
    }
    switch (name) {
      case 'zoomIn':  cam.zoom = Math.min(ZOOM_IN_LIMIT, cam.zoom * 1.1); clampCamera(); saveSettings(); break;
      case 'zoomOut': cam.zoom = Math.max(ZOOM_OUT_LIMIT, cam.zoom / 1.1); clampCamera(); saveSettings(); break;
      case 'camera':  centerOnWorld(); saveSettings(); sfx('ui/sfx_ui_click_1.mp3', 0.4); break;
      case 'home':    goHome(); break;
      case 'market':  sfx('ui/sfx_ui_click_1.mp3', 0.4); openMarket(); break;
      case 'sfx':     audioOn = !audioOn; saveSettings(); toast(audioOn ? '🔊 Sound on' : '🔇 Sound off'); break;
      case 'graphics': toast('Graphics'); break;
      case 'music':   toast('Music'); break;
      case 'water':   toast('Water'); break;
      case 'messages': toast('Messages'); break;
      case 'search':  toast('Search neighbors'); break;
      case 'addcoins': toast('Add Coins & Cash'); break;
      case 'fullscreen': {
        const g = document.getElementById('game');
        if (document.fullscreenElement) document.exitFullscreen();
        else if (g && g.requestFullscreen) g.requestFullscreen();
        break;
      }
      default: break;
    }
  }
  function fmtClock() { return new Date(serverTime * 1000).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit' }); }

  // ---------- farm actions (Phase 3) ----------
  let tempCounter = 0;
  function nextTempId() { return TEMP_ID_START + (++tempCounter); }

  function saveObj(o) {
    const s = { id: o.id, className: o.className || 'Plot', deleted: false };
    if (o.id >= TEMP_ID_START) s.tempId = o.id;
    s.position = { x: o.pos.x, y: o.pos.y, z: o.pos.z || 0 };
    return s;
  }

  const HOE = { id: -1, key: 'HOE:1' };

  async function runAction(label, fn) {
    if (busy) return;
    busy = true;
    setBusy(true);
    try {
      await fn();
    } catch (e) {
      toast('✗ ' + label + ': ' + e.message);
    } finally {
      busy = false;
      setBusy(false);
    }
  }

  function setBusy(b) { const p = $('panel'); if (p) p.style.opacity = b ? '0.55' : ''; }

  let toastTimer = null;
  function toast(msg) {
    const t = $('toast');
    t.textContent = msg;
    t.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { t.hidden = true; }, 2600);
  }

  // Equipment path: plow / place(=plant) — main farm loop per rpc-contract §6a.
  // Response is an array, one entry per plot; the real id lives in entry.data.id.
  async function doPlow(o) {
    const r = await conn.call('EquipmentWorldService.onUseEquipment', [
      'plow', HOE, { [o.id]: { position: { x: o.pos.x, y: o.pos.y, z: o.pos.z || 0 } } }, 'plowed',
    ]);
    return r && r[0] && r[0].data ? r[0].data.id : null;
  }

  async function doPlant(o, seedName) {
    const seed = seeds[seedName];
    if (!seed) throw new Error('unknown seed "' + seedName + '"');
    const code = seed.code || seedName.slice(0, 2).toUpperCase();
    const r = await conn.call('EquipmentWorldService.onUseEquipment', [
      'place', { id: -1, key: code + ':1' },
      { [o.id]: { position: { x: o.pos.x, y: o.pos.y, z: o.pos.z || 0 } } },
      seedName,
    ]);
    return r && r[0] && r[0].data ? r[0].data.id : null;
  }

  // Generic path: harvest / clear — rpc-contract §6b (response data = {id,...})
  async function doHarvest(o) {
    const r = await conn.call('WorldService.performAction', ['harvest', saveObj(o)]);
    return r && r.id != null ? r.id : o.id;
  }

  async function doClear(o) {
    await conn.call('WorldService.performAction', ['clear', saveObj(o)]);
    return null; // object removed
  }

  /** M2: sell a world object (server removes it and credits gold). */
  async function doSell(o) {
    await conn.call('WorldService.performAction', ['sell', saveObj(o)]);
    return null;
  }

  /** M2: place a non-crop world object (decoration/tree/building/animal) on empty ground. */
  // The live maps a world object's class via className -> Classes.<name>, else type -> class (FarmItem
  // .getMapResourceClassByType). A tree must be class "Tree" (not "Decoration") or it renders shadow-only.
  const TYPE_CLASS = { tree: 'Tree', building: 'Building', animal: 'Animal', decoration: 'Decoration', seed: 'Plot', plot: 'Plot', messageSign: 'MessageSign' };
  const classCache = {};
  async function itemClassFor(name) {
    if (classCache[name]) return classCache[name];
    let cls = 'Decoration';
    try {
      const d = await fetch('/api/items?q=' + encodeURIComponent(name)).then(r => r.json());
      const it = (d.items || []).find(x => x.name === name);
      if (it && TYPE_CLASS[it.type]) cls = TYPE_CLASS[it.type];
    } catch (e) { /* offline */ }
    classCache[name] = cls; return cls;
  }
  async function doPlaceDeco(gx, gy, itemName) {
    const className = await itemClassFor(itemName);
    const id = nextTempId();
    const save = { id, tempId: id, className, deleted: false, itemName, direction: 0, isJumbo: false, components: {}, position: { x: gx, y: gy, z: 0 } };
    const r = await conn.call('WorldService.performAction', ['place', save]);
    return r && r.id != null ? r.id : null;
  }

  async function onPanelAction(action, seedName) {
    const o = selected;
    if (!o || busy) return;
    if (visitingUid) { toast('Not your farm'); return; }
    const label = action + (seedName ? ' ' + seedName : '');
    await runAction(label, async () => {
      let adoptId = null;
      switch (action) {
        case 'plow':
          adoptId = await doPlow(o);
          sfx('actions/sfx_plow_01.mp3');
          toast('⛏ Plowed');
          break;
        case 'plant':
          adoptId = await doPlant(o, seedName);
          sfx('actions/sfx_plant_01.mp3');
          toast('🌱 Planted ' + seedName);
          break;
        case 'harvest': {
          const goldBefore = player.gold;
          adoptId = await doHarvest(o);
          await refreshWorld(adoptId);
          const delta = (player.gold || 0) - (goldBefore || 0);
          sfx('actions/sfx_harvest_crop_01.mp3');
          if (delta > 0) sfx('actions/sfx_receive_coins_01.mp3', 0.5);
          toast(delta > 0 ? '🧺 Harvested +' + delta + ' gold' : '🧺 Harvested');
          return; // already refreshed
        }
        case 'clear':
          await doClear(o);
          sfx('ui/sfx_ui_click_1.mp3', 0.5);
          selected = null;
          $('panel').hidden = true;
          toast('✕ Cleared');
          break;
        case 'sell':
          await doSell(o);
          sfx('actions/sfx_receive_coins_02.mp3', 0.6);
          selected = null;
          $('panel').hidden = true;
          toast('💰 Sold');
          break;
        case 'move':
          moveObj = o;
          toast('Click empty ground to move #' + o.id);
          return;
      }
      if (action !== 'harvest' && action !== 'move') await refreshWorld(adoptId);
    });
  }

  // ---------- drawing ----------
  function drawDiamond(g, cx, cy, w, h) {
    g.beginPath();
    g.moveTo(cx, cy - h / 2); g.lineTo(cx + w / 2, cy); g.lineTo(cx, cy + h / 2); g.lineTo(cx - w / 2, cy);
    g.closePath();
  }

  function drawTile(o, sx, sy, g) {
    g = g || ctx;
    const z = cam.zoom;
    const [fx, fy] = o.size || [1, 1];
    const c = worldToScreen({ x: o.pos.x + (fx - 1) / 2, y: o.pos.y + (fy - 1) / 2 });
    sx = c.x; sy = c.y;
    const w = (fx + fy) * TILE_W / 2 * z, h = (fx + fy) * TILE_H / 2 * z;
    // soil base per state
    let top = '#7bbf5a', edge = '#5f9e46';           // grass (default/fallow)
    if (o.state === 'plowed') { top = '#8a5a2b'; edge = '#6d451f'; }
    else if (o.state === 'fallow') { top = '#6f9c4e'; edge = '#577f3c'; }
    else if (o.state === 'withered') { top = '#8a7a4a'; edge = '#6d6038'; }
    // tile side (thickness)
    const th = TILE_W * 0.125 * z;
    g.fillStyle = edge;
    g.beginPath();
    g.moveTo(sx - w / 2, sy); g.lineTo(sx, sy + h / 2); g.lineTo(sx, sy + h / 2 + th); g.lineTo(sx - w / 2, sy + th);
    g.closePath(); g.fill();
    g.beginPath();
    g.moveTo(sx + w / 2, sy); g.lineTo(sx, sy + h / 2); g.lineTo(sx, sy + h / 2 + th); g.lineTo(sx + w / 2, sy + th);
    g.closePath(); g.fill();
    // tile top
    drawDiamond(g, sx, sy, w, h);
    g.fillStyle = top; g.fill();
    g.lineWidth = 1; g.strokeStyle = 'rgba(0,0,0,.18)'; g.stroke();
    // plowed furrows
    if (o.state === 'plowed') {
      g.strokeStyle = 'rgba(60,35,12,.5)'; g.lineWidth = Math.max(1, 2 * z);
      for (let i = -1; i <= 1; i++) {
        g.beginPath();
        g.moveTo(sx - w / 4 + i * TILE_W * 0.1 * z, sy - h / 6);
        g.lineTo(sx + w / 4 + i * TILE_W * 0.1 * z, sy + h / 6);
        g.stroke();
      }
    }
  }

  function drawCrop(o, sx, sy, g) {
    g = g || ctx;
    const z = cam.zoom;
    if (o.state === 'planted' || o.state === 'grown') {
      const url = imgFor(o.itemName);
      const im = getImg(url);
      const [fx, fy] = o.size || [1, 1];
      const c = worldToScreen({ x: o.pos.x + (fx - 1) / 2, y: o.pos.y + (fy - 1) / 2 });
      const size = (fx + fy) * TILE_W / 2 * 1.125 * z;
      const cy = c.y - size / 2 + TILE_W * 0.075 * z;
      if (im && im.complete && im.naturalWidth) {
        g.drawImage(im, c.x - size / 2, cy - size / 2, size, size);
      } else {
        // placeholder: colored blob with initials
        g.fillStyle = o.state === 'grown' ? '#7ed957' : '#4f8f3a';
        g.beginPath(); g.arc(c.x, cy, size * 0.32, 0, Math.PI * 2); g.fill();
        g.fillStyle = '#fff'; g.font = 'bold ' + (size * 0.3) + 'px system-ui';
        g.textAlign = 'center'; g.textBaseline = 'middle';
        g.fillText((o.itemName || '?').slice(0, 2).toUpperCase(), c.x, cy);
      }
    }
  }

  /** Draw a converted original stage tile (square sprite, iso art + transparency baked in).
      Returns true if it actually drew (image ready), false to fall back to synthetic. */
  function drawOriginalTile(o, url, sx, sy, g) {
    g = g || ctx;
    const im = getImg(url);
    if (!im || !im.complete || !im.naturalWidth) return false;
    const z = cam.zoom;
    // Crop tiles are 200x200 full-plot art (soil diamond + plant). The plot footprint is
    // Plot.SIZE_X x SIZE_Y = 4x4 tiles; its bounding width is (sizeX+sizeY)*TILE_W/2. The original
    // (MapResource.updateDisplayObjectTransform) scales the art so its full width = boxWidth
    // (scale = boxWidth/contentWidth), which leaves the soil diamond (~0.845 of the art) slightly
    // inside the footprint — hence the small gap between adjacent plots. Place the soil centre
    // (measured at ~(0.50, 0.71) of the art) on the footprint centre.
    const [fx, fy] = o.size || [1, 1];
    const boxWidth = (fx + fy) * TILE_W / 2;
    const S = boxWidth * z;
    const a = worldToScreen({ x: o.pos.x + (fx - 1) / 2, y: o.pos.y + (fy - 1) / 2 });
    g.drawImage(im, a.x - S * 0.50, a.y - S * 0.71, S, S);
    return true;
  }

  // ---------- world-object scenes (M2: decorations / trees / buildings / animals) ----------
  // Scenes are served statically from scenesbyname.json when mapped; otherwise the client asks the
  // server to convert the item's SWF on demand (fvng/scene.php), so ANY placed object renders even
  // if it wasn't in the offline batch — the world data always comes from the server on load.
  function getObjectScene(o) {
    const name = o.itemName;
    if (!name) return null;
    let sc = sceneCache.get(name);
    if (sc === undefined) {
      sceneCache.set(name, 'loading');
      const stem = scenesByName[name];
      const url = stem ? ('scenes/' + stem + '.scene.json?v=' + BUILD) : ('scene.php?item=' + encodeURIComponent(name));
      fetch(url).then(r => r.ok ? r.json() : null).then(raw => {
        if (!raw) { sceneCache.set(name, null); return null; }
        const s = new FVScene(raw);
        return s.load().then(() => sceneCache.set(name, s));
      }).catch(() => sceneCache.set(name, null));
      return null;
    }
    return (sc && sc !== 'loading') ? sc : null;
  }

  /** pick the render symbol from a world-object scene: direction variant, else the grown/mature
      state (the original uses SimpleHarvestableResource.getCurrentImageName -> "mature"), never the
      "bare" or master "static" placeholder symbol. */
  function objectSymbol(sc, dir) {
    const syms = sc.symbols();
    if (!syms.length) return null;
    const lower = syms.map(s => s.toLowerCase());
    const placeholder = s => /(_bare|_static|master|_icon)/i.test(s);
    const want = ((dir | 0) === 2 || (dir | 0) === 3) ? 'vertical' : 'horizontal';
    let i = lower.findIndex(s => s.endsWith('_' + want) && !placeholder(s));
    if (i < 0) i = lower.findIndex(s => s.endsWith('_mature'));
    if (i < 0) i = lower.findIndex(s => s.endsWith('_ripe'));
    if (i < 0) i = lower.findIndex(s => !placeholder(s));
    if (i < 0) i = 0;
    return syms[i];
  }

  /** draw a non-crop world object via its SWF scene; returns true when actually drawn.
      Uses the item's footprint (sizeX/sizeY) and imageScale for placement fidelity. */
  function drawSceneObject(o, g) {
    g = g || ctx;
    const sc = getObjectScene(o);
    if (!sc) return false;                       // still loading / failed
    const sym = objectSymbol(sc, o.direction);
    const dir = o.direction | 0;
    const b = sym ? sc.measure(0, sym) : sc.measure(0, '');
    const [fx, fy] = o.size || [1, 1];
    const a = worldToScreen({ x: o.pos.x + (fx - 1) / 2, y: o.pos.y + (fy - 1) / 2 }); // footprint centre
    // original MapResource.updateDisplayObjectTransform: scale = boxWidth / contentWidth * imageScale,
    // where boxWidth = the footprint's bounding width = (sizeX + sizeY) * TILE_WIDTH / 2.
    const boxWidth = (fx + fy) * TILE_W / 2;
    const k = cam.zoom * (boxWidth / (b.w || 1)) * (o.scale || 1);   // normalise art to footprint + imageScale
    const flip = (dir === 1 || dir === 2);        // mirror for the opposite iso half
    g.save();
    g.translate(a.x, a.y - (b.y + b.h) * k);      // bottom-centre of the sprite on the footprint centre
    if (flip) g.scale(-k, k); else g.scale(k, k);
    if (sym) sc.renderSymbol(g, sym, [1, 0, 0, 1, -(b.x + b.w / 2), 0]);
    else sc.render(g, 0);
    g.restore();
    return true;
  }

  /** draw one map object (world object, full-plot art, or synthetic tile+crop) into context g. */
  function drawObject(g, o, a) {
    if (o.className && o.className !== 'Plot') {
      if (!drawSceneObject(o, g)) { drawTile(o, a.x, a.y, g); drawCrop(o, a.x, a.y, g); }
      return;
    }
    const tu = tileUrl(o) || plotBaseUrl(o);
    if (tu && drawOriginalTile(o, tu, a.x, a.y, g)) return;
    drawTile(o, a.x, a.y, g);
    drawCrop(o, a.x, a.y, g);
  }

  // ---------- original object highlight (FarmGameObject.showHighlight) ----------
  // The original applies an OUTER GlowFilter(color, alpha=1, blurX=8, blurY=8, strength=20) to the
  // object's display object on mouse-over (removed on mouse-out). Default color = Constants
  // .COLOR_HIGHLIGHT = 0xFFAA00 (Classes/FarmGameObject.as:395-419).
  const HL_COLOR = '#ffaa00', HL_BLUR = 8, HL_STRENGTH = 20;
  const _hlBuf = {};
  function hlBuf(id, w, h) {
    let c = _hlBuf[id];
    if (!c) { c = _hlBuf[id] = document.createElement('canvas'); }
    if (c.width !== w || c.height !== h) { c.width = w; c.height = h; }
    return c;
  }

  /** screen-space bounding box of an object (matches drawSceneObject / full-plot art placement). */
  function objectScreenBox(o, a) {
    const [fx, fy] = o.size || [1, 1];
    const boxWidth = (fx + fy) * TILE_W / 2;
    if (o.className && o.className !== 'Plot') {
      const sc = getObjectScene(o);
      if (sc) {
        const sym = objectSymbol(sc, o.direction);
        const b = sym ? sc.measure(0, sym) : sc.measure(0, '');
        const k = cam.zoom * (boxWidth / (b.w || 1)) * (o.scale || 1);
        return { x: a.x - k * b.w / 2, y: a.y - k * b.h, w: Math.max(1, k * b.w), h: Math.max(1, k * b.h) };
      }
    }
    const S = boxWidth * cam.zoom;
    return { x: a.x - S * 0.5, y: a.y - S * 0.75, w: S, h: S };
  }

  /** render an object with the original outer glow behind it (1:1 with FarmGameObject.showHighlight). */
  function drawObjectGlow(o, a, color, blur, strength) {
    const box = objectScreenBox(o, a);
    const pad = Math.ceil(blur * 3) + 2;
    const w = Math.max(1, Math.ceil(box.w) + pad * 2), h = Math.max(1, Math.ceil(box.h) + pad * 2);
    const srcC = hlBuf('src', w, h), glowC = hlBuf('glow', w, h);
    const g0 = srcC.getContext('2d');
    g0.setTransform(1, 0, 0, 1, 0, 0); g0.clearRect(0, 0, w, h);
    g0.save(); g0.translate(pad - box.x, pad - box.y);
    drawObject(g0, o, a);
    g0.restore();
    const g1 = glowC.getContext('2d');
    g1.setTransform(1, 0, 0, 1, 0, 0); g1.clearRect(0, 0, w, h);
    g1.filter = 'blur(' + blur.toFixed(2) + 'px)';
    g1.drawImage(srcC, 0, 0);
    g1.filter = 'none';
    g1.globalCompositeOperation = 'source-in';
    g1.fillStyle = color; g1.fillRect(0, 0, w, h);
    g1.globalCompositeOperation = 'source-over';
    ctx.save();
    const passes = Math.max(1, Math.min(4, Math.round(strength / 5)));   // strength 20 -> strong opaque glow
    for (let i = 0; i < passes; i++) ctx.drawImage(glowC, box.x - pad, box.y - pad);
    ctx.drawImage(srcC, box.x - pad, box.y - pad);
    ctx.restore();
  }

  function drawTimerRing(o, sx, sy) {
    const seed = seeds[o.itemName];
    if (!seed || !seed.grow_time || o.plantTime == null) return;
    if (isWithered(o)) return;
    const z = cam.zoom;
    const [fx, fy] = o.size || [1, 1];
    const boxWidth = (fx + fy) * TILE_W / 2;
    const c = worldToScreen({ x: o.pos.x + (fx - 1) / 2, y: o.pos.y + (fy - 1) / 2 });
    const nowMs = serverTime * 1000;
    const total = seed.grow_time * GROW_UNIT_MS;
    const frac = Math.max(0, Math.min(1, (nowMs - o.plantTime) / total));
    const ready = frac >= 1;
    const r = boxWidth * 0.575 * z, cy = c.y - boxWidth * 0.375 * z;
    ctx.lineWidth = Math.max(2, TILE_W * 0.0625 * z);
    ctx.strokeStyle = 'rgba(0,0,0,.35)';
    ctx.beginPath(); ctx.arc(c.x, cy, r, 0, Math.PI * 2); ctx.stroke();
    ctx.strokeStyle = ready ? '#ffcf4d' : '#7ed957';
    ctx.beginPath(); ctx.arc(c.x, cy, r, -Math.PI / 2, -Math.PI / 2 + frac * Math.PI * 2); ctx.stroke();
    // countdown text
    let label;
    if (ready) label = 'READY';
    else {
      const rem = Math.max(0, total - (nowMs - o.plantTime));
      const m = Math.floor(rem / 60000), s = Math.floor((rem % 60000) / 1000);
      label = m + ':' + String(s).padStart(2, '0');
    }
    ctx.fillStyle = ready ? '#ffcf4d' : '#eafff0';
    ctx.font = 'bold ' + (TILE_W * 0.1625 * z) + 'px system-ui'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
    ctx.fillText(label, c.x, cy);
  }

  // Selection is shown with the original object glow (drawObjectGlow), not a synthetic outline.

  // ---------- original vector farm backdrop (1:1 art) ----------
  // ground.svg is the composed content of grass_themeBackground_12.swf at native scale
  // (24 units = 1px). Its anchor = field-plane center; fieldHalfWpx = half-width of the
  // base diamond. Map that onto our grid center, scaled so the plane spans our farm.
  let groundCanvas = null;   // offscreen raster of the SVG (fast per-frame scaling)
  function bakeGround() {
    if (!groundImg || !groundImg.naturalWidth) return false;
    const c = document.createElement('canvas');
    c.width = Math.round(groundImg.naturalWidth); c.height = Math.round(groundImg.naturalHeight);
    c.getContext('2d').drawImage(groundImg, 0, 0);
    groundCanvas = c;
    return true;
  }

  /** Bake the base grass terrain (original tile map) into an offscreen canvas in native tile
      resolution (pixel-perfect tiling), then scale the whole layer to the grid. Tiles are chosen
      per position with the original hash, giving the varied grass field. */
  function bakeGrass() {
    if (!grassTiles || !grassTiles.imgs.length || !world) return false;
    const sx = world.sizeX, sy = world.sizeY;
    const gw = grassTiles.w, gh = grassTiles.h;                 // native tile size (50x25)
    const isoN = (x, y) => ({ x: (x - y) * gw / 2, y: -(x + y) * gh / 2 });
    const minX = (0 - (sy - 1)) * gw / 2 - gw / 2;
    const maxX = ((sx - 1) - 0) * gw / 2 + gw / 2;
    const minY = -((sx - 1) + (sy - 1)) * gh / 2 - gh / 2;
    const maxY = 0 + gh / 2;
    const c = document.createElement('canvas');
    c.width = Math.ceil(maxX - minX); c.height = Math.ceil(maxY - minY);
    const g = c.getContext('2d');
    g.imageSmoothingEnabled = false;
    const imgs = grassTiles.imgs;
    for (let y = 0; y < sy; y++) {
      for (let x = 0; x < sx; x++) {
        const s = isoN(x, y);
        const idx = Math.abs(Math.floor(Math.sin(x * 97 + y) * 214013)) % imgs.length;
        g.drawImage(imgs[idx], Math.round(s.x - minX - gw / 2), Math.round(s.y - minY - gh / 2), gw, gh);
      }
    }
    grassCanvas = c; grassOrigin = { x: minX, y: minY }; grassScale = TILE_W / gw;
    return true;
  }

  /** Load the theme background ("outside image") for this farm size with the FULL scene engine
      (the original picks `backgroundPath + (width-2)/4 + ".swf"`). */
  async function loadHorizon() {
    if (!world) return false;
    const suffix = Math.round((world.sizeX - 2) / 4);
    for (const stem of ['horizon_' + suffix, 'horizon_12']) {
      try {
        const raw = await loadJSON('scenes/' + stem + '.scene.json?v=' + BUILD);
        const s = new FVScene(raw);
        await s.load();
        horizonScene = s;
        bakeHorizon();
        bootLog('horizon: ' + stem + ' (' + Object.keys(s.characters).length + ' chars)', 'ok');
        return !!horizonCanvas;
      } catch (e) { /* try next */ }
    }
    bootLog('no horizon scene — using SVG backdrop', 'dim');
    return false;
  }

  function bakeHorizon() {
    if (!horizonScene) return false;
    const b = horizonScene.measure(0, '');
    const c = document.createElement('canvas');
    c.width = Math.ceil(b.w); c.height = Math.ceil(b.h);
    const g = c.getContext('2d');
    g.translate(-b.x, -b.y);
    horizonScene.render(g, 0);
    horizonCanvas = c;
    // The environment scene is authored centred on the field centre; map the art centre into the
    // cropped canvas (the original centres the "outside image" on the field centre).
    horizonCenter = { x: b.x + b.w / 2, y: b.y + b.h / 2 };
  }

  /** Far sky/horizon strip (grass_theme.swf) — clouds + distant hills, tiled behind everything. */
  async function loadStrip() {
    try {
      const raw = await loadJSON('scenes/horizonstrip.scene.json?v=' + BUILD);
      const s = new FVScene(raw);
      await s.load();
      stripScene = s;
      const b = s.measure(0, '');
      const c = document.createElement('canvas');
      c.width = Math.round(b.w); c.height = Math.round(b.h);
      const g = c.getContext('2d');
      g.translate(-b.x, -b.y);
      s.render(g, 0);
      stripCanvas = c;
      // Seamless tiling: extend the source by BLEED columns that wrap around from the left edge, so
      // bilinear sampling at the tile's right edge reads real pixels (not transparent) — otherwise a
      // sub-pixel seam shows through (and scales up with zoom).
      const BLEED = 4;
      const bc = document.createElement('canvas');
      bc.width = c.width + BLEED; bc.height = c.height;
      const bg = bc.getContext('2d');
      bg.drawImage(c, 0, 0);
      bg.drawImage(c, 0, 0, BLEED, c.height, c.width, 0, BLEED, c.height);
      stripBleed = bc;
      // debug: is the art seamless? compare the wrap edge (col w-1 vs col 0) with an interior pair
      try {
        const id = g.getImageData(0, 0, c.width, c.height).data;
        const colDiff = (a, b) => { let d = 0, n = 0; for (let y = 0; y < c.height; y += 2) { const i = (y * c.width + a) * 4, j = (y * c.width + b) * 4; d += Math.abs(id[i] - id[j]) + Math.abs(id[i + 1] - id[j + 1]) + Math.abs(id[i + 2] - id[j + 2]) + Math.abs(id[i + 3] - id[j + 3]); n++; } return (d / n).toFixed(1); };
        bootLog('strip edge wrap diff=' + colDiff(0, c.width - 1) + ' interior diff=' + colDiff(100, 101) + ' w=' + c.width, 'dim');
      } catch (e) {}
      bootLog('sky strip: ' + Math.round(b.w) + 'x' + Math.round(b.h), 'ok');
    } catch (e) { bootLog('no sky strip (' + e.message + ')', 'dim'); }
  }

  // world settings (xml/gz/.../worldSettings.xml.gz) — the theme background ("outside image") is
  // drawn at OUTSIDE_IMAGE_SIZE_FACTOR of these visible dimensions, scaled to our grid.
  const OUTSIDE_W = 13900, OUTSIDE_H = 7900, OUTSIDE_FACTOR = 0.5;
  const ORIGINAL_TILE_W = 25;
  const SKY_COLOR = '#206fb1';   // grass_theme skyColor (0xFF206FB1) — sky ABOVE the horizon strip
  const BG_COLOR = '#43a143';    // grass_theme bgColor (0xFF43A143) — the green fields behind/around the farm
  const OUTLINE_COLOR = '#3a6f29'; // grass_theme outlineColor (0x3A6F29), drawOutline=true
  // Original FarmIsoViewport zoom range (ZOOM_OUT_LIMIT=0.302, ZOOM_IN_LIMIT=2.0). Our tiles are the
  // original 25px tiles, so ZOOM_SCALE == 1 and our zoom equals the original zoom directly.
  const ZOOM_SCALE = ORIGINAL_TILE_W / TILE_W;
  const ZOOM_OUT_LIMIT = 0.302 * ZOOM_SCALE;
  const ZOOM_IN_LIMIT = 2.0 * ZOOM_SCALE;
  const ZOOM_DEFAULT = 1.717 * ZOOM_SCALE;   // worldSettings.xml onLoadDefaults zoom for 'farm'

  function drawGround() {
    if (!world) return false;
    const C = { x: (world.sizeX - 1) / 2, y: (world.sizeY - 1) / 2 }; // grid center == field center
    const a = worldToScreen(C);
    // grass layer geometry (computed first so the sky strip can sit at the field's BACK edge)
    const kk = grassScale * cam.zoom;
    const ox = W / 2 + cam.x + grassOrigin.x * kk;
    const oy = H * 0.46 + cam.y + grassOrigin.y * kk;
    const cw = grassCanvas.width * kk, ch = grassCanvas.height * kk;
    // Base fill = theme bgColor (0xFF43A143) — the GREEN FIELDS that surround the farm. The original
    // clears the viewport with bgColor and only paints the sky (skyColor) ABOVE the horizon strip.
    ctx.fillStyle = BG_COLOR;
    ctx.fillRect(0, 0, W, H);
    // far sky/horizon strip (clouds + distant hills) tiled across the top, behind the environment.
    // Original FarmBackgroundRenderer.renderHorizon: zoomEffect = zoom / HORIZON_ZOOM_FACTOR = zoom*3,
    // horizontal scroll factor 2/3, bottom at world y=0 (the field's back vertex). The strip is a
    // background layer at the world scale.
    if (stripBleed) {
      // Original renderHorizon integerises the tile width and x (imageWidth:int, x:int) so adjacent
      // tiles meet exactly. We additionally draw from the edge-bled source (BLEED wrapped columns)
      // and overlap each tile by BLEED*zoom*3 px, so bilinear edge sampling never reveals a seam —
      // including when zoomed in (the seam scales with zoom otherwise).
      const ze = cam.zoom * 3 * (TILE_W / ORIGINAL_TILE_W);
      const iw = Math.round(stripCanvas.width * ze), ih = Math.round(stripCanvas.height * ze);
      const dw = Math.round(stripBleed.width * ze);        // tile + bleed, overlaps the next tile
      // Sit the strip LOWER so the environment's hills/river (drawn on top) mask its lower edge —
      // the strip is a distant backdrop, not a band floating above the hills. Its content (clouds +
      // hills) does not reach the very bottom of the exported canvas, so push it down accordingly.
      const bottomY = oy + ih * 0.01;                   // field back vertex + overlap behind the hills
      const topY = Math.round(bottomY - ih);
      const hpos = (cam.x - W / 2 * cam.zoom + W / 2) * (2 / 3);
      let x = Math.round(((hpos % iw) + iw) % iw) - iw;
      for (; x < W; x += iw) ctx.drawImage(stripBleed, x, topY, dw, ih);
      // sky (skyColor) fills everything above the strip
      if (topY > 0) { ctx.fillStyle = SKY_COLOR; ctx.fillRect(0, 0, W, topY); }
    }
    // theme background ("outside image") BEHIND the grass plane. The original draws the art at
    //   scale = zoom * OUTSIDE_IMAGE_SIZE_FACTOR (0.5), centred on the field.
    if (horizonCanvas) {
      const k = OUTSIDE_FACTOR * cam.zoom;
      ctx.drawImage(horizonCanvas, a.x - horizonCenter.x * k, a.y - horizonCenter.y * k, horizonCanvas.width * k, horizonCanvas.height * k);
    } else if (groundCanvas && groundMeta) {
      const k = OUTSIDE_FACTOR * cam.zoom;
      const ax = groundMeta.anchor[0] / 24, ay = groundMeta.anchor[1] / 24;
      ctx.drawImage(groundCanvas, a.x - ax * k, a.y - ay * k, groundCanvas.width * k, groundCanvas.height * k);
    }
    // base grass terrain (original tile map) ON TOP of the environment, aligned to the grid
    if (grassCanvas) {
      ctx.drawImage(grassCanvas, ox, oy, cw, ch);
      // farm lot outline (yimf drawOutline=true, outlineColor 0x3A6F29) — 2px (original) diamond
      // traced along the field edge, matching FarmGameWorld.renderLotLine
      const top = { x: ox + cw / 2, y: oy }, right = { x: ox + cw, y: oy + ch / 2 };
      const bottom = { x: ox + cw / 2, y: oy + ch }, left = { x: ox, y: oy + ch / 2 };
      ctx.strokeStyle = OUTLINE_COLOR;
      ctx.lineWidth = Math.max(1, 2 * (TILE_W / ORIGINAL_TILE_W) * cam.zoom);
      ctx.beginPath();
      ctx.moveTo(top.x, top.y); ctx.lineTo(right.x, right.y);
      ctx.lineTo(bottom.x, bottom.y); ctx.lineTo(left.x, left.y);
      ctx.closePath(); ctx.stroke();
    }
    return true;
  }

  // ---------- avatar (1:1 with MyLife.Assets.Avatar.ClothingConflictManager) ----------
  // Base = Avatar_standFront. Its clothing containers (chest.clothing, pelvis.clothing, head.hair,
  // ...) are CLEARED (clearAllClothes), then each equipped item's part symbols — named by
  // SimpleClothingItem.ALL_VIEWS className — are placed INTO their containerClip slot so they layer
  // with the body. Colour = getColorTransform: white fills -> Fill, black fills -> Outline. The skin
  // sprites are tinted with the body item's Fill/Outline.
  function metaFillOutline(meta) {
    const f = String(meta || '').match(/Fill:([0-9A-Fa-f]{6})/);
    const o = String(meta || '').match(/Outline:([0-9A-Fa-f]{6})/);
    return { fill: f ? '#' + f[1].toLowerCase() : null, outline: o ? '#' + o[1].toLowerCase() : null };
  }

  /** getColorTransform: white -> fill, black -> outline (applied to solid fills + strokes). */
  function tintWhiteBlack(scene, fill, outline) {
    if (!fill && !outline) return;
    for (const id in scene.chars) {
      const c = scene.chars[id];
      if (!c || c.type !== 'shape' || !c.prims) continue;
      for (const pr of c.prims) {
        if (pr.fill && pr.fill.kind === 'solid') {
          const col = String(pr.fill.color || '').toLowerCase();
          if (fill && (col === '#ffffff' || col === '#fefefe' || col === '#fffffe')) pr.fill.color = fill;
          else if (outline && (col === '#000000' || col === '#000001')) pr.fill.color = outline;
        }
        if (outline && pr.stroke && String(pr.stroke.color || '').toLowerCase() === '#000000') pr.stroke.color = outline;
      }
    }
  }

  let avatarSlots = null;    // containerClip path -> { char, m, order } in the base symbol
  function buildAvatarSlots() {
    if (avatarSlots) return avatarSlots;
    const MUL = window.FVScene_mul;
    const bc = avatarScene && avatarScene.chars[avatarScene.exports[AVATAR_BASE]];
    if (!bc || !MUL) return null;
    const map = {};
    let n = 0;
    const walk = (list, pm, prefix, depth) => {
      if (!list || depth > 8) return;
      const sorted = list.slice().sort((a, b) => (a.depth || 0) - (b.depth || 0));
      for (const p of sorted) {
        const m = MUL(pm, p.m || [1, 0, 0, 1, 0, 0]);
        const c = avatarScene.chars[p.char];
        const path = p.name ? prefix + p.name : null;
        if (path) map[path] = { char: p.char, m, order: n++ };
        if (c && c.type === 'sprite') walk(c.frames[0], m, path ? path + '.' : prefix, depth + 1);
      }
    };
    walk(bc.frames[0], [1, 0, 0, 1, 0, 0], '', 0);
    return (avatarSlots = map);
  }

  /** clearAllClothes: empty every clothing container so the base's baked default clothing is gone. */
  function clearAvatarContainers() {
    const slots = buildAvatarSlots();
    if (!slots || !avatarMap) return;
    const done = new Set();
    for (const part of avatarMap.parts) {
      const s = slots[part.containerClip];
      if (!s || done.has(s.char)) continue;
      done.add(s.char);
      const c = avatarScene.chars[s.char];
      if (c && c.type === 'sprite') for (const f of c.frames) f.length = 0;
    }
    // the base's own default hair-back / cape-back are replaced by the player's items
    const bc = avatarScene.chars[avatarScene.exports[AVATAR_BASE]];
    for (const f of bc.frames) for (const p of f) if (p.name === 'hairBack' || p.name === 'capeBack') p.visible = false;
  }

  /** tintSkin: the body item's Fill/Outline recolours the skin sprites (white -> fill, black -> outline). */
  function tintCharShapes(c, chars, fill, outline, depth) {
    if (!c || depth > 8) return;
    if (c.type === 'shape' && c.prims) {
      for (const pr of c.prims) {
        if (pr.fill && pr.fill.kind === 'solid') {
          const col = String(pr.fill.color || '').toLowerCase();
          if (fill && col === '#ffffff') pr.fill.color = fill;
          else if (col === '#000000') pr.fill = null;   // hide the base's baked default sleeve/shading
        }
      }
      return;
    }
    if (c.type === 'sprite') for (const p of c.frames[0]) tintCharShapes(chars[p.char], chars, fill, outline, depth + 1);
  }
  function tintAvatarSkin(skin) {
    const slots = buildAvatarSlots();
    if (!slots) return;
    for (const p of ['chest.skin', 'rightUpperArm.skin', 'rightForeArm.skin', 'rightHand.skin', 'leftUpperArm.skin', 'leftForeArm.skin', 'leftHand.skin', 'pelvis.skin', 'rightThigh.skin', 'rightCalf.skin', 'rightFoot.skin', 'leftThigh.skin', 'leftCalf.skin', 'leftFoot.skin']) {
      const s = slots[p];
      if (!s) continue;
      tintCharShapes(avatarScene.chars[s.char], avatarScene.chars, skin.fill, skin.outline, 0);
    }
  }


  // ---------- avatar outfit (avatarmap.json) ----------
  // Each clothing item SWF (mylife/avatar_assets/<filename>.swf) exports part symbols named by
  // SimpleClothingItem.ALL_VIEWS className (e.g. ChestShirtFront, PelvisPantsFront, HairFront).
  // Each part is placed into its containerClip slot in the base (mirrors getPartList/addClothingItem).
  let avatarParts = null;    // containerClip path -> [{ scene, sym, back }]
  async function loadAvatarClothes() {
    if (!avatarScene || !avatarMap) return;
    const slots = buildAvatarSlots();
    if (!slots) return;
    clearAvatarContainers();
    const items = (player.avatar && player.avatar.items) || {};
    const avq = new URLSearchParams(location.search).get('avatar');   // dev: ?avatar=none|hair,shirt,...
    if (avq === 'none') { avatarParts = {}; return; }
    const only = avq ? new Set(avq.split(',')) : null;
    const body = items.body || {};
    const bmo = metaFillOutline(body.metaData);
    const skin = { fill: bmo.fill || '#ffdca9', outline: bmo.outline || '#7b6240' };
    tintAvatarSkin(skin);
    const byClip = {};
    for (const cat of Object.keys(items)) {
      const it = items[cat];
      if (!it || !it.filename || cat === 'body') continue;   // body = skin tint only
      if (only && !only.has(cat)) continue;
      const sc = await loadSceneAsync('av_' + it.filename);
      if (!sc) continue;
      const mo = metaFillOutline(it.metaData);
      const skinCat = (cat === 'face' || cat === 'ears' || cat === 'nose');
      tintWhiteBlack(sc, skinCat ? skin.fill : mo.fill, skinCat ? skin.outline : mo.outline);
      const syms = sc.symbols();
      for (const part of avatarMap.parts) {
        if (!slots[part.containerClip]) continue;            // slot not present on this base pose
        if (/Back$/.test(part.className)) continue;          // *Back parts belong to the back clip (avatarBackClip)
        const sym = syms.find(n => n === part.className || n.endsWith('.' + part.className));
        if (!sym) continue;                                  // this item doesn't provide that part
        (byClip[part.containerClip] = byClip[part.containerClip] || []).push({ scene: sc, sym });
      }
    }
    avatarParts = byClip;
  }

  /** render the base display list, injecting the clothing parts at their containerClip slots (interleaved). */
  function drawAvatarNode(ctx, charId, m, parts, path, depth) {
    const sc = avatarScene, c = sc.chars[charId];
    if (!c || depth > 32) return;
    if (c.type === 'shape') return sc._drawShape(ctx, c, m, 1);
    if (c.type === 'bitmap') return sc._drawBitmap(ctx, c, charId, m, 1);
    if (c.type === 'text') return sc._drawText(ctx, c, m, 1);
    if (c.type === 'button') return sc._drawButton(ctx, c, m, 1, depth, 0);
    if (c.type !== 'sprite') return;
    const MUL = window.FVScene_mul;
    const sorted = c.frames[0].slice().sort((a, b) => (a.depth || 0) - (b.depth || 0));
    for (const p of sorted) {
      if (p.visible === false) continue;
      const mm = MUL(m, p.m || [1, 0, 0, 1, 0, 0]);
      const childPath = p.name ? (path ? path + '.' + p.name : p.name) : path;
      const list = parts[childPath];
      if (list) for (const part of list) part.scene.renderSymbol(ctx, part.sym, mm, 0);
      drawAvatarNode(ctx, p.char, mm, parts, childPath, depth + 1);
    }
  }

  function drawAvatar() {
    if (!avatarScene || !world) return;
    if (!avatarPos) avatarPos = { x: Math.floor(world.sizeX / 2), y: Math.floor(world.sizeY / 2) };
    const s = worldToScreen({ x: avatarPos.x, y: avatarPos.y });
    // soft ground shadow
    ctx.save(); ctx.globalAlpha = 0.28; ctx.fillStyle = '#0a1a0e';
    ctx.beginPath(); ctx.ellipse(s.x, s.y, 20 * cam.zoom, 10 * cam.zoom, 0, 0, Math.PI * 2); ctx.fill();
    ctx.restore();
    const b = avatarScene.measure(0, AVATAR_SYM);
    if (!b.h) return;
    // original FarmAvatar.scaleX/scaleY = gameSettings.avatarScale (0.5)
    const k = AVATAR_SCALE * cam.zoom;
    const A0 = [1, 0, 0, 1, -(b.x + b.w / 2), -(b.y + b.h)];
    ctx.save();
    ctx.translate(s.x, s.y); ctx.scale(k, k);
    drawAvatarNode(ctx, avatarScene.exports[AVATAR_BASE], A0, avatarParts || {}, '', 0);
    ctx.restore();
  }

  function frame() {
    lastRafTs = performance.now();
    // background
    const g = ctx.createLinearGradient(0, 0, 0, H);
    g.addColorStop(0, '#2b5a34'); g.addColorStop(1, '#16301f');
    ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);

    // original vector ground (1:1) — replaces synthetic grid when present
    if (!drawGround()) {
      // faint iso grid for depth
      ctx.strokeStyle = 'rgba(255,255,255,.04)'; ctx.lineWidth = 1;
      const span = 30;
      for (let i = -span; i <= span; i++) {
        let a = worldToScreen({ x: i, y: -span }), b = worldToScreen({ x: i, y: span });
        ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y); ctx.stroke();
        a = worldToScreen({ x: -span, y: i }); b = worldToScreen({ x: span, y: i });
        ctx.beginPath(); ctx.moveTo(a.x, a.y); ctx.lineTo(b.x, b.y); ctx.stroke();
      }
    }

    // objects + avatar depth-sorted together (the avatar is a world object at the centre tile)
    const av = avatarPos || { x: Math.floor(world.sizeX / 2), y: Math.floor(world.sizeY / 2) };
    const avDepth = -(av.x + av.y + 1);   // 1x1 footprint, same depth formula as normalizeObject
    const sorted = objects.slice().sort((a, b) => a.depth - b.depth);
    let avDrawn = false;
    for (const o of sorted) {
      if (!avDrawn && o.depth >= avDepth) { drawAvatar(); avDrawn = true; }
      const s = worldToScreen(o.pos);
      if (s.x < -200 || s.x > W + 200 || s.y < -200 || s.y > H + 200) continue;
      const [ffx, ffy] = o.size || [1, 1];
      const a = worldToScreen({ x: o.pos.x + (ffx - 1) / 2, y: o.pos.y + (ffy - 1) / 2 }); // footprint centre
      // original hover/selection highlight: outer GlowFilter on the object's display object
      const showHover = o === hoveredObject && !(dialog && dialog.isOpen());
      if (showHover || o === selected) drawObjectGlow(o, a, HL_COLOR, HL_BLUR * cam.zoom, HL_STRENGTH);
      else drawObject(ctx, o, a);
      drawTimerRing(o, s.x, s.y);
    }
    if (!avDrawn) drawAvatar();

    // live clock + panel countdown (single span update, no DOM rebuild)
    serverTime = conn ? conn.serverTime : serverTime;
    $('h-clock').textContent = fmtClock();
    if (selected && selected.state === 'planted') {
      const gi = growInfo(selected);
      const t = $('timer');
      if (gi && t) {
        const m = Math.floor(gi.rem / 60000), s = Math.floor((gi.rem % 60000) / 1000);
        const txt = gi.ready ? 'Ready ✓' : m + ':' + String(s).padStart(2, '0');
        if (t.textContent !== txt) { t.textContent = txt; t.classList.toggle('ready', gi.ready); }
      }
    }

    // modal UI dialog on top (#3)
    if (dialog && dialog.isOpen()) dialog.render(performance.now());

    // original Farmville HUD (M-HUD) — hidden while a modal dialog is open (dialog draws on #stage)
    if (hud) {
      const modal = dialog && dialog.isOpen();
      if (hudCanvas) hudCanvas.style.display = modal ? 'none' : 'block';
      if (!modal) hud.render(performance.now());
    }

    // dev aid: ?stop=N renders N frames then halts (reliable headless screenshots)
    if (STOP && ++framesDrawn >= STOP) return;
    requestAnimationFrame(frame);
    // Headless/hidden tabs throttle rAF to ~0fps; keep the loop alive with a slow
    // fallback so the farm still renders (and screenshots work) when rAF is starved.
    clearTimeout(groundFallbackT);
    groundFallbackT = setTimeout(() => { if (!rafFiredRecently()) frame(); }, 500);
  }
  let groundFallbackT = null;
  let lastRafTs = 0;
  let framesDrawn = 0;
  function rafFiredRecently() { return performance.now() - lastRafTs < 1200; }

  function growInfo(o) {
    const seed = seeds[o.itemName];
    if (!seed || !seed.grow_time || o.plantTime == null) return null;
    const nowMs = serverTime * 1000, total = seed.grow_time * GROW_UNIT_MS;
    const rem = Math.max(0, total - (nowMs - o.plantTime));
    return { rem, ready: rem <= 0 };
  }

  function row(k, v) { return '<div class="row"><span class="k">' + k + '</span><span>' + v + '</span></div>'; }

  /** Rebuild the selection panel (called on select / after world refresh). */
  function rebuildPanel() {
    const o = selected;
    const body = $('panel-body');
    if (!o || !body) return;
    const seed = seeds[o.itemName];
    let html = '';
    html += row('Object', '#' + o.id + (o.id >= TEMP_ID_START ? ' (new)' : '') + ' · ' + (o.className || ''));
    html += '<div class="row"><span class="k">State</span><span class="badge b-' + o.state + '">' + o.state + '</span></div>';
    if (o.itemName) {
      html += row('Item', o.itemName);
      if (seed && seed.coin_yield != null) html += row('Yield', seed.coin_yield + ' gold');
      const gi = growInfo(o);
      if (gi) {
        const m = Math.floor(gi.rem / 60000), s = Math.floor((gi.rem % 60000) / 1000);
        html += '<div class="row"><span class="k">Grows in</span><span id="timer" class="' + (gi.ready ? 'ready' : '') + '">' + (gi.ready ? 'Ready ✓' : m + ':' + String(s).padStart(2, '0')) + '</span></div>';
      }
    }
    html += row('Position', '(' + o.pos.x + ', ' + o.pos.y + ')');

    // actions by state
    let btns = '';
    if (o.state === 'fallow' || o.state === 'withered') {
      btns += '<button class="btn" data-action="plow">⛏ Plow <small>15g</small></button>';
    } else if (o.state === 'plowed') {
      btns += '<div class="plantrow"><input id="seedpick" list="seedlist" placeholder="seed name…" spellcheck="false">'
            + '<datalist id="seedlist"></datalist><button class="btn go" data-action="plant">🌱 Plant</button></div>';
    } else if (o.state === 'planted') {
      btns += '<button class="btn dim" disabled>⏳ Growing…</button>';
    } else if (o.state === 'grown') {
      btns += '<button class="btn go" data-action="harvest">🧺 Harvest' + (seed && seed.coin_yield != null ? ' <small>+' + seed.coin_yield + 'g</small>' : '') + '</button>';
    }
    btns += '<button class="btn warn" data-action="clear">✕ Clear</button>';
    if (o.className && o.className !== 'Plot') {
      btns = '<button class="btn" data-action="move">↔ Move</button>'
           + '<button class="btn warn" data-action="sell">💰 Sell</button>'
           + '<button class="btn warn" data-action="clear">✕ Clear</button>';
    }
    html += '<div class="actions">' + btns + '</div>';

    body.innerHTML = html;
    const dl = $('seedlist');
    if (dl && !dl.dataset.filled) {
      dl.dataset.filled = '1';
      const names = Object.keys(seeds).filter(n => seeds[n].grow_time != null);
      names.sort((a, b) => (seeds[a].grow_time - seeds[b].grow_time) || a.localeCompare(b));
      dl.innerHTML = names.slice(0, 400).map(n =>
        '<option value="' + n + '">' + (seeds[n].cost != null ? ' (' + seeds[n].cost + 'g)' : '') + '</option>').join('');
    }
  }

  // ---------- interaction ----------
  canvas.addEventListener('mousedown', e => { if (dialog && dialog.isOpen()) { dialog.onDown(e); return; } if (hud && hud.onDown(e)) { hudCaptured = true; return; } dragging = true; moved = 0; lastX = e.clientX; lastY = e.clientY; canvas.classList.add('dragging'); canvas.style.cursor = 'url("' + CURSOR_IMG.handClosed + '") 12 20, auto'; });
  window.addEventListener('mouseup', e => {
    if (dialog && dialog.isOpen()) { dialog.onUp(e); return; }
    if (hudCaptured) { if (hud) hud.onUp(e); hudCaptured = false; dragging = false; canvas.classList.remove('dragging'); applyCursor(); return; }
    if (dragging && moved < 5) handleClick(e);
    if (dragging && moved >= 5) saveSettings();
    dragging = false; canvas.classList.remove('dragging'); applyCursor();
  });
  window.addEventListener('mousemove', e => {
    if (dialog && dialog.isOpen()) { dialog.onMove(e); return; }
    if (hud) hud.onMove(e);
    if (dragging) {
      const dx = e.clientX - lastX, dy = e.clientY - lastY;
      cam.x += dx; cam.y += dy; moved += Math.abs(dx) + Math.abs(dy);
      clampCamera();
      lastX = e.clientX; lastY = e.clientY;
      return;
    }
    hoveredObject = pickObject(e.clientX, e.clientY).o;
    applyCursor();
  });
  canvas.addEventListener('mouseleave', () => { hoveredObject = null; });
  canvas.addEventListener('wheel', e => {
    e.preventDefault();
    if (dialog && dialog.isOpen()) return;
    const factor = e.deltaY < 0 ? 1.1 : 1 / 1.1;
    cam.zoom = Math.max(ZOOM_OUT_LIMIT, Math.min(ZOOM_IN_LIMIT, cam.zoom * factor));
    clampCamera();
    saveSettings();
  }, { passive: false });
  window.addEventListener('keydown', e => { if (e.key === 'Escape' && dialog && dialog.isOpen()) dialog.close(); });

  /** true when a sizeX×sizeY footprint at (x,y) is in-bounds and clear of other objects */
  function footprintFree(x, y, sx, sy) {
    if (!world || x < 0 || y < 0 || x + sx > world.sizeX || y + sy > world.sizeY) return false;
    for (const o of objects) {
      const [fx, fy] = o.size || [1, 1];
      if (x < o.pos.x + fx && x + sx > o.pos.x && y < o.pos.y + fy && y + sy > o.pos.y) return false;
    }
    return true;
  }

  /** pick the object under a screen point (footprint first, then nearest base) + its world tile. */
  function pickObject(cx, cy) {
    const g = screenToWorld(cx, cy);
    let best = null;
    for (const o of objects) {
      const [fx, fy] = o.size || [1, 1];
      if (g.x >= o.pos.x && g.x < o.pos.x + fx && g.y >= o.pos.y && g.y < o.pos.y + fy) { best = o; break; }
    }
    // fallback: nearest sprite centre within a tile radius (tall sprites overhang their footprint)
    if (!best) {
      let bestD = TILE_W * cam.zoom * 0.6;
      for (const o of objects) {
        const s = worldToScreen(o.pos);
        const d = Math.hypot(s.x - cx, s.y - cy);
        if (d < bestD) { bestD = d; best = o; }
      }
    }
    return { o: best, g };
  }

  function handleClick(e) {
    let { o: best, g } = pickObject(e.clientX, e.clientY);
    if (!best && world && !visitingUid) {
      // empty ground tile -> place/move/spawn a temp plot
      if (g.x >= 0 && g.y >= 0 && g.x < world.sizeX && g.y < world.sizeY
          && !objects.some(o => { const [fx, fy] = o.size || [1, 1]; return g.x >= o.pos.x && g.x < o.pos.x + fx && g.y >= o.pos.y && g.y < o.pos.y + fy; })) {
        if (placeMode) {
          const item = placeMode;
          const m = itemMeta[item];
          const [px, py] = m ? [m[0], m[1]] : [1, 1];
          if (!footprintFree(g.x, g.y, px, py)) { toast('Not enough room for ' + item + ' (' + px + '×' + py + ')'); return; }
          runAction('place ' + item, async () => {
            const id = await doPlaceDeco(g.x, g.y, item);
            sfx('actions/sfx_building_place.mp3');
            if (placeConsume) { await conn.call('UserService.consumeInventoryItem', [item, 1]); await loadStorage(); }
            await refreshWorld(id);
            toast('🪑 Placed ' + item);
          });
          return;
        }
        if (moveObj) {
          const mo = moveObj; moveObj = null;
          runAction('move', async () => {
            await conn.call('WorldService.performAction', ['move', { id: mo.id, className: mo.className || 'Plot', deleted: false, position: { x: g.x, y: g.y, z: 0 } }]);
            sfx('ui/sfx_ui_click_2.mp3', 0.5);
            await refreshWorld(mo.id);
            toast('↔ Moved #' + mo.id);
          });
          return;
        }
        best = normalizeObject({ id: nextTempId(), className: 'Plot', state: 'fallow', position: { x: g.x, y: g.y, z: 0 } });
      }
    }
    selected = best;
    $('panel').hidden = !best;
    if (best) rebuildPanel();
  }

  // panel action delegation (buttons are rebuilt, so one listener on the container)
  $('panel').addEventListener('click', e => {    const b = e.target.closest('button[data-action]');
    if (!b || b.disabled) return;
    const action = b.dataset.action;
    const seedName = action === 'plant' ? (($('seedpick') && $('seedpick').value.trim().toLowerCase()) || null) : null;
    if (action === 'plant' && !seedName) { toast('Type a seed name first'); return; }
    onPanelAction(action, seedName);
  });

  // M2: arm/disarm placement of a mapped world object
  const placeBtn = $('placebtn');  if (placeBtn) placeBtn.addEventListener('click', () => {
    const v = (($('decopick') && $('decopick').value) || '').trim().toLowerCase();
    if (!v) { toast('Type an item name first'); return; }
    if (!scenesByName[v] && !itemMeta[v]) { toast('No scene or item data for "' + v + '"'); return; }
    placeMode = (placeMode === v) ? null : v;
    placeBtn.style.background = placeMode ? '#2f5a2a' : '';
    cursorTool = placeMode ? 'shovel' : null; applyCursor();   // original tool cursor while placing
    toast(placeMode ? 'Click empty ground to place ' + v : 'Placement cancelled');
  });

  const muteBtn = $('mute');
  if (muteBtn) muteBtn.addEventListener('click', () => { audioOn = !audioOn; muteBtn.textContent = audioOn ? '🔊' : '🔇'; saveSettings(); });

  const locSel = $('locale');
  if (locSel) locSel.addEventListener('change', () => { locale = locSel.value; applyLocale(); saveSettings(); });

  const fitBtn = $('fitbtn');
  if (fitBtn) fitBtn.addEventListener('click', () => { centerOnWorld(); saveSettings(); });

  // ---------- market browser (M3a): reads the DB-driven catalog at /api/items ----------
  let marketLoaded = false;
  let mktType = '';   // current category tab ('' = Featured/all)
  const MKT_LABELS = { seed: 'Seeds', tree: 'Trees', animal: 'Animals', building: 'Buildings', decoration: 'Decorations', vehicle: 'Vehicles', consumable: 'Consumables', currency_exchange: 'Currency', itembuff: 'Boosts', buff: 'Boosts', fuel: 'Fuel', plot: 'Plots', expansionAccess: 'Expansions', change_farm: 'Farms', messageSign: 'Signs', ugc_part: 'UGC' };
  const mktLabel = t => MKT_LABELS[t] || (t ? t[0].toUpperCase() + t.slice(1) : t);
  const scenePromises = new Map();
  function loadSceneAsync(stem) {
    if (scenePromises.has(stem)) return scenePromises.get(stem);
    const p = fetch('scenes/' + stem + '.scene.json?v=' + BUILD).then(r => r.json()).then(raw => {
      const s = new FVScene(raw); return s.load().then(() => s);
    }).catch(() => null);
    scenePromises.set(stem, p); return p;
  }
  // render an original SWF window as the panel chrome (background canvas)
  async function renderPanelBg(canvasId, stem) {
    const canvas = $(canvasId);
    if (!canvas) return;
    const sc = await loadSceneAsync(stem);
    if (!sc) return;
    const W = 960, H = 560, dpr = Math.min(window.devicePixelRatio || 1, 2);
    canvas.width = Math.round(W * dpr); canvas.height = Math.round(H * dpr);
    const g = canvas.getContext('2d'); g.scale(dpr, dpr); g.clearRect(0, 0, W, H);
    const b = sc.measure(0, '');
    const s = Math.min(W / b.w, H / b.h);
    g.translate((W - b.w * s) / 2 - b.x * s, (H - b.h * s) / 2 - b.y * s);
    g.scale(s, s);
    sc.render(g, 0);
  }
  function renderMarket() {
    const cv = $('mkt-canvas'); if (!cv || !market) return;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const W = cv.clientWidth || 960, H = cv.clientHeight || 560;
    if (cv.width !== Math.round(W * dpr) || cv.height !== Math.round(H * dpr)) { cv.width = Math.round(W * dpr); cv.height = Math.round(H * dpr); }
    const ctx = cv.getContext('2d'); ctx.setTransform(dpr, 0, 0, dpr, 0, 0); ctx.clearRect(0, 0, W, H);
    market.render(ctx, W, H);
  }
  async function loadMarket() {
    const url = '/api/items?buyable=1&limit=200' + (mktType ? '&type=' + encodeURIComponent(mktType) : '');
    try {
      const data = await fetch(url).then(r => r.json());
      if (market) { market.setItems((data.items || []).slice(0, 9)); renderMarket(); }   // LE grid = 9 slots
    } catch (e) { /* offline */ }
  }
  // original item art as a canvas (for the market binder)
  const itemScenePromises = new Map();
  function loadItemScene(name) {
    if (itemScenePromises.has(name)) return itemScenePromises.get(name);
    const stem = scenesByName[name];
    const url = stem ? ('scenes/' + stem + '.scene.json?v=' + BUILD) : ('scene.php?item=' + encodeURIComponent(name));
    const p = fetch(url).then(r => r.ok ? r.json() : null).then(raw => {
      if (!raw) return null;
      const s = new FVScene(raw); return s.load().then(() => s);
    }).catch(() => null);
    itemScenePromises.set(name, p); return p;
  }
  async function itemArt(name) {
    const sc = await loadItemScene(name);
    if (!sc) return null;
    const sym = sc.symbols().length ? sc.symbols()[0] : null;
    const b = sym ? sc.measure(0, sym) : sc.measure(0, '');
    if (!b.w || !b.h) return null;
    const c = document.createElement('canvas'); const S = 128; c.width = S; c.height = S;
    const g = c.getContext('2d');
    const k = Math.min(S * 0.86 / b.w, S * 0.86 / b.h);
    g.translate((S - b.w * k) / 2 - b.x * k, (S - b.h * k) / 2 - b.y * k); g.scale(k, k);
    if (sym) sc.renderSymbol(g, sym, [1, 0, 0, 1, 0, 0], 0); else sc.render(g, 0);
    c.ready = true;
    return c;
  }
  async function openMarket() {
    $('market').hidden = false;
    if (!market) {
      const sc = await loadSceneAsync('dlg_FV_Market_LE');
      if (!sc) { toast('Market unavailable'); return; }
      market = new FVMarketWindow(sc, {
        level: player.level, gold: player.gold, cash: player.cash, artFor: itemArt,
        onBuy: (name) => buyItem(name),
        onTab: (it) => { mktType = (it && it.data && it.data !== 'special') ? it.data : ''; loadMarket(); },
        onRender: () => renderMarket(),
        onClose: () => { $('market').hidden = true; },
      });
      const icons = [];
      for (let i = 1; i <= 8; i++) { const img = new Image(); img.src = 'market/tab' + i + '.png'; await new Promise(r => { img.onload = r; img.onerror = r; }); icons.push(img); }
      market.setIcons(icons);
    }
    await loadMarket();
  }
  const mktBtn = $('marketbtn');
  if (mktBtn) mktBtn.addEventListener('click', () => { if ($('market').hidden) openMarket(); else $('market').hidden = true; });
  const mktCanvas = $('mkt-canvas');
  if (mktCanvas) {
    mktCanvas.addEventListener('mousemove', e => { if (!market) return; const r = mktCanvas.getBoundingClientRect(); mktCanvas.style.cursor = market.move(e.clientX - r.left, e.clientY - r.top) ? 'pointer' : 'default'; });
    mktCanvas.addEventListener('mouseup', e => { if (!market) return; const r = mktCanvas.getBoundingClientRect(); market.up(e.clientX - r.left, e.clientY - r.top); renderMarket(); });
  }

  // ---------- storage (original window binder) ----------
  async function openStorage() {
    $('storage').hidden = false;
    if (!storageWin) {
      storageWin = new FVStorage($('st-canvas'), {
        build: BUILD, artFor: itemArt, hasScene: (n) => !!scenesByName[n],
        onAction: (action, name) => storageAction(action, name),
      });
      await storageWin.open('dlg_FV_Storage_transfer');
    }
    loadStorage();
  }
  async function storageAction(action, name) {
    if (action === 'close') { $('storage').hidden = true; }
    else if (action === 'expand') { toast('Expand Storage is not available'); }
    else if (action === 'place') {
      placeMode = name; placeConsume = true; cursorTool = 'shovel'; applyCursor();
      $('storage').hidden = true; toast('Click empty ground to place ' + name);
    } else if (action === 'sell') {
      const r = await conn.call('UserService.sellStoredItem', [{ code: name }, false, 0, 1]);
      if (r && r.gold) player.gold = (player.gold || 0) + r.gold;
      sfx('actions/sfx_receive_coins_02.mp3', 0.6);
      updateHUD(); toast('💰 Sold ' + name); await loadStorage();
    }
  }
  async function loadStorage() {
    try { const r = await conn.call('UserService.getInventory', []); inventory = (r && r.items) || []; }
    catch (e) { inventory = []; }
    const total = inventory.reduce((n, it) => n + (it.quantity || 1), 0);
    if (storageWin) storageWin.setState({ items: inventory, capacity: String(total), current: String(inventory.length) });
  }
  async function buyItem(name) {
    const r = await conn.call('UserService.buyItemPutGiftbox', [name, 1, false]);
    if (r && r.error) { toast('✗ ' + r.error); return; }
    if (r && r.gold != null) player.gold = r.gold;
    updateHUD();
    sfx('actions/sfx_building_place.mp3', 0.5);
    toast('🛒 Bought ' + name);
    await loadStorage();
  }
  if ($('st-close')) $('st-close').addEventListener('click', () => { $('storage').hidden = true; });


  // ---------- original UI dialogs (#3) ----------
  /** dispatch a clicked dialog button (by its export/class name) to a client action. */
  function dispatchDialogButton(btnName) {
    const n = (btnName || '').toLowerCase();
    if (n.includes('market') || n.includes('shop')) { dialog.close(); openMarket(); return; }
    if (n.includes('storage') || n.includes('inventory') || n.includes('shed')) { dialog.close(); openStorage(); return; }
    if (n.includes('close') || n.includes('cancel') || n.includes('exit') || n.includes('dismiss')) { dialog.close(); return; }
    toast('▸ ' + (btnName || 'button'));
    dialog.close();
  }
  async function openDialog(name) {
    const stem = dialogsByName[name] || name;
    if (!stem) { toast('No dialog "' + name + '"'); return; }
    try {
      await dialog.open('scenes/' + stem + '.scene.json?v=' + BUILD, { name: name, onButton: dispatchDialogButton });
      sfx('ui/sfx_ui_expand_menu.mp3', 0.5);
      toast('Opened ' + name);
    } catch (e) { toast('✗ dialog: ' + e.message); }
  }
  const helpBtn = $('helpbtn');
  if (helpBtn) helpBtn.addEventListener('click', () => openDialog('FV_motd_idealvacation'));
  const questBtn = $('questbtn');
  if (questBtn) questBtn.addEventListener('click', () => openDialog('FV_themedQuest_puzzle_reward'));
  const stCanvas = $('st-canvas');
  if (stCanvas) {
    stCanvas.addEventListener('mousemove', e => { if (storageWin) storageWin.onMove(e); });
    stCanvas.addEventListener('mouseup', e => { if (storageWin) storageWin.onUp(e); });
  }

  // periodic world poll: server flips planted->grown (autoGrow) and the UI follows
  let lastPoll = 0;
  if (!STOP) setInterval(async () => {
    if (busy || !conn || visitingUid) return;
    const now = Date.now();
    if (now - lastPoll < 5000) return;
    lastPoll = now;
    try { await refreshWorld(); } catch (e) { /* transient — next tick retries */ }
  }, 4000);

  // ---------- go ----------
  resize();
  boot();
})();

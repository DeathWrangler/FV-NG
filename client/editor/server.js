// FV-NG — UI Editor dev server (zero external deps). Serves the editor SPA + JSON APIs:
//   GET /api/index            -> build/uiindex/index.json  (AS3 class -> asset + bindings)
//   GET /api/manifest         -> dialog/menu/overlay SWF inventory (name, hash, stem, converted?)
//   GET /api/scene?stem=...   -> a converted .scene.json (deployed dir)
//   GET /api/report           -> verification report (buttons w/o handler, handlers w/o scene, etc.)
//   GET /                     -> client/editor/index.html  (+ static editor assets)
// Run:  node client/editor/server.js   [port]     (default 8787)
const http = require('http');
const fs = require('fs');
const path = require('path');
const { loadConfig } = require('./config.js');

const cfg = loadConfig();
const repoRoot = cfg.repoRoot;
const PORT = parseInt(process.argv[2] || process.env.PORT || String(cfg.port), 10);
const SCENE_DIR = cfg.deployedSceneDir;
const ASSETHASH = cfg.assethashFile;
const DIALOGS_BYNAME = cfg.dialogsByNameFile;
const INDEX = cfg.indexFile;
const EDITOR_DIR = __dirname;
const { convert } = require(path.join(__dirname, 'api/converter.js'));
const { buildDispatch } = require(path.join(__dirname, 'api/dispatch.js'));
const { buildReport: _buildReport } = require(path.join(__dirname, 'api/report.js'));

// ---- lazy caches ----
let _hash, _byName, _index;
function assetHash() { if (!_hash) _hash = JSON.parse(fs.readFileSync(ASSETHASH, 'utf8')); return _hash; }
function dialogsByName() { if (!_byName) _byName = JSON.parse(fs.readFileSync(DIALOGS_BYNAME, 'utf8')); return _byName; }
function uiIndex() { if (!_index) _index = JSON.parse(fs.readFileSync(INDEX, 'utf8')); return _index; }

// ---- manifest: every dialog-ish SWF with its conversion state, plus the AS3 classes that use it ----
// `converted` is canonical from build/scenes/ (fresh named conversions). `deployed` reports the
// legacy deployed-scene dir (fvng/scenes) for reference only — do not mix the two in one field.
const sceneCacheExists = (key) => fs.existsSync(path.join(cfg.sceneCacheDir, key.replace(/[\\/]/g, '__') + '.scene.json'));
function buildManifest() {
  const dlg = assetHash().dialogs || {};
  const byName = dialogsByName();
  const idx = uiIndex();
  // map assetPath -> classes (from index.byAsset)
  const rows = [];
  for (const k in dlg) {
    if (!/\.swf$/i.test(k)) continue;
    const base = path.basename(k);
    const stemName = base.replace(/\.swf$/i, '');
    const stem = byName[stemName] || byName[k];
    const deployed = !!(stem && fs.existsSync(path.join(SCENE_DIR, stem + '.scene.json')));
    const converted = sceneCacheExists(k);   // canonical: fresh named conversion in build/scenes
    // classes that reference this exact asset path or basename
    const usingClasses = [];
    const seenCls = new Set();
    for (const ap in idx.byAsset) {
      if (ap === k || path.basename(ap) === base) {
        for (const u of idx.byAsset[ap]) {
          if (seenCls.has(u.cls)) continue;   // a class referenced twice (asset + primary) counts once
          seenCls.add(u.cls);
          usingClasses.push({ cls: u.cls, file: u.file, primary: !!u.primary });
        }
      }
    }
    rows.push({ key: k, name: stemName, hash: dlg[k], stem, converted, deployed, classes: usingClasses });
  }
  return { count: rows.length, converted: rows.filter(r => r.converted).length, withClass: rows.filter(r => r.classes.length).length, rows };
}

// ---- verification report: built by api/report.js (unit-testable, no port binding) ----
// M3-3: cached manifest & report, keyed by source mtimes + a ?refresh=1 bypass. The underlying
// so the cache key is the mtime of index.json + assethash.json. A changed fingerprint rebuilds.
function sourceFingerprint() {
  let iM = 0, hM = 0;
  try { iM = fs.statSync(INDEX).mtimeMs; } catch (e) {}
  try { hM = fs.statSync(ASSETHASH).mtimeMs; } catch (e) {}
  return { iM, hM };
}
const sameFp = (a, b) => a.iM === b.iM && a.hM === b.hM;

// manifest: synchronous build, memoized.
let _manifest = null, _manifestFp = { iM: -1, hM: -1 };
function getManifest(refresh) {
  const fp = sourceFingerprint();
  if (!refresh && _manifest && sameFp(_manifestFp, fp)) return _manifest;
  _manifest = buildManifest();
  _manifestFp = fp;
  return _manifest;
}

// report: expensive (converts many SWFs); built cooperatively in api/report.js. Cached here;
// concurrent callers await the same in-flight promise.
let _report = null, _reportFp = { iM: -1, hM: -1 }, _reportInFlight = null;
function getReport(refresh) {
  const fp = sourceFingerprint();
  if (!refresh && _report && sameFp(_reportFp, fp)) return Promise.resolve(_report);
  if (_reportInFlight) return _reportInFlight;
  _reportInFlight = _buildReport().then(r => {
    _report = r; _reportFp = fp; _reportInFlight = null; return r;
  }).catch(e => { _reportInFlight = null; throw e; });
  return _reportInFlight;
}

// dispatch: cheap (pure index join), memoized like the manifest.
let _dispatch = null, _dispatchFp = { iM: -1, hM: -1 };
function getDispatch(refresh) {
  const fp = sourceFingerprint();
  if (!refresh && _dispatch && sameFp(_dispatchFp, fp)) return _dispatch;
  _dispatch = buildDispatch(uiIndex(), dialogsByName());
  _dispatchFp = fp;
  return _dispatch;
}

// ---- static serving ----
const MIME = { '.html': 'text/html', '.js': 'application/javascript', '.css': 'text/css', '.json': 'application/json', '.png': 'image/png', '.svg': 'image/svg+xml' };
function send(res, code, body, type) { res.writeHead(code, { 'Content-Type': type || 'text/plain', 'Cache-Control': 'no-store', 'Access-Control-Allow-Origin': '*' }); res.end(body); }
function sendJson(res, code, obj) { send(res, code, JSON.stringify(obj), MIME['.json']); }
// Windows-safe containment check: normalize BOTH paths to posix (forward slashes) before comparing.
const toPosix = (p) => p.split('\\').join('/');
function inside(base, full) {
  const b = path.posix.normalize(toPosix(base));
  const f = toPosix(full);
  return f.startsWith(b + '/') || f === b;
}
function serveStatic(req, res, urlPath) {
  let p = urlPath === '/' ? '/index.html' : urlPath;
  const full = path.normalize(path.join(EDITOR_DIR, p));
  if (!inside(EDITOR_DIR, full)) return send(res, 403, 'forbidden');
  fs.readFile(full, (err, buf) => {
    if (err) return send(res, 404, 'not found: ' + urlPath);
    send(res, 200, buf, MIME[path.extname(full)] || 'application/octet-stream');
  });
}

const server = http.createServer((req, res) => {
  const u = new URL(req.url, 'http://localhost');
  try {
    if (u.pathname === '/api/index') return sendJson(res, 200, uiIndex());
    if (u.pathname === '/api/manifest') return sendJson(res, 200, getManifest(u.searchParams.get('refresh') === '1'));
    if (u.pathname === '/api/dispatch') return sendJson(res, 200, getDispatch(u.searchParams.get('refresh') === '1'));
    if (u.pathname === '/api/report') {
      return getReport(u.searchParams.get('refresh') === '1').then(r => sendJson(res, 200, r)).catch(e => sendJson(res, 500, { ok: false, error: 'report build failed: ' + e.message }));
    }
    // /api/convert?key=<asset key or dlg_ stem>  -> fresh named scene JSON (cached to disk)
    if (u.pathname === '/api/convert') {
      const key = u.searchParams.get('key');
      if (!key) return sendJson(res, 400, { ok: false, error: 'missing key' });
      try {
        const r = convert(key);
        return sendJson(res, 200, { ok: true, key: r.key, fromCache: r.fromCache, scene: r.scene });
      } catch (e) {
        return sendJson(res, 404, { ok: false, error: e.message });
      }
    }
    if (u.pathname === '/api/scene') {
      const stem = u.searchParams.get('stem');
      if (!stem) return sendJson(res, 400, { ok: false, error: 'missing stem' });
      const f = path.normalize(path.join(SCENE_DIR, stem + '.scene.json'));
      if (!inside(SCENE_DIR, f)) return sendJson(res, 403, { ok: false, error: 'forbidden' });
      fs.readFile(f, (err, buf) => err ? sendJson(res, 404, { ok: false, error: 'no scene: ' + stem }) : send(res, 200, buf, MIME['.json']));
      return;
    }
    if (u.pathname === '/api/health') return sendJson(res, 200, { ok: true, port: PORT });
    // /lib/* -> existing client/web renderer + helpers (FVScene etc.), no copy/drift
    if (u.pathname.startsWith('/lib/')) {
      const rel = u.pathname.slice(5);
      const full = path.normalize(path.join(repoRoot, 'client/web', rel));
      if (!inside(repoRoot + '/client/web', full)) return send(res, 403, 'forbidden');
      return fs.readFile(full, (err, buf) => err ? send(res, 404, 'not found: ' + u.pathname) : send(res, 200, buf, MIME[path.extname(full)] || 'application/octet-stream'));
    }
    // /src/* -> decompiled AS3 source (accuracy: jump from a binding to its line)
    if (u.pathname.startsWith('/src/')) {
      const rel = u.pathname.slice(5);
      const full = path.normalize(path.join(repoRoot, 'decompiled/farmgame/scripts', rel));
      if (!inside(repoRoot + '/decompiled', full)) return send(res, 403, 'forbidden');
      return fs.readFile(full, (err, buf) => err ? send(res, 404, 'no source: ' + u.pathname) : send(res, 200, buf, 'text/plain; charset=utf-8'));
    }
    return serveStatic(req, res, u.pathname);
  } catch (e) {
    if (u.pathname.startsWith('/api/')) return sendJson(res, 500, { ok: false, error: 'server error: ' + e.message });
    return send(res, 500, 'server error: ' + e.message);
  }
});

// M3-4: graceful port bind — on EADDRINUSE log a clean message and exit(1) (no stack dump).
server.on('error', (err) => {
  if (err && err.code === 'EADDRINUSE') {
    console.error('port in use: ' + PORT + ' — stop the other editor server or pick another port');
    process.exit(1);
  }
  throw err;
});

server.listen(PORT, () => {
  console.log('FV-NG UI Editor running:  http://localhost:' + PORT);
  console.log('  scene dir : ' + SCENE_DIR);
  console.log('  index     : ' + INDEX);
});

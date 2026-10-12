#!/usr/bin/env node
// FV-NG UI Editor — integration tests (BUILD_PLAN §11.2). Spawns the REAL server on a test port,
// polls /api/health until ready, then asserts over HTTP via fetch. Always kills the child in a
// finally; exit 0 only if all pass, exit 2 on health timeout.
'use strict';
const { spawn } = require('child_process');
const path = require('path');

let passed = 0; const fails = [];
function ok(name, cond, detail) { if (cond) { passed++; console.log('  PASS  ' + name); } else { fails.push(name + (detail ? ' [' + detail + ']' : '')); console.log('  FAIL  ' + name + (detail ? ' [' + detail + ']' : '')); } }

const ROOT = path.resolve(__dirname, '..', '..');
// pick a free-ish test port distinct from the default dev server (8787) and any running instance
const PORT = parseInt(process.env.EDITOR_TEST_PORT || '8790', 10);
const BASE = 'http://localhost:' + PORT;

async function get(p, { timeoutMs = 30000 } = {}) {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), timeoutMs);
  try {
    const r = await fetch(BASE + p, { signal: ctrl.signal });
    let body = null, text = null;
    try { text = await r.text(); } catch (e) {}
    try { body = text ? JSON.parse(text) : null; } catch (e) { /* not json */ }
    return { status: r.status, ct: r.headers.get('content-type') || '', body, text };
  } finally { clearTimeout(t); }
}

async function waitReady(maxMs = 10000) {
  const start = Date.now();
  while (Date.now() - start < maxMs) {
    try { const r = await get('/api/health', { timeoutMs: 1500 }); if (r.status === 200 && r.body && r.body.ok) return true; } catch (e) {}
    await new Promise(res => setTimeout(res, 250));
  }
  return false;
}

(async () => {
  const child = spawn(process.execPath, [path.join(ROOT, 'client/editor/server.js'), String(PORT)], { cwd: ROOT, stdio: 'ignore' });
  let timedOut = false;
  try {
    if (!(await waitReady(10000))) { timedOut = true; fails.push('server did not become ready on port ' + PORT); console.log('  FAIL  server health timeout'); }
    else {
      console.log('== 1. /api/health ==');
      const h = await get('/api/health');
      ok('/api/health -> {ok:true}', h.status === 200 && h.body && h.body.ok === true, JSON.stringify(h.body));

      console.log('== 2. /api/index ==');
      const ix = await get('/api/index');
      ok('/api/index HTTP 200 + application/json', ix.status === 200 && /application\/json/.test(ix.ct), 'status=' + ix.status + ' ct=' + ix.ct);
      ok('index.stats.uiClasses > 0', ix.body && ix.body.stats && ix.body.stats.uiClasses > 0, ix.body && JSON.stringify(ix.body.stats));

      console.log('== 3. /api/manifest ==');
      const mf = await get('/api/manifest');
      ok('manifest.count > 0', mf.body && mf.body.count > 0, String(mf.body && mf.body.count));
      const row = mf.body && mf.body.rows.find(r => r.name === 'FV_delete_confirm');
      ok('FV_delete_confirm row has converted:true', row && row.converted === true, row ? JSON.stringify({ name: row.name, converted: row.converted }) : 'no row');

      console.log('== 4. /api/convert (real asset) ==');
      const cv = await get('/api/convert?key=' + encodeURIComponent('FV_delete_confirm.swf'));
      ok('/api/convert -> {ok:true}', cv.status === 200 && cv.body && cv.body.ok === true, 'status=' + cv.status);
      const names = new Set();
      if (cv.body && cv.body.scene) {
        const s = cv.body.scene, chars = s.characters || {};
        for (const n in s.exports) names.add(n.split('.').pop());
        const seen = new Set();
        const walk = (l, d) => { if (!l || d > 40) return; for (const p of l) { if (p.name) names.add(p.name); const c = chars[p.char]; if (c && c.type === 'sprite' && !seen.has(p.char)) { seen.add(p.char); walk(c.frames[0], d + 1); } } };
        (s.frames || []).forEach(f => walk(f, 0));
      }
      ok('converted scene has a placement named accept_bt', names.has('accept_bt'), [...names].slice(0, 8).join(','));

      console.log('== 5. /api/convert (missing) ==');
      const miss = await get('/api/convert?key=' + encodeURIComponent('__missing__'));
      ok('/api/convert missing -> HTTP 404', miss.status === 404, 'status=' + miss.status);
      ok('missing body parses as JSON with ok:false', miss.body && miss.body.ok === false, miss.text ? miss.text.slice(0, 80) : 'no body');

      console.log('== 6. /api/report (cached) ==');
      const rep1 = await get('/api/report');
      ok('report has mappedButtons (number)', rep1.body && typeof rep1.body.mappedButtons === 'number', JSON.stringify(rep1.body && { m: rep1.body.mappedButtons }));
      ok('report has unmappedButtons (array)', rep1.body && Array.isArray(rep1.body.unmappedButtons), String(Array.isArray(rep1.body && rep1.body.unmappedButtons)));
      const t0 = Date.now();
      const rep2 = await get('/api/report');
      const dt = Date.now() - t0;
      ok('second report call cached (same generatedAt)', rep1.body && rep2.body && rep1.body.generatedAt === rep2.body.generatedAt, 'gen1=' + (rep1.body && rep1.body.generatedAt) + ' gen2=' + (rep2.body && rep2.body.generatedAt));
      ok('cached report returns in < 1000 ms', dt < 1000, dt + 'ms');

      console.log('== 7. /api/dispatch ==');
      const dp = await get('/api/dispatch');
      const entry = dp.body && dp.body.byAssetBase && dp.body.byAssetBase['FV_delete_confirm'];
      ok("dispatch byAssetBase.FV_delete_confirm.byLeaf.accept_bt[0].handler === 'onAcceptClick'", entry && entry.byLeaf && entry.byLeaf.accept_bt && entry.byLeaf.accept_bt[0].handler === 'onAcceptClick', entry ? JSON.stringify(entry.byLeaf.accept_bt && entry.byLeaf.accept_bt[0]) : 'no entry');

      console.log('== 8. /lib/scene2d.js ==');
      const lib = await get('/lib/scene2d.js');
      ok('/lib/scene2d.js HTTP 200 + javascript', lib.status === 200 && /javascript/.test(lib.ct), 'status=' + lib.status + ' ct=' + lib.ct);

      console.log('== 9. path traversal ==');
      const trav = await get('/src/' + '../../../../Windows/win.ini');
      ok('traversal blocked (403/404, never 200 with data)', (trav.status === 403 || trav.status === 404) && !(trav.status === 200 && trav.text && /forbidden/.test(trav.text)), 'status=' + trav.status);
    }
  } finally {
    try { child.kill(); } catch (e) {}
  }

  console.log('');
  console.log(passed + ' passed, ' + fails.length + ' failed');
  if (fails.length) { fails.forEach(f => console.log('  - ' + f)); process.exit(timedOut ? 2 : 1); }
  process.exit(0);
})().catch(e => { console.error('e2e harness error:', e.message); process.exit(3); });

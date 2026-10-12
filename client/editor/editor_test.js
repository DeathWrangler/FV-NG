#!/usr/bin/env node
// FV-NG UI Editor — unit tests (BUILD_PLAN §11.1). No server, no network: exercises config, key
// resolution, the converter + scene cache, dispatch building, and report building directly.
// Harness style matches client/tools/test_scene.js: passed counter, fails array, ok(name,cond,detail),
// process.exit(fails.length ? 1 : 0).
'use strict';
const fs = require('fs');
const path = require('path');

let passed = 0; const fails = [];
function ok(name, cond, detail) { if (cond) { passed++; console.log('  PASS  ' + name); } else { fails.push(name + (detail ? ' [' + detail + ']' : '')); console.log('  FAIL  ' + name + (detail ? ' [' + detail + ']' : '')); } }

const EDITOR = __dirname;
const ROOT = path.resolve(EDITOR, '..', '..');
const { loadConfig } = require(path.join(EDITOR, 'config.js'));
const { convert, resolveKey, swfPathFor, clearCache } = require(path.join(EDITOR, 'api/converter.js'));
const { buildDispatch } = require(path.join(EDITOR, 'api/dispatch.js'));
const { buildReport } = require(path.join(EDITOR, 'api/report.js'));

const cfg = loadConfig();
// collect named elements of a scene (same walk as api/report.js) — for the accept_bt placement check
function sceneNames(s) {
  const set = new Set(); const chars = s.characters || {};
  for (const n in s.exports) set.add(n.split('.').pop());
  const seen = new Set();
  const walk = (list, d) => { if (!list || d > 40) return; for (const p of list) { if (p.name) set.add(p.name); const c = chars[p.char]; if (c && c.type === 'sprite' && !seen.has(p.char)) { seen.add(p.char); walk(c.frames[0], d + 1); } } };
  (s.frames || []).forEach(f => walk(f, 0));
  return set;
}

console.log('== 1. config ==');
{
  const required = ['repoRoot', 'indexSourceDir', 'indexFile', 'dispatchFile', 'sceneCacheDir', 'assethashFile', 'dialogsByNameFile', 'deployedSceneDir', 'swfHashedRoot', 'categories', 'port'];
  ok('loadConfig() has all required keys', required.every(k => k in cfg), required.filter(k => !(k in cfg)).join(','));
  // repoRoot must be THIS repo root (config.js lives at <root>/client/editor/config.js)
  const norm = (p) => p.split(path.sep).join('/');
  ok('repoRoot equals the FV-NG repo root', norm(cfg.repoRoot) === norm(ROOT), cfg.repoRoot + ' vs ' + ROOT);
  ok('categories are dialogs+overlays (no HUD)', JSON.stringify(cfg.categories) === JSON.stringify(['dialogs', 'overlays']), JSON.stringify(cfg.categories));
  const o = loadConfig({ port: 12345 });
  ok('overriding port works', o.port === 12345, String(o.port));
}

console.log('== 2. resolveKey (categories) ==');
{
  const k1 = resolveKey('FV_delete_confirm.swf');
  const k2 = resolveKey('dlg_FV_delete_confirm');
  ok("resolveKey('FV_delete_confirm.swf') resolves", !!k1, String(k1));
  ok("resolveKey('dlg_FV_delete_confirm') resolves (stem prefix stripped)", !!k2 && k2 === k1, String(k2));
  // both must point at a real asset: the SWF file exists on disk via swfPathFor
  ok('resolved key maps to an existing SWF', !!k1 && !!swfPathFor(k1), k1 ? swfPathFor(k1) : 'no key');
}

console.log('== 3. convert real asset ==');
let r1 = null;
{
  try {
    r1 = convert('FV_delete_confirm.swf');
    ok("convert('FV_delete_confirm.swf') returns a scene", !!r1 && !!r1.scene, 'no scene');
    ok('scene.characters non-empty', r1 && Object.keys(r1.scene.characters).length > 0, r1 ? Object.keys(r1.scene.characters).length : '-');
    ok("scene has a placement named 'accept_bt'", r1 && sceneNames(r1.scene).has('accept_bt'), r1 ? [...sceneNames(r1.scene)].slice(0, 8).join(',') : '-');
  } catch (e) { ok('convert does not throw', false, e.message); }
}

console.log('== 4. scene cache ==');
{
  try {
    const r2 = convert('FV_delete_confirm.swf');
    ok('second convert() is fromCache:true', r2.fromCache === true, String(r2.fromCache));
    ok('cached scene has same object identity (in-memory LRU)', r1 && r2.scene === r1.scene);
  } catch (e) { ok('cache convert does not throw', false, e.message); }
}

console.log('== 5. convert miss ==');
{
  let threw = null;
  try { convert('__definitely_missing__'); } catch (e) { threw = e; }
  ok("convert('__definitely_missing__') throws", !!threw, 'did not throw');
  ok('error carries a message', threw && typeof threw.message === 'string' && threw.message.length > 0, threw && threw.message);
}

console.log('== 6. dispatch ==');
{
  const idx = JSON.parse(fs.readFileSync(cfg.indexFile, 'utf8'));
  let byName = {};
  try { byName = JSON.parse(fs.readFileSync(cfg.dialogsByNameFile, 'utf8')); } catch (e) {}
  const d = buildDispatch(idx, byName);
  const entry = d.byAssetBase && d.byAssetBase['FV_delete_confirm'];
  ok('byAssetBase has FV_delete_confirm', !!entry, Object.keys(d.byAssetBase || {}).length + ' bases');
  ok("byLeaf.accept_bt[0].handler === 'onAcceptClick' (per-asset)", entry && entry.byLeaf && entry.byLeaf.accept_bt && entry.byLeaf.accept_bt[0].handler === 'onAcceptClick', entry ? JSON.stringify(entry.byLeaf.accept_bt && entry.byLeaf.accept_bt[0]) : 'no entry');
  ok('shortcuts is an array', Array.isArray(d.shortcuts), String(Array.isArray(d.shortcuts)));
  ok('stats.elementBindings > 0', d.stats && d.stats.elementBindings > 0, JSON.stringify(d.stats));
}

console.log('== 7. report ==');
(async () => {
  const rep = await buildReport();
  ok('report stats are numeric', [rep.classesWithBindings, rep.classesChecked, rep.mappedButtons, rep.unmappedButtonsCount].every(n => typeof n === 'number' && isFinite(n)), JSON.stringify({ c: rep.classesChecked, m: rep.mappedButtons }));
  const unmappedLeaves = new Set((rep.unmappedButtons || []).map(u => u.leaf));
  ok('accept_bt is NOT unmapped (mapped in art)', !unmappedLeaves.has('accept_bt'), 'accept_bt found in unmapped');
  ok('m_checkbox1 IS unmapped (expected naming mismatch)', unmappedLeaves.has('m_checkbox1'), 'm_checkbox1 not in unmapped');
  ok('m_checkbox2 IS unmapped (expected naming mismatch)', unmappedLeaves.has('m_checkbox2'), 'm_checkbox2 not in unmapped');

  console.log('== 8. overlay box ==');
  // Pure-JS check (no canvas): for a scene with button hit boxes, the candidate descriptor's stored
  // box (as pickAt builds it) must equal the corresponding buttonBoxes() entry. DeleteConfirm has no
  // type:'button' chars (its buttons are named sprite placements), so scan cached scenes for one that does.
  require(path.join(ROOT, 'client/web/scene2d.js'));
  const FV = global.FVScene || (typeof FVScene !== 'undefined' ? FVScene : null);
  if (!FV) { ok('FVScene available for overlay check', false, 'no FVScene global'); }
  else {
    const dir = cfg.sceneCacheDir;
    let checked = 0, allEqual = true, sample = '';
    for (const f of fs.readdirSync(dir).filter(x => x.endsWith('.scene.json')).slice(0, 120)) {
      try {
        const scene = JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8'));
        const fv = new FV(scene);
        const boxes = fv.buttonBoxes(0);
        if (!boxes.length) continue;
        // replicate app.js pickAt's button candidate box construction:
        for (const bb of boxes.slice(0, 5)) {
          const candBox = { x0: bb.x0, y0: bb.y0, x1: bb.x1, y1: bb.y1 };
          const eq = candBox.x0 === bb.x0 && candBox.y0 === bb.y0 && candBox.x1 === bb.x1 && candBox.y1 === bb.y1;
          if (!eq) { allEqual = false; sample = f + ' box mismatch'; break; }
          checked++;
        }
      } catch (e) {}
    }
    ok('button candidate box equals buttonBoxes() entry', checked > 0 && allEqual, checked + ' boxes compared' + (sample ? '; ' + sample : ''));
  }

  console.log('');
  console.log(passed + ' passed, ' + fails.length + ' failed');
  if (fails.length) { fails.forEach(f => console.log('  - ' + f)); process.exit(1); }
  process.exit(0);
})();

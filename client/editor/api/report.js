// FV-NG UI Editor — verification report builder (M6). Extracted from server.js so it can be unit
// tested without binding a port. Joins AS3 bindings (by instance name) to rendered art via fresh
// named conversions: a button/click binding is "mapped" if its leaf appears in the scene's named
// elements, else it lands in unmappedButtons. Built cooperatively in chunks of 50 via setImmediate
// so the event loop keeps serving other requests while it runs.
'use strict';
const fs = require('fs');
const { config } = require('../config.js');
const { convert } = require('./converter.js');

let _index;
function uiIndex() { if (!_index) _index = JSON.parse(fs.readFileSync(config.indexFile, 'utf8')); return _index; }

// key -> Set of instance/export names present in the (freshly converted) scene.
const _sceneNameCache = {};
function sceneNamesFor(key) {
  if (_sceneNameCache[key] !== undefined) return _sceneNameCache[key];
  const set = new Set();
  try {
    const r = convert(key);
    const s = r.scene;
    const chars = s.characters || {};
    for (const n in s.exports) set.add(n.split('.').pop());
    const seen = new Set();
    const walk = (list, d) => { if (!list || d > 40) return; for (const p of list) { if (p.name) set.add(p.name); const c = chars[p.char]; if (c && c.type === 'sprite' && !seen.has(p.char)) { seen.add(p.char); walk(c.frames[0], d + 1); } } };
    (s.frames || []).forEach(f => walk(f, 0));
    for (const id in chars) { const c = chars[id]; if (c.type === 'button') for (const st of ['up', 'over', 'down', 'hit']) for (const p of (c.states[st] || [])) if (p.name) set.add(p.name); }
  } catch (e) {}
  return (_sceneNameCache[key] = set);
}

// Build the full report. Returns a Promise resolving to:
// { generatedAt, classesWithBindings, classesChecked, mappedButtons, unmappedButtonsCount, orphansNotConverted, unmappedButtons[], orphans[] }
function buildReport() {
  const classes = uiIndex().classes.filter(c => c.bindings.length);
  let i = 0, classesChecked = 0, mappedButtons = 0;
  const unmappedButtons = [], orphans = [];
  function step() {
    const end = Math.min(i + 50, classes.length);
    for (; i < end; i++) {
      const c = classes[i];
      const ap = c.assetPrimary || (c.assets[0] && c.assets[0].path);
      if (!ap) { orphans.push({ cls: c.cls, reason: 'no-asset-path', bindings: c.bindings.length }); continue; }
      let key = null;
      try { key = convert(ap).key; } catch (e) { /* no swf / not convertible */ }
      if (!key) { orphans.push({ cls: c.cls, asset: ap, reason: 'swf-missing-or-unconvertible', bindings: c.bindings.length }); continue; }
      classesChecked++;
      const names = sceneNamesFor(key);
      for (const b of c.bindings) {
        if (b.kind !== 'button' && b.kind !== 'click') continue; // only element-bound ones are checkable in-scene
        if (names.has(b.leaf)) mappedButtons++;
        else unmappedButtons.push({ cls: c.cls, leaf: b.leaf, handler: b.handler, kind: b.kind, sceneKey: key });
      }
    }
    if (i < classes.length) return new Promise(res => setImmediate(() => res(step())));
    return Promise.resolve({
      generatedAt: new Date().toISOString(),
      classesWithBindings: classes.length,
      classesChecked, mappedButtons, unmappedButtonsCount: unmappedButtons.length,
      orphansNotConverted: orphans.length,
      unmappedButtons: unmappedButtons.slice(0, 500),
      orphans: orphans.slice(0, 500),
    });
  }
  return step();
}

module.exports = { buildReport, sceneNamesFor };

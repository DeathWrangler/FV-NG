// FV-NG UI Editor — dispatch-map builder (M4-1).
// Turns the AS3 index (build/uiindex/index.json) into a machine-consumable map that a client port
// can use to resolve: asset -> scene stems + per-instance handler metadata. This is the build
// artifact the pipeline consumes; it is also served live at GET /api/dispatch (M4-2).
//
// Shape of the dispatch object:
//   {
//     generatedAt,
//     byAsset:    { "assets/dialogs/FV_delete_confirm.swf": { stems:[...], byLeaf:{ accept_bt:[{cls,handler,kind,line,file,full},...] } } },
//     byAssetBase:{ "FV_delete_confirm": <same entry object as byAsset[full path]> },
//     byLeaf:     { "accept_bt": [ {cls,asset,handler,kind,line,file,full}, ... ] },   // across all assets
//     shortcuts:  [ {cls,asset,slot,handler,line,file}, ... ],                          // shortcut KEYs (not scene instances)
//     stats:      { assets, assetBases, leaves, elementBindings, shortcuts }
//   }
// Only element-bound kinds (button/click/ddd_button) go into byAsset/byLeaf; `shortcut` bindings are
// kept apart in `shortcuts` because their leaf is a shortcut key, not an SWF instance name.
'use strict';
const fs = require('fs');
const path = require('path');
const { loadConfig } = require('../config.js');

const ELEMENT_KINDS = new Set(['button', 'click', 'ddd_button']);

// Resolve scene stems for an asset path via dialogsbyname.json (base name and full key both tried).
function stemsFor(assetPath, byName) {
  const base = path.basename(assetPath).replace(/\.swf$/i, '');
  const out = new Set();
  for (const k of [base, assetPath, path.basename(assetPath)]) {
    if (byName && byName[k]) out.add(byName[k]);
  }
  return [...out];
}

// buildDispatch(index, byName) -> dispatch object (see file header for shape).
function buildDispatch(index, byName) {
  const byAsset = {};
  const byLeaf = {};
  const shortcuts = [];
  let elementBindings = 0;

  const entryFor = (assetPath) => {
    if (!byAsset[assetPath]) byAsset[assetPath] = { stems: stemsFor(assetPath, byName), byLeaf: {} };
    return byAsset[assetPath];
  };

  for (const c of index.classes || []) {
    const asset = c.assetPrimary || (c.assets && c.assets[0] && c.assets[0].path) || null;
    for (const b of c.bindings || []) {
      if (b.kind === 'shortcut') {
        shortcuts.push({ cls: c.cls, asset, slot: b.slot || b.leaf, handler: b.handler, line: b.line, file: c.file });
        continue;
      }
      if (!ELEMENT_KINDS.has(b.kind)) continue;
      elementBindings++;
      const rec = { cls: c.cls, handler: b.handler, kind: b.kind, line: b.line, file: c.file, full: b.full };
      // top-level byLeaf (across all assets) — carries the asset it was seen on
      (byLeaf[b.leaf] = byLeaf[b.leaf] || []).push(Object.assign({ asset }, rec));
      if (asset) {
        const entry = entryFor(asset);
        (entry.byLeaf[b.leaf] = entry.byLeaf[b.leaf] || []).push(rec);
      }
    }
  }

  // byAssetBase: same entry objects keyed by base name (basename without extension).
  const byAssetBase = {};
  for (const ap in byAsset) {
    const base = path.basename(ap).replace(/\.swf$/i, '');
    if (!byAssetBase[base]) byAssetBase[base] = byAsset[ap];   // first wins on a basename collision
  }

  return {
    generatedAt: new Date().toISOString(),
    byAsset,
    byAssetBase,
    byLeaf,
    shortcuts,
    stats: { assets: Object.keys(byAsset).length, assetBases: Object.keys(byAssetBase).length, leaves: Object.keys(byLeaf).length, elementBindings, shortcuts: shortcuts.length },
  };
}

// ---- CLI: node client/editor/api/dispatch.js  -> writes config.dispatchFile, prints stats ----
if (require.main === module) {
  const cfg = loadConfig();
  const index = JSON.parse(fs.readFileSync(cfg.indexFile, 'utf8'));
  let byName = {};
  try { byName = JSON.parse(fs.readFileSync(cfg.dialogsByNameFile, 'utf8')); } catch (e) { /* optional */ }
  const dispatch = buildDispatch(index, byName);
  fs.mkdirSync(path.dirname(cfg.dispatchFile), { recursive: true });
  fs.writeFileSync(cfg.dispatchFile, JSON.stringify(dispatch));
  console.log(JSON.stringify({ out: cfg.dispatchFile, ...dispatch.stats }, null, 1));
}

module.exports = { buildDispatch };

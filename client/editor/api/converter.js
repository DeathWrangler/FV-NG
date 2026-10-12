// FV-NG — on-demand SWF -> scene converter with instance-name capture + disk cache.
// The deployed scenes (fvng/scenes/*.scene.json) predate name-capture, so the editor needs
// fresh conversions to join AS3 bindings (by instance name) to rendered art. This module:
//   convert(stemOrKey) -> { scene, fromCache, swfPath, key }
//   stem "dlg_X" or asset key "X.swf" / "subdir/X.swf" -> locate SWF via assethash (all configured
//   categories, not just dialogs) -> parse -> swfToScene.
// Cached under build/scenes/<key>.scene.json (names included), plus a small in-memory LRU.
const fs = require('fs');
const path = require('path');
const { config } = require('../config.js');

const TOOLS = path.join(config.repoRoot, 'client/tools');
const ASSETHASH = config.assethashFile;
const SWF_ROOT = config.swfHashedRoot;
const CACHE_DIR = config.sceneCacheDir;
const CATEGORIES = config.categories || ['dialogs'];

// swf-parser is ESM-only; Node >=22 can require() it by bare name from within client/tools.
// Pull both deps through a tiny shim that lives in client/tools so resolution works.
const { parseSwf, swfToScene } = require(path.join(TOOLS, '_loader.js'));

let _hash;
function allHashes() { if (!_hash) _hash = JSON.parse(fs.readFileSync(ASSETHASH, 'utf8')); return _hash; }
// Map of a single category: { "<key>.swf": "<sha1>" }.
const catMap = (cat) => allHashes()[cat] || {};

// Normalize an input (stem "dlg_X", key "X.swf", or "subdir/X.swf") to an asset key present in
// one of the configured categories' maps. Searches every category, not just dialogs.
function resolveKey(input) {
  let cand = String(input).trim();
  if (cand.startsWith('dlg_')) cand = cand.slice(4);                 // strip scene-stem prefix
  if (!/\.swf$/i.test(cand)) cand += '.swf';                          // ensure .swf
  const base = path.basename(cand);
  for (const cat of CATEGORIES) {
    const h = catMap(cat);
    if (h[cand]) return cand;                                          // exact key (incl. subdir)
    for (const k in h) if (path.basename(k) === base) return k;        // fallback: match by basename
  }
  return null;
}

// Category for a resolved asset key: the segment after `assets/` if the key is a full path, else
// the configured category whose map contains it (scan in config order). Defaults to first category.
function categoryFor(key) {
  const m = String(key).match(/^assets\/([^\/]+)\//);
  if (m && allHashes()[m[1]]) return m[1];
  for (const cat of CATEGORIES) if (catMap(cat)[key]) return cat;
  return CATEGORIES[0];
}

function swfPathFor(key) {
  const cat = categoryFor(key);
  const hash = catMap(cat)[key];
  if (!hash) return null;
  const p = path.join(SWF_ROOT, cat, hash + '.swf');
  return fs.existsSync(p) ? p : null;
}

function cachePathFor(key) {
  return path.join(CACHE_DIR, key.replace(/[\\/]/g, '__') + '.scene.json');
}

// ---- in-memory LRU (M3-2): max 24 entries, insertion-order eviction, keyed by canonical asset key ----
const MAX_MEM = 24;
const memCache = new Map();   // key -> { scene, swfPath }
function clearCache() { memCache.clear(); }

// Convert (fresh if not cached). Returns { scene, fromCache, swfPath, key } or throws.
function convert(input, { force = false } = {}) {
  const key = resolveKey(input);
  if (!key) throw new Error('no asset matches in categories [' + CATEGORIES.join(', ') + ']: ' + input);

  if (!force && memCache.has(key)) {
    const hit = memCache.get(key);
    memCache.delete(key); memCache.set(key, hit);   // refresh recency
    return { scene: hit.scene, fromCache: true, swfPath: hit.swfPath, key };
  }

  fs.mkdirSync(CACHE_DIR, { recursive: true });
  const cp = cachePathFor(key);
  if (!force && fs.existsSync(cp)) {
    const scene = JSON.parse(fs.readFileSync(cp, 'utf8'));
    const swfPath = swfPathFor(key);
    memCache.set(key, { scene, swfPath });
    evict();
    return { scene, fromCache: true, swfPath, key };
  }

  const swfPath = swfPathFor(key);
  if (!swfPath) throw new Error('SWF file missing on disk for key: ' + key);
  const swf = parseSwf(fs.readFileSync(swfPath));
  const scene = swfToScene(swf, { source: key });
  fs.writeFileSync(cp, JSON.stringify(scene));
  memCache.set(key, { scene, swfPath });
  evict();
  return { scene, fromCache: false, swfPath, key };
}
function evict() {
  while (memCache.size > MAX_MEM) memCache.delete(memCache.keys().next().value);
}

module.exports = { convert, resolveKey, swfPathFor, cachePathFor, categoryFor, clearCache };

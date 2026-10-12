// FV-NG — convert a single world item's SWF to a runtime scene, on demand.
// Resolves an item name to its hashed SWF via assethash.json (with naming heuristics), converts
// it with the shared exporter, and writes <out>/<stem>.scene.json. Prints the scene stem on
// success (for the caller to record in scenesbyname.json) or nothing on failure.
//
// Usage: node convert_one.js --name <itemName> --out <scenesDir> [--assethash <path>] [--force]
'use strict';
const fs = require('fs');
const path = require('path');
const { parseSwf, swfToScene } = require('./_loader.js');

function arg(name, def) { const i = process.argv.indexOf('--' + name); return i >= 0 ? process.argv[i + 1] : def; }
const NAME = (arg('name') || '').trim();
const OUT = arg('out') || 'C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes';
const HASH = arg('assethash') || 'C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json';
const FORCE = process.argv.includes('--force');
const ASSETS = arg('assets') || 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets';

if (!/^[A-Za-z0-9_]+$/.test(NAME)) { process.stderr.write('bad name\n'); process.exit(2); }

const hash = JSON.parse(fs.readFileSync(HASH, 'utf8'));
const index = {};   // lowercased "category/name.swf" and "name.swf" -> {cat, key, hash}
for (const cat of Object.keys(hash)) {
  for (const key of Object.keys(hash[cat] || {})) {
    if (!/\.swf$/i.test(key)) continue;
    const base = key.split('/').pop().toLowerCase();
    if (!(base in index)) index[base] = { cat, key, hash: hash[cat][key] };
  }
}

// naming heuristics: exact, then common type prefixes/suffixes
const low = NAME.toLowerCase();
const candidates = [
  low + '.swf',
  'tree_' + low + '.swf', low + '_tree.swf',
  'deco_' + low + '.swf', low + '_deco.swf', 'decoration_' + low + '.swf',
  'bldg_' + low + '.swf', low + '_bldg.swf', 'building_' + low + '.swf',
  'animal_' + low + '.swf', low + '_animal.swf',
];
let hit = null;
for (const c of candidates) { if (index[c]) { hit = index[c]; break; } }

if (!hit) { process.stderr.write('no swf for ' + NAME + '\n'); process.exit(1); }

const stem = hit.key.split('/').pop().replace(/\.swf$/i, '');
const outFile = path.join(OUT, stem + '.scene.json');
if (!FORCE && fs.existsSync(outFile)) { process.stdout.write(stem); process.exit(0); }

const swfPath = path.join(ASSETS, hit.cat, hit.hash + '.swf');
if (!fs.existsSync(swfPath)) { process.stderr.write('swf missing: ' + swfPath + '\n'); process.exit(1); }

try {
  const scene = swfToScene(parseSwf(fs.readFileSync(swfPath)), { source: hit.key });
  fs.mkdirSync(OUT, { recursive: true });
  fs.writeFileSync(outFile, JSON.stringify(scene));
  process.stdout.write(stem);
} catch (e) { process.stderr.write('convert failed: ' + e.message + '\n'); process.exit(1); }

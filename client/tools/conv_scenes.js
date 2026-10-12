// FV-NG — batch SWF -> scene converter for world assets (M2 content pipeline).
// Resolves each item's image (from build/item_assets.json) to a hashed SWF via assethash.json,
// converts it to a runtime scene, and writes a name -> scene map the client uses to render world
// objects. Dedupes by SWF stem and RESUMES (skips scenes already on disk), so it can be run
// repeatedly / in batches until every placeable item is covered.
//
// Usage: node conv_scenes.js [limitPerCategory] [typesCsv] [totalBudget]
//   e.g. node conv_scenes.js 5000 decoration,tree,building,animal 20000
// Output: <webroot>/farmville/fvng/scenes/{stem}.scene.json  +  scenesbyname.json
const fs = require('fs');
const path = require('path');
const { parseSwf } = require('swf-parser');
const { swfToScene } = require('./swf2scene.js');

const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets';
const OUT = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes';
const DEV_MAP = 'C:/Users/Remote/Desktop/FV-NG/client/web/scenesbyname.json';
const ITEMS = 'C:/Users/Remote/Desktop/FV-NG/build/item_assets.json';
const HASH = 'C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json';

const LIMIT = parseInt(process.argv[2] || '2000', 10);
const TYPES = (process.argv[3] || 'decoration,tree,building,animal').split(',').map(s => s.trim());
const BUDGET = parseInt(process.argv[4] || '100000', 10);

const items = JSON.parse(fs.readFileSync(ITEMS, 'utf8'));
const assethash = JSON.parse(fs.readFileSync(HASH, 'utf8'));
const cats = Object.keys(assethash);

// global case-insensitive name index across all categories
const INDEX = {};
for (const c of cats) for (const n of Object.keys(assethash[c])) { const k = n.toLowerCase(); if (!(k in INDEX)) INDEX[k] = { cat: c, hash: assethash[c][n] }; }

fs.mkdirSync(OUT, { recursive: true });
const mapPath = path.join(OUT, 'scenesbyname.json');
const map = fs.existsSync(mapPath) ? JSON.parse(fs.readFileSync(mapPath, 'utf8')) : {};
const counts = {}, seen = new Set();
let ok = 0, resume = 0, skip = 0, fail = 0;

for (const it of items) {
  if (!TYPES.includes(it.type)) continue;
  if (ok >= BUDGET) break;
  if ((counts[it.type] || 0) >= LIMIT) continue;
  const stem = it.image.replace(/\.swf$/i, '');
  if (seen.has(stem)) continue;
  const res = INDEX[it.image.toLowerCase()];
  if (!res) { skip++; continue; }
  const outFile = path.join(OUT, stem + '.scene.json');
  seen.add(stem);
  map[it.name] = stem;
  counts[it.type] = (counts[it.type] || 0) + 1;
  if (fs.existsSync(outFile)) { resume++; continue; }   // already converted (resume)
  const swfPath = path.join(ASSETS, res.cat, res.hash + '.swf');
  if (!fs.existsSync(swfPath)) { skip++; continue; }
  try {
    const scene = swfToScene(parseSwf(fs.readFileSync(swfPath)), { source: it.image });
    fs.writeFileSync(outFile, JSON.stringify(scene));
    ok++;
    if (ok % 500 === 0) console.log('  ...converted ' + ok + ' (mapped ' + Object.keys(map).length + ')');
  } catch (e) { fail++; }
}

fs.writeFileSync(mapPath, JSON.stringify(map));
fs.mkdirSync(path.dirname(DEV_MAP), { recursive: true });
fs.writeFileSync(DEV_MAP, JSON.stringify(map));
console.log(JSON.stringify({ converted: ok, resumed: resume, skipped: skip, failed: fail, mapped: Object.keys(map).length, perType: counts }, null, 1));

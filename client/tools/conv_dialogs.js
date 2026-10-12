// FV-NG — dialog/UI SWF -> scene converter (Track A / #3 Widgets slice).
// Converts `dialogs/` SWFs to runtime scenes and builds a name -> scene map so the client can
// render original UI screens (MOTD, support, etc.) as modal overlays. Resume-safe.
//
// Usage: node conv_dialogs.js [budget]
// Output: <webroot>/farmville/fvng/scenes/{stem}.scene.json + dialogsbyname.json
const fs = require('fs');
const path = require('path');
const { parseSwf } = require('swf-parser');
const { swfToScene } = require('./swf2scene.js');

const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets/dialogs';
const OUT = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes';
const DEV_MAP = 'C:/Users/Remote/Desktop/FV-NG/client/web/dialogsbyname.json';
const HASH = 'C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json';
const BUDGET = parseInt(process.argv[2] || '400', 10);

const assethash = JSON.parse(fs.readFileSync(HASH, 'utf8'));
const dialogs = assethash.dialogs || {};
const keys = Object.keys(dialogs).filter(k => k.toLowerCase().endsWith('.swf'));

fs.mkdirSync(OUT, { recursive: true });
const mapPath = path.join(OUT, 'dialogsbyname.json');
const map = fs.existsSync(mapPath) ? JSON.parse(fs.readFileSync(mapPath, 'utf8')) : {};
const sanitize = s => s.replace(/\.[^.]+$/, '').replace(/[^A-Za-z0-9]+/g, '_').replace(/^_+|_+$/g, '');

let ok = 0, resume = 0, skip = 0, fail = 0;
for (const key of keys) {
  if (ok >= BUDGET) break;
  const stem = 'dlg_' + sanitize(key);
  const base = path.basename(key).replace(/\.swf$/i, '');
  const swfPath = path.join(ASSETS, dialogs[key] + '.swf');
  if (!fs.existsSync(swfPath)) { skip++; continue; }
  if (!map[base]) map[base] = stem;               // short name -> stem (first wins)
  map[key] = stem;                                 // full key -> stem
  const outFile = path.join(OUT, stem + '.scene.json');
  if (fs.existsSync(outFile)) { resume++; continue; }
  try {
    const scene = swfToScene(parseSwf(fs.readFileSync(swfPath)), { source: key });
    fs.writeFileSync(outFile, JSON.stringify(scene));
    ok++;
    if (ok % 100 === 0) { console.log('  ...converted ' + ok); fs.writeFileSync(mapPath, JSON.stringify(map)); }
  } catch (e) { fail++; }
}
fs.writeFileSync(mapPath, JSON.stringify(map));
fs.mkdirSync(path.dirname(DEV_MAP), { recursive: true });
fs.writeFileSync(DEV_MAP, JSON.stringify(map));
console.log(JSON.stringify({ converted: ok, resumed: resume, skipped: skip, failed: fail, mapped: Object.keys(map).length, dialogSwfs: keys.length }, null, 1));

// FV-NG — regenerate already-converted scene JSONs after a converter fix.
// Walks the deployed scenes dir, reads each scene's meta.source, resolves the source SWF via
// assethash.json, re-converts with the current swf2scene.js, and overwrites. Resumable via an
// append-only progress file. By default only files whose matrices contain a gradient or a
// skew/rotation are touched; use --all to force every file.
//
// Usage: node regen_scenes.js [--all] [--limit=N] [--skip=dlg_] [--only=dlg_]
const fs = require('fs');
const path = require('path');
const { parseSwf } = require('swf-parser');
const { swfToScene } = require('./swf2scene.js');

const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets';
const OUT = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes';
const HASH = 'C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json';
const PROGRESS = path.join(OUT, '.regen_progress.txt');

const arg = (name, def) => { const a = process.argv.find(x => x.startsWith('--' + name + '=')); return a ? a.split('=')[1] : def; };
const force = process.argv.includes('--all');
const LIMIT = parseInt(arg('limit', '0'), 10) || Infinity;
const SKIP = arg('skip', '');
const ONLY = arg('only', '');

const assethash = JSON.parse(fs.readFileSync(HASH, 'utf8'));
const INDEX = {};
for (const c of Object.keys(assethash)) for (const n of Object.keys(assethash[c])) { const k = n.toLowerCase(); if (!(k in INDEX)) INDEX[k] = { cat: c, hash: assethash[c][n] }; }

const done = new Set(fs.existsSync(PROGRESS) ? fs.readFileSync(PROGRESS, 'utf8').split('\n').filter(Boolean) : []);

function matricesNeedRegen(j) {
  if (/"kind":"grad"/.test(j)) return true;
  const re = /"m":\[([^\]]+)\]/g; let m;
  while ((m = re.exec(j))) {
    const a = m[1].split(',');
    if (a.length >= 4 && (Math.abs(parseFloat(a[1])) > 1e-6 || Math.abs(parseFloat(a[2])) > 1e-6)) return true;
  }
  return false;
}

const files = fs.readdirSync(OUT).filter(f => f.endsWith('.scene.json')).sort();
let regenerated = 0, skipped = 0, unchanged = 0, fail = 0, noSwf = 0;
const t0 = Date.now();
for (const f of files) {
  if (regenerated >= LIMIT) break;
  if (SKIP && f.startsWith(SKIP)) continue;
  if (ONLY && !f.startsWith(ONLY)) continue;
  const stem = f.replace(/\.scene\.json$/, '');
  if (done.has(stem)) { skipped++; continue; }
  const outFile = path.join(OUT, f);
  try {
    const j = fs.readFileSync(outFile, 'utf8');
    const mark = (ok) => { if (ok) regenerated++; else unchanged++; done.add(stem); fs.appendFileSync(PROGRESS, stem + '\n'); };
    if (!force && !matricesNeedRegen(j)) { mark(false); continue; }
    const srcM = j.match(/"source":"([^"]*)"/);
    const src = srcM ? srcM[1] : null;
    const res = src && INDEX[String(src).toLowerCase()];
    if (!res) { noSwf++; mark(false); continue; }
    const swfPath = path.join(ASSETS, res.cat, res.hash + '.swf');
    if (!fs.existsSync(swfPath)) { noSwf++; mark(false); continue; }
    const scene = swfToScene(parseSwf(fs.readFileSync(swfPath)), { source: src });
    fs.writeFileSync(outFile, JSON.stringify(scene));
    mark(true);
    if (regenerated % 200 === 0) console.log('  ...regenerated ' + regenerated + ' (' + Math.round((Date.now() - t0) / 1000) + 's)');
  } catch (e) { fail++; }
}
console.log(JSON.stringify({ files: files.length, regenerated, skipped, unchanged, noSwf, fail }, null, 1));

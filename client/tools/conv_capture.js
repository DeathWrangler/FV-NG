// FV-NG — capture-driven sprite-conversion manager.
//
// Reads an AMF capture (produced by the amfphp hook + client/editor/amf_capture.js), derives the
// avatar-item and world-object sprites the live client actually used, checks the deployed scene set,
// and converts any missing SWFs to runtime scenes via the standard swf2scene pipeline. Parity is
// therefore automatic for ANY capture, not just the one it was built against.
//
// Usage:
//   node conv_capture.js <capture.jsonl> [--dialogs=a,b,c] [--source=flash|all] [--budget=N] [--dry]
//
// Outputs: <webroot>/farmville/fvng/scenes/{av_*,stem,dlg_*}.scene.json
//          + scenesbyname.json / dialogsbyname.json (also copied to client/web/)
// Requires swf-parser in this dir (client/tools/node_modules).
'use strict';
const fs = require('fs');
const path = require('path');
const { parseSwf } = require('swf-parser');
const { swfToScene } = require('./swf2scene.js');
const { readRecords, decodeRecord } = require('../editor/amf_capture_lib.js');

const ROOT = 'C:/Farmville/xampp/htdocs/public/farmville';
const ASSETS = ROOT + '/assets/hashed/assets';
const REPO = path.join(__dirname, '..');                  // client/
const DEVWEB = path.join(REPO, 'web');
const HASH = path.join(REPO, 'assets', 'assethash.json');
const ITEMS = path.join(REPO, '..', 'build', 'item_assets.json');

const arg = (name, def) => { const a = process.argv.find(x => x.startsWith('--' + name + '=')); return a ? a.split('=')[1] : def; };
const hasFlag = name => process.argv.includes('--' + name);
const captureFile = process.argv[2] && !process.argv[2].startsWith('--') ? process.argv[2] : '/tmp/fvng_amf_capture.jsonl';
const ONLY_SOURCE = arg('source', 'flash');              // 'flash' (live client) | 'all'
const BUDGET = parseInt(arg('budget', '300'), 10);
const DRY = hasFlag('dry');
const OUT_OVERRIDE = arg('out', null);                    // test hook: write elsewhere, skip dev-map copy
const OUT = OUT_OVERRIDE || (ROOT + '/fvng/scenes');
const CLIDIALOGS = (arg('dialogs', '') || '').split(',').map(s => s.trim()).filter(Boolean);

// Resolve an assethash key to its file: hashed assets mirror the key's directory
// (mylife/avatar_assets/<name>.swf -> assets/mylife/avatar_assets/<hash>.swf).
function assetPath(cat, key, hash) {
  const ext = path.extname(key) || '.swf';
  const dir = path.dirname(key);
  const cands = [];
  if (dir && dir !== '.') cands.push(path.join(ASSETS, cat, dir, hash + ext));
  cands.push(path.join(ASSETS, cat, hash + ext));
  return cands.find(fs.existsSync) || cands[0];
}

// ---- asset index (name -> {cat, hash, key}); exact-key + basename lookups ----
const assethash = JSON.parse(fs.readFileSync(HASH, 'utf8'));
const INDEX = {}, BASE = {}, SUFFIX = {};
for (const cat of Object.keys(assethash)) for (const key of Object.keys(assethash[cat] || {})) {
  const k = key.toLowerCase(); const rec = { cat, key, hash: assethash[cat][key] };
  if (!(k in INDEX)) INDEX[k] = rec;
  const b = path.basename(k); if (!(b in BASE)) BASE[b] = rec;   // basename without dir
  if (/\.swf$/.test(k)) {                                        // prefix-stripped suffix (tree_lombardypoplar -> lombardypoplar)
    const stem = path.basename(k, '.swf'); if (!(stem in SUFFIX)) SUFFIX[stem] = rec;
    const cut = stem.indexOf('_'); if (cut !== -1) { const s = stem.slice(cut + 1); if (!(s in SUFFIX)) SUFFIX[s] = rec; }
  }
}
const ITEM_IMAGE = {};                                    // itemName -> image swf
if (fs.existsSync(ITEMS)) for (const it of JSON.parse(fs.readFileSync(ITEMS, 'utf8'))) ITEM_IMAGE[it.name] = it.image;

const sanitize = s => s.replace(/\.[^.]+$/, '').replace(/[^A-Za-z0-9]+/g, '_').replace(/^_+|_+$/g, '');
const findAsset = (...cands) => {
  for (const c of cands) {
    if (!c) continue;
    const k = String(c).toLowerCase();
    const hit = INDEX[k] || BASE[path.basename(k)] || SUFFIX[path.basename(k).replace(/\.swf$/, '')];
    if (hit) return hit;
  }
  return null;
};

// ---- deployed maps (loaded before deriving so we can reuse existing stems) ----
const mapPath = p => path.join(OUT, p);
const scenesByName = fs.existsSync(mapPath('scenesbyname.json')) ? JSON.parse(fs.readFileSync(mapPath('scenesbyname.json'), 'utf8')) : {};
const dialogsByName = fs.existsSync(mapPath('dialogsbyname.json')) ? JSON.parse(fs.readFileSync(mapPath('dialogsbyname.json'), 'utf8')) : {};

// ---- derive required sprites from the capture ----
function walkStrings(v, out, depth) {
  if (depth > 6 || v == null) return;
  if (typeof v === 'string') { if (v.length <= 64) out.push(v); return; }
  if (Array.isArray(v)) { for (const x of v) walkStrings(x, out, depth + 1); return; }
  if (typeof v === 'object') for (const k of Object.keys(v)) walkStrings(v[k], out, depth + 1);
}

const records = readRecords(captureFile);
if (!records.length) { console.error('no capture records at ' + captureFile); process.exit(1); }

const avatarItems = {};        // category -> item (from initUser.userInfo.avatar)
const worldNames = new Set();  // world object itemNames
const allStrings = [];
let flash = 0, fvng = 0;
for (const rec of records) {
  const d = decodeRecord(rec);
  if (d.source === 'flash') flash++; else fvng++;
  if (ONLY_SOURCE === 'flash' && d.source !== 'flash') continue;
  for (const e of d.respEntries) {
    const p = e && e.data;
    if (!p || typeof p !== 'object') continue;
    const ui = p.userInfo || (p.userInfo === undefined && p.avatar ? p : null);
    if (ui && ui.avatar && ui.avatar.items) Object.assign(avatarItems, ui.avatar.items);
    const world = (ui && ui.world) || p.world;             // initUser has world at top level; loadOwnWorld nests it
    if (world && world.objectsArray) {
      const arr = Array.isArray(world.objectsArray) ? world.objectsArray : Object.values(world.objectsArray);
      for (const o of arr) if (o && o.itemName) worldNames.add(o.itemName);
    }
    walkStrings(p, allStrings, 0);
  }
}

// dialogs: explicit + any captured string matching a known dialog SWF basename
const DIALOG_BASE = {};   // lowercased basename -> assethash key
for (const key of Object.keys(assethash.dialogs || {})) DIALOG_BASE[path.basename(key, '.swf').toLowerCase()] = key;
const dialogHits = new Set(CLIDIALOGS.map(s => s.toLowerCase()));
for (const s of allStrings) { const b = path.basename(s, '.swf').toLowerCase(); if (DIALOG_BASE[b]) dialogHits.add(b); }

// ---- resolve required scene stems -> source spec ----
const required = [];   // { kind, stem, label, swfPath|null, mapKey, mapValue }
const unresolved = [];

for (const [cat, it] of Object.entries(avatarItems)) {
  if (!it || !it.filename) continue;                       // 'body' = skin tint only
  const res = findAsset('avatar_assets/' + it.filename + '.swf', it.filename);
  required.push({ kind: 'avatar', stem: 'av_' + it.filename, label: it.filename, swfPath: res ? assetPath(res.cat, res.key, res.hash) : null });
}
for (const name of worldNames) {
  const image = ITEM_IMAGE[name] || (name + '.swf');
  const res = findAsset(image, name + '.swf', name);
  const stem = scenesByName[name] || (res ? path.basename(res.key, '.swf') : image.replace(/\.swf$/i, ''));
  required.push({ kind: 'world', stem, label: name, swfPath: res ? assetPath(res.cat, res.key, res.hash) : null, mapKey: name, mapValue: stem });
}
for (const b of dialogHits) {
  const key = DIALOG_BASE[b]; if (!key) { unresolved.push('dialog ' + b); continue; }
  const stem = 'dlg_' + sanitize(key);
  required.push({ kind: 'dialog', stem, label: b, swfPath: assetPath('dialogs', key, assethash.dialogs[key]), mapKey: path.basename(key, '.swf'), mapValue: stem });
}

// ---- convert missing ----
fs.mkdirSync(OUT, { recursive: true });
const seen = new Set();
let present = 0, converted = 0, failed = 0, dup = 0;
for (const r of required) {
  if (seen.has(r.stem)) { dup++; continue; }
  seen.add(r.stem);
  const outFile = path.join(OUT, r.stem + '.scene.json');
  if (fs.existsSync(outFile)) {               // already deployed — reuse it
    present++;
  } else if (!r.swfPath || !fs.existsSync(r.swfPath)) {
    failed++; unresolved.push(r.kind + ' ' + r.label + ' (no source SWF, stem ' + r.stem + ')');
  } else if (converted >= BUDGET) {
    failed++; unresolved.push(r.kind + ' ' + r.label + ' (budget reached)');
  } else if (DRY) {
    converted++;
  } else {
    try {
      fs.writeFileSync(outFile, JSON.stringify(swfToScene(parseSwf(fs.readFileSync(r.swfPath)), { source: r.label })));
      converted++;
    } catch (e) { failed++; unresolved.push(r.kind + ' ' + r.label + ' convert failed: ' + e.message); }
  }
  if (r.kind === 'world' && r.mapKey) scenesByName[r.mapKey] = r.mapValue;
  if (r.kind === 'dialog' && r.mapKey) dialogsByName[r.mapKey] = r.mapValue;
}

if (!DRY) {
  fs.writeFileSync(mapPath('scenesbyname.json'), JSON.stringify(scenesByName));
  fs.writeFileSync(mapPath('dialogsbyname.json'), JSON.stringify(dialogsByName));
  if (!OUT_OVERRIDE) {   // don't clobber the repo maps when writing to a test dir
    fs.writeFileSync(path.join(DEVWEB, 'scenesbyname.json'), JSON.stringify(scenesByName));
    fs.writeFileSync(path.join(DEVWEB, 'dialogsbyname.json'), JSON.stringify(dialogsByName));
  }
}

// ---- report ----
const byKind = { avatar: 0, world: 0, dialog: 0 };
for (const r of required) byKind[r.kind]++;
console.log('== capture sprite manager ==');
console.log('capture: ' + captureFile + '  (records=' + records.length + ', flash=' + flash + ', fvng=' + fvng + ', source=' + ONLY_SOURCE + ')');
console.log('required: ' + seen.size + '  ->  avatar=' + byKind.avatar + ' world=' + byKind.world + ' dialog=' + byKind.dialog);
console.log('scenes: present=' + present + '  converted=' + converted + '  failed=' + failed + (dup ? '  (dupes=' + dup + ')' : '') + (DRY ? '  [DRY RUN]' : ''));
if (unresolved.length) { console.log('unresolved (' + unresolved.length + '):'); for (const u of unresolved.slice(0, 40)) console.log('  - ' + u); }
console.log('\navatar items used by the live client:');
for (const [cat, it] of Object.entries(avatarItems)) console.log('  ' + cat.padEnd(9) + (it.filename || '(skin)') + (it.metaData ? '  ' + it.metaData : ''));

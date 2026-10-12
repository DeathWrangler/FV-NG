// FV-NG — UI indexer: scan decompiled AS3 classes, extract dialog/menu asset paths + every
// button/text-field binding (the "functions mapped" source of truth). Emits build/uiindex/index.json.
//
// The JOIN KEY between code and art is the SWF INSTANCE NAME (e.g. `accept_bt` in
// `m_window.popupBox_mc.accept_bt`). swf2scene captures instance names on placements, so the
// editor matches a code binding's last-segment to a scene placement/button by name.
//
// Binding idioms handled:
//   new GenericButton(<path>, this.<handler>)                          -> kind=button
//   setShortcutListener("<name>", ..., this.<handler>)                 -> kind=shortcut
//   ddd.addButtonEventListener(GenericXMLDialog.STR_..., this.<h>)     -> kind=ddd_button
//   <mc>.addEventListener(MouseEvent.CLICK, this.<handler>)            -> kind=click
// Text fields:  `<path> as TextField` / `.htmlText = ...` / `.text = ...`
const fs = require('fs');
const path = require('path');
const { loadConfig } = require('../config.js');

// CLI: node indexer.js [--src <dir>] [--out <path>]  (defaults from config)
const argv = process.argv.slice(2);
function argVal(flag, dflt) { const i = argv.indexOf(flag); return i >= 0 && argv[i + 1] ? argv[i + 1] : dflt; }
const cfg = loadConfig();
const ROOT = argVal('--src', cfg.indexSourceDir);
const OUT = argVal('--out', cfg.indexFile);

// ---- walk .as files ----
function walk(dir, out) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, out);
    else if (e.name.endsWith('.as')) out.push(p);
  }
  return out;
}

// ---- extract last segment of an instance path: `a.b.c` -> `c`; strip `m_window.` prefix noise ----
function lastSeg(expr) {
  const s = expr.trim().replace(/\s+/g, '');
  if (!s) return null;
  // drop a leading this./m_window./getWindow() prefix chain up to the leaf that looks like an instance name
  const parts = s.split('.');
  // The instance name is typically the last identifier token (not a method call). If it ends in '()' take prior.
  let leaf = parts[parts.length - 1];
  if (/^\w+\($/.test(leaf) && parts.length > 1) leaf = parts[parts.length - 2];
  return leaf || null;
}
function fullPath(expr) {
  // keep the meaningful tail: from popupBox_mc onward, or last two segments
  const s = expr.trim().replace(/\s+/g, '');
  const parts = s.split('.').filter(Boolean);
  const idx = parts.findIndex(p => /_mc$|_bt$|_tf$/.test(p));
  if (idx >= 0) return parts.slice(idx).join('.');
  return parts.slice(-2).join('.');
}
// Category of an asset path: the segment after `assets/` (assets/dialogs/x.swf -> dialogs).
function categoryOf(assetPath) {
  const m = String(assetPath).match(/^assets\/([^\/]+)\//);
  return m ? m[1] : null;
}

// Join physical lines into "logical" lines so multi-line calls bind correctly. A logical line
// continues onto the next while parens are unbalanced or the line ends in an operator/comma.
// Each entry is { text, line } where line is the 1-based starting physical line (for `line` fields).
function logicalLines(lines) {
  const out = [];
  let buf = '', start = 0;
  for (let i = 0; i < lines.length; i++) {
    const ln = lines[i];
    if (!buf) { buf = ln; start = i + 1; }
    else buf += ' ' + ln;
    let depth = 0;
    for (const ch of buf) { if (ch === '(') depth++; else if (ch === ')') depth--; }
    const trimmed = buf.replace(/\s+$/, '');
    const endsContinuation = /[,=+\-*/&|?:.]$/.test(trimmed);
    if (depth <= 0 && !endsContinuation) { out.push({ text: buf, line: start }); buf = ''; }
  }
  if (buf.trim()) out.push({ text: buf, line: start });
  return out;
}

function parseClass(file) {
  const src = fs.readFileSync(file, 'utf8');
  const lines = src.split(/\r?\n/);
  const rec = {
    file: file.replace(/\\/g, '/').replace(ROOT + '/', ''),
    cls: null, pkg: null, extends: null,
    assets: [],          // {path, line, category}
    assetPrimary: null,  // m_dialogAsset value
    dddNames: [],        // createDialog("X") names (data-driven)
    bindings: [],        // {element, leaf, handler, kind, line, raw}
    textFields: [],      // {element, leaf, line}
    sounds: [],          // SoundManager.playSound("x")
  };

  // package + class decl
  let m = src.match(/package\s+([\w.]+)\s*\{/); if (m) rec.pkg = m[1];
  m = src.match(/class\s+(\w+)\s+(?:extends\s+(\w+))?/); if (m) { rec.cls = m[1]; rec.extends = m[2] || null; }

  // global regexes (exec loop so multiple matches per line are caught without infinite loop)
  const reAsset = /"(assets\/[A-Za-z0-9_\/\.\-]+?\.swf)"/g;
  const reDDD = /(?:createDialog|getDialogsXMLByName)\(\s*"([\w]+)"/g;
  const reGB = /new\s+GenericButton\(\s*([\w.\[\]]+)\s*,\s*(?:this\.)?(\w+)/g;
  const reShortcut = /setShortcutListener\(\s*"([\w]+)"\s*,[^,]*,\s*(?:this\.)?(\w+)/g;
  const reDddBtn = /addButtonEventListener\(\s*(?:GenericXMLDialog\.)?([\w]+)\s*,\s*(?:this\.)?(\w+)/g;
  const reClick = /([\w.]+)\.addEventListener\(\s*MouseEvent\.(CLICK|MOUSE_DOWN|MOUSE_UP|DOUBLE_CLICK|ROLL_OVER|ROLL_OUT)\s*,\s*(?:this\.)?(\w+)/g;
  const reSound = /playSound\(\s*"([\w]+)"/g;

  // assetPrimary may be assigned on one line and the literal on the next — carry a pending flag.
  let pendingPrimary = false;
  for (const { text: ln, line: lineNo } of logicalLines(lines)) {
    if (/m_dialogAsset\s*=/.test(ln)) pendingPrimary = true;
    // --- asset paths: any "assets/....swf" literal (works even if the m_dialogAsset = is on a prior line) ---
    let am; reAsset.lastIndex = 0;
    while ((am = reAsset.exec(ln))) {
      rec.assets.push({ path: am[1], line: lineNo, category: categoryOf(am[1]) });
      if (pendingPrimary) { rec.assetPrimary = am[1]; pendingPrimary = false; }
    }
    // --- data-driven dialog name ---
    let dm; reDDD.lastIndex = 0;
    while ((dm = reDDD.exec(ln))) if (!rec.dddNames.includes(dm[1])) rec.dddNames.push(dm[1]);
    if (/DIALOG_ASSET_TYPE_DDD/.test(ln)) rec.isDDD = true;

    // --- button binding: new GenericButton(<path>, this.<handler>) ---
    let gm; reGB.lastIndex = 0;
    while ((gm = reGB.exec(ln))) {
      const element = gm[1];
      rec.bindings.push({ element, leaf: lastSeg(element), full: fullPath(element), handler: gm[2], kind: 'button', line: lineNo, raw: ln.trim() });
    }
    // --- shortcut listener (slot is a shortcut KEY, not an SWF instance name) ---
    let sm; reShortcut.lastIndex = 0;
    while ((sm = reShortcut.exec(ln))) rec.bindings.push({ element: sm[1], leaf: sm[1], full: sm[1], slot: sm[1], handler: sm[2], kind: 'shortcut', line: lineNo, raw: ln.trim() });
    // --- DDD button listener ---
    let bm; reDddBtn.lastIndex = 0;
    while ((bm = reDddBtn.exec(ln))) rec.bindings.push({ element: bm[1], leaf: bm[1], full: bm[1], handler: bm[2], kind: 'ddd_button', line: lineNo, raw: ln.trim() });
    // --- click listener on a named mc (any mouse event) ---
    let cm; reClick.lastIndex = 0;
    while ((cm = reClick.exec(ln))) rec.bindings.push({ element: cm[1], leaf: lastSeg(cm[1]), full: fullPath(cm[1]), handler: cm[3], kind: 'click', line: lineNo, raw: ln.trim() });

    // --- text fields ---
    let tm = ln.match(/([\w.]+)\s+as\s+TextField/);
    if (tm) rec.textFields.push({ element: tm[1], leaf: lastSeg(tm[1]), full: fullPath(tm[1]), line: lineNo });
    else {
      const lm = ln.match(/([\w.]+)\.(?:htmlText|text)\s*=/);
      if (lm) rec.textFields.push({ element: lm[1], leaf: lastSeg(lm[1]), full: fullPath(lm[1]), line: lineNo });
    }

    // --- sounds ---
    let sd; reSound.lastIndex = 0;
    while ((sd = reSound.exec(ln))) if (!rec.sounds.includes(sd[1])) rec.sounds.push(sd[1]);
  }

  // dedupe text fields by leaf+line
  const seen = new Set(); rec.textFields = rec.textFields.filter(t => { const k = t.leaf + ':' + t.line; if (seen.has(k)) return false; seen.add(k); return true; });
  // only keep as a UI record if it has an asset, binding, or ddd name
  rec.isUI = !!(rec.assets.length || rec.bindings.length || rec.dddNames.length);
  return rec;
}

const files = walk(ROOT, []);
let ui = 0, total = 0;
const records = [];
for (const f of files) {
  total++;
  try { const r = parseClass(f); if (r.isUI) { records.push(r); ui++; } } catch (e) { /* skip */ }
}

// ---- reverse maps ----
// asset path -> [class, ...]   and   leaf instance name -> [{cls, handler, kind, file}]
const byAsset = {};
const byLeaf = {};
const categories = {};   // <category> -> number of distinct assets in that category
for (const r of records) {
  for (const a of r.assets) {
    (byAsset[a.path] = byAsset[a.path] || []).push({ cls: r.cls, file: r.file, category: a.category });
    if (a.category) categories[a.category] = (categories[a.category] || 0) + 1;
  }
  if (r.assetPrimary) {
    const cat = categoryOf(r.assetPrimary);
    (byAsset[r.assetPrimary] = byAsset[r.assetPrimary] || []).push({ cls: r.cls, file: r.file, primary: true, category: cat });
    if (cat && !r.assets.some(a => a.path === r.assetPrimary)) categories[cat] = (categories[cat] || 0) + 1;
  }
  for (const b of r.bindings) {
    (byLeaf[b.leaf] = byLeaf[b.leaf] || []).push({ cls: r.cls, handler: b.handler, kind: b.kind, element: b.element, line: b.line, file: r.file });
  }
}

const index = {
  generatedAt: new Date().toISOString(),
  root: ROOT,
  stats: { filesScanned: total, uiClasses: ui, assets: Object.keys(byAsset).length, leaves: Object.keys(byLeaf).length, categories },
  classes: records,
  byAsset,
  byLeaf,
};

fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, JSON.stringify(index));
console.log(JSON.stringify(index.stats, null, 1));
console.log('sample classes:', records.slice(0, 8).map(r => r.cls + ' (assets:' + r.assets.length + ', bindings:' + r.bindings.length + ')').join(', '));

// M4-2: keep dispatch.json in lockstep with index.json — regenerate it right after a default
// index write (skipped for --out scratch paths so they don't clobber the canonical artifact).
if (path.resolve(OUT) === path.resolve(cfg.indexFile)) {
  try {
    const { buildDispatch } = require('./dispatch.js');
    let byName = {};
    try { byName = JSON.parse(fs.readFileSync(cfg.dialogsByNameFile, 'utf8')); } catch (e) {}
    const dispatch = buildDispatch(index, byName);
    fs.mkdirSync(path.dirname(cfg.dispatchFile), { recursive: true });
    fs.writeFileSync(cfg.dispatchFile, JSON.stringify(dispatch));
    console.log('dispatch written:', cfg.dispatchFile, '| stats:', JSON.stringify(dispatch.stats));
  } catch (e) {
    console.warn('dispatch regeneration skipped:', e.message);
  }
}

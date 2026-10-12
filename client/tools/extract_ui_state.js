#!/usr/bin/env node
// FV-NG — AS3 UI-state extractor (1:1 emulation, layer "state").
//
// The market/dialog SWFs are STATIC display lists: one root frame contains every UI variant
// (small/med backgrounds, LE revamp, FTUE overlays, charity banner, flash-sale slots, ...).
// The original client emulates "scenes" by hiding most of them with AS3 (.visible = false) and
// picking a layout with gotoAndStop(n). This tool mechanically extracts that state program from
// the decompiled window class so the JS renderer can reproduce any UI state 1:1.
//
// It is DERIVATION, not invention: every emitted rule cites its source line in the .as file.
//
// Usage:
//   node extract_ui_state.js <WindowClass.as> [more.as ...] [--out state.json]
//   FVNG_STATE_SCENE=<scene.json>  # optional: cross-check names against scene named elements
'use strict';
const fs = require('fs');

const files = [];
let outFile = null;
for (let i = 2; i < process.argv.length; i++) {
  const a = process.argv[i];
  if (a === '--out') { outFile = process.argv[++i]; }
  else if (!a.startsWith('--')) files.push(a);
}
if (!files.length) { console.error('usage: node extract_ui_state.js <Window.as> [--out state.json]'); process.exit(1); }

// ---- patterns (kept intentionally narrow; every match is cited) ----
const RE_VISIBLE = /^(\s*)(\(?[\w.$]+\s+as\s+\w+\)?|[\w.$]+)\.visible\s*=\s*(true|false)(?:\s*as\s+\w+)?\s*;?\s*$/;
const RE_GOTO    = /^(\s*)(\(?[\w.$]+\s+as\s+\w+\)?|[\w.$]+)\.gotoAndStop\s*\(\s*([^\)]+)\)/;
const RE_WIDGET  = /new\s+(\w+)\((m_window|this\.m_window)\.([\w$]+)/g;

// resolve a receiver like `m_window.bgMed_mc` or `this.m_sortByMenu` to (rootName|null, widgetVar)
function resolveReceiver(recv, file) {
  // strip an AS3 cast wrapper: (this.m_ftue as MovieClip).gotoAndStop(...)
  const cast = recv.match(/^\(([\w.$]+)\s+as\s+\w+\)$/);
  if (cast) recv = cast[1];
  // bare m_window -> the loaded SWF root timeline itself
  if (/^(?:this\.)?m_window$/.test(recv)) return { kind: 'root' };
  // m_window.NAME  -> element on the SWF root
  const mw = recv.match(/^(?:this\.)?m_window\.([\w$]+)$/);
  if (mw) return { kind: 'element', name: mw[1] };
  // this.m_widgetVar -> a widget wrapping an element; we record it as a widget binding
  const wv = recv.match(/^(?:this\.)?(m_\w+)$/);
  if (wv) return { kind: 'widget', var: wv[1] };
  return { kind: 'other', raw: recv, file };
}

const states = [];          // {file, line, target:{kind,name|var}, op:'show'|'hide'}
const gotos = [];           // {file, line, target, frame}
const widgetBindings = {};  // var -> {class, element, file, line}
const otherAssigns = new Map();

for (const f of files) {
  const lines = fs.readFileSync(f, 'utf8').replace(/\r\n/g, '\n').split('\n');
  // build a line -> enclosing method map so rules can be grouped into per-method UI states
  const fnStarts = []; // [lineIdx, name]
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^\s*(?:public\s+|private\s+|internal\s+|final\s+|override\s+|static\s+|protected\s+)*function\s+(\w+)/);
    if (m) fnStarts.push([i, m[1]]);
  }
  const methodAt = lineIdx => {
    let name = null;
    for (const [li, n] of fnStarts) { if (li <= lineIdx) name = n; else break; }
    return name;
  };
  let lastWidgetLine = null;
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const line = raw.replace(/\s+$/, '');
    // widget bindings: this.m_x = addWidget(new SomeClass(m_window.NAME, ...))
    let wm = line.match(/this\.(m_\w+)\s*=\s*addWidget\s*\(\s*new\s+(\w+)\s*\(\s*(?:this\.)?m_window\.([\w$]+)/);
    if (wm) { widgetBindings[wm[1]] = { class: wm[2], element: wm[3], file: f, line: i + 1 }; lastWidgetLine = i; }
    const vm = line.match(RE_VISIBLE);
    if (vm) {
      const r = resolveReceiver(vm[2], f);
      states.push({ file: f, line: i + 1, method: methodAt(i), target: r, op: vm[3] === 'true' ? 'show' : 'hide', ctx: line.trim() });
      continue;
    }
    const gm = line.match(RE_GOTO);
    if (gm) {
      const r = resolveReceiver(gm[2], f);
      gotos.push({ file: f, line: i + 1, method: methodAt(i), target: r.kind === 'root' ? 'windowRoot' : (r.name || r.var || r.raw), frame: gm[3].trim(), ctx: line.trim() });
    }
  }
}

// ---- cross-check against scene named elements (optional) ----
let sceneCheck = null;
const scenePath = process.env.FVNG_STATE_SCENE;
if (scenePath && fs.existsSync(scenePath)) {
  const scene = JSON.parse(fs.readFileSync(scenePath, 'utf8'));
  const named = new Set();
  const walk = list => { for (const p of list) if (p.name) named.add(p.name); };
  (scene.frames || []).forEach(walk);
  for (const id in scene.characters || {}) { const c = scene.characters[id]; if (c.type === 'sprite') (c.frames || [c.frames[0]]).forEach(f => walk(Array.isArray(f) ? f : [])); }
  const touchedNames = new Set();
  for (const s of states) if (s.target.kind === 'element') touchedNames.add(s.target.name);
  for (const b of Object.values(widgetBindings)) touchedNames.add(b.element);
  const frame1Named = named;
  sceneCheck = {
    scene: scenePath,
    totalNamedInScene: frame1Named.size,
    touchedByAS3: [...touchedNames].filter(n => frame1Named.has(n)).length,
    untouchedByNameInScene: [...frame1Named].filter(n => !touchedNames.has(n)).sort(),
    referencedButNotInScene: [...touchedNames].filter(n => !frame1Named.has(n)).sort(),
  };
}

const report = {
  files,
  summary: { visibilityRules: states.length, gotoAndStopRules: gotos.length, widgetBindings: Object.keys(widgetBindings).length },
  sceneCheck,
  // per-method rule counts (the "states" of the window, one method ~= one UI state)
  methods: (() => {
    const m = new Map();
    for (const s of states) { const k = s.method || '(ctor/field)'; const e = m.get(k) || { show: 0, hide: 0 }; e[s.op]++; m.set(k, e); }
    for (const g of gotos) { const k = g.method || '(ctor/field)'; const e = m.get(k) || { show: 0, hide: 0 }; e.gotos = (e.gotos || 0) + 1; m.set(k, e); }
    return [...m.entries()].map(([name, c]) => ({ method: name, ...c })).sort((a, b) => (b.show + b.hide + b.gotos) - (a.show + a.hide + a.gotos));
  })(),
  // element-level rules (these map directly onto scene placements by name)
  elementRules: states.filter(s => s.target.kind === 'element').map(s => ({ method: s.method, line: s.line, file: s.file, name: s.target.name, op: s.op, ctx: s.ctx })),
  // widget-level rules (the renderer must resolve var -> element via widgetBindings first)
  widgetRules: states.filter(s => s.target.kind === 'widget').map(s => ({ method: s.method, line: s.line, file: s.file, widget: s.target.var, op: s.op, ctx: s.ctx })),
  gotos: gotos.map(g => ({ method: g.method, line: g.line, file: g.file, target: g.target, frame: g.frame, ctx: g.ctx })),
  widgetBindings,
};

const json = JSON.stringify(report, null, 1);
if (outFile) { fs.writeFileSync(outFile, json); console.log('wrote ' + outFile); }
console.log(JSON.stringify(report.summary));
console.log('top methods by rule count:');
for (const m of report.methods.slice(0, 12)) console.log('   ' + m.method + ': show=' + m.show + ' hide=' + m.hide + (m.gotos ? ' gotos=' + m.gotos : ''));
if (sceneCheck) {
  console.log('scene named elements:', sceneCheck.totalNamedInScene, '| touched by AS3:', sceneCheck.touchedByAS3);
  if (sceneCheck.untouchedByNameInScene.length) console.log('in scene but NEVER toggled by AS3 (always-visible baseline):', sceneCheck.untouchedByNameInScene.join(', '));
  if (sceneCheck.referencedButNotInScene.length) console.log('referenced by AS3 but NOT in scene:', sceneCheck.referencedButNotInScene.join(', '));
}

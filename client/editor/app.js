'use strict';
/* FV-NG UI Editor — app logic.
   Loads /api/index (AS3 bindings) + /api/manifest (assets). On asset select, fetches a fresh
   named scene from /api/convert, renders it with the shared FVScene renderer, and lets you pick
   elements on the canvas to see exactly which decompiled handler maps to each button/field. */

const $ = (s) => document.querySelector(s);
const cv = $('#cv'), ctx = cv.getContext('2d');

// ---------- state ----------
let INDEX = null;          // /api/index
let MANIFEST = null;       // /api/manifest
let bindingsByLeaf = {};   // leaf name -> [{cls,handler,kind,line,file}]
let classesByAsset = {};   // FULL asset key (assets/dialogs/X.swf) -> [class]  (primary)
let classesByBase = {};    // basename-no-ext (X) -> [class]  (fallback for collisions)
let currentKey = null;     // selected asset key
let fv = null;             // current FVScene
let view = { scale: 1, tx: 0, ty: 0 };
let selected = null;       // picked element descriptor
let hovered = null;

// ---------- boot ----------
(async function boot() {
  setStatus('loading index + manifest…');
  [INDEX, MANIFEST] = await Promise.all([
    fetch('/api/index').then(r => r.json()),
    fetch('/api/manifest').then(r => r.json()),
  ]);
  buildIndexes();
  renderAssetList();
  bindUI();
  resizeCanvas();
  window.addEventListener('resize', () => { resizeCanvas(); redraw(); });
  setStatus(`ready — ${MANIFEST.count} assets, ${INDEX.stats.uiClasses} UI classes`);
})().catch(e => { console.error('boot failed', e); setStatus('BOOT ERROR: ' + e.message); });

function buildIndexes() {
  for (const c of INDEX.classes) {
    // asset -> classes, keyed by FULL asset key (primary) AND basename-without-ext (fallback).
    // Full-key primary avoids collisions between two subdirs sharing a filename.
    const fullKeys = new Set();
    if (c.assetPrimary) fullKeys.add(c.assetPrimary);
    for (const a of c.assets || []) fullKeys.add(a.path);
    for (const k of fullKeys) {
      (classesByAsset[k] = classesByAsset[k] || []).push(c);
      (classesByBase[baseNoExt(k)] = classesByBase[baseNoExt(k)] || []).push(c);
    }
    // leaf -> bindings
    for (const b of c.bindings || []) {
      if (!b.leaf) continue;
      (bindingsByLeaf[b.leaf] = bindingsByLeaf[b.leaf] || []).push({ cls: c.cls, handler: b.handler, kind: b.kind, line: b.line, file: c.file, full: b.full });
    }
  }
}
const baseNoExt = (p) => { const b = String(p).split('/').pop(); return b.replace(/\.swf$/i, ''); };
// classes for a manifest row: exact full-key match first, then basename fallback.
function classesForKey(key) {
  if (!key) return [];
  if (classesByAsset[key]) return classesByAsset[key];
  return classesByBase[baseNoExt(key)] || [];
}

// ---------- asset list ----------
function renderAssetList() {
  const q = ($('#search').value || '').trim().toLowerCase();
  const onlyMapped = $('#onlyMapped').checked;
  const rows = [];
  for (const a of MANIFEST.rows) {
    const classes = classesForKey(a.key);
    const mapped = classes.length > 0;
    if (onlyMapped && !mapped) continue;
    if (q) {
      const hay = (a.name + ' ' + a.key + ' ' + classes.map(c => c.cls).join(' ')).toLowerCase();
      if (!hay.includes(q)) continue;
    }
    rows.push({ a, mapped, classes });
  }
  // sort: mapped first, then name
  rows.sort((x, y) => (y.mapped - x.mapped) || (x.a.name || '').localeCompare(y.a.name || ''));
  const el = $('#assetList');
  el.innerHTML = '';
  const frag = document.createDocumentFragment();
  for (const r of rows.slice(0, 1500)) {
    const d = document.createElement('div');
    d.className = 'asset-row' + (r.a.key === currentKey ? ' active' : '');
    d.dataset.key = r.a.key;
    const badges = [];
    if (r.mapped) badges.push('<span class="badge mapped">mapped</span>');
    for (const c of r.classes.slice(0, 1)) if (c.isDDD) badges.push('<span class="badge ddd">ddd</span>');
    d.innerHTML = `<div class="aname">${esc(r.a.name || r.a.key)}</div>
      <div class="ameta">${badges.join(' ')}<span>${r.classes.length ? r.classes.map(c => c.cls).slice(0, 2).join(', ') : 'no AS3 class'}</span></div>`;
    d.onclick = () => selectAsset(r.a.key);
    frag.appendChild(d);
  }
  el.appendChild(frag);
}

// ---------- asset selection + scene load ----------
async function selectAsset(key) {
  currentKey = key; selected = null; hovered = null; fv = null;
  document.querySelectorAll('.asset-row').forEach(r => r.classList.toggle('active', r.dataset.key === key));
  setStatus('converting ' + key + '…');
  $('#stageName').textContent = key;
  try {
    const resp = await fetch('/api/convert?key=' + encodeURIComponent(key));
    const r = resp.ok ? await resp.json() : { ok: false, error: await resp.text() };
    if (!r.ok) throw new Error(r.error || ('HTTP ' + resp.status));
    fv = new FVScene(r.scene);
    await fv.load();
    fitView();
    setStatus((r.fromCache ? 'cached' : 'converted') + ' · ' + key);
    redraw();
    showAssetInspector(key);
  } catch (e) {
    setStatus('error: ' + e.message);
    $('#inspector').innerHTML = `<div class="empty">Could not load scene for <b>${esc(key)}</b>: ${esc(e.message)}</div>`;
  }
}

// ---------- canvas view transform ----------
function resizeCanvas() {
  const r = cv.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  cv.width = Math.max(1, Math.round(r.width * dpr));
  cv.height = Math.max(1, Math.round(r.height * dpr));
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}
function fitView() {
  if (!fv) return;
  const r = cv.getBoundingClientRect();
  const m = fv.measure(0);
  const pad = 0.92;
  view.scale = Math.min(r.width / m.w, r.height / m.h) * pad;
  view.tx = (r.width - m.w * view.scale) / 2 - m.x * view.scale;
  view.ty = (r.height - m.h * view.scale) / 2 - m.y * view.scale;
  $('#zoomLabel').textContent = Math.round(view.scale * 100) + '%';
}
function scenePoint(mx, my) {
  const r = cv.getBoundingClientRect();
  return { x: (mx - r.left - view.tx) / view.scale, y: (my - r.top - view.ty) / view.scale };
}

// ---------- redraw ----------
function redraw() {
  window.fv = fv; window.view = view; window.selected = selected;   // expose for debugging / external inspection
  const dpr = window.devicePixelRatio || 1;
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, cv.width, cv.height);
  if (!fv) return;
  ctx.save();
  ctx.translate(view.tx, view.ty);
  ctx.scale(view.scale, view.scale);
  fv.render(ctx, 0, null);
  ctx.restore();
  // overlays (screen space)
  drawOverlay(hovered, 'rgba(95,214,139,.9)', 1.5);
  if (selected) drawOverlay(selected, '#f2c14e', 2.5);
}
function overlayBox(desc) {
  // desc: {kind:'button',char,name,box} (box is scene-space from buttonBoxes) or {kind:'named',char,name,m}
  if (!fv) return null;
  let x0, y0, x1, y1;
  if (desc.box) {
    // absolute scene-space box already computed by the renderer — transform to screen directly
    x0 = desc.box.x0; y0 = desc.box.y0; x1 = desc.box.x1; y1 = desc.box.y1;
  } else {
    const lb = localBounds(desc.char);
    if (!lb) return null;
    const m = (desc.m || [1, 0, 0, 1, 0, 0]);
    const pts = [[lb.x0, lb.y0], [lb.x1, lb.y0], [lb.x0, lb.y1], [lb.x1, lb.y1]]
      .map(([x, y]) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]]);
    x0 = Math.min(...pts.map(p => p[0])), y0 = Math.min(...pts.map(p => p[1]));
    x1 = Math.max(...pts.map(p => p[0])), y1 = Math.max(...pts.map(p => p[1]));
  }
  return { x: x0 * view.scale + view.tx, y: y0 * view.scale + view.ty, w: (x1 - x0) * view.scale, h: (y1 - y0) * view.scale };
}
function drawOverlay(desc, color, lw) {
  if (!desc) return;
  const b = overlayBox(desc);
  if (!b || b.w <= 0) return;
  ctx.save();
  ctx.strokeStyle = color; ctx.lineWidth = lw; ctx.setLineDash([6, 4]);
  ctx.strokeRect(b.x - 2, b.y - 2, b.w + 4, b.h + 4);
  ctx.restore();
}
function localBounds(charId) {
  const c = fv.characters[charId];
  if (!c) return null;
  if (c.type === 'shape' && c.bounds) return { x0: c.bounds.xMin / 20, y0: c.bounds.yMin / 20, x1: c.bounds.xMax / 20, y1: c.bounds.yMax / 20 };
  if (c.type === 'bitmap') return { x0: 0, y0: 0, x1: c.w, y1: c.h };
  if (c.type === 'text' && c.bounds) return { x0: c.bounds.xMin / 20, y0: c.bounds.yMin / 20, x1: c.bounds.xMax / 20, y1: c.bounds.yMax / 20 };
  if (c.type === 'sprite') { const bb = fv._bboxList(c.frames[0], 0, new Set()); return bb ? { x0: bb.x0, y0: bb.y0, x1: bb.x1, y1: bb.y1 } : null; }
  if (c.type === 'button') { const src = (c.states.hit && c.states.hit.length) ? c.states.hit : (c.states.up || []); const bb = fv._bboxList(src, 0, new Set()); return bb ? { x0: bb.x0, y0: bb.y0, x1: bb.x1, y1: bb.y1 } : null; }
  return null;
}

// ---------- picking ----------
function pickAt(sp) {
  if (!fv) return null;
  const cands = [];
  // buttons via hit boxes
  for (const bb of fv.buttonBoxes(0)) {
    if (sp.x >= bb.x0 && sp.x <= bb.x1 && sp.y >= bb.y0 && sp.y <= bb.y1)
      cands.push({ kind: 'button', char: bb.char, name: bb.name, box: { x0: bb.x0, y0: bb.y0, x1: bb.x1, y1: bb.y1 }, prio: 3 });
  }
  // named placements
  const nl = fv.namedList(0);
  for (let i = 0; i < nl.length; i++) {
    const n = nl[i];
    const lb = localBounds(n.char);
    if (!lb) continue;
    const m = n.m;
    const pts = [[lb.x0, lb.y0], [lb.x1, lb.y0], [lb.x0, lb.y1], [lb.x1, lb.y1]]
      .map(([x, y]) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]]);
    const x0 = Math.min(...pts.map(p => p[0])), y0 = Math.min(...pts.map(p => p[1]));
    const x1 = Math.max(...pts.map(p => p[0])), y1 = Math.max(...pts.map(p => p[1]));
    if (sp.x >= x0 && sp.x <= x1 && sp.y >= y0 && sp.y <= y1) {
      const t = fv.characters[n.char].type;
      cands.push({ kind: 'named', char: n.char, name: n.name, m: n.m, type: t, prio: (t === 'button' ? 3 : t === 'text' ? 2.5 : 1) + i * 0.0001 });
    }
  }
  if (!cands.length) return null;
  // Prefer the element that actually has a mapped handler (e.g. the button) over a decorative
  // label sitting on top of it (e.g. its text field); break ties by type priority then depth.
  const hasHandler = (d) => { const l = d.name; return !!(l && bindingsByLeaf[l] && bindingsByLeaf[l].length); };
  cands.sort((a, b) => (hasHandler(b) - hasHandler(a)) || (b.prio - a.prio));
  return cands[0];
}

// ---------- inspector ----------
function showAssetInspector(key) {
  const classes = classesForKey(key);
  const el = $('#inspector');
  if (!classes.length) {
    el.innerHTML = `<div class="block"><h4>Asset</h4><div class="kv"><span class="k">key</span><span class="v">${esc(key)}</span></div>
      <div class="empty" style="padding:10px 0">No decompiled AS3 class references this asset. It may be a pure art asset or referenced by a generic/data-driven system.</div></div>`;
    return;
  }
  let html = `<div class="block"><h4>Asset</h4><div class="kv"><span class="k">key</span><span class="v">${esc(key)}</span></div></div>`;
  for (const c of classes) {
    const nB = (c.bindings || []).filter(b => b.kind === 'button' || b.kind === 'click').length;
    const nT = (c.textFields || []).length;
    html += `<div class="block"><h4>${esc(c.cls)} ${c.isDDD ? '<span class="tag warn">data-driven</span>' : ''}</h4>
      <div class="kv"><span class="k">extends</span><span class="v">${esc(c.extends || '—')}</span></div>
      <div class="kv"><span class="k">bindings</span><span class="v">${nB} buttons · ${nT} text fields</span></div>
      <a class="src-link" href="/src/${esc(c.file)}" target="_blank">view source ↗</a>
      <div style="margin-top:8px">`;
    for (const b of (c.bindings || []).filter(b => b.kind === 'button' || b.kind === 'click').slice(0, 40)) {
      const inScene = fv && sceneHasLeaf(b.leaf);
      html += `<div class="btn-item"><span class="leaf">${esc(b.leaf)}</span> → <span class="handler">${esc(b.handler || '?')}</span>
        ${inScene ? '<span class="tag ok">in art</span>' : '<span class="tag miss">not in art</span>'}
        <div class="cls">${esc(c.cls)} · line ${b.line}</div></div>`;
    }
    html += `</div></div>`;
  }
  el.innerHTML = html;
}
function sceneHasLeaf(leaf) {
  if (!fv || !leaf) return false;
  const named = fv.namedList(0).map(n => n.name);
  for (const bb of fv.buttonBoxes(0)) if (bb.name === leaf) return true;
  return named.includes(leaf);
}

function showElementInspector(desc) {
  const el = $('#inspector');
  const chars = fv.characters;
  const c = chars[desc.char];
  let html = `<div class="block"><h4>Selected Element</h4>`;
  if (desc.name) html += `<div class="kv"><span class="k">instance name</span><span class="v" style="color:var(--sel)">${esc(desc.name)}</span></div>`;
  html += `<div class="kv"><span class="k">type</span><span class="v">${c ? c.type : 'unknown'}</span></div>`;
  const lb = localBounds(desc.char);
  if (lb) html += `<div class="kv"><span class="k">local bounds</span><span class="v">${Math.round(lb.x1 - lb.x0)}×${Math.round(lb.y1 - lb.y0)}</span></div>`;
  html += `</div>`;

  // MAPPED HANDLERS for this element's instance name — the core verification.
  // Instance names are reused across many dialogs, so lead with the CURRENT asset's own class(es)
  // and demote same-name bindings from other classes (they're collisions, not this dialog's wiring).
  const leaf = desc.name;
  const hits = leaf ? (bindingsByLeaf[leaf] || []) : [];
  const curClasses = new Set((currentKey ? classesForKey(currentKey) : []).map(c => c.cls));
  const mine = hits.filter(h => curClasses.has(h.cls));
  const others = hits.filter(h => !curClasses.has(h.cls));
  html += `<div class="block"><h4>Mapped Handlers (${mine.length + others.length})</h4>`;
  if (!hits.length) {
    html += `<div class="empty" style="padding:8px 0">${leaf ? 'No decompiled handler references <b>' + esc(leaf) + '</b> in any class. This element may be decorative, created dynamically, or its binding uses a different idiom the indexer does not capture.' : 'Unnamed element — instance name is the join key to AS3 code; this one has none.'}</div>`;
  } else {
    const item = (h, tag) => {
      // M4-3: per-mapping copy — copies "<leaf> -> <handler> (<file>:<line>)"
      const copyText = `${leaf} -> ${h.handler || '?'} (${h.file}:${h.line})`;
      return `<div class="btn-item"><span class="handler">${esc(h.handler || '(anonymous)')}</span>
      <span class="tag ${h.kind === 'button' ? 'ok' : 'warn'}">${esc(h.kind)}</span>${tag}
      <button class="copy-btn" title="Copy mapping" data-copy="${esc(copyText)}">⧉ copy</button>
      <div class="cls">${esc(h.cls)} · line ${h.line}</div>
      <a class="src-link" href="/src/${esc(h.file)}#L${h.line}" target="_blank">jump to source ↗</a></div>`;
    };
    if (!mine.length && others.length) {
      html += `<div class="empty" style="padding:6px 0;color:var(--warn)">This dialog's own class does <b>not</b> bind <b>${esc(leaf)}</b>. The handlers below are from other dialogs that reuse this instance name — they are NOT confirmed for this asset. (The binding may live in a base-class method or be wired dynamically.)</div>`;
    }
    for (const h of mine) html += item(h, '<span class="tag ok">this dialog</span>');
    if (others.length) {
      html += `<div style="color:var(--muted);font-size:11px;margin:8px 0 4px;text-transform:uppercase;letter-spacing:.5px">same name in other dialogs (${others.length})</div>`;
      for (const h of others.slice(0, 8)) html += item(h, '');
      if (others.length > 8) html += `<div class="cls" style="padding:4px">…+${others.length - 8} more</div>`;
    }
  }
  html += `</div>`;
  el.innerHTML = html;
}

// ---------- UI bindings ----------
function bindUI() {
  const search = $('#search');
  let t;
  search.addEventListener('input', () => { clearTimeout(t); t = setTimeout(renderAssetList, 120); });
  $('#onlyMapped').addEventListener('change', renderAssetList);

  // zoom buttons
  document.querySelectorAll('#stagebar [data-zoom]').forEach(b => b.onclick = () => {
    const k = b.dataset.zoom;
    if (k === 'fit') fitView();
    else zoomBy(k === 'in' ? 1.2 : 1 / 1.2);
    redraw();
  });
  cv.addEventListener('wheel', (e) => { e.preventDefault(); const f = scenePoint(e.clientX, e.clientY); zoomAt(f.x, f.y, e.deltaY < 0 ? 1.12 : 1 / 1.12); }, { passive: false });

  // pan + pick
  let panning = false, px = 0, py = 0, moved = false;
  cv.addEventListener('mousedown', (e) => { panning = true; moved = false; px = e.clientX; py = e.clientY; });
  window.addEventListener('mousemove', (e) => {
    if (!fv) return;
    if (panning) {
      const dx = e.clientX - px, dy = e.clientY - py;
      if (Math.abs(dx) + Math.abs(dy) > 3) moved = true;
      view.tx += dx; view.ty += dy; px = e.clientX; py = e.clientY; redraw(); return;
    }
    const sp = scenePoint(e.clientX, e.clientY);
    hovered = pickAt(sp);
    cv.style.cursor = hovered ? 'pointer' : 'grab';
    redraw();
  });
  window.addEventListener('mouseup', (e) => {
    if (!panning) return; panning = false;
    if (moved || !fv) return;
    const sp = scenePoint(e.clientX, e.clientY);
    selected = pickAt(sp);
    redraw();
    if (selected) showElementInspector(selected);
  });

  // report modal
  $('#btnReport').onclick = openReport;
  $('#closeReport').onclick = () => $('#reportModal').classList.add('hidden');

  // M4-3: export dispatch.json as a Blob download (no new tab / no server-side file write).
  $('#btnExport').onclick = async () => {
    const btn = $('#btnExport');
    try {
      const r = await fetch('/api/dispatch');
      if (!r.ok) throw new Error('HTTP ' + r.status);
      const blob = await r.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url; a.download = 'dispatch.json';
      document.body.appendChild(a); a.click(); a.remove();
      setTimeout(() => URL.revokeObjectURL(url), 1000);
      setStatus('Exported dispatch.json');
    } catch (e) { setStatus('Export failed: ' + e.message, true); }
  };

  // M4-3: per-mapping copy buttons (delegated — inspector innerHTML is rebuilt on each pick).
  $('#inspector').addEventListener('click', async (e) => {
    const btn = e.target.closest('.copy-btn');
    if (!btn) return;
    const text = btn.dataset.copy || '';
    try {
      await navigator.clipboard.writeText(text);
      const old = btn.textContent; btn.textContent = '✓ copied';
      setTimeout(() => { btn.textContent = old; }, 1200);
    } catch (err) { setStatus('Copy failed: ' + err.message, true); }
  });
}
function zoomAt(sx, sy, factor) {
  const ns = Math.max(0.02, Math.min(40, view.scale * factor));
  const f = ns / view.scale;
  view.tx = sx - (sx - view.tx) * f;
  view.ty = sy - (sy - view.ty) * f;
  view.scale = ns;
  $('#zoomLabel').textContent = Math.round(view.scale * 100) + '%';
}
function zoomBy(factor) { const r = cv.getBoundingClientRect(); zoomAt(r.width / 2, r.height / 2, factor); }

// ---------- report modal ----------
async function openReport() {
  $('#reportModal').classList.remove('hidden');
  $('#reportBody').innerHTML = '<div class="empty">Loading verification report (first run converts every asset with bindings)…</div>';
  try {
    const r = await fetch('/api/report').then(r => r.json());
    renderReport(r);
  } catch (e) { $('#reportBody').innerHTML = `<div class="empty">Error: ${esc(e.message)}</div>`; }
}
function renderReport(r) {
  const stats = `
    <div class="stat-grid">
      <div class="stat"><div class="n">${r.classesWithBindings}</div><div class="l">classes w/ bindings</div></div>
      <div class="stat"><div class="n">${r.classesChecked}</div><div class="l">converted & checked</div></div>
      <div class="stat"><div class="n" style="color:var(--ok)">${r.mappedButtons}</div><div class="l">buttons in art</div></div>
      <div class="stat"><div class="n" style="color:var(--bad)">${r.unmappedButtonsCount}</div><div class="l">unmapped buttons</div></div>
      <div class="stat"><div class="n" style="color:var(--warn)">${r.orphansNotConverted}</div><div class="l">assets not convertible</div></div>
    </div>`;
  let html = stats + `<div class="rep-section"><h4>Buttons with no matching element in the art (top ${r.unmappedButtons.length})</h4>`;
  for (const u of r.unmappedButtons) html += `<div class="rep-item"><span class="cls">${esc(u.cls)}</span> → <span class="miss">${esc(u.leaf)}</span> (${esc(u.handler)}) · ${esc(u.sceneKey)}</div>`;
  html += `</div><div class="rep-section"><h4>Classes whose asset could not be converted (top ${r.orphans.length})</h4>`;
  for (const o of r.orphans) html += `<div class="rep-item"><span class="cls">${esc(o.cls)}</span> · ${esc(o.asset || o.reason)} (${o.bindings} bindings)</div>`;
  html += `</div>`;
  $('#reportBody').innerHTML = html;
}

// ---------- utils ----------
function setStatus(s, isErr) { const el = $('#status'); el.textContent = s; el.style.color = isErr ? 'var(--warn)' : ''; }
function esc(s) { return String(s == null ? '' : s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c])); }

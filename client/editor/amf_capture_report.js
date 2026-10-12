#!/usr/bin/env node
// FV-NG AMF capture report — decodes every record (AMF0 harness + AMF3 live client) via
// amf_capture_lib and aggregates per functionName.
//
//   node amf_capture_report.js [file.jsonl]            summary + per-call breakdown
//   node amf_capture_report.js [file.jsonl] --dump FN  write full req/resp JSON for FN -> captures/<FN>.json
'use strict';
const fs = require('fs');
const path = require('path');
const { readRecords, decodeRecord, bytes } = require('./amf_capture_lib.js');

const file = process.argv[2] && !process.argv[2].startsWith('--') ? process.argv[2] : '/tmp/fvng_amf_capture.jsonl';
const dumpArg = process.argv.indexOf('--dump');
const dumpFn = dumpArg !== -1 ? process.argv[dumpArg + 1] : null;
const records = readRecords(file);
if (!records.length) { console.error('no capture records at ' + file); process.exit(1); }

const stats = new Map();   // fn -> {count, flash, fvng, respBytes:[], keys:Set, samples:[]}
const identities = new Set();
const srcCount = {};
let n = 0, calls = 0, faults = 0, reqErr = 0, respErr = 0;
let tMin = Infinity, tMax = 0;
const dumps = new Map();

for (const rec of records) {
  n++;
  tMin = Math.min(tMin, rec.t); tMax = Math.max(tMax, rec.t);
  const d = decodeRecord(rec);
  if (d.reqErr) reqErr++;
  if (d.fault) faults++;
  if (d.respErr) respErr++;
  srcCount[d.source] = (srcCount[d.source] || 0) + 1;
  if (d.signed) identities.add(d.source + ': uid=' + d.signed.uid + ' token=' + String(d.signed.token).slice(0, 10) + '…');

  d.callList.forEach((c, i) => {
    calls++;
    const fn = c && c.functionName ? c.functionName : '<unknown>';
    if (!stats.has(fn)) stats.set(fn, { count: 0, flash: 0, fvng: 0, respBytes: [], keys: new Set(), samples: [] });
    const st = stats.get(fn);
    st.count++; st[d.source]++;
    const e = d.respEntries[i] || d.respEntries[0];
    if (e && e.data !== undefined) {
      const payload = e.data;
      let size = 0;
      try { size = JSON.stringify(payload).length; } catch (x) {}
      st.respBytes.push(size);
      if (payload && typeof payload === 'object' && !Array.isArray(payload)) Object.keys(payload).forEach(k => st.keys.add(k));
    }
    if (!dumpFn && st.samples.length < 1) st.samples.push({ req: c, resp: e && e.data });
    if (dumpFn === fn) dumps.set(String(dumps.size + 1), { t: rec.t, dt_ms: rec.dt_ms, call: c, response: e && e.data });
  });
}

if (dumpFn) {
  const outDir = path.join(__dirname, 'captures');
  fs.mkdirSync(outDir, { recursive: true });
  const out = path.join(outDir, dumpFn.replace(/[^\w.]/g, '_') + '.json');
  fs.writeFileSync(out, JSON.stringify([...dumps.values()], null, 2));
  console.log('wrote ' + dumps.size + ' call(s) for ' + dumpFn + ' -> ' + out);
  process.exit(0);
}

const span = ((tMax - tMin)).toFixed(1) + 's';
console.log('== FV-NG capture report ==');
console.log('file: ' + file);
console.log('records=' + n + '  calls=' + calls + '  span=' + span + '  gatewayFaults=' + faults + '  reqDecodeErr=' + reqErr + '  respDecodeErr=' + respErr);
console.log('identities: ' + ([...identities].join(' | ') || '(none)'));
console.log('sources: ' + JSON.stringify(srcCount) + '   (flash = AMF3 live client, fvng = AMF0 harness)');
console.log('\n' + 'functionName'.padEnd(36) + 'count'.padStart(6) + 'flash'.padStart(7) + 'fvng'.padStart(6) + '   avgResp   top-level response keys');
console.log('-'.repeat(120));
const rows = [...stats.entries()].sort((a, b) => b[1].count - a[1].count);
for (const [fn, st] of rows) {
  const avg = st.respBytes.length ? Math.round(st.respBytes.reduce((a, b) => a + b, 0) / st.respBytes.length) : 0;
  const keys = [...st.keys].slice(0, 12).join(', ') + (st.keys.size > 12 ? ' … +' + (st.keys.size - 12) : '');
  console.log(String(fn).padEnd(36) + String(st.count).padStart(6) + String(st.flash || 0).padStart(7) + String(st.fvng || 0).padStart(6) + '  ' + bytes(avg).padStart(8) + '   ' + keys);
}
console.log('\n-- sample request params (first call of each function) --');
for (const [fn, st] of rows) {
  const s = st.samples[0];
  if (!s) continue;
  let p = '[]';
  try { p = JSON.stringify(s.req.params); } catch (e) { p = '<unserializable>'; }
  if (p && p.length > 240) p = p.slice(0, 240) + '…';
  console.log(fn.padEnd(30) + ' params=' + p);
}

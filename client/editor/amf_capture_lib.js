'use strict';
// FV-NG — shared AMF decode for capture JSONL. Single source of truth for reading the amfphp hook's
// records: the Flash Remoting envelope, AMF0 request bodies, and the live Flash client's AMF3 values
// embedded in AMF0 (0x11 marker). Used by amf_capture_report.js and tools/conv_capture.js.
const fs = require('fs');
const path = require('path');
const { parseResponse, A3Reader } = require(path.join(__dirname, '..', 'net', 'amf3.js'));

const dec = new TextDecoder();
function utf8(u, o, l) { return dec.decode(u.subarray(o, o + l)); }
function readUTF(u, s) { const l = (u[s.p] << 8) | u[s.p + 1]; s.p += 2; const v = utf8(u, s.p, l); s.p += l; return v; }
function readPairs(u, s, ctx) { // AMF0 object / mixed-array body: raw-utf8 key + typed value, until empty key + 0x09
  const o = {};
  let k = readUTF(u, s);
  while (k !== '') { o[k] = readAMF0(u, s, ctx); k = readUTF(u, s); }
  s.p++; // trailing 0x09
  return o;
}
function readAMF0(u, s, ctx) {
  const t = u[s.p++];
  switch (t) {
    case 0x00: { const v = new DataView(u.buffer, u.byteOffset).getFloat64(s.p); s.p += 8; return v; }
    case 0x01: return u[s.p++] === 1;
    case 0x02: return readUTF(u, s);
    case 0x03: return readPairs(u, s, ctx);
    case 0x05: return null;
    case 0x06: return undefined;
    case 0x08: s.p += 4; return readPairs(u, s, ctx);   // mixed array: skip count, keyed pairs
    case 0x0a: { const n = (u[s.p] << 24) | (u[s.p + 1] << 16) | (u[s.p + 2] << 8) | u[s.p + 3]; s.p += 4; const a = []; for (let i = 0; i < n; i++) a.push(readAMF0(u, s, ctx)); return a; }
    case 0x0b: { const v = new DataView(u.buffer, u.byteOffset).getFloat64(s.p); s.p += 10; return new Date(v); }
    case 0x0c: { const n = (u[s.p] << 24) | (u[s.p + 1] << 16) | (u[s.p + 2] << 8) | u[s.p + 3]; s.p += 4; const v = utf8(u, s.p, n); s.p += n; return v; }
    case 0x10: { readUTF(u, s); return readPairs(u, s, ctx); } // typed object: skip class name
    case 0x11: { // AMF3 value embedded in AMF0 (live Flash client, objectEncoding=AMF3)
      if (!ctx || !ctx.a3) throw new Error('AMF3 value without context @' + s.p);
      ctx.sawAMF3 = true;
      ctx.a3.p = s.p - ctx.base;   // sync the shared AMF3 reader (shares string/object tables)
      const v = ctx.a3.data();
      s.p = ctx.base + ctx.a3.p;
      return v;
    }
    default: throw new Error('AMF0 type 0x' + t.toString(16) + ' @' + s.p);
  }
}
// Flash Remoting envelope -> [{ target, response, body, amf3 }]
function parseRequest(buf) {
  const u = new Uint8Array(buf);
  const s = { p: 0 };
  s.p += 2;                          // version [0x00,0x03]
  const headerCount = (u[s.p] << 8) | u[s.p + 1]; s.p += 2;
  for (let i = 0; i < headerCount; i++) { readUTF(u, s); u[s.p++]; s.p += 4; readAMF0(u, s, null); }
  const msgCount = (u[s.p] << 8) | u[s.p + 1]; s.p += 2;
  const msgs = [];
  for (let i = 0; i < msgCount; i++) {
    const target = readUTF(u, s), response = readUTF(u, s);  // raw length-prefixed utf8, no type tag
    s.p += 4;                                                // message body length (u32)
    const ctx = { base: s.p, a3: new A3Reader(u.subarray(s.p)), sawAMF3: false };
    const body = readAMF0(u, s, ctx);
    msgs.push({ target, response, body, amf3: ctx.sawAMF3 });
  }
  return msgs;
}

function readRecords(file) {
  if (!fs.existsSync(file)) return [];
  return fs.readFileSync(file, 'utf8').split('\n').filter(l => l.trim()).map(line => {
    let rec; try { rec = JSON.parse(line); } catch (e) { return null; }
    return { t: rec.t, dt_ms: rec.dt_ms, req: Buffer.from(rec.req_b64 || '', 'base64'), resp: Buffer.from(rec.resp_b64 || '', 'base64') };
  }).filter(Boolean);
}

// One record -> decoded request identity + batched calls + response entries.
function decodeRecord(rec) {
  const out = { source: 'fvng', signed: null, callList: [], respEntries: [], fault: false, reqErr: false, respErr: false };
  try {
    const msgs = parseRequest(rec.req);
    out.source = msgs[0] && msgs[0].amf3 ? 'flash' : 'fvng';
    const body = msgs[0] && msgs[0].body;
    out.signed = Array.isArray(body) ? body[0] : null;
    const batch = Array.isArray(body) ? body[1] : null;
    if (Array.isArray(batch)) out.callList = batch;
  } catch (e) { out.reqErr = true; }
  if (rec.resp.length) {
    try {
      const parsed = parseResponse(rec.resp);
      const m = parsed[0];
      if (!m || m.target === '__gateway') out.fault = true;
      else { const d = m.data || {}; out.respEntries = Array.isArray(d.data) ? d.data : [d.data]; }
    } catch (e) { out.respErr = true; }
  }
  return out;
}

function bytes(n) { return n < 1024 ? n + 'B' : (n / 1024).toFixed(1) + 'KB'; }

module.exports = { parseRequest, decodeRecord, readRecords, parseResponse, bytes, A3Reader };

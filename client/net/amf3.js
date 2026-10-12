#!/usr/bin/env node
/**
 * FV-NG — AMF3-over-HTTP client (Phase 2, workstream A)
 * Speaks the Flash Remoting envelope that amfphp expects:
 *   [0x00][0x03] msgCount(2B BE)=1
 *     targetUri(UTF16) response(UTF16) len(4B BE)
 *     body = AMF0 mixed array of the 3 call args for FlashService.dispatchBatch:
 *       [ signedParams, batchedCallInfo[], retryCount ]
 * Response: same envelope; message data is a single AMF0 value (the result object).
 */
'use strict';

// ---------- AMF0 writer ----------
class AWriter {
  constructor() { this.b = []; }
  byte(v) { this.b.push(v & 0xff); return this; }
  int16(v) { this.b.push((v >> 8) & 0xff, v & 0xff); return this; }
  int32(v) { this.b.push((v >>> 24) & 0xff, (v >>> 16) & 0xff, (v >>> 8) & 0xff, v & 0xff); return this; }
  utf16(s) { const buf = Buffer.from(String(s ?? ''), 'utf8'); this.int16(buf.length); this.b.push(...buf); return this; }
  double(v) { const b = Buffer.alloc(8); b.writeDoubleBE(Number(v)); this.b.push(...b); return this; }
  value(v) {
    if (v === null || v === undefined) return this.byte(0x05);
    if (typeof v === 'boolean') return this.byte(0x01).byte(v ? 1 : 0);
    if (typeof v === 'number') return this.byte(0x00).double(v);
    if (typeof v === 'string') return this.byte(0x02).utf16(v);
    if (Array.isArray(v)) { // AMF0 strict array: type 0x0A, count u32, then values
      this.byte(0x0a).int32(v.length);
      for (const e of v) this.value(e);
      return this;
    }
    if (v instanceof Date) { const b = Buffer.alloc(12); b.writeDoubleBE(v.getTime()); b.writeInt32BE(0, 8); this.byte(0x0b); this.b.push(...b); return this; }
    if (typeof v === 'object') { // AMF0 object: type 0x03, key/value pairs, terminator = empty key (00 00) + ObjectEnd (09)
      this.byte(0x03);
      for (const [k, val] of Object.entries(v)) { this.utf16(k); this.value(val); }
      this.int16(0).byte(0x09); // empty property name, then 0x09 end marker
      return this;
    }
    throw new Error('AMF0: unsupported type ' + typeof v);
  }
  buffer() { return Buffer.from(this.b); }
}

// ---------- shared byte-view helpers (work on Node Buffer AND browser shim) ----------
function _u8(b) { return b && b.u8 ? b.u8 : (b instanceof Uint8Array ? b : new Uint8Array(b.buffer || b)); }
const _dec = typeof TextDecoder !== 'undefined' ? new TextDecoder() : null;
function _utf(u, off, len) { const s = u.subarray(off, off + len); return _dec ? _dec.decode(s) : Buffer.from(s).toString('utf8'); }

// ---------- AMF0 reader ----------
class AReader {
  constructor(buf) { this.u = _u8(buf); this.dv = new DataView(this.u.buffer, this.u.byteOffset, this.u.byteLength); this.p = 0; }
  byte() { return this.u[this.p++]; }
  int16() { const v = this.dv.getInt16(this.p); this.p += 2; return v >>> 0; }
  int32() { const v = this.dv.getInt32(this.p); this.p += 4; return v; }
  utf16() { const len = this.int16(); const s = _utf(this.u, this.p, len); this.p += len; return s; }
  value() {
    const t = this.byte();
    switch (t) {
      case 0x00: { const v = this.dv.getFloat64(this.p); this.p += 8; return v; }
      case 0x01: return this.byte() === 1;
      case 0x02: return this.utf16();
      case 0x03: { // object — read key, then loop on type byte (amfphp style)
        const o = {};
        let k = this.utf16();
        for (let t = this.byte(); t !== 0x09; t = this.byte()) { o[k] = this.value(); k = this.utf16(); }
        return o;
      }
      case 0x05: return null;
      case 0x06: return undefined;
      case 0x07: { const ref = this.int16(); throw new Error('AMF0 circular ref ' + ref); }
      case 0x08: { this.p += 4; // mixed array: skip count
        const o = {};
        let k = this.utf16();
        for (let t = this.byte(); t !== 0x09; t = this.byte()) { o[k] = this.value(); k = this.utf16(); }
        return o;
      }
      case 0x09: { const z = this.int16(); if (z !== 0) throw new Error('bad obj terminator'); return null; }
      case 0x0a: { const n = this.int32(); const a = []; for (let i = 0; i < n; i++) a.push(this.value()); return a; }
      case 0x0b: { const ms = this.dv.getFloat64(this.p); this.p += 12; return new Date(ms); }
      case 0x0c: { const len = this.int32(); const s = _utf(this.u, this.p, len); this.p += len; return s; }
      case 0x0d: throw new Error('AMF0 typedef not supported');
      case 0x0f: { const len = this.int32(); const s = _utf(this.u, this.p, len); this.p += len; return s; }
      case 0x10: { // custom class
        const cls = this.utf16(); const o = { __class: cls };
        let k = this.utf16();
        for (let t = this.byte(); t !== 0x09; t = this.byte()) { o[k] = this.value(); k = this.utf16(); }
        return o;
      }
      default: throw new Error('AMF0 unknown type 0x' + t.toString(16));
    }
  }
}

// ---------- AMF3 reader (amfphp serializes response bodies in AMF3) ----------
class A3Reader {
  constructor(buf) { this.u = _u8(buf); this.dv = new DataView(this.u.buffer, this.u.byteOffset, this.u.byteLength); this.p = 0; this.strings = []; this.objects = []; }
  byte() { return this.u[this.p++]; }
  u29() { // AMF3 U29 int — matches amfphp getAmf3Int, which writes NON-spec varints:
          // NO continuation bits; the number of bytes is determined by magnitude.
          const b0 = this.byte();
          if (b0 < 0x80) return b0;                       // 1 byte
          const b1 = this.byte();                          // 2 bytes (< 2^14)
          if (b1 < 0x80) return ((b0 & 0x7f) << 7) | b1;
          const b2 = this.byte();                          // 3 bytes (< 2^21)
          if (b2 < 0x80) return ((b0 & 0x7f) << 14) | ((b1 & 0x7f) << 7) | b2;
          const b3 = this.byte();                          // 4 bytes
          return ((b0 & 0x7f) << 21) | ((b1 & 0x7f) << 14) | ((b2 & 0x7f) << 7) | b3;
        }
  double() { const v = this.dv.getFloat64(this.p); this.p += 8; return v; } // amfphp writes BE on this host (verified)
  str() { // AMF3 string: u29 handle. low bit set ⇒ inline (len=handle>>1); else reference
    const h = this.u29();
    if ((h & 1) === 0) return this.strings[h >> 1];
    const len = h >> 1;
    if (len === 0) return '';
    const s = _utf(this.u, this.p, len); this.p += len;
    this.strings.push(s);
    return s;
  }
  data() { // one AMF3 value (marker already consumed by caller of readAmf3Data)
    const t = this.byte();
    switch (t) {
      case 0x00: return undefined;
      case 0x01: return null;
      case 0x02: return false;
      case 0x03: return true;
      case 0x04: return this.u29(); // int (non-negative in our payloads)
      case 0x05: return this.double();
      case 0x06: return this.str();
      case 0x08: { const h = this.u29(); if ((h & 1) === 0) return new Date(this.objects[h >> 1]); const ms = this.double(); const d = new Date(ms); this.objects.push(d); return d; }
      case 0x09: { // array
        const h = this.u29();
        if ((h & 1) === 0) return this.objects[h >> 1];
        const count = h >> 1;
        const o = {}; this.objects.push(o);
        for (let k = this.str(); k !== ''; k = this.str()) o[k] = this.data(); // hash part
        for (let i = 0; i < count; i++) o[i] = this.data();                     // dense part
        return Array.isArray(this._maybeArray(o, count)) ? this._maybeArray(o, count) : o;
      }
      case 0x0a: { // object
        const h = this.u29();
        if ((h & 1) === 0) return this.objects[h >> 1]; // reference
        let handle = h >> 1;
        const inlineClassDef = (handle & 1) !== 0; handle >>= 1;
        let members, dynamic;
        if (inlineClassDef) {
          const cls = this.str();
          let f = handle;
          const externalizable = (f & 1) !== 0; f >>= 1;
          dynamic = (f & 1) !== 0; f >>= 1;
          const n = f;
          members = []; for (let i = 0; i < n; i++) members.push(this.str());
          if (externalizable) { // externalized: single data value
            const o = {}; this.objects.push(o); return o;
          }
        } else {
          // reference to a prior class def — not emitted by amfphp for anonymous objects, but handle gracefully
          members = []; dynamic = true;
        }
        const o = {}; this.objects.push(o);
        for (let i = 0; i < members.length; i++) o[members[i]] = this.data();
        if (dynamic) { for (let k = this.str(); k !== ''; k = this.str()) o[k] = this.data(); }
        return o;
      }
      default: throw new Error('AMF3 unknown type 0x' + t.toString(16));
    }
  }
  _maybeArray(o, count) { // if dense numeric-only, present as JS array
    const keys = Object.keys(o);
    if (keys.length === count && keys.every((k, i) => k === String(i))) {
      return Array.from({ length: count }, (_, i) => o[i]);
    }
    return o;
  }
}

// ---------- packet envelope (Flash Remoting) ----------
function buildRequest(targetUri, argsArray) {
  // The message body is ONE value: the call-argument list. amfphp's readArray (AMF0
  // strict array, type 0x0a) yields a positional PHP array that ServiceRouter splats via
  // call_user_func_array — exactly what FlashService.dispatchBatch($userData,$reqData,$params3) needs.
  const body = new AWriter();
  body.byte(0x0a).int32(argsArray.length); // strict array: count, then values
  for (const a of argsArray) body.value(a);
  const bodyBuf = body.buffer();

  const out = new AWriter();
  out.byte(0x00).byte(0x03);           // version marker (amfphp accepts 0 or 3; 3 ⇒ AMF3-capable)
  out.int16(0);                        // header count
  out.int16(1);                        // message count
  out.utf16(targetUri);                // e.g. "FlashService.dispatchBatch"
  out.utf16('');                       // response target
  out.int32(bodyBuf.length);           // message length (amfphp skips it)
  out.b.push(...bodyBuf);
  return out.buffer();
}

function parseResponse(buf) {
  const r = new AReader(buf);
  const top = r.byte(), second = r.byte();
  if (!(top === 0 || top === 3)) throw new Error('bad packet version ' + top);
  const headerCount = r.int16();
  for (let i = 0; i < headerCount; i++) {
    r.utf16(); r.byte(); r.p += 4;     // name, mustUnderstand, length
    r.value();                          // content
  }
  const msgCount = r.int16();
  const results = [];
  for (let i = 0; i < msgCount; i++) {
    const target = r.utf16(), response = r.utf16();
    r.p += 4;                           // length
    const marker = r.byte();            // body type marker
    let data;
    if (marker === 0x11) {              // AMF3-encoded body (amfphp default when request byte1==3)
      const a3 = new A3Reader(buf.subarray ? buf.subarray(r.p) : buf.u8.slice(r.p));
      data = a3.data();
      r.p = buf.length - (a3.u.length - a3.p); // sync outer cursor past the AMF3 value
    } else {
      r.p--;                            // re-read marker as AMF0 type byte
      data = r.value();
    }
    results.push({ target, response, data });
  }
  return results;
}

// ---------- connection ----------
class FVConnection {
  constructor(baseUrl, identity) {
    this.baseUrl = baseUrl.replace(/\/$/, '');   // e.g. http://localhost/farmville
    this.identity = identity || {};              // { masterId, uid, token, ... }
    this.seq = 0;
    this.serverTime = Math.floor(Date.now() / 1000);
  }

  /** Call one logical Service.method (batched alone). Resolves to the entry's `data`. */
  async call(functionName, params) {
    const seq = ++this.seq;
    const signedParams = Object.assign({}, this.identity, {
      flashRevision: '855037', configRevision: '855026', phpRevision: '1',
    });
    const batchedCallInfo = [{
      functionName,
      params: params || [],
      sequence: seq,
      sequenceID: String(seq),
    }];
    const payload = buildRequest('FlashService.dispatchBatch', [signedParams, batchedCallInfo, 0]);

    const res = await fetch(this.baseUrl + '/flashservices/gateway.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/octet-stream' },
      // send raw bytes (Node Buffer or browser shim) as a native ArrayBuffer so fetch serializes it verbatim
      body: payload.u8 ? payload.u8.buffer.slice(payload.u8.byteOffset, payload.u8.byteOffset + payload.u8.length) : payload,
    });
    if (!res.ok) throw new Error('gateway HTTP ' + res.status);
    const buf = Buffer.from(await res.arrayBuffer());

    let parsed;
    try {
      parsed = parseResponse(buf);
    } catch (e) {
      // gateway returned HTML (error page) — surface it
      const head = buf.slice(0, 400).toString('utf8');
      const diag = 'len=' + buf.length + ' isBufferShim=' + (typeof Buffer !== 'undefined' && !Buffer.isBuffer) + ' first16hex=' + (buf.slice(0,16).toString('hex'));
      throw new Error('AMF parse failed: ' + e.message + ' | ' + diag + '\nbody head: ' + head);
    }
    if (!parsed.length || parsed[0].target === '__gateway') {
      // amfphp fault message
      const f = parsed[0] && parsed[0].data;
      throw new Error('gateway fault: ' + JSON.stringify(f));
    }
    const result = parsed[0].data;
    if (result && typeof result === 'object' && 'serverTime' in result) this.serverTime = result.serverTime;
    if (!result || result.errorType !== 0) {
      throw new Error(functionName + ' errorType=' + (result && result.errorType) + ' ' + JSON.stringify(result && result.errorData));
    }
    const entry = Array.isArray(result.data) ? result.data[0] : result.data;
    if (!entry || entry.errorType !== 0) {
      throw new Error(functionName + ' entry error: ' + JSON.stringify(entry));
    }
    return entry.data;
  }
}

module.exports = { FVConnection, buildRequest, parseResponse, AReader, A3Reader };

// ---------- CLI test harness ----------
if (require.main === module) {
  const baseUrl = process.env.FV_BASE_URL || 'http://localhost/farmville';
  const uid = process.env.FV_UID || '1111111111';
  const conn = new FVConnection(baseUrl, { masterId: uid, uid, token: 'test-token', sigTime: Math.floor(Date.now() / 1000) });

  (async () => {
    console.log('== getBalance ==');
    try {
      const bal = await conn.call('UserService.getBalance', []);
      console.log(JSON.stringify(bal, null, 2));
    } catch (e) { console.error('FAIL:', e.message); process.exitCode = 1; }

    console.log('== initUser ==');
    try {
      const u = await conn.call('UserService.initUser', ['Tester', -420, true, false, 'flashControllerInit']);
      console.log('initUser ok. keys:', Object.keys(u || {}).slice(0, 25).join(', '));
      if (u) {
        const pick = {};
        for (const k of ['energy', 'credits', 'gold', 'cash', 'level', 'xp', 'currentWorldType']) if (k in u) pick[k] = u[k];
        console.log('player fields:', JSON.stringify(pick));
      }
    } catch (e) { console.error('FAIL:', e.message); process.exitCode = 1; }

    console.log('== loadOwnWorld ==');
    try {
      const w = await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]);
      console.log('loadOwnWorld ok. top keys:', Object.keys(w || {}).join(', '));
      if (w && w.world) {
        console.log('world keys:', Object.keys(w.world).slice(0, 30).join(', '));
        console.log('sizeX/Y:', w.world.sizeX + 'x' + w.world.sizeY, ' type:', w.world.type);
        const oa = w.world.objectsArray;
        if (oa) {
          const arr = Array.isArray(oa) ? oa : Object.values(oa);
          console.log('objectsArray count:', arr.length);
          if (arr[0]) console.log('first object keys:', Object.keys(arr[0]).join(', '));
          if (arr[0]) console.log('sample object:', JSON.stringify(arr[0]).slice(0, 300));
        }
      }
    } catch (e) { console.error('FAIL:', e.message); process.exitCode = 1; }

    console.log('== serverTime sync check ==');
    console.log('conn.serverTime =', conn.serverTime, '(unix), now =', Math.floor(Date.now()/1000));

    console.log('== postInit ==');
    try {
      const p = await conn.call('UserService.postInit', []);
      console.log('postInit ok. keys:', Object.keys(p || {}).slice(0, 25).join(', '));
    } catch (e) { console.error('FAIL:', e.message); process.exitCode = 1; }

    console.log('DONE');
  })();
}

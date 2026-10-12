#!/usr/bin/env node
// FV-NG AMF capture decoder — reads the JSONL produced by the amfphp/index.php hook and renders
// every captured request/response pair as functionName -> payload, using the real parseResponse()
// from client/net/amf3.js for the response side. The request side (AMF0 strict array of 3 args) is
// scanned for `functionName` string values to label each batched call without a full AMF0 decoder.
//
// Usage:
//   node amf_capture_decode.js                 # decode /tmp/fvng_amf_capture.jsonl
//   node amf_capture_decode.js <file.jsonl>    # decode a specific capture file
//   FVNG_AMF_CAPTURE_LOG=/path/node ...        # (log path is set on the PHP side)
// Turn capture on/off (truncates the log so each session is clean):
//   node amf_capture.js on | off | status
'use strict';
const fs = require('fs');
const path = require('path');
const { parseResponse } = require(path.join(__dirname, '..', 'net', 'amf3.js'));

const file = process.argv[2] || '/tmp/fvng_amf_capture.jsonl';
if (!fs.existsSync(file)) { console.log('no capture file at ' + file + ' (is the marker /tmp/fvng_amf_capture present and has traffic flowed?)'); process.exit(0); }

// Extract short ASCII string values that follow a `functionName` key inside an AMF0 body.
// AMF0 string = 0x02 int16(len) utf8 — these are short, so we look for the literal key then the
// nearest following 0x02-len-utf8 token. Good enough to label calls; not a full decoder.
function extractFunctionNames(buf) {
  const out = [];
  const keyIdx = [];
  const key = Buffer.from('functionName', 'latin1');
  let i = 0;
  while ((i = buf.indexOf(key, i)) !== -1) { keyIdx.push(i); i += key.length; }
  for (const k of keyIdx) {
    // after the key bytes there is the ':' separator in AMF0 object form; scan forward a bit for a 0x02 string marker
    const window = buf.subarray(k + key.length, k + key.length + 12);
    for (let j = 0; j < window.length - 3; j++) {
      if (window[j] === 0x02) {
        const len = window.readUInt16BE(j + 1);
        if (len > 0 && len <= 80 && j + 3 + len <= window.length + 40) {
          const s = buf.subarray(k + key.length + j + 3, k + key.length + j + 3 + len).toString('utf8');
          if (/^[A-Za-z_][\w.]*$/.test(s)) { out.push(s); break; }
        }
      }
    }
  }
  return out;
}

const lines = fs.readFileSync(file, 'utf8').split('\n').filter(l => l.trim());
console.log('== FV-NG AMF capture: ' + lines.length + ' record(s) from ' + file + ' ==\n');
let okCount = 0, errCount = 0;
for (const line of lines) {
  let rec; try { rec = JSON.parse(line); } catch (e) { continue; }
  const req = Buffer.from(rec.req_b64 || '', 'base64');
  const resp = Buffer.from(rec.resp_b64 || '', 'base64');
  const fns = extractFunctionNames(req);
  console.log('--- t=' + rec.t + '  dt=' + (rec.dt_ms != null ? rec.dt_ms + 'ms' : '?') + '  req=' + req.length + 'B resp=' + resp.length + 'B');
  if (fns.length) console.log('    call: ' + fns.join(', '));
  if (!resp.length) {
    console.log('    *** EMPTY RESPONSE BODY — the capture hook dropped the response (regression: ob_end_clean instead of ob_end_flush) ***');
    errCount++;
    continue;
  }
  try {
    const parsed = parseResponse(resp);
    for (const m of parsed) {
      if (m.target === '__gateway') { console.log('    GATEWAY FAULT: ' + JSON.stringify(m.data).slice(0, 300)); errCount++; continue; }
      const d = m.data || {};
      const entries = Array.isArray(d.data) ? d.data : [d.data];
      for (const e of entries) {
        if (!e) { console.log('    entry: <null>'); continue; }
        const payload = e.data;
        const size = JSON.stringify(payload).length;
        console.log('    result seq=' + (e.sequenceNumber != null ? e.sequenceNumber : '?') + ' errorType=' + e.errorType + '  payload=' + size + 'B');
        // show a compact preview of the payload shape (top-level keys)
        if (payload && typeof payload === 'object' && !Array.isArray(payload)) {
          const keys = Object.keys(payload);
          console.log('      keys: ' + keys.slice(0, 24).join(', ') + (keys.length > 24 ? ' … +' + (keys.length - 24) : ''));
        } else if (Array.isArray(payload)) {
          console.log('      array len=' + payload.length);
        } else {
          console.log('      scalar: ' + String(payload).slice(0, 120));
        }
        okCount++;
      }
    }
  } catch (e) {
    const head = resp.slice(0, 160).toString('utf8');
    console.log('    [decode error] ' + e.message + ' | head: ' + JSON.stringify(head));
    errCount++;
  }
}
console.log('\n== summary: ' + okCount + ' payload(s) decoded, ' + errCount + ' fault/error ==');

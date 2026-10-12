#!/usr/bin/env node
// FV-NG AMF capture toggle — controls the marker file that gates the amfphp/index.php hook and
// truncates the JSONL so each capture session is clean.
//
//   node amf_capture.js on       create marker, truncate the log  (start a fresh capture)
//   node amf_capture.js off      remove marker                   (hook becomes a no-op)
//   node amf_capture.js status   show marker/log state + record count
//
// Paths default to the PHP hook's defaults on this host:
//   Windows:  C:\tmp\fvng_amf_capture  and  C:\tmp\fvng_amf_capture.jsonl
//   POSIX:    /tmp/fvng_amf_capture    and  /tmp/fvng_amf_capture.jsonl
// Override with FVNG_AMF_CAPTURE_FILE / FVNG_AMF_CAPTURE_LOG (must match the PHP env).
'use strict';
const fs = require('fs');
const path = require('path');

const isWin = process.platform === 'win32';
const DEF_MARKER = isWin ? 'C:\\tmp\\fvng_amf_capture' : '/tmp/fvng_amf_capture';
const DEF_LOG = isWin ? 'C:\\tmp\\fvng_amf_capture.jsonl' : '/tmp/fvng_amf_capture.jsonl';
const marker = process.env.FVNG_AMF_CAPTURE_FILE || DEF_MARKER;
const log = process.env.FVNG_AMF_CAPTURE_LOG || DEF_LOG;

const cmd = (process.argv[2] || 'status').toLowerCase();

function ensureDir(f) { fs.mkdirSync(path.dirname(f), { recursive: true }); }
function countRecords(f) {
  if (!fs.existsSync(f)) return 0;
  const s = fs.readFileSync(f, 'utf8');
  let n = 0;
  for (const line of s.split('\n')) if (line.trim()) n++;
  return n;
}

switch (cmd) {
  case 'on': {
    ensureDir(marker);
    ensureDir(log);
    fs.writeFileSync(log, '');
    fs.writeFileSync(marker, new Date().toISOString() + '\n');
    console.log('capture ON (log truncated)\n  marker: ' + marker + '\n  log:    ' + log);
    break;
  }
  case 'off': {
    if (fs.existsSync(marker)) fs.unlinkSync(marker);
    console.log('capture OFF\n  marker: ' + marker + ' (removed)');
    break;
  }
  case 'status': {
    const on = fs.existsSync(marker);
    const recs = countRecords(log);
    console.log('capture ' + (on ? 'ON' : 'OFF'));
    console.log('  marker: ' + marker + (on ? '  [' + fs.readFileSync(marker, 'utf8').trim() + ']' : ''));
    console.log('  log:    ' + log + '  ' + (fs.existsSync(log) ? '(' + recs + ' records)' : '(missing)'));
    break;
  }
  default:
    console.error('usage: node amf_capture.js on|off|status');
    process.exit(2);
}

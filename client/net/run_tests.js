#!/usr/bin/env node
/**
 * FV-NG — automated regression harness (Phase C2).
 *
 * Three layers:
 *   A. Encoder golden  — buildRequest() output bytes are locked against committed vectors
 *                        (guards the non-spec amfphp wire shape: strict-array body etc.).
 *   B. Decoder fixtures — captured real gateway response bytes are decoded and shape-asserted
 *                        (guards the non-spec AMF3 int table + big-endian doubles).
 *   C. Live farm loop   — boot -> plow -> plant -> grow -> harvest -> clear against the running
 *                        gateway, asserting world state and the credit economy (--live).
 *
 * Usage:
 *   node net/run_tests.js            # offline (A + B only)
 *   node net/run_tests.js --live     # offline + live farm loop (requires Apache/gateway)
 *   node net/run_tests.js --record   # capture/refresh golden fixtures from the live gateway
 *
 * Exit code: 0 all pass, 1 assertion failure, 2 harness/environment error.
 */
'use strict';

const fs = require('fs');
const path = require('path');
const { FVConnection, buildRequest, parseResponse } = require('./amf3.js');

const FIXDIR = path.join(__dirname, 'fixtures');
const BASE = process.env.FV_BASE_URL || 'http://localhost/farmville';
const UID = process.env.FV_UID || '1111111111';
const args = process.argv.slice(2);
const RECORD = args.includes('--record');
const LIVE = args.includes('--live') || RECORD;

// ---------- tiny test framework ----------
let passed = 0;
const failures = [];
function ok(name, cond, detail) {
  if (cond) { passed++; console.log('  PASS  ' + name); }
  else { failures.push(name + (detail ? '  [' + detail + ']' : '')); console.log('  FAIL  ' + name + (detail ? '  [' + detail + ']' : '')); }
}
function eq(name, actual, expected) { ok(name, actual === expected, 'got ' + JSON.stringify(actual) + ' want ' + JSON.stringify(expected)); }
function section(t) { console.log('\n== ' + t + ' =='); }

function readFixture(name) {
  const p = path.join(FIXDIR, name);
  if (!fs.existsSync(p)) return null;
  return fs.readFileSync(p, 'utf8').trim();
}

// Raw request/response capture (mirrors FVConnection.call but returns the unparsed buffer).
async function rawCall(functionName, params, identity) {
  const signedParams = Object.assign({}, identity, { flashRevision: '855037', configRevision: '855026', phpRevision: '1' });
  const batchedCallInfo = [{ functionName, params: params || [], sequence: 1, sequenceID: '1' }];
  const payload = buildRequest('FlashService.dispatchBatch', [signedParams, batchedCallInfo, 0]);
  const res = await fetch(BASE + '/flashservices/gateway.php', {
    method: 'POST', headers: { 'Content-Type': 'application/octet-stream' },
    body: payload.buffer.slice(payload.byteOffset, payload.byteOffset + payload.byteLength),
  });
  return Buffer.from(await res.arrayBuffer());
}

// ---------- A. encoder golden ----------
function encodeCases() {
  const identity = { masterId: '1111111111', uid: '1111111111', token: 'fvng', sigTime: 1700000000 };
  const mk = (fn, params, seq) => [Object.assign({}, identity, { flashRevision: '855037', configRevision: '855026', phpRevision: '1' }),
    [{ functionName: fn, params, sequence: seq, sequenceID: String(seq) }], 0];
  return [
    { name: 'getBalance', args: mk('UserService.getBalance', [], 1) },
    { name: 'initUser', args: mk('UserService.initUser', ['Farmer', -420, true, false, 'flashControllerInit'], 2) },
    { name: 'plant', args: mk('EquipmentWorldService.onUseEquipment', ['place', { id: -1, key: 'EP:1' }, { 63001: { position: { x: 3, y: 4, z: 0 } } }, 'wheat'], 3) },
    { name: 'harvest', args: mk('WorldService.performAction', ['harvest', { id: 7, className: 'Plot', deleted: false }], 4) },
  ];
}

function runEncoderTests() {
  section('A. Encoder golden (non-spec amfphp wire shape)');
  const golden = readFixture('encode.json');
  if (RECORD) {
    const out = {};
    for (const c of encodeCases()) out[c.name] = buildRequest('FlashService.dispatchBatch', c.args).toString('hex');
    fs.mkdirSync(FIXDIR, { recursive: true });
    fs.writeFileSync(path.join(FIXDIR, 'encode.json'), JSON.stringify(out, null, 2) + '\n');
    console.log('  recorded ' + Object.keys(out).length + ' encoder vectors -> fixtures/encode.json');
    return;
  }
  if (!golden) { ok('encoder fixtures present', false, 'run: node net/run_tests.js --record'); return; }
  const want = JSON.parse(golden);
  for (const c of encodeCases()) {
    const got = buildRequest('FlashService.dispatchBatch', c.args).toString('hex');
    ok('encode ' + c.name, want[c.name] === got, want[c.name] === got ? '' : 'bytes differ from golden');
  }
}

// ---------- B. decoder fixtures ----------
function runDecoderTests() {
  section('B. Decoder fixtures (captured gateway responses)');
  const names = ['getBalance', 'loadOwnWorld'];
  for (const n of names) {
    const hex = readFixture(n + '.hex');
    if (RECORD) {
      // captured in recordResponseFixtures()
      continue;
    }
    if (!hex) { ok('fixture ' + n, false, 'missing fixtures/' + n + '.hex — run --record'); continue; }
    let parsed;
    try { parsed = parseResponse(Buffer.from(hex, 'hex')); }
    catch (e) { ok('decode ' + n, false, e.message); continue; }
    const result = parsed[0] && parsed[0].data;
    ok('decode ' + n + ' envelope', !!result && typeof result === 'object' && result.errorType === 0, JSON.stringify(result && result.errorType));
    const entry = result && Array.isArray(result.data) ? result.data[0] : result && result.data;
    ok('decode ' + n + ' entry ok', !!entry && entry.errorType === 0);
    if (n === 'getBalance') {
      ok('decode getBalance has gold', entry && entry.data && typeof entry.data.gold === 'number');
    } else {
      const w = entry && entry.data && entry.data.world;
      ok('decode loadOwnWorld has sizeX/sizeY/objectsArray', !!w && typeof w.sizeX === 'number' && typeof w.sizeY === 'number' && w.objectsArray != null);
    }
  }
}

async function recordResponseFixtures(conn) {
  fs.mkdirSync(FIXDIR, { recursive: true });
  for (const [label, fn, params] of [
    ['getBalance', 'UserService.getBalance', []],
    ['loadOwnWorld', 'WorldService.loadOwnWorld', ['farm', false, false, null]],
  ]) {
    const buf = await rawCall(fn, params, conn.identity);
    fs.writeFileSync(path.join(FIXDIR, label + '.hex'), buf.toString('hex') + '\n');
    console.log('  recorded fixtures/' + label + '.hex (' + buf.length + ' bytes)');
  }
}

// ---------- C. live farm loop ----------
async function runLiveLoop() {
  section('C. Live farm loop (equipment + generic paths)');
  const conn = new FVConnection(BASE, { masterId: UID, uid: UID, token: 'fvng', sigTime: Math.floor(Date.now() / 1000) });
  const gold = async () => ((await conn.call('UserService.getBalance', [])) || {}).gold;
  const world = async () => (await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null])).world;

  await conn.call('UserService.getBalance', []);
  await conn.call('UserService.initUser', ['Farmer', -420, true, false, 'flashControllerInit']);
  let w = await world();
  const gold0 = await gold();
  ok('boot loadOwnWorld', !!w && w.sizeX > 0 && w.sizeY > 0, 'world ' + (w && w.sizeX + 'x' + w.sizeY) + ' gold=' + gold0);

  const emptyTile = (ww) => {
    const occ = new Set((Array.isArray(ww.objectsArray) ? ww.objectsArray : Object.values(ww.objectsArray || {})).map(o => o.position.x + ',' + o.position.y));
    for (let y = 0; y < ww.sizeY; y++) for (let x = 0; x < ww.sizeX; x++) if (!occ.has(x + ',' + y)) return [x, y];
    return null;
  };

  // equipment path: plow fresh tile -> plant eggplant
  const [ex, ey] = emptyTile(w);
  const TEMP_A = 63501;
  let r = await conn.call('EquipmentWorldService.onUseEquipment', ['plow', { id: -1, key: 'HOE:1' }, { [TEMP_A]: { position: { x: ex, y: ey, z: 0 } } }, 'plowed']);
  const idA = r && r[0] && r[0].data && r[0].data.id;
  ok('equipment plow assigns fresh id', idA != null && idA > 0, 'id=' + idA);

  const gPrePlant = await gold();
  r = await conn.call('EquipmentWorldService.onUseEquipment', ['place', { id: -1, key: 'EP:1' }, { [idA]: { position: { x: ex, y: ey, z: 0 } } }, 'eggplant']);
  const gPostPlant = await gold();
  eq('plant charges seed cost (eggplant=25)', gPostPlant, gPrePlant - 25);

  w = await world();
  const arr = Array.isArray(w.objectsArray) ? w.objectsArray : Object.values(w.objectsArray || {});
  let objA = arr.find(o => o.id === idA);
  ok('plot persisted planted+eggplant', !!objA && objA.state === 'planted' && objA.itemName === 'eggplant' && objA.plantTime > 0,
    objA ? JSON.stringify({ s: objA.state, i: objA.itemName, t: !!objA.plantTime }) : 'missing');

  // generic path: plow a second tile, then instantGrow/harvest/clear
  const [bx, by] = emptyTile(w);
  const TEMP_B = 63502;
  const gPrePlowB = await gold();
  r = await conn.call('WorldService.performAction', ['plow', { id: TEMP_B, tempId: TEMP_B, className: 'Plot', deleted: false, position: { x: bx, y: by, z: 0 } }]);
  const idB = r && r.id;
  ok('performAction plow assigns fresh id', idB != null && idB > 0 && idB !== TEMP_B, 'id=' + idB);
  eq('plow charges 15 gold', await gold(), gPrePlowB - 15);

  r = await conn.call('WorldService.performAction', ['instantGrow', { id: idA, className: 'Plot', deleted: false }]);
  ok('instantGrow ok', r && r.id === idA);
  w = await world();
  objA = (Array.isArray(w.objectsArray) ? w.objectsArray : Object.values(w.objectsArray || {})).find(o => o.id === idA);
  ok('plot grown after instantGrow', objA && objA.state === 'grown');

  const gPreHarvest = await gold();
  await conn.call('WorldService.performAction', ['harvest', { id: idA, className: 'Plot', deleted: false }]);
  eq('harvest awards coinYield (eggplant=88)', await gold(), gPreHarvest + 88);

  await conn.call('WorldService.performAction', ['clear', { id: idB, className: 'Plot', deleted: false }]);
  w = await world();
  const goneB = !(Array.isArray(w.objectsArray) ? w.objectsArray : Object.values(w.objectsArray || {})).some(o => o.id === idB);
  ok('plot B removed after clear', goneB);

  // grow-timer canonicalization: the client's seeds.json grow_time must drive the server's
  // natural autoGrow flip (server reads items_ng.grow_time; no instantGrow used here).
  const seeds = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'assets', 'seeds.json'), 'utf8'));
  const pick = Object.entries(seeds)
    .filter(([, s]) => s.grow_time >= 0.05 && s.grow_time <= 0.5)   // ~3s–30s: long enough to observe 'planted'
    .sort((a, b) => a[1].grow_time - b[1].grow_time)[0];
  if (!pick) { ok('grow-timer seed available', false, 'no fractional seed in seeds.json'); return; }
  const [seedName, seedDef] = pick;
  const totalMs = seedDef.grow_time * 60 * 1000;
  ok('client seeds.json carries fractional grow_time', totalMs > 0 && totalMs < 60 * 1000,
    seedName + ' grow_time=' + seedDef.grow_time + ' (' + Math.round(totalMs) + 'ms)');

  w = await world();
  const [gx, gy] = emptyTile(w);
  const TEMP_G = 63503;
  let rg = await conn.call('EquipmentWorldService.onUseEquipment', ['plow', { id: -1, key: 'HOE:1' }, { [TEMP_G]: { position: { x: gx, y: gy, z: 0 } } }, 'plowed']);
  const idG = rg && rg[0] && rg[0].data && rg[0].data.id;
  await conn.call('EquipmentWorldService.onUseEquipment', ['place', { id: -1, key: 'EP:1' }, { [idG]: { position: { x: gx, y: gy, z: 0 } } }, seedName]);
  const stateOf = async () => {
    const ww = await world();
    const o = (Array.isArray(ww.objectsArray) ? ww.objectsArray : Object.values(ww.objectsArray || {})).find(x => x.id === idG);
    return o && o.state;
  };
  ok('planted seed starts in planted state', (await stateOf()) === 'planted');
  const deadline = Date.now() + totalMs + 8000; // grow_time + polling slack
  let state = 'planted';
  while (Date.now() < deadline && state !== 'grown') { await new Promise(r => setTimeout(r, 1500)); state = await stateOf(); }
  ok('server autoGrow flips to grown by seeds.json grow_time', state === 'grown', 'state=' + state + ' seed=' + seedName);
  await conn.call('WorldService.performAction', ['clear', { id: idG, className: 'Plot', deleted: false }]);

  // ---- M2: place a non-crop world object (decoration) ----
  const decor = '4thbirthdaybush';
  const TEMP_D = 63510;
  const rd = await conn.call('WorldService.performAction', ['place', { id: TEMP_D, tempId: TEMP_D, className: 'Decoration', deleted: false, itemName: decor, position: { x: 6, y: 6, z: 0 } }]);
  const idD = rd && rd.id;
  ok('place decoration assigns fresh id', idD != null && idD > 0 && idD !== TEMP_D, 'id=' + idD);
  w = await world();
  const objD = (Array.isArray(w.objectsArray) ? w.objectsArray : Object.values(w.objectsArray || {})).find(o => o.id === idD);
  ok('decoration persisted with className+itemName', !!objD && objD.className === 'Decoration' && objD.itemName === decor, objD ? JSON.stringify({ c: objD.className, i: objD.itemName }) : 'missing');
  await conn.call('WorldService.performAction', ['clear', { id: idD, className: 'Decoration', deleted: false }]);

  // ---- M3b: market purchase -> storage -> consume / sell ----
  const gA = await gold();
  await conn.call('UserService.buyItemPutGiftbox', ['12drumtree', 1, false]);
  ok('buy deducts gold (10000)', (await gold()) === gA - 10000, gA + '->' + (await gold()));
  let inv = await conn.call('UserService.getInventory', []);
  ok('buy adds to storage', inv && inv.items.some(i => i.name === '12drumtree' && i.quantity >= 1), JSON.stringify(inv));
  const consumed = await conn.call('UserService.consumeInventoryItem', ['12drumtree', 1]);
  ok('consume removes from storage', !!consumed && !consumed.error, JSON.stringify(consumed));
  await conn.call('UserService.buyItemPutGiftbox', ['12drumtree', 1, false]);
  const sold = await conn.call('UserService.sellStoredItem', [{ code: '12drumtree' }, false, 0, 1]);
  ok('sell refunds 5% of cost (500)', sold && sold.gold === 500, JSON.stringify(sold));
}

// ---------- main ----------
(async () => {
  console.log('FV-NG test harness  base=' + BASE + '  uid=' + UID + (RECORD ? '  [record]' : LIVE ? '  [live]' : '  [offline]'));
  runEncoderTests();
  if (RECORD) {
    const conn = new FVConnection(BASE, { masterId: UID, uid: UID, token: 'fvng', sigTime: Math.floor(Date.now() / 1000) });
    section('Recording response fixtures');
    await recordResponseFixtures(conn);
  } else {
    runDecoderTests();
  }
  if (LIVE && !RECORD) await runLiveLoop();

  console.log('\n' + passed + ' passed, ' + failures.length + ' failed');
  if (failures.length) { for (const f of failures) console.log('  - ' + f); process.exitCode = 1; }
})().catch(e => { console.error('HARNESS ERROR:', e.stack || e.message); process.exitCode = 2; });

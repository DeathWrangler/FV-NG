#!/usr/bin/env node
// Phase 3 E2E: drive the core farm loop against the live gateway and verify state + economy.
const { FVConnection } = require('./amf3.js');

const BASE = 'http://localhost/farmville';
const UID = process.argv[2] || '1111111111';
const conn = new FVConnection(BASE, { masterId: UID, uid: UID, token: 'fvng', sigTime: Math.floor(Date.now() / 1000) });

let failures = 0;
function check(name, cond, detail) {
  console.log((cond ? 'PASS' : 'FAIL') + '  ' + name + (detail ? '  [' + detail + ']' : ''));
  if (!cond) failures++;
}

(async () => {
  // boot
  await conn.call('UserService.getBalance', []);
  const user = await conn.call('UserService.initUser', ['Farmer', -420, true, false, 'flashControllerInit']) || {};
  let wres = await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]);
  let world = wres.world;
  const gold0 = (await conn.call('UserService.getBalance', []) || {}).gold;
  console.log('boot ok: gold=' + gold0 + ' objects=' + world.objectsArray.length);

  // pick an empty tile (no object at that x,y)
  const occupied = new Set(world.objectsArray.map(o => o.position.x + ',' + o.position.y));
  let ex = 0, ey = 0;
  outer: for (let y = 0; y < world.sizeY; y++) for (let x = 0; x < world.sizeX; x++) {
    if (!occupied.has(x + ',' + y)) { ex = x; ey = y; break outer; }
  }

  // ---- PATH A: equipment path (plow -> place) on a fresh empty tile ----
  const TEMP_A = 63001;
  let r = await conn.call('EquipmentWorldService.onUseEquipment', [
    'plow', { id: -1, key: 'HOE:1' },
    { [TEMP_A]: { position: { x: ex, y: ey, z: 0 } } },
    'plowed',
  ]);
  let newIdA = r && r[0] && r[0].data && r[0].data.id;
  // server assigns its own sequence id (maxId+1), not the client temp id — must be a positive real id
  check('equip plow returns fresh id (in data.id)', newIdA != null && newIdA > 0, 'id=' + newIdA);

  const goldBeforePlant = (await conn.call('UserService.getBalance', []) || {}).gold;
  r = await conn.call('EquipmentWorldService.onUseEquipment', [
    'place', { id: -1, key: 'EP:1' },
    { [newIdA]: { position: { x: ex, y: ey, z: 0 } } },
    'eggplant',
  ]);
  const goldAfterPlant = (await conn.call('UserService.getBalance', []) || {}).gold;
  check('equip place charges seed cost (25)', goldAfterPlant === goldBeforePlant - 25, goldBeforePlant + '->' + goldAfterPlant);

  // verify world state persisted
  wres = await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]);
  world = wres.world;
  let objA = world.objectsArray.find(o => o.id === newIdA);
  check('plot A planted+eggplant persisted', objA && objA.state === 'planted' && objA.itemName === 'eggplant' && objA.plantTime > 0,
    objA ? JSON.stringify({ s: objA.state, i: objA.itemName, t: !!objA.plantTime }) : 'missing');

  // ---- PATH B: performAction (generic) — plow another fresh tile via temp id ----
  let bx = 0, by = 0;
  const occ2 = new Set(world.objectsArray.map(o => o.position.x + ',' + o.position.y));
  outer2: for (let y = 0; y < world.sizeY; y++) for (let x = 0; x < world.sizeX; x++) {
    if (!occ2.has(x + ',' + y)) { bx = x; by = y; break outer2; }
  }
  const TEMP_B = 63002;
  const goldBeforePlowB = (await conn.call('UserService.getBalance', []) || {}).gold;
  r = await conn.call('WorldService.performAction', [
    'plow',
    { id: TEMP_B, tempId: TEMP_B, className: 'Plot', deleted: false, position: { x: bx, y: by, z: 0 } },
  ]);
  const newIdB = r && r.id;
  check('performAction plow returns fresh id (in data.id)', newIdB != null && newIdB > 0 && newIdB !== TEMP_B, 'id=' + newIdB);
  const goldAfterPlowB = (await conn.call('UserService.getBalance', []) || {}).gold;
  check('plow charges 15 gold', goldAfterPlowB === goldBeforePlowB - 15, goldBeforePlowB + '->' + goldAfterPlowB);

  // instantGrow A then harvest A (eggplant coinYield=88)
  r = await conn.call('WorldService.performAction', ['instantGrow', { id: newIdA, className: 'Plot', deleted: false }]);
  check('instantGrow ok', r && r.id === newIdA);

  wres = await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]);
  world = wres.world;
  objA = world.objectsArray.find(o => o.id === newIdA);
  check('plot A grown after instantGrow', objA && objA.state === 'grown');

  const goldBeforeHarvest = (await conn.call('UserService.getBalance', []) || {}).gold;
  r = await conn.call('WorldService.performAction', ['harvest', { id: newIdA, className: 'Plot', deleted: false }]);
  const goldAfterHarvest = (await conn.call('UserService.getBalance', []) || {}).gold;
  check('harvest awards coinYield (88)', goldAfterHarvest === goldBeforeHarvest + 88, goldBeforeHarvest + '->' + goldAfterHarvest);

  wres = await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]);
  world = wres.world;
  objA = world.objectsArray.find(o => o.id === newIdA);
  check('plot A back to fallow after harvest', objA && objA.state === 'fallow' && !objA.itemName);

  // equipment-path harvest on plot B: plant first, instantGrow, then equip harvest
  await conn.call('EquipmentWorldService.onUseEquipment', ['place', { id: -1, key: 'EP:1' }, { [newIdB]: { position: { x: bx, y: by, z: 0 } } }, 'eggplant']);
  await conn.call('WorldService.performAction', ['instantGrow', { id: newIdB, className: 'Plot', deleted: false }]);
  const goldBeforeEH = (await conn.call('UserService.getBalance', []) || {}).gold;
  r = await conn.call('EquipmentWorldService.onUseEquipment', ['harvest', { id: -1, key: 'HOE:1' }, { [newIdB]: { position: { x: bx, y: by, z: 0 } } }, 'plowed']);
  check('equip harvest data.id matches plot', r && r[0] && r[0].data && r[0].data.id === newIdB, JSON.stringify(r && r[0]));
  const goldAfterEH = (await conn.call('UserService.getBalance', []) || {}).gold;
  check('equip harvest awards coinYield (88)', goldAfterEH === goldBeforeEH + 88, goldBeforeEH + '->' + goldAfterEH);

  // clear plot B
  r = await conn.call('WorldService.performAction', ['clear', { id: newIdB, className: 'Plot', deleted: false }]);
  wres = await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]);
  world = wres.world;
  check('plot B removed after clear', !world.objectsArray.some(o => o.id === newIdB));

  // harvest not-ready plot must be a no-op (plant fresh, harvest immediately)
  await conn.call('EquipmentWorldService.onUseEquipment', ['place', { id: -1, key: 'EP:1' }, { [newIdA]: { position: { x: ex, y: ey, z: 0 } } }, 'eggplant']);
  const goldBeforeNR = (await conn.call('UserService.getBalance', []) || {}).gold; // AFTER the plant's charge
  r = await conn.call('WorldService.performAction', ['harvest', { id: newIdA, className: 'Plot', deleted: false }]);
  const goldAfterNR = (await conn.call('UserService.getBalance', []) || {}).gold;
  check('harvest of planted (not grown) is no-op', goldAfterNR === goldBeforeNR, goldBeforeNR + '->' + goldAfterNR);

  console.log(failures === 0 ? '\nALL PASS' : '\n' + failures + ' FAILURES');
  process.exit(failures === 0 ? 0 : 1);
})().catch(e => { console.error('E2E ERROR:', e.message); process.exit(2); });

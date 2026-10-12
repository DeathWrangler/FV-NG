const { FVConnection } = require("./amf3.js");
(async () => {
  const conn = new FVConnection(process.env.FV_BASE_URL || 'http://localhost/farmville',
    { masterId: process.env.FV_UID || '1111111111', uid: process.env.FV_UID || '1111111111', token: 't' });
  const w = await conn.call('WorldService.loadOwnWorld', ['farm', false, false, null]);
  const arr = Array.isArray(w.world.objectsArray) ? w.world.objectsArray : Object.values(w.world.objectsArray);
  console.log(`World ${w.world.type} ${w.world.sizeX}x${w.world.sizeY} — ${arr.length} objects:\n`);
  for (const o of arr) {
    const pos = o.position ? `(${o.position.x},${o.position.y},${o.position.z})` : '';
    console.log(`  [${o.id}] ${String(o.className).padEnd(10)} state=${String(o.state).padEnd(9)} item=${o.itemName||'-'} pos=${pos}`);
  }
  const states = {};
  for (const o of arr) states[o.state] = (states[o.state]||0)+1;
  console.log('\nstate counts:', JSON.stringify(states));
})().catch(e => { console.error('FAIL', e.message); process.exit(1); });

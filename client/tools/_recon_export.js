const fs = require('fs');
const { parseSwf } = require('swf-parser');
const { swfToScene } = require('./swf2scene.js');
const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets/dialogs';
const hash = JSON.parse(fs.readFileSync('C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json','utf8')).dialogs;
const key = Object.keys(hash).find(k=>/FV_delete_confirm/i.test(k));
console.log('converting:', key);
const swf = parseSwf(fs.readFileSync(ASSETS + '/' + hash[key] + '.swf'));
const scene = swfToScene(swf, { source: key });

// walk all frames (root + sprites) for named placements
const chars = scene.characters;
const seen = new Set(); const names = [];
const walk = (list, depth) => { if(!list||depth>25)return; for(const p of list){ if(p.name)names.push(p.name); const c=chars[p.char]; if(c&&c.type==='sprite'&&!seen.has(p.char)){seen.add(p.char);walk(c.frames[0],depth+1);} } };
(scene.frames||[]).forEach(f=>walk(f,0));
// also button states
for(const id in chars){const c=chars[id]; if(c.type==='button'){for(const st of ['up','over','down','hit'])for(const p of (c.states[st]||[]))if(p.name)names.push('btn.'+p.name);}}

console.log('named placements found:', names.length);
console.log(JSON.stringify([...new Set(names)]));
// button chars + their export names
const btns = Object.entries(chars).filter(([id,c])=>c.type==='button');
console.log('\nbutton chars:', btns.length);
for(const [id,c] of btns) console.log('  char', id, '-> up[0].char=', c.states.up[0]&&c.states.up[0].char, 'exportName=', scene.exports && Object.keys(scene.exports).find(n=>scene.exports[n]==id));

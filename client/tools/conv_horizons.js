// FV-NG — convert all grass theme-background ("outside image") SWFs to horizon scenes.
// The original picks `backgroundPath + (width-2)/4 + ".swf"`; we emit horizon_{n}.scene.json so the
// client can select the matching variant for any farm size. Resume-safe.
const fs = require('fs');
const path = require('path');
const { parseSwf } = require('swf-parser');
const { swfToScene } = require('./swf2scene.js');

const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets/Environment';
const OUT = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes';
const HASH = 'C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json';

const env = (JSON.parse(fs.readFileSync(HASH, 'utf8')).Environment) || {};
const force = process.argv.includes('--force');
const keys = Object.keys(env).filter(k => /^grass_themeBackground_\d+\.swf$/.test(k));
fs.mkdirSync(OUT, { recursive: true });
let ok = 0, resume = 0, fail = 0;
for (const k of keys) {
  const n = k.match(/_(\d+)\.swf$/)[1];
  const outFile = path.join(OUT, 'horizon_' + n + '.scene.json');
  if (fs.existsSync(outFile) && !force) { resume++; continue; }
  const swfPath = path.join(ASSETS, env[k] + '.swf');
  if (!fs.existsSync(swfPath)) { fail++; continue; }
  try { fs.writeFileSync(outFile, JSON.stringify(swfToScene(parseSwf(fs.readFileSync(swfPath)), { source: k }))); ok++; }
  catch (e) { fail++; }
}
// far sky/horizon strip (grass_theme.swf = clouds + distant hills + sky gradient), tiled by the client
const strip = env['grass_theme.swf'];
if (strip) {
  const swfPath = path.join(ASSETS, strip + '.swf');
  try { fs.writeFileSync(path.join(OUT, 'horizonstrip.scene.json'), JSON.stringify(swfToScene(parseSwf(fs.readFileSync(swfPath)), { source: 'grass_theme.swf' }))); ok++; }
  catch (e) { fail++; }
}
console.log(JSON.stringify({ variants: keys.length, converted: ok, resumed: resume, failed: fail }));

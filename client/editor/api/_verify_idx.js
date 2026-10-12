const fs = require('fs');
const idx = JSON.parse(fs.readFileSync('C:/Users/Remote/Desktop/FV-NG/build/uiindex/index.json','utf8'));
function show(cls) {
  const r = idx.classes.find(c => c.cls === cls);
  if (!r) { console.log(cls + ': NOT FOUND'); return; }
  console.log('\n=== ' + r.cls + ' (' + (r.extends||'?') + ') file=' + r.file);
  console.log('  primary asset:', r.assetPrimary, '| all assets:', JSON.stringify(r.assets.map(a=>a.path)));
  console.log('  dddNames:', JSON.stringify(r.dddNames), 'isDDD:', !!r.isDDD);
  console.log('  bindings:');
  for (const b of r.bindings) console.log('    [' + b.kind + '] ' + b.element + ' -> ' + b.handler + '  (L' + b.line + ')');
  console.log('  textFields:', JSON.stringify(r.textFields.map(t=>t.leaf)));
  console.log('  sounds:', JSON.stringify(r.sounds));
}
show('DeleteConfirm');
show('AskBuyPopup');
show('AssetPreviewDialog');
// overall binding kind distribution
const kinds = {}; let totalB=0, totalT=0;
for (const c of idx.classes) { for (const b of c.bindings){kinds[b.kind]=(kinds[b.kind]||0)+1;totalB++;} totalT+=c.textFields.length; }
console.log('\nBINDING KINDS:', JSON.stringify(kinds), 'totalBindings=', totalB, 'totalTextFields=', totalT);
// how many classes have a primary asset that is in the dialogs category (mappable to a scene)
let withDlgAsset=0; for(const c of idx.classes){ if(c.assetPrimary && /assets\/dialogs\//.test(c.assetPrimary)) withDlgAsset++; }
console.log('classes with assets/dialogs/ primary:', withDlgAsset);

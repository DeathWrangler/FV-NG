const fs = require('fs');
const { parseSwf } = require('swf-parser');
const swf = parseSwf(fs.readFileSync('C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets/Environment/df0a488eac94bee5d6eca26fd6114603.swf'));
// find a PlaceObject with a colorTransform
function scan(tags, depth) {
  for (const t of tags) {
    if (t.type !== undefined) {
      const s = JSON.stringify(t);
      if (s.includes('colorTransform') && s.includes('alpha')) {
        console.log('tag type', t.type, 'keys', Object.keys(t).join(','));
        console.log('  colorTransform:', JSON.stringify(t.colorTransform));
        return true;
      }
    }
    if (t.subTags) { if (scan(t.subTags, depth+1)) return true; }
  }
  return false;
}
scan(swf.tags, 0);

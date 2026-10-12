// FV-NG — sound name map (M8a audio). Emits { originalName: hash } from assethash.json's `sounds`
// category, so the client can resolve a named SFX/track to assets/hashed/assets/sounds/<hash>.mp3.
const fs = require('fs');
const HASH = 'C:/Users/Remote/Desktop/FV-NG/client/assets/assethash.json';
const OUT = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/sounds.json';
const DEV = 'C:/Users/Remote/Desktop/FV-NG/client/web/sounds.json';
const a = JSON.parse(fs.readFileSync(HASH, 'utf8'));
const sounds = a.sounds || {};
fs.writeFileSync(OUT, JSON.stringify(sounds));
fs.writeFileSync(DEV, JSON.stringify(sounds));
console.log('wrote sounds.json: ' + Object.keys(sounds).length + ' entries');

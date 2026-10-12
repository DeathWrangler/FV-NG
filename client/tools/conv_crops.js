// Batch-convert ALL crop-category SWFs -> per-stage PNG tiles with alpha.
// Symbols are found by SUFFIX match (<anything>_seeds/_growing1/...) so expansion prefixes work.
// Output: {OUT}/{fileStem}_{stage}.png   (stem = swf filename without .swf)
// Usage: node conv_all.js <start> <count>
const fs = require('fs'), path = require('path');
const { parseSwf } = require('swf-parser');
const zlib = require('zlib');
const jpeg = require('jpeg-js');

const ASSETS = 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets/crops';
const OUT = 'C:/Farmville/xampp/htdocs/public/farmville/fvng/croptiles';
const hashmap = JSON.parse(fs.readFileSync('C:/Farmville/xampp/htdocs/public/farmville/fvng/assethash.crops.json','utf8')).crops;

function crc32(buf){let t=[];for(let n=0;n<256;n++){let c=n;for(let k=0;k<8;k++)c=c&1?0xEDB88320^(c>>>1):c>>>1;t[n]=c;}let crc=0xFFFFFFFF;for(const b of buf)crc=t[(crc^b)&0xFF]^(crc>>>8);return (crc^0xFFFFFFFF)>>>0;}
function chunk(type,data){const len=Buffer.alloc(4);len.writeUInt32BE(data.length);const t=Buffer.from(type);const crc=Buffer.alloc(4);crc.writeUInt32BE(crc32(Buffer.concat([t,data])));return Buffer.concat([len,t,data,crc]);}
function encodePNG(w,h,rgba){
  const sig=Buffer.from([0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a]);
  const ihdr=Buffer.alloc(13);ihdr.writeUInt32BE(w,0);ihdr.writeUInt32BE(h,4);ihdr[8]=8;ihdr[9]=6;
  const raw=Buffer.alloc((w*4+1)*h);
  for(let y=0;y<h;y++){raw[y*(w*4+1)]=0;rgba.copy(raw,y*(w*4+1)+1,y*w*4,(y+1)*w*4);}
  return Buffer.concat([sig,chunk('IHDR',ihdr),chunk('IDAT',zlib.deflateSync(raw,{level:5})),chunk('IEND',Buffer.alloc(0))]);
}
function toRGBA(rgb,w,h,lo=12,hi=72){
  const out=Buffer.alloc(w*h*4);
  for(let i=0;i<w*h;i++){
    const r=rgb[i*3],g=rgb[i*3+1],b=rgb[i*3+2];
    const m=Math.max(r,g,b);
    let a=(m-lo)/(hi-lo); a=a<0?0:a>1?1:a;
    out[i*4]=r;out[i*4+1]=g;out[i*4+2]=b;out[i*4+3]=(a*255)|0;
  }
  return out;
}
function decodeJpeg3(data){
  const buf = Buffer.from(data.buffer, data.byteOffset, data.length);
  const colorLen=buf.readUInt32LE(0);
  const jpg=Buffer.from(buf.subarray(4,4+colorLen));
  return jpeg.decode(jpg,{useTArray:true});
}
// DefineBitsLossless2 payload (as swf-parser exposes it): [bitDepth(1)][w(u16 LE)][h(u16 LE)][zlib(RAW RGBA32)]
// After zlib decompression the bytes ARE the raw pixel data (RGBA, 4 bytes/px) — no RLE.
// Locate the zlib magic (0x78) in the first 8 bytes to find the stream start.
function decodeLossless2(data,w,h){
  const buf = Buffer.from(data.buffer, data.byteOffset, data.length);
  let zoff=-1;
  for(let o=1;o<8 && o+1<buf.length;o++){ if(buf[o]===0x78 && (buf[o+1]===0x01||buf[o+1]===0x9c||buf[o+1]===0xda)){ zoff=o; break; } }
  if(zoff<0) throw new Error('no zlib magic in lossless2 prefix');
  const raw = zlib.inflateSync(buf.subarray(zoff)); // raw RGBA32
  const out = Buffer.alloc(w*h*4);
  raw.copy(out, 0, 0, Math.min(raw.length, w*h*4));
  return {data:new Uint8Array(out), width:w, height:h};
}

const allSwfs = Object.keys(hashmap).filter(k=>k.endsWith('.swf')).sort();
const start=parseInt(process.argv[2]||'0',10);
const count=parseInt(process.argv[3]||'50',10);
fs.mkdirSync(OUT,{recursive:true});
const manifest = {}; // symbolStem -> {stages:[...]}
let ok=0, fail=0, low=[];
for(let i=start;i<allSwfs.length && i<start+count;i++){
  const name=allSwfs[i];
  const fp=path.join(ASSETS,hashmap[name]+'.swf');
  try{
    if(!fs.existsSync(fp)){fail++;continue;}
    const swf=parseSwf(fs.readFileSync(fp));
    // stage -> {symbolId, symbolStem}
    const stages=['seeds','growing1','growing2','grown','super','withered'];
    const stageInfo={};
    for(const t of swf.tags){
      if(t.type!==64) continue;
      for(const s of (t.symbols||[])){
        for(const st of stages){
          if(s.name.endsWith('_'+st) && !(st in stageInfo)) {
            const stem=s.name.slice(0, s.name.length-('_'+st).length);
            stageInfo[st]={id:s.id, stem};
          }
        }
      }
    }
    const bitmaps={};
    for(const t of swf.tags) if(t.type===5||t.type===60) bitmaps[t.id]={w:t.width,h:t.height,data:t.data,mt:t.mediaType||''};
    let found=0, stem=null;
    for(const st of stages){
      const info=stageInfo[st];
      if(!info||!bitmaps[info.id]||!bitmaps[info.id].data) continue;
      stem = info.stem;
      try{
        const bm=bitmaps[info.id];
        let dec, rgba;
        if(/lossless2/.test(bm.mt)){
          dec=decodeLossless2(bm.data,bm.w,bm.h);
          // Lossless2 carries real RGBA — preserve native alpha (corners already transparent)
          rgba=Buffer.from(dec.data.buffer,dec.data.byteOffset,dec.data.length);
        } else {
          dec=decodeJpeg3(bm.data);
          // JPEG3 color stream has no alpha — derive it from black background (luminance ramp)
          const rgb=Buffer.alloc(dec.width*dec.height*3);
          for(let p=0;p<dec.width*dec.height;p++){rgb[p*3]=dec.data[p*4];rgb[p*3+1]=dec.data[p*4+1];rgb[p*3+2]=dec.data[p*4+2];}
          rgba=toRGBA(rgb,dec.width,dec.height);
        }
        fs.writeFileSync(path.join(OUT,stem+'_'+st+'.png'),encodePNG(dec.width,dec.height,rgba));
        found++;
      }catch(e){ /* skip stage */ }
    }
    if(found>=4 && stem){ ok++; manifest[stem]={stages:stages.filter(st=>stageInfo[st])}; }
    else if (found>0) low.push((stem||name)+'('+found+')');
  }catch(e){ fail++; }
}
// append manifest slice
const mfPath=path.join(OUT,'_manifest.json');
let mf={};
if(fs.existsSync(mfPath)){ try{mf=JSON.parse(fs.readFileSync(mfPath,'utf8'));}catch(e){} }
Object.assign(mf,manifest);
fs.writeFileSync(mfPath,JSON.stringify(mf));
console.log(`slice ${start}..${Math.min(start+count,allSwfs.length)}: ok=${ok} fail=${fail} lowStage=${low.length}${low.length?' -> '+low.slice(0,10).join(','):''}`);

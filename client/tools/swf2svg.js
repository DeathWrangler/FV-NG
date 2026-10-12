// FV-NG SWF vector renderer — flattens a static single-frame AS2 SWF (DefineShape2/3/4 +
// sprites) into an SVG of paths in COMPOSED space, plus a JSON sidecar with the content
// bounds and display anchor so the client can position it exactly like the original.
//
// Units: Flash 1px = 24 units. Matrix scale is Sfixed16P16 (1.0 = 65536); translate is a
// raw signed integer in Flash units. The original FarmBackgroundRenderer scales this
// backdrop by OUTSIDE_IMAGE_SIZE_FACTOR=0.5 and crops it — the content is intentionally
// larger than the stage, so we emit a viewBox covering ALL composed content (no clipping).
const fs = require('fs');
const { parseSwf } = require('swf-parser');

const FP = 65536; // Sfixed16P16 fixed-point scale (1.0 = 65536)
function e(v) { return v ? (v.epsilons / FP) : 0; }

// affine [a,b,c,d,tx,ty] (column-major): x' = a*x + c*y + tx ; y' = b*x + d*y + ty
function mul(A, B) {
  return [A[0]*B[0]+A[2]*B[1], A[1]*B[0]+A[3]*B[1], A[0]*B[2]+A[2]*B[3], A[1]*B[2]+A[3]*B[3],
          A[0]*B[4]+A[2]*B[5]+A[4], A[1]*B[4]+A[3]*B[5]+A[5]];
}
function matFromM(m) {
  if (!m) return [1, 0, 0, 1, 0, 0];
  const sx = e(m.scaleX), sy = e(m.scaleY), c0 = e(m.rotateSkew0), s1 = e(m.rotateSkew1);
  let a, b, c, d;
  if (c0 === 0 && s1 === 0) { a = sx; b = 0; c = 0; d = sy; }        // no rotation/skew
  else { a = sx*c0; b = sx*s1; c = -sy*s1; d = sy*c0; }              // rotateSkew0=cos, rotateSkew1=sin
  return [a, b, c, d, m.translateX, m.translateY];                   // translate: raw Flash units
}

function fillOf(sh) {
  const f = (sh.initialStyles.fill || [])[0];
  if (!f || !f.color) return 'none';
  const c = f.color;
  if (c.a !== undefined && c.a < 255) return `rgba(${c.r},${c.g},${c.b},${(c.a/255).toFixed(3)})`;
  return `rgb(${c.r},${c.g},${c.b})`;
}

function swfToFlat(swf) {
  let charId = 0; const chars = {};
  const isDef = t => t.shape !== undefined || (t.frameCount !== undefined && t.tags);
  for (const t of swf.tags) if (isDef(t)) { charId++; chars[charId] = { kind: t.shape ? 'shape' : 'sprite', def: t }; }

  const paths = []; let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  let fieldHalfWpx = null; // half-width (px) of the largest path = the field plane diamond
  function render(cid, M) {
    const ch = chars[cid]; if (!ch) return;
    if (ch.kind === 'shape') {
      const sh = ch.def.shape;
      let cx = 0, cy = 0, d = '', prevMove = true;
      let pminX = Infinity, pminY = Infinity, pmaxX = -Infinity, pmaxY = -Infinity;
      for (const r of sh.records) {
        if (r.type === 1) { cx = r.moveTo.x; cy = r.moveTo.y; prevMove = true; }
        else if (r.type === 0) { cx += r.delta.x; cy += r.delta.y; prevMove = false; }
        else if (r.type === 2) { const c1 = r.quadraticControl, ept = r.endPoint; cx += c1.x; cy += c1.y; cx += ept.x; cy += ept.y; }
        else if (r.type === 3) { const p1 = r.cubicControlPoint1, p2 = r.cubicControlPoint2, ept = r.endPoint; cx += p1.x; cy += p1.y; cx += p2.x; cy += p2.y; cx += ept.x; cy += ept.y; }
        else continue;
        const X = M[0]*cx + M[2]*cy + M[4], Y = M[1]*cx + M[3]*cy + M[5];
        minX = Math.min(minX, X); maxX = Math.max(maxX, X); minY = Math.min(minY, Y); maxY = Math.max(maxY, Y);
        pminX = Math.min(pminX, X); pmaxX = Math.max(pmaxX, X); pminY = Math.min(pminY, Y); pmaxY = Math.max(pmaxY, Y);
        d += (prevMove ? 'M' : 'L') + X.toFixed(1) + ' ' + Y.toFixed(1) + ' ';
      }
      if (d) {
        paths.push(`<path d='${d.trim()}' fill='${fillOf(sh)}'/>`);
        const halfW = (pmaxX - pminX) / 2 / 24; // px
        if (fieldHalfWpx === null || halfW > fieldHalfWpx) fieldHalfWpx = halfW;
      }
    } else {
      for (const sub of ch.def.tags)
        if (sub.characterId !== undefined && sub.matrix !== undefined) render(sub.characterId, mul(M, matFromM(sub.matrix)));
    }
  }
  let anchor = null;
  for (const t of swf.tags) {
    if (t.characterId !== undefined && t.matrix !== undefined) {
      const M = matFromM(t.matrix);
      if (!anchor) anchor = [M[4], M[5]]; // root placement origin = backdrop center anchor
      render(t.characterId, M);
    }
  }
  return { paths, bounds: [minX, minY, maxX, maxY], anchor, fieldHalfWpx };
}

function swfToSvg(swf) {
  const { paths, bounds, anchor, fieldHalfWpx } = swfToFlat(swf);
  const [x0, y0, x1, y1] = bounds;
  const W = x1 - x0, H = y1 - y0;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${x0.toFixed(1)} ${y0.toFixed(1)} ${W.toFixed(1)} ${H.toFixed(1)}" width="${(W/24).toFixed(1)}" height="${(H/24).toFixed(1)}">${paths.join('')}</svg>`;
  const meta = { bounds: [x0, y0, x1, y1], anchor: anchor, fieldHalfWpx: fieldHalfWpx, unitPx: 24 };
  return { svg, meta };
}

module.exports = { swfToSvg, swfToFlat };

if (require.main === module) {
  const [,, inFile, outFile] = process.argv;
  const swf = parseSwf(fs.readFileSync(inFile));
  const { svg, meta } = swfToSvg(swf);
  if (outFile) {
    fs.writeFileSync(outFile, svg);
    fs.writeFileSync(outFile.replace(/\.svg$/, '.json'), JSON.stringify(meta, null, 1));
  }
  console.log('SVG bytes:', svg.length, '| paths:', (svg.match(/<path/g) || []).length,
              '| bounds:', meta.bounds.map(Math.round).join(','), '| anchor:', meta.anchor);
}

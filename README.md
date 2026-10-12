# FV-NG

A **1:1 web rewrite of FarmVille** (the 2009–2012 Flash game) with **no Flash runtime**. The original
SWF art is exported to a runtime scene format and re-rendered on Canvas2D, driven by the same
AMF3/Flash-Remoting backend the live client used.

> Reverse-engineering / preservation project. Original game files are not included.

## How it works

```
 original SWF ──(swf-parser)──► client/tools/swf2scene.js ──► *.scene.json
                                                              │
                                     client/web/scene2d.js ◄──┘  (FVScene renderer, browser + Node)
                                                              │
 FarmGame.amfphp gateway ──(client/net/amf3.js AMF3/HTTP)──► client/web/app.js (farm, HUD, dialogs…)
```

- **Sprite pipeline** — `swf2scene.js` flattens vectors, bitmaps (JPEG3/Lossless2), gradients,
  bitmap-fills, fonts/glyphs, blend modes and filters into a runtime scene; `scene2d.js` renders it
  (Node-requirable, so scenes can also be rendered headless for diffing/testing).
- **Net layer** — `client/net/amf3.js` speaks the Flash Remoting envelope amfphp expects and decodes
  AMF0/AMF3 responses.
- **Capture/debug** — an additive hook in the amfphp entrypoint records every real request/response
  pair so the rewrite can mirror the live client exactly (see *AMF capture* below).

## Layout

```
client/web       browser client (app.js, hud.js, scene2d.js, fvstage.js, market.js, ui.js, …)
client/tools     SWF→scene exporters + asset converters (swf2scene, conv_*, scene2svg, conv_capture)
client/net       AMF3-over-HTTP client + regression harness (amf3.js, run_tests.js)
client/editor    UI/menu/overlay editor + AMF capture tooling (amf_capture*.js)
client/assets    assethash.json (asset name → hash) + crop/seed/level maps
decompiled/      decompiled AS3 of the original client (reference for 1:1 behaviour)
decompile.bat    AS3 decompile helper
build/           generated data (asset DB, ledgers, UI index) — large, NOT in git
```

## Requirements

- **Node.js 18+** (developed on Node 24) — converter/editor/test tooling.
- A web server exposing the original game assets and the amfphp gateway, e.g. XAMPP/Apache with the
  game under `/farmville/`. Deployed rewrite lives at `public/farmville/fvng/`.
- Asset/DB source files live outside the repo (original SWFs, `assethash.json`, item DB).

## Getting started

Serve `client/web/` same-origin with the game (the client calls `/farmville/flashservices/gateway.php`
and reads hashed assets). Then open the client page. Dev query params: `?uid=<id>` (login as a player),
`?zoom=<n>`, `?dialog=<name>`, `?market`, `?storage`, `?debug`.

### UI / overlay editor

```bash
node client/editor/start.js 8787      # detached server → http://localhost:8787/
```

Imports dialog/menu/overlay SWFs, renders them interactively and maps each element to its decompiled
AS3 handler. See `client/editor/README.md`.

## Tests

```bash
cd client
npm test              # net regression (encode/parse fixtures)
npm run test:live     # against a running gateway
npm run test:scene    # SWF→scene pipeline regression (keep green)
npm run test:editor   # editor unit tests
```

## Asset conversion

```bash
cd client/tools
node conv_scenes.js 2000 tree,decoration   # world objects  → fvng/scenes + scenesbyname.json
node conv_dialogs.js                        # dialog/UI SWFs → scenes + dialogsbyname.json
node conv_hud.js                            # HUD chrome      → hud.json
node conv_crops.js                          # crop stage tiles → croptiles/
node scene2svg.js <scene.json> out.svg      # render a scene to SVG (verification)
```

## AMF capture (mirror the live client)

An additive, marker-gated block in `flashservices/amfphp/index.php` tees raw request/response bytes
into JSONL (zero overhead when off). Tooling in `client/editor/`:

```bash
node client/editor/amf_capture.js on|off|status             # marker + truncate log
node client/editor/amf_capture_decode.js <cap.jsonl>        # render every call → payload
node client/editor/amf_capture_report.js <cap.jsonl>        # per-functionName breakdown (+ --dump FN)
node client/tools/conv_capture.js <cap.jsonl>               # derive & convert missing avatar/world/dialog sprites
```

The decoder understands both the rewrite's AMF0 bodies and the **live Flash client's AMF3 values**
(so a real session can be parsed and replayed). Deployed scenes are cross-checked byte-for-byte by
the converter.

## License / disclaimer

Fan preservation project; all original FarmVille art, code and trademarks belong to their respective
owners (Zynga/Playdom). Source here is provided for study and preservation only.

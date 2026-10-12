# FV-NG — Original crop-art converter (1:1 sprites)

The original `crop_*.swf` files are **not vector** — each is a container of **6 complete
isometric plot tiles** (soil diamond + plant), one per growth stage:
`seeds / growing1 / growing2 / grown / super / withered`. This directory extracts those
tiles to PNG so the browser client renders true original art instead of flat icons.

## Outputs (already generated, deployed to `/farmville/fvng/`)
- `croptiles/{stem}_{stage}.png` — one transparent square tile per crop stage (~12k files)
- `croptiles/_manifest.json` — `{ stem: { stages: [...] } }`
- `cropsbyname.json` — `{ itemName: stem }` (world `itemName` → tile stem)

## Regenerate
```bash
# 1. convert all crop SWFs -> croptiles/  (needs node + swf-parser + jpeg-js in this dir)
node conv_crops.js 0 4000 < /dev/null        # start, count  (run foreground; background shell needs </dev/null)

# 2. rebuild the itemName->stem map from the item DB  (needs XAMPP MariaDB running)
"/c/Farmville/xampp/php/php.exe" make_name_map.php
```

## How it works
- `swf-parser` decompresses the CWS wrapper and exposes tags.
- Stage bitmaps are found by symbol-name suffix (`<stem>_<stage>`), so expansion prefixes
  (`xmd_seaglasswheat`, `flower_alfalfa`) work without special-casing.
- Two bitmap formats exist in the catalog:
  - **JPEG3** (DefineBitsJPEG3): `[u32 LE colorLen][JPEG..EOI][alpha tables]` → jpeg-js decodes
    the RGB; alpha is *derived* from the black background via a luminance ramp.
  - **Lossless2** (DefineBitsLossless2): `[bitDepth(1)][w(u16)][h(u16)][zlib(raw RGBA32)]` →
    zlib inflate gives raw pixels with **native alpha preserved** (corners already transparent).
- PNGs are encoded with a tiny built-in encoder (no external PNG lib needed).

## Client wiring (client/web/app.js)
`boot()` loads `cropsbyname.json`; the render loop calls `tileUrl(o)` → if a stage tile exists it
draws the original plot art (`drawOriginalTile`) in place of synthetic soil+icon, else falls back
to the icon renderer. Stage is chosen from grow-fraction (seeds/growing1/growing2/grown), with
`super` for jumbo and `withered` for dead crops.

## Coverage
Every crop whose `.swf` was extracted from the WARC (2,099/2,103). Crops in other asset
categories (trees, animals, buildings) are out of the core-farm-loop scope.

---

# FV-NG — SWF scene pipeline (Track A / milestone M1)

A general SWF→runtime-scene exporter + Canvas2D renderer, so **any** asset renders without a Flash
runtime (not just crops). This is the core of the 1:1 preservation rendering path.

## Files
- `swf2scene.js` — export a SWF to a runtime scene JSON:
  - `characters`: `shape` (flattened path primitives w/ solid fills + strokes), `sprite` (nested
    timelines), `bitmap` (decoded JPEG/Lossless → embedded PNG data-URI)
  - `exports`: SymbolClass name → character id (Farmville assets are **symbol libraries**)
  - `frames`: root timeline (PlaceObject/RemoveObject → per-frame display lists, with full matrix,
    colour transform, ratio, clipDepth)
  - units: Flash twips (1px = 20 twips)
- `scene2d.js` — runtime `FVScene` renderer (browser + Node-requirable). Display-list traversal,
  nested timelines, affine matrices, alpha, vector fills/strokes, bitmap draws, `measure()` bounds.
- `scene2svg.js` — Node-side scene → SVG (visual verification / diffing without a browser).
- `test_scene.js` — pipeline tests (matrix math, shape flattening, real-asset conversion).

## Commands
```bash
node swf2scene.js <in.swf> <out.scene.json>            # export
node scene2svg.js <scene.json> <out.svg> [frame] [sym] # render to SVG
node test_scene.js                                     # tests  (or: npm run test:scene)
```

## Browser demo
`client/web/scene-test.html` loads a scene (`?scene=scenes/foo.scene.json`), renders it with
`FVScene`, and offers a frame slider + symbol picker. Deployed same-origin at
`/farmville/fvng/scene-test.html`. Headless screenshot:
```
msedge --headless=new --screenshot=out.png "http://localhost/farmville/fvng/scene-test.html?scene=scenes/trellis.scene.json"
```

## Verified
- 160/160 sampled assets (decorations/buildings/hud/trees/avatars) convert + render; 97 with bitmaps.
- Original artwork reproduces with no Flash runtime (e.g. `trellis_horizontal` bitmap, 415-path vector).
- **M1b (2026-10-09):** gradient fills (linear/radial/focal), bitmap-fill styles, dynamic text
  (DefineEditText), clipDepth masks, and time-driven animation playback are implemented and
  verified (`npm run test:scene` 25/25; headless screenshots show a gradient droplet, bitmap-fill
  HUD, and an animated "100" label).
- **M1c (2026-10-09):** SWF blend modes (multiply/screen/overlay/hard-light/…) and filters
  (glow / drop shadow / blur) exported and rendered (canvas `globalCompositeOperation` +
  `ctx.filter`; SVG `mix-blend-mode` + `feDropShadow`/`feGaussianBlur`). `npm run test:scene`
  30/30; headless screenshot shows a glow on grass.
- **M1d (2026-10-09):** embedded-font **glyph text** (`DefineFont` outlines + metrics) for
  `DefineEditText` — `scene.fonts` carries per-glyph outline prims + advances; renderer lays out
  glyphs at the text's size/align/colour (SVG too). `npm run test:scene` 34/34; a full fall/avatar
  dialog reproduces 1:1. Static `DefineText` is absent from the catalog (Farmville uses dynamic
  text everywhere). Color-matrix filters emitted in SVG (`feColorMatrix`); canvas has no direct
  equivalent.
- Still not implemented: audio (Track A13/M8), and button/AVM2 interactivity.

---

# FV-NG — world-object scene pipeline (M2)

Batch-converts placeable world items (decorations / trees / buildings / animals) to runtime scenes
and builds the `itemName -> scene` map the farm client uses to render them.

## Pipeline
```bash
# 1) dump item asset references from the DB (one SWF image per placeable item)
"C:\Farmville\xampp\php\php.exe" ..\..\build\list_items.php     # -> build/item_assets.json
# 2) resolve each image -> hashed SWF (via client/assets/assethash.json) and convert
node conv_scenes.js 150                                          # limit per category
```
Outputs `<webroot>/farmville/fvng/scenes/{stem}.scene.json` + `scenesbyname.json`
(`{ itemName: sceneStem }`), also copied to `client/web/scenesbyname.json`.

## Client wiring (`client/web/app.js`)
`boot()` loads `scenesbyname.json` + `itemmeta.json`; the render loop draws any non-`Plot` object
through `drawSceneObject()` (`FVScene.renderSymbol`), anchored bottom-centre on its **footprint
centre** (`sizeX/sizeY`). **Scale matches `MapResource.updateDisplayObjectTransform`:
`scale = boxWidth / contentWidth * imageScale`**, where `boxWidth = (sizeX+sizeY) * TILE_WIDTH/2`
is the footprint's bounding width — i.e. the art is normalised to the footprint and then multiplied
by `imageScale`. `TILE_W/H = 25/12` are the original runtime values (`FarmGame.as` sets
`ZEngineOptions.tileWidth=25, tileHeight=12, tileScale=2`), so no extra factor is needed. Crop
`Plot`s use the original `Plot.SIZE_X/Y = 4` footprint. Depth sorts by the footprint's front edge;
the camera fits the world content (`Fit` button). Placement is footprint-aware (collision check) and selection
hit-tests the footprint. Panel actions add Move / Sell / Clear. `build/gen_itemmeta.php` emits
`itemmeta.json` (`{ name: [sizeX, sizeY, imageScale, cost] }`).

> **Isometric projection.** `app.js iso()` matches the original `IsoMath.tilePosToPixelPos`
> (ROTATION_0): `x = (gx-gy)*TILE_W/2`, `y = -(gx+gy)*TILE_H/2` — grid `(0,0)` at the FRONT (bottom),
> high coords at the BACK (top, toward the horizon). Verified 1:1 against the live Flash client
> (load the same farm with `?uid=<id>`); `?zoom=<n>` re-centres the view.

> **2026-10-09 fix — matrix conversion.** `swf2scene.js` previously decomposed
> `rotateSkew0/rotateSkew1` as cos/sin angles; swf-parser returns the raw SWF MATRIX 2×2, so the
> correct mapping is `[scaleX, rotateSkew0, rotateSkew1, scaleY]` (verified against FFdec SVG).
> The old code collapsed every rotated/skewed placement and gradient to a degenerate matrix
> (e.g. the sky gradient became a solid colour, rotated sub-parts of trees/buildings were garbled).
> Re-run `conv_scenes.js --force` / `regen_scenes.js` after any such fix. `regen_scenes.js`
> re-converts already-deployed scenes in place (resumable).

## Verified
- **7,743** world scenes converted (2,000 decorations, 2,000 trees, 1,591 buildings, 2,000 animals,
  + bloom/vehicle). The converter is resume-safe and dedupes by SWF; run it repeatedly with a larger
  budget to approach the ~74k unique placeable SWFs. `scenesbyname.json` maps item name → scene stem.
- Farm client renders placed decorations (headless screenshot); `npm run test:live` places a
  decoration via AMF and asserts persistence. Orientation variants (horizontal/vertical + mirror) wired.
- Remaining: full catalog coverage (long batch), rotation exactness.

---

# FV-NG — audio + market (M8a / M3a)

## Audio (M8a)
`gen_sounds.js` reads `client/assets/assethash.json`'s `sounds` category and emits
`fvng/sounds.json` (`{ originalName: hash }`). The client (`app.js sfx()`) resolves a named sound to
`assets/hashed/assets/sounds/<hash>.mp3` and plays it; plow/plant/harvest/coins/place/UI actions are
wired, with a mute toggle. 205 sounds (99 MP3s present).

## Market (M3a)
The client's Market panel fetches the DB-driven catalog at `/api/items` (Laravel) with search +
type filter and arms placement for any item that has a converted scene (`scenesbyname.json`).
64,813 buyable items. Purchase/storage is not yet implemented (server buy methods pending).

## Market + storage (M3a/M3b)
- Market panel: `/api/items` catalog (search + type filter) with a **Buy** button per item.
- **Buy** → `UserService.buyItemPutGiftbox(name, qty, forceGift)` deducts gold and adds to storage
  (`playermeta.inventory`). Server also: `getInventory`, `sellStoredItem` (5% refund),
  `consumeInventoryItem`.
- **Storage** panel lists inventory with **Place** (arms footprint-aware placement, consumes the
  item) and **Sell**.

## Localization, settings, buttons (M8b)
- `client/web/locales.json` — UI strings for 6 languages (`en, de_DE, es_ES, fr_FR, it_IT, pt_BR`);
  `app.js` applies them via `data-i18n` attributes and a locale selector (persisted).
- Settings persistence via `localStorage` (`audioOn`, `locale`, `uid`, camera `x/y/zoom`).
- **Buttons:** `DefineButton` → per-state display lists (`states.up/over/down/hit`) in `swf2scene.js`;
  `scene2d.js` renders the current `_buttonState` and exposes `buttonBoxes()` for hit-testing. The
  `scene-test.html` demo toggles up/over/down on hover/press. (`?btnstate=down` for screenshots.)

## Original UI dialogs (#3)
- `conv_dialogs.js` converts `dialogs/` SWFs → scenes (+ `dialogsbyname.json`); resume-safe,
  budgeted, checkpoints the map. Current: **1,432 dialog scenes / 2,903 mapped names**.
- `client/web/ui.js` `FVDialog` wraps an `FVScene` into a modal: fits the largest render target,
  dims the backdrop, tracks button up/over/down on hover/press, and routes clicks via
  `buttonBoxes()` — which now returns each button's **export/class name**.
- `client/web/app.js` dispatches clicked buttons by name (`market`/`storage`/`close`/…) and wires
  HUD **Help** + **Quest** buttons; `?dialog=<name>` opens directly. `ui-test.html` is a standalone
  preview. ESC closes; farm input is suspended while a dialog is open.

---

# FV-NG — base grass terrain (background)

The farm's grass field is a **tile map** (`Display.FarmTileMap` / `YimfMap`), not part of the theme
backdrop. Its tiles are embedded bitmaps in `FarmGame.swf` (`grass_base` + `grass_base_1..7`), so
they are not in the WARC asset set — extract them with FFdec:

```powershell
java -Xmx12g -jar "C:\Program Files (x86)\FFdec\ffdec.jar" -export image <outdir> ^
  "C:\Farmville\xampp\htdocs\public\farmville\embeds\Flash\v855037.855026\FarmGame.855037.855026.swf"
# then copy *_grass_base*.png -> fvng/grasstiles/ (grass_base.png, grass_base_1..7.png)
```

- `grasstiles.json` = `{ w, h, variants:[...] }` (native tile 50×25).
- `app.js bakeGrass()` tiles the whole world grid using the original per-tile hash
  (`abs(floor(sin(x*97+y)*214013)) % N`), **pixel-perfect at native resolution**, then scales the
  baked layer to the grid (`TILE_W/50`). Drawn over the theme backdrop, under objects.
- **Horizon / skybox:** the theme background is config-driven (server `xml/gz/v855038/yimf.xml` +
  `worldSettings.xml`). For `grass_theme`: `backgroundPath=assets/Environment/grass_themeBackground_`
  (variant `_n` where `n = (width-2)/4` → `_12` at 50-wide), `horizon=assets/Environment/grass_theme.swf`
  (clouds + distant hills), `skyColor=0xFF206FB1`, `renderBackgroundAtBottom` (env behind the grass).
  - The client renders into a fixed **1018×600** stage (the original `game.blade.php` embed size) so
    zoom/scroll/horizon match. Zoom range is the original `FarmIsoViewport` range
    (`0.302`…`2.0`, default `1.717`); our tiles are the original 25px tiles, so the zoom applies 1:1.
  - `conv_horizons.js` converts every `grass_themeBackground_{n}.swf` → `horizon_{n}.scene.json`;
    `grass_theme.swf` → `horizonstrip.scene.json`. All via the **full scene engine** (so river water,
    tree/hill textures and clouds render — the old `swf2svg.js` flattener dropped them).
  - `app.js drawGround()` layering, matching the original 1:1:
    1. **sky fill** (`skyColor`, `0xFF206FB1`);
    2. **sky strip** tiled at the top (`HORIZON_ZOOM_FACTOR = 1/3` → `zoom*3`, scroll factor 2/3)
       — the strip contains a **linear sky gradient**
       (`#206FB1` at the top → `#9EE9F2` light cyan at the horizon) plus clouds and distant hills. It
       is positioned lower than the field's back vertex (`oy + ih*0.3`) so the environment's
       hills/river (drawn on top) mask its lower edge;
    3. **environment** ("outside image") **behind** the grass, drawn at `zoom * OUTSIDE_IMAGE_SIZE_FACTOR`
       (`0.5`) and anchored on its **bounds centre** (the original centres the art on the field centre);
    4. **grass** tile map on top;
    5. **farm lot outline** (`drawOutline=true`, `outlineColor=0x3A6F29`) — a 2px diamond traced
       along the field edge (`FarmGameWorld.renderLotLine`).
- Verified: gradient sky (deep blue → light cyan) with clouds, textured hills, river with water and
  trees around the farm. The gradient required the matrix-conversion fix above.

## Plot sprites (crops + base)

`app.js` picks a plot's sprite by state (`stageFor`/`tileUrl`/`plotBaseUrl`):

- **Crop stages** — `croptiles/{stem}_{stage}.png` (`seeds`, `growing1`, `growing2`, `grown`, `super`,
  `withered`), extracted from the crop SWFs by `conv_crops.js`.
- **Base art (no crop)** — `plot_withered.png` for `STATE_FALLOW` and `plot_plowed.png` for
  `STATE_PLOWED`, matching `Classes/Plot.as setDisplayStatesForPlots`. These are the embedded bitmaps
  `Classes.EmbeddedArt_plot_withered` (`/_assets/777.png`) and `Classes.EmbeddedArt_plot_plowed`
  (`/_assets/694.png`) in `FarmGame.swf`; extract with FFdec (`-export image`, then copy `777.png` →
  `plot_withered.png` and `694.png` → `plot_plowed.png`).
- **Withering** — a crop withers at `plantTime + growTime * (witherMultiplier + randomRange*rand)`
  (`witherMultiplier=2.2`, `witherRandomRange=0.5`, `gameSettingsCMS.xml`); `isWithered()` applies this
  client-side so over-ripe crops render the `withered` stage like the original.
- **Scale / spacing** — the art is scaled so its full width = the footprint bounding width
  (`boxWidth = (sizeX+sizeY)*TILE_W/2`), matching `MapResource.updateDisplayObjectTransform`. The soil
  diamond is ~0.845 of the art, so adjacent plots leave the small gap seen in the original (do not add
  a fudge factor).

---

# FV-NG — capture-driven sprite manager

`conv_capture.js` closes the loop between the live-client AMF capture and the sprite set: it reads a
capture JSONL (the amfphp hook + `client/editor/amf_capture.js`), derives the **avatar items** and
**world objects** the live Flash client actually used, checks the deployed scene set, and converts any
missing SWFs via `swf2scene.js`. Parity is therefore automatic for any capture, not a one-off.

```bash
# from client/tools
node conv_capture.js C:/tmp/fvng_amf_capture.jsonl --dry          # report only (no writes)
node conv_capture.js C:/tmp/fvng_amf_capture.jsonl                # convert missing + update maps
node conv_capture.js <cap> --dialogs=CraftingMainWindow,MarketWindow   # force extra UI dialogs
```

- **Avatar items** — `initUser.userInfo.avatar.items[*].filename` → `av_<filename>.scene.json`, source
  `mylife/avatar_assets/<filename>.swf` (resolved via `assethash.json`).
- **World objects** — `world.objectsArray[*].itemName` → `scenesbyname.json` stem (new stems resolve
  through `build/item_assets.json` + the asset index, with a prefix-stripped fallback so
  `tree_lombardypoplar.swf` resolves from `lombardypoplar`).
- **Dialogs** — explicit `--dialogs=` plus any captured string matching a `dialogs/` SWF basename →
  `dlg_<sanitized>.scene.json`.
- Decode is shared with the report via `client/editor/amf_capture_lib.js` (AMF0 + the live client's
  AMF3-in-AMF0). `--source=flash` (default) restricts to the real client; `--all` includes the harness.
- Writes scenes to `<webroot>/farmville/fvng/scenes/` and refreshes `scenesbyname.json` /
  `dialogsbyname.json` (deployed + `client/web/`). Verified: a full re-convert of the captured
  avatar's `av_*` scenes is **byte-identical** to the deployed ones.





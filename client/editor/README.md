# FV-NG UI / Menu / Overlay Editor

A local web editor that imports FarmVille dialog/menu/overlay `.swf` assets, renders them on an
interactive canvas, and lets you **pick individual elements** to see exactly which decompiled AS3
handler each one maps to. Built on the existing `client/tools/swf2scene.js` exporter +
`client/web/scene2d.js` renderer — it does not duplicate that pipeline.

Scope: dialogs, menus (ActionMenu/ContextMenu), overlays, and data-driven (XML) dialogs.
**HUD is intentionally out of scope.**

## Run

```bash
# from the repo root (C:\Users\Remote\Desktop\FV-NG)
node client/editor/start.js 8787        # detaches a server on port 8787
# then open http://localhost:8787/
```

`start.js` spawns `server.js` fully detached (survives the launching shell), writes its pid to
`build/editor-server.pid`, and logs to `build/editor-server.log`. To stop it, kill that pid.

> The plain `node client/editor/server.js [port]` also works in a foreground terminal, but this
> environment's background wrapper kills long-lived node with "stdin is not a tty" — use the
> detached launcher (or a normal terminal) to keep it alive.

## What you can do

- **Search** dialogs/menus/overlays by name or asset key (left panel). Defaults to "mapped only"
  (assets referenced by at least one decompiled class); uncheck to see all ~5,200 dialog SWFs.
- **Pick an element** on the canvas — click any button/text/sprite. The inspector shows its
  instance name, type, bounds, and every decompiled handler bound to that name.
- **Accuracy join** is by *instance name* (e.g. `accept_bt`). Because names are reused across many
  dialogs, the inspector **leads with this dialog's own class** ("this dialog") and demotes
  same-name bindings from other classes. If this dialog's class does not bind that name at all, it
  says so explicitly instead of attributing another dialog's handler to this asset.
- **Jump to source**: every handler links to `/src/<Class.as>#L<line>` — the decompiled AS3 line.
- **Report** button: a verification report (see below).

## The accuracy model (how "functions mapped" is verified)

1. `api/indexer.js` scans all decompiled `.as` files and extracts, per class: asset paths,
   button/click/shortcut bindings (element instance name → handler method + line), and text fields.
   Output: `build/uiindex/index.json`.
2. `api/converter.js` converts an SWF→scene **on demand** using the current `swf2scene.js`, which
   captures **instance names** on placements. (The 1,434 *deployed* scenes predate name-capture and
   are used only as a fallback — fresh conversions are cached under `build/scenes/`.)
3. The join key is the instance-name leaf: code `m_window.popupBox_mc.accept_bt` → `accept_bt`
   matches placement `name:"accept_bt"` in the scene.

### Verification report (`GET /api/report`)

Cross-references every button/click binding against the fresh named conversion of its asset and
reports:
- **buttons in art** — bound element names that exist in the rendered scene (mapped ✓)
- **unmapped buttons** — bound names with no matching element (often dynamically-created controls,
  e.g. `m_checkbox1`, or a name the indexer captured but that isn't in this SWF)
- **assets not convertible** — classes whose asset has no on-disk SWF / failed conversion

First run converts every asset-with-bindings (~30–40s); subsequent runs are cached (sub-second).
The report builder lives in `api/report.js` (unit-testable without a port); the server only caches it.

## Dispatch map (`GET /api/dispatch`)

A machine-consumable build artifact for client ports: asset → scene stems + per-instance handler
metadata, derived from the AS3 index. Shape:

- `byAsset["assets/dialogs/X.swf"]` → `{ stems:[…], byLeaf:{ accept_bt:[{cls,handler,kind,line,file,full},…] } }`
- `byAssetBase["X"]` → same entry keyed by base name (for stem-based lookup)
- `byLeaf` → across all assets; `shortcuts` → shortcut-key bindings kept apart (not scene instances)

Regenerated in lockstep whenever the index is rebuilt, or on demand:
`node client/editor/api/dispatch.js`. The editor's **Export dispatch** button downloads it as a
Blob; each inspector mapping has a copy button (`<leaf> -> <handler> (<file>:<line>)`).

## API

| Route | Purpose |
|---|---|
| `GET /api/health` | liveness |
| `GET /api/index` | the AS3 index (classes, assets, bindings, stats) |
| `GET /api/manifest` | every dialog SWF + conversion state + referencing classes |
| `GET /api/convert?key=<asset key \| dlg_ stem>` | fresh named scene JSON (disk-cached) |
| `GET /api/report` | verification report |
| `GET /api/dispatch` | dispatch map (asset → stems + per-instance handler metadata) |
| `GET /lib/*` | the shared renderer (`scene2d.js`, etc.) from `client/web/` — no copy/drift |
| `GET /src/*` | decompiled AS3 source (relative to `decompiled/farmgame/scripts/`) |

## Files

```
client/editor/
  server.js        zero-dep Node dev server (APIs + static)
  start.js         detached launcher (pid/log files under build/)
  index.html       SPA shell
  app.js           canvas render + picking + inspector + report UI
  style.css        dark editor theme
  config.js        single source of truth for paths/ports (repoRoot derived; env + editor.config.json overrides)
  api/indexer.js   AS3 -> index.json (asset paths + bindings + text fields); regenerates dispatch.json
  api/converter.js on-demand SWF->scene with name capture + disk cache
  api/dispatch.js  build uiindex/dispatch.json (CLI) + buildDispatch() for the server
  api/report.js    verification report builder (unit-testable, no port binding)
  editor_test.js   unit tests (§11.1: config/resolveKey/convert/cache/dispatch/report/overlay)
  e2e_test.js      integration tests (§11.2: spawns the real server, asserts over HTTP)
client/tools/
  _loader.js       re-exports swf-parser (ESM-only) + swf2scene for modules outside client/tools
build/
  uiindex/index.json   the generated index
  uiindex/dispatch.json the generated dispatch map
  scenes/*.scene.json  fresh named conversions (cache)
  editor-server.{pid,log}
```

## Configuration

`config.js` derives `repoRoot` from its own location (no hardcoded absolute path), so the editor is
portable. Precedence (low → high): built-in defaults < `client/editor/editor.config.json`
(`__*` keys ignored) < environment (`FV_HASHED_ROOT`, `FV_DEPLOY_SCENES`, `EDITOR_PORT`). Keys:

| Key | Meaning | Default |
|---|---|---|
| `indexSourceDir` | decompiled AS3 to scan | `<root>/decompiled/farmgame/scripts` |
| `indexFile` / `dispatchFile` | generated index + dispatch map | `<root>/build/uiindex/*.json` |
| `sceneCacheDir` | fresh named conversions | `<root>/build/scenes` |
| `assethashFile` | asset name → sha1 map | `<root>/client/assets/assethash.json` |
| `dialogsByNameFile` | stem → scene-name map | `<root>/client/web/dialogsbyname.json` |
| `deployedSceneDir` | legacy deployed scenes (reference only) | `C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes` |
| `swfHashedRoot` | hashed SWF tree root | `C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets` |
| `categories` | asset categories in scope (HUD excluded) | `["dialogs", "overlays"]` |
| `port` | dev server port | `8787` |

## Tests

```bash
# from the client/ directory (where package.json lives)
npm run test:editor        # unit: node editor/editor_test.js   (no server, no network)
npm run test:editor:e2e    # integration: spawns the real server on :8790, asserts over HTTP
npm run test:scene         # shared pipeline regression (must stay green after any frozen-file edit)
```

The e2e suite uses port `8790` by default; override with `EDITOR_TEST_PORT`.

## Rebuilding the index

If decompiled code changes: `node client/editor/api/indexer.js` (regenerates `build/uiindex`).

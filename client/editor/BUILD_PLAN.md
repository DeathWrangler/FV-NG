# FV-NG UI / Menu / Overlay Editor — Build Plan (local-model execution spec)

> **Audience:** an autonomous local code model. Follow tasks **in order**. Each task has a stable ID,
> exact files, exact steps, **Acceptance** criteria, and a **Verify** command. Do not skip Verify.
> If a Verify fails, fix and re-run before moving on. If a fact you need is not in this document,
> **read the referenced file — never invent an API, path, or field.**

---

## 0. How to use this document

- Work milestones M0 → M7. Do not reorder.
- One task = one commit-sized change. Run the task's **Verify** after each.
- The **Master checklist** (§12) is the source of truth for progress. Update it as you go.
- The **E2E** spec (§11) is mandatory before declaring done.
- If you must deviate from a step, record why in `client/editor/NOTES.md` (create it) and stop if unsure.

---

## 1. Mission

Turn the existing `client/editor/` review tool into a pipeline-grade editor that:

1. Runs **portably** (no hardcoded absolute paths; configurable, CI-friendly).
2. Covers **dialogs + overlays** (and is extensible to menus), not just the `dialogs` category.
3. Emits a **machine-consumable dispatch map** (`build/uiindex/dispatch.json`) that the client port
   (`client/web/ui.js` `FVDialog` and the future Widgets port) can use for **named-button dispatch**.
4. Is **correct** (no misleading errors, no misplaced hit/overlay boxes, no two-source-of-truth).
5. Is **fast and non-blocking** (cached, in-memory scene cache, cached manifest/report).
6. Is **verified** by an automated test suite (`client/editor/editor_test.js` + `e2e_test.js`).

**Out of scope:** the HUD (per the existing README). Do not port game logic. Do not edit
`client/tools/swf2scene.js` or `client/web/scene2d.js` (shared pipeline) except where a task
explicitly says so; if you do, you **must** re-run `npm run test:scene`.

---

## 2. Environment & constraints

- OS: Windows 10/11. Shell: **PowerShell 5.1**. Do not use `&&`; use `;` or `if ($?) { ... }`.
- Node: **v24** (CommonJS works; ESM-only `swf-parser` is pulled via `client/tools/_loader.js`).
- **Zero external npm dependencies** in `client/editor/`. Use Node built-ins only
  (`fs`, `path`, `http`, `child_process`, `url`, `zlib`).
- Do not use `rg`. Use `Get-ChildItem`, `Select-String`, `Get-Content`.
- Keep the existing dark editor theme; do not redesign the UI.
- Code style: match the files you edit. **No comments unless a step asks for one.**
- Never commit secrets. Never delete unrelated files.

**Canonical commands (run from `C:\Users\Remote\Desktop\FV-NG`):**

```powershell
# shared pipeline regression (must stay green after any shared-file edit)
Set-Location C:\Users\Remote\Desktop\FV-NG\client; npm run test:scene
# editor unit tests (you will add these)
node C:\Users\Remote\Desktop\FV-NG\client\editor\editor_test.js
# editor end-to-end tests (you will add these)
node C:\Users\Remote\Desktop\FV-NG\client\editor\e2e_test.js
```

---

## 3. Repo map (read these before starting)

| Path | Role |
|---|---|
| `client/editor/server.js` | zero-dep dev server: `/api/*`, `/lib/*`, `/src/*`, static SPA |
| `client/editor/start.js` | detached launcher (pid/log under `build/`) |
| `client/editor/app.js` | SPA: canvas render + picking + inspector + report |
| `client/editor/index.html` | SPA shell (loads `/lib/scene2d.js` then `app.js`) |
| `client/editor/style.css` | theme |
| `client/editor/api/indexer.js` | AS3 → `build/uiindex/index.json` |
| `client/editor/api/converter.js` | on-demand SWF → scene (+ disk cache) |
| `client/editor/api/_verify_idx.js` | ad-hoc index dump (dev only) |
| `client/tools/_loader.js` | exports `parseSwf`, `swfToScene` |
| `client/tools/swf2scene.js` | SWF → scene exporter (**do not edit without task**) |
| `client/web/scene2d.js` | `FVScene` renderer (**do not edit without task**) |
| `client/web/ui.js` | `FVDialog` modal (integration target in M6) |
| `client/assets/assethash.json` | `{ <category>: { "<key>.swf": "<hash>" } }` (64 categories) |
| `client/web/dialogsbyname.json` | `{ <name-or-key>: "dlg_<stem>" }` |
| `build/uiindex/index.json` | generated index (M2) |
| `build/scenes/*.scene.json` | on-demand conversions (cache) |
| `build/editor-server.{pid,log}` | launcher artifacts |

---

## 4. Data contracts (do not change shapes without updating every consumer)

### 4.1 `build/uiindex/index.json` (indexer output; current shape)
```jsonc
{
  "generatedAt": "ISO",
  "root": "<abs path>",
  "stats": { "filesScanned": 6117, "uiClasses": 829, "assets": 918, "leaves": 192 },
  "classes": [{
    "file": "FarmGame/Widgets/.../Foo.as",   // relative to decompiled/farmgame/scripts
    "cls": "Foo", "pkg": "Widgets...", "extends": "Dialog",
    "assets": [{ "path": "assets/dialogs/FV_x.swf", "line": 12 }],
    "assetPrimary": "assets/dialogs/FV_x.swf" | null,
    "dddNames": ["X"], "isDDD": true|false,
    "bindings": [{ "element","leaf","full","handler","kind","line","raw" }],
    "textFields": [{ "element","leaf","full","line" }],
    "sounds": ["x"]
  }],
  "byAsset": { "assets/dialogs/FV_x.swf": [{ "cls","file","primary"? }] },
  "byLeaf":  { "accept_bt": [{ "cls","handler","kind","element","line","file" }] }
}
```
`kind ∈ { "button", "click", "shortcut", "ddd_button" }`.

### 4.2 scene JSON (`build/scenes/<key>.scene.json`, from `swfToScene`)
```jsonc
{ "meta": { "scale": 20, "frameRate": 24, "source": "<asset key>" },
  "characters": { "<id>": { "type": "shape|sprite|bitmap|text|button", ... } },
  "fonts": {}, "exports": { "<ClassName>": <id> },
  "frames": [ [ { "depth","char","m":[a,b,c,d,tx,ty],"ct","name":<instance name|null>, ... } ] ] }
```
Instance name is `placement.name`; buttons only exist as characters (their states hold placements).

### 4.3 `assethash.json`
`{ "<category>": { "<key possibly with subdir>.swf": "<sha1>" } }`. Relevant categories:
`dialogs` (10,878), `overlays` (26), `hud` (1,441), `misc` (455). The SWF on disk lives at
`<swfHashedRoot>/<category>/<hash>.swf` where `<swfHashedRoot>` default is
`C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets`.

### 4.4 `dialogsbyname.json`
`{ "<baseOrKey>": "dlg_<stem>" }`, e.g. `"FV_delete_confirm": "dlg_FV_delete_confirm"`.
The `dlg_<stem>` names are the **deployed** scene filenames (no instance names). Editor conversions
are cached separately under `build/scenes/`.

---

## 5. Milestone M0 — Config & portability (P1-4)

**Goal:** remove hardcoded absolute paths; one config module used by all editor files.

### M0-1 · Create `client/editor/config.js`
- Module (CommonJS) exporting a frozen config object. Derive `repoRoot` from `__dirname`
  (`path.resolve(__dirname, '..', '..')`).
- If `client/editor/editor.config.json` exists, shallow-merge it over defaults (keys with `__comment` ignored).
- Also allow env overrides: `FV_HASHED_ROOT`, `FV_DEPLOY_SCENES`, `EDITOR_PORT`.
- Required keys:
  ```js
  {
    repoRoot,                       // repo root
    indexSourceDir,                 // <repoRoot>/decompiled/farmgame/scripts
    indexFile,                      // <repoRoot>/build/uiindex/index.json
    dispatchFile,                   // <repoRoot>/build/uiindex/dispatch.json
    sceneCacheDir,                  // <repoRoot>/build/scenes
    assethashFile,                  // <repoRoot>/client/assets/assethash.json
    dialogsByNameFile,              // <repoRoot>/client/web/dialogsbyname.json
    deployedSceneDir,               // env FV_DEPLOY_SCENES || 'C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes'
    swfHashedRoot,                  // env FV_HASHED_ROOT || 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets'
    categories,                     // ['dialogs','overlays']
    port                            // env EDITOR_PORT || 8787
  }
  ```
- Export `loadConfig(overrides)` and a default `config` instance.

**Acceptance:** `node -e "console.log(require('./client/editor/config.js'))"` prints the object; no
`C:/Users/Remote/Desktop/FV-NG` literal remains in `config.js` (repoRoot is derived).

### M0-2 · Migrate `server.js`, `start.js`, `converter.js`, `indexer.js` to config
- Replace every `const ROOT = 'C:/Users/Remote/Desktop/FV-NG'` etc. with `require('./config.js')`
  (`'./config.js'` from `api/` is `'../config.js'`).
- `indexer.js` must also accept `--out <path>` (default `config.indexFile`) and
  `--src <dir>` (default `config.indexSourceDir`).
- Keep behavior identical otherwise.

**Verify:** start server (`node client/editor/server.js 8788`) and
`Invoke-RestMethod http://localhost:8788/api/health` returns `{ok:true,...}`. Stop the test server.

---

## 6. Milestone M1 — Correctness fixes (P0-1..P0-5, P2-1, P2-2)

### M1-1 · JSON API errors (P0-1)
- In `server.js` add `function sendJson(res, code, obj) { send(res, code, JSON.stringify(obj), MIME['.json']); }`.
- All `/api/*` routes use `sendJson`. Convert failure route returns
  `sendJson(res, 404, { ok:false, error: e.message })`.
- In `app.js` `selectAsset()`: replace `fetch(...).then(r => r.json())` with:
  ```js
  const resp = await fetch('/api/convert?key=' + encodeURIComponent(key));
  const r = resp.ok ? await resp.json() : { ok:false, error: await resp.text() };
  if (!r.ok) throw new Error(r.error || ('HTTP ' + resp.status));
  ```

**Acceptance:** requesting a bad key yields a **JSON** body `{ok:false,error:...}` with HTTP 404, and
the UI shows the real message.

### M1-2 · MIME key bug (P0-2)
- `MIME` keys are `.html/.js/.css/.json/.png/.svg`. Every `MIME.json` use must become `MIME['.json']`
  (also `/lib/*` and `/src/*` already use `MIME[ext]`, verify).

**Verify:** `curl.exe -i http://localhost:8787/api/index` (or `Invoke-WebRequest`) shows
`Content-Type: application/json`.

### M1-3 · Nested-button overlay box (P0-3)
- `FVScene.buttonBoxes()` already returns absolute scene-space boxes
  (`scene2d.js:266-291`) including `{x0,y0,x1,y1,char,name}`.
- In `app.js`:
  - In `pickAt`, when pushing a button candidate, store the box: `{ kind:'button', char, name, box:{x0,y0,x1,y1}, prio:3 }`.
  - In `overlayBox(desc)`, if `desc.box` exists, transform it with the current view directly
    (`x*scale+tx`, etc.) instead of recomputing via `buttonMatrix`. Delete `buttonMatrix()` if it
    becomes unused.
  - Keep the named-placement path (uses `desc.m`) unchanged.

**Acceptance:** selecting/hovering a button nested inside a sprite draws its box exactly over the
button (not at the scene origin).

### M1-4 · Single source of truth for scenes (P0-4)
- Make `build/scenes/` canonical for editor conversion state.
- In `server.js` `buildManifest()`: `converted` and `stem` come from the converter/cache
  (`config.sceneCacheDir`), not `deployedSceneDir`. Add a `deployed` boolean for the old dir.
- `/api/scene` may keep serving `deployedSceneDir` but must be documented as legacy; prefer
  `/api/convert`. Do not silently mix them in one field.

**Acceptance:** a row whose asset has a fresh `build/scenes` conversion reports `converted:true`
even if no deployed scene exists, and vice versa.

### M1-5 · Asset key collisions (P0-5)
- In `app.js` `buildIndexes()`, key `classesByAsset` by **full asset key** (e.g.
  `assets/dialogs/FV_x.swf`) **and** by basename-without-ext as a secondary map.
- `renderAssetList`/`showAssetInspector` look up by `MANIFEST` row `key` first, then basename.

**Acceptance:** two different subdir assets with the same filename show their own class lists.

### M1-6 · Remove dead code / dead UI (P2-1, P2-2)
- Delete `resolveAsset()` from `server.js` (unused) **or** use it consistently in `buildManifest`;
  choose delete unless you adopt it in M1-4.
- Remove the unused `#results` dropdown from `index.html` **or** implement it. Prefer **remove**
  (search already filters the left list); also remove now-dead `.results` CSS rules.

---

## 7. Milestone M2 — Indexer: coverage & robustness (P1-6, P1-7, category tagging)

### M2-1 · Multi-line + broader capture (`api/indexer.js`)
- Pre-process each file: join a line with the next when the current line has an unbalanced `(` or ends
  with a `,`/operator inside a call; match regexes on the joined logical line. Preserve original line
  numbers for `line` fields.
- Broaden click events: match `addEventListener\s*\(\s*MouseEvent\.(CLICK|MOUSE_DOWN|MOUSE_UP|DOUBLE_CLICK|ROLL_OVER|ROLL_OUT)`.
- Set `assetPrimary` from **any** `m_dialogAsset` assignment even if the literal is on the next line.
- Keep `kind` values exactly as today (add new kinds only if needed; document them).

### M2-2 · Separate shortcut vs element bindings
- `setShortcutListener("<name>", ...)` captures a shortcut **key**, not a SWF instance name. Keep
  `kind:'shortcut'` but add `slot: <name>`; do **not** treat `leaf` as a scene instance for mapping.
- The report (M3) must not count `shortcut` as "unmapped button".

### M2-3 · Category tagging
- Determine an asset's category from its path: the segment after `assets/` (e.g.
  `assets/dialogs/FV_x.swf` → `dialogs`; `assets/overlays/x.swf` → `overlays`). Add `category` to each
  `assets[]` entry and a top-level `categories: { <cat>: <count> }` in the index stats.

### M2-4 · Regenerate & verify
**Verify:** `node client/editor/api/indexer.js` writes `build/uiindex/index.json`; then run
`node client/editor/api/_verify_idx.js` — `DeleteConfirm` still shows 3 button + 2 click bindings.

**Acceptance:** index stats include `categories`; `DeleteConfirm.bindings` unchanged in content.

---

## 8. Milestone M3 — Converter coverage, caching & report (P1-2, P1-3, P1-8, P1-5)

### M3-1 · Category-aware converter (`api/converter.js`)
- Read `config.categories` (from M0). `resolveKey()` searches **all** configured categories'
  maps in `assethash.json`, not just `dialogs`.
- `swfPathFor(key)` resolves the category from the key (`assets/<cat>/<name>.swf` → `<cat>`), falling
  back to scanning configured categories for the basename. SWF dir =
  `path.join(config.swfHashedRoot, category, hash + '.swf')`.
- `cachePathFor()` unchanged (sanitizes `key` → `__`, under `config.sceneCacheDir`).

### M3-2 · In-memory scene cache (P1-3, P1-8)
- Add an LRU `Map` (max 24 entries, insertion-order eviction) keyed by canonical asset key.
- `convert()` returns the cached parsed scene when present; only disk-reads on miss.
- Export `clearCache()` for tests.

### M3-3 · Cache manifest & report; non-blocking report (P1-3, P1-8)
- Cache `buildManifest()` and `buildReport()` results keyed by:
  `index.json` mtime + assethash mtime + a `bump` counter. `GET /api/manifest?refresh=1` (and
  `report`) bypasses the cache.
- Build report cooperatively: process classes in chunks of 50 using `setImmediate`, so the event
  loop can serve other requests. (Simplest acceptable alternative: build once on first request and
  serve the cached result thereafter, with a `building:true` placeholder for concurrent callers.)

### M3-4 · Graceful port bind (P1-5)
- In `server.js`: `server.on('error', ...)`; on `EADDRINUSE` log `port in use` and `process.exit(1)`
  (no stack dump).
- In `start.js`: before spawning, probe `http://localhost:<port>/api/health`; if it responds, print
  `already running` and exit 0. Only spawn if the probe fails.

**Verify:**
```powershell
node client/editor/server.js 8790 ; # leave running in one shell, then in another:
Invoke-RestMethod "http://localhost:8790/api/convert?key=FV_delete_confirm.swf" | Select-Object ok,key,fromCache
Invoke-RestMethod "http://localhost:8790/api/convert?key=__missing__" -SkipHttpErrorCheck
```
(Second call must be JSON `{ok:false,...}`.) Stop the test server.

---

## 9. Milestone M4 — Dispatch export for the pipeline (P1-1)

**Goal:** a build artifact the port consumes.

### M4-1 · `client/editor/api/dispatch.js`
```js
// buildDispatch(index) -> dispatch object
// {
//   generatedAt,
//   byAsset: { "assets/dialogs/FV_delete_confirm.swf": {
//       stems: ["dlg_FV_delete_confirm"],
//       byLeaf: { "accept_bt": [ {cls,handler,kind,line,file,full}, ... ] }
//   }, ... },
//   byAssetBase: { "FV_delete_confirm": <same as byAsset entry>, ... },
//   byLeaf: { "accept_bt": [ {cls,asset,handler,kind,line,file,full}, ... ] }
// }
module.exports = { buildDispatch };
```
- Resolve `stems` via `dialogsbyname.json` (both `base` and full `key`).
- Only include `kind ∈ {button, click, ddd_button}` in `byAsset`; keep `shortcut` in a separate
  `shortcuts` array.
- Add `node client/editor/api/dispatch.js` CLI mode that writes `config.dispatchFile` and prints stats.

### M4-2 · Server route
- `GET /api/dispatch` → `sendJson(200, dispatch)` (cached like manifest; `?refresh=1` bypass).
- Add `client/editor/api/indexer.js` step (or a separate command) so `dispatch.json` is regenerated
  whenever `index.json` is; document the command in README.

### M4-3 · Editor UI
- Add an **"Export dispatch"** button in `#topbar` that downloads `dispatch.json`
  (`window.open('/api/dispatch')` or a Blob download).
- In the element inspector, when a mapping is shown, add a **"copy"** button that copies
  `<leaf> -> <handler> (<file>:<line>)`.

**Acceptance:** `build/uiindex/dispatch.json` exists; `byAsset["assets/dialogs/FV_delete_confirm.swf"].byLeaf.accept_bt[0].handler === "onAcceptClick"`.

### M4-4 (guarded integration) · `client/web/ui.js`
- Optional. Add an opt-in `dispatch` argument to `FVDialog.open(url, { dispatch })` so
  `onButton(name)` can resolve `handler` metadata. **Do not change default behavior.** If you edit
  `ui.js`, re-run `npm run test:scene` (shared pipeline) and keep it green.

---

## 10. Milestone M5 — UI polish (P2-3..P2-6) — only if time remains and E2E is green

- **M5-1** Memoize `sceneHasLeaf` per selection (build a name/type Set once when a scene loads).
- **M5-2** In the element inspector, show the matched **type** for "in art" (button vs text), so
  mis-joins are visible.
- **M5-3** Show report progress state while `building:true`.
- **M5-4** (optional) Serve `/api/index` gzipped when the client sends `Accept-Encoding: gzip`.

---

## 11. End-to-end testing specification

### 11.1 `client/editor/editor_test.js` (unit; no server)
Follow the existing harness style (`client/tools/test_scene.js:13-14`): a `passed` counter, a
`fails` array, `ok(name, cond, detail)`, `process.exit(fails.length ? 1 : 0)`.

Cases (each must print PASS/FAIL):
1. **config**: `loadConfig()` has all required keys; `repoRoot` equals repo root; overriding
   `port` works.
2. **resolveKey (categories)**: `resolveKey('FV_delete_confirm.swf')` and
   `resolveKey('dlg_FV_delete_confirm')` both resolve to an existing key.
3. **convert real asset**: `convert('FV_delete_confirm.swf')` returns a scene with
   `characters` non-empty and at least one placement with `name === 'accept_bt'`.
4. **scene cache**: second `convert()` returns the same object identity (in-memory cache) and
   `fromCache:true`.
5. **convert miss**: `convert('__definitely_missing__')` throws (caught) with a message; does not
   crash.
6. **dispatch**: `buildDispatch(index)` for `FV_delete_confirm.swf` has `byLeaf.accept_bt[0].handler
   === 'onAcceptClick'`; `shortcuts` is an array; `byAssetBase` key exists.
7. **report**: `buildReport()` returns numeric stats and includes `accept_bt` **not** in
   `unmappedButtons` while `m_checkbox1`/`m_checkbox2` **are** (naming mismatch is expected).
8. **overlay**: construct a fake `FVScene`-like object OR use the real renderer if `Path2D` is
   unavailable to skip; assert that a button candidate's stored `box` equals the corresponding
   `buttonBoxes()` entry (pure-JS check, no canvas needed).

### 11.2 `client/editor/e2e_test.js` (integration; spawns the real server)
- Spawn `node client/editor/server.js <TESTPORT>` (use `8789` or a free port) via
  `child_process.spawn`, cwd = repo root, stdio ignored.
- Poll `GET /api/health` until ready (max ~10 s); fail with exit 2 on timeout.
- Assertions (all via `fetch`):
  1. `/api/health` → `{ok:true}`.
  2. `/api/index` → HTTP 200, `Content-Type` contains `application/json`, `stats.uiClasses > 0`.
  3. `/api/manifest` → `count > 0`; a row for `FV_delete_confirm` has `converted:true`.
  4. `/api/convert?key=FV_delete_confirm.swf` → `{ok:true}`, scene has a placement named `accept_bt`.
  5. `/api/convert?key=__missing__` → HTTP 404 **and** body parses as JSON with `ok:false`.
  6. `/api/report` → has `mappedButtons` (number) and `unmappedButtons` (array); a second call
     returns the **same** `generatedAt` (cached) in < 1000 ms.
  7. `/api/dispatch` → `byAssetBase.FV_delete_confirm.byLeaf.accept_bt[0].handler === 'onAcceptClick'`.
  8. `/lib/scene2d.js` → HTTP 200, `Content-Type` includes `javascript`.
  9. Path traversal: `/src/../../../../Windows/win.ini` → HTTP 403 or 404 (never 200 with file data).
- Always `child.kill()` the server in a `finally`; exit 0 only if all pass.

### 11.3 Manual browser E2E checklist (no automation dep available)
Run `node client/editor/start.js 8787`, open `http://localhost:8787/`, then confirm:
- [ ] Search finds `FV_delete_confirm`; selecting it renders the dialog.
- [ ] Clicking the accept button highlights it **exactly** (M1-3) and the inspector shows
      `accept_bt → onAcceptClick` tagged "this dialog".
- [ ] Selecting a checkbox shows `m_checkbox1/m_checkbox2` as unmapped (expected mismatch).
- [ ] The asset inspector marks `accept_bt` "in art" and `m_checkbox1` "not in art".
- [ ] Report modal opens with non-zero stats without freezing the UI (M3-3).
- [ ] "Export dispatch" downloads valid JSON.
- [ ] Zoom/pan/fit still work; wheel-zoom centers on the cursor.

---

## 12. Master checklist

### M0 — Config & portability
- [x] M0-1 create `config.js` (repoRoot derived; env + `editor.config.json` overrides)
- [x] M0-2 migrate `server.js`, `start.js`, `converter.js`, `indexer.js` to config
- [x] no hardcoded `C:/Users/Remote/Desktop/FV-NG` remains (except as documented env defaults)

### M1 — Correctness
- [x] M1-1 JSON API errors (`sendJson`, 404 `{ok:false}`, client `r.ok` handling)
- [x] M1-2 `MIME['.json']` everywhere
- [x] M1-3 nested-button overlay box (store box in `pickAt`; use in `overlayBox`)
- [x] M1-4 `build/scenes` canonical for `converted`; add `deployed` flag
- [x] M1-5 asset key collisions (full-key map + basename fallback)
- [x] M1-6 remove dead `resolveAsset` + `#results` (and its CSS)

### M2 — Indexer
- [x] M2-1 multi-line + broader MouseEvent capture; assetPrimary across lines
- [x] M2-2 `shortcut` separated (`slot`), not treated as scene instance
- [x] M2-3 category tagging in assets + stats
- [x] M2-4 regenerate index; `_verify_idx.js` still shows DeleteConfirm 3 button + 2 click

### M3 — Converter & server
- [x] M3-1 category-aware `resolveKey`/`swfPathFor` (dialogs + overlays)
- [x] M3-2 LRU in-memory scene cache
- [x] M3-3 cached manifest/report (`?refresh=1`), non-blocking report
- [x] M3-4 graceful `EADDRINUSE`; `start.js` health probe

### M4 — Dispatch
- [x] M4-1 `api/dispatch.js` + CLI writing `build/uiindex/dispatch.json`
- [x] M4-2 `GET /api/dispatch` (cached)
- [x] M4-3 Export button + per-mapping copy in inspector
- [ ] M4-4 (optional, guarded) `ui.js` dispatch wiring + `npm run test:scene` green

### M5 — Polish (optional)
- [ ] M5-1 memoize `sceneHasLeaf`
- [ ] M5-2 show matched type for "in art"
- [ ] M5-3 report "building" state

### M6 — Tests & docs
- [x] `editor_test.js` (all §11.1 cases PASS)
- [x] `e2e_test.js` (all §11.2 cases PASS)
- [x] add `"test:editor": "node editor/editor_test.js"` and
      `"test:editor:e2e": "node editor/e2e_test.js"` to `client/package.json`
- [x] update `client/editor/README.md`: config keys, `/api/dispatch`, test commands, category scope
- [x] re-run `npm run test:scene` (shared pipeline) — must stay green

---

## 13. Guardrails (do not violate)

1. **Derive, never invent.** If a field/API/path is unknown, read the source file.
2. **Backward compatibility.** Existing routes (`/api/index`, `/api/manifest`, `/api/convert`,
   `/api/report`, `/api/scene`, `/lib/*`, `/src/*`) keep working; only additive changes.
3. **Shared files are frozen** (`swf2scene.js`, `scene2d.js`) unless a task says so; after any such
   edit run `npm run test:scene` and keep it green.
4. **No new npm dependencies.** No network access at build time.
5. **Fail loudly in tests, quietly in prod.** Server errors return JSON; never crash the process on a
   bad request.
6. **Keep the diff minimal and focused.** No reformatting of untouched code, no renames outside scope.
7. **Stop and ask (write to `NOTES.md` and halt)** if acceptance cannot be met without changing a
   contract in §4 or editing a frozen file.

---

## 14. Definition of Done

- All M0–M4 checklist items checked; M5 optional.
- `editor_test.js` and `e2e_test.js` exit 0.
- `npm run test:scene` stays green.
- `client/editor/README.md` documents: config, category scope, `/api/dispatch`, and how to run both
  test suites.
- Manual browser E2E checklist (§11.3) fully checked.

---

## 15. Appendix — known-good fixture expectations (use in tests)

Asset key: `assets/dialogs/FV_delete_confirm.swf` (basename `FV_delete_confirm.swf`), scene cached at
`build/scenes/FV_delete_confirm.swf.scene.json`, class `DeleteConfirm extends Dialog`.

Bindings (from `index.json`):
| leaf | handler | kind | line | in scene? |
|---|---|---|---|---|
| `accept_bt` | `onAcceptClick` | button | 54 | **yes** |
| `cancel_bt` | `onCancelClick` | button | 56 | **yes** |
| `whatisthis_mc` | `onWhatClick` | button | 58 | **yes** |
| `m_checkbox1` | `onCheck1Click` | click | 112 | no (scene has `checkbox1_mc`) |
| `m_checkbox2` | `onCheck2Click` | click | 113 | no (scene has `checkbox2_mc`) |

Scene instance names include: `popupBox_mc, accept_bt, cancel_bt, whatisthis_mc, generic_tf,
popupBox_tf, option1_tf, option2_tf, checkbox1_mc, checkbox2_mc`.

Expected report for this asset: `accept_bt`, `cancel_bt`, `whatisthis_mc` mapped;
`m_checkbox1`, `m_checkbox2` unmapped.

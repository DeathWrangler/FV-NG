// FV-NG UI Editor — single source of truth for paths/ports. No hardcoded absolute repo path:
// repoRoot is derived from this file's location, so the editor runs portably / in CI.
// Overrides (lowest -> highest precedence): defaults < client/editor/editor.config.json
// (keys named __* ignored) < environment (FV_HASHED_ROOT, FV_DEPLOY_SCENES, EDITOR_PORT).
'use strict';
const fs = require('fs');
const path = require('path');

function loadConfig(overrides) {
  const repoRoot = path.resolve(__dirname, '..', '..');
  const defaults = {
    repoRoot,
    indexSourceDir: path.join(repoRoot, 'decompiled/farmgame/scripts'),
    indexFile: path.join(repoRoot, 'build/uiindex/index.json'),
    dispatchFile: path.join(repoRoot, 'build/uiindex/dispatch.json'),
    sceneCacheDir: path.join(repoRoot, 'build/scenes'),
    assethashFile: path.join(repoRoot, 'client/assets/assethash.json'),
    dialogsByNameFile: path.join(repoRoot, 'client/web/dialogsbyname.json'),
    deployedSceneDir: 'C:/Farmville/xampp/htdocs/public/farmville/fvng/scenes',
    swfHashedRoot: 'C:/Farmville/xampp/htdocs/public/farmville/assets/hashed/assets',
    categories: ['dialogs', 'overlays'],
    port: 8787,
  };
  const fileCfgPath = path.join(__dirname, 'editor.config.json');
  let fileCfg = {};
  if (fs.existsSync(fileCfgPath)) {
    try {
      const raw = JSON.parse(fs.readFileSync(fileCfgPath, 'utf8'));
      for (const k of Object.keys(raw)) if (!k.startsWith('__')) fileCfg[k] = raw[k];
    } catch (e) { /* malformed config: fall back to defaults */ }
  }
  const env = process.env || {};
  return Object.freeze(Object.assign({}, defaults, fileCfg, {
    deployedSceneDir: env.FV_DEPLOY_SCENES || fileCfg.deployedSceneDir || defaults.deployedSceneDir,
    swfHashedRoot: env.FV_HASHED_ROOT || fileCfg.swfHashedRoot || defaults.swfHashedRoot,
    port: (env.EDITOR_PORT ? parseInt(env.EDITOR_PORT, 10) : (fileCfg.port != null ? fileCfg.port : defaults.port)),
  }, overrides || {}));
}

module.exports = { loadConfig, config: loadConfig() };

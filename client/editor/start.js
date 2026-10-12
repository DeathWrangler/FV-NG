// Detach-launcher for the editor server: spawns `node server.js <port>` fully detached
// (own process group, no stdio) so it survives the launching shell / background-wrapper quirks.
// Usage: node start.js [port]   (default 8787). Writes pid to build/editor-server.pid.
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const { loadConfig } = require('./config.js');

const cfg = loadConfig();
const PORT = process.argv[2] || String(cfg.port);
const logFile = path.join(cfg.repoRoot, 'build/editor-server.log');
const pidFile = path.join(cfg.repoRoot, 'build/editor-server.pid');
fs.mkdirSync(path.dirname(logFile), { recursive: true });

// M3-4: authoritative check — probe the port. If a healthy server already answers, report and exit 0.
function healthProbe() {
  return new Promise((resolve) => {
    const req = require('http').get({ host: '127.0.0.1', port: Number(PORT), path: '/api/health', timeout: 800 }, (res) => {
      res.resume();
      resolve(res.statusCode === 200);
    });
    req.on('error', () => resolve(false));
    req.on('timeout', () => { req.destroy(); resolve(false); });
  });
}

(async () => {
  // fast path: pid file points at a live process.
  try {
    const oldPid = parseInt(fs.readFileSync(pidFile, 'utf8'), 10);
    if (oldPid) process.kill(oldPid, 0); // throws if dead
    console.log('already running pid=' + oldPid + ' port=' + PORT);
    process.exit(0);
  } catch (e) { /* not running (per pid file) */ }

  // authoritative path: is something healthy already on the port?
  if (await healthProbe()) {
    console.log('already running port=' + PORT + ' (health probe succeeded)');
    process.exit(0);
  }

  const out = fs.openSync(logFile, 'a');
  const child = spawn(process.execPath, [path.join(cfg.repoRoot, 'client/editor/server.js'), PORT], {
    detached: true,
    stdio: ['ignore', out, out],
  });
  child.unref();
  fs.writeFileSync(pidFile, String(child.pid));
  console.log('started editor server pid=' + child.pid + ' port=' + PORT + ' log=' + logFile);
})();

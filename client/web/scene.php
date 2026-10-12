<?php
/**
 * FV-NG — on-demand world-object scene endpoint.
 *   GET scene.php?item=<itemName>
 * Serves the runtime scene JSON for a placed item. If the item is already mapped in
 * scenesbyname.json (and its scene is on disk) it is served directly; otherwise the server
 * converts the item's SWF with the shared Node exporter (client/tools/convert_one.js), caches it,
 * records the mapping, and serves it. This lets the client render ANY object returned by the
 * server's loadOwnWorld, even ones the offline batch missed.
 *
 * Local preservation instance: paths default to this machine and can be overridden with env vars
 * FVNG_NODE / FVNG_CONVERTER / FVNG_ASSETHASH.
 */
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Cache-Control: no-store');

$dir       = __DIR__;
$mapFile   = $dir . '/scenesbyname.json';
$scenesDir = $dir . '/scenes';
$item      = isset($_GET['item']) ? $_GET['item'] : '';
if (!preg_match('/^[A-Za-z0-9_]+$/', $item)) { http_response_code(400); echo json_encode(['error' => 'bad item']); exit; }

$node      = getenv('FVNG_NODE')      ?: 'C:\\Program Files\\nodejs\\node.exe';
$converter = getenv('FVNG_CONVERTER') ?: 'C:\\Users\\Remote\\Desktop\\FV-NG\\client\\tools\\convert_one.js';
$assethash = getenv('FVNG_ASSETHASH') ?: 'C:\\Users\\Remote\\Desktop\\FV-NG\\client\\assets\\assethash.json';

$map = is_file($mapFile) ? json_decode(file_get_contents($mapFile), true) : [];
if (!is_array($map)) $map = [];

function serve_scene($file) { readfile($file); exit; }

if (isset($map[$item])) {
    $f = $scenesDir . '/' . $map[$item] . '.scene.json';
    if (is_file($f)) serve_scene($f);
}

if (is_file($node) && is_file($converter)) {
    $cmd = escapeshellarg($node) . ' ' . escapeshellarg($converter)
         . ' --name ' . escapeshellarg($item)
         . ' --out ' . escapeshellarg($scenesDir)
         . ' --assethash ' . escapeshellarg($assethash) . ' 2>&1';
    $stem = trim((string)shell_exec($cmd));
    if ($stem !== '' && preg_match('/^[A-Za-z0-9_]+$/', $stem)) {
        $f = $scenesDir . '/' . $stem . '.scene.json';
        if (is_file($f)) {
            $map[$item] = $stem;
            @file_put_contents($mapFile, json_encode($map));
            serve_scene($f);
        }
    }
    http_response_code(404);
    echo json_encode(['error' => 'convert failed', 'item' => $item, 'detail' => $stem]);
    exit;
}

http_response_code(404);
echo json_encode(['error' => 'no scene', 'item' => $item]);

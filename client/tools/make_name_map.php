<?php
$c = new mysqli("localhost","farmville","farmville","farmville");
$manifest = json_decode(file_get_contents('C:/Farmville/xampp/htdocs/public/farmville/fvng/croptiles/_manifest.json'), true);
// stem index + a set of all stems for fast lookup
$stems = array_keys($manifest);
// also build: swf basename (no crop_/flower_ prefix) -> stem, and exact basename -> stem
$byBase = []; $byExact = [];
foreach ($stems as $st){
  $byExact[$st] = $st;
  $byBase[preg_replace('/^(crop|flower)_/','',$st)] = $st;
}
$rows = $c->query("SELECT name, data_json FROM items_ng WHERE type='seed'")->fetch_all(MYSQLI_ASSOC);
$out = [];
$hit=0;
foreach($rows as $r){
  $name=$r['name'];
  $d=json_decode($r['data_json'],true);
  if(!isset($d['image'][0]['url'])) continue;
  $file=basename($d['image'][0]['url'],'.swf'); // e.g. crop_wheat, xmd_seaglasswheat, flower_alfalfa
  $stem=null;
  if(isset($byExact[$file])) $stem=$file;
  elseif(isset($byBase[$file])) $stem=$byBase[$file];
  else { // try stripping prefix from file and matching stem
    $fb=preg_replace('/^(crop|flower)_/','',$file);
    if(isset($byBase[$fb])) $stem=$byBase[$fb];
    elseif(isset($manifest[$name])) $stem=$name;
  }
  if($stem!==null){ $out[$name]=$stem; $hit++; }
}
file_put_contents('C:/Farmville/xampp/htdocs/public/farmville/fvng/cropsbyname.json', json_encode($out));
echo "seed rows: ".count($rows).", mapped (unique names): ".count($out)."\n";

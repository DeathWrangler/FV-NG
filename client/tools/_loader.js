// Loader shim so modules outside client/tools can pull the ESM-only swf-parser + the exporter.
// Lives in client/tools so bare-name resolution of 'swf-parser' works from here.
module.exports = {
  parseSwf: require('swf-parser').parseSwf,
  swfToScene: require('./swf2scene.js').swfToScene,
};

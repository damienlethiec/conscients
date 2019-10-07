const { environment } = require("@rails/webpacker");

const webpack = require("webpack");
const erb = require("./loaders/erb");

environment.plugins.prepend(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    Popper: ["popper.js", "default"]
  })
);

// https://github.com/rails/webpacker/blob/master/docs/v4-upgrade.md
// #excluding-node_modules-from-being-transpiled-by-babel-loader
const nodeModulesLoader = environment.loaders.get('nodeModules')
if (!Array.isArray(nodeModulesLoader.exclude)) {
  nodeModulesLoader.exclude = (nodeModulesLoader.exclude == null)
    ? []
    : [nodeModulesLoader.exclude]
}
nodeModulesLoader.exclude.push(/gmaps/)

environment.loaders.append("erb", erb);
module.exports = environment;



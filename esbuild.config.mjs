import * as esbuild from "esbuild";

await esbuild.build({
  entryPoints: ["lib/ruby_ui/index.js"],
  bundle: true,
  minify: false,
  sourcemap: true,
  target: ["es2015"],
  outfile: "dist/ruby_ui_js.min.js",
  format: "iife",
  globalName: "RubyUI",
});

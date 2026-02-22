const isProduction = process.env.NODE_ENV === "production"
const isWatch = process.argv.includes("--watch")

const config = {
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  sourcemap: true,
  outdir: "app/assets/builds",
  publicPath: "assets",
  minify: isProduction,
  logLevel: "info",
  // jquery and popper.js are loaded via Sprockets (jquery-rails gem)
  external: ["jquery", "popper.js"],
}

if (isWatch) {
  require("esbuild")
    .context(config)
    .then((ctx) => ctx.watch())
    .catch(() => process.exit(1))
} else {
  require("esbuild")
    .build(config)
    .catch(() => process.exit(1))
}

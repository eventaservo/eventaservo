const fs = require("fs")
const rewritePattern = require("regexpu-core")
const isProduction = process.env.NODE_ENV === "production"
const isWatch = process.argv.includes("--watch")

// Slim Select's Unicode property escapes cannot be parsed by Firefox Mobile 77.
// Compile the exact expression to an equivalent regex for older engines.
const legacySlimSelectRegex = {
  name: "legacy-slim-select-regex",
  setup(build) {
    build.onLoad({ filter: /[/\\]slim-select[/\\]dist[/\\]slimselect\.es\.js$/ }, async ({ path }) => {
      const source = await fs.promises.readFile(path, "utf8")
      const original = String.raw`/[\p{L}\p{N}]/u`
      if (!source.includes(original)) {
        throw new Error("Slim Select Unicode regex changed; review the compatibility transform")
      }
      const replacement = `/${rewritePattern(String.raw`[\p{L}\p{N}]`, "u", { unicodePropertyEscapes: "transform", unicodeFlag: "transform" })}/`
      return { contents: source.replaceAll(original, replacement), loader: "js", resolveDir: require("path").dirname(path) }
    })
  },
}

const config = {
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  sourcemap: true,
  outdir: "app/assets/builds",
  publicPath: "assets",
  minify: isProduction,
  logLevel: "info",
  target: ["es2018"],
  plugins: [legacySlimSelectRegex],
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

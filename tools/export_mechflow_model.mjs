import { createHash } from "node:crypto";
import { watch } from "node:fs";
import { readFile, rename, rm, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const toolsDir = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(toolsDir, "..");
const mechflowRoot = resolve(process.env.MECHFLOW_ROOT ?? resolve(projectRoot, "../mechflow"));
const sourcePath = resolve(projectRoot, "simulation/models/ceres-water.yaml");
const outputPath = resolve(projectRoot, "simulation/models/ceres-water.runtime.json");
const temporaryPath = `${outputPath}.tmp`;
const coreEntry = pathToFileURL(resolve(mechflowRoot, "packages/core/dist/index.js")).href;
const { parseModelYaml } = await import(coreEntry);

async function exportModel() {
  const yaml = await readFile(sourcePath, "utf8");
  const parsed = parseModelYaml(yaml);
  if (!parsed.ok) {
    await rm(outputPath, { force: true });
    console.error("Mechflow model is invalid; removed the generated Godot model:");
    for (const error of parsed.errors) {
      console.error(`  ${error.path || "<root>"}: ${error.message}`);
    }
    return false;
  }

  const sourceSha256 = createHash("sha256").update(yaml).digest("hex");
  const generated = JSON.stringify({ format_version: 1, source_sha256: sourceSha256, model: parsed.model }, null, 2) + "\n";
  await writeFile(temporaryPath, generated, "utf8");
  await rename(temporaryPath, outputPath);
  console.log(`Exported ${sourcePath} -> ${outputPath}`);
  return true;
}

await exportModel();
if (!process.argv.includes("--watch")) process.exit(0);

let timer;
const watcher = watch(dirname(sourcePath), { persistent: true }, (_event, filename) => {
  if (filename && filename.toString() !== "ceres-water.yaml") return;
  clearTimeout(timer);
  timer = setTimeout(() => {
    exportModel().catch((error) => console.error("Mechflow model export failed:", error));
  }, 120);
});

for (const signal of ["SIGINT", "SIGTERM"]) {
  process.on(signal, () => {
    watcher.close();
    clearTimeout(timer);
    process.exit(0);
  });
}

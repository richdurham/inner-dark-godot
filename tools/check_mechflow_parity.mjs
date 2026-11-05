import { spawnSync } from "node:child_process";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { dirname } from "node:path";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const mechflowRoot = resolve(process.env.MECHFLOW_ROOT ?? resolve(projectRoot, "../mechflow"));
const coreEntry = pathToFileURL(resolve(mechflowRoot, "packages/core/dist/index.js")).href;
const { createRun, parseModelYaml } = await import(coreEntry);
const godot = process.env.GODOT_BIN ?? "/Applications/Godot.app/Contents/MacOS/Godot";
const modelPath = resolve(projectRoot, "simulation/models/ceres-water.yaml");
const parsed = parseModelYaml(await readFile(modelPath, "utf8"));
if (!parsed.ok) throw new Error(`Invalid Mechflow model: ${JSON.stringify(parsed.errors)}`);

function mechflowCase(name, parameters, overrides, steps) {
  const created = createRun(parsed.model, { seed: 7, steps, parameters, overrides });
  if (!created.ok) throw new Error(`${name}: ${JSON.stringify(created.errors)}`);
  const result = [];
  for (let day = 0; day < steps; day++) {
    const step = created.run.step();
    if (!step) throw new Error(`${name}: Mechflow stopped at day ${day + 1}`);
    result.push({
      water: step.amounts.water_reserve_days / parsed.model.parameters.find((p) => p.id === "units_per_reserve_day").value,
      unmet: step.amounts.unmet_water_days / parsed.model.parameters.find((p) => p.id === "units_per_reserve_day").value,
    });
  }
  return result;
}

const engineCases = {
  normal: mechflowCase("normal", {}, {}, 7),
  rationed: mechflowCase("rationed", { rationing_enabled: 1 }, {}, 12),
  repaired: mechflowCase("repaired", {}, {
    "nodes.treatment_online.start": 1,
    "nodes.treatment_parts.start": 0,
  }, 8),
};

const run = spawnSync(godot, ["--headless", "--path", projectRoot, "--script", resolve(projectRoot, "tools/ceres_parity_runner.gd")], {
  cwd: projectRoot,
  encoding: "utf8",
  maxBuffer: 4 * 1024 * 1024,
});
if (run.error) throw run.error;
if (run.status !== 0) throw new Error(`Godot parity runner failed (${run.status}):\n${run.stdout}\n${run.stderr}`);
const resultLine = run.stdout.split(/\r?\n/).find((line) => line.startsWith("CERES_PARITY:"));
if (!resultLine) throw new Error(`Godot parity output missing:\n${run.stdout}\n${run.stderr}`);
const godotCases = JSON.parse(resultLine.slice("CERES_PARITY:".length));

for (const [name, expected] of Object.entries(engineCases)) {
  const actual = godotCases[name];
  if (!Array.isArray(actual) || actual.length !== expected.length) {
    throw new Error(`${name}: Godot produced ${actual?.length ?? "no"} days; Mechflow produced ${expected.length}`);
  }
  for (let index = 0; index < expected.length; index++) {
    for (const key of ["water", "unmet"]) {
      if (Math.abs(expected[index][key] - actual[index][key]) > 1e-8) {
        throw new Error(`${name} day ${index + 1} ${key}: Mechflow=${expected[index][key]}, Godot=${actual[index][key]}`);
      }
    }
  }
}

console.log("Mechflow/Godot parity passed: normal, rationed, and already-repaired daily water balances.");
console.log("Repair action timing itself is not compared; Mechflow converters advance a step, while Godot B is outside the day tick.");

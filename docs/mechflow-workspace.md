# Mechflow economy workspace

## Goal

Use Mechflow as a separate local tool beside the Godot game to draw, inspect, and run the Ceres economy. The graph is a view of the same model the game uses, not a second specification that someone must copy into GDScript.

## One editable model

The single editable model belongs in `simulation/models/` inside `inner-dark-godot`. Mechflow runs from the sibling `mechflow` checkout, but `tools/run_mechflow.sh` passes the Godot model directory to its server. The browser therefore reads and writes the same model file that the game project owns. Do not duplicate the model under `mechflow/models/` or manually transcribe its rates into the game.

Start it from the Godot project folder:

```sh
./tools/run_mechflow.sh
```

Then open `http://127.0.0.1:3000`. The Mechflow server binds to loopback. The sidecar checkout is at `../mechflow`; it uses Node 22 or later and pnpm 9. Its app build is separate from the Godot project and does not modify Godot source files.

## Godot data contract

`ceres-water.yaml` is the canonical, editable model. `tools/run_mechflow.sh` starts Mechflow with this directory and runs `tools/export_mechflow_model.mjs` in watch mode. The exporter uses Mechflow's own YAML parser and schema validator to write `ceres-water.runtime.json`, an automatically generated Godot-readable file containing the parsed model and a SHA-256 of its YAML source. If the YAML is invalid, the exporter removes the generated file; it never leaves a stale runtime model that looks current. Do not edit the generated JSON by hand.

At startup, `CeresRunSimulation` checks the source hash and supported flow shape. It reads initial stock amounts, unit scale, normal and rationed demand, treatment output, and repair cost from the shared model. It converts quarter-day model units into the game's displayed reserve-days. The GDScript code applies the validated Ceres transition to `SimulationState`; it does not keep its own numeric copies of those values. If the source file changes while the game is running, restart the game to load the newly generated model. If the file is invalid, stale, or has unsupported flow formulas, the game reports a model load error instead of using fallback constants.

New saves record the canonical YAML hash and refuse to load after the model changes. Existing saves without that field remain loadable and are marked as model-unverified. The first adapter supports this model's named nodes and four rate formulas. It is not a general Mechflow interpreter. Editing supported stock starts and numeric parameters in Mechflow changes the values Godot loads; the model's four rate formulas are checked against the adapter so unsupported rule edits stop at load rather than silently diverge. This bounded adapter keeps the current design small while preventing numeric data from being maintained in two places.

## Current state and known gap

The Mechflow repository has been cloned and built as a sibling local tool. The shared `ceres-water.yaml` model is in the Godot repository, and the Mechflow launcher edits that file directly. The automatic exporter generates the adjacent runtime JSON; Godot reads its stock starts and numeric parameters and checks that its expected flow formulas still match. This maps the current demonstration only. The underlying Ceres colony model remains open design work.

The adapter uses four quarter-day units per reserve-day because Mechflow pools hold integers while the Godot display uses reserve-days. The Mechflow formulas split treatment output between demand and reserve so the same-day water balance matches Godot. The remaining interaction timing difference is that Mechflow converters deliver output on the following step, while the Godot B action occurs outside the day tick. Compare the already-repaired initial state to inspect the same day behavior; do not compare the converter action step to a Godot day. The remaining compatibility limit is:

- Mechflow converters deliver outputs on the following step. The repair action therefore occurs during a Mechflow step; for direct day-by-day parity with Godot, compare a run initialized with treatment already online after the repair cost has been paid.

The current demo mapping is now loaded by Godot, but it remains exploratory and must not be presented as the authoritative colony simulation.

## Parity gate

Run `node tools/check_mechflow_parity.mjs` to compare each daily water balance in Mechflow and Godot. The repeatable cases cover normal demand through first shortage, rationing through depletion, and eight days from an already-repaired state. Mechflow stores quarter-day integer units; Godot displays days. The repair action timing itself is excluded because Mechflow converters advance a step, while Godot B is outside the day tick. Add boundary cases before changing formulas.

See [the simulation model decision record](simulation-model-design.md) for the open game-design choices. The reference tool is [Mechflow](https://github.com/Yalton/mechflow).

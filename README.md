# The Inner Dark — Godot game project

The Inner Dark is a grounded, character-centered science-fiction RPG set across a simulated Solar System. This repository owns whole-game design and the Godot 4 game. The separate [inner-dark-narrative](https://github.com/richdurham/inner-dark-narrative) repository owns a standalone Python narrative prototype; it is not integrated with this game.

## Start here

- [Whole-game design](docs/game-design.md) — vision, pillars, systems, milestones, boundaries, risks, and acceptance criteria.
- [Project roadmap](docs/roadmap.md) — phased implementation plan, deliverables, status, and exit gates.
- [Current architecture](docs/architecture.md) — what runs today, target dependency boundaries, authority, data, and integration rules.
- [Ceres Run vertical slice](docs/ceres-run.md) — established crisis premise, character knowledge, scope, and acceptance checks.
- [Ceres simulation model design](docs/simulation-model-design.md) — open decisions for the actual simulation; current Godot rates and values are placeholders.
- [Mechflow workspace](docs/mechflow-workspace.md) — separate local economy visualizer, shared model location, and Godot compatibility plan.
- [LLM handoff](docs/llm-handoff.md) — concise context and guardrails for another coding model.
- [Python subsystem guide](https://github.com/richdurham/inner-dark-narrative/blob/main/docs/subsystem-guide.md) — implementation facts and limitations for the separate narrative prototype.

## Current Godot project state

The opening scene is a temporary top-down 2D interaction and simulation test: move with WASD/arrow keys, approach the crisis board or one of three sources, press E to inspect/speak, J to review sourced case notes, T to advance a day, C to toggle rationing, B to repair water treatment with a spare component, and R to restart. It is not the intended 3D wireframe brief. Recover that reference before further visual implementation. The water loop is also a plumbing demo; the underlying Ceres simulation model has not been agreed.

A small simulation foundation now exists in `simulation/`: typed stocks and state, tick advancement, validated stock changes, and inspectable events. The scene is connected to a temporary water-reserve loop: T advances a day; C toggles rationing, changing demand from 1.0 to 0.5 reserve-days per tick; B spends one spare component to restore treatment, adding 0.25 reserve-days before each day's demand is served. If supply falls short, unmet demand accumulates and the daily event records a shortage and full water balance. Starting stocks and rates are demonstration placeholders, not established game facts. Production schedules, broader treatment capacity, travel, story choices, storylets, local model runtime, and Godot-to-Python integration are not implemented. The Python narrative prototype runs independently.

## Running the scene

Open this project in Godot and run the main scene (F5). Use WASD/arrow keys to move, E to inspect a source, J to open the case file, T to advance one day, C to toggle rationing, B to repair treatment, K to save, L to load, and R to restart.

## Mechflow economy workspace

Start the separate visualizer with `./tools/run_mechflow.sh` and open `http://127.0.0.1:3000`. It edits the canonical model under `simulation/models/`; Godot loads the automatically generated runtime data from that same file. Restart the game after changing the model. Run `node tools/check_mechflow_parity.mjs` to compare normal, rationed, and repaired balances. See [the Mechflow workspace guide](docs/mechflow-workspace.md) for the adapter contract and current demo limits.

## Project constraints

- Godot 4 and GDScript are the game target.
- Game code owns authoritative state; a model may propose, but game code validates and applies.
- Narrative generation and embeddings use local models only; no cloud narrative inference or external narrative service.
- Keep bounded data (IDs, time, quantities, balances) typed. Use tags for flexible semantic/narrative state.
- Travel is abstracted between meaningful locations; simulation advances in discrete ticks.
- Do not turn uncertain story details into canon without an explicit design decision.

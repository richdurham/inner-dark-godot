# The Inner Dark — Godot game project

The Inner Dark is a grounded, character-centered science-fiction RPG set across a simulated Solar System. This repository owns whole-game design and the Godot 4 game. The separate [inner-dark-narrative](https://github.com/richdurham/inner-dark-narrative) repository owns a standalone Python narrative prototype; it is not integrated with this game.

## Start here

- [Whole-game design](docs/game-design.md) — vision, pillars, systems, milestones, boundaries, risks, and acceptance criteria.
- [Project roadmap](docs/roadmap.md) — phased implementation plan, deliverables, status, and exit gates.
- [Current architecture](docs/architecture.md) — what runs today, target dependency boundaries, authority, data, and integration rules.
- [Ceres Run vertical slice](docs/ceres-run.md) — established crisis premise, character knowledge, scope, and acceptance checks.
- [LLM handoff](docs/llm-handoff.md) — concise context and guardrails for another coding model.
- [Python subsystem guide](https://github.com/richdurham/inner-dark-narrative/blob/main/docs/subsystem-guide.md) — implementation facts and limitations for the separate narrative prototype.

## Current Godot project state

The opening scene is a temporary top-down 2D interaction test: move with WASD/arrow keys, approach the crisis board or one of three sources, press E to inspect/speak, and press R to restart. It demonstrates authored crisis information and basic interaction only. It is not the intended 3D wireframe brief or a simulation. The 3D reference/brief must be recovered before further visual implementation.

A small simulation foundation now exists in `simulation/`: typed stock values and state, tick advancement, validated stock changes, and inspectable events. The scene is connected to a temporary water-reserve demo: press T to advance a day. Its 6.0-day starting reserve and one reserve-day consumed per advance are placeholders, not established game facts. The display demonstrates a state transition, not a finished settlement economy. Persistence, production/consumption rules, travel, validated story choices, storylets, local model runtime, and Godot-to-Python integration are not implemented. The Python narrative prototype runs independently.

## Running the scene

Open this project in Godot and run the main scene (F5). The temporary test uses WASD/arrow keys, E to interact, T to advance the demo simulation, and R to restart.

## Project constraints

- Godot 4 and GDScript are the game target.
- Game code owns authoritative state; a model may propose, but game code validates and applies.
- Narrative generation and embeddings use local models only; no cloud narrative inference or external narrative service.
- Keep bounded data (IDs, time, quantities, balances) typed. Use tags for flexible semantic/narrative state.
- Travel is abstracted between meaningful locations; simulation advances in discrete ticks.
- Do not turn uncertain story details into canon without an explicit design decision.

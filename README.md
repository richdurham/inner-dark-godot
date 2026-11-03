# The Inner Dark — Godot game project

The Inner Dark is a grounded, character-centered science-fiction RPG set across a simulated Solar System. This repository is the intended home for the Godot 4 game, its overall design, and its technical architecture. The current scene is an early UI placeholder; planned systems below are not claims of implementation.

## Start here

- [Whole-game design](docs/game-design.md) — vision, pillars, systems, milestones, boundaries, risks, and acceptance criteria.
- [Technical architecture](docs/architecture.md) — simulation authority, local AI boundary, visual direction, and Godot-AI workflow.
- [Ceres Run vertical slice](docs/ceres-run.md) — premise, established characters, scope, and criteria.
- [Narrative subsystem](https://github.com/richdurham/inner-dark-narrative) — separate Python prototype; its [docs](https://github.com/richdurham/inner-dark-narrative/tree/main/docs) describe actual subsystem behavior.

This repository owns game-wide design and Godot implementation. The narrative repository owns Python subsystem implementation. Keep one canonical copy of each: cross-link rather than copying subsystem internals here.

## Current state

The checkout contains a minimal interactive placeholder scene and the Godot-AI editor plugin. The Solar System simulation, economy, careers, travel, faction simulation, storylets, and Godot-to-narrative integration are not implemented. The Python narrative prototype runs independently.

## Non-negotiable constraints

- Godot 4 and GDScript are the game target.
- Simulation code owns authoritative state; AI may propose, while game code validates and applies.
- Generation and embeddings run with local models. No cloud inference or external narrative service.
- Tags represent flexible semantic/narrative state; quantities, IDs, time, money, and other bounded values remain typed.
- Travel is abstracted between meaningful locations; simulation advances in discrete ticks.

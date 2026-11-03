# Current architecture and implementation boundaries

This document separates what exists in the Godot checkout from the intended architecture. The game-design document owns game intent; the roadmap sequences implementation; the Ceres Run document owns the established slice premise and acceptance checks.

## Repository ownership

- **This repository, `inner-dark-godot`:** canonical whole-game design, Godot project, and eventual authoritative simulation.
- **Separate `inner-dark-narrative` repository:** standalone Python narrative subsystem prototype. It has its own implementation documentation. It is not imported by this Godot project and there is no runtime bridge.
- **Godot-AI plugin:** editor authoring and inspection dependency under `addons/godot_ai`; it is not game simulation code or the future narrative runtime.

Keep this ownership boundary clear. Cross-link subsystem specifics instead of copying Python implementation details into the game repo.

## What currently runs

The project opens `res://main.tscn`, whose root is a `Control` using `res://main.gd`. The script draws a top-down floorplan, source markers, and player marker with `_draw()`, constructs a UI overlay from Control nodes, processes movement and interaction, and stores the current briefing progress in script variables.

The temporary scene supports movement with WASD/arrow keys, E to inspect or speak near the crisis board and three information sources, and R to restart. It presents documented Ceres facts and a completion message. Position and source-review progress are transient: there is no save, simulation tick, world-state model, event log, or consequential action.

**Visual status:** this is a quick 2D interaction prototype. It is not the intended 3D wireframe brief and is not a locked art direction. The 3D wireframe brief/reference is not present in the checked-in design docs reviewed for this update. Recover that brief before doing further visual implementation; do not infer its layout, camera, scale, or asset language from this 2D test.

Godot 4.7.2 was reported by the connected editor at the last review. The Godot-AI plugin is enabled from `addons/godot_ai`; editor plugin version can change independently.

## Current runtime flow

```
project.godot -> main.tscn -> Main (Control) / main.gd
                                   ├─ draws the temporary floorplan and markers
                                   ├─ creates the header, interaction and objective UI
                                   ├─ reads movement / interact / restart input
                                   └─ updates volatile player and briefing variables
```

No other game scripts, gameplay scenes, domain resources, or project-owned autoloads were found at the time of review. The `_mcp_game_helper` autoload belongs to the Godot-AI editor plugin.

## Target dependency direction

```
Input and presentation
        ↓ commands / read models
Application actions and validation
        ↓
Domain state + deterministic simulation
        ├─ validated events -> persistence
        └─ snapshots/events -> UI and sanitized narrative context

Godot game <-> future local narrative process
      narrative output -> validation as data -> game-owned action resolution
```

This is a direction for future work, not an implemented module map. Keep domain rules independent of scene nodes. Presentation may request actions and display outcomes; it must not mutate canonical world state directly.

### Responsibilities

- **Presentation:** render location and status, gather player intent, show inspectable events and validated results. It does not decide whether a trade, clue, travel action, or NPC plan is allowed.
- **Application layer:** translate input into explicit commands; validate preconditions at the boundary; coordinate domain operations and return clear outcomes.
- **Domain and simulation:** own typed identities, quantities, time, permissions, rules, and state transitions. Keep rules deterministic for the same initial state, seed, and ordered inputs.
- **Events and persistence:** record meaningful state changes with enough information to explain them, support reproducibility, and eventually save/load with a versioned format. Storage format and event sourcing strategy remain open.
- **Narrative adapter (future):** accept bounded, character-scoped context; return dialogue or a constrained proposal. It cannot write game state. The initial Ceres slice must run with this adapter absent.

## State and evidence rules

Use typed values for bounded facts such as resource quantity, credits, time, actor identity, location, ownership, and permissions. Use tags for flexible descriptors such as `rumored`, `verified`, `contested`, or `scarce`; tags never replace an amount or identity.

Keep evidence provenance explicit: direct observation, authored fact, trusted report, rumor, or inference. Do not promote generated text or retrieved memory into canon without game-side validation. Keep NPC authored knowledge distinct and character-scoped. The established boundaries are listed in [Ceres Run](ceres-run.md).

A state-changing action should follow this shape:

1. Input expresses a command, not a direct mutation.
2. Game code checks actor, permissions, preconditions, costs, quantities, and bounds.
3. Simulation applies the operation as one coherent transition.
4. The result and meaningful event are returned for presentation and persistence.
5. A narrative model, if present, may describe or propose; it does not apply the result.

## Determinism and testing direction

A simulation step should be reproducible from known starting state, seed, configuration, and ordered commands. Keep randomness explicit and seeded. Tests should cover normal transitions, boundaries, invalid commands, and repeated runs; character knowledge tests should prove one NPC cannot retrieve another's private data. UI smoke tests complement domain tests; they do not substitute for them.

No project-owned automated gameplay test suite or simulation tests exist yet. The earlier editor smoke check only confirmed movement and one Mara interaction in the temporary 2D scene. It did not verify all source locations, a 3D scene, or any simulation behavior.

## Integration and local-only model constraints

Narrative generation and embeddings are intended to use local models only. Do not add hosted inference, cloud narrative APIs, or network calls for narrative behavior. The Python prototype currently runs independently. Its integration-contract file is a draft, not a live protocol.

Before an integration is built, specify a versioned local contract with bounded payloads, timeouts, health/status behavior, schema validation, character-scoped context, graceful unavailable behavior, and tests that prove model output cannot change authoritative state. See [the Python subsystem guide](https://github.com/richdurham/inner-dark-narrative/blob/main/docs/subsystem-guide.md) for actual Python behavior and limits.

## Open architecture decisions

Do not silently settle these in implementation: tick duration and order; offline advancement; event-log and save format; world/content data format; location graph; travel failure behavior; career and access rules; faction and relationship model; storylet schema; local-model target hardware and budget; narrative process transport. Resolve a decision only when the next slice needs it, document the choice, and preserve reversibility where practical.

## Editor workflow

For Godot changes, inspect the live editor/project state, read affected files, make the smallest coherent change, run or inspect the scene when useful, and read diagnostics before reporting. Confirm tests actually ran before calling them passed. The `addons/godot_ai` plugin can help with editor operations, but its availability does not imply that a feature was tested.

# Current architecture and implementation boundaries

This document separates what exists in the Godot checkout from the intended architecture. The game-design document owns game intent; the roadmap sequences implementation; the Ceres Run document owns the established slice premise and acceptance checks.

## Repository ownership

- **This repository, `inner-dark-godot`:** canonical whole-game design, Godot project, and eventual authoritative simulation.
- **Separate `inner-dark-narrative` repository:** standalone Python narrative subsystem prototype. It has its own implementation documentation. It is not imported by this Godot project and there is no runtime bridge.
- **Godot-AI plugin:** editor authoring and inspection dependency under `addons/godot_ai`; it is not game simulation code or the future narrative runtime.

Keep this ownership boundary clear. Cross-link subsystem specifics instead of copying Python implementation details into the game repo.

## What currently runs

The project opens `res://main.tscn`, whose root is a `Control` using `res://main.gd`. The script draws a top-down floorplan, source markers, and player marker with `_draw()`, constructs a UI overlay from Control nodes, processes movement and interaction, and stores the current briefing progress in script variables.

The temporary scene supports movement with WASD/arrow keys, E to inspect or speak near the crisis board and three information sources, J to review a sourced case file, T to advance the simulation demo, C to toggle rationing, B to spend a spare component repairing treatment, K to save, L to load, and R to restart. It presents documented Ceres facts and a completion message. Position is transient; K saves the simulation, evidence notes, and source-review progress in a versioned local file. The case file records verified statements, rumors, unresolved claims, and their sources. The top-right status card displays reserve, projected runout, day, active policy, treatment state/parts, cumulative unmet demand, and the three most recent meaningful simulation events. The public board reports current simulation state; Mara and Sato give shortage-aware dialogue after a shortfall. Starting values and rates are temporary demonstration assumptions, not canon. The Ceres simulation model has not been agreed; see [the simulation model design record](simulation-model-design.md) before extending or tuning these rules.

**Visual status:** this is a quick 2D interaction prototype. It is not the intended 3D wireframe brief and is not a locked art direction. The 3D wireframe brief/reference is not present in the checked-in design docs reviewed for this update. Recover that brief before doing further visual implementation; do not infer its layout, camera, scale, or asset language from this 2D test.

Godot 4.7.2 was reported by the connected editor at the last review. The Godot-AI plugin is enabled from `addons/godot_ai`; editor plugin version can change independently.

## Current runtime flow

```
project.godot -> main.tscn -> Main (Control) / main.gd
                                   ├─ draws the temporary floorplan and markers
                                   ├─ creates the header, interaction and objective UI
                                   ├─ reads movement / interact / restart / advance-day input
                                   ├─ sends T to CeresRunSimulation
                                   │       └─ SimulationEngine -> SimulationState -> events
                                   └─ updates player and briefing presentation state
```

Game-owned simulation scripts now exist under `simulation/`; no other gameplay scenes or project-owned autoloads were found. The `_mcp_game_helper` autoload belongs to the Godot-AI editor plugin.

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

The design for language-rich world records and embedding-assisted storylet discovery is in [semantic-world-narrative.md](semantic-world-narrative.md). The proposed political and social substrate, and its coupling to economic access and flows, is in [political-ecosystem-model.md](political-ecosystem-model.md). These documents describe intended model shape, not current runtime behavior.

### NPC population scaling direction

The target is a persistent NPC roster with aggregate community capabilities, not a continuously simulated agent for every resident. Background resolution can query the roster by capability, location, availability, and required resources; detailed schedules and personal state are reserved for NPCs whose tasks, relationships, or encounters matter. When an encounter is surfaced, it refers to an existing roster identity. This is a design direction only; the current prototype has a fixed set of information sources and no autonomous NPC work simulation.

World time should be shared across simulation scales, with coarser update cadence for broader regions. Only the player's current scale and nearby parent/child context need detailed resolution. Inactive settlements or regions advance from their last timestamp through aggregate transitions and consequential scheduled events when relevant; they do not run every local tick in the background. Catch-up must be deterministic and account for intervening transfers, deadlines, and player-visible events in timestamp order. Exact cadence, aggregation, and catch-up behavior remain design decisions, not current implementation.

The current `world_time_units` field is a monotonic integer counter, not a calendar or a defined unit. `advance_world_time` records elapsed units but does not itself simulate locations, processes, or scheduled events. The intended world-clock and scale model is recorded in [simulation-model-design.md](simulation-model-design.md); its cadence and catch-up rules remain open.

## Simulation foundation currently implemented

The following GDScript contracts exist in the game-owned simulation layer. The stock-flow demo is connected to `main.tscn`; the reusable records and candidate verifier are domain foundations and are not yet used by the scene:

- `simulation/resource_stock.gd` defines a resource ID, non-negative finite amount, and unit. It does not set game-specific values or capacities.
- `simulation/simulation_state.gd` holds stocks, stable world records, relationships, a local tick index, one world-time counter, and ordered event history. Its snapshot/restore path includes these structures and accepts older snapshots that lack world time and record arrays.
- `simulation/world_record.gd` carries stable identity, kind, name, prose description, tags, visibility, provenance IDs, and creation/update world times. It can represent characters, groups, places, institutions, objects, resources, work, or events without forcing all meaning into numeric stats.
- `simulation/world_relationship.gd` carries a typed, scoped, sourced relationship between two records, with visibility and active state. It deliberately has no universal relationship-strength score.
- `simulation/simulation_event.gd` carries sequence, tick and world time, type, readable summary, structured payload, affected IDs, source/provenance IDs, and broad domain tags.
- `simulation/semantic_candidate.gd` represents an untrusted embedding/retrieval suggestion using IDs and ranking only. `simulation/semantic_candidate_verifier.gd` checks record existence, observer visibility, active relationships, and that relationship endpoints are included before returning context. It does not commit state changes or treat similarity as proof.
- `simulation/simulation_result.gd` represents accepted/rejected results and an optional event.
- `simulation/simulation_engine.gd` advances a tick and world time together for local steps, can advance world time by a coarser elapsed interval, and emits events for both. Its generic `change_stock` operation validates resource existence, finite non-zero changes, non-negative resulting stock, and a non-empty reason. Its record/relationship upserts validate and timestamp changes and emit provenance-aware events.
- `simulation/ceres_run_simulation.gd` wraps those generic operations for the current scene. It seeds 6.0 reserve-days and one treatment component; T advances a day; C records a rationing action changing demand from 1.0 to 0.5 reserve-days; B spends the component to repair treatment, which adds 0.25 reserve-days before daily demand is served. Each tick emits a `daily_water_balance` or `water_shortage` event with opening reserve, treatment output, demand, served/unmet amounts, ending reserve, and policy state. Unserved demand also accumulates as a stock. Start values and rates are loaded from the shared Mechflow model, but remain temporary assumptions, not approved Ceres simulation rules. The model boundary and rule decisions remain open and are tracked in [simulation-model-design.md](simulation-model-design.md). The Mechflow sidecar data path is documented in [mechflow-workspace.md](mechflow-workspace.md); Godot now reads numeric configuration from the shared model and rejects stale generated data. The HUD displays the last three meaningful events; the complete event history is retained in state and included in manual saves.

The core remains a generic contract layer. The new records do not yet define a complete colony model, political action rules, NPC autonomy, settlement capability aggregation, or multi-scale catch-up. Coarse world-time advancement is only a primitive; callers still need to define deterministic scheduled events and catch-up rules. Semantic candidates are not yet produced by an embedding index or connected to a narrative model. The Ceres demo does not yet model scalable production/capacity, actor permissions, long-term action costs, automatic saves, migration between save versions, or seeded randomness. It has a manual version-1 local save for current simulation/evidence state, a fixed one-time component repair, a policy toggle, unmet-demand accumulation, shortage-aware factual dialogue, and a provenance-preserving case file; water and case rules remain temporary or authored prototype data. A headless model smoke check confirmed the shared definition loads, then matched Mechflow for normal demand through first shortage, rationing through depletion, and eight days from an already-repaired state. The game uses quarter-day scaling for those comparisons. The user also confirmed manual K/L save-load works. No automated gameplay test suite exists yet; the converter action timing still needs a parity check because Mechflow advances a step when firing an interactive converter.

## Player case file currently implemented

`simulation/evidence_record.gd` models a claim with an epistemic status (`verified`, `rumor`, or `unresolved`) and source observations tagged with the simulation tick. `simulation/evidence_ledger.gd` merges repeat claims by ID while preserving distinct source/tick observations. Inspecting a character or the public board adds only that source's authored statements; J displays the resulting notes grouped by status and attributed to sources. Rumors stay unspecific, and the ledger does not infer a culprit. K/L save and restore this ledger together with simulation state; R resets the running slice but does not delete the local save file.

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

No project-owned automated gameplay test suite exists yet. The earlier smoke check covered movement and one Mara interaction. The latest smoke check confirmed one T press advances the reserve and displays an event. Neither check verifies all source locations, a 3D scene, or the eventual settlement rules.

## Integration and local-only model constraints

Narrative generation and embeddings are intended to use local models only. Do not add hosted inference, cloud narrative APIs, or network calls for narrative behavior. The Python prototype currently runs independently. Its integration-contract file is a draft, not a live protocol.

Before an integration is built, specify a versioned local contract with bounded payloads, timeouts, health/status behavior, schema validation, character-scoped context, graceful unavailable behavior, and tests that prove model output cannot change authoritative state. See [the Python subsystem guide](https://github.com/richdurham/inner-dark-narrative/blob/main/docs/subsystem-guide.md) for actual Python behavior and limits.

## Open architecture decisions

Do not silently settle these in implementation: tick duration and order; offline advancement; event-log and save format; world/content data format; location graph; travel failure behavior; career and access rules; faction and relationship model; storylet schema; local-model target hardware and budget; narrative process transport. Resolve a decision only when the next slice needs it, document the choice, and preserve reversibility where practical.

## Editor workflow

For Godot changes, inspect the live editor/project state, read affected files, make the smallest coherent change, run or inspect the scene when useful, and read diagnostics before reporting. Confirm tests actually ran before calling them passed. The `addons/godot_ai` plugin can help with editor operations, but its availability does not imply that a feature was tested.

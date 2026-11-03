# Project roadmap

This roadmap expands the milestone summary in [game-design.md](game-design.md). It describes intended order and completion evidence, not delivery dates. Implement only the details needed to prove a player-facing loop; keep the broader world abstract until the slice earns expansion.

## Product target

The first meaningful game slice is a bounded Ceres colony under water-supply pressure. The player should understand the shortage and missing water-treatment components, gather information from people with different knowledge, choose between supported approaches, see game-validated consequences, and observe time/state advance. The simulation must work with narrative inference disabled.

The current Godot scene is only a temporary 2D interaction test. The user has referred to a separate 3D wireframe brief; that reference is not contained in the design files reviewed for this roadmap. Before visual work, recover the original brief/reference and compare the implementation against it. Do not spend another milestone polishing the current 2D layout.

## Status at roadmap creation

| Area | Status | Evidence / boundary |
|---|---|---|
| Godot shell | Exists | One main scene and one attached GDScript. |
| Temporary interaction test | Exists | Movement, source proximity, authored text, progress counter, restart. It is presentation-only. |
| 3D wireframe direction | Unverified here | Mentioned by the user; source brief/reference must be recovered before implementing it. |
| Typed world model and simulation tick | Partial foundation | Typed stock/state/result/event/engine scripts exist; a generic tick and stock adjustment are visible through T in the scene. No approved settlement rules, persistence, or automated tests yet. |
| Event history and save/load | Partial / not implemented | Events are retained in memory for the running demo; there is no durable event log or save/load. |
| Travel, work, economy, validated choices | Not implemented | Planned; the current reserve demo has no player choice or settlement economy. |
| Python narrative subsystem | Exists separately | Standalone local prototype; current user confirmed its stub-mode plumbing test completed. |
| Godot/Python integration | Not implemented | Draft contract only; defer until game-side behavior is authoritative and independently playable. |

## Phase 1 status after initial foundation work

The generic contracts exist in `simulation/resource_stock.gd`, `simulation/simulation_state.gd`, `simulation/simulation_event.gd`, `simulation/simulation_result.gd`, and `simulation/simulation_engine.gd`. `simulation/ceres_run_simulation.gd` currently demonstrates the connection: T advances the tick and consumes one reserve-day from a 6.0-day starting value. Both values are temporary demo assumptions, not established Ceres facts. The UI shows the current reserve, day, and latest event. Phase 1 remains in progress: automated state/action tests, a save direction, and actual Ceres rules are still needed. Phase 2 is only a visible demonstration, not a settlement simulation.

## Working principles

- **Prove simulation before scale.** Start with one settlement, a few typed resources, a small number of actors, and explicit transitions.
- **Keep outcomes legible.** A tick or action should expose what changed and why.
- **Separate evidence from truth.** Keep rumor, report, inference, and verified event distinct.
- **Keep AI optional and non-authoritative.** A missing model cannot block the core slice.
- **Use visuals in service of the loop.** Do not build a large 3D world before one location and a meaningful action work.
- **Preserve known boundaries.** Unknown route, culprit, motive, career roster, and ending remain open design areas.

## Phases and exit gates

### Phase 0 — Recover the intended visual brief and define the first playable slice

**Purpose:** prevent the temporary 2D interaction scene from driving the intended game's presentation.

**Deliverables:**
- Locate the 3D wireframe brief/reference the user already has in mind.
- Record the minimal camera, scale, composition, and interaction requirements that are actually in that brief.
- Define what one player can do in the first Ceres slice and what feedback proves the action worked.
- Keep unresolved story content explicitly unresolved.

**Exit gate:** there is a concrete, reviewable visual brief and a narrow playable-loop acceptance list. Do not invent missing visual direction.

### Phase 1 — Foundation

**Purpose:** create boundaries that keep rules testable and independent of the UI.

**Deliverables:**
- Establish a small project structure for domain state, actions, simulation, events, persistence, and presentation. Names and exact file layout are implementation choices.
- Define typed IDs and quantities for only the actors, settlement, time, and resources the first loop needs.
- Define a deterministic tick/action interface and a small event/result format.
- Decide the minimum save/load direction needed for the slice; do not build a general persistence framework prematurely.
- Add focused tests for value bounds, event results, invalid inputs, and deterministic replay.

**Exit gate:** given the same initial state and ordered inputs, the model produces the same state and event sequence. A UI can inspect the result without owning the rule logic.

### Phase 2 — Minimal simulation loop

**Purpose:** prove a changing world and one validated player intervention.

**Deliverables:**
- Model a single Ceres settlement with explicit water and water-treatment-component stocks or capacity values. Define units and safe bounds before coding.
- Add a deterministic scheduled change that can be advanced by one tick and has an inspectable explanation.
- Add one player action that passes through game-side validation and produces typed state changes and an event.
- Provide an inspection surface showing current state, action availability, and the latest event.
- Cover success, insufficient-resource or denied-precondition cases, boundary values, and repeatability with tests.

**Exit gate:** a user can inspect supply, perform one valid action, advance a tick, and see a reproducible, explained result. Invalid actions leave state unchanged.

### Phase 3 — Work, trade, and abstract travel

**Purpose:** give the player meaningful ways to affect the shortage without requiring a full Solar System simulation.

**Deliverables:**
- Add only the route/location representation needed to move between a Ceres origin and one meaningful destination.
- Represent travel time, cost, and arrival as typed data; resolve progress on ticks rather than continuous piloting.
- Add one work, trade, or logistics action that produces a cost/reward and a clear event.
- Ensure action permissions and stock/capacity bounds are enforced in simulation.
- Keep distance, commodities, ship detail, and service schedules minimal until gameplay requires more.

**Exit gate:** at least one travel path and one work/trade/action path produce distinct, reproducible outcomes through the same validation and event model.

### Phase 4 — Ceres Run vertical slice

**Purpose:** join the shortage loop with the missing-freighter mystery and character knowledge.

**Deliverables:**
- Present the shortage and why water-treatment components matter.
- Add bounded knowledge for Mara Venn, Ilyan Rusk, and Officer Sato without allowing one character to know another's private information.
- Preserve rumor versus verified fact and retain evidence provenance.
- Support at least two game-validated approaches with meaningfully different consequences; keep exact story branches open until designed.
- Add conditional storylets only where they explain or deliver a decision. The simulation, not dialogue text, decides eligibility and effects.
- Verify the slice runs without any narrative model installed or active.

**Exit gate:** the player can understand the crisis, gather distinct information, choose two different supported approaches, advance time, and inspect different reproducible outcomes without an LLM changing state.

### Phase 5 — Local narrative bridge

**Purpose:** integrate the separate Python prototype only after the game has an authoritative loop.

**Prerequisites:** game-side types/actions and knowledge boundaries are implemented and tested; the Python service has a stable local launch/status contract.

**Deliverables:**
- Specify a versioned local request/response schema and transport. Set payload limits and timeouts.
- Send only the active character's authorized profile/context and permitted memories.
- Validate all returned fields and reject malformed, oversized, stale, or unauthorized proposals.
- Keep dialogue usable or provide a safe fallback when the process/model is unavailable.
- Measure latency and memory use on target hardware. Confirm no external inference calls occur.
- Test that model text cannot mutate stock, credits, travel, missions, relationships, or canon.

**Exit gate:** disabling or crashing the narrative process leaves core gameplay correct and usable; valid dialogue remains character-scoped; invalid model output has no world effect.

### Phase 6 — Expansion by evidence

Only after the Ceres slice meets its acceptance criteria, broaden settlement coverage, commodities, careers, factions, NPC schedules, storylets, ships, and Solar System routes. Each addition should support a player choice, a legible consequence, or a required world relationship.

## Cross-phase verification

At each phase, use the smallest relevant checks:

- Static/script parse and project boot.
- Unit tests for deterministic domain transitions and failure cases.
- Replay tests comparing state and event sequences.
- UI smoke checks for visibility, input, and outcome communication.
- Character-boundary tests for knowledge and memory filtering.
- Narrative-availability tests proving gameplay works without a model.
- Review the Git diff and update status documentation when implementation changes.

Do not report a check as passed unless it was run. Avoid adding a broad test harness before there is game-side behavior to test.

## Decisions intentionally left open

Exact Ceres locations, culprit and motive, endings, career roster, route graph, tick duration/order, offline-time policy, economy model, ship detail, faction model, save/event schema, narrative transport, and final visual production direction. The 3D wireframe brief should resolve only visual requirements it actually specifies; it must not be treated as authorization to invent story canon.

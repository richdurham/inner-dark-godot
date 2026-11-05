# LLM handoff — The Inner Dark

Use this document to orient a fresh coding assistant. It summarizes confirmed context and guardrails; it does not override the user, repository instructions, or the canonical design docs.

## Project identity and repo boundary

This checkout is the Godot game repository, `inner-dark-godot`. It owns whole-game design and eventual authoritative simulation. The separate `inner-dark-narrative` Python repository is a local-only narrative prototype with a basic CLI, SQLite memory, stub/local model adapters, and tests. It does not run inside Godot and has no IPC bridge.

The user recently ran the Python project successfully in stub mode and confirmed the basic test is complete. Do not divert current Godot work into Python unless requested. On macOS the user needs `python3` to create the venv; after activation the project commands use `python`.

## Read first

1. `README.md` — repo map and actual current scene status.
2. `docs/game-design.md` — canonical game intent and confirmed/open decisions.
3. `docs/architecture.md` — current implementation versus intended dependency boundaries.
4. `docs/roadmap.md` — phases and exit gates.
5. `docs/ceres-run.md` — established crisis facts, character knowledge, and slice acceptance.
6. `docs/simulation-model-design.md` — open design decisions; do not treat demo constants as game rules.
7. `docs/mechflow-workspace.md` — Mechflow sidecar setup, shared model source, generated data path, and adapter limits.
8. `docs/ceres-simulation-proposal.md` — the first NPC-owned treatment repair case, with established facts separated from assumptions.
9. `docs/semantic-world-narrative.md` and `docs/design-references.md` — semantic retrieval/storylet proposal and design precedents.
10. `docs/political-ecosystem-model.md` — how group support, mobilization, coordination, material resources, and access can sustain collective agendas.
11. Check `git status --short` and inspect diffs before editing.

## Current implementation snapshot

- Godot project main scene: `res://main.tscn`.
- The main scene is a `Control` using `res://main.gd`; the script draws a top-down 2D floorplan and creates a keyboard-driven briefing overlay.
- The temporary demo supports movement, proximity interaction with the crisis board and three NPC sources, a J-key sourced case file, progress tracking, T-key day advancement, C-key rationing, B-key treatment repair using one spare part, K-key save, L-key load, and restart. K/L use a versioned `user://inner_dark_ceres_run.json` snapshot for simulation, event history, evidence, reviewed-source state, and the canonical Mechflow source hash; player position is not saved. Hashed saves reject a changed model; legacy un-hashed saves load with a warning.
- `EvidenceLedger` groups authored claims by verified/rumor/unresolved status and keeps source IDs and tick observations. Interacting with a source adds only that speaker's defined claims; evidence text is not inferred from dialogue and does not reveal a culprit.
- The `simulation/` directory contains typed stock/state/result/event contracts and an engine, plus reusable `WorldRecord` and `WorldRelationship` types. State snapshots include these records and a shared monotonic `world_time_units` counter; older snapshots without the new optional fields remain readable. Events carry world time, affected IDs, provenance IDs, and domain tags. `SemanticCandidate` holds untrusted retrieval IDs and a ranking score; `SemanticCandidateVerifier` checks current records, observer visibility, active recorded ties, and endpoints before returning context. None of these semantic contracts are connected to an embedding index or narrative model yet. `CeresRunSimulation` connects the stock model to the scene: the demo starts at 6.0 water-reserve days with one treatment component; T advances a day; C toggles demand from 1.0 to 0.5 reserve-days per tick; B consumes the part and restores 0.25 reserve-days before demand. Unserved demand accumulates and each tick emits a complete water-balance event. The HUD displays reserve, projected runout, day, policy, treatment/parts, cumulative unmet demand, and the three most recent meaningful events. The public crisis board reports current state; Mara and Sato react to recorded shortfalls without asserting a freighter culprit. K/L persist the full simulation and case file; there is no autosave or version migration yet. These stocks/rules are temporary demonstration assumptions, not canon.
- Godot-AI editor tooling is installed under `addons/godot_ai`. It is editor support, not gameplay architecture.
- Earlier smoke checks launched the scene, verified movement and one Mara interaction, and confirmed the original T-only reserve change. The newer shortages, case file, and K/L save path have not yet been verified in Godot. No automated gameplay test suite exists.

## Current simulation foundation

This is a contract layer plus a deliberately small visible demo rule, not a finished settlement simulation. Preserve the generic API; do not silently promote the 6.0-day start or 1.0-day use rate into canon. World time currently has no defined unit or automatic multi-scale catch-up. The records and semantic-candidate verifier are foundations only; political actions, background NPC capability aggregation, and storylet creation remain design/future work. The state snapshot sorts stock, world-record, and relationship IDs and returns event dictionaries. Rejected stock changes leave state and event sequence untouched. No broad automated gameplay test suite exists yet. `node tools/check_mechflow_parity.mjs` repeatably checks normal, rationed, and already-repaired water traces; the user confirmed manual save/load works. Mechflow converter action timing still differs from Godot B, as documented in `docs/mechflow-workspace.md`.

## User direction to preserve

The user said the 2D scene does not match the intended 3D wireframe brief and is a side track, then asked to continue the simulation and connect it to the scene. Keep the current T-key simulation display minimal; do not polish the 2D layout or treat it as the 3D specification. The 3D brief/reference was not found in checked-in docs at handoff creation; locate/read it before visual implementation. Do not invent what it looks like.

The Python test the user just completed was only a stub plumbing test. The user has not asked for model-quality benchmarking or for the Python subsystem to be integrated.

The user agreed that an offline treatment unit is a useful first scenario anchor if it exercises a small cast and coupled economic, social, and political dynamics. They selected one transfer mode for the first pass and clarified that water is a household necessity with high value under scarcity: it must actually be available and authorized to trade, and services should not shut down by default because they consume water as an industrial input. The proposal uses a component sale, maintenance-lead archetype, people-centered service impacts, a provisional shared-time cadence, and a community water-access rota as working choices. These are design assumptions for review, not canon. See `docs/ceres-simulation-proposal.md`.

## Canonical narrative facts

Ceres reserves are below one week; a commercial freighter carrying water-treatment components is missing; cargo transfers occurred outside the normal manifest schedule. Mara knows the shortage and missing freighter. Ilyan knows about off-schedule transfers and has rumors but does not know who took the freighter. Officer Sato knows irregular cargo is under investigation and that no verified evidence identifies attackers. No culprit, motive, exact route, branch outcomes, or ending has been established. Keep rumor distinct from verified fact.

## Architecture and trust rules

- Godot simulation/game code is the only authority for world state and state-changing actions. The rationing toggle and one-time treatment repair are placeholder interventions, each validated and recorded as events.
- Use typed values for identities, quantities, time, money, location, ownership, and permissions; use tags for flexible semantic state, never as a replacement for typed values.
- Preserve major events as language-rich, multi-domain records plus typed effects and provenance; do not reduce them to one resource metric. Embeddings suggest links; authoritative relationships and state verify them.
- Keep a persistent NPC roster and aggregate background capability; only resolve detailed individual behavior for relevant people/tasks and use coarser updates for inactive locations.
- Treat political groups as actors in the same resource-flow simulation. Separate sympathy, expressed support, mobilizable participation, organizational capacity, and material/institutional access; do not collapse them into one influence score.
- Couple political and economic state through authoritative ownership, access, policy, and transaction records. Political actions can change the rules governing flows; economic conditions can enable or constrain collective action, but neither system should be collapsed into a generic score.
- Treat social ties as a sparse, sourced network that can route information, credit, favors, access, obligations, and coordination. Preserve context-specific relationships; do not replace them with one universal affinity score.
- Make simulation changes deterministic from known state, explicit seed, and ordered input; emit events users can inspect.
- Model output and retrieved text are untrusted data. Narrative may present or propose; it never commits world changes.
- Character knowledge and memory must be scoped to authorized speakers and carry provenance.
- Local models only for narrative generation/embeddings; no hosted narrative API or external runtime call.
- Keep a model-free path through the core slice.

## Recommended next work

Follow `docs/roadmap.md` and `docs/mechflow-workspace.md`. Keep one editable Mechflow model under `simulation/models/`; Godot loads its numeric data through the generated runtime JSON and rejects unsupported formula changes. The current reserve-days model is still a plumbing demo. The next design artifact is the treatment-repair case in `docs/ceres-simulation-proposal.md`; get the user's review of its scenario assumptions and outcomes before replacing demo behavior. Then evolve the shared Mechflow model, Godot transitions, semantic retrieval contract, and deterministic scenario checks together. The longer-term text/embedding design is in `docs/semantic-world-narrative.md`; embeddings propose links but never authorize effects.

## Godot workflow

Inspect the active editor/session and project tree before making changes. Prefer the connected Godot editor tooling when available; verify its current tool schema rather than assuming names. Read diagnostics after script/scene edits and run a small, relevant smoke test. Preserve all existing working-tree edits. Never reset, overwrite, or discard unrelated changes to `main.gd`, `project.godot`, or docs while syncing. The owner plans to sync this local repository manually; do not push or publish on their behalf.

## Reporting

When handing work back, state what files changed, checks actually run, and any decisions still open. Distinguish implementation from roadmap and do not claim design goals are already implemented.

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
6. Check `git status --short` and inspect diffs before editing.

## Current implementation snapshot

- Godot project main scene: `res://main.tscn`.
- The main scene is a `Control` using `res://main.gd`; the script draws a top-down 2D floorplan and creates a keyboard-driven briefing overlay.
- The temporary demo supports movement, proximity interaction with the crisis board and three NPC sources, progress tracking, and restart. All progress is transient presentation state.
- No typed simulation model, deterministic tick, event history, save/load, travel, economy, validated consequence, player career, storylet system, local narrative runtime, or Godot/Python bridge exists.
- Godot-AI editor tooling is installed under `addons/godot_ai`. It is editor support, not gameplay architecture.
- A prior smoke check launched the scene, moved the player, interacted with Mara, and observed the progress counter advance to 1/4. This does not certify all interactions or any simulation feature.

## User direction to preserve

The user said the current Godot demo does not match the intended 3D wireframe brief and is a side track. Treat the 2D scene as a throwaway interaction test, not the visual design specification. The user does not want more time spent polishing or extending it right now. The 3D wireframe brief/reference was not found in the checked-in docs at handoff creation; locate/read it before attempting visual implementation. Do not invent what it looks like.

The Python test the user just completed was only a stub plumbing test. The user has not asked for model-quality benchmarking or for the Python subsystem to be integrated.

## Canonical narrative facts

Ceres reserves are below one week; a commercial freighter carrying water-treatment components is missing; cargo transfers occurred outside the normal manifest schedule. Mara knows the shortage and missing freighter. Ilyan knows about off-schedule transfers and has rumors but does not know who took the freighter. Officer Sato knows irregular cargo is under investigation and that no verified evidence identifies attackers. No culprit, motive, exact route, branch outcomes, or ending has been established. Keep rumor distinct from verified fact.

## Architecture and trust rules

- Godot simulation/game code is the only authority for world state and state-changing actions.
- Use typed values for identities, quantities, time, money, location, ownership, and permissions; use tags for flexible semantic state, never as a replacement for typed values.
- Make simulation changes deterministic from known state, explicit seed, and ordered input; emit events users can inspect.
- Model output and retrieved text are untrusted data. Narrative may present or propose; it never commits world changes.
- Character knowledge and memory must be scoped to authorized speakers and carry provenance.
- Local models only for narrative generation/embeddings; no hosted narrative API or external runtime call.
- Keep a model-free path through the core slice.

## Recommended next work

Follow `docs/roadmap.md`. First recover the 3D wireframe brief if visual work is needed. For gameplay architecture, the next substantive step is the foundation: agree minimal typed state and deterministic action/tick/event contracts, then implement one bounded Ceres stock transition and test it without UI or models. Keep the first slice small and report open decisions instead of silently canonizing them.

## Godot workflow

Inspect the active editor/session and project tree before making changes. Prefer the connected Godot editor tooling when available; verify its current tool schema rather than assuming names. Read diagnostics after script/scene edits and run a small, relevant smoke test. Preserve all existing working-tree edits. Never reset, overwrite, or discard unrelated changes to `main.gd`, `project.godot`, or docs while syncing. The owner plans to sync this local repository manually; do not push or publish on their behalf.

## Reporting

When handing work back, state what files changed, checks actually run, and any decisions still open. Distinguish implementation from roadmap and do not claim design goals are already implemented.

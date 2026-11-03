# Technical architecture and Godot workflow

## Authority and dependency direction

The Godot 4 game, written in GDScript, is authoritative. Keep domain state and rules in typed game code. UI and narrative services may request or present outcomes but cannot commit world changes. Target dependency direction:

```text
UI/scenes -> application actions -> simulation/domain -> persistence
                                -> event stream -> UI and narrative context
Godot game <-> local narrative process (future, explicit versioned contract)
```

This is a target boundary, not the current code. The checkout is a minimal interactive placeholder.

## State and actions

Use typed structures for money, counts, IDs, time, location, and other bounded values. Use tags for flexible semantic or narrative descriptors. Resolve actions in simulation: validate actor, permissions, preconditions, costs, and bounds; apply atomically; emit an outcome event. Treat model text, retrieved memory, and generated JSON as untrusted input. A proposal is data to validate, never an instruction to execute. Discrete ticks advance schedules and abstract travel. Keep simulation rules independent of UI nodes.

## Local narrative boundary

All generation and embeddings use local models; no cloud inference or external narrative service. The separate [inner-dark-narrative Python prototype](https://github.com/richdurham/inner-dark-narrative) has no current game integration. A future bridge needs versioned schemas, timeouts, health reporting, local-only operation, bounded payloads, and safe unavailable behavior. See that repository for the subsystem's actual behavior.

## Visual direction

The placeholder suggests a dark, quiet, information-forward UI: deep blue-black surfaces, restrained teal accents, clear typography, generous spacing, compact editorial labels. This is wireframe direction, not locked art direction. Establish legible panels and status hierarchy before decorative detail; support keyboard use and window resizing.

## Connected Godot-AI MCP

Discovery on 2026-11-02 found a live `inner-dark-godot` editor session targeting this checkout, Godot **4.7.2-stable**, plugin/server **4.4.1**, `main.tscn` open, game running. Advertised tool areas include session/editor state; project settings/run control; filesystem; scene/node inspection and authoring; GDScript create/read/patch; signals; resources; UI/theme; animation, audio, camera, materials, navigation, tilemaps; logs; runtime inspection/input; and GDScript test run/results. Inspect current tool descriptions and operation parameters at task time.

For Godot-specific work, list sessions and inspect editor state first; read affected files, use the relevant discovered tools, save explicitly as needed, and inspect logs/runtime. The MCP's presence does not prove the game was tested. Only session discovery was performed for this documentation. If the server is unavailable, say so and use repository files/installed Godot tools; do not invent tool names or assume availability. The plugin files under `addons/godot_ai` are project dependencies.

## Actual implementation status

Implemented: minimal `Control` scene and GDScript placeholder beats with a continue/restart button, plus the Godot-AI plugin. Not implemented: simulation, ticks, world data, persistence, careers, economy, travel, storylets, local model runtime, or narrative bridge.

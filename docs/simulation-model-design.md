# Ceres simulation model design

## Status

**Open for review: a player-scale model proposal is available in [ceres-simulation-proposal.md](ceres-simulation-proposal.md).** It treats colony strain as a result of production and demand, rather than asking the player to manage a colony-wide water inventory. No proposed rate or rule is established canon yet. A separate [Mechflow](https://github.com/Yalton/mechflow) instance hosts the visual economy model beside Godot. Its canonical model file is under `simulation/models/` in the Godot repository; the Mechflow launcher edits that file and exports a generated runtime JSON for the game. The adapter and its limits are documented in [mechflow-workspace.md](mechflow-workspace.md). The proposal is not a realism specification and does not add story canon.

The current Godot loop is a plumbing demo. Its reserve-days, treatment-part count, daily demand, rationing reduction, repair output, and tick behavior are temporary assumptions. They show that state, actions, events, and save/load can connect; they should not be read as the colony's operating rules.

## Established narrative constraints

- Ceres reserves are below a week.
- A commercial freighter carrying water-treatment components is missing.
- Cargo transfers occurred outside the normal manifest schedule.
- The person or group responsible, motive, route, and detailed cargo inventory are unverified.
- Character dialogue and generated narrative do not own or mutate simulation state.
- The player is an individual participant, not a colony manager; colony-wide conditions should be presented as operational strain and consequences rather than an inventory dashboard.
- Water is a household necessity and can become highly valuable under scarcity. Do not assume water is an input to unrelated manufacturing or that market listings include household-held/unavailable supply. Trade only actual available stock under valid access/ownership rules. Service disruption should be modeled through people, staffing, care, and availability unless a specific facility establishes a direct water dependency.
- The first Ceres scenario should exercise a small cast across economic, social, and political dynamics alongside the treatment repair. It should not expand into a whole-colony management simulator.
- Keeping authoritative records for the whole world is separate from simulating every record continuously. Store what exists and its last resolved time; resolve detailed behavior only at the active scale and relevant adjacent context. Catch inactive places up on demand from their last resolved time using elapsed-time rules, aggregate transitions, and consequential events in order. This is bookkeeping for continuity, not a visible clockwork schedule.

## Decisions to make

Resolve only the detail required to create a playable Ceres crisis loop. Keep each choice tied to an observable player decision or consequence.

The current first-slice proposal makes provisional choices for the transfer mode, maintenance-role archetype, service effects, time cadence, and collective response. See the [Ceres Run simulation proposal](ceres-simulation-proposal.md). In particular, the hour/day/week/month cadence and water-access rota are design hypotheses to review against action and travel pacing, not locked rules or established Ceres facts.

| Decision | Questions to settle | Record in the result |
|---|---|---|
| Player-facing pressure | What is the player trying to protect or restore, and which tradeoffs should be understandable? | Intended choices and success/failure states |
| Model boundary | Which local facilities, work orders, NPCs, and aggregate settlement conditions are needed for the first situation? Which people/locations stay in background pools? | Explicit entities and out-of-scope detail |
| Water accounting | Which local quantities or rates are needed to resolve treatment work? What production-demand relationship derives player-facing strain? Is any local buffer necessary? | Local units, capacity/rate rules, derived condition; no global inventory unless justified |
| Supply and demand | What sources, treatment steps, losses, and demand categories matter to the slice? Which are constant, scheduled, or action-dependent? | Rates and dependencies with sources or rationale |
| Treatment components | What does a component enable, how many are available, and what repair time or conditions apply? | Preconditions, costs, delay, resulting capacity |
| NPC capability and work | Which persistent NPC owns the concern? What can they do autonomously, and how are background capability, availability, tools, and parts aggregated? | Roster identity, skills, task ownership, autonomous and blocked outcomes |
| Time and scale | What does one local step mean? Which larger scopes need summaries? What state can be derived lazily, how does an inactive place catch up from its last resolved time, and in what order do production, travel, transfers, and consequential events resolve? | Shared timeline, per-scope resolution rules, deterministic catch-up, offline policy; no requirement to tick every record continuously |
| Player actions | Which actions should be available in this slice, what do they cost, who can authorize them, and when do effects arrive? | Validations, costs, delays, success and rejection outcomes |
| Shortage consequences | What changes when demand is unmet, at what thresholds, and how can the colony recover? | Explicit thresholds, effects, and recovery conditions |
| Information and semantics | Which structured facts and prose records are authoritative? Which links can semantic retrieval suggest, and what validates them? Whose knowledge is scoped? | Provenance, visibility, retrieval filters, verification rules |
| Tags and storylets | Which tags derive from state, which are earned, and how can a storylet proposal change state through validated actions? | Tag meanings, eligibility, allowed effects, stale-candidate behavior |
| Scenarios | What happens without the player, with each contribution, and when generated choices are stale or invalid? | Small deterministic outcomes for later checks |

## Decision record template

For each agreed rule, capture:

- **Rule:**
- **Reason it serves the player experience:**
- **State and unit affected:**
- **Transition or equation:**
- **Preconditions, bounds, and failure behavior:**
- **What the player can observe:**
- **Example input and expected result:**
- **Source:** user decision, established project fact, or explicitly labeled design assumption

## Design constraints

- Prefer the smallest model that creates a legible choice and consequence. Do not model a complete settlement or solar system for its own sake.
- Use explicit units and update order. Avoid mixing physical quantity with convenience metrics unless the conversion is defined.
- Keep rules deterministic for the same initial state and ordered actions unless a seeded random process is deliberately selected.
- Preserve the distinction between game truth, reports, rumors, and unknowns. Numerical precision must not imply unsupported narrative certainty.
- Preserve major events as language-rich, multi-domain records with explicit typed effects and provenance; do not collapse them into one convenient metric.
- Embeddings suggest relevant records; typed relationships, knowledge boundaries, and current simulation state verify candidate links before use.
- Treat the current values as replaceable demo data. Do not tune them into canon by repetition.

## Exit gate

The model is ready to implement when the user has reviewed the first NPC-owned situation, local quantities and rates, derived strain condition, background and player outcomes, tags/semantic eligibility, event meaning/provenance, timing, and deterministic scenario results. The future verification plan can then turn those scenarios into checks.

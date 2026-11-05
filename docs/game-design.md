# The Inner Dark — game design

Canonical whole-game design for the Godot repository. Confirmed decisions, prototype facts, and open design areas are distinguished below. Planned systems are not represented as implemented.

## Vision and pillars

The Inner Dark is a grounded, character-centered science-fiction RPG about making a life and consequential choices in a living, economically interdependent Solar System. The player is a person with a role in society, not an all-powerful commander. Work, access, scarcity, institutions, travel, and relationships create pressure behind stories. The first playable proof is Ceres Run: a colony under water-supply pressure, a missing freighter carrying water-treatment components, irregular cargo movements, and people with different, bounded pieces of the truth.

Pillars: (1) a world that moves without the player; (2) human-scale agency in a large system; (3) grounded uncertainty between witnessed fact, report, rumor, and inference; (4) local AI within firm simulation boundaries; and (5) readable systems with restrained presentation.

Relevant precedents and the project-specific synthesis are recorded in [design references](design-references.md). They inform design questions; they are not feature commitments.

## Player role and careers

The player inhabits an individual in the Solar System and participates through a career or occupation. A career should grant useful actions, access, contacts, income, and obligations without blocking the central story. Starting careers, skills, progression, character creation, and career changes are undecided. Do not treat specific career examples as canon. Ceres Run should support at least two viable approaches to its problem; the exact roster remains open. Player agency stays at the individual scale: the player can buy or deliver supplies, contribute relevant items or sourced advice, and perform skilled work when qualified. For settlement-scale problems, the responsible NPC or institution owns the response; the player enables or influences it rather than directly managing the colony.

## Solar System simulation and world loop

Godot game code owns authoritative state. Discrete ticks advance scheduled work, stocks, travel, NPC plans, and settlement conditions. A tick should be reproducible from known state and inputs and emit events explaining meaningful changes. Intended loop: inspect conditions and people; choose work, trade, travel, conversation, or another supported action; validate and resolve it in simulation; advance time; observe inventory, relationships, availability, and story opportunities. Tick duration, offline advancement, event order, save format, and simulation scale are open. Start with a bounded set of places and modeled flows; add detail only when it creates a choice or legible consequence.

NPCs pursue their own work and concerns, but the simulation need not update every individual continuously. Keep a persistent roster of people and their meaningful skills, roles, affiliations, locations, and tags. Aggregate background capability by community or area so routine problems can be handled abstractly—for example, repair capacity depends on qualified and available people as well as suitable parts. When the player enters an area or a situation makes someone relevant, surface an existing rostered NPC whose location and capabilities fit. Preserve that NPC's identity and important state; do not create duplicate or disposable characters just to fill an encounter. Let the simulation spend detail on named NPCs, active tasks, and player-visible consequences while resolving other background activity in aggregate.

Simulation cadence follows the scale relevant to the player. Use one world clock with finer updates for local activity and coarser updates for settlements, planets, regions, and the Solar System. When the player is on foot, resolve the current settlement at its local cadence and expose at most adjacent-scale context; do not advance every settlement's detailed daily simulation just because time passes. During interplanetary travel, update travel and system-level conditions at a coarser cadence. When an area becomes relevant again, bring its aggregate state forward from its last update using elapsed time, scheduled events, and intervening inputs. This is a design direction; exact cadences and catch-up rules remain open.

NPCs pursue their own work and concerns. They can notice a broken machine, a market shortage, or another pressure, then try to address it using their goals, skills, resources, and access. Some problems resolve without the player; others stall, worsen, or create an opportunity for help. Named characters make these processes legible and personal, while background activity can remain aggregated. The player discovers and responds to situations rather than receiving every problem as an assignment or being responsible for solving the world.

## Travel, locations, and ships

Travel between meaningful locations is abstracted. The player chooses a destination and route/service, sees known time and cost, and simulation resolves progress and arrival over ticks. Continuous piloting and n-body orbital simulation are not requirements for the core loop. Local scenes may support direct exploration when useful. The initial slice centers on Ceres and immediate connections; the canonical location list, route graph, hazards, and missed-departure behavior are TBD.

Ships are mobile assets enabling travel and cargo/people movement. Future typed fields may include condition, capacity, operating supplies, ownership, and services only where they create gameplay. No detailed ship system is established. Ceres Run uses only enough detail to make arrival, cargo, and travel choices clear.

## Economy and commodities

The economy connects production, stocks, transport, demand, price, and access. Scarcity should have understandable logistical causes. Amounts, prices, balances, and transfer records are typed; tags can describe `scarce`, `restricted`, or `rumored`, but never replace quantities or identities. Item and advice tags may help an NPC evaluate whether a contribution fits a work order; tags do not guarantee acceptance or a state change. Simulation code resolves transactions and validates contributions. Settlement-scale simulation should expose conditions such as production strain and service reliability at the player's level, not require colony-management of aggregate inventory.

Political groups are part of the same resource-flow ecosystem as markets, work, ownership, and infrastructure. Economic rules shape who can obtain, control, and move resources; political groups can influence those rules and the resulting flows. Their ability to act depends on expressed support, active participants, coordination, material means, legitimacy, and access appropriate to the group. Do not reduce politics to one influence score or assume supporter numbers alone create action. Preserve motivations, internal differences, and histories in language-rich records; use typed aggregates only where needed to resolve a specific collective action. See [political ecosystem model](political-ecosystem-model.md).

Tags also carry semantic progression. Some tags are projections of current simulation conditions (such as a strained service); others record an NPC's skills, the player's demonstrated capabilities, affiliations, reputation, or choices. They can affect which NPCs can handle a background problem, who engages the player, which opportunities appear, and which missions become available. A tag that represents a changing material condition should be derived from authoritative stocks, rates, or events; a tag that represents a person or player's capability or earned trust should be awarded from authored data or validated actions with provenance. Community capability is an aggregate derived from rostered people, availability, tools, and parts; a skill tag by itself does not guarantee that the community can perform the work. Tags do not replace inventory, skill checks, relationships, or simulation state. Ceres Run establishes water and water-treatment components as relevant; the missing commercial freighter and off-schedule transfers appear in prototype profiles. Full commodity catalog, production chains, pricing, currency, ownership, tag taxonomy, and market interface remain undecided.

## Factions and NPCs

Three established prototype characters define the current Ceres premise:

- **Mara Venn**, Mining Administrator: pragmatic and politically cautious; knows the water-treatment freighter is missing and reserve capacity is below a week.
- **Ilyan Rusk**, Independent Merchant: opportunistic and observant; knows transfers occurred outside the normal manifest schedule, has rumors, and does not know who took the freighter.
- **Officer Sato**, Militia Officer: disciplined and suspicious; knows irregular cargo is under investigation; no verified evidence identifies attackers.

Administration and militia are present as roles, not a finished faction system. A formal faction roster, membership, reputation, NPC schedules, and relationship mechanics are TBD. Enforce character-specific knowledge.

The social substrate connects persistent people and groups through relevant ties such as affiliation, obligation, trust, conflict, dependency, and communication. These ties can route information, access, credit, favors, and coordination, but do not replace material resources or make all characters agree. Preserve relationship context and provenance; avoid collapsing relationships into one universal social score. Aggregate background networks when individual ties do not matter to the current situation.

## Narrative, storylets, and tags

Authored scenes and conditional storylets become eligible when location, timing, prerequisites, and state conditions hold. Game code checks eligibility and commits consequences. Tags represent flexible semantic/narrative state (for example, a clue is `rumored`, `verified`, or `contested`); typed structures represent people, amounts, time, and accounts. Preserve source and confidence: witnessed event, trusted report, rumor, inference, unresolved claim. Model output never becomes canon just because it sounds plausible. Storylet schema, tools, conflict handling, and localization remain open.

The intended longer-term direction includes semantic retrieval across descriptions and sourced world events to find combinations of characters, objects/resources, and situations that can form relevant storylet opportunities. Structured state and relationships remain authoritative; embedding similarity proposes relevance, not causality. Preserve major events as language-rich, multi-domain records with typed effects and provenance; do not reduce a place or event to its most visible resource metric. The local text model may frame a storylet and propose choices, but game validation resolves any resource, task, relationship, evidence, or flow changes. See [semantic world narrative design](semantic-world-narrative.md) for the proposed layers and controls.

## Natural-language dialogue and memory

Local models may make conversation responsive. Retrieval is scoped to the speaking character and explicit visibility rules. Memory preserves provenance and separates established events from unverified candidates. Dialogue can communicate, ask, react, or make a constrained proposal; it cannot itself complete a trade, mission, movement, or world-state change. The independent [Python narrative subsystem](https://github.com/richdurham/inner-dark-narrative) owns its implementation details. There is no Godot IPC or runtime integration yet.

## Scope boundaries

Game direction includes a useful abstraction of a living Solar System, tick-based simulation, meaningful travel, economic participation, settlements, ships, commodities, NPCs, authored storylets, and local dialogue support. Initial scope excludes real-time orbital mechanics, seamless planet-scale worlds, cloud narrative AI, autonomous state-mutating AI agents, full voice simulation, universal simulation of every actor, and a large handcrafted map before the loop works.

## Milestones

1. Foundation: Godot structure, typed domain model, deterministic tick/event contracts, save/load direction.
2. Simulation loop: one settlement, a few commodities/actors, observable transitions, one validated player action.
3. Travel and work: abstract route progress, arrival, occupation, tick-resolved costs/rewards.
4. Ceres Run: shortage, missing freighter, irregular cargo clue, three knowledge-bounded NPCs, multiple validated outcomes.
5. Narrative bridge: explicit local process contract, graceful unavailable behavior, character-scoped context, strict proposal validation.
6. Expansion: broaden locations, economy, careers, factions, and content based on slice evidence.

Ordering goals, not schedule commitments. See the [implementation roadmap](roadmap.md) for phase deliverables, dependencies, and exit gates.

## Risks and mitigation

Scope growth: keep Ceres bounded and justify every variable by player value. Opaque simulation: emit inspectable events and explain changes. Fabricated AI facts/actions: limit context, validate structured output, keep state mutation in game code. Memory leakage: filter per character and test visibility. Model performance/licensing: benchmark target hardware, support unavailable-model behavior, verify distribution rights. Prototype drift: narrative repo owns subsystem facts; this document owns game intent; integration uses an explicit versioned contract.

## First slice acceptance criteria

- Player can inspect the Ceres supply crisis and understand the component dependency.
- A tick deterministically advances relevant stock/schedule and exposes changes.
- At least one travel and one work/trade/action path resolve through game validation and typed state.
- Mara, Ilyan, and Sato retain distinct bounded knowledge.
- Rumor does not silently become verified fact.
- Two supported approaches reach meaningfully different simulation-validated outcomes.
- No model response directly changes credits, inventory, missions, travel, or canonical facts.
- Slice works with no local model installed or running.

## Open decisions

Tick duration/order; careers/progression; location graph; ship operations; commodity/pricing rules; formal factions; tag/storylet schemas; persistence/event log; target hardware/model budget; dialogue transport; final visual production direction.

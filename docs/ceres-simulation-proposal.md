# Ceres Run simulation proposal

## Status

This proposal follows the player-scale boundary: Ceres is not a colony-management interface. The player should encounter operational strain and its effects, not a colony-wide water ledger or an exact countdown to depletion. The current water reserve-days demo remains useful for checking stock/flow plumbing, but it is not the target player model. The user considers an offline treatment unit a useful working scenario assumption if the situation exercises character relationships and political, social, and economic dynamics together. This accepts it as a design anchor, not as established Ceres canon. Other rules below remain proposals.

## Simulation viewpoint

Model water infrastructure through production capacity, active production, and demand rates. The settlement-level result is a qualitative strain state derived from how dependable production compares with demand. Do not expose or require a single total quantity of water held across Ceres.

The player is an individual in a living settlement, not its administrator. NPCs have their own work, concerns, and attempts to address problems. An NPC may notice an outage or shortage and pursue a fix; a task can progress, stall for missing resources, or worsen without player involvement. The player may come across the problem, hear the NPC's account, and decide whether to help, trade, take advantage of the opportunity, build goodwill, or continue on. Not every problem needs to become a player mission, and not every problem should wait for the player.

Player actions affect local processes, components, work orders, shipments, markets, or relationships within reach. The simulation can propagate local changes into a colony-level strain trend, but the player does not directly set colony policy or allocate every unit. When a problem belongs to settlement infrastructure, an NPC or institution owns the response; the player may help that response succeed.

## Model boundary

Represent just enough of the water system to explain the missing treatment components and support a few player-scale interventions:

| Model concept | What the simulation tracks | What the player sees |
|---|---|---|
| Dependable treatment capacity | Capacity that can operate when required components and conditions are present | Whether treatment is operating reliably or has a known limitation |
| Production rate | Output rate of the relevant infrastructure, in internal model units per tick | A broad status such as keeping pace, falling behind, or unreliable |
| Demand and access | Household and essential-use demand, plus local availability and access rules | Who can obtain water, where, and at what terms; water is a high-value necessity, not a generic industrial input |
| Local component/work state | Parts, work orders, and ownership only for locations or actions that matter to the player | Whether the player can help, what the action costs, and when its effect arrives |
| Player contribution | The player's own inventory, relevant skills, delivered goods, and offered information | What the player can personally do and what an NPC can use |
| Settlement strain | Derived state from the production-demand relationship over time | Qualitative condition and concrete service or work consequences, not total water or days remaining |
| NPC situation/work | An NPC's concern, goal, available means, current task, and progress | Who is trying to do what, what is blocking them, and how the player could engage |
| NPC roster and community capability | Persistent identities and capability tags, plus aggregate coverage by community/area based on people, availability, parts, and tools | Relevant existing people appear when encountered; routine work can resolve without a full simulation of everyone |
| Semantic tags | Derived condition tags and earned capability/reputation tags, each with a source | Context for dialogue, recognition, and opportunity access |

Internal rate units are for consistent simulation and balance. They do not imply that the player knows precise colony-wide quantities. A local facility may use exact component counts when those counts matter to an action; that does not create a global stock inventory.

## Draft behavior

The missing freighter remains the disruption: it carried water-treatment components, and the colony's system is under pressure. A settlement NPC is responsible for restoring the affected treatment process. The player may contribute at an individual scale in several ways:

- Sell one compatible treatment component to the maintenance lead as the first playable transfer mode, if the player owns it and the buyer has an authorized budget. Donation is deferred so the first loop has one clear economic transaction; it can be added later as a distinct choice with social consequences.
- Buy and deliver bulk water only when a seller has water actually available and is willing or permitted to trade it. Under severe strain, water is valuable because people need to drink and provide for their families. Household-held or unavailable water is not market stock that the player can simply buy.
- Offer advice or a useful lead later as a tagged, sourced contribution; an NPC decides whether it is relevant to the repair.
- Perform repair work directly only in a later route if the player has the required skill and the action is within their reach.

These paths should not all be available in every case. The particular machine failure, needed parts, NPC responsible, player skill, access, and consequence must be defined by the scenario. A delivery of water can relieve a local short-term need; a successful repair changes a production rate and can ease continuing settlement strain. The model should make that difference legible without displaying a total colony water stock.

NPCs and markets can also make situations the player may exploit or support. A shortage might prompt an NPC to seek a supplier, while a player with access to bulk goods can sell or deliver them. A player may choose immediate profit, a favorable price, or a goodwill-building contribution. These should resolve through transactions and relationships in simulation, not dialogue alone.

At each local resolution, compare dependable treatment output with household and essential-use demand and resolve water access. If reliable supply falls short, strain worsens. Water scarcity does not directly shut down unrelated manufacturing or services as though water were a machine input. A service can be disrupted because people are absent, ill, caring for family, waiting for water, or organizing around access; represent that through the relevant people, availability, and work state. Do not invent industrial water dependencies unless a specific facility and scenario establish them. A repair is an NPC-owned work order with preconditions, required parts or skill, progress, and a resulting change to local treatment capacity or uptime. The player's initial action changes the work order through one validated component sale. The game records the causes and consequences as events.

### Character and substrate dynamics for the first situation

Use the repair as a shared pressure point for a small cast, not as a solitary part-fetch. The minimum useful cast can be authored by role before names are chosen:

- **Maintenance lead:** owns the work order and can explain the technical blocker, while having their own limits, obligations, and judgment about proposed help.
- **Bulk-market seller or broker:** controls or knows about relevant stock, prices, credit, and supply delays. Their economic choices respond to scarcity and risk.
- **Political or community organizer:** makes water access a public issue, seeks support for a particular response, and may frame responsibility or allocation in a way that is contested.
- **Affected resident or worker:** shows the lived consequence and may have ties, duties, or priorities that do not align with either the organizer or the maintenance lead.

These are roles to exercise the model, not a fixed cast or faction canon. Existing scene characters can fill a role only if their established knowledge and motivation fit. Not every role must approach the player immediately; some can act in the background or be encountered through a display, rumor, market listing, dispute, or later consequence.

The situation should make at least one causal loop legible across substrates: the outage constrains dependable supply; households prioritize drinking water and family needs; only genuine surplus or authorized stock appears for sale, so market availability tightens and prices may rise; people interpret who receives access and express support or resentment; an organizer coordinates a response using relationships, participants, and material means; that response may change distribution access or procurement; and those changes feed back into people's availability and repair progress. Social ties route trust, information, favors, and cooperation, but do not create parts or prove claims. Political action requires specific participants, coordination, access, and resources rather than one generic influence score. The player can buy the compatible repair component if it is genuinely available, pass information later, take a position, or decline, while NPCs and groups continue their own attempts.

For a first collective response, use a provisional **community water-access rota**: the organizer is trying to coordinate pickup times and priority for people with urgent household needs, with the affected resident helping or challenging the proposed rules. It requires a trusted organizer, a place or channel to publish the rota, agreement from a water distributor, and enough participants to make it workable. The market broker may resist restrictions or cooperate to retain customers and trust; the maintenance lead may support repair priority because it improves dependable supply, while refusing to endorse a rule they cannot control. The rota changes who can access available water and when; it does not create water or directly repair the treatment unit. Record participation, access, and resulting relationship or service effects. This is a scenario proposal, not established Ceres politics.

Keep this bounded: one treatment outage, one work order, a small set of existing characters, one market, and one collective response or dispute are enough to test the coupling. The player should encounter different interpretations and consequences, not manage a full settlement budget or simulate every supporter as an individual.

NPC work continues when the player does nothing. A person with the relevant responsibility can make progress if they have the required means, seek help if blocked, or fail to resolve the problem in time. The player enters this activity through encounters and opportunities, not a global task list. Their contributions can affect task completion, profit, goodwill, and later access to opportunities.

## NPC population and simulation detail

Keep a persistent roster of NPC identities with only the data needed to support continuity and world logic: role, skills/capabilities, tags, home or work area, affiliations, and any individually important state. Do not run every NPC's full schedule and decision loop on every simulation tick.

For background resolution, derive community capability from the roster. For a repair, for example, capability depends on how many suitable people are available in that area and whether the required parts, tools, and work access exist. If coverage is adequate, routine work may be completed abstractly without creating a player mission. If no capable person is available or a key input is missing, the problem can remain unresolved, worsen, or create a help-seeking situation.

When the player enters an area or a situation calls for an encounter, select a relevant person from the persistent roster based on location, role, capability, schedule/availability, and current concerns. Surface the same person and preserve consequential state such as commitments, relationships, and active work. This is lazy presentation and detailed simulation of existing people, not procedural creation of a new NPC for each event.

Use exact individual detail for named characters and active player-facing situations; use aggregate capability and coarse outcomes for the rest. A capability tag is evidence of skill, not a unit of workforce by itself: background success also checks availability and necessary resources. The aggregate should not count an unavailable, occupied, or unequipped specialist as ready capacity.

## Provisional simulation cadence by scale

For the first slice, use one shared timeline measured in **hours** and resolve local work in **one-day intervals**. This is a starting assumption for scenario pacing, not a visible player clock or a claim about final travel times. Local interactions and transactions may create timestamped changes immediately; ongoing repair work, household access, and NPC availability are summarized at the next local day boundary. Settlement/planet summaries can be recomputed weekly and regional/system summaries monthly when they become relevant. Revisit these intervals when travel pace and playable action costs are known.

The shared clock is a consistent timeline, not an instruction to continuously tick every location or NPC. Keep the world roster and authoritative records available as data, with a last-resolved timestamp for state that changes over time. Resolve detailed activity where the player is; summarize broader scopes. When an inactive place or process becomes relevant, catch it up from its last resolved time using applicable aggregate rules and timestamped consequential events. This avoids simulating every settlement every local day while preserving continuity. Only consequential changes need persistent events; routine background activity can be folded into an aggregate result. The current code has a monotonic `world_time_units` counter but not these catch-up semantics.

- At a settlement, resolve local work, nearby NPC concerns, household access summaries, and player actions at daily boundaries. Expose the local situation plus only adjacent-scale context, such as the settlement's relationship to Ceres or its region.
- At a planetary or regional scale, refresh settlement summaries weekly and account for timestamped transfers. Do not simulate the internal daily work of every settlement in detail.
- During deep-space travel, advance route progress and relevant Solar System conditions; refresh broad system summaries monthly or at a consequential event. Do not tick every Ceres facility or NPC each day while the player is away.
- When a place becomes relevant again, update it from its last simulation timestamp to the current world time using its aggregate rates and scheduled inputs. Retain exact event history only for consequential events; do not replay every unobserved routine action.

This is a hierarchy of resolution, not independent clocks that drift apart. Actions, transfers, deadlines, and important events carry world timestamps. Coarser transitions must account for those inputs in order and produce deterministic results. Preserve detailed local state for active player-facing situations; background locations can summarize elapsed activity into current condition tags, capability coverage, and important events. The player-facing view should normally center on the current scale and one adjacent scale, not expand every lower-level entity at once.

## Tags and opportunity access

Use tags as semantic links between simulation and narrative opportunities, not as substitutes for state:

- **Condition tags** such as `treatment_strained` or `market_shortage` derive from authoritative flows, capacities, and task state. They appear and clear as those conditions change.
- **Capability tags** summarize demonstrated skills, knowledge, contacts, or access. Validated progression or evidence awards them.
- **Relationship tags** record meaningful standing with a person or group, with provenance such as a fulfilled request, successful trade, or broken commitment.
- **Item tags** describe properties useful for matching an item to a task. Quantity, ownership, and transfer are checked separately.

Mission and conversation eligibility can combine tags with location, time, NPC availability, evidence, and current simulation conditions. A tag can open an opportunity; it cannot make an unavailable part appear, complete a repair, or prove a rumor. Tags that change should record their source and the condition that clears or updates them.

## First worked case: treatment repair

This is the proposed first NPC-owned situation. The listed project facts are established; the machine failure, work order, and exact intervention details are scenario assumptions to review.

| Established project fact | Working scenario assumption |
|---|---|
| Ceres reserves are below a week. | A treatment unit is offline, contributing to community water-service strain. |
| A missing commercial freighter carried water-treatment components. | The repair needs a component with a known compatibility tag that is currently not in the maintenance area's ready stock. |
| Cargo transfers occurred outside the normal manifest schedule; responsibility is unverified. | A persistent maintenance NPC owns the work order and has the skill to perform the repair if the required input is available. This NPC's identity is an authored roster record, not generated anew per encounter. |

### State to represent

- A service-level treatment capacity/rate and a derived qualitative condition such as `strained`. Do not put total Ceres water inventory or days-left into the player HUD.
- Separate authoritative conditions from player knowledge and presentation. Track which conditions are public, which a character knows, what the player has observed or been told, and the source/time of each report. A display or NPC line is an interpretation of state, and may be local, incomplete, stale, or access-controlled.
- A local work order with a stable ID and owner NPC, status (`diagnosing`, `waiting_for_component`, `ready`, `in_progress`, `complete`), compatible part requirement, progress, and result.
- Persistent NPC roster data for role/capability, location, current availability, concern, and relevant relationship/knowledge state. Community repair coverage is derived from available qualified people plus required parts/tools; it is not a raw count of skill tags.
- Player inventory, credits if the scenario uses a purchase, relevant skill tags, and sourced advice/evidence. Existing game state validates possession and access.
- A semantic record for the outage, the maintenance NPC, and the component description, each linked to structured IDs and source/uncertainty data.
- Player-facing manifestations of strain: local service status, market stock/price signals, NPC concerns and disputes, political claims or organizing, and concrete requests for help. These are authored or derived from the same underlying state and retain location, access, source, and time; they are not separate competing water models.

### How the player learns that water is under pressure

The player should infer a living situation through several partial, situated signals rather than a global inventory dashboard. The game need not expose every signal everywhere, and none of these channels alone has to explain the whole cause:

| Channel | Example signal | What it communicates and what constrains it |
|---|---|---|
| NPC dialogue and ambient comments | Workers mention disrupted shifts; residents complain about restrictions; a maintenance NPC explains what is blocking a repair. | The speaker's knowledge, perspective, and willingness shape what they say. Claims retain source and uncertainty. |
| Diegetic displays in the 3D wireframe | In a water-cargo area, a permitted terminal or sign reports low local inventory or delayed replenishment. | Display only what that location measures and what the player can access. Local cargo inventory is not the same thing as total Ceres water. A display can be delayed or limited to an authorized user. |
| Bulk market | Water or treatment-related goods show low listed stock, high prices, limits, or supplier delays. | This reflects market inventory, offers, and transactions. Price and stock are evidence of pressure, not a complete measure of community condition. |
| Political activity | A group or representative makes water access an issue, organizes around allocation, or blames a policy. | Political actors interpret and frame conditions; their claims may be contested and should be attributed. |
| Social friction | People argue over access, queues, priority, or perceived unfairness when strain affects them. | Conflicts emerge from specific access rules and relationships. Do not make desperation automatic or universal merely because a condition tag is active. |
| Discrete requests and missions | The maintenance NPC asks for a compatible part, a supplier lead, skilled labor, or help reaching someone. | Requests arise from an existing person's goal and a real blocker. Not every shortage becomes a mission, and the player can decline while the world continues. |

These presentations should be consistent consequences of shared authoritative records: treatment capacity and work status drive service conditions; local inventory and offers drive market signals; affected characters and groups respond according to their knowledge, stakes, resources, and relationships. The 3D wireframe can present an intentionally loose interpretation of reality, but must not contradict a more precise fact the game has already established without a reason such as stale data, restricted access, or an unreliable source. Keep the distinction between what is true, what is observable in a place, and what a character or the player currently believes.

### Background behavior

At the local settlement cadence, the NPC can inspect the work order and act without player input. If a qualified person and compatible part/tool are available locally, routine work proceeds and may complete in the background. If the required component is absent, the work order becomes `waiting_for_component`; the NPC can register a procurement request or seek a known source, but the simulation does not invent an arrival date or a component. A later supply event can unblock it. If the player is elsewhere, this location advances through its coarser background update and preserves task status and consequential events.

This makes the player useful but not mandatory: a capable community can solve a supplied repair, while a real input shortage remains a world condition that can persist or create an opportunity.

### Player-facing opportunity

When the player is in a relevant area, the system can surface the existing work-order owner and form a storylet candidate from three linked records:

1. **Event/condition:** treatment outage and current strain.
2. **Character:** the maintenance NPC owns the task, is present, and has repair capability.
3. **Object/resource:** a compatible component is present in player inventory or a local market, or an evidence-backed lead points to a source.

Embedding similarity can retrieve related descriptions and event memories. Structured relations and live checks then determine whether any choice is valid. In the first pass, offer a sale only when the player owns a compatible component, the maintenance NPC can purchase it, and access/task conditions hold; otherwise do not offer the transaction. Donation, a sourced lead, and qualified player repair are later options, not part of this initial loop.

For the first slice, focus on the one component-sale choice. Advice/lead actions can follow once the evidence and knowledge model defines how an NPC accepts technical information. Donation and qualified player repair can be added later after their distinct social, skill, and access rules are defined.

### Validated effects and event record

The selected option is resolved by game code as one transaction. For example, an accepted part transfer checks ownership, quantity, location, compatibility, NPC/task acceptance, and whether the part has already been committed elsewhere. It transfers the item and changes the work order to `ready`; it does not instantly change settlement strain. Work progresses on the local cadence, and completion changes treatment capacity. The settlement condition is then recomputed from production versus demand.

Record the outcome as a multi-domain event linked to its source records: item/credit transfer if any, work-order status and owner, treatment capacity change when it occurs, updated strain condition, relationship effect if authored, and provenance. The event retains a readable description and affected entities instead of reducing the result to only a water-rate delta. Rumors about the freighter remain separate from verified repair facts.

### Scenario checks before implementation

- **Routine background success:** compatible part and qualified NPC are available; work completes without player involvement, and service strain can ease.
- **Blocked repair:** part is unavailable; NPC records or pursues procurement, but the unit remains offline until a real supply event.
- **Player sells part:** a valid owned component is transferred for an authored price; NPC task becomes ready; repair completes only after its work interval.
- **No compatible component for sale:** the sale option is absent; the NPC's procurement effort and the collective water-access response can continue independently.
- **Later extension — unqualified repair attempt:** if direct player repair is added, reject it without changing inventory, task, or treatment state.
- **Stale storylet:** if the NPC moved, the part sold, or the task completed after generation, revalidate and remove/update the option before presenting or committing it.

Do not yet choose numeric thresholds for strain tiers, specific services affected, exact treatment output, a repair delay, or a rationing action. Those need to follow from the intended player role and the consequences the slice should support. Keep physical reserve storage out of the settlement-level model unless a concrete scene decision requires a local buffer.

## Why stocks and flows still help

Stocks and flows remain useful for showing what changes a production system over time: installed capacity, available components, work in progress, production, and demand. At larger scales, the diagram can connect local facilities to settlement service pressure and connect settlements through shipments and travel delays. It need not represent every physical unit held by an entire colony.

The same model can therefore have two kinds of state: local stocks needed to resolve an operation, and aggregate indicators derived from flows for settlement-level conditions. Godot should consume the shared model values and apply reusable transitions; the HUD should present consequences at the player's level of knowledge and agency.

## Design questions to settle next

1. **Working scenario assumption:** an offline treatment unit anchors the case, paired with a small cast and coupled economic, social, and political dynamics. The outage itself remains an assumption; the established facts do not identify a particular failed machine.
2. **Player transfer:** begin with one mode: a validated sale of a compatible component to the maintenance NPC. Defer donations until their distinct social consequences are designed.
3. **Water consequence:** do not model water as an automatic manufacturing input. Under scarcity, actual water stock is retained for drinking/family needs and sold only when available surplus and permission exist. Service disruption is represented through concrete NPC availability/work consequences (absence, care duties, time spent obtaining water), not a generic water-dependent-industry penalty. Choose the specific affected person and service when authoring the worked case.
4. **Maintenance character:** use a persistent maintenance-lead archetype until the named cast is chosen; do not create a new character identity per encounter.
5. **Provisional cadence:** use an hour-based shared timeline; resolve local work and household access daily, settlement/planet summaries weekly, and broader regional/system summaries monthly or at consequential events. Catch up inactive state on demand. Revisit once action costs and travel times are known.
6. **Provisional collective response:** test a community water-access rota coordinated by an organizer, requiring participant support, a publication/meeting channel, and distributor cooperation. It changes access timing/priority, not total water or repair capacity. The broker, maintenance lead, and affected resident can hold different interests in it.

Once these are answered, update the Mechflow model and Godot transition together. Keep exact counts and rates internal where needed, but expose only information the player could reasonably access. The existing demo parity scenarios should be replaced by scenarios for local interventions and changing strain states.

# Semantic world narrative design

## Goal

Use the local text model and embedding index to connect simulation events, objects/resources, characters, and places into relevant narrative opportunities. Preserve events as language-rich, multi-domain records, not just numeric deltas. A major event can affect several systems, relationships, and perspectives; its record should retain that context so later retrieval does not treat it as only the one metric that changed most visibly.

The intended result is a storylet opportunity whose choices can affect the world: advance or block work, transfer an item, change a relationship, add or remove a tag, expose evidence, or change a local flow. Semantic retrieval helps find candidate connections; the game simulation validates and applies every effect.

## Three linked representations

| Layer | Stores | Authority |
|---|---|---|
| Structured world state | Stable IDs, typed quantities, ownership, location, time, relationships, work/task state, capability, tags, event sources, and knowledge boundaries | Authoritative game state. The simulation reads and changes this layer. |
| Semantic text records | Descriptions of people, places, objects, resources, events, memories, and authored lore, each attached to stable IDs and provenance. Event records retain context, affected entities/systems, perspectives, and uncertainty. | Human-readable context and semantic retrieval material. Text never supersedes its linked structured facts; numeric state does not replace the event's meaning. |
| Embedding index | Vector representations of semantic text records, indexed by record ID and filtered metadata | Search index only. It can suggest relevance; it is not the canonical database and does not itself prove a relationship. |

Do not try to store the world only in vector embeddings. Keep the original text and structured record. An embedding can find that two descriptions are conceptually related, but it cannot reliably answer whether an item is owned by the player, is available, fits a machine, or is known to a particular character.

## Candidate formation by triangulation

Use both semantic similarity and explicit world relationships to form a candidate. A minimal pattern is:

1. **Event or pressure:** a dated, sourced event or derived condition creates a reason for something to happen (for example, a repair task is blocked or a market has a shortage).
2. **Character:** find an existing rostered person who has a role, goal, knowledge, relationship, or capability that connects to the situation and is actually available in the area.
3. **Object/resource:** find an object, item, service, or resource that is semantically relevant and is structurally available to that character or the player. Confirm ownership, quantity, tags, location, compatibility, and transfer rules through authoritative state.

Semantic search can broaden each candidate list. A relationship graph and typed filters then establish which links are real: a character owns a task, an item is a required input, an event was witnessed, a resource is available at a market, or a person has the relevant skill. Requiring connected evidence across event, person, and object helps create unexpected but grounded combinations. Similarity alone must never turn an unrelated item into a valid repair part or give a character knowledge they do not have.

Triangulation should also cross system boundaries. For example, a catastrophic explosion on Luna should remain an event with a place, people and organizations involved, sources, uncertainty, and any established operational, social, political, or logistical consequences. It must not be represented only as “water production decreased.” Which consequences are real is decided by authored scenario data and validated simulation rules; semantic links can surface related characters, reports, goods, and later storylets without inventing those consequences.

## Storylet proposal and resolution

The text model may propose:

- A concise setup that reflects the retrieved situation and character perspective.
- One or more choices whose requirements are visible or explainable.
- A typed list of intended effects, such as `offer_item`, `sell_item`, `contribute_advice`, `perform_work`, `advance_work_order`, `change_relationship`, `record_evidence`, or `adjust_local_rate`.
- Provenance references to the event, character, item/resource, and authored records used to build the proposal.

The model does not directly write canonical state. Game code validates each option against live state: actor identity, knowledge permissions, location, time, skills, inventory and ownership, price or cost, resource availability, task preconditions, effect bounds, and any scenario rules. The simulation commits a valid selection as one transaction and records an event. Invalid or stale proposals are discarded or refreshed. Dialogue describes the accepted result; it does not determine it.

For an early implementation, keep outcomes selected from approved effect templates and let the model generate connective framing and context-sensitive prose. Broaden the set of effects only after the typed contract and validation cases are stable.

## Persistence, identity, and repetition

Generated opportunities need stable identity and a record of their source state. Store the selected record IDs, world timestamp, retrieval/filter version, generated text, offered choices, validation result, and committed event ID. Use a deterministic signature of the relevant situation to suppress duplicate opportunities while the same conditions remain unchanged. Re-evaluate or expire an opportunity if its NPC, object, task, or world condition changes. Never generate a replacement identity for an existing rostered NPC because a new text description was produced.

Semantic indexes can be rebuilt from authoritative text records. A rebuild must not alter game state, evidence, NPC knowledge, or committed story outcomes.

## Provenance and knowledge boundaries

Every retrieved statement should preserve its source and epistemic status: observed event, authored fact, trusted report, rumor, inference, or unresolved claim. Filter records for the speaking character before semantic ranking; a high similarity score is not authorization to reveal another character's private knowledge. Keep public world truth distinct from what an NPC or the player knows.

An event record should preserve both the event's language-level description and its typed effects. Effects may touch different systems, but each effect must have a domain, target ID, time, and provenance. Do not compress a multi-domain event into one overall score or the single resource-rate change that happens to be easiest to calculate.

Condition tags should be derived from authoritative simulation data and clear when that condition ends. Capability, relationship, and reputation tags should be created or changed only by authored setup or a validated event. Tags can make storylets eligible, but they do not substitute for stock, skill, ownership, access, or evidence checks.

## Failure modes and controls

| Failure mode | Control |
|---|---|
| Semantically similar but causally unrelated records are combined | Require typed relations, compatible tags, shared location/time where applicable, and provenance for every candidate. |
| The model invents a resource, person, event, or relationship | Only allow stable IDs from retrieved records in structured effects; validate all references. |
| An NPC knows something they should not | Apply character-scoped filtering before retrieval and validate knowledge provenance before generation and commit. |
| Similarity retrieves a stale condition | Recheck all candidates against live simulation state immediately before showing or resolving the storylet. |
| Repeated generation floods the player with nearly identical situations | Deduplicate by situation signature, persist seen/resolved state, apply cooldowns, and limit active opportunities. |
| Generated rules become a second undocumented simulation | Require effects to use typed, versioned game actions; the LLM may not introduce new effect types or numeric rules at runtime. |
| A model or embedding service is unavailable | Keep core simulation running; use authored opportunities or a clear no-new-opportunity fallback. |

## Development sequence

1. Define the typed entities, relations, tags, event provenance, and knowledge scopes for one local situation.
2. Build semantic retrieval over authored descriptions and recorded simulation events, returning stable IDs with provenance.
3. Test candidate triangulation without generation: verify relevant and irrelevant combinations across event, NPC, and object/resource records.
4. Add model-generated storylet framing and choices using a strict schema and a small set of approved effect templates.
5. Validate choices against game state, commit effects through the simulation, and persist the outcome and provenance.
6. Only then test broader generated event combinations and local NPC memory retrieval.

## Research precedent and limit

The [Generative Agents paper](https://arxiv.org/abs/2304.03442) combines natural-language memory records with retrieval by relevance, recency, and importance, plus reflection and planning. It is a useful precedent for retrieving contextual memories and helping agents act coherently. It is not evidence that semantic retrieval alone can safely maintain an authoritative economy or produce reliable game rules. Its own discussion includes failures from improper memory retrieval. This project should use that kind of retrieval for context while keeping state changes in deterministic, validated game code.

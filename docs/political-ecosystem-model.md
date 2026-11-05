# Political ecosystem model

## Purpose

Model political groups as participants in the same living resource-flow world as settlements, markets, and characters. Their ability to sustain or advance an agenda depends on people, organization, material means, legitimacy, and access—not on a single abstract influence score.

This is a design direction, not an implemented system or a commitment to any specific Ceres faction. The exact group types, agendas, and numeric rules remain open.

## What a political group uses

Separate four things that are easy to collapse into “support”:

1. **Alignment or concern:** people have reasons to care about an issue, based on their circumstances, identities, beliefs, histories, and relationships. This can be expressed in language and tags, and need not be a fully counted hidden population value for every person.
2. **Expressed support:** public or recorded acts such as joining, signing, voting, donating, attending, speaking, or affiliating. These acts are attributable to people or represented as a documented aggregate.
3. **Mobilizable participation:** supporters who can actually contribute time, labor, skills, votes, care work, communication, or risk at a given time. Commitment and availability differ from nominal support.
4. **Organizational capacity:** the group's ability to turn participation into sustained action through coordination, trusted relationships, leadership, communication, logistics, and institutional access.

Material and institutional inputs can include money, supplies, meeting places, transport, communication channels, legal protection, recognized authority, seats, coalition agreements, procedures, and access to decision-makers. Which of these matter depends on the group and the action. A religious community, labor movement, mutual-aid network, and lawmaking bloc should not all be forced into the same resource template.

## Group state and flows

A group record can combine:

- A persistent identity and descriptive account of its history, values, internal tensions, and public agenda.
- Structured issues, goals, affiliations, memberships/expressed support, leadership, and relationship links.
- Tag bundles that describe its commitments and capabilities; tags need stable meanings and provenance.
- Typed resource pools where relevant: funds, active organizers, available labor, supplies, communication reach, institutional seats/access, or other scenario-specific means.
- Current initiatives or campaigns, with state such as proposed, organizing, active, blocked, achieved, compromised, or abandoned.
- A profile of what the group attempts when conditions permit, and what it cannot do without resources or authorization.

Typical flows might be:

```text
conditions and events
        ↓ shape concern, urgency, and interpretation
individual alignment → expressed support → available participants
        ↓                                      ↓
organizational trust, leadership, and coordination ← resources/access
        ↓
collective action → policy, service, market, legal, or relationship changes
        ↓
new conditions, consequences, and public interpretation
```

This is not a guaranteed funnel. People can support multiple groups, decline public affiliation, become inactive, disagree with a group on one issue, or withdraw support after outcomes. Group totals are not a conserved population split. The important quantities are the ones needed to resolve a specific collective action.

## Social substrate

The social substrate is the network of relationships and channels through which people and groups exchange information, trust, obligations, care, access, and coordination. It connects individual characters to households, workplaces, communities, markets, institutions, and movements. It is worth modeling because resources and agendas move through relationships; it should not become a second economy or a universal “social capital” meter.

Represent only relevant ties, with stable endpoints and provenance. Useful relation types may include affiliation, kinship, trust, obligation, mentorship, patronage, rivalry, conflict, dependency, communication, and shared work. Some ties can have typed scope or facets—for example, a merchant trusts a person to repay credit but disagrees with them politically. Keep descriptions and history with the relationship; use numeric intensity only where a rule genuinely needs a threshold.

Social ties can:

- Carry information, testimony, and rumors along channels a character can actually access.
- Enable referrals, credit, favors, mutual aid, introductions, or access to a place or decision-maker.
- Make collective action easier through trust, shared commitments, and coordination.
- Constrain action through obligations, dependency, conflict, stigma, or risk to relationships.
- Shape how an event is interpreted without changing the event's authoritative facts.

A social tie does not create a missing good, prove a claim, or guarantee agreement. It can change whether someone hears an offer, considers a lead credible, extends credit, joins an effort, or accepts a risk. Record changes through sourced events and retain character-specific perspectives. Aggregate broad networks when no individual relationship is relevant; keep individual ties persistent when the player can act on them.

## Economic and political coupling

Treat the economic and political ecosystems as linked parts of one world model, not two independent sets of scores.

- **Economic conditions shape political capacity and stakes.** Ownership, access, prices, scarcity, wages, supply routes, contracts, and control of infrastructure affect who can act, who bears a cost, and what groups can organize. Money, goods, labor, meeting space, communications, and transport can support collective activity.
- **Political organization changes economic rules and flows.** Laws, permits, allocation priorities, labor agreements, property rights, sanctions, and institutional decisions can change who may use, sell, move, produce, or repair a resource, and on what terms.
- **Collective outcomes feed back into support.** A decision may improve or worsen material conditions for different groups, changing expressed support, trust, resources, and future organizing capacity.

Represent the connection with shared, typed records for ownership, access rights, transactions, policy, work, and resource flows. Social relationships can route information, trust, credit, or cooperation between the people making and responding to those decisions. Political state can determine eligibility or rules for a transaction; it does not conjure the resource itself. Economic state can enable or constrain a group's action; it does not by itself decide what that group believes or how its members interpret an outcome. Keep the causal steps visible: group action changes a policy or agreement, the policy changes access or flow, and affected people respond through their circumstances and relationships.

For example, if a treatment component is available in a market, its price, ownership, trade terms, and any access restrictions determine whether a maintenance task can obtain it. A group or institution might negotiate priority, change a rule, or organize a collective purchase. The resulting transaction can unblock a repair and change service capacity; who benefits or pays can then affect relationships and expressed support. This is a model pattern, not established Ceres law or faction content.

## From support to action

For each group action, define its requirements rather than asking whether the group has enough generic “power.” For example, a public campaign might need a minimum level of active participants, trusted organizers, a communication path, and a low enough risk of suppression. A legislative effort might instead need procedural access, a voting coalition, staff work, and a recognized mandate. A religious initiative might depend on leaders, ritual knowledge, meeting networks, and community trust.

An action can consume or mobilize some resources and change others. A successful effort may strengthen a relationship or make an agenda more visible; it may also spend funds, expose participants to risk, provoke a counter-mobilization, or create internal disagreement. These effects should be explicit in the action rules and recorded with provenance. A supporter count alone should never guarantee success.

## Individual characters and aggregate populations

Keep important named characters as persistent individuals with reasons, loyalties, ambivalence, histories, and relationships represented in language-rich records. Structured tags and values can support eligibility and simulation, but should not replace those descriptions.

For background populations, use aggregate pools by area, issue, group, and commitment/availability band when the distinction matters. Derive mobilization capacity from these pools and group infrastructure. Surface specific existing NPCs when their role, choices, or relationships become relevant; do not continuously simulate every supporter.

An individual may be:

- privately sympathetic but not publicly affiliated;
- publicly supportive but unavailable for action;
- an active organizer with high coordination ability;
- a member who disagrees with the group on a specific action;
- disengaged, opposed, or newly persuaded by recent events.

This allows public support numbers to matter without treating every person's beliefs as one fixed score.

## Connection to economic and semantic simulation

Political groups use and redirect resources in the same world: a movement may organize labor, withhold work, distribute supplies, fund a service, or bargain over access. Economic strain can change issue salience; collective action can in turn change production, distribution, legal constraints, or access. Record those typed effects in the simulation.

Language-rich events and descriptions preserve why a group or person acts. Semantic retrieval may connect an event to a group agenda, a character's history, or a relevant object/resource. Embedding similarity only proposes those links. Verify membership, evidence, material availability, authorization, timing, and knowledge through authoritative records and relationships before generating or resolving a storylet.

Tags can help bridge story and simulation:

- **Issue/agenda tags** describe a group's commitments (`water_access`, `worker_safety`, `religious_autonomy`).
- **Condition tags** derive from current world conditions (`service_strained`, `new_law_proposed`).
- **Capability tags** describe organization or skills (`mutual_aid_network`, `legal_advocacy`).
- **Relationship/status tags** record sourced trust, affiliation, recognition, or opposition.

Keep tags semantically stable. Track actual quantities such as funds, attendees, votes, or supplies in typed fields when an action depends on them.

## Player-scale interaction

The player does not manage the whole political system. They meet representatives and affected people, observe conditions, and choose personal actions: contribute an item, sell supplies, deliver a message, offer evidence, provide labor, attend, persuade, negotiate, or walk away. Their effects pass through validation and may change an initiative, relationship, public commitment, or group resource. Profit, goodwill, ideology, and personal risk can pull in different directions.

Storylets can emerge from a triangulation of:

1. A world event or condition that creates a political opening or pressure.
2. A group or existing character with a relevant agenda and capacity/need.
3. A resource, relationship, evidence record, or institutional opportunity that can enable or block action.

The local text model can frame the encounter and propose choices using those records. The simulation determines eligibility and commits effects; dialogue does not create supporters, money, access, or policy changes on its own.

## First implementation boundary

Do not start with a universal ideology simulator or model every political group across the Solar System. The first Ceres treatment-repair situation should include one bounded collective issue or dispute alongside the economic repair and personal relationships. Use a few characters/groups with distinguishable interests, then track only the support, coordination, resources, and access needed to resolve one collective response. This is an intentional cross-substrate scenario, not a complete political simulation; the specific action and cast remain to be designed in the [Ceres simulation proposal](ceres-simulation-proposal.md).

Before implementation, decide:

- Which collective action is meaningful to the player's current role?
- What counts as private alignment versus expressed support in this situation?
- Which inputs are essential to coordinate the action?
- What would the group try autonomously, and what can the player change?
- Which results are material, institutional, relational, or epistemic?


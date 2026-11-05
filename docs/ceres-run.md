# Ceres Run — vertical slice

## Purpose and established premise

Prove that a small, readable simulation can create a character-driven mystery and meaningful choices without delegating authority to a language model. Ceres Run is a bounded slice, not a claim that the colony or route network exists in-game.

A Ceres colony faces a water shortage. Its commercial freighter carrying water-treatment components is missing. Reserve capacity is below a week. Cargo transfers occurred outside the normal manifest schedule. The militia investigates irregular movements, but there is no verified evidence identifying attackers.

## Characters and knowledge

- **Mara Venn — Mining Administrator:** knows the freighter is missing and reserves are below a week; pragmatic, politically cautious, protective of the colony.
- **Ilyan Rusk — Independent Merchant:** knows about off-schedule transfers, has rumors, and does not know who took the freighter; opportunistic, guarded about contacts.
- **Officer Sato — Militia Officer:** knows irregular cargo is under investigation and no verified evidence names attackers; disciplined and suspicious of outsiders.

These facts mirror the narrative prototype profiles. Authored profiles and source events are the truth; private memories do not cross characters by default.

## Current Godot demo rules (temporary, not canon)

The scene currently uses deliberately simple placeholder values to exercise a player-facing simulation loop:

- Start with 6.0 water-reserve days and one spare treatment component.
- T advances one simulated day.
- C switches daily demand between normal use (1.0 reserve-day) and rationing (0.5 reserve-day).
- B consumes the spare component once to repair treatment. The repaired system adds 0.25 reserve-days before each day's demand is served.
- Every tick records opening reserve, treatment output, demand, served and unmet amounts, closing reserve, and active policy in one `daily_water_balance` or `water_shortage` event. If available water cannot meet demand, the missing amount accumulates. Time continues advancing after the reserve reaches zero.
- The HUD reports reserve, projected runout under current settings, policy, treatment status/parts, cumulative unmet demand, and the three most recent meaningful events. Inspecting the public crisis board shows the current simulation summary; Mara and Sato respond to recorded shortages without changing the unresolved freighter facts. K saves the full event history, current state, and canonical Mechflow model hash to a local versioned JSON file; L rejects a save from a different hashed model. Older saves without a hash still load with a warning. There is no autosave.
- E records each source's established statements and uncertainty in a player case file; J opens it. Repeated claims cite all sources that corroborated them. Unnamed rumors stay marked as rumor, and no culprit or specific accusation is added.

The initial stock, rates, and repair outcome are prototype assumptions, not established colony facts. They do not describe the missing freighter's cargo inventory or establish a canonical treatment design. Replace them after quantities, treatment constraints, and action consequences are agreed.

## Intended loop and minimum scope

Observe shortage and affected people; gather information through conversation, work, travel, or trade; choose an action; let simulation validate costs, permissions, and consequences; advance a tick; observe supply, trust, investigation, and eligible storylets. Exact branch structure and endings are not established.

Minimum: one Ceres settlement and only necessary locations; explicit water and treatment-component stocks; a tick advancing a stock/schedule with an inspectable event; three bounded NPC profiles; a few conditional storylets and rumor/verified distinction; two approaches with different validated consequences. Dialogue inference is optional, and the slice must work without a model. Do not expand into a full Solar System economy or detailed flight simulation.

## Acceptance checks

1. The shortage, missing freighter, and component dependency are understandable.
2. Dialogue does not turn rumor into proof or leak another character's knowledge.
3. Game code validates and resolves every state-changing choice.
4. Tick effects and events can be inspected.
5. Two approaches yield distinct, reproducible outcomes.
6. The slice starts and completes with narrative inference disabled.

## Open content

Who caused the disappearance and why; exact route/locations; additional characters and named factions; career options; branch outcomes; and resolution are not established in available project material. Leave these as design work rather than invented canon.

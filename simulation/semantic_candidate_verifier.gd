class_name SemanticCandidateVerifier
extends RefCounted

## Checks embedding-retrieved IDs against current authoritative world records.
## Relevance scores rank suggestions; only existing visible records and active,
## recorded relationships make a candidate usable as grounded context.


func verify(
	state: SimulationState,
	candidate: SemanticCandidate,
	observer_id: StringName
) -> Dictionary:
	if state == null:
		return {"ok": false, "reason": "invalid_state"}
	if candidate == null or not candidate.is_valid():
		return {"ok": false, "reason": "invalid_candidate"}
	if String(observer_id).is_empty():
		return {"ok": false, "reason": "missing_observer"}

	var record_context: Array[WorldRecord] = []
	for record_id in candidate.matched_record_ids:
		var record := state.get_world_record(record_id)
		if record == null:
			return {"ok": false, "reason": "unknown_record", "record_id": String(record_id)}
		if not record.is_visible_to(observer_id):
			return {"ok": false, "reason": "record_not_visible", "record_id": String(record_id)}
		record_context.append(record)

	var relationship_context: Array[WorldRelationship] = []
	for relationship_id in candidate.matched_relationship_ids:
		var relationship := state.get_relationship(relationship_id)
		if relationship == null:
			return {"ok": false, "reason": "unknown_relationship", "relationship_id": String(relationship_id)}
		if not relationship.active:
			return {"ok": false, "reason": "inactive_relationship", "relationship_id": String(relationship_id)}
		if not relationship.is_visible_to(observer_id):
			return {"ok": false, "reason": "relationship_not_visible", "relationship_id": String(relationship_id)}
		if (
			not candidate.matched_record_ids.has(relationship.source_record_id)
			or not candidate.matched_record_ids.has(relationship.target_record_id)
		):
			return {"ok": false, "reason": "relationship_outside_candidate", "relationship_id": String(relationship_id)}
		relationship_context.append(relationship)

	return {
		"ok": true,
		"candidate_id": String(candidate.candidate_id),
		"relevance_score": candidate.relevance_score,
		"records": record_context,
		"relationships": relationship_context
	}

class_name EvidenceRecord
extends RefCounted

const VERIFIED: StringName = &"verified"
const RUMOR: StringName = &"rumor"
const UNRESOLVED: StringName = &"unresolved"
const VALID_CONFIDENCE := [VERIFIED, RUMOR, UNRESOLVED]

var evidence_id: StringName = &""
var claim: String = ""
var confidence: StringName = &""
var observations: Array[Dictionary] = []


func _init(
	p_evidence_id: StringName = &"",
	p_claim: String = "",
	p_confidence: StringName = &""
) -> void:
	evidence_id = p_evidence_id
	claim = p_claim.strip_edges()
	confidence = p_confidence


func is_valid() -> bool:
	return (
		not String(evidence_id).is_empty()
		and not claim.is_empty()
		and VALID_CONFIDENCE.has(confidence)
	)


func add_observation(source_id: StringName, tick_index: int) -> bool:
	if String(source_id).is_empty() or tick_index < 0:
		return false
	for observation in observations:
		if observation["source_id"] == source_id and observation["tick_index"] == tick_index:
			return false
	observations.append({"source_id": source_id, "tick_index": tick_index})
	return true


func source_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for observation in observations:
		var source_id: StringName = observation["source_id"]
		if not result.has(source_id):
			result.append(source_id)
	result.sort()
	return result


func to_dictionary() -> Dictionary:
	var serialized_observations: Array[Dictionary] = []
	for observation in observations:
		serialized_observations.append({
			"source_id": String(observation["source_id"]),
			"tick_index": observation["tick_index"]
		})
	return {
		"evidence_id": String(evidence_id),
		"claim": claim,
		"confidence": String(confidence),
		"observations": serialized_observations
	}

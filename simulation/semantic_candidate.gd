class_name SemanticCandidate
extends RefCounted

## An untrusted retrieval result from an embedding index. It carries only stable
## IDs and a ranking score; it cannot contain or commit proposed state changes.

var candidate_id: StringName = &""
var query_record_id: StringName = &""
var matched_record_ids: Array[StringName] = []
var matched_relationship_ids: Array[StringName] = []
var relevance_score: float = 0.0


func _init(
	p_candidate_id: StringName = &"",
	p_query_record_id: StringName = &"",
	p_matched_record_ids: Array[StringName] = [],
	p_matched_relationship_ids: Array[StringName] = [],
	p_relevance_score: float = 0.0
) -> void:
	candidate_id = p_candidate_id
	query_record_id = p_query_record_id
	matched_record_ids = _unique_sorted(p_matched_record_ids)
	matched_relationship_ids = _unique_sorted(p_matched_relationship_ids)
	relevance_score = p_relevance_score


func is_valid() -> bool:
	return (
		not String(candidate_id).is_empty()
		and not String(query_record_id).is_empty()
		and matched_record_ids.size() >= 2
		and matched_record_ids.has(query_record_id)
		and not matched_relationship_ids.is_empty()
		and _all_nonempty(matched_record_ids)
		and _all_nonempty(matched_relationship_ids)
		and is_finite(relevance_score)
	)


func to_dictionary() -> Dictionary:
	return {
		"candidate_id": String(candidate_id),
		"query_record_id": String(query_record_id),
		"matched_record_ids": _strings(matched_record_ids),
		"matched_relationship_ids": _strings(matched_relationship_ids),
		"relevance_score": relevance_score
	}


static func from_dictionary(data: Variant) -> SemanticCandidate:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var candidate_id: Variant = data.get("candidate_id")
	var query_record_id: Variant = data.get("query_record_id")
	var records_data: Variant = data.get("matched_record_ids")
	var relationships_data: Variant = data.get("matched_relationship_ids")
	var relevance: Variant = data.get("relevance_score")
	if typeof(candidate_id) != TYPE_STRING or typeof(query_record_id) != TYPE_STRING:
		return null
	if typeof(records_data) != TYPE_ARRAY or typeof(relationships_data) != TYPE_ARRAY:
		return null
	if typeof(relevance) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(relevance)):
		return null
	var records := _string_names(records_data)
	var relationships := _string_names(relationships_data)
	if records == null or relationships == null:
		return null
	var candidate := SemanticCandidate.new(
		StringName(candidate_id),
		StringName(query_record_id),
		records,
		relationships,
		float(relevance)
	)
	return candidate if candidate.is_valid() else null


static func _string_names(values: Array) -> Variant:
	var result: Array[StringName] = []
	for value in values:
		if typeof(value) != TYPE_STRING or String(value).is_empty():
			return null
		result.append(StringName(value))
	return result


static func _unique_sorted(values: Array[StringName]) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		if not String(value).is_empty() and not result.has(value):
			result.append(value)
	result.sort()
	return result


static func _strings(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	return result


static func _all_nonempty(values: Array[StringName]) -> bool:
	for value in values:
		if String(value).is_empty():
			return false
	return true

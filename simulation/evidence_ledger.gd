class_name EvidenceLedger
extends RefCounted

var _records: Dictionary = {}


func clear() -> void:
	_records.clear()


func restore_from_dictionary(saved_records: Variant, maximum_tick: int) -> bool:
	if typeof(saved_records) != TYPE_ARRAY:
		return false
	if saved_records.size() > 10000 or maximum_tick < 0:
		return false
	var restored := EvidenceLedger.new()
	for record_data in saved_records:
		if typeof(record_data) != TYPE_DICTIONARY:
			return false
		var evidence_id: Variant = record_data.get("evidence_id")
		var claim: Variant = record_data.get("claim")
		var confidence: Variant = record_data.get("confidence")
		var observations: Variant = record_data.get("observations")
		if typeof(evidence_id) != TYPE_STRING or typeof(claim) != TYPE_STRING:
			return false
		if typeof(confidence) != TYPE_STRING or typeof(observations) != TYPE_ARRAY:
			return false
		if observations.is_empty():
			return false
		if observations.size() > 10000:
			return false
		for observation in observations:
			if typeof(observation) != TYPE_DICTIONARY:
				return false
			var source_id: Variant = observation.get("source_id")
			var tick_index: Variant = observation.get("tick_index")
			if typeof(source_id) != TYPE_STRING or not _is_integer_number(tick_index):
				return false
			tick_index = int(tick_index)
			if tick_index < 0 or tick_index > maximum_tick:
				return false
			if not restored.add_claim(
				StringName(evidence_id),
				String(claim),
				StringName(source_id),
				StringName(confidence),
				int(tick_index)
			):
				return false
	_records = restored._records
	return true


func add_claim(
	evidence_id: StringName,
	claim: String,
	source_id: StringName,
	confidence: StringName,
	tick_index: int
) -> bool:
	if String(evidence_id).is_empty() or String(source_id).is_empty():
		return false
	if claim.strip_edges().is_empty() or tick_index < 0:
		return false
	if not EvidenceRecord.VALID_CONFIDENCE.has(confidence):
		return false

	var record: EvidenceRecord
	if _records.has(evidence_id):
		record = _records[evidence_id]
		if record.claim != claim.strip_edges() or record.confidence != confidence:
			return false
	else:
		record = EvidenceRecord.new(evidence_id, claim, confidence)
		_records[evidence_id] = record

	return record.add_observation(source_id, tick_index)


func get_records() -> Array[EvidenceRecord]:
	var result: Array[EvidenceRecord] = []
	for evidence_id in _records:
		result.append(_records[evidence_id])
	result.sort_custom(func(a: EvidenceRecord, b: EvidenceRecord) -> bool:
		return String(a.evidence_id) < String(b.evidence_id)
	)
	return result


func get_records_by_confidence(confidence: StringName) -> Array[EvidenceRecord]:
	var result: Array[EvidenceRecord] = []
	for record in get_records():
		if record.confidence == confidence:
			result.append(record)
	return result


func to_dictionary() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record in get_records():
		result.append(record.to_dictionary())
	return result


func _is_integer_number(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var numeric_value := float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)

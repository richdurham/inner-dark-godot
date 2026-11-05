class_name SimulationEvent
extends RefCounted

var sequence: int = 0
var tick_index: int = 0
var event_type: StringName = &""
var summary: String = ""
var payload: Dictionary = {}
var world_time_units: int = 0
var affected_record_ids: Array[StringName] = []
var source_record_ids: Array[StringName] = []
var domain_tags: Array[StringName] = []


func _init(
	p_sequence: int = 0,
	p_tick_index: int = 0,
	p_event_type: StringName = &"",
	p_summary: String = "",
	p_payload: Dictionary = {},
	p_world_time_units: int = 0,
	p_affected_record_ids: Array[StringName] = [],
	p_source_record_ids: Array[StringName] = [],
	p_domain_tags: Array[StringName] = []
) -> void:
	sequence = p_sequence
	tick_index = p_tick_index
	event_type = p_event_type
	summary = p_summary
	payload = p_payload.duplicate(true)
	world_time_units = p_world_time_units
	affected_record_ids = _unique_sorted(p_affected_record_ids)
	source_record_ids = _unique_sorted(p_source_record_ids)
	domain_tags = _unique_sorted(p_domain_tags)


func to_dictionary() -> Dictionary:
	return {
		"sequence": sequence,
		"tick_index": tick_index,
		"event_type": String(event_type),
		"summary": summary,
		"payload": payload.duplicate(true),
		"world_time_units": world_time_units,
		"affected_record_ids": _strings(affected_record_ids),
		"source_record_ids": _strings(source_record_ids),
		"domain_tags": _strings(domain_tags)
	}


static func from_dictionary(data: Variant) -> SimulationEvent:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var sequence: Variant = data.get("sequence")
	var tick: Variant = data.get("tick_index")
	var event_type: Variant = data.get("event_type")
	var summary: Variant = data.get("summary")
	var payload_data: Variant = data.get("payload")
	var world_time: Variant = data.get("world_time_units", tick)
	var affected_data: Variant = data.get("affected_record_ids", [])
	var sources_data: Variant = data.get("source_record_ids", [])
	var domains_data: Variant = data.get("domain_tags", [])
	if not _is_integer_number(sequence) or not _is_integer_number(tick) or not _is_integer_number(world_time):
		return null
	if typeof(event_type) != TYPE_STRING or String(event_type).is_empty() or typeof(summary) != TYPE_STRING:
		return null
	if typeof(payload_data) != TYPE_DICTIONARY:
		return null
	if typeof(affected_data) != TYPE_ARRAY or typeof(sources_data) != TYPE_ARRAY or typeof(domains_data) != TYPE_ARRAY:
		return null
	var affected := _string_names(affected_data)
	var sources := _string_names(sources_data)
	var domains := _string_names(domains_data)
	if affected == null or sources == null or domains == null:
		return null
	return SimulationEvent.new(
		int(sequence),
		int(tick),
		StringName(event_type),
		String(summary),
		Dictionary(payload_data),
		int(world_time),
		affected,
		sources,
		domains
	)


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


static func _string_names(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		if typeof(value) != TYPE_STRING or String(value).is_empty():
			return null
		result.append(StringName(value))
	return result


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var numeric_value := float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)

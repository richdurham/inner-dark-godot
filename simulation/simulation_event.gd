class_name SimulationEvent
extends RefCounted

var sequence: int = 0
var tick_index: int = 0
var event_type: StringName = &""
var summary: String = ""
var payload: Dictionary = {}


func _init(
	p_sequence: int = 0,
	p_tick_index: int = 0,
	p_event_type: StringName = &"",
	p_summary: String = "",
	p_payload: Dictionary = {}
) -> void:
	sequence = p_sequence
	tick_index = p_tick_index
	event_type = p_event_type
	summary = p_summary
	payload = p_payload.duplicate(true)


func to_dictionary() -> Dictionary:
	return {
		"sequence": sequence,
		"tick_index": tick_index,
		"event_type": String(event_type),
		"summary": summary,
		"payload": payload.duplicate(true)
	}

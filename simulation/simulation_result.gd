class_name SimulationResult
extends RefCounted

var accepted: bool = false
var reason: StringName = &""
var event: SimulationEvent = null


func _init(
	p_accepted: bool = false,
	p_reason: StringName = &"",
	p_event: SimulationEvent = null
) -> void:
	accepted = p_accepted
	reason = p_reason
	event = p_event

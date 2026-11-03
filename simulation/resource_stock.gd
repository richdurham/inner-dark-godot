class_name ResourceStock
extends RefCounted

var resource_id: StringName = &""
var amount: float = 0.0
var unit: StringName = &""


func _init(
	p_resource_id: StringName = &"",
	p_amount: float = 0.0,
	p_unit: StringName = &""
) -> void:
	resource_id = p_resource_id
	amount = p_amount
	unit = p_unit


func is_valid() -> bool:
	return not String(resource_id).is_empty() \
		and not String(unit).is_empty() \
		and is_finite(amount) \
		and amount >= 0.0


func to_dictionary() -> Dictionary:
	return {
		"resource_id": String(resource_id),
		"amount": amount,
		"unit": String(unit)
	}


func copy() -> ResourceStock:
	return ResourceStock.new(resource_id, amount, unit)

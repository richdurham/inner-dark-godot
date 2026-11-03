class_name SimulationState
extends RefCounted

var tick_index: int = 0
var next_event_sequence: int = 1
var _stocks: Dictionary = {}
var _event_history: Array[SimulationEvent] = []


func add_stock(stock: ResourceStock) -> bool:
	if stock == null or not stock.is_valid():
		return false
	if _stocks.has(stock.resource_id):
		return false
	_stocks[stock.resource_id] = stock.copy()
	return true


func has_stock(resource_id: StringName) -> bool:
	return _stocks.has(resource_id)


func get_stock(resource_id: StringName) -> ResourceStock:
	if not _stocks.has(resource_id):
		return null
	var stock: ResourceStock = _stocks[resource_id]
	return stock.copy()


func get_events() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in _event_history:
		result.append(event.to_dictionary())
	return result


func snapshot() -> Dictionary:
	var resource_ids: Array[StringName] = []
	for resource_id in _stocks:
		resource_ids.append(resource_id)
	resource_ids.sort()

	var stock_snapshots: Array[Dictionary] = []
	for resource_id in resource_ids:
		var stock: ResourceStock = _stocks[resource_id]
		stock_snapshots.append(stock.to_dictionary())

	return {
		"tick_index": tick_index,
		"next_event_sequence": next_event_sequence,
		"stocks": stock_snapshots,
		"events": get_events()
	}


func _set_stock_amount(resource_id: StringName, amount: float) -> bool:
	if not is_finite(amount) or amount < 0.0 or not _stocks.has(resource_id):
		return false
	var stock: ResourceStock = _stocks[resource_id]
	stock.amount = amount
	return true


func _record_event(
	event_type: StringName,
	summary: String,
	payload: Dictionary
) -> SimulationEvent:
	var event := SimulationEvent.new(
		next_event_sequence,
		tick_index,
		event_type,
		summary,
		payload
	)
	next_event_sequence += 1
	_event_history.append(event)
	return event

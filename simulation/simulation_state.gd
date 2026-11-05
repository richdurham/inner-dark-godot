class_name SimulationState
extends RefCounted

var tick_index: int = 0
var world_time_units: int = 0
var next_event_sequence: int = 1
var _stocks: Dictionary = {}
var _world_records: Dictionary = {}
var _relationships: Dictionary = {}
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


func has_world_record(record_id: StringName) -> bool:
	return _world_records.has(record_id)


func get_world_record(record_id: StringName) -> WorldRecord:
	if not _world_records.has(record_id):
		return null
	var record: WorldRecord = _world_records[record_id]
	return record.copy()


func get_world_records() -> Array[WorldRecord]:
	var result: Array[WorldRecord] = []
	var record_ids: Array[StringName] = []
	for record_id in _world_records:
		record_ids.append(record_id)
	record_ids.sort()
	for record_id in record_ids:
		var record: WorldRecord = _world_records[record_id]
		result.append(record.copy())
	return result


func has_relationship(relationship_id: StringName) -> bool:
	return _relationships.has(relationship_id)


func get_relationship(relationship_id: StringName) -> WorldRelationship:
	if not _relationships.has(relationship_id):
		return null
	var relationship: WorldRelationship = _relationships[relationship_id]
	return relationship.copy()


func get_relationships_for(record_id: StringName) -> Array[WorldRelationship]:
	var result: Array[WorldRelationship] = []
	var relationship_ids: Array[StringName] = []
	for relationship_id in _relationships:
		var relationship: WorldRelationship = _relationships[relationship_id]
		if relationship.source_record_id == record_id or relationship.target_record_id == record_id:
			relationship_ids.append(relationship_id)
	relationship_ids.sort()
	for relationship_id in relationship_ids:
		var relationship: WorldRelationship = _relationships[relationship_id]
		result.append(relationship.copy())
	return result


func has_active_relationship(
	source_record_id: StringName,
	target_record_id: StringName,
	relation_type: StringName,
	scope_id: StringName = &""
) -> bool:
	for relationship in get_relationships_for(source_record_id):
		if (
			relationship.active
			and relationship.source_record_id == source_record_id
			and relationship.target_record_id == target_record_id
			and relationship.relation_type == relation_type
			and relationship.scope_id == scope_id
		):
			return true
	return false


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
		"world_time_units": world_time_units,
		"next_event_sequence": next_event_sequence,
		"stocks": stock_snapshots,
		"world_records": _world_records_snapshot(),
		"relationships": _relationships_snapshot(),
		"events": get_events()
	}


func latest_event() -> SimulationEvent:
	return _event_history.back() if not _event_history.is_empty() else null


func restore_snapshot(snapshot_data: Variant) -> bool:
	if typeof(snapshot_data) != TYPE_DICTIONARY:
		return false
	var saved_tick: Variant = snapshot_data.get("tick_index")
	var saved_world_time: Variant = snapshot_data.get("world_time_units", saved_tick)
	var saved_next_sequence: Variant = snapshot_data.get("next_event_sequence")
	var saved_stocks: Variant = snapshot_data.get("stocks")
	var saved_world_records: Variant = snapshot_data.get("world_records", [])
	var saved_relationships: Variant = snapshot_data.get("relationships", [])
	var saved_events: Variant = snapshot_data.get("events")
	if not _is_integer_number(saved_tick):
		return false
	saved_tick = int(saved_tick)
	if saved_tick < 0:
		return false
	if not _is_integer_number(saved_world_time):
		return false
	saved_world_time = int(saved_world_time)
	if saved_world_time < 0:
		return false
	if not _is_integer_number(saved_next_sequence):
		return false
	saved_next_sequence = int(saved_next_sequence)
	if saved_next_sequence < 1:
		return false
	if typeof(saved_stocks) != TYPE_ARRAY:
		return false
	if saved_stocks.is_empty():
		return false
	if typeof(saved_world_records) != TYPE_ARRAY or saved_world_records.size() > 100000:
		return false
	if typeof(saved_relationships) != TYPE_ARRAY or saved_relationships.size() > 250000:
		return false
	if typeof(saved_events) != TYPE_ARRAY:
		return false
	if saved_events.size() > 100000:
		return false

	var restored_stocks: Dictionary = {}
	for stock_data in saved_stocks:
		if typeof(stock_data) != TYPE_DICTIONARY:
			return false
		var resource_id: Variant = stock_data.get("resource_id")
		var amount: Variant = stock_data.get("amount")
		var unit: Variant = stock_data.get("unit")
		if typeof(resource_id) != TYPE_STRING or typeof(unit) != TYPE_STRING:
			return false
		if typeof(amount) not in [TYPE_INT, TYPE_FLOAT]:
			return false
		if not is_finite(float(amount)):
			return false
		var stock := ResourceStock.new(StringName(resource_id), float(amount), StringName(unit))
		if not stock.is_valid() or restored_stocks.has(stock.resource_id):
			return false
		restored_stocks[stock.resource_id] = stock

	var restored_records: Dictionary = {}
	for record_data in saved_world_records:
		var record := WorldRecord.from_dictionary(record_data)
		if record == null or record.updated_at_world_time > saved_world_time:
			return false
		if restored_records.has(record.record_id):
			return false
		restored_records[record.record_id] = record

	var restored_relationships: Dictionary = {}
	for relationship_data in saved_relationships:
		var relationship := WorldRelationship.from_dictionary(relationship_data)
		if relationship == null or relationship.updated_at_world_time > saved_world_time:
			return false
		if restored_relationships.has(relationship.relationship_id):
			return false
		if not restored_records.has(relationship.source_record_id) or not restored_records.has(relationship.target_record_id):
			return false
		restored_relationships[relationship.relationship_id] = relationship

	var restored_events: Array[SimulationEvent] = []
	var expected_sequence := 1
	var previous_event_tick := 0
	var previous_event_time := 0
	for event_data in saved_events:
		var event := SimulationEvent.from_dictionary(event_data)
		if event == null:
			return false
		if event.sequence != expected_sequence:
			return false
		if event.tick_index < previous_event_tick or event.tick_index > saved_tick:
			return false
		if event.world_time_units < previous_event_time or event.world_time_units > saved_world_time:
			return false
		restored_events.append(event)
		expected_sequence += 1
		previous_event_tick = event.tick_index
		previous_event_time = event.world_time_units
	if saved_next_sequence != expected_sequence:
		return false

	tick_index = saved_tick
	world_time_units = saved_world_time
	next_event_sequence = saved_next_sequence
	_stocks = restored_stocks
	_world_records = restored_records
	_relationships = restored_relationships
	_event_history = restored_events
	return true


func _set_stock_amount(resource_id: StringName, amount: float) -> bool:
	if not is_finite(amount) or amount < 0.0 or not _stocks.has(resource_id):
		return false
	var stock: ResourceStock = _stocks[resource_id]
	stock.amount = amount
	return true


func _record_event(
	event_type: StringName,
	summary: String,
	payload: Dictionary,
	affected_record_ids: Array[StringName] = [],
	source_record_ids: Array[StringName] = [],
	domain_tags: Array[StringName] = []
) -> SimulationEvent:
	var event := SimulationEvent.new(
		next_event_sequence,
		tick_index,
		event_type,
		summary,
		payload,
		world_time_units,
		affected_record_ids,
		source_record_ids,
		domain_tags
	)
	next_event_sequence += 1
	_event_history.append(event)
	return event


func _put_world_record(record: WorldRecord) -> bool:
	if record == null or not record.is_valid():
		return false
	_world_records[record.record_id] = record.copy()
	return true


func _put_relationship(relationship: WorldRelationship) -> bool:
	if relationship == null or not relationship.is_valid():
		return false
	if not _world_records.has(relationship.source_record_id) or not _world_records.has(relationship.target_record_id):
		return false
	_relationships[relationship.relationship_id] = relationship.copy()
	return true


func _world_records_snapshot() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record in get_world_records():
		result.append(record.to_dictionary())
	return result


func _relationships_snapshot() -> Array[Dictionary]:
	var relationships: Array[WorldRelationship] = []
	for relationship_id in _relationships:
		var relationship: WorldRelationship = _relationships[relationship_id]
		relationships.append(relationship.copy())
	relationships.sort_custom(func(a: WorldRelationship, b: WorldRelationship) -> bool:
		return String(a.relationship_id) < String(b.relationship_id)
	)
	var result: Array[Dictionary] = []
	for relationship in relationships:
		result.append(relationship.to_dictionary())
	return result


func _is_integer_number(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var numeric_value := float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)

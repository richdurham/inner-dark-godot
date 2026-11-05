class_name SimulationEngine
extends RefCounted


func advance_tick(state: SimulationState) -> SimulationResult:
	if state == null:
		return SimulationResult.new(false, &"invalid_state")

	var previous_tick := state.tick_index
	var previous_world_time := state.world_time_units
	state.tick_index += 1
	state.world_time_units += 1
	var event := state._record_event(
		&"tick_advanced",
		"Advanced from tick %d to tick %d." % [previous_tick, state.tick_index],
		{
			"from_tick": previous_tick,
			"to_tick": state.tick_index,
			"from_world_time": previous_world_time,
			"to_world_time": state.world_time_units
		},
		[],
		[],
		[&"time"]
	)
	return SimulationResult.new(true, &"", event)


func advance_world_time(
	state: SimulationState,
	elapsed_units: int,
	reason: String
) -> SimulationResult:
	if state == null:
		return SimulationResult.new(false, &"invalid_state")
	if elapsed_units <= 0:
		return SimulationResult.new(false, &"invalid_elapsed_time")
	if reason.strip_edges().is_empty():
		return SimulationResult.new(false, &"missing_reason")
	var previous_time := state.world_time_units
	state.world_time_units += elapsed_units
	var event := state._record_event(
		&"world_time_advanced",
		"World time advanced by %d units. Reason: %s" % [elapsed_units, reason.strip_edges()],
		{
			"from_world_time": previous_time,
			"to_world_time": state.world_time_units,
			"elapsed_units": elapsed_units,
			"reason": reason.strip_edges()
		},
		[],
		[],
		[&"time"]
	)
	return SimulationResult.new(true, &"", event)


func upsert_world_record(
	state: SimulationState,
	record: WorldRecord,
	reason: String
) -> SimulationResult:
	if state == null:
		return SimulationResult.new(false, &"invalid_state")
	if record == null or not record.is_valid():
		return SimulationResult.new(false, &"invalid_world_record")
	if reason.strip_edges().is_empty():
		return SimulationResult.new(false, &"missing_reason")
	if record.created_at_world_time > state.world_time_units:
		return SimulationResult.new(false, &"record_created_in_future")

	var stored := record.copy()
	var previous := state.get_world_record(stored.record_id)
	if previous != null:
		stored.created_at_world_time = previous.created_at_world_time
	else:
		stored.created_at_world_time = state.world_time_units
	stored.updated_at_world_time = state.world_time_units
	if not stored.is_valid() or not state._put_world_record(stored):
		return SimulationResult.new(false, &"invalid_world_record")

	var event_type: StringName = &"world_record_updated" if previous != null else &"world_record_created"
	var event := state._record_event(
		event_type,
		"%s record '%s' %s. Reason: %s" % [
			String(stored.record_kind),
			stored.display_name,
			"updated" if previous != null else "created",
			reason.strip_edges()
		],
		{
			"record_id": String(stored.record_id),
			"record_kind": String(stored.record_kind),
			"tags": _string_array(stored.tags),
			"reason": reason.strip_edges()
		},
		[stored.record_id],
		stored.source_record_ids,
		[&"world_record", stored.record_kind]
	)
	return SimulationResult.new(true, &"", event)


func upsert_relationship(
	state: SimulationState,
	relationship: WorldRelationship,
	reason: String
) -> SimulationResult:
	if state == null:
		return SimulationResult.new(false, &"invalid_state")
	if relationship == null or not relationship.is_valid():
		return SimulationResult.new(false, &"invalid_relationship")
	if reason.strip_edges().is_empty():
		return SimulationResult.new(false, &"missing_reason")
	if not state.has_world_record(relationship.source_record_id) or not state.has_world_record(relationship.target_record_id):
		return SimulationResult.new(false, &"unknown_relationship_endpoint")
	if relationship.created_at_world_time > state.world_time_units:
		return SimulationResult.new(false, &"relationship_created_in_future")

	var stored := relationship.copy()
	var previous := state.get_relationship(stored.relationship_id)
	if previous != null:
		stored.created_at_world_time = previous.created_at_world_time
	else:
		stored.created_at_world_time = state.world_time_units
	stored.updated_at_world_time = state.world_time_units
	if not stored.is_valid() or not state._put_relationship(stored):
		return SimulationResult.new(false, &"invalid_relationship")

	var event := state._record_event(
		&"relationship_updated" if previous != null else &"relationship_created",
		"Relationship '%s' between '%s' and '%s' %s. Reason: %s" % [
			String(stored.relation_type),
			String(stored.source_record_id),
			String(stored.target_record_id),
			"updated" if previous != null else "recorded",
			reason.strip_edges()
		],
		{
			"relationship_id": String(stored.relationship_id),
			"source_record_id": String(stored.source_record_id),
			"target_record_id": String(stored.target_record_id),
			"relation_type": String(stored.relation_type),
			"scope_id": String(stored.scope_id),
			"active": stored.active,
			"reason": reason.strip_edges()
		},
		[stored.source_record_id, stored.target_record_id],
		stored.source_record_ids,
		[&"world_model", &"relationship"]
	)
	return SimulationResult.new(true, &"", event)


func change_stock(
	state: SimulationState,
	resource_id: StringName,
	delta: float,
	reason: String
) -> SimulationResult:
	if state == null:
		return SimulationResult.new(false, &"invalid_state")
	if String(resource_id).is_empty():
		return SimulationResult.new(false, &"invalid_resource_id")
	if not is_finite(delta) or delta == 0.0:
		return SimulationResult.new(false, &"invalid_delta")
	if reason.strip_edges().is_empty():
		return SimulationResult.new(false, &"missing_reason")

	var stock := state.get_stock(resource_id)
	if stock == null:
		return SimulationResult.new(false, &"unknown_resource")

	var previous_amount := stock.amount
	var next_amount := previous_amount + delta
	if not is_finite(next_amount):
		return SimulationResult.new(false, &"invalid_result")
	if next_amount < 0.0:
		return SimulationResult.new(false, &"insufficient_stock")
	if not state._set_stock_amount(resource_id, next_amount):
		return SimulationResult.new(false, &"invalid_result")

	var event := state._record_event(
		&"stock_changed",
		"%s changed by %s %s. Reason: %s" % [
			String(resource_id),
			str(delta),
			String(stock.unit),
			reason.strip_edges()
		],
		{
			"resource_id": String(resource_id),
			"previous_amount": previous_amount,
			"delta": delta,
			"new_amount": next_amount,
			"unit": String(stock.unit),
			"reason": reason.strip_edges()
		},
		[resource_id],
		[],
		[&"economy", &"resource_flow"]
	)
	return SimulationResult.new(true, &"", event)


func _string_array(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	return result

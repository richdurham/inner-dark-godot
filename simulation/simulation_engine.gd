class_name SimulationEngine
extends RefCounted


func advance_tick(state: SimulationState) -> SimulationResult:
	if state == null:
		return SimulationResult.new(false, &"invalid_state")

	var previous_tick := state.tick_index
	state.tick_index += 1
	var event := state._record_event(
		&"tick_advanced",
		"Advanced from tick %d to tick %d." % [previous_tick, state.tick_index],
		{"from_tick": previous_tick, "to_tick": state.tick_index}
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
		}
	)
	return SimulationResult.new(true, &"", event)

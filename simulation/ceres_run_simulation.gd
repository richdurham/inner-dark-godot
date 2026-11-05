class_name CeresRunSimulation
extends RefCounted

const WATER_RESERVE_ID: StringName = &"water_reserve_days"
const TREATMENT_PARTS_ID: StringName = &"treatment_parts"
const UNMET_WATER_ID: StringName = &"unmet_water_days"
const MODEL_SOURCE_PATH := "res://simulation/models/ceres-water.yaml"
const MODEL_RUNTIME_PATH := "res://simulation/models/ceres-water.runtime.json"

var state: SimulationState
var model_error: String = ""
var model_source_sha256: String = ""
var _model: Dictionary = {}
var latest_event: SimulationEvent = null
var rationing_enabled: bool = false
var treatment_repaired: bool = false
var _engine := SimulationEngine.new()


func _init() -> void:
	var loaded := _load_model()
	if loaded["ok"]:
		_model = loaded["model"]
		model_source_sha256 = loaded["source_sha256"]
	else:
		model_error = loaded["reason"]
	reset()


func is_ready() -> bool:
	return model_error.is_empty() and not _model.is_empty()


func reset() -> void:
	state = SimulationState.new()
	latest_event = null
	rationing_enabled = false
	treatment_repaired = false
	if not is_ready():
		return
	var unit_scale := _model_parameter("units_per_reserve_day")
	state.add_stock(ResourceStock.new(WATER_RESERVE_ID, _model_pool_start(WATER_RESERVE_ID) / unit_scale, &"days"))
	state.add_stock(ResourceStock.new(TREATMENT_PARTS_ID, _model_pool_start(TREATMENT_PARTS_ID), &"parts"))
	state.add_stock(ResourceStock.new(UNMET_WATER_ID, _model_pool_start(UNMET_WATER_ID) / unit_scale, &"demand-days"))
	rationing_enabled = _model_parameter("rationing_enabled") >= 0.5


func to_dictionary() -> Dictionary:
	return {
		"state": state.snapshot(),
		"rationing_enabled": rationing_enabled,
		"treatment_repaired": treatment_repaired
	}


func restore_from_dictionary(saved_data: Variant) -> bool:
	if typeof(saved_data) != TYPE_DICTIONARY:
		return false
	var saved_rationing: Variant = saved_data.get("rationing_enabled")
	var saved_repaired: Variant = saved_data.get("treatment_repaired")
	var saved_state: Variant = saved_data.get("state")
	if typeof(saved_rationing) != TYPE_BOOL or typeof(saved_repaired) != TYPE_BOOL:
		return false
	if typeof(saved_state) != TYPE_DICTIONARY:
		return false
	var saved_stocks: Variant = saved_state.get("stocks")
	if typeof(saved_stocks) != TYPE_ARRAY:
		return false
	if saved_stocks.size() != 3:
		return false

	var restored_state := SimulationState.new()
	if not restored_state.restore_snapshot(saved_state):
		return false
	var water := restored_state.get_stock(WATER_RESERVE_ID)
	var parts := restored_state.get_stock(TREATMENT_PARTS_ID)
	var unmet := restored_state.get_stock(UNMET_WATER_ID)
	if water == null or parts == null or unmet == null:
		return false
	if water.unit != &"days" or parts.unit != &"parts" or unmet.unit != &"demand-days":
		return false
	var expected_parts := _model_pool_start(TREATMENT_PARTS_ID)
	if saved_repaired:
		expected_parts -= _repair_part_cost()
	if not is_equal_approx(parts.amount, expected_parts):
		return false

	state = restored_state
	rationing_enabled = bool(saved_rationing)
	treatment_repaired = bool(saved_repaired)
	latest_event = state.latest_event()
	return true


func set_rationing_enabled(enabled: bool) -> SimulationResult:
	if enabled == rationing_enabled:
		return SimulationResult.new(false, &"already_in_requested_state")

	var previous_mode := rationing_enabled
	rationing_enabled = enabled
	var mode_name := "rationing" if enabled else "normal use"
	var event := state._record_event(
		&"rationing_changed",
		"Water use changed from %s to %s." % [
			"rationing" if previous_mode else "normal use",
			mode_name
		],
		{
			"previous_enabled": previous_mode,
			"enabled": rationing_enabled,
			"next_tick_use_days": _reserve_use_per_tick()
		}
	)
	latest_event = event
	return SimulationResult.new(true, &"", event)


func repair_treatment() -> SimulationResult:
	if treatment_repaired:
		return SimulationResult.new(false, &"treatment_already_repaired")

	var repair_cost := _repair_part_cost()
	var parts_result := _engine.change_stock(
		state,
		TREATMENT_PARTS_ID,
		-repair_cost,
		"Temporary demo action: install %.0f spare water-treatment component(s)." % repair_cost
	)
	if not parts_result.accepted:
		return parts_result

	treatment_repaired = true
	var event := state._record_event(
		&"treatment_repaired",
		"Water treatment restored; it adds %.2f reserve-days per simulated day." % treatment_output_per_tick(),
		{
			"treatment_parts_remaining": treatment_parts(),
			"recovery_per_tick_days": treatment_output_per_tick()
		}
	)
	latest_event = event
	return SimulationResult.new(true, &"", event)


func advance_day() -> SimulationResult:
	var reserve_before_tick := state.get_stock(WATER_RESERVE_ID)
	if reserve_before_tick == null:
		return SimulationResult.new(false, &"unknown_resource")
	var opening_reserve := reserve_before_tick.amount
	var treatment_output := treatment_output_per_tick() if treatment_repaired else 0.0

	var tick_result := _engine.advance_tick(state)
	if not tick_result.accepted:
		return tick_result
	latest_event = tick_result.event

	if treatment_repaired:
		var recovery_result := _engine.change_stock(
			state,
			WATER_RESERVE_ID,
			treatment_output_per_tick(),
			"Temporary demo rule: repaired treatment restores %.2f reserve-days per simulated day." % treatment_output_per_tick()
		)
		if recovery_result.accepted:
			latest_event = recovery_result.event
		else:
			return recovery_result

	var reserve := state.get_stock(WATER_RESERVE_ID)
	if reserve == null:
		return SimulationResult.new(false, &"unknown_resource")

	var demand := _reserve_use_per_tick()
	var served := minf(demand, reserve.amount)
	var unmet := demand - served
	if served > 0.0:
		var use_reason := "Temporary demo rule: serve %.2f of %.2f reserve-days of daily demand." % [served, demand]
		var use_result := _engine.change_stock(state, WATER_RESERVE_ID, -served, use_reason)
		if not use_result.accepted:
			return use_result
		latest_event = use_result.event

	if unmet > 0.000001:
		var shortage_stock_result := _engine.change_stock(
			state,
			UNMET_WATER_ID,
			unmet,
			"Temporary demo metric: record water demand that could not be served."
		)
		if not shortage_stock_result.accepted:
			return shortage_stock_result
	var ending_reserve := reserve_days()
	var day_event_type: StringName = &"water_shortage" if unmet > 0.000001 else &"daily_water_balance"
	var day_summary := "Day %d: served %.2f/%.2f demand; reserve %.2f; unmet %.2f (%.2f total)." % [
		state.tick_index,
		served,
		demand,
		ending_reserve,
		unmet,
		unmet_water_days()
	]
	var day_event := state._record_event(
		day_event_type,
		day_summary,
		{
			"opening_reserve": opening_reserve,
			"treatment_output": treatment_output,
			"demand": demand,
			"served": served,
			"unmet": unmet,
			"ending_reserve": ending_reserve,
			"cumulative_unmet": unmet_water_days(),
			"rationing_enabled": rationing_enabled,
			"treatment_repaired": treatment_repaired
		}
	)
	latest_event = day_event
	return SimulationResult.new(true, &"", day_event)


func reserve_days() -> float:
	var reserve := state.get_stock(WATER_RESERVE_ID)
	return reserve.amount if reserve != null else 0.0


func treatment_parts() -> float:
	var parts := state.get_stock(TREATMENT_PARTS_ID)
	return parts.amount if parts != null else 0.0


func unmet_water_days() -> float:
	var unmet := state.get_stock(UNMET_WATER_ID)
	return unmet.amount if unmet != null else 0.0


func daily_water_demand() -> float:
	return _reserve_use_per_tick()


func treatment_output_per_tick() -> float:
	return _model_parameter("treatment_output") / _model_parameter("units_per_reserve_day") if is_ready() else 0.0


func projected_days_until_empty() -> float:
	var net_draw := daily_water_demand()
	if treatment_repaired:
		net_draw -= treatment_output_per_tick()
	if net_draw <= 0.0:
		return -1.0
	return reserve_days() / net_draw


func tick_index() -> int:
	return state.tick_index


func _reserve_use_per_tick() -> float:
	if not is_ready():
		return 0.0
	var parameter_id := "rationed_demand" if rationing_enabled else "normal_demand"
	return _model_parameter(parameter_id) / _model_parameter("units_per_reserve_day")


func _load_model() -> Dictionary:
	if not FileAccess.file_exists(MODEL_SOURCE_PATH) or not FileAccess.file_exists(MODEL_RUNTIME_PATH):
		return {"ok": false, "reason": "Mechflow model or generated runtime model is missing."}
	var source_file := FileAccess.open(MODEL_SOURCE_PATH, FileAccess.READ)
	if source_file == null:
		return {"ok": false, "reason": "Unable to read the canonical Mechflow model."}
	var source_text := source_file.get_as_text()
	source_file.close()
	var hashing := HashingContext.new()
	if hashing.start(HashingContext.HASH_SHA256) != OK:
		return {"ok": false, "reason": "Unable to verify the canonical Mechflow model."}
	hashing.update(source_text.to_utf8_buffer())
	var source_hash := hashing.finish().hex_encode()
	var runtime_text := FileAccess.get_file_as_string(MODEL_RUNTIME_PATH)
	var parser := JSON.new()
	if parser.parse(runtime_text) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "Generated Mechflow runtime model is invalid JSON."}
	var envelope: Dictionary = parser.data
	if envelope.get("format_version") != 1 or envelope.get("source_sha256") != source_hash:
		return {"ok": false, "reason": "Generated Mechflow model is stale; restart the Mechflow launcher and regenerate it."}
	var model: Variant = envelope.get("model")
	if typeof(model) != TYPE_DICTIONARY or not _model_shape_is_supported(model):
		return {"ok": false, "reason": "Mechflow model uses an unsupported Ceres rule shape."}
	return {"ok": true, "model": model, "source_sha256": source_hash}


func _model_shape_is_supported(model: Dictionary) -> bool:
	var parameters: Variant = model.get("parameters")
	var nodes: Variant = model.get("nodes")
	var edges: Variant = model.get("edges")
	if typeof(parameters) != TYPE_ARRAY or typeof(nodes) != TYPE_ARRAY or typeof(edges) != TYPE_ARRAY:
		return false
	for parameter_id in ["units_per_reserve_day", "normal_demand", "rationed_demand", "rationing_enabled", "treatment_output"]:
		if _find_entry(parameters, parameter_id).is_empty():
			return false
	var expected_kinds := {
		WATER_RESERVE_ID: "pool",
		TREATMENT_PARTS_ID: "pool",
		UNMET_WATER_ID: "pool",
		&"treatment_online": "pool",
		&"repair_treatment": "converter",
		&"daily_demand": "register",
		&"treatment_production": "source",
		&"unmet_demand_source": "source",
		&"daily_water_use": "drain"
	}
	for node_id in expected_kinds:
		if _find_entry(nodes, node_id).get("kind") != expected_kinds[node_id]:
			return false
	for stock_id in [WATER_RESERVE_ID, TREATMENT_PARTS_ID, UNMET_WATER_ID]:
		var stock_start := float(_find_entry(nodes, stock_id).get("start", -1.0))
		if stock_start < 0.0 or stock_start != floor(stock_start):
			return false
	var online_pool := _find_entry(nodes, &"treatment_online")
	if not is_equal_approx(float(online_pool.get("start", -1.0)), 0.0) or not is_equal_approx(float(online_pool.get("capacity", -1.0)), 1.0):
		return false
	var scale := float(_entry_value(parameters, "units_per_reserve_day", "value"))
	if scale <= 0.0:
		return false
	var repair := _find_entry(nodes, &"repair_treatment")
	if repair.get("kind") != "converter":
		return false
	var inputs: Variant = repair.get("inputs")
	if typeof(inputs) != TYPE_ARRAY or inputs.size() != 1:
		return false
	if inputs[0].get("resource") != String(TREATMENT_PARTS_ID):
		return false
	if not is_equal_approx(float(inputs[0].get("amount", -1.0)), 1.0):
		return false
	var daily_demand := _find_entry(nodes, &"daily_demand")
	if daily_demand.get("kind") != "register" or daily_demand.get("formula") != "normal_demand - (normal_demand - rationed_demand) * rationing_enabled":
		return false
	var expected_edges := {
		"treatment_serves_shortage": {"from": "treatment_production", "to": "daily_water_use", "rate": "min(treatment_output * treatment_online, max(0, daily_demand - water_reserve_days))"},
		"treatment_replenishes_reserve": {"from": "treatment_production", "to": String(WATER_RESERVE_ID), "rate": "max(0, treatment_output * treatment_online - max(0, daily_demand - water_reserve_days))"},
		"reserve_serves_demand": {"from": String(WATER_RESERVE_ID), "to": "daily_water_use", "rate": "min(daily_demand, water_reserve_days)"},
		"unmet_demand_accumulates": {"from": "unmet_demand_source", "to": String(UNMET_WATER_ID), "rate": "max(0, daily_demand - water_reserve_days - treatment_output * treatment_online)"}
	}
	for edge_id in expected_edges:
		var edge := _find_entry(edges, edge_id)
		var expected: Dictionary = expected_edges[edge_id]
		if edge.get("kind") != "flow" or edge.get("from") != expected["from"] or edge.get("to") != expected["to"] or edge.get("rate") != expected["rate"]:
			return false
	return true


func _find_entry(entries: Array, entry_id: Variant) -> Dictionary:
	for entry in entries:
		if typeof(entry) == TYPE_DICTIONARY and entry.get("id") == entry_id:
			return entry
	return {}


func _entry_value(entries: Array, entry_id: Variant, key: String) -> Variant:
	return _find_entry(entries, entry_id).get(key)


func _model_parameter(parameter_id: String) -> float:
	if not is_ready() and _model.is_empty():
		return 0.0
	return float(_entry_value(_model.get("parameters", []), parameter_id, "value"))


func _model_pool_start(node_id: StringName) -> float:
	var node := _find_entry(_model.get("nodes", []), node_id)
	return float(node.get("start", 0.0))


func _repair_part_cost() -> float:
	var repair := _find_entry(_model.get("nodes", []), &"repair_treatment")
	var inputs: Array = repair.get("inputs", [])
	if inputs.is_empty():
		return 0.0
	return float(inputs[0].get("amount", 0.0))

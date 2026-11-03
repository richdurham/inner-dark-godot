class_name CeresRunSimulation
extends RefCounted

const WATER_RESERVE_ID: StringName = &"water_reserve_days"
const DEMO_STARTING_RESERVE_DAYS: float = 6.0
const DEMO_RESERVE_USE_PER_TICK: float = 1.0

var state: SimulationState
var latest_event: SimulationEvent = null
var _engine := SimulationEngine.new()


func _init() -> void:
	reset()


func reset() -> void:
	state = SimulationState.new()
	state.add_stock(ResourceStock.new(WATER_RESERVE_ID, DEMO_STARTING_RESERVE_DAYS, &"days"))
	latest_event = null


func advance_day() -> SimulationResult:
	var tick_result := _engine.advance_tick(state)
	if not tick_result.accepted:
		return tick_result
	latest_event = tick_result.event

	var reserve := state.get_stock(WATER_RESERVE_ID)
	if reserve == null or reserve.amount <= 0.0:
		return tick_result

	var amount_used := minf(DEMO_RESERVE_USE_PER_TICK, reserve.amount)
	var stock_result := _engine.change_stock(
		state,
		WATER_RESERVE_ID,
		-amount_used,
		"Temporary demo rule: use one reserve-day per simulated day."
	)
	if stock_result.accepted:
		latest_event = stock_result.event
		return stock_result

	return stock_result


func reserve_days() -> float:
	var reserve := state.get_stock(WATER_RESERVE_ID)
	return reserve.amount if reserve != null else 0.0


func tick_index() -> int:
	return state.tick_index

extends SceneTree
const CeresRunSimulation = preload("res://simulation/ceres_run_simulation.gd")

func _initialize() -> void:
	var output := {
		"normal": _run_case(false, false, 7),
		"rationed": _run_case(true, false, 12),
		"repaired": _run_case(false, true, 8)
	}
	print("CERES_PARITY:" + JSON.stringify(output))
	quit()


func _run_case(use_rationing: bool, repair: bool, days: int) -> Array[Dictionary]:
	var simulation := CeresRunSimulation.new()
	if not simulation.is_ready():
		push_error(simulation.model_error)
		quit(1)
		return []
	if use_rationing and not simulation.set_rationing_enabled(true).accepted:
		push_error("Could not enable rationing in parity case.")
		quit(1)
		return []
	if repair and not simulation.repair_treatment().accepted:
		push_error("Could not repair treatment in parity case.")
		quit(1)
		return []
	var balances: Array[Dictionary] = []
	for _day in range(days):
		var result := simulation.advance_day()
		if not result.accepted:
			push_error("Could not advance a parity case day.")
			quit(1)
			return []
		balances.append({
			"water": simulation.reserve_days(),
			"unmet": simulation.unmet_water_days()
		})
	return balances

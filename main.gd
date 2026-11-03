extends Control

const PLAYER_SPEED := 210.0
const PLAYER_RADIUS := 13.0
const PLAYER_START := Vector2(575, 405)
const WALK_BOUNDS := Rect2(Vector2(88, 128), Vector2(976, 292))
const OBSTACLES := [
	Rect2(Vector2(512, 270), Vector2(150, 66)),
	Rect2(Vector2(690, 307), Vector2(150, 40)),
	Rect2(Vector2(358, 174), Vector2(158, 34))
]

const SOURCES := [
	{
		"id": "board",
		"name": "Crisis board",
		"role": "PUBLIC CRISIS FACTS",
		"position": Vector2(245, 188),
		"color": "#e7bd77",
		"initials": "!",
		"dialogue": "Ceres reserves are below one week. The missing commercial freighter carried water-treatment components. Transfers occurred outside the normal manifest schedule. Who took the freighter remains unverified."
	},
	{
		"id": "mara",
		"name": "Mara Venn",
		"role": "MINING ADMINISTRATOR",
		"position": Vector2(435, 230),
		"color": "#82b9c7",
		"initials": "MV",
		"dialogue": "The commercial freighter carrying the water-treatment components is missing. Our reserves are below a week. Those are the facts I can confirm."
	},
	{
		"id": "ilyan",
		"name": "Ilyan Rusk",
		"role": "INDEPENDENT MERCHANT",
		"position": Vector2(790, 356),
		"color": "#b8a2d6",
		"initials": "IR",
		"dialogue": "Transfers happened outside the normal manifest schedule. There are rumors, but I don't know who took the freighter."
	},
	{
		"id": "sato",
		"name": "Officer Sato",
		"role": "MILITIA OFFICER",
		"position": Vector2(930, 225),
		"color": "#d59b83",
		"initials": "OS",
		"dialogue": "Irregular cargo is under investigation. There is no verified evidence identifying who took the freighter."
	}
]

const COLORS := {
	"background": "#080c13",
	"floor": "#0d151f",
	"grid": "#15232f",
	"wall": "#526474",
	"furniture": "#172632",
	"panel": "#111a25",
	"panel_alt": "#151f2b",
	"border": "#344455",
	"text": "#eef2ed",
	"body": "#dce3e2",
	"muted": "#9eacba",
	"quiet": "#788797",
	"accent": "#82b9c7",
	"accent_bright": "#a9d4d3",
	"accent_dark": "#101820",
	"warning": "#e7bd77"
}

var player_position := PLAYER_START
var facing := Vector2.UP
var reviewed_sources: Dictionary = {}
var nearby_source: Dictionary = {}
var complete := false

var dialogue_title: Label
var dialogue_role: Label
var dialogue_body: Label
var interaction_hint: Label
var objective_title: Label
var objective_body: Label
var progress_label: Label
var simulation: CeresRunSimulation
var reserve_status_label: Label
var tick_status_label: Label
var event_status_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for source in SOURCES:
		reviewed_sources[source["id"]] = false
	simulation = CeresRunSimulation.new()
	_build_overlay()
	_update_simulation_display()
	_update_objective()
	_refresh_nearby_source()
	queue_redraw()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_interact()
	if Input.is_action_just_pressed("restart_briefing"):
		_restart_slice()
	if Input.is_action_just_pressed("advance_day"):
		_advance_simulation()

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length_squared() > 0.0:
		facing = direction
		_move_player(direction * PLAYER_SPEED * delta)
		queue_redraw()

	_refresh_nearby_source()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), _color("background"))

	var floor_rect := Rect2(Vector2(64, 106), Vector2(1024, 350))
	draw_rect(floor_rect, _color("floor"))
	for x in range(80, 1088, 48):
		draw_line(Vector2(x, 106), Vector2(x, 456), _color("grid"), 1.0)
	for y in range(122, 456, 48):
		draw_line(Vector2(64, y), Vector2(1088, y), _color("grid"), 1.0)
	draw_rect(floor_rect, _color("wall"), false, 2.0)
	_draw_floor_labels()
	_draw_board()
	_draw_furniture()
	_draw_sources()
	_draw_player()


func _draw_floor_labels() -> void:
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(85, 127), "PROTOTYPE FLOORPLAN  /  CERES RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, _color("quiet"))
	draw_string(font, Vector2(373, 160), "ADMINISTRATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, _color("quiet"))
	draw_string(font, Vector2(708, 272), "COMMON AREA", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, _color("quiet"))
	draw_string(font, Vector2(879, 157), "MILITIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, _color("quiet"))


func _draw_board() -> void:
	var board_rect := Rect2(Vector2(155, 145), Vector2(180, 88))
	draw_rect(board_rect, _color("panel_alt"))
	draw_rect(board_rect, _color("warning"), false, 1.5)
	draw_rect(Rect2(Vector2(168, 158), Vector2(5, 60)), _color("warning"))
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(184, 176), "WATER / FREIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, _color("text"))
	draw_string(font, Vector2(184, 198), "RESERVES < 1 WEEK", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, _color("warning"))
	draw_string(font, Vector2(184, 216), "MANIFEST REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, _color("muted"))


func _draw_furniture() -> void:
	_draw_furniture_item(Rect2(Vector2(512, 270), Vector2(150, 66)), "BRIEFING TABLE")
	_draw_furniture_item(Rect2(Vector2(690, 307), Vector2(150, 40)), "TRADE DESK")
	_draw_furniture_item(Rect2(Vector2(358, 174), Vector2(158, 34)), "ADMIN DESK")


func _draw_furniture_item(rect: Rect2, label_text: String) -> void:
	draw_rect(rect, _color("furniture"))
	draw_rect(rect, _color("border"), false, 1.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(10, rect.size.y + 15), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, _color("quiet"))


func _draw_sources() -> void:
	for source in SOURCES:
		var source_position: Vector2 = source["position"]
		var source_id: String = source["id"]
		var accent := Color(source["color"])
		var is_nearby: bool = nearby_source.get("id", "") == source_id
		if is_nearby:
			draw_arc(source_position, 35.0, 0.0, TAU, 40, _color("accent_bright"), 2.0, true)

		if source_id == "board":
			draw_circle(source_position, 11.0, accent)
			draw_arc(source_position, 18.0, 0.0, TAU, 36, accent, 1.5, true)
			draw_string(ThemeDB.fallback_font, source_position + Vector2(-4, 5), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, _color("accent_dark"))
			continue

		draw_circle(source_position, 24.0, _color("panel_alt"))
		draw_arc(source_position, 24.0, 0.0, TAU, 40, accent, 2.0, true)
		draw_string(ThemeDB.fallback_font, source_position + Vector2(-14, 5), source["initials"], HORIZONTAL_ALIGNMENT_CENTER, 28, 12, _color("text"))
		draw_string(ThemeDB.fallback_font, source_position + Vector2(-54, 45), source["name"], HORIZONTAL_ALIGNMENT_CENTER, 108, 11, _color("body"))


func _draw_player() -> void:
	draw_circle(player_position, PLAYER_RADIUS, _color("accent_bright"))
	draw_arc(player_position, PLAYER_RADIUS + 3.0, 0.0, TAU, 32, _color("accent"), 1.5, true)
	var tip := player_position + facing * 19.0
	var side := Vector2(-facing.y, facing.x) * 6.0
	var points := PackedVector2Array([
		tip,
		player_position - facing * 5.0 + side,
		player_position - facing * 5.0 - side
	])
	draw_colored_polygon(points, _color("accent_dark"))


func _build_overlay() -> void:
	var margins := MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margins.add_theme_constant_override("margin_left", 28)
	margins.add_theme_constant_override("margin_right", 28)
	margins.add_theme_constant_override("margin_top", 20)
	margins.add_theme_constant_override("margin_bottom", 18)
	add_child(margins)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margins.add_child(page)

	var header := HBoxContainer.new()
	page.add_child(header)

	var title_block := VBoxContainer.new()
	title_block.add_theme_constant_override("separation", 2)
	header.add_child(title_block)

	var title := _label("THE INNER DARK", 24, "text")
	title_block.add_child(title)
	title_block.add_child(_label("CERES RUN  /  FIELD BRIEF", 11, "accent"))

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	var status_card := PanelContainer.new()
	status_card.custom_minimum_size = Vector2(300, 0)
	status_card.add_theme_stylebox_override("panel", _panel_style("panel", 8, 12))
	header.add_child(status_card)
	var status := VBoxContainer.new()
	status.add_theme_constant_override("separation", 2)
	status_card.add_child(status)
	status.add_child(_label("SIMULATION TEST  /  TEMPORARY RULES", 10, "accent"))
	reserve_status_label = _label("", 12, "warning")
	status.add_child(reserve_status_label)
	tick_status_label = _label("", 10, "muted")
	status.add_child(tick_status_label)
	event_status_label = _label("", 10, "quiet")
	event_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_child(event_status_label)

	var vertical_spacer := Control.new()
	vertical_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(vertical_spacer)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 14)
	page.add_child(footer)

	var dialogue_panel := PanelContainer.new()
	dialogue_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_panel.custom_minimum_size = Vector2(0, 154)
	dialogue_panel.add_theme_stylebox_override("panel", _panel_style("panel", 9, 16))
	footer.add_child(dialogue_panel)

	var dialogue_stack := VBoxContainer.new()
	dialogue_stack.add_theme_constant_override("separation", 5)
	dialogue_panel.add_child(dialogue_stack)
	dialogue_stack.add_child(_label("FIELD NOTES  /  INTERACTION", 10, "accent"))
	dialogue_title = _label("Crisis board", 18, "text")
	dialogue_stack.add_child(dialogue_title)
	dialogue_role = _label("PUBLIC CRISIS FACTS", 10, "quiet")
	dialogue_stack.add_child(dialogue_role)
	dialogue_body = _label("Ceres reserves are below one week. The missing commercial freighter carried water-treatment components. Transfers occurred outside the normal manifest schedule. Who took the freighter remains unverified.", 13, "body")
	dialogue_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_stack.add_child(dialogue_body)
	interaction_hint = _label("Walk to a marked source and press E to inspect or speak.", 10, "accent")
	dialogue_stack.add_child(interaction_hint)

	var objective_panel := PanelContainer.new()
	objective_panel.custom_minimum_size = Vector2(330, 154)
	objective_panel.add_theme_stylebox_override("panel", _panel_style("panel_alt", 9, 16))
	footer.add_child(objective_panel)

	var objective_stack := VBoxContainer.new()
	objective_stack.add_theme_constant_override("separation", 7)
	objective_panel.add_child(objective_stack)
	objective_title = _label("BRIEFING OBJECTIVE", 10, "accent")
	objective_stack.add_child(objective_title)
	objective_body = _label("Inspect the crisis board and speak with all three information sources.", 13, "text")
	objective_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_stack.add_child(objective_body)
	progress_label = _label("", 11, "warning")
	objective_stack.add_child(progress_label)
	var controls := _label("WASD / ARROWS MOVE   E INTERACT   T ADVANCE DAY   R RESTART", 9, "muted")
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_stack.add_child(controls)


func _label(text: String, font_size: int, color_key: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", _color(color_key))
	return label


func _panel_style(background: String, radius: int, inset: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _color(background)
	style.border_color = _color("border")
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.content_margin_left = inset
	style.content_margin_right = inset
	style.content_margin_top = inset
	style.content_margin_bottom = inset
	return style


func _color(key: String) -> Color:
	return Color(COLORS[key])


func _advance_simulation() -> void:
	var result := simulation.advance_day()
	if result.accepted:
		_update_simulation_display()


func _update_simulation_display() -> void:
	reserve_status_label.text = "WATER RESERVE: %.1f DAYS" % simulation.reserve_days()
	tick_status_label.text = "DAY %d  /  T ADVANCES ONE DAY" % simulation.tick_index()
	if simulation.latest_event == null:
		event_status_label.text = "LAST EVENT: NONE"
	else:
		var event: SimulationEvent = simulation.latest_event
		event_status_label.text = "EVENT %d  /  %s" % [event.sequence, event.summary]


func _move_player(movement: Vector2) -> void:
	var left := WALK_BOUNDS.position.x + PLAYER_RADIUS
	var right := WALK_BOUNDS.end.x - PLAYER_RADIUS
	var top := WALK_BOUNDS.position.y + PLAYER_RADIUS
	var bottom := WALK_BOUNDS.end.y - PLAYER_RADIUS

	var horizontal := Vector2(clampf(player_position.x + movement.x, left, right), player_position.y)
	if not _blocked(horizontal):
		player_position.x = horizontal.x

	var vertical := Vector2(player_position.x, clampf(player_position.y + movement.y, top, bottom))
	if not _blocked(vertical):
		player_position.y = vertical.y


func _blocked(position_to_check: Vector2) -> bool:
	for obstacle in OBSTACLES:
		var obstacle_rect: Rect2 = obstacle
		if obstacle_rect.grow(PLAYER_RADIUS).has_point(position_to_check):
			return true
	return false


func _nearest_source() -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_distance := 76.0
	for source in SOURCES:
		var source_position: Vector2 = source["position"]
		var distance := player_position.distance_to(source_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest = source
	return nearest


func _refresh_nearby_source() -> void:
	var next_source := _nearest_source()
	var old_id: String = nearby_source.get("id", "")
	var new_id: String = next_source.get("id", "")
	if old_id == new_id:
		return
	nearby_source = next_source
	queue_redraw()
	if new_id == "":
		interaction_hint.text = "Walk to a marked source and press E to inspect or speak."
	else:
		interaction_hint.text = "E  /  %s" % next_source["name"]


func _interact() -> void:
	var source := _nearest_source()
	if source.is_empty():
		dialogue_title.text = "No source in reach"
		dialogue_role.text = "MOVE CLOSER TO A MARKED SOURCE"
		dialogue_body.text = "The board and colony staff are the available information sources in this prototype."
		return

	dialogue_title.text = source["name"]
	dialogue_role.text = source["role"]
	dialogue_body.text = source["dialogue"]
	reviewed_sources[source["id"]] = true
	_update_objective()


func _update_objective() -> void:
	var reviewed_count := 0
	for value in reviewed_sources.values():
		if value:
			reviewed_count += 1
	progress_label.text = "SOURCES REVIEWED  /  %d OF %d" % [reviewed_count, SOURCES.size()]
	complete = reviewed_count == SOURCES.size()
	if complete:
		objective_title.text = "BRIEFING COMPLETE"
		objective_body.text = "All documented sources reviewed. The cause remains unresolved."
	else:
		objective_title.text = "BRIEFING OBJECTIVE"
		objective_body.text = "Inspect the crisis board and speak with all three information sources."


func _restart_slice() -> void:
	simulation.reset()
	_update_simulation_display()
	player_position = PLAYER_START
	facing = Vector2.UP
	nearby_source = {}
	complete = false
	for source in SOURCES:
		reviewed_sources[source["id"]] = false
	dialogue_title.text = "Crisis board"
	dialogue_role.text = "PUBLIC CRISIS FACTS"
	dialogue_body.text = "Ceres reserves are below one week. The missing commercial freighter carried water-treatment components. Transfers occurred outside the normal manifest schedule. Who took the freighter remains unverified."
	_update_objective()
	_refresh_nearby_source()
	queue_redraw()

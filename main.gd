extends Control

const BEATS: Array[String] = [
	"This is a placeholder opening beat. Replace it with the first authored moment of the story.",
	"Use this space to introduce a character, a place, or a question the player wants answered.",
	"The scene is live and interactive. The project's story text can take over from here."
]

var beat_index := 0
var beat_label: Label
var chapter_label: Label
var next_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()
	_show_beat()


func _build_interface() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("#080c13")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 460)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#111a25")
	panel_style.border_color = Color("#344455")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left = 40
	panel_style.content_margin_right = 40
	panel_style.content_margin_top = 34
	panel_style.content_margin_bottom = 34
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 18)
	panel.add_child(stack)

	var masthead := HBoxContainer.new()
	stack.add_child(masthead)

	var brand := Label.new()
	brand.text = "FIELD NOTES   /   NARRATIVE PROTOTYPE"
	brand.add_theme_color_override("font_color", Color("#82b9c7"))
	brand.add_theme_font_size_override("font_size", 13)
	masthead.add_child(brand)

	chapter_label = Label.new()
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	chapter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chapter_label.add_theme_color_override("font_color", Color("#8796a7"))
	chapter_label.add_theme_font_size_override("font_size", 13)
	masthead.add_child(chapter_label)

	var title := Label.new()
	title.text = "THE INNER DARK"
	title.add_theme_color_override("font_color", Color("#eef2ed"))
	title.add_theme_font_size_override("font_size", 40)
	stack.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A quiet place for a story to begin."
	subtitle.add_theme_color_override("font_color", Color("#9eacba"))
	subtitle.add_theme_font_size_override("font_size", 17)
	stack.add_child(subtitle)

	var divider := HSeparator.new()
	stack.add_child(divider)

	beat_label = Label.new()
	beat_label.custom_minimum_size = Vector2(0, 150)
	beat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	beat_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	beat_label.add_theme_color_override("font_color", Color("#dce3e2"))
	beat_label.add_theme_font_size_override("font_size", 21)
	stack.add_child(beat_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(spacer)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 16)
	stack.add_child(footer)

	var note := Label.new()
	note.text = "PLACEHOLDER COPY  •  NO CANONICAL STORY TEXT"
	note.add_theme_color_override("font_color", Color("#788797"))
	note.add_theme_font_size_override("font_size", 12)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(note)

	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(168, 48)
	next_button.focus_mode = Control.FOCUS_ALL
	next_button.add_theme_font_size_override("font_size", 15)
	next_button.add_theme_color_override("font_color", Color("#101820"))
	next_button.add_theme_stylebox_override("normal", _button_style("#a9d4d3", "#a9d4d3"))
	next_button.add_theme_stylebox_override("hover", _button_style("#c0e3df", "#c0e3df"))
	next_button.add_theme_stylebox_override("pressed", _button_style("#83b8ba", "#83b8ba"))
	next_button.pressed.connect(_advance)
	footer.add_child(next_button)


func _button_style(fill: String, border: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill)
	style.border_color = Color(border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _show_beat() -> void:
	beat_label.text = BEATS[beat_index]
	chapter_label.text = "OPENING  //  %02d" % (beat_index + 1)
	next_button.text = "Continue" if beat_index < BEATS.size() - 1 else "Restart"
	next_button.grab_focus()


func _advance() -> void:
	beat_index = (beat_index + 1) % BEATS.size()
	_show_beat()

class_name CeresSaveStore
extends RefCounted

const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://inner_dark_ceres_run.json"


func write_save(payload: Dictionary) -> Dictionary:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "reason": "open_failed_%d" % FileAccess.get_open_error()}

	file.store_string(JSON.stringify({
		"format_version": SAVE_VERSION,
		"payload": payload
	}, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return {"ok": false, "reason": "write_failed_%d" % write_error}
	return {"ok": true, "path": SAVE_PATH}


func read_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"ok": false, "reason": "save_not_found"}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": "open_failed_%d" % FileAccess.get_open_error()}
	var contents := file.get_as_text()
	file.close()

	var parser := JSON.new()
	var parse_error := parser.parse(contents)
	if parse_error != OK:
		return {"ok": false, "reason": "invalid_json_%s" % parser.get_error_message()}
	if typeof(parser.data) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "invalid_save_root"}
	var envelope: Dictionary = parser.data
	var version: Variant = envelope.get("format_version")
	var payload: Variant = envelope.get("payload")
	var is_supported_version := (typeof(version) == TYPE_INT or typeof(version) == TYPE_FLOAT) and is_finite(float(version)) and float(version) == float(SAVE_VERSION)
	if not is_supported_version:
		return {"ok": false, "reason": "unsupported_save_version_%s_expected_%d" % [str(version), SAVE_VERSION]}
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "invalid_save_payload"}
	return {"ok": true, "payload": payload}

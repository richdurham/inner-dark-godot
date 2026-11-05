class_name WorldRecord
extends RefCounted

## Authoritative identity and language record for a person, group, place,
## institution, item, resource, work order, or other world concept.
## Numeric stocks remain in typed simulation state; this record links identity,
## descriptive context, semantic tags, visibility, and provenance.

var record_id: StringName = &""
var record_kind: StringName = &""
var display_name: String = ""
var description: String = ""
var tags: Array[StringName] = []
var audience_ids: Array[StringName] = []
var source_record_ids: Array[StringName] = []
var created_at_world_time: int = 0
var updated_at_world_time: int = 0


func _init(
	p_record_id: StringName = &"",
	p_record_kind: StringName = &"",
	p_display_name: String = "",
	p_description: String = "",
	p_tags: Array[StringName] = [],
	p_audience_ids: Array[StringName] = [],
	p_source_record_ids: Array[StringName] = [],
	p_created_at_world_time: int = 0,
	p_updated_at_world_time: int = 0
) -> void:
	record_id = p_record_id
	record_kind = p_record_kind
	display_name = p_display_name.strip_edges()
	description = p_description.strip_edges()
	tags = _unique_sorted(p_tags)
	audience_ids = _unique_sorted(p_audience_ids)
	source_record_ids = _unique_sorted(p_source_record_ids)
	created_at_world_time = p_created_at_world_time
	updated_at_world_time = p_updated_at_world_time


func is_valid() -> bool:
	return (
		not String(record_id).is_empty()
		and not String(record_kind).is_empty()
		and not display_name.is_empty()
		and created_at_world_time >= 0
		and updated_at_world_time >= created_at_world_time
		and _all_nonempty(tags)
		and _all_nonempty(audience_ids)
		and _all_nonempty(source_record_ids)
	)


func is_visible_to(observer_id: StringName) -> bool:
	return audience_ids.is_empty() or audience_ids.has(observer_id)


func to_dictionary() -> Dictionary:
	return {
		"record_id": String(record_id),
		"record_kind": String(record_kind),
		"display_name": display_name,
		"description": description,
		"tags": _strings(tags),
		"audience_ids": _strings(audience_ids),
		"source_record_ids": _strings(source_record_ids),
		"created_at_world_time": created_at_world_time,
		"updated_at_world_time": updated_at_world_time
	}


func copy() -> WorldRecord:
	return WorldRecord.from_dictionary(to_dictionary())


static func from_dictionary(data: Variant) -> WorldRecord:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var record_id: Variant = data.get("record_id")
	var record_kind: Variant = data.get("record_kind")
	var display_name: Variant = data.get("display_name")
	var description: Variant = data.get("description", "")
	var tags_data: Variant = data.get("tags", [])
	var audience_data: Variant = data.get("audience_ids", [])
	var sources_data: Variant = data.get("source_record_ids", [])
	var created_at: Variant = data.get("created_at_world_time", 0)
	var updated_at: Variant = data.get("updated_at_world_time", created_at)
	if typeof(record_id) != TYPE_STRING or typeof(record_kind) != TYPE_STRING:
		return null
	if typeof(display_name) != TYPE_STRING or typeof(description) != TYPE_STRING:
		return null
	if typeof(tags_data) != TYPE_ARRAY or typeof(audience_data) != TYPE_ARRAY or typeof(sources_data) != TYPE_ARRAY:
		return null
	if not _is_integer_number(created_at) or not _is_integer_number(updated_at):
		return null
	var tags := _string_names(tags_data)
	var audiences := _string_names(audience_data)
	var sources := _string_names(sources_data)
	if tags == null or audiences == null or sources == null:
		return null
	var record := WorldRecord.new(
		StringName(record_id),
		StringName(record_kind),
		String(display_name),
		String(description),
		tags,
		audiences,
		sources,
		int(created_at),
		int(updated_at)
	)
	return record if record.is_valid() else null


static func _string_names(values: Array) -> Variant:
	var result: Array[StringName] = []
	for value in values:
		if typeof(value) != TYPE_STRING or String(value).is_empty():
			return null
		result.append(StringName(value))
	return result


static func _unique_sorted(values: Array[StringName]) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		if not String(value).is_empty() and not result.has(value):
			result.append(value)
	result.sort()
	return result


static func _strings(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	return result


static func _all_nonempty(values: Array[StringName]) -> bool:
	for value in values:
		if String(value).is_empty():
			return false
	return true


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	var numeric_value := float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)

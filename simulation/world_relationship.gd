class_name WorldRelationship
extends RefCounted

## A sourced, directed or mutual tie between stable world-record identities.
## Relationship meaning is carried by relation_type, scope, description, and
## tags; there is deliberately no universal relationship-strength score.

var relationship_id: StringName = &""
var source_record_id: StringName = &""
var target_record_id: StringName = &""
var relation_type: StringName = &""
var scope_id: StringName = &""
var description: String = ""
var tags: Array[StringName] = []
var audience_ids: Array[StringName] = []
var source_record_ids: Array[StringName] = []
var active: bool = true
var created_at_world_time: int = 0
var updated_at_world_time: int = 0


func _init(
	p_relationship_id: StringName = &"",
	p_source_record_id: StringName = &"",
	p_target_record_id: StringName = &"",
	p_relation_type: StringName = &"",
	p_scope_id: StringName = &"",
	p_description: String = "",
	p_tags: Array[StringName] = [],
	p_audience_ids: Array[StringName] = [],
	p_source_record_ids: Array[StringName] = [],
	p_active: bool = true,
	p_created_at_world_time: int = 0,
	p_updated_at_world_time: int = 0
) -> void:
	relationship_id = p_relationship_id
	source_record_id = p_source_record_id
	target_record_id = p_target_record_id
	relation_type = p_relation_type
	scope_id = p_scope_id
	description = p_description.strip_edges()
	tags = _unique_sorted(p_tags)
	audience_ids = _unique_sorted(p_audience_ids)
	source_record_ids = _unique_sorted(p_source_record_ids)
	active = p_active
	created_at_world_time = p_created_at_world_time
	updated_at_world_time = p_updated_at_world_time


func is_valid() -> bool:
	return (
		not String(relationship_id).is_empty()
		and not String(source_record_id).is_empty()
		and not String(target_record_id).is_empty()
		and source_record_id != target_record_id
		and not String(relation_type).is_empty()
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
		"relationship_id": String(relationship_id),
		"source_record_id": String(source_record_id),
		"target_record_id": String(target_record_id),
		"relation_type": String(relation_type),
		"scope_id": String(scope_id),
		"description": description,
		"tags": _strings(tags),
		"audience_ids": _strings(audience_ids),
		"source_record_ids": _strings(source_record_ids),
		"active": active,
		"created_at_world_time": created_at_world_time,
		"updated_at_world_time": updated_at_world_time
	}


func copy() -> WorldRelationship:
	return WorldRelationship.from_dictionary(to_dictionary())


static func from_dictionary(data: Variant) -> WorldRelationship:
	if typeof(data) != TYPE_DICTIONARY:
		return null
	var relationship_id: Variant = data.get("relationship_id")
	var source_id: Variant = data.get("source_record_id")
	var target_id: Variant = data.get("target_record_id")
	var relation_type: Variant = data.get("relation_type")
	var scope_id: Variant = data.get("scope_id", "")
	var description: Variant = data.get("description", "")
	var tags_data: Variant = data.get("tags", [])
	var audience_data: Variant = data.get("audience_ids", [])
	var sources_data: Variant = data.get("source_record_ids", [])
	var active: Variant = data.get("active", true)
	var created_at: Variant = data.get("created_at_world_time", 0)
	var updated_at: Variant = data.get("updated_at_world_time", created_at)
	if typeof(relationship_id) != TYPE_STRING or typeof(source_id) != TYPE_STRING or typeof(target_id) != TYPE_STRING:
		return null
	if typeof(relation_type) != TYPE_STRING or typeof(scope_id) != TYPE_STRING or typeof(description) != TYPE_STRING:
		return null
	if typeof(active) != TYPE_BOOL:
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
	var relationship := WorldRelationship.new(
		StringName(relationship_id),
		StringName(source_id),
		StringName(target_id),
		StringName(relation_type),
		StringName(scope_id),
		String(description),
		tags,
		audiences,
		sources,
		bool(active),
		int(created_at),
		int(updated_at)
	)
	return relationship if relationship.is_valid() else null


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

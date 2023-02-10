class_name MessageViewState
extends State

var file_path: String
var filter: String
var sort: int = 0
var messages := PoolStringArray()
var active_messages := PoolStringArray()


func _persisted_properties() -> Array:
	return ["file_path", "sort"]


func set_file_path(new_file_path: String) -> void:
	set_state("file_path", new_file_path)


func set_filter(new_filter: String) -> void:
	set_state("filter", new_filter)


func set_sort(new_sort: int) -> void:
	set_state("sort", new_sort)


func set_messages(new_messages: PoolStringArray) -> void:
	set_state("messages", new_messages)


func set_active_messages(new_messages: PoolStringArray) -> void:
	set_state("active_messages", new_messages)

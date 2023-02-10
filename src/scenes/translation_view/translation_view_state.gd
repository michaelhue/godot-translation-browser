class_name TranslationViewState
extends State

var file_paths: PoolStringArray
var translation: Translation
var message: String
var message_source: int = -1


func _persisted_properties() -> Array:
	return ["file_paths"]


func set_file_paths(new_paths: PoolStringArray) -> void:
	set_state("file_paths", new_paths)


func set_translation(new_translation: Translation) -> void:
	set_state("translation", new_translation)


func set_message(new_message: String) -> void:
	set_state("message", new_message)


func set_message_source(new_source: int) -> void:
	set_state("message_source", new_source)

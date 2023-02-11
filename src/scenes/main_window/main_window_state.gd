class_name MainWindowState
extends State


var split_offset_message := 0
var split_offset_locale := 0


func _persisted_properties() -> Array:
	return ["split_offset_message", "split_offset_locale"]


func set_split_offset_message(offset: int) -> void:
	set_state("split_offset_message", offset)


func set_split_offset_locale(offset: int) -> void:
	set_state("split_offset_locale", offset)

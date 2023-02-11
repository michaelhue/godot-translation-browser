extends Control


onready var state := get_node("%MainWindowState") as MainWindowState
onready var message_split := get_node("%MessageSplit") as SplitContainer
onready var locale_split := get_node("%LocaleSplit") as SplitContainer


func _ready() -> void:
	state.watch(self, "_on_state_changed")

	message_split.connect(
			"dragged", self, "_on_split_offset_changed", ["split_offset_message"])
	locale_split.connect(
			"dragged", self, "_on_split_offset_changed", ["split_offset_locale"])


func _on_state_changed(property: String, value, _old) -> void:
	match property:
		"split_offset_message":
			message_split.set_split_offset(value)
		"split_offset_locale":
			locale_split.set_split_offset(value)


func _on_split_offset_changed(offset: int, property: String) -> void:
	state.set_state(property, offset)

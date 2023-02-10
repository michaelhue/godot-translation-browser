tool
class_name ItemListNavigator
extends Node
## Adds global keyboard navigation to [ItemList].


export var next_action: String
export var prev_action: String

onready var _item_list := get_parent() as ItemList


func _get_configuration_warning() -> String:
	if not get_parent() is ItemList:
		return "Must be a direct child of ItemList"

	InputMap.load_from_globals()

	if not InputMap.has_action(next_action):
		return "Invalid next_action"

	if not InputMap.has_action(prev_action):
		return "Invalid prev_action"

	return ""


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed(next_action):
		select_offset(1)
	elif event.is_action_pressed(prev_action):
		select_offset(-1)


func select_offset(offset: int) -> int:
	var total := _item_list.get_item_count()
	var index := 0
	var new_index := index

	if total == 0:
		return -1

	if _item_list.is_anything_selected():
		index = _item_list.get_selected_items()[0]
		new_index = index + offset

	if new_index < 0:
		new_index = _item_list.get_item_count() - 1
	elif new_index > total - 1:
		new_index = 0

	if new_index == index:
		return index

	_item_list.select(new_index, true)
	_item_list.ensure_current_is_visible()
	_item_list.emit_signal("item_selected", new_index)

	return new_index

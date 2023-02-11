extends PanelContainer

enum Sort { NONE, ASC, DESC }

var loader: MessageLoader

onready var state := get_node("%MessageViewState") as MessageViewState

onready var file_dialog := get_node("%FileDialog") as FileDialog
onready var path_row := get_node("%PathRow") as Control
onready var path_input := get_node("%PathInput") as LineEdit
onready var filter_input := get_node("%FilterInput") as LineEdit
onready var item_list := get_node("%ItemList") as ItemList
onready var status_label := get_node("%StatusLabel") as Label
onready var sort_button := get_node("%SortButton") as Button
onready var sort_menu := get_node("%SortMenu") as PopupMenu
onready var load_button := get_node("%LoadButton") as Button
onready var clear_button := get_node("%ClearButton") as Button


func _init() -> void:
	loader = MessageLoader.new()


func _ready() -> void:
	loader.connect("loaded", self, "_on_messages_loaded")

	AppState.notify(self, "_on_app_state_changed")

	path_row.visible = false
	filter_input.editable = false
	sort_button.disabled = true


func update_item_list() -> void:
	var messages := state.messages

	if state.sort != Sort.NONE:
		messages.sort()

	if state.sort == Sort.DESC:
		messages.invert()

	if not state.filter.empty():
		var filtered := PoolStringArray()

		for message in messages:
			if message.findn(state.filter) >= 0:
				filtered.append(message)

		messages = filtered

	state.set_active_messages(messages)


func select(message_id: String) -> int:
	var index := state.active_messages.find(message_id)

	if index >= 0:
		item_list.select(index)
		item_list.ensure_current_is_visible()

	return index


func _on_app_state_changed(property: String, value, _old) -> void:
	match property:
		"message_id":
			select(value)


func _on_state_changed(property: String, _value, _old) -> void:
	match property:
		"file_path":
			_on_file_path_changed()
		"messages":
			_on_messages_changed()
		"active_messages":
			_on_active_messages_changed()
		"sort":
			_on_sort_changed()
		"filter":
			update_item_list()


func _on_file_path_changed() -> void:
	state.set_messages(PoolStringArray())

	var error: int

	if not state.file_path.empty():
		error = loader.load_file(state.file_path)

	if error != OK:
		state.set_file_path("")
		return

	load_button.visible = state.file_path.empty()
	path_row.visible = not state.file_path.empty()

	path_input.set_text(state.file_path)
	path_input.caret_position = path_input.text.length()


func _on_messages_loaded(messages: PoolStringArray) -> void:
	state.set_messages(messages)


func _on_messages_changed() -> void:
	sort_button.disabled = state.messages.empty()
	filter_input.editable = not state.messages.empty()

	update_item_list()


func _on_active_messages_changed() -> void:
	item_list.clear()

	for message in state.active_messages:
		item_list.add_item(message)

	status_label.text = "%d messages" % state.active_messages.size()

	if state.active_messages.size() != state.messages.size():
		status_label.text += " (%d total)" % state.messages.size()

	# If the active list of messages does not include the current message_id,
	# set it to the first message in the list.
	if select(AppState.message_id) == -1:
		if state.active_messages.empty():
			AppState.set_message_id("")
		else:
			AppState.set_message_id(state.active_messages[0])


func _on_sort_changed() -> void:
	for i in range(sort_menu.get_item_count()):
		if sort_menu.is_item_checkable(i):
			sort_menu.set_item_checked(i, i == state.sort)

	update_item_list()


func _on_load_pressed() -> void:
	file_dialog.popup_centered_clamped(
			file_dialog.get_parent_area_size())


func _on_dialog_file_selected(path: String) -> void:
	state.set_file_path(path)


func _on_list_item_selected(index: int) -> void:
	AppState.set_message_id(state.active_messages[index])


func _on_reload_pressed() -> void:
	var path := String(state.file_path)
	state.set_file_path("")
	state.call_deferred("set_file_path", path)


func _on_clear_pressed() -> void:
	state.set_file_path("")


func _on_filter_text_changed(text: String) -> void:
	state.set_filter(text.strip_edges())


func _on_sort_pressed() -> void:
	if not sort_button.pressed:
		return

	var rect := sort_button.get_global_rect() as Rect2
	sort_menu.set_global_position(Vector2(rect.position.x, rect.end.y))
	sort_menu.popup()


func _on_sort_menu_popup_hide() -> void:
	sort_button.pressed = false


func _on_sort_menu_index_pressed(index: int) -> void:
	state.set_sort(index)


func _on_list_item_rmb_selected(index: int, _at_position: Vector2) -> void:
	OS.set_clipboard(state.active_messages[index])

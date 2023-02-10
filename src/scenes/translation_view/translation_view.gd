extends PanelContainer

signal updated()

const FileType = preload("res://src/scenes/file_type/file_type.gd")
const ViewLabel = preload("res://src/scenes/view_label/view_label.gd")

export var state_path: NodePath
export var manager_path: NodePath
export var label: String
export var label_color := Color.white

## Collapse the control when no files are selected.
export var collapse_empty := false

onready var state := get_node(state_path) as TranslationViewState
onready var manager := get_node(manager_path) as TranslationManager

onready var file_dialog := get_node("%FileDialog") as FileDialog
onready var view_label := get_node("%ViewLabel") as ViewLabel
onready var preview_container := get_node("%PreviewContainer") as Container
onready var preview := get_node("%Preview") as TextEdit
onready var preview_locale := get_node("%PreviewLocale") as LocaleAwareControl
onready var path_container := get_node("%PathContainer") as Control
onready var path_input := get_node("%PathInput") as LineEdit
onready var file_type := get_node("%FileType") as FileType
onready var load_button := get_node("%LoadButton") as Button
onready var clear_button := get_node("%ClearButton") as Button
onready var files_button := get_node("%FilesButton") as MenuButton
onready var source_label := get_node("%SourceLabel") as Label
onready var stats_label := get_node("%StatsLabel") as Label


func _ready() -> void:
	AppState.notify(self, "_on_app_state_changed")
	state.notify(self, "_on_state_changed")

	view_label.set_label_text(label)
	view_label.set_label_color(label_color)

	reset()
	_on_message_changed()
	_on_translation_changed()


func _on_app_state_changed(property: String, _value, _old) -> void:
	match property:
		"locale", "fallback_locale", "message_id":
			update_preview()


func _on_state_changed(property: String, _value, _old) -> void:
	match property:
		"file_paths":
			update_files()
		"message":
			_on_message_changed()
		"translation":
			_on_translation_changed()


func reset() -> void:
	manager.clear()

	preview_container.visible = not collapse_empty
	size_flags_stretch_ratio = 1 if preview_container.visible else 0

	load_button.visible = true
	path_container.visible = false
	path_input.text = ""

	update_preview()


func update_files() -> void:
	reset()

	if state.file_paths.empty():
		return

	manager.load_all(state.file_paths)

	size_flags_stretch_ratio = 1
	preview_container.visible = true
	path_container.visible = true
	load_button.visible = false

	update_preview()
	_update_files_list()


func update_preview() -> void:
	var translation := manager.get_translation(AppState.locale)

	var message := manager.translate(
			AppState.message_id, AppState.locale, AppState.fallback_locale)

	var message_source := manager.get_message_source(
			AppState.message_id, AppState.locale, AppState.fallback_locale)

	state.set_translation(translation)
	state.set_message(message)
	state.set_message_source(message_source)

	emit_signal("updated")


func _on_message_changed() -> void:
	var message := state.message

	preview.set_text(message)

	var chars := message.length()
	var words := message.split(" ").size() if message.length() else 0
	var lines := message.split("\n").size() if message.length() else 0

	match state.message_source:
		TranslationManager.MessageSource.LOCALE:
			source_label.set_text("Translated: %s" % AppState.locale.to_upper())
			preview_locale.set_locale(AppState.locale)
		TranslationManager.MessageSource.FALLBACK_LOCALE:
			source_label.set_text("Fallback: %s" % AppState.fallback_locale.to_upper())
			preview_locale.set_locale(AppState.fallback_locale)
		_:
			source_label.set_text("Untranslated")
			preview_locale.set_locale("")

	stats_label.set_text("Chars: %d    Words: %d    Lines: %d" % [chars, words, lines])


func _on_translation_changed() -> void:
	var translation := state.translation
	var ext := "N/A"
	var path := ""

	if translation is Translation:
		path = translation.get_meta(TranslationLoader.META_SOURCE_FILE)
		ext = path.get_extension()

	file_type.set_text(ext)
	file_type.set_visible(not ext.empty())
	path_input.set_text(path)
	path_input.caret_position = path.length() - 1

	_update_files_list()


func _update_files_list() -> void:
	var files := manager.get_files()
	var popup := files_button.get_popup()

	popup.clear()
	files_button.text = "%d sources" % files.size()
	files_button.visible = files.size() > 1

	for i in range(files.size()):
		var file: String = files[i]

		popup.add_item(file)
		popup.set_item_disabled(i, true)

		if file == path_input.text:
			popup.set_item_as_radio_checkable(i, true)
			popup.set_item_checked(i, true)


func _on_load_pressed() -> void:
	file_dialog.popup_centered_clamped(file_dialog.get_parent_area_size())


func _on_dialog_file_selected(path: String) -> void:
	state.set_file_paths(PoolStringArray([path]))


func _on_dialog_files_selected(paths: PoolStringArray) -> void:
	state.set_file_paths(paths)


func _on_reload_pressed() -> void:
	update_files()


func _on_clear_pressed() -> void:
	state.set_file_paths(PoolStringArray())

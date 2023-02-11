extends MarginContainer


const StatusLabel = preload("res://src/scenes/status_label/status_label.gd")

export var state_a_path: NodePath
export var state_b_path: NodePath

onready var state_a := get_node(state_a_path) as TranslationViewState
onready var state_b := get_node(state_b_path) as TranslationViewState
onready var status_label := get_node("%StatusLabel") as StatusLabel
onready var analyzer_button := get_node("%AnalyzerButton") as Button


func _ready() -> void:
	AppState.watch(self, "_on_app_state_changed")
	state_a.watch(self, "_on_state_changed")
	state_b.watch(self, "_on_state_changed")

	set_visible(false)


func _on_app_state_changed(property: String, value, _old) -> void:
	match property:
		"show_analyzer":
			analyzer_button.pressed = value

			if not value and visible:
				analyzer_button.grab_focus()


func _on_state_changed(_property: String, _value, _old) -> void:
	if state_a.file_paths.empty() or state_b.file_paths.empty():
		AppState.set_show_analyzer(false)
		set_visible(false)
		return

	var is_equal = state_a.message == state_b.message

	if is_equal:
		status_label.set_status(status_label.Status.SUCCESS)
	else:
		status_label.set_status(status_label.Status.WARNING)

	set_visible(true)


func _on_switch_pressed() -> void:
	var paths_a := PoolStringArray(state_a.file_paths)
	var paths_b := PoolStringArray(state_b.file_paths)

	state_a.set_file_paths(paths_b)
	state_b.set_file_paths(paths_a)


func _on_inspector_pressed() -> void:
	AppState.set_show_analyzer(not AppState.show_analyzer)

extends Node

const MIN_WINDOW_SIZE := Vector2(600, 400)


func _ready() -> void:
	setup_window()


func _notification(type: int) -> void:
	match type:
		NOTIFICATION_WM_FOCUS_OUT:
			Engine.set_target_fps(60)
		NOTIFICATION_WM_FOCUS_IN:
			Engine.set_target_fps(0)


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("app_reset"):
		_reset()


func setup_window() -> void:
	OS.set_min_window_size(MIN_WINDOW_SIZE)

	if AppState.window_size.length() > 0:
		OS.set_window_size(Vector2(
				max(AppState.window_size.x, MIN_WINDOW_SIZE.x),
				max(AppState.window_size.y, MIN_WINDOW_SIZE.y)))

	get_tree().connect("screen_resized", self, "_on_screen_resized")


func _on_screen_resized() -> void:
	AppState.set_window_size(OS.window_size)


func _reset() -> void:
	StateManager.clear()
	get_tree().reload_current_scene()

extends Node

const MIN_WINDOW_SIZE := Vector2(600, 400)


func _ready() -> void:
	get_tree().connect("screen_resized", self, "_on_screen_resized")

	setup_window()
	get_tree().paused = true


func _notification(type: int) -> void:
	match type:
		NOTIFICATION_WM_FOCUS_OUT:
			Engine.set_target_fps(30)
		NOTIFICATION_WM_FOCUS_IN:
			Engine.set_target_fps(0)


func setup_window() -> void:
	OS.set_min_window_size(MIN_WINDOW_SIZE)

	if AppState.window_size is Vector2:
		OS.set_window_size(Vector2(
				max(AppState.window_size.x, MIN_WINDOW_SIZE.x),
				max(AppState.window_size.y, MIN_WINDOW_SIZE.y)))


func _on_screen_resized() -> void:
	AppState.set_window_size(OS.window_size)

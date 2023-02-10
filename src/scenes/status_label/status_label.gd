tool
extends HBoxContainer

enum Status { SUCCESS, WARNING, ERROR, UNKNOWN = -1 }

export(Status) var status setget set_status, get_status

export var success_text := "Success"
export var warning_text := "Warning"
export var error_text := "Error"
export var text_override: String

var _status: int = Status.UNKNOWN

onready var _icon := get_node("%Icon") as TextureRect
onready var _label := get_node("%Label") as Label


func _ready() -> void:
	_update()


func set_status(new_status: int) -> void:
	_status = new_status
	_update()


func get_status() -> int:
	return _status


func _update() -> void:
	if not _icon or not _label:
		return

	var texture: Texture
	var text: String

	match _status:
		Status.SUCCESS:
			texture = get_icon("icon_success")
			text = success_text
		Status.WARNING:
			texture = get_icon("icon_warning")
			text = warning_text
		Status.ERROR:
			texture = get_icon("icon_error")
			text = error_text
		_:
			texture = get_icon("icon_unknown")
			text = "Unknown"

	if not text_override.empty():
		text = text_override

	if texture:
		_icon.texture = texture

	if text:
		_label.text = text

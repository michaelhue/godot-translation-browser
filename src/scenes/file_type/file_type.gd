tool
extends PanelContainer

export var text: String setget set_text, get_text

var _text := "EXT"
var _label: Label


func _ready() -> void:
	_label = get_node("%Label") as Label
	_label.set_text(_text)


func set_text(new_text: String) -> void:
	if _label:
		_label.set_text(new_text)
	_text = new_text


func get_text() -> String:
	return _text

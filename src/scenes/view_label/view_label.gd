tool
extends PanelContainer


export var label_text: String setget set_label_text, get_label_text
export var label_color: Color setget set_label_color, get_label_color

var _text := "?"
var _color := Color.white

onready var _label := get_node("%Label") as Label


func _enter_tree() -> void:
	_label = get_node("%Label")


func set_label_text(new_text: String) -> void:
	_text = new_text

	if _label:
		_label.set_text(new_text)


func get_label_text() -> String:
	return _text


func set_label_color(new_color: Color) -> void:
	_color = new_color
	modulate = new_color


func get_label_color() -> Color:
	return _color

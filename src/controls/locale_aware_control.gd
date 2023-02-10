tool
class_name LocaleAwareControl
extends Node
## Makes a Control node locale-aware by overriding its font.


## Name of the locale to use for the font override.
export var locale: String setget set_locale, get_locale

## Name of the font item to override.
export var font_item := "font"

var _locale: String
var _locale_variants := PoolStringArray()


func _get_configuration_warning() -> String:
	if not get_parent() is Control:
		return "Must be the child of a Control node"

	return ""


func set_locale(new_locale: String) -> void:
	_locale = new_locale

	_locale_variants = PoolStringArray([
		_locale.to_lower(),
		_locale.to_lower().substr(0, 2)
	])

	if get_parent() is Control:
		_update_font(get_parent())


func get_locale() -> String:
	return _locale


func _update_font(node: Control) -> void:
	var font: Font

	for variant in _locale_variants:
		if node.get_font(variant) != node.get_theme_default_font():
			font = node.get_font(variant)
			break

	if font:
		node.add_font_override(font_item, font)
	elif node.has_font_override(font_item):
		node.remove_font_override(font_item)

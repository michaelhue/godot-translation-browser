extends TextEdit


## Name of the locale to use for the font override.
export var locale: String setget set_locale, get_locale

## Name of the font item to override.
export var font_item := "font"

var _locale: String
var _locale_variants := PoolStringArray()


func _ready() -> void:
	add_color_region("{", "}", Color("#d1fae5"))


func set_locale(new_locale: String) -> void:
	_locale = new_locale

	_locale_variants = PoolStringArray([
		_locale.to_lower(),
		_locale.to_lower().substr(0, 2)
	])

	_update_font()


func get_locale() -> String:
	return _locale


func _update_font() -> void:
	var font: Font

	for variant in _locale_variants:
		if get_font(variant) != get_theme_default_font():
			font = get_font(variant)
			break

	if font:
		add_font_override("font", font)
	elif has_font_override("font"):
		remove_font_override("font")

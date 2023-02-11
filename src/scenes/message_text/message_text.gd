extends TextEdit


const MENU_TRANSLATE = 1000
const MENU_TRANSLATE_GOOGLE = 1001
const MENU_TRANSLATE_DEEPL = 1002
const MENU_TRANSLATE_BING = 1003

const TRANSLATION_SERVICES := {
	MENU_TRANSLATE_GOOGLE: "https://translate.google.com/?sl={locale}&text={text}&op=translate",
	MENU_TRANSLATE_DEEPL: "https://www.deepl.com/translator#{locale}/-/{text}",
	MENU_TRANSLATE_BING: "https://www.bing.com/translator/?from={locale}&text={text}",
}

## Name of the locale to use for the font override.
export var locale: String setget set_locale, get_locale

## Name of the font item to override.
export var font_item := "font"

var _locale: String
var _locale_variants := PoolStringArray()


func _ready() -> void:
	add_color_region("{", "}", Color("#d1fae5"))

	get_menu().add_separator()
	get_menu().add_submenu_item("Translate", "../TranslateMenu", MENU_TRANSLATE)


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


func _on_translate_menu_id_pressed(id: int) -> void:
	if not TRANSLATION_SERVICES.has(id):
		return

	var selection := get_selection_text()
	var stext := selection if not selection.empty() else text

	var url := TRANSLATION_SERVICES[id] as String
	var params := {
		"locale": AppState.locale.substr(0, 2),
		"text": stext.percent_encode(),
	}

	OS.shell_open(url.format(params))

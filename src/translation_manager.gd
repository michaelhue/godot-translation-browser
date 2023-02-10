class_name TranslationManager
extends Node
## Loads and manages a list of [Translation] resources from files.


## Emitted when a new [Translation] is added via [method append].
signal added(translation)

## Emitted when the list of translations changed.
signal updated()

## Enum for distinguishing the source of a message translation.
enum MessageSource { FALLBACK_LOCALE, LOCALE, NONE = -1 }

## Instance of [TranslationLoader] for loading translation source files.
var loader: TranslationLoader

## List of loaded [Translation] resources.
var translations := Array()

## List of loaded locales, matching [member translations].
var locales := PoolStringArray()


func _init() -> void:
	loader = TranslationLoader.new()
	loader.connect("loaded", self, "add")


## Add a [Translation] resource to the manager.
func add(translation: Translation) -> void:
	translations.append(translation)
	locales.append(translation.locale)

	emit_signal("added", translation)
	emit_signal("updated")


## Clear all loaded [Translation] resources.
func clear() -> void:
	translations.clear()
	locales = PoolStringArray()

	emit_signal("updated")


## Check if the manager has loaded any translations.
func empty() -> bool:
	return translations.empty()


## Loaded all translations from the given [code]path[/code]. See
## [TranslationLoader] for details on supported files.
func load_all(paths: PoolStringArray) -> void:
	loader.load_all(paths)


## Check if the given [code]locale[/locale] is loaded.
func has_locale(locale: String) -> bool:
	return locales.has(locale)


## Get the list of loaded translation locales.
func get_locales() -> PoolStringArray:
	return locales


## Get the sorted list of loaded translation locales.
func get_sorted_locales() -> PoolStringArray:
	var list := PoolStringArray(get_locales())
	list.sort()
	return list


## Get the loaded [Translation] resources.
func get_translations() -> Array:
	return translations


## Get the loaded [Translation] resource for the given [code]locale[/code].
func get_translation(locale: String) -> Translation:
	var index := get_locales().find(locale)

	if index == -1:
		return null

	return translations[index]


## Get a sorted list of unique translation source file names.
func get_files() -> PoolStringArray:
	var files = PoolStringArray()

	for res in get_translations():
		var file: String = res.get_meta(TranslationLoader.META_SOURCE_FILE)
		if not files.has(file):
			files.append(file)

	files.sort()

	return files


## Get the [enum MessageSource] type considering the given [code]message_id[/code],
## [code]locale[/code] and optional [code]fallback_locale[/code].
func get_message_source(message_id: String, locale: String, fallback_locale := "") -> int:
	if has_message(message_id, locale):
		return MessageSource.LOCALE

	if not fallback_locale.empty() \
			and locale != fallback_locale \
			and has_message(message_id, fallback_locale):
		return MessageSource.FALLBACK_LOCALE

	return MessageSource.NONE


## Get the list of message IDs for the given [code]locale[/code].
func get_message_ids(locale: String) -> PoolStringArray:
	var translation := get_translation(locale)

	if translation:
		return translation.get_message_list()

	return PoolStringArray()


## Check if the [Translation] for [code]locale[/code] contains the give
## [code]message_id[/code].
func has_message(message_id: String, locale: String) -> bool:
	return get_message_ids(locale).has(message_id)


## Get the message matching the given [code]message_id[/code] and
## [code]locale[/code]. Returns an empty [String] if no message was found.
func get_message(message_id: String, locale: String) -> String:
	var translation := get_translation(locale)

	if translation:
		return translation.get_message(message_id)

	return String()


## Translate the given [code]message_id[/code] like [method Object.tr] would. If
## no message was found for the given [code]locale[/code] or optional
## [code]fallback_locale[/code], the [code]message_id[/code] will be returned.
func translate(message_id: String, locale: String, fallback_locale := "") -> String:
	var source := get_message_source(message_id, locale, fallback_locale)

	match source:
		MessageSource.LOCALE:
			return get_message(message_id, locale)
		MessageSource.FALLBACK_LOCALE:
			return get_message(message_id, fallback_locale)
		_:
			return message_id

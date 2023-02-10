extends State

var locale: String
var fallback_locale: String
var message_id: String
var show_analyzer := false


func _ready() -> void:
	set_locale("en")
	set_fallback_locale("en")


func _persisted_properties() -> Array:
	return ["locale", "fallback_locale", "message_id", "show_analyzer"]


func set_locale(new_locale: String) -> void:
	set_state("locale", new_locale)


func set_fallback_locale(new_locale: String) -> void:
	set_state("fallback_locale", new_locale)


func set_message_id(new_message_id: String) -> void:
	set_state("message_id", new_message_id)


func set_show_analyzer(show: bool) -> void:
	set_state("show_analyzer", show)

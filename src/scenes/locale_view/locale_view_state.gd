class_name LocaleViewState
extends State


var filter := 0
var locales := PoolStringArray()
var active_locales := PoolStringArray()


func _persisted_properties() -> Array:
	return ["filter"]


func set_filter(new_filter: int) -> void:
	set_state("filter", new_filter)


func set_locales(new_locales: PoolStringArray) -> void:
	set_state("locales", new_locales)


func set_active_locales(new_locales: PoolStringArray) -> void:
	set_state("active_locales", new_locales)

class_name State
extends Node

## Emitted when a state property is changed via [method set_state]. This signal should be used to
## react to state changes. Listeners should be connected with the [member Object.CONNECT_DEFERRED]
## flag to prevent race conditions. Consider the [method notify] method to connect listeners.
signal changed(property, new_value, old_value)


func _ready() -> void:
	if not get_persisted_properties().empty():
		_state_manager().call_deferred("load_state", self)


## Override this method to return the property names that should be persisted.
func _persisted_properties() -> Array:
	return []


## Get the [StateManager] instance for loading/persisting state. Uses the global instance by default
## but can be overriden for special use cases.
func _state_manager():
	return StateManager


## Update a state property's value and emit the [signal changed] signal. Since state properties
## should be considered immutable, this method should be used in most cases for state updates. By
## default [signal change] signals are deferred to avoid potential race conditions when multiple
## properties are changed on the same frame. Enable [code]immediate[/code] to emit the signal on
## the current frame.
func set_state(property: String, new_value, immediate := false) -> void:
	var old_value = self[property]

	if new_value == old_value:
		return

	self[property] = new_value

	if property in get_persisted_properties():
		call_deferred("persist")

	if immediate:
		emit_signal("changed", property, new_value, old_value)
	else:
		call_deferred("emit_signal", "changed", property, new_value, old_value)


## Get the property names that should be persisted. See [method _persisted_properties].
func get_persisted_properties() -> Array:
	return _persisted_properties()


## Update persisted properties with the [StateManager].
func persist() -> void:
	if not get_persisted_properties().empty():
		_state_manager().call_deferred("save_state", self)


## Registers the given [code]method[/code] as a handler for [signal changed] signals.
func notify(target: Object, method: String) -> void:
	connect("changed", target, method, [], Object.CONNECT_DEFERRED)

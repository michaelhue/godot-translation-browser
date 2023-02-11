extends Node

signal loaded(state)
signal persisted(state)
signal saved()

const PATH = "user://state.cfg"

var config_file: ConfigFile


func _init() -> void:
	config_file = ConfigFile.new()


func _ready() -> void:
	config_file.load(PATH)


func _exit_tree() -> void:
	save()


func load_state(state: State) -> void:
	var section := state.get_name()
	var props := state.get_persisted_properties()

	for prop in props:
		if not config_file.has_section_key(section, prop):
			continue

		var value = config_file.get_value(section, prop)
		state.set_state(prop, value)

	emit_signal("loaded", state)


func persist_state(state: State) -> void:
	var section := state.get_name()
	var props := state.get_persisted_properties()

	for prop in props:
		config_file.set_value(section, prop, state[prop])

	emit_signal("persisted", state)


func save() -> void:
	config_file.save(PATH)
	emit_signal("saved")

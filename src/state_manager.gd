extends Node

const PATH = "user://state.cfg"

onready var config_file: ConfigFile


func _init() -> void:
	config_file = ConfigFile.new()
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


func save_state(state: State) -> void:
	var section := state.get_name()
	var props := state.get_persisted_properties()

	for prop in props:
		config_file.set_value(section, prop, state[prop])


func save() -> void:
	config_file.save(PATH)

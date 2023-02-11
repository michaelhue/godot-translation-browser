extends Node
## Manages [State] objects and loads/saves their persisted properties.


## Emitted when a [State] object's persisted properties were loaded.
signal loaded(state)

## Emitted when a [State] object's persisted properties were updated.
signal persisted(state)

## Emitted when the [member config_file] was saved to disk.
signal saved()

## [ConfigFile] path on file system.
const PATH = "user://state.cfg"

## [ConfigFile] instance for saving/loading state data.
var config_file: ConfigFile


func _init() -> void:
	config_file = ConfigFile.new()


func _ready() -> void:
	config_file.load(PATH)


func _exit_tree() -> void:
	save()


## Loads and sets persisted properties of the [code]state[/code] from the
## config file.
func load_state(state: State) -> void:
	var section := state.get_name()
	var props := state.get_persisted_properties()

	for prop in props:
		if not config_file.has_section_key(section, prop):
			continue

		var value = config_file.get_value(section, prop)
		state.set_state(prop, value)

	emit_signal("loaded", state)


## Updates persisted properties of the [code]state[/code] in the config file.
func persist_state(state: State) -> void:
	var section := state.get_name()
	var props := state.get_persisted_properties()

	for prop in props:
		config_file.set_value(section, prop, state[prop])

	emit_signal("persisted", state)


## Writes the config file to disk.
func save() -> void:
	config_file.save(PATH)
	emit_signal("saved")


## Clear the config file contents.
func clear() -> void:
	config_file.clear()
	save()

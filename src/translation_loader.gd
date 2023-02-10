class_name TranslationLoader
extends Object
## Load translations from files and directories.
##
## The script provides various methods for loading [Translation] resources from
## CSV and PO source files or directories containing those files. Since one
## load call can yield multple [Translation] resources, the results will not
## returned directly but emitted through the [signal loaded] signal instead.


## Emitted when a [Translation] resource has been loaded.
signal loaded(translation)

enum Type { UNKNOWN, CSV, PO }

const EXT_CSV := "csv"
const EXT_PO := "po"
const META_SOURCE_FILE := "source_file"
const META_SOURCE_TYPE := "source_type"


func load_all(paths: PoolStringArray) -> void:
	var dir := Directory.new()

	for path in paths:
		if dir.dir_exists(path):
			load_dir(path)
		elif dir.file_exists(path):
			load_file(path)


func load_file(path: String) -> int:
	match get_type(path):
		Type.CSV:
			return _load_file_csv(path)
		Type.PO:
			return _load_file_po(path)
		_:
			return ERR_FILE_UNRECOGNIZED


func load_files(paths: Array) -> void:
	for path in paths:
		if get_type(path) != Type.UNKNOWN:
			load_file(path)


func load_dir(path: String) -> void:
	var dir := Directory.new()

	if dir.open(path) != OK:
		printerr("could not open directory")
		return

	dir.list_dir_begin(true, true)

	var files := PoolStringArray()
	var file_name := dir.get_next()

	while not file_name.empty():
		if not dir.current_is_dir() and get_type(file_name) == Type.PO:
			files.append(path.plus_file(file_name))

		file_name = dir.get_next()

	dir.list_dir_end()

	load_files(files)


func get_type(path: String) -> int:
	match path.get_extension():
		EXT_CSV:
			return Type.CSV
		EXT_PO:
			return Type.PO
		_:
			return Type.UNKNOWN


func _load_file_csv(path: String) -> int:
	var file = File.new()

	var err: int = file.open(path, File.READ)

	if err != OK:
		return err

	var headers: PoolStringArray = file.get_csv_line()
	var resources := Array()

	# Create a Translation resource for each locale, skipping the first column
	# which contains the message ids.
	for i in range(1, headers.size()):
		var res = Translation.new()
		res.locale = headers[i].strip_edges()
		res.set_meta(META_SOURCE_FILE, path)
		res.set_meta(META_SOURCE_TYPE, Type.CSV)
		resources.append(res)

	# Iterate through remaining lines and columns and add messages to the
	# respective resources.
	while not file.eof_reached():
		var cols: PoolStringArray = file.get_csv_line()
		var msgid: String = cols[0].strip_edges()

		for i in range(1, cols.size()):
			var value := cols[i] as String
			if not value.empty():
				resources[i - 1].add_message(msgid, value)

	file.close()

	for res in resources:
		emit_signal("loaded", res)

	return OK


func _load_file_po(path: String) -> int:
	var res: Translation = ResourceLoader.load(path, "Translation")

	if not res:
		return ERR_FILE_UNRECOGNIZED

	res.set_meta(META_SOURCE_FILE, path)
	res.set_meta(META_SOURCE_TYPE, Type.PO)
	emit_signal("loaded", res)

	return OK

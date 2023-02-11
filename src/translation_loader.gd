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

enum Type { UNKNOWN, PO, TRANSLATION }

const EXT_PO := "po"
const EXT_TRANSLATION := "translation"
const META_SOURCE_FILE := "source_file"
const META_SOURCE_TYPE := "source_type"


## Load a resource as [Translation] from the given path. Returns OK if
## [code]path[/code] is a valid [Translation] resource and emits it via
## [signal]loaded[/signal]. Adds two metadata entries [const META_SOURCE_FILE]
## and [const META_SOURCE_TYPE].
func load_resource(path: String) -> int:
	var res: Translation = ResourceLoader.load(path, "Translation", true)

	if not res:
		return ERR_FILE_UNRECOGNIZED

	if not res is Translation:
		return ERR_INVALID_DATA

	var type := get_type(path)

	res.set_meta(META_SOURCE_FILE, path)
	res.set_meta(META_SOURCE_TYPE, type)

	emit_signal("loaded", res)

	return OK


## Load all given files and directories. Returns OK if at least one valid
## [Translation] resource was loaded.
func load_all(paths: PoolStringArray) -> int:
	var dir := Directory.new()
	var errors := PoolIntArray()

	for path in paths:
		var error := OK

		if dir.dir_exists(path):
			error = load_dir(path)
		elif dir.file_exists(path):
			error = load_file(path)

		errors.append(error)

	if not errors.has(OK):
		return ERR_CANT_RESOLVE

	return OK


## Load a single file. Returns OK if the file is a valid [Translation] resource.
func load_file(path: String) -> int:
	if get_type(path) == Type.UNKNOWN:
		return ERR_FILE_UNRECOGNIZED

	return load_resource(path)


## Load multiple files. Returns OK if at least one file is a valid [Translation]
## resource.
func load_files(paths: Array) -> int:
	var errors := PoolIntArray()

	for path in paths:
		var loaded := load_file(path)
		errors.append(loaded)

	if not errors.has(OK):
		return ERR_CANT_RESOLVE

	return OK


## Load all files in a directory. Returns OK if at least one valid [Translation]
## resource was loaded.
func load_dir(path: String) -> int:
	var dir := Directory.new()
	var error := dir.open(path)

	if error != OK:
		return error

	dir.list_dir_begin(true, true)

	var files := PoolStringArray()
	var file_name := dir.get_next()

	while not file_name.empty():
		if dir.current_is_dir():
			continue

		files.append(path.plus_file(file_name))
		file_name = dir.get_next()

	dir.list_dir_end()

	return load_files(files)


## Get the assumed [enum Type] of a file path based on the extension.
func get_type(path: String) -> int:
	match path.get_extension():
		EXT_PO:
			return Type.PO
		EXT_TRANSLATION:
			return Type.TRANSLATION
		_:
			return Type.UNKNOWN

class_name MessageLoader
extends Object

signal loaded(messages)


func load_file(path: String) -> int:
	var messages := PoolStringArray()

	var file := File.new()
	var error := file.open(path, File.READ)

	if error != OK:
		return error

	while file.get_position() < file.get_len():
		var line := file.get_line()

		if not line.begins_with("msgid"):
			continue

		var start := line.find("\"") + 1
		var end := line.find_last("\"") - start

		var message := line.substr(start, end)

		if not message.empty():
			messages.append(message)

	file.close()

	emit_signal("loaded", messages)

	return OK

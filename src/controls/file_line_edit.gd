class_name FileLineEdit
extends LineEdit
## Variation of the [LineEdit] control intendend for file paths.


const MENU_ID_FILE_OPEN := 1000
const MENU_ID_FILE_SHOW := 1001


func _ready() -> void:
	var menu := get_menu()

	menu.add_separator()

	menu.add_item("Open File", MENU_ID_FILE_OPEN)
	menu.set_item_icon(menu.get_item_index(MENU_ID_FILE_OPEN), get_icon("file_open"))

	menu.add_item("Show in File Manager", MENU_ID_FILE_SHOW)
	menu.set_item_icon(menu.get_item_index(MENU_ID_FILE_SHOW), get_icon("file_show"))

	menu.connect("about_to_show", self, "_on_file_menu_about_to_show")
	menu.connect("id_pressed", self, "_on_file_menu_id_pressed", [], CONNECT_DEFERRED)


## Check if the current [property text] is a file path.
func is_file() -> bool:
	return not text.get_file().empty()


func _on_file_menu_about_to_show() -> void:
	for id in [MENU_ID_FILE_OPEN, MENU_ID_FILE_SHOW]:
		var idx := get_menu().get_item_index(id)
		get_menu().set_item_disabled(idx, not is_file())


func _on_file_menu_id_pressed(id: int) -> void:
	if not id in [MENU_ID_FILE_OPEN, MENU_ID_FILE_SHOW]:
		return

	var file := get_text()

	if id == MENU_ID_FILE_SHOW:
		file = file.get_base_dir()

	if file.empty():
		return

	var path := ProjectSettings.globalize_path(file)

	OS.shell_open("file://" + path)

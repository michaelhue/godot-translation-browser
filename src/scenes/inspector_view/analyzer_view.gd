extends PanelContainer


const MessageView := preload("res://src/scenes/message_view/message_view.gd")

const META_LOCALE := "locale"
const META_MSGID := "msgid"

export var message_view_path: NodePath
export var manager_a_path: NodePath
export var manager_b_path: NodePath

var analyzer: Analyzer
var is_queued := false

var _spinner_wait := 0.0
var _spinner_index := 0
var _spinner_icons := [
	preload("res://src/ui/icons/Progress1.svg"),
	preload("res://src/ui/icons/Progress2.svg"),
	preload("res://src/ui/icons/Progress3.svg"),
	preload("res://src/ui/icons/Progress4.svg"),
	preload("res://src/ui/icons/Progress5.svg"),
	preload("res://src/ui/icons/Progress6.svg"),
	preload("res://src/ui/icons/Progress7.svg"),
	preload("res://src/ui/icons/Progress8.svg"),
]

onready var message_view := get_node(message_view_path) as MessageView
onready var manager_a := get_node(manager_a_path) as TranslationManager
onready var manager_b := get_node(manager_b_path) as TranslationManager

onready var tree := get_node("%Tree") as Tree
onready var progress_bar := get_node("%ProgressBar") as ProgressBar


func _ready() -> void:
	analyzer = Analyzer.new()
	analyzer.connect("progress", self, "_on_analyzer_progress")
	analyzer.connect("result", self, "_on_analyzer_result")

	AppState.watch(self, "_on_app_state_changed")

	manager_a.connect("updated", self, "_on_manager_updated")
	manager_b.connect("updated", self, "_on_manager_updated")
	message_view.state.connect("changed", self, "_on_message_state_changed")

	tree.set_column_expand(0, true)
	tree.set_column_expand(1, false)
	tree.set_column_min_width(1, 50)

	set_visible(false)
	progress_bar.set_visible(false)


func _exit_tree() -> void:
	analyzer.abort()


func _process(delta: float) -> void:
	var root := tree.get_root()
	_spinner_wait += delta

	if not root:
		return

	if not analyzer.is_working() or not root or _spinner_wait < 0:
		return

	root.set_icon(0, _spinner_icons[_spinner_index])

	_spinner_wait = -0.1
	_spinner_index += 1

	if _spinner_index >= _spinner_icons.size():
		_spinner_index = 0


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_released("ui_cancel"):
		AppState.set_show_analyzer(false)


func queue_run() -> void:
	if is_queued:
		return

	is_queued = true
	call_deferred("run")


func run() -> void:
	is_queued = false

	tree.clear()

	if analyzer.is_working():
		analyzer.abort()

	var root := tree.create_item()
	root.set_selectable(0, false)

	if not can_run():
		root.set_text(0, "Nothing to analyze, messages or translations missing")
		root.set_icon(0, tree.get_icon("status_warning"))
		return

	root.set_text(0, "Analyzing...")

	analyzer.start(
			message_view.state.messages,
			manager_a,
			manager_b,
			AppState.fallback_locale)

	progress_bar.set_visible(true)


func can_run() -> bool:
	return (
		message_view
		and not message_view.state.messages.empty()
		and manager_a
		and not manager_a.empty()
		and manager_b
		and not manager_b.empty()
	)


func _on_app_state_changed(property: String, _value, _old) -> void:
	match property:
		"show_analyzer":
			_on_show_analyzer_changed()
		"fallback_locale":
			queue_run()


func _on_manager_updated() -> void:
	queue_run()


func _on_message_state_changed(property: String, _value, _old) -> void:
	if property == "messages":
		queue_run()


func _on_analyzer_result(result: Analyzer.Result) -> void:
	if analyzer.is_working():
		return

	tree.clear()
	progress_bar.set_visible(false)

	var root := tree.create_item()
	root.set_selectable(0, false)

	if result == null:
		root.set_text(0, "Analysis failed")
		root.set_icon(0, tree.get_icon("status_error"))
		return

	if not result.finished:
		root.set_text(0, "Analysis was aborted")
		root.set_icon(0, tree.get_icon("status_warning"))
		return

	if result.errors == 0:
		root.set_text(0, "No issues found")
		root.set_icon(0, tree.get_icon("status_success"))
		root.set_collapsed(true)
	else:
		root.set_text(0, "Found issues with %d locale(s)" % result.errors)
		root.set_icon(0, tree.get_icon("status_warning"))

	for i in range(result.locales.size()):
		var locresult: Analyzer.LocaleResult = result.locales[i]

		var locitem := tree.create_item(root)
		locitem.set_collapsed(true)
		locitem.set_text_align(1, TreeItem.ALIGN_RIGHT)
		locitem.set_selectable(1, false)
		locitem.set_text(0, locresult.locale.to_upper())
		locitem.set_meta(META_LOCALE, locresult.locale)
		locitem.set_tooltip(0, TranslationServer.get_locale_name(locresult.locale))

		if locresult.errors == 0:
			locitem.set_icon(0, tree.get_icon("status_success"))
		else:
			locitem.set_icon(0, tree.get_icon("status_error"))
			locitem.set_text(1, String(locresult.errors))

		for msgid in locresult.messages:
			var msgitem := tree.create_item(locitem)
			msgitem.set_text(0, msgid)
			msgitem.set_meta(META_LOCALE, locresult.locale)
			msgitem.set_meta(META_MSGID, msgid)

		var remaining_errors := locresult.errors - locresult.messages.size()

		if remaining_errors > 0:
			var remitem := tree.create_item(locitem)
			remitem.set_text(0, "%d more..." % remaining_errors)
			remitem.set_selectable(0, false)


func _on_analyzer_progress(percent: float) -> void:
	progress_bar.set_value(percent)


func _on_show_analyzer_changed() -> void:
	set_visible(AppState.show_analyzer)

	if visible:
		tree.grab_focus()


func _on_item_selected() -> void:
	var item := tree.get_selected()

	if item.has_meta(META_LOCALE):
		AppState.set_locale(item.get_meta(META_LOCALE))

	if item.has_meta(META_MSGID):
		AppState.set_message_id(item.get_meta(META_MSGID))


func _on_item_rmb_selected(_position: Vector2) -> void:
	var item := tree.get_selected()

	if item:
		OS.set_clipboard(item.get_text(0))

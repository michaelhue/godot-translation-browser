extends PanelContainer


enum Filter { ALL, SHARED, A, B }

const META_LOCALE = "locale"

export var manager_a_path: NodePath
export var manager_b_path: NodePath

onready var state := get_node("%LocaleViewState") as LocaleViewState
onready var manager_a := get_node(manager_a_path) as TranslationManager
onready var manager_b := get_node(manager_b_path) as TranslationManager

onready var option_button := get_node("%OptionButton") as OptionButton
onready var tree := get_node("%Tree") as Tree
onready var stats_label := get_node("%StatsLabel") as Label


func _ready() -> void:
	AppState.notify(self, "_on_app_state_changed")

	manager_a.connect("updated", self, "_on_manager_update", [], CONNECT_DEFERRED)
	manager_b.connect("updated", self, "_on_manager_update", [], CONNECT_DEFERRED)

	tree.set_column_expand(1, false)
	tree.set_column_min_width(1, 28)


func select_locale(locale: String, force := false) -> void:
	if not tree.get_root():
		return

	var needs_switch := not state.active_locales.has(locale) \
			and state.locales.has(locale)

	if needs_switch and force:
		state.set_filter(Filter.ALL)
		yield(state, "changed")

	var item: TreeItem = tree.get_root().get_children()

	while item:
		if not item.has_meta(META_LOCALE):
			continue

		if item.get_meta(META_LOCALE) == locale:
			item.select(0)
			break

		item = item.get_next()

	tree.ensure_cursor_is_visible()


func _on_app_state_changed(property: String, value, _old) -> void:
	match property:
		"locale":
			select_locale(value, true)
		"fallback_locale":
			_update_items()


func _on_state_changed(property: String, value, _old) -> void:
	match property:
		"filter":
			option_button.select(value)
			_update_locales()
		"active_locales":
			_update_items()


func _update_locales() -> void:
	var a := manager_a.get_sorted_locales()
	var b := manager_b.get_sorted_locales()

	var combined := PoolStringArray()
	combined.append_array(a)
	combined.append_array(b)
	combined.sort()

	var all := PoolStringArray()
	var shared := PoolStringArray()

	for locale in combined:
		if not all.has(locale):
			all.append(locale)

		if  not shared.has(locale) and a.has(locale) and b.has(locale):
			shared.append(locale)

	var active := all

	match state.filter:
		Filter.SHARED:
			active = shared
		Filter.A:
			active = a
		Filter.B:
			active = b

	state.set_locales(all)
	state.set_active_locales(active)

	option_button.set_item_disabled(Filter.SHARED, shared.empty())
	option_button.set_item_disabled(Filter.A, a.empty())
	option_button.set_item_disabled(Filter.B, b.empty())

	if option_button.is_item_disabled(state.filter):
		state.set_filter(Filter.ALL)


func _update_items() -> void:
	tree.clear()

	var root := tree.create_item()

	for i in range(state.active_locales.size()):
		var locale := state.active_locales[i] as String
		var is_fallback := locale == AppState.fallback_locale

		var item := tree.create_item(root)
		item.set_meta(META_LOCALE, locale)

		item.set_text(0, locale.to_upper())
		item.set_tooltip(0, TranslationServer.get_locale_name(locale))

		item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		item.set_checked(1, is_fallback)
		item.set_editable(1, not is_fallback)
		item.set_tooltip(1, "Fallback locale" if is_fallback else "Set as fallback locale")

	stats_label.text = "%d locales" % state.active_locales.size()

	if state.active_locales.size() != state.locales.size():
		stats_label.text +=  " (%d total)" % state.locales.size()

	select_locale(AppState.locale)


func _on_manager_update() -> void:
	_update_locales()
	_update_items()


func _on_option_item_selected(index: int) -> void:
	state.set_filter(index)


func _on_item_selected() -> void:
	var item := tree.get_selected()

	if item and item.has_meta(META_LOCALE):
		AppState.set_locale(item.get_meta(META_LOCALE))


func _on_item_edited() -> void:
	var item := tree.get_edited()

	if not item or not item.has_meta(META_LOCALE):
		return

	AppState.set_fallback_locale(item.get_meta(META_LOCALE))


func _on_item_rmb_selected(_position: Vector2) -> void:
	var item := tree.get_selected()

	if item:
		OS.set_clipboard(item.get_text(0))

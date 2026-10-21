class_name SettingsPanel
extends CanvasLayer

# Pause menu and settings in one card. In "pause" mode it offers Resume and
# Home; from the main menu it just offers Done. Runs while the tree is paused.

signal settings_changed(music: float, sfx: float, muted: bool)
signal resume_requested
signal home_requested
signal name_changed(player_name: String)

var _card: Panel
var _title: Label
var _music_slider: HSlider
var _sfx_slider: HSlider
var _mute_toggle: Button
var _name_edit: LineEdit
var _primary_button: Button
var _home_button: Button
var _pause_mode := false
var _credits_button: Button
var _credits_layer: Control
var credits_text := ""
var version_log_text := ""
var _whats_new_button: Button
var _layer_title: Label
func _init() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Color(CuteStyle.INK, 0.5)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.theme = CuteStyle.make_theme()
	add_child(dim)

	_card = Panel.new()
	_card.add_theme_stylebox_override("panel", CuteStyle.box(CuteStyle.CREAM, 44, CuteStyle.WHITE, 6, 0.3))
	_card.set_anchors_preset(Control.PRESET_CENTER)
	_card.size = Vector2(560.0, 640.0)
	_card.position = -_card.size * 0.5
	dim.add_child(_card)

	_title = _add_label("PAUSED", Vector2(0.0, 36.0), Vector2(560.0, 70.0), 50, CuteStyle.ACCENT)
	_title.add_theme_color_override("font_outline_color", CuteStyle.WHITE)
	_title.add_theme_constant_override("outline_size", 10)

	_add_label("MUSIC", Vector2(60.0, 240.0), Vector2(440.0, 34.0), 24, CuteStyle.INK, HORIZONTAL_ALIGNMENT_LEFT)
	_music_slider = _add_slider(Vector2(60.0, 280.0))
	_add_label("SOUND EFFECTS", Vector2(60.0, 340.0), Vector2(440.0, 34.0), 24, CuteStyle.INK, HORIZONTAL_ALIGNMENT_LEFT)
	_sfx_slider = _add_slider(Vector2(60.0, 380.0))

	_add_label("YOUR NAME", Vector2(60.0, 120.0), Vector2(440.0, 34.0), 24, CuteStyle.INK, HORIZONTAL_ALIGNMENT_LEFT)
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "TAP TO TYPE"
	_name_edit.max_length = 12
	_name_edit.position = Vector2(60.0, 158.0)
	_name_edit.size = Vector2(440.0, 60.0)
	_name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_edit.add_theme_font_size_override("font_size", 26)
	_name_edit.add_theme_color_override("font_color", CuteStyle.INK)
	_name_edit.add_theme_color_override("font_placeholder_color", CuteStyle.INK_SOFT)
	_name_edit.add_theme_stylebox_override("normal", CuteStyle.box(CuteStyle.WHITE, 18, CuteStyle.SKY, 4))
	_name_edit.add_theme_stylebox_override("focus", CuteStyle.box(CuteStyle.WHITE, 18, CuteStyle.ACCENT, 4))
	_name_edit.text_submitted.connect(func(_t: String) -> void:
		_name_edit.release_focus()
		_emit_name()
	)
	_name_edit.focus_exited.connect(_emit_name)
	_card.add_child(_name_edit)

	# A big, easy-to-tap ON/OFF pill instead of the tiny default switch.
	var mute_label := _add_label("MUTE ALL", Vector2(60.0, 440.0), Vector2(240.0, 72.0), 26, CuteStyle.INK, HORIZONTAL_ALIGNMENT_LEFT)
	mute_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_mute_toggle = Button.new()
	_mute_toggle.name = "MuteToggle"
	_mute_toggle.toggle_mode = true
	_mute_toggle.position = Vector2(320.0, 440.0)
	_mute_toggle.size = Vector2(180.0, 72.0)
	_mute_toggle.add_theme_font_size_override("font_size", 30)
	_mute_toggle.toggled.connect(func(_on: bool) -> void:
		_refresh_mute_look()
		_emit_change()
	)
	_card.add_child(_mute_toggle)
	_refresh_mute_look()

	_primary_button = Button.new()
	_primary_button.position = Vector2(110.0, 548.0)
	_primary_button.size = Vector2(340.0, 84.0)
	_primary_button.add_theme_font_size_override("font_size", 30)
	CuteStyle.style_button(_primary_button, CuteStyle.MINT)
	_primary_button.pressed.connect(_on_primary_pressed)
	_card.add_child(_primary_button)

	_home_button = Button.new()
	_home_button.text = "HOME"
	_home_button.position = Vector2(150.0, 652.0)
	_home_button.size = Vector2(260.0, 70.0)
	_home_button.add_theme_font_size_override("font_size", 24)
	CuteStyle.style_button(_home_button, CuteStyle.LAVENDER)
	_home_button.pressed.connect(func() -> void:
		close()
		home_requested.emit()
	)
	_card.add_child(_home_button)

	_credits_button = Button.new()
	_credits_button.text = "CREDITS & LICENSES"
	_credits_button.flat = true
	_credits_button.add_theme_font_size_override("font_size", 18)
	_credits_button.add_theme_color_override("font_color", CuteStyle.INK_SOFT)
	_credits_button.add_theme_color_override("font_hover_color", CuteStyle.ACCENT)
	_credits_button.pressed.connect(_show_credits)
	_card.add_child(_credits_button)

	_whats_new_button = Button.new()
	_whats_new_button.text = "WHAT'S NEW"
	_whats_new_button.flat = true
	_whats_new_button.add_theme_font_size_override("font_size", 18)
	_whats_new_button.add_theme_color_override("font_color", CuteStyle.ACCENT)
	_whats_new_button.add_theme_color_override("font_hover_color", CuteStyle.INK)
	_whats_new_button.pressed.connect(_show_version_log)
	_card.add_child(_whats_new_button)

	# Full-screen scrolling credits (engine licence and asset attributions).
	_credits_layer = ColorRect.new()
	(_credits_layer as ColorRect).color = CuteStyle.CREAM
	_credits_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_credits_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	_credits_layer.hide()
	dim.add_child(_credits_layer)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 32.0
	scroll.offset_right = -32.0
	scroll.offset_top = 110.0
	scroll.offset_bottom = -130.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_credits_layer.add_child(scroll)
	var credits_label := Label.new()
	credits_label.name = "CreditsText"
	credits_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits_label.custom_minimum_size = Vector2(620.0, 0.0)
	credits_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CuteStyle.style_label(credits_label, CuteStyle.INK, 16)
	scroll.add_child(credits_label)
	var credits_title := Label.new()
	credits_title.text = "CREDITS"
	_layer_title = credits_title
	credits_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	credits_title.offset_top = 36.0
	credits_title.offset_bottom = 96.0
	CuteStyle.style_label(credits_title, CuteStyle.ACCENT, 44)
	_credits_layer.add_child(credits_title)
	var close_credits := Button.new()
	close_credits.text = "BACK"
	close_credits.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	close_credits.offset_left = -130.0
	close_credits.offset_right = 130.0
	close_credits.offset_top = -110.0
	close_credits.offset_bottom = -40.0
	close_credits.add_theme_font_size_override("font_size", 26)
	CuteStyle.style_button(close_credits, CuteStyle.LAVENDER)
	close_credits.pressed.connect(func() -> void: _credits_layer.hide())
	_credits_layer.add_child(close_credits)
func _add_label(text: String, pos: Vector2, label_size: Vector2, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = label_size
	label.horizontal_alignment = align
	CuteStyle.style_label(label, color, font_size)
	_card.add_child(label)
	return label


func _add_slider(pos: Vector2) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.position = pos
	slider.size = Vector2(440.0, 40.0)
	slider.add_theme_stylebox_override("slider", CuteStyle.box(Color("dfe7f3"), 12))
	slider.add_theme_stylebox_override("grabber_area", CuteStyle.box(CuteStyle.SKY, 12))
	slider.add_theme_stylebox_override("grabber_area_highlight", CuteStyle.box(CuteStyle.ACCENT, 12))
	slider.value_changed.connect(func(_value: float) -> void: _emit_change())
	_card.add_child(slider)
	return slider


func open(pause_mode: bool, music: float, sfx: float, muted: bool, player_name: String = "") -> void:
	_pause_mode = pause_mode
	_title.text = "PAUSED" if pause_mode else "SETTINGS"
	_primary_button.text = "RESUME" if pause_mode else "DONE"
	_home_button.visible = pause_mode
	var card_height := 820.0 if pause_mode else 720.0
	# Centre with offsets (relative to the centre anchor), not position.
	_card.offset_left = -280.0
	_card.offset_right = 280.0
	_card.offset_top = -card_height * 0.5
	_card.offset_bottom = card_height * 0.5
	_whats_new_button.position = Vector2(30.0, card_height - 66.0)
	_whats_new_button.size = Vector2(200.0, 44.0)
	_credits_button.position = Vector2(230.0, card_height - 66.0)
	_credits_button.size = Vector2(300.0, 44.0)
	_credits_layer.hide()
	# Set values without echoing change events back to the game.
	_music_slider.set_value_no_signal(music)
	_sfx_slider.set_value_no_signal(sfx)
	_mute_toggle.set_pressed_no_signal(muted)
	_refresh_mute_look()
	_name_edit.text = player_name
	visible = true
	CuteStyle.pop_in(_card)


func close() -> void:
	if visible:
		_emit_name()
	visible = false


func _on_primary_pressed() -> void:
	close()
	if _pause_mode:
		resume_requested.emit()


func _emit_change() -> void:
	settings_changed.emit(_music_slider.value, _sfx_slider.value, _mute_toggle.button_pressed)


func _refresh_mute_look() -> void:
	var muted := _mute_toggle.button_pressed
	_mute_toggle.text = "ON" if muted else "OFF"
	CuteStyle.style_button(_mute_toggle, CuteStyle.CORAL if muted else Color("b7c3d6"))


func _emit_name() -> void:
	name_changed.emit(_name_edit.text)


func _show_credits() -> void:
	_show_text_page("CREDITS", credits_text)


func _show_version_log() -> void:
	_show_text_page("WHAT'S NEW", version_log_text)


func _show_text_page(title: String, text: String) -> void:
	_layer_title.text = title
	(_credits_layer.find_child("CreditsText", true, false) as Label).text = text
	var scroll := _credits_layer.find_child("CreditsText", true, false).get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_vertical = 0
	_credits_layer.show()

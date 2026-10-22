class_name Tutorial
extends CanvasLayer

# A short paged "How to Play" guide. Pages are given by the game as
# {title, text, images: Array[Texture2D], extra: Callable -> Node2D/Control (optional)}.

signal closed

var pages: Array[Dictionary] = []
var _index := 0
var _card: Panel
var _title: Label
var _body: Label
var _art: HBoxContainer
var _extra_holder: Control
var _dots: Label
var _back_button: Button
var _next_button: Button


func _init() -> void:
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Color(CuteStyle.INK, 0.6)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.theme = CuteStyle.make_theme()
	add_child(dim)

	_card = Panel.new()
	_card.add_theme_stylebox_override("panel", CuteStyle.box(CuteStyle.CREAM, 44, CuteStyle.WHITE, 6, 0.3))
	_card.set_anchors_preset(Control.PRESET_CENTER)
	_card.offset_left = -300.0
	_card.offset_right = 300.0
	_card.offset_top = -430.0
	_card.offset_bottom = 430.0
	dim.add_child(_card)

	var skip := Button.new()
	skip.name = "SkipButton"
	skip.text = "SKIP"
	skip.flat = true
	skip.position = Vector2(470.0, 18.0)
	skip.size = Vector2(110.0, 48.0)
	skip.add_theme_font_size_override("font_size", 20)
	skip.add_theme_color_override("font_color", CuteStyle.INK_SOFT)
	skip.add_theme_color_override("font_hover_color", CuteStyle.ACCENT)
	skip.pressed.connect(close)
	_card.add_child(skip)

	_title = Label.new()
	_title.position = Vector2(20.0, 60.0)
	_title.size = Vector2(560.0, 70.0)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CuteStyle.style_label(_title, CuteStyle.ACCENT, 42, CuteStyle.WHITE, 10)
	_card.add_child(_title)

	_art = HBoxContainer.new()
	_art.position = Vector2(30.0, 150.0)
	_art.size = Vector2(540.0, 200.0)
	_art.alignment = BoxContainer.ALIGNMENT_CENTER
	_art.add_theme_constant_override("separation", 18)
	_card.add_child(_art)

	_extra_holder = Control.new()
	_extra_holder.position = Vector2(300.0, 250.0)
	_extra_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(_extra_holder)

	_body = Label.new()
	_body.position = Vector2(44.0, 380.0)
	_body.size = Vector2(512.0, 300.0)
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CuteStyle.style_label(_body, CuteStyle.INK, 27)
	_card.add_child(_body)

	_dots = Label.new()
	_dots.position = Vector2(20.0, 690.0)
	_dots.size = Vector2(560.0, 40.0)
	_dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CuteStyle.style_label(_dots, CuteStyle.SKY, 26)
	_card.add_child(_dots)

	_back_button = Button.new()
	_back_button.text = "BACK"
	_back_button.position = Vector2(40.0, 750.0)
	_back_button.size = Vector2(220.0, 80.0)
	_back_button.add_theme_font_size_override("font_size", 28)
	CuteStyle.style_button(_back_button, CuteStyle.LAVENDER)
	_back_button.pressed.connect(func() -> void: show_page(_index - 1))
	_card.add_child(_back_button)

	_next_button = Button.new()
	_next_button.name = "NextButton"
	_next_button.position = Vector2(340.0, 750.0)
	_next_button.size = Vector2(220.0, 80.0)
	_next_button.add_theme_font_size_override("font_size", 28)
	CuteStyle.style_button(_next_button, CuteStyle.MINT)
	_next_button.pressed.connect(func() -> void:
		if _index >= pages.size() - 1:
			close()
		else:
			show_page(_index + 1)
	)
	_card.add_child(_next_button)


func open() -> void:
	visible = true
	show_page(0)
	CuteStyle.pop_in(_card)


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func current_page() -> int:
	return _index


func show_page(index: int) -> void:
	if pages.is_empty():
		return
	_index = clampi(index, 0, pages.size() - 1)
	var page := pages[_index]
	_title.text = str(page.get("title", ""))
	_body.text = str(page.get("text", ""))
	for child in _art.get_children():
		child.queue_free()
	for child in _extra_holder.get_children():
		child.queue_free()
	var images: Array = page.get("images", [])
	var image_size := 170.0 if images.size() <= 2 else 112.0
	for texture in images:
		var picture := TextureRect.new()
		picture.texture = texture
		picture.custom_minimum_size = Vector2(image_size, image_size)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_art.add_child(picture)
	var extra = page.get("extra", null)
	if extra is Callable and (extra as Callable).is_valid():
		var made = (extra as Callable).call()
		if made is Node:
			_extra_holder.add_child(made)
	var dot_text := ""
	for i in range(pages.size()):
		dot_text += ("●" if i == _index else "○") + ("  " if i < pages.size() - 1 else "")
	_dots.text = dot_text
	_back_button.visible = _index > 0
	_next_button.text = "LET'S GO!" if _index == pages.size() - 1 else "NEXT"

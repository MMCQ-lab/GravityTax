class_name PlaceholderAd
extends CanvasLayer

# Stand-in for a real ad network. A white full-screen card that says "AD" with a
# close button that counts down before it can be tapped. When an ad SDK is
# added later, only this class needs to change: callers just wait for `closed`.

signal closed

var countdown_seconds := 5.0
var _remaining := 0.0
var _close_button: Button
var _finished := false


func _init(seconds: float = 5.0) -> void:
	countdown_seconds = seconds
	layer = 200
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color.WHITE
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.theme = CuteStyle.make_theme()
	add_child(backdrop)

	var ad_label := Label.new()
	ad_label.text = "AD"
	ad_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ad_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ad_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	CuteStyle.style_label(ad_label, Color("b8b8c4"), 120)
	backdrop.add_child(ad_label)

	var caption := Label.new()
	caption.text = "placeholder"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
	caption.offset_top = 80.0
	caption.offset_bottom = 120.0
	CuteStyle.style_label(caption, Color("cfcfd8"), 24)
	backdrop.add_child(caption)

	_close_button = Button.new()
	_close_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_close_button.offset_left = -104.0
	_close_button.offset_right = -28.0
	_close_button.offset_top = 52.0
	_close_button.offset_bottom = 128.0
	_close_button.add_theme_font_size_override("font_size", 30)
	var idle := CuteStyle.box(Color("eeeef3"), 38, Color("d7d7e0"), 3)
	var ready := CuteStyle.box(Color("ffffff"), 38, Color("9a9aa8"), 4)
	_close_button.add_theme_stylebox_override("disabled", idle)
	_close_button.add_theme_stylebox_override("normal", ready)
	_close_button.add_theme_stylebox_override("hover", ready)
	_close_button.add_theme_stylebox_override("pressed", idle)
	_close_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_close_button.add_theme_color_override("font_disabled_color", Color("a6a6b2"))
	_close_button.add_theme_color_override("font_color", Color("55556a"))
	_close_button.add_theme_color_override("font_hover_color", Color("33334a"))
	_close_button.add_theme_color_override("font_pressed_color", Color("33334a"))
	_close_button.disabled = true
	_close_button.pressed.connect(_close)
	backdrop.add_child(_close_button)

	_remaining = countdown_seconds
	_refresh_button()


func _process(delta: float) -> void:
	if _remaining <= 0.0:
		return
	_remaining = maxf(0.0, _remaining - delta)
	_refresh_button()


func _refresh_button() -> void:
	if _remaining > 0.0:
		_close_button.text = str(ceili(_remaining))
		_close_button.disabled = true
	else:
		_close_button.text = "X"
		_close_button.disabled = false


func _close() -> void:
	if _finished or _remaining > 0.0:
		return
	_finished = true
	closed.emit()
	queue_free()

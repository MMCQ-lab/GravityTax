class_name PrizeWheel
extends CanvasLayer

# Post-death lucky spin. Every slice pays coins; one thin slice also revives.
# Slice widths match their real odds, so what the player sees is what they get.

signal finished(coins: int, revive: bool)
signal spin_started
signal landed(revive: bool)
const SLICES := [
	{"label": "5", "coins": 5, "weight": 22.0, "color": Color("c7e6ff")},
	{"label": "10", "coins": 10, "weight": 22.0, "color": Color("bdeedd")},
	{"label": "15", "coins": 15, "weight": 18.0, "color": Color("d9d4ff")},
	{"label": "25", "coins": 25, "weight": 14.0, "color": Color("ffe6a1")},
	{"label": "50", "coins": 50, "weight": 8.0, "color": Color("b9f0e8")},
	{"label": "100", "coins": 100, "weight": 4.0, "color": Color("ffd2b0")},
	{"label": "REVIVE", "coins": 10, "weight": 5.0, "color": Color("3a8dff"), "revive": true},
]

var allow_revive := true
var _slices: Array = []
var _wheel: Control
var _spin_button: Button
var _result_label: Label
var _title: Label
var _spinning := false
var _done := false
var _result_index := -1


func _init(can_revive: bool = true) -> void:
	allow_revive = can_revive
	layer = 150
	for slice in SLICES:
		if slice.get("revive", false) and not allow_revive:
			continue
		_slices.append(slice)


func _ready() -> void:
	var dim := ColorRect.new()
	dim.color = Color(CuteStyle.INK, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.theme = CuteStyle.make_theme()
	add_child(dim)

	var card := Panel.new()
	card.add_theme_stylebox_override("panel", CuteStyle.box(CuteStyle.CREAM, 44, CuteStyle.WHITE, 6, 0.3))
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.size = Vector2(600.0, 860.0)
	card.position = -card.size * 0.5
	dim.add_child(card)

	_title = Label.new()
	_title.text = "LUCKY SPIN!"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.position = Vector2(0.0, 34.0)
	_title.size = Vector2(card.size.x, 70.0)
	CuteStyle.style_label(_title, CuteStyle.ACCENT, 54, CuteStyle.WHITE, 10)
	card.add_child(_title)

	var subtitle := Label.new()
	subtitle.text = "Every spin wins coins!"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(0.0, 104.0)
	subtitle.size = Vector2(card.size.x, 36.0)
	CuteStyle.style_label(subtitle, CuteStyle.INK_SOFT, 24)
	card.add_child(subtitle)

	var wheel_size := 460.0
	var wheel_holder := Control.new()
	wheel_holder.position = Vector2((card.size.x - wheel_size) * 0.5, 160.0)
	wheel_holder.size = Vector2(wheel_size, wheel_size)
	wheel_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(wheel_holder)

	_wheel = Control.new()
	_wheel.size = wheel_holder.size
	_wheel.pivot_offset = wheel_holder.size * 0.5
	_wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wheel.draw.connect(_draw_wheel)
	wheel_holder.add_child(_wheel)

	var pointer := Control.new()
	pointer.size = wheel_holder.size
	pointer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pointer.draw.connect(_draw_pointer.bind(pointer))
	wheel_holder.add_child(pointer)

	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.position = Vector2(0.0, 640.0)
	_result_label.size = Vector2(card.size.x, 60.0)
	CuteStyle.style_label(_result_label, CuteStyle.INK, 38)
	card.add_child(_result_label)

	_spin_button = Button.new()
	_spin_button.text = "SPIN!"
	_spin_button.position = Vector2((card.size.x - 320.0) * 0.5, 720.0)
	_spin_button.size = Vector2(320.0, 96.0)
	_spin_button.add_theme_font_size_override("font_size", 38)
	CuteStyle.style_button(_spin_button, CuteStyle.ACCENT)
	_spin_button.pressed.connect(_on_button_pressed)
	card.add_child(_spin_button)

	CuteStyle.pop_in(card)
	_wheel.rotation = randf() * TAU


func _process(delta: float) -> void:
	if not _spinning and not _done:
		# Idle drift makes it feel alive before the player taps.
		_wheel.rotation += delta * 0.6


func _total_weight() -> float:
	var total := 0.0
	for slice in _slices:
		total += float(slice["weight"])
	return total


func _slice_span(index: int) -> Vector2:
	# Start and end angle (radians, wheel-local) of slice `index`.
	var total := _total_weight()
	var start := 0.0
	for i in range(index):
		start += float(_slices[i]["weight"]) / total * TAU
	return Vector2(start, start + float(_slices[index]["weight"]) / total * TAU)


func _pick_index() -> int:
	var roll := randf() * _total_weight()
	for i in range(_slices.size()):
		roll -= float(_slices[i]["weight"])
		if roll <= 0.0:
			return i
	return _slices.size() - 1


func _on_button_pressed() -> void:
	if _done:
		var slice: Dictionary = _slices[_result_index]
		finished.emit(int(slice["coins"]), bool(slice.get("revive", false)))
		queue_free()
		return
	if _spinning:
		return
	_spinning = true
	_spin_button.disabled = true
	_result_index = _pick_index()
	var span := _slice_span(_result_index)
	# Land somewhere inside the slice, not always dead centre.
	var landing := lerpf(span.x, span.y, randf_range(0.2, 0.8))
	var target := -PI * 0.5 - landing
	var current := _wheel.rotation
	while target > current - TAU * 5.0:
		target -= TAU
	spin_started.emit()
	# 2.5 s matches the length of the slowing-down click sound.
	var tween := create_tween()
	tween.tween_property(_wheel, "rotation", target, 2.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_show_result)


func _show_result() -> void:
	_spinning = false
	_done = true
	var slice: Dictionary = _slices[_result_index]
	var revive := bool(slice.get("revive", false))
	landed.emit(revive)
	if revive:
		_result_label.text = "REVIVED!  +%d COINS" % int(slice["coins"])
		_result_label.add_theme_color_override("font_color", CuteStyle.ACCENT)
		_spin_button.text = "KEEP GOING!"
	else:
		_result_label.text = "+%d COINS!" % int(slice["coins"])
		_spin_button.text = "YAY!"
	_spin_button.disabled = false
	CuteStyle.style_button(_spin_button, CuteStyle.MINT if not revive else CuteStyle.ACCENT)
	CuteStyle.pop_in(_result_label)


func _draw_wheel() -> void:
	var center := _wheel.size * 0.5
	var radius := _wheel.size.x * 0.5 - 10.0
	var font := CuteStyle.font()
	_wheel.draw_circle(center, radius + 10.0, CuteStyle.WHITE)
	for i in range(_slices.size()):
		var slice: Dictionary = _slices[i]
		var span := _slice_span(i)
		var points := PackedVector2Array([center])
		var steps := maxi(6, int((span.y - span.x) / TAU * 96.0))
		for step in range(steps + 1):
			var angle := lerpf(span.x, span.y, float(step) / float(steps))
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		_wheel.draw_colored_polygon(points, slice["color"])
		_wheel.draw_line(center, center + Vector2(cos(span.x), sin(span.x)) * radius, CuteStyle.WHITE, 4.0, true)
		# Rotated label along the slice's middle.
		var mid := (span.x + span.y) * 0.5
		var is_revive := bool(slice.get("revive", false))
		var text := str(slice["label"])
		var font_size := 22 if is_revive else 34
		var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		_wheel.draw_set_transform(center + Vector2(cos(mid), sin(mid)) * radius * 0.62, mid, Vector2.ONE)
		var text_color := CuteStyle.WHITE if is_revive else CuteStyle.INK
		_wheel.draw_string(font, Vector2(-text_width * 0.5, font_size * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
		_wheel.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_wheel.draw_arc(center, radius, 0.0, TAU, 96, CuteStyle.WHITE, 8.0, true)
	# Little candy lights around the rim.
	for light in range(16):
		var angle := TAU * float(light) / 16.0
		_wheel.draw_circle(center + Vector2(cos(angle), sin(angle)) * (radius + 1.0), 6.0, CuteStyle.BUTTER if light % 2 == 0 else CuteStyle.CORAL)
	_wheel.draw_circle(center, 44.0, CuteStyle.WHITE)
	_wheel.draw_circle(center, 34.0, CuteStyle.CORAL)
	_wheel.draw_circle(center + Vector2(-10.0, -10.0), 9.0, Color(1, 1, 1, 0.75))


func _draw_pointer(pointer: Control) -> void:
	var top := Vector2(pointer.size.x * 0.5, 6.0)
	var tri := PackedVector2Array([top + Vector2(-26.0, -22.0), top + Vector2(26.0, -22.0), top + Vector2(0.0, 30.0)])
	var outline := PackedVector2Array([top + Vector2(-34.0, -28.0), top + Vector2(34.0, -28.0), top + Vector2(0.0, 40.0)])
	pointer.draw_colored_polygon(outline, CuteStyle.WHITE)
	pointer.draw_colored_polygon(tri, CuteStyle.ACCENT)

class_name PlaceholderBanner
extends CanvasLayer

# Stand-in for a real banner ad. A white strip pinned to the bottom of the
# screen that says "AD". Shown on menus only, never over active gameplay.
# When an ad SDK is added, swap the contents of this class for the SDK banner.

const HEIGHT := 100.0

var _strip: Panel
func _init() -> void:
	layer = 50


func _ready() -> void:
	var strip := Panel.new()
	_strip = strip
	strip.name = "BannerStrip"
	strip.mouse_filter = Control.MOUSE_FILTER_STOP
	strip.anchor_left = 0.0
	strip.anchor_right = 1.0
	strip.anchor_top = 1.0
	strip.anchor_bottom = 1.0
	strip.offset_top = -HEIGHT
	strip.offset_bottom = 0.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color("d7dbe3")
	style.border_width_top = 2
	strip.add_theme_stylebox_override("panel", style)
	strip.theme = CuteStyle.make_theme()
	add_child(strip)

	var label := Label.new()
	label.text = "AD"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	CuteStyle.style_label(label, Color("b8bcc8"), 40)
	strip.add_child(label)

	var tag := Label.new()
	tag.text = "banner placeholder"
	tag.position = Vector2(12.0, 6.0)
	CuteStyle.style_label(tag, Color("c8ccd6"), 14)
	strip.add_child(tag)


func set_bottom_inset(inset: float) -> void:
	# Grow the white strip under the home indicator so the "AD" stays visible.
	if _strip:
		_strip.offset_top = -(HEIGHT + inset)

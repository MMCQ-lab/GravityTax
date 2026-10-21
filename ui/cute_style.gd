class_name CuteStyle
extends RefCounted

# Shared pastel palette and style helpers for every menu, popup and HUD element.
# Keeping them in one place means the whole game can be re-skinned from here.

const INK := Color("2f3d5c")          # soft navy used instead of black text
const INK_SOFT := Color("66789a")
const CREAM := Color("fbfdff")
const CORAL := Color("ff8a65")
const ACCENT := Color("3a8dff")
const MINT := Color("3fd3b0")
const LAVENDER := Color("9b8cff")
const BUTTER := Color("ffd76a")
const SKY := Color("5fbfff")
const PEACH := Color("ffa257")
const WHITE := Color(1.0, 1.0, 1.0, 1.0)

const OPTIONAL_FONT_PATH := "res://fonts/cute.ttf"

# Rarity colours used everywhere a tier is shown.
const RARITY_COLORS := {
	"COMMON": Color("9aa3b2"),
	"UNCOMMON": Color("43c463"),
	"RARE": Color("3a8dff"),
	"EPIC": Color("9b5cff"),
	"LEGENDARY": Color("f5b821"),
}
static var _font: Font = null


static func font() -> Font:
	# Drop any rounded .ttf at res://fonts/cute.ttf to use it everywhere.
	# Otherwise ask the OS for a rounded face (iOS ships Arial Rounded MT Bold)
	# and fall back to Godot's built-in font, which keeps web builds working.
	if _font:
		return _font
	if ResourceLoader.exists(OPTIONAL_FONT_PATH):
		_font = load(OPTIONAL_FONT_PATH) as Font
	if _font == null:
		var system_font := SystemFont.new()
		system_font.font_names = PackedStringArray(["Arial Rounded MT Bold", "SF Pro Rounded", "Nunito", "Varela Round", "Quicksand"])
		system_font.font_weight = 700
		_font = system_font
	return _font


static func make_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = font()
	theme.default_font_size = 24
	return theme


static func box(bg: Color, radius: int = 28, border: Color = Color(1, 1, 1, 0), border_width: int = 0, shadow_alpha: float = 0.0, bottom_extra: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(radius)
	style.corner_detail = 10
	style.anti_aliasing = true
	if border_width > 0:
		style.border_color = border
		style.set_border_width_all(border_width)
		style.border_width_bottom = border_width + bottom_extra
	if shadow_alpha > 0.0:
		style.shadow_color = Color(INK, shadow_alpha)
		style.shadow_size = 8
		style.shadow_offset = Vector2(0.0, 6.0)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


static func style_button(button: BaseButton, color: Color, text_color: Color = WHITE, selected_look_when_disabled: bool = false) -> void:
	# Bubbly "gummy" buttons: rounded, a darker bottom lip and a soft drop shadow.
	var lip := color.darkened(0.22)
	var normal := box(color, 30, lip, 3, 0.28, 4)
	var hover := box(color.lightened(0.12), 30, lip, 3, 0.32, 4)
	var pressed := box(color.darkened(0.06), 30, lip, 3, 0.12, 1)
	var disabled: StyleBoxFlat
	if selected_look_when_disabled:
		# Tabs use "disabled" to mean "currently selected", so make it the loudest state.
		disabled = box(color.lightened(0.05), 30, WHITE, 4, 0.30, 3)
	else:
		disabled = box(color.lerp(Color("d3dbe6"), 0.6), 30, Color("c3ccd9"), 3, 0.0, 2)
	var focus := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	button.add_theme_color_override("font_hover_pressed_color", text_color)
	button.add_theme_color_override("font_focus_color", text_color)
	button.add_theme_color_override("font_disabled_color", text_color if selected_look_when_disabled else Color(text_color, 0.55))
	button.add_theme_color_override("font_outline_color", lip.darkened(0.15))
	button.add_theme_constant_override("outline_size", 8 if text_color == WHITE else 0)
	add_squish(button)


static func style_tab(button: BaseButton, color: Color) -> void:
	# Unselected tabs are quiet cream pills; the selected tab is the colourful one.
	style_button(button, color, WHITE, true)
	var idle := box(Color(WHITE, 0.85), 30, Color(color, 0.7), 3, 0.15, 3)
	var idle_hover := box(WHITE, 30, color, 3, 0.2, 3)
	button.add_theme_stylebox_override("normal", idle)
	button.add_theme_stylebox_override("hover", idle_hover)
	button.add_theme_color_override("font_color", color.darkened(0.25))
	button.add_theme_color_override("font_hover_color", color.darkened(0.3))
	button.add_theme_constant_override("outline_size", 0)


static func add_squish(control: Control) -> void:
	# A quick jelly squash on press and a springy rebound on release.
	if control.has_meta("cute_squish"):
		return
	control.set_meta("cute_squish", true)
	control.resized.connect(func() -> void: control.pivot_offset = control.size * 0.5)
	control.pivot_offset = control.size * 0.5
	if control is BaseButton:
		var button := control as BaseButton
		button.button_down.connect(func() -> void:
			var tween := button.create_tween()
			tween.tween_property(button, "scale", Vector2(1.08, 0.9), 0.07)
		)
		button.button_up.connect(func() -> void:
			var tween := button.create_tween()
			tween.tween_property(button, "scale", Vector2(0.96, 1.05), 0.08)
			tween.tween_property(button, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		)


static func style_label(label: Label, color: Color = INK, size: int = -1, outline: Color = Color(1, 1, 1, 0), outline_size: int = 0) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	if outline_size > 0:
		label.add_theme_color_override("font_outline_color", outline)
		label.add_theme_constant_override("outline_size", outline_size)
	else:
		label.add_theme_constant_override("outline_size", 0)
	if size > 0:
		label.add_theme_font_size_override("font_size", size)


static func pill_label(label: Label, bg: Color, text_color: Color = INK) -> void:
	# HUD counters sit on little rounded candy pills so they stay readable.
	style_label(label, text_color)
	var pill := box(bg, 24, Color(WHITE, 0.9), 3, 0.18, 0)
	pill.content_margin_left = 16.0
	pill.content_margin_right = 16.0
	pill.content_margin_top = 2.0
	pill.content_margin_bottom = 2.0
	label.add_theme_stylebox_override("normal", pill)


static func round_panel(rect: ColorRect, bg: Color, border: Color = WHITE, border_width: int = 4, radius: int = 32) -> Panel:
	# ColorRect cannot have rounded corners, so hide its fill and slip a rounded
	# Panel behind its children. Existing node paths and scripts keep working.
	var existing := rect.get_node_or_null("CuteBackground") as Panel
	var panel := existing if existing else Panel.new()
	panel.name = "CuteBackground"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", box(bg, radius, border, border_width, 0.22, 0))
	if not existing:
		rect.add_child(panel)
		rect.move_child(panel, 0)
	rect.color = Color(0, 0, 0, 0)
	return panel


static func gradient_backdrop(rect: ColorRect, top: Color, bottom: Color) -> TextureRect:
	# Full-screen pastel gradient behind a screen's children.
	var existing := rect.get_node_or_null("CuteGradient") as TextureRect
	var texture_rect := existing if existing else TextureRect.new()
	texture_rect.name = "CuteGradient"
	var gradient := Gradient.new()
	gradient.set_color(0, top)
	gradient.set_color(1, bottom)
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill_from = Vector2(0.5, 0.0)
	gradient_texture.fill_to = Vector2(0.5, 1.0)
	gradient_texture.width = 8
	gradient_texture.height = 256
	texture_rect.texture = gradient_texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not existing:
		rect.add_child(texture_rect)
		rect.move_child(texture_rect, 0)
	rect.color = Color(0, 0, 0, 0)
	return texture_rect


static func pop_in(control: Control, delay: float = 0.0) -> void:
	# Bouncy entrance used when a panel or popup appears.
	control.pivot_offset = control.size * 0.5
	control.scale = Vector2(0.6, 0.6)
	control.modulate.a = 0.0
	var tween := control.create_tween()
	tween.tween_interval(delay)
	tween.set_parallel(true)
	tween.tween_property(control, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "modulate:a", 1.0, 0.2)


static func rarity_color(tier: String) -> Color:
	return RARITY_COLORS.get(tier.to_upper(), RARITY_COLORS["COMMON"])


extends Node2D

@onready var block: ColorRect = $Block
@onready var floor_rect: ColorRect = $Floor

# Movement settings
var gravity: float = 500.0
var velocity: float = 0.0
var jump_strength: float = -350.0

# Animation settings
var flip_tween: Tween
var jelly_tween: Tween
var straighten_tween: Tween

var was_on_floor: bool = false


func _ready() -> void:
	randomize()

	# Position floor at bottom of phone screen
	var screen_size = get_viewport_rect().size
	floor_rect.position = Vector2(
		0, screen_size.y - 100
	)
	floor_rect.size = Vector2(screen_size.x, 100)

	# Rotate and squash around the block's center
	block.pivot_offset = block.size / 2.0

	# Begin with the block upright
	block.rotation = 0.0
	block.scale = Vector2.ONE


func _process(delta: float) -> void:
	# Apply gravity
	velocity += gravity * delta
	block.position.y += velocity * delta

	var floor_top = floor_rect.position.y
	var block_bottom = block.position.y + block.size.y
	var on_floor = false

	# Floor collision
	if block_bottom >= floor_top and velocity >= 0.0:
		block.position.y = floor_top - block.size.y
		velocity = 0.0
		on_floor = true

	# Play landing animation once
	if on_floor and not was_on_floor:
		land()

	was_on_floor = on_floor

	# Ceiling collision
	if block.position.y < 0.0:
		block.position.y = 0.0
		velocity = 0.0


func _input(event: InputEvent) -> void:
	# Mouse click on Windows
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			jump()

	# Touchscreen tap on iPhone
	elif event is InputEventScreenTouch:
		if event.pressed:
			jump()


func jump() -> void:
	velocity = jump_strength
	was_on_floor = false

	# Stop existing animations
	if flip_tween and flip_tween.is_running():
		flip_tween.kill()

	if jelly_tween and jelly_tween.is_running():
		jelly_tween.kill()

	if straighten_tween and straighten_tween.is_running():
		straighten_tween.kill()

	# Random clockwise or counterclockwise spin
	var direction: int = [-1, 1].pick_random()
	var spin_amount: float = randf_range(0.8, 1.3) * TAU

	flip_tween = create_tween()
	flip_tween.tween_property(
		block,
		"rotation",
		block.rotation + spin_amount * direction,
		0.55
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Extreme jelly animation
	jelly_tween = create_tween()

	# Stretch upward
	jelly_tween.tween_property(
		block,
		"scale",
		Vector2(0.55, 1.65),
		0.12
	)

	# Squash sideways
	jelly_tween.tween_property(
		block,
		"scale",
		Vector2(1.45, 0.65),
		0.15
	)

	# Elastic recovery
	jelly_tween.tween_property(
		block,
		"scale",
		Vector2.ONE,
		0.45
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func land() -> void:
	# Stop spinning and stretching
	if flip_tween and flip_tween.is_running():
		flip_tween.kill()

	if jelly_tween and jelly_tween.is_running():
		jelly_tween.kill()

	if straighten_tween and straighten_tween.is_running():
		straighten_tween.kill()

	# Return to upright rotation
	straighten_tween = create_tween()
	straighten_tween.tween_property(
		block,
		"rotation",
		round(block.rotation / TAU) * TAU,
		0.15
	).set_trans(Tween.TRANS_SINE)

	# Squash on landing
	jelly_tween = create_tween()

	jelly_tween.tween_property(
		block,
		"scale",
		Vector2(1.65, 0.50),
		0.10
	)

	# Spring back to normal shape
	jelly_tween.tween_property(
		block,
		"scale",
		Vector2.ONE,
		0.50
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

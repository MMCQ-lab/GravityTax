
extends Node2D

const PURPLE_ORB_TEXTURE := preload("res://images/purple_swing_orb.png")
const BAT_TEXTURE := preload("res://images/chase_bat.png")
const ROCKET_TEXTURE := preload("res://images/rocket_powerup.png")
const TELEPORT_TEXTURE := preload("res://images/teleport_powerup.png")
const MAGNET_TEXTURE := preload("res://images/magnet_powerup.png")
const KNIFE_TEXTURE := preload("res://images/knife_powerup.png")
const SCORE_SAVE_PATH := "user://gravity_tax_scores.cfg"

@onready var block: ColorRect = $Block
@onready var floor_rect: ColorRect = $Floor
@onready var camera: Camera2D = $Camera2D
@onready var swing_anchors: Node2D = $SwingAnchors
@onready var coin_counter: Label = $HUD/CoinCounter
@onready var high_score_label: Label = $HUD/HighScore
@onready var bats: Node2D = $Bats
@onready var power_ups: Node2D = $PowerUps
@onready var blade_orbit: Node2D = $BladeOrbit
@onready var game_over_screen: ColorRect = $HUD/GameOverScreen
@onready var game_over_best_label: Label = $HUD/GameOverScreen/GameOverBest
@onready var restart_button: Button = $HUD/GameOverScreen/RestartButton
@onready var power_message: Label = $HUD/PowerMessage
@onready var kill_counter: Label = $HUD/KillCounter
@onready var start_screen: ColorRect = $HUD/StartScreen
@onready var start_button: Button = $HUD/StartScreen/StartButton
@onready var menu_best_label: Label = $HUD/StartScreen/MenuBest
@onready var game_over_run_label: Label = $HUD/GameOverScreen/GameOverRun

# World dimensions are intentionally much larger than the phone viewport.
var map_width: float = 12000.0
var floor_y: float = 9000.0
var sky_top_color := Color("4bb5f2")
var sky_bottom_color := Color("dff8ff")
var anchor_count := 320
var coin_count := 180
var coin_positions: Array[Vector2] = []
var big_coin_count := 34
var big_coin_positions: Array[Vector2] = []
var coins_collected := 0
var high_score := 0
var bat_count := 28
var bat_chase_speed := 540.0
var bat_wake_radius := 120.0
var bat_attack_radius := 48.0
var bat_arm_delay := 0.18
var rocket_count := 16
var teleport_count := 12
var magnet_count := 12
var knife_count := 10
var world_elapsed := 0.0
var game_over := false
var game_started := false
var power_message_time := 0.0
var magnet_time := 0.0
var knife_time := 0.0
var knife_angle := 0.0
var bat_kills := 0
var orbiting_knives: Array[Sprite2D] = []
var previous_player_center := Vector2.ZERO

# Movement settings
var gravity: float = 500.0
var velocity: Vector2 = Vector2.ZERO
var launch_speed: float = 460.0
var floor_bounce: float = 0.46
var wall_bounce: float = 0.36
var minimum_bounce_speed: float = 75.0

# Swing settings
var is_swinging := false
var swing_anchor: Sprite2D
var swing_rope_length := 0.0
var swing_boost_per_second := 110.0
var is_pointer_held := false
var hold_elapsed := 0.0
var swing_attempted := false
var swing_hold_delay := 0.5

# Animation settings
var flip_tween: Tween
var jelly_tween: Tween
var straighten_tween: Tween

var was_on_floor: bool = false


func _ready() -> void:
	randomize()

	# Place the floor deep within the larger world.
	floor_rect.position = Vector2(0, floor_y)
	floor_rect.size = Vector2(map_width, 120)

	# Rotate and squash around the block's center
	block.pivot_offset = block.size / 2.0

	# Begin with the block upright
	block.rotation = 0.0
	block.scale = Vector2.ONE
	populate_world()
	update_coin_counter()
	load_high_score()
	update_high_score_label()
	game_over_screen.hide()
	start_screen.show()
	$HUD.get_node("CoinCounter").hide()
	$HUD.get_node("HighScore").hide()
	$HUD.get_node("KillCounter").hide()
	power_message.hide()
	setup_orbiting_knives()
	update_kill_counter()
	previous_player_center = get_player_center()
	restart_button.pressed.connect(restart_game)
	start_button.pressed.connect(start_game)


func _physics_process(delta: float) -> void:
	queue_redraw()
	if not game_started:
		return
	if power_message_time > 0.0:
		power_message_time -= delta
		if power_message_time <= 0.0:
			power_message.hide()
	if game_over:
		return
	if magnet_time > 0.0:
		magnet_time -= delta
	if knife_time > 0.0:
		knife_time -= delta
		knife_angle += TAU * 2.5 * delta
		update_orbiting_knives()
	elif not orbiting_knives.is_empty():
		hide_orbiting_knives()

	world_elapsed += delta
	animate_world_decorations(delta)
	if is_pointer_held and not is_swinging:
		hold_elapsed += delta
		if hold_elapsed >= swing_hold_delay and not swing_attempted:
			swing_attempted = true
			begin_swing()

	# Apply gravity
	previous_player_center = get_player_center()
	velocity.y += gravity * delta
	block.position += velocity * delta
	if is_swinging and is_instance_valid(swing_anchor):
		# Keep Jelly moving along a circular arc around the selected orb.
		var jelly_center := block.position + block.size / 2.0
		var rope_direction := (jelly_center - swing_anchor.global_position).normalized()
		block.position = swing_anchor.global_position + rope_direction * swing_rope_length - block.size / 2.0
		var tangential_velocity: Vector2 = velocity - rope_direction * velocity.dot(rope_direction)
		if tangential_velocity.length() < 30.0:
			tangential_velocity = Vector2(-rope_direction.y, rope_direction.x) * 30.0
		velocity = tangential_velocity + tangential_velocity.normalized() * swing_boost_per_second * delta

	var floor_top = floor_rect.position.y
	var block_bottom = block.position.y + block.size.y
	var on_floor = false

	# Floor collision: give the cube a small rebound after a hard landing.
	if block_bottom >= floor_top and velocity.y >= 0.0:
		block.position.y = floor_top - block.size.y
		velocity.y = -velocity.y * floor_bounce if velocity.y > minimum_bounce_speed else 0.0
		on_floor = true

	# Play landing animation once
	if on_floor and not was_on_floor:
		land()

	was_on_floor = on_floor

	# Ceiling collision: the top boundary has a gentler bounce than the floor.
	if block.position.y < 0.0:
		block.position.y = 0.0
		velocity.y = abs(velocity.y) * wall_bounce

	# Side walls bounce the cube back into the play area.
	if block.position.x < 0.0:
		block.position.x = 0.0
		velocity.x = abs(velocity.x) * wall_bounce
	elif block.position.x + block.size.x > map_width:
		block.position.x = map_width - block.size.x
		velocity.x = -abs(velocity.x) * wall_bounce

	collect_power_ups()

	# Keep Jelly centered on screen as it travels through the tall level.
	camera.global_position = block.global_position + block.size / 2.0
	collect_coins(delta)
	update_bats(delta)


func populate_world() -> void:
	# Replace the editor placeholders with a fresh layout on every run.
	for anchor in swing_anchors.get_children():
		swing_anchors.remove_child(anchor)
		anchor.queue_free()
	for bat in bats.get_children():
		bats.remove_child(bat)
		bat.queue_free()
	for power_up in power_ups.get_children():
		power_ups.remove_child(power_up)
		power_up.queue_free()
	coin_positions.clear()
	big_coin_positions.clear()

	# Ensure the opening screen always has one reachable anchor.
	spawn_anchor(Vector2(randf_range(350.0, 580.0), randf_range(400.0, 650.0)))
	for anchor_index in range(anchor_count - 1):
		spawn_anchor(Vector2(
			randf_range(90.0, map_width - 90.0),
			randf_range(260.0, floor_y - 180.0)
		))

	for coin_index in range(coin_count):
		coin_positions.append(Vector2(
			randf_range(45.0, map_width - 45.0),
			randf_range(180.0, floor_y - 140.0)
		))
	for big_coin_index in range(big_coin_count):
		big_coin_positions.append(Vector2(
			randf_range(70.0, map_width - 70.0),
			randf_range(220.0, floor_y - 180.0)
		))

	for bat_index in range(bat_count):
		spawn_bat(Vector2(
			randf_range(120.0, map_width - 120.0),
			randf_range(720.0, floor_y - 220.0)
		))
	for rocket_index in range(rocket_count):
		spawn_power_up("rocket", Vector2(
			randf_range(120.0, map_width - 120.0),
			randf_range(300.0, floor_y - 220.0)
		))
	for teleport_index in range(teleport_count):
		spawn_power_up("teleport", Vector2(
			randf_range(120.0, map_width - 120.0),
			randf_range(300.0, floor_y - 220.0)
		))
	for magnet_index in range(magnet_count):
		spawn_power_up("magnet", Vector2(
			randf_range(120.0, map_width - 120.0),
			randf_range(300.0, floor_y - 220.0)
		))
	for knife_index in range(knife_count):
		spawn_power_up("knife", Vector2(
			randf_range(120.0, map_width - 120.0),
			randf_range(300.0, floor_y - 220.0)
		))


func spawn_anchor(anchor_position: Vector2) -> void:
	var anchor := Sprite2D.new()
	anchor.texture = PURPLE_ORB_TEXTURE
	anchor.position = anchor_position
	anchor.scale = Vector2(0.025, 0.025)
	anchor.set_meta("pulse_offset", randf_range(0.0, TAU))
	swing_anchors.add_child(anchor)


func spawn_bat(bat_position: Vector2) -> void:
	var bat := Sprite2D.new()
	bat.texture = BAT_TEXTURE
	bat.position = bat_position
	bat.scale = Vector2(0.075, 0.075)
	bat.set_meta("home", bat_position)
	bat.set_meta("phase", randf_range(0.0, TAU))
	bat.set_meta("chasing", false)
	bat.set_meta("arming_time", 0.0)
	bats.add_child(bat)


func spawn_power_up(kind: String, power_up_position: Vector2) -> void:
	var power_up := Sprite2D.new()
	match kind:
		"rocket": power_up.texture = ROCKET_TEXTURE
		"teleport": power_up.texture = TELEPORT_TEXTURE
		"magnet": power_up.texture = MAGNET_TEXTURE
		_: power_up.texture = KNIFE_TEXTURE
	power_up.position = power_up_position
	power_up.scale = Vector2(0.052, 0.052)
	power_up.set_meta("pulse_offset", randf_range(0.0, TAU))
	power_up.set_meta("kind", kind)
	power_ups.add_child(power_up)


func collect_power_ups() -> void:
	for power_up_node in power_ups.get_children():
		var power_up := power_up_node as Sprite2D
		if power_up and has_player_contact(power_up.global_position, 50.0):
			apply_power_up(str(power_up.get_meta("kind")))
			power_ups.remove_child(power_up)
			power_up.queue_free()


func apply_power_up(kind: String) -> void:
	is_swinging = false
	swing_anchor = null
	if kind == "rocket":
		velocity = Vector2(velocity.x * 1.4, -1150.0)
		show_power_message("ROCKET BOOST!")
	elif kind == "teleport":
		block.position = get_safe_teleport_position() - block.size / 2.0
		velocity = Vector2(randf_range(-170.0, 170.0), randf_range(-180.0, 20.0))
		show_power_message("WARP!")
	elif kind == "magnet":
		magnet_time = 8.0
		show_power_message("COIN MAGNET!")
	else:
		knife_time = 10.0
		show_power_message("KNIFE STORM: 10s")


func setup_orbiting_knives() -> void:
	for blade in blade_orbit.get_children():
		blade_orbit.remove_child(blade)
		blade.queue_free()
	for blade_index in range(2):
		var blade := Sprite2D.new()
		blade.texture = KNIFE_TEXTURE
		blade.scale = Vector2(0.052, 0.052)
		blade.hide()
		blade_orbit.add_child(blade)
		orbiting_knives.append(blade)


func update_orbiting_knives() -> void:
	var jelly_center := block.global_position + block.size / 2.0
	for blade_index in range(orbiting_knives.size()):
		var blade := orbiting_knives[blade_index]
		var blade_angle := knife_angle + PI * blade_index
		blade.global_position = jelly_center + Vector2.RIGHT.rotated(blade_angle) * 88.0
		blade.rotation = blade_angle
		blade.show()


func hide_orbiting_knives() -> void:
	for blade in orbiting_knives:
		blade.hide()


func get_safe_teleport_position() -> Vector2:
	var destination := Vector2(map_width / 2.0, floor_y / 2.0)
	for attempt in range(16):
		destination = Vector2(
			randf_range(150.0, map_width - 150.0),
			randf_range(300.0, floor_y - 260.0)
		)
		var clear_of_bats := true
		for bat_node in bats.get_children():
			var bat := bat_node as Sprite2D
			if bat and destination.distance_to(bat.global_position) < 280.0:
				clear_of_bats = false
				break
		if clear_of_bats:
			return destination
	return destination


func show_power_message(message: String) -> void:
	power_message.text = message
	power_message_time = 1.5
	power_message.show()


func animate_world_decorations(delta: float) -> void:
	# Gentle motion makes nearby targets easier to notice without changing their collision area.
	for anchor_node in swing_anchors.get_children():
		var anchor := anchor_node as Sprite2D
		if anchor:
			var pulse: float = 1.0 + sin(world_elapsed * 2.4 + float(anchor.get_meta("pulse_offset"))) * 0.09
			anchor.scale = Vector2.ONE * 0.025 * pulse
			anchor.rotation += delta * 0.35
	for power_up_node in power_ups.get_children():
		var power_up := power_up_node as Sprite2D
		if power_up:
			var pulse: float = 1.0 + sin(world_elapsed * 3.0 + float(power_up.get_meta("pulse_offset"))) * 0.12
			power_up.scale = Vector2.ONE * 0.052 * pulse
			power_up.rotation += delta * 0.8


func update_bats(delta: float) -> void:
	var jelly_center := get_player_center()
	for bat_node in bats.get_children():
		var bat := bat_node as Sprite2D
		if not bat:
			continue
		if knife_time > 0.0 and bat.global_position.distance_to(jelly_center) < 142.0:
			defeat_bat(bat)
			continue
		var chasing: bool = bat.get_meta("chasing")
		if chasing:
			var arming_time: float = bat.get_meta("arming_time")
			if arming_time > 0.0:
				bat.set_meta("arming_time", arming_time - delta)
				continue

			var hunt_direction: Vector2 = (jelly_center - bat.global_position).normalized()
			# The run ramps up gradually, rewarding early exploration before the pressure rises.
			var current_chase_speed: float = bat_chase_speed + min(float(coins_collected) * 3.0, 150.0)
			bat.position += hunt_direction * current_chase_speed * delta
			bat.scale.x = abs(bat.scale.x) * sign(hunt_direction.x) if hunt_direction.x != 0.0 else bat.scale.x
			if has_player_contact(bat.global_position, bat_attack_radius):
				end_game()
		else:
			var home: Vector2 = bat.get_meta("home")
			var phase: float = bat.get_meta("phase")
			bat.position = home + Vector2(
				sin(world_elapsed * 1.8 + phase) * 80.0,
				cos(world_elapsed * 2.3 + phase) * 45.0
			)
			if has_player_contact(bat.global_position, bat_wake_radius):
				# Touching a patrolling bat wakes it, then it starts hunting Jelly.
				bat.set_meta("chasing", true)
				bat.set_meta("arming_time", bat_arm_delay)


func defeat_bat(bat: Sprite2D) -> void:
	bats.remove_child(bat)
	bat.queue_free()
	bat_kills += 1
	update_kill_counter()


func end_game() -> void:
	game_over = true
	velocity = Vector2.ZERO
	is_swinging = false
	swing_anchor = null
	if flip_tween and flip_tween.is_running():
		flip_tween.kill()
	if jelly_tween and jelly_tween.is_running():
		jelly_tween.kill()
	if straighten_tween and straighten_tween.is_running():
		straighten_tween.kill()
	if coins_collected > high_score:
		high_score = coins_collected
		save_high_score()
		update_high_score_label()
	game_over_screen.show()
	game_over_run_label.text = "Run: %d coins  •  %d bats defeated" % [coins_collected, bat_kills]


func start_game() -> void:
	if game_started:
		return
	game_started = true
	start_screen.hide()
	coin_counter.show()
	high_score_label.show()
	kill_counter.show()
	restart_game()


func restart_game() -> void:
	game_over = false
	velocity = Vector2.ZERO
	block.position = Vector2(300.0, 100.0)
	block.rotation = 0.0
	block.scale = Vector2.ONE
	is_swinging = false
	swing_anchor = null
	is_pointer_held = false
	coins_collected = 0
	bat_kills = 0
	magnet_time = 0.0
	knife_time = 0.0
	knife_angle = 0.0
	hold_elapsed = 0.0
	swing_attempted = false
	was_on_floor = false
	world_elapsed = 0.0
	power_message_time = 0.0
	if flip_tween and flip_tween.is_running():
		flip_tween.kill()
	if jelly_tween and jelly_tween.is_running():
		jelly_tween.kill()
	if straighten_tween and straighten_tween.is_running():
		straighten_tween.kill()
	populate_world()
	update_coin_counter()
	update_kill_counter()
	power_message.hide()
	hide_orbiting_knives()
	game_over_screen.hide()
	previous_player_center = get_player_center()


func get_player_center() -> Vector2:
	return block.global_position + block.size / 2.0


func has_player_contact(world_position: Vector2, radius: float) -> bool:
	# Test the full physics-step path, not only the final frame position.
	var closest_point := Geometry2D.get_closest_point_to_segment(
		world_position,
		previous_player_center,
		get_player_center()
	)
	return closest_point.distance_to(world_position) <= radius


func collect_coins(delta: float) -> void:
	var jelly_center := get_player_center()
	var remaining_coins: Array[Vector2] = []
	var collected_any := false
	for coin_position in coin_positions:
		var adjusted_position := coin_position
		if magnet_time > 0.0 and jelly_center.distance_to(adjusted_position) < 620.0:
			adjusted_position = adjusted_position.move_toward(jelly_center, 900.0 * delta)
		if has_player_contact(adjusted_position, 34.0):
			coins_collected += 1
			collected_any = true
		else:
			remaining_coins.append(adjusted_position)
	coin_positions = remaining_coins

	var remaining_big_coins: Array[Vector2] = []
	for big_coin_position in big_coin_positions:
		var adjusted_big_coin := big_coin_position
		if magnet_time > 0.0 and jelly_center.distance_to(adjusted_big_coin) < 720.0:
			adjusted_big_coin = adjusted_big_coin.move_toward(jelly_center, 780.0 * delta)
		if has_player_contact(adjusted_big_coin, 52.0):
			coins_collected += 5
			collected_any = true
			show_power_message("BIG COIN +5!")
		else:
			remaining_big_coins.append(adjusted_big_coin)
	big_coin_positions = remaining_big_coins

	if collected_any:
		update_coin_counter()


func update_coin_counter() -> void:
	coin_counter.text = "Coins: %d" % coins_collected


func update_kill_counter() -> void:
	kill_counter.text = "Bats: %d" % bat_kills


func load_high_score() -> void:
	var score_file := ConfigFile.new()
	if score_file.load(SCORE_SAVE_PATH) == OK:
		high_score = int(score_file.get_value("scores", "high_score", 0))


func save_high_score() -> void:
	var score_file := ConfigFile.new()
	score_file.set_value("scores", "high_score", high_score)
	score_file.save(SCORE_SAVE_PATH)


func update_high_score_label() -> void:
	high_score_label.text = "Best: %d" % high_score
	game_over_best_label.text = "High Score: %d" % high_score
	menu_best_label.text = "BEST RUN: %d COINS" % high_score


func _input(event: InputEvent) -> void:
	if not game_started or game_over:
		return

	# Mouse click on Windows
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_hold()
			else:
				end_hold()

	# Touchscreen tap on iPhone
	elif event is InputEventScreenTouch:
		if event.pressed:
			start_hold()
		else:
			end_hold()


func start_hold() -> void:
	is_pointer_held = true
	hold_elapsed = 0.0
	swing_attempted = false


func end_hold() -> void:
	is_pointer_held = false
	if is_swinging:
		release_swing()
	else:
		# A short press, or a long press without a visible anchor, is a jump.
		launch()


func begin_swing() -> void:
	# Holding attaches to the closest orb currently visible on screen.
	var selected_anchor := get_closest_visible_anchor()
	if not selected_anchor:
		return

	is_swinging = true
	swing_anchor = selected_anchor
	var jelly_center := block.position + block.size / 2.0
	swing_rope_length = max(jelly_center.distance_to(swing_anchor.global_position), 105.0)


func release_swing() -> void:
	# Releasing preserves tangential speed, sending Jelly flying from the swing.
	is_swinging = false
	swing_anchor = null


func get_closest_visible_anchor() -> Sprite2D:
	var closest_anchor: Sprite2D
	var closest_distance := INF
	var jelly_center := block.global_position + block.size / 2.0
	var viewport_bounds := Rect2(Vector2.ZERO, get_viewport_rect().size)
	for anchor in swing_anchors.get_children():
		if anchor is Sprite2D:
			var screen_position: Vector2 = get_canvas_transform() * anchor.global_position
			if viewport_bounds.has_point(screen_position):
				var distance := jelly_center.distance_to(anchor.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_anchor = anchor
	return closest_anchor


func launch() -> void:
	# Fallback launch when no anchor is visible.
	is_swinging = false
	swing_anchor = null
	velocity = Vector2.UP * launch_speed
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


func _draw() -> void:
	# Paint the large world with a soft sky gradient behind the play area.
	var sky_start_y := -1600.0
	var sky_height := floor_y - sky_start_y + 120.0
	var sky_strips := 96
	var strip_height := sky_height / sky_strips
	for strip in range(sky_strips):
		var blend := float(strip) / float(sky_strips - 1)
		var strip_color := sky_top_color.lerp(sky_bottom_color, blend)
		draw_rect(
			Rect2(0, sky_start_y + strip * strip_height, map_width, strip_height + 1.0),
			strip_color
		)

	# Draw collectible coins over the sky, beneath the game objects.
	for coin_position in coin_positions:
		draw_circle(coin_position, 15.0, Color("e5a900"))
		draw_circle(coin_position, 11.0, Color("ffdf3c"))
		draw_arc(coin_position, 8.0, 0.0, TAU, 20, Color("fff4a3"), 2.0, true)
	for big_coin_position in big_coin_positions:
		draw_circle(big_coin_position, 30.0, Color("bd6900"))
		draw_circle(big_coin_position, 25.0, Color("ffb000"))
		draw_circle(big_coin_position, 19.0, Color("ffe261"))
		draw_arc(big_coin_position, 15.0, 0.0, TAU, 20, Color("fff7bc"), 3.0, true)

	# Draw the tether only while Jelly is swinging.
	if not is_instance_valid(block):
		return

	var origin = block.position + block.size / 2.0
	if is_swinging and is_instance_valid(swing_anchor):
		draw_line(swing_anchor.global_position, origin, Color.BLACK, 6.0, true)


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

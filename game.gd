
extends Node2D

const PURPLE_ORB_TEXTURE := preload("res://images/purple_swing_orb.png")
const BAT_TEXTURE := preload("res://images/chase_bat.png")
const ROCKET_TEXTURE := preload("res://images/rocket_powerup.png")
const TELEPORT_TEXTURE := preload("res://images/teleport_powerup.png")
const MAGNET_TEXTURE := preload("res://images/magnet_powerup.png")
const KNIFE_TEXTURE := preload("res://images/knife_powerup.png")
const JELLY_TEXTURE := preload("res://images/cute cube face.png")
const SKIN_CATALOG_TEXTURE := preload("res://images/jelly_skin_catalog.png")
const COMMON_CHEST_TEXTURE := preload("res://images/common_chest.png")
const UNCOMMON_CHEST_TEXTURE := preload("res://images/uncommon_chest.png")
const FOOD_SKIN_TEXTURES := [
	preload("res://images/food_sushi_jelly.png"),
	preload("res://images/food_donut_jelly.png"),
	preload("res://images/food_strawberry_jelly.png"),
	preload("res://images/food_cupcake_jelly.png"),
	preload("res://images/food_watermelon_jelly.png")
]
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
@onready var bot_swings: Node2D = $BotSwings
@onready var game_over_screen: ColorRect = $HUD/GameOverScreen
@onready var game_over_best_label: Label = $HUD/GameOverScreen/GameOverBest
@onready var restart_button: Button = $HUD/GameOverScreen/RestartButton
@onready var main_menu_button: Button = $HUD/GameOverScreen/MainMenuButton
@onready var power_message: Label = $HUD/PowerMessage
@onready var kill_counter: Label = $HUD/KillCounter
@onready var start_screen: ColorRect = $HUD/StartScreen
@onready var start_button: Button = $HUD/StartScreen/StartButton
@onready var menu_best_label: Label = $HUD/StartScreen/MenuBest
@onready var menu_wallet_label: Label = $HUD/StartScreen/MenuWallet
@onready var game_over_run_label: Label = $HUD/GameOverScreen/GameOverRun
@onready var leaderboard_panel: ColorRect = $HUD/LeaderboardPanel
@onready var leaderboard_label: Label = $HUD/LeaderboardPanel/LeaderboardText
@onready var jelly_sprite: Sprite2D = $Block/jelly
@onready var shop_screen: ColorRect = $HUD/ShopScreen
@onready var shop_button: Button = $HUD/StartScreen/ShopButton
@onready var shop_back_button: Button = $HUD/ShopScreen/BackButton
@onready var shop_wallet_label: Label = $HUD/ShopScreen/Wallet
@onready var skin_list: GridContainer = $HUD/ShopScreen/SkinList
@onready var chest_tab_button: Button = $HUD/ShopScreen/ChestTabButton
@onready var jelly_tab_button: Button = $HUD/ShopScreen/JellyTabButton
@onready var skin_catalog: TextureRect = $HUD/ShopScreen/SkinCatalog
@onready var chest_icon: TextureRect = $HUD/ShopScreen/ChestIcon
@onready var chest_card: ColorRect = $HUD/ShopScreen/ChestCard
@onready var chest_heading: Label = $HUD/ShopScreen/ChestHeading
@onready var chest_description: Label = $HUD/ShopScreen/ChestDescription
@onready var future_chest_row: Control = $HUD/ShopScreen/FutureChestRow
@onready var common_chest_button: Button = $HUD/ShopScreen/CommonChestButton
@onready var uncommon_chest_button: TextureButton = $HUD/ShopScreen/FutureChestRow/Uncommon
@onready var chest_result_label: Label = $HUD/ShopScreen/ChestResult
@onready var chest_preview: TextureRect = $HUD/ShopScreen/ChestPreview
@onready var chest_carousel_backdrop: ColorRect = $HUD/ShopScreen/ChestCarouselBackdrop
@onready var chest_carousel: Control = $HUD/ShopScreen/ChestCarousel

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
var wallet_coins := 0
var selected_skin := 0
var unlocked_skins: Array[int] = [0]
var skin_definitions: Array[Dictionary] = [
	{"name": "Jelly Blue", "price": 0, "body": "35e4f2", "face": "ffffff"},
	{"name": "Bubblegum", "price": 15, "body": "ff73bd", "face": "fff0fa"},
	{"name": "Grape Pop", "price": 30, "body": "a66cff", "face": "f3eaff"},
	{"name": "Lime Zing", "price": 50, "body": "91ef64", "face": "efffe5"},
	{"name": "Sunburst", "price": 75, "body": "ffba3d", "face": "fff5c7"},
	{"name": "Cherry", "price": 110, "body": "f04c59", "face": "ffe8e9"},
	{"name": "Midnight", "price": 160, "body": "34448f", "face": "dbe5ff"},
	{"name": "Mint Chip", "price": 220, "body": "42d8b3", "face": "e8fff8"},
	{"name": "Lava Glow", "price": 300, "body": "ff5d22", "face": "fff0cc"},
	{"name": "Galaxy", "price": 450, "body": "6328a8", "face": "ffd5ff"},
	{"name": "Sushi Jelly", "tier": "Uncommon"},
	{"name": "Donut Jelly", "tier": "Uncommon"},
	{"name": "Strawberry Jelly", "tier": "Uncommon"},
	{"name": "Cupcake Jelly", "tier": "Uncommon"},
	{"name": "Watermelon Jelly", "tier": "Uncommon"}
]
var bot_names: Array[String] = ["Bloop", "Mochi", "Pip", "Zing", "Wobble", "Nori", "Fizz", "Taffy", "Pebble", "Comet", "Pogo", "Doodle"]
var common_chest_cost := 50
var uncommon_chest_cost := 100
var chest_rolling := false
var chest_roll_elapsed := 0.0
var chest_next_tick := 0.0
var chest_target_skin := 0
var chest_reward_pool: Array[int] = []
var chest_carousel_items: Array[TextureRect] = []
var chest_carousel_target_index := 24
var chest_carousel_final_offset := 0.0
var bat_count := 28
var swing_bot_count := 42
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
var jump_cooldown: float = 0.55
var jump_cooldown_remaining := 0.0
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
var touch_gesture_active := false
var last_touch_event_msec := -1000

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
	floor_rect.color = Color("e64018")

	# Rotate and squash around the block's center
	block.pivot_offset = block.size / 2.0

	# Begin with the block upright
	block.rotation = 0.0
	block.scale = Vector2.ONE
	populate_world()
	update_coin_counter()
	load_high_score()
	load_profile()
	update_coin_counter()
	apply_selected_skin()
	update_high_score_label()
	game_over_screen.hide()
	start_screen.show()
	$HUD.get_node("CoinCounter").hide()
	$HUD.get_node("HighScore").hide()
	$HUD.get_node("KillCounter").hide()
	leaderboard_panel.hide()
	shop_screen.hide()
	power_message.hide()
	setup_orbiting_knives()
	update_kill_counter()
	previous_player_center = get_player_center()
	restart_button.pressed.connect(restart_game)
	main_menu_button.pressed.connect(return_to_main_menu)
	start_button.pressed.connect(start_game)
	shop_button.pressed.connect(open_shop)
	shop_back_button.pressed.connect(close_shop)
	common_chest_button.pressed.connect(open_common_chest)
	uncommon_chest_button.pressed.connect(open_uncommon_chest)
	chest_tab_button.pressed.connect(set_shop_tab.bind("chests"))
	jelly_tab_button.pressed.connect(set_shop_tab.bind("jellies"))
	build_skin_shop()


func _process(delta: float) -> void:
	if not chest_rolling:
		return
	chest_roll_elapsed += delta
	update_chest_carousel(clamp(chest_roll_elapsed / 3.2, 0.0, 1.0))
	if chest_roll_elapsed >= chest_next_tick:
		var progress: float = clamp(chest_roll_elapsed / 3.2, 0.0, 1.0)
		var preview_skin: int = chest_reward_pool.pick_random()
		chest_preview.texture = create_skin_texture(preview_skin)
		chest_result_label.text = "OPENING...  %s" % str(skin_definitions[preview_skin]["name"])
		chest_next_tick += lerp(0.07, 0.42, progress)
	if chest_roll_elapsed >= 3.2:
		finish_chest()


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
	jump_cooldown_remaining = max(jump_cooldown_remaining - delta, 0.0)
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
	update_swing_bots(delta)
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
	# The floor is lava: one touch ends the run instead of bouncing Jelly safely.
	if block_bottom >= floor_top and velocity.y >= 0.0:
		end_game()
		return

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
	for bot in bot_swings.get_children():
		bot_swings.remove_child(bot)
		bot.queue_free()
	coin_positions.clear()
	big_coin_positions.clear()

	# Ensure the opening screen always has one reachable anchor.
	spawn_anchor(Vector2(randf_range(350.0, 580.0), randf_range(400.0, 650.0)))
	for anchor_index in range(anchor_count - 1):
		spawn_anchor(Vector2(
			randf_range(90.0, map_width - 90.0),
			randf_range(260.0, floor_y - 180.0)
		))
	for bot_index in range(swing_bot_count):
		var anchor := swing_anchors.get_children().pick_random() as Sprite2D
		if anchor:
			spawn_swing_bot(anchor.global_position, bot_index + 1)

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


func spawn_swing_bot(anchor_position: Vector2, bot_number: int) -> void:
	# Friendly AI racers swing between anchors and compete for the same coins as Jelly.
	var bot := Node2D.new()
	var rope_length := randf_range(110.0, 210.0)
	bot.position = anchor_position + Vector2.DOWN * rope_length
	bot.set_meta("from_anchor", anchor_position)
	bot.set_meta("rope_length", rope_length)
	bot.set_meta("velocity", Vector2(randf_range(-260.0, 260.0), 0.0))
	bot.set_meta("switch_at", world_elapsed + randf_range(3.0, 5.0))
	bot.set_meta("rope_cut", false)
	bot.set_meta("coins", 0)
	var bot_skin_id := randi_range(0, skin_definitions.size() - 1)
	bot.set_meta("name", bot_names.pick_random())
	bot.set_meta("magnet_until", 0.0)
	bot.set_meta("knife_until", 0.0)

	var body := ColorRect.new()
	body.position = Vector2(-24.0, -24.0)
	body.size = Vector2(48.0, 48.0)
	body.color = Color.TRANSPARENT
	body.pivot_offset = body.size / 2.0
	bot.add_child(body)

	var sprite := Sprite2D.new()
	var bot_skin_texture := create_skin_texture(bot_skin_id)
	sprite.texture = bot_skin_texture
	sprite.position = Vector2(24.0, 24.0)
	sprite.scale = get_skin_sprite_scale(bot_skin_texture)
	body.add_child(sprite)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.position = Vector2(-54.0, -66.0)
	name_label.size = Vector2(108.0, 22.0)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_shadow_color", Color("1a1230"))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 2)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.text = str(bot.get_meta("name"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bot.add_child(name_label)
	bot_swings.add_child(bot)


func get_next_bot_anchor(from_position: Vector2) -> Vector2:
	var candidates: Array[Sprite2D] = []
	for anchor_node in swing_anchors.get_children():
		var anchor := anchor_node as Sprite2D
		if anchor and anchor.global_position.distance_to(from_position) > 110.0 and anchor.global_position.distance_to(from_position) < 460.0:
			candidates.append(anchor)
	if candidates.is_empty():
		return from_position
	return candidates.pick_random().global_position


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



func update_swing_bots(delta: float) -> void:
	for bot_node in bot_swings.get_children():
		var bot := bot_node as Node2D
		if not bot:
			continue
		var bot_velocity: Vector2 = bot.get_meta("velocity")
		var anchor_position: Vector2 = bot.get_meta("from_anchor")
		var rope_length: float = float(bot.get_meta("rope_length"))
		var rope_cut: bool = bool(bot.get_meta("rope_cut"))

		# The same gravity + tangential-rope physics used by Jelly.
		bot_velocity.y += gravity * delta
		bot.position += bot_velocity * delta
		if not rope_cut and player_hits_bot_rope(anchor_position, bot.global_position):
			rope_cut = true
			bot.set_meta("rope_cut", true)
			show_power_message("ROPE CUT!")
		if not rope_cut:
			var rope_direction := (bot.global_position - anchor_position).normalized()
			if rope_direction == Vector2.ZERO:
				rope_direction = Vector2.DOWN
			bot.global_position = anchor_position + rope_direction * rope_length
			var tangential_velocity: Vector2 = bot_velocity - rope_direction * bot_velocity.dot(rope_direction)
			if tangential_velocity.length() < 30.0:
				tangential_velocity = Vector2(-rope_direction.y, rope_direction.x) * 75.0
			bot_velocity = tangential_velocity + tangential_velocity.normalized() * swing_boost_per_second * 0.65 * delta

			# Bots periodically throw their rope to a nearby purple orb.
			if world_elapsed >= float(bot.get_meta("switch_at")):
				var next_anchor := get_next_bot_anchor(bot.global_position)
				var next_rope_length := bot.global_position.distance_to(next_anchor)
				# Never clamp a new rope: clamping was what visibly snapped bots across the map.
				if next_rope_length >= 105.0 and next_rope_length <= 460.0:
					anchor_position = next_anchor
					rope_length = next_rope_length
					bot.set_meta("from_anchor", anchor_position)
					bot.set_meta("rope_length", rope_length)
					bot.set_meta("switch_at", world_elapsed + randf_range(3.0, 5.0))
				else:
					# Try again soon if no reachable orb is currently available.
					bot.set_meta("switch_at", world_elapsed + 0.75)

		# Lava removes a bot from the current race.
		if bot.position.y + 24.0 >= floor_rect.position.y and bot_velocity.y >= 0.0:
			bot_swings.remove_child(bot)
			bot.queue_free()
			continue
		if bot.position.y - 24.0 < 0.0:
			bot.position.y = 24.0
			bot_velocity.y = abs(bot_velocity.y) * wall_bounce
		if bot.position.x - 24.0 < 0.0:
			bot.position.x = 24.0
			bot_velocity.x = abs(bot_velocity.x) * wall_bounce
		elif bot.position.x + 24.0 > map_width:
			bot.position.x = map_width - 24.0
			bot_velocity.x = -abs(bot_velocity.x) * wall_bounce
		bot.set_meta("velocity", bot_velocity)
		bot.rotation = bot_velocity.angle() * 0.12
		var name_label := bot.get_node_or_null("NameLabel") as Label
		if name_label:
			name_label.rotation = -bot.rotation
		collect_power_ups_for_bot(bot)
		collect_coins_for_bot(bot, delta)
	bots_cut_ropes()
	update_leaderboard()


func player_hits_bot_rope(anchor_position: Vector2, rope_end: Vector2) -> bool:
	# Check both ends of Jelly's physics-step path so fast swings can still cut a rope.
	var cut_radius := 28.0
	var current_closest := Geometry2D.get_closest_point_to_segment(get_player_center(), anchor_position, rope_end)
	var previous_closest := Geometry2D.get_closest_point_to_segment(previous_player_center, anchor_position, rope_end)
	return current_closest.distance_to(get_player_center()) <= cut_radius or previous_closest.distance_to(previous_player_center) <= cut_radius


func bots_cut_ropes() -> void:
	var cut_radius := 27.0
	# A moving bot can cut any other bot's intact tether.
	for cutter_node in bot_swings.get_children():
		var cutter := cutter_node as Node2D
		if not cutter:
			continue
		for target_node in bot_swings.get_children():
			var target := target_node as Node2D
			if not target or target == cutter or bool(target.get_meta("rope_cut")):
				continue
			var target_anchor: Vector2 = target.get_meta("from_anchor")
			var closest_point := Geometry2D.get_closest_point_to_segment(cutter.global_position, target_anchor, target.global_position)
			if closest_point.distance_to(cutter.global_position) <= cut_radius:
				target.set_meta("rope_cut", true)

	# Bots can also cut Jelly loose, but Jelly keeps its current flight velocity.
	if is_swinging and is_instance_valid(swing_anchor):
		var jelly_center := get_player_center()
		for cutter_node in bot_swings.get_children():
			var cutter := cutter_node as Node2D
			if cutter:
				var closest_point := Geometry2D.get_closest_point_to_segment(cutter.global_position, swing_anchor.global_position, jelly_center)
				if closest_point.distance_to(cutter.global_position) <= cut_radius:
					is_swinging = false
					swing_anchor = null
					show_power_message("BOT CUT YOUR ROPE!")
					break


func collect_power_ups_for_bot(bot: Node2D) -> void:
	for power_up_node in power_ups.get_children():
		var power_up := power_up_node as Sprite2D
		if power_up and bot.global_position.distance_to(power_up.global_position) < 50.0:
			apply_power_up_to_bot(bot, str(power_up.get_meta("kind")))
			power_ups.remove_child(power_up)
			power_up.queue_free()
			return


func apply_power_up_to_bot(bot: Node2D, kind: String) -> void:
	var bot_velocity: Vector2 = bot.get_meta("velocity")
	match kind:
		"rocket":
			bot_velocity = Vector2(bot_velocity.x * 1.4, -1150.0)
		"teleport":
			bot.global_position = get_safe_teleport_position()
			var nearest_anchor := get_nearest_anchor(bot.global_position)
			bot.set_meta("from_anchor", nearest_anchor)
			bot.set_meta("rope_length", bot.global_position.distance_to(nearest_anchor))
		"magnet":
			bot.set_meta("magnet_until", world_elapsed + 8.0)
		"knife":
			bot.set_meta("knife_until", world_elapsed + 10.0)
	bot.set_meta("velocity", bot_velocity)


func get_nearest_anchor(world_position: Vector2) -> Vector2:
	var closest_position := world_position
	var closest_distance := INF
	for anchor_node in swing_anchors.get_children():
		var anchor := anchor_node as Sprite2D
		if anchor:
			var distance := anchor.global_position.distance_to(world_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_position = anchor.global_position
	return closest_position


func collect_coins_for_bot(bot: Node2D, delta: float) -> void:
	var magnet_active := world_elapsed < float(bot.get_meta("magnet_until"))
	for coin_index in range(coin_positions.size() - 1, -1, -1):
		var coin_position := coin_positions[coin_index]
		if magnet_active and bot.global_position.distance_to(coin_position) < 620.0:
			coin_position = coin_position.move_toward(bot.global_position, 900.0 * delta)
			coin_positions[coin_index] = coin_position
		if bot.global_position.distance_to(coin_position) < 42.0:
			coin_positions.remove_at(coin_index)
			bot.set_meta("coins", int(bot.get_meta("coins")) + 1)
			return
	for big_coin_index in range(big_coin_positions.size() - 1, -1, -1):
		var big_coin_position := big_coin_positions[big_coin_index]
		if magnet_active and bot.global_position.distance_to(big_coin_position) < 720.0:
			big_coin_position = big_coin_position.move_toward(bot.global_position, 780.0 * delta)
			big_coin_positions[big_coin_index] = big_coin_position
		if bot.global_position.distance_to(big_coin_position) < 58.0:
			big_coin_positions.remove_at(big_coin_index)
			bot.set_meta("coins", int(bot.get_meta("coins")) + 5)
			return


func update_bats(delta: float) -> void:
	var jelly_center := get_player_center()
	for bat_node in bats.get_children():
		var bat := bat_node as Sprite2D
		if not bat:
			continue
		if knife_time > 0.0 and bat.global_position.distance_to(jelly_center) < 142.0:
			defeat_bat(bat)
			continue
		if bot_has_active_knife_near(bat.global_position):
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


func bot_has_active_knife_near(world_position: Vector2) -> bool:
	for bot_node in bot_swings.get_children():
		var bot := bot_node as Node2D
		if bot and world_elapsed < float(bot.get_meta("knife_until")) and bot.global_position.distance_to(world_position) < 118.0:
			return true
	return false


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
	save_profile()


func start_game() -> void:
	if game_started:
		return
	game_started = true
	start_screen.hide()
	coin_counter.show()
	high_score_label.show()
	kill_counter.show()
	leaderboard_panel.show()
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
	jump_cooldown_remaining = 0.0
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
	update_leaderboard()
	power_message.hide()
	hide_orbiting_knives()
	game_over_screen.hide()
	previous_player_center = get_player_center()


func return_to_main_menu() -> void:
	game_started = false
	game_over = false
	velocity = Vector2.ZERO
	is_swinging = false
	swing_anchor = null
	is_pointer_held = false
	power_message.hide()
	hide_orbiting_knives()
	game_over_screen.hide()
	coin_counter.hide()
	high_score_label.hide()
	kill_counter.hide()
	leaderboard_panel.hide()
	update_high_score_label()
	start_screen.show()


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
			wallet_coins += 1
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
			wallet_coins += 5
			collected_any = true
			show_power_message("BIG COIN +5!")
		else:
			remaining_big_coins.append(adjusted_big_coin)
	big_coin_positions = remaining_big_coins

	if collected_any:
		update_coin_counter()
		update_leaderboard()


func update_coin_counter() -> void:
	coin_counter.text = "Run: %d  Bank: %d" % [coins_collected, wallet_coins]
	menu_wallet_label.text = "COIN BANK: %d" % wallet_coins


func update_leaderboard() -> void:
	var standings: Array[Dictionary] = [{"name": "YOU", "coins": coins_collected}]
	for bot_node in bot_swings.get_children():
		var bot := bot_node as Node2D
		if bot:
			standings.append({"name": str(bot.get_meta("name")), "coins": int(bot.get_meta("coins"))})
	standings.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["coins"]) > int(b["coins"]))
	var text := "LEADERBOARD"
	for place in range(min(5, standings.size())):
		var entry: Dictionary = standings[place]
		text += "\n%d. %-7s %d" % [place + 1, str(entry["name"]), int(entry["coins"])]
	leaderboard_label.text = text


func update_kill_counter() -> void:
	kill_counter.text = "Bats: %d" % bat_kills


func load_high_score() -> void:
	var score_file := ConfigFile.new()
	if score_file.load(SCORE_SAVE_PATH) == OK:
		high_score = int(score_file.get_value("scores", "high_score", 0))


func load_profile() -> void:
	var profile_file := ConfigFile.new()
	if profile_file.load(SCORE_SAVE_PATH) == OK:
		wallet_coins = int(profile_file.get_value("profile", "wallet_coins", 0))
		selected_skin = int(profile_file.get_value("profile", "selected_skin", 0))
		var unlocked_text := str(profile_file.get_value("profile", "unlocked_skins", "0"))
		unlocked_skins.clear()
		for skin_id_text in unlocked_text.split(",", false):
			unlocked_skins.append(int(skin_id_text))
	if not unlocked_skins.has(0):
		unlocked_skins.append(0)
	if selected_skin < 0 or selected_skin >= skin_definitions.size() or not unlocked_skins.has(selected_skin):
		selected_skin = 0


func save_profile() -> void:
	var profile_file := ConfigFile.new()
	profile_file.load(SCORE_SAVE_PATH)
	profile_file.set_value("profile", "wallet_coins", wallet_coins)
	profile_file.set_value("profile", "selected_skin", selected_skin)
	var saved_skin_ids: Array[String] = []
	for skin_id in unlocked_skins:
		saved_skin_ids.append(str(skin_id))
	profile_file.set_value("profile", "unlocked_skins", ",".join(saved_skin_ids))
	profile_file.save(SCORE_SAVE_PATH)


func save_high_score() -> void:
	var score_file := ConfigFile.new()
	score_file.set_value("scores", "high_score", high_score)
	score_file.save(SCORE_SAVE_PATH)


func update_high_score_label() -> void:
	high_score_label.text = "Best: %d" % high_score
	game_over_best_label.text = "High Score: %d" % high_score
	menu_best_label.text = "BEST RUN: %d COINS" % high_score


func apply_selected_skin() -> void:
	# Each skin is a real generated texture tile, not a color tint of the base Jelly.
	var selected_skin_texture := create_skin_texture(selected_skin)
	jelly_sprite.texture = selected_skin_texture
	jelly_sprite.scale = get_skin_sprite_scale(selected_skin_texture)
	jelly_sprite.modulate = Color.WHITE
	block.color = Color.TRANSPARENT


func get_skin_sprite_scale(skin_texture: Texture2D) -> Vector2:
	# Generated skins can have different source resolutions. Normalize by their
	# longest edge so every Jelly has the same on-screen size.
	var largest_edge := maxf(float(skin_texture.get_width()), float(skin_texture.get_height()))
	return Vector2.ONE * (100.0 / largest_edge)


func create_skin_texture(skin_id: int) -> Texture2D:
	if skin_id >= 10:
		return FOOD_SKIN_TEXTURES[skin_id - 10]
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = SKIN_CATALOG_TEXTURE
	var column: int = skin_id % 2
	var row: int = skin_id / 2
	atlas_texture.region = Rect2(float(column) * 512.0, float(row) * 307.2, 512.0, 307.2)
	return atlas_texture


func build_skin_shop() -> void:
	for skin_button_node in skin_list.get_children():
		skin_list.remove_child(skin_button_node)
		skin_button_node.queue_free()
	for skin_id in range(skin_definitions.size()):
		var skin: Dictionary = skin_definitions[skin_id]
		var skin_button := TextureButton.new()
		skin_button.custom_minimum_size = Vector2(185.0, 104.0)
		skin_button.texture_normal = create_skin_texture(skin_id)
		skin_button.ignore_texture_size = true
		skin_button.stretch_mode = TextureButton.STRETCH_SCALE
		var owned := unlocked_skins.has(skin_id)
		if skin_id == selected_skin:
			skin_button.tooltip_text = "%s — EQUIPPED" % str(skin["name"])
		elif owned:
			skin_button.tooltip_text = "%s — OWNED" % str(skin["name"])
		else:
			skin_button.modulate = Color(0.28, 0.28, 0.32, 1.0)
			skin_button.tooltip_text = "%s — LOCKED" % str(skin["name"])
		skin_button.pressed.connect(buy_or_equip_skin.bind(skin_id))
		skin_list.add_child(skin_button)
	shop_wallet_label.text = "COIN BANK: %d" % wallet_coins
	common_chest_button.text = "COMMON CHEST — %d COINS" % common_chest_cost
	common_chest_button.disabled = chest_rolling
	uncommon_chest_button.disabled = chest_rolling
	if not chest_rolling:
		chest_preview.texture = create_skin_texture(selected_skin)


func buy_or_equip_skin(skin_id: int) -> void:
	if not unlocked_skins.has(skin_id):
		chest_result_label.text = "LOCKED — OPEN A CHEST TO UNLOCK"
		return
	selected_skin = skin_id
	apply_selected_skin()
	save_profile()
	update_coin_counter()
	build_skin_shop()


func open_common_chest() -> void:
	open_chest("COMMON", common_chest_cost, [1, 2, 3, 4, 5, 6, 7, 8, 9], COMMON_CHEST_TEXTURE, "Guaranteed new classic Jelly skin")


func open_uncommon_chest() -> void:
	open_chest("UNCOMMON", uncommon_chest_cost, [10, 11, 12, 13, 14], UNCOMMON_CHEST_TEXTURE, "Guaranteed new food Jelly skin")


func open_chest(tier_name: String, cost: int, reward_pool: Array[int], chest_texture: Texture2D, description: String) -> void:
	if chest_rolling:
		return
	var locked_skins: Array[int] = []
	for skin_id in reward_pool:
		if not unlocked_skins.has(skin_id):
			locked_skins.append(skin_id)
	if locked_skins.is_empty():
		chest_result_label.text = "ALL %s REWARDS UNLOCKED!" % tier_name
		return
	if wallet_coins < cost:
		chest_result_label.text = "NEED %d MORE COINS" % (cost - wallet_coins)
		return
	wallet_coins -= cost
	chest_target_skin = locked_skins.pick_random()
	chest_reward_pool = reward_pool
	chest_roll_elapsed = 0.0
	chest_next_tick = 0.0
	chest_rolling = true
	prepare_chest_carousel(reward_pool)
	chest_icon.texture = chest_texture
	chest_heading.text = "%s CHEST" % tier_name
	chest_description.text = description
	common_chest_button.disabled = true
	uncommon_chest_button.disabled = true
	shop_back_button.disabled = true
	shop_wallet_label.text = "COIN BANK: %d" % wallet_coins
	chest_preview.hide()
	chest_carousel_backdrop.show()
	chest_carousel.show()


func prepare_chest_carousel(reward_pool: Array[int]) -> void:
	for carousel_item in chest_carousel_items:
		carousel_item.queue_free()
	chest_carousel_items.clear()
	var item_spacing := 112.0
	chest_carousel_target_index = 24
	chest_carousel_final_offset = chest_carousel_target_index * item_spacing + 50.0 - chest_carousel.size.x * 0.5
	for item_index in range(30):
		var reward_id: int = reward_pool.pick_random()
		if item_index == chest_carousel_target_index:
			reward_id = chest_target_skin
		var carousel_item := TextureRect.new()
		carousel_item.texture = create_skin_texture(reward_id)
		carousel_item.position = Vector2(item_index * item_spacing, 10.0)
		carousel_item.size = Vector2(100.0, 110.0)
		carousel_item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		carousel_item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		carousel_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chest_carousel.add_child(carousel_item)
		chest_carousel_items.append(carousel_item)


func update_chest_carousel(progress: float) -> void:
	# Cubic ease-out gives the carousel a quick start and a satisfying slow landing.
	var eased_progress := 1.0 - pow(1.0 - progress, 3.0)
	var offset := chest_carousel_final_offset * eased_progress
	for item_index in range(chest_carousel_items.size()):
		chest_carousel_items[item_index].position.x = item_index * 112.0 - offset


func finish_chest() -> void:
	chest_rolling = false
	unlocked_skins.append(chest_target_skin)
	selected_skin = chest_target_skin
	chest_preview.texture = create_skin_texture(chest_target_skin)
	chest_preview.show()
	chest_carousel_backdrop.hide()
	chest_carousel.hide()
	chest_result_label.text = "UNLOCKED: %s!" % str(skin_definitions[chest_target_skin]["name"])
	apply_selected_skin()
	save_profile()
	update_coin_counter()
	shop_back_button.disabled = false
	build_skin_shop()


func open_shop() -> void:
	build_skin_shop()
	start_screen.hide()
	shop_screen.show()
	set_shop_tab("chests")


func close_shop() -> void:
	shop_screen.hide()
	start_screen.show()


func set_shop_tab(tab_name: String) -> void:
	var showing_chests := tab_name == "chests"
	common_chest_button.show() if showing_chests else common_chest_button.hide()
	chest_preview.show() if showing_chests else chest_preview.hide()
	chest_carousel_backdrop.show() if showing_chests and chest_rolling else chest_carousel_backdrop.hide()
	chest_carousel.show() if showing_chests and chest_rolling else chest_carousel.hide()
	chest_result_label.show() if showing_chests else chest_result_label.hide()
	skin_catalog.hide()
	chest_icon.show() if showing_chests else chest_icon.hide()
	chest_card.show() if showing_chests else chest_card.hide()
	chest_heading.show() if showing_chests else chest_heading.hide()
	chest_description.show() if showing_chests else chest_description.hide()
	future_chest_row.show() if showing_chests else future_chest_row.hide()
	skin_list.show() if not showing_chests else skin_list.hide()
	chest_tab_button.disabled = showing_chests
	jelly_tab_button.disabled = not showing_chests


func _input(event: InputEvent) -> void:
	if not game_started or game_over:
		return

	# Mouse click on Windows
	if event is InputEventMouseButton:
		# Web browsers often emit a synthetic mouse event after a touchscreen event.
		# Ignore it so releasing a swing does not become an unwanted second "jump".
		if touch_gesture_active or Time.get_ticks_msec() - last_touch_event_msec < 500:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_hold()
			else:
				end_hold()

	# Touchscreen tap on iPhone
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_gesture_active = true
			start_hold()
		else:
			end_hold()
			touch_gesture_active = false
			last_touch_event_msec = Time.get_ticks_msec()


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
	if jump_cooldown_remaining > 0.0:
		return
	is_swinging = false
	swing_anchor = null
	velocity = Vector2.UP * launch_speed
	was_on_floor = false
	jump_cooldown_remaining = jump_cooldown

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

	# Bright rolling embers make the lethal floor immediately readable as lava.
	for ember_x in range(0, int(map_width), 56):
		var ember_y := floor_y - 7.0 + sin(world_elapsed * 3.0 + float(ember_x) * 0.08) * 8.0
		draw_circle(Vector2(float(ember_x), ember_y), 11.0, Color("ffb11f"))

	# Draw the tether only while Jelly is swinging.
	if not is_instance_valid(block):
		return

	var origin = block.position + block.size / 2.0
	if is_swinging and is_instance_valid(swing_anchor):
		draw_line(swing_anchor.global_position, origin, Color.BLACK, 6.0, true)

	# Friendly bots use thinner lavender tethers so they read as background activity.
	for bot_node in bot_swings.get_children():
		var bot := bot_node as Node2D
		if bot and not bool(bot.get_meta("rope_cut")):
			var bot_anchor_position: Vector2 = bot.get_meta("from_anchor")
			draw_line(bot_anchor_position, bot.global_position, Color(0.24, 0.12, 0.39, 0.72), 3.0, true)


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



extends Node2D



const PURPLE_ORB_TEXTURE := preload("res://images/purple_swing_orb.png")

const BAT_TEXTURE := preload("res://images/chase_bat.png")

const ROCKET_TEXTURE := preload("res://images/rocket_powerup.png")

const TELEPORT_TEXTURE := preload("res://images/teleport_powerup.png")

const MAGNET_TEXTURE := preload("res://images/magnet_powerup.png")

const KNIFE_TEXTURE := preload("res://images/knife_powerup.png")

const COMMON_CHEST_TEXTURE := preload("res://images/common_chest.png")
const UNCOMMON_CHEST_TEXTURE := preload("res://images/uncommon_chest.png")
# Audio sources and licences: sounds/CREDITS.md
const BACKGROUND_MUSIC := preload("res://sounds/music_1.mp3")
const BACKGROUND_MUSIC_ALT := preload("res://sounds/music_2.mp3")
const JUMP_SOUND := preload("res://sounds/jump.mp3")
const BOUNCE_SOUND := preload("res://sounds/bounce.mp3")
const SWOOSH_SOUND := preload("res://sounds/swing.mp3")
const ACTION_SOUND := preload("res://sounds/bat_defeat.mp3")
const GAME_OVER_SOUND := preload("res://sounds/game_over.mp3")
const JETPACK_SOUND := preload("res://sounds/powerup.mp3")
const COLLECT_SOUND := preload("res://sounds/coin.mp3")
const WHEEL_SPIN_SOUND := preload("res://sounds/wheel_spin.mp3")
const SUCCESS_SOUND := preload("res://sounds/success.mp3")
const REVIVE_SOUND := preload("res://sounds/revive.mp3")
const BUTTON_SOUND := preload("res://sounds/button.mp3")
const SCORE_SAVE_PATH := "user://gravity_tax_scores.cfg"
# Tests point this at a throwaway file so they never touch a real save.
var save_path := SCORE_SAVE_PATH
const MMCQ_LAB_LOGO := preload("res://images/mmcq_lab_logo.png")



@onready var block: ColorRect = $Block

@onready var floor_rect: ColorRect = $Floor

@onready var camera: Camera2D = $Camera2D

@onready var swing_anchors: Node2D = $SwingAnchors

@onready var coin_counter: Label = $HUD/CoinCounter

@onready var high_score_label: Label = $HUD/HighScore

@onready var height_score_label: Label = $HUD/HeightScore

@onready var level_label: Label = $HUD/LevelIndicator

@onready var bats: Node2D = $Bats

@onready var power_ups: Node2D = $PowerUps

@onready var blade_orbit: Node2D = $BladeOrbit

@onready var swing_rope: Line2D = $SwingRope

@onready var bot_swings: Node2D = $BotSwings

@onready var game_over_screen: ColorRect = $HUD/GameOverScreen

@onready var game_over_best_label: Label = $HUD/GameOverScreen/GameOverBest

@onready var restart_button: Button = $HUD/GameOverScreen/RestartButton

@onready var main_menu_button: Button = $HUD/GameOverScreen/MainMenuButton

@onready var power_message: Label = $HUD/PowerMessage

@onready var kill_counter: Label = $HUD/KillCounter

@onready var start_screen: ColorRect = $HUD/StartScreen

@onready var start_button: Button = $HUD/StartScreen/StartButton

@onready var climb_button: Button = $HUD/StartScreen/ClimbButton

@onready var tag_button: Button = $HUD/StartScreen/TagButton

@onready var tag_status_label: Label = $HUD/TagStatus

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

@onready var skin_scroll: ScrollContainer = $HUD/ShopScreen/SkinScroll

@onready var skin_list: GridContainer = $HUD/ShopScreen/SkinScroll/SkinList

@onready var chest_tab_button: Button = $HUD/ShopScreen/ChestTabButton

@onready var jelly_tab_button: Button = $HUD/ShopScreen/JellyTabButton

@onready var coins_tab_button: Button = $HUD/ShopScreen/CoinsTabButton

@onready var skin_catalog: TextureRect = $HUD/ShopScreen/SkinCatalog

@onready var chest_icon: TextureRect = $HUD/ShopScreen/ChestIcon

@onready var chest_card: ColorRect = $HUD/ShopScreen/ChestCard

@onready var chest_heading: Label = $HUD/ShopScreen/ChestHeading

@onready var chest_description: Label = $HUD/ShopScreen/ChestDescription

@onready var future_chest_row: Control = $HUD/ShopScreen/FutureChestRow

@onready var common_chest_button: Button = $HUD/ShopScreen/CommonChestButton

@onready var common_chest_picker: TextureButton = $HUD/ShopScreen/FutureChestRow/Common

@onready var uncommon_chest_button: TextureButton = $HUD/ShopScreen/FutureChestRow/Uncommon

@onready var rare_chest_picker: TextureButton = $HUD/ShopScreen/FutureChestRow/Rare

@onready var epic_chest_picker: TextureButton = $HUD/ShopScreen/FutureChestRow/Epic

@onready var legendary_chest_picker: TextureButton = $HUD/ShopScreen/FutureChestRow/Legendary

@onready var chest_result_label: Label = $HUD/ShopScreen/ChestResult

@onready var chest_preview: TextureRect = $HUD/ShopScreen/ChestPreview

@onready var chest_carousel_backdrop: ColorRect = $HUD/ShopScreen/ChestCarouselBackdrop

@onready var chest_carousel: Control = $HUD/ShopScreen/ChestCarousel

@onready var ad_panel: ColorRect = $HUD/ShopScreen/AdPanel

@onready var ad_reward_button: Button = $HUD/ShopScreen/AdPanel/AdRewardButton

@onready var ad_status_label: Label = $HUD/ShopScreen/AdPanel/AdStatus



# World dimensions are intentionally much larger than the phone viewport.

var map_width: float = 12000.0

var floor_y: float = 9000.0

# Sky Climb is split into tall, replayable courses. Height is banked at each
# finish line so the score remains a single uninterrupted climb total.
const CLIMB_LEVEL_HEIGHT := 16000.0
const LAVA_JAM_COLOR := Color("ff7a3d")
const CLIMB_SKY_CHAIN: Array[Color] = [
	Color("e3f3ff"), Color("9ad7ff"), Color("b8c4ff"),
	Color("a8ecdf"), Color("ffe1a8"), Color("c6eaff"),
]
const CLIMB_LEVEL_TOP_Y := 220.0
var climb_level := 1
var climb_height_bank := 0

var jelly_swipe_tracking := false

var jelly_swipe_last_y := 0.0

var jelly_swipe_distance := 0.0

var jelly_swipe_release_msec := 0

var sky_top_color := Color("9ad7ff")

var sky_bottom_color := Color("e3f3ff")

var anchor_count := 560

var coin_count := 180

var coin_positions: Array[Vector2] = []

var big_coin_count := 34

var big_coin_positions: Array[Vector2] = []

var bounce_pad_count := 105

var bounce_pad_positions: Array[Vector2] = []

var bounce_pad_size := Vector2(130.0, 17.0)

var bounce_pad_launch_speed := 980.0

var bounce_pad_next_trigger_time := 0.0

var highest_generated_pad_y := 0.0

var run_start_height_y := 0.0

var coins_collected := 0

var high_score := 0

var height_score := 0

var best_height_score := 0

var coin_high_score := 0

var climb_high_score := 0

var active_game_mode := "COIN"

var wallet_coins := 0

var selected_skin := 0

var unlocked_skins: Array[int] = [0]

var jelly_sprite_textures: Array[Texture2D] = []

var skin_definitions: Array[Dictionary] = [

	{"name": "Ruby Jelly", "tier": "Common"},

	{"name": "Tangerine Jelly", "tier": "Common"},

	{"name": "Sunny Jelly", "tier": "Common"},

	{"name": "Lime Jelly", "tier": "Common"},

	{"name": "Ocean Jelly", "tier": "Common"},

	{"name": "Bubblegum Jelly", "tier": "Common"},

	{"name": "Grape Jelly", "tier": "Common"},

	{"name": "Aqua Jelly", "tier": "Common"},

	{"name": "Marshmallow Jelly", "tier": "Common"},

	{"name": "Midnight Jelly", "tier": "Common"},

	{"name": "Fox Jelly", "tier": "Uncommon"},

	{"name": "Panda Jelly", "tier": "Uncommon"},

	{"name": "Kitten Jelly", "tier": "Uncommon"},

	{"name": "Bunny Jelly", "tier": "Uncommon"},

	{"name": "Tiger Jelly", "tier": "Uncommon"},

	{"name": "Penguin Jelly", "tier": "Uncommon"},

	{"name": "Axolotl Jelly", "tier": "Uncommon"},

	{"name": "Monkey Jelly", "tier": "Uncommon"},

	{"name": "Koala Jelly", "tier": "Uncommon"},

	{"name": "Lion Jelly", "tier": "Uncommon"},

	{"name": "Strawberry Jelly", "tier": "Rare"},

	{"name": "Watermelon Jelly", "tier": "Rare"},

	{"name": "Cherry Cupcake Jelly", "tier": "Rare"},

	{"name": "Donut Jelly", "tier": "Rare"},

	{"name": "Sushi Jelly", "tier": "Rare"},

	{"name": "Chocolate Jelly", "tier": "Rare"},

	{"name": "Mint Chip Jelly", "tier": "Rare"},

	{"name": "Honey Jelly", "tier": "Rare"},

	{"name": "Sprinkle Cupcake Jelly", "tier": "Rare"},

	{"name": "Boba Jelly", "tier": "Rare"},

	{"name": "Sun Hat Jelly", "tier": "Epic"},

	{"name": "Cash Stack Jelly", "tier": "Epic"},

	{"name": "Masked Hero Jelly", "tier": "Epic"},

	{"name": "Pixel Block Jelly", "tier": "Epic"},

	{"name": "Galaxy Jelly", "tier": "Epic"},

	{"name": "Ice Crystal Jelly", "tier": "Epic"},

	{"name": "Sprout Jelly", "tier": "Epic"},

	{"name": "Magma Jelly", "tier": "Epic"},

	{"name": "Cloud Jelly", "tier": "Epic"},

	{"name": "Arcade Bot Jelly", "tier": "Epic"},

	{"name": "Neon Bot Jelly", "tier": "Legendary"},

	{"name": "Demon King Jelly", "tier": "Legendary"},

	{"name": "Forest Dragon Jelly", "tier": "Legendary"},

	{"name": "Cosmic Knight Jelly", "tier": "Legendary"},

	{"name": "Hooded Mech Jelly", "tier": "Legendary"},

	{"name": "Pirate Captain Jelly", "tier": "Legendary"},

	{"name": "Star Mushroom Jelly", "tier": "Legendary"},

	{"name": "Sky Knight Jelly", "tier": "Legendary"},

	{"name": "Shadow Knight Jelly", "tier": "Legendary"},

	{"name": "Moon Mage Jelly", "tier": "Legendary"}

]

var bot_names: Array[String] = ["Bloop", "Mochi", "Pip", "Zing", "Wobble", "Nori", "Fizz", "Taffy", "Pebble", "Comet", "Pogo", "Doodle"]

var common_chest_cost := 50

var uncommon_chest_cost := 100

var selected_chest_tier := "COMMON"

var chest_definitions: Dictionary = {

	"COMMON": {"cost": 50, "rewards": [1, 2, 3, 4, 5, 6, 7, 8, 9], "texture": COMMON_CHEST_TEXTURE, "description": "Guaranteed new classic Jelly skin", "available": true},

	"UNCOMMON": {"cost": 100, "rewards": [10, 11, 12, 13, 14, 15, 16, 17, 18, 19], "texture": UNCOMMON_CHEST_TEXTURE, "description": "Guaranteed cute animal Jelly", "available": true},

	"RARE": {"cost": 175, "rewards": [20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "texture": preload("res://images/rare_chest.png"), "description": "Guaranteed new food Jelly skin", "available": true},

	"EPIC": {"cost": 250, "rewards": [30, 31, 32, 33, 34, 35, 36, 37, 38, 39], "texture": preload("res://images/epic_chest.png"), "description": "Guaranteed new epic Jelly skin", "available": true},

	"LEGENDARY": {"cost": 500, "rewards": [40, 41, 42, 43, 44, 45, 46, 47, 48, 49], "texture": preload("res://images/legendary_chest.png"), "description": "Guaranteed new legendary Jelly skin", "available": true}

}

var chest_rolling := false

var chest_roll_elapsed := 0.0

var chest_next_tick := 0.0

var chest_target_skin := 0

var chest_reward_pool: Array[int] = []
# A spun chest's Jelly waits here until the player claims it (or rerolls once
# by watching an ad). -1 means nothing is waiting.
var chest_pending_skin := -1
var chest_reroll_used := false
var chest_claim_button: Button
var chest_reroll_button: Button
var banner_ad: PlaceholderBanner
var ad_manager: JellyAdManager
var pending_reward_action := ""
var reward_action_completed := false
var chest_carousel_items: Array[TextureButton] = []

var chest_carousel_target_index := 24

var chest_carousel_final_offset := 0.0

var redraw_timer := 0.0

var bot_rope_check_timer := 0.0

var leaderboard_update_timer := 0.0

var bat_count := 28

var swing_bot_count := 42

var bat_chase_speed := 540.0

var bat_wake_radius := 120.0

var bat_attack_radius := 48.0

var bat_arm_delay := 0.18
const BAT_CHASE_DURATION := 10.0
const BAT_REENGAGE_DELAY := 2.0

var rocket_count := 34

var teleport_count := 12

var magnet_count := 12

var knife_count := 10

var world_elapsed := 0.0

var game_over := false

# Death flow: lucky spin, one continue per run, and a standard interstitial
# opportunity after every third finalized death.
const INTERSTITIAL_EVERY_GAME_OVERS := 3
const REVIVE_SHIELD_SECONDS := 3.0
var revive_shield_time := 0.0
var continue_used_this_run := false
var game_overs_since_ad := 0
var game_over_finalized := false
var ad_audio_muted := false

# Gameplay sprites were authored at 1254px but are drawn at 30-100px. They are
# imported at a reduced size to save memory, so scales are derived from the
# imported width to keep the on-screen size identical.
const ART_DESIGN_WIDTH := 1254.0
var orb_scale := 0.025
var bat_scale := 0.075
var power_up_scale := 0.052
# Player settings (saved with the profile).
const SAVE_VERSION := 2
var music_volume := 0.8
var sfx_volume := 0.9
var audio_muted := false
var settings_panel: SettingsPanel
var pause_button: Button
var settings_button: Button
var safe_area_top := 0.0
var safe_area_bottom := 0.0
# Space reserved at the bottom of menus for the banner (canvas pixels).
var banner_reserved_height := PlaceholderBanner.HEIGHT
var toast_label: Label
var continue_button: Button
var game_over_card: Panel

var game_started := false

var power_message_time := 0.0

var magnet_time := 0.0

var knife_time := 0.0

var knife_angle := 0.0

var bat_kills := 0

var orbiting_knives: Array[Sprite2D] = []

var previous_player_center := Vector2.ZERO

var jelly_base_scale := Vector2.ONE

var jelly_collision_next_time := 0.0

var tag_holders: Array[Node] = []
var tag_times: Dictionary = {}
var tag_chaser: Node2D
var tag_transfer_cooldown_until := 0.0
# Tag AI: each IT racer hunts a target; safe racers flee nearby IT racers.
const TAG_HUNT_RADIUS := 2600.0
const TAG_FLEE_RADIUS := 520.0
const TAG_MAX_PLAYER_HUNTERS := 2
const TAG_WIN_BONUS := 50
const TAG_BOT_SPEED_CAP := 1300.0
var tag_ai_timer := 0.0
var tag_round_won := false
const TAG_TIMEOUT_SECONDS := 15.0
const TAG_HOLDER_COUNT := 4

var background_music_player: AudioStreamPlayer

var jump_sound_player: AudioStreamPlayer

var bounce_sound_player: AudioStreamPlayer

var swoosh_sound_player: AudioStreamPlayer

var action_sound_player: AudioStreamPlayer

var game_over_sound_player: AudioStreamPlayer

var jetpack_sound_player: AudioStreamPlayer

var collect_sound_player: AudioStreamPlayer
var wheel_spin_sound_player: AudioStreamPlayer
var success_sound_player: AudioStreamPlayer
var revive_sound_player: AudioStreamPlayer
var button_sound_player: AudioStreamPlayer
# Movement settings

var gravity: float = 500.0

var velocity: Vector2 = Vector2.ZERO

var launch_speed: float = 460.0

var jump_cooldown: float = 0.55

var jump_cooldown_remaining := 0.0

var floor_bounce: float = 0.46

var wall_bounce: float = 0.9
# Side walls are springy: anything hitting them leaves with at least this speed.
const WALL_MIN_REBOUND := 420.0
const PLAYER_NAME_MAX := 12
var player_name := ""
var wall_bounce_sound_next := 0.0

var minimum_bounce_speed: float = 75.0



# Swing settings

var is_swinging := false

var swing_anchor: Sprite2D

var swing_rope_length := 0.0

var swing_boost_per_second := 350.0

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
var studio_intro_played := false





func _ready() -> void:
	orb_scale = art_scale(PURPLE_ORB_TEXTURE, 0.025)
	bat_scale = art_scale(BAT_TEXTURE, 0.075)
	power_up_scale = art_scale(ROCKET_TEXTURE, 0.052)
	randomize()



	# Place the floor deep within the larger world.

	floor_rect.position = Vector2(0, floor_y)

	floor_rect.size = Vector2(map_width, 120)

	floor_rect.color = LAVA_JAM_COLOR



	# Rotate and squash around the block's center

	block.pivot_offset = block.size / 2.0

	jelly_sprite.position = block.size * 0.5



	# Begin with the block upright

	block.rotation = 0.0

	block.scale = Vector2.ONE

	setup_audio()

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

	height_score_label.hide()

	level_label.hide()

	tag_status_label.hide()

	leaderboard_panel.hide()

	shop_screen.hide()

	power_message.hide()

	setup_orbiting_knives()

	update_kill_counter()

	previous_player_center = get_player_center()

	restart_button.pressed.connect(restart_game)

	main_menu_button.pressed.connect(return_to_main_menu)

	start_button.pressed.connect(select_game_mode.bind("COIN"))

	climb_button.pressed.connect(select_game_mode.bind("CLIMB"))

	tag_button.pressed.connect(select_game_mode.bind("TAG"))

	shop_button.pressed.connect(open_shop)

	shop_back_button.pressed.connect(close_shop)

	common_chest_button.pressed.connect(open_selected_chest)

	common_chest_picker.pressed.connect(select_chest.bind("COMMON"))

	uncommon_chest_button.pressed.connect(select_chest.bind("UNCOMMON"))

	rare_chest_picker.pressed.connect(select_chest.bind("RARE"))

	epic_chest_picker.pressed.connect(select_chest.bind("EPIC"))

	legendary_chest_picker.pressed.connect(select_chest.bind("LEGENDARY"))

	chest_tab_button.pressed.connect(set_shop_tab.bind("chests"))

	jelly_tab_button.pressed.connect(set_shop_tab.bind("jellies"))

	coins_tab_button.pressed.connect(set_shop_tab.bind("coins"))

	ad_reward_button.pressed.connect(claim_test_ad_reward)
	ad_manager = JellyAdManager.new()
	add_child(ad_manager)
	ad_manager.banner_height_changed.connect(_on_real_banner_height)
	ad_manager.reward_earned.connect(_on_admob_reward_earned)
	ad_manager.rewarded_finished.connect(_on_admob_rewarded_finished)
	ad_manager.fullscreen_started.connect(func() -> void:
		ad_audio_muted = true
		apply_audio_settings()
	)
	ad_manager.fullscreen_finished.connect(func() -> void:
		ad_audio_muted = false
		apply_audio_settings()
	)

	skin_scroll.scroll_deadzone = 8

	build_skin_shop()

	select_chest("COMMON")
	apply_cute_ui()
	build_pause_and_settings()
	apply_wide_layout()
	apply_safe_area()
	apply_audio_settings()
	call_deferred("show_studio_intro")





func apply_cute_ui() -> void:
	# One pastel, rounded, squishy look for every screen. Layout positions from
	# game.tscn are kept; this only restyles and adds a few small extras.
	var hud := $HUD
	var cute_theme := CuteStyle.make_theme()
	for child in hud.get_children():
		if child is Control:
			(child as Control).theme = cute_theme

	# In-game HUD: candy pills that stay readable over any sky colour.
	CuteStyle.pill_label(coin_counter, Color(CuteStyle.BUTTER, 0.95), CuteStyle.INK)
	coin_counter.add_theme_font_size_override("font_size", 25)
	coin_counter.position = Vector2(20.0, 22.0)
	coin_counter.size = Vector2(300.0, 50.0)
	CuteStyle.pill_label(high_score_label, Color(CuteStyle.WHITE, 0.88), CuteStyle.INK_SOFT)
	high_score_label.add_theme_font_size_override("font_size", 20)
	high_score_label.position = Vector2(20.0, 80.0)
	high_score_label.size = Vector2(250.0, 40.0)
	CuteStyle.pill_label(kill_counter, Color(CuteStyle.LAVENDER, 0.92), CuteStyle.WHITE)
	kill_counter.add_theme_font_size_override("font_size", 20)
	kill_counter.position = Vector2(20.0, 128.0)
	kill_counter.size = Vector2(160.0, 40.0)
	CuteStyle.pill_label(height_score_label, Color(CuteStyle.SKY, 0.95), CuteStyle.WHITE)
	height_score_label.add_theme_color_override("font_outline_color", Color("3f8fc4"))
	height_score_label.add_theme_constant_override("outline_size", 6)
	# Sky Climb's height and level sit top-right (the leaderboard spot is only used in Coin Run).
	height_score_label.anchor_left = 1.0
	height_score_label.anchor_right = 1.0
	height_score_label.offset_left = -200.0
	height_score_label.offset_right = -20.0
	height_score_label.offset_top = 22.0
	height_score_label.offset_bottom = 74.0
	CuteStyle.pill_label(level_label, Color(CuteStyle.ACCENT, 0.95), CuteStyle.WHITE)
	level_label.add_theme_font_size_override("font_size", 19)
	level_label.anchor_left = 1.0
	level_label.anchor_right = 1.0
	level_label.offset_left = -170.0
	level_label.offset_right = -50.0
	level_label.offset_top = 82.0
	level_label.offset_bottom = 116.0
	CuteStyle.pill_label(tag_status_label, Color(CuteStyle.PEACH, 0.95), CuteStyle.INK)
	# Keep the IT list clear of the centred pause button.
	tag_status_label.position.x = 420.0
	tag_status_label.size.x = 280.0
	CuteStyle.style_label(power_message, CuteStyle.ACCENT, 36, CuteStyle.WHITE, 10)
	# Below the leaderboard so pop-up messages never cover it.
	power_message.position.y = 245.0
	CuteStyle.round_panel(leaderboard_panel, Color(CuteStyle.WHITE, 0.82), Color(CuteStyle.SKY, 0.9), 3, 24)
	CuteStyle.style_label(leaderboard_label, CuteStyle.INK, 20)

	# Gameplay touches: an orange candy rope with rounded ends.
	swing_rope.default_color = Color("ff9248")
	swing_rope.width = 7.0
	swing_rope.begin_cap_mode = Line2D.LINE_CAP_ROUND
	swing_rope.end_cap_mode = Line2D.LINE_CAP_ROUND

	# Main menu: keep the illustrated background, swap in gummy buttons.
	CuteStyle.style_button(start_button, CuteStyle.MINT)
	CuteStyle.style_button(climb_button, CuteStyle.SKY)
	CuteStyle.style_button(tag_button, CuteStyle.PEACH)
	CuteStyle.style_button(shop_button, CuteStyle.ACCENT)
	menu_wallet_label.show()
	menu_wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CuteStyle.pill_label(menu_wallet_label, Color(CuteStyle.BUTTER, 0.95), CuteStyle.INK)
	menu_wallet_label.add_theme_font_size_override("font_size", 22)
	menu_wallet_label.position = Vector2(230.0, 1205.0)
	menu_wallet_label.size = Vector2(260.0, 44.0)

	# Game over: soft blue veil with a rounded cream card.
	game_over_screen.color = Color(CuteStyle.SKY.lerp(CuteStyle.LAVENDER, 0.5), 0.55)
	game_over_card = Panel.new()
	game_over_card.name = "CuteCard"
	game_over_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over_card.position = Vector2(70.0, 190.0)
	game_over_card.size = Vector2(580.0, 560.0)
	game_over_card.add_theme_stylebox_override("panel", CuteStyle.box(CuteStyle.CREAM, 44, CuteStyle.WHITE, 6, 0.3))
	game_over_screen.add_child(game_over_card)
	game_over_screen.move_child(game_over_card, 0)
	var game_over_title := game_over_screen.get_node("GameOver") as Label
	game_over_title.text = "OOPS!"
	CuteStyle.style_label(game_over_title, CuteStyle.ACCENT, 58, CuteStyle.WHITE, 10)
	CuteStyle.style_label(game_over_best_label, CuteStyle.INK, 28)
	CuteStyle.style_label(game_over_run_label, CuteStyle.INK_SOFT, 21)
	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = "CONTINUE  (WATCH AD)"
	continue_button.position = Vector2(150.0, 432.0)
	continue_button.size = Vector2(420.0, 84.0)
	continue_button.add_theme_font_size_override("font_size", 26)
	CuteStyle.style_button(continue_button, CuteStyle.BUTTER, CuteStyle.INK)
	continue_button.pressed.connect(_on_continue_pressed)
	game_over_screen.add_child(continue_button)
	restart_button.position = Vector2(190.0, 536.0)
	restart_button.size = Vector2(340.0, 80.0)
	main_menu_button.position = Vector2(230.0, 636.0)
	main_menu_button.size = Vector2(260.0, 66.0)
	CuteStyle.style_button(restart_button, CuteStyle.MINT)
	CuteStyle.style_button(main_menu_button, CuteStyle.LAVENDER)

	# Shop / collection.
	CuteStyle.gradient_backdrop(shop_screen, Color("d6efff"), Color("dcf7ee"))
	var shop_title := shop_screen.get_node("Title") as Label
	CuteStyle.style_label(shop_title, CuteStyle.ACCENT, 56, CuteStyle.WHITE, 12)
	CuteStyle.style_label(shop_wallet_label, CuteStyle.INK, 26)
	CuteStyle.style_tab(chest_tab_button, CuteStyle.PEACH)
	CuteStyle.style_tab(jelly_tab_button, CuteStyle.LAVENDER)
	CuteStyle.style_tab(coins_tab_button, CuteStyle.MINT)
	CuteStyle.style_button(shop_back_button, CuteStyle.LAVENDER)
	CuteStyle.style_button(common_chest_button, CuteStyle.ACCENT)
	CuteStyle.round_panel(chest_card, CuteStyle.CREAM, CuteStyle.WHITE, 5, 40)
	CuteStyle.round_panel(chest_carousel_backdrop, Color("eaf2ff"), Color(CuteStyle.SKY, 0.8), 3, 22)
	CuteStyle.style_label(chest_heading, CuteStyle.ACCENT, 32)
	CuteStyle.style_label(chest_description, CuteStyle.INK_SOFT, 19)
	CuteStyle.style_label(chest_result_label, CuteStyle.INK, 18)
	CuteStyle.style_label(future_chest_row.get_node("Title") as Label, CuteStyle.INK, 18)
	# Chest labels show each tier's price in its rarity colour.
	for tier_name in ["COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY"]:
		var tier_label := future_chest_row.get_node(tier_name.capitalize() + "Label") as Label
		tier_label.text = "%s • %d" % [tier_name, int(chest_definitions[tier_name]["cost"])]
		CuteStyle.style_label(tier_label, CuteStyle.rarity_color(tier_name).darkened(0.15), 14)
	for chest_picker in [common_chest_picker, uncommon_chest_button, rare_chest_picker, epic_chest_picker, legendary_chest_picker]:
		CuteStyle.add_squish(chest_picker)
	chest_claim_button = Button.new()
	chest_claim_button.name = "ClaimButton"
	chest_claim_button.text = "CLAIM"
	chest_claim_button.position = Vector2(105.0, 815.0)
	chest_claim_button.size = Vector2(210.0, 70.0)
	chest_claim_button.add_theme_font_size_override("font_size", 26)
	CuteStyle.style_button(chest_claim_button, CuteStyle.MINT)
	chest_claim_button.pressed.connect(claim_pending_chest)
	chest_claim_button.hide()
	shop_screen.add_child(chest_claim_button)
	chest_reroll_button = Button.new()
	chest_reroll_button.name = "RerollButton"
	chest_reroll_button.text = "REROLL (WATCH AD)"
	chest_reroll_button.position = Vector2(330.0, 815.0)
	chest_reroll_button.size = Vector2(285.0, 70.0)
	chest_reroll_button.add_theme_font_size_override("font_size", 20)
	CuteStyle.style_button(chest_reroll_button, CuteStyle.BUTTER, CuteStyle.INK)
	chest_reroll_button.pressed.connect(reroll_pending_chest)
	chest_reroll_button.hide()
	shop_screen.add_child(chest_reroll_button)

	# Bottom banner ad space. Menu buttons move up so nothing hides behind it.
	banner_ad = PlaceholderBanner.new()
	add_child(banner_ad)
	for mode_button in [start_button, climb_button, tag_button]:
		mode_button.position.y = 890.0
	shop_button.position.y = 1005.0
	menu_wallet_label.position.y = 1106.0
	shop_back_button.position.y = 1082.0

	CuteStyle.round_panel(ad_panel, CuteStyle.CREAM, CuteStyle.WHITE, 5, 40)
	var ad_title := ad_panel.get_node("Title") as Label
	CuteStyle.style_label(ad_title, CuteStyle.ACCENT, 40)
	var ad_description := ad_panel.get_node("Description") as Label
	ad_description.text = "Watch a short ad\nfor free coins!"
	CuteStyle.style_label(ad_description, CuteStyle.INK_SOFT, 24)
	CuteStyle.style_button(ad_reward_button, CuteStyle.BUTTER, CuteStyle.INK)
	CuteStyle.style_label(ad_status_label, CuteStyle.INK_SOFT, 18)
	ad_status_label.text = "Watch a short video ad" if OS.has_feature("ios") else "Placeholder ad (real ads on iPhone)"





func build_pause_and_settings() -> void:
	settings_panel = SettingsPanel.new()
	settings_panel.credits_text = build_credits_text()
	add_child(settings_panel)
	settings_panel.settings_changed.connect(_on_settings_changed)
	settings_panel.name_changed.connect(set_player_name)
	settings_panel.resume_requested.connect(resume_game)
	settings_panel.home_requested.connect(func() -> void:
		get_tree().paused = false
		return_to_main_menu()
	)

	# Pause button sits top-centre during a run, clear of the score pills.
	pause_button = Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = "II"
	pause_button.set_anchors_preset(Control.PRESET_CENTER_TOP)
	pause_button.offset_left = -36.0
	pause_button.offset_right = 36.0
	pause_button.offset_top = 20.0
	pause_button.offset_bottom = 92.0
	pause_button.add_theme_font_size_override("font_size", 28)
	CuteStyle.style_button(pause_button, CuteStyle.ACCENT)
	pause_button.pressed.connect(pause_game)
	pause_button.hide()
	$HUD.add_child(pause_button)

	# Settings gear on the main menu.
	settings_button = Button.new()
	settings_button.name = "SettingsButton"
	settings_button.text = "SETTINGS"
	settings_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	settings_button.offset_left = -196.0
	settings_button.offset_right = -20.0
	settings_button.offset_top = 20.0
	settings_button.offset_bottom = 82.0
	settings_button.add_theme_font_size_override("font_size", 20)
	CuteStyle.style_button(settings_button, CuteStyle.LAVENDER)
	settings_button.pressed.connect(func() -> void:
		settings_panel.open(false, music_volume, sfx_volume, audio_muted, player_name)
	)
	start_screen.add_child(settings_button)





func build_credits_text() -> String:
	var lines: Array[String] = [
		"JELLY SWING ARCADE",
		"Made by MMCQ-Lab.",
		"",
		"MUSIC & SOUND EFFECTS",
		"All music and sound effects are from Pixabay, used under the Pixabay Content License (pixabay.com/service/license-summary).",
		"Music: \"Retro Game\" by the_mountain; \"Retro Arcade Game Music\" by arpmedia.",
		"Sound effects: \"Jump Sound\" by Bestuploadsever67aryan; \"Simple Whoosh\" by DRAGON-STUDIO; \"8-bit Jump 001\" by EdR; \"Retro coin 3\" by Driken5482; \"power up (Type 1)\" by RibhavAgrawal; \"Hurt sound\" by Stepir44; \"Marimba Game Over\" and \"Computer Mouse Click\" by Universfield; \"Wheel Spin Click Slow Down\" by pooky1, \"Success 1\" by Leszek_Szary and \"AHHHH\" by random_intruder (Freesound community).",
		"",
		"ENGINE",
		"Made with the Godot Engine (godotengine.org).",
		"",
		Engine.get_license_text(),
	]
	# Third-party components bundled inside the engine.
	var components := Engine.get_copyright_info()
	if not components.is_empty():
		lines.append("")
		lines.append("THIRD-PARTY COMPONENTS")
		for component in components:
			lines.append("%s" % str(component.get("name", "")))
	return "\n".join(lines)





func pause_game() -> void:
	if not game_started or game_over or get_tree().paused:
		return
	is_pointer_held = false
	write_save()
	get_tree().paused = true
	settings_panel.open(true, music_volume, sfx_volume, audio_muted, player_name)





func resume_game() -> void:
	settings_panel.close()
	get_tree().paused = false
	is_pointer_held = false
	touch_gesture_active = false
	last_touch_event_msec = Time.get_ticks_msec()





func _notification(what: int) -> void:
	# Phones can background the app at any moment: save, and pause a live run
	# so the player returns to a pause menu instead of an instant death.
	if not is_node_ready():
		return
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_CLOSE_REQUEST:
			write_save()
			pause_game()





func apply_wide_layout() -> void:
	# The UI is laid out for a 720px-wide portrait canvas. On wider screens
	# (iPad, ~960px canvas) centre the menus and keep right-hand HUD items at
	# the right edge instead of leaving everything hugging the left.
	var canvas_size := get_viewport().get_visible_rect().size
	var extra_width := canvas_size.x - 720.0
	if extra_width <= 1.0:
		return
	var half := extra_width * 0.5
	var full_rect_names := ["JellySky", "ReadabilityVeil", "CuteGradient", "CuteBackground", "SettingsButton"]
	for screen in [start_screen, shop_screen, game_over_screen]:
		for child in screen.get_children():
			if child is Control and not full_rect_names.has(str(child.name)):
				(child as Control).position.x += half
	for right_control in [leaderboard_panel, tag_status_label]:
		(right_control as Control).position.x += extra_width
	power_message.position.x += half
	# Keep the menu art's logo visible: fill the width and crop from the bottom.
	var menu_art := start_screen.get_node_or_null("JellySky") as TextureRect
	if menu_art and menu_art.texture:
		var art_size := menu_art.texture.get_size()
		var fitted_height := canvas_size.x * art_size.y / art_size.x
		if fitted_height > canvas_size.y:
			menu_art.set_anchors_preset(Control.PRESET_TOP_LEFT)
			menu_art.stretch_mode = TextureRect.STRETCH_SCALE
			menu_art.position = Vector2.ZERO
			menu_art.size = Vector2(canvas_size.x, fitted_height)





func _on_real_banner_height(height_pixels: float) -> void:
	# The real AdMob banner can be taller than the placeholder; convert its
	# screen-pixel height to game-canvas pixels and make room for it.
	var window_height := float(DisplayServer.window_get_size().y)
	if window_height <= 0.0:
		return
	var canvas_height := get_viewport().get_visible_rect().size.y
	banner_reserved_height = maxf(PlaceholderBanner.HEIGHT, height_pixels * canvas_height / window_height)
	fit_menus_above_banner()





func show_toast(message: String) -> void:
	# Small message that works on any screen, including while paused.
	if not toast_label:
		var toast_layer := CanvasLayer.new()
		toast_layer.layer = 160
		toast_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(toast_layer)
		toast_label = Label.new()
		toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		toast_label.offset_left = -300.0
		toast_label.offset_right = 300.0
		toast_label.offset_top = 150.0 + safe_area_top
		toast_label.offset_bottom = 210.0 + safe_area_top
		toast_label.theme = CuteStyle.make_theme()
		CuteStyle.pill_label(toast_label, Color(CuteStyle.INK, 0.9), CuteStyle.WHITE)
		toast_label.add_theme_font_size_override("font_size", 22)
		toast_layer.add_child(toast_label)
	toast_label.text = message
	toast_label.modulate.a = 1.0
	toast_label.show()
	var tween := toast_label.create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(toast_label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(toast_label.hide)





func fit_menus_above_banner() -> void:
	# Whatever the screen shape, nothing tappable on the menu or shop may sit
	# under the bottom banner: if the lowest control overlaps it, lift the
	# screen's content just enough (never above the top safe area).
	var canvas_height := get_viewport().get_visible_rect().size.y
	var banner_top := canvas_height - banner_reserved_height - safe_area_bottom - 12.0
	var skip_names := ["JellySky", "ReadabilityVeil", "CuteGradient", "CuteBackground", "SettingsButton"]
	for screen in [start_screen]:
		var lowest := -INF
		var highest := INF
		for child in screen.get_children():
			if child is Control and not skip_names.has(str(child.name)):
				var rect := (child as Control).get_rect()
				lowest = maxf(lowest, rect.end.y)
				highest = minf(highest, rect.position.y)
		var overlap := lowest - banner_top
		if overlap <= 0.0:
			continue
		var lift := minf(overlap, maxf(0.0, highest - safe_area_top - 8.0))
		for child in screen.get_children():
			if child is Control and not skip_names.has(str(child.name)):
				(child as Control).position.y -= lift





func apply_safe_area() -> void:
	# Push HUD and screen headers below the notch / Dynamic Island, and lift the
	# banner above the home indicator. Safe area is reported in screen pixels,
	# so convert to the 720-wide game canvas.
	# On desktop the "safe area" is the work area above the taskbar, which would
	# wrongly push the banner up over the buttons, so only phones/tablets use it.
	if not OS.has_feature("mobile"):
		fit_menus_above_banner()
		return
	var safe_rect := DisplayServer.get_display_safe_area()
	var screen_size := DisplayServer.screen_get_size()
	var canvas_size := get_viewport().get_visible_rect().size
	if safe_rect.size.y <= 0 or screen_size.y <= 0:
		return
	var to_canvas := canvas_size.y / float(screen_size.y)
	safe_area_top = clampf(float(safe_rect.position.y) * to_canvas, 0.0, 160.0)
	safe_area_bottom = clampf(float(screen_size.y - safe_rect.end.y) * to_canvas, 0.0, 120.0)
	if safe_area_top > 0.0:
		for hud_control in [coin_counter, high_score_label, kill_counter, height_score_label, level_label, tag_status_label, leaderboard_panel, power_message, pause_button]:
			(hud_control as Control).position.y += safe_area_top
		for shop_child in shop_screen.get_children():
			if shop_child is Control and shop_child.name != "CuteGradient":
				(shop_child as Control).position.y += safe_area_top
		settings_button.position.y += safe_area_top
	if banner_ad:
		banner_ad.set_bottom_inset(safe_area_bottom)
	fit_menus_above_banner()





func art_scale(texture: Texture2D, design_scale: float) -> float:
	return design_scale * ART_DESIGN_WIDTH / float(maxi(texture.get_width(), 1))





func show_studio_intro() -> void:
	# One brief studio card appears after the engine has finished booting.
	if studio_intro_played:
		return
	studio_intro_played = true
	var intro_layer := CanvasLayer.new()
	intro_layer.layer = 100
	var backdrop := ColorRect.new()
	backdrop.color = Color("070918")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	intro_layer.add_child(backdrop)
	var logo := TextureRect.new()
	logo.texture = MMCQ_LAB_LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.set_anchors_preset(Control.PRESET_CENTER)
	logo.offset_left = -155.0
	logo.offset_right = 155.0
	logo.offset_top = -230.0
	logo.offset_bottom = 80.0
	backdrop.add_child(logo)
	var studio_label := Label.new()
	studio_label.name = "StudioName"
	studio_label.text = "MMCQ-Lab™"
	studio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	studio_label.set_anchors_preset(Control.PRESET_CENTER)
	studio_label.offset_left = -300.0
	studio_label.offset_right = 300.0
	studio_label.offset_top = 100.0
	studio_label.offset_bottom = 160.0
	studio_label.add_theme_font_size_override("font_size", 44)
	studio_label.add_theme_color_override("font_color", Color.WHITE)
	backdrop.add_child(studio_label)
	# Green loading bar under the studio name.
	var bar_back := Panel.new()
	bar_back.set_anchors_preset(Control.PRESET_CENTER)
	bar_back.offset_left = -200.0
	bar_back.offset_right = 200.0
	bar_back.offset_top = 200.0
	bar_back.offset_bottom = 228.0
	bar_back.add_theme_stylebox_override("panel", CuteStyle.box(Color(1.0, 1.0, 1.0, 0.14), 14))
	backdrop.add_child(bar_back)
	var bar_fill := Panel.new()
	bar_fill.name = "LoadingBar"
	bar_fill.position = Vector2(4.0, 4.0)
	bar_fill.size = Vector2(0.0, 20.0)
	bar_fill.add_theme_stylebox_override("panel", CuteStyle.box(Color("3ddc6a"), 10))
	bar_back.add_child(bar_fill)
	add_child(intro_layer)
	# Starts fully visible so it continues straight on from the boot splash.
	var intro_tween := create_tween()
	intro_tween.tween_property(bar_fill, "size:x", 392.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	intro_tween.tween_interval(0.2)
	intro_tween.tween_property(backdrop, "modulate:a", 0.0, 0.35)
	intro_tween.tween_callback(intro_layer.queue_free)


func setup_audio() -> void:

	# Both possible music tracks are MP3 resources; make each repeat seamlessly.
	var music_streams: Array[AudioStream] = [BACKGROUND_MUSIC, BACKGROUND_MUSIC_ALT]
	for music_stream in music_streams:
		if music_stream is AudioStreamMP3:
			(music_stream as AudioStreamMP3).loop = true
	ensure_audio_buses()
	# Levels balanced from each file's measured loudness so no effect jumps out;
	# coins are a touch quieter because they play constantly.
	background_music_player = make_audio_player(BACKGROUND_MUSIC, -20.0, "Music")
	jump_sound_player = make_audio_player(JUMP_SOUND, -8.0)
	bounce_sound_player = make_audio_player(BOUNCE_SOUND, -20.0)
	swoosh_sound_player = make_audio_player(SWOOSH_SOUND, -7.0)
	action_sound_player = make_audio_player(ACTION_SOUND, -9.0)
	game_over_sound_player = make_audio_player(GAME_OVER_SOUND, -1.0)
	jetpack_sound_player = make_audio_player(JETPACK_SOUND, -7.0)
	collect_sound_player = make_audio_player(COLLECT_SOUND, -15.0)
	wheel_spin_sound_player = make_audio_player(WHEEL_SPIN_SOUND, 0.0)
	success_sound_player = make_audio_player(SUCCESS_SOUND, -2.0)
	revive_sound_player = make_audio_player(REVIVE_SOUND, -8.0)
	button_sound_player = make_audio_player(BUTTON_SOUND, 10.0)
	# Menu clicks must still sound while the game is paused.
	button_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	# Every button in the game, including ones created later, gets a tap sound.
	get_tree().node_added.connect(_on_node_added_for_button_sound)
	for existing_button in find_children("*", "BaseButton", true, false):
		_on_node_added_for_button_sound(existing_button)





func ensure_audio_buses() -> void:
	# Separate Music and SFX buses so each has its own volume slider.
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			var bus_index := AudioServer.bus_count - 1
			AudioServer.set_bus_name(bus_index, bus_name)
			AudioServer.set_bus_send(bus_index, "Master")





func apply_audio_settings() -> void:
	var music_bus := AudioServer.get_bus_index("Music")
	var sfx_bus := AudioServer.get_bus_index("SFX")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(maxf(music_volume, 0.0001)))
		AudioServer.set_bus_mute(music_bus, music_volume <= 0.0)
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(maxf(sfx_volume, 0.0001)))
		AudioServer.set_bus_mute(sfx_bus, sfx_volume <= 0.0)
	# The player's mute and an ad's temporary mute are tracked separately so
	# closing an ad never un-mutes a player who chose silence.
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), audio_muted or ad_audio_muted)





func _on_settings_changed(music: float, sfx: float, muted: bool) -> void:
	music_volume = music
	sfx_volume = sfx
	audio_muted = muted
	apply_audio_settings()
	write_save()





func _on_node_added_for_button_sound(node: Node) -> void:
	if node is BaseButton and not node.has_meta("tap_sound"):
		node.set_meta("tap_sound", true)
		(node as BaseButton).pressed.connect(func() -> void: play_sfx(button_sound_player))





func make_audio_player(stream: AudioStream, volume_db: float, bus_name: String = "SFX") -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.bus = bus_name
	add_child(player)

	return player





func play_sfx(player: AudioStreamPlayer) -> void:

	if not player:

		return

	player.stop()

	player.play()





func _process(delta: float) -> void:
	if banner_ad:
		# Banner only on menu-style screens, never over active gameplay.
		# Main menu and game over only: the shop is too dense to share space with it.
		var banner_should_show := (start_screen.visible or game_over_screen.visible) and not shop_screen.visible
		# On iOS the real AdMob banner replaces the placeholder strip.
		banner_ad.visible = banner_should_show and not OS.has_feature("ios")
		ad_manager.set_banner_visible(banner_should_show)
	if pause_button:
		pause_button.visible = game_started and not game_over and not get_tree().paused
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

	# The world art is procedural; redraw at 20 FPS instead of rebuilding the

	# entire 12,000px scene on every physics step.

	redraw_timer += delta

	if redraw_timer >= 0.05:

		redraw_timer = 0.0

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
	if revive_shield_time > 0.0:
		revive_shield_time = maxf(revive_shield_time - delta, 0.0)
		# Blink while protected so the player can see the shield running out.
		block.modulate.a = 0.45 + 0.55 * absf(sin(world_elapsed * 14.0)) if revive_shield_time > 0.0 else 1.0

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

		var jelly_center := get_player_center()

		var rope_direction := (jelly_center - swing_anchor.global_position).normalized()

		block.position = swing_anchor.global_position + rope_direction * swing_rope_length - block.size / 2.0

		var tangential_velocity: Vector2 = velocity - rope_direction * velocity.dot(rope_direction)

		if tangential_velocity.length() < 30.0:

			tangential_velocity = Vector2(-rope_direction.y, rope_direction.x) * 30.0

		velocity = tangential_velocity + tangential_velocity.normalized() * swing_boost_per_second * delta



	var floor_top = floor_rect.position.y

	var block_bottom = block.position.y + block.size.y

	if check_bounce_pads(block_bottom):

		block_bottom = block.position.y + block.size.y

	# Crossing the top of a Sky Climb course starts a tougher, freshly generated
	# course before the ceiling collision can bounce Jelly back down.
	if active_game_mode == "CLIMB" and get_player_center().y <= CLIMB_LEVEL_TOP_Y:
		advance_climb_level()
		return

	# The floor is lava on level one and a bottomless void on later levels.
	if block_bottom >= floor_top and velocity.y >= 0.0 and revive_shield_time > 0.0:
		# A freshly revived Jelly gets a free bounce instead of an instant second death.
		block.position.y = floor_top - block.size.y - 2.0
		velocity.y = -1300.0
	elif block_bottom >= floor_top and velocity.y >= 0.0:

		end_game()

		return



	# The original fixed map has a gentle ceiling bounce.

	if block.position.y < 0.0:

		block.position.y = 0.0

		velocity.y = abs(velocity.y) * wall_bounce



	# Side walls bounce the cube back into the play area.

	if block.position.x < 0.0:

		block.position.x = 0.0

		velocity.x = maxf(abs(velocity.x) * wall_bounce, WALL_MIN_REBOUND)
		_on_player_wall_bounce()

	elif block.position.x + block.size.x > map_width:

		block.position.x = map_width - block.size.x

		velocity.x = -maxf(abs(velocity.x) * wall_bounce, WALL_MIN_REBOUND)
		_on_player_wall_bounce()



	resolve_jelly_collisions()

	if active_game_mode == "TAG":

		update_tag_mode(delta)

	collect_power_ups()



	# Keep Jelly centered on screen as it travels through the tall level.

	camera.global_position = get_player_center()

	update_height_score()

	collect_coins(delta)

	update_bats(delta)

	update_swing_rope()





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

	bounce_pad_positions.clear()

	highest_generated_pad_y = 0.0



	# Each mode starts with a reachable first swing target.

	if active_game_mode == "CLIMB":

		spawn_anchor(get_start_pad_position() + Vector2(0.0, -440.0))

	else:

		spawn_anchor(Vector2(randf_range(350.0, 580.0), randf_range(400.0, 650.0)))

	var generated_anchor_count := anchor_count
	var climb_chain_count := 0
	if active_game_mode == "CLIMB":
		# A reliable route makes a course completable, while larger gaps make
		# later levels progressively more demanding.
		generated_anchor_count = max(260, anchor_count - (climb_level - 1) * 38)
		var chain_position := get_start_pad_position() + Vector2(0.0, -760.0)
		var chain_step := minf(460.0, 300.0 + float(climb_level - 1) * 24.0)
		while chain_position.y > CLIMB_LEVEL_TOP_Y + 240.0:
			chain_position.x = clampf(chain_position.x + randf_range(-330.0, 330.0), 180.0, map_width - 180.0)
			spawn_anchor(chain_position)
			climb_chain_count += 1
			chain_position.y -= randf_range(chain_step * 0.78, chain_step)

	for anchor_index in range(max(0, generated_anchor_count - 1 - climb_chain_count)):

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



	# Spring pads offer random recovery routes throughout the fixed map.

	bounce_pad_positions.append(get_start_pad_position() if active_game_mode == "CLIMB" else Vector2(390.0, 640.0))

	var generated_pad_count := bounce_pad_count
	if active_game_mode == "CLIMB":
		# Recovery pads become rarer as courses progress.
		generated_pad_count = max(28, bounce_pad_count - (climb_level - 1) * 12)
	for pad_index in range(generated_pad_count - 1):

		bounce_pad_positions.append(Vector2(

			randf_range(90.0, map_width - 90.0),

			randf_range(540.0, floor_y - 190.0)

		))



	var generated_bat_count := bat_count + (climb_level - 1) * 6 if active_game_mode == "CLIMB" else bat_count
	for bat_index in range(generated_bat_count):

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





func check_bounce_pads(block_bottom: float) -> bool:

	if world_elapsed < bounce_pad_next_trigger_time:

		return false

	for pad_position in bounce_pad_positions:

		var pad_rect := Rect2(pad_position - bounce_pad_size * 0.5, bounce_pad_size)

		var player_rect := Rect2(block.position, block.size)

		# Pads are intentionally forgiving: touching one from any direction launches

		# Jelly back above it, so passing underneath cannot make a pad feel broken.

		if player_rect.grow(10.0).intersects(pad_rect):

			var pad_top := pad_rect.position.y

			block.position.y = pad_top - block.size.y

			velocity.y = -maxf(absf(velocity.y) * 1.18, bounce_pad_launch_speed)

			bounce_pad_next_trigger_time = world_elapsed + 0.22

			land()

			play_sfx(bounce_sound_player)

			show_power_message("BOING!")

			return true

	return false





func get_start_pad_position() -> Vector2:

	return Vector2(map_width * 0.5, floor_y - 180.0)


func configure_climb_level() -> void:
	# Every climb course uses the same tall vertical distance, then swaps its
	# palette and hazard treatment when Jelly reaches the summit.
	floor_y = CLIMB_LEVEL_HEIGHT
	floor_rect.position = Vector2(0.0, floor_y)
	floor_rect.size = Vector2(map_width, 180.0)

	# Each course's bottom colour is the previous course's top colour, so the
	# climb reads as one continuous sky that keeps changing as Jelly rises.
	sky_bottom_color = CLIMB_SKY_CHAIN[(climb_level - 1) % CLIMB_SKY_CHAIN.size()]
	sky_top_color = CLIMB_SKY_CHAIN[climb_level % CLIMB_SKY_CHAIN.size()]
	# Level one has a visible jam-lava floor. Later levels have no visible floor
	# (falling off the bottom still ends the run), so nothing breaks the sky.
	floor_rect.color = LAVA_JAM_COLOR if climb_level == 1 else Color(sky_bottom_color, 0.0)
	level_label.text = "LEVEL %d" % climb_level


func configure_standard_world() -> void:
	floor_y = 9000.0
	floor_rect.position = Vector2(0.0, floor_y)
	floor_rect.size = Vector2(map_width, 120.0)
	floor_rect.color = LAVA_JAM_COLOR
	sky_top_color = Color("4bb5f2")
	sky_bottom_color = Color("dff8ff")


func advance_climb_level() -> void:
	# Bank confirmed peak progress, then rebuild at the bottom of a new course.
	update_height_score()
	climb_height_bank = height_score
	climb_level += 1
	velocity = Vector2.ZERO
	is_swinging = false
	swing_anchor = null
	swing_rope.hide()
	bounce_pad_next_trigger_time = 0.0
	configure_climb_level()
	populate_world()
	place_player_on_start_pad()
	run_start_height_y = get_player_center().y
	previous_player_center = get_player_center()
	update_height_score()
	show_power_message("LEVEL %d  •  CLIMB HIGHER!" % climb_level)





func place_player_on_start_pad() -> void:

	var start_pad := get_start_pad_position()

	block.position = start_pad - Vector2(block.size.x * 0.5, bounce_pad_size.y * 0.5 + block.size.y)





func spawn_anchor(anchor_position: Vector2) -> void:

	var anchor := Sprite2D.new()

	anchor.texture = PURPLE_ORB_TEXTURE

	anchor.position = anchor_position

	anchor.scale = Vector2.ONE * orb_scale
	anchor.set_meta("pulse_offset", randf_range(0.0, TAU))

	swing_anchors.add_child(anchor)





func spawn_bat(bat_position: Vector2) -> void:

	var bat := Sprite2D.new()

	bat.texture = BAT_TEXTURE

	bat.position = bat_position

	bat.scale = Vector2.ONE * bat_scale
	bat.set_meta("home", bat_position)

	bat.set_meta("phase", randf_range(0.0, TAU))

	bat.set_meta("chasing", false)
	bat.set_meta("chase_started_at", -1.0)
	bat.set_meta("ignore_until", 0.0)

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
	bot.set_meta("rope_attached_at", world_elapsed)

	bot.set_meta("coins", 0)

	var bot_skin_id := randi_range(0, skin_definitions.size() - 1)

	bot.set_meta("name", bot_names.pick_random())

	bot.set_meta("magnet_until", 0.0)

	bot.set_meta("knife_until", 0.0)

	bot.set_meta("next_collect_at", world_elapsed + randf_range(0.0, 0.12))



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

	sprite.scale = get_skin_sprite_scale(bot_skin_id, bot_skin_texture)

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





func get_next_bot_anchor(from_position: Vector2, goal: Vector2 = Vector2.INF, flee: bool = false) -> Vector2:
	if active_game_mode == "TAG" and goal != Vector2.INF:
		# Tag racers swing purposefully: hunters toward their target, fleers away.
		var best_position := from_position
		var best_score := INF
		for anchor_node in swing_anchors.get_children():
			var tag_anchor := anchor_node as Sprite2D
			if not tag_anchor:
				continue
			var reach := tag_anchor.global_position.distance_to(from_position)
			if reach < 110.0 or reach > 460.0:
				continue
			var to_goal := tag_anchor.global_position.distance_to(goal)
			var score := -to_goal if flee else to_goal
			score += randf_range(0.0, 60.0)  # a little variety so racers don't move in lockstep
			if score < best_score:
				best_score = score
				best_position = tag_anchor.global_position
		if best_position != from_position:
			return best_position
	if active_game_mode != "CLIMB":

		var coin_mode_candidates: Array[Sprite2D] = []

		for anchor_node in swing_anchors.get_children():

			var coin_mode_anchor := anchor_node as Sprite2D

			if coin_mode_anchor and coin_mode_anchor.global_position.distance_to(from_position) > 110.0 and coin_mode_anchor.global_position.distance_to(from_position) < 460.0:

				coin_mode_candidates.append(coin_mode_anchor)

		return coin_mode_candidates.pick_random().global_position if not coin_mode_candidates.is_empty() else from_position



	var best_anchor_position := from_position

	var best_climb_score := INF
	# If nothing higher is reachable (e.g. while falling), catch the nearest orb.
	var fallback_position := from_position
	var fallback_distance := INF

	for anchor_node in swing_anchors.get_children():

		var anchor := anchor_node as Sprite2D

		if not anchor:

			continue

		var distance := anchor.global_position.distance_to(from_position)

		var climbs_upward := anchor.global_position.y < from_position.y - 35.0

		if distance >= 105.0 and distance <= 460.0 and distance < fallback_distance:
			fallback_distance = distance
			fallback_position = anchor.global_position

		if distance < 105.0 or distance > 460.0 or not climbs_upward:

			continue

		# Lower world Y means higher on screen. Favor the highest reachable orb,

		# with a small distance cost to avoid impossible-looking rope switches.

		var climb_score := anchor.global_position.y + distance * 0.16

		if climb_score < best_climb_score:

			best_climb_score = climb_score

			best_anchor_position = anchor.global_position

	return best_anchor_position if best_anchor_position != from_position else fallback_position





func spawn_power_up(kind: String, power_up_position: Vector2) -> void:

	var power_up := Sprite2D.new()

	match kind:

		"rocket": power_up.texture = ROCKET_TEXTURE

		"teleport": power_up.texture = TELEPORT_TEXTURE

		"magnet": power_up.texture = MAGNET_TEXTURE

		_: power_up.texture = KNIFE_TEXTURE

	power_up.position = power_up_position

	power_up.scale = Vector2.ONE * power_up_scale
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
	# Every power-up (rocket, warp, magnet, knives) plays the pickup sound.
	play_sfx(jetpack_sound_player)
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

		blade.scale = Vector2.ONE * power_up_scale
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





func update_swing_rope() -> void:

	if is_swinging and is_instance_valid(swing_anchor):

		swing_rope.points = PackedVector2Array([swing_anchor.global_position, get_player_center()])

		swing_rope.show()

	else:

		swing_rope.hide()





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

	var camera_position := camera.global_position

	var animate_range_squared := 1600.0 * 1600.0

	for anchor_node in swing_anchors.get_children():

		var anchor := anchor_node as Sprite2D

		if anchor and anchor.global_position.distance_squared_to(camera_position) <= animate_range_squared:

			var pulse: float = 1.0 + sin(world_elapsed * 2.4 + float(anchor.get_meta("pulse_offset"))) * 0.09

			anchor.scale = Vector2.ONE * orb_scale * pulse
			anchor.rotation += delta * 0.35

	for power_up_node in power_ups.get_children():

		var power_up := power_up_node as Sprite2D

		if power_up:

			var pulse: float = 1.0 + sin(world_elapsed * 3.0 + float(power_up.get_meta("pulse_offset"))) * 0.12

			power_up.scale = Vector2.ONE * power_up_scale * pulse
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
		var rope_attached_at: float = float(bot.get_meta("rope_attached_at"))

		# No racer may stay tethered to a single orb for longer than six seconds.
		if not rope_cut and world_elapsed - rope_attached_at >= 6.0:
			rope_cut = true
			bot.set_meta("rope_cut", true)

		# The same gravity + tangential-rope physics used by Jelly.

		bot_velocity.y += gravity * delta
		bot.position += bot_velocity * delta
		# In Tag, a racer that loses its rope tries to catch a new orb, as a
		# player would, instead of always dropping into the lava.
		if rope_cut and (active_game_mode == "TAG" or active_game_mode == "CLIMB") and not bot.has_meta("regrab_after") and not bot.has_meta("regrab_gave_up"):
			bot.set_meta("regrab_after", world_elapsed + (0.3 if active_game_mode == "CLIMB" else 0.5))
		if rope_cut and bot.has_meta("regrab_after") and world_elapsed >= float(bot.get_meta("regrab_after")):
			var regrab_anchor := get_next_bot_anchor(bot.global_position, tag_anchor_goal(bot))
			var regrab_length := bot.global_position.distance_to(regrab_anchor)
			if regrab_length >= 105.0 and regrab_length <= 460.0:
				rope_cut = false
				anchor_position = regrab_anchor
				rope_length = regrab_length
				bot.set_meta("rope_cut", false)
				bot.set_meta("from_anchor", regrab_anchor)
				bot.set_meta("rope_length", regrab_length)
				bot.set_meta("rope_attached_at", world_elapsed)
				bot.set_meta("switch_at", world_elapsed + randf_range(1.2, 2.0))
				bot.remove_meta("regrab_after")
				if bot.has_meta("regrab_gave_up"):
					bot.remove_meta("regrab_gave_up")
			elif world_elapsed - float(bot.get_meta("regrab_after")) > 2.5:
				bot.remove_meta("regrab_after")
				bot.set_meta("regrab_gave_up", true)
		if not rope_cut and player_hits_bot_rope(anchor_position, bot.global_position):

			rope_cut = true

			bot.set_meta("rope_cut", true)

			show_power_message("YOU CUT %s'S ROPE!" % str(bot.get_meta("name", "RACER")))

		if not rope_cut:

			var rope_direction := (bot.global_position - anchor_position).normalized()

			if rope_direction == Vector2.ZERO:

				rope_direction = Vector2.DOWN

			bot.global_position = anchor_position + rope_direction * rope_length

			var tangential_velocity: Vector2 = bot_velocity - rope_direction * bot_velocity.dot(rope_direction)

			if tangential_velocity.length() < 30.0:

				tangential_velocity = Vector2(-rope_direction.y, rope_direction.x) * 75.0

			bot_velocity = tangential_velocity + tangential_velocity.normalized() * swing_boost_per_second * (1.0 if active_game_mode == "CLIMB" else 0.65) * delta



			# Sky Climb racers fling themselves upward off a fast upswing and
			# catch a higher orb, just like a skilled player.
			if active_game_mode == "CLIMB" and world_elapsed - float(bot.get_meta("rope_attached_at")) > 0.35 and bot_velocity.y < -360.0 and _has_orb_above(bot.global_position):
				rope_cut = true
				bot.set_meta("rope_cut", true)
				bot_velocity.y -= 180.0
				bot.set_meta("regrab_after", world_elapsed + 0.25)

			# Bots periodically throw their rope to a nearby purple orb.

			elif world_elapsed >= float(bot.get_meta("switch_at")):
				var next_anchor := get_next_bot_anchor(bot.global_position, tag_anchor_goal(bot), tag_holders.has(bot) == false and bot.has_meta("threat_pos"))

				var next_rope_length := bot.global_position.distance_to(next_anchor)

				# Never clamp a new rope: clamping was what visibly snapped bots across the map.

				var climb_ok := active_game_mode != "CLIMB" or next_anchor.y < anchor_position.y - 40.0
				if climb_ok and next_rope_length >= 105.0 and next_rope_length <= 460.0:

					anchor_position = next_anchor

					rope_length = next_rope_length

					bot.set_meta("from_anchor", anchor_position)

					bot.set_meta("rope_length", rope_length)
					bot.set_meta("rope_attached_at", world_elapsed)

					bot.set_meta("switch_at", world_elapsed + bot_switch_delay(bot))

				elif active_game_mode == "CLIMB":

					# Nothing higher in reach yet: look again very soon.
					bot.set_meta("switch_at", world_elapsed + 0.2)

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

			bot_velocity.x = maxf(abs(bot_velocity.x) * wall_bounce, WALL_MIN_REBOUND)

		elif bot.position.x + 24.0 > map_width:

			bot.position.x = map_width - 24.0

			bot_velocity.x = -maxf(abs(bot_velocity.x) * wall_bounce, WALL_MIN_REBOUND)

		if active_game_mode == "TAG":
			bot_velocity = steer_tag_bot(bot, bot_velocity, rope_cut, delta)
			rope_cut = bool(bot.get_meta("rope_cut"))

		bot.set_meta("velocity", bot_velocity)

		bot.rotation = bot_velocity.angle() * 0.12

		var name_label := bot.get_node_or_null("NameLabel") as Label

		if name_label:

			name_label.rotation = -bot.rotation

		# Stagger expensive pickup scans across bots rather than having every bot

		# scan every coin and power-up 60 times per second.

		if world_elapsed >= float(bot.get_meta("next_collect_at")):

			collect_power_ups_for_bot(bot)

			collect_coins_for_bot(bot, delta)

			bot.set_meta("next_collect_at", world_elapsed + 0.12)

	bot_rope_check_timer -= delta

	if bot_rope_check_timer <= 0.0:

		bot_rope_check_timer = 0.10

		bots_cut_ropes()

	leaderboard_update_timer -= delta

	if leaderboard_update_timer <= 0.0:

		leaderboard_update_timer = 0.25

		update_leaderboard()





func resolve_jelly_collisions() -> void:

	# Jelly and the racer Jellies bump apart rather than overlapping.

	var player_center := get_player_center()

	# Use compact contact circles so racers only bump when their Jelly bodies touch.

	var player_radius := 42.0

	var bot_radius := 34.0

	for bot_node in bot_swings.get_children():

		var bot := bot_node as Node2D

		if not bot:

			continue

		var offset := player_center - bot.global_position

		var minimum_distance := player_radius + bot_radius

		if offset.length_squared() >= minimum_distance * minimum_distance:

			continue

		var normal := offset.normalized() if offset.length_squared() > 0.001 else Vector2.UP

		var overlap := minimum_distance - offset.length()

		block.position += normal * overlap * 0.7

		bot.global_position -= normal * overlap * 0.3

		if velocity.dot(normal) < 0.0:

			velocity = velocity.bounce(normal) * 0.72

		var bot_velocity: Vector2 = bot.get_meta("velocity")

		if bot_velocity.dot(normal) > 0.0:

			bot_velocity = bot_velocity.bounce(-normal) * 0.72

		bot.set_meta("velocity", bot_velocity)

		if active_game_mode == "TAG":

			try_tag_transfer(bot)

		if world_elapsed >= jelly_collision_next_time:

			jelly_collision_next_time = world_elapsed + 0.35

			show_power_message("JELLY BUMP!")





func tag_anchor_goal(bot: Node2D) -> Vector2:
	if active_game_mode != "TAG":
		return Vector2.INF
	if tag_holders.has(bot):
		var target = (bot.get_meta("tag_target") if bot.has_meta("tag_target") else null)
		return racer_position(target as CanvasItem) if is_instance_valid(target) else Vector2.INF
	if bot.has_meta("threat_pos"):
		return bot.get_meta("threat_pos")
	return Vector2.INF





func racer_velocity(racer: CanvasItem) -> Vector2:
	return velocity if racer == block else Vector2(racer.get_meta("velocity", Vector2.ZERO))





func racer_position(racer: CanvasItem) -> Vector2:
	return get_player_center() if racer == block else (racer as Node2D).global_position





func assign_tag_targets() -> void:
	# Every IT racer picks the closest safe racer to hunt. Jelly is a slightly
	# preferred target, but at most two bots hunt Jelly at once so the player
	# is pressured without being swarmed. Safe racers note the nearest threat.
	var racers: Array[CanvasItem] = [block]
	for bot_node in bot_swings.get_children():
		if bot_node is Node2D:
			racers.append(bot_node as CanvasItem)
	var player_hunters := 0
	var hunters: Array[Node2D] = []
	for racer in racers:
		if racer != block and tag_holders.has(racer):
			hunters.append(racer as Node2D)
	hunters.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.global_position.distance_squared_to(get_player_center()) < b.global_position.distance_squared_to(get_player_center()))
	for hunter in hunters:
		var best: CanvasItem = null
		var best_score := TAG_HUNT_RADIUS
		for racer in racers:
			if racer == hunter or tag_holders.has(racer):
				continue
			var score := hunter.global_position.distance_to(racer_position(racer))
			if racer == block:
				if player_hunters >= TAG_MAX_PLAYER_HUNTERS:
					continue
				score *= 0.65
			if score < best_score:
				best_score = score
				best = racer
		if best == block:
			player_hunters += 1
		if best:
			hunter.set_meta("tag_target", best)
		elif hunter.has_meta("tag_target"):
			hunter.remove_meta("tag_target")
	for racer in racers:
		if racer == block:
			continue
		if tag_holders.has(racer):
			if racer.has_meta("threat_pos"):
				racer.remove_meta("threat_pos")
			continue
		var nearest_threat := Vector2.INF
		var nearest_distance := TAG_FLEE_RADIUS
		var safe_bot := racer as Node2D
		for holder in tag_holders:
			if not is_instance_valid(holder):
				continue
			var threat := holder as CanvasItem
			var distance := safe_bot.global_position.distance_to(racer_position(threat))
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_threat = racer_position(threat)
		if nearest_threat != Vector2.INF:
			racer.set_meta("threat_pos", nearest_threat)
		elif racer.has_meta("threat_pos"):
			racer.remove_meta("threat_pos")





func _has_orb_within(point: Vector2, radius: float) -> bool:
	var radius_squared := radius * radius
	for anchor_node in swing_anchors.get_children():
		var anchor := anchor_node as Node2D
		if anchor and anchor.global_position.distance_squared_to(point) <= radius_squared and anchor.global_position.distance_squared_to(point) >= 110.0 * 110.0:
			return true
	return false





func _has_orb_above(point: Vector2) -> bool:
	for anchor_node in swing_anchors.get_children():
		var anchor := anchor_node as Node2D
		if not anchor or anchor.global_position.y > point.y - 60.0:
			continue
		var distance := anchor.global_position.distance_to(point)
		if distance >= 110.0 and distance <= 430.0:
			return true
	return false


func bot_switch_delay(bot: Node2D) -> float:
	match active_game_mode:
		"CLIMB":
			return randf_range(0.15, 0.4)
		"TAG":
			if tag_holders.has(bot):
				return randf_range(0.8, 1.4)
			if bot.has_meta("threat_pos"):
				return randf_range(0.9, 1.6)
			return randf_range(2.0, 3.5)
	return randf_range(3.0, 5.0)


func steer_tag_bot(bot: Node2D, bot_velocity: Vector2, rope_cut: bool, delta: float) -> Vector2:
	var goal := tag_anchor_goal(bot)
	# A racer dangling slowly on a rope with somewhere to be leaps like Jelly
	# does: a hop toward (or away from) its goal, then it grabs a new orb.
	if not rope_cut and goal != Vector2.INF:
		if bot_velocity.length() < 140.0:
			if not bot.has_meta("slow_since"):
				bot.set_meta("slow_since", world_elapsed)
			elif world_elapsed - float(bot.get_meta("slow_since")) > 0.8 and _has_orb_within(bot.global_position, 460.0):
				var leap_direction := (goal - bot.global_position).normalized()
				if not tag_holders.has(bot):
					leap_direction = -leap_direction
				bot_velocity = Vector2(leap_direction.x * 650.0, minf(leap_direction.y * 650.0, 0.0) - 550.0)
				bot.set_meta("rope_cut", true)
				bot.set_meta("regrab_after", world_elapsed + 0.35)
				bot.remove_meta("slow_since")
				return bot_velocity
		elif bot.has_meta("slow_since"):
			bot.remove_meta("slow_since")
	if tag_holders.has(bot):
		var target_ref = (bot.get_meta("tag_target") if bot.has_meta("tag_target") else null)
		if is_instance_valid(target_ref):
			var target := target_ref as CanvasItem
			# Aim where the target is going, not where it is.
			var lead := racer_position(target) + racer_velocity(target) * 0.35
			var to_target := lead - bot.global_position
			var direction := to_target.normalized()
			# Hunters get bolder as their own IT timer runs down.
			var urgency := 1.0 + clampf(float(tag_times.get(bot, 0.0)) / TAG_TIMEOUT_SECONDS, 0.0, 1.0)
			if rope_cut:
				# Close in hard for the final pounce.
				var pounce := 1.8 if to_target.length() < 280.0 else 1.0
				bot_velocity += direction * 520.0 * urgency * pounce * delta
			else:
				bot_velocity += direction * 180.0 * urgency * delta
				# Let go of the rope when the swing is flinging the bot at its target.
				var speed := bot_velocity.length()
				if speed > 340.0 and to_target.length() < 750.0 and bot_velocity.dot(direction) > speed * 0.6 and _has_orb_within(bot.global_position + direction * 250.0, 400.0):
					bot.set_meta("rope_cut", true)
					# A hunter that lets go grabs a new orb shortly after, instead of falling.
					bot.set_meta("regrab_after", world_elapsed + 0.55)
	elif bot.has_meta("threat_pos"):
		var away: Vector2 = (bot.global_position - Vector2(bot.get_meta("threat_pos"))).normalized()
		bot_velocity += away * (380.0 if rope_cut else 170.0) * delta
	if bot_velocity.length() > TAG_BOT_SPEED_CAP:
		bot_velocity = bot_velocity.normalized() * TAG_BOT_SPEED_CAP
	return bot_velocity





func bot_tag_transfers() -> void:
	# IT racers can now tag each other's safe racers, not just Jelly.
	for holder in tag_holders.duplicate():
		var hunter := holder as Node2D
		if not is_instance_valid(hunter) or hunter == block:
			continue
		if world_elapsed < float(hunter.get_meta("tag_ready_at", 0.0)):
			continue
		for bot_node in bot_swings.get_children():
			var prey := bot_node as Node2D
			if not prey or prey == hunter or tag_holders.has(prey):
				continue
			if hunter.global_position.distance_squared_to(prey.global_position) > 80.0 * 80.0:
				continue
			var index := tag_holders.find(hunter)
			tag_holders[index] = prey
			tag_times.erase(hunter)
			tag_times[prey] = 0.0
			# The new IT racer can't instantly tag back.
			prey.set_meta("tag_ready_at", world_elapsed + 1.2)
			if hunter.has_meta("tag_target"):
				hunter.remove_meta("tag_target")
			choose_tag_chaser()
			update_tag_glows()
			if prey.global_position.distance_to(get_player_center()) < 900.0:
				show_power_message("%s TAGGED %s!" % [str(hunter.get_meta("name", "RACER")), str(prey.get_meta("name", "RACER"))])
			break





func try_tag_transfer(bot: Node2D) -> void:
	# Touching an IT racer makes Jelly IT. If Jelly is IT, touching a safe racer
	# passes Jelly's tag to that racer.
	if world_elapsed < tag_transfer_cooldown_until:
		return
	if tag_holders.has(bot) and not tag_holders.has(block):
		replace_tag_holder(bot, block)
		show_power_message("%s TAGGED YOU! YOU'RE IT!" % str(bot.get_meta("name", "RACER")))
	elif tag_holders.has(block) and not tag_holders.has(bot):
		replace_tag_holder(block, bot)
		show_power_message("YOU TAGGED %s!" % str(bot.get_meta("name", "RACER")))


func setup_tag_round() -> void:
	tag_holders.clear()
	tag_times.clear()
	tag_chaser = null
	fill_tag_holders()
	choose_tag_chaser()
	update_tag_status()
	update_tag_glows()


func fill_tag_holders() -> void:
	while tag_holders.size() < TAG_HOLDER_COUNT:
		var candidates: Array[Node] = []
		for bot_node in bot_swings.get_children():
			if not tag_holders.has(bot_node):
				candidates.append(bot_node)
		if candidates.is_empty():
			return
		var holder := candidates.pick_random() as Node
		tag_holders.append(holder)
		tag_times[holder] = 0.0


func replace_tag_holder(old_holder: Node, new_holder: Node) -> void:
	var index := tag_holders.find(old_holder)
	if index < 0:
		return
	tag_holders[index] = new_holder
	tag_times.erase(old_holder)
	tag_times[new_holder] = 0.0
	tag_transfer_cooldown_until = world_elapsed + 0.75
	choose_tag_chaser()
	update_tag_status()
	update_tag_glows()


func choose_tag_chaser() -> void:
	# Select the IT bot nearest Jelly, so only one of the four actively hunts.
	var nearest_distance := INF
	tag_chaser = null
	for holder in tag_holders:
		var bot := holder as Node2D
		if bot and bot != block:
			var distance := bot.global_position.distance_squared_to(get_player_center())
			if distance < nearest_distance:
				nearest_distance = distance
				tag_chaser = bot


func update_tag_status() -> void:
	if active_game_mode != "TAG":
		return
	var holder_lines: Array[String] = []
	for holder in tag_holders:
		var holder_name := display_player_name() if holder == block else str(holder.get_meta("name", "RACER"))
		var seconds_left := maxi(0, ceili(TAG_TIMEOUT_SECONDS - float(tag_times.get(holder, 0.0))))
		holder_lines.append("%s  %ds" % [holder_name, seconds_left])
	tag_status_label.text = "IT PLAYERS (%d)
%s" % [tag_holders.size(), "
".join(holder_lines)]
	tag_status_label.modulate = Color("ffdf83")


func update_tag_glows() -> void:
	# Pulsing warm tint makes every IT Jelly obvious, including the player.
	var pulse := 0.72 + sin(world_elapsed * 5.0) * 0.18
	block.modulate = Color(1.0, pulse, 0.28, 1.0) if tag_holders.has(block) else Color.WHITE
	for bot_node in bot_swings.get_children():
		var bot := bot_node as Node2D
		if bot:
			bot.modulate = Color(1.0, pulse, 0.28, 1.0) if tag_holders.has(bot) else Color.WHITE


func update_tag_mode(delta: float) -> void:
	# Drop racers that fell out or were freed (rebuild rather than erase, since
	# erasing a freed object from a typed array is an engine error).
	var still_in: Array[Node] = []
	for holder in tag_holders:
		if is_instance_valid(holder) and (holder == block or holder.get_parent() == bot_swings):
			still_in.append(holder)
	tag_holders = still_in
	for timed in tag_times.keys():
		if not is_instance_valid(timed) or not tag_holders.has(timed):
			tag_times.erase(timed)
	fill_tag_holders()
	if tag_holders.is_empty():
		tag_round_won = true
		end_game()
		return
	var expired_holders: Array[Node] = []
	for holder in tag_holders:
		tag_times[holder] = float(tag_times.get(holder, 0.0)) + delta
		if float(tag_times[holder]) >= TAG_TIMEOUT_SECONDS:
			expired_holders.append(holder)
	for holder in expired_holders:
		if holder == block:
			show_power_message("TAG OUT!")
			end_game()
			return
		var eliminated_bot := holder as Node2D
		var eliminated_name := str(eliminated_bot.get_meta("name", "RACER")) if eliminated_bot else "RACER"
		tag_holders.erase(holder)
		tag_times.erase(holder)
		if eliminated_bot and eliminated_bot.get_parent() == bot_swings:
			bot_swings.remove_child(eliminated_bot)
			eliminated_bot.queue_free()
		show_power_message("%s IS OUT!" % eliminated_name)
	fill_tag_holders()
	# Last jelly standing wins, even if Jelly happens to be IT at that moment.
	if bot_swings.get_child_count() == 0:
		tag_round_won = true
		end_game()
		return
	choose_tag_chaser()
	tag_ai_timer -= delta
	if tag_ai_timer <= 0.0:
		tag_ai_timer = 0.25
		assign_tag_targets()
	# Bots tag each other on touch, so check every frame (at most 4 x 12 pairs).
	bot_tag_transfers()
	update_tag_status()
	update_tag_glows()


func player_hits_bot_rope(anchor_position: Vector2, rope_end: Vector2) -> bool:

	# Check both ends of Jelly's physics-step path so fast swings can still cut a rope.

	var cut_radius := 28.0

	var current_closest := Geometry2D.get_closest_point_to_segment(get_player_center(), anchor_position, rope_end)

	var previous_closest := Geometry2D.get_closest_point_to_segment(previous_player_center, anchor_position, rope_end)

	return current_closest.distance_to(get_player_center()) <= cut_radius or previous_closest.distance_to(previous_player_center) <= cut_radius





func bots_cut_ropes() -> void:

	var cut_radius := 27.0
	# A moving bot can cut any other bot's intact tether. Positions and ropes are
	# gathered once per frame, and a cheap bounding-box test skips the segment
	# maths for ropes that are nowhere near the cutter (most pairs).
	var bot_nodes := bot_swings.get_children()
	var cutters: Array[Node2D] = []
	var bot_positions: Array[Vector2] = []
	var rope_targets: Array[Node2D] = []
	var rope_boxes: Array[Rect2] = []
	var rope_anchors: Array[Vector2] = []
	for bot_node in bot_nodes:
		var bot := bot_node as Node2D
		if not bot:
			continue
		cutters.append(bot)
		bot_positions.append(bot.global_position)
		if not bool(bot.get_meta("rope_cut")):
			var anchor_point: Vector2 = bot.get_meta("from_anchor")
			rope_targets.append(bot)
			rope_anchors.append(anchor_point)
			rope_boxes.append(Rect2(anchor_point, Vector2.ZERO).expand(bot.global_position).grow(cut_radius))
	for cutter_index in range(bot_positions.size()):
		var cutter_position := bot_positions[cutter_index]
		for rope_index in range(rope_targets.size()):
			var target := rope_targets[rope_index]
			if target == cutters[cutter_index] or not rope_boxes[rope_index].has_point(cutter_position):
				continue
			if bool(target.get_meta("rope_cut")):
				continue
			var closest_point := Geometry2D.get_closest_point_to_segment(cutter_position, rope_anchors[rope_index], target.global_position)
			if closest_point.distance_to(cutter_position) <= cut_radius:
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

					show_power_message("%s CUT YOUR ROPE!" % str(cutter.get_meta("name", "A JELLY")))

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

			# A bat only remembers Jelly for a short burst, then returns to patrol.
			if world_elapsed - float(bat.get_meta("chase_started_at")) >= BAT_CHASE_DURATION:
				bat.set_meta("chasing", false)
				bat.set_meta("chase_started_at", -1.0)
				bat.set_meta("ignore_until", world_elapsed + BAT_REENGAGE_DELAY)
				continue

			var arming_time: float = bat.get_meta("arming_time")

			if arming_time > 0.0:

				bat.set_meta("arming_time", arming_time - delta)

				continue



			var hunt_direction: Vector2 = (jelly_center - bat.global_position).normalized()

			# The run ramps up gradually, rewarding early exploration before the pressure rises.

			var current_chase_speed: float = bat_chase_speed + min(float(coins_collected) * 3.0, 150.0)

			bat.position += hunt_direction * current_chase_speed * delta

			bat.scale.x = abs(bat.scale.x) * sign(hunt_direction.x) if hunt_direction.x != 0.0 else bat.scale.x

			if has_player_contact(bat.global_position, bat_attack_radius) and revive_shield_time <= 0.0:

				end_game()

		else:

			var home: Vector2 = bat.get_meta("home")

			var phase: float = bat.get_meta("phase")

			bat.position = home + Vector2(

				sin(world_elapsed * 1.8 + phase) * 80.0,

				cos(world_elapsed * 2.3 + phase) * 45.0

			)

			if world_elapsed >= float(bat.get_meta("ignore_until")) and has_player_contact(bat.global_position, bat_wake_radius):

				# Touching a patrolling bat wakes it for one limited hunt.
				bat.set_meta("chasing", true)
				bat.set_meta("chase_started_at", world_elapsed)
				bat.set_meta("arming_time", bat_arm_delay)





func defeat_bat(bat: Sprite2D) -> void:

	bats.remove_child(bat)

	bat.queue_free()

	bat_kills += 1

	play_sfx(action_sound_player)

	update_kill_counter()





func bot_has_active_knife_near(world_position: Vector2) -> bool:

	for bot_node in bot_swings.get_children():

		var bot := bot_node as Node2D

		if bot and world_elapsed < float(bot.get_meta("knife_until")) and bot.global_position.distance_to(world_position) < 118.0:

			return true

	return false





func end_game() -> void:

	if game_over:
		return
	game_over = true

	velocity = Vector2.ZERO

	is_swinging = false

	swing_anchor = null

	swing_rope.hide()

	if flip_tween and flip_tween.is_running():

		flip_tween.kill()

	if jelly_tween and jelly_tween.is_running():

		jelly_tween.kill()

	if straighten_tween and straighten_tween.is_running():

		straighten_tween.kill()

	# A won Tag round goes straight to results; every other end gets a lucky spin.
	if active_game_mode == "TAG" and tag_round_won:
		finalize_game_over()
	else:
		# The game-over sting plays at the moment of death, then again on the
		# final game-over screen if the spin doesn't revive.
		play_sfx(game_over_sound_player)
		show_death_wheel()





func show_death_wheel() -> void:
	var wheel := PrizeWheel.new(active_game_mode != "TAG")
	wheel.finished.connect(_on_death_wheel_finished)
	wheel.spin_started.connect(func() -> void: play_sfx(wheel_spin_sound_player))
	wheel.landed.connect(func(_revive: bool) -> void: play_sfx(success_sound_player))
	add_child(wheel)





func _on_death_wheel_finished(coins: int, revive: bool) -> void:
	wallet_coins += coins
	save_profile()
	update_coin_counter()
	play_sfx(collect_sound_player)
	if revive:
		revive_player()
	else:
		finalize_game_over()





func finalize_game_over() -> void:
	if game_over_finalized:
		return
	game_over_finalized = true
	var won_tag := active_game_mode == "TAG" and tag_round_won
	var game_over_title := game_over_screen.get_node("GameOver") as Label
	if won_tag:
		# Last jelly standing: celebrate instead of the game-over sting.
		game_over_title.text = "YOU WIN!"
		wallet_coins += TAG_WIN_BONUS
		play_sfx(success_sound_player)
	else:
		game_over_title.text = "OOPS!"
		play_sfx(game_over_sound_player)
	if active_game_mode == "COIN" and coins_collected > coin_high_score:

		coin_high_score = coins_collected

	if active_game_mode == "CLIMB" and height_score > climb_high_score:

		climb_high_score = height_score

	best_height_score = climb_high_score

	high_score = coin_high_score if active_game_mode == "COIN" else climb_high_score

	save_high_score()

	update_high_score_label()

	game_over_screen.show()

	game_over_run_label.text = "Run: %d coins  •  %d bats" % [coins_collected, bat_kills] if active_game_mode == "COIN" else "Run: %dm high  •  %d coins  •  %d bats" % [height_score, coins_collected, bat_kills]
	if won_tag:
		game_over_best_label.text = "Last jelly standing!"
		game_over_run_label.text = "Winner bonus: +%d coins" % TAG_WIN_BONUS
		update_coin_counter()

	save_profile()
	continue_button.visible = not continue_used_this_run and active_game_mode != "TAG" and not tag_round_won
	CuteStyle.pop_in(game_over_card)
	if won_tag:
		return  # no interstitial right after a win
	game_overs_since_ad += 1
	if game_overs_since_ad >= INTERSTITIAL_EVERY_GAME_OVERS:
		game_overs_since_ad = 0
		# Results are already visible. A missing ad or cooldown never blocks them.
		ad_manager.try_show_death_interstitial()





func show_placeholder_ad(on_closed: Callable) -> void:
	# Real ads silence game audio, so the placeholder does too.
	ad_audio_muted = true
	apply_audio_settings()
	var ad := PlaceholderAd.new(5.0)
	ad.closed.connect(func() -> void:
		ad_audio_muted = false
		apply_audio_settings()
		if on_closed.is_valid():
			on_closed.call()
	)
	add_child(ad)





func _on_continue_pressed() -> void:
	if continue_used_this_run:
		return
	if OS.has_feature("ios"):
		if _request_native_reward("continue"):
			continue_used_this_run = true
			continue_button.hide()
		else:
			show_toast("Ad not ready yet. Try again in a moment!")
		return
	continue_used_this_run = true
	continue_button.hide()
	show_placeholder_ad(revive_player)





func revive_player() -> void:
	# Put Jelly back in the air above where the run ended, calm nearby bats,
	# and grant a few seconds of protection.
	game_over_screen.hide()
	var center := get_player_center()
	var min_y := CLIMB_LEVEL_TOP_Y + 420.0 if active_game_mode == "CLIMB" else 300.0
	var revive_center := Vector2(
		clampf(center.x, 180.0, map_width - 180.0),
		clampf(minf(center.y - 420.0, floor_y - 650.0), min_y, floor_y - 650.0)
	)
	block.position = revive_center - block.size / 2.0
	_finish_jump_visual_reset()
	velocity = Vector2(0.0, -700.0)
	is_swinging = false
	swing_anchor = null
	swing_rope.hide()
	is_pointer_held = false
	swing_attempted = false
	for bat_node in bats.get_children():
		var bat := bat_node as Sprite2D
		if bat:
			bat.set_meta("chasing", false)
			bat.set_meta("chase_started_at", -1.0)
			bat.set_meta("ignore_until", world_elapsed + REVIVE_SHIELD_SECONDS + 1.0)
	previous_player_center = get_player_center()
	revive_shield_time = REVIVE_SHIELD_SECONDS
	game_over = false
	game_over_finalized = false
	show_power_message("REVIVED!")
	play_sfx(revive_sound_player)
	if not background_music_player.playing:
		background_music_player.play()





func select_game_mode(mode: String) -> void:

	active_game_mode = mode

	high_score = coin_high_score if active_game_mode == "COIN" else climb_high_score

	start_game()





func start_game() -> void:

	if game_started:

		return

	game_started = true

	if not background_music_player.playing:

		background_music_player.stream = BACKGROUND_MUSIC if randi() % 2 == 0 else BACKGROUND_MUSIC_ALT

		background_music_player.play()

	start_screen.hide()

	coin_counter.show()

	high_score_label.show()

	kill_counter.show()

	height_score_label.visible = active_game_mode == "CLIMB"

	level_label.visible = active_game_mode == "CLIMB"

	tag_status_label.visible = active_game_mode == "TAG"

	# The coin leaderboard only applies to the score-chasing mode.
	leaderboard_panel.visible = active_game_mode == "COIN"

	restart_game()





func restart_game() -> void:

	game_over = false
	game_over_finalized = false

	continue_used_this_run = false

	revive_shield_time = 0.0

	block.modulate.a = 1.0

	velocity = Vector2.ZERO

	if active_game_mode == "CLIMB":
		climb_level = 1
		climb_height_bank = 0
		configure_climb_level()
		place_player_on_start_pad()

	else:
		climb_level = 1
		climb_height_bank = 0
		configure_standard_world()
		block.position = Vector2(300.0, 100.0)

	block.rotation = 0.0

	block.scale = Vector2.ONE

	run_start_height_y = get_player_center().y

	is_swinging = false

	swing_anchor = null

	swing_rope.hide()

	is_pointer_held = false

	coins_collected = 0

	height_score = 0

	bat_kills = 0

	magnet_time = 0.0

	knife_time = 0.0

	knife_angle = 0.0

	hold_elapsed = 0.0

	swing_attempted = false

	was_on_floor = false

	jump_cooldown_remaining = 0.0

	world_elapsed = 0.0

	tag_holders.clear()
	tag_times.clear()
	tag_chaser = null
	tag_transfer_cooldown_until = 0.0
	tag_ai_timer = 0.0
	tag_round_won = false

	bounce_pad_next_trigger_time = 0.0

	jelly_collision_next_time = 0.0

	power_message_time = 0.0

	if flip_tween and flip_tween.is_running():

		flip_tween.kill()

	if jelly_tween and jelly_tween.is_running():

		jelly_tween.kill()

	if straighten_tween and straighten_tween.is_running():

		straighten_tween.kill()

	populate_world()

	if active_game_mode == "TAG":
		setup_tag_round()
	else:
		block.modulate = Color.WHITE

	update_coin_counter()

	update_height_score()

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

	background_music_player.stop()

	is_swinging = false

	swing_anchor = null

	swing_rope.hide()

	is_pointer_held = false

	power_message.hide()

	hide_orbiting_knives()

	game_over_screen.hide()

	coin_counter.hide()

	high_score_label.hide()

	kill_counter.hide()

	height_score_label.hide()

	level_label.hide()

	tag_status_label.hide()

	leaderboard_panel.hide()

	update_high_score_label()

	start_screen.show()





func get_player_center() -> Vector2:

	# The rope endpoint, camera target, and collision center share Jelly's pivot.

	return jelly_sprite.global_position





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

		play_sfx(collect_sound_player)

		update_coin_counter()

		update_leaderboard()





func update_coin_counter() -> void:

	coin_counter.text = "Run: %d  Bank: %d" % [coins_collected, wallet_coins]

	menu_wallet_label.text = "COIN BANK: %d" % wallet_coins





func sanitize_player_name(raw: String) -> String:
	# Letters, digits and spaces only, upper-cased and short enough for labels.
	var cleaned := ""
	for character in raw.strip_edges().to_upper():
		var code := character.unicode_at(0)
		if (code >= 65 and code <= 90) or (code >= 48 and code <= 57) or code == 32:
			cleaned += character
	while cleaned.contains("  "):
		cleaned = cleaned.replace("  ", " ")
	return cleaned.strip_edges().substr(0, PLAYER_NAME_MAX).strip_edges()


func display_player_name() -> String:
	return player_name if not player_name.is_empty() else "YOU"


func set_player_name(raw: String) -> void:
	player_name = sanitize_player_name(raw)
	write_save()
	if game_started and not game_over:
		update_leaderboard()
		update_tag_status()


func _on_player_wall_bounce() -> void:
	if world_elapsed >= wall_bounce_sound_next:
		wall_bounce_sound_next = world_elapsed + 0.25
		play_sfx(bounce_sound_player)


func update_leaderboard() -> void:

	var standings: Array[Dictionary] = [{"name": display_player_name(), "coins": coins_collected}]

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





func update_height_score() -> void:

	# Banked height survives each completed Sky Climb course, so the center HUD
	# number never falls back to zero when the next level begins.
	var current_course_height: int = maxi(0, int((run_start_height_y - get_player_center().y) / 10.0))
	height_score = max(height_score, climb_height_bank + current_course_height)

	height_score_label.text = str(height_score)





func read_save_file() -> ConfigFile:
	# Load the save, falling back to the last good backup if the main file is
	# missing or unreadable. Returns null when there is no usable save yet.
	for path in [save_path, save_path + ".bak"]:
		if not FileAccess.file_exists(path):
			continue
		var save_file := ConfigFile.new()
		if save_file.load(path) == OK:
			return save_file
		push_warning("Save file %s could not be read; trying backup." % path)
	return null





func write_save() -> void:
	# Scores, profile and settings are written together so one section can
	# never overwrite another. The file is written to a temp path first and then
	# swapped in, keeping a .bak of the previous good save.
	var save_file := ConfigFile.new()
	save_file.set_value("meta", "save_version", SAVE_VERSION)
	save_file.set_value("scores", "high_score", coin_high_score)
	save_file.set_value("scores", "best_height_score", climb_high_score)
	save_file.set_value("scores", "coin_high_score", coin_high_score)
	save_file.set_value("scores", "climb_high_score", climb_high_score)
	save_file.set_value("profile", "wallet_coins", wallet_coins)
	save_file.set_value("profile", "selected_skin", selected_skin)
	save_file.set_value("profile", "pending_chest_skin", chest_pending_skin)
	save_file.set_value("profile", "player_name", player_name)
	var saved_skin_ids: Array[String] = []
	for skin_id in unlocked_skins:
		saved_skin_ids.append(str(skin_id))
	save_file.set_value("profile", "unlocked_skins", ",".join(saved_skin_ids))
	save_file.set_value("settings", "music_volume", music_volume)
	save_file.set_value("settings", "sfx_volume", sfx_volume)
	save_file.set_value("settings", "muted", audio_muted)
	var temp_path := save_path + ".tmp"
	if save_file.save(temp_path) != OK:
		push_warning("Could not write save file.")
		return
	if FileAccess.file_exists(save_path):
		DirAccess.copy_absolute(save_path, save_path + ".bak")
		DirAccess.remove_absolute(save_path)
	if DirAccess.rename_absolute(temp_path, save_path) != OK:
		save_file.save(save_path)





func load_high_score() -> void:
	var score_file := read_save_file()
	if score_file:
		coin_high_score = maxi(0, int(score_file.get_value("scores", "coin_high_score", score_file.get_value("scores", "high_score", 0))))
		climb_high_score = maxi(0, int(score_file.get_value("scores", "climb_high_score", score_file.get_value("scores", "best_height_score", 0))))
	best_height_score = climb_high_score
	high_score = coin_high_score





func load_profile() -> void:
	var profile_file := read_save_file()
	if profile_file:
		wallet_coins = maxi(0, int(profile_file.get_value("profile", "wallet_coins", 0)))
		selected_skin = int(profile_file.get_value("profile", "selected_skin", 0))
		var unlocked_text := str(profile_file.get_value("profile", "unlocked_skins", "0"))
		unlocked_skins.clear()
		for skin_id_text in unlocked_text.split(",", false):
			# Ignore anything that is not a valid skin id instead of crashing later.
			if not skin_id_text.strip_edges().is_valid_int():
				continue
			var skin_id := int(skin_id_text)
			if skin_id >= 0 and skin_id < skin_definitions.size() and not unlocked_skins.has(skin_id):
				unlocked_skins.append(skin_id)
		# A chest reward left unclaimed when the app closed is granted on launch.
		player_name = sanitize_player_name(str(profile_file.get_value("profile", "player_name", "")))
		var pending_from_save := int(profile_file.get_value("profile", "pending_chest_skin", -1))
		if pending_from_save >= 0 and pending_from_save < skin_definitions.size() and not unlocked_skins.has(pending_from_save):
			unlocked_skins.append(pending_from_save)
		music_volume = clampf(float(profile_file.get_value("settings", "music_volume", music_volume)), 0.0, 1.0)
		sfx_volume = clampf(float(profile_file.get_value("settings", "sfx_volume", sfx_volume)), 0.0, 1.0)
		audio_muted = bool(profile_file.get_value("settings", "muted", false))
	if not unlocked_skins.has(0):
		unlocked_skins.append(0)
	if selected_skin < 0 or selected_skin >= skin_definitions.size() or not unlocked_skins.has(selected_skin):
		selected_skin = 0
	apply_audio_settings()





func save_profile() -> void:
	write_save()





func save_high_score() -> void:
	write_save()





func update_high_score_label() -> void:

	if active_game_mode == "CLIMB":

		high_score_label.text = "Best Height: %dm" % climb_high_score

		game_over_best_label.text = "Best Height: %dm" % climb_high_score

	elif active_game_mode == "TAG":

		high_score_label.text = "TAG MODE"

		game_over_best_label.text = "Survive the tag timer"

	else:

		high_score_label.text = "Best Coins: %d" % coin_high_score

		game_over_best_label.text = "Best Coins: %d" % coin_high_score

	menu_best_label.text = "COIN BEST: %d   •   CLIMB BEST: %dm" % [coin_high_score, climb_high_score]





func apply_selected_skin() -> void:

	# Each skin is a real generated texture tile, not a color tint of the base Jelly.

	var selected_skin_texture := create_skin_texture(selected_skin)

	jelly_sprite.texture = selected_skin_texture

	jelly_base_scale = get_skin_sprite_scale(selected_skin, selected_skin_texture)

	jelly_sprite.scale = jelly_base_scale

	# The Sprite's origin is always the exact center of the gameplay hitbox.

	jelly_sprite.position = block.size * 0.5

	jelly_sprite.modulate = Color.WHITE

	block.color = Color.TRANSPARENT

	block.scale = Vector2.ONE





func get_skin_sprite_scale(skin_id: int, skin_texture: Texture2D) -> Vector2:

	# Keep the artwork about 96px, with a 105px hitbox giving it a small buffer.

	var source_edge := maxf(float(skin_texture.get_width()), float(skin_texture.get_height()))

	return Vector2.ONE * (96.0 / source_edge)





func create_skin_texture(skin_id: int) -> Texture2D:
	# Every playable Jelly and bot uses a sprite cut directly from the supplied collection sheet.
	var normalized_skin_id := clampi(skin_id, 0, skin_definitions.size() - 1)
	while jelly_sprite_textures.size() <= normalized_skin_id:
		var sprite_id := jelly_sprite_textures.size()
		jelly_sprite_textures.append(load("res://images/jelly_sprites/jelly_%02d.png" % sprite_id) as Texture2D)
	return jelly_sprite_textures[normalized_skin_id]



func build_skin_shop() -> void:

	for skin_button_node in skin_list.get_children():

		skin_list.remove_child(skin_button_node)

		skin_button_node.queue_free()

	for skin_id in range(skin_definitions.size()):

		var skin: Dictionary = skin_definitions[skin_id]

		var skin_button := TextureButton.new()

		skin_button.custom_minimum_size = Vector2(185.0, 142.0)

		skin_button.texture_normal = create_skin_texture(skin_id)

		skin_button.ignore_texture_size = true

		skin_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

		var owned := unlocked_skins.has(skin_id)
		# Rounded card tinted by rarity, drawn behind the Jelly artwork.
		var tier_color: Color = CuteStyle.rarity_color(str(skin.get("tier", "Common")))
		var card := Panel.new()
		card.show_behind_parent = true
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.position = Vector2(6.0, 4.0)
		card.size = skin_button.custom_minimum_size - Vector2(12.0, 8.0)
		card.add_theme_stylebox_override("panel", CuteStyle.box(Color(tier_color, 0.35 if owned else 0.18), 26, Color(tier_color, 0.9 if owned else 0.45), 3))
		skin_button.add_child(card)
		CuteStyle.add_squish(skin_button)

		if skin_id == selected_skin:

			skin_button.tooltip_text = "%s — EQUIPPED" % str(skin["name"])

			var equipped_outline := StyleBoxFlat.new()

			equipped_outline.bg_color = Color(1.0, 1.0, 1.0, 0.08)

			equipped_outline.border_width_left = 4

			equipped_outline.border_width_top = 4

			equipped_outline.border_width_right = 4

			equipped_outline.border_width_bottom = 4

			equipped_outline.border_color = CuteStyle.ACCENT

			equipped_outline.corner_radius_top_left = 14

			equipped_outline.corner_radius_top_right = 14

			equipped_outline.corner_radius_bottom_right = 14

			equipped_outline.corner_radius_bottom_left = 14

			equipped_outline.shadow_color = Color(CuteStyle.ACCENT, 0.45)

			equipped_outline.shadow_size = 9

			var outline_panel := Panel.new()

			outline_panel.position = Vector2(2.0, 2.0)

			outline_panel.size = skin_button.custom_minimum_size - Vector2(4.0, 4.0)

			outline_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

			outline_panel.add_theme_stylebox_override("panel", equipped_outline)

			skin_button.add_child(outline_panel)

		elif owned:

			skin_button.tooltip_text = "%s — OWNED" % str(skin["name"])

		else:

			skin_button.self_modulate = Color(0.42, 0.34, 0.55, 0.75)

			skin_button.tooltip_text = "%s — LOCKED" % str(skin["name"])

		skin_button.pressed.connect(_on_skin_button_pressed.bind(skin_id))

		skin_list.add_child(skin_button)

	shop_wallet_label.text = "COIN BANK: %d" % wallet_coins

	refresh_chest_selection_ui()

	chest_preview.hide()





func _on_skin_button_pressed(skin_id: int) -> void:

	# A swipe ends with a touch release. Do not treat that release as selecting a Jelly.

	if Time.get_ticks_msec() < jelly_swipe_release_msec:

		return

	buy_or_equip_skin(skin_id)





func buy_or_equip_skin(skin_id: int) -> void:

	if not unlocked_skins.has(skin_id):

		chest_result_label.text = "LOCKED — OPEN A CHEST TO UNLOCK"

		return

	selected_skin = skin_id

	apply_selected_skin()

	save_profile()

	update_coin_counter()

	build_skin_shop()





func select_chest(tier_name: String) -> void:

	# Picking another chest claims any Jelly still waiting from the last one.
	if chest_claim_button:
		claim_pending_chest()
	selected_chest_tier = tier_name

	refresh_chest_selection_ui()

	var chest_data: Dictionary = chest_definitions[selected_chest_tier]

	if bool(chest_data["available"]):

		var preview_rewards: Array[int] = []

		for reward_id in chest_data["rewards"]:

			preview_rewards.append(int(reward_id))

		prepare_chest_carousel(preview_rewards)

		chest_carousel_backdrop.show()

		chest_carousel.show()

		chest_result_label.text = "TAP OPEN TO SPIN"

	else:

		clear_chest_carousel()

		chest_carousel_backdrop.hide()

		chest_carousel.hide()





func refresh_chest_selection_ui() -> void:

	var chest_data: Dictionary = chest_definitions[selected_chest_tier]

	var is_available: bool = bool(chest_data["available"])

	chest_icon.texture = chest_data["texture"]

	chest_heading.text = "%s CHEST" % selected_chest_tier

	chest_description.text = str(chest_data["description"])

	common_chest_button.text = "OPEN %s CHEST — %d COINS" % [selected_chest_tier, int(chest_data["cost"])] if is_available else "%s CHEST — COMING SOON" % selected_chest_tier

	common_chest_button.disabled = chest_rolling or not is_available

	var pickers: Array[TextureButton] = [common_chest_picker, uncommon_chest_button, rare_chest_picker, epic_chest_picker, legendary_chest_picker]

	var picker_tiers: Array[String] = ["COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY"]

	for picker_index in range(pickers.size()):

		pickers[picker_index].disabled = chest_rolling

		pickers[picker_index].modulate = Color.WHITE if picker_tiers[picker_index] == selected_chest_tier else Color(0.55, 0.55, 0.65, 1.0)





func open_selected_chest() -> void:

	var chest_data: Dictionary = chest_definitions[selected_chest_tier]

	if not bool(chest_data["available"]):

		chest_result_label.text = "%s REWARDS ARE COMING SOON" % selected_chest_tier

		return

	var rewards: Array[int] = []

	for reward_id in chest_data["rewards"]:

		rewards.append(int(reward_id))

	open_chest(selected_chest_tier, int(chest_data["cost"]), rewards, chest_data["texture"], str(chest_data["description"]))





func claim_test_ad_reward() -> void:
	if ad_reward_button.disabled:
		return
	if OS.has_feature("ios"):
		if not _request_native_reward("coins"):
			ad_status_label.text = "AD UNAVAILABLE — TRY AGAIN LATER"
		return
	# The existing local/web placeholder remains a non-native test flow.
	ad_reward_button.disabled = true
	show_placeholder_ad(func() -> void:
		ad_reward_button.disabled = false
		wallet_coins += 10
		ad_status_label.text = "+10 COINS ADDED!"
		save_profile()
		update_coin_counter()
		build_skin_shop()
	)


func _request_native_reward(action: String) -> bool:
	if not pending_reward_action.is_empty():
		return false
	pending_reward_action = action
	reward_action_completed = false
	if not ad_manager.try_show_rewarded():
		pending_reward_action = ""
		return false
	if action == "coins":
		ad_reward_button.disabled = true
	return true


func _on_admob_reward_earned() -> void:
	if pending_reward_action.is_empty() or reward_action_completed:
		return
	reward_action_completed = true
	match pending_reward_action:
		"coins":
			wallet_coins += 10
			ad_status_label.text = "+10 COINS ADDED!"
			save_profile()
			update_coin_counter()
			build_skin_shop()
		"continue":
			revive_player()
		"reroll":
			_complete_chest_reroll()


func _on_admob_rewarded_finished() -> void:
	ad_reward_button.disabled = false
	chest_reroll_button.disabled = false
	if pending_reward_action == "continue" and not reward_action_completed:
		continue_used_this_run = false
		continue_button.visible = game_over and active_game_mode != "TAG"
	elif pending_reward_action == "coins" and not reward_action_completed:
		ad_status_label.text = "NO COINS AWARDED"
	pending_reward_action = ""
	reward_action_completed = false





func open_chest(tier_name: String, cost: int, reward_pool: Array[int], chest_texture: Texture2D, description: String) -> void:

	if chest_rolling or chest_pending_skin >= 0:
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
	chest_reroll_used = false
	save_profile()
	play_sfx(swoosh_sound_player)
	chest_target_skin = locked_skins.pick_random()

	chest_reward_pool = reward_pool

	chest_roll_elapsed = 0.0

	chest_next_tick = 0.0

	chest_rolling = true

	refresh_chest_selection_ui()

	prepare_chest_carousel(reward_pool, chest_target_skin)

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





func clear_chest_carousel() -> void:

	for carousel_item in chest_carousel_items:

		carousel_item.queue_free()

	chest_carousel_items.clear()





func prepare_chest_carousel(reward_pool: Array[int], final_skin_id: int = -1) -> void:

	clear_chest_carousel()

	var item_spacing := 70.0

	chest_carousel_target_index = 24

	chest_carousel_final_offset = chest_carousel_target_index * item_spacing + 29.0 - chest_carousel.size.x * 0.5

	for item_index in range(30):

		var reward_id: int = reward_pool.pick_random()

		if item_index == chest_carousel_target_index and final_skin_id >= 0:

			reward_id = final_skin_id

		# TextureButton with STRETCH_SCALE reliably fits both atlas tiles and the

		# generated food PNGs inside a fixed carousel card.

		var carousel_item := TextureButton.new()

		carousel_item.texture_normal = create_skin_texture(reward_id)

		# Fixed 58 × 64 cards keep every Jelly inside the case-opening strip.

		carousel_item.position = Vector2(item_index * item_spacing, 33.0)

		carousel_item.size = Vector2(58.0, 64.0)

		carousel_item.ignore_texture_size = true

		carousel_item.stretch_mode = TextureButton.STRETCH_SCALE

		carousel_item.mouse_filter = Control.MOUSE_FILTER_IGNORE

		chest_carousel.add_child(carousel_item)

		chest_carousel_items.append(carousel_item)





func update_chest_carousel(progress: float) -> void:

	# Cubic ease-out gives the carousel a quick start and a satisfying slow landing.

	var eased_progress := 1.0 - pow(1.0 - progress, 3.0)

	var offset := chest_carousel_final_offset * eased_progress

	for item_index in range(chest_carousel_items.size()):

		chest_carousel_items[item_index].position.x = item_index * 70.0 - offset





func finish_chest() -> void:
	chest_rolling = false
	chest_pending_skin = chest_target_skin
	# Persist the pending reward so closing the app mid-choice never loses it.
	save_profile()
	# Keep the winning Jelly centered in the spinner instead of switching to a
	# separate large cube preview.
	chest_preview.hide()
	chest_carousel_backdrop.show()
	chest_carousel.show()
	chest_result_label.text = "YOU GOT: %s!" % str(skin_definitions[chest_target_skin]["name"])
	play_sfx(success_sound_player)
	update_coin_counter()
	refresh_chest_claim_ui()





func chest_reroll_candidates() -> Array[int]:
	var candidates: Array[int] = []
	for skin_id in chest_reward_pool:
		if not unlocked_skins.has(skin_id) and skin_id != chest_pending_skin and not candidates.has(skin_id):
			candidates.append(skin_id)
	return candidates





func refresh_chest_claim_ui() -> void:
	var pending := chest_pending_skin >= 0
	var on_chest_tab := chest_tab_button.disabled
	chest_claim_button.visible = pending and on_chest_tab
	chest_reroll_button.visible = pending and on_chest_tab and not chest_reroll_used and not chest_reroll_candidates().is_empty()
	common_chest_button.visible = not pending and on_chest_tab
	shop_back_button.disabled = chest_rolling





func claim_pending_chest() -> void:
	if chest_pending_skin < 0:
		return
	var skin_id := chest_pending_skin
	chest_pending_skin = -1
	chest_reroll_used = false
	if not unlocked_skins.has(skin_id):
		unlocked_skins.append(skin_id)
	selected_skin = skin_id
	chest_result_label.text = "UNLOCKED: %s!" % str(skin_definitions[skin_id]["name"])
	play_sfx(collect_sound_player)
	apply_selected_skin()
	save_profile()
	update_coin_counter()
	build_skin_shop()
	refresh_chest_claim_ui()





func reroll_pending_chest() -> void:
	# One ad-funded reroll per chest; it always lands on a different Jelly.
	if chest_pending_skin < 0 or chest_reroll_used or chest_rolling:
		return
	if chest_reroll_candidates().is_empty():
		return
	if OS.has_feature("ios"):
		if not _request_native_reward("reroll"):
			show_toast("Ad not ready yet. Try again in a moment!")
		return
	chest_reroll_button.disabled = true
	show_placeholder_ad(func() -> void:
		chest_reroll_button.disabled = false
		_complete_chest_reroll()
	)


func _complete_chest_reroll() -> void:
	var candidates := chest_reroll_candidates()
	if candidates.is_empty():
		return
	chest_reroll_used = true
	chest_pending_skin = -1
	chest_target_skin = candidates.pick_random()
	chest_roll_elapsed = 0.0
	chest_next_tick = 0.0
	chest_rolling = true
	chest_claim_button.hide()
	chest_reroll_button.hide()
	shop_back_button.disabled = true
	play_sfx(swoosh_sound_player)
	prepare_chest_carousel(chest_reward_pool, chest_target_skin)
	chest_carousel_backdrop.show()
	chest_carousel.show()





func open_shop() -> void:

	build_skin_shop()

	start_screen.hide()

	shop_screen.show()

	set_shop_tab("chests")





func close_shop() -> void:
	# Never lose a won Jelly: leaving the shop claims anything still waiting.
	claim_pending_chest()
	shop_screen.hide()

	start_screen.show()





func _handle_jelly_swipe(event: InputEvent) -> bool:

	if not skin_scroll.visible:

		return false

	if event is InputEventScreenTouch:

		if event.pressed:

			jelly_swipe_tracking = true

			jelly_swipe_last_y = event.position.y

			jelly_swipe_distance = 0.0

		elif jelly_swipe_tracking:

			jelly_swipe_tracking = false

			if jelly_swipe_distance > 10.0:

				jelly_swipe_release_msec = Time.get_ticks_msec() + 180

				return true

	elif event is InputEventScreenDrag and jelly_swipe_tracking:

		_drag_jelly_list(event.position.y)

		return jelly_swipe_distance > 10.0

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:

			jelly_swipe_tracking = true

			jelly_swipe_last_y = event.position.y

			jelly_swipe_distance = 0.0

		elif jelly_swipe_tracking:

			jelly_swipe_tracking = false

			if jelly_swipe_distance > 10.0:

				jelly_swipe_release_msec = Time.get_ticks_msec() + 180

				return true

	elif event is InputEventMouseMotion and jelly_swipe_tracking and event.button_mask & MOUSE_BUTTON_MASK_LEFT:

		_drag_jelly_list(event.position.y)

		return jelly_swipe_distance > 10.0

	return false





func _drag_jelly_list(current_y: float) -> void:

	var delta_y := current_y - jelly_swipe_last_y

	if is_zero_approx(delta_y):

		return

	jelly_swipe_distance += absf(delta_y)

	jelly_swipe_last_y = current_y

	var scroll_bar := skin_scroll.get_v_scroll_bar()

	scroll_bar.value -= delta_y





func set_shop_tab(tab_name: String) -> void:

	var showing_chests := tab_name == "chests"

	var showing_jellies := tab_name == "jellies"

	var showing_coins := tab_name == "coins"

	common_chest_button.show() if showing_chests else common_chest_button.hide()

	chest_preview.hide()

	chest_carousel_backdrop.show() if showing_chests and (chest_rolling or not chest_carousel_items.is_empty()) else chest_carousel_backdrop.hide()

	chest_carousel.show() if showing_chests and (chest_rolling or not chest_carousel_items.is_empty()) else chest_carousel.hide()

	chest_result_label.show() if showing_chests else chest_result_label.hide()

	skin_catalog.hide()

	chest_icon.show() if showing_chests else chest_icon.hide()

	chest_card.show() if showing_chests else chest_card.hide()

	chest_heading.show() if showing_chests else chest_heading.hide()

	chest_description.show() if showing_chests else chest_description.hide()

	future_chest_row.show() if showing_chests else future_chest_row.hide()

	skin_scroll.show() if showing_jellies else skin_scroll.hide()

	if showing_jellies:

		skin_scroll.get_v_scroll_bar().value = 0.0

	ad_panel.show() if showing_coins else ad_panel.hide()

	chest_tab_button.disabled = showing_chests

	jelly_tab_button.disabled = showing_jellies

	coins_tab_button.disabled = showing_coins
	if chest_claim_button:
		refresh_chest_claim_ui()
func _input(event: InputEvent) -> void:

	# iPhone browsers can send touch events directly to the viewport instead of

	# the nested ScrollContainer. Read raw input while the collection is open so

	# a drag works from any part of the Jelly page, including directly on a card.

	if shop_screen.visible:

		if _handle_jelly_swipe(event):

			get_viewport().set_input_as_handled()

		return

	if not game_started or game_over or get_tree().paused:
		return
	# Taps on the pause button belong to the button, not to the jelly.
	if pause_button and pause_button.visible and (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		if pause_button.get_global_rect().grow(12.0).has_point(event.position):
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
	# A release without a matching press (e.g. lifting the finger that tapped
	# Resume or a menu button) must not trigger a surprise jump.
	if not is_pointer_held:
		return
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

	play_sfx(swoosh_sound_player)

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

	play_sfx(jump_sound_player)

	was_on_floor = false

	jump_cooldown_remaining = jump_cooldown



	# Stop existing animations

	if flip_tween and flip_tween.is_running():

		flip_tween.kill()



	if jelly_tween and jelly_tween.is_running():

		jelly_tween.kill()



	if straighten_tween and straighten_tween.is_running():

		straighten_tween.kill()



	# A tap-jump starts from the same clean state as a bounce-pad launch.

	block.rotation = 0.0

	block.scale = Vector2.ONE

	jelly_sprite.position = block.size * 0.5

	jelly_sprite.scale = jelly_base_scale



	# Random clockwise or counterclockwise spin

	var direction: int = [-1, 1].pick_random()

	# A whole number of turns lands naturally upright instead of snapping back.

	var spin_amount: float = float([1, 2].pick_random()) * TAU



	flip_tween = create_tween()

	flip_tween.tween_property(

		block,

		"rotation",

		block.rotation + spin_amount * direction,

		0.50

	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	flip_tween.tween_callback(_finish_jump_visual_reset)



	# Deform only the artwork, so Jelly feels elastic while the hitbox stays stable.

	jelly_tween = create_tween()

	jelly_tween.tween_property(jelly_sprite, "scale", jelly_base_scale * Vector2(0.82, 1.18), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	jelly_tween.tween_property(jelly_sprite, "scale", jelly_base_scale * Vector2(1.14, 0.88), 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	jelly_tween.tween_property(jelly_sprite, "scale", jelly_base_scale, 0.22).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)



	# Keep the displayed Jelly exactly aligned with the fixed gameplay hitbox.

	# Scaling the parent made the visual larger than collisions during a jump.

	block.scale = Vector2.ONE

	jelly_sprite.position = block.size * 0.5





func _finish_jump_visual_reset() -> void:

	# Restore the clean hitbox-aligned look exactly 0.5 seconds after launching.

	block.rotation = 0.0

	block.scale = Vector2.ONE

	jelly_sprite.position = block.size * 0.5

	jelly_sprite.scale = jelly_base_scale





func _draw() -> void:

	# Only draw the part of the world currently on screen. The old version drew

	# the entire 12,000px map every frame, even though a phone sees only a slice.

	var viewport_size := get_viewport_rect().size

	var visible_size := viewport_size / camera.zoom

	var visible_bounds := Rect2(camera.global_position - visible_size * 0.6, visible_size * 1.2)

	var expanded_bounds := visible_bounds.grow(90.0)



	# Paint a soft sky gradient behind the visible play area.

	var sky_start_y := -1600.0

	var sky_height := floor_y - sky_start_y + 120.0

	var sky_strips := 28

	var strip_height := sky_height / sky_strips

	for strip in range(sky_strips):

		var blend := float(strip) / float(sky_strips - 1)

		var strip_color := sky_top_color.lerp(sky_bottom_color, blend)

		draw_rect(

			Rect2(visible_bounds.position.x - 32.0, sky_start_y + strip * strip_height, visible_bounds.size.x + 64.0, strip_height + 1.0),

			strip_color

		)



	draw_sky_decorations(visible_bounds)
	# A soft candy rim makes the ceiling and side walls easy to recognize.

	var map_border := Rect2(0.0, 0.0, map_width, floor_y)

	if active_game_mode == "CLIMB":
		# Climb courses stack into one endless sky: no rim, and the sky keeps
		# going below the floor line instead of ending in a hard edge.
		draw_rect(Rect2(visible_bounds.position.x - 32.0, floor_y, visible_bounds.size.x + 64.0, 2400.0), sky_bottom_color)
	else:
		draw_rect(map_border, Color(0.4, 0.72, 1.0, 0.25), false, 28.0, true)

		draw_rect(map_border, Color(0.45, 0.76, 1.0, 0.95), false, 8.0, true)



	# Draw collectible coins over the sky, beneath the game objects.

	for coin_position in coin_positions:

		if expanded_bounds.has_point(coin_position):

			draw_cute_coin(coin_position, 15.0)
	for big_coin_position in big_coin_positions:

		if expanded_bounds.has_point(big_coin_position):

			draw_cute_coin(big_coin_position, 30.0)
	# Neon spring pads are drawn in-world rather than as dozens of extra nodes.

	for pad_position in bounce_pad_positions:

		if expanded_bounds.has_point(pad_position):

			draw_cute_pad(pad_position)
	# Bright rolling embers make level one's lava readable. Later Sky Climb
	# floors are deliberately quiet voids instead.
	if visible_bounds.end.y >= floor_y - 70.0 and not (active_game_mode == "CLIMB" and climb_level > 1):

		var ember_start: int = max(0, int(visible_bounds.position.x / 56.0) * 56)

		var ember_end: int = min(int(map_width), int(visible_bounds.end.x / 56.0 + 1.0) * 56)

		for ember_x in range(ember_start, ember_end, 56):

			var ember_y := floor_y - 7.0 + sin(world_elapsed * 3.0 + float(ember_x) * 0.08) * 8.0

			draw_circle(Vector2(float(ember_x), ember_y), 11.0, Color("ffd2a6"))
			draw_circle(Vector2(float(ember_x) - 3.0, ember_y - 3.0), 3.5, Color(1.0, 1.0, 1.0, 0.8))



	# Friendly bots use thinner lavender tethers so they read as background activity.

	for bot_node in bot_swings.get_children():

		var bot := bot_node as Node2D

		if bot and not bool(bot.get_meta("rope_cut")) and expanded_bounds.has_point(bot.global_position):

			var bot_anchor_position: Vector2 = bot.get_meta("from_anchor")

			draw_line(bot_anchor_position, bot.global_position, Color(0.72, 0.55, 0.95, 0.8), 3.0, true)





func draw_sky_decorations(visible_bounds: Rect2) -> void:
	# Fluffy clouds and twinkling sparkles, placed by hashing fixed grid cells so
	# they never pop around and only the cells on screen cost anything.
	var cell := Vector2(460.0, 380.0)
	var first := Vector2i(floori(visible_bounds.position.x / cell.x) - 1, floori(visible_bounds.position.y / cell.y) - 1)
	var last := Vector2i(floori(visible_bounds.end.x / cell.x) + 1, floori(visible_bounds.end.y / cell.y) + 1)
	for cell_y in range(first.y, last.y + 1):
		for cell_x in range(first.x, last.x + 1):
			var seed_value := absi(cell_x * 73856093 ^ cell_y * 19349663)
			var base := Vector2(cell_x, cell_y) * cell + Vector2(float(seed_value % 300), float((seed_value / 7) % 260))
			if seed_value % 3 != 0:
				var drift := sin(world_elapsed * 0.25 + float(seed_value % 17)) * 26.0
				var cloud_scale := 0.75 + float(seed_value % 5) * 0.12
				draw_cute_cloud(base + Vector2(drift, 0.0), cloud_scale)
			var sparkle_pos := base + Vector2(210.0, -120.0)
			var twinkle := 0.5 + 0.5 * sin(world_elapsed * 3.0 + float(seed_value % 11))
			draw_sparkle(sparkle_pos, 7.0 + twinkle * 5.0, Color(1.0, 1.0, 1.0, 0.35 + twinkle * 0.5))





func draw_cute_cloud(center: Vector2, cloud_scale: float) -> void:
	var puff := Color(1.0, 1.0, 1.0, 0.72)
	var shade := Color(0.84, 0.93, 1.0, 0.6)
	draw_circle(center + Vector2(-58.0, 14.0) * cloud_scale, 40.0 * cloud_scale, shade)
	draw_circle(center + Vector2(52.0, 16.0) * cloud_scale, 42.0 * cloud_scale, shade)
	draw_circle(center + Vector2(-50.0, 8.0) * cloud_scale, 40.0 * cloud_scale, puff)
	draw_circle(center + Vector2(0.0, -14.0) * cloud_scale, 54.0 * cloud_scale, puff)
	draw_circle(center + Vector2(56.0, 8.0) * cloud_scale, 40.0 * cloud_scale, puff)
	draw_rect(Rect2(center + Vector2(-58.0, 8.0) * cloud_scale, Vector2(116.0, 40.0) * cloud_scale), puff)





func draw_sparkle(center: Vector2, size: float, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0.0, -size), center + Vector2(size * 0.22, -size * 0.22),
		center + Vector2(size, 0.0), center + Vector2(size * 0.22, size * 0.22),
		center + Vector2(0.0, size), center + Vector2(-size * 0.22, size * 0.22),
		center + Vector2(-size, 0.0), center + Vector2(-size * 0.22, -size * 0.22),
	])
	draw_colored_polygon(points, color)





func draw_cute_coin(center: Vector2, radius: float) -> void:
	# Gentle bob and a glossy highlight so coins look like candy buttons.
	var bob := Vector2(0.0, sin(world_elapsed * 3.0 + center.x * 0.02) * radius * 0.12)
	var c := center + bob
	draw_circle(c + Vector2(0.0, radius * 0.12), radius, Color(0.85, 0.5, 0.2, 0.25))
	draw_circle(c, radius, Color("f2a93b"))
	draw_circle(c, radius * 0.8, Color("ffd45c"))
	draw_arc(c, radius * 0.55, 0.0, TAU, 20, Color("fff1a8"), maxf(2.0, radius * 0.1), true)
	draw_circle(c + Vector2(-radius * 0.35, -radius * 0.38), radius * 0.2, Color(1.0, 1.0, 1.0, 0.85))





func draw_cute_pad(pad_position: Vector2) -> void:
	# Marshmallow bounce pad: a squishy capsule with a little face.
	var pad_rect := Rect2(pad_position - bounce_pad_size * 0.5, bounce_pad_size)
	var squish := 1.0 + sin(world_elapsed * 5.0 + pad_position.x * 0.01) * 0.04
	var half_h := pad_rect.size.y * 0.5 * squish
	var radius := maxf(half_h, 6.0)
	var left := Vector2(pad_rect.position.x + radius, pad_position.y)
	var right := Vector2(pad_rect.end.x - radius, pad_position.y)
	var outline := Color("ffffff")
	var body := Color("5fd6c6")
	draw_circle(left, radius + 3.0, outline)
	draw_circle(right, radius + 3.0, outline)
	draw_rect(Rect2(left - Vector2(0.0, radius + 3.0), Vector2(right.x - left.x, (radius + 3.0) * 2.0)), outline)
	draw_circle(left, radius, body)
	draw_circle(right, radius, body)
	draw_rect(Rect2(left - Vector2(0.0, radius), Vector2(right.x - left.x, radius * 2.0)), body)
	draw_line(left + Vector2(2.0, -radius * 0.45), right + Vector2(-2.0, -radius * 0.45), Color(1.0, 1.0, 1.0, 0.7), 3.0, true)
	var face := pad_position + Vector2(0.0, radius * 0.1)
	draw_circle(face + Vector2(-10.0, -1.0), 2.6, CuteStyle.INK)
	draw_circle(face + Vector2(10.0, -1.0), 2.6, CuteStyle.INK)
	draw_arc(face + Vector2(0.0, 1.0), 4.5, 0.2, PI - 0.2, 8, CuteStyle.INK, 2.0, true)





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



	# Do not squash the parent: collision uses the unscaled 48x48 hitbox.

	block.scale = Vector2.ONE

	jelly_sprite.position = block.size * 0.5

	jelly_sprite.scale = jelly_base_scale

extends SceneTree
# Renders the six App Store screenshots of the current build.
# Run with a window at the store size, e.g.:
#   xvfb-run -s "-screen 0 1320x2868x24" godot --path . --rendering-driver opengl3 \
#     --resolution 1320x2868 -s tools/store_screenshots.gd -- store/screenshots/iphone-6.9

var out_dir := ""


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	out_dir = args[0] if args.size() > 0 else "store/screenshots/tmp"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + out_dir))
	_run.call_deferred()


func shot(name: String) -> void:
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://%s/%s.png" % [out_dir, name]))


func hold(g, frames: int, at := Vector2.INF, swing := false) -> void:
	for i in range(frames):
		g.revive_shield_time = 0.0
		g.block.modulate.a = 1.0
		if at != Vector2.INF:
			g.block.position = at - g.block.size / 2.0
			g.velocity = Vector2(80, -30)
			g.previous_player_center = g.get_player_center()
		await physics_frame


func _run() -> void:
	var g = load("res://game.tscn").instantiate()
	g.save_path = "user://store_shots.cfg"
	g.auto_show_tutorial = false
	root.add_child(g)
	await create_timer(3.0).timeout
	# A good-looking profile: some jellies, coins, an effect and power-ups.
	g.wallet_coins = 640
	for skin_id in [1, 4, 5, 11, 15, 21, 24, 33, 41, 50, 52]:
		if not g.unlocked_skins.has(skin_id):
			g.unlocked_skins.append(skin_id)
	g.selected_skin = 5
	var owned: Array[String] = ["hearts", "rainbow", "glow"]
	g.effects_owned = owned
	g.selected_effect = "hearts"
	g.powerup_inventory = {"rocket": 2, "magnet": 1, "wild": 1}
	g.apply_selected_skin()
	g.update_coin_counter()
	# No placeholder ad strip in store screenshots.
	if g.banner_ad:
		g.banner_ad.queue_free()
		g.banner_ad = null
	await create_timer(0.5).timeout
	await shot("1_menu")

	g.select_game_mode("COIN")
	g.coins_collected = 37
	g.coin_time_left = 63.0
	g.update_coin_counter()
	var bots: Array = g.bot_swings.get_children()
	for i in range(bots.size()):
		bots[i].set_meta("coins", [29, 24, 18, 11, 6][i % 5])
	await hold(g, 90)
	g.update_coin_counter()
	g.power_message.hide()
	await shot("2_coin_run")
	g.return_to_main_menu()

	g.select_game_mode("CLIMB")
	g.climb_level = 2
	g.configure_climb_level()
	g.populate_world()
	g.clear_spider_webs()
	var tower: Vector2 = g.climb_scenery[0]["pos"] + Vector2(120, -700)
	await hold(g, 40, tower)
	await shot("3_sky_climb")
	g.return_to_main_menu()

	g.select_game_mode("TAG")
	await hold(g, 60)
	var nearby: Array = g.bot_swings.get_children()
	for i in range(mini(3, nearby.size())):
		nearby[i].global_position = g.get_player_center() + Vector2(-220 + i * 220, -260 + (i % 2) * 120)
	g.replace_tag_holder(g.tag_holders[0], g.block)
	await hold(g, 4)
	await shot("4_jelly_tag")
	g.return_to_main_menu()

	g.season_override = "fall"
	g.open_shop()
	g.select_chest("SPARKLE")
	await create_timer(0.4).timeout
	await shot("5_chests")
	g.set_shop_tab("effects")
	await create_timer(0.4).timeout
	await shot("6_effects")
	quit()

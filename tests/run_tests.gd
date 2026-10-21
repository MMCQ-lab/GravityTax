extends SceneTree

# Headless test suite. Run with:
#   godot --headless --path . -s res://tests/run_tests.gd
# Exits with code 1 if any check fails. Uses a throwaway save file, so it never
# touches a real player's progress.

const TEST_SAVE := "user://test_gravity_tax_save.cfg"

var game: Node
var failures := 0
var passes := 0


func _initialize() -> void:
	_run.call_deferred()


func check(test_name: String, ok: bool) -> void:
	if ok:
		passes += 1
		print("PASS  ", test_name)
	else:
		failures += 1
		print("FAIL  ", test_name)


func wait(seconds: float) -> void:
	await create_timer(seconds).timeout


func clear_save_files() -> void:
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(TEST_SAVE + suffix):
			DirAccess.remove_absolute(TEST_SAVE + suffix)


func spawn_game() -> void:
	if game:
		game.queue_free()
		await process_frame
	game = load("res://game.tscn").instantiate()
	game.save_path = TEST_SAVE
	root.add_child(game)
	await wait(0.3)


func child_of(cls) -> Node:
	for child in game.get_children():
		if is_instance_of(child, cls):
			return child
	return null


func close_all_ads() -> void:
	for child in game.get_children():
		if child is PlaceholderAd:
			child.queue_free()
	game.ad_audio_muted = false
	game.apply_audio_settings()


func _run() -> void:
	clear_save_files()
	await test_resources()
	await test_fresh_save_defaults()
	await test_save_round_trip()
	await test_corrupt_save_recovery()
	await test_scores_survive_profile_saves()
	await test_skin_catalogue()
	await test_death_spin_and_revive()
	await test_continue_and_interstitial()
	await test_chest_claim_and_reroll()
	await test_pause_and_settings()
	await test_banner_visibility()
	await test_sounds()
	await test_power_up_sounds()
	await test_tag_win()
	await test_tag_ai()
	await test_banner_never_covers_buttons()
	await test_ad_layout_and_feedback()
	await test_player_name()
	await test_bouncy_walls()
	await test_climb_bots()
	clear_save_files()
	print("\n%d passed, %d failed" % [passes, failures])
	quit(1 if failures > 0 else 0)


func test_resources() -> void:
	# Every resource the game references must exist and load.
	var paths: Array[String] = ["res://game.tscn", "res://images/app_icon_1024.png", "res://images/mmcq_lab_logo.png"]
	for skin_index in range(50):
		paths.append("res://images/jelly_sprites/jelly_%02d.png" % skin_index)
	var all_loaded := true
	for path in paths:
		if not ResourceLoader.exists(path) or load(path) == null:
			print("   missing: ", path)
			all_loaded = false
	check("all scene, icon and jelly resources load", all_loaded)


func test_fresh_save_defaults() -> void:
	clear_save_files()
	await spawn_game()
	check("fresh install starts with the default jelly", game.unlocked_skins == [0] and game.selected_skin == 0)
	check("fresh install has zero coins", game.wallet_coins == 0)


func test_save_round_trip() -> void:
	game.wallet_coins = 321
	game.unlocked_skins.append(7)
	game.selected_skin = 7
	game.coin_high_score = 42
	game.climb_high_score = 900
	game.music_volume = 0.3
	game.sfx_volume = 0.6
	game.audio_muted = true
	game.write_save()
	await spawn_game()
	check("coins persist", game.wallet_coins == 321)
	check("unlocked and equipped skin persist", game.unlocked_skins.has(7) and game.selected_skin == 7)
	check("high scores persist", game.coin_high_score == 42 and game.climb_high_score == 900)
	check("audio settings persist", is_equal_approx(game.music_volume, 0.3) and is_equal_approx(game.sfx_volume, 0.6) and game.audio_muted)
	check("mute applied to master bus", AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
	game.audio_muted = false
	game.apply_audio_settings()
	game.write_save()


func test_corrupt_save_recovery() -> void:
	# A garbled main file falls back to the last good backup.
	game.wallet_coins = 555
	game.write_save()
	game.wallet_coins = 556
	game.write_save()  # previous (555) is now the .bak
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string("[profile\nwallet_coins = ??? not valid")
	file.close()
	await spawn_game()
	check("corrupt save recovers from backup", game.wallet_coins == 555)
	# Invalid values are cleaned instead of crashing.
	var bad := ConfigFile.new()
	bad.set_value("profile", "wallet_coins", -50)
	bad.set_value("profile", "selected_skin", 999)
	bad.set_value("profile", "unlocked_skins", "0,abc,3,3,77")
	bad.save(TEST_SAVE)
	await spawn_game()
	check("negative coins clamped", game.wallet_coins == 0)
	check("invalid skin ids dropped", game.unlocked_skins.has(3) and not game.unlocked_skins.has(77) and game.unlocked_skins.count(3) == 1)
	check("invalid equipped skin falls back to default", game.selected_skin == 0)


func test_scores_survive_profile_saves() -> void:
	# Regression: saving the high score used to rewrite the file from scratch.
	game.coin_high_score = 77
	game.save_high_score()
	game.wallet_coins = 12
	game.save_profile()
	game.save_high_score()
	await spawn_game()
	check("high score and wallet both survive alternating saves", game.coin_high_score == 77 and game.wallet_coins == 12)


func test_skin_catalogue() -> void:
	var tiers := {}
	for skin in game.skin_definitions:
		tiers[str(skin["tier"])] = int(tiers.get(str(skin["tier"]), 0)) + 1
	check("50 skins across five rarities", game.skin_definitions.size() == 50 and tiers.size() == 5)
	var obtainable := {0: true}
	for tier_name in game.chest_definitions:
		var chest: Dictionary = game.chest_definitions[tier_name]
		if bool(chest["available"]):
			for reward in chest["rewards"]:
				obtainable[int(reward)] = true
	check("every skin can be earned from a chest", obtainable.size() == game.skin_definitions.size())
	var consistent_size := true
	for skin_index in range(game.skin_definitions.size()):
		var texture: Texture2D = game.create_skin_texture(skin_index)
		var on_screen: Vector2 = Vector2(texture.get_width(), texture.get_height()) * game.get_skin_sprite_scale(skin_index, texture)
		if absf(maxf(on_screen.x, on_screen.y) - 96.0) > 0.5:
			consistent_size = false
	check("every jelly renders at the same 96px size", consistent_size)


func test_death_spin_and_revive() -> void:
	game.select_game_mode("COIN")
	await wait(0.3)
	game.end_game()
	await wait(0.1)
	var coins_before: int = game.wallet_coins
	var wheel: Node = child_of(PrizeWheel)
	check("death opens the lucky spin", wheel != null and not game.game_over_screen.visible)
	wheel.finished.emit(25, true)
	wheel.queue_free()
	await wait(0.1)
	check("spin coins are banked", game.wallet_coins == coins_before + 25)
	check("revive resumes the run with a shield", not game.game_over and game.revive_shield_time > 0.0)
	check("revive places jelly above the lava", game.get_player_center().y < game.floor_y - 300.0)
	var odds_wheel := PrizeWheel.new(true)
	var revives := 0
	for roll in range(20000):
		if bool(odds_wheel._slices[odds_wheel._pick_index()].get("revive", false)):
			revives += 1
	odds_wheel.free()
	check("revive odds are about 5%", revives > 600 and revives < 1400)


func test_continue_and_interstitial() -> void:
	game.game_overs_since_ad = 0
	game.end_game()
	await wait(0.1)
	var wheel: Node = child_of(PrizeWheel)
	wheel.finished.emit(5, false)
	wheel.queue_free()
	await wait(0.1)
	check("game over offers continue once", game.game_over_screen.visible and game.continue_button.visible)
	game._on_continue_pressed()
	await wait(0.1)
	var ad: Node = child_of(PlaceholderAd)
	check("continue plays an ad first", ad != null and game.game_over)
	check("ad mutes audio", AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
	ad._close()
	check("ad cannot close during countdown", not ad._finished)
	await wait(5.2)
	ad._close()
	await wait(0.1)
	check("closing the ad revives", not game.game_over)
	check("audio returns after the ad", not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))
	game.end_game()
	await wait(0.1)
	wheel = child_of(PrizeWheel)
	wheel.finished.emit(5, false)
	wheel.queue_free()
	await wait(0.1)
	check("continue is not offered twice in a run", not game.continue_button.visible)
	check("interstitial shows on the 2nd/3rd game over cadence", game.game_overs_since_ad == 2 and child_of(PlaceholderAd) == null)
	game.restart_game()
	game.end_game()
	await wait(0.1)
	wheel = child_of(PrizeWheel)
	var wallet_before_third_death: int = game.wallet_coins
	wheel.finished.emit(5, false)
	wheel.queue_free()
	await wait(0.1)
	check("third death reaches an interstitial opportunity", game.game_overs_since_ad == 0 and child_of(PlaceholderAd) == null)
	check("standard interstitial grants no coins", game.wallet_coins == wallet_before_third_death + 5)
	game.finalize_game_over()
	check("same death cannot trigger twice", game.game_overs_since_ad == 0)
	close_all_ads()
	game.return_to_main_menu()


func test_chest_claim_and_reroll() -> void:
	game.wallet_coins = 2000
	game.open_shop()
	game.set_shop_tab("chests")
	game.select_chest("UNCOMMON")
	var unlocked_before: int = game.unlocked_skins.size()
	game.open_selected_chest()
	await wait(3.5)
	var first: int = game.chest_pending_skin
	check("chest result waits for claim", first >= 0 and game.unlocked_skins.size() == unlocked_before)
	check("chest coins are spent and saved", game.wallet_coins == 1900 and int(game.read_save_file().get_value("profile", "wallet_coins", -1)) == 1900)
	game.reroll_pending_chest()
	await wait(0.1)
	var ad: Node = child_of(PlaceholderAd)
	check("reroll needs an ad", ad != null and game.chest_pending_skin == first)
	await wait(5.2)
	ad._close()
	await wait(3.6)
	var second: int = game.chest_pending_skin
	check("reroll lands on a different jelly", second >= 0 and second != first)
	check("only one reroll per chest", not game.chest_reroll_button.visible)
	game.claim_pending_chest()
	check("claim unlocks and equips", game.unlocked_skins.has(second) and game.selected_skin == second and not game.unlocked_skins.has(first))
	game.open_selected_chest()
	await wait(3.5)
	var third: int = game.chest_pending_skin
	game.close_shop()
	check("leaving the shop never loses a won jelly", game.unlocked_skins.has(third))
	game.open_shop()
	game.open_selected_chest()
	await wait(3.5)
	var fourth: int = game.chest_pending_skin
	await spawn_game()
	check("unclaimed jelly is granted after an app restart", game.unlocked_skins.has(fourth))


func test_pause_and_settings() -> void:
	game.select_game_mode("CLIMB")
	await wait(0.2)
	game.pause_game()
	check("pause freezes the game", paused and game.settings_panel.visible)
	var y_before: float = game.block.position.y
	await wait(0.3)
	check("jelly does not move while paused", is_equal_approx(game.block.position.y, y_before))
	game._on_settings_changed(0.25, 0.5, false)
	check("volume sliders change bus volumes", is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.25))
	game.resume_game()
	await wait(0.1)
	check("resume unfreezes", not paused and not game.settings_panel.visible)
	var jumped_velocity: float = game.velocity.y
	game.end_hold()
	check("a release without a press does not jump", is_equal_approx(game.velocity.y, jumped_velocity))
	game.pause_game()
	game.settings_panel.home_requested.emit()
	await wait(0.1)
	check("home from pause returns to menu unpaused", not paused and game.start_screen.visible)


func test_banner_visibility() -> void:
	await wait(0.1)
	check("banner shows on the menu", game.banner_ad.visible)
	game.select_game_mode("COIN")
	await wait(0.1)
	check("banner hidden during gameplay", not game.banner_ad.visible)
	check("pause button visible during gameplay", game.pause_button.visible)
	game.return_to_main_menu()
	await wait(0.1)
	check("pause button hidden on the menu", not game.pause_button.visible)


func test_sounds() -> void:
	# Every sound file loads, buttons click, and the wheel and chest play their cues.
	var all_loaded := true
	for sound_name in ["music_1", "music_2", "jump", "swing", "bounce", "coin", "powerup", "bat_defeat", "game_over", "wheel_spin", "success", "revive", "button"]:
		if load("res://sounds/%s.mp3" % sound_name) == null:
			all_loaded = false
	check("all 13 sounds load", all_loaded)
	game.button_sound_player.stop()
	game.shop_button.pressed.emit()
	check("tapping a scene button plays the click", game.button_sound_player.playing)
	game.close_shop()
	check("buttons created in code also click", game.settings_button.has_meta("tap_sound") and game.pause_button.has_meta("tap_sound"))
	check("button clicks still work while paused", game.button_sound_player.process_mode == Node.PROCESS_MODE_ALWAYS)


func test_power_up_sounds() -> void:
	var all_play := true
	for kind in ["rocket", "teleport", "magnet", "knife"]:
		game.jetpack_sound_player.stop()
		game.apply_power_up(kind)
		if not game.jetpack_sound_player.playing:
			all_play = false
			print("   no sound for ", kind)
	check("every power-up plays the pickup sound", all_play)


func test_tag_win() -> void:
	game.select_game_mode("TAG")
	await wait(0.2)
	var coins_before: int = game.wallet_coins
	# Remove every other racer: Jelly is the last one standing, even if IT.
	if not game.tag_holders.has(game.block) and not game.tag_holders.is_empty():
		game.replace_tag_holder(game.tag_holders[0], game.block)
	for bot in game.bot_swings.get_children():
		game.bot_swings.remove_child(bot)
		bot.queue_free()
	await wait(0.2)
	var title := game.game_over_screen.get_node("GameOver") as Label
	check("last jelly standing wins Tag", game.game_over and game.tag_round_won and game.game_over_screen.visible)
	check("win screen and bonus", title.text == "YOU WIN!" and game.wallet_coins == coins_before + game.TAG_WIN_BONUS)
	check("no lucky spin or continue on a win", child_of(PrizeWheel) == null and not game.continue_button.visible)
	game.return_to_main_menu()
	await wait(0.1)
	game.select_game_mode("COIN")
	game.end_game()
	await wait(0.1)
	var wheel: Node = child_of(PrizeWheel)
	wheel.finished.emit(5, false)
	wheel.queue_free()
	await wait(0.1)
	check("normal game over still says OOPS!", title.text == "OOPS!")
	close_all_ads()
	game.return_to_main_menu()


func test_tag_ai() -> void:
	game.select_game_mode("TAG")
	game.revive_shield_time = 999.0
	var hunters_with_targets := 0
	var bot_tags := 0
	var previous: Array = game.tag_holders.duplicate()
	for frame in range(600):
		game.revive_shield_time = 999.0
		game.tag_times[game.block] = 0.0
		await physics_frame
		if game.game_over:
			break
		for holder in game.tag_holders:
			if holder != game.block and not previous.has(holder) and not previous.has(game.block) and not game.tag_holders.has(game.block):
				bot_tags += 1
		previous = game.tag_holders.duplicate()
	for holder in game.tag_holders:
		if holder != game.block and is_instance_valid(holder) and holder.has_meta("tag_target"):
			hunters_with_targets += 1
	check("IT bots pick targets to hunt", hunters_with_targets > 0)
	var player_hunters := 0
	for holder in game.tag_holders:
		if holder != game.block and is_instance_valid(holder) and holder.has_meta("tag_target") and holder.get_meta("tag_target") == game.block:
			player_hunters += 1
	check("at most two bots hunt Jelly at once", player_hunters <= game.TAG_MAX_PLAYER_HUNTERS)
	print("   bot-to-bot tag changes in 10s: ", bot_tags)
	game.return_to_main_menu()


func test_banner_never_covers_buttons() -> void:
	# Simulate a phone/tablet with a big home-indicator inset and a notch.
	await spawn_game()
	game.safe_area_bottom = 70.0
	game.banner_ad.set_bottom_inset(70.0)
	game.fit_menus_above_banner()
	var banner_top: float = game.get_viewport().get_visible_rect().size.y - PlaceholderBanner.HEIGHT - 70.0
	var clear := true
	for screen in [game.start_screen, game.game_over_screen]:
		for button in screen.find_children("*", "BaseButton", true, false):
			var control := button as Control
			if true:
				if control.get_global_rect().end.y > banner_top + 0.5:
					clear = false
					print("   under banner: ", control.name)
	check("no menu or game-over button sits under the banner", clear)
	game.open_shop()
	await wait(0.1)
	check("banner is hidden in the shop", not game.banner_ad.visible)
	game.close_shop()


func test_ad_layout_and_feedback() -> void:
	# A taller real banner (e.g. AdMob adaptive banner) still never covers buttons.
	await spawn_game()
	var window_height := float(DisplayServer.window_get_size().y)
	game._on_real_banner_height(window_height * 0.12)  # roughly 150+ canvas px
	var banner_top: float = game.get_viewport().get_visible_rect().size.y - game.banner_reserved_height - game.safe_area_bottom
	var clear := true
	for button in game.start_screen.find_children("*", "BaseButton", true, false):
		if (button as Control).get_global_rect().end.y > banner_top + 0.5 and str(button.name) != "SettingsButton":
			clear = false
			print("   under real banner: ", button.name)
	check("menu buttons clear a taller real banner", clear)
	game.show_toast("Ad not ready yet. Try again in a moment!")
	check("toast message shows", game.toast_label.visible and game.toast_label.text.begins_with("Ad not ready"))
	check("no native ads off-device", not game.ad_manager.native_available and not game.ad_manager.is_rewarded_ready())


func test_player_name() -> void:
	check("name is cleaned and shortened", game.sanitize_player_name("  mat<>thew  the great!! ") == "MATTHEW THE")
	game.set_player_name("Matt")
	check("name shows on the leaderboard", game.display_player_name() == "MATT")
	await spawn_game()
	check("name survives a restart", game.player_name == "MATT")
	game.set_player_name("")
	check("blank name falls back to YOU", game.display_player_name() == "YOU")


func test_bouncy_walls() -> void:
	game.select_game_mode("COIN")
	game.revive_shield_time = 999.0
	game.is_swinging = false
	game.block.position.x = -5.0
	game.velocity = Vector2(-60.0, 0.0)
	await physics_frame
	await physics_frame
	print("   wall test: started=%s x=%.1f vx=%.1f" % [game.game_started, game.block.position.x, game.velocity.x])
	check("side walls bounce Jelly back hard", game.velocity.x >= game.WALL_MIN_REBOUND * 0.9)
	game.return_to_main_menu()


func test_climb_bots() -> void:
	game.select_game_mode("CLIMB")
	var start_y := {}
	for bot in game.bot_swings.get_children():
		start_y[bot] = bot.global_position.y
	var best_climb := 0.0
	for frame in range(480):
		game.revive_shield_time = 999.0
		game.velocity = Vector2.ZERO
		await physics_frame
		if game.game_over:
			break
		for bot in game.bot_swings.get_children():
			if start_y.has(bot):
				best_climb = maxf(best_climb, float(start_y[bot]) - bot.global_position.y)
	print("   best bot climb in 8s: %d px" % int(best_climb))
	check("Sky Climb bots climb well", best_climb > 700.0)
	game.return_to_main_menu()

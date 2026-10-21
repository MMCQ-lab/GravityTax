class_name JellyAdManager
extends Node

# Production IDs are public AdMob configuration, not credentials. The project
# defaults to Google's test units until ads/use_production_ads is explicitly set.
const IOS_APP_ID := "ca-app-pub-4782649901919643~3774299795"
const BANNER_UNIT := "ca-app-pub-4782649901919643/3290909050"
const REWARDED_UNIT := "ca-app-pub-4782649901919643/9954274346"
const INTERSTITIAL_UNIT := "ca-app-pub-4782649901919643/1977827386"
const IOS_TEST_APP_ID := "ca-app-pub-3940256099942544~1458002511"
const IOS_TEST_BANNER := "ca-app-pub-3940256099942544/2435281174"
const IOS_TEST_REWARDED := "ca-app-pub-3940256099942544/1712485313"
const IOS_TEST_INTERSTITIAL := "ca-app-pub-3940256099942544/4411468910"
const MIN_INTERSTITIAL_INTERVAL_MSEC := 90000
const LOAD_RETRY_SECONDS := 30.0

signal reward_earned
signal rewarded_finished
signal fullscreen_started
signal fullscreen_finished
# Real banner height in screen pixels, so menus can make room for it.
signal banner_height_changed(height_pixels: float)
var native_available := false
var _sdk: Admob
var _initialized := false
var _banner_requested := false
var _banner_id := ""
var _banner_visible := false
var _interstitial_id := ""
var _interstitial_loading := false
var _interstitial_showing := false
var _last_interstitial_msec := -1
var _rewarded_id := ""
var _rewarded_loading := false
var _rewarded_showing := false
var _reward_granted := false


func _ready() -> void:
	if not OS.has_feature("ios") or not Engine.has_singleton("AdmobPlugin"):
		return
	native_available = true
	_sdk = Admob.new()
	_sdk.is_real = bool(ProjectSettings.get_setting("ads/use_production_ads", false))
	_sdk.ios_debug_application_id = IOS_TEST_APP_ID
	_sdk.ios_real_application_id = IOS_APP_ID
	_sdk.ios_debug_banner_id = IOS_TEST_BANNER
	_sdk.ios_real_banner_id = BANNER_UNIT
	_sdk.ios_debug_rewarded_id = IOS_TEST_REWARDED
	_sdk.ios_real_rewarded_id = REWARDED_UNIT
	_sdk.ios_debug_interstitial_id = IOS_TEST_INTERSTITIAL
	_sdk.ios_real_interstitial_id = INTERSTITIAL_UNIT
	_sdk.banner_position = LoadAdRequest.AdPosition.BOTTOM
	_sdk.banner_size = LoadAdRequest.RequestedAdSize.ADAPTIVE
	_sdk.banner_anchor_to_safe_area = true
	_sdk.max_banner_ad_cache = 1
	_sdk.max_interstitial_ad_cache = 1
	_sdk.max_rewarded_ad_cache = 1
	add_child(_sdk)
	_sdk.initialization_completed.connect(_on_initialized)
	_sdk.consent_info_updated.connect(_on_consent_updated)
	_sdk.consent_info_update_failed.connect(_on_consent_failed)
	_sdk.consent_form_loaded.connect(_on_consent_form_loaded)
	_sdk.consent_form_dismissed.connect(_on_consent_form_dismissed)
	_sdk.consent_form_failed_to_load.connect(_on_consent_failed)
	_sdk.banner_ad_loaded.connect(_on_banner_loaded)
	_sdk.banner_ad_size_measured.connect(func(info: AdInfo) -> void:
		var measured := _sdk.get_banner_dimension_in_pixels(info.get_ad_id())
		if measured.y > 0.0:
			banner_height_changed.emit(measured.y)
	)
	_sdk.banner_ad_failed_to_load.connect(_on_banner_failed)
	_sdk.interstitial_ad_loaded.connect(_on_interstitial_loaded)
	_sdk.interstitial_ad_failed_to_load.connect(_on_interstitial_failed)
	_sdk.interstitial_ad_dismissed_full_screen_content.connect(_on_interstitial_closed)
	_sdk.interstitial_ad_showed_full_screen_content.connect(func(_info: AdInfo) -> void: fullscreen_started.emit())
	_sdk.interstitial_ad_failed_to_show_full_screen_content.connect(_on_interstitial_show_failed)
	_sdk.rewarded_ad_loaded.connect(_on_rewarded_loaded)
	_sdk.rewarded_ad_failed_to_load.connect(_on_rewarded_failed)
	_sdk.rewarded_ad_user_earned_reward.connect(_on_reward_earned)
	_sdk.rewarded_ad_dismissed_full_screen_content.connect(_on_rewarded_closed)
	_sdk.rewarded_ad_showed_full_screen_content.connect(func(_info: AdInfo) -> void: fullscreen_started.emit())
	_sdk.rewarded_ad_failed_to_show_full_screen_content.connect(_on_rewarded_show_failed)
	# UMP propagates the user's choice to Mobile Ads. No request is sent while
	# consent status is unknown or a required consent form is being shown.
	_sdk.update_consent_info()


func _on_consent_updated() -> void:
	var consent := _sdk.get_consent_status()
	if consent == null:
		return
	if consent.status == UserConsent.Status.REQUIRED:
		if _sdk.is_consent_form_available():
			_sdk.show_consent_form()
		else:
			_sdk.load_consent_form()
	elif consent.status == UserConsent.Status.NOT_REQUIRED or consent.status == UserConsent.Status.OBTAINED:
		_start_sdk()


func _on_consent_form_loaded() -> void:
	_sdk.show_consent_form()


func _on_consent_form_dismissed(_error: FormError) -> void:
	var consent := _sdk.get_consent_status()
	if consent != null and (consent.status == UserConsent.Status.NOT_REQUIRED or consent.status == UserConsent.Status.OBTAINED):
		_start_sdk()


func _on_consent_failed(_error: FormError) -> void:
	# An existing valid consent choice may be reused when an update fails.
	var consent := _sdk.get_consent_status()
	if consent != null and (consent.status == UserConsent.Status.NOT_REQUIRED or consent.status == UserConsent.Status.OBTAINED):
		_start_sdk()


func _start_sdk() -> void:
	if _initialized:
		return
	_initialized = true
	_sdk.initialize()


func _on_initialized(_status: InitializationStatus) -> void:
	_load_banner()
	_load_interstitial()
	_load_rewarded()


func set_banner_visible(should_show: bool) -> void:
	if not native_available or _banner_visible == should_show:
		return
	_banner_visible = should_show
	if _banner_id.is_empty():
		return
	if should_show:
		_sdk.show_banner_ad(_banner_id)
	else:
		_sdk.hide_banner_ad(_banner_id)


func _load_banner() -> void:
	if _banner_requested or not _initialized:
		return
	_banner_requested = true
	_sdk.load_banner_ad()


func _on_banner_loaded(info: AdInfo, _response: ResponseInfo) -> void:
	_banner_id = info.get_ad_id()
	var banner_size := _sdk.get_banner_dimension_in_pixels(_banner_id)
	if banner_size.y > 0.0:
		banner_height_changed.emit(banner_size.y)
	if _banner_visible:
		_sdk.show_banner_ad(_banner_id)
	else:
		_sdk.hide_banner_ad(_banner_id)


func _on_banner_failed(_info: AdInfo, _error: LoadAdError) -> void:
	_banner_requested = false
	_retry_later(_load_banner)


func _load_interstitial() -> void:
	if not _initialized or _interstitial_loading or _interstitial_showing or not _interstitial_id.is_empty():
		return
	_interstitial_loading = true
	_sdk.load_interstitial_ad()


func _on_interstitial_loaded(info: AdInfo, _response: ResponseInfo) -> void:
	_interstitial_loading = false
	_interstitial_id = info.get_ad_id()


func _on_interstitial_failed(_info: AdInfo, _error: LoadAdError) -> void:
	_interstitial_loading = false
	_retry_later(_load_interstitial)


func try_show_death_interstitial() -> bool:
	if not native_available or not _initialized or _interstitial_showing or _interstitial_id.is_empty():
		return false
	var now := Time.get_ticks_msec()
	if _last_interstitial_msec >= 0 and now - _last_interstitial_msec < MIN_INTERSTITIAL_INTERVAL_MSEC:
		return false
	_last_interstitial_msec = now
	_interstitial_showing = true
	var ad_id := _interstitial_id
	_interstitial_id = ""
	_sdk.show_interstitial_ad(ad_id)
	return true


func _on_interstitial_closed(_info: AdInfo) -> void:
	_interstitial_showing = false
	fullscreen_finished.emit()
	_load_interstitial()


func _on_interstitial_show_failed(_info: AdInfo, _error: AdError) -> void:
	_interstitial_showing = false
	fullscreen_finished.emit()
	_load_interstitial()


func _load_rewarded() -> void:
	if not _initialized or _rewarded_loading or _rewarded_showing or not _rewarded_id.is_empty():
		return
	_rewarded_loading = true
	_sdk.load_rewarded_ad()


func _on_rewarded_loaded(info: AdInfo, _response: ResponseInfo) -> void:
	_rewarded_loading = false
	_rewarded_id = info.get_ad_id()


func _on_rewarded_failed(_info: AdInfo, _error: LoadAdError) -> void:
	_rewarded_loading = false
	_retry_later(_load_rewarded)


func try_show_rewarded() -> bool:
	if not native_available or not _initialized or _rewarded_showing or _rewarded_id.is_empty():
		return false
	_rewarded_showing = true
	_reward_granted = false
	var ad_id := _rewarded_id
	_rewarded_id = ""
	_sdk.show_rewarded_ad(ad_id)
	return true


func _on_reward_earned(_info: AdInfo, _reward: RewardItem) -> void:
	if _rewarded_showing and not _reward_granted:
		_reward_granted = true
		reward_earned.emit()


func _on_rewarded_closed(_info: AdInfo) -> void:
	_rewarded_showing = false
	fullscreen_finished.emit()
	_load_rewarded()
	rewarded_finished.emit()


func _on_rewarded_show_failed(_info: AdInfo, _error: AdError) -> void:
	_rewarded_showing = false
	fullscreen_finished.emit()
	_load_rewarded()
	rewarded_finished.emit()


func _retry_later(callback: Callable) -> void:
	get_tree().create_timer(LOAD_RETRY_SECONDS).timeout.connect(callback)


func is_rewarded_ready() -> bool:
	return native_available and _initialized and not _rewarded_id.is_empty() and not _rewarded_showing

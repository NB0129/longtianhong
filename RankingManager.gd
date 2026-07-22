extends Node

signal login_state_changed(logged_in: bool)
signal score_submit_finished(stage_key: String, score: int, submitted_online: bool)
signal leaderboard_show_finished(stage_key: String, success: bool, reason: String)

const KEY_EASY := "easy"
const KEY_NORMAL := "normal"
const KEY_HARD_MIRAGE := "hard_mirage"
const KEY_TOO_EASY := "too_easy"
const KEY_ABNORMAL := "abnormal"
const KEY_VERY_HARD_NIGHTMARE := "very_hard_nightmare"
const KEY_ENDLESS := "endless"

const LEADERBOARD_NAMES: Dictionary = {
	KEY_EASY: "easy",
	KEY_NORMAL: "normal",
	KEY_HARD_MIRAGE: "hard + mirage",
	KEY_TOO_EASY: "Too easy",
	KEY_ABNORMAL: "abnormal",
	KEY_VERY_HARD_NIGHTMARE: "very hard + nightmare",
	KEY_ENDLESS: "endless / instant",
}

# Google Play Games IDs. These values must never be sent to Game Center.
const ANDROID_LEADERBOARD_IDS: Dictionary = {
	KEY_EASY: "CgkI6s38m_cNEAIQAQ",
	KEY_NORMAL: "CgkI6s38m_cNEAIQAg",
	KEY_HARD_MIRAGE: "CgkI6s38m_cNEAIQAw",
	KEY_TOO_EASY: "CgkI6s38m_cNEAIQBA",
	KEY_ABNORMAL: "CgkI6s38m_cNEAIQBQ",
	KEY_VERY_HARD_NIGHTMARE: "CgkI6s38m_cNEAIQBg",
	KEY_ENDLESS: "CgkI6s38m_cNEAIQBw",
}

# Permanent Game Center IDs. Create these exact IDs in App Store Connect before
# enabling the Game Center entitlement in a release archive.
const IOS_LEADERBOARD_IDS: Dictionary = {
	KEY_EASY: "com.nb0129.machiate.leaderboard.easy",
	KEY_NORMAL: "com.nb0129.machiate.leaderboard.normal",
	KEY_HARD_MIRAGE: "com.nb0129.machiate.leaderboard.hardmirage",
	KEY_TOO_EASY: "com.nb0129.machiate.leaderboard.tooeasy",
	KEY_ABNORMAL: "com.nb0129.machiate.leaderboard.abnormal",
	KEY_VERY_HARD_NIGHTMARE: "com.nb0129.machiate.leaderboard.veryhardnightmare",
	KEY_ENDLESS: "com.nb0129.machiate.leaderboard.endless",
}

const IOS_GAME_CENTER_ADAPTER_SCRIPT = preload("res://IOSGameCenterAdapter.gd")
const IOS_LEADERBOARD_REQUIRED_COUNT := 7

const ANDROID_SINGLETON_CANDIDATES: Array[String] = [
	"GodotPlayGamesServices",
	"GooglePlayGames",
	"PlayGamesServices",
	"GodotGooglePlayGameServices",
]

const IOS_SINGLETON_CANDIDATES: Array[String] = [
	"GameCenter",
	"GodotGameCenter",
]

var _logged_in: bool = false
var _native_singleton: Object = null
var _native_singleton_name: String = ""
var _leaderboard_id_to_stage_key: Dictionary = {}
var _ios_game_center_adapter: RefCounted = null


func _ready() -> void:
	_detect_native_singleton()
	set_process(_ios_game_center_adapter != null)
	if _ios_game_center_adapter != null:
		call_deferred("_initialize_ios_game_center")


func _process(delta: float) -> void:
	if _ios_game_center_adapter != null:
		_ios_game_center_adapter.poll(delta)


func _notification(what: int) -> void:
	if what != NOTIFICATION_APPLICATION_RESUMED or _ios_game_center_adapter == null:
		return
	_ios_game_center_adapter.on_application_resumed()
	var resumed_logged_in: bool = _ios_game_center_adapter.is_logged_in()
	if resumed_logged_in != _logged_in:
		_on_native_login_state_changed(resumed_logged_in)
	elif resumed_logged_in:
		flush_pending_scores()


func _initialize_ios_game_center() -> void:
	if _ios_game_center_adapter == null:
		return
	if _ios_game_center_adapter.is_logged_in():
		_on_native_login_state_changed(true)
	_ios_game_center_adapter.login()


func is_available(stage_key: String = "") -> bool:
	_detect_native_singleton()
	if _native_singleton == null:
		return false
	if OS.get_name() != "iOS":
		return true
	return _ios_game_center_adapter != null and _has_ios_leaderboard_configuration(stage_key)


static func should_expose_ranking_ui(platform_name: String, service_available: bool) -> bool:
	return platform_name != "iOS" or service_available


func should_show_ranking_ui(stage_key: String = "") -> bool:
	return should_expose_ranking_ui(OS.get_name(), is_available(stage_key))


func is_logged_in() -> bool:
	if OS.get_name() == "iOS" and _ios_game_center_adapter != null:
		return _ios_game_center_adapter.is_logged_in()
	return _logged_in


func login_if_needed() -> bool:
	if is_logged_in():
		return true
	_detect_native_singleton()
	if _native_singleton == null:
		print("[RankingManager] native ranking plugin unavailable on ", OS.get_name())
		return false
	if OS.get_name() == "iOS":
		return _ios_game_center_adapter != null and _ios_game_center_adapter.login()
	var result: Variant = _call_first_existing(_native_singleton, ["login", "signIn", "authenticate", "sign_in"], [])
	if result == null:
		print("[RankingManager] native plugin has no known login method: ", _native_singleton_name)
		return false
	print("[RankingManager] login requested via ", _native_singleton_name, " result=", result)
	return true


func submit_score(stage_key: String, score: int) -> bool:
	if not _is_known_stage_key(stage_key):
		print("[RankingManager] submit skipped. unknown stage_key=", stage_key, " score=", score)
		return false
	if OS.get_name() == "iOS" and not is_available(stage_key):
		print("[RankingManager] submit skipped. Game Center unavailable for stage_key=", stage_key)
		return false
	var safe_score: int = maxi(0, score)
	var submit_started := false
	if OS.get_name() == "iOS":
		var player_id := ""
		if _ios_game_center_adapter != null:
			_ios_game_center_adapter.login()
			player_id = str(_ios_game_center_adapter.get_player_id())
		SaveData.record_ios_ranking_score(player_id, stage_key, safe_score)
		if player_id != "":
			submit_started = _submit_score_online(stage_key, safe_score, player_id)
	else:
		SaveData.record_ranking_score(stage_key, safe_score)
		submit_started = _submit_score_online(stage_key, safe_score)
	print("[RankingManager] submit_score stage_key=", stage_key, " score=", safe_score, " started=", submit_started, " local_best=", SaveData.get_ranking_best_score(stage_key))
	if not submit_started:
		score_submit_finished.emit(stage_key, safe_score, false)
	return true


func flush_pending_scores() -> void:
	if OS.get_name() == "iOS":
		if _ios_game_center_adapter == null:
			return
		if not _ios_game_center_adapter.is_logged_in():
			_ios_game_center_adapter.login()
			return
		var player_id: String = _ios_game_center_adapter.get_player_id()
		var ios_pending: Dictionary = SaveData.get_ios_pending_ranking_scores(player_id)
		for stage_key in ios_pending.keys():
			var leaderboard_id := _get_leaderboard_id(str(stage_key))
			if leaderboard_id != "":
				_ios_game_center_adapter.submit_score(leaderboard_id, int(ios_pending[stage_key]), player_id)
		return
	if not login_if_needed():
		return
	var pending: Dictionary = SaveData.get_pending_ranking_scores()
	for stage_key in pending.keys():
		var score: int = int(pending[stage_key])
		_submit_score_online(str(stage_key), score)


func show_leaderboard(stage_key: String = "") -> bool:
	if stage_key != "" and not _is_known_stage_key(stage_key):
		print("[RankingManager] show skipped. unknown stage_key=", stage_key)
		return false
	if OS.get_name() == "iOS" and not is_available(stage_key):
		print("[RankingManager] show skipped. Game Center unavailable for stage_key=", stage_key)
		return false
	var leaderboard_id: String = _get_leaderboard_id(stage_key)
	if OS.get_name() == "iOS":
		if _ios_game_center_adapter == null:
			return false
		return _ios_game_center_adapter.show_leaderboard(leaderboard_id)
	if not login_if_needed():
		_print_local_leaderboard(stage_key)
		return false
	var result: Variant = _call_first_existing(_native_singleton, ["showLeaderboard", "showLeaderboards", "show_leaderboard", "show_leaderboards"], [leaderboard_id])
	if result == null and stage_key == "":
		result = _call_first_existing(_native_singleton, ["show_all_leaderboards", "showAllLeaderboards"], [])
	if result == null:
		print("[RankingManager] native plugin has no known show leaderboard method: ", _native_singleton_name)
		_print_local_leaderboard(stage_key)
		return false
	print("[RankingManager] show_leaderboard stage_key=", stage_key, " leaderboard_id=", leaderboard_id, " result=", result)
	return true


func cancel_pending_leaderboard() -> void:
	if _ios_game_center_adapter != null:
		_ios_game_center_adapter.cancel_pending_leaderboard()


func get_local_best_score(stage_key: String) -> int:
	return SaveData.get_ranking_best_score(stage_key)


func get_local_ranking_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for key in LEADERBOARD_NAMES.keys():
		entries.append({
			"key": key,
			"name": LEADERBOARD_NAMES[key],
			"score": SaveData.get_ranking_best_score(key),
			"pending": SaveData.get_pending_ranking_scores().has(key),
		})
	return entries


func get_stage_key(stage_name: String, _custom_difficulty: String = "", is_instant_mode: bool = false) -> String:
	if is_instant_mode or stage_name == "endless":
		return KEY_ENDLESS
	if stage_name == "custom":
		return ""
	match stage_name:
		"tutorial", "stage1":
			return KEY_EASY
		"stage2":
			return KEY_NORMAL
		"stage3", "stage4":
			return KEY_HARD_MIRAGE
		"ex_stage1":
			return KEY_TOO_EASY
		"ex_stage2":
			return KEY_ABNORMAL
		"ex_stage3", "ex_stage4":
			return KEY_VERY_HARD_NIGHTMARE
	return ""


func _submit_score_online(stage_key: String, score: int, expected_ios_player_id: String = "") -> bool:
	var leaderboard_id: String = _get_leaderboard_id(stage_key)
	if leaderboard_id == "":
		print("[RankingManager] leaderboard ID is not set for stage_key=", stage_key)
		return false
	if OS.get_name() == "iOS":
		return (
			_ios_game_center_adapter != null
			and expected_ios_player_id != ""
			and _ios_game_center_adapter.submit_score(leaderboard_id, score, expected_ios_player_id)
		)
	if not login_if_needed():
		return false
	var result: Variant = _call_first_existing(_native_singleton, ["submitScore", "submit_score", "leaderboard_submit_score", "post_score"], [leaderboard_id, score])
	return result != null and bool(result)


func _detect_native_singleton() -> void:
	if _native_singleton != null:
		return
	var candidates: Array[String] = []
	if OS.get_name() == "Android":
		candidates = ANDROID_SINGLETON_CANDIDATES
	elif OS.get_name() == "iOS":
		candidates = IOS_SINGLETON_CANDIDATES
	for singleton_name in candidates:
		if Engine.has_singleton(singleton_name):
			_native_singleton = Engine.get_singleton(singleton_name)
			_native_singleton_name = singleton_name
			if OS.get_name() == "iOS":
				var adapter: RefCounted = IOS_GAME_CENTER_ADAPTER_SCRIPT.new()
				if not adapter.configure(_native_singleton):
					_native_singleton = null
					_native_singleton_name = ""
					continue
				_ios_game_center_adapter = adapter
				_connect_ios_adapter_signals()
				set_process(true)
			else:
				_connect_native_signals()
			_rebuild_leaderboard_id_lookup()
			print("[RankingManager] native singleton detected: ", singleton_name)
			return


func _connect_native_signals() -> void:
	if _native_singleton == null:
		return
	if _native_singleton.has_signal("login_state_changed") and not _native_singleton.login_state_changed.is_connected(_on_native_login_state_changed):
		_native_singleton.login_state_changed.connect(_on_native_login_state_changed)
	if _native_singleton.has_signal("score_submit_finished") and not _native_singleton.score_submit_finished.is_connected(_on_native_score_submit_finished):
		_native_singleton.score_submit_finished.connect(_on_native_score_submit_finished)


func _connect_ios_adapter_signals() -> void:
	if _ios_game_center_adapter == null:
		return
	_ios_game_center_adapter.login_state_changed.connect(_on_native_login_state_changed)
	_ios_game_center_adapter.player_identity_changed.connect(_on_ios_player_identity_changed)
	_ios_game_center_adapter.score_submit_finished.connect(_on_ios_score_submit_finished)
	_ios_game_center_adapter.leaderboard_show_finished.connect(_on_ios_leaderboard_show_finished)


func _rebuild_leaderboard_id_lookup() -> void:
	_leaderboard_id_to_stage_key.clear()
	var platform_ids := _get_leaderboard_ids_for_platform(OS.get_name())
	for key in platform_ids.keys():
		var leaderboard_id := str(platform_ids[key])
		if leaderboard_id != "":
			_leaderboard_id_to_stage_key[leaderboard_id] = str(key)


func _on_native_login_state_changed(logged_in: bool) -> void:
	if _logged_in == logged_in:
		return
	_logged_in = logged_in
	login_state_changed.emit(_logged_in)
	if _logged_in:
		flush_pending_scores()


func _on_ios_player_identity_changed(player_id: String) -> void:
	print("[RankingManager] Game Center player identity changed. authenticated=", player_id != "")
	if _logged_in and player_id != "":
		flush_pending_scores()


func _on_ios_score_submit_finished(
	player_id: String,
	leaderboard_id: String,
	score: int,
	submitted_online: bool,
	_message: String = ""
) -> void:
	var stage_key := str(_leaderboard_id_to_stage_key.get(leaderboard_id, ""))
	if stage_key == "":
		print("[RankingManager] iOS submit callback for unknown leaderboard_id=", leaderboard_id, " score=", score, " online=", submitted_online)
		return
	if submitted_online:
		SaveData.clear_ios_pending_ranking_score(player_id, stage_key, score)
	print("[RankingManager] iOS submit finished stage_key=", stage_key, " score=", score, " online=", submitted_online)
	score_submit_finished.emit(stage_key, score, submitted_online)


func _on_ios_leaderboard_show_finished(leaderboard_id: String, success: bool, message: String) -> void:
	var stage_key := str(_leaderboard_id_to_stage_key.get(leaderboard_id, ""))
	leaderboard_show_finished.emit(stage_key, success, "" if success else _classify_ios_leaderboard_error(message))


static func _classify_ios_leaderboard_error(message: String) -> String:
	var normalized := message.to_lower()
	if "busy" in normalized:
		return "busy"
	if "identity" in normalized or "restricted" in normalized:
		return "restricted"
	if "authentication" in normalized:
		return "login_failed"
	return "show_failed"


func _on_native_score_submit_finished(leaderboard_id: String, score: int, submitted_online: bool, _message: String = "") -> void:
	var stage_key := str(_leaderboard_id_to_stage_key.get(leaderboard_id, ""))
	if stage_key == "":
		print("[RankingManager] native submit callback for unknown leaderboard_id=", leaderboard_id, " score=", score, " online=", submitted_online)
		return
	if submitted_online:
		SaveData.clear_pending_ranking_score(stage_key, score)
	print("[RankingManager] native submit finished stage_key=", stage_key, " score=", score, " online=", submitted_online)
	score_submit_finished.emit(stage_key, score, submitted_online)


func _call_first_existing(target: Object, method_names: Array[String], args: Array) -> Variant:
	if target == null:
		return null
	for method_name in method_names:
		if target.has_method(method_name):
			return target.callv(method_name, args)
	if OS.get_name() == "Android" and _native_singleton_name == "GodotPlayGamesServices":
		return _call_known_android_plugin_method(target, method_names, args)
	return null


func _call_known_android_plugin_method(target: Object, method_names: Array[String], args: Array) -> Variant:
	for method_name in method_names:
		if method_name in ["login", "signIn", "authenticate", "submitScore", "showLeaderboard", "showLeaderboards", "showAllLeaderboards", "isLoggedIn"]:
			print("[RankingManager] calling Android plugin method without has_method: ", method_name)
			return target.callv(method_name, args)
	return null


func _get_leaderboard_id(stage_key: String) -> String:
	return get_leaderboard_id_for_platform(stage_key, OS.get_name())


static func get_leaderboard_id_for_platform(stage_key: String, platform_name: String) -> String:
	if stage_key == "":
		return ""
	var platform_ids := _get_leaderboard_ids_for_platform(platform_name)
	return str(platform_ids.get(stage_key, ""))


static func _get_leaderboard_ids_for_platform(platform_name: String) -> Dictionary:
	if platform_name == "iOS":
		return IOS_LEADERBOARD_IDS
	return ANDROID_LEADERBOARD_IDS


func _has_ios_leaderboard_configuration(stage_key: String = "") -> bool:
	if not has_complete_ios_leaderboard_configuration(IOS_LEADERBOARD_IDS):
		return false
	if stage_key != "":
		return get_leaderboard_id_for_platform(stage_key, "iOS") != ""
	return true


static func has_complete_ios_leaderboard_configuration(ids: Dictionary) -> bool:
	if ids.size() != IOS_LEADERBOARD_REQUIRED_COUNT:
		return false
	var unique_ids: Dictionary = {}
	for stage_key in LEADERBOARD_NAMES.keys():
		var leaderboard_id := str(ids.get(stage_key, "")).strip_edges()
		if leaderboard_id == "" or leaderboard_id.begins_with("Cgk") or unique_ids.has(leaderboard_id):
			return false
		unique_ids[leaderboard_id] = true
	return unique_ids.size() == IOS_LEADERBOARD_REQUIRED_COUNT


func _is_known_stage_key(stage_key: String) -> bool:
	return stage_key != "" and LEADERBOARD_NAMES.has(stage_key)


func _print_local_leaderboard(stage_key: String = "") -> void:
	print("[RankingManager] local leaderboard fallback")
	for key in LEADERBOARD_NAMES.keys():
		if stage_key != "" and key != stage_key:
			continue
		print("  ", key, " / ", LEADERBOARD_NAMES[key], ": ", SaveData.get_ranking_best_score(key))

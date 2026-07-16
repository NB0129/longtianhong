extends Node

signal login_state_changed(logged_in: bool)
signal score_submit_finished(stage_key: String, score: int, submitted_online: bool)

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

# Replace these placeholder values with the real Google Play Games /
# Game Center leaderboard IDs after they are created in each console.
const LEADERBOARD_IDS: Dictionary = {
	KEY_EASY: "CgkI6s38m_cNEAIQAQ",
	KEY_NORMAL: "CgkI6s38m_cNEAIQAg",
	KEY_HARD_MIRAGE: "CgkI6s38m_cNEAIQAw",
	KEY_TOO_EASY: "CgkI6s38m_cNEAIQBA",
	KEY_ABNORMAL: "CgkI6s38m_cNEAIQBQ",
	KEY_VERY_HARD_NIGHTMARE: "CgkI6s38m_cNEAIQBg",
	KEY_ENDLESS: "CgkI6s38m_cNEAIQBw",
}

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


func _ready() -> void:
	_detect_native_singleton()


func is_available() -> bool:
	return _native_singleton != null


func is_logged_in() -> bool:
	return _logged_in


func login_if_needed() -> bool:
	if _logged_in:
		return true
	_detect_native_singleton()
	if _native_singleton == null:
		print("[RankingManager] native ranking plugin unavailable on ", OS.get_name())
		return false
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
	var safe_score: int = maxi(0, score)
	SaveData.record_ranking_score(stage_key, safe_score)
	var submit_started := _submit_score_online(stage_key, safe_score)
	print("[RankingManager] submit_score stage_key=", stage_key, " score=", safe_score, " started=", submit_started, " local_best=", SaveData.get_ranking_best_score(stage_key))
	if not submit_started:
		score_submit_finished.emit(stage_key, safe_score, false)
	return true


func flush_pending_scores() -> void:
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
	if not login_if_needed():
		_print_local_leaderboard(stage_key)
		return false
	var leaderboard_id: String = _get_leaderboard_id(stage_key)
	var result: Variant = _call_first_existing(_native_singleton, ["showLeaderboard", "showLeaderboards", "show_leaderboard", "show_leaderboards"], [leaderboard_id])
	if result == null and stage_key == "":
		result = _call_first_existing(_native_singleton, ["show_all_leaderboards", "showAllLeaderboards"], [])
	if result == null:
		print("[RankingManager] native plugin has no known show leaderboard method: ", _native_singleton_name)
		_print_local_leaderboard(stage_key)
		return false
	print("[RankingManager] show_leaderboard stage_key=", stage_key, " leaderboard_id=", leaderboard_id, " result=", result)
	return true


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


func _submit_score_online(stage_key: String, score: int) -> bool:
	if not login_if_needed():
		return false
	var leaderboard_id: String = _get_leaderboard_id(stage_key)
	if leaderboard_id == "":
		print("[RankingManager] leaderboard ID is not set for stage_key=", stage_key)
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


func _rebuild_leaderboard_id_lookup() -> void:
	_leaderboard_id_to_stage_key.clear()
	for key in LEADERBOARD_IDS.keys():
		var leaderboard_id := str(LEADERBOARD_IDS[key])
		if leaderboard_id != "":
			_leaderboard_id_to_stage_key[leaderboard_id] = str(key)


func _on_native_login_state_changed(logged_in: bool) -> void:
	if _logged_in == logged_in:
		return
	_logged_in = logged_in
	login_state_changed.emit(_logged_in)
	if _logged_in:
		flush_pending_scores()


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
	if stage_key == "":
		return ""
	return str(LEADERBOARD_IDS.get(stage_key, ""))


func _is_known_stage_key(stage_key: String) -> bool:
	return stage_key != "" and LEADERBOARD_NAMES.has(stage_key)


func _print_local_leaderboard(stage_key: String = "") -> void:
	print("[RankingManager] local leaderboard fallback")
	for key in LEADERBOARD_NAMES.keys():
		if stage_key != "" and key != stage_key:
			continue
		print("  ", key, " / ", LEADERBOARD_NAMES[key], ": ", SaveData.get_ranking_best_score(key))

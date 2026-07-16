extends Node
# セーブデータ管理（AutoLoad名：SaveData）

const SAVE_PATH = "user://save.cfg"

# 各ステージの初回クリアフラグ
var stage1_cleared: bool = false
var stage2_cleared: bool = false
var stage3_cleared: bool = false
var stage4_cleared: bool = false
var ex_stage1_cleared: bool = false
var ex_stage2_cleared: bool = false
var ex_stage3_cleared: bool = false
var ex_stage4_cleared: bool = false

# カスタムモードの設定
var custom_difficulty: String = "stage1"
var custom_sort_enabled: bool = true
var custom_timer_enabled: bool = false
var custom_timer_seconds: int = 30
var custom_bgm_yume: bool = true
var custom_bgm_utu: bool = true
var custom_bgm_mabo_first: bool = true
var custom_bgm_mabo_second: bool = true
var custom_question_count: int = 10
var tile_suit: String = "pinzu"

# 最後にいたモード
var last_mode: String = "surface"

# 音楽室：プレイリスト
var music_playlist: Array = []

# 音楽室：再生モード
var music_play_mode: String = "sequential"
var music_repeat_one: bool = false

var is_supporter: bool = false
var high_scores: Dictionary = {}
var ranking_best_scores: Dictionary = {}
var ranking_pending_scores: Dictionary = {}
var language_code: String = "ja"


func _ready():
	load_data()


func save():
	var config = ConfigFile.new()
	config.set_value("cleared", "stage1_cleared", stage1_cleared)
	config.set_value("cleared", "stage2_cleared", stage2_cleared)
	config.set_value("cleared", "stage3_cleared", stage3_cleared)
	config.set_value("cleared", "stage4_cleared", stage4_cleared)
	config.set_value("cleared", "ex_stage1_cleared", ex_stage1_cleared)
	config.set_value("cleared", "ex_stage2_cleared", ex_stage2_cleared)
	config.set_value("cleared", "ex_stage3_cleared", ex_stage3_cleared)
	config.set_value("cleared", "ex_stage4_cleared", ex_stage4_cleared)
	config.set_value("custom", "difficulty", custom_difficulty)
	config.set_value("custom", "sort_enabled", custom_sort_enabled)
	config.set_value("custom", "timer_enabled", custom_timer_enabled)
	config.set_value("custom", "timer_seconds", custom_timer_seconds)
	config.set_value("custom", "bgm_yume", custom_bgm_yume)
	config.set_value("custom", "bgm_utu", custom_bgm_utu)
	config.set_value("custom", "bgm_mabo_first", custom_bgm_mabo_first)
	config.set_value("custom", "bgm_mabo_second", custom_bgm_mabo_second)
	config.set_value("custom", "question_count", custom_question_count)
	config.set_value("game", "tile_suit", tile_suit)
	config.set_value("meta", "last_mode", last_mode)
	config.set_value("music", "playlist", music_playlist)
	config.set_value("music", "play_mode", music_play_mode)
	config.set_value("music", "repeat_one", music_repeat_one)
	config.set_value("support", "is_supporter", is_supporter)
	config.set_value("score", "high_scores", high_scores)
	config.set_value("ranking", "best_scores", ranking_best_scores)
	config.set_value("ranking", "pending_scores", ranking_pending_scores)
	config.set_value("localization", "language_code", language_code)
	config.save(SAVE_PATH)


func load_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return
	stage1_cleared       = config.get_value("cleared", "stage1_cleared", false)
	stage2_cleared       = config.get_value("cleared", "stage2_cleared", false)
	stage3_cleared       = config.get_value("cleared", "stage3_cleared", false)
	stage4_cleared       = config.get_value("cleared", "stage4_cleared", false)
	ex_stage1_cleared    = config.get_value("cleared", "ex_stage1_cleared", false)
	ex_stage2_cleared    = config.get_value("cleared", "ex_stage2_cleared", false)
	ex_stage3_cleared    = config.get_value("cleared", "ex_stage3_cleared", false)
	ex_stage4_cleared    = config.get_value("cleared", "ex_stage4_cleared", false)
	custom_difficulty    = config.get_value("custom", "difficulty", "stage1")
	custom_sort_enabled  = config.get_value("custom", "sort_enabled", true)
	custom_timer_enabled = config.get_value("custom", "timer_enabled", false)
	custom_timer_seconds = config.get_value("custom", "timer_seconds", 30)
	custom_bgm_yume        = config.get_value("custom", "bgm_yume", true)
	custom_bgm_utu         = config.get_value("custom", "bgm_utu", true)
	custom_bgm_mabo_first  = config.get_value("custom", "bgm_mabo_first", true)
	custom_bgm_mabo_second = config.get_value("custom", "bgm_mabo_second", true)
	custom_question_count  = config.get_value("custom", "question_count", 10)
	tile_suit              = config.get_value("game", "tile_suit", "pinzu")
	last_mode            = config.get_value("meta", "last_mode", "surface")
	music_playlist       = config.get_value("music", "playlist", [])
	music_play_mode      = config.get_value("music", "play_mode", "sequential")
	music_repeat_one     = config.get_value("music", "repeat_one", false)
	var removed_deprecated_bgm: bool = false
	for bgm in ["bgm_utu_zakozako", "bgm_utu_syogakusei"]:
		while music_playlist.has(bgm):
			music_playlist.erase(bgm)
			removed_deprecated_bgm = true
	is_supporter         = config.get_value("support", "is_supporter", false)
	high_scores          = config.get_value("score", "high_scores", {})
	ranking_best_scores  = config.get_value("ranking", "best_scores", {})
	ranking_pending_scores = config.get_value("ranking", "pending_scores", {})
	language_code        = normalize_language_code(str(config.get_value("localization", "language_code", "ja")))
	var instant_score: int = int(high_scores.get("instant", 0))
	var endless_score: int = int(high_scores.get("endless", 0))
	if high_scores.has("instant"):
		high_scores["endless"] = maxi(instant_score, endless_score)
		high_scores.erase("instant")
		save()
	elif removed_deprecated_bgm:
		save()


func reset():
	stage1_cleared     = false
	stage2_cleared     = false
	stage3_cleared     = false
	stage4_cleared     = false
	ex_stage1_cleared  = false
	ex_stage2_cleared  = false
	ex_stage3_cleared  = false
	ex_stage4_cleared  = false
	custom_difficulty    = "stage1"
	custom_sort_enabled  = true
	custom_timer_enabled = false
	custom_timer_seconds = 30
	custom_bgm_yume        = true
	custom_bgm_utu         = true
	custom_bgm_mabo_first  = true
	custom_bgm_mabo_second = true
	custom_question_count  = 10
	tile_suit              = "pinzu"
	last_mode       = "surface"
	music_playlist  = []
	music_play_mode = "sequential"
	music_repeat_one = false
	is_supporter = false
	high_scores = {}
	ranking_best_scores = {}
	ranking_pending_scores = {}
	language_code = "ja"
	save()


func normalize_language_code(value: String) -> String:
	if value in ["ja", "en", "zh_CN", "zh_TW", "ko"]:
		return value
	return "ja"


func set_language_code(value: String) -> void:
	var normalized := normalize_language_code(value)
	if language_code == normalized:
		return
	language_code = normalized
	save()


func get_high_score(stage_name: String) -> int:
	if stage_name == "instant":
		stage_name = "endless"
	return int(high_scores.get(stage_name, 0))


func record_high_score(stage_name: String, score: int) -> bool:
	if stage_name == "instant":
		stage_name = "endless"
	if score <= get_high_score(stage_name):
		return false
	high_scores[stage_name] = score
	save()
	return true


func get_ranking_best_score(stage_key: String) -> int:
	return int(ranking_best_scores.get(stage_key, 0))


func record_ranking_score(stage_key: String, score: int) -> bool:
	if stage_key == "":
		return false
	var changed := false
	if score > get_ranking_best_score(stage_key):
		ranking_best_scores[stage_key] = score
		changed = true
	if score > int(ranking_pending_scores.get(stage_key, 0)):
		ranking_pending_scores[stage_key] = score
		changed = true
	if changed:
		save()
	return changed


func get_pending_ranking_scores() -> Dictionary:
	return ranking_pending_scores.duplicate(true)


func clear_pending_ranking_score(stage_key: String, score: int = -1) -> void:
	if not ranking_pending_scores.has(stage_key):
		return
	if score >= 0 and int(ranking_pending_scores.get(stage_key, 0)) > score:
		return
	ranking_pending_scores.erase(stage_key)
	save()


func set_supporter(value: bool) -> void:
	is_supporter = value
	save()


func record_clear(stage_name: String) -> void:
	match stage_name:
		"stage1":
			if not stage1_cleared:
				stage1_cleared = true
		"stage2":
			if not stage2_cleared:
				stage2_cleared = true
		"stage3":
			if not stage3_cleared:
				stage3_cleared = true
		"stage4":
			if not stage4_cleared:
				stage4_cleared = true
		"ex_stage1":
			if not ex_stage1_cleared:
				ex_stage1_cleared = true
		"ex_stage2":
			if not ex_stage2_cleared:
				ex_stage2_cleared = true
		"ex_stage3":
			if not ex_stage3_cleared:
				ex_stage3_cleared = true
		"ex_stage4":
			if not ex_stage4_cleared:
				ex_stage4_cleared = true
	save()


func is_cleared(stage_name: String) -> bool:
	match stage_name:
		"stage1":    return stage1_cleared
		"stage2":    return stage2_cleared
		"stage3":    return stage3_cleared
		"stage4":    return stage4_cleared
		"ex_stage1": return ex_stage1_cleared
		"ex_stage2": return ex_stage2_cleared
		"ex_stage3": return ex_stage3_cleared
		"ex_stage4": return ex_stage4_cleared
	return false

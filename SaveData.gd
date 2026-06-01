extends Node
# セーブデータ管理（AutoLoad名：SaveData）

const SAVE_PATH = "user://save.cfg"

# 解放済みステージのリスト
var unlocked_stages: Array = ["tutorial", "stage1"]

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

# 最後にいたモード
var last_mode: String = "surface"

# 音楽室：解放済み曲リスト
var unlocked_bgm: Array = []

# 音楽室：プレイリスト
var music_playlist: Array = []

# 音楽室：再生モード
var music_play_mode: String = "sequential"


func _ready():
	load_data()


func save():
	var config = ConfigFile.new()
	config.set_value("stages", "unlocked_stages", unlocked_stages)
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
	config.set_value("meta", "last_mode", last_mode)
	config.set_value("music", "unlocked_bgm", unlocked_bgm)
	config.set_value("music", "playlist", music_playlist)
	config.set_value("music", "play_mode", music_play_mode)
	config.save(SAVE_PATH)


func load_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return
	unlocked_stages      = config.get_value("stages", "unlocked_stages", ["tutorial", "stage1"])
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
	last_mode            = config.get_value("meta", "last_mode", "surface")
	unlocked_bgm         = config.get_value("music", "unlocked_bgm", [])
	music_playlist       = config.get_value("music", "playlist", [])
	music_play_mode      = config.get_value("music", "play_mode", "sequential")


func reset():
	unlocked_stages    = ["tutorial", "stage1"]
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
	last_mode       = "surface"
	unlocked_bgm    = []
	music_playlist  = []
	music_play_mode = "sequential"
	save()


func is_unlocked(stage_name: String) -> bool:
	return stage_name in unlocked_stages


func unlock_stage(stage_name: String) -> void:
	if stage_name not in unlocked_stages:
		unlocked_stages.append(stage_name)
		save()


func unlock_bgm(bgm_filename: String) -> void:
	if bgm_filename not in unlocked_bgm:
		unlocked_bgm.append(bgm_filename)
		save()


func is_bgm_unlocked(bgm_filename: String) -> bool:
	return bgm_filename in unlocked_bgm


func record_clear(stage_name: String) -> String:
	var newly_unlocked = ""
	match stage_name:
		"stage1":
			if not stage1_cleared:
				stage1_cleared = true
				unlock_stage("stage2")
				newly_unlocked = "stage2"
		"stage2":
			if not stage2_cleared:
				stage2_cleared = true
				unlock_stage("stage3")
				newly_unlocked = "stage3"
		"stage3":
			if not stage3_cleared:
				stage3_cleared = true
		"stage4":
			if not stage4_cleared:
				stage4_cleared = true
				unlock_stage("ex_stage1")
				unlock_stage("custom")
				unlock_stage("music_room")
				newly_unlocked = "custom"
		"ex_stage1":
			if not ex_stage1_cleared:
				ex_stage1_cleared = true
				unlock_stage("ex_stage2")
				newly_unlocked = "ex_stage2"
		"ex_stage2":
			if not ex_stage2_cleared:
				ex_stage2_cleared = true
				unlock_stage("ex_stage3")
				newly_unlocked = "ex_stage3"
		"ex_stage3":
			if not ex_stage3_cleared:
				ex_stage3_cleared = true
		"ex_stage4":
			if not ex_stage4_cleared:
				ex_stage4_cleared = true
				unlock_stage("endless")
				newly_unlocked = "ex_stage4"
	save()
	return newly_unlocked


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

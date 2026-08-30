extends Control

const ModalFoundation := preload("res://ModalFoundation.gd")
const GAME_SCENE := preload("res://game.tscn")
const MUSIC_ROOM_SCENE := preload("res://MusicRoom.tscn")
const TITLE_SCENE := preload("res://Title.tscn")
const STAGE_SELECT_SCENE := preload("res://StageSelect.tscn")

const VIEWPORT_SIZE := Vector2i(480, 854)
const TIMER_CROP := Rect2i(0, 0, 480, 240)
const OUTPUT_DIR := "res://artifacts/visual_evidence/ui_audit_adopted_20260828"
const REPORT_PATH := OUTPUT_DIR + "/ui_audit_visual_containment_report_r09_exact.json"
const PIXEL_PROBE_REPORT_PATH := OUTPUT_DIR + "/credit_legal_pixel_probe_report_r09_exact2.json"
const LOCALES: Array[String] = ["ja", "en", "zh_CN", "zh_TW", "ko"]
const MUSIC_STATES: Array[String] = ["selected", "playing", "paused"]
const SUPPORT_STATUS_KEYS: Array[String] = [
	"purchase_start",
	"restore_start",
	"supported",
	"busy",
	"product_loading",
	"product_unavailable",
]
const TIMER_SOURCE_MAX := 990.0
const PRICE_STRESS_SAMPLE := "US$999,999.99"
const LEGAL_NAMED_LINE_COUNT := 306
const LEGAL_URL_LINE_COUNT := 11
const LEGAL_COPYRIGHT_LINE_COUNT := 297
const LEGAL_KNOWN_LINE_HASHES: Array[String] = [
	"5EDD496807A321F9BC535670C4A1E637E40167F2D21B29FAA4CA46761FD9C888",
	"F8CF7A706917EE0E2F4F5B70B9BE8B6381AD98268D4E505A76223197FCF746F2",
]
const LEGAL_PIXEL_PROBE_HASH := "38A73031F3CED0333534D9693397DEF4FBAB5BC4943FA82582A81572EADE2BE4"

var _failed := false
var _debts: Array[String] = []
var _captures: Array[Dictionary] = []
var _report: Dictionary = {}
var _original: Dictionary = {}


func _enter_tree() -> void:
	get_window().size = VIEWPORT_SIZE
	get_window().content_scale_size = VIEWPORT_SIZE


func _ready() -> void:
	_snapshot_runtime_state()
	var absolute_output := ProjectSettings.globalize_path(OUTPUT_DIR)
	_assert(DirAccess.make_dir_recursive_absolute(absolute_output) == OK, "visual evidence output directory is available")
	if OS.get_environment("MACHI_ATE_CREDIT_PIXEL_PROBE_ONLY") == "1":
		await _run_credit_pixel_probe_only()
		_restore_runtime_state()
		_report["captures"] = _captures
		_report["debts"] = _debts
		_report["failed"] = _failed
		_write_report(PIXEL_PROBE_REPORT_PATH)
		if _failed:
			print("FAIL credit_legal_pixel_probe debts=%d captures=%d" % [_debts.size(), _captures.size()])
			get_tree().quit(1)
			return
		print("PASS credit_legal_pixel_probe captures=%d" % _captures.size())
		get_tree().quit(0)
		return
	await _audit_timer_and_capture()
	await _audit_music_room_and_capture()
	await _audit_title_and_capture()
	await _audit_stage_support_and_capture()
	_restore_runtime_state()
	_report["captures"] = _captures
	_report["debts"] = _debts
	_report["failed"] = _failed
	_write_report()
	if AudioManager != null:
		AudioManager.stop_bgm()
	if _failed:
		print("FAIL ui_audit_visual_containment debts=%d captures=%d" % [_debts.size(), _captures.size()])
		get_tree().quit(1)
		return
	print("PASS ui_audit_visual_containment music_status=315 music_rows=105 title_locales=5 support_locales=5 timer_locales=5 captures=%d debts=%d" % [_captures.size(), _debts.size()])
	get_tree().quit(0)


func _run_credit_pixel_probe_only() -> void:
	_set_runtime_locale("en")
	var title := TITLE_SCENE.instantiate() as Control
	_assert(title != null, "Title scene instantiates for focused Legal pixel probe")
	if title == null:
		return
	add_child(title)
	await _settle(3)
	await _click_control(title.get_node("CreditFrame/BtnCredit") as Button)
	await _click_control(title.get_node("CreditPopup/VBox/CreditActionRow/BtnLicenses") as Button)
	_assert(bool(title.get("_credit_legal_view_active")), "real Credits action opens Legal for pixel probe")
	await _capture_legal_pixel_probe(title)
	await _remove_scene(title)


func _snapshot_runtime_state() -> void:
	_original = {
		"language": SaveData.language_code,
		"stage": GameState.current_stage,
		"endless_block": GameState.endless_block,
		"custom_difficulty": SaveData.custom_difficulty,
		"custom_timer_enabled": SaveData.custom_timer_enabled,
		"custom_timer_seconds": SaveData.custom_timer_seconds,
		"custom_question_count": SaveData.custom_question_count,
		"custom_bgm_yume": SaveData.custom_bgm_yume,
		"support_formatted_price": SupportPurchase.formatted_price,
	}


func _restore_runtime_state() -> void:
	_set_runtime_locale(str(_original["language"]))
	GameState.current_stage = str(_original["stage"])
	GameState.endless_block = int(_original["endless_block"])
	SaveData.custom_difficulty = str(_original["custom_difficulty"])
	SaveData.custom_timer_enabled = bool(_original["custom_timer_enabled"])
	SaveData.custom_timer_seconds = int(_original["custom_timer_seconds"])
	SaveData.custom_question_count = int(_original["custom_question_count"])
	SaveData.custom_bgm_yume = bool(_original["custom_bgm_yume"])
	SupportPurchase.formatted_price = str(_original["support_formatted_price"])


func _set_runtime_locale(locale: String) -> void:
	SaveData.language_code = str(SaveData.normalize_language_code(locale))
	LocaleFonts.call("_apply_locale", SaveData.language_code)


func _record_face_candidate(candidates: Dictionary, path: String, context: String) -> void:
	var contexts: Array = candidates.get(path, []) as Array
	if context not in contexts:
		contexts.append(context)
	candidates[path] = contexts


func _audit_timer_and_capture() -> void:
	var custom_source := FileAccess.get_file_as_string("res://Custom.gd")
	_assert(custom_source.contains("min(990, SaveData.custom_timer_seconds + 10)"), "Custom source fixes the selectable timer maximum at 990 seconds")
	GameState.current_stage = "custom"
	SaveData.custom_difficulty = "stage1"
	SaveData.custom_timer_enabled = true
	SaveData.custom_timer_seconds = int(TIMER_SOURCE_MAX)
	SaveData.custom_question_count = 10
	SaveData.custom_bgm_yume = true
	_set_runtime_locale("ja")

	var game := GAME_SCENE.instantiate() as Control
	_assert(game != null, "game scene instantiates for maximum timer audit")
	if game == null:
		return
	add_child(game)
	await _settle()
	var intro := game.get_node_or_null("StageIntro/IntroPanel") as Control
	if intro != null:
		intro.visible = false
	game.process_mode = Node.PROCESS_MODE_DISABLED
	var timer := game.get_node("TimerLabel") as Label
	var score := game.get_node("ScoreDisplay") as Control
	var face := game.get_node("FaceBoss") as TextureRect
	timer.visible = true
	score.visible = true
	face.visible = true
	game.set("timer_enabled", true)
	game.call("setup_timer_display")

	var timer_overflows := 0
	var timer_longest: Dictionary = {"width": -1.0}
	var timer_visible_bounds: Dictionary = {}
	for locale in LOCALES:
		_set_runtime_locale(locale)
		game.set("time_left", TIMER_SOURCE_MAX)
		game.call("update_timer_display")
		await _settle(1)
		var metric := _measure_text_control(timer, timer.text, false)
		metric["locale"] = locale
		metric["text"] = timer.text
		metric["source_max_seconds"] = TIMER_SOURCE_MAX
		var global_visible_bounds := _label_visible_canvas_rect(timer)
		timer_visible_bounds[locale] = global_visible_bounds
		metric["visible_render_bounds"] = str(global_visible_bounds)
		print("MEASURE timer_max " + JSON.stringify(metric))
		if bool(metric["overflow"]):
			timer_overflows += 1
			_record_debt("TIMER_MAX_OVERFLOW", "%s %s width=%.3f available=%.3f" % [locale, timer.text, metric["required_width"], metric["available_width"]], true)
		if float(metric["required_width"]) > float(timer_longest["width"]):
			timer_longest = {"width": metric["required_width"], "locale": locale, "text": timer.text, "available": metric["available_width"]}

	var timer_rect := Rect2(timer.position, timer.size)
	var face_paths: Dictionary = {}
	var face_contexts: Array[Dictionary] = []
	for difficulty in ["stage1", "stage2", "stage3", "stage4"]:
		face_contexts.append({"stage": "custom", "difficulty": difficulty, "endless_block": 0})
	for ex_stage in ["ex_stage1", "ex_stage2", "ex_stage3", "ex_stage4"]:
		face_contexts.append({"stage": ex_stage, "difficulty": "stage1", "endless_block": 0})
	for endless_block in [4, 5, 6, 7, 8]:
		face_contexts.append({"stage": "endless", "difficulty": "stage1", "endless_block": endless_block})
	for context in face_contexts:
		GameState.current_stage = str(context["stage"])
		SaveData.custom_difficulty = str(context["difficulty"])
		GameState.endless_block = int(context["endless_block"])
		var context_name := "%s:difficulty=%s:block=%d" % [GameState.current_stage, SaveData.custom_difficulty, GameState.endless_block]
		_record_face_candidate(face_paths, str(game.call("_get_boss_def_path")), context_name + ":default")
		for question_index in [0, 3, 7]:
			game.set("current_question", question_index)
			_record_face_candidate(face_paths, str(game.call("_get_boss_phase_path")), context_name + ":phase%d" % question_index)
		_record_face_candidate(face_paths, str(game.call("_get_boss_wrong_path")), context_name + ":wrong")
	_assert(face_contexts.size() == 13, "timer-enabled FaceBoss audit covers custom4, EX4 and Endless5 contexts")
	_assert(face_paths.size() == 21, "timer-enabled FaceBoss audit resolves all 21 unique candidate textures")
	var face_overlaps := 0
	var face_checks: Array[Dictionary] = []
	for path_variant in face_paths.keys():
		var path := str(path_variant)
		_assert(ResourceLoader.exists(path), "timer-enabled FaceBoss candidate exists: %s" % path)
		if not ResourceLoader.exists(path):
			continue
		face.texture = load(path)
		var visible_rect := _texture_visible_alpha_rect(face)
		var locale_overlaps: Dictionary = {}
		for locale in LOCALES:
			var timer_visible := timer_visible_bounds[locale] as Rect2
			var locale_overlap := timer_visible.intersection(visible_rect)
			if timer_visible.intersects(visible_rect):
				locale_overlaps[locale] = str(locale_overlap)
		var clear := locale_overlaps.is_empty()
		if not clear:
			face_overlaps += 1
			_record_debt("TIMER_FACE_VISIBLE_OVERLAP", "%s locale_overlaps=%s" % [path, JSON.stringify(locale_overlaps)], true)
		face_checks.append({"path": path, "contexts": face_paths[path], "visible_alpha_rect": str(visible_rect), "locale_overlaps": locale_overlaps, "clear": clear})
		print("MEASURE timer_face path=%s contexts=%s visible_alpha_rect=%s timer_visible_bounds=%s locale_overlaps=%s clear=%s" % [path, JSON.stringify(face_paths[path]), visible_rect, JSON.stringify(timer_visible_bounds), JSON.stringify(locale_overlaps), clear])

	SaveData.custom_difficulty = "stage1"
	game.call("_set_face", face, game.call("_get_boss_def_path"))
	_set_runtime_locale("en")
	game.set("time_left", 9.9)
	game.call("update_timer_display")
	await _settle()
	_assert(timer.text == "Time left: 9.9s", "game visual capture uses the adopted English timer sample")
	_assert(timer_rect == Rect2(12.0, 1.0, 182.0, 45.0), "TimerLabel remains (12,1,182,45)")
	_assert(Rect2(score.position, score.size) == Rect2(204.0, 18.0, 266.0, 45.0), "ScoreDisplay remains (204,18,266,45)")
	await _save_viewport_capture("game_timer_en_9_9_full_r09_exact_480x854.png", {"screen": "game", "locale": "en", "timer": timer.text, "crop": "full", "revision": "r09_exact"})
	await _save_viewport_capture("game_timer_en_9_9_top_r09_exact_480x240.png", {"screen": "game", "locale": "en", "timer": timer.text, "crop": "0,0,480,240", "revision": "r09_exact"}, TIMER_CROP)

	_report["timer"] = {
		"source_max_seconds": TIMER_SOURCE_MAX,
		"locale_cases": LOCALES.size(),
		"overflow_count": timer_overflows,
		"longest": timer_longest,
		"face_candidate_count": face_checks.size(),
		"face_context_count": face_contexts.size(),
		"face_locale_case_count": face_checks.size() * LOCALES.size(),
		"face_overlap_count": face_overlaps,
		"face_candidates": face_checks,
		"visible_render_bounds_by_locale": timer_visible_bounds,
		"rect": str(timer_rect),
		"score_rect": str(Rect2(score.position, score.size)),
	}
	await _remove_scene(game)


func _audit_music_room_and_capture() -> void:
	_set_runtime_locale("ja")
	var music := MUSIC_ROOM_SCENE.instantiate() as Control
	_assert(music != null, "MusicRoom scene instantiates for containment audit")
	if music == null:
		return
	add_child(music)
	await _settle()
	var status := music.get_node("PlaybackStatusLabel") as Label
	var scroll := music.get_node("FullListScroll") as ScrollContainer
	var vbox := music.get_node("FullListScroll/FullListVBox") as VBoxContainer
	var constants: Dictionary = music.get_script().get_script_constant_map()
	var tracks: Array = constants.get("ALL_BGM_LIST", [])
	_assert(tracks.size() == 21, "MusicRoom script exposes all 21 actual tracks")
	_assert(status.size == Vector2(404.0, 28.0), "MusicRoom status uses the adopted 404x28 band")
	_assert(status.get_theme_font_size("font_size") == 18, "MusicRoom status uses actual font size 18")

	var status_count := 0
	var status_overflows := 0
	var status_longest: Dictionary = {"required_width": -1.0}
	var row_count := 0
	var row_overflows := 0
	var row_longest: Dictionary = {"required_width": -1.0}
	for locale in LOCALES:
		_set_runtime_locale(locale)
		music.call("_build_full_list")
		await _settle(2)
		var rows := vbox.get_children()
		_assert(rows.size() == 21, "%s MusicRoom has all 21 actual list rows" % locale)
		for index in range(rows.size()):
			var row := rows[index] as Button
			var row_metric := _measure_text_control(row, row.text, false)
			row_metric["locale"] = locale
			row_metric["track_index"] = index
			row_metric["text"] = row.text.strip_edges()
			row_metric["clip_text"] = row.clip_text
			row_metric["overrun"] = row.text_overrun_behavior
			row_metric["autowrap"] = row.autowrap_mode
			row_count += 1
			if bool(row_metric["overflow"]):
				row_overflows += 1
				print("OVERFLOW music_row " + JSON.stringify(row_metric))
				_record_debt("MUSIC_ROW_OVERFLOW", "%s row=%d text=%s" % [locale, index, row.text.strip_edges()], true)
			if float(row_metric["required_width"]) > float(row_longest["required_width"]):
				row_longest = row_metric.duplicate(true)

		for index in range(tracks.size()):
			var entry: Dictionary = tracks[index]
			var file := str(entry["file"])
			var display_name := str(music.call("_get_display_name", file))
			for state in MUSIC_STATES:
				var text := str(music.call("_music_status_text", state, display_name))
				var metric := _measure_text_control(status, text, false)
				metric["locale"] = locale
				metric["track_index"] = index
				metric["file"] = file
				metric["track"] = display_name
				metric["state"] = state
				metric["text"] = text
				status_count += 1
				if bool(metric["overflow"]):
					status_overflows += 1
					print("OVERFLOW music_status " + JSON.stringify(metric))
					_record_debt("MUSIC_STATUS_OVERFLOW", "%s %s %s" % [locale, state, text], true)
				if float(metric["required_width"]) > float(status_longest["required_width"]):
					status_longest = metric.duplicate(true)

	_assert(status_count == 315, "MusicRoom measures 21 tracks x 3 states x 5 locales")
	_assert(row_count == 105, "MusicRoom measures 21 rows x 5 locales")
	_assert(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "MusicRoom list horizontal scrolling is disabled")
	_assert(not scroll.get_h_scroll_bar().visible, "MusicRoom list has no visible horizontal scrollbar")
	_assert(status.autowrap_mode == TextServer.AUTOWRAP_OFF, "MusicRoom status is one line")
	print("SUMMARY music_status cases=%d longest=%s overflow=%d clip_text=%s overrun=%d rect=%s" % [status_count, JSON.stringify(status_longest), status_overflows, status.clip_text, status.text_overrun_behavior, status.size])
	print("SUMMARY music_rows cases=%d longest=%s overflow=%d hscroll_visible=%s hscroll_mode=%d" % [row_count, JSON.stringify(row_longest), row_overflows, scroll.get_h_scroll_bar().visible, scroll.horizontal_scroll_mode])

	var worst_locale := str(status_longest["locale"])
	var worst_index := int(status_longest["track_index"])
	var worst_file := str(status_longest["file"])
	var worst_state := str(status_longest["state"])
	_set_runtime_locale(worst_locale)
	music.call("_build_full_list")
	await _settle(2)
	music.set("_full_list_selected_index", worst_index)
	if worst_state == "selected":
		music.set("_player_state", "idle")
		music.set("_current_playing_file", "")
	else:
		music.set("_player_state", worst_state)
		music.set("_current_playing_file", worst_file)
	music.call("_update_visuals")
	music.call("_update_track_name_display")
	await _settle(2)
	var capture_rows := vbox.get_children()
	if worst_index >= 0 and worst_index < capture_rows.size():
		var focused_row := capture_rows[worst_index] as Button
		focused_row.grab_focus()
		scroll.call_deferred("ensure_control_visible", focused_row)
		await _settle(3)
	_assert(status.text == str(status_longest["text"]), "MusicRoom capture renders the actual longest measured status")
	await _save_viewport_capture(
		"music_room_%s_%s_track_%02d_r09_exact_480x854.png" % [worst_locale, worst_state, worst_index + 1],
		{"screen": "music_room", "locale": worst_locale, "state": worst_state, "track_index": worst_index, "track_file": worst_file, "text": status.text, "rows": capture_rows.size(), "revision": "r09_exact"}
	)
	_report["music_room"] = {
		"status_cases": status_count,
		"status_overflow_count": status_overflows,
		"status_longest": status_longest,
		"status_clip_text": status.clip_text,
		"status_overrun": status.text_overrun_behavior,
		"row_cases": row_count,
		"row_overflow_count": row_overflows,
		"row_longest": row_longest,
		"horizontal_scroll_mode": scroll.horizontal_scroll_mode,
		"horizontal_scrollbar_visible": scroll.get_h_scroll_bar().visible,
	}
	await _remove_scene(music)


func _audit_title_and_capture() -> void:
	_set_runtime_locale("ja")
	var title := TITLE_SCENE.instantiate() as Control
	_assert(title != null, "Title scene instantiates for modal containment audit")
	if title == null:
		return
	add_child(title)
	await _settle()

	var settings_button := title.get_node("BtnSettings") as Button
	await _click_control(settings_button)
	var settings_panel := title.get_node("SettingsPopup") as Panel
	var settings_overlay := title.get_node("SettingsOverlay") as Control
	_assert(settings_panel.visible and settings_overlay.visible, "real Title Settings input opens panel and backdrop")
	_assert(settings_overlay.mouse_filter == Control.MOUSE_FILTER_STOP and settings_overlay.get_global_rect().size == Vector2(480.0, 854.0), "Title Settings backdrop blocks the full screen")
	_assert_focus_confined(settings_panel)
	var settings_worst: Dictionary = {"ratio": -1.0, "locale": "ja", "path": "VBox/BgmSlider"}
	var settings_overflows := 0
	for locale in LOCALES:
		_set_runtime_locale(locale)
		title.call("_apply_title_language")
		title.call("_refresh_settings_skin")
		title.call("_setup_language_controls")
		title.call("_refresh_language_buttons")
		await _settle(3)
		var locale_result := _audit_title_settings_locale(settings_panel, locale)
		settings_overflows += int(locale_result["overflow_count"])
		if float(locale_result["worst_ratio"]) > float(settings_worst["ratio"]):
			settings_worst = {"ratio": locale_result["worst_ratio"], "locale": locale, "path": locale_result["worst_path"], "text": locale_result["worst_text"]}

	_set_runtime_locale(str(settings_worst["locale"]))
	title.call("_apply_title_language")
	title.call("_refresh_settings_skin")
	title.call("_setup_language_controls")
	await _settle(3)
	var settings_focus := settings_panel.get_node_or_null(str(settings_worst["path"])) as Control
	if settings_focus == null or settings_focus.focus_mode == Control.FOCUS_NONE:
		settings_focus = settings_panel.get_node("VBox/LanguageGrid/BtnLanguageen") as Control
	settings_focus.grab_focus()
	await _settle(2)
	await _save_viewport_capture(
		"title_settings_%s_focus_r09_exact_480x854.png" % str(settings_worst["locale"]),
		{"screen": "title_settings", "locale": settings_worst["locale"], "focus": str(settings_focus.get_path()), "language_targets": 5, "backdrop": true, "revision": "r09_exact"}
	)
	await _push_action("ui_cancel")
	await _settle(2)
	_assert(not settings_panel.visible and not settings_overlay.visible, "real Back closes only Title Settings")
	_assert(get_viewport().gui_get_focus_owner() == settings_button, "Title Settings Back restores invoker focus")

	var credit_button := title.get_node("CreditFrame/BtnCredit") as Button
	await _click_control(credit_button)
	var credit_panel := title.get_node("CreditPopup") as Panel
	var credit_overlay := title.get_node("CreditOverlay") as Control
	_assert(credit_panel.visible and credit_overlay.visible, "real Title Credits input opens panel and backdrop")
	_assert(credit_overlay.mouse_filter == Control.MOUSE_FILTER_STOP and credit_overlay.get_global_rect().size == Vector2(480.0, 854.0), "Title Credits backdrop blocks the full screen")
	_assert_focus_confined(credit_panel)
	var normal_worst: Dictionary = {"worst_ratio": -1.0, "locale": "ja"}
	var legal_worst: Dictionary = {"worst_ratio": -1.0, "locale": "ja"}
	var credit_overflows := 0
	var credit_scroll_debts: Array[String] = []
	for locale in LOCALES:
		_set_runtime_locale(locale)
		title.call("_apply_title_language")
		title.set("_credit_legal_view_active", false)
		title.call("_update_credit_view", true)
		await _settle(3)
		var normal_result := await _audit_credit_locale(title, locale, false)
		credit_overflows += int(normal_result["overflow_count"])
		if not bool(normal_result["bottom_reached"]):
			credit_scroll_debts.append(locale + ":credits")
		if float(normal_result["worst_ratio"]) > float(normal_worst["worst_ratio"]):
			normal_worst = normal_result.duplicate(true)

		title.set("_credit_legal_view_active", true)
		title.call("_update_credit_view", true)
		await _settle(3)
		var legal_result := await _audit_credit_locale(title, locale, true)
		credit_overflows += int(legal_result["overflow_count"])
		if not bool(legal_result["bottom_reached"]):
			credit_scroll_debts.append(locale + ":legal")
		if float(legal_result["worst_ratio"]) > float(legal_worst["worst_ratio"]):
			legal_worst = legal_result.duplicate(true)

	_set_runtime_locale(str(normal_worst["locale"]))
	title.call("_apply_title_language")
	title.set("_credit_legal_view_active", false)
	title.call("_update_credit_view", true)
	await _settle(3)
	var licenses := credit_panel.get_node("VBox/CreditActionRow/BtnLicenses") as Button
	licenses.grab_focus()
	await _settle(2)
	await _save_viewport_capture(
		"title_credits_%s_focus_r09_exact_480x854.png" % str(normal_worst["locale"]),
		{"screen": "title_credits", "locale": normal_worst["locale"], "focus": "licenses", "backdrop": true, "revision": "r09_exact"}
	)

	await _click_control(licenses)
	_assert(bool(title.get("_credit_legal_view_active")), "real Licenses input opens Legal")
	_set_runtime_locale(str(legal_worst["locale"]))
	title.call("_apply_title_language")
	title.call("_update_credit_view", true)
	await _settle(3)
	licenses.grab_focus()
	await _save_viewport_capture(
		"title_legal_%s_focus_r09_exact_480x854.png" % str(legal_worst["locale"]),
		{"screen": "title_legal", "locale": legal_worst["locale"], "focus": "back_to_credits", "backdrop": true, "revision": "r09_exact"}
	)
	await _capture_legal_pixel_probe(title)
	await _push_action("ui_cancel")
	await _settle(2)
	_assert(credit_panel.visible and not bool(title.get("_credit_legal_view_active")), "first real Back returns Legal to Credits only")
	await _push_action("ui_cancel")
	await _settle(2)
	_assert(not credit_panel.visible and not credit_overlay.visible, "second real Back closes Credits")
	_assert(get_viewport().gui_get_focus_owner() == credit_button, "Credits Back restores invoker focus")

	_report["title"] = {
		"settings_locales": LOCALES.size(),
		"settings_overflow_count": settings_overflows,
		"settings_worst": settings_worst,
		"credits_modes": LOCALES.size() * 2,
		"credits_overflow_count": credit_overflows,
		"credits_normal_worst": normal_worst,
		"credits_legal_worst": legal_worst,
		"scroll_bottom_failures": credit_scroll_debts,
	}
	await _remove_scene(title)


func _capture_legal_pixel_probe(title: Control) -> void:
	_set_runtime_locale("en")
	title.call("_apply_title_language")
	title.set("_credit_legal_view_active", true)
	title.call("_update_credit_view", true)
	await _settle(3)
	var scroll := title.get_node("CreditPopup/VBox/CreditScroll") as ScrollContainer
	var body := title.get_node("CreditPopup/VBox/CreditScroll/CreditBody") as Label
	var vbar := scroll.get_v_scroll_bar()
	var named := _audit_named_legal_lines(body)
	var known_lines := named["known_lines"] as Dictionary
	_assert(known_lines.has(LEGAL_PIXEL_PROBE_HASH), "Legal pixel probe target line is present")
	if not known_lines.has(LEGAL_PIXEL_PROBE_HASH):
		_record_debt("CREDIT_PIXEL_PROBE_INCONCLUSIVE", "target line missing", true)
		return
	var detail := known_lines[LEGAL_PIXEL_PROBE_HASH] as Dictionary
	var local_bounds := Rect2(
		Vector2(float(detail["actual_x"]), float(detail["actual_y"])),
		Vector2(float(detail["actual_width"]), float(detail["actual_height"]))
	)
	scroll.scroll_vertical = maxi(0, int(floor(local_bounds.position.y - 100.0)))
	await _settle(3)
	var global_bounds := _transform_rect_aabb(body.get_global_transform(), local_bounds)
	var body_rect := body.get_global_rect()
	var vbar_rect := vbar.get_global_rect()
	var crop_x := maxi(0, int(floor(scroll.get_global_rect().position.x)) - 8)
	var crop_y := maxi(0, int(floor(global_bounds.position.y)) - 20)
	var crop_width := mini(VIEWPORT_SIZE.x - crop_x, int(ceil(scroll.get_global_rect().size.x)) + 16)
	var crop_height := mini(VIEWPORT_SIZE.y - crop_y, maxi(96, int(ceil(global_bounds.size.y)) + 40))
	var crop := Rect2i(crop_x, crop_y, crop_width, crop_height)
	var actual_name := "title_legal_en_overflow_line_actual_r09_exact2_%dx%d.png" % [crop.size.x, crop.size.y]
	var clear_name := "title_legal_en_overflow_line_vbar_clear_probe_r09_exact2_%dx%d.png" % [crop.size.x, crop.size.y]
	var background_name := "title_legal_en_overflow_line_background_probe_r09_exact2_%dx%d.png" % [crop.size.x, crop.size.y]
	await _save_viewport_capture(actual_name, {"screen": "title_legal_pixel_probe", "locale": "en", "variant": "actual", "line": detail["line"], "revision": "r09_exact"}, crop)
	var original_vbar_modulate := vbar.modulate
	vbar.modulate = Color(original_vbar_modulate.r, original_vbar_modulate.g, original_vbar_modulate.b, 0.0)
	await _settle(2)
	await _save_viewport_capture(clear_name, {"screen": "title_legal_pixel_probe", "locale": "en", "variant": "vbar_clear_test_probe", "line": detail["line"], "revision": "r09_exact"}, crop)
	var original_body_self_modulate := body.self_modulate
	body.self_modulate = Color(original_body_self_modulate.r, original_body_self_modulate.g, original_body_self_modulate.b, 0.0)
	await _settle(2)
	await _save_viewport_capture(background_name, {"screen": "title_legal_pixel_probe", "locale": "en", "variant": "vbar_clear_background_probe", "line": detail["line"], "revision": "r09_exact"}, crop)
	body.self_modulate = original_body_self_modulate
	vbar.modulate = original_vbar_modulate
	await _settle(1)
	var actual_path := ProjectSettings.globalize_path(OUTPUT_DIR + "/" + actual_name)
	var clear_path := ProjectSettings.globalize_path(OUTPUT_DIR + "/" + clear_name)
	var background_path := ProjectSettings.globalize_path(OUTPUT_DIR + "/" + background_name)
	var actual_image := Image.load_from_file(actual_path)
	var clear_image := Image.load_from_file(clear_path)
	var background_image := Image.load_from_file(background_path)
	var band_start := maxi(0, int(floor(body_rect.end.x)) - crop.position.x)
	var band_end := mini(clear_image.get_width(), int(ceil(global_bounds.end.x)) - crop.position.x + 1)
	var reference_glyph_pixels := 0
	var occluded_reference_glyph_pixels := 0
	for y in range(clear_image.get_height()):
		for x in range(band_start, band_end):
			var reference_pixel := clear_image.get_pixel(x, y)
			var actual_pixel := actual_image.get_pixel(x, y)
			var background_pixel := background_image.get_pixel(x, y)
			var glyph_delta := Vector4(reference_pixel.r - background_pixel.r, reference_pixel.g - background_pixel.g, reference_pixel.b - background_pixel.b, reference_pixel.a - background_pixel.a).length()
			if glyph_delta > 0.02:
				reference_glyph_pixels += 1
				var pixel_delta := Vector4(reference_pixel.r - actual_pixel.r, reference_pixel.g - actual_pixel.g, reference_pixel.b - actual_pixel.b, reference_pixel.a - actual_pixel.a).length()
				if pixel_delta > 0.08:
					occluded_reference_glyph_pixels += 1
	var actual_occlusion := reference_glyph_pixels > 0 and occluded_reference_glyph_pixels > 0
	_report["legal_pixel_probe"] = {
		"line": detail,
		"body_rect": str(body_rect),
		"vbar_rect": str(vbar_rect),
		"global_character_bounds": str(global_bounds),
		"overflow_band_width": snappedf(maxf(0.0, global_bounds.end.x - body_rect.end.x), 0.001),
		"bounds_intersect_visible_vbar": global_bounds.intersects(vbar_rect) and vbar.visible,
		"reference_glyph_pixels_beyond_body": reference_glyph_pixels,
		"occluded_reference_glyph_pixels_in_actual": occluded_reference_glyph_pixels,
		"actual_pixel_occlusion": actual_occlusion,
		"actual_capture": actual_path,
		"vbar_clear_probe_capture": clear_path,
		"background_probe_capture": background_path,
	}
	if reference_glyph_pixels == 0:
		print("PASS credit_pixel_probe actual_right exceeds body bounds but no rendered glyph pixels exist beyond the body rect")
	elif actual_occlusion:
		_record_debt("CREDIT_ACTUAL_PIXEL_OCCLUSION", "line=%d overflow_band=%.3f reference_glyph_pixels=%d occluded_in_actual=%d" % [detail["line"], global_bounds.end.x - body_rect.end.x, reference_glyph_pixels, occluded_reference_glyph_pixels], true)
	else:
		print("PASS credit_pixel_probe rendered glyph pixels beyond the body rect remain visible in the actual product capture")


func _audit_title_settings_locale(panel: Panel, locale: String) -> Dictionary:
	var overflow_count := 0
	var worst_ratio := -1.0
	var worst_path := ""
	var worst_text := ""
	var panel_rect := panel.get_global_rect()
	var vbox := panel.get_node("VBox") as VBoxContainer
	_assert(_rect_contains(panel_rect, vbox.get_global_rect()), "%s Title Settings VBox stays inside panel" % locale)
	_assert_sibling_non_overlap(vbox, "%s Title Settings" % locale)
	var text_controls := _collect_text_controls(panel)
	for control in text_controls:
		if not control.is_visible_in_tree():
			continue
		var text := _control_text(control)
		if text.is_empty():
			continue
		var wrapped := control is Label and (control as Label).autowrap_mode != TextServer.AUTOWRAP_OFF
		var metric := _measure_text_control(control, text, wrapped)
		var ratio := maxf(float(metric["required_width"]) / maxf(float(metric["available_width"]), 1.0), float(metric["required_height"]) / maxf(float(metric["available_height"]), 1.0))
		if bool(metric["overflow"]):
			overflow_count += 1
			print("OVERFLOW title_settings locale=%s path=%s metric=%s" % [locale, control.get_path(), JSON.stringify(metric)])
			_record_debt("TITLE_SETTINGS_TEXT_OVERFLOW", "%s %s %s" % [locale, control.get_path(), text], true)
		if ratio > worst_ratio:
			worst_ratio = ratio
			worst_path = str(panel.get_path_to(control))
			worst_text = text
		_assert(_rect_contains(panel_rect, control.get_global_rect()), "%s %s stays inside Title Settings panel" % [locale, control.name])

	var language_buttons: Array[Control] = []
	for suffix in ["ja", "en", "zhCN", "zhTW", "ko"]:
		var button := panel.get_node("VBox/LanguageGrid/BtnLanguage" + suffix) as Control
		language_buttons.append(button)
		_assert(button.size.y >= ModalFoundation.PREFERRED_TOUCH_TARGET, "%s %s language target is at least 48px" % [locale, button.name])
		_assert(_rect_contains(panel_rect, button.get_global_rect()), "%s %s language target stays in panel" % [locale, button.name])
	_assert_pairwise_non_overlap(language_buttons, "%s Title language targets" % locale)
	_assert_focus_confined(panel)
	print("SUMMARY title_settings locale=%s overflow=%d worst_ratio=%.5f worst_path=%s worst_text=%s language_targets=5 touch48=1" % [locale, overflow_count, worst_ratio, worst_path, worst_text])
	return {"locale": locale, "overflow_count": overflow_count, "worst_ratio": worst_ratio, "worst_path": worst_path, "worst_text": worst_text}


func _audit_credit_locale(title: Control, locale: String, legal: bool) -> Dictionary:
	var mode := "legal" if legal else "credits"
	var panel := title.get_node("CreditPopup") as Panel
	var scroll := title.get_node("CreditPopup/VBox/CreditScroll") as ScrollContainer
	var body := title.get_node("CreditPopup/VBox/CreditScroll/CreditBody") as Label
	var row := title.get_node("CreditPopup/VBox/CreditActionRow") as HBoxContainer
	var licenses := title.get_node("CreditPopup/VBox/CreditActionRow/BtnLicenses") as Button
	var privacy := title.get_node("CreditPopup/VBox/CreditActionRow/BtnPrivacyPolicy") as Button
	var close := title.get_node("CreditPopup/VBox/BtnCreditClose") as Button
	var panel_rect := panel.get_global_rect()
	var overflow_count := 0
	_assert(_rect_contains(panel_rect, scroll.get_global_rect()), "%s %s CreditScroll stays inside panel" % [locale, mode])
	_assert(_rect_contains(panel_rect, row.get_global_rect()), "%s %s ActionRow stays inside panel" % [locale, mode])
	_assert(_rect_contains(panel_rect, close.get_global_rect()), "%s %s Close stays inside panel" % [locale, mode])
	_assert(not row.get_global_rect().intersects(close.get_global_rect()), "%s %s ActionRow and Close do not overlap" % [locale, mode])
	_assert(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "%s %s legal/credit horizontal scrolling is disabled" % [locale, mode])
	_assert(not scroll.get_h_scroll_bar().visible, "%s %s legal/credit horizontal scrollbar stays hidden" % [locale, mode])

	var body_metric := _measure_text_control(body, body.text, true)
	var longest_token := _longest_unbreakable_token(body)
	var widest_source_line := _widest_wrapped_source_line(body)
	var named_legal_lines := _audit_named_legal_lines(body)
	_assert(int(named_legal_lines["exact_checked_count"]) == int(named_legal_lines["candidate_count"]), "%s %s checks every URL/copyright line with actual character bounds" % [locale, mode])
	if legal:
		_assert(int(named_legal_lines["candidate_count"]) == LEGAL_NAMED_LINE_COUNT, "%s Legal retains all named URL/copyright lines" % locale)
		_assert(int(named_legal_lines["url_count"]) == LEGAL_URL_LINE_COUNT, "%s Legal retains all URL lines" % locale)
		_assert(int(named_legal_lines["copyright_count"]) == LEGAL_COPYRIGHT_LINE_COUNT, "%s Legal retains all copyright lines" % locale)
		for expected_hash in LEGAL_KNOWN_LINE_HASHES:
			var known_lines := named_legal_lines["known_lines"] as Dictionary
			_assert(known_lines.has(expected_hash), "%s Legal retains known line %s" % [locale, expected_hash])
			if known_lines.has(expected_hash):
				var known := known_lines[expected_hash] as Dictionary
				_assert(float(known["actual_right"]) <= float(known["available_width"]) + 0.5, "%s known Legal line %s actual-right fits" % [locale, expected_hash])
	else:
		_assert(not bool(body_metric["overflow"]), "%s Credits normal body fits its actual text area" % locale)
	if bool(widest_source_line["actual_right_overflow"]):
		overflow_count += 1
		_record_debt("CREDIT_BODY_HORIZONTAL_OVERFLOW", "%s %s actual_right=%.3f available=%.3f source_line=%d kind=%s preview=%s" % [locale, mode, widest_source_line["actual_right"], body.size.x, widest_source_line["line"], widest_source_line["kind"], widest_source_line["preview"]], true)
	if int(named_legal_lines["overflow_count"]) > 0:
		overflow_count += int(named_legal_lines["overflow_count"])
		_record_debt("CREDIT_NAMED_LINE_HORIZONTAL_OVERFLOW", "%s %s count=%d worst=%s" % [locale, mode, named_legal_lines["overflow_count"], named_legal_lines["worst_preview"]], true)
	var longest_raw := _longest_raw_line(body)
	var action_metrics: Array[Dictionary] = []
	if legal:
		_assert(licenses.visible and not privacy.visible, "%s Legal shows exactly the single back-to-credits action" % locale)
	else:
		_assert(licenses.visible and privacy.visible, "%s Credits shows both legal action buttons" % locale)
	for button in [licenses, privacy]:
		if not button.visible:
			continue
		var metric := _measure_text_control(button, button.text, false)
		metric["button"] = button.name
		action_metrics.append(metric)
		if bool(metric["overflow"]):
			overflow_count += 1
			_record_debt("CREDIT_ACTION_TEXT_OVERFLOW", "%s %s %s text=%s" % [locale, mode, button.name, button.text], true)
		_assert(_rect_contains(row.get_global_rect(), button.get_global_rect()), "%s %s %s stays in ActionRow" % [locale, mode, button.name])
	if privacy.visible:
		_assert(not licenses.get_global_rect().intersects(privacy.get_global_rect()), "%s Credits action buttons do not overlap" % locale)
	var used_width := licenses.size.x
	if privacy.visible:
		used_width = privacy.get_global_rect().end.x - licenses.get_global_rect().position.x
	var remaining := row.size.x - used_width
	_assert(remaining >= -0.5, "%s %s ActionRow content fits its actual width" % [locale, mode])

	var vbar := scroll.get_v_scroll_bar()
	var max_scroll := maxf(0.0, vbar.max_value - vbar.page)
	scroll.scroll_vertical = int(ceil(max_scroll))
	await _settle(2)
	var bottom_reached := absf(float(scroll.scroll_vertical) - max_scroll) <= 2.0
	if not bottom_reached:
		_record_debt("CREDIT_SCROLL_END_UNREACHABLE", "%s %s actual=%d max=%.3f" % [locale, mode, scroll.scroll_vertical, max_scroll], true)
	scroll.scroll_vertical = 0
	await _settle(1)
	var worst_ratio := used_width / maxf(row.size.x, 1.0)
	for metric in action_metrics:
		worst_ratio = maxf(worst_ratio, float(metric["required_width"]) / maxf(float(metric["available_width"]), 1.0))
	print("SUMMARY title_credit locale=%s mode=%s row_width=%.3f used_width=%.3f remaining=%.3f overflow=%d body_size=%s body_required=%sx%s body_lines=%d visible_lines=%d widest_source_line=%s hscroll=0 scroll_clip=%s body_clip_text=%s vscroll_max=%.3f bottom_reached=%s" % [locale, mode, row.size.x, used_width, remaining, overflow_count, body.size, body_metric["required_width"], body_metric["required_height"], body.get_line_count(), body.get_visible_line_count(), JSON.stringify(widest_source_line), scroll.clip_contents, body.clip_text, max_scroll, bottom_reached])
	return {
		"locale": locale,
		"mode": mode,
		"overflow_count": overflow_count,
		"worst_ratio": worst_ratio,
		"row_width": row.size.x,
		"used_width": used_width,
		"remaining_width": remaining,
		"body_required_width": body_metric["required_width"],
		"body_required_height": body_metric["required_height"],
		"body_available_width": body_metric["available_width"],
		"body_available_height": body_metric["available_height"],
		"line_count": body.get_line_count(),
		"visible_line_count": body.get_visible_line_count(),
		"longest_raw_line": longest_raw,
		"longest_unbreakable_token": longest_token,
		"widest_wrapped_source_line": widest_source_line,
		"named_url_copyright_lines": named_legal_lines,
		"vertical_scroll_max": max_scroll,
		"bottom_reached": bottom_reached,
		"horizontal_scrollbar_visible": scroll.get_h_scroll_bar().visible,
		"scroll_clips_contents": scroll.clip_contents,
		"body_clip_text": body.clip_text,
		"body_text_overrun_behavior": body.text_overrun_behavior,
	}


func _audit_stage_support_and_capture() -> void:
	_set_runtime_locale("ja")
	SupportPurchase.formatted_price = ""
	var stage := STAGE_SELECT_SCENE.instantiate() as Control
	_assert(stage != null, "StageSelect scene instantiates for support containment audit")
	if stage == null:
		return
	add_child(stage)
	await _settle()
	var invoker := stage.get_node("BtnSettings") as Button
	invoker.grab_focus()
	stage.set("_support_invoker", invoker)
	stage.call("_set_support_popup_visible", true)
	await _settle(3)
	var panel := stage.get_node("SupportPopup") as Panel
	var backdrop := stage.get_node("SupportPopupInputBlocker") as Control
	_assert(panel.visible and backdrop.visible, "Stage Support actual panel/backdrop opens")
	_assert(backdrop.mouse_filter == Control.MOUSE_FILTER_STOP and backdrop.get_global_rect().size == Vector2(480.0, 854.0), "Stage Support backdrop blocks the full screen")
	_assert_focus_confined(panel)

	var total_cases := 0
	var overflow_count := 0
	var worst: Dictionary = {"worst_ratio": -1.0, "locale": "ja", "status_key": "product_unavailable"}
	var price_probe_failures := 0
	for locale in LOCALES:
		_set_runtime_locale(locale)
		for with_price in [false, true]:
			SupportPurchase.formatted_price = PRICE_STRESS_SAMPLE if with_price else ""
			stage.call("_refresh_support_popup_texts")
			await _settle(3)
			var base_result := _audit_support_layout(panel, locale, "body_with_price" if with_price else "body", "")
			total_cases += 1
			overflow_count += int(base_result["overflow_count"])
			if with_price and int(base_result["overflow_count"]) > 0:
				price_probe_failures += 1
			if float(base_result["worst_ratio"]) > float(worst["worst_ratio"]):
				worst = base_result.duplicate(true)
		for status_key in SUPPORT_STATUS_KEYS:
			SupportPurchase.formatted_price = ""
			stage.call("_refresh_support_popup_texts")
			stage.call("_set_support_message", stage.call("_support_ui_text", status_key))
			await _settle(3)
			var result := _audit_support_layout(panel, locale, "status", status_key)
			total_cases += 1
			overflow_count += int(result["overflow_count"])
			if float(result["worst_ratio"]) > float(worst["worst_ratio"]):
				worst = result.duplicate(true)

	SupportPurchase.formatted_price = ""
	_set_runtime_locale(str(worst["locale"]))
	stage.call("_refresh_support_popup_texts")
	var capture_status_key := str(worst.get("status_key", ""))
	if capture_status_key.is_empty():
		capture_status_key = "product_unavailable"
	stage.call("_set_support_message", stage.call("_support_ui_text", capture_status_key))
	await _settle(3)
	var close := panel.get_node("VBox/BtnSupportClose") as Button
	close.grab_focus()
	await _settle(2)
	await _save_viewport_capture(
		"stage_support_%s_%s_focus_r09_exact_480x854.png" % [str(worst["locale"]), capture_status_key],
		{"screen": "stage_support", "locale": worst["locale"], "status": capture_status_key, "price": "none", "focus": "close", "backdrop": true, "revision": "r09_exact"}
	)
	stage.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await _settle(2)
	_assert(not panel.visible and not backdrop.visible, "actual system Back notification closes Stage Support")
	_assert(get_viewport().gui_get_focus_owner() == invoker, "Stage Support system Back restores invoker focus")

	_report["stage_support"] = {
		"locales": LOCALES.size(),
		"cases": total_cases,
		"overflow_count": overflow_count,
		"worst": worst,
		"price_stress_sample": PRICE_STRESS_SAMPLE,
		"price_probe_failures": price_probe_failures,
		"store_price_length_bound_proven": false,
	}
	_record_debt("STORE_PRICE_LENGTH_UNBOUNDED", "stress sample %s was measured, but the external store does not define a source-level maximum formatted-price length" % PRICE_STRESS_SAMPLE, false)
	await _remove_scene(stage)


func _audit_support_layout(panel: Panel, locale: String, variant: String, status_key: String) -> Dictionary:
	var title := panel.get_node("VBox/SupportTitle") as Label
	var body := panel.get_node("VBox/SupportBody") as Label
	var message := panel.get_node("VBox").get_child(2) as Label
	var buy := panel.get_node("VBox/BtnSupportBuy") as Button
	var restore := panel.get_node("VBox/BtnSupportRestore") as Button
	var close := panel.get_node("VBox/BtnSupportClose") as Button
	var controls: Array[Control] = [title, body, message, buy, restore, close]
	var overflow_count := 0
	var worst_ratio := -1.0
	var worst_control := ""
	var panel_rect := panel.get_global_rect()
	for control in controls:
		_assert(_rect_contains(panel_rect, control.get_global_rect()), "%s %s %s stays inside Support panel" % [locale, variant, control.name])
		var text := _control_text(control)
		if text.is_empty():
			continue
		var wrapped := control is Label and (control as Label).autowrap_mode != TextServer.AUTOWRAP_OFF
		var metric := _measure_text_control(control, text, wrapped)
		var ratio := maxf(float(metric["required_width"]) / maxf(float(metric["available_width"]), 1.0), float(metric["required_height"]) / maxf(float(metric["available_height"]), 1.0))
		if bool(metric["overflow"]):
			overflow_count += 1
			print("OVERFLOW support locale=%s variant=%s status=%s control=%s metric=%s text=%s" % [locale, variant, status_key, control.name, JSON.stringify(metric), text])
			_record_debt("SUPPORT_TEXT_OVERFLOW", "%s %s %s %s" % [locale, variant, status_key, control.name], true)
		if ratio > worst_ratio:
			worst_ratio = ratio
			worst_control = control.name
	_assert_pairwise_non_overlap(controls, "%s %s Support controls" % [locale, variant])
	var message_metric := _measure_text_control(message, message.text, true) if not message.text.is_empty() else {"required_width": 0.0, "required_height": 0.0, "available_width": message.size.x, "available_height": message.size.y, "overflow": false}
	print("SUMMARY support locale=%s variant=%s status=%s overflow=%d worst_ratio=%.5f worst_control=%s title=%s body_size=%s body_lines=%d/%d message_size=%s message_required=%sx%s message_lines=%d/%d buttons=%s|%s|%s" % [locale, variant, status_key, overflow_count, worst_ratio, worst_control, title.text, body.size, body.get_line_count(), body.get_visible_line_count(), message.size, message_metric["required_width"], message_metric["required_height"], message.get_line_count(), message.get_visible_line_count(), buy.text, restore.text, close.text])
	return {"locale": locale, "variant": variant, "status_key": status_key, "overflow_count": overflow_count, "worst_ratio": worst_ratio, "worst_control": worst_control, "message_size": str(message.size), "message_required_width": message_metric["required_width"], "message_required_height": message_metric["required_height"], "message_line_count": message.get_line_count(), "message_visible_line_count": message.get_visible_line_count()}


func _measure_text_control(control: Control, text: String, wrapped: bool) -> Dictionary:
	var font := control.get_theme_font("font")
	var font_size := control.get_theme_font_size("font_size")
	var available := _available_text_size(control)
	var required: Vector2
	var actual_bounds := Rect2()
	var measurement_method := "font_measure"
	if control is Label and (control as Label).text == text and text.length() <= 2048:
		actual_bounds = _label_character_bounds(control as Label)
		if actual_bounds.size.x > 0.0 and actual_bounds.size.y > 0.0:
			measurement_method = "label_character_bounds"
			available = control.size
			required = actual_bounds.size
			var label_outline := control.get_theme_constant("outline_size")
			var expanded_bounds := actual_bounds.grow(float(label_outline))
			var label_rect := Rect2(Vector2.ZERO, control.size)
			var bounds_overflow_width := actual_bounds.position.x < -0.5 or actual_bounds.end.x > label_rect.end.x + 0.5
			var bounds_overflow_height := actual_bounds.position.y < -0.5 or actual_bounds.end.y > label_rect.end.y + 0.5
			var outline_bleed_width := expanded_bounds.position.x < -0.5 or expanded_bounds.end.x > label_rect.end.x + 0.5
			var outline_bleed_height := expanded_bounds.position.y < -0.5 or expanded_bounds.end.y > label_rect.end.y + 0.5
			return {
				"font_size": font_size,
				"required_width": snappedf(actual_bounds.size.x, 0.001),
				"required_height": snappedf(actual_bounds.size.y, 0.001),
				"available_width": snappedf(available.x, 0.001),
				"available_height": snappedf(available.y, 0.001),
				"glyph_bounds": str(actual_bounds),
				"visible_render_bounds": str(expanded_bounds),
				"outline_bleed_width": outline_bleed_width,
				"outline_bleed_height": outline_bleed_height,
				"overflow_width": bounds_overflow_width,
				"overflow_height": bounds_overflow_height,
				"overflow": bounds_overflow_width or bounds_overflow_height,
				"wrapped": wrapped,
				"measurement_method": measurement_method,
			}
	if wrapped:
		required = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, maxf(available.x, 1.0), font_size)
	else:
		required = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var outline := control.get_theme_constant("outline_size")
	required += Vector2(float(outline * 2), float(outline * 2))
	var overflow_width := required.x > available.x + 0.5
	var overflow_height := required.y > available.y + 0.5
	return {
		"font_size": font_size,
		"required_width": snappedf(required.x, 0.001),
		"required_height": snappedf(required.y, 0.001),
		"available_width": snappedf(available.x, 0.001),
		"available_height": snappedf(available.y, 0.001),
		"overflow_width": overflow_width,
		"overflow_height": overflow_height,
		"overflow": overflow_width or overflow_height,
		"wrapped": wrapped,
		"measurement_method": measurement_method,
	}


func _label_character_bounds(label: Label) -> Rect2:
	var found := false
	var bounds := Rect2()
	for index in range(label.text.length()):
		var character_bounds := label.get_character_bounds(index)
		if character_bounds.size.x <= 0.0 or character_bounds.size.y <= 0.0:
			continue
		if not found:
			bounds = character_bounds
			found = true
		else:
			bounds = bounds.merge(character_bounds)
	return bounds if found else Rect2()


func _label_visible_canvas_rect(label: Label) -> Rect2:
	var local_bounds := _label_character_bounds(label)
	local_bounds = local_bounds.grow(float(maxi(0, label.get_theme_constant("outline_size"))))
	return _transform_rect_aabb(label.get_global_transform(), local_bounds)


func _transform_rect_aabb(transform: Transform2D, local_rect: Rect2) -> Rect2:
	var points: Array[Vector2] = [
		transform * local_rect.position,
		transform * Vector2(local_rect.end.x, local_rect.position.y),
		transform * local_rect.end,
		transform * Vector2(local_rect.position.x, local_rect.end.y),
	]
	var minimum := points[0]
	var maximum := points[0]
	for point in points:
		minimum = minimum.min(point)
		maximum = maximum.max(point)
	return Rect2(minimum, maximum - minimum)


func _available_text_size(control: Control) -> Vector2:
	var available := control.size
	var style := control.get_theme_stylebox("normal")
	if style != null:
		available.x -= maxf(0.0, style.get_content_margin(SIDE_LEFT)) + maxf(0.0, style.get_content_margin(SIDE_RIGHT))
		available.y -= maxf(0.0, style.get_content_margin(SIDE_TOP)) + maxf(0.0, style.get_content_margin(SIDE_BOTTOM))
	if control is CheckBox:
		var check := control as CheckBox
		var icon_name := "checked" if check.button_pressed else "unchecked"
		var icon := check.get_theme_icon(icon_name)
		if icon != null:
			available.x -= icon.get_width() + check.get_theme_constant("h_separation")
	elif control is Button:
		var button := control as Button
		if button.icon != null and not button.text.is_empty():
			available.x -= button.icon.get_width() + button.get_theme_constant("icon_max_width")
	return Vector2(maxf(0.0, available.x), maxf(0.0, available.y))


func _longest_raw_line(label: Label) -> Dictionary:
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var longest := {"text": "", "width": 0.0}
	for line in label.text.split("\n"):
		var width := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		if width > float(longest["width"]):
			longest = {"text": line, "width": snappedf(width, 0.001)}
	return longest


func _longest_unbreakable_token(label: Label) -> Dictionary:
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var longest := {"preview": "", "width": 0.0, "line": -1, "sha256": ""}
	var lines := label.text.replace("\t", " ").split("\n")
	for line_index in range(lines.size()):
		for token_variant in str(lines[line_index]).split(" ", false):
			var token := str(token_variant)
			if token.is_empty():
				continue
			var width := font.get_string_size(token, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
			if width > float(longest["width"]):
				longest = {
					"preview": token.left(160),
					"width": snappedf(width, 0.001),
					"line": line_index + 1,
					"sha256": token.sha256_text().to_upper(),
				}
	return longest


func _widest_wrapped_source_line(label: Label) -> Dictionary:
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var available_width := maxf(1.0, label.size.x)
	var source_lines := label.text.split("\n", true)
	var widest := {"preview": "", "measured_width": 0.0, "line": -1, "start_index": 0, "length": 0, "sha256": ""}
	var source_offset := 0
	for line_index in range(source_lines.size()):
		var line := str(source_lines[line_index])
		var measured_width := font.get_multiline_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, available_width, font_size).x
		if measured_width > float(widest["measured_width"]):
			widest = {
				"preview": line.left(160),
				"measured_width": snappedf(measured_width, 0.001),
				"line": line_index + 1,
				"start_index": source_offset,
				"length": line.length(),
				"sha256": line.sha256_text().to_upper(),
			}
		source_offset += line.length() + 1
	var actual_bounds := _label_character_range_bounds(label, int(widest["start_index"]), int(widest["length"]))
	actual_bounds = actual_bounds.grow(float(maxi(0, label.get_theme_constant("outline_size"))))
	widest["actual_bounds"] = str(actual_bounds)
	widest["actual_right"] = snappedf(actual_bounds.end.x, 0.001)
	widest["actual_right_overflow"] = actual_bounds.end.x > label.size.x + 0.5
	var preview := str(widest["preview"])
	widest["kind"] = "url" if preview.contains("http://") or preview.contains("https://") else ("copyright" if preview.to_lower().contains("copyright") else "license_text")
	return widest


func _label_character_range_bounds(label: Label, start_index: int, character_count: int) -> Rect2:
	var found := false
	var bounds := Rect2()
	var end_index := mini(label.text.length(), start_index + character_count)
	for index in range(maxi(0, start_index), end_index):
		var character_bounds := label.get_character_bounds(index)
		if character_bounds.size.x <= 0.0 or character_bounds.size.y <= 0.0:
			continue
		if not found:
			bounds = character_bounds
			found = true
		else:
			bounds = bounds.merge(character_bounds)
	return bounds if found else Rect2()


func _audit_named_legal_lines(label: Label) -> Dictionary:
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var outline := float(maxi(0, label.get_theme_constant("outline_size")))
	var source_lines := label.text.split("\n", true)
	var source_offset := 0
	var candidate_count := 0
	var url_count := 0
	var copyright_count := 0
	var coarse_risk_count := 0
	var exact_checked_count := 0
	var overflow_count := 0
	var overflow_details: Array[Dictionary] = []
	var known_lines: Dictionary = {}
	var worst_right := -INF
	var worst_preview := ""
	var worst_line := -1
	for line_index in range(source_lines.size()):
		var line := str(source_lines[line_index])
		var lowered := line.to_lower()
		var is_url := lowered.contains("http://") or lowered.contains("https://")
		var is_copyright := lowered.contains("copyright")
		if not is_url and not is_copyright:
			source_offset += line.length() + 1
			continue
		candidate_count += 1
		url_count += 1 if is_url else 0
		copyright_count += 1 if is_copyright else 0
		var coarse_width := font.get_multiline_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, label.size.x, font_size).x + outline * 2.0
		if coarse_width > label.size.x + 0.5:
			coarse_risk_count += 1
		var bounds := _label_character_range_bounds(label, source_offset, line.length())
		bounds = bounds.grow(outline)
		exact_checked_count += 1
		if bounds.end.x > worst_right:
			worst_right = bounds.end.x
			worst_preview = line.left(160)
			worst_line = line_index + 1
		var detail := {
			"line": line_index + 1,
			"kind": "url" if is_url else "copyright",
			"start_index": source_offset,
			"length": line.length(),
			"actual_x": snappedf(bounds.position.x, 0.001),
			"actual_y": snappedf(bounds.position.y, 0.001),
			"actual_width": snappedf(bounds.size.x, 0.001),
			"actual_height": snappedf(bounds.size.y, 0.001),
			"actual_right": snappedf(bounds.end.x, 0.001),
			"available_width": label.size.x,
			"coarse_width": snappedf(coarse_width, 0.001),
			"preview": line.left(200),
			"sha256": line.sha256_text().to_upper(),
		}
		if LEGAL_KNOWN_LINE_HASHES.has(str(detail["sha256"])) or str(detail["sha256"]) == LEGAL_PIXEL_PROBE_HASH:
			known_lines[str(detail["sha256"])] = detail.duplicate(true)
		if bounds.end.x > label.size.x + 0.5:
			overflow_count += 1
			overflow_details.append(detail)
		source_offset += line.length() + 1
	return {
		"candidate_count": candidate_count,
		"url_count": url_count,
		"copyright_count": copyright_count,
		"coarse_risk_count": coarse_risk_count,
		"exact_checked_count": exact_checked_count,
		"overflow_count": overflow_count,
		"overflow_details": overflow_details,
		"known_lines": known_lines,
		"worst_right": snappedf(maxf(0.0, worst_right), 0.001),
		"available_width": label.size.x,
		"worst_line": worst_line,
		"worst_preview": worst_preview,
	}


func _texture_visible_alpha_rect(texture_rect: TextureRect) -> Rect2:
	if texture_rect.texture == null:
		return Rect2()
	var image := texture_rect.texture.get_image()
	if image == null or image.is_empty():
		return Rect2()
	var used_pixels := image.get_used_rect()
	if used_pixels.size.x <= 0 or used_pixels.size.y <= 0:
		return Rect2()
	var source_size := Vector2(image.get_width(), image.get_height())
	var scale := minf(texture_rect.size.x / source_size.x, texture_rect.size.y / source_size.y)
	var draw_size := source_size * scale
	var offset := (texture_rect.size - draw_size) * 0.5
	var local_visible_rect := Rect2(offset + Vector2(used_pixels.position) * scale, Vector2(used_pixels.size) * scale)
	return _transform_rect_aabb(texture_rect.get_global_transform(), local_visible_rect)


func _collect_text_controls(root: Node) -> Array[Control]:
	var result: Array[Control] = []
	for child in root.get_children():
		if child is Label or child is Button:
			result.append(child as Control)
		result.append_array(_collect_text_controls(child))
	return result


func _control_text(control: Control) -> String:
	if control is Label:
		return (control as Label).text
	if control is Button:
		return (control as Button).text
	return ""


func _assert_focus_confined(panel: Control) -> void:
	var controls := ModalFoundation.collect_focusable_controls(panel)
	_assert(not controls.is_empty(), "%s has focusable modal controls" % panel.name)
	for control in controls:
		for path in [control.focus_neighbor_left, control.focus_neighbor_right, control.focus_neighbor_top, control.focus_neighbor_bottom, control.focus_previous, control.focus_next]:
			var target := control.get_node_or_null(path) as Control
			_assert(target != null and panel.is_ancestor_of(target), "%s focus stays inside %s" % [control.name, panel.name])


func _assert_sibling_non_overlap(container: Container, context: String) -> void:
	var controls: Array[Control] = []
	for child in container.get_children():
		if child is Control and (child as Control).visible:
			controls.append(child as Control)
	_assert_pairwise_non_overlap(controls, context)


func _assert_pairwise_non_overlap(controls: Array[Control], context: String) -> void:
	for first_index in range(controls.size()):
		for second_index in range(first_index + 1, controls.size()):
			var first := controls[first_index]
			var second := controls[second_index]
			_assert(not first.get_global_rect().intersects(second.get_global_rect()), "%s: %s and %s do not overlap" % [context, first.name, second.name])


func _rect_contains(outer: Rect2, inner: Rect2) -> bool:
	return outer.grow(0.5).encloses(inner)


func _click_control(control: Control) -> void:
	_assert(control != null and control.is_visible_in_tree(), "actual pointer target is visible")
	if control == null or not control.is_visible_in_tree():
		return
	var point := control.get_global_rect().get_center()
	for is_pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if is_pressed else 0
		event.pressed = is_pressed
		event.position = point
		event.global_position = point
		get_viewport().push_input(event, true)
		await get_tree().process_frame


func _push_action(action: StringName) -> void:
	for is_pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = is_pressed
		get_viewport().push_input(event, true)
		await get_tree().process_frame


func _settle(frame_count: int = 3) -> void:
	for _index in range(frame_count):
		await get_tree().process_frame
	RenderingServer.force_draw(false)
	await get_tree().process_frame


func _save_viewport_capture(file_name: String, metadata: Dictionary, crop: Rect2i = Rect2i()) -> void:
	await _settle(2)
	var image := get_viewport().get_texture().get_image()
	_assert(image != null and not image.is_empty(), "%s viewport capture returns pixels" % file_name)
	if image == null or image.is_empty():
		return
	_assert(image.get_size() == VIEWPORT_SIZE, "%s source viewport is 480x854" % file_name)
	if crop.size.x > 0 and crop.size.y > 0:
		image = image.get_region(crop)
	var path := OUTPUT_DIR + "/" + file_name
	var absolute_path := ProjectSettings.globalize_path(path)
	var save_error := image.save_png(absolute_path)
	_assert(save_error == OK, "%s saves as PNG" % file_name)
	if save_error != OK:
		return
	var capture := metadata.duplicate(true)
	capture["path"] = absolute_path
	capture["width"] = image.get_width()
	capture["height"] = image.get_height()
	capture["bytes"] = FileAccess.get_file_as_bytes(absolute_path).size()
	capture["sha256"] = FileAccess.get_sha256(absolute_path).to_upper()
	_captures.append(capture)
	print("CAPTURE " + JSON.stringify(capture))


func _remove_scene(scene: Node) -> void:
	if scene != null and is_instance_valid(scene):
		scene.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame


func _write_report(report_path: String = REPORT_PATH) -> void:
	var absolute_path := ProjectSettings.globalize_path(report_path)
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	_assert(file != null, "containment JSON report opens for writing")
	if file == null:
		return
	file.store_string(JSON.stringify(_report, "  ", false))
	file.close()
	print("REPORT path=%s bytes=%d sha256=%s" % [absolute_path, FileAccess.get_file_as_bytes(absolute_path).size(), FileAccess.get_sha256(absolute_path).to_upper()])


func _record_debt(code: String, detail: String, fail_test: bool) -> void:
	var value := code + ": " + detail
	if value not in _debts:
		_debts.append(value)
	print("DEBT " + value)
	if fail_test:
		_failed = true


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)

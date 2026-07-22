extends Node

const AdapterScript = preload("res://IOSGameCenterAdapter.gd")
const RankingScript = preload("res://candidate/RankingManager.gd")
const MockScript = preload("res://MockGameCenter.gd")

var _failures: PackedStringArray = []
var _assertion_count := 0


func _ready() -> void:
	_test_ios_id_contract()
	_test_authentication_then_show()
	_test_authentication_timeout_recovery()
	_test_resume_recovers_stuck_authentication()
	_test_stale_authentication_event_correlation()
	_test_persistent_player_identity_required()
	_test_expected_owner_mismatch_never_posts()
	_test_fifo_score_submission()
	_test_late_score_callback_correlation()
	_test_account_switch_keeps_submission_owner()
	_test_old_owner_timeout_does_not_pause_new_owner()
	_test_immediate_post_error()
	_test_score_timeout()
	_test_higher_score_deduplication()
	_test_show_waits_for_score()
	_test_explicit_show_prioritizes_matching_score()
	_test_leaderboard_timeout_and_cancel()
	_test_pending_clear_contract()

	if _failures.is_empty():
		print("PASS: %d deterministic iOS Game Center assertions" % _assertion_count)
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error(failure)
	get_tree().quit(1)


func _test_ios_id_contract() -> void:
	var ids: Dictionary = RankingScript.IOS_LEADERBOARD_IDS
	var expected_ios := {
		RankingScript.KEY_EASY: "com.nb0129.machiate.leaderboard.easy",
		RankingScript.KEY_NORMAL: "com.nb0129.machiate.leaderboard.normal",
		RankingScript.KEY_HARD_MIRAGE: "com.nb0129.machiate.leaderboard.hardmirage",
		RankingScript.KEY_TOO_EASY: "com.nb0129.machiate.leaderboard.tooeasy",
		RankingScript.KEY_ABNORMAL: "com.nb0129.machiate.leaderboard.abnormal",
		RankingScript.KEY_VERY_HARD_NIGHTMARE: "com.nb0129.machiate.leaderboard.veryhardnightmare",
		RankingScript.KEY_ENDLESS: "com.nb0129.machiate.leaderboard.endless",
	}
	var expected_android := {
		RankingScript.KEY_EASY: "CgkI6s38m_cNEAIQAQ",
		RankingScript.KEY_NORMAL: "CgkI6s38m_cNEAIQAg",
		RankingScript.KEY_HARD_MIRAGE: "CgkI6s38m_cNEAIQAw",
		RankingScript.KEY_TOO_EASY: "CgkI6s38m_cNEAIQBA",
		RankingScript.KEY_ABNORMAL: "CgkI6s38m_cNEAIQBQ",
		RankingScript.KEY_VERY_HARD_NIGHTMARE: "CgkI6s38m_cNEAIQBg",
		RankingScript.KEY_ENDLESS: "CgkI6s38m_cNEAIQBw",
	}
	_expect_equal("seven iOS IDs", ids.size(), 7)
	_expect_true("complete iOS ID map", RankingScript.has_complete_ios_leaderboard_configuration(ids))
	var unique: Dictionary = {}
	for stage_key in RankingScript.LEADERBOARD_NAMES.keys():
		var leaderboard_id := str(ids.get(stage_key, ""))
		_expect_equal("exact iOS ID mapping: %s" % stage_key, leaderboard_id, expected_ios[stage_key])
		_expect_equal(
			"exact Android ID mapping: %s" % stage_key,
			str(RankingScript.ANDROID_LEADERBOARD_IDS.get(stage_key, "")),
			expected_android[stage_key]
		)
		_expect_true("iOS ID has product namespace: %s" % stage_key, leaderboard_id.begins_with("com.nb0129.machiate.leaderboard."))
		_expect_true("iOS ID is not Android ID: %s" % stage_key, not leaderboard_id.begins_with("Cgk"))
		unique[leaderboard_id] = true
	_expect_equal("seven unique iOS IDs", unique.size(), 7)
	var partial := ids.duplicate(true)
	partial.erase(RankingScript.KEY_ENDLESS)
	_expect_false("partial iOS ID map rejected", RankingScript.has_complete_ios_leaderboard_configuration(partial))
	var duplicate := ids.duplicate(true)
	duplicate[RankingScript.KEY_ENDLESS] = duplicate[RankingScript.KEY_EASY]
	_expect_false("duplicate iOS ID map rejected", RankingScript.has_complete_ios_leaderboard_configuration(duplicate))
	_expect_equal("busy native error is normalized", RankingScript._classify_ios_leaderboard_error("native_ui_busy"), "busy")
	_expect_equal("temporary player ID is classified as restricted", RankingScript._classify_ios_leaderboard_error("player_identity_unavailable"), "restricted")
	_expect_equal("authentication error is normalized", RankingScript._classify_ios_leaderboard_error("authentication_failed"), "login_failed")
	_expect_equal("unknown display error is normalized", RankingScript._classify_ios_leaderboard_error("leaderboard_timeout"), "show_failed")


func _test_authentication_then_show() -> void:
	var mock: RefCounted = MockScript.new()
	var adapter: RefCounted = AdapterScript.new()
	var login_events: Array[bool] = []
	adapter.login_state_changed.connect(func(value: bool) -> void: login_events.append(value))
	_expect_true("adapter configures official contract", adapter.configure(mock))
	_expect_true("show request accepted before auth", adapter.show_leaderboard("lb.easy"))
	_expect_equal("authenticate called once", mock.calls_for("authenticate").size(), 1)
	_expect_equal("overlay waits for authentication", mock.calls_for("show_game_center").size(), 0)
	mock.authenticated = true
	mock.push_authentication_result(0)
	adapter.poll()
	_expect_equal("auth success emitted", login_events, [true])
	var show_calls: Array[Dictionary] = mock.calls_for("show_game_center")
	_expect_equal("overlay opens after auth", show_calls.size(), 1)
	_expect_equal("individual leaderboard payload", show_calls[0]["payload"].get("leaderboard_name"), "lb.easy")


func _test_authentication_timeout_recovery() -> void:
	var mock: RefCounted = MockScript.new()
	var adapter: RefCounted = AdapterScript.new()
	var results: Array[Dictionary] = []
	adapter.leaderboard_show_finished.connect(func(id: String, ok: bool, message: String) -> void:
		results.append({"id": id, "ok": ok, "message": message})
	)
	adapter.configure(mock)
	adapter.show_leaderboard("lb.easy")
	adapter.poll(AdapterScript.AUTHENTICATION_TIMEOUT_SECONDS + 0.1)
	_expect_equal("auth timeout closes pending show", results, [{"id": "lb.easy", "ok": false, "message": "authentication_timeout"}])
	_expect_true("login can retry after auth timeout", adapter.login())
	_expect_equal("authenticate retried after timeout", mock.calls_for("authenticate").size(), 2)


func _test_resume_recovers_stuck_authentication() -> void:
	var mock: RefCounted = MockScript.new()
	var adapter: RefCounted = AdapterScript.new()
	adapter.configure(mock)
	_expect_true("initial login starts before resume recovery", adapter.login())
	adapter.on_application_resumed()
	_expect_true("login can retry after resume reset", adapter.login())
	_expect_equal("authenticate retried after resume", mock.calls_for("authenticate").size(), 2)


func _test_stale_authentication_event_correlation() -> void:
	var mock: RefCounted = MockScript.new()
	var adapter: RefCounted = AdapterScript.new()
	var results: Array[Dictionary] = []
	adapter.leaderboard_show_finished.connect(func(id: String, ok: bool, message: String) -> void:
		results.append({"id": id, "ok": ok, "message": message})
	)
	adapter.configure(mock)
	adapter.show_leaderboard("lb.easy")
	adapter.on_application_resumed()
	_expect_equal("resume starts a new correlated authentication request", mock.calls_for("authenticate").size(), 2)
	mock.authenticated = true
	mock.push_authentication_result(1)
	adapter.poll()
	_expect_equal("new authentication opens leaderboard", mock.calls_for("show_game_center").size(), 1)
	mock.push_authentication_result(0, "error", "late old failure")
	adapter.poll()
	_expect_equal("stale authentication failure cannot finish current show", results.size(), 0)
	mock.push_show_result(0)
	adapter.poll()
	_expect_equal("current show still closes successfully", results, [{"id": "lb.easy", "ok": true, "message": ""}])


func _test_persistent_player_identity_required() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	mock.player_id_persistent = false
	var adapter: RefCounted = AdapterScript.new()
	adapter.configure(mock)
	_expect_false("temporary Game Center identity is not logged in", adapter.is_logged_in())
	_expect_equal("temporary identity is not exposed", adapter.get_player_id(), "")
	_expect_false("temporary identity score is not queued", adapter.submit_score("lb.easy", 50, "player-a"))
	_expect_equal("temporary identity never reaches native score API", mock.calls_for("post_score").size(), 0)


func _test_expected_owner_mismatch_never_posts() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	mock.game_player_id = "player-b"
	var adapter: RefCounted = AdapterScript.new()
	adapter.configure(mock)
	_expect_false("A score is rejected when current player is B", adapter.submit_score("lb.easy", 75, "player-a"))
	_expect_false("unowned score is never accepted for online submission", adapter.submit_score("lb.easy", 75, ""))
	_expect_equal("owner mismatch never reaches native score API", mock.calls_for("post_score").size(), 0)


func _test_fifo_score_submission() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	var results: Array[Dictionary] = []
	adapter.score_submit_finished.connect(func(player_id: String, id: String, score: int, ok: bool, message: String) -> void:
		results.append({"player_id": player_id, "id": id, "score": score, "ok": ok, "message": message})
	)
	adapter.configure(mock)
	_expect_true("first score accepted", adapter.submit_score("lb.easy", 100, "player-a"))
	_expect_true("second score accepted", adapter.submit_score("lb.normal", 200, "player-a"))
	_expect_equal("only one score in flight", mock.calls_for("post_score").size(), 1)
	var first_payload: Dictionary = mock.calls_for("post_score")[0]["payload"]
	_expect_equal("official dictionary category", first_payload.get("category"), "lb.easy")
	_expect_equal("official dictionary integer score", first_payload.get("score"), 100)
	_expect_equal("native payload binds expected owner", first_payload.get("expected_game_player_id"), "player-a")
	_expect_true("native payload has correlation ID", str(first_payload.get("request_id", "")) != "")
	mock.push_score_result(0)
	adapter.poll()
	_expect_equal("second score starts after first callback", mock.calls_for("post_score").size(), 2)
	_expect_equal("first normalized success", results[0], {"player_id": "player-a", "id": "lb.easy", "score": 100, "ok": true, "message": ""})
	mock.push_score_result(1)
	adapter.poll()
	_expect_equal("second normalized success", results[1], {"player_id": "player-a", "id": "lb.normal", "score": 200, "ok": true, "message": ""})


func _test_late_score_callback_correlation() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	var results: Array[Dictionary] = []
	adapter.score_submit_finished.connect(func(player_id: String, id: String, score: int, ok: bool, message: String) -> void:
		results.append({"player_id": player_id, "id": id, "score": score, "ok": ok, "message": message})
	)
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 300, "player-a")
	mock.push_event({"type": "post_score", "result": "ok", "game_player_id": "player-a", "request_id": "late:1", "category": "lb.normal", "score": 250})
	adapter.poll()
	_expect_equal("late callback keeps its own identity", results[0]["id"], "lb.normal")
	_expect_equal("late callback keeps its owner", results[0]["player_id"], "player-a")
	_expect_true("late matching metadata can complete safely", bool(results[0]["ok"]))
	_expect_equal("late callback does not consume active submission", adapter.get_queued_submission_count(), 1)
	mock.push_score_result(0)
	adapter.poll()
	_expect_equal("active callback still completes", results[1]["id"], "lb.easy")


func _test_account_switch_keeps_submission_owner() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	var results: Array[Dictionary] = []
	adapter.score_submit_finished.connect(func(player_id: String, id: String, score: int, ok: bool, _message: String) -> void:
		results.append({"player_id": player_id, "id": id, "score": score, "ok": ok})
	)
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 325, "player-a")
	mock.game_player_id = "player-b"
	adapter.on_application_resumed()
	_expect_equal("active A request remains correlated during B switch", adapter.get_queued_submission_count(), 1)
	_expect_equal("adapter exposes switched player", adapter.get_player_id(), "player-b")
	_expect_true("B score can wait behind active A request", adapter.submit_score("lb.normal", 326, "player-b"))
	mock.push_score_result(0)
	adapter.poll()
	_expect_equal("A callback reports A owner after switch", results[0]["player_id"], "player-a")
	_expect_equal("B request starts only after A callback", mock.calls_for("post_score").size(), 2)
	_expect_equal("B request binds B owner", mock.calls_for("post_score")[1]["payload"].get("expected_game_player_id"), "player-b")


func _test_old_owner_timeout_does_not_pause_new_owner() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 350, "player-a")
	mock.game_player_id = "player-b"
	adapter.on_application_resumed()
	adapter.submit_score("lb.normal", 351, "player-b")
	adapter.poll(AdapterScript.SCORE_TIMEOUT_SECONDS + 0.1)
	_expect_equal("old A timeout releases B queue", mock.calls_for("post_score").size(), 2)
	_expect_equal("B starts with its own owner after A timeout", mock.calls_for("post_score")[1]["payload"].get("expected_game_player_id"), "player-b")


func _test_immediate_post_error() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	mock.post_score_result = ERR_UNAVAILABLE
	var adapter: RefCounted = AdapterScript.new()
	var outcome := {"succeeded": true}
	adapter.score_submit_finished.connect(func(_player_id: String, _id: String, _score: int, ok: bool, _message: String) -> void: outcome["succeeded"] = ok)
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 400, "player-a")
	_expect_false("immediate native rejection emits failure", bool(outcome["succeeded"]))
	_expect_equal("rejected operation leaves no active adapter item", adapter.get_queued_submission_count(), 0)


func _test_score_timeout() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	var messages: PackedStringArray = []
	adapter.score_submit_finished.connect(func(_player_id: String, _id: String, _score: int, _ok: bool, message: String) -> void: messages.append(message))
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 500, "player-a")
	adapter.poll(AdapterScript.SCORE_TIMEOUT_SECONDS + 0.1)
	_expect_equal("score timeout emitted", messages, PackedStringArray(["timeout"]))
	_expect_equal("timed out item released but durable SaveData remains authoritative", adapter.get_queued_submission_count(), 0)


func _test_higher_score_deduplication() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 10, "player-a")
	adapter.submit_score("lb.easy", 15, "player-a")
	adapter.submit_score("lb.easy", 12, "player-a")
	_expect_equal("active plus one higher replacement", adapter.get_queued_submission_count(), 2)
	mock.push_score_result(0)
	adapter.poll()
	var calls: Array[Dictionary] = mock.calls_for("post_score")
	_expect_equal("higher queued score wins dedupe", calls[1]["payload"].get("score"), 15)


func _test_show_waits_for_score() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 600, "player-a")
	adapter.show_leaderboard("lb.easy")
	_expect_equal("overlay waits for active score", mock.calls_for("show_game_center").size(), 0)
	mock.push_score_result(0)
	adapter.poll()
	_expect_equal("overlay opens after score success", mock.calls_for("show_game_center").size(), 1)


func _test_explicit_show_prioritizes_matching_score() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	adapter.configure(mock)
	adapter.submit_score("lb.easy", 610, "player-a")
	adapter.submit_score("lb.normal", 620, "player-a")
	adapter.submit_score("lb.hard", 630, "player-a")
	adapter.show_leaderboard("lb.hard")
	mock.push_score_result(0)
	adapter.poll()
	var score_calls: Array[Dictionary] = mock.calls_for("post_score")
	_expect_equal("requested leaderboard score jumps ahead of background queue", score_calls[1]["payload"].get("category"), "lb.hard")
	mock.push_score_result(1)
	adapter.poll()
	_expect_equal("requested leaderboard opens before unrelated pending score", mock.calls_for("show_game_center").size(), 1)
	_expect_equal("unrelated score remains queued while overlay is open", adapter.get_queued_submission_count(), 1)
	mock.push_show_result(0)
	adapter.poll()
	_expect_equal("background queue resumes after leaderboard closes", mock.calls_for("post_score").size(), 3)
	_expect_equal("unrelated score resumes after overlay", mock.calls_for("post_score")[2]["payload"].get("category"), "lb.normal")


func _test_leaderboard_timeout_and_cancel() -> void:
	var mock: RefCounted = MockScript.new()
	mock.authenticated = true
	var adapter: RefCounted = AdapterScript.new()
	var results: Array[Dictionary] = []
	adapter.leaderboard_show_finished.connect(func(id: String, ok: bool, message: String) -> void:
		results.append({"id": id, "ok": ok, "message": message})
	)
	adapter.configure(mock)
	adapter.show_leaderboard("lb.easy")
	adapter.poll(AdapterScript.LEADERBOARD_TIMEOUT_SECONDS + 0.1)
	_expect_equal("leaderboard timeout releases overlay state", results, [{"id": "lb.easy", "ok": false, "message": "leaderboard_timeout"}])
	_expect_false("leaderboard request no longer pending after timeout", adapter.is_leaderboard_request_pending())
	_expect_true("leaderboard can be retried after timeout", adapter.show_leaderboard("lb.easy"))
	_expect_equal("native show retried after timeout", mock.calls_for("show_game_center").size(), 2)

	var unauthenticated_mock: RefCounted = MockScript.new()
	var cancellable_adapter: RefCounted = AdapterScript.new()
	cancellable_adapter.configure(unauthenticated_mock)
	cancellable_adapter.show_leaderboard("lb.normal")
	cancellable_adapter.cancel_pending_leaderboard()
	unauthenticated_mock.authenticated = true
	unauthenticated_mock.push_authentication_result(0)
	cancellable_adapter.poll()
	_expect_equal("scene exit cancels deferred native presentation", unauthenticated_mock.calls_for("show_game_center").size(), 0)


func _test_pending_clear_contract() -> void:
	SaveData.reset()
	var manager: Node = RankingScript.new()
	var leaderboard_id := str(RankingScript.IOS_LEADERBOARD_IDS[RankingScript.KEY_EASY])
	manager._leaderboard_id_to_stage_key[leaderboard_id] = RankingScript.KEY_EASY
	SaveData.record_ios_ranking_score("player-a", RankingScript.KEY_EASY, 700)
	SaveData.record_ios_ranking_score("player-b", RankingScript.KEY_EASY, 710)
	manager._on_ios_score_submit_finished("player-a", leaderboard_id, 700, false, "offline")
	_expect_true("failed callback retains owner pending score", SaveData.get_ios_pending_ranking_scores("player-a").has(RankingScript.KEY_EASY))
	manager._on_ios_score_submit_finished("player-a", leaderboard_id, 700, true, "")
	_expect_false("matching success clears matching owner score", SaveData.get_ios_pending_ranking_scores("player-a").has(RankingScript.KEY_EASY))
	_expect_equal("A success cannot clear B pending score", SaveData.get_ios_pending_ranking_scores("player-b").get(RankingScript.KEY_EASY), 710)
	SaveData.record_ios_ranking_score("player-a", RankingScript.KEY_EASY, 800)
	manager._on_ios_score_submit_finished("player-a", leaderboard_id, 700, true, "")
	_expect_equal("stale success cannot clear same-owner newer high score", SaveData.get_ios_pending_ranking_scores("player-a").get(RankingScript.KEY_EASY), 800)
	SaveData.record_ios_ranking_score("", RankingScript.KEY_NORMAL, 900)
	_expect_equal("unowned score stays isolated", SaveData.get_ios_unowned_ranking_scores().get(RankingScript.KEY_NORMAL), 900)
	_expect_false("unowned score is never inserted into player A bucket", SaveData.get_ios_pending_ranking_scores("player-a").has(RankingScript.KEY_NORMAL))
	manager.free()


func _expect_true(label: String, value: bool) -> void:
	_expect_equal(label, value, true)


func _expect_false(label: String, value: bool) -> void:
	_expect_equal(label, value, false)


func _expect_equal(label: String, actual: Variant, expected: Variant) -> void:
	_assertion_count += 1
	if actual != expected:
		_failures.append("FAIL: %s (actual=%s expected=%s)" % [label, str(actual), str(expected)])

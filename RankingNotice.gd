class_name RankingNotice
extends PanelContainer

const DISPLAY_SECONDS := 5.0
const MESSAGES: Dictionary = {
	"ja": {
		"login_failed": "Game Centerにサインインできませんでした。ランキングを押すと再試行できます。",
		"restricted": "この端末の設定によりGame Centerを利用できません。",
		"show_failed": "ランキング画面を開けませんでした。少し待って、もう一度お試しください。",
		"busy": "別のApple画面を処理中です。閉じてから、もう一度お試しください。",
		"score_saved": "通信できませんでした。スコアは端末に保存し、次回自動送信します。",
	},
	"en": {
		"login_failed": "Could not sign in to Game Center. Tap Ranking to try again.",
		"restricted": "Game Center is unavailable because of this device's settings.",
		"show_failed": "Could not open the leaderboard. Please wait a moment and try again.",
		"busy": "Another Apple screen is open. Close it, then try again.",
		"score_saved": "Could not connect. Your score is saved on this device and will be sent later.",
	},
	"zh_CN": {
		"login_failed": "无法登录 Game Center。再次点按排行榜即可重试。",
		"restricted": "由于此设备的设置，无法使用 Game Center。",
		"show_failed": "无法打开排行榜。请稍候再试。",
		"busy": "正在处理另一个 Apple 窗口。请关闭后重试。",
		"score_saved": "无法连接网络。分数已保存在设备上，稍后会自动发送。",
	},
	"zh_TW": {
		"login_failed": "無法登入 Game Center。再次點按排行榜即可重試。",
		"restricted": "由於此裝置的設定，無法使用 Game Center。",
		"show_failed": "無法開啟排行榜。請稍候再試。",
		"busy": "正在處理另一個 Apple 視窗。請關閉後再試。",
		"score_saved": "無法連線。分數已儲存在裝置上，稍後會自動傳送。",
	},
	"ko": {
		"login_failed": "Game Center에 로그인할 수 없습니다. 랭킹을 다시 누르면 재시도합니다.",
		"restricted": "이 기기의 설정으로 인해 Game Center를 사용할 수 없습니다.",
		"show_failed": "랭킹 화면을 열 수 없습니다. 잠시 후 다시 시도해 주세요.",
		"busy": "다른 Apple 화면을 처리 중입니다. 닫은 후 다시 시도해 주세요.",
		"score_saved": "네트워크에 연결할 수 없습니다. 점수는 기기에 저장되며 나중에 자동으로 전송됩니다.",
	},
}

var _message_label: Label
var _hide_timer: Timer


func _ready() -> void:
	name = "RankingNotice"
	set_anchors_preset(Control.PRESET_TOP_WIDE)
	offset_left = 24.0
	offset_top = 22.0
	offset_right = -24.0
	offset_bottom = 116.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 1000
	visible = false

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.04, 0.10, 0.14, 0.94)
	panel_style.border_color = Color(0.95, 0.78, 0.35, 0.92)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left = 14.0
	panel_style.content_margin_top = 9.0
	panel_style.content_margin_right = 14.0
	panel_style.content_margin_bottom = 9.0
	add_theme_stylebox_override("panel", panel_style)

	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.add_theme_font_size_override("font_size", 17)
	_message_label.add_theme_color_override("font_color", Color(1.0, 0.97, 0.86))
	_message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_message_label)

	_hide_timer = Timer.new()
	_hide_timer.one_shot = true
	_hide_timer.timeout.connect(hide_notice)
	add_child(_hide_timer)


func show_reason(reason: String) -> void:
	var message := localized_message(reason, SaveData.language_code)
	if message == "":
		return
	_message_label.text = message
	visible = true
	move_to_front()
	_hide_timer.start(DISPLAY_SECONDS)


func hide_notice() -> void:
	visible = false
	if _hide_timer != null:
		_hide_timer.stop()


static func localized_message(reason: String, locale: String) -> String:
	var normalized_locale := SaveData.normalize_language_code(locale)
	var locale_messages: Dictionary = MESSAGES.get(normalized_locale, MESSAGES["ja"])
	return str(locale_messages.get(reason, MESSAGES["ja"].get(reason, "")))

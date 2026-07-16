extends Control

const PopupSkin := preload("res://PopupSkin.gd")
const ButtonFeedback := preload("res://ButtonFeedback.gd")

const TUTORIAL_TEXT := {
	"ja": {
		"q0_intro": "麻雀は1つの「雀頭」と複数の「メンツ」を作って遊ぶゲームなのだ。",
		"q0_pair": "「雀頭」は同じ牌を2枚で完成。今回でいうと、この2枚が雀頭に当たるのだ。",
		"q0_meld": "「メンツ」は2・3・4みたいな3つの横並び、あるいは同じ牌を3枚集めると完成するのだ。",
		"q0_pick": "今回は、雀頭は既にあってメンツが1つ欠けているのだ。これに8があれば完成するから、8を押すのだ。",
		"q0_submit": "答えを選んだら、次は決定を押すのだ。",
		"q0_correct": "正解したのだ！",
		"q1_prompt": "じゃあ、次の問題で欠けてる牌を選択するのだ。",
		"q2_intro": "次の問題なのだ。",
		"q2_prompt": "今度はメンツが完成しているけど、雀頭が欠けているのだ。何が必要かを答えるのだ！",
		"submit_hint": "正解の牌を選べたのだ。\n最後に「答える」を押すのだ。",
		"select_hint": "その調子なのだ。\n光っているもうひとつの待ち牌も選ぶのだ。",
		"correct": "正解なのだ！",
		"incorrect_retry": "不正解なのだ。やり直し！",
		"incorrect": "不正解なのだ。",
		"no_meld": "それだとメンツは完成しないのだ。",
		"no_pair": "それだと雀頭が無くなってしまうのだ。",
		"partial": "それは正解の1つだけど、まだ他にも完成する牌があるのだ。正解は全て選ばなきゃクリアできないのだ。",
		"clear": "チュートリアルクリア\nおめでとうなのだ！",
	},
	"en": {
		"q0_intro": "Mahjong is a game where you make one pair and several melds.",
		"q0_pair": "A pair is complete when you have two identical tiles. In this hand, these two tiles are the pair.",
		"q0_meld": "A meld is complete with three tiles in a row, like 2-3-4, or three identical tiles.",
		"q0_pick": "This hand already has a pair, but one meld is missing a tile. An 8 completes it, so press 8.",
		"q0_submit": "After choosing your answer, press Confirm.",
		"q0_correct": "Correct!",
		"q1_prompt": "Now choose the missing tile in the next question.",
		"q2_intro": "Here is the next question.",
		"q2_prompt": "This time the melds are complete, but the pair is missing. Answer which tile is needed!",
		"submit_hint": "You selected the winning tile.\nNow press Answer.",
		"select_hint": "That's it.\nSelect the other highlighted winning tile too.",
		"correct": "Correct!",
		"incorrect_retry": "Not correct. Try again!",
		"incorrect": "Not correct.",
		"no_meld": "That does not complete a meld.",
		"no_pair": "That would leave you without a pair.",
		"partial": "That is one correct answer, but another tile also completes the hand. Select every correct tile to clear it.",
		"clear": "Tutorial Clear\nCongratulations!",
	},
	"zh_CN": {
		"q0_intro": "麻将是组成一个雀头和若干面子的游戏。",
		"q0_pair": "雀头由两张相同的牌组成。现在这两张就是雀头。",
		"q0_meld": "面子可以是像2、3、4这样的三张连续牌，也可以是三张相同的牌。",
		"q0_pick": "这次雀头已经有了，还差一张牌就能组成面子。有8就能完成，所以请按8。",
		"q0_submit": "选好答案后，按确认。",
		"q0_correct": "答对了！",
		"q1_prompt": "接下来，请选择下一题缺少的牌。",
		"q2_intro": "下一题来了。",
		"q2_prompt": "这次面子已经完成，但还缺雀头。请回答需要哪张牌！",
		"submit_hint": "你已经选中了正确的牌。\n最后按“回答”。",
		"select_hint": "就是这个感觉。\n再选择另一张亮起的听牌。",
		"correct": "答对了！",
		"incorrect_retry": "答错了。再试一次！",
		"incorrect": "答错了。",
		"no_meld": "那样不能完成面子。",
		"no_pair": "那样雀头就没有了。",
		"partial": "这是正确答案之一，但还有其他能完成的牌。必须选出全部正确答案才能过关。",
		"clear": "教程通关\n恭喜！",
	},
	"zh_TW": {
		"q0_intro": "麻將是組成一個雀頭和數個面子的遊戲。",
		"q0_pair": "雀頭由兩張相同的牌組成。現在這兩張就是雀頭。",
		"q0_meld": "面子可以是像2、3、4這樣的三張連續牌，也可以是三張相同的牌。",
		"q0_pick": "這次雀頭已經有了，還差一張牌就能組成面子。有8就能完成，所以請按8。",
		"q0_submit": "選好答案後，按確認。",
		"q0_correct": "答對了！",
		"q1_prompt": "接下來，請選擇下一題缺少的牌。",
		"q2_intro": "下一題來了。",
		"q2_prompt": "這次面子已經完成，但還缺雀頭。請回答需要哪張牌！",
		"submit_hint": "你已經選中了正確的牌。\n最後按「回答」。",
		"select_hint": "就是這個感覺。\n再選擇另一張亮起的聽牌。",
		"correct": "答對了！",
		"incorrect_retry": "答錯了。再試一次！",
		"incorrect": "答錯了。",
		"no_meld": "那樣不能完成面子。",
		"no_pair": "那樣雀頭就沒有了。",
		"partial": "這是正確答案之一，但還有其他能完成的牌。必須選出全部正確答案才能過關。",
		"clear": "教學通關\n恭喜！",
	},
	"ko": {
		"q0_intro": "마작은 하나의 머리와 여러 몸통을 만들어 가는 게임이야.",
		"q0_pair": "머리는 같은 패 2장으로 완성돼. 지금 손패에서는 이 두 장이 머리야.",
		"q0_meld": "몸통은 2, 3, 4처럼 이어지는 세 장이거나 같은 패 세 장이면 완성돼.",
		"q0_pick": "이번에는 머리는 이미 있고 몸통 하나에 패가 하나 부족해. 8이 있으면 완성되니까 8을 눌러.",
		"q0_submit": "답을 골랐으면 이제 확인을 눌러.",
		"q0_correct": "정답이야!",
		"q1_prompt": "그럼 다음 문제에서 빠진 패를 골라 봐.",
		"q2_intro": "다음 문제야.",
		"q2_prompt": "이번에는 몸통은 완성됐지만 머리가 부족해. 어떤 패가 필요한지 맞혀 봐!",
		"submit_hint": "정답 패를 골랐어.\n마지막으로 답하기를 눌러.",
		"select_hint": "좋아.\n빛나는 다른 대기패도 골라.",
		"correct": "정답이야!",
		"incorrect_retry": "오답이야. 다시 해 봐!",
		"incorrect": "오답이야.",
		"no_meld": "그걸로는 몸통이 완성되지 않아.",
		"no_pair": "그러면 머리가 없어져 버려.",
		"partial": "그건 정답 중 하나지만, 아직 완성되는 패가 더 있어. 정답을 모두 골라야 클리어할 수 있어.",
		"clear": "튜토리얼 클리어\n축하해!",
	},
}

# ============================================================
# 牌画像
# ============================================================
var tile_textures: Array = []
var tall_tile_textures: Array = []

# ============================================================
# 牌サイズ定数
# ============================================================
const TILE_W: int       = 64
const TILE_H: int       = 89
const TILE_W_MID: int   = 44
const TILE_H_MID: int   = 61
const TILE_W_SMALL: int = 33
const TILE_H_SMALL: int = 46
const TILE_W_TALL: int  = 36
const TILE_H_TALL: int  = 61

# ============================================================
# BGMリスト
# ============================================================
var bgm_list = {
	"stage1":    ["bgm_yume_jantou"],
	"stage2":    ["bgm_utu_higakureru", "bgm_utu_kotaewo", "bgm_utu_matigai"],
	"stage3":    ["bgm_mabo_first_appaku"],
	"stage4":    ["bgm_mabo_second_kougetu"],
	"ex_stage1": ["bgm_yume_barabara"],
	"ex_stage2": ["bgm_utu_nochan"],
	"ex_stage3": ["bgm_mabo_first_2tunoboketu"],
	"ex_stage4": ["bgm_mabo_second_inisie"],
}

const ENDLESS_BGM: Array = [
	"bgm_yume_main",           # 0 Easy
	"bgm_utu_higakureru",      # 1 Normal
	"bgm_mabo_first_nebumi",   # 2 Hard
	"bgm_mabo_second_kougetu", # 3 Mirage
	"bgm_yume_barabara",       # 4 Too Easy
	"bgm_utu_nochan",          # 5 Abnormal
	"bgm_mabo_second_ginniro", # 6 Very Hard
	"bgm_mabo_second_inisie",  # 7 Nightmare
	"bgm_mabo_mugen",          # 8+ Endless
]

var bgm_display_names = {
	"bgm_yume_main":               "リーチの歌",
	"bgm_yume_jantou":             "雀頭を探して",
	"bgm_yume_barabara":           "配牌がバラバラ！",
	"bgm_utu_higakureru":          "日が暮れちゃう♡",
	"bgm_utu_matigai":             "あれ、間違ってるよ♡",
	"bgm_utu_nochan":              "ノーミスでクリアして♡",
	"bgm_utu_kotaewo":             "答えを教えてあげる♡",
	"bgm_mabo_first_2tunoboketu":  "二つの墓穴",
	"bgm_mabo_first_appaku":       "圧迫問答",
	"bgm_mabo_first_nebumi":       "値踏みの視線",
	"bgm_mabo_second_kougetu":     "紅月の狼",
	"bgm_mabo_second_ginniro":     "銀色の影",
	"bgm_mabo_second_inisie":      "古の英雄",
	"bgm_mabo_mugen":              "無限の決闘",
}

var stage_display_names = {
	"tutorial":  "Tutorial",
	"stage1":    "Easy",
	"stage2":    "Normal",
	"stage3":    "Hard",
	"stage4":    "Mirage",
	"ex_stage1": "Too Easy",
	"ex_stage2": "Abnormal",
	"ex_stage3": "Very Hard",
	"ex_stage4": "Nightmare",
}

const ENDLESS_BLOCK_NAMES: Array = [
	"Easy",       # 0
	"Normal",     # 1
	"Hard",       # 2
	"Mirage",     # 3
	"Too Easy",   # 4
	"Abnormal",   # 5
	"Very Hard",  # 6
	"Nightmare",  # 7
	"Endless",    # 8+
]

const EX_STAGE_TIME_LIMIT := 30.0
const ENDLESS_FINAL_TIME_LIMIT := 20.0

const ENDLESS_TIME_LIMITS: Array = [
	0.0,   # 0 Easy
	0.0,   # 1 Normal
	0.0,   # 2 Hard
	0.0,   # 3 Mirage
	EX_STAGE_TIME_LIMIT,         # 4 Too Easy
	EX_STAGE_TIME_LIMIT,         # 5 Abnormal
	EX_STAGE_TIME_LIMIT,         # 6 Very Hard
	EX_STAGE_TIME_LIMIT,         # 7 Nightmare
	ENDLESS_FINAL_TIME_LIMIT,    # 8+ Endless
]

# ============================================================
# 顔画像パス
# ============================================================
const KAO_PYOKO_DEF    := "res://assets/kao/pyoko2_waku_def.webp"
const KAO_PYOKO_SEIKAI := [
	"res://assets/kao/pyoko2_waku_seikai1.webp",
	"res://assets/kao/pyoko2_waku_seikai2.webp",
	"res://assets/kao/pyoko2_waku_seikai3.webp",
]
const KAO_PYOKO_MAKE   := [
	"res://assets/kao/pyoko2_waku_hazure1.webp",
	"res://assets/kao/pyoko2_waku_hazure2.webp",
	"res://assets/kao/pyoko2_waku_hazure3.webp",
	"res://assets/kao/pyoko2_waku_hazure4.webp",
]

const KAO_YUME_DEF     := "res://assets/kao/yume2_waku_1.webp"
const KAO_YUME_DEF2    := "res://assets/kao/yume2_waku_2.webp"
const KAO_YUME_DEF3    := "res://assets/kao/yume2_waku_3.webp"
const KAO_YUME_KATI    := "res://assets/kao/yume2_waku_kati.webp"

const KAO_YUME_EX_DEF  := "res://assets/kao/yume2_waku_4.webp"
const KAO_YUME_EX_DEF2 := "res://assets/kao/yume2_waku_5.webp"
const KAO_YUME_EX_DEF3 := "res://assets/kao/yume2_waku_6.webp"
const KAO_YUME_EX_KATI := "res://assets/kao/yume2_waku_kati2.webp"

const KAO_UTU_DEF      := "res://assets/kao/ututu2_waku_1.webp"
const KAO_UTU_DEF2     := "res://assets/kao/ututu2_waku_2.webp"
const KAO_UTU_DEF3     := "res://assets/kao/ututu2_waku_3.webp"
const KAO_UTU_KATI     := "res://assets/kao/ututu2_waku_kati.webp"

const KAO_UTU_EX_DEF   := "res://assets/kao/ututu2_waku_4.webp"
const KAO_UTU_EX_DEF2  := "res://assets/kao/ututu2_waku_5.webp"
const KAO_UTU_EX_DEF3  := "res://assets/kao/ututu2_waku_6.webp"

const KAO_MABO_HARD_DEF     := "res://assets/kao/mabo2_waku1_1.webp"
const KAO_MABO_HARD_DEF2    := "res://assets/kao/mabo2_waku1_2.webp"
const KAO_MABO_HARD_DEF3    := "res://assets/kao/mabo2_waku1_3.webp"
const KAO_MABO_MIRAGE_DEF   := "res://assets/kao/mabo_waku1_4.webp"
const KAO_MABO_MIRAGE_DEF2  := "res://assets/kao/mabo_waku1_5.webp"
const KAO_MABO_MIRAGE_DEF3  := "res://assets/kao/mabo_waku1_6.webp"
const KAO_MABO_KATI         := "res://assets/kao/mabo2_waku1_2.webp"

const SEIKAI_FLASH_DURATION := 0.8

const BTN_HOME_X_NORMAL := 160.0
const BTN_HOME_X_CENTER := 105.0
const TOP_BAR_BUTTON_SIZE := 84.0
const TOP_BAR_MARGIN := 10.0
const TOP_BAR_GAP := 8.0
const TOP_BAR_OFFSET_Y := 20.0
const TOP_BAR_MAIN_ICON_SCALE := 0.9

# ============================================================
# アイコンパス
# ============================================================
const ICON_LAYOUT   := "res://assets/bg/icon_tile_display.webp"
const ICON_SETTINGS := "res://assets/bg/music_icon_settings_ui.webp"
const ICON_HOME     := "res://assets/bg/music_icon_home_ui.webp"
const FOUR_CHIITOI_HINT := "res://assets/ui/four_chiitoi_hint.webp"
const FOUR_CHIITOI_HINT_SIZE := Vector2(74.0, 74.0)

const GAMEOVER_IMAGE_PATH := "res://assets/bg/gameover.webp"
const STAGE_CLEAR_IMAGE_PATH := "res://assets/ui/result_header_clear_v2.webp"
const RESULT_GAMEOVER_IMAGE_PATH := "res://assets/ui/result_gameover_text_v3.webp"
const RESULT_CHARA_PYOKO2 := "res://assets/chara/pyoko2.webp"
const RESULT_CHARA_PYOKO1 := "res://assets/chara/pyoko1.webp"
const RESULT_CHARA_SEIKAI1 := "res://assets/chara/pyokoseikai1.webp"
const RESULT_CHARA_SEIKAI2 := "res://assets/chara/pyokoseikai2.webp"
const RESULT_CHARA_SEIKAI3 := "res://assets/chara/pyokoseikai3.webp"
const RESULT_GAMEOVER_CHARAS: Array[String] = [
	"res://assets/chara/pyokogameover.webp",
	"res://assets/chara/pyokogameover2.webp",
	"res://assets/chara/pyokogameover3.webp",
	"res://assets/chara/pyokogameover4.webp",
]
const SEIKAI_IMAGE_PATH := "res://assets/ui/seikai.webp"
const RESULT_PANEL_IMAGE_PATH := "res://assets/ui/result_panel_v2.webp"
const RESULT_BTN_RETRY := "res://assets/ui/result_buttons/result_btn_retry_v2.webp"
const RESULT_BTN_RETRY_PRESSED := "res://assets/ui/result_buttons/result_btn_retry_v2.webp"
const RESULT_BTN_NEXT := "res://assets/ui/result_buttons/result_btn_next_v2.webp"
const RESULT_BTN_NEXT_PRESSED := "res://assets/ui/result_buttons/result_btn_next_v2.webp"
const RESULT_BTN_HOME := "res://assets/ui/result_buttons/result_btn_home_v2.webp"
const RESULT_BTN_HOME_PRESSED := "res://assets/ui/result_buttons/result_btn_home_v2.webp"
const RESULT_BTN_RANKING := "res://assets/ui/result_buttons/result_btn_ranking_v2.webp"
const RESULT_BTN_RANKING_PRESSED := "res://assets/ui/result_buttons/result_btn_ranking_v2.webp"
const RESULT_BTN_ANSWER := "res://assets/ui/result_buttons/result_btn_answer_v2.webp"
const RESULT_BTN_ANSWER_PRESSED := "res://assets/ui/result_buttons/result_btn_answer_v2.webp"
const RESULT_BTN_BACK := "res://assets/ui/result_buttons/result_btn_back_v2.webp"
const RESULT_BTN_BACK_PRESSED := "res://assets/ui/result_buttons/result_btn_back_v2.webp"
const RESULT_PETAL_IMAGE_PATH := "res://assets/ui/result_petal.webp"
const KEYPAD_BTN_CLEAR := "res://assets/ui/keypad_buttons/keypad_btn_clear.webp"
const KEYPAD_BTN_CLEAR_PRESSED := "res://assets/ui/keypad_buttons/keypad_btn_clear_pressed.webp"
const KEYPAD_BTN_SUBMIT := "res://assets/ui/keypad_buttons/keypad_btn_submit.webp"
const KEYPAD_BTN_SUBMIT_PRESSED := "res://assets/ui/keypad_buttons/keypad_btn_submit_pressed.webp"
const KEYPAD_BTN_SUBMIT_DISABLED := "res://assets/ui/keypad_buttons/keypad_btn_submit_disabled.webp"
const KEYPAD_BTN_NONE := "res://assets/ui/keypad_buttons/keypad_btn_none.webp"
const KEYPAD_BTN_NONE_PRESSED := "res://assets/ui/keypad_buttons/keypad_btn_none_pressed.webp"
const KEYPAD_BTN_NONE_DISABLED := "res://assets/ui/keypad_buttons/keypad_btn_none_disabled.webp"
const LOCALIZED_KEYPAD_BUTTON_DIR := "res://assets/language/normalized/%s/keypad_buttons/"
const LOCALIZED_RESULT_BUTTON_DIR := "res://assets/language/normalized/%s/result_buttons/"
const LOCALIZED_RESULT_HEADER_DIR := "res://assets/language/normalized/%s/result_headers/"
const LOCALIZED_STAGE_INTRO_DIR := "res://assets/language/normalized/%s/stage_intro/"
const LOCALIZED_MISC_DIR := "res://assets/language/normalized/%s/misc/"
const CUTIN_MIRAGE_CHARA_PATH := "res://assets/chara/mabo_sikatanasi.webp"
const CUTIN_NIGHTMARE_CHARA_PATH := "res://assets/chara/mabo_yarujan.webp"
const STAGE_INTRO_DIR := "res://assets/ui/stage_intro/"
const STAGE_INTRO_DIFFICULTY_LABEL := STAGE_INTRO_DIR + "difficulty_label_jp.webp"
const STAGE_INTRO_STAR_FULL := STAGE_INTRO_DIR + "difficulty_star_full.webp"
const STAGE_INTRO_STAR_HALF := STAGE_INTRO_DIR + "difficulty_star_half.webp"
const STAGE_INTRO_STAR_EMPTY := STAGE_INTRO_DIR + "difficulty_star_empty.webp"
const STAGE_INTRO_DIFFICULTY_LOGOS := {
	"Easy": STAGE_INTRO_DIR + "difficulty_kantan_logo.webp",
	"Normal": STAGE_INTRO_DIR + "difficulty_futsuu_logo.webp",
	"Hard": STAGE_INTRO_DIR + "difficulty_muzukashii_logo.webp",
	"Mirage": STAGE_INTRO_DIR + "difficulty_mirage_logo.webp",
	"Too Easy": STAGE_INTRO_DIR + "difficulty_ex_too_easy_logo.webp",
	"Abnormal": STAGE_INTRO_DIR + "difficulty_ex_abnormal_logo.webp",
	"Very Hard": STAGE_INTRO_DIR + "difficulty_ex_very_hard_logo.webp",
	"Nightmare": STAGE_INTRO_DIR + "difficulty_ex_nightmare_logo.webp",
	"Endless": STAGE_INTRO_DIR + "difficulty_ex_endless_logo.webp",
}
const STAGE_INTRO_DIFFICULTY_STARS := {
	"Easy": 1.0,
	"Normal": 2.0,
	"Hard": 3.0,
	"Mirage": 4.0,
	"Too Easy": 2.5,
	"Abnormal": 3.5,
	"Very Hard": 3.5,
	"Nightmare": 4.5,
	"Endless": 5.0,
}
const STAGE_INTRO_LOGO_SCALES := {
	"Nightmare": 1.32,
}
const STAGE_INTRO_JACKETS := {
	"bgm_talk_tutorial": STAGE_INTRO_DIR + "jacket_bgm_talk_tutorial.webp",
	"bgm_talk_easy": STAGE_INTRO_DIR + "jacket_bgm_talk_easy.webp",
	"bgm_talk_normal": STAGE_INTRO_DIR + "jacket_bgm_talk_normal.webp",
	"bgm_talk_hard": STAGE_INTRO_DIR + "jacket_bgm_talk_hard.webp",
	"bgm_yume_main": STAGE_INTRO_DIR + "jacket_bgm_yume_reach_v8.webp",
	"bgm_yume_jantou": STAGE_INTRO_DIR + "jacket_bgm_yume_jantou_v4.webp",
	"bgm_yume_barabara": STAGE_INTRO_DIR + "jacket_bgm_yume_barabara.webp",
	"bgm_utu_higakureru": STAGE_INTRO_DIR + "jacket_bgm_utu_higakureru_v4.webp",
	"bgm_utu_matigai": STAGE_INTRO_DIR + "jacket_bgm_utu_matigai.webp",
	"bgm_utu_nochan": STAGE_INTRO_DIR + "jacket_bgm_utu_nochan_trial.webp",
	"bgm_utu_kotaewo": STAGE_INTRO_DIR + "jacket_bgm_utu_kotaewo_v3.webp",
	"bgm_mabo_first_2tunoboketu": STAGE_INTRO_DIR + "jacket_bgm_mabo_first_2tunoboketu.webp",
	"bgm_mabo_first_appaku": STAGE_INTRO_DIR + "jacket_bgm_mabo_first_appaku_no_tiles.webp",
	"bgm_mabo_first_nebumi": STAGE_INTRO_DIR + "jacket_bgm_mabo_first_nebumi.webp",
	"bgm_mabo_second_kougetu": STAGE_INTRO_DIR + "jacket_bgm_mabo_second_kougetu_v2.webp",
	"bgm_mabo_second_ginniro": STAGE_INTRO_DIR + "jacket_bgm_mabo_second_ginniro.webp",
	"bgm_mabo_second_inisie": STAGE_INTRO_DIR + "jacket_bgm_mabo_second_inisie.webp",
	"bgm_mabo_mugen": STAGE_INTRO_DIR + "jacket_bgm_mabo_mugen.webp",
}
const DIGIT_IMAGE_DIR := "res://assets/ui/"
const SCORE_DISPLAY_DIGITS := 7
const SCORE_DIGIT_HEIGHT := 45.0
const SCORE_DIGIT_SLOT_WIDTH := 38.0
const TIME_BONUS_REQUIRED_QUESTIONS := 10
const ANSWER_TOGGLE_DEBOUNCE_MS := 160
const TUTORIAL_SPOTLIGHT_PADDING := 26.0
const TUTORIAL_MESSAGE_MARGIN := 18.0
const TUTORIAL_MESSAGE_HEIGHT := 132.0
const TUTORIAL_MESSAGE_TOP := 18.0
const TUTORIAL_QUESTIONS: Array[Dictionary] = [
	{
		"hand": [2, 2, 7, 9],
		"answers": [8],
		"text": "最初の問題なのだ。\nこの4枚にくっつく待ち牌を選ぶのだ。",
	},
	{
		"hand": [1, 1, 5, 6],
		"answers": [4, 7],
		"text": "今度は待ち牌が2種類あるのだ。\n4と7を選んでから答えるのだ。",
	},
	{
		"hand": [1, 7, 8, 9],
		"answers": [1],
		"text": "次の問題なのだ。",
	},
]

# ============================================================
# ゲーム状態変数
# ============================================================
var current_bgm_filename: String = ""
var selected_tiles = []
var correct_tiles = []
var hand_size: int = 13
var total_questions: int = 10
var current_question: int = 0
var popup_state: String = ""
var is_animating: bool = false
var is_game_over: bool = false
var is_gameover_result: bool = false
var is_result_answer_view: bool = false
var _stage_intro_card: Control = null
var _last_answer_toggle_key: String = ""
var _last_answer_toggle_msec: int = -100000

var timer_enabled: bool = false
var time_left: float = 20.0
var timer_running: bool = false
var time_limit: float = 20.0

var current_hand: Array = []
var current_hand_sorted: bool = true
var current_hand_flipped: Array[bool] = []
var current_question_allows_none: bool = false
var _custom_bgm_connected: bool = false
var total_score: int = 0
var time_bonus_total: int = 0
var question_started_msec: int = 0
var last_question_score: int = 0
var answer_times: Array[float] = []
var wait_bonus_counts: Dictionary = {4: 0, 5: 0, 6: 0, 7: 0}
var score_digit_slots: Array[Control] = []
var score_digit_rects: Array[TextureRect] = []
var score_digit_values: Array[int] = []
var upside_down_tile_material: ShaderMaterial = null
var tile_shape_button: Button = null
var four_chiitoi_hint: TextureRect = null
var tutorial_layer: Control = null
var tutorial_mask: ColorRect = null
var tutorial_message_panel: Panel = null
var tutorial_message_label: Label = null
var tutorial_mask_material: ShaderMaterial = null
var tutorial_allowed_controls: Array[Control] = []
var keypad_feedback_tweens: Dictionary = {}
var tutorial_page_index: int = 0
var tutorial_feedback_text: String = ""
var tutorial_feedback_key: String = ""
var tutorial_advance_block_until_msec: int = 0

# ============================================================
# 初期化
# ============================================================
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _is_tutorial_stage():
		_layout_tutorial_layer()
		_update_tutorial_spotlight()


func _ready() -> void:
	var should_fade_stage_entry: bool = GameState.phase_entry_fade_pending
	if should_fade_stage_entry:
		GameState.phase_entry_fade_pending = false

	_load_tile_textures()

	hand_size = get_hand_size_for_stage(GameState.current_stage)
	if not _can_use_tall_tiles():
		GameState.two_row_layout = false
	total_questions = 10
	current_question = 0

	if GameState.current_stage == "custom":
		timer_enabled = SaveData.custom_timer_enabled
		time_limit = float(SaveData.custom_timer_seconds)
		if SaveData.custom_question_count == -1:
			total_questions = 999999
		else:
			total_questions = SaveData.custom_question_count
	elif GameState.current_stage == "endless":
		_apply_endless_block_settings()
	elif _is_tutorial_stage():
		total_questions = TUTORIAL_QUESTIONS.size()
		timer_enabled = false
		time_limit = 0.0
	elif GameState.current_stage.begins_with("ex_"):
		timer_enabled = true
		time_limit = EX_STAGE_TIME_LIMIT
	else:
		timer_enabled = false
		time_limit = EX_STAGE_TIME_LIMIT

	_load_stage_bg()
	_setup_face_icons()
	_setup_top_bar_icons()
	_load_persistent_score_run()
	_setup_score_display()
	if _is_tutorial_stage():
		_setup_tutorial_mode()

	play_stage_bgm()
	var starts_wolf_phase: bool = (
		GameState.current_stage == "stage4"
		or GameState.current_stage == "ex_stage4"
		or (GameState.current_stage == "endless" and GameState.endless_block in [3, 7])
	)
	if starts_wolf_phase:
		AudioManager.play_se("se_tooboe")
	if should_fade_stage_entry:
		var transition_overlay: Node = get_node_or_null("/root/TransitionOverlay")
		if transition_overlay != null:
			transition_overlay.fade_from_black(0.65)
	load_new_question()
	update_question_counter()
	update_debug_display()

	for i in range(1, 10):
		var btn = $Keypad.get_node("Btn" + str(i))
		btn.icon = tile_textures[i - 1]
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.button_down.connect(_play_tile_touch_se)
		btn.pressed.connect(_on_number_pressed.bind(i))
		ButtonFeedback.set_use_modulate(btn, false)

	_setup_keypad_action_buttons()
	ButtonFeedback.skip($Keypad/BtnNone)
	ButtonFeedback.skip($Keypad/BtnSubmit)
	$Keypad/BtnNone.button_down.connect(_play_tile_touch_se)
	$Keypad/BtnClear.button_down.connect(_play_tile_touch_se)
	$Keypad/BtnNone.button_down.connect(_on_none_button_down)
	$Keypad/BtnNone.button_up.connect(_on_none_button_up)
	$Keypad/BtnSubmit.button_down.connect(_on_submit_button_down)
	$Keypad/BtnSubmit.button_up.connect(_on_submit_button_up)
	$Keypad/BtnNone.pressed.connect(_on_none_pressed)
	$Keypad/BtnClear.pressed.connect(_on_clear_pressed)
	$Keypad/BtnSubmit.pressed.connect(_on_submit_pressed)
	$Keypad/BtnSubmit.disabled = true

	if tile_shape_button != null:
		tile_shape_button.pressed.connect(_on_btn_layout_pressed)
	$TopBar/BtnSettings.pressed.connect(_on_btn_settings_pressed)

	$HomeConfirmPopup/BtnConfirmYes.pressed.connect(_on_btn_confirm_yes_pressed)
	$HomeConfirmPopup/BtnConfirmNo.pressed.connect(_on_btn_confirm_no_pressed)

	if not $PopupResult/PopupPanel/BtnRetry.pressed.is_connected(_on_btn_retry_pressed):
		$PopupResult/PopupPanel/BtnRetry.pressed.connect(_on_btn_retry_pressed)
	if not $PopupResult/PopupPanel/BtnHome.pressed.is_connected(_on_popup_btn_home_pressed):
		$PopupResult/PopupPanel/BtnHome.pressed.connect(_on_popup_btn_home_pressed)

	$SettingsPopup/VBox/BgmSlider.value_changed.connect(_on_bgm_slider_changed)
	$SettingsPopup/VBox/SeSlider.value_changed.connect(_on_se_slider_changed)
	$SettingsPopup/VBox/BtnSettingsClose.pressed.connect(_on_btn_settings_close_pressed)
	$SettingsPopup/VBox/TileSuitGrid.disable_manzu2_when_sorted_stage = true
	$SettingsPopup/VBox/TileSuitGrid.tile_suit_changed.connect(_on_tile_suit_changed)
	_sync_tile_suit_buttons()
	$SettingsPopup.visible = false
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	PopupSkin.apply_home_confirm_popup($HomeConfirmPopup)
	_setup_home_confirm_feedback_targets()
	ButtonFeedback.install(self)

	setup_timer_display()

	$HandArea.visible = false
	await play_intro()
	if _is_tutorial_stage():
		_update_tutorial_step()
	_start_question_clock()

	if timer_enabled:
		start_timer()

func _load_tile_textures() -> void:
	tile_textures.clear()
	tall_tile_textures.clear()
	var filename_prefix: String = "a"
	var filename_suffix: String = "pinz"
	match SaveData.tile_suit:
		"souzu":
			filename_prefix = "so"
			filename_suffix = ""
		"manzu", "manzu2":
			filename_prefix = "man"
			filename_suffix = ""
	for number in range(1, 10):
		var path: String = "res://assets/tiles/" + filename_prefix + str(number) + filename_suffix + ".webp"
		var texture: Texture2D = load(path) as Texture2D
		tile_textures.append(texture)
		var tall_path: String = "res://assets/tiles_rich_tatenaga/" + filename_prefix + str(number) + filename_suffix + ".webp"
		var tall_texture: Texture2D = load(tall_path) as Texture2D
		tall_tile_textures.append(tall_texture if tall_texture != null else texture)

func _update_tile_button_icons() -> void:
	for number in range(1, 10):
		var button: Button = $Keypad.get_node("Btn" + str(number))
		button.icon = tile_textures[number - 1]

func _sync_tile_suit_buttons() -> void:
	$SettingsPopup/VBox/TileSuitGrid.sync_selection()

func _on_tile_suit_changed(tile_suit: String) -> void:
	SaveData.tile_suit = tile_suit
	_load_tile_textures()
	_update_tile_button_icons()
	_randomize_hand_flips()
	if not current_hand.is_empty():
		display_hand(current_hand)
	AudioManager.play_se("se_btntap")

# ============================================================
# TopBarアイコン設定
# ============================================================
func _setup_top_bar_icons() -> void:
	var top_bar: HBoxContainer = $TopBar
	var btn_layout: Button = $TopBar/BtnLayout
	var btn_settings: Button = $TopBar/BtnSettings
	var btn_home: Button = $TopBar/BtnHome
	tile_shape_button = btn_layout

	btn_layout.text = ""
	btn_settings.text = ""
	btn_home.text = ""
	btn_layout.flat = true
	btn_settings.flat = true
	btn_home.flat = true
	btn_layout.visible = _can_use_tall_tiles()

	if ResourceLoader.exists(ICON_LAYOUT):
		btn_layout.icon = load(ICON_LAYOUT)
	if ResourceLoader.exists(ICON_SETTINGS):
		btn_settings.icon = _load_top_bar_scaled_icon(ICON_SETTINGS)
	if ResourceLoader.exists(ICON_HOME):
		btn_home.icon = _load_top_bar_scaled_icon(ICON_HOME)

	btn_layout.expand_icon   = true
	btn_settings.expand_icon = false
	btn_home.expand_icon     = false

	for btn in [btn_layout, btn_settings, btn_home]:
		btn.custom_minimum_size = Vector2(TOP_BAR_BUTTON_SIZE, TOP_BAR_BUTTON_SIZE)

	if btn_layout.get_parent() == top_bar:
		btn_layout.reparent(self)
		btn_layout.set_anchors_preset(Control.PRESET_TOP_LEFT)
		btn_layout.size = Vector2(58.0, 58.0)
		btn_layout.custom_minimum_size = btn_layout.size
		btn_layout.position = Vector2(get_viewport_rect().size.x - 68.0, 68.0)
		btn_layout.move_to_front()
		_setup_four_chiitoi_hint()
	_update_tile_shape_button_state()

	if btn_home.get_parent() == top_bar and btn_settings.get_parent() == top_bar:
		top_bar.move_child(btn_home, 0)
		top_bar.move_child(btn_settings, 1)

	top_bar.add_theme_constant_override("separation", int(TOP_BAR_GAP))
	var visible_count: int = 2
	var bar_w: float = TOP_BAR_BUTTON_SIZE * visible_count + TOP_BAR_GAP * (visible_count - 1)
	var vp: Vector2 = get_viewport_rect().size
	top_bar.position = Vector2(vp.x - bar_w - TOP_BAR_MARGIN, vp.y - TOP_BAR_BUTTON_SIZE - TOP_BAR_MARGIN + TOP_BAR_OFFSET_Y)
	top_bar.size = Vector2(bar_w, TOP_BAR_BUTTON_SIZE)

func _load_top_bar_scaled_icon(path: String) -> Texture2D:
	var texture := load(path) as Texture2D
	if texture == null:
		return null
	var image := texture.get_image()
	if image == null:
		return texture
	var bottom_overflow := maxf(0.0, TOP_BAR_OFFSET_Y - TOP_BAR_MARGIN)
	var visible_button_size := TOP_BAR_BUTTON_SIZE - bottom_overflow
	var icon_size := maxi(1, roundi(visible_button_size * TOP_BAR_MAIN_ICON_SCALE))
	image.resize(icon_size, icon_size, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)

func _can_use_tall_tiles() -> bool:
	if hand_size != 13:
		return false
	if GameState.current_stage == "endless":
		return GameState.endless_block in [2, 3, 6, 7] or GameState.endless_block >= 8
	if GameState.current_stage == "custom":
		return SaveData.custom_difficulty in ["stage3", "stage4"]
	return GameState.current_stage in ["stage3", "stage4", "ex_stage3", "ex_stage4"]

func _uses_tall_tile_hand() -> bool:
	return _can_use_tall_tiles() and GameState.two_row_layout

func _update_tile_shape_button_state() -> void:
	if tile_shape_button == null:
		return
	tile_shape_button.visible = _can_use_tall_tiles()
	tile_shape_button.modulate = Color(1.4, 1.22, 0.62, 1.0) if _uses_tall_tile_hand() else Color(1.0, 1.0, 1.0, 1.0)
	if four_chiitoi_hint != null:
		four_chiitoi_hint.visible = _can_use_tall_tiles()
		_position_four_chiitoi_hint()

func _setup_four_chiitoi_hint() -> void:
	if four_chiitoi_hint != null:
		return
	four_chiitoi_hint = TextureRect.new()
	four_chiitoi_hint.name = "FourChiitoiHint"
	four_chiitoi_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	four_chiitoi_hint.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	four_chiitoi_hint.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	four_chiitoi_hint.size = FOUR_CHIITOI_HINT_SIZE
	four_chiitoi_hint.custom_minimum_size = four_chiitoi_hint.size
	var hint_path := _localized_misc_path("four_chiitoi_hint.webp", FOUR_CHIITOI_HINT)
	if ResourceLoader.exists(hint_path):
		four_chiitoi_hint.texture = load(hint_path)
	add_child(four_chiitoi_hint)
	four_chiitoi_hint.move_to_front()
	_position_four_chiitoi_hint()

func _position_four_chiitoi_hint() -> void:
	if four_chiitoi_hint == null or tile_shape_button == null:
		return
	four_chiitoi_hint.position = Vector2(
		tile_shape_button.position.x - four_chiitoi_hint.size.x - 8.0,
		tile_shape_button.position.y - (four_chiitoi_hint.size.y - tile_shape_button.size.y) * 0.5
	)

# ============================================================
# endlessブロック設定適用
# ============================================================
func _apply_endless_block_settings() -> void:
	var block := GameState.endless_block
	var idx: int = min(block, ENDLESS_TIME_LIMITS.size() - 1)
	var t: float = ENDLESS_TIME_LIMITS[idx] as float
	if t > 0.0:
		timer_enabled = true
		time_limit = t
	else:
		timer_enabled = false
		time_limit = 0.0

# ============================================================
# ゲームオーバー表示リセット
# ============================================================
func _is_tutorial_stage() -> bool:
	return GameState.current_stage == "tutorial"


func _setup_tutorial_mode() -> void:
	$FaceBoss.visible = false
	$FaceMain.visible = true
	if has_node("ScoreDisplay"):
		$ScoreDisplay.visible = false
	if tile_shape_button != null:
		tile_shape_button.visible = false
	if four_chiitoi_hint != null:
		four_chiitoi_hint.visible = false
	_setup_tutorial_layer()


func _setup_tutorial_layer() -> void:
	if tutorial_layer != null:
		return
	tutorial_layer = Control.new()
	tutorial_layer.name = "TutorialGuideLayer"
	tutorial_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tutorial_layer)

	tutorial_mask = ColorRect.new()
	tutorial_mask.name = "Mask"
	tutorial_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_mask_material = _make_tutorial_mask_material()
	tutorial_mask.material = tutorial_mask_material
	tutorial_layer.add_child(tutorial_mask)

	tutorial_message_panel = Panel.new()
	tutorial_message_panel.name = "MessagePanel"
	tutorial_message_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.05, 0.08, 0.93)
	panel_style.border_color = Color(1.0, 0.78, 0.34, 0.92)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	tutorial_message_panel.add_theme_stylebox_override("panel", panel_style)
	tutorial_layer.add_child(tutorial_message_panel)

	tutorial_message_label = Label.new()
	tutorial_message_label.name = "Message"
	tutorial_message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_message_label.add_theme_font_size_override("font_size", 24)
	tutorial_message_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82))
	tutorial_message_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	tutorial_message_label.add_theme_constant_override("outline_size", 4)
	var font := load("res://assets/font/font_1_kokumr_1.00_rls.ttf") as Font
	if font != null:
		tutorial_message_label.add_theme_font_override("font", font)
	tutorial_message_panel.add_child(tutorial_message_label)

	_layout_tutorial_layer()
	tutorial_layer.move_to_front()


func _make_tutorial_mask_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec2 viewport_size = vec2(480.0, 854.0);
uniform vec2 spotlight_center = vec2(-1000.0, -1000.0);
uniform float spotlight_radius = 0.0;
uniform float feather = 12.0;
uniform vec4 mask_color : source_color = vec4(0.0, 0.0, 0.0, 0.68);

void fragment() {
	vec2 pixel = SCREEN_UV * viewport_size;
	float dist_to_center = distance(pixel, spotlight_center);
	float outside = smoothstep(spotlight_radius - feather, spotlight_radius + feather, dist_to_center);
	COLOR = vec4(mask_color.rgb, mask_color.a * outside);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _layout_tutorial_layer() -> void:
	if tutorial_layer == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	tutorial_layer.position = Vector2.ZERO
	tutorial_layer.size = vp
	if tutorial_mask != null:
		tutorial_mask.position = Vector2.ZERO
		tutorial_mask.size = vp
	if tutorial_mask_material != null:
		tutorial_mask_material.set_shader_parameter("viewport_size", vp)
	if tutorial_message_panel != null:
		tutorial_message_panel.position = Vector2(TUTORIAL_MESSAGE_MARGIN, TUTORIAL_MESSAGE_TOP)
		tutorial_message_panel.size = Vector2(vp.x - TUTORIAL_MESSAGE_MARGIN * 2.0, TUTORIAL_MESSAGE_HEIGHT)
	if tutorial_message_label != null and tutorial_message_panel != null:
		tutorial_message_label.position = Vector2(18.0, 10.0)
		tutorial_message_label.size = tutorial_message_panel.size - Vector2(36.0, 20.0)


func _load_tutorial_question() -> void:
	var question: Dictionary = TUTORIAL_QUESTIONS[current_question]
	current_hand = (question.get("hand", []) as Array).duplicate()
	correct_tiles = (question.get("answers", []) as Array).duplicate()
	correct_tiles.sort()
	current_hand_sorted = true
	current_question_allows_none = false
	current_hand_flipped.clear()
	for _tile in current_hand:
		current_hand_flipped.append(false)
	selected_tiles = []
	tutorial_page_index = 0
	_clear_tutorial_feedback()
	display_hand(current_hand)
	update_ui()
	update_debug_display()
	_update_tutorial_step()


func _update_tutorial_step() -> void:
	if not _is_tutorial_stage() or current_question >= TUTORIAL_QUESTIONS.size() or tutorial_layer == null:
		return
	tutorial_message_label.text = _get_tutorial_message_text()
	_apply_tutorial_input_gate(_get_tutorial_target_control())
	_update_tutorial_spotlight()


func _tutorial_text(key: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var dict: Dictionary = TUTORIAL_TEXT.get(locale, TUTORIAL_TEXT["ja"])
	return str(dict.get(key, TUTORIAL_TEXT["ja"].get(key, "")))


func _set_tutorial_feedback(key: String) -> void:
	tutorial_feedback_key = key
	tutorial_feedback_text = _tutorial_text(key)


func _clear_tutorial_feedback() -> void:
	tutorial_feedback_key = ""
	tutorial_feedback_text = ""


func _get_localized_tutorial_message_text() -> String:
	if current_question == 0:
		match tutorial_page_index:
			0:
				return _tutorial_text("q0_intro")
			1:
				return _tutorial_text("q0_pair")
			2:
				return _tutorial_text("q0_meld")
			3:
				return _tutorial_text("q0_pick")
			4:
				return _tutorial_text("q0_submit")
			5:
				return _tutorial_text("q0_correct")
	if current_question == 1:
		return _tutorial_text("q1_prompt")
	if current_question == 2:
		if tutorial_page_index == 0:
			return _tutorial_text("q2_intro")
		return _tutorial_text("q2_prompt")
	var target := _get_tutorial_target_control()
	if target == $Keypad/BtnSubmit:
		return _tutorial_text("submit_hint")
	if not selected_tiles.is_empty():
		return _tutorial_text("select_hint")
	var question: Dictionary = TUTORIAL_QUESTIONS[current_question]
	return str(question.get("text", ""))


func _get_tutorial_message_text() -> String:
	if tutorial_feedback_key != "":
		return _tutorial_text(tutorial_feedback_key)
	if tutorial_feedback_text != "":
		return tutorial_feedback_text
	return _get_localized_tutorial_message_text()
	if current_question == 0:
		match tutorial_page_index:
			0:
				return "麻雀は１つの『雀頭』と複数の『メンツ』を作って遊ぶゲームなのだ。"
			1:
				return "『雀頭』は同じ牌を２枚で完成。今回でいうとこの２２が雀頭に当たるのだ。"
			2:
				return "『メンツ』は１２３や７８９みたいな３つの横並び、あるいは同じ牌を３枚集めると完成するのだ。"
			3:
				return "今回、雀頭は既にあってメンツが１つ欠けているのだ。これは８があれば完成するから、８を押すのだ。"
			4:
				return "答えを選んだら、次は決定を押すのだ。"
			5:
				return "正解したのだ！"
	if current_question == 1:
		return "じゃぁ、次の問題で欠けてる牌を選択するのだ。"
	if current_question == 2:
		match tutorial_page_index:
			0:
				return "次の問題なのだ。"
			_:
				return "今度はメンツが完成しているけど、雀頭が欠けているのだ。何が必要かを答えるのだ！"
	var question: Dictionary = TUTORIAL_QUESTIONS[current_question]
	var text: String = str(question.get("text", ""))
	var target := _get_tutorial_target_control()
	if target == $Keypad/BtnSubmit:
		text = "正解の牌を選べたのだ。\n最後に「答える」を押すのだ。"
	elif not selected_tiles.is_empty():
		text = "その調子なのだ。\n光っているもうひとつの待ち牌も選ぶのだ。"
	return text


func _get_tutorial_target_control() -> Control:
	if current_question >= TUTORIAL_QUESTIONS.size():
		return null
	if current_question == 0:
		if tutorial_page_index == 3:
			return $Keypad/Btn8
		if tutorial_page_index == 4:
			return $Keypad/BtnSubmit
		return null
	if current_question == 1:
		return null
	if current_question == 2:
		return null
	var answers: Array = (TUTORIAL_QUESTIONS[current_question].get("answers", []) as Array).duplicate()
	answers.sort()
	for tile in answers:
		if not (tile in selected_tiles):
			return $Keypad.get_node("Btn" + str(tile)) as Control
	return $Keypad/BtnSubmit


func _apply_tutorial_input_gate(target: Control) -> void:
	tutorial_allowed_controls.clear()
	if target != null:
		tutorial_allowed_controls.append(target)
	if target == null and _tutorial_allows_free_selection():
		$Keypad/BtnNone.disabled = true
		$Keypad/BtnClear.disabled = selected_tiles.is_empty()
		$Keypad/BtnSubmit.disabled = selected_tiles.is_empty()
		var has_none: bool = not selected_tiles.is_empty() and selected_tiles[0] == -1
		for i in range(1, 10):
			var free_btn: Button = $Keypad.get_node("Btn" + str(i))
			free_btn.disabled = has_none
		return
	for i in range(1, 10):
		var btn: Button = $Keypad.get_node("Btn" + str(i))
		btn.disabled = btn != target
	$Keypad/BtnNone.disabled = true
	$Keypad/BtnClear.disabled = true
	$Keypad/BtnSubmit.disabled = $Keypad/BtnSubmit != target
	if tile_shape_button != null:
		tile_shape_button.disabled = true


func _update_tutorial_spotlight() -> void:
	if tutorial_mask_material == null:
		return
	var target := _get_tutorial_target_control()
	if tutorial_mask != null:
		tutorial_mask.visible = _should_show_tutorial_mask(target)
	var spotlight_rect := _get_tutorial_spotlight_rect(target)
	if spotlight_rect.size == Vector2.ZERO:
		tutorial_mask_material.set_shader_parameter("spotlight_center", Vector2(-1000.0, -1000.0))
		tutorial_mask_material.set_shader_parameter("spotlight_radius", 0.0)
		return
	var center := spotlight_rect.get_center()
	var radius := maxf(spotlight_rect.size.x, spotlight_rect.size.y) * 0.5 + TUTORIAL_SPOTLIGHT_PADDING
	tutorial_mask_material.set_shader_parameter("spotlight_center", center)
	tutorial_mask_material.set_shader_parameter("spotlight_radius", radius)


func _should_show_tutorial_mask(target: Control) -> bool:
	if current_question == 0 and tutorial_page_index == 1:
		return true
	return target != null


func _get_tutorial_spotlight_rect(target: Control) -> Rect2:
	if current_question == 0 and tutorial_page_index == 1:
		return _get_hand_tiles_rect([0, 1])
	if target == null:
		return Rect2()
	return Rect2(target.global_position, target.size)


func _get_hand_tiles_rect(indices: Array[int]) -> Rect2:
	var row := $HandArea/TileBoxRow1
	var result := Rect2()
	var has_rect := false
	for index in indices:
		if index < 0 or index >= row.get_child_count():
			continue
		var child := row.get_child(index) as Control
		if child == null:
			continue
		var child_rect := Rect2(child.global_position, child.size)
		if has_rect:
			result = result.merge(child_rect)
		else:
			result = child_rect
			has_rect = true
	return result if has_rect else Rect2()


func _tutorial_allows_free_selection() -> bool:
	return current_question == 1 or (current_question == 2 and tutorial_page_index >= 1)


func _can_press_tutorial_number(number: int) -> bool:
	if _tutorial_allows_free_selection():
		return true
	var target := _get_tutorial_target_control()
	return target == $Keypad.get_node("Btn" + str(number))


func _handle_tutorial_advance_input(event: InputEvent) -> bool:
	var should_advance := _is_tutorial_advance_event(event)
	if not should_advance:
		return false
	if is_animating or Time.get_ticks_msec() < tutorial_advance_block_until_msec:
		get_viewport().set_input_as_handled()
		return true
	if not _tutorial_waits_for_page_advance():
		return false
	get_viewport().set_input_as_handled()
	_advance_tutorial_page()
	return true


func _is_tutorial_advance_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true
	if event is InputEventScreenTouch and event.pressed:
		return true
	return event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]


func _block_tutorial_advance_input(duration_msec: int = 180) -> void:
	tutorial_advance_block_until_msec = max(tutorial_advance_block_until_msec, Time.get_ticks_msec() + duration_msec)


func _tutorial_waits_for_page_advance() -> bool:
	if not _is_tutorial_stage() or tutorial_layer == null:
		return false
	if current_question == 0:
		return tutorial_page_index in [0, 1, 2, 5]
	if current_question == 1:
		return tutorial_feedback_key == "correct" or tutorial_feedback_text == _tutorial_text("correct")
	if current_question == 2:
		return tutorial_page_index == 0
	return false


func _advance_tutorial_page() -> void:
	if current_question == 0:
		if tutorial_page_index < 5:
			tutorial_page_index += 1
			_update_tutorial_step()
			return
		_start_next_tutorial_question()
	elif current_question == 1 and (tutorial_feedback_key == "correct" or tutorial_feedback_text == _tutorial_text("correct")):
		_start_next_tutorial_question()
	elif current_question == 2 and tutorial_page_index == 0:
		tutorial_page_index = 1
		_update_tutorial_step()


func _start_next_tutorial_question() -> void:
	is_animating = true
	await slide_hand_out()
	current_question += 1
	if current_question >= total_questions:
		_finish_tutorial_mode()
		SaveData.record_clear("tutorial")
		_show_clear_result(_tutorial_text("clear"))
		is_animating = false
		return
	load_new_question()
	update_question_counter()
	await slide_hand_in()
	_update_tutorial_step()
	_start_question_clock()
	is_animating = false


func _on_tutorial_submit_pressed() -> void:
	if current_question == 0:
		if tutorial_page_index != 4 or selected_tiles != [8]:
			return
		AudioManager.play_se("se_seikai")
		tutorial_page_index = 5
		selected_tiles = []
		update_ui()
		_update_tutorial_step()
		_block_tutorial_advance_input()
		return
	if current_question == 1:
		_handle_tutorial_second_submit()
		return
	if current_question == 2:
		_handle_tutorial_third_submit()
		return
	var target := _get_tutorial_target_control()
	if target != $Keypad/BtnSubmit:
		return
	AudioManager.play_se("se_btntap")
	var sorted_selected := selected_tiles.duplicate()
	sorted_selected.sort()
	if sorted_selected == correct_tiles:
		_add_score_for_current_answer()
		current_question += 1
		_handle_correct_progress()
	else:
		_set_tutorial_feedback("incorrect_retry")
		selected_tiles = []
		update_ui()
		_update_tutorial_step()


func _handle_tutorial_second_submit() -> void:
	if selected_tiles.is_empty():
		return
	var sorted_selected := selected_tiles.duplicate()
	sorted_selected.sort()
	if sorted_selected == [4, 7]:
		AudioManager.play_se("se_seikai")
		_set_tutorial_feedback("correct")
		selected_tiles = []
		update_ui()
		_update_tutorial_step()
		_block_tutorial_advance_input()
		return
	if sorted_selected.size() == 1:
		var tile: int = int(sorted_selected[0])
		if tile in [2, 3, 5, 6, 8, 9]:
			_set_tutorial_feedback("no_meld")
		elif tile == 1:
			_set_tutorial_feedback("no_pair")
		elif tile in [4, 7]:
			_set_tutorial_feedback("partial")
		else:
			_set_tutorial_feedback("incorrect_retry")
	else:
		_set_tutorial_feedback("incorrect_retry")
	selected_tiles = []
	update_ui()
	_update_tutorial_step()


func _handle_tutorial_third_submit() -> void:
	if selected_tiles.is_empty():
		return
	var sorted_selected := selected_tiles.duplicate()
	sorted_selected.sort()
	if sorted_selected == [1]:
		AudioManager.play_se("se_seikai")
		_finish_tutorial_mode()
		SaveData.record_clear("tutorial")
		_show_clear_result(_tutorial_text("clear"))
		return
	_set_tutorial_feedback("incorrect")
	selected_tiles = []
	update_ui()
	_update_tutorial_step()


func _finish_tutorial_mode() -> void:
	if tutorial_layer != null:
		tutorial_layer.visible = false
	$TopBar/BtnSettings.disabled = false
	$TopBar/BtnHome.disabled = false


func _reset_gameover_display() -> void:
	is_result_answer_view = false
	$PopupResult/PopupPanel.visible = true
	if has_node("PopupResult/ResultButtons/BtnRetry"):
		$PopupResult/ResultButtons/BtnRetry.reparent($PopupResult/PopupPanel)
	if has_node("PopupResult/ResultButtons/BtnHome"):
		$PopupResult/ResultButtons/BtnHome.reparent($PopupResult/PopupPanel)
	if has_node("PopupResult/ResultButtons/BtnShowAnswer"):
		$PopupResult/ResultButtons/BtnShowAnswer.visible = false
	if has_node("PopupResult/BtnBackToResult"):
		$PopupResult/BtnBackToResult.visible = false
	var img: TextureRect = $PopupResult/PopupPanel/GameOverImage
	img.visible = false
	img.position = Vector2(0.0, 8.0)
	img.rotation_degrees = 0.0
	$PopupResult/PopupPanel/CorrectNoneLabel.visible = false
	$PopupResult/PopupPanel/CorrectTilesRow1.visible = false
	$PopupResult/PopupPanel/CorrectTilesRow2.visible = false
	for child in $PopupResult/PopupPanel/CorrectTilesRow1.get_children():
		child.queue_free()
	for child in $PopupResult/PopupPanel/CorrectTilesRow2.get_children():
		child.queue_free()
	if has_node("PopupResult/StageClearImage"):
		$PopupResult/StageClearImage.visible = false
	if has_node("PopupResult/ResultChara"):
		$PopupResult/ResultChara.visible = false
	if has_node("PopupResult/ResultMask"):
		$PopupResult/ResultMask.visible = false
	if has_node("PopupResult/ResultPanel"):
		$PopupResult/ResultPanel.visible = false
	if has_node("PopupResult/CorrectImage"):
		$PopupResult/CorrectImage.visible = false
	if has_node("PopupResult/CorrectScore"):
		$PopupResult/CorrectScore.visible = false
		$PopupResult/CorrectScore.modulate = Color(1, 1, 1, 1)
		_clear_digit_row($PopupResult/CorrectScore)
	if has_node("PopupResult/ResultPanel/ResultScores"):
		$PopupResult/ResultPanel/ResultScores.visible = false
		for child in $PopupResult/ResultPanel/ResultScores.get_children():
			child.queue_free()
	if has_node("PopupResult/ResultButtons"):
		$PopupResult/ResultButtons.visible = false
	_stop_result_sakura_fx()

func _clear_digit_row(row: Control) -> void:
	for child in row.get_children():
		child.queue_free()

func _add_number_images(row: Control, value: int, digit_h: float = 40.0, prefix: String = "", leading_symbol: String = "") -> void:
	_clear_digit_row(row)
	if row is HBoxContainer:
		var digit_row: HBoxContainer = row as HBoxContainer
		digit_row.add_theme_constant_override("separation", -1)
	var text: String = leading_symbol + str(maxi(0, value))
	for i in range(text.length()):
		var ch: String = text.substr(i, 1)
		var path: String = DIGIT_IMAGE_DIR + prefix + ch + ".webp"
		if not ResourceLoader.exists(path):
			continue
		var rect: TextureRect = TextureRect.new()
		var texture: Texture2D = load(path) as Texture2D
		if texture == null:
			continue
		var texture_h: float = float(texture.get_height())
		if texture_h <= 0.0:
			texture_h = 1.0
		var digit_w: float = digit_h * float(texture.get_width()) / texture_h
		rect.texture = texture
		rect.custom_minimum_size = Vector2(digit_w, digit_h)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(rect)

func _score_text(value: int) -> String:
	var clamped_value: int = clampi(value, 0, 9999999)
	var score_text: String = str(clamped_value)
	while score_text.length() < SCORE_DISPLAY_DIGITS:
		score_text = "0" + score_text
	return score_text

func _uses_persistent_score_run() -> bool:
	return (
		GameState.current_stage == "endless"
		or GameState.is_instant_mode
		or GameState.current_stage in ["stage3", "stage4", "ex_stage3", "ex_stage4"]
	)

func _load_persistent_score_run() -> void:
	if not _uses_persistent_score_run():
		return
	total_score = GameState.run_total_score
	time_bonus_total = GameState.run_time_bonus_total
	answer_times.clear()
	answer_times.assign(GameState.run_answer_times)
	wait_bonus_counts = GameState.run_wait_bonus_counts.duplicate()

func _sync_persistent_score_run() -> void:
	if not _uses_persistent_score_run():
		return
	GameState.run_total_score = total_score
	GameState.run_time_bonus_total = time_bonus_total
	GameState.run_answer_times.clear()
	GameState.run_answer_times.assign(answer_times)
	GameState.run_wait_bonus_counts = wait_bonus_counts.duplicate()

func _create_score_digit_rect(digit: int) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	var path: String = DIGIT_IMAGE_DIR + "score_" + str(digit) + ".webp"
	if ResourceLoader.exists(path):
		var texture: Texture2D = load(path) as Texture2D
		if texture != null:
			var texture_h: float = float(texture.get_height())
			if texture_h <= 0.0:
				texture_h = 1.0
			var digit_w: float = SCORE_DIGIT_HEIGHT * float(texture.get_width()) / texture_h
			rect.texture = texture
			rect.size = Vector2(digit_w, SCORE_DIGIT_HEIGHT)
			rect.custom_minimum_size = Vector2(digit_w, SCORE_DIGIT_HEIGHT)
			rect.position = Vector2((SCORE_DIGIT_SLOT_WIDTH - digit_w) * 0.5, 0.0)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _setup_score_display() -> void:
	score_digit_slots.clear()
	score_digit_rects.clear()
	score_digit_values.clear()
	if not has_node("ScoreDisplay"):
		return
	var display: HBoxContainer = $ScoreDisplay
	display.move_to_front()
	display.size = Vector2(SCORE_DIGIT_SLOT_WIDTH * SCORE_DISPLAY_DIGITS, SCORE_DIGIT_HEIGHT)
	display.custom_minimum_size = display.size
	display.position.x = get_viewport_rect().size.x - display.size.x - 10.0
	for child in display.get_children():
		child.queue_free()
	display.add_theme_constant_override("separation", 0)
	for i in range(SCORE_DISPLAY_DIGITS):
		var slot: Control = Control.new()
		slot.custom_minimum_size = Vector2(SCORE_DIGIT_SLOT_WIDTH, SCORE_DIGIT_HEIGHT)
		slot.size = Vector2(SCORE_DIGIT_SLOT_WIDTH, SCORE_DIGIT_HEIGHT)
		slot.clip_contents = true
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		display.add_child(slot)
		var rect: TextureRect = _create_score_digit_rect(0)
		slot.add_child(rect)
		score_digit_slots.append(slot)
		score_digit_rects.append(rect)
		score_digit_values.append(0)
	_update_score_display(false)

func _set_score_digit(index: int, digit: int) -> void:
	if index < 0 or index >= score_digit_slots.size():
		return
	var slot: Control = score_digit_slots[index]
	for child in slot.get_children():
		child.queue_free()
	var rect: TextureRect = _create_score_digit_rect(digit)
	slot.add_child(rect)
	score_digit_rects[index] = rect
	score_digit_values[index] = digit

func _animate_score_digit(index: int, digit: int) -> void:
	if index < 0 or index >= score_digit_slots.size():
		return
	var slot: Control = score_digit_slots[index]
	var old_rect: TextureRect = score_digit_rects[index]
	var new_rect: TextureRect = _create_score_digit_rect(digit)
	new_rect.position.y = -SCORE_DIGIT_HEIGHT
	new_rect.modulate.a = 0.0
	slot.add_child(new_rect)
	score_digit_rects[index] = new_rect
	score_digit_values[index] = digit

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	if is_instance_valid(old_rect):
		tween.tween_property(old_rect, "position:y", SCORE_DIGIT_HEIGHT, 0.22)
		tween.tween_property(old_rect, "modulate:a", 0.0, 0.22)
	tween.tween_property(new_rect, "position:y", 0.0, 0.22)
	tween.tween_property(new_rect, "modulate:a", 1.0, 0.22)
	await tween.finished
	if is_instance_valid(old_rect):
		old_rect.queue_free()

func _update_score_display(animated: bool = true) -> void:
	if score_digit_slots.size() != SCORE_DISPLAY_DIGITS:
		return
	var score_text: String = _score_text(total_score)
	for i in range(SCORE_DISPLAY_DIGITS):
		var digit: int = int(score_text.substr(i, 1))
		if not animated or score_digit_values[i] == digit:
			if not animated:
				_set_score_digit(i, digit)
			continue
		_animate_score_digit(i, digit)

func _make_score_number_row(value: int, digit_h: float = 38.0) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.custom_minimum_size = Vector2(164.0, digit_h + 4.0)
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", -1)
	_add_number_images(row, value, digit_h, "w")
	return row

func _make_score_group(label_text: String, value: int) -> VBoxContainer:
	var group: VBoxContainer = VBoxContainer.new()
	group.custom_minimum_size = Vector2(164.0, 64.0)
	group.add_theme_constant_override("separation", 0)

	var label: Label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(150.0, 24.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.56))
	label.add_theme_color_override("font_outline_color", Color(0.10, 0.02, 0.02, 0.96))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	var label_margin: MarginContainer = MarginContainer.new()
	label_margin.custom_minimum_size = Vector2(164.0, 24.0)
	label_margin.add_theme_constant_override("margin_left", 4)
	label_margin.add_child(label)
	group.add_child(label_margin)
	group.add_child(_make_score_number_row(value, 30.0))
	return group

func _get_result_chara_path(score: int) -> String:
	if score < 10000:
		return RESULT_CHARA_PYOKO2
	elif score < 15000:
		return RESULT_CHARA_PYOKO1
	elif score < 20000:
		return RESULT_CHARA_SEIKAI3
	elif score < 30000:
		return RESULT_CHARA_SEIKAI1
	else:
		return RESULT_CHARA_SEIKAI2

func _get_gameover_result_chara_path() -> String:
	var available_paths: Array[String] = []
	for path in RESULT_GAMEOVER_CHARAS:
		if ResourceLoader.exists(path):
			available_paths.append(path)
	if available_paths.is_empty():
		return RESULT_CHARA_PYOKO2
	return available_paths[randi() % available_paths.size()]

func _get_final_score() -> int:
	return total_score + _get_time_bonus() + _get_wait_bonus_total()

func _get_high_score_key() -> String:
	if GameState.is_instant_mode or GameState.current_stage == "endless":
		return "endless"
	return GameState.current_stage

func _get_ranking_stage_key() -> String:
	return RankingManager.get_stage_key(GameState.current_stage, SaveData.custom_difficulty, GameState.is_instant_mode)

func _record_result_high_score() -> void:
	var key: String = _get_high_score_key()
	if key == "":
		return
	SaveData.record_high_score(key, _get_final_score())

func _play_stage_clear_animation(is_gameover: bool = false) -> void:
	var stage_clear: TextureRect = $PopupResult/StageClearImage
	var result_chara: TextureRect = $PopupResult/ResultChara
	var result_panel: TextureRect = $PopupResult/ResultPanel
	var header_path: String = _localized_result_header_path("result_gameover_text.webp", RESULT_GAMEOVER_IMAGE_PATH) if is_gameover else _localized_result_header_path("result_header_clear.webp", STAGE_CLEAR_IMAGE_PATH)
	if ResourceLoader.exists(header_path):
		stage_clear.texture = load(header_path)
	var panel_path := _localized_result_panel_path(RESULT_PANEL_IMAGE_PATH)
	if ResourceLoader.exists(panel_path):
		result_panel.texture = load(panel_path)
	var final_score: int = _get_final_score()
	var chara_path: String = _get_gameover_result_chara_path() if is_gameover else _get_result_chara_path(final_score)
	if ResourceLoader.exists(chara_path):
		result_chara.texture = load(chara_path)

	var header_size := Vector2(460.0, 210.0) if is_gameover else Vector2(420.0, 112.0)
	var header_start := Vector2(10.0, -230.0) if is_gameover else Vector2(30.0, -150.0)
	var header_end := Vector2(10.0, 14.0) if is_gameover else Vector2(30.0, 30.0)
	stage_clear.size = header_size
	stage_clear.position = header_start
	stage_clear.stretch_mode = TextureRect.STRETCH_SCALE
	result_panel.size = Vector2(240.0, 480.0)
	result_panel.stretch_mode = TextureRect.STRETCH_SCALE
	result_chara.position = Vector2(-260.0, 250.0)
	result_panel.position = Vector2(get_viewport_rect().size.x + 222.0, 210.0)
	$PopupResult/ResultPanel/ResultScores.position = Vector2(30.0, 104.0)
	$PopupResult/ResultPanel/ResultScores.size = Vector2(166.0, 312.0)
	$PopupResult/ResultPanel/ResultScores.add_theme_constant_override("separation", 2)
	stage_clear.visible = true
	result_chara.visible = true
	result_panel.visible = true

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(stage_clear, "position", header_end, 0.55)
	tween.tween_property(result_chara, "position", Vector2(0.0, 250.0), 0.55)
	tween.tween_property(result_panel, "position", Vector2(222.0, 210.0), 0.55)

func _show_clear_result(_message: String) -> void:
	is_gameover_result = false
	is_result_answer_view = false
	_record_result_high_score()
	_play_correct_faces(false)
	AudioManager.stop_bgm()
	AudioManager.play_se("se_clear")
	popup_state = "clear"
	_setup_popup_buttons(popup_state)
	$PopupResult/ResultMask.visible = true
	_move_clear_buttons_to_result_layer()
	$PopupResult.visible = true
	$PopupResult.move_to_front()
	_start_result_sakura_fx()
	_play_stage_clear_animation(false)
	_show_result_scores_sequence()

func _show_gameover_result() -> void:
	is_gameover_result = true
	is_result_answer_view = false
	_record_result_high_score()
	_play_wrong_faces()
	AudioManager.stop_bgm()
	AudioManager.play_bgm("bgm_gameover_mou")
	AudioManager.play_se("se_gameover")
	popup_state = "clear"
	_setup_popup_buttons(popup_state)
	$PopupResult/ResultMask.visible = true
	_move_clear_buttons_to_result_layer()
	$PopupResult.visible = true
	$PopupResult.move_to_front()
	_start_result_sakura_fx()
	_play_stage_clear_animation(true)
	_show_result_scores_sequence()

func _make_button_stylebox(texture_path: String) -> StyleBoxTexture:
	var texture: Texture2D = load(texture_path) as Texture2D
	if texture == null:
		return null
	var stylebox: StyleBoxTexture = StyleBoxTexture.new()
	stylebox.texture = texture
	return stylebox

func _clear_image_button_style(button: Button) -> void:
	button.remove_theme_stylebox_override("normal")
	button.remove_theme_stylebox_override("hover")
	button.remove_theme_stylebox_override("pressed")
	button.remove_theme_stylebox_override("focus")
	button.remove_theme_stylebox_override("disabled")
	button.flat = false

func _apply_image_button_style(button: Button, normal_path: String, pressed_path: String, disabled_path: String = "") -> void:
	var normal_stylebox: StyleBoxTexture = _make_button_stylebox(normal_path)
	if normal_stylebox == null:
		return
	var pressed_stylebox: StyleBoxTexture = _make_button_stylebox(pressed_path)
	if pressed_stylebox == null:
		pressed_stylebox = normal_stylebox
	var disabled_stylebox: StyleBoxTexture = normal_stylebox
	if disabled_path != "":
		var loaded_disabled_stylebox: StyleBoxTexture = _make_button_stylebox(disabled_path)
		if loaded_disabled_stylebox != null:
			disabled_stylebox = loaded_disabled_stylebox
	button.text = ""
	button.icon = null
	button.flat = false
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", normal_stylebox)
	button.add_theme_stylebox_override("hover", normal_stylebox)
	button.add_theme_stylebox_override("focus", normal_stylebox)
	button.add_theme_stylebox_override("disabled", disabled_stylebox)
	button.add_theme_stylebox_override("pressed", pressed_stylebox)

func _localized_keypad_button_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_path := (LOCALIZED_KEYPAD_BUTTON_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _localized_result_button_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_path := (LOCALIZED_RESULT_BUTTON_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _localized_result_header_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var localized_path := (LOCALIZED_RESULT_HEADER_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _localized_result_panel_path(fallback_path: String) -> String:
	return _localized_result_header_path("result_panel.webp", fallback_path)

func _localized_stage_intro_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if locale == "ja":
		return fallback_path
	var localized_path := (LOCALIZED_STAGE_INTRO_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _localized_misc_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if locale == "ja":
		return fallback_path
	var localized_path := (LOCALIZED_MISC_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path

func _refresh_localized_game_images() -> void:
	_setup_keypad_action_buttons()
	_refresh_visible_result_buttons()
	_refresh_back_to_result_button()
	_refresh_visible_result_header()
	_refresh_visible_result_panel()
	if four_chiitoi_hint != null:
		var hint_path := _localized_misc_path("four_chiitoi_hint.webp", FOUR_CHIITOI_HINT)
		if ResourceLoader.exists(hint_path):
			four_chiitoi_hint.texture = load(hint_path)
	if has_node("PopupResult/CorrectImage") and $PopupResult/CorrectImage.visible:
		_apply_correct_result_image()

func _refresh_visible_result_buttons() -> void:
	if not has_node("PopupResult/ResultButtons"):
		return
	if not $PopupResult/ResultButtons.visible:
		return
	_move_clear_buttons_to_result_layer()

func _refresh_back_to_result_button() -> void:
	if not has_node("PopupResult/BtnBackToResult"):
		return
	_apply_result_image_button_style($PopupResult/BtnBackToResult, _localized_result_button_path("result_btn_back.webp", RESULT_BTN_BACK))

func _refresh_visible_result_header() -> void:
	if not has_node("PopupResult/StageClearImage"):
		return
	var stage_clear: TextureRect = $PopupResult/StageClearImage
	if not stage_clear.visible:
		return
	var header_path: String = _localized_result_header_path("result_gameover_text.webp", RESULT_GAMEOVER_IMAGE_PATH) if is_gameover_result else _localized_result_header_path("result_header_clear.webp", STAGE_CLEAR_IMAGE_PATH)
	if ResourceLoader.exists(header_path):
		stage_clear.texture = load(header_path)

func _refresh_visible_result_panel() -> void:
	if not has_node("PopupResult/ResultPanel"):
		return
	var result_panel: TextureRect = $PopupResult/ResultPanel
	if not result_panel.visible:
		return
	var panel_path := _localized_result_panel_path(RESULT_PANEL_IMAGE_PATH)
	if ResourceLoader.exists(panel_path):
		result_panel.texture = load(panel_path)

func _apply_correct_result_image() -> void:
	var correct_image_path := _localized_result_header_path("result_correct.webp", SEIKAI_IMAGE_PATH)
	if ResourceLoader.exists(correct_image_path):
		$PopupResult/CorrectImage.texture = load(correct_image_path)

func _result_ui_text(key: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var texts := {
		"ja": {
			"score_base": "基本点",
			"score_time_bonus": "タイムボーナス",
			"score_wait_bonus": "多面張ボーナス",
			"score_total": "合計",
		},
		"en": {
			"score_base": "Base Score",
			"score_time_bonus": "Time Bonus",
			"score_wait_bonus": "Wait Bonus",
			"score_total": "Total",
		},
		"zh_CN": {
			"score_base": "基础分",
			"score_time_bonus": "时间奖励",
			"score_wait_bonus": "多面听奖励",
			"score_total": "合计",
		},
		"zh_TW": {
			"score_base": "基本分",
			"score_time_bonus": "時間獎勵",
			"score_wait_bonus": "多面聽獎勵",
			"score_total": "合計",
		},
		"ko": {
			"score_base": "기본 점수",
			"score_time_bonus": "시간 보너스",
			"score_wait_bonus": "다중 대기 보너스",
			"score_total": "합계",
		},
	}
	var locale_texts: Dictionary = texts.get(locale, texts["ja"])
	return str(locale_texts.get(key, texts["ja"].get(key, "")))

func _apply_result_image_button_style(button: Button, normal_path: String) -> void:
	button.text = ""
	button.icon = null
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.clip_contents = false
	button.size_flags_horizontal = Control.SIZE_FILL
	button.size_flags_vertical = Control.SIZE_FILL
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("focus", empty)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_stylebox_override("pressed", empty)
	var art: TextureRect = button.get_node_or_null("ResultButtonArt") as TextureRect
	if art == null:
		art = TextureRect.new()
		art.name = "ResultButtonArt"
		button.add_child(art)
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.offset_left = 0.0
	art.offset_top = 0.0
	art.offset_right = 0.0
	art.offset_bottom = 0.0
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.clip_contents = false
	if ResourceLoader.exists(normal_path):
		art.texture = load(normal_path)

func _get_next_stage_after_clear() -> String:
	match GameState.current_stage:
		"tutorial":
			return "stage1"
		"stage1":
			return "stage2"
		"stage2":
			return "stage3"
		"ex_stage1":
			return "ex_stage2"
		"ex_stage2":
			return "ex_stage3"
	return ""

func _is_mirage_clear_result() -> bool:
	return popup_state == "clear" and not is_gameover_result and GameState.current_stage == "stage4"

func _is_nightmare_clear_result() -> bool:
	return popup_state == "clear" and not is_gameover_result and GameState.current_stage == "ex_stage4"

func _should_show_next_stage_button() -> bool:
	return popup_state == "clear" and not is_gameover_result and _get_next_stage_after_clear() != ""

func _should_show_result_next_button() -> bool:
	return _should_show_next_stage_button() or _is_mirage_clear_result() or _is_nightmare_clear_result()

func _get_stage_talk_scene_id(stage: String) -> String:
	match stage:
		"stage1":
			return "stage1_intro"
		"stage2":
			return "stage2_intro"
		"stage3":
			return "stage3_intro"
		"ex_stage2":
			return "ex_stage2_intro"
		"ex_stage3":
			return "ex_stage3_intro"
	return ""

func _ensure_result_sakura_fx() -> Control:
	var layer: Control = $PopupResult.get_node_or_null("ResultSakuraFx") as Control
	if layer != null:
		return layer
	layer = Control.new()
	layer.name = "ResultSakuraFx"
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	$PopupResult.add_child(layer)
	$PopupResult.move_child(layer, 1)
	if not ResourceLoader.exists(RESULT_PETAL_IMAGE_PATH):
		return layer
	var texture: Texture2D = load(RESULT_PETAL_IMAGE_PATH)
	for i in range(28):
		var petal := TextureRect.new()
		petal.name = "Petal%02d" % i
		petal.texture = texture
		petal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		petal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		petal.size = Vector2(24.0 + randf() * 16.0, 18.0 + randf() * 12.0)
		petal.pivot_offset = petal.size * 0.5
		petal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(petal)
	return layer

func _start_result_sakura_fx() -> void:
	var layer := _ensure_result_sakura_fx()
	layer.visible = true
	layer.move_to_front()
	$PopupResult/StageClearImage.move_to_front()
	$PopupResult/ResultChara.move_to_front()
	$PopupResult/ResultPanel.move_to_front()
	$PopupResult/ResultButtons.move_to_front()
	for child in layer.get_children():
		var petal := child as TextureRect
		if petal != null and petal.get_meta("falling", false) == false:
			_animate_result_petal(petal, randf() * 2.4)

func _stop_result_sakura_fx() -> void:
	var layer: Control = $PopupResult.get_node_or_null("ResultSakuraFx") as Control
	if layer == null:
		return
	layer.visible = false
	for child in layer.get_children():
		child.set_meta("falling", false)

func _animate_result_petal(petal: TextureRect, delay: float = 0.0) -> void:
	if petal == null:
		return
	petal.set_meta("falling", true)
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	if petal == null or not is_instance_valid(petal) or not $PopupResult.visible:
		return
	var start_x := randf_range(-44.0, 480.0)
	var end_x := start_x + randf_range(-70.0, 110.0)
	var duration := randf_range(4.8, 8.2)
	petal.position = Vector2(start_x, randf_range(-90.0, -22.0))
	petal.rotation_degrees = randf_range(-80.0, 80.0)
	petal.modulate = Color(1.0, 1.0, 1.0, randf_range(0.55, 0.88))
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(petal, "position", Vector2(end_x, 884.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(petal, "rotation_degrees", petal.rotation_degrees + randf_range(160.0, 420.0), duration)
	tween.tween_property(petal, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	await tween.finished
	if petal != null and is_instance_valid(petal) and petal.get_meta("falling", false) and $PopupResult.visible:
		_animate_result_petal(petal, randf_range(0.0, 1.2))

func _setup_keypad_action_buttons() -> void:
	var btn_clear: Button = $Keypad/BtnClear
	var btn_submit: Button = $Keypad/BtnSubmit
	var btn_none: Button = $Keypad/BtnNone
	btn_clear.custom_minimum_size = Vector2(118.0, 60.0)
	btn_submit.custom_minimum_size = Vector2(100.0, 105.0)
	btn_none.custom_minimum_size = Vector2(108.0, 61.0)
	for button in [btn_clear, btn_submit, btn_none]:
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.pivot_offset = button.custom_minimum_size * 0.5
	var clear_path := _localized_keypad_button_path("keypad_btn_clear.webp", KEYPAD_BTN_CLEAR)
	var submit_path := _localized_keypad_button_path("keypad_btn_submit.webp", KEYPAD_BTN_SUBMIT)
	var none_path := _localized_keypad_button_path("keypad_btn_none.webp", KEYPAD_BTN_NONE)
	_apply_image_button_style(btn_clear, clear_path, clear_path)
	_apply_image_button_style(btn_submit, submit_path, submit_path, submit_path)
	_apply_image_button_style(btn_none, none_path, none_path, none_path)

func _on_submit_button_down() -> void:
	var button := $Keypad/BtnSubmit as Button
	if button.disabled:
		return
	_play_keypad_feedback_down(button, Color(1.25, 1.12, 0.66, 1.0), Vector2(0.92, 0.92), 0.055)

func _on_submit_button_up() -> void:
	_play_keypad_feedback_up($Keypad/BtnSubmit, Color(1.0, 1.0, 1.0, 1.0), 0.095)

func _on_none_button_down() -> void:
	var button := $Keypad/BtnNone as Button
	if button.disabled or not current_question_allows_none:
		return
	_play_keypad_feedback_down(button, Color(1.18, 1.22, 1.65, 1.0), Vector2(0.95, 0.95), 0.055)

func _on_none_button_up() -> void:
	var target_modulate := _get_none_button_target_modulate()
	_play_keypad_feedback_up($Keypad/BtnNone, target_modulate, 0.095)

func _play_keypad_feedback_down(button: Button, target_modulate: Color, target_scale: Vector2, duration: float) -> void:
	_kill_keypad_feedback_tween(button)
	_update_keypad_feedback_pivot(button)
	var tween := create_tween()
	keypad_feedback_tweens[button] = tween
	tween.set_parallel(true)
	tween.tween_property(button, "scale", target_scale, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", target_modulate, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _play_keypad_feedback_up(button: Button, target_modulate: Color, duration: float) -> void:
	_kill_keypad_feedback_tween(button)
	_update_keypad_feedback_pivot(button)
	var tween := create_tween()
	keypad_feedback_tweens[button] = tween
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", target_modulate, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void:
		keypad_feedback_tweens.erase(button)
	)

func _kill_keypad_feedback_tween(button: Button) -> void:
	if keypad_feedback_tweens.has(button):
		var tween := keypad_feedback_tweens[button] as Tween
		if tween != null and is_instance_valid(tween):
			tween.kill()
		keypad_feedback_tweens.erase(button)

func _update_keypad_feedback_pivot(button: Button) -> void:
	var pivot_size := button.size
	if pivot_size.x <= 0.0 or pivot_size.y <= 0.0:
		pivot_size = button.custom_minimum_size
	button.pivot_offset = pivot_size * 0.5

func _move_clear_buttons_to_result_layer() -> void:
	_ensure_result_answer_buttons()
	var buttons: GridContainer = $PopupResult/ResultButtons
	var btn_retry: Button = $PopupResult/PopupPanel/BtnRetry
	var btn_home: Button = $PopupResult/PopupPanel/BtnHome
	var btn_ranking: Button = $PopupResult/ResultButtons/BtnSubmitRanking
	var btn_answer: Button = $PopupResult/ResultButtons/BtnShowAnswer
	if btn_retry.get_parent() != buttons:
		btn_retry.reparent(buttons)
	if btn_home.get_parent() != buttons:
		btn_home.reparent(buttons)
	buttons.move_child(btn_retry, 0)
	buttons.move_child(btn_home, 1)
	buttons.move_child(btn_ranking, 2)
	buttons.move_child(btn_answer, 3)
	buttons.columns = 2
	buttons.position = Vector2(50.0, 700.0)
	buttons.size = Vector2(380.0, 144.0)
	buttons.add_theme_constant_override("h_separation", 12)
	buttons.add_theme_constant_override("v_separation", 4)
	btn_retry.custom_minimum_size = Vector2(184.0, 70.0)
	btn_home.custom_minimum_size = Vector2(184.0, 70.0)
	btn_ranking.custom_minimum_size = Vector2(184.0, 70.0)
	btn_answer.custom_minimum_size = Vector2(184.0, 70.0)
	var retry_button_image := _localized_result_button_path("result_btn_next.webp", RESULT_BTN_NEXT) if _should_show_result_next_button() else _localized_result_button_path("result_btn_retry.webp", RESULT_BTN_RETRY)
	_apply_result_image_button_style(btn_retry, retry_button_image)
	if btn_home.text == "OK":
		_clear_image_button_style(btn_home)
	else:
		_apply_result_image_button_style(btn_home, _localized_result_button_path("result_btn_home.webp", RESULT_BTN_HOME))
	_apply_result_image_button_style(btn_ranking, _localized_result_button_path("result_btn_ranking.webp", RESULT_BTN_RANKING))
	_apply_result_image_button_style(btn_answer, _localized_result_button_path("result_btn_answer.webp", RESULT_BTN_ANSWER))
	btn_ranking.visible = _get_ranking_stage_key() != ""
	btn_answer.visible = true
	buttons.visible = true
	buttons.move_to_front()

func _ensure_result_answer_buttons() -> void:
	if not has_node("PopupResult/ResultButtons/BtnSubmitRanking"):
		var btn_ranking: Button = Button.new()
		btn_ranking.name = "BtnSubmitRanking"
		btn_ranking.text = "RANKING"
		btn_ranking.add_theme_font_size_override("font_size", 18)
		btn_ranking.pressed.connect(_on_btn_submit_ranking_pressed)
		$PopupResult/ResultButtons.add_child(btn_ranking)
	if not has_node("PopupResult/ResultButtons/BtnShowAnswer"):
		var btn_answer: Button = Button.new()
		btn_answer.name = "BtnShowAnswer"
		btn_answer.text = "答えを確認"
		btn_answer.add_theme_font_size_override("font_size", 22)
		btn_answer.pressed.connect(_on_btn_show_answer_pressed)
		$PopupResult/ResultButtons.add_child(btn_answer)
	if not has_node("PopupResult/BtnBackToResult"):
		var btn_back: Button = Button.new()
		btn_back.name = "BtnBackToResult"
		btn_back.text = "リザルトに戻る"
		btn_back.position = Vector2(110.0, 782.0)
		btn_back.size = Vector2(260.0, 62.0)
		btn_back.custom_minimum_size = Vector2(260.0, 62.0)
		btn_back.add_theme_font_size_override("font_size", 22)
		btn_back.visible = false
		btn_back.pressed.connect(_on_btn_back_to_result_pressed)
		$PopupResult.add_child(btn_back)
	_refresh_back_to_result_button()

func _on_btn_submit_ranking_pressed() -> void:
	var stage_key := _get_ranking_stage_key()
	var final_score := _get_final_score()
	print("[Game] submit ranking pressed stage_key=", stage_key, " score=", final_score)
	if RankingManager.submit_score(stage_key, final_score):
		RankingManager.show_leaderboard(stage_key)

func _on_btn_show_answer_pressed() -> void:
	_show_answer_view_from_result()

func _on_btn_back_to_result_pressed() -> void:
	_show_result_view_from_answer()

func _show_answer_view_from_result() -> void:
	if is_result_answer_view:
		return
	is_result_answer_view = true
	_stop_result_sakura_fx()
	$PopupResult/ResultMask.visible = false
	$PopupResult/StageClearImage.visible = false
	$PopupResult/ResultChara.visible = false
	$PopupResult/ResultPanel.visible = false
	$PopupResult/ResultButtons.visible = false
	$PopupResult/PopupPanel.visible = true
	$PopupResult/PopupPanel.position = Vector2(90.0, 300.0)
	$PopupResult/PopupPanel/ResultLabel.visible = false
	$PopupResult/PopupPanel/GameOverImage.visible = false
	_show_correct_tiles(_get_effective_correct_tiles())
	if has_node("PopupResult/BtnBackToResult"):
		$PopupResult/BtnBackToResult.visible = true
		$PopupResult/BtnBackToResult.move_to_front()

func _show_result_view_from_answer() -> void:
	if not is_result_answer_view:
		return
	is_result_answer_view = false
	_start_result_sakura_fx()
	$PopupResult/ResultMask.visible = true
	$PopupResult/StageClearImage.visible = true
	$PopupResult/ResultChara.visible = true
	$PopupResult/ResultPanel.visible = true
	$PopupResult/ResultButtons.visible = true
	$PopupResult/PopupPanel.visible = false
	$PopupResult/PopupPanel/CorrectNoneLabel.visible = false
	$PopupResult/PopupPanel/CorrectTilesRow1.visible = false
	$PopupResult/PopupPanel/CorrectTilesRow2.visible = false
	if has_node("PopupResult/BtnBackToResult"):
		$PopupResult/BtnBackToResult.visible = false

func _get_time_bonus() -> int:
	return time_bonus_total

func _calc_time_bonus_for_times(times: Array[float]) -> int:
	if times.size() < TIME_BONUS_REQUIRED_QUESTIONS:
		return 0
	var max_time: float = 0.0
	for t in times:
		if t > max_time:
			max_time = t
	if max_time <= 5.0:
		return 40000
	elif max_time <= 10.0:
		return 20000
	elif max_time <= 20.0:
		return 10000
	elif max_time <= 30.0:
		return 5000
	return 0

func _complete_time_bonus_segment() -> void:
	var bonus: int = _calc_time_bonus_for_times(answer_times)
	time_bonus_total += bonus
	answer_times.clear()
	_sync_persistent_score_run()

func _get_wait_bonus_total() -> int:
	return int(wait_bonus_counts[4]) * 2000 \
		+ int(wait_bonus_counts[5]) * 3000 \
		+ int(wait_bonus_counts[6]) * 5000 \
		+ int(wait_bonus_counts[7]) * 10000

func _show_result_scores_sequence() -> void:
	var box: VBoxContainer = $PopupResult/ResultPanel/ResultScores
	box.visible = true
	for child in box.get_children():
		child.queue_free()
	var labels: Array[String] = [
		_result_ui_text("score_base"),
		_result_ui_text("score_time_bonus"),
		_result_ui_text("score_wait_bonus"),
		_result_ui_text("score_total"),
	]
	var rows: Array[int] = [
		total_score,
		_get_time_bonus(),
		_get_wait_bonus_total(),
		_get_final_score(),
	]
	for i in range(rows.size()):
		await get_tree().create_timer(0.4).timeout
		if i == rows.size() - 1:
			AudioManager.play_se("se_rizafinish")
		else:
			AudioManager.play_se("se_riza1")
		box.add_child(_make_score_group(labels[i], rows[i]))

# ============================================================
# ポップアップのボタン表示切り替え
# ============================================================
func _play_correct_score_float() -> void:
	var score_row: HBoxContainer = $PopupResult/CorrectScore
	score_row.position = Vector2(210.0, 455.0)
	score_row.modulate = Color(1, 1, 1, 1)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(score_row, "position:y", 395.0, 0.9)
	tween.tween_property(score_row, "modulate:a", 0.0, 0.9)

func _setup_popup_buttons(state: String) -> void:
	_reset_gameover_display()
	var transparent_panel: StyleBoxFlat = StyleBoxFlat.new()
	transparent_panel.bg_color = Color(0, 0, 0, 0)
	if state == "wrong":
		$PopupResult/PopupPanel.remove_theme_stylebox_override("panel")
	else:
		$PopupResult/PopupPanel.add_theme_stylebox_override("panel", transparent_panel)

	var btn_retry: Button = $PopupResult/PopupPanel/BtnRetry
	var btn_home: Button = $PopupResult/PopupPanel/BtnHome
	var has_next_stage_button := _should_show_next_stage_button()
	btn_retry.position.y = 210.0
	btn_home.position.y  = 210.0

	if state == "wrong":
		$PopupResult/PopupPanel.position = Vector2(90.0, 320.0)
		$PopupResult/PopupPanel/ResultLabel.visible = false
	elif state == "correct":
		$PopupResult/PopupPanel.position = Vector2(90.0, 220.0)
		$PopupResult/PopupPanel/ResultLabel.visible = false
		$PopupResult/PopupPanel/ResultLabel.position.y = 90.0
	else:
		$PopupResult/PopupPanel.position = Vector2(90.0, 220.0)
		$PopupResult/PopupPanel/ResultLabel.visible = false
		$PopupResult/PopupPanel/ResultLabel.position.y = 40.0

	if state == "clear":
		btn_retry.visible = true
		btn_retry.text    = "次へ" if _should_show_result_next_button() else "もう一度"
		btn_home.visible  = true
		btn_home.text     = "ホーム"
		btn_home.position.x = BTN_HOME_X_NORMAL
	elif state == "correct":
		btn_retry.visible = false
		btn_home.visible  = false
	else:
		btn_retry.visible = true
		btn_retry.text    = "もう一度"
		btn_home.visible  = true
		if GameState.is_instant_mode:
			btn_home.text = "タイトルへ"
		else:
			btn_home.text = "ホーム"
		btn_home.position.x = BTN_HOME_X_NORMAL

# ============================================================
# 正解牌を画像で表示
# ============================================================
func _show_correct_tiles(tiles: Array) -> void:
	for child in $PopupResult/PopupPanel/CorrectTilesRow1.get_children():
		child.queue_free()
	for child in $PopupResult/PopupPanel/CorrectTilesRow2.get_children():
		child.queue_free()

	if tiles.is_empty():
		$PopupResult/PopupPanel/CorrectNoneLabel.visible = true
		$PopupResult/PopupPanel/CorrectTilesRow1.visible = false
		$PopupResult/PopupPanel/CorrectTilesRow2.visible = false
		return

	$PopupResult/PopupPanel/CorrectNoneLabel.visible = false

	const SPLIT := 5
	var use_two_rows := tiles.size() > SPLIT
	$PopupResult/PopupPanel/CorrectTilesRow1.visible = true
	$PopupResult/PopupPanel/CorrectTilesRow2.visible = use_two_rows

	for i in range(tiles.size()):
		var tile: int = tiles[i]
		var rect := make_tile_image(tile, TILE_W_SMALL, TILE_H_SMALL)
		if i < SPLIT:
			$PopupResult/PopupPanel/CorrectTilesRow1.add_child(rect)
		else:
			$PopupResult/PopupPanel/CorrectTilesRow2.add_child(rect)

# ============================================================
# ゲームオーバータンブルアニメーション
# ============================================================
func _play_gameover_animation() -> void:
	var img: TextureRect = $PopupResult/PopupPanel/GameOverImage
	if ResourceLoader.exists(GAMEOVER_IMAGE_PATH):
		img.texture = load(GAMEOVER_IMAGE_PATH)
	img.pivot_offset = Vector2(150.0, 37.5)
	img.position = Vector2(-320.0, 8.0)
	img.rotation_degrees = -270.0
	img.visible = true

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(img, "position:x", 0.0, 0.6)
	tween.parallel().tween_property(img, "rotation_degrees", 0.0, 0.6)
	await tween.finished

# ============================================================
# 顔アイコン
# ============================================================
func _setup_face_icons() -> void:
	var face_size: Vector2 = Vector2(173.0, 173.0)
	var vp: Vector2 = get_viewport_rect().size

	$FaceBoss.size = face_size
	$FaceBoss.position = Vector2(10.0, 40.0)

	$FaceMain.size = face_size
	$FaceMain.position = Vector2(vp.x - face_size.x - 10.0, vp.y / 2.0 - face_size.y / 2.0 - 40.0)

	_set_face($FaceMain, KAO_PYOKO_DEF)
	_set_face($FaceBoss, _get_boss_def_path())

func _set_face(node: TextureRect, path: String) -> void:
	if ResourceLoader.exists(path):
		node.texture = load(path)
	else:
		node.texture = null

func _get_effective_stage() -> String:
	if GameState.current_stage == "custom":
		return SaveData.custom_difficulty
	if GameState.current_stage == "endless":
		match GameState.endless_block:
			0: return "stage1"
			1: return "stage2"
			2: return "stage3"
			3: return "stage4"
			4: return "stage1"
			5: return "stage2"
			6: return "stage3"
			_: return "stage4"
	match GameState.current_stage:
		"tutorial":  return "stage1"
		"ex_stage1": return "stage1"
		"ex_stage2": return "stage2"
		"ex_stage3": return "stage3"
		"ex_stage4": return "stage4"
	return GameState.current_stage

func _uses_yume_ex_faces() -> bool:
	return (
		GameState.current_stage == "ex_stage1"
		or (GameState.current_stage == "endless" and GameState.endless_block == 4)
	)

func _uses_utu_ex_faces() -> bool:
	return (
		GameState.current_stage == "ex_stage2"
		or (GameState.current_stage == "endless" and GameState.endless_block == 5)
	)

func _get_boss_def_path() -> String:
	if _uses_yume_ex_faces():
		return KAO_YUME_EX_DEF
	if _uses_utu_ex_faces():
		return KAO_UTU_EX_DEF
	var effective: String = _get_effective_stage()
	match effective:
		"stage1": return KAO_YUME_DEF
		"stage2": return KAO_UTU_DEF
		"stage3": return KAO_MABO_HARD_DEF
		"stage4": return KAO_MABO_MIRAGE_DEF
		_: return KAO_MABO_HARD_DEF

func _get_boss_phase_path() -> String:
	var effective: String = _get_effective_stage()
	var paths: Array
	if _uses_yume_ex_faces():
		paths = [KAO_YUME_EX_DEF, KAO_YUME_EX_DEF2, KAO_YUME_EX_DEF3]
	elif _uses_utu_ex_faces():
		paths = [KAO_UTU_EX_DEF, KAO_UTU_EX_DEF2, KAO_UTU_EX_DEF3]
	else:
		match effective:
			"stage1": paths = [KAO_YUME_DEF,  KAO_YUME_DEF2,  KAO_YUME_DEF3]
			"stage2": paths = [KAO_UTU_DEF,   KAO_UTU_DEF2,   KAO_UTU_DEF3]
			"stage3": paths = [KAO_MABO_HARD_DEF, KAO_MABO_HARD_DEF2, KAO_MABO_HARD_DEF3]
			_:        paths = [KAO_MABO_MIRAGE_DEF, KAO_MABO_MIRAGE_DEF2, KAO_MABO_MIRAGE_DEF3]
	if current_question >= 7:
		return paths[2]
	elif current_question >= 3:
		return paths[1]
	else:
		return paths[0]

func _get_boss_wrong_path() -> String:
	if _uses_yume_ex_faces():
		return KAO_YUME_EX_KATI
	if _uses_utu_ex_faces():
		return KAO_UTU_EX_DEF
	var effective: String = _get_effective_stage()
	match effective:
		"stage1": return KAO_YUME_KATI
		"stage2": return KAO_UTU_KATI
		_: return KAO_MABO_KATI

func _play_correct_faces(revert: bool = true) -> void:
	var seikai_path: String = KAO_PYOKO_SEIKAI[randi() % KAO_PYOKO_SEIKAI.size()]
	_set_face($FaceMain, seikai_path)
	if revert:
		await get_tree().create_timer(SEIKAI_FLASH_DURATION).timeout
		_set_face($FaceMain, KAO_PYOKO_DEF)
	_set_face($FaceBoss, _get_boss_phase_path())

func _play_wrong_faces() -> void:
	var make_path: String = KAO_PYOKO_MAKE[randi() % KAO_PYOKO_MAKE.size()]
	_set_face($FaceMain, make_path)
	_set_face($FaceBoss, _get_boss_wrong_path())

# ============================================================
# 背景ロード
# ============================================================
func _load_stage_bg() -> void:
	var path := _get_bg_path()
	if path != "" and ResourceLoader.exists(path):
		$BG.texture = load(path)

func _get_bg_path() -> String:
	if GameState.current_stage == "endless":
		match GameState.endless_block:
			0: return "res://assets/bg/bg_yume.webp"
			1: return "res://assets/bg/bg_ututu.webp"
			2: return "res://assets/bg/bg_maboro_game.webp"
			3: return "res://assets/bg/bg_maboro_mirage.webp"
			4: return "res://assets/bg/bg_yumeex.webp"
			5: return "res://assets/bg/bg_ututuex.webp"
			6: return "res://assets/bg/bg_maboroex.webp"
			_: return "res://assets/bg/bg_maboroex2.webp"
	match GameState.current_stage:
		"tutorial", "stage1": return "res://assets/bg/bg_yume.webp"
		"stage2":              return "res://assets/bg/bg_ututu.webp"
		"stage3":              return "res://assets/bg/bg_maboro_game.webp"
		"stage4":              return "res://assets/bg/bg_maboro_mirage.webp"
		"ex_stage1":           return "res://assets/bg/bg_yumeex.webp"
		"ex_stage2":           return "res://assets/bg/bg_ututuex.webp"
		"ex_stage3":           return "res://assets/bg/bg_maboroex.webp"
		"ex_stage4":           return "res://assets/bg/bg_maboroex2.webp"
	if GameState.current_stage == "custom":
		match SaveData.custom_difficulty:
			"stage1": return "res://assets/bg/bg_yume.webp"
			"stage2": return "res://assets/bg/bg_ututu.webp"
			"stage3": return "res://assets/bg/bg_maboro_game.webp"
			"stage4": return "res://assets/bg/bg_maboro_mirage.webp"
	return ""

# ============================================================
# BGM
# ============================================================
func get_custom_bgm_list() -> Array:
	var list: Array = []
	if SaveData.custom_bgm_yume:
		list.append_array(["bgm_yume_main", "bgm_yume_jantou", "bgm_yume_barabara"])
	if SaveData.custom_bgm_utu:
		list.append_array(["bgm_utu_higakureru", "bgm_utu_kotaewo", "bgm_utu_matigai", "bgm_utu_nochan"])
	if SaveData.custom_bgm_mabo_first:
		list.append_array(["bgm_mabo_first_2tunoboketu", "bgm_mabo_first_appaku", "bgm_mabo_first_nebumi"])
	if SaveData.custom_bgm_mabo_second:
		list.append_array(["bgm_mabo_second_kougetu", "bgm_mabo_second_ginniro", "bgm_mabo_second_inisie", "bgm_mabo_mugen"])
	if list.is_empty():
		list = ["bgm_yume_jantou"]
	return list

func play_stage_bgm() -> void:
	if GameState.current_stage == "endless":
		var idx: int = min(GameState.endless_block, ENDLESS_BGM.size() - 1)
		current_bgm_filename = ENDLESS_BGM[idx]
		AudioManager.play_bgm(current_bgm_filename)
		return
	if GameState.current_stage == "custom":
		var list: Array = get_custom_bgm_list()
		current_bgm_filename = list[randi() % list.size()]
		AudioManager.play_bgm_once(current_bgm_filename)
		if not _custom_bgm_connected:
			AudioManager.bgm_player.finished.connect(_on_custom_bgm_finished)
			_custom_bgm_connected = true
		return
	if not bgm_list.has(GameState.current_stage):
		return
	var list: Array = bgm_list[GameState.current_stage]
	current_bgm_filename = list[randi() % list.size()]
	AudioManager.play_bgm(current_bgm_filename)

func _on_custom_bgm_finished() -> void:
	if GameState.current_stage != "custom":
		return
	if AudioManager.bgm_player.playing:
		return
	var list: Array = get_custom_bgm_list()
	current_bgm_filename = list[randi() % list.size()]
	AudioManager.play_bgm_once(current_bgm_filename)

# ============================================================
# イントロ
# ============================================================
func get_intro_stage_name() -> String:
	if GameState.current_stage == "endless":
		var idx: int = min(GameState.endless_block, ENDLESS_BLOCK_NAMES.size() - 1)
		return ENDLESS_BLOCK_NAMES[idx]
	if GameState.current_stage == "custom":
		match SaveData.custom_difficulty:
			"stage1": return "Easy"
			"stage2": return "Normal"
			"stage3": return "Hard"
			"stage4": return "Mirage"
	return stage_display_names.get(GameState.current_stage, "")

func play_intro() -> void:
	if _is_tutorial_stage():
		$StageIntro/IntroPanel.visible = false
		_hide_stage_intro_card()
		await slide_hand_in()
		return
	var panel = $StageIntro/IntroPanel
	var stage_label = $StageIntro/IntroPanel/StageName
	var bgm_label = $StageIntro/IntroPanel/BgmName

	var intro_card_data := _get_stage_intro_card_data()
	var use_card_intro := not intro_card_data.is_empty()
	if use_card_intro:
		stage_label.visible = false
		bgm_label.visible = false
		_show_stage_intro_card(panel, intro_card_data)
	else:
		_hide_stage_intro_card()
		stage_label.visible = true
		bgm_label.visible = true
		stage_label.text = "難易度　" + get_intro_stage_name()
		bgm_label.text = "♪ " + bgm_display_names.get(current_bgm_filename, "")

	panel.color = Color(0, 0, 0, 0.4)
	panel.modulate.a = 1.0
	panel.visible = true

	await get_tree().create_timer(3.0).timeout

	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	await tween.finished

	panel.visible = false
	_hide_stage_intro_card()
	await slide_hand_in()

func _get_stage_intro_card_data() -> Dictionary:
	var difficulty_name := get_intro_stage_name()
	var logo_path: String = STAGE_INTRO_DIFFICULTY_LOGOS.get(difficulty_name, "")
	var jacket_path: String = STAGE_INTRO_JACKETS.get(current_bgm_filename, "")
	if logo_path == "" or jacket_path == "":
		return {}
	logo_path = _localized_stage_intro_path(logo_path.get_file(), logo_path)
	if not ResourceLoader.exists(logo_path) or not ResourceLoader.exists(jacket_path):
		return {}
	return {
		"logo_path": logo_path,
		"jacket_path": jacket_path,
		"logo_scale": float(STAGE_INTRO_LOGO_SCALES.get(difficulty_name, 1.0)),
		"stars": float(STAGE_INTRO_DIFFICULTY_STARS.get(difficulty_name, 0.0)),
	}

func _show_stage_intro_card(panel: ColorRect, card_data: Dictionary) -> void:
	_ensure_stage_intro_card(panel)
	_update_stage_intro_card(card_data)
	_layout_stage_intro_card()
	_stage_intro_card.visible = true

func _hide_stage_intro_card() -> void:
	if _stage_intro_card != null:
		_stage_intro_card.visible = false

func _ensure_stage_intro_card(panel: Control) -> void:
	if _stage_intro_card != null:
		return

	_stage_intro_card = Control.new()
	_stage_intro_card.name = "StageIntroCard"
	_stage_intro_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_stage_intro_card)

	_add_intro_texture("DifficultyLogo", "")
	_add_intro_texture("DifficultyLabel", _localized_stage_intro_path("difficulty_label.webp", STAGE_INTRO_DIFFICULTY_LABEL))
	var star_mask := ColorRect.new()
	star_mask.name = "StarMask"
	star_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_mask.color = Color(0.0, 0.0, 0.0, 0.48)
	_stage_intro_card.add_child(star_mask)
	for i in range(5):
		_add_intro_texture("Star" + str(i + 1), STAGE_INTRO_STAR_EMPTY)
	_add_intro_texture("Jacket", "")

func _add_intro_texture(node_name: String, path: String) -> void:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(path):
		rect.texture = load(path)
	_stage_intro_card.add_child(rect)

func _update_stage_intro_card(card_data: Dictionary) -> void:
	_set_intro_texture("DifficultyLogo", card_data.get("logo_path", ""))
	_set_intro_texture("Jacket", card_data.get("jacket_path", ""))
	_stage_intro_card.set_meta("logo_scale", float(card_data.get("logo_scale", 1.0)))
	var stars: float = float(card_data.get("stars", 0.0))
	for i in range(5):
		var star_value := float(i + 1)
		var path := STAGE_INTRO_STAR_EMPTY
		if stars >= star_value:
			path = STAGE_INTRO_STAR_FULL
		elif stars >= star_value - 0.5:
			path = STAGE_INTRO_STAR_HALF
		_set_intro_texture("Star" + str(i + 1), path)

func _set_intro_texture(node_name: String, path: String) -> void:
	var rect := _stage_intro_card.get_node(node_name) as TextureRect
	if path != "" and ResourceLoader.exists(path):
		rect.texture = load(path)
	else:
		rect.texture = null

func _layout_stage_intro_card() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var scale_factor: float = minf(vp.x / 480.0, vp.y / 854.0)
	var offset := Vector2((vp.x - 480.0 * scale_factor) * 0.5, (vp.y - 854.0 * scale_factor) * 0.5)
	_stage_intro_card.position = Vector2.ZERO
	_stage_intro_card.size = vp

	var logo_scale: float = float(_stage_intro_card.get_meta("logo_scale", 1.0))
	var logo_w: float = 632.0 * logo_scale
	var logo_h: float = 236.0 * logo_scale
	_place_intro_node("DifficultyLogo", -76.0 - (logo_w - 632.0) * 0.5, 38.0 - (logo_h - 236.0) * 0.5, logo_w, logo_h, scale_factor, offset)
	_place_intro_node("DifficultyLabel", 42.0, 315.0, 134.0, 48.0, scale_factor, offset)
	_place_intro_node("StarMask", 0.0, 304.0, 480.0, 70.0, scale_factor, offset)
	for i in range(5):
		_place_intro_node("Star" + str(i + 1), 172.0 + 49.0 * float(i), 318.0, 42.0, 42.0, scale_factor, offset)
	_place_intro_node("Jacket", 66.0, 432.0, 348.0, 348.0, scale_factor, offset)

func _place_intro_node(node_name: String, x: float, y: float, w: float, h: float, scale_factor: float, offset: Vector2) -> void:
	var node := _stage_intro_card.get_node(node_name) as Control
	node.position = offset + Vector2(x, y) * scale_factor
	node.size = Vector2(w, h) * scale_factor
	node.custom_minimum_size = node.size

# ============================================================
# タイマー
# ============================================================
func _process(delta: float) -> void:
	if not timer_running:
		return
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		update_timer_display()
		on_time_up()
	else:
		update_timer_display()

func start_timer() -> void:
	time_left = time_limit
	timer_running = true
	update_timer_display()

func stop_timer() -> void:
	timer_running = false

func setup_timer_display() -> void:
	$TimerLabel.visible = timer_enabled

func update_timer_display() -> void:
	if not timer_enabled:
		return
	$TimerLabel.text = _timer_text(time_left)

func _timer_text(seconds: float) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	var formats := {
		"ja": "残り：%.1f秒",
		"en": "Time left: %.1fs",
		"zh_CN": "剩余：%.1f秒",
		"zh_TW": "剩餘：%.1f秒",
		"ko": "남은 시간: %.1f초",
	}
	return str(formats.get(locale, formats["ja"])) % seconds

func _start_question_clock() -> void:
	question_started_msec = Time.get_ticks_msec()

func _reset_score_state() -> void:
	total_score = 0
	time_bonus_total = 0
	last_question_score = 0
	answer_times.clear()
	wait_bonus_counts = {4: 0, 5: 0, 6: 0, 7: 0}
	if _uses_persistent_score_run():
		GameState.reset_run_score()
	_update_score_display(false)

func _add_score_for_current_answer() -> void:
	var elapsed: float = float(Time.get_ticks_msec() - question_started_msec) / 1000.0
	var deciseconds: int = int(floor(elapsed * 10.0))
	var score: int = maxi(100, 3000 - deciseconds * 10)
	last_question_score = score
	total_score += score
	_update_score_display(true)
	answer_times.append(elapsed)
	var wait_count: int = correct_tiles.size()
	if wait_count >= 7:
		wait_bonus_counts[7] = int(wait_bonus_counts[7]) + 1
	elif wait_count >= 4:
		wait_bonus_counts[wait_count] = int(wait_bonus_counts[wait_count]) + 1
	_sync_persistent_score_run()

func on_time_up() -> void:
	if is_game_over:
		return
	is_game_over = true
	is_animating = false
	stop_timer()
	$HomeConfirmPopup.visible = false
	$Keypad/BtnSubmit.disabled = true
	_show_gameover_result()

# ============================================================
# デバッグ
# ============================================================
func _input(event: InputEvent) -> void:
	if _is_tutorial_stage() and _handle_tutorial_advance_input(event):
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		GameState.debug_mode = not GameState.debug_mode
		update_debug_display()
		print("デバッグモード: ", GameState.debug_mode)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		_force_clear_current_question()
	if event is InputEventKey and event.pressed and event.keycode == KEY_F6:
		_force_exhausted_tile_question()
	if event is InputEventKey and event.pressed and event.keycode == KEY_F7:
		_play_phase_cutin(CUTIN_MIRAGE_CHARA_PATH)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F8:
		_play_phase_cutin(CUTIN_NIGHTMARE_CHARA_PATH)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F5:
		_force_exhausted_tile_question()
		return

func update_debug_display() -> void:
	if GameState.debug_mode:
		$DebugLabel.visible = true
		if correct_tiles.is_empty():
			$DebugLabel.text = "正解：待ちなし"
		else:
			$DebugLabel.text = "正解：" + str(correct_tiles)
	else:
		$DebugLabel.visible = false

# ============================================================
# ステージ設定
# ============================================================
func get_hand_size_for_stage(stage_name: String) -> int:
	if stage_name == "endless":
		return _get_endless_hand_size()
	if stage_name == "custom":
		match SaveData.custom_difficulty:
			"stage1": return 7
			"stage2": return 10
			_: return 13
	match stage_name:
		"tutorial", "stage1", "ex_stage1": return 7
		"stage2", "ex_stage2":             return 10
		_:                                 return 13

func _get_endless_hand_size() -> int:
	match GameState.endless_block:
		0: return 7
		1: return 10
		2: return 13
		3: return 13
		4: return 7
		5: return 10
		_: return 13

# ============================================================
# 問題生成
# ============================================================
func load_new_question() -> void:
	is_game_over = false
	if _is_tutorial_stage():
		_load_tutorial_question()
		return
	var sort_hand: bool
	var use_tenpai_only: bool

	if GameState.current_stage == "endless":
		match GameState.endless_block:
			0: sort_hand = true;  use_tenpai_only = true
			1: sort_hand = true;  use_tenpai_only = true
			2: sort_hand = true;  use_tenpai_only = true
			3: sort_hand = false; use_tenpai_only = true
			4: sort_hand = false; use_tenpai_only = true
			5: sort_hand = false; use_tenpai_only = true
			6: sort_hand = true;  use_tenpai_only = false
			7: sort_hand = false; use_tenpai_only = false
			_: sort_hand = false; use_tenpai_only = false
	elif GameState.current_stage.begins_with("ex_"):
		match GameState.current_stage:
			"ex_stage1": sort_hand = false; use_tenpai_only = true
			"ex_stage2": sort_hand = false; use_tenpai_only = true
			"ex_stage3": sort_hand = true;  use_tenpai_only = false
			"ex_stage4": sort_hand = false; use_tenpai_only = false
			_:           sort_hand = false; use_tenpai_only = false
	else:
		var effective_stage := GameState.current_stage
		if GameState.current_stage == "custom":
			effective_stage = SaveData.custom_difficulty
		if GameState.current_stage == "custom":
			sort_hand = SaveData.custom_sort_enabled
		else:
			sort_hand = (effective_stage != "stage4")
		use_tenpai_only = true
	current_hand_sorted = sort_hand
	current_question_allows_none = not use_tenpai_only

	var hand: Array
	if use_tenpai_only:
		hand = MahjongLogic.generate_tenpai_hand(hand_size, 1000, sort_hand)
	else:
		hand = MahjongLogic.generate_hand(hand_size, sort_hand)

	correct_tiles = MahjongLogic.find_waiting_tiles(hand)
	current_hand = hand
	_randomize_hand_flips()
	selected_tiles = []
	display_hand(hand)
	update_ui()
	update_debug_display()

func _randomize_hand_flips() -> void:
	current_hand_flipped.clear()
	var allow_random_flip: bool = SaveData.tile_suit == "manzu2" and not current_hand_sorted
	for _tile in current_hand:
		current_hand_flipped.append(allow_random_flip and randf() < 0.5)
	if allow_random_flip and not current_hand_flipped.is_empty() and not current_hand_flipped.has(true):
		current_hand_flipped[randi_range(0, current_hand_flipped.size() - 1)] = true

func update_question_counter() -> void:
	if GameState.current_stage == "endless":
		var total := GameState.endless_total_question + current_question + 1
		if total <= 80:
			$QuestionCounter.text = str(total) + " / 80"
		else:
			$QuestionCounter.text = str(total) + " / ∞"
	elif GameState.current_stage == "custom" and SaveData.custom_question_count == -1:
		$QuestionCounter.text = str(current_question + 1) + " / ∞"
	else:
		$QuestionCounter.text = str(current_question + 1) + " / " + str(total_questions)

# ============================================================
# 入力処理
# ============================================================
func _on_number_pressed(number: int) -> void:
	if is_animating or is_game_over:
		return
	if _is_tutorial_stage() and not _can_press_tutorial_number(number):
		return
	if not _can_accept_answer_toggle("num_" + str(number)):
		return
	if number in _get_exhausted_tiles():
		return
	if number in selected_tiles:
		selected_tiles.erase(number)
		update_ui()
		return
	selected_tiles.append(number)
	selected_tiles.sort()
	if _is_tutorial_stage():
		_clear_tutorial_feedback()
		if current_question == 0 and tutorial_page_index == 3 and number == 8:
			tutorial_page_index = 4
	update_ui()
	_update_tutorial_step()

func _on_none_pressed() -> void:
	if is_animating or is_game_over or not current_question_allows_none:
		return
	if not _can_accept_answer_toggle("none"):
		return
	if selected_tiles.size() == 1 and selected_tiles[0] == -1:
		selected_tiles = []
		update_ui()
		return
	selected_tiles = [-1]
	update_ui()

func _on_clear_pressed() -> void:
	if is_animating or is_game_over:
		return
	selected_tiles = []
	update_ui()

func _play_tile_touch_se() -> void:
	AudioManager.play_se("se_tailetap")

func _can_accept_answer_toggle(toggle_key: String) -> bool:
	var now_msec: int = Time.get_ticks_msec()
	if toggle_key == _last_answer_toggle_key and now_msec - _last_answer_toggle_msec < ANSWER_TOGGLE_DEBOUNCE_MS:
		return false
	_last_answer_toggle_key = toggle_key
	_last_answer_toggle_msec = now_msec
	return true

# ============================================================
# 手牌で4枚使い切っている牌のリストを返す
# ============================================================
func _get_exhausted_tiles() -> Array:
	var count: Dictionary = {}
	for tile in current_hand:
		count[tile] = count.get(tile, 0) + 1
	var exhausted: Array = []
	for tile in count:
		if count[tile] >= 4:
			exhausted.append(tile)
	return exhausted

func _get_effective_correct_tiles() -> Array:
	var exhausted: Array = _get_exhausted_tiles()
	var effective_correct: Array = correct_tiles.filter(func(tile): return not (tile in exhausted))
	effective_correct.sort()
	return effective_correct

func _remove_exhausted_selected_tiles() -> void:
	if selected_tiles.is_empty() or selected_tiles[0] == -1:
		return
	var exhausted: Array = _get_exhausted_tiles()
	if exhausted.is_empty():
		return
	var filtered: Array = []
	for tile in selected_tiles:
		if not (tile in exhausted):
			filtered.append(tile)
	selected_tiles = filtered

func _force_exhausted_tile_question() -> void:
	if is_animating or is_game_over:
		return
	current_hand = [1, 1, 2, 2, 3, 3, 3, 3, 4, 5, 7, 8, 9]
	correct_tiles = MahjongLogic.find_waiting_tiles(current_hand)
	selected_tiles = []
	display_hand(current_hand)
	update_ui()
	update_debug_display()
	_start_question_clock()
	print("縲舌ョ繝舌ャ繧ｰ縲鞫ｯF6 4譫壻ｽｿ縺・・謇狗煙: ", current_hand, " 豁｣隗｣: ", correct_tiles, " 4譫壻ｽｿ縺・・ ", _get_exhausted_tiles())

func _force_clear_current_question() -> void:
	if is_animating or is_game_over:
		return
	print("【デバッグ】F2 強制クリア")
	stop_timer()
	_add_score_for_current_answer()
	current_question += 1
	_handle_correct_progress()

func _handle_correct_progress() -> void:
	if current_question >= total_questions:
		_complete_time_bonus_segment()
		if _is_tutorial_stage():
			_finish_tutorial_mode()
			SaveData.record_clear("tutorial")
			_show_clear_result(_tutorial_text("clear"))
			return
		if GameState.current_stage == "endless":
			_on_endless_block_clear()
			return

		if GameState.current_stage == "stage3":
			_record_result_high_score()
			SaveData.record_clear("stage3")
			GameState.came_from_stage3 = true
			_play_stage_transition("stage4", CUTIN_MIRAGE_CHARA_PATH)
			return

		elif GameState.current_stage == "stage4":
			SaveData.record_clear("stage4")
			_show_clear_result("真のクリア\nおめでとう")

		elif GameState.current_stage == "ex_stage3":
			_record_result_high_score()
			SaveData.record_clear("ex_stage3")
			_play_stage_transition("ex_stage4", CUTIN_NIGHTMARE_CHARA_PATH)
			return

		elif GameState.current_stage == "ex_stage4":
			SaveData.record_clear("ex_stage4")
			_show_clear_result("真のクリア\nおめでとう")

		elif GameState.current_stage == "custom":
			_show_clear_result("クリア\nおめでとう")

		else:
			SaveData.record_clear(GameState.current_stage)
			_show_clear_result("クリア\nおめでとう")
	else:
		popup_state = "correct"
		_setup_popup_buttons(popup_state)
		play_correct_sequence()

# ============================================================
# 提出・正誤判定
# ============================================================
func _on_submit_pressed() -> void:
	if is_animating or is_game_over:
		return
	if _is_tutorial_stage():
		_on_tutorial_submit_pressed()
		return
	if timer_enabled and time_left <= 0.0:
		on_time_up()
		return
	if selected_tiles.is_empty():
		return

	AudioManager.play_se("se_btntap")
	stop_timer()

	var effective_correct: Array = _get_effective_correct_tiles()

	var is_correct = false
	if selected_tiles[0] == -1:
		# 「なし」は、正解が空 または 使い切り牌を除いた正解が空なら正解
		is_correct = effective_correct.is_empty()
	else:
		var sorted_selected = selected_tiles.duplicate()
		sorted_selected.sort()
		# 完全一致（使い切り牌込みの正解）でも、使い切り牌を除いた正解でも正解
		is_correct = sorted_selected == effective_correct

	if is_correct:
		_add_score_for_current_answer()
		current_question += 1
		_handle_correct_progress()
	else:
		is_game_over = true
		_show_gameover_result()

# ============================================================
# endlessブロッククリア処理
# ============================================================
func _on_endless_block_clear() -> void:
	GameState.endless_total_question += total_questions
	var next_block: int = GameState.endless_block + 1
	if next_block == 3:
		_play_endless_phase_transition(next_block, CUTIN_MIRAGE_CHARA_PATH)
		return
	if next_block == 7:
		_play_endless_phase_transition(next_block, CUTIN_NIGHTMARE_CHARA_PATH)
		return
	GameState.endless_block = next_block

	# block 9 以降はEndlessループ継続。シーン再読み込み・難易度表示なし
	if GameState.endless_block >= 9:
		current_question = 0
		popup_state = "correct"
		_setup_popup_buttons(popup_state)
		play_correct_sequence()
		return

	get_tree().change_scene_to_file("res://game.tscn")

# ============================================================
# 正解演出シーケンス
# ============================================================
func _play_stage_transition(next_stage: String, chara_path: String) -> void:
	await _play_transition_cutin(chara_path)

	GameState.current_stage = next_stage
	GameState.phase_entry_fade_pending = true
	get_tree().change_scene_to_file("res://game.tscn")

func _play_endless_phase_transition(next_block: int, chara_path: String) -> void:
	await _play_transition_cutin(chara_path)

	GameState.endless_block = next_block
	GameState.phase_entry_fade_pending = true
	get_tree().change_scene_to_file("res://game.tscn")

func _play_transition_cutin(chara_path: String) -> void:
	is_animating = true
	selected_tiles = []
	update_ui()
	_sync_persistent_score_run()

	AudioManager.play_se("se_seikai")
	$PopupResult/PopupPanel.visible = false
	_apply_correct_result_image()
	$PopupResult/CorrectImage.visible = true
	$PopupResult/CorrectScore.visible = true
	_add_number_images($PopupResult/CorrectScore, last_question_score, 23.0, "w", "+")
	_play_correct_score_float()
	$PopupResult.visible = true
	_play_correct_faces(false)

	await get_tree().create_timer(0.85).timeout
	$PopupResult.visible = false
	$PopupResult/CorrectImage.visible = false
	$PopupResult/CorrectScore.visible = false
	AudioManager.stop_bgm()
	await _play_phase_cutin(chara_path, true)

func _play_phase_cutin(chara_path: String, keep_black: bool = false) -> void:
	if has_node("PhaseCutin"):
		return
	var was_animating: bool = is_animating
	is_animating = true
	var viewport_size: Vector2 = get_viewport_rect().size
	var overlay: Control = Control.new()
	overlay.name = "PhaseCutin"
	overlay.size = viewport_size
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	overlay.move_to_front()

	var dim: ColorRect = ColorRect.new()
	dim.size = viewport_size
	dim.color = Color(0.0, 0.0, 0.0, 0.0)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)

	var band_y: float = viewport_size.y * 0.30
	var band_h: float = 350.0
	var band: ColorRect = ColorRect.new()
	band.position = Vector2(-viewport_size.x, band_y)
	band.size = Vector2(viewport_size.x, band_h)
	band.color = Color(0.015, 0.015, 0.022, 0.94)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(band)

	var lightning_points := PackedVector2Array([
		Vector2(0.0, band_y + 190.0),
		Vector2(20.0, band_y + 190.0),
		Vector2(40.0, band_y + 190.0),
		Vector2(60.0, band_y + 190.0),
		Vector2(80.0, band_y + 190.0),
		Vector2(96.0, band_y + 190.0),
		Vector2(111.0, band_y + 190.0),
		Vector2(126.0, band_y + 190.0),
		Vector2(146.0, band_y + 190.0),
		Vector2(160.0, band_y + 190.0),
		Vector2(174.0, band_y + 190.0),
		Vector2(189.0, band_y + 190.0),
		Vector2(211.0, band_y + 190.0),
		Vector2(233.0, band_y + 190.0),
		Vector2(255.0, band_y + 190.0),
		Vector2(275.0, band_y + 190.0),
		Vector2(291.0, band_y + 190.0),
		Vector2(307.0, band_y + 190.0),
		Vector2(323.0, band_y + 190.0),
		Vector2(340.0, band_y + 190.0),
		Vector2(354.0, band_y + 190.0),
		Vector2(370.0, band_y + 190.0),
		Vector2(394.0, band_y + 190.0),
		Vector2(418.0, band_y + 190.0),
		Vector2(442.0, band_y + 190.0),
		Vector2(480.0, band_y + 190.0),
	])
	var lightning_glow: Line2D = Line2D.new()
	lightning_glow.width = 13.0
	lightning_glow.default_color = Color(0.36, 0.86, 1.0, 0.42)
	lightning_glow.antialiased = true
	var glow_gradient: Gradient = Gradient.new()
	glow_gradient.set_color(0, Color(0.55, 0.94, 1.0, 0.72))
	glow_gradient.set_color(1, Color(0.55, 0.94, 1.0, 0.72))
	lightning_glow.gradient = glow_gradient
	overlay.add_child(lightning_glow)

	var lightning_core: Line2D = Line2D.new()
	lightning_core.width = 3.0
	lightning_core.default_color = Color(1.0, 1.0, 1.0, 1.0)
	lightning_core.antialiased = true
	var core_gradient: Gradient = Gradient.new()
	core_gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	core_gradient.set_color(1, Color(1.0, 1.0, 1.0, 1.0))
	lightning_core.gradient = core_gradient
	overlay.add_child(lightning_core)

	var chara_texture: Texture2D = load(chara_path) as Texture2D if ResourceLoader.exists(chara_path) else null
	var chara_width: float = 230.0
	var chara_full_height: float = 491.0
	if chara_texture != null and chara_texture.get_width() > 0:
		chara_full_height = chara_width * float(chara_texture.get_height()) / float(chara_texture.get_width())
	var chara_visible_height: float = chara_full_height * 0.70
	var chara_render_width: float = chara_width * 2.0
	var chara_render_height: float = chara_full_height * 2.0
	var chara_mask: Control = Control.new()
	chara_mask.position = Vector2(0.0, band_y + 2.0)
	chara_mask.size = Vector2(chara_render_width, chara_visible_height)
	chara_mask.clip_contents = true
	chara_mask.modulate.a = 0.0
	chara_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(chara_mask)

	var chara: TextureRect = TextureRect.new()
	chara.size = Vector2(chara_render_width, chara_render_height)
	chara.position = Vector2(0.0, -chara_render_height * 0.20)
	chara.texture = chara_texture
	chara.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chara.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chara.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var chara_shader: Shader = Shader.new()
	chara_shader.code = """
shader_type canvas_item;

uniform float red_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float lightness = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	vec3 werewolf_red = vec3(
		min(1.0, lightness * 1.55 + 0.10),
		lightness * 0.13,
		lightness * 0.13
	);
	vec3 transformed = mix(source.rgb, werewolf_red, red_amount);
	COLOR = vec4(transformed, source.a) * COLOR;
}
"""
	var chara_material: ShaderMaterial = ShaderMaterial.new()
	chara_material.shader = chara_shader
	chara_material.set_shader_parameter("red_amount", 0.0)
	chara.material = chara_material
	chara_mask.add_child(chara)

	var band_intro: Tween = create_tween()
	AudioManager.play_se("koukaonrabo/ken")
	band_intro.set_parallel(true)
	band_intro.set_ease(Tween.EASE_OUT)
	band_intro.set_trans(Tween.TRANS_QUART)
	band_intro.tween_property(dim, "color:a", 0.42, 0.22)
	band_intro.tween_property(band, "position:x", 0.0, 0.30)
	await band_intro.finished

	const CHARA_FADE_IN_SECONDS := 0.65
	const LIGHTNING_STEP_SECONDS := 0.006
	const HOLD_SECONDS := 1.24
	const FADE_OUT_SECONDS := 0.65
	var motion_seconds: float = CHARA_FADE_IN_SECONDS \
		+ float(lightning_points.size()) * LIGHTNING_STEP_SECONDS \
		+ HOLD_SECONDS + FADE_OUT_SECONDS
	var chara_motion: Tween = create_tween()
	chara_motion.set_trans(Tween.TRANS_LINEAR)
	chara_motion.tween_property(chara_mask, "position:x", 10.0, motion_seconds)

	var chara_fade: Tween = create_tween()
	chara_fade.set_ease(Tween.EASE_OUT)
	chara_fade.set_trans(Tween.TRANS_SINE)
	chara_fade.tween_property(chara_mask, "modulate:a", 1.0, CHARA_FADE_IN_SECONDS)
	await chara_fade.finished

	AudioManager.play_se("koukaonrabo/dokun")
	var red_transform: Tween = create_tween()
	red_transform.set_ease(Tween.EASE_OUT)
	red_transform.set_trans(Tween.TRANS_CUBIC)
	red_transform.tween_property(
		chara_material,
		"shader_parameter/red_amount",
		1.0,
		0.20
	)
	var trail: Array[Vector2] = []
	var point_index: int = 0
	var draw_started_usec: int = Time.get_ticks_usec()
	while point_index < lightning_points.size():
		var draw_elapsed: float = float(Time.get_ticks_usec() - draw_started_usec) / 1000000.0
		var target_point_count: int = mini(
			lightning_points.size(),
			int(draw_elapsed / LIGHTNING_STEP_SECONDS) + 1
		)
		while point_index < target_point_count:
			trail.append(lightning_points[point_index])
			point_index += 1
		var visible_points := PackedVector2Array(trail)
		lightning_glow.points = visible_points
		lightning_core.points = visible_points
		await get_tree().process_frame
	await get_tree().create_timer(HOLD_SECONDS).timeout

	var outro: Tween = create_tween()
	outro.set_parallel(true)
	outro.set_ease(Tween.EASE_IN)
	outro.set_trans(Tween.TRANS_SINE)
	outro.tween_property(dim, "color:a", 1.0, FADE_OUT_SECONDS)
	outro.tween_property(band, "modulate:a", 0.0, FADE_OUT_SECONDS)
	outro.tween_property(chara_mask, "modulate:a", 0.0, FADE_OUT_SECONDS)
	outro.tween_property(lightning_glow, "modulate:a", 0.0, 0.20)
	outro.tween_property(lightning_core, "modulate:a", 0.0, 0.20)
	if keep_black:
		var transition_overlay: Node = get_node_or_null("/root/TransitionOverlay")
		if transition_overlay != null:
			transition_overlay.fade_to_black(FADE_OUT_SECONDS)
	await outro.finished
	if not keep_black:
		var preview_fade_in: Tween = create_tween()
		preview_fade_in.set_ease(Tween.EASE_OUT)
		preview_fade_in.set_trans(Tween.TRANS_SINE)
		preview_fade_in.tween_property(overlay, "modulate:a", 0.0, 0.65)
		await preview_fade_in.finished
		overlay.queue_free()
	is_animating = was_animating

func play_correct_sequence() -> void:
	is_animating = true
	selected_tiles = []
	update_ui()

	AudioManager.play_se("se_seikai")
	$PopupResult/PopupPanel.visible = false
	_apply_correct_result_image()
	$PopupResult/CorrectImage.visible = true
	$PopupResult/CorrectScore.visible = true
	_add_number_images($PopupResult/CorrectScore, last_question_score, 23.0, "w", "+")
	_play_correct_score_float()
	$PopupResult.visible = true

	_play_correct_faces()

	await get_tree().create_timer(1.0).timeout
	if is_game_over or popup_state == "wrong":
		is_animating = false
		return

	$PopupResult.visible = false
	$PopupResult/CorrectImage.visible = false
	$PopupResult/CorrectScore.visible = false
	await slide_hand_out()
	if is_game_over or popup_state == "wrong":
		is_animating = false
		return
	load_new_question()
	update_question_counter()
	await slide_hand_in()
	if _is_tutorial_stage():
		_update_tutorial_step()
	_start_question_clock()

	is_animating = false

	if timer_enabled:
		start_timer()

# ============================================================
# 手牌アニメーション
# ============================================================
func slide_hand_out() -> void:
	var hand_area = $HandArea
	var start_x = hand_area.position.x
	var end_x = start_x - get_viewport_rect().size.x
	var tween = create_tween()
	tween.tween_property(hand_area, "position:x", end_x, 0.3)
	await tween.finished
	hand_area.position.x = start_x

func slide_hand_in() -> void:
	var hand_area = $HandArea
	var home_x = 0.0
	var start_x = home_x + get_viewport_rect().size.x
	hand_area.position.x = start_x
	hand_area.visible = true
	var tween = create_tween()
	tween.tween_property(hand_area, "position:x", home_x, 0.3)
	await tween.finished

# ============================================================
# UI更新
# ============================================================
func update_ui() -> void:
	_remove_exhausted_selected_tiles()

	$Keypad/BtnSubmit.disabled = selected_tiles.is_empty()

	var has_number = not selected_tiles.is_empty() and selected_tiles[0] != -1
	$Keypad/BtnNone.disabled = has_number or not current_question_allows_none
	_update_none_button_availability_visual()

	var has_none = not selected_tiles.is_empty() and selected_tiles[0] == -1
	var exhausted: Array = _get_exhausted_tiles()
	for i in range(1, 10):
		var btn = $Keypad.get_node("Btn" + str(i))
		var is_exhausted: bool = i in exhausted
		btn.disabled = has_none or is_exhausted
		if is_exhausted:
			btn.modulate = Color(0.45, 0.45, 0.45, 0.75)
		elif i in selected_tiles:
			btn.modulate = Color(1.8, 1.4, 0.6)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)
	if _is_tutorial_stage():
		_apply_tutorial_input_gate(_get_tutorial_target_control())
		_update_none_button_availability_visual()
		_update_tutorial_spotlight()

func _update_none_button_availability_visual() -> void:
	if not has_node("Keypad/BtnNone"):
		return
	var btn_none := $Keypad/BtnNone as Button
	btn_none.modulate = _get_none_button_target_modulate()

func _is_none_selected() -> bool:
	return selected_tiles.size() == 1 and selected_tiles[0] == -1

func _get_none_button_target_modulate() -> Color:
	if _is_none_selected():
		return Color(1.18, 1.22, 1.65, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0) if current_question_allows_none else Color(1.0, 1.0, 1.0, 0.16)

# ============================================================
# 手牌表示
# ============================================================
func display_hand(hand: Array) -> void:
	for child in $HandArea/TileBoxRow1.get_children():
		child.queue_free()
	for child in $HandArea/TileBoxRow2.get_children():
		child.queue_free()

	var effective_stage := _get_effective_stage()
	var is_late_stage = (effective_stage == "stage3" or effective_stage == "stage4")
	var use_tall_tiles = _uses_tall_tile_hand()
	var small_size = is_late_stage and not use_tall_tiles

	var tile_w: int
	var tile_h: int
	var tile_gap: int = 4
	if use_tall_tiles:
		tile_w = TILE_W_TALL
		tile_h = TILE_H_TALL
		tile_gap = 1
	elif small_size:
		tile_w = TILE_W_SMALL
		tile_h = TILE_H_SMALL
	elif effective_stage == "stage2":
		tile_w = TILE_W_MID
		tile_h = TILE_H_MID
	else:
		tile_w = TILE_W
		tile_h = TILE_H

	$HandArea/TileBoxRow1.add_theme_constant_override("separation", tile_gap)
	$HandArea/TileBoxRow2.visible = false
	for i in range(hand.size()):
		var tile = hand[i]
		var flip_tile: bool = i < current_hand_flipped.size() and current_hand_flipped[i]
		var rect = make_tile_image(tile, tile_w, tile_h, flip_tile, use_tall_tiles)
		$HandArea/TileBoxRow1.add_child(rect)

func make_tile_image(tile: int, w: int, h: int, flipped: bool = false, use_tall_texture: bool = false) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	var texture_source: Array = tall_tile_textures if use_tall_texture else tile_textures
	rect.texture = texture_source[tile - 1]
	rect.custom_minimum_size = Vector2(w, h)
	rect.size = Vector2(w, h)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if flipped:
		rect.material = _get_upside_down_tile_material()
	return rect

func _get_upside_down_tile_material() -> ShaderMaterial:
	if upside_down_tile_material != null:
		return upside_down_tile_material
	var shader: Shader = Shader.new()
	shader.code = """
shader_type canvas_item;

void fragment() {
	vec4 source = texture(TEXTURE, vec2(1.0) - UV);
	COLOR = source;
}
"""
	upside_down_tile_material = ShaderMaterial.new()
	upside_down_tile_material.shader = shader
	return upside_down_tile_material

# ============================================================
# 「もう一度」ボタン
# ============================================================
func _start_next_stage_after_clear() -> void:
	var next_stage := _get_next_stage_after_clear()
	if next_stage == "":
		return
	if next_stage.begins_with("ex_"):
		SaveData.last_mode = "ex"
	else:
		SaveData.last_mode = "surface"
	SaveData.save()
	GameState.came_from_stage3 = false
	GameState.current_stage = next_stage
	if next_stage == "stage3" or next_stage == "ex_stage3":
		GameState.reset_run_score()
	var talk_scene_id := _get_stage_talk_scene_id(next_stage)
	if talk_scene_id != "":
		GameState.talk_scene_id = talk_scene_id
		GameState.talk_return_scene = "res://game.tscn"
		get_tree().change_scene_to_file("res://TalkScene.tscn")
		return
	GameState.talk_scene_id = ""
	GameState.talk_return_scene = ""
	get_tree().change_scene_to_file("res://game.tscn")

func _start_mirage_clear_talk() -> void:
	GameState.came_from_stage3 = false
	GameState.reset_run_score()
	GameState.talk_scene_id = "mirage_clear"
	GameState.talk_return_scene = "res://StageSelect.tscn"
	get_tree().change_scene_to_file("res://TalkScene.tscn")

func _start_nightmare_clear_talk() -> void:
	GameState.came_from_stage3 = false
	GameState.came_from_ex = true
	GameState.reset_run_score()
	GameState.talk_scene_id = "nightmare_clear"
	GameState.talk_return_scene = "res://StageSelect.tscn"
	get_tree().change_scene_to_file("res://TalkScene.tscn")

func _on_btn_retry_pressed() -> void:
	$PopupResult.visible = false
	selected_tiles = []

	if _is_mirage_clear_result():
		_start_mirage_clear_talk()
		return
	if _is_nightmare_clear_result():
		_start_nightmare_clear_talk()
		return

	if _should_show_next_stage_button():
		_start_next_stage_after_clear()
		return

	if GameState.current_stage == "ex_stage4":
		if popup_state == "wrong":
			GameState.reset_run_score()
			GameState.current_stage = "ex_stage3"
			get_tree().change_scene_to_file("res://game.tscn")
			return

	if popup_state == "clear":
		if GameState.current_stage == "endless":
			GameState.endless_block = 0
			GameState.endless_total_question = 0
			GameState.reset_run_score()
			get_tree().change_scene_to_file("res://game.tscn")
			return
		current_question = 0
		_reset_score_state()
		load_new_question()
		play_stage_bgm()
		update_question_counter()
		update_ui()
		_set_face($FaceMain, KAO_PYOKO_DEF)
		_set_face($FaceBoss, _get_boss_def_path())
		$HandArea.visible = false
		await play_intro()
		_start_question_clock()
		if timer_enabled:
			start_timer()
		return

	if GameState.current_stage == "endless":
		GameState.endless_block = 0
		GameState.endless_total_question = 0
		GameState.reset_run_score()
		get_tree().change_scene_to_file("res://game.tscn")
		return

	if GameState.current_stage == "stage4":
		GameState.came_from_stage3 = false
		GameState.reset_run_score()
		GameState.current_stage = "stage3"
		get_tree().change_scene_to_file("res://game.tscn")
		return

	current_question = 0
	_reset_score_state()
	load_new_question()
	play_stage_bgm()
	update_question_counter()
	update_ui()
	_set_face($FaceMain, KAO_PYOKO_DEF)
	_set_face($FaceBoss, _get_boss_def_path())
	$HandArea.visible = false
	await play_intro()
	_start_question_clock()
	if timer_enabled:
		start_timer()

# ============================================================
# 「ホーム」ボタン
# ============================================================
func _on_popup_btn_home_pressed() -> void:
	$PopupResult.visible = false

	if _is_mirage_clear_result():
		_start_mirage_clear_talk()
		return

	# いきなりゲームモードのゲームオーバー→タイトルへ
	if _is_nightmare_clear_result():
		_start_nightmare_clear_talk()
		return

	if GameState.is_instant_mode and (popup_state == "wrong" or is_gameover_result):
		GameState.is_instant_mode = false
		GameState.reset_run_score()
		get_tree().change_scene_to_file("res://Title.tscn")
		return

	if GameState.current_stage.begins_with("ex_"):
		GameState.came_from_ex = true
	if GameState.current_stage == "endless":
		GameState.came_from_ex = true
	if GameState.current_stage in ["stage3", "stage4", "ex_stage3", "ex_stage4", "endless"]:
		GameState.endless_block = 0
		GameState.endless_total_question = 0
		GameState.reset_run_score()
	get_tree().change_scene_to_file("res://StageSelect.tscn")

# ============================================================
# レイアウト切り替え
# ============================================================
func _on_btn_layout_pressed() -> void:
	if _can_use_tall_tiles():
		GameState.two_row_layout = not GameState.two_row_layout
		_update_tile_shape_button_state()
		display_hand(current_hand)
	return
	var effective_stage := _get_effective_stage()
	if effective_stage != "stage3" and effective_stage != "stage4":
		print("レイアウト切り替えはHard・Mirage相当難易度でのみ使えます")
		return
	GameState.two_row_layout = not GameState.two_row_layout
	display_hand(current_hand)

# ============================================================
# 設定ボタン
# ============================================================
func _on_btn_settings_pressed() -> void:
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	$SettingsPopup/VBox/BgmSlider.value = AudioManager.bgm_volume
	$SettingsPopup/VBox/SeSlider.value  = AudioManager.se_volume
	_sync_tile_suit_buttons()
	$SettingsPopup.visible = true

func _on_bgm_slider_changed(value: float) -> void:
	AudioManager.bgm_volume = value
	AudioManager.bgm_player.volume_db = linear_to_db(value)

func _on_se_slider_changed(value: float) -> void:
	AudioManager.se_volume = value

func _on_language_button_pressed(code: String) -> void:
	SaveData.set_language_code(code)
	TranslationServer.set_locale(SaveData.language_code)
	PopupSkin.ensure_settings_language_controls($SettingsPopup, Callable(self, "_on_language_button_pressed"))
	PopupSkin.apply_settings_popup($SettingsPopup)
	PopupSkin.refresh_settings_language($SettingsPopup)
	_refresh_localized_game_images()
	update_timer_display()
	if _is_tutorial_stage() and tutorial_layer != null:
		_update_tutorial_step()
	AudioManager.play_se("se_btntap")

func _on_btn_settings_close_pressed() -> void:
	$SettingsPopup.visible = false

# ============================================================
# TopBarのホームボタン
# ============================================================
func _on_btn_home_pressed() -> void:
	PopupSkin.apply_home_confirm_popup($HomeConfirmPopup)
	_setup_home_confirm_feedback_targets()
	$HomeConfirmPopup.visible = true

func _on_btn_confirm_yes_pressed() -> void:
	GameState.came_from_stage3 = false
	if GameState.is_instant_mode:
		GameState.is_instant_mode = false
		GameState.reset_run_score()
		get_tree().change_scene_to_file("res://Title.tscn")
		return
	if GameState.current_stage.begins_with("ex_") or GameState.current_stage == "endless":
		GameState.came_from_ex = true
	if GameState.current_stage in ["stage3", "stage4", "ex_stage3", "ex_stage4", "endless"]:
		GameState.endless_block = 0
		GameState.endless_total_question = 0
		GameState.reset_run_score()
	get_tree().change_scene_to_file("res://StageSelect.tscn")

func _on_btn_confirm_no_pressed() -> void:
	$HomeConfirmPopup.visible = false


func _setup_home_confirm_feedback_targets() -> void:
	var panel := $HomeConfirmPopup as Panel
	_setup_home_confirm_feedback_target(panel, "BtnConfirmYes", "ConfirmYesFeedback")
	_setup_home_confirm_feedback_target(panel, "BtnConfirmNo", "ConfirmNoFeedback")


func _setup_home_confirm_feedback_target(panel: Panel, button_name: String, target_name: String) -> void:
	var button := panel.get_node_or_null(button_name) as Button
	if button == null:
		return
	var old_target := panel.get_node_or_null(target_name) as Control
	if old_target != null:
		old_target.visible = false
	ButtonFeedback.set_target(button, button)

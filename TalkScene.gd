extends Control

signal end_logo_advance_requested

const PopupSkin := preload("res://PopupSkin.gd")
const ButtonFeedback := preload("res://ButtonFeedback.gd")
const TalkLocalization := preload("res://TalkLocalization.gd")

const FONT_PATH := "res://assets/font/font_1_kokumr_1.00_rls.ttf"
const BG_TUTORIAL := "res://assets/bg/bg_sentaku_generated_screen.webp"
const BG_STAGE1 := "res://assets/bg/bg_yume.webp"
const BG_STAGE2 := "res://assets/bg/bg_ututu.webp"
const BG_STAGE3 := "res://assets/bg/bg_maboro_toku.webp"
const BG_EX_STAGE1 := "res://assets/bg/bg_yumeex.webp"
const BG_EX_STAGE2 := "res://assets/bg/bg_ututuex.webp"
const BG_EX_STAGE3 := "res://assets/bg/bg_maboro_toku.webp"
const BG_MIRAGE_CLEAR := "res://assets/bg/bg_mabo_asa.webp"
const END_IMAGE := "res://assets/ui/ending_end_generated.webp"
const LOCALIZED_ENDING_DIR := "res://assets/language/normalized/%s/ending/"
const BG_BASE_SCALE := Vector2(1.5, 1.5)
const BG_SPOTLIGHT_SCALE := Vector2(1.65, 1.65)
const ADVANCE_INPUT_COOLDOWN_MS := 180
const MABOROSHI_Y_OFFSET := -48.0
const PYOKO_HEIGHT_MULTIPLIER := 1.0
const PYOKO_WIDTH_MULTIPLIER := 0.48
const MABOROSHI_HEIGHT_MULTIPLIER := 1.12
const MABOROSHI_WIDTH_MULTIPLIER := 0.5
const YUME_TEXTURE_WIDTH_MULTIPLIER := 0.644
const YUME_HEIGHT_MULTIPLIER := 1.18
const UTUTU_HEIGHT_MULTIPLIER := 1.0
const UTUTU_WIDTH_MULTIPLIER := 0.59
const YUME_VISIBLE_RIGHT_MARGIN_RATIO := 160.0 / 644.0
const LEFT_INACTIVE_OFFSET := Vector2(-54.0, 18.0)
const RIGHT_INACTIVE_OFFSET := Vector2(54.0, 18.0)
const DEFAULT_INACTIVE_OFFSET := Vector2(0.0, 18.0)
const CHARA_PYOKO_DEFAULT := "res://assets/chara/pyokoyahho.webp"
const CHARA_PYOKO_1 := "res://assets/chara/pyoko1.webp"
const CHARA_PYOKO_2 := "res://assets/chara/pyoko2.webp"
const CHARA_PYOKO_NARUHODO := "res://assets/chara/pyokonaruhodo.webp"
const CHARA_PYOKO_DEF := "res://assets/chara/pyokodef.webp"
const CHARA_PYOKO_NIKO := "res://assets/chara/pyokoniko.webp"
const CHARA_PYOKO_NIYAKE := "res://assets/chara/pyokoniyake.webp"
const CHARA_PYOKO_ASERI := "res://assets/chara/pyokoaseri.webp"
const CHARA_PYOKO_ASERI2 := "res://assets/chara/pyokoaseri2.webp"
const CHARA_PYOKO_TAIHEN := "res://assets/chara/pyokotaihen.webp"
const CHARA_PYOKO_TIKAI := "res://assets/chara/pyokotikai.webp"
const CHARA_PYOKO_SEIKAI1 := "res://assets/chara/pyokoseikai1.webp"
const CHARA_PYOKO_SEIKAI2 := "res://assets/chara/pyokoseikai2.webp"
const CHARA_PYOKO_SEIKAI3 := "res://assets/chara/pyokoseikai3.webp"
const CHARA_PYOKO_GAMEOVER2 := "res://assets/chara/pyokogameover2.webp"
const CHARA_PYOKO_GAMEOVER3 := "res://assets/chara/pyokogameover3.webp"
const CHARA_PYOKO_GAMEOVER4 := "res://assets/chara/pyokogameover4.webp"
const CHARA_MABOROSHI_DEFAULT := "res://assets/chara/mabo_kawa.webp"
const CHARA_MABOROSHI_DEF := "res://assets/chara/mabo_def.webp"
const CHARA_MABOROSHI_MUSU := "res://assets/chara/mabo_musu.webp"
const CHARA_MABOROSHI_OMOSIROI := "res://assets/chara/mabo_omosiroi.webp"
const CHARA_MABOROSHI_SIKATANASI2 := "res://assets/chara/mabo_sikatanasi2.webp"
const CHARA_YUME_DEFAULT := "res://assets/chara/yume_def.webp"
const CHARA_YUME_WORRIED := "res://assets/chara/yume_awawa.webp"
const CHARA_YUME_AWAWA2 := "res://assets/chara/yume_awawa2.webp"
const CHARA_YUME_SMILE := "res://assets/chara/yume_warai.webp"
const CHARA_YUME_SPARKLE2 := "res://assets/chara/yume_kirakira2.webp"
const CHARA_YUME_GAAN := "res://assets/chara/yume_ga-n.webp"
const CHARA_YUME_SMILE2 := "res://assets/chara/yume_warai2.webp"
const CHARA_YUME_SPARKLE_A := "res://assets/chara/yume_kirakiraa.webp"
const CHARA_YUME_GAKKARI := "res://assets/chara/yume_gakkari.webp"
const CHARA_YUME_NEMU2 := "res://assets/chara/yume_nemu2.webp"
const CHARA_UTUTU_KORA2 := "res://assets/chara/ututu2_kora2.webp"
const CHARA_UTUTU_YABA := "res://assets/chara/ututu2_yaba.webp"
const CHARA_UTUTU_MAZU := "res://assets/chara/ututu2_mazu.webp"
const CHARA_UTUTU_MAKE := "res://assets/chara/ututu2_make.webp"
const CHARA_UTUTU_KORA := "res://assets/chara/ututu2_kora.webp"
const CHARA_UTUTU_DEFAULT := "res://assets/chara/ututu2_def.webp"
const CHARA_UTUTU_IRA3A := "res://assets/chara/ututu2_ira3a.webp"
const CHARA_UTUTU_SIITAKE := "res://assets/chara/ututu2_siitake.webp"
const ICON_SETTINGS := "res://assets/bg/music_icon_settings_ui.webp"
const ICON_HOME := "res://assets/bg/music_icon_home_ui.webp"
const TILE_SUIT_SELECTOR_SCRIPT := preload("res://TileSuitSelector.gd")

const SPEAKER_PYOKO := "pyoko"
const SPEAKER_MABOROSHI := "maboroshi"
const SPEAKER_YUME := "yume"
const SPEAKER_UTUTU := "ututu"

const TUTORIAL_INTRO_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "ぼくの名前はぴょこたん！\nどこにでもいる普通の男の子なのだ！",
		"portrait": CHARA_PYOKO_DEFAULT,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "実は最近、気になっている女の子がいるのだ…",
		"portrait": CHARA_PYOKO_NARUHODO,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "ぴょこたん",
		"text": "幻朧（まぼろし）ちゃん。\nミステリアスで素敵なのだ！",
		"portrait": CHARA_MABOROSHI_DEFAULT,
		"transition": "spotlight_maboroshi",
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "まぼろしちゃんは麻雀好きという噂を耳にしたのだ。\nぼくも、がんばって麻雀を覚えたのだ！",
		"portrait": CHARA_PYOKO_NARUHODO,
		"transition": "back_to_pyoko",
		"hide_other": true,
		"finish": "whiteout",
	},
]
const STAGE1_INTRO_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "あれ、まぼろしちゃんを見失っちゃったのだ。\nこっちの方に歩いて行ったようにみえたけど……",
		"portrait": CHARA_PYOKO_NARUHODO,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "あれ、君。\nこの先は私有地だから入っちゃ駄目だよ。",
		"portrait": CHARA_YUME_SMILE,
		"transition": "yume_slide_in",
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "こんにちはお姉さん。\nぼくの名前はぴょこたんなのだ！",
		"portrait": CHARA_PYOKO_2,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "こんにちは、ぴょこたん。\n挨拶できてえらいねー。私は夢幽（ゆめ）だよ。",
		"portrait": CHARA_YUME_SPARKLE2,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "この山はね、うちの一族のおうちなの。\n危ないから、勝手に入っちゃ駄目だよ。",
		"portrait": CHARA_YUME_DEFAULT,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "でも、ぼくの友達がこの先に行くのを見たのだ！",
		"portrait": CHARA_PYOKO_TIKAI,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "え、本当？　おかしいな、\nお母さんしか来てないはずだけど……",
		"portrait": CHARA_YUME_WORRIED,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "もしかして見逃しちゃったのかな。\nどうしよう、お姉ちゃんに怒られちゃう……",
		"portrait": CHARA_YUME_GAAN,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "安心して、お姉さん！\n僕が責任を持って探してくるのだ！",
		"portrait": CHARA_PYOKO_SEIKAI3,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "ありがとう、ぴょこたん。\nでも心配だな。ぴょこたんは麻雀ってわかる？",
		"portrait": CHARA_YUME_SMILE2,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "麻雀！　知っているのだ！",
		"portrait": CHARA_PYOKO_1,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "でも、ちょっとしか知らないのだ。",
		"portrait": CHARA_PYOKO_NIKO,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "そっか。この先はお姉ちゃんもいるし、\n危険だからちょっとだけコツを教えてあげるね。",
		"portrait": CHARA_YUME_SPARKLE_A,
		"finish": "whiteout",
	},
]
const STAGE2_INTRO_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "暗くなってきたのだ……",
		"portrait": CHARA_PYOKO_NIKO,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "ちょっとちょっと！\nなに勝手にうちの山に入ってきてんのよ、ガキんちょ！",
		"portrait": CHARA_UTUTU_KORA2,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "こんにちはお姉さん。\nぼくの名前はぴょこたんなのだ！",
		"portrait": CHARA_PYOKO_2,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "は～？　誰もあんたの名前なんか聞いてないんだけど～？",
		"portrait": CHARA_UTUTU_MAZU,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "ふほーしんにゅーよ、ふほーしんにゅー。\nさっさと帰んなさい！",
		"portrait": CHARA_UTUTU_MAKE,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "このお姉さんは怖い人なのだ……",
		"portrait": CHARA_PYOKO_ASERI,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "お姉ちゃん。この子の友達がこっちに来たらしいんだけど、見てない？",
		"portrait": CHARA_YUME_SMILE2,
		"transition": "yume_left_slide_in",
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "はー？　ママしか来てないに決まってるじゃん。\nあんた何言ってるの？",
		"portrait": CHARA_UTUTU_KORA,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "ま、退屈してたとこだし？\n麻雀で私に勝てたら見逃してあげるわ。",
		"portrait": CHARA_UTUTU_DEFAULT,
		"finish": "whiteout",
	},
]
const STAGE3_INTRO_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "ママ～！\nなんか変な奴がきた！",
		"portrait": CHARA_UTUTU_YABA,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "なんだ現棘、騒がしいな。",
		"portrait": CHARA_MABOROSHI_DEF,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "あ、まぼろしちゃん！\nやっと見つけたのだー！",
		"portrait": CHARA_PYOKO_SEIKAI2,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "貴様は……",
		"portrait": CHARA_MABOROSHI_MUSU,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "え、お母さん。\nこの子知ってるの？",
		"portrait": CHARA_YUME_AWAWA2,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "わしが通ってる園で噂になっている男だ。",
		"portrait": CHARA_MABOROSHI_MUSU,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "確か、両親の金を使い込んで\n実家を出禁になってしまった男……\nぴょこたん！",
		"portrait": CHARA_MABOROSHI_SIKATANASI2,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "な、なんでぼくの秘密を知っているのだー！",
		"portrait": CHARA_PYOKO_GAMEOVER4,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "まぁいいのだ。\n今日は遊びにきたのだ。\nまぼろしちゃん、僕と麻雀で勝負なのだ！",
		"portrait": CHARA_PYOKO_SEIKAI3,
		"finish": "whiteout",
	},
]
const EX_STAGE1_INTRO_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "また来ちゃったのだ。\nまぼろしちゃんと麻雀で遊ぶのだー！",
		"portrait": CHARA_PYOKO_SEIKAI2,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "あれ？\nまだお昼なのに妙に暗い気がするのだ。",
		"portrait": CHARA_PYOKO_NIKO,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "侵入者……",
		"portrait": CHARA_YUME_GAKKARI,
		"transition": "yume_slide_in",
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "あ、優しい方のお姉さん！\nぴょこたんなのだ！　また遊びに来たのだー！",
		"portrait": CHARA_PYOKO_2,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "人間……\n排除しなきゃ……",
		"portrait": CHARA_YUME_NEMU2,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "お姉さんの様子が何かおかしいのだ……？",
		"portrait": CHARA_PYOKO_ASERI2,
		"finish": "whiteout",
	},
]
const EX_STAGE2_INTRO_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "不気味なのだ……\n前来た時と様子が全然違うのだ。",
		"portrait": CHARA_PYOKO_TAIHEN,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "ガキんちょ……！\nなんであんたがここにいるのよ！",
		"portrait": CHARA_UTUTU_IRA3A,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "あ、怖い方のお姉さんなのだ。",
		"portrait": CHARA_PYOKO_ASERI,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "まぁいいわ。\nちょっとイライラしてたから、私が特別に遊んであげる。今日は手加減なしよ！",
		"portrait": CHARA_UTUTU_SIITAKE,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "わー！　いじめられるのだー！",
		"portrait": CHARA_PYOKO_GAMEOVER4,
		"finish": "whiteout",
	},
]
const EX_STAGE3_INTRO_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "なんとか山頂にこれたのだ……",
		"portrait": CHARA_PYOKO_GAMEOVER2,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "ふん。\nよくここまでこれたな。",
		"portrait": CHARA_MABOROSHI_DEF,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "あ、まぼろしちゃん！\n遊ぼうなのだー！",
		"portrait": CHARA_PYOKO_SEIKAI2,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "面白い。いいだろう。\n貴様には、わしの相手をする資格がある……！",
		"portrait": CHARA_MABOROSHI_OMOSIROI,
		"finish": "whiteout",
	},
]
const MIRAGE_CLEAR_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "つ、ついにクリアしたのだ……\nこれでぼくも一人前の麻雀打ちなのだ！",
		"portrait": CHARA_PYOKO_GAMEOVER3,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "やるな、出禁男。\n少しは認めてやってもいい。",
		"portrait": CHARA_MABOROSHI_OMOSIROI,
	},
	{
		"speaker": SPEAKER_YUME,
		"name": "夢幽（ゆめ）",
		"text": "すごいよ、ぴょこたん！\nこれで清一色は完璧だね！",
		"portrait": CHARA_YUME_SPARKLE2,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "ちょっとはやるじゃない。\nところで、両親のお金を使い込んだって話だけど、何に使ったの？",
		"portrait": CHARA_UTUTU_DEFAULT,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "ぼくはぱちすろが大好きなのだ！",
		"portrait": CHARA_PYOKO_SEIKAI1,
	},
	{
		"speaker": SPEAKER_UTUTU,
		"name": "現棘（うつつ）",
		"text": "あ、そう。",
		"portrait": CHARA_UTUTU_MAZU,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "これなら、また麻雀の相手をしてやってもいいぞ。\n好きな時に遊びに来い。",
		"portrait": CHARA_MABOROSHI_DEF,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "やったのだー！　また遊びに来るのだー！",
		"portrait": CHARA_PYOKO_SEIKAI2,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "ただ、満月の日はやめておけ。\nわしはまだしも、娘たちはまだ人狼としては未熟な身。手荒な歓迎になりかねないからな。",
		"portrait": CHARA_MABOROSHI_OMOSIROI,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "？\nわかったのだー！",
		"portrait": CHARA_PYOKO_1,
	},
]
const NIGHTMARE_CLEAR_LINES: Array[Dictionary] = [
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "……！！",
		"portrait": CHARA_MABOROSHI_MUSU,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "や、やった……",
		"portrait": CHARA_PYOKO_DEF,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "ついにクリアできたのだー！！",
		"portrait": CHARA_PYOKO_SEIKAI2,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "やるじゃないか。\n麻雀のプロでさえ、容易にはクリアできない難易度だったはずだが……",
		"portrait": CHARA_MABOROSHI_OMOSIROI,
	},
	{
		"speaker": SPEAKER_MABOROSHI,
		"name": "幻朧（まぼろし）",
		"text": "『清一色マスター』の称号をくれてやる。園で自慢してくるといい。",
		"portrait": CHARA_MABOROSHI_DEF,
	},
	{
		"speaker": SPEAKER_PYOKO,
		"name": "ぴょこたん",
		"text": "清一色マスター……\n良い響きなのだー！",
		"portrait": CHARA_PYOKO_NIYAKE,
		"finish": "end_logo",
	},
]

var _lines: Array[Dictionary] = []
var _line_index: int = 0
var _font: FontFile = null
var _bg: TextureRect = null
var _shade: ColorRect = null
var _pyoko: TextureRect = null
var _maboroshi: TextureRect = null
var _side_yume: TextureRect = null
var _mirage_clear_right_speaker: String = ""
var _left_character_speaker: String = SPEAKER_PYOKO
var _right_character_speaker: String = SPEAKER_MABOROSHI
var _side_character_speaker: String = SPEAKER_YUME
var _talk_panel: Panel = null
var _name_panel: Panel = null
var _name_label: Label = null
var _body_label: Label = null
var _next_mark: Label = null
var _home_button: Button = null
var _settings_button: Button = null
var _skip_button: Button = null
var _settings_popup: Panel = null
var _settings_overlay: Button = null
var _language_buttons: Dictionary = {}
var _home_confirm_popup: Panel = null
var _home_confirm_overlay: Button = null
var _whiteout: ColorRect = null
var _end_image: TextureRect = null
var _is_animating: bool = false
var _is_finishing_scene: bool = false
var _waiting_for_end_logo_input: bool = false
var _last_advance_input_msec: int = -100000
var _ui_hidden: bool = false


func _ready() -> void:
	_lines = _get_lines_for_scene(GameState.talk_scene_id)
	if _lines.is_empty():
		_go_next_scene()
		return
	_play_talk_bgm()
	_font = load(FONT_PATH) as FontFile
	_build_ui()
	_layout_ui()
	_apply_text_language()
	ButtonFeedback.install(self)
	_show_line(0, false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		if _bg == null or _pyoko == null or _maboroshi == null or _side_yume == null or _talk_panel == null:
			return
		_layout_ui()
		_apply_speaker_focus(_get_current_speaker(), false)


func _input(event: InputEvent) -> void:
	if _waiting_for_end_logo_input:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			end_logo_advance_requested.emit()
			get_viewport().set_input_as_handled()
		elif event is InputEventScreenTouch and event.pressed:
			end_logo_advance_requested.emit()
			get_viewport().set_input_as_handled()
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			end_logo_advance_requested.emit()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_toggle_ui_hidden()
			get_viewport().set_input_as_handled()
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if _is_ui_point(event.position):
			return
		_try_advance_from_input()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		if _is_ui_point(event.position):
			return
		_try_advance_from_input()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
			_try_advance_from_input()
			get_viewport().set_input_as_handled()


func _get_lines_for_scene(scene_id: String) -> Array[Dictionary]:
	match scene_id:
		"tutorial_intro":
			return TUTORIAL_INTRO_LINES.duplicate(true)
		"stage1_intro":
			return STAGE1_INTRO_LINES.duplicate(true)
		"stage2_intro":
			return STAGE2_INTRO_LINES.duplicate(true)
		"stage3_intro":
			return STAGE3_INTRO_LINES.duplicate(true)
		"ex_stage1_intro":
			return EX_STAGE1_INTRO_LINES.duplicate(true)
		"ex_stage2_intro":
			return EX_STAGE2_INTRO_LINES.duplicate(true)
		"ex_stage3_intro":
			return EX_STAGE3_INTRO_LINES.duplicate(true)
		"mirage_clear":
			return MIRAGE_CLEAR_LINES.duplicate(true)
		"nightmare_clear":
			return NIGHTMARE_CLEAR_LINES.duplicate(true)
		_:
			return []


func _play_talk_bgm() -> void:
	var bgm_filename := _get_bgm_for_scene(GameState.talk_scene_id)
	if bgm_filename == "":
		return
	AudioManager.play_bgm(bgm_filename)


func _get_bgm_for_scene(scene_id: String) -> String:
	match scene_id:
		"tutorial_intro":
			return "bgm_talk_tutorial"
		"stage1_intro", "ex_stage1_intro":
			return "bgm_talk_easy"
		"stage2_intro", "ex_stage2_intro":
			return "bgm_talk_normal"
		"stage3_intro", "ex_stage3_intro":
			return "bgm_talk_hard"
		"mirage_clear", "nightmare_clear":
			return "bgm_t_title"
		_:
			return ""


func _get_background_path() -> String:
	match GameState.talk_scene_id:
		"stage1_intro":
			return BG_STAGE1
		"stage2_intro":
			return BG_STAGE2
		"stage3_intro":
			return BG_STAGE3
		"ex_stage1_intro":
			return BG_EX_STAGE1
		"ex_stage2_intro":
			return BG_EX_STAGE2
		"ex_stage3_intro":
			return BG_EX_STAGE3
		"mirage_clear":
			return BG_MIRAGE_CLEAR
		"nightmare_clear":
			return BG_MIRAGE_CLEAR
		_:
			return BG_TUTORIAL


func _is_yume_scene() -> bool:
	return GameState.talk_scene_id == "stage1_intro" or GameState.talk_scene_id == "ex_stage1_intro"


func _is_tutorial_scene() -> bool:
	return GameState.talk_scene_id == "tutorial_intro"


func _is_stage2_scene() -> bool:
	return GameState.talk_scene_id == "stage2_intro" or GameState.talk_scene_id == "ex_stage2_intro"


func _is_stage3_scene() -> bool:
	return GameState.talk_scene_id == "stage3_intro" or GameState.talk_scene_id == "ex_stage3_intro"


func _is_mirage_clear_scene() -> bool:
	return GameState.talk_scene_id == "mirage_clear"


func _is_final_clear_scene() -> bool:
	return GameState.talk_scene_id == "mirage_clear" or GameState.talk_scene_id == "nightmare_clear"


func _build_ui() -> void:
	_bg = TextureRect.new()
	_bg.name = "Background"
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_path := _get_background_path()
	if ResourceLoader.exists(bg_path):
		_bg.texture = load(bg_path)
	add_child(_bg)

	_shade = ColorRect.new()
	_shade.name = "SceneShade"
	_shade.color = Color(0.03, 0.02, 0.05, 0.24)
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shade)

	_maboroshi = _make_character("Maboroshi", CHARA_MABOROSHI_DEFAULT)
	_pyoko = _make_character("Pyoko", CHARA_PYOKO_DEFAULT)
	_side_yume = _make_character("SideYume", CHARA_YUME_SMILE2)
	_maboroshi.visible = false
	_side_yume.visible = false
	add_child(_side_yume)
	add_child(_maboroshi)
	add_child(_pyoko)

	_talk_panel = Panel.new()
	_talk_panel.name = "TalkPanel"
	_talk_panel.z_index = 10
	_talk_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.025, 0.04, 0.88), Color(1.0, 0.76, 0.34, 0.75), 4.0, 10))
	add_child(_talk_panel)

	_name_panel = Panel.new()
	_name_panel.name = "NamePanel"
	_name_panel.z_index = 11
	_name_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.44, 0.12, 0.18, 0.94), Color(1.0, 0.82, 0.42, 0.85), 3.0, 8))
	add_child(_name_panel)

	_name_label = Label.new()
	_name_label.name = "NameLabel"
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_apply_label_font(_name_label, 24)
	_name_panel.add_child(_name_label)

	_body_label = Label.new()
	_body_label.name = "BodyLabel"
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_body_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88))
	_body_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_body_label.add_theme_constant_override("shadow_offset_x", 2)
	_body_label.add_theme_constant_override("shadow_offset_y", 2)
	_apply_label_font(_body_label, 25)
	_talk_panel.add_child(_body_label)

	_next_mark = Label.new()
	_next_mark.name = "NextMark"
	_next_mark.text = ">"
	_next_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_next_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_next_mark.add_theme_color_override("font_color", Color(1.0, 0.84, 0.4))
	_apply_label_font(_next_mark, 26)
	_talk_panel.add_child(_next_mark)

	_home_button = _make_icon_button("BtnHome", ICON_HOME)
	_home_button.pressed.connect(_on_home_pressed)
	add_child(_home_button)

	_settings_button = _make_icon_button("BtnSettings", ICON_SETTINGS)
	_settings_button.pressed.connect(_on_settings_pressed)
	add_child(_settings_button)

	_skip_button = Button.new()
	_skip_button.name = "BtnSkip"
	_skip_button.text = "SKIP"
	_skip_button.z_index = 13
	_skip_button.focus_mode = Control.FOCUS_NONE
	_skip_button.add_theme_font_size_override("font_size", 20)
	_skip_button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82))
	_skip_button.add_theme_color_override("font_hover_color", Color(1.0, 0.84, 0.38))
	_skip_button.add_theme_color_override("font_pressed_color", Color(0.2, 0.1, 0.04))
	_skip_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.03, 0.025, 0.04, 0.68), Color(1.0, 0.76, 0.34, 0.7)))
	_skip_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.1, 0.06, 0.08, 0.78), Color(1.0, 0.84, 0.38, 0.9)))
	_skip_button.add_theme_stylebox_override("pressed", _make_button_style(Color(1.0, 0.75, 0.28, 0.82), Color(1.0, 0.92, 0.55, 0.9)))
	_skip_button.pressed.connect(_on_skip_pressed)
	add_child(_skip_button)

	_build_settings_popup()
	_build_home_confirm_popup()

	_whiteout = ColorRect.new()
	_whiteout.name = "Whiteout"
	_whiteout.color = Color(1.0, 1.0, 1.0, 0.0)
	_whiteout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_whiteout.z_index = 20
	add_child(_whiteout)

	_end_image = TextureRect.new()
	_end_image.name = "EndImage"
	_end_image.visible = false
	_end_image.modulate.a = 0.0
	_end_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_end_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_end_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_image.z_index = 21
	var end_image_path := _localized_ending_path("ending_end_generated.webp", END_IMAGE)
	if ResourceLoader.exists(end_image_path):
		_end_image.texture = load(end_image_path)
	add_child(_end_image)


func _localized_ending_path(file_name: String, fallback_path: String) -> String:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if locale == "ja":
		return fallback_path
	var localized_path := (LOCALIZED_ENDING_DIR % locale) + file_name
	if ResourceLoader.exists(localized_path):
		return localized_path
	return fallback_path


func _make_character(node_name: String, path: String) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(path):
		rect.texture = load(path)
	return rect


func _make_icon_button(node_name: String, icon_path: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = ""
	button.flat = true
	button.z_index = 13
	button.focus_mode = Control.FOCUS_NONE
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if ResourceLoader.exists(icon_path):
		button.icon = load(icon_path)
	return button


func _build_settings_popup() -> void:
	_settings_overlay = Button.new()
	_settings_overlay.name = "SettingsOverlay"
	_settings_overlay.visible = false
	_settings_overlay.flat = true
	_settings_overlay.text = ""
	_settings_overlay.focus_mode = Control.FOCUS_NONE
	_settings_overlay.z_index = 14
	_settings_overlay.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_settings_overlay.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_settings_overlay.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_settings_overlay.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_settings_overlay.pressed.connect(_on_settings_close_pressed)
	add_child(_settings_overlay)

	_settings_popup = Panel.new()
	_settings_popup.name = "SettingsPopup"
	_settings_popup.visible = false
	_settings_popup.z_index = 15
	add_child(_settings_popup)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 10)
	_settings_popup.add_child(vbox)

	var bgm_label := Label.new()
	bgm_label.name = "LabelBgm"
	bgm_label.text = "BGM"
	bgm_label.add_theme_font_size_override("font_size", 26)
	vbox.add_child(bgm_label)

	var bgm_slider := HSlider.new()
	bgm_slider.name = "BgmSlider"
	bgm_slider.custom_minimum_size = Vector2(0.0, 40.0)
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.01
	bgm_slider.value = 0.3
	bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	vbox.add_child(bgm_slider)

	var se_label := Label.new()
	se_label.name = "LabelSe"
	se_label.text = "SE"
	se_label.add_theme_font_size_override("font_size", 26)
	vbox.add_child(se_label)

	var se_slider := HSlider.new()
	se_slider.name = "SeSlider"
	se_slider.custom_minimum_size = Vector2(0.0, 32.0)
	se_slider.min_value = 0.0
	se_slider.max_value = 1.0
	se_slider.step = 0.01
	se_slider.value = 0.5
	se_slider.value_changed.connect(_on_se_slider_changed)
	vbox.add_child(se_slider)

	var tile_label := Label.new()
	tile_label.name = "LabelTileSuit"
	tile_label.text = "牌の種類"
	tile_label.add_theme_font_size_override("font_size", 22)
	vbox.add_child(tile_label)

	var tile_grid := GridContainer.new()
	tile_grid.name = "TileSuitGrid"
	tile_grid.columns = 2
	tile_grid.add_theme_constant_override("h_separation", 8)
	tile_grid.add_theme_constant_override("v_separation", 4)
	tile_grid.set_script(TILE_SUIT_SELECTOR_SCRIPT)
	tile_grid.set("disable_manzu2_when_sorted_stage", true)
	for button_name in ["BtnPinzu", "BtnSouzu", "BtnManzu", "BtnManzu2"]:
		var check := CheckBox.new()
		check.name = button_name
		check.custom_minimum_size = Vector2(150.0, 38.0)
		check.add_theme_font_size_override("font_size", 20)
		tile_grid.add_child(check)
	tile_grid.connect("tile_suit_changed", Callable(self, "_on_tile_suit_changed"))
	vbox.add_child(tile_grid)

	var language_label := Label.new()
	language_label.name = "LabelLanguage"
	language_label.text = TalkLocalization.ui_text(SaveData.language_code, "language")
	language_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(language_label)

	var language_grid := GridContainer.new()
	language_grid.name = "LanguageGrid"
	language_grid.columns = 2
	language_grid.add_theme_constant_override("h_separation", 8)
	language_grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(language_grid)

	_language_buttons.clear()
	var language_group := ButtonGroup.new()
	for option in TalkLocalization.LANGUAGE_OPTIONS:
		var code: String = option["code"]
		var button := CheckBox.new()
		button.name = "BtnLanguage" + code.replace("_", "")
		button.text = str(option["label"])
		button.button_group = language_group
		button.custom_minimum_size = Vector2(126.0, 34.0)
		button.add_theme_font_size_override("font_size", 16)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_language_button_pressed.bind(code))
		language_grid.add_child(button)
		_language_buttons[code] = button

	var close_button := Button.new()
	close_button.name = "BtnSettingsClose"
	close_button.text = ""
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.pressed.connect(_on_settings_close_pressed)
	vbox.add_child(close_button)
	PopupSkin.apply_settings_popup(_settings_popup)


func _build_home_confirm_popup() -> void:
	_home_confirm_overlay = Button.new()
	_home_confirm_overlay.name = "HomeConfirmOverlay"
	_home_confirm_overlay.visible = false
	_home_confirm_overlay.flat = true
	_home_confirm_overlay.text = ""
	_home_confirm_overlay.focus_mode = Control.FOCUS_NONE
	_home_confirm_overlay.z_index = 14
	_home_confirm_overlay.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_home_confirm_overlay.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_home_confirm_overlay.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_home_confirm_overlay.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_home_confirm_overlay.pressed.connect(_on_home_confirm_no_pressed)
	add_child(_home_confirm_overlay)

	_home_confirm_popup = Panel.new()
	_home_confirm_popup.name = "HomeConfirmPopup"
	_home_confirm_popup.visible = false
	_home_confirm_popup.z_index = 15
	add_child(_home_confirm_popup)

	var message := Label.new()
	message.name = "ConfirmLabel"
	message.text = ""
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 24)
	_home_confirm_popup.add_child(message)

	var yes_button := Button.new()
	yes_button.name = "BtnConfirmYes"
	yes_button.text = ""
	yes_button.pressed.connect(_on_home_confirm_yes_pressed)
	_home_confirm_popup.add_child(yes_button)

	var no_button := Button.new()
	no_button.name = "BtnConfirmNo"
	no_button.text = ""
	no_button.pressed.connect(_on_home_confirm_no_pressed)
	_home_confirm_popup.add_child(no_button)
	PopupSkin.apply_home_confirm_popup(_home_confirm_popup)


func _make_panel_style(bg_color: Color, border_color: Color, border_width: float, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(int(border_width))
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style


func _make_button_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(3)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _apply_label_font(label: Label, font_size: int) -> void:
	if _font != null:
		label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", font_size)


func _layout_ui() -> void:
	var vp: Vector2 = get_viewport_rect().size
	_bg.position = Vector2.ZERO
	_bg.size = vp
	_bg.pivot_offset = Vector2(vp.x * 0.5, vp.y)
	if _bg.scale == Vector2.ONE:
		_bg.scale = BG_BASE_SCALE
	_shade.position = Vector2.ZERO
	_shade.size = vp
	_whiteout.position = Vector2.ZERO
	_whiteout.size = vp
	if _end_image != null:
		var end_width: float = min(vp.x * 0.72, 760.0)
		var end_height: float = end_width * 0.563
		_end_image.size = Vector2(end_width, end_height)
		_end_image.position = Vector2((vp.x - end_width) * 0.5, (vp.y - end_height) * 0.5)

	_apply_character_node_size(_pyoko, _left_character_speaker)
	_apply_character_node_size(_maboroshi, _right_character_speaker)
	_apply_character_node_size(_side_yume, _side_character_speaker)

	_talk_panel.position = Vector2(22.0, vp.y - 260.0)
	_talk_panel.size = Vector2(vp.x - 44.0, 176.0)
	_name_panel.position = Vector2(36.0, vp.y - 296.0)
	_name_panel.size = Vector2(166.0, 48.0)
	_name_label.position = Vector2.ZERO
	_name_label.size = _name_panel.size
	_body_label.position = Vector2(22.0, 24.0)
	_body_label.size = Vector2(_talk_panel.size.x - 44.0, 112.0)
	_next_mark.position = Vector2(_talk_panel.size.x - 48.0, _talk_panel.size.y - 42.0)
	_next_mark.size = Vector2(30.0, 28.0)

	var icon_size := Vector2(68.0, 68.0)
	_home_button.position = Vector2(vp.x - 154.0, vp.y - 76.0)
	_home_button.size = icon_size
	_home_button.custom_minimum_size = icon_size
	_settings_button.position = Vector2(vp.x - 78.0, vp.y - 76.0)
	_settings_button.size = icon_size
	_settings_button.custom_minimum_size = icon_size
	_skip_button.position = Vector2(vp.x - 126.0, 18.0)
	_skip_button.size = Vector2(108.0, 44.0)
	_skip_button.custom_minimum_size = _skip_button.size

	_settings_overlay.position = Vector2.ZERO
	_settings_overlay.size = vp
	_settings_overlay.custom_minimum_size = vp

	_home_confirm_overlay.position = Vector2.ZERO
	_home_confirm_overlay.size = vp
	_home_confirm_overlay.custom_minimum_size = vp


func _advance() -> void:
	if _is_animating or (_settings_popup != null and _settings_popup.visible) or (_home_confirm_popup != null and _home_confirm_popup.visible):
		return
	if _line_index + 1 >= _lines.size():
		_finish_current_scene()
		return
	_show_line(_line_index + 1, true)


func _try_advance_from_input() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_advance_input_msec < ADVANCE_INPUT_COOLDOWN_MS:
		return
	_last_advance_input_msec = now
	_advance()


func _toggle_ui_hidden() -> void:
	if (_settings_popup != null and _settings_popup.visible) or (_home_confirm_popup != null and _home_confirm_popup.visible):
		return
	_ui_hidden = not _ui_hidden
	_apply_ui_visibility()


func _apply_ui_visibility() -> void:
	var show_ui := not _ui_hidden
	_talk_panel.visible = show_ui
	_name_panel.visible = show_ui
	_home_button.visible = show_ui
	_settings_button.visible = show_ui
	_skip_button.visible = show_ui


func _show_line(index: int, animated: bool) -> void:
	_is_animating = true
	_line_index = index
	var line: Dictionary = _lines[_line_index]
	var speaker := str(line.get("speaker", SPEAKER_PYOKO))
	var portrait := str(line.get("portrait", ""))
	if _is_mirage_clear_scene() and speaker != SPEAKER_PYOKO:
		await _set_mirage_clear_right_speaker(speaker, portrait, animated)
	else:
		_set_speaker_portrait(speaker, portrait)
	if animated:
		await _play_line_transition(str(line.get("transition", "")))
	_refresh_current_line_text()
	_apply_speaker_focus(speaker, animated)
	if str(line.get("transition", "")) == "spotlight_maboroshi":
		_pyoko.visible = false
		_pyoko.modulate.a = 0.0
	if bool(line.get("hide_other", false)) and str(line.get("speaker", SPEAKER_PYOKO)) == SPEAKER_PYOKO:
		_maboroshi.visible = false
	if str(line.get("transition", "")) == "yume_left_slide_in":
		_pyoko.visible = false
		_pyoko.modulate.a = 0.0
	_apply_ui_visibility()
	_is_animating = false


func _get_current_speaker() -> String:
	if _line_index < 0 or _line_index >= _lines.size():
		return SPEAKER_PYOKO
	return str(_lines[_line_index].get("speaker", SPEAKER_PYOKO))


func _apply_speaker_focus(speaker: String, animated: bool) -> void:
	if _is_mirage_clear_scene():
		_apply_mirage_clear_focus(speaker, animated)
		return

	var vp: Vector2 = get_viewport_rect().size
	_apply_character_node_size(_pyoko, _left_character_speaker)
	_apply_character_node_size(_maboroshi, _right_character_speaker)
	_apply_character_node_size(_side_yume, _side_character_speaker)
	var pyoko_active := speaker == SPEAKER_PYOKO
	var maboroshi_active := speaker == SPEAKER_MABOROSHI
	var right_yume_active := speaker == SPEAKER_YUME and _is_yume_scene()
	var side_yume_active := speaker == SPEAKER_YUME and _is_stage2_scene()
	var stage2_ututu_active := speaker == SPEAKER_UTUTU and _is_stage2_scene()
	var stage3_left_active := _is_stage3_scene() and (speaker == SPEAKER_UTUTU or speaker == SPEAKER_YUME)
	var mirage_clear_right_active := _is_mirage_clear_scene() and speaker != SPEAKER_PYOKO
	var character_bottom_y := vp.y - 150.0
	_set_character_state(_pyoko, _get_left_character_position(_left_character_speaker, character_bottom_y), pyoko_active or stage3_left_active, animated, LEFT_INACTIVE_OFFSET)
	var second_pos := _get_right_character_position(_right_character_speaker, _maboroshi, character_bottom_y)
	if maboroshi_active and _is_tutorial_scene():
		second_pos = _get_tutorial_maboroshi_position()
	_set_character_state(_maboroshi, second_pos, maboroshi_active or right_yume_active or stage2_ututu_active or mirage_clear_right_active, animated, RIGHT_INACTIVE_OFFSET)
	var side_yume_pos := _get_side_character_position(_side_character_speaker, character_bottom_y)
	_set_character_state(_side_yume, side_yume_pos, side_yume_active, animated, LEFT_INACTIVE_OFFSET)


func _get_tutorial_maboroshi_position() -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	var character_bottom_y := vp.y - 150.0
	return Vector2((vp.x - _maboroshi.size.x) * 0.5, character_bottom_y - _maboroshi.size.y + MABOROSHI_Y_OFFSET)


func _apply_mirage_clear_focus(speaker: String, animated: bool) -> void:
	_apply_character_node_size(_pyoko, _left_character_speaker)
	_apply_character_node_size(_maboroshi, _mirage_clear_right_speaker)
	var vp: Vector2 = get_viewport_rect().size
	var character_bottom_y := vp.y - 150.0
	var pyoko_active := speaker == SPEAKER_PYOKO
	var right_active := speaker != SPEAKER_PYOKO
	var pyoko_pos := _get_left_character_position(_left_character_speaker, character_bottom_y)
	var right_pos := _get_mirage_clear_right_position()
	_set_character_state(_pyoko, pyoko_pos, pyoko_active, animated, LEFT_INACTIVE_OFFSET)
	_set_character_state(_maboroshi, right_pos, right_active, animated, RIGHT_INACTIVE_OFFSET)
	_side_yume.visible = false


func _get_mirage_clear_right_position() -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	var character_bottom_y := vp.y - 150.0
	return _get_right_character_position(_mirage_clear_right_speaker, _maboroshi, character_bottom_y)


func _set_mirage_clear_right_speaker(speaker: String, portrait: String, animated: bool) -> void:
	if speaker == _mirage_clear_right_speaker:
		_set_speaker_portrait(speaker, portrait)
		return

	var vp: Vector2 = get_viewport_rect().size
	if animated and _maboroshi.visible and _mirage_clear_right_speaker != "":
		var out_tween := create_tween()
		out_tween.set_parallel(true)
		out_tween.tween_property(_maboroshi, "position:x", vp.x + 24.0, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		out_tween.tween_property(_maboroshi, "modulate:a", 0.0, 0.16)
		await out_tween.finished

	_mirage_clear_right_speaker = speaker
	_apply_character_node_size(_maboroshi, speaker)
	_set_speaker_portrait(speaker, portrait)

	var target_pos := _get_mirage_clear_right_position()
	if not animated:
		_maboroshi.position = target_pos
		_maboroshi.modulate = Color(1, 1, 1, 1)
		_maboroshi.scale = Vector2.ONE
		_maboroshi.visible = true
		return

	_maboroshi.visible = true
	_maboroshi.position = Vector2(vp.x + 24.0, target_pos.y)
	_maboroshi.modulate = Color(1, 1, 1, 0)
	_maboroshi.scale = Vector2.ONE
	var in_tween := create_tween()
	in_tween.set_parallel(true)
	in_tween.tween_property(_maboroshi, "position", target_pos, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	in_tween.tween_property(_maboroshi, "modulate:a", 1.0, 0.2)
	await in_tween.finished


func _set_speaker_portrait(speaker: String, path: String) -> void:
	if path == "":
		return
	var node := _get_speaker_node(speaker)
	node.flip_h = _should_flip_speaker_on_node(speaker, node)
	if ResourceLoader.exists(path):
		node.texture = load(path)
	if node == _pyoko:
		var changed_left_character := _left_character_speaker != speaker
		_left_character_speaker = speaker
		_apply_character_node_size(node, speaker)
		if changed_left_character:
			_reset_left_character_start_position(speaker)
		return
	elif node == _maboroshi:
		_right_character_speaker = speaker
	elif node == _side_yume:
		_side_character_speaker = speaker
	_apply_character_node_size(node, speaker)


func _reset_left_character_start_position(speaker: String) -> void:
	var vp: Vector2 = get_viewport_rect().size
	var character_bottom_y := vp.y - 150.0
	_pyoko.position = _get_left_character_position(speaker, character_bottom_y) + LEFT_INACTIVE_OFFSET


func _apply_character_node_size(node: TextureRect, speaker: String) -> void:
	if node == null:
		return
	var old_size := node.size
	var old_position := node.position
	node.size = _get_character_size(speaker)
	if old_size == Vector2.ZERO:
		return
	var old_bottom := old_position.y + old_size.y
	if node == _maboroshi:
		var old_right := old_position.x + old_size.x
		node.position.x = old_right - node.size.x
	else:
		node.position.x = old_position.x
	node.position.y = old_bottom - node.size.y


func _get_character_size(speaker: String) -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	var character_h: float = vp.y * 0.58
	match speaker:
		SPEAKER_YUME:
			var yume_h := character_h * YUME_HEIGHT_MULTIPLIER
			return Vector2(yume_h * YUME_TEXTURE_WIDTH_MULTIPLIER, yume_h)
		SPEAKER_UTUTU:
			var ututu_h := character_h * UTUTU_HEIGHT_MULTIPLIER
			return Vector2(ututu_h * UTUTU_WIDTH_MULTIPLIER, ututu_h)
		SPEAKER_MABOROSHI:
			var maboroshi_h := character_h * MABOROSHI_HEIGHT_MULTIPLIER
			return Vector2(maboroshi_h * MABOROSHI_WIDTH_MULTIPLIER, maboroshi_h)
		_:
			var pyoko_h := character_h * PYOKO_HEIGHT_MULTIPLIER
			return Vector2(pyoko_h * PYOKO_WIDTH_MULTIPLIER, pyoko_h)


func _get_left_character_position(speaker: String, character_bottom_y: float) -> Vector2:
	var x := 10.0 - _get_character_left_offset(speaker, _pyoko.size.x)
	return Vector2(x, character_bottom_y - _pyoko.size.y)


func _get_side_character_position(speaker: String, character_bottom_y: float) -> Vector2:
	var x := 10.0 - _get_character_left_offset(speaker, _side_yume.size.x)
	return Vector2(x, character_bottom_y - _side_yume.size.y)


func _get_right_character_position(speaker: String, node: TextureRect, character_bottom_y: float) -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	var x := vp.x - node.size.x - 10.0 + _get_character_right_offset(speaker, node.size.x)
	var y := character_bottom_y - node.size.y
	return Vector2(x, y)


func _get_character_right_offset(speaker: String, node_width: float) -> float:
	if speaker == SPEAKER_YUME:
		return node_width * YUME_VISIBLE_RIGHT_MARGIN_RATIO
	return 0.0


func _get_character_left_offset(speaker: String, node_width: float) -> float:
	if speaker == SPEAKER_YUME:
		return node_width * YUME_VISIBLE_RIGHT_MARGIN_RATIO
	return 0.0


func _should_flip_speaker_on_node(speaker: String, node: TextureRect) -> bool:
	if speaker != SPEAKER_YUME and speaker != SPEAKER_UTUTU:
		return false
	return node == _pyoko or node == _side_yume


func _get_speaker_node(speaker: String) -> TextureRect:
	if speaker == SPEAKER_PYOKO:
		return _pyoko
	if _is_stage3_scene() and (speaker == SPEAKER_UTUTU or speaker == SPEAKER_YUME):
		return _pyoko
	if speaker == SPEAKER_YUME and _is_stage2_scene():
		return _side_yume
	return _maboroshi


func _play_line_transition(transition_name: String) -> void:
	match transition_name:
		"spotlight_maboroshi":
			_name_label.text = ""
			_body_label.text = ""
			_next_mark.visible = false
			_talk_panel.modulate.a = 0.0
			_name_panel.modulate.a = 0.0
			_apply_character_node_size(_maboroshi, SPEAKER_MABOROSHI)
			_maboroshi.position = _get_tutorial_maboroshi_position()
			_maboroshi.scale = Vector2.ONE
			_maboroshi.modulate.a = 0.0
			_maboroshi.visible = true
			var tween := create_tween()
			tween.set_parallel(true)
			tween.tween_property(_pyoko, "modulate:a", 0.0, 0.34)
			tween.tween_property(_bg, "scale", BG_SPOTLIGHT_SCALE, 0.48).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(_maboroshi, "modulate:a", 1.0, 0.44).set_delay(0.16)
			await tween.finished
			_pyoko.visible = false
			_talk_panel.modulate.a = 1.0
			_name_panel.modulate.a = 1.0
			_next_mark.visible = true
		"back_to_pyoko":
			_name_label.text = ""
			_body_label.text = ""
			_next_mark.visible = false
			_talk_panel.modulate.a = 0.0
			_name_panel.modulate.a = 0.0
			_pyoko.modulate.a = 0.0
			_pyoko.visible = true
			var tween := create_tween()
			tween.set_parallel(true)
			tween.tween_property(_maboroshi, "modulate:a", 0.0, 0.34)
			tween.tween_property(_bg, "scale", BG_BASE_SCALE, 0.48).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(_pyoko, "modulate:a", 1.0, 0.42).set_delay(0.16)
			await tween.finished
			_maboroshi.visible = false
			_talk_panel.modulate.a = 1.0
			_name_panel.modulate.a = 1.0
			_next_mark.visible = true
		"yume_slide_in":
			var vp: Vector2 = get_viewport_rect().size
			_maboroshi.visible = true
			_maboroshi.modulate.a = 0.0
			_maboroshi.scale = Vector2(1.0, 1.0)
			var character_bottom_y := vp.y - 150.0
			_apply_character_node_size(_maboroshi, SPEAKER_YUME)
			var target_pos := _get_right_character_position(SPEAKER_YUME, _maboroshi, character_bottom_y)
			_maboroshi.position = Vector2(vp.x + 18.0, target_pos.y)
			var tween := create_tween()
			tween.set_parallel(true)
			tween.tween_property(_maboroshi, "position", target_pos, 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(_maboroshi, "modulate:a", 1.0, 0.24)
			await tween.finished
		"yume_left_slide_in":
			var vp: Vector2 = get_viewport_rect().size
			var character_bottom_y := vp.y - 150.0
			_apply_character_node_size(_side_yume, SPEAKER_YUME)
			var target_pos := _get_side_character_position(SPEAKER_YUME, character_bottom_y)
			_side_yume.visible = true
			_side_yume.position = Vector2(-_side_yume.size.x - 20.0, target_pos.y)
			_side_yume.scale = Vector2(1.0, 1.0)
			_side_yume.modulate.a = 0.0
			_pyoko.visible = true
			var tween := create_tween()
			tween.set_parallel(true)
			tween.tween_property(_side_yume, "position", target_pos, 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(_side_yume, "modulate:a", 1.0, 0.24)
			tween.tween_property(_pyoko, "position", Vector2(-_pyoko.size.x - 20.0, character_bottom_y - _pyoko.size.y), 0.38).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.tween_property(_pyoko, "modulate:a", 0.0, 0.24)
			await tween.finished
		_:
			return


func _set_character_state(node: TextureRect, base_pos: Vector2, active: bool, animated: bool, inactive_offset: Vector2 = DEFAULT_INACTIVE_OFFSET) -> void:
	var target_scale := Vector2(1.0, 1.0) if active else Vector2(0.93, 0.93)
	var target_pos := base_pos if active else base_pos + inactive_offset
	var target_modulate := Color(1, 1, 1, 1) if active else Color(0.52, 0.52, 0.6, 0.58)
	if active:
		node.visible = true
	node.z_index = 2 if active else 1
	node.pivot_offset = node.size * 0.5
	if not animated:
		node.position = target_pos
		node.scale = target_scale
		node.modulate = target_modulate
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", target_pos, 0.16)
	tween.tween_property(node, "scale", target_scale, 0.16)
	tween.tween_property(node, "modulate", target_modulate, 0.16)
	await tween.finished


func _finish_current_scene() -> void:
	if _is_finishing_scene:
		return
	_is_finishing_scene = true
	var line: Dictionary = _lines[_line_index] if _line_index >= 0 and _line_index < _lines.size() else {}
	if str(line.get("finish", "")) == "whiteout":
		_is_animating = true
		var tween := create_tween()
		tween.tween_property(_whiteout, "color:a", 1.0, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished
	elif str(line.get("finish", "")) == "end_logo":
		await _play_end_logo_finish()
	_go_next_scene()


func _play_end_logo_finish() -> void:
	_is_animating = true
	var hide_tween := create_tween()
	hide_tween.set_parallel(true)
	hide_tween.tween_property(_talk_panel, "modulate:a", 0.0, 0.2)
	hide_tween.tween_property(_name_panel, "modulate:a", 0.0, 0.2)
	hide_tween.tween_property(_home_button, "modulate:a", 0.0, 0.2)
	hide_tween.tween_property(_settings_button, "modulate:a", 0.0, 0.2)
	hide_tween.tween_property(_skip_button, "modulate:a", 0.0, 0.2)
	await hide_tween.finished
	_talk_panel.visible = false
	_name_panel.visible = false
	_next_mark.visible = false
	_home_button.visible = false
	_settings_button.visible = false
	_skip_button.visible = false
	if _end_image == null:
		return
	_end_image.visible = true
	_end_image.modulate.a = 0.0
	var end_tween := create_tween()
	end_tween.tween_property(_end_image, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await end_tween.finished
	_waiting_for_end_logo_input = true
	_is_animating = false
	await end_logo_advance_requested
	_waiting_for_end_logo_input = false
	_is_animating = true


func _refresh_current_line_text() -> void:
	if _line_index < 0 or _line_index >= _lines.size():
		return
	var line: Dictionary = _lines[_line_index]
	var speaker := str(line.get("speaker", SPEAKER_PYOKO))
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	_name_label.text = TalkLocalization.speaker_name(locale, speaker, str(line.get("name", "")))
	_body_label.text = TalkLocalization.talk_text(locale, GameState.talk_scene_id, _line_index, str(line.get("text", "")))


func _is_ui_point(point: Vector2) -> bool:
	var controls: Array[Control] = [_home_button, _settings_button, _skip_button]
	if _settings_popup != null and _settings_popup.visible:
		controls.append(_settings_popup)
		controls.append(_settings_overlay)
	if _home_confirm_popup != null and _home_confirm_popup.visible:
		controls.append(_home_confirm_popup)
		controls.append(_home_confirm_overlay)
	for control in controls:
		if control != null and control.visible:
			var rect := Rect2(control.global_position, control.size)
			if rect.has_point(point):
				return true
	return false


func _apply_text_language() -> void:
	var locale := SaveData.normalize_language_code(SaveData.language_code)
	if _settings_popup != null and _settings_popup.has_node("VBox"):
		var vbox := _settings_popup.get_node("VBox")
		_set_label_text(vbox, "LabelBgm", TalkLocalization.ui_text(locale, "settings_bgm"))
		_set_label_text(vbox, "LabelSe", TalkLocalization.ui_text(locale, "settings_se"))
		_set_label_text(vbox, "LabelTileSuit", TalkLocalization.ui_text(locale, "settings_tile"))
		_set_label_text(vbox, "LabelLanguage", TalkLocalization.ui_text(locale, "language"))
		_set_button_text(vbox, "BtnSettingsClose", "")
	if _home_confirm_popup != null:
		_apply_home_confirm_skin()
	_refresh_language_buttons()
	_refresh_current_line_text()


func _set_label_text(parent: Node, node_name: String, value: String) -> void:
	var label := parent.get_node_or_null(node_name) as Label
	if label != null:
		label.text = value


func _set_button_text(parent: Node, node_name: String, value: String) -> void:
	var button := parent.get_node_or_null(node_name) as Button
	if button != null:
		button.text = value


func _apply_home_confirm_skin() -> void:
	if _home_confirm_popup == null:
		return
	PopupSkin.apply_home_confirm_popup(_home_confirm_popup)
	_set_label_text(_home_confirm_popup, "ConfirmLabel", "")
	_set_button_text(_home_confirm_popup, "BtnConfirmYes", "")
	_set_button_text(_home_confirm_popup, "BtnConfirmNo", "")


func _refresh_language_buttons() -> void:
	var current := SaveData.normalize_language_code(SaveData.language_code)
	for option in TalkLocalization.LANGUAGE_OPTIONS:
		var code: String = option["code"]
		if not _language_buttons.has(code):
			continue
		var button := _language_buttons[code] as CheckBox
		button.text = str(option["label"])
		button.set_pressed_no_signal(code == current)
		button.modulate = Color(1.0, 0.92, 0.72, 1.0) if code == current else Color(1.0, 1.0, 1.0, 1.0)


func _on_home_pressed() -> void:
	if _home_confirm_popup == null:
		return
	_apply_home_confirm_skin()
	_home_confirm_overlay.visible = true
	_home_confirm_popup.visible = true
	_home_confirm_overlay.move_to_front()
	_home_confirm_popup.move_to_front()


func _on_home_confirm_yes_pressed() -> void:
	GameState.talk_scene_id = ""
	GameState.talk_return_scene = ""
	get_tree().change_scene_to_file("res://StageSelect.tscn")


func _on_home_confirm_no_pressed() -> void:
	if _home_confirm_overlay != null:
		_home_confirm_overlay.visible = false
	if _home_confirm_popup != null:
		_home_confirm_popup.visible = false


func _on_settings_pressed() -> void:
	if _settings_popup == null:
		return
	PopupSkin.apply_settings_popup(_settings_popup)
	(_settings_popup.get_node("VBox/BgmSlider") as HSlider).value = AudioManager.bgm_volume
	(_settings_popup.get_node("VBox/SeSlider") as HSlider).value = AudioManager.se_volume
	(_settings_popup.get_node("VBox/TileSuitGrid") as GridContainer).call("sync_selection")
	_apply_text_language()
	_settings_overlay.visible = true
	_settings_popup.visible = true
	_settings_overlay.move_to_front()
	_settings_popup.move_to_front()


func _on_settings_close_pressed() -> void:
	if _settings_overlay != null:
		_settings_overlay.visible = false
	if _settings_popup != null:
		_settings_popup.visible = false


func _on_bgm_slider_changed(value: float) -> void:
	AudioManager.bgm_volume = float(value)
	if AudioManager.bgm_player != null:
		AudioManager.bgm_player.volume_db = linear_to_db(AudioManager.bgm_volume)


func _on_se_slider_changed(value: float) -> void:
	AudioManager.se_volume = float(value)


func _on_tile_suit_changed(_tile_suit: String) -> void:
	AudioManager.play_se("se_btntap")


func _on_language_button_pressed(code: String) -> void:
	SaveData.set_language_code(code)
	TranslationServer.set_locale(SaveData.language_code)
	PopupSkin.apply_settings_popup(_settings_popup)
	_apply_text_language()
	AudioManager.play_se("se_btntap")


func _on_skip_pressed() -> void:
	if _is_animating:
		return
	_go_next_scene()


func _go_next_scene() -> void:
	var scene_id := GameState.talk_scene_id
	var target := GameState.talk_return_scene
	if _is_final_clear_scene():
		target = "res://StageSelect.tscn"
	if scene_id == "nightmare_clear":
		GameState.came_from_ex = true
	if target == "":
		target = "res://game.tscn"
	GameState.talk_scene_id = ""
	GameState.talk_return_scene = ""
	call_deferred("_go_next_scene_deferred", target)


func _go_next_scene_deferred(target: String) -> void:
	var err := get_tree().change_scene_to_file(target)
	if err != OK:
		push_error("Failed to change scene after talk: %s" % target)
		get_tree().change_scene_to_file("res://StageSelect.tscn")

extends RefCounted

const LOCALES := ["ja", "en", "zh_CN", "zh_TW", "ko"]

const LANGUAGE_OPTIONS: Array[Dictionary] = [
	{"code": "ja", "label": "日本語"},
	{"code": "en", "label": "English"},
	{"code": "zh_CN", "label": "简体中文"},
	{"code": "zh_TW", "label": "繁體中文"},
	{"code": "ko", "label": "한국어"},
]

const UI_TEXT := {
	"ja": {
		"settings_bgm": "BGM音量",
		"settings_se": "SE音量",
		"settings_tile": "牌の種類",
		"language": "Language",
		"close": "閉じる",
		"home_confirm": "ステージ選択に戻りますか？",
		"yes": "はい",
		"no": "いいえ",
	},
	"en": {
		"settings_bgm": "BGM volume",
		"settings_se": "SE volume",
		"settings_tile": "Tile suit",
		"language": "Language",
		"close": "Close",
		"home_confirm": "Return to stage select?",
		"yes": "Yes",
		"no": "No",
	},
	"zh_CN": {
		"settings_bgm": "BGM 音量",
		"settings_se": "SE 音量",
		"settings_tile": "牌面花色",
		"language": "Language",
		"close": "关闭",
		"home_confirm": "要返回关卡选择吗？",
		"yes": "是",
		"no": "否",
	},
	"zh_TW": {
		"settings_bgm": "BGM 音量",
		"settings_se": "SE 音量",
		"settings_tile": "牌面花色",
		"language": "Language",
		"close": "關閉",
		"home_confirm": "要返回關卡選擇嗎？",
		"yes": "是",
		"no": "否",
	},
	"ko": {
		"settings_bgm": "BGM 볼륨",
		"settings_se": "SE 볼륨",
		"settings_tile": "패 종류",
		"language": "Language",
		"close": "닫기",
		"home_confirm": "스테이지 선택으로 돌아갈까요?",
		"yes": "예",
		"no": "아니요",
	},
}

const SPEAKER_NAMES := {
	"en": {
		"pyoko": "Pyokotan",
		"maboroshi": "Maboroshi",
		"yume": "Yume",
		"ututu": "Ututsu",
	},
	"zh_CN": {
		"pyoko": "皮约可炭",
		"maboroshi": "幻胧",
		"yume": "梦幽",
		"ututu": "现棘",
	},
	"zh_TW": {
		"pyoko": "皮約可炭",
		"maboroshi": "幻朧",
		"yume": "夢幽",
		"ututu": "現棘",
	},
	"ko": {
		"pyoko": "표코탄",
		"maboroshi": "마보로시",
		"yume": "유메",
		"ututu": "우츠츠",
	},
}

const TALK_TEXT := {
	"en": {
		"tutorial_intro": [
			"My name is Pyokotan!\nI am an ordinary boy you could find anywhere!",
			"Actually, there is a girl I have been thinking about lately...",
			"Maboroshi.\nShe is mysterious and wonderful!",
			"I heard a rumor that Maboroshi likes mahjong.\nSo I worked hard and learned mahjong too!",
		],
		"stage1_intro": [
			"Huh, I lost sight of Maboroshi.\nIt looked like she walked this way...",
			"Hey, you.\nThis is private property beyond here, so you must not enter.",
			"Hello, big sister.\nMy name is Pyokotan!",
			"Hello, Pyokotan.\nGood job saying hello. I am Yume.",
			"This mountain is our family's home.\nIt is dangerous, so do not come in without permission.",
			"But I saw my friend go this way!",
			"Really? That is strange.\nOnly Mother should have come here...",
			"Did I miss her somehow?\nWhat should I do? My big sister is going to be angry...",
			"Do not worry, big sister!\nI will take responsibility and look for her!",
			"Thank you, Pyokotan.\nBut I am worried. Do you know mahjong?",
			"Mahjong! I know it!",
			"But I only know a little.",
			"I see. My big sister is farther ahead too,\nand it is dangerous, so I will teach you a few tips.",
		],
		"stage2_intro": [
			"It is getting dark...",
			"Hey, hey!\nWhy are you barging into our mountain, kid?",
			"Hello, big sister.\nMy name is Pyokotan!",
			"Huh? Nobody asked your name, did they?",
			"This is trespassing, trespassing.\nGo home already!",
			"This big sister is scary...",
			"Big sister. This kid says his friend came this way. Did you see anyone?",
			"Huh? Obviously only Mama came here.\nWhat are you talking about?",
			"Well, I was bored anyway.\nIf you can beat me at mahjong, I will let you pass.",
		],
		"stage3_intro": [
			"Mama!\nSome weird guy showed up!",
			"What is it, Ututsu? You are being loud.",
			"Ah, Maboroshi!\nI finally found you!",
			"You are...",
			"Huh, Mother.\nDo you know him?",
			"He is the boy people talk about at the place I attend.",
			"If I recall, he spent all his parents' money\nand got banned from his family home...\nPyokotan!",
			"H-how do you know my secret?",
			"Well, never mind.\nI came to play today.\nMaboroshi, challenge me at mahjong!",
		],
		"ex_stage1_intro": [
			"I came again.\nI am going to play mahjong with Maboroshi!",
			"Huh?\nIt is still daytime, but it feels strangely dark.",
			"Intruder...",
			"Ah, the kind big sister!\nIt is Pyokotan! I came to play again!",
			"Human...\nMust eliminate...",
			"Something seems strange about you...",
		],
		"ex_stage2_intro": [
			"This is creepy...\nEverything feels completely different from last time.",
			"Kid...!\nWhy are you here?",
			"Ah, it is the scary big sister.",
			"Fine.\nI was irritated anyway, so I will play with you myself. No holding back today!",
			"Wah! I am going to be bullied!",
		],
		"ex_stage3_intro": [
			"I somehow made it to the summit...",
			"Hmph.\nYou did well to make it this far.",
			"Ah, Maboroshi!\nLet us play!",
			"Interesting. Very well.\nYou have earned the right to face me...!",
		],
		"mirage_clear": [
			"I-I finally cleared it...\nNow I am a full-fledged mahjong player!",
			"Not bad, banned boy.\nI may acknowledge you a little.",
			"Amazing, Pyokotan!\nNow you have Chinitsu down perfectly!",
			"You are not half bad.\nBy the way, about spending your parents' money: what did you spend it on?",
			"I love pachislot!",
			"Oh. Okay.",
			"At this rate, I may play mahjong with you again.\nCome whenever you like.",
			"Yay! I will come play again!",
			"However, avoid nights with a full moon.\nI may be fine, but my daughters are still immature as werewolves. The welcome could become rough.",
			"?\nGot it!",
		],
		"nightmare_clear": [
			"...!!",
			"I-I did it...",
			"I finally cleared it!",
			"Impressive.\nEven a mahjong professional would have found that difficulty hard to clear...",
			"I grant you the title of Chinitsu Master. Go boast about it at your school.",
			"Chinitsu Master...\nThat sounds great!",
		],
	},
	"zh_CN": {
		"tutorial_intro": [
			"我的名字是皮约可炭！\n我是随处可见的普通男孩子！",
			"其实最近，我有一个很在意的女孩子……",
			"幻胧。\n她神秘又迷人！",
			"我听说幻胧很喜欢麻将。\n所以我也努力学会了麻将！",
		],
		"stage1_intro": [
			"咦，我跟丢幻胧了。\n看起来她好像往这边走了……",
			"喂，你。\n前面是私人土地，不能进去哦。",
			"姐姐你好。\n我的名字是皮约可炭！",
			"你好，皮约可炭。\n会打招呼真乖。我是梦幽。",
			"这座山是我们一族的家。\n很危险，不可以擅自进去哦。",
			"可是，我看到我的朋友往前面去了！",
			"欸，真的吗？真奇怪，\n应该只有妈妈来过才对……",
			"难道我看漏了吗？\n怎么办，会被姐姐骂的……",
			"放心吧，姐姐！\n我会负起责任去找她的！",
			"谢谢你，皮约可炭。\n不过我还是担心。你知道麻将吗？",
			"麻将！我知道！",
			"不过，只知道一点点。",
			"这样啊。前面还有姐姐，\n很危险，所以我教你一点诀窍吧。",
		],
		"stage2_intro": [
			"天色变暗了……",
			"等一下等一下！\n你为什么擅自闯进我家的山里啊，小鬼！",
			"姐姐你好。\n我的名字是皮约可炭！",
			"哈？谁问你名字了啊？",
			"这是非法入侵，非法入侵。\n快点回去！",
			"这个姐姐好可怕……",
			"姐姐。这个孩子说他的朋友来这边了，你有看到吗？",
			"哈？当然只有妈妈来过啊。\n你在说什么？",
			"算了，我正好无聊。\n如果你能在麻将上赢我，我就放你过去。",
		],
		"stage3_intro": [
			"妈妈～！\n来了个奇怪的家伙！",
			"怎么了，现棘，吵吵闹闹的。",
			"啊，幻胧！\n终于找到你了！",
			"你是……",
			"欸，妈妈。\n你认识这个孩子？",
			"他是我去的园里被人议论的男孩。",
			"我记得，他把父母的钱花光了，\n结果被老家禁止进入……\n皮约可炭！",
			"为、为什么你知道我的秘密！",
			"算了。\n今天我是来玩的。\n幻胧，和我用麻将决胜负吧！",
		],
		"ex_stage1_intro": [
			"我又来了。\n要和幻胧一起打麻将！",
			"咦？\n明明还是中午，却觉得莫名地暗。",
			"入侵者……",
			"啊，是温柔的姐姐！\n我是皮约可炭！我又来玩了！",
			"人类……\n必须排除……",
			"姐姐的样子好像有点不对劲……？",
		],
		"ex_stage2_intro": [
			"好诡异……\n和上次来的时候完全不一样。",
			"小鬼……！\n你为什么会在这里！",
			"啊，是可怕的姐姐。",
			"好吧。\n我正好有点烦，就特别陪你玩玩。今天可不会手下留情！",
			"哇！我要被欺负了！",
		],
		"ex_stage3_intro": [
			"总算爬到山顶了……",
			"哼。\n你居然能来到这里。",
			"啊，幻胧！\n来玩吧！",
			"有意思。好吧。\n你已经有资格做我的对手了……！",
		],
		"mirage_clear": [
			"终、终于通关了……\n这样我也是独当一面的麻将打手了！",
			"不错嘛，禁止回家的男人。\n我可以稍微认可你一下。",
			"太厉害了，皮约可炭！\n这样清一色就完美了！",
			"你还挺能干的嘛。\n话说回来，听说你把父母的钱花光了，到底花在什么上？",
			"我最喜欢柏青斯洛了！",
			"啊，是吗。",
			"这样的话，以后再陪你打麻将也可以。\n想来的时候就来吧。",
			"太好了！我还会再来玩的！",
			"不过，满月的日子就别来了。\n我倒还好，女儿们作为人狼还不成熟，可能会粗暴地欢迎你。",
			"？\n知道了！",
		],
		"nightmare_clear": [
			"……！！",
			"我、我做到了……",
			"终于通关了！！",
			"挺有本事。\n就算是麻将职业选手，也不该能轻易通关这个难度……",
			"我授予你“清一色大师”的称号。去园里炫耀吧。",
			"清一色大师……\n听起来真棒！",
		],
	},
	"zh_TW": {
		"tutorial_intro": [
			"我的名字是皮約可炭！\n我是隨處可見的普通男孩子！",
			"其實最近，我有一個很在意的女孩子……",
			"幻朧。\n她神祕又迷人！",
			"我聽說幻朧很喜歡麻將。\n所以我也努力學會了麻將！",
		],
		"stage1_intro": [
			"咦，我跟丟幻朧了。\n看起來她好像往這邊走了……",
			"喂，你。\n前面是私人土地，不能進去喔。",
			"姐姐妳好。\n我的名字是皮約可炭！",
			"你好，皮約可炭。\n會打招呼真乖。我是夢幽。",
			"這座山是我們一族的家。\n很危險，不可以擅自進去喔。",
			"可是，我看到我的朋友往前面去了！",
			"欸，真的嗎？真奇怪，\n應該只有媽媽來過才對……",
			"難道我看漏了嗎？\n怎麼辦，會被姐姐罵的……",
			"放心吧，姐姐！\n我會負起責任去找她的！",
			"謝謝你，皮約可炭。\n不過我還是擔心。你知道麻將嗎？",
			"麻將！我知道！",
			"不過，只知道一點點。",
			"這樣啊。前面還有姐姐，\n很危險，所以我教你一點訣竅吧。",
		],
		"stage2_intro": [
			"天色變暗了……",
			"等一下等一下！\n你為什麼擅自闖進我家的山裡啊，小鬼！",
			"姐姐妳好。\n我的名字是皮約可炭！",
			"蛤？誰問你名字了啊？",
			"這是非法入侵，非法入侵。\n快點回去！",
			"這個姐姐好可怕……",
			"姐姐。這個孩子說他的朋友來這邊了，妳有看到嗎？",
			"蛤？當然只有媽媽來過啊。\n你在說什麼？",
			"算了，我正好無聊。\n如果你能在麻將上贏我，我就放你過去。",
		],
		"stage3_intro": [
			"媽媽～！\n來了個奇怪的傢伙！",
			"怎麼了，現棘，吵吵鬧鬧的。",
			"啊，幻朧！\n終於找到妳了！",
			"你是……",
			"欸，媽媽。\n妳認識這個孩子？",
			"他是我去的園裡被人議論的男孩。",
			"我記得，他把父母的錢花光了，\n結果被老家禁止進入……\n皮約可炭！",
			"為、為什麼妳知道我的祕密！",
			"算了。\n今天我是來玩的。\n幻朧，和我用麻將決勝負吧！",
		],
		"ex_stage1_intro": [
			"我又來了。\n要和幻朧一起打麻將！",
			"咦？\n明明還是中午，卻覺得莫名地暗。",
			"入侵者……",
			"啊，是溫柔的姐姐！\n我是皮約可炭！我又來玩了！",
			"人類……\n必須排除……",
			"姐姐的樣子好像有點不對勁……？",
		],
		"ex_stage2_intro": [
			"好詭異……\n和上次來的時候完全不一樣。",
			"小鬼……！\n你為什麼會在這裡！",
			"啊，是可怕的姐姐。",
			"好吧。\n我正好有點煩，就特別陪你玩玩。今天可不會手下留情！",
			"哇！我要被欺負了！",
		],
		"ex_stage3_intro": [
			"總算爬到山頂了……",
			"哼。\n你居然能來到這裡。",
			"啊，幻朧！\n來玩吧！",
			"有意思。好吧。\n你已經有資格做我的對手了……！",
		],
		"mirage_clear": [
			"終、終於通關了……\n這樣我也是獨當一面的麻將打手了！",
			"不錯嘛，禁止回家的男人。\n我可以稍微認可你一下。",
			"太厲害了，皮約可炭！\n這樣清一色就完美了！",
			"你還挺能幹的嘛。\n話說回來，聽說你把父母的錢花光了，到底花在什麼上？",
			"我最喜歡柏青斯洛了！",
			"啊，是嗎。",
			"這樣的話，以後再陪你打麻將也可以。\n想來的時候就來吧。",
			"太好了！我還會再來玩的！",
			"不過，滿月的日子就別來了。\n我倒還好，女兒們作為人狼還不成熟，可能會粗暴地歡迎你。",
			"？\n知道了！",
		],
		"nightmare_clear": [
			"……！！",
			"我、我做到了……",
			"終於通關了！！",
			"挺有本事。\n就算是麻將職業選手，也不該能輕易通關這個難度……",
			"我授予你「清一色大師」的稱號。去園裡炫耀吧。",
			"清一色大師……\n聽起來真棒！",
		],
	},
	"ko": {
		"tutorial_intro": [
			"내 이름은 표코탄!\n어디에나 있는 평범한 남자아이인 거야!",
			"사실 요즘 신경 쓰이는 여자아이가 있는 거야...",
			"마보로시.\n신비롭고 멋진 아이인 거야!",
			"마보로시가 마작을 좋아한다는 소문을 들은 거야.\n나도 열심히 마작을 배운 거야!",
		],
		"stage1_intro": [
			"어라, 마보로시를 놓쳐 버린 거야.\n이쪽으로 걸어간 것처럼 보였는데...",
			"저기, 너.\n이 앞은 사유지니까 들어가면 안 돼.",
			"안녕하세요, 누나.\n내 이름은 표코탄인 거야!",
			"안녕, 표코탄.\n인사도 잘하네. 나는 유메야.",
			"이 산은 우리 일족의 집이야.\n위험하니까 마음대로 들어가면 안 돼.",
			"하지만 내 친구가 이 앞쪽으로 가는 걸 본 거야!",
			"어, 정말? 이상하네.\n엄마밖에 오지 않았을 텐데...",
			"혹시 내가 못 본 걸까?\n어쩌지, 언니한테 혼나겠어...",
			"걱정 마, 누나!\n내가 책임지고 찾아올 거야!",
			"고마워, 표코탄.\n그래도 걱정되네. 표코탄은 마작을 알아?",
			"마작! 알고 있는 거야!",
			"하지만 조금밖에 모르는 거야.",
			"그렇구나. 이 앞에는 언니도 있고,\n위험하니까 내가 요령을 조금 알려 줄게.",
		],
		"stage2_intro": [
			"어두워지고 있는 거야...",
			"잠깐잠깐!\n왜 멋대로 우리 산에 들어온 거야, 꼬맹아!",
			"안녕하세요, 누나.\n내 이름은 표코탄인 거야!",
			"하아? 아무도 네 이름 같은 거 안 물어봤거든?",
			"불법 침입이야, 불법 침입.\n얼른 돌아가!",
			"이 누나는 무서운 사람인 거야...",
			"언니. 이 아이 친구가 이쪽으로 왔다는데, 못 봤어?",
			"하아? 엄마밖에 안 온 게 당연하잖아.\n너 무슨 소리야?",
			"뭐, 마침 심심했으니까.\n마작으로 나를 이기면 보내 줄게.",
		],
		"stage3_intro": [
			"엄마~!\n뭔가 이상한 녀석이 왔어!",
			"무슨 일이냐, 우츠츠. 시끄럽구나.",
			"아, 마보로시!\n드디어 찾은 거야!",
			"너는...",
			"어, 엄마.\n이 아이 알아?",
			"내가 다니는 곳에서 소문난 남자다.",
			"분명 부모의 돈을 다 써 버리고\n본가 출입 금지를 당한 남자...\n표코탄!",
			"어, 어째서 내 비밀을 알고 있는 거야!",
			"뭐, 괜찮은 거야.\n오늘은 놀러 온 거야.\n마보로시, 나와 마작으로 승부인 거야!",
		],
		"ex_stage1_intro": [
			"또 와 버린 거야.\n마보로시랑 마작으로 놀 거야!",
			"어라?\n아직 낮인데 이상하게 어두운 느낌이 드는 거야.",
			"침입자...",
			"아, 상냥한 쪽 누나!\n표코탄인 거야! 또 놀러 온 거야!",
			"인간...\n배제해야 해...",
			"누나 상태가 뭔가 이상한 거야...?",
		],
		"ex_stage2_intro": [
			"기분 나쁜 거야...\n전에 왔을 때와 분위기가 완전히 다른 거야.",
			"꼬맹이...!\n왜 네가 여기 있는 거야!",
			"아, 무서운 쪽 누나인 거야.",
			"뭐 좋아.\n조금 짜증 나 있던 참이니까, 내가 특별히 놀아 줄게. 오늘은 봐주지 않아!",
			"와아! 괴롭힘당하는 거야!",
		],
		"ex_stage3_intro": [
			"어떻게든 산 정상에 온 거야...",
			"흥.\n여기까지 잘도 왔구나.",
			"아, 마보로시!\n놀자!",
			"재미있군. 좋다.\n너는 나를 상대할 자격이 있다...!",
		],
		"mirage_clear": [
			"드, 드디어 클리어한 거야...\n이걸로 나도 어엿한 마작꾼인 거야!",
			"제법이구나, 출입 금지 남자.\n조금은 인정해 줘도 되겠어.",
			"대단해, 표코탄!\n이걸로 청일색은 완벽하네!",
			"조금은 하잖아.\n그런데 부모님 돈을 다 썼다는 이야기 말인데, 어디에 쓴 거야?",
			"나는 파치슬롯을 정말 좋아하는 거야!",
			"아, 그래.",
			"이 정도라면 또 마작 상대를 해 줘도 되겠군.\n좋아할 때 놀러 와라.",
			"해냈다! 또 놀러 올 거야!",
			"다만 보름달이 뜬 날은 그만둬라.\n나는 몰라도 딸들은 아직 늑대인간으로 미숙한 몸. 거친 환영이 될지도 모른다.",
			"?\n알겠는 거야!",
		],
		"nightmare_clear": [
			"...!!",
			"해, 해냈다...",
			"드디어 클리어한 거야!!",
			"제법이구나.\n마작 프로라 해도 쉽게 클리어할 수 없는 난이도였을 텐데...",
			"'청일색 마스터'라는 칭호를 주마. 가서 자랑해도 좋다.",
			"청일색 마스터...\n좋은 울림인 거야!",
		],
	},
}


static func normalize_locale(locale: String) -> String:
	if locale in LOCALES:
		return locale
	return "ja"


static func ui_text(locale: String, key: String) -> String:
	var normalized := normalize_locale(locale)
	var dict: Dictionary = UI_TEXT.get(normalized, UI_TEXT["ja"])
	return str(dict.get(key, UI_TEXT["ja"].get(key, "")))


static func speaker_name(locale: String, speaker: String, fallback: String) -> String:
	var normalized := normalize_locale(locale)
	if normalized == "ja":
		return fallback
	var dict: Dictionary = SPEAKER_NAMES.get(normalized, {})
	return str(dict.get(speaker, fallback))


static func talk_text(locale: String, scene_id: String, index: int, fallback: String) -> String:
	var normalized := normalize_locale(locale)
	if normalized == "ja":
		return fallback
	var locale_dict: Dictionary = TALK_TEXT.get(normalized, {})
	var scene_lines: Array = locale_dict.get(scene_id, [])
	if index < 0 or index >= scene_lines.size():
		return fallback
	return str(scene_lines[index])

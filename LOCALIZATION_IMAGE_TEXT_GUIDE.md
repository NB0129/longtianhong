# Localization Image Text Guide

This is the working guide for replacing baked-in image text during localization.

Locales:
- `ja`: Japanese
- `en`: English
- `zh_CN`: Simplified Chinese
- `zh_TW`: Traditional Chinese
- `ko`: Korean

Notes:
- Keep `assets/ui/matiate.webp` as the Japanese brand logo for now.
- Prefer `Machiate!` as the romanized brand name outside Japanese storefront text.
- The text below is a practical UI proposal, not final marketing copy.
- Files marked "check visually" should be opened in an image editor before production replacement.

## Title

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/ui/matiate.webp` | まちあて！ | Machiate! | Machiate! | Machiate! | Machiate! | Optional |
| `assets/ui/tinitukuizu.webp` | ちんいつクイズ / 清一クイズ | Chinitsu Quiz | 清一色问答 | 清一色問答 | 청일색 퀴즈 | Optional |
| `assets/ui/title_btn_story.webp` | ストーリー | Story | 剧情 | 劇情 | 스토리 | Required |
| `assets/ui/title_btn_instant.webp` | いきなり | Quick Play | 快速开始 | 快速開始 | 바로 시작 | Required |
| `assets/ui/title_btn_ranking.webp` | ランキング | Ranking | 排行榜 | 排行榜 | 랭킹 | Required |
| `assets/ui/title_btn_credit.webp` | クレジット | Credits | 制作名单 | 製作名單 | 크레딧 | Required |
| `assets/ui/haisukoa.webp` | ハイスコア | High Score | 最高分 | 最高分 | 최고 점수 | Required |

Generated localized high score labels currently live at `assets/language/normalized/<locale>/haisukoa.webp`.

## Stage Select

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/bg/menu_header_stage_select.webp` | ステージ選択 | Stage Select | 选择关卡 | 選擇關卡 | 스테이지 선택 | Required |
| `assets/bg/menu_header_ex_mode.webp` | EXモード | EX Mode | EX模式 | EX模式 | EX 모드 | Required |
| `assets/bg/menu_btn_tutorial.webp` | チュートリアル | Tutorial | 教程 | 教學 | 튜토리얼 | Required |
| `assets/bg/menu_btn_easy.webp` | かんたん | Easy | 简单 | 簡單 | 쉬움 | Required |
| `assets/bg/menu_btn_normal.webp` | ふつう | Normal | 普通 | 普通 | 보통 | Required |
| `assets/bg/menu_btn_hard.webp` | むずかしい | Hard | 困难 | 困難 | 어려움 | Required |
| `assets/bg/menu_btn_custom.webp` | カスタム | Custom | 自定义 | 自訂 | 커스텀 | Required |
| `assets/bg/menu_btn_to_ex.webp` | EXへ | EX Mode | EX模式 | EX模式 | EX 모드 | Required |
| `assets/bg/menu_btn_to_surface.webp` | 表へ / 通常へ | Main Mode | 主模式 | 主模式 | 기본 모드 | Required |
| `assets/bg/menu_btn_support.webp` | 応援 / 支援 | Support | 支持 | 支援 | 응원하기 | Required |
| `assets/bg/menu_btn_ex_too_easy.webp` | Too easy | Too Easy | 太简单 | 太簡單 | 너무 쉬움 | Required |
| `assets/bg/menu_btn_ex_abnormal.webp` | abnormal | Abnormal | 反常 | 反常 | 비정상 | Required |
| `assets/bg/menu_btn_ex_very_hard.webp` | very hard | Very Hard | 非常困难 | 非常困難 | 매우 어려움 | Required |
| `assets/bg/menu_btn_ex_endless.webp` | endless | Endless | 无尽 | 無盡 | 엔드리스 | Required |
| `assets/bg/menu_btn_ex_music_room.webp` | music room | Music Room | 音乐室 | 音樂室 | 음악실 | Required |
| `assets/bg/mikai2.webp` | 未開放 | Locked | 未解锁 | 未解鎖 | 잠김 | Required |

## Custom Room

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/bg/custom_room_title.webp` | カスタムルーム | Custom Room | 自定义房间 | 自訂房間 | 커스텀 룸 | Required |
| `assets/bg/custom_btn_back.webp` | 戻る | Back | 返回 | 返回 | 뒤로 | Required |
| `assets/bg/custom_btn_start.webp` | 開始 | Start | 开始 | 開始 | 시작 | Required |

## In-Game Keypad

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/ui/keypad_buttons/keypad_btn_clear.webp` | クリア | Clear | 清除 | 清除 | 지우기 | Required |
| `assets/ui/keypad_buttons/keypad_btn_clear_pressed.webp` | クリア | Clear | 清除 | 清除 | 지우기 | Required |
| `assets/ui/keypad_buttons/keypad_btn_submit.webp` | 決定 / 答える | Submit | 提交 | 提交 | 제출 | Required |
| `assets/ui/keypad_buttons/keypad_btn_submit_pressed.webp` | 決定 / 答える | Submit | 提交 | 提交 | 제출 | Required |
| `assets/ui/keypad_buttons/keypad_btn_submit_disabled.webp` | 決定 / 答える | Submit | 提交 | 提交 | 제출 | Required |
| `assets/ui/keypad_buttons/keypad_btn_none.webp` | なし | None | 无 | 無 | 없음 | Required |
| `assets/ui/keypad_buttons/keypad_btn_none_pressed.webp` | なし | None | 无 | 無 | 없음 | Required |
| `assets/ui/keypad_buttons/keypad_btn_none_disabled.webp` | なし | None | 无 | 無 | 없음 | Required |

## Result

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/ui/result_header_clear_v2.webp` | ステージクリア | Stage Clear | 关卡通关 | 關卡通關 | 스테이지 클리어 | Required |
| `assets/ui/result_panel_v2.webp` | 結果 | Result | 结果 | 結果 | 결과 | Required |
| `assets/ui/result_gameover_text_v2.webp` | GAME OVER | Game Over | 游戏结束 | 遊戲結束 | 게임 오버 | Required |
| `assets/ui/seikai.webp` | 正解 | Correct | 正确 | 正確 | 정답 | Required |
| `assets/ui/result_buttons/result_btn_retry_v2.webp` | リトライ | Retry | 重试 | 重試 | 다시 하기 | Required |
| `assets/ui/result_buttons/result_btn_next_v2.webp` | 次へ | Next | 下一关 | 下一關 | 다음 | Required |
| `assets/ui/result_buttons/result_btn_home_v2.webp` | ホーム | Home | 主页 | 首頁 | 홈 | Required |
| `assets/ui/result_buttons/result_btn_ranking_v2.webp` | ランキング | Ranking | 排行榜 | 排行榜 | 랭킹 | Required |
| `assets/ui/result_buttons/result_btn_answer_v2.webp` | 答え | Answer | 答案 | 答案 | 정답 보기 | Required |
| `assets/ui/result_buttons/result_btn_back_v2.webp` | 戻る | Back | 返回 | 返回 | 뒤로 | Required |

## Popups

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/ui/popups/popup_btn_close_generated.webp` | 閉じる | Close | 关闭 | 關閉 | 닫기 | Required |
| `assets/ui/popups/popup_btn_close_generated_pressed.webp` | 閉じる | Close | 关闭 | 關閉 | 닫기 | Required |
| `assets/ui/popups/popup_btn_close_v2.webp` | 閉じる | Close | 关闭 | 關閉 | 닫기 | Required |
| `assets/ui/popups/popup_btn_yes_generated.webp` | はい | Yes | 是 | 是 | 예 | Required |
| `assets/ui/popups/popup_btn_yes_generated_pressed.webp` | はい | Yes | 是 | 是 | 예 | Required |
| `assets/ui/popups/popup_btn_yes_v2.webp` | はい | Yes | 是 | 是 | 예 | Required |
| `assets/ui/popups/popup_btn_no_generated.webp` | いいえ | No | 否 | 否 | 아니요 | Required |
| `assets/ui/popups/popup_btn_no_generated_pressed.webp` | いいえ | No | 否 | 否 | 아니요 | Required |
| `assets/ui/popups/popup_btn_no_v2.webp` | いいえ | No | 否 | 否 | 아니요 | Required |
| `assets/ui/popups/popup_btn_back_v2.webp` | 戻る | Back | 返回 | 返回 | 뒤로 | Required |
| `assets/ui/popups/popup_btn_buy_generated.webp` | 購入 | Buy | 购买 | 購買 | 구매 | Required |
| `assets/ui/popups/popup_btn_buy_generated_pressed.webp` | 購入 | Buy | 购买 | 購買 | 구매 | Required |
| `assets/ui/popups/popup_btn_restore_generated.webp` | 復元 | Restore | 恢复购买 | 恢復購買 | 복원 | Required |
| `assets/ui/popups/popup_btn_restore_generated_pressed.webp` | 復元 | Restore | 恢复购买 | 恢復購買 | 복원 | Required |
| `assets/ui/popups/popup_btn_support_buy_generated.webp` | 応援購入 | Support | 支持 | 支援 | 응원하기 | Required |
| `assets/ui/popups/popup_btn_support_buy_generated_pressed.webp` | 応援購入 | Support | 支持 | 支援 | 응원하기 | Required |
| `assets/ui/popups/popup_btn_support_restore_generated.webp` | 購入を復元 | Restore | 恢复购买 | 恢復購買 | 구매 복원 | Required |
| `assets/ui/popups/popup_btn_support_restore_generated_pressed.webp` | 購入を復元 | Restore | 恢复购买 | 恢復購買 | 구매 복원 | Required |
| `assets/ui/popups/popup_btn_support_close_generated.webp` | 閉じる | Close | 关闭 | 關閉 | 닫기 | Required |
| `assets/ui/popups/popup_btn_support_close_generated_pressed.webp` | 閉じる | Close | 关闭 | 關閉 | 닫기 | Required |

## Stage Intro

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/ui/stage_intro/difficulty_label_jp.webp` | 難易度 | Difficulty | 难度 | 難度 | 난이도 | Required |
| `assets/ui/stage_intro/difficulty_kantan_logo.webp` | かんたん | Easy | 简单 | 簡單 | 쉬움 | Required |
| `assets/ui/stage_intro/difficulty_futsuu_logo.webp` | ふつう | Normal | 普通 | 普通 | 보통 | Required |
| `assets/ui/stage_intro/difficulty_muzukashii_logo.webp` | むずかしい | Hard | 困难 | 困難 | 어려움 | Required |
| `assets/ui/stage_intro/difficulty_mirage_logo.webp` | 幻 / Mirage | Mirage | 幻境 | 幻境 | 미라지 | Required |
| `assets/ui/stage_intro/difficulty_ex_too_easy_logo.webp` | Too easy | Too Easy | 太简单 | 太簡單 | 너무 쉬움 | Required |
| `assets/ui/stage_intro/difficulty_ex_abnormal_logo.webp` | abnormal | Abnormal | 反常 | 反常 | 비정상 | Required |
| `assets/ui/stage_intro/difficulty_ex_very_hard_logo.webp` | very hard | Very Hard | 非常困难 | 非常困難 | 매우 어려움 | Required |
| `assets/ui/stage_intro/difficulty_ex_nightmare_logo.webp` | nightmare | Nightmare | 噩梦 | 惡夢 | 악몽 | Required |
| `assets/ui/stage_intro/difficulty_ex_endless_logo.webp` | endless | Endless | 无尽 | 無盡 | 엔드리스 | Required |

## Music Room

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/bg/music_title_ui.webp` | 音楽室 | Music Room | 音乐室 | 音樂室 | 음악실 | Required |
| `assets/bg/music_now_playing_ui.webp` | 再生中 | Now Playing | 正在播放 | 正在播放 | 재생 중 | Required |
| `assets/bg/music_header_all_tracks_ui.webp` | 全曲 | All Tracks | 全部曲目 | 全部曲目 | 전체 곡 | Required |
| `assets/bg/music_btn_play_ui.webp` | 再生 | Play | 播放 | 播放 | 재생 | Required |
| `assets/bg/music_btn_pause_ui.webp` | 一時停止 | Pause | 暂停 | 暫停 | 일시정지 | Required |
| `assets/bg/music_btn_stop_ui.webp` | 停止 | Stop | 停止 | 停止 | 정지 | Required |

## Other Image Text

| File | Current meaning | en | zh_CN | zh_TW | ko | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| `assets/ui/four_chiitoi_hint.webp` | 4枚七対子用ヒント / check visually | 4-Tile Chiitoi | 4张七对子 | 4張七對子 | 4장 치또이 | Check |
| `assets/ui/ending_end_generated.webp` | END / 終 | The End | 完 | 完 | 끝 | Required |

Generated localized misc assets currently live under:
- `assets/language/normalized/<locale>/misc/four_chiitoi_hint.webp`

## Jacket Images

Music jacket images may contain song titles. Treat these as low priority unless the text is large enough to read in normal play.

Recommended policy:
- Keep song titles as Japanese proper nouns for the first localization pass.
- Localize track display names in `MusicRoom.gd` or translation resources instead.
- Revisit jacket text only if the storefront/screenshots rely on the music room.

Files to inspect:
- `assets/ui/stage_intro/jacket_bgm_gameover_mou.webp`
- `assets/ui/stage_intro/jacket_bgm_gameover_mou_character_trial.webp`
- `assets/ui/stage_intro/jacket_bgm_gameover_mou_silhouette_trial.webp`
- `assets/ui/stage_intro/jacket_bgm_mabo_first_2tunoboketu.webp`
- `assets/ui/stage_intro/jacket_bgm_mabo_first_appaku_no_tiles.webp`
- `assets/ui/stage_intro/jacket_bgm_mabo_first_nebumi.webp`
- `assets/ui/stage_intro/jacket_bgm_mabo_mugen.webp`
- `assets/ui/stage_intro/jacket_bgm_mabo_second_ginniro.webp`
- `assets/ui/stage_intro/jacket_bgm_mabo_second_inisie.webp`
- `assets/ui/stage_intro/jacket_bgm_mabo_second_kougetu_v2.webp`
- `assets/ui/stage_intro/jacket_bgm_talk_easy.webp`
- `assets/ui/stage_intro/jacket_bgm_talk_hard.webp`
- `assets/ui/stage_intro/jacket_bgm_talk_normal.webp`
- `assets/ui/stage_intro/jacket_bgm_talk_tutorial.webp`
- `assets/ui/stage_intro/jacket_bgm_t_sentaku.webp`
- `assets/ui/stage_intro/jacket_bgm_t_title.webp`
- `assets/ui/stage_intro/jacket_bgm_utu_higakureru_v4.webp`
- `assets/ui/stage_intro/jacket_bgm_utu_kotaewo_v3.webp`
- `assets/ui/stage_intro/jacket_bgm_utu_matigai.webp`
- `assets/ui/stage_intro/jacket_bgm_utu_nochan_trial.webp`
- `assets/ui/stage_intro/jacket_bgm_yume_barabara.webp`
- `assets/ui/stage_intro/jacket_bgm_yume_jantou_v4.webp`
- `assets/ui/stage_intro/jacket_bgm_yume_reach_v8.webp`

## No Text Replacement Needed

These are probably safe to leave as-is:
- Numeric score images: `assets/ui/0.webp` through `assets/ui/9.webp`, `assets/ui/w0.webp` through `assets/ui/w9.webp`, `assets/ui/score_*.webp`, `assets/ui/menu_score_*.webp`, `assets/ui/+.webp`, `assets/ui/w+.webp`
- Stars: `assets/ui/stage_intro/difficulty_star_*.webp`
- Icon-only UI: `assets/bg/music_icon_*.webp`, `assets/bg/icon_tile_display.webp`
- Backgrounds and decorative panels: `assets/bg/bg_*.webp`, `assets/bg/stage_bg_*.webp`, `assets/ui/result_panel_v2.webp`, `assets/ui/popups/popup_panel_*.webp`
- Blank popup button bases: `assets/ui/popups/popup_btn_blue*.webp`, `popup_btn_green*.webp`, `popup_btn_pink*.webp`, `popup_btn_gold*.webp`

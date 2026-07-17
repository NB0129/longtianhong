extends Node

signal state_changed
signal purchase_finished(success: bool, message: String)
signal restore_finished(success: bool, message: String)

const SUPPORT_PRODUCT_ID := "support_pack"
const NATIVE_BRIDGE_SINGLETON_CANDIDATES: Array[String] = [
	"LongtianhongStoreKit",
	"LongtianhongBilling",
]

const SUPPORT_MESSAGES: Dictionary = {
	"ja": {
		"purchase_success": "開発支援を有効にしました。",
		"purchase_unavailable": "購入機能は現在準備中です。",
		"purchase_canceled": "購入をキャンセルしました。",
		"purchase_pending": "購入が保留中です。Google Play の処理完了後にもう一度確認してください。",
		"purchase_missing": "購入情報を確認できませんでした。時間をおいて再度お試しください。",
		"purchase_failed": "購入処理に失敗しました。時間をおいて再度お試しください。",
		"restore_success": "購入済み状態を確認しました。",
		"restore_none": "復元できる購入はありません。",
		"restore_unavailable": "購入の復元機能は現在準備中です。",
		"purchase_init_failed": "購入機能の初期化に失敗しました。",
		"restore_init_failed": "購入情報の確認に失敗しました。",
	},
	"en": {
		"purchase_success": "Development support has been enabled.",
		"purchase_unavailable": "Purchases are currently being prepared.",
		"purchase_canceled": "Purchase canceled.",
		"purchase_pending": "Purchase is pending. Please check again after Google Play finishes processing it.",
		"purchase_missing": "Purchase information could not be confirmed. Please try again later.",
		"purchase_failed": "Purchase failed. Please try again later.",
		"restore_success": "Purchased status confirmed.",
		"restore_none": "No purchase is available to restore.",
		"restore_unavailable": "Purchase restoration is currently being prepared.",
		"purchase_init_failed": "Failed to initialize purchases.",
		"restore_init_failed": "Failed to check purchase information.",
	},
	"zh_CN": {
		"purchase_success": "已启用开发支援。",
		"purchase_unavailable": "购买功能目前正在准备中。",
		"purchase_canceled": "已取消购买。",
		"purchase_pending": "购买正在处理中。请在 Google Play 处理完成后再次确认。",
		"purchase_missing": "无法确认购买信息。请稍后重试。",
		"purchase_failed": "购买失败。请稍后重试。",
		"restore_success": "已确认购买状态。",
		"restore_none": "没有可恢复的购买。",
		"restore_unavailable": "购买恢复功能目前正在准备中。",
		"purchase_init_failed": "购买功能初始化失败。",
		"restore_init_failed": "购买信息确认失败。",
	},
	"zh_TW": {
		"purchase_success": "已啟用開發支援。",
		"purchase_unavailable": "購買功能目前正在準備中。",
		"purchase_canceled": "已取消購買。",
		"purchase_pending": "購買正在處理中。請在 Google Play 處理完成後再次確認。",
		"purchase_missing": "無法確認購買資訊。請稍後再試。",
		"purchase_failed": "購買失敗。請稍後再試。",
		"restore_success": "已確認購買狀態。",
		"restore_none": "沒有可復原的購買。",
		"restore_unavailable": "購買復原功能目前正在準備中。",
		"purchase_init_failed": "購買功能初始化失敗。",
		"restore_init_failed": "購買資訊確認失敗。",
	},
	"ko": {
		"purchase_success": "개발 지원이 활성화되었습니다.",
		"purchase_unavailable": "구매 기능은 현재 준비 중입니다.",
		"purchase_canceled": "구매를 취소했습니다.",
		"purchase_pending": "구매가 처리 중입니다. Google Play 처리가 끝난 뒤 다시 확인해 주세요.",
		"purchase_missing": "구매 정보를 확인할 수 없습니다. 잠시 후 다시 시도해 주세요.",
		"purchase_failed": "구매에 실패했습니다. 잠시 후 다시 시도해 주세요.",
		"restore_success": "구매 상태를 확인했습니다.",
		"restore_none": "복원할 수 있는 구매가 없습니다.",
		"restore_unavailable": "구매 복원 기능은 현재 준비 중입니다.",
		"purchase_init_failed": "구매 기능 초기화에 실패했습니다.",
		"restore_init_failed": "구매 정보 확인에 실패했습니다.",
	},
}

var is_busy: bool = false
var _native_bridge: Object = null


func _ready() -> void:
	_detect_native_bridge()


func is_supporter() -> bool:
	return SaveData.is_supporter


func refresh_entitlements() -> void:
	if _has_native_bridge():
		_call_native_bridge("refresh_entitlements", [SUPPORT_PRODUCT_ID])
		return
	state_changed.emit()


func purchase_support() -> void:
	if is_busy:
		return
	is_busy = true
	state_changed.emit()
	if _has_native_bridge():
		_call_native_bridge("purchase_support", [SUPPORT_PRODUCT_ID])
		return
	if OS.is_debug_build():
		_set_supporter_from_purchase(true)
		_finish_purchase(true, _support_message("purchase_success"))
	else:
		_finish_purchase(false, _support_message("purchase_unavailable"))


func restore_support() -> void:
	if is_busy:
		return
	is_busy = true
	state_changed.emit()
	if _has_native_bridge():
		_call_native_bridge("restore_support", [SUPPORT_PRODUCT_ID])
		return
	if SaveData.is_supporter:
		_finish_restore(true, _support_message("restore_success"))
	elif OS.is_debug_build():
		_finish_restore(false, _support_message("restore_none"))
	else:
		_finish_restore(false, _support_message("restore_unavailable"))


func debug_reset_supporter() -> void:
	SaveData.set_supporter(false)
	state_changed.emit()


func complete_native_purchase(success: bool, message: String, owns_product: bool) -> void:
	if owns_product:
		_set_supporter_from_purchase(true)
	var display_message := _native_purchase_message(success, message, owns_product)
	_finish_purchase(success and owns_product, display_message)


func complete_native_restore(success: bool, message: String, owns_product: bool) -> void:
	_set_supporter_from_purchase(owns_product)
	var display_message := _native_restore_message(success, message, owns_product)
	_finish_restore(success and owns_product, display_message)


func complete_native_entitlement_check(owns_product: bool) -> void:
	_set_supporter_from_purchase(owns_product)
	state_changed.emit()


func _set_supporter_from_purchase(value: bool) -> void:
	SaveData.set_supporter(value)


func _finish_purchase(success: bool, message: String) -> void:
	is_busy = false
	state_changed.emit()
	purchase_finished.emit(success, message)


func _finish_restore(success: bool, message: String) -> void:
	is_busy = false
	state_changed.emit()
	restore_finished.emit(success, message)


func _has_native_bridge() -> bool:
	_detect_native_bridge()
	return _native_bridge != null


func _call_native_bridge(method_name: String, args: Array) -> void:
	_detect_native_bridge()
	var bridge: Object = _native_bridge
	if bridge != null and bridge.has_method(method_name):
		bridge.callv(method_name, args)
		return
	if method_name == "purchase_support":
		_finish_purchase(false, _support_message("purchase_init_failed"))
	elif method_name == "restore_support":
		_finish_restore(false, _support_message("restore_init_failed"))
	else:
		state_changed.emit()


func _native_purchase_message(success: bool, message: String, owns_product: bool) -> String:
	if success and owns_product:
		return _support_message("purchase_success")
	match message:
		"purchase_canceled":
			return _support_message("purchase_canceled")
		"purchase_pending":
			return _support_message("purchase_pending")
		"purchase_missing":
			return _support_message("purchase_missing")
		"purchase_completed":
			return _support_message("purchase_success")
	if message.begins_with("billing_"):
		return _support_message("purchase_failed")
	return _support_message("purchase_failed")


func _native_restore_message(success: bool, message: String, owns_product: bool) -> String:
	if success and owns_product:
		return _support_message("restore_success")
	if message == "not_owned":
		return _support_message("restore_none")
	if message == "restore_completed":
		return _support_message("restore_success")
	if message.begins_with("billing_"):
		return _support_message("restore_init_failed")
	return _support_message("restore_none")


func _support_message(key: String) -> String:
	var language: String = SaveData.normalize_language_code(SaveData.language_code)
	var messages: Dictionary = SUPPORT_MESSAGES.get(language, SUPPORT_MESSAGES["ja"])
	return str(messages.get(key, SUPPORT_MESSAGES["ja"].get(key, "")))


func _detect_native_bridge() -> void:
	if _native_bridge != null:
		return
	for singleton_name in NATIVE_BRIDGE_SINGLETON_CANDIDATES:
		if Engine.has_singleton(singleton_name):
			_native_bridge = Engine.get_singleton(singleton_name)
			_connect_native_bridge_signals()
			print("[SupportPurchase] native bridge detected: ", singleton_name)
			return


func _connect_native_bridge_signals() -> void:
	if _native_bridge == null:
		return
	if _native_bridge.has_signal("purchase_finished") and not _native_bridge.purchase_finished.is_connected(_on_native_purchase_finished):
		_native_bridge.purchase_finished.connect(_on_native_purchase_finished)
	if _native_bridge.has_signal("restore_finished") and not _native_bridge.restore_finished.is_connected(_on_native_restore_finished):
		_native_bridge.restore_finished.connect(_on_native_restore_finished)
	if _native_bridge.has_signal("entitlement_check_finished") and not _native_bridge.entitlement_check_finished.is_connected(_on_native_entitlement_check_finished):
		_native_bridge.entitlement_check_finished.connect(_on_native_entitlement_check_finished)


func _on_native_purchase_finished(success: bool, message: String, owns_product: bool) -> void:
	complete_native_purchase(success, message, owns_product)


func _on_native_restore_finished(success: bool, message: String, owns_product: bool) -> void:
	complete_native_restore(success, message, owns_product)


func _on_native_entitlement_check_finished(owns_product: bool) -> void:
	complete_native_entitlement_check(owns_product)

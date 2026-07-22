extends Node

signal state_changed
signal purchase_finished(success: bool, message: String)
signal restore_finished(success: bool, message: String)

const SUPPORT_PRODUCT_ID := "support_pack"
const OPERATION_NONE := ""
const OPERATION_PURCHASE := "purchase"
const OPERATION_RESTORE := "restore"
const IOS_IN_APP_STORE_SINGLETON := "InAppStore"
const IOS_EVENT_DRAIN_LIMIT := 128
const OPERATION_TIMEOUT_SECONDS := 300.0
const OPERATION_RESUME_RECOVERY_SECONDS := 15.0
const NATIVE_BRIDGE_SINGLETON_CANDIDATES: Array[String] = [
	"LongtianhongStoreKit",
	"LongtianhongBilling",
]

const SUPPORT_MESSAGES: Dictionary = {
	"ja": {
		"purchase_success": "開発支援を有効にしました。",
		"purchase_unavailable": "購入機能は現在準備中です。",
		"purchase_canceled": "購入をキャンセルしました。",
		"purchase_pending": "購入が保留中です。ストアの処理完了後にもう一度確認してください。",
		"purchase_missing": "購入情報を確認できませんでした。時間をおいて再度お試しください。",
		"purchase_price_updated": "価格情報が更新されました。表示価格を確認して、もう一度購入してください。",
		"purchase_failed": "購入処理に失敗しました。時間をおいて再度お試しください。",
		"restore_success": "購入済み状態を確認しました。",
		"restore_none": "復元できる購入はありません。",
		"restore_unavailable": "購入の復元機能は現在準備中です。",
		"purchase_init_failed": "購入機能の初期化に失敗しました。",
		"restore_init_failed": "購入情報の確認に失敗しました。",
		"purchase_timeout": "購入結果を確認できませんでした。購入状況を確認し、アプリを再起動してからもう一度お試しください。",
		"restore_timeout": "購入情報の確認に時間がかかっています。アプリを再起動してからもう一度お試しください。",
	},
	"en": {
		"purchase_success": "Development support has been enabled.",
		"purchase_unavailable": "Purchases are currently being prepared.",
		"purchase_canceled": "Purchase canceled.",
		"purchase_pending": "Purchase is pending. Please check again after the store finishes processing it.",
		"purchase_missing": "Purchase information could not be confirmed. Please try again later.",
		"purchase_price_updated": "The price was updated. Check the displayed price, then tap purchase again.",
		"purchase_failed": "Purchase failed. Please try again later.",
		"restore_success": "Purchased status confirmed.",
		"restore_none": "No purchase is available to restore.",
		"restore_unavailable": "Purchase restoration is currently being prepared.",
		"purchase_init_failed": "Failed to initialize purchases.",
		"restore_init_failed": "Failed to check purchase information.",
		"purchase_timeout": "The purchase result could not be confirmed. Check its status, then restart the app before trying again.",
		"restore_timeout": "Checking purchase information took too long. Restart the app before trying again.",
	},
	"zh_CN": {
		"purchase_success": "已启用开发支援。",
		"purchase_unavailable": "购买功能目前正在准备中。",
		"purchase_canceled": "已取消购买。",
		"purchase_pending": "购买正在处理中。请在商店处理完成后再次确认。",
		"purchase_missing": "无法确认购买信息。请稍后重试。",
		"purchase_price_updated": "价格信息已更新。请确认显示的价格后再次购买。",
		"purchase_failed": "购买失败。请稍后重试。",
		"restore_success": "已确认购买状态。",
		"restore_none": "没有可恢复的购买。",
		"restore_unavailable": "购买恢复功能目前正在准备中。",
		"purchase_init_failed": "购买功能初始化失败。",
		"restore_init_failed": "购买信息确认失败。",
		"purchase_timeout": "无法确认购买结果。请检查购买状态并重启应用后再试。",
		"restore_timeout": "购买信息确认超时。请重启应用后再试。",
	},
	"zh_TW": {
		"purchase_success": "已啟用開發支援。",
		"purchase_unavailable": "購買功能目前正在準備中。",
		"purchase_canceled": "已取消購買。",
		"purchase_pending": "購買正在處理中。請在商店處理完成後再次確認。",
		"purchase_missing": "無法確認購買資訊。請稍後再試。",
		"purchase_price_updated": "價格資訊已更新。請確認顯示的價格後再次購買。",
		"purchase_failed": "購買失敗。請稍後再試。",
		"restore_success": "已確認購買狀態。",
		"restore_none": "沒有可復原的購買。",
		"restore_unavailable": "購買復原功能目前正在準備中。",
		"purchase_init_failed": "購買功能初始化失敗。",
		"restore_init_failed": "購買資訊確認失敗。",
		"purchase_timeout": "無法確認購買結果。請檢查購買狀態並重新啟動App後再試。",
		"restore_timeout": "確認購買資訊逾時。請重新啟動App後再試。",
	},
	"ko": {
		"purchase_success": "개발 지원이 활성화되었습니다.",
		"purchase_unavailable": "구매 기능은 현재 준비 중입니다.",
		"purchase_canceled": "구매를 취소했습니다.",
		"purchase_pending": "구매가 처리 중입니다. 스토어 처리가 끝난 뒤 다시 확인해 주세요.",
		"purchase_missing": "구매 정보를 확인할 수 없습니다. 잠시 후 다시 시도해 주세요.",
		"purchase_price_updated": "가격 정보가 업데이트되었습니다. 표시된 가격을 확인한 뒤 다시 구매해 주세요.",
		"purchase_failed": "구매에 실패했습니다. 잠시 후 다시 시도해 주세요.",
		"restore_success": "구매 상태를 확인했습니다.",
		"restore_none": "복원할 수 있는 구매가 없습니다.",
		"restore_unavailable": "구매 복원 기능은 현재 준비 중입니다.",
		"purchase_init_failed": "구매 기능 초기화에 실패했습니다.",
		"restore_init_failed": "구매 정보 확인에 실패했습니다.",
		"purchase_timeout": "구매 결과를 확인할 수 없습니다. 구매 상태를 확인하고 앱을 다시 시작한 뒤 재시도해 주세요.",
		"restore_timeout": "구매 정보 확인 시간이 초과되었습니다. 앱을 다시 시작한 뒤 재시도해 주세요.",
	},
}

var is_busy: bool = false
var product_info_loaded: bool = false
var product_info_loading: bool = false
var product_available: bool = false
var formatted_price: String = ""
var product_info_message: String = ""
var _native_bridge: Object = null
var _ios_in_app_store: Object = null
var _ios_restore_request_in_flight: bool = false
var _ios_restore_saw_owned_product: bool = false
var _entitlement_refresh_in_flight: bool = false
var _entitlement_refresh_pending: bool = false
var _entitlement_refresh_revision: int = -1
var _ownership_revision: int = 0
var _active_operation: String = OPERATION_NONE
var _active_operation_revision: int = -1
var _refresh_after_resume_pending: bool = false
var _active_operation_elapsed: float = 0.0
var _resume_recovery_pending: bool = false
var _resume_recovery_elapsed: float = 0.0
var _retry_blocked_operations: Dictionary = {
	OPERATION_PURCHASE: false,
	OPERATION_RESTORE: false,
}


func _ready() -> void:
	_detect_native_bridge()
	if _native_bridge == null:
		_detect_ios_in_app_store()
	set_process(_ios_in_app_store != null)


func _process(delta: float) -> void:
	_drain_ios_events()
	_update_operation_watchdog(delta)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		call_deferred("_handle_application_resumed")


func _handle_application_resumed() -> void:
	# A queued StoreKit result gets the first chance to finish the operation. If no
	# callback arrives, release the modal lock after a short grace period instead of
	# trapping the player indefinitely.
	_drain_ios_events()
	if is_busy:
		_resume_recovery_pending = true
		_resume_recovery_elapsed = 0.0
	_refresh_after_resume()


func _refresh_after_resume() -> void:
	if not _has_purchase_backend():
		return
	if is_busy:
		_refresh_after_resume_pending = true
		return
	_refresh_after_resume_pending = false
	refresh_product_info()
	refresh_entitlements()


func is_supporter() -> bool:
	return SaveData.is_supporter


func is_purchase_retry_blocked() -> bool:
	return bool(_retry_blocked_operations.get(OPERATION_PURCHASE, false))


func is_restore_retry_blocked() -> bool:
	return bool(_retry_blocked_operations.get(OPERATION_RESTORE, false))


func get_retry_block_message() -> String:
	if is_purchase_retry_blocked():
		return _support_message("purchase_timeout")
	if is_restore_retry_blocked():
		return _support_message("restore_timeout")
	return ""


func can_offer_support_purchase() -> bool:
	return _can_offer_support_purchase(OS.is_debug_build())


func _can_offer_support_purchase(is_debug_build: bool) -> bool:
	return is_debug_build or _has_purchase_backend()


func refresh_product_info() -> void:
	if product_info_loading:
		return
	if _has_native_bridge():
		_begin_product_info_refresh()
		_call_native_bridge("query_product_info", [SUPPORT_PRODUCT_ID])
		return
	if _has_ios_in_app_store():
		_begin_product_info_refresh()
		var request := {"product_ids": [SUPPORT_PRODUCT_ID]}
		if not _call_ios_in_app_store("request_product_info", [request]):
			_finish_ios_product_info_failure("purchase_init_failed")
		return
	product_info_loading = false
	product_info_loaded = true
	product_available = OS.is_debug_build()
	formatted_price = ""
	product_info_message = "debug_product" if product_available else "purchase_unavailable"
	state_changed.emit()


func refresh_entitlements() -> void:
	if _entitlement_refresh_in_flight or is_busy:
		if _has_purchase_backend():
			_entitlement_refresh_pending = true
		return
	if _has_native_bridge():
		_entitlement_refresh_pending = false
		_entitlement_refresh_in_flight = true
		_entitlement_refresh_revision = _ownership_revision
		_call_native_bridge("refresh_entitlements", [SUPPORT_PRODUCT_ID])
		return
	if _has_ios_in_app_store():
		_entitlement_refresh_pending = false
		# Apple recommends restore only after an explicit user action because it can
		# prompt for App Store credentials. The documented InAppStore plugin does not
		# expose StoreKit 2 currentEntitlements, so automatic refresh keeps the cache.
		state_changed.emit()
		return
	state_changed.emit()


func purchase_support() -> void:
	if is_busy:
		return
	if is_purchase_retry_blocked():
		purchase_finished.emit(false, _support_message("purchase_timeout"))
		return
	if not product_available:
		purchase_finished.emit(false, _support_message("purchase_unavailable"))
		return
	_begin_operation(OPERATION_PURCHASE)
	if _has_native_bridge():
		_call_native_bridge("purchase_support", [SUPPORT_PRODUCT_ID])
		return
	if _has_ios_in_app_store():
		var request := {"product_id": SUPPORT_PRODUCT_ID}
		if not _call_ios_in_app_store("purchase", [request]):
			_finish_purchase(false, _support_message("purchase_init_failed"))
		return
	if OS.is_debug_build():
		_apply_verified_ownership(true)
		_finish_purchase(true, _support_message("purchase_success"))
	else:
		_finish_purchase(false, _support_message("purchase_unavailable"))


func restore_support() -> void:
	if is_busy:
		return
	if is_restore_retry_blocked():
		restore_finished.emit(false, _support_message("restore_timeout"))
		return
	_begin_operation(OPERATION_RESTORE)
	if _has_native_bridge():
		_call_native_bridge("restore_support", [SUPPORT_PRODUCT_ID])
		return
	if _has_ios_in_app_store():
		if _ios_restore_request_in_flight:
			_finish_restore(false, _support_message("restore_init_failed"))
			return
		_start_ios_restore_query()
		return
	if SaveData.is_supporter:
		_finish_restore(true, _support_message("restore_success"))
	elif OS.is_debug_build():
		_finish_restore(false, _support_message("restore_none"))
	else:
		_finish_restore(false, _support_message("restore_unavailable"))


func debug_reset_supporter() -> void:
	if not OS.is_debug_build():
		return
	SaveData.set_supporter(false)
	_ownership_revision += 1
	state_changed.emit()


func complete_native_purchase(success: bool, message: String, owns_product: bool) -> void:
	_resolve_timed_out_operation(OPERATION_PURCHASE)
	if owns_product:
		_apply_verified_ownership(true)
	if _active_operation != OPERATION_PURCHASE:
		state_changed.emit()
		return
	var display_message := _native_purchase_message(success, message, owns_product)
	_finish_purchase(success and owns_product, display_message)


func complete_native_restore(query_succeeded: bool, message: String, owns_product: bool) -> void:
	var resolved_timed_out_request := _resolve_timed_out_operation(OPERATION_RESTORE)
	if _active_operation != OPERATION_RESTORE:
		# A verified success may arrive after the watchdog released the UI. Never
		# discard positive ownership, but do not let a stale negative result revoke it.
		if query_succeeded and owns_product:
			_apply_verified_ownership(true)
			resolved_timed_out_request = true
		if resolved_timed_out_request:
			state_changed.emit()
		return
	var resolved_ownership: bool = bool(SaveData.is_supporter)
	if query_succeeded and _active_operation_revision == _ownership_revision:
		_apply_verified_ownership(owns_product)
		resolved_ownership = owns_product
	var display_message := _native_restore_message(query_succeeded, message, resolved_ownership)
	_finish_restore(query_succeeded and resolved_ownership, display_message)


func complete_native_entitlement_check(query_succeeded: bool, owns_product: bool, _message: String) -> void:
	_entitlement_refresh_in_flight = false
	if query_succeeded and _entitlement_refresh_revision == _ownership_revision:
		_apply_verified_ownership(owns_product)
	state_changed.emit()
	_flush_pending_entitlement_refresh()


func complete_native_product_info(
	query_succeeded: bool,
	product_id: String,
	available: bool,
	price: String,
	message: String
) -> void:
	if product_id != SUPPORT_PRODUCT_ID:
		product_info_loading = false
		product_info_loaded = true
		product_available = false
		formatted_price = ""
		product_info_message = "product_mismatch"
		state_changed.emit()
		return
	product_info_loading = false
	product_info_loaded = true
	product_available = query_succeeded and available and not price.is_empty()
	formatted_price = price if product_available else ""
	product_info_message = message
	state_changed.emit()


func _begin_product_info_refresh() -> void:
	product_info_loading = true
	product_info_loaded = false
	product_available = false
	formatted_price = ""
	product_info_message = ""
	state_changed.emit()


func _finish_ios_product_info_failure(message: String) -> void:
	complete_native_product_info(false, SUPPORT_PRODUCT_ID, false, "", message)


func _start_ios_restore_query() -> void:
	if _ios_restore_request_in_flight:
		return
	_ios_restore_request_in_flight = true
	_ios_restore_saw_owned_product = false
	if not _call_ios_in_app_store("restore_purchases", []):
		_finish_ios_restore_query(false, "billing_ios_restore_start_failed")


func _finish_ios_restore_query(query_succeeded: bool, message: String) -> void:
	if not _ios_restore_request_in_flight:
		return
	var owns_product := _ios_restore_saw_owned_product
	_ios_restore_request_in_flight = false
	_ios_restore_saw_owned_product = false
	complete_native_restore(query_succeeded, message, owns_product)


func _drain_ios_events() -> void:
	if _ios_in_app_store == null:
		return
	var drained := 0
	while drained < IOS_EVENT_DRAIN_LIMIT:
		var pending_count: Variant = _ios_in_app_store.call("get_pending_event_count")
		if not (pending_count is int) or int(pending_count) <= 0:
			return
		var event: Variant = _ios_in_app_store.call("pop_pending_event")
		drained += 1
		if event is Dictionary:
			_handle_ios_event(event)


func _handle_ios_event(event: Dictionary) -> void:
	var event_type := str(event.get("type", "")).to_lower()
	var result := str(event.get("result", "")).to_lower()
	match event_type:
		"product_info":
			_handle_ios_product_info_event(event, result)
		"purchase":
			_handle_ios_purchase_event(event, result)
		"restore":
			_handle_ios_restore_event(event, result)
		"completed":
			_handle_ios_restore_completed_event(event, result)
		"error":
			_handle_ios_generic_error_event(event)


func _handle_ios_product_info_event(event: Dictionary, result: String) -> void:
	if not product_info_loading:
		return
	if result == "progress":
		return
	if result != "ok":
		_finish_ios_product_info_failure(_ios_error_message("product_info", event))
		return
	var product_index := _ios_find_index(event.get("ids", []), SUPPORT_PRODUCT_ID)
	if product_index < 0:
		complete_native_product_info(true, SUPPORT_PRODUCT_ID, false, "", "product_not_found")
		return
	var price := _ios_indexed_string(event.get("localized_prices", []), product_index)
	if price.is_empty():
		price = _ios_indexed_string(event.get("prices", []), product_index)
	complete_native_product_info(true, SUPPORT_PRODUCT_ID, not price.is_empty(), price, "product_info")


func _handle_ios_purchase_event(event: Dictionary, result: String) -> void:
	if result == "progress":
		return
	if result == "ok":
		var product_id := str(event.get("product_id", ""))
		if product_id == SUPPORT_PRODUCT_ID:
			complete_native_purchase(true, "purchase_completed", true)
		elif _active_operation == OPERATION_PURCHASE:
			complete_native_purchase(false, "product_mismatch", false)
		return
	complete_native_purchase(false, _ios_error_message("purchase", event), false)


func _handle_ios_restore_event(event: Dictionary, result: String) -> void:
	if not _ios_restore_request_in_flight:
		# A restored transaction can arrive after resume recovery released the UI.
		# Positive ownership is still authoritative even when its request timed out.
		var state_needs_update := false
		if result == "ok" and str(event.get("product_id", "")) == SUPPORT_PRODUCT_ID:
			_apply_verified_ownership(true)
			state_needs_update = true
		if result == "completed" or result == "error" or result == "unhandled":
			state_needs_update = _resolve_timed_out_operation(OPERATION_RESTORE) or state_needs_update
		if state_needs_update:
			state_changed.emit()
		return
	if result == "progress":
		return
	if result == "completed":
		_finish_ios_restore_query(true, _ios_restore_completion_message())
		return
	if result != "ok":
		_finish_ios_restore_query(false, _ios_error_message("restore", event))
		return
	if str(event.get("product_id", "")) != SUPPORT_PRODUCT_ID:
		return
	_ios_restore_saw_owned_product = true
	_apply_verified_ownership(true)
	state_changed.emit()


func _handle_ios_restore_completed_event(event: Dictionary, result: String) -> void:
	if not _ios_restore_request_in_flight:
		if _resolve_timed_out_operation(OPERATION_RESTORE):
			state_changed.emit()
		return
	if result == "error" or result == "unhandled":
		_finish_ios_restore_query(false, _ios_error_message("restore", event))
		return
	_finish_ios_restore_query(true, _ios_restore_completion_message())


func _handle_ios_generic_error_event(event: Dictionary) -> void:
	var operation := str(event.get("operation", event.get("request", ""))).to_lower()
	if operation == "product_info":
		_finish_ios_product_info_failure(_ios_error_message("product_info", event))
	elif operation == "purchase":
		complete_native_purchase(false, _ios_error_message("purchase", event), false)
	elif operation == "restore" or _ios_restore_request_in_flight:
		if _ios_restore_request_in_flight:
			_finish_ios_restore_query(false, _ios_error_message("restore", event))
		elif _resolve_timed_out_operation(OPERATION_RESTORE):
			state_changed.emit()
	elif _active_operation == OPERATION_PURCHASE:
		complete_native_purchase(false, _ios_error_message("purchase", event), false)
	elif product_info_loading:
		_finish_ios_product_info_failure(_ios_error_message("product_info", event))


func _ios_restore_completion_message() -> String:
	return "restore_completed" if _ios_restore_saw_owned_product else "not_owned"


func _ios_error_message(operation: String, event: Dictionary) -> String:
	var details := str(event.get("error_description", event.get("message", event.get("error", "")))).to_lower()
	if operation == "purchase" and details.contains("cancel"):
		return "purchase_canceled"
	return "billing_ios_%s_error" % operation


func _ios_find_index(values: Variant, expected: String) -> int:
	if values is Array or values is PackedStringArray:
		for index in range(values.size()):
			if str(values[index]) == expected:
				return index
	return -1


func _ios_indexed_string(values: Variant, index: int) -> String:
	if index < 0:
		return ""
	if values is Array or values is PackedStringArray or values is PackedFloat32Array or values is PackedFloat64Array:
		if index < values.size():
			return str(values[index])
	return ""


func _invalidate_entitlement_queries() -> void:
	_ownership_revision += 1


func _begin_operation(operation: String) -> void:
	_invalidate_entitlement_queries()
	is_busy = true
	_active_operation = operation
	_active_operation_revision = _ownership_revision
	_active_operation_elapsed = 0.0
	_resume_recovery_pending = false
	_resume_recovery_elapsed = 0.0
	set_process(true)
	state_changed.emit()


func _apply_verified_ownership(value: bool) -> void:
	_ownership_revision += 1
	if SaveData.is_supporter != value:
		SaveData.set_supporter(value)


func _finish_purchase(success: bool, message: String) -> void:
	if _active_operation != OPERATION_PURCHASE:
		return
	_active_operation = OPERATION_NONE
	_active_operation_revision = -1
	is_busy = false
	_reset_operation_watchdog()
	set_process(_ios_in_app_store != null)
	state_changed.emit()
	purchase_finished.emit(success, message)
	_flush_pending_resume_refresh()
	_flush_pending_entitlement_refresh()


func _finish_restore(success: bool, message: String) -> void:
	if _active_operation != OPERATION_RESTORE:
		return
	_active_operation = OPERATION_NONE
	_active_operation_revision = -1
	is_busy = false
	_reset_operation_watchdog()
	set_process(_ios_in_app_store != null)
	state_changed.emit()
	restore_finished.emit(success, message)
	_flush_pending_resume_refresh()
	_flush_pending_entitlement_refresh()


func _flush_pending_resume_refresh() -> void:
	if _refresh_after_resume_pending and not is_busy:
		call_deferred("_refresh_after_resume")


func _flush_pending_entitlement_refresh() -> void:
	if _entitlement_refresh_pending and not _entitlement_refresh_in_flight and not is_busy:
		call_deferred("refresh_entitlements")


func _update_operation_watchdog(delta: float) -> void:
	if not is_busy:
		return
	var elapsed_delta := maxf(delta, 0.0)
	_active_operation_elapsed += elapsed_delta
	if _resume_recovery_pending:
		_resume_recovery_elapsed += elapsed_delta
		if _resume_recovery_elapsed >= OPERATION_RESUME_RECOVERY_SECONDS:
			_finish_timed_out_operation()
			return
	if _active_operation_elapsed >= OPERATION_TIMEOUT_SECONDS:
		_finish_timed_out_operation()


func _finish_timed_out_operation() -> void:
	var timed_out_operation := _active_operation
	if timed_out_operation == OPERATION_PURCHASE or timed_out_operation == OPERATION_RESTORE:
		# Current native callbacks have no request ID. Quarantine only this operation
		# kind so its late result cannot be mistaken for a new request in this session.
		_retry_blocked_operations[timed_out_operation] = true
	_ios_restore_request_in_flight = false
	_ios_restore_saw_owned_product = false
	if timed_out_operation == OPERATION_PURCHASE:
		_finish_purchase(false, _support_message("purchase_timeout"))
	elif timed_out_operation == OPERATION_RESTORE:
		_finish_restore(false, _support_message("restore_timeout"))
	else:
		is_busy = false
		_active_operation = OPERATION_NONE
		_active_operation_revision = -1
		_reset_operation_watchdog()
		set_process(_ios_in_app_store != null)
		state_changed.emit()


func _reset_operation_watchdog() -> void:
	_active_operation_elapsed = 0.0
	_resume_recovery_pending = false
	_resume_recovery_elapsed = 0.0


func _resolve_timed_out_operation(operation: String) -> bool:
	if not bool(_retry_blocked_operations.get(operation, false)):
		return false
	_retry_blocked_operations[operation] = false
	return true


func _has_purchase_backend() -> bool:
	return _has_native_bridge() or _has_ios_in_app_store()


func _has_native_bridge() -> bool:
	_detect_native_bridge()
	return _native_bridge != null


func _has_ios_in_app_store() -> bool:
	if _has_native_bridge():
		return false
	_detect_ios_in_app_store()
	return _ios_in_app_store != null


func _call_ios_in_app_store(method_name: String, args: Array) -> bool:
	if not _has_ios_in_app_store() or not _ios_in_app_store.has_method(method_name):
		return false
	var accepted: Variant = _ios_in_app_store.callv(method_name, args)
	return accepted is int and int(accepted) == OK


func set_ios_in_app_store_for_test(store: Object) -> bool:
	if not OS.is_debug_build():
		return false
	_native_bridge = null
	_ios_in_app_store = null
	return _configure_ios_in_app_store(store, false)


func _call_native_bridge(method_name: String, args: Array) -> void:
	_detect_native_bridge()
	var bridge: Object = _native_bridge
	if bridge != null and bridge.has_method(method_name):
		var accepted: Variant = bridge.callv(method_name, args)
		if not (accepted is bool) or bool(accepted):
			return
		_handle_native_call_failure(method_name)
		return
	_handle_native_call_failure(method_name)


func _handle_native_call_failure(method_name: String) -> void:
	if method_name == "purchase_support":
		_finish_purchase(false, _support_message("purchase_init_failed"))
	elif method_name == "restore_support":
		_finish_restore(false, _support_message("restore_init_failed"))
	elif method_name == "query_product_info":
		product_info_loading = false
		product_info_loaded = true
		product_available = false
		formatted_price = ""
		product_info_message = "purchase_init_failed"
		state_changed.emit()
	elif method_name == "refresh_entitlements":
		_entitlement_refresh_in_flight = false
		state_changed.emit()
		_flush_pending_entitlement_refresh()
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
		"product_refresh_required":
			return _support_message("purchase_price_updated")
		"product_not_found", "product_offer_unavailable":
			return _support_message("purchase_unavailable")
	if message.begins_with("product_unfetched_"):
		return _support_message("purchase_unavailable")
	if message.begins_with("billing_"):
		return _support_message("purchase_failed")
	return _support_message("purchase_failed")


func _native_restore_message(query_succeeded: bool, message: String, owns_product: bool) -> String:
	if query_succeeded and owns_product:
		return _support_message("restore_success")
	if query_succeeded and message == "not_owned":
		return _support_message("restore_none")
	if query_succeeded and message == "restore_completed":
		return _support_message("restore_success")
	if not query_succeeded:
		return _support_message("restore_init_failed")
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


func _detect_ios_in_app_store() -> void:
	if _native_bridge != null or _ios_in_app_store != null:
		return
	if not Engine.has_singleton(IOS_IN_APP_STORE_SINGLETON):
		return
	var store: Object = Engine.get_singleton(IOS_IN_APP_STORE_SINGLETON)
	if _configure_ios_in_app_store(store, true):
		print("[SupportPurchase] iOS InAppStore detected")


func _configure_ios_in_app_store(store: Object, report_error: bool) -> bool:
	if store == null:
		return false
	var required_methods: Array[String] = [
		"request_product_info",
		"purchase",
		"restore_purchases",
		"set_auto_finish_transaction",
		"get_pending_event_count",
		"pop_pending_event",
	]
	for method_name in required_methods:
		if not store.has_method(method_name):
			if report_error:
				push_error("[SupportPurchase] InAppStore is missing method: %s" % method_name)
			return false
	_ios_in_app_store = store
	_ios_in_app_store.call("set_auto_finish_transaction", true)
	set_process(true)
	return true


func _connect_native_bridge_signals() -> void:
	if _native_bridge == null:
		return
	if _native_bridge.has_signal("purchase_finished") and not _native_bridge.purchase_finished.is_connected(_on_native_purchase_finished):
		_native_bridge.purchase_finished.connect(_on_native_purchase_finished)
	if _native_bridge.has_signal("restore_finished") and not _native_bridge.restore_finished.is_connected(_on_native_restore_finished):
		_native_bridge.restore_finished.connect(_on_native_restore_finished)
	if _native_bridge.has_signal("entitlement_check_finished") and not _native_bridge.entitlement_check_finished.is_connected(_on_native_entitlement_check_finished):
		_native_bridge.entitlement_check_finished.connect(_on_native_entitlement_check_finished)
	if _native_bridge.has_signal("product_info_finished") and not _native_bridge.product_info_finished.is_connected(_on_native_product_info_finished):
		_native_bridge.product_info_finished.connect(_on_native_product_info_finished)


func _on_native_purchase_finished(success: bool, message: String, owns_product: bool) -> void:
	complete_native_purchase(success, message, owns_product)


func _on_native_restore_finished(query_succeeded: bool, message: String, owns_product: bool) -> void:
	complete_native_restore(query_succeeded, message, owns_product)


func _on_native_entitlement_check_finished(query_succeeded: bool, owns_product: bool, message: String) -> void:
	complete_native_entitlement_check(query_succeeded, owns_product, message)


func _on_native_product_info_finished(
	query_succeeded: bool,
	product_id: String,
	available: bool,
	price: String,
	message: String
) -> void:
	complete_native_product_info(query_succeeded, product_id, available, price, message)

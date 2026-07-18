package com.nb0129.machiate

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class LongtianhongStoreKit(godot: Godot) : GodotPlugin(godot), PurchasesUpdatedListener {
	companion object {
		private val TAG = LongtianhongStoreKit::class.java.simpleName
		private const val PRODUCT_TYPE = BillingClient.ProductType.INAPP
		private const val SUPPORT_PRODUCT_ID = "support_pack"
		private const val SUPPORT_PURCHASE_OPTION_ID = "standard"
		private const val MAX_ACKNOWLEDGE_ATTEMPTS = 3
		private const val ACKNOWLEDGE_RETRY_DELAY_MS = 2_000L

		private val PURCHASE_FINISHED = SignalInfo(
			"purchase_finished",
			Boolean::class.javaObjectType,
			String::class.java,
			Boolean::class.javaObjectType
		)
		private val RESTORE_FINISHED = SignalInfo(
			"restore_finished",
			Boolean::class.javaObjectType,
			String::class.java,
			Boolean::class.javaObjectType
		)
		private val ENTITLEMENT_CHECK_FINISHED = SignalInfo(
			"entitlement_check_finished",
			Boolean::class.javaObjectType,
			Boolean::class.javaObjectType,
			String::class.java
		)
		private val PRODUCT_INFO_FINISHED = SignalInfo(
			"product_info_finished",
			Boolean::class.javaObjectType,
			String::class.java,
			Boolean::class.javaObjectType,
			String::class.java,
			String::class.java
		)
		private val SIGNALS = setOf(
			PURCHASE_FINISHED,
			RESTORE_FINISHED,
			ENTITLEMENT_CHECK_FINISHED,
			PRODUCT_INFO_FINISHED
		)
	}

	private data class SelectedOffer(
		val productDetails: ProductDetails,
		val offerDetails: ProductDetails.OneTimePurchaseOfferDetails,
		val offerToken: String
	)

	private data class PendingBillingAction(
		val label: String,
		val onError: (String) -> Unit,
		val onReady: (BillingClient, Activity) -> Unit
	)

	private val mainHandler = Handler(Looper.getMainLooper())
	private val pendingBillingActions = mutableListOf<PendingBillingAction>()
	private val acknowledgingPurchaseTokens = mutableSetOf<String>()
	private var billingClient: BillingClient? = null
	private var billingConnectionInProgress = false
	private var pendingPurchaseProductId: String? = null
	private var displayedOfferProductId: String? = null
	private var displayedOfferFormattedPrice: String? = null

	override fun getPluginName() = "LongtianhongStoreKit"

	override fun getPluginSignals() = SIGNALS

	override fun onMainCreate(activity: Activity?): View? {
		if (activity != null) {
			ensureBillingClient()
		}
		return null
	}

	override fun onMainDestroy() {
		mainHandler.removeCallbacksAndMessages(null)
		pendingBillingActions.clear()
		acknowledgingPurchaseTokens.clear()
		billingClient?.endConnection()
		billingClient = null
		billingConnectionInProgress = false
		pendingPurchaseProductId = null
		clearDisplayedOffer()
		super.onMainDestroy()
	}

	@UsedByGodot
	fun query_product_info(productId: String): Boolean {
		runOnHostThread {
			if (!isSupportedProduct(productId)) {
				clearDisplayedOffer()
				emitProductInfoFinished(false, productId, false, "", "product_invalid")
				return@runOnHostThread
			}
			withReadyBillingClient("query_product_info", onError = {
				clearDisplayedOffer()
				emitProductInfoFinished(false, productId, false, "", it)
			}) { client, _ ->
				querySelectedOffer(client, productId) { result, selectedOffer, message ->
					if (!isOk(result)) {
						clearDisplayedOffer()
						emitProductInfoFinished(false, productId, false, "", errorCode(result))
						return@querySelectedOffer
					}
					if (selectedOffer == null) {
						clearDisplayedOffer()
						emitProductInfoFinished(true, productId, false, "", message)
						return@querySelectedOffer
					}
					rememberDisplayedOffer(productId, selectedOffer.offerDetails.formattedPrice)
					emitProductInfoFinished(
						true,
						productId,
						true,
						selectedOffer.offerDetails.formattedPrice,
						"product_available"
					)
				}
			}
		}
		return true
	}

	@UsedByGodot
	fun purchase_support(productId: String): Boolean {
		runOnHostThread {
			if (!isSupportedProduct(productId)) {
				emitPurchaseFinished(false, "product_invalid", false)
				return@runOnHostThread
			}
			withReadyBillingClient("purchase_support", onError = {
				emitPurchaseFinished(false, it, false)
			}) { client, currentActivity ->
				querySelectedOffer(client, productId) { result, selectedOffer, message ->
					if (!isOk(result)) {
						emitPurchaseFinished(false, errorCode(result), false)
						return@querySelectedOffer
					}
					if (selectedOffer == null) {
						clearDisplayedOffer()
						emitProductInfoFinished(true, productId, false, "", message)
						emitPurchaseFinished(false, message, false)
						return@querySelectedOffer
					}
					val freshPrice = selectedOffer.offerDetails.formattedPrice
					val priceMatchesDisplay = isDisplayedOfferPriceCurrent(productId, freshPrice)
					rememberDisplayedOffer(productId, freshPrice)
					if (!priceMatchesDisplay) {
						emitProductInfoFinished(
							true,
							productId,
							true,
							freshPrice,
							"product_available"
						)
						emitPurchaseFinished(false, "product_refresh_required", false)
						return@querySelectedOffer
					}
					launchPurchaseFlow(client, currentActivity, productId, selectedOffer)
				}
			}
		}
		return true
	}

	private fun clearDisplayedOffer() {
		displayedOfferProductId = null
		displayedOfferFormattedPrice = null
	}

	private fun rememberDisplayedOffer(productId: String, formattedPrice: String) {
		displayedOfferProductId = productId
		displayedOfferFormattedPrice = formattedPrice
	}

	private fun isDisplayedOfferPriceCurrent(productId: String, formattedPrice: String): Boolean {
		return displayedOfferProductId == productId && displayedOfferFormattedPrice == formattedPrice
	}

	@UsedByGodot
	fun restore_support(productId: String): Boolean {
		runOnHostThread {
			if (!isSupportedProduct(productId)) {
				emitRestoreFinished(false, "product_invalid", false)
				return@runOnHostThread
			}
			withReadyBillingClient("restore_support", onError = {
				emitRestoreFinished(false, it, false)
			}) { client, _ ->
				queryOwnedPurchases(client, productId) { result, ownsProduct ->
					if (!isOk(result)) {
						emitRestoreFinished(false, errorCode(result), false)
						return@queryOwnedPurchases
					}
					emitRestoreFinished(
						true,
						if (ownsProduct) "restore_completed" else "not_owned",
						ownsProduct
					)
				}
			}
		}
		return true
	}

	@UsedByGodot
	fun refresh_entitlements(productId: String): Boolean {
		runOnHostThread {
			if (!isSupportedProduct(productId)) {
				emitEntitlementCheckFinished(false, false, "product_invalid")
				return@runOnHostThread
			}
			withReadyBillingClient("refresh_entitlements", onError = {
				Log.w(TAG, "refresh_entitlements failed: $it")
				emitEntitlementCheckFinished(false, false, it)
			}) { client, _ ->
				queryOwnedPurchases(client, productId) { result, ownsProduct ->
					if (!isOk(result)) {
						val message = errorCode(result)
						Log.w(TAG, "refresh_entitlements failed: $message")
						emitEntitlementCheckFinished(false, false, message)
						return@queryOwnedPurchases
					}
					emitEntitlementCheckFinished(
						true,
						ownsProduct,
						if (ownsProduct) "owned" else "not_owned"
					)
				}
			}
		}
		return true
	}

	override fun onPurchasesUpdated(billingResult: BillingResult, purchases: MutableList<Purchase>?) {
		val pendingProductId = pendingPurchaseProductId
		if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
			pendingPurchaseProductId = null
			if (pendingProductId != null) {
				emitPurchaseFinished(false, "purchase_canceled", false)
			}
			return
		}
		if (!isOk(billingResult)) {
			pendingPurchaseProductId = null
			if (pendingProductId != null) {
				if (billingResult.responseCode == BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED) {
					withReadyBillingClient("purchase_already_owned", onError = {
						emitPurchaseFinished(false, it, false)
					}) { client, _ ->
						reconcileAlreadyOwnedPurchase(client, pendingProductId)
					}
				} else {
					emitPurchaseFinished(false, errorCode(billingResult), false)
				}
			} else {
				Log.w(TAG, "Unsolicited purchase update failed: ${errorCode(billingResult)}")
			}
			return
		}

		val expectedProductId = pendingProductId ?: SUPPORT_PRODUCT_ID
		val matchingPurchase = purchases
			.orEmpty()
			.firstOrNull { purchase -> purchase.products.contains(expectedProductId) }
		if (matchingPurchase == null) {
			pendingPurchaseProductId = null
			if (pendingProductId != null) {
				emitPurchaseFinished(false, "purchase_missing", false)
			}
			return
		}
		handlePurchase(matchingPurchase, expectedProductId, true)
	}

	private fun ensureBillingClient(): BillingClient {
		val existing = billingClient
		if (existing != null) {
			return existing
		}
		val context = activity?.applicationContext
			?: throw IllegalStateException("Activity is unavailable")
		val client = BillingClient.newBuilder(context)
			.setListener(this)
			.enablePendingPurchases(
				PendingPurchasesParams.newBuilder()
					.enableOneTimeProducts()
					.build()
			)
			.enableAutoServiceReconnection()
			.build()
		billingClient = client
		return client
	}

	private fun withReadyBillingClient(
		label: String,
		onError: (String) -> Unit,
		onReady: (BillingClient, Activity) -> Unit
	) {
		val currentActivity = activity
		if (currentActivity == null) {
			onError("activity_unavailable")
			return
		}
		val client = try {
			ensureBillingClient()
		} catch (error: IllegalStateException) {
			Log.w(TAG, "$label failed: ${error.message}")
			onError("activity_unavailable")
			return
		}
		if (client.isReady) {
			onReady(client, currentActivity)
			return
		}

		pendingBillingActions.add(PendingBillingAction(label, onError, onReady))
		if (billingConnectionInProgress) {
			return
		}
		billingConnectionInProgress = true
		try {
			client.startConnection(object : BillingClientStateListener {
				override fun onBillingSetupFinished(billingResult: BillingResult) {
					billingConnectionInProgress = false
					if (isOk(billingResult)) {
						drainPendingBillingActions(client, null)
					} else {
						val message = errorCode(billingResult)
						Log.w(TAG, "Billing setup failed: $message")
						drainPendingBillingActions(client, message)
					}
				}

				override fun onBillingServiceDisconnected() {
					Log.w(TAG, "Billing service disconnected")
					if (billingConnectionInProgress) {
						billingConnectionInProgress = false
						drainPendingBillingActions(client, "billing_service_disconnected")
					}
				}
			})
		} catch (error: RuntimeException) {
			billingConnectionInProgress = false
			Log.w(TAG, "Billing connection failed", error)
			drainPendingBillingActions(client, "billing_connection_failed")
		}
	}

	private fun drainPendingBillingActions(client: BillingClient, errorMessage: String?) {
		val actions = pendingBillingActions.toList()
		pendingBillingActions.clear()
		if (errorMessage != null) {
			actions.forEach { action ->
				Log.w(TAG, "${action.label} failed: $errorMessage")
				action.onError(errorMessage)
			}
			return
		}
		val currentActivity = activity
		if (currentActivity == null) {
			actions.forEach { it.onError("activity_unavailable") }
			return
		}
		actions.forEach { it.onReady(client, currentActivity) }
	}

	private fun querySelectedOffer(
		client: BillingClient,
		productId: String,
		callback: (BillingResult, SelectedOffer?, String) -> Unit
	) {
		val product = QueryProductDetailsParams.Product.newBuilder()
			.setProductId(productId)
			.setProductType(PRODUCT_TYPE)
			.build()
		val params = QueryProductDetailsParams.newBuilder()
			.setProductList(listOf(product))
			.build()
		client.queryProductDetailsAsync(params) { billingResult, productDetailsResult ->
			if (!isOk(billingResult)) {
				callback(billingResult, null, errorCode(billingResult))
				return@queryProductDetailsAsync
			}
			val productDetails = productDetailsResult.productDetailsList.firstOrNull {
				it.productId == productId && it.productType == PRODUCT_TYPE
			}
			if (productDetails == null) {
				val unfetchedProduct = productDetailsResult.unfetchedProductList.firstOrNull {
					it.productId == productId && it.productType == PRODUCT_TYPE
				}
				val message = if (unfetchedProduct == null) {
					"product_not_found"
				} else {
					"product_unfetched_${unfetchedProduct.statusCode}"
				}
				callback(billingResult, null, message)
				return@queryProductDetailsAsync
			}
			val selectedOffer = selectOffer(productDetails)
			callback(
				billingResult,
				selectedOffer,
				if (selectedOffer == null) "product_offer_unavailable" else "product_available"
			)
		}
	}

	private fun selectOffer(productDetails: ProductDetails): SelectedOffer? {
		val eligibleOffers = productDetails.oneTimePurchaseOfferDetailsList.orEmpty()
		val configuredOffer = eligibleOffers.firstOrNull { offer ->
			offer.purchaseOptionId == SUPPORT_PURCHASE_OPTION_ID &&
				offer.offerId.isNullOrEmpty() &&
				offer.rentalDetails == null
		}
		val backwardCompatibleOffer = if (eligibleOffers.isEmpty()) {
			productDetails.oneTimePurchaseOfferDetails?.takeIf { it.rentalDetails == null }
		} else {
			null
		}
		val offer = configuredOffer ?: backwardCompatibleOffer ?: return null
		val offerToken = offer.offerToken
		if (offerToken.isNullOrBlank()) {
			return null
		}
		return SelectedOffer(productDetails, offer, offerToken)
	}

	private fun launchPurchaseFlow(
		client: BillingClient,
		currentActivity: Activity,
		productId: String,
		selectedOffer: SelectedOffer
	) {
		if (selectedOffer.productDetails.productId != productId) {
			emitPurchaseFinished(false, "product_mismatch", false)
			return
		}
		pendingPurchaseProductId = productId
		val productDetailsParams = BillingFlowParams.ProductDetailsParams.newBuilder()
			.setProductDetails(selectedOffer.productDetails)
			.setOfferToken(selectedOffer.offerToken)
			.build()
		val params = BillingFlowParams.newBuilder()
			.setProductDetailsParamsList(listOf(productDetailsParams))
			.build()
		val launchResult = client.launchBillingFlow(currentActivity, params)
		if (!isOk(launchResult)) {
			pendingPurchaseProductId = null
			if (launchResult.responseCode == BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED) {
				reconcileAlreadyOwnedPurchase(client, productId)
			} else {
				emitPurchaseFinished(false, errorCode(launchResult), false)
			}
		}
	}

	private fun reconcileAlreadyOwnedPurchase(client: BillingClient, productId: String) {
		queryOwnedPurchases(client, productId) { result, ownsProduct ->
			if (!isOk(result)) {
				emitPurchaseFinished(false, errorCode(result), false)
				return@queryOwnedPurchases
			}
			emitPurchaseFinished(
				ownsProduct,
				if (ownsProduct) "purchase_completed" else "purchase_missing",
				ownsProduct
			)
		}
	}

	private fun queryOwnedPurchases(
		client: BillingClient,
		productId: String,
		callback: (BillingResult, Boolean) -> Unit
	) {
		val params = QueryPurchasesParams.newBuilder()
			.setProductType(PRODUCT_TYPE)
			.build()
		client.queryPurchasesAsync(params) { billingResult, purchases ->
			if (!isOk(billingResult)) {
				callback(billingResult, false)
				return@queryPurchasesAsync
			}
			val matchingPurchases = purchases.filter { it.products.contains(productId) }
			matchingPurchases
				.filter { it.purchaseState == Purchase.PurchaseState.PURCHASED }
				.forEach { handlePurchase(it, productId, false) }
			val ownsProduct = matchingPurchases.any {
				it.purchaseState == Purchase.PurchaseState.PURCHASED
			}
			callback(billingResult, ownsProduct)
		}
	}

	private fun handlePurchase(purchase: Purchase, productId: String, fromPurchaseFlow: Boolean) {
		if (!purchase.products.contains(productId) || productId != SUPPORT_PRODUCT_ID) {
			if (fromPurchaseFlow) {
				pendingPurchaseProductId = null
				emitPurchaseFinished(false, "product_mismatch", false)
			}
			return
		}
		if (purchase.purchaseState != Purchase.PurchaseState.PURCHASED) {
			if (fromPurchaseFlow) {
				pendingPurchaseProductId = null
				val message = if (purchase.purchaseState == Purchase.PurchaseState.PENDING) {
					"purchase_pending"
				} else {
					"purchase_missing"
				}
				emitPurchaseFinished(false, message, false)
			}
			return
		}

		if (fromPurchaseFlow) {
			pendingPurchaseProductId = null
			emitPurchaseFinished(true, "purchase_completed", true)
		}
		if (!purchase.isAcknowledged) {
			acknowledgePurchase(purchase, productId)
		}
	}

	private fun acknowledgePurchase(purchase: Purchase, productId: String) {
		val purchaseToken = purchase.purchaseToken
		if (!acknowledgingPurchaseTokens.add(purchaseToken)) {
			return
		}
		acknowledgePurchaseAttempt(purchaseToken, productId, 0)
	}

	private fun acknowledgePurchaseAttempt(
		purchaseToken: String,
		productId: String,
		attempt: Int,
		itemNotOwnedRefreshAttempted: Boolean = false
	) {
		withReadyBillingClient("acknowledge_purchase", onError = { message ->
			scheduleAcknowledgeRetry(
				purchaseToken,
				productId,
				attempt,
				message,
				itemNotOwnedRefreshAttempted
			)
		}) { client, _ ->
			val params = AcknowledgePurchaseParams.newBuilder()
				.setPurchaseToken(purchaseToken)
				.build()
			client.acknowledgePurchase(params) { result ->
				if (isOk(result)) {
					acknowledgingPurchaseTokens.remove(purchaseToken)
				} else {
					val message = errorCode(result)
					if (
						result.responseCode == BillingClient.BillingResponseCode.ITEM_NOT_OWNED &&
						!itemNotOwnedRefreshAttempted
					) {
						refreshPurchaseCacheBeforeAcknowledgeRetry(
							client,
							purchaseToken,
							productId,
							attempt
						)
					} else if (isRetryableAcknowledgeError(result)) {
						scheduleAcknowledgeRetry(
							purchaseToken,
							productId,
							attempt,
							message,
							itemNotOwnedRefreshAttempted
						)
					} else {
						acknowledgingPurchaseTokens.remove(purchaseToken)
						Log.w(TAG, "acknowledgePurchase failed for $productId: $message")
					}
				}
			}
		}
	}

	private fun refreshPurchaseCacheBeforeAcknowledgeRetry(
		client: BillingClient,
		purchaseToken: String,
		productId: String,
		attempt: Int
	) {
		val params = QueryPurchasesParams.newBuilder()
			.setProductType(PRODUCT_TYPE)
			.build()
		client.queryPurchasesAsync(params) { result, purchases ->
			if (!isOk(result)) {
				scheduleAcknowledgeRetry(
					purchaseToken,
					productId,
					attempt,
					errorCode(result),
					false
				)
				return@queryPurchasesAsync
			}
			val refreshedPurchase = purchases.firstOrNull { purchase ->
				purchase.purchaseToken == purchaseToken &&
					purchase.products.contains(productId) &&
					purchase.purchaseState == Purchase.PurchaseState.PURCHASED
			}
			if (refreshedPurchase == null) {
				acknowledgingPurchaseTokens.remove(purchaseToken)
				Log.w(TAG, "Purchase disappeared while refreshing acknowledge state for $productId")
				return@queryPurchasesAsync
			}
			if (refreshedPurchase.isAcknowledged) {
				acknowledgingPurchaseTokens.remove(purchaseToken)
				return@queryPurchasesAsync
			}
			acknowledgePurchaseAttempt(purchaseToken, productId, attempt, true)
		}
	}

	private fun scheduleAcknowledgeRetry(
		purchaseToken: String,
		productId: String,
		attempt: Int,
		message: String,
		itemNotOwnedRefreshAttempted: Boolean
	) {
		val nextAttempt = attempt + 1
		if (nextAttempt >= MAX_ACKNOWLEDGE_ATTEMPTS) {
			acknowledgingPurchaseTokens.remove(purchaseToken)
			Log.w(TAG, "acknowledgePurchase exhausted retries for $productId: $message")
			return
		}
		val delayMillis = ACKNOWLEDGE_RETRY_DELAY_MS * (1L shl attempt)
		Log.w(TAG, "acknowledgePurchase retry $nextAttempt for $productId after $delayMillis ms: $message")
		mainHandler.postDelayed(
			{
				acknowledgePurchaseAttempt(
					purchaseToken,
					productId,
					nextAttempt,
					itemNotOwnedRefreshAttempted
				)
			},
			delayMillis
		)
	}

	private fun isRetryableAcknowledgeError(result: BillingResult): Boolean {
		return when (result.responseCode) {
			BillingClient.BillingResponseCode.NETWORK_ERROR,
			BillingClient.BillingResponseCode.SERVICE_DISCONNECTED,
			BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE,
			BillingClient.BillingResponseCode.ERROR -> true
			else -> false
		}
	}

	private fun isSupportedProduct(productId: String): Boolean {
		return productId == SUPPORT_PRODUCT_ID
	}

	private fun emitPurchaseFinished(success: Boolean, message: String, ownsProduct: Boolean) {
		emitSignal(PURCHASE_FINISHED.name, success, message, ownsProduct)
	}

	private fun emitRestoreFinished(querySucceeded: Boolean, message: String, ownsProduct: Boolean) {
		emitSignal(RESTORE_FINISHED.name, querySucceeded, message, ownsProduct)
	}

	private fun emitEntitlementCheckFinished(
		querySucceeded: Boolean,
		ownsProduct: Boolean,
		message: String
	) {
		emitSignal(ENTITLEMENT_CHECK_FINISHED.name, querySucceeded, ownsProduct, message)
	}

	private fun emitProductInfoFinished(
		querySucceeded: Boolean,
		productId: String,
		available: Boolean,
		formattedPrice: String,
		message: String
	) {
		emitSignal(
			PRODUCT_INFO_FINISHED.name,
			querySucceeded,
			productId,
			available,
			formattedPrice,
			message
		)
	}

	private fun isOk(result: BillingResult): Boolean {
		return result.responseCode == BillingClient.BillingResponseCode.OK
	}

	private fun errorCode(result: BillingResult): String {
		val message = result.debugMessage
		val code = "billing_${result.responseCode}"
		return if (message.isBlank()) code else "$code:$message"
	}
}

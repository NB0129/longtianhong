package com.nb0129.machiate

import android.app.Activity
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
			Boolean::class.javaObjectType
		)
		private val SIGNALS = setOf(PURCHASE_FINISHED, RESTORE_FINISHED, ENTITLEMENT_CHECK_FINISHED)
	}

	private var billingClient: BillingClient? = null
	private var pendingPurchaseProductId: String? = null
	private var cachedProductDetails: ProductDetails? = null

	override fun getPluginName() = "LongtianhongStoreKit"

	override fun getPluginSignals() = SIGNALS

	override fun onMainCreate(activity: Activity?): View? {
		if (activity != null) {
			ensureBillingClient()
		}
		return null
	}

	@UsedByGodot
	fun purchase_support(productId: String): Boolean {
		runOnHostThread {
			withReadyBillingClient("purchase_support", onError = {
				emitPurchaseFinished(false, it, false)
			}) { client, currentActivity ->
				queryProductDetails(client, productId) { result, productDetails ->
					if (!isOk(result) || productDetails == null) {
						emitPurchaseFinished(false, errorCode(result), false)
						return@queryProductDetails
					}
					cachedProductDetails = productDetails
					pendingPurchaseProductId = productId
					val productDetailsParams = BillingFlowParams.ProductDetailsParams.newBuilder()
						.setProductDetails(productDetails)
						.build()
					val params = BillingFlowParams.newBuilder()
						.setProductDetailsParamsList(listOf(productDetailsParams))
						.build()
					val launchResult = client.launchBillingFlow(currentActivity, params)
					if (!isOk(launchResult)) {
						pendingPurchaseProductId = null
						emitPurchaseFinished(false, errorCode(launchResult), false)
					}
				}
			}
		}
		return true
	}

	@UsedByGodot
	fun restore_support(productId: String): Boolean {
		runOnHostThread {
			withReadyBillingClient("restore_support", onError = {
				emitRestoreFinished(false, it, false)
			}) { client, _ ->
				queryOwnedPurchases(client, productId) { result, ownsProduct ->
					if (!isOk(result)) {
						emitRestoreFinished(false, errorCode(result), ownsProduct)
						return@queryOwnedPurchases
					}
					emitRestoreFinished(ownsProduct, if (ownsProduct) "restore_completed" else "not_owned", ownsProduct)
				}
			}
		}
		return true
	}

	@UsedByGodot
	fun refresh_entitlements(productId: String): Boolean {
		runOnHostThread {
			withReadyBillingClient("refresh_entitlements", onError = {
				Log.w(TAG, "refresh_entitlements failed: $it")
				emitEntitlementCheckFinished(false)
			}) { client, _ ->
				queryOwnedPurchases(client, productId) { result, ownsProduct ->
					if (!isOk(result)) {
						Log.w(TAG, "refresh_entitlements failed: ${errorCode(result)}")
					}
					emitEntitlementCheckFinished(isOk(result) && ownsProduct)
				}
			}
		}
		return true
	}

	override fun onPurchasesUpdated(billingResult: BillingResult, purchases: MutableList<Purchase>?) {
		val productId = pendingPurchaseProductId
		if (billingResult.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
			pendingPurchaseProductId = null
			emitPurchaseFinished(false, "purchase_canceled", false)
			return
		}
		if (!isOk(billingResult)) {
			pendingPurchaseProductId = null
			emitPurchaseFinished(false, errorCode(billingResult), false)
			return
		}
		val matchingPurchase = purchases
			.orEmpty()
			.firstOrNull { purchase ->
				productId == null || purchase.products.contains(productId)
			}
		if (matchingPurchase == null) {
			pendingPurchaseProductId = null
			emitPurchaseFinished(false, "purchase_missing", false)
			return
		}
		handlePurchase(matchingPurchase, productId ?: matchingPurchase.products.firstOrNull().orEmpty(), true)
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
		val client = ensureBillingClient()
		if (client.isReady) {
			onReady(client, currentActivity)
			return
		}
		client.startConnection(object : BillingClientStateListener {
			override fun onBillingSetupFinished(billingResult: BillingResult) {
				if (isOk(billingResult)) {
					onReady(client, currentActivity)
				} else {
					Log.w(TAG, "$label setup failed: ${errorCode(billingResult)}")
					onError(errorCode(billingResult))
				}
			}

			override fun onBillingServiceDisconnected() {
				Log.w(TAG, "$label billing service disconnected")
			}
		})
	}

	private fun queryProductDetails(
		client: BillingClient,
		productId: String,
		callback: (BillingResult, ProductDetails?) -> Unit
	) {
		val product = QueryProductDetailsParams.Product.newBuilder()
			.setProductId(productId)
			.setProductType(PRODUCT_TYPE)
			.build()
		val params = QueryProductDetailsParams.newBuilder()
			.setProductList(listOf(product))
			.build()
		client.queryProductDetailsAsync(params) { billingResult, productDetailsResult ->
			callback(billingResult, productDetailsResult.productDetailsList.firstOrNull())
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
			val matchingPurchases = purchases.filter { it.products.contains(productId) }
			matchingPurchases.forEach { handlePurchase(it, productId, false) }
			val ownsProduct = matchingPurchases.any {
				it.purchaseState == Purchase.PurchaseState.PURCHASED
			}
			callback(billingResult, ownsProduct)
		}
	}

	private fun handlePurchase(purchase: Purchase, productId: String, fromPurchaseFlow: Boolean) {
		if (purchase.purchaseState != Purchase.PurchaseState.PURCHASED) {
			if (fromPurchaseFlow) {
				pendingPurchaseProductId = null
				emitPurchaseFinished(false, "purchase_pending", false)
			}
			return
		}
		if (purchase.isAcknowledged) {
			if (fromPurchaseFlow) {
				pendingPurchaseProductId = null
				emitPurchaseFinished(true, "purchase_completed", true)
			}
			return
		}
		val params = AcknowledgePurchaseParams.newBuilder()
			.setPurchaseToken(purchase.purchaseToken)
			.build()
		billingClient?.acknowledgePurchase(params) { result ->
			val success = isOk(result)
			if (!success) {
				Log.w(TAG, "acknowledgePurchase failed for $productId: ${errorCode(result)}")
			}
			if (fromPurchaseFlow) {
				pendingPurchaseProductId = null
				emitPurchaseFinished(success, if (success) "purchase_completed" else errorCode(result), success)
			}
		}
	}

	private fun emitPurchaseFinished(success: Boolean, message: String, ownsProduct: Boolean) {
		emitSignal(PURCHASE_FINISHED.name, success, message, ownsProduct)
	}

	private fun emitRestoreFinished(success: Boolean, message: String, ownsProduct: Boolean) {
		emitSignal(RESTORE_FINISHED.name, success, message, ownsProduct)
	}

	private fun emitEntitlementCheckFinished(ownsProduct: Boolean) {
		emitSignal(ENTITLEMENT_CHECK_FINISHED.name, ownsProduct)
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

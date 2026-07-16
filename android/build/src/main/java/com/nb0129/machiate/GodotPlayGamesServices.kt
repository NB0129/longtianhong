package com.nb0129.machiate

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.View
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.PlayGamesSdk
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class GodotPlayGamesServices(godot: Godot) : GodotPlugin(godot) {
	companion object {
		private val TAG = GodotPlayGamesServices::class.java.simpleName
		private const val REQUEST_LEADERBOARD_UI = 9004

		private val LOGIN_STATE_CHANGED = SignalInfo("login_state_changed", Boolean::class.javaObjectType)
		private val SCORE_SUBMIT_FINISHED = SignalInfo(
			"score_submit_finished",
			String::class.java,
			Int::class.javaObjectType,
			Boolean::class.javaObjectType,
			String::class.java
		)
		private val LEADERBOARD_SHOW_FINISHED = SignalInfo(
			"leaderboard_show_finished",
			String::class.java,
			Boolean::class.javaObjectType,
			String::class.java
		)
		private val SIGNALS = setOf(
			LOGIN_STATE_CHANGED,
			SCORE_SUBMIT_FINISHED,
			LEADERBOARD_SHOW_FINISHED
		)
	}

	private var initialized = false
	private var loggedIn = false

	override fun getPluginName() = "GodotPlayGamesServices"

	override fun getPluginSignals() = SIGNALS

	override fun onMainCreate(activity: Activity?): View? {
		initializeSdk()
		return null
	}

	@UsedByGodot
	fun is_logged_in(): Boolean {
		return loggedIn
	}

	@UsedByGodot
	fun isLoggedIn(): Boolean {
		return is_logged_in()
	}

	@UsedByGodot
	fun login(): Boolean {
		initializeSdk()
		runOnHostThread {
			val currentActivity = activity
			if (currentActivity == null) {
				updateLoginState(false)
				return@runOnHostThread
			}
			PlayGames.getGamesSignInClient(currentActivity)
				.isAuthenticated
				.addOnCompleteListener { authTask ->
					val alreadyAuthenticated = authTask.isSuccessful && authTask.result.isAuthenticated
					if (alreadyAuthenticated) {
						updateLoginState(true)
						return@addOnCompleteListener
					}
					PlayGames.getGamesSignInClient(currentActivity)
						.signIn()
						.addOnCompleteListener { signInTask ->
							val success = signInTask.isSuccessful && signInTask.result.isAuthenticated
							logTaskFailure("signIn", signInTask.exception)
							updateLoginState(success)
						}
				}
		}
		return true
	}

	@UsedByGodot
	fun signIn(): Boolean {
		return login()
	}

	@UsedByGodot
	fun authenticate(): Boolean {
		return login()
	}

	@UsedByGodot
	fun submitScore(leaderboardId: String, score: Int): Boolean {
		initializeSdk()
		if (leaderboardId.isBlank()) {
			emitScoreSubmitFinished(leaderboardId, score, false, "leaderboard_id_empty")
			return false
		}
		runOnHostThread {
			val currentActivity = activity
			if (currentActivity == null) {
				emitScoreSubmitFinished(leaderboardId, score, false, "activity_unavailable")
				return@runOnHostThread
			}
			PlayGames.getGamesSignInClient(currentActivity)
				.isAuthenticated
				.addOnCompleteListener { authTask ->
					val authenticated = authTask.isSuccessful && authTask.result.isAuthenticated
					updateLoginState(authenticated)
					if (authenticated) {
						submitAuthenticatedScore(currentActivity, leaderboardId, score)
						return@addOnCompleteListener
					}
					PlayGames.getGamesSignInClient(currentActivity)
						.signIn()
						.addOnCompleteListener { signInTask ->
							val signedIn = signInTask.isSuccessful && signInTask.result.isAuthenticated
							updateLoginState(signedIn)
							if (signedIn) {
								submitAuthenticatedScore(currentActivity, leaderboardId, score)
							} else {
								logTaskFailure("signIn before submitScore", signInTask.exception)
								emitScoreSubmitFinished(leaderboardId, score, false, "not_authenticated")
							}
						}
					if (!authTask.isSuccessful) {
						logTaskFailure("isAuthenticated before submitScore", authTask.exception)
					}
				}
		}
		return true
	}

	@UsedByGodot
	fun showLeaderboard(leaderboardId: String): Boolean {
		initializeSdk()
		runOnHostThread {
			val currentActivity = activity
			if (currentActivity == null) {
				emitLeaderboardShowFinished(leaderboardId, false, "activity_unavailable")
				return@runOnHostThread
			}
			withAuthenticatedGamesClient(currentActivity, "showLeaderboard", leaderboardId) {
				showAuthenticatedLeaderboard(currentActivity, leaderboardId)
			}
		}
		return true
	}

	@UsedByGodot
	fun showLeaderboards(): Boolean {
		return showLeaderboard("")
	}

	@UsedByGodot
	fun showAllLeaderboards(): Boolean {
		return showLeaderboard("")
	}

	private fun initializeSdk() {
		if (initialized) {
			return
		}
		val currentActivity = activity
		if (currentActivity == null) {
			return
		}
		PlayGamesSdk.initialize(currentActivity.applicationContext)
		initialized = true
	}

	private fun updateLoginState(value: Boolean) {
		if (loggedIn == value) {
			return
		}
		loggedIn = value
		emitSignal(LOGIN_STATE_CHANGED.name, loggedIn)
	}

	private fun submitAuthenticatedScore(currentActivity: Activity, leaderboardId: String, score: Int) {
		PlayGames.getLeaderboardsClient(currentActivity)
			.submitScoreImmediate(leaderboardId, score.toLong())
			.addOnCompleteListener { submitTask ->
				logTaskFailure("submitScore", submitTask.exception)
				emitScoreSubmitFinished(
					leaderboardId,
					score,
					submitTask.isSuccessful,
					errorCode(submitTask.exception)
				)
			}
	}

	private fun showAuthenticatedLeaderboard(currentActivity: Activity, leaderboardId: String) {
		val client = PlayGames.getLeaderboardsClient(currentActivity)
		val intentTask = if (leaderboardId.isBlank()) {
			client.allLeaderboardsIntent
		} else {
			client.getLeaderboardIntent(leaderboardId)
		}
		intentTask
			.addOnSuccessListener { intent: Intent ->
				currentActivity.startActivityForResult(intent, REQUEST_LEADERBOARD_UI)
				emitLeaderboardShowFinished(leaderboardId, true, "")
			}
			.addOnFailureListener { exception ->
				Log.w(TAG, "showLeaderboard failed: ${errorCode(exception)}", exception)
				emitLeaderboardShowFinished(leaderboardId, false, errorCode(exception))
			}
	}

	private fun withAuthenticatedGamesClient(
		currentActivity: Activity,
		label: String,
		leaderboardId: String,
		onAuthenticated: () -> Unit
	) {
		PlayGames.getGamesSignInClient(currentActivity)
			.isAuthenticated
			.addOnCompleteListener { authTask ->
				val authenticated = authTask.isSuccessful && authTask.result.isAuthenticated
				updateLoginState(authenticated)
				if (authenticated) {
					onAuthenticated()
					return@addOnCompleteListener
				}
				PlayGames.getGamesSignInClient(currentActivity)
					.signIn()
					.addOnCompleteListener { signInTask ->
						val signedIn = signInTask.isSuccessful && signInTask.result.isAuthenticated
						updateLoginState(signedIn)
						if (signedIn) {
							onAuthenticated()
						} else {
							logTaskFailure("signIn before $label", signInTask.exception)
							emitLeaderboardShowFinished(leaderboardId, false, "not_authenticated")
						}
					}
				if (!authTask.isSuccessful) {
					logTaskFailure("isAuthenticated before $label", authTask.exception)
				}
			}
	}

	private fun emitScoreSubmitFinished(leaderboardId: String, score: Int, success: Boolean, message: String) {
		emitSignal(SCORE_SUBMIT_FINISHED.name, leaderboardId, score, success, message)
	}

	private fun emitLeaderboardShowFinished(leaderboardId: String, success: Boolean, message: String) {
		emitSignal(LEADERBOARD_SHOW_FINISHED.name, leaderboardId, success, message)
	}

	private fun logTaskFailure(label: String, exception: Exception?) {
		if (exception != null) {
			Log.w(TAG, "$label failed: ${errorCode(exception)}", exception)
		}
	}

	private fun errorCode(exception: Exception?): String {
		return when (exception) {
			null -> ""
			is ApiException -> "api_${exception.statusCode}"
			else -> exception.javaClass.simpleName
		}
	}
}

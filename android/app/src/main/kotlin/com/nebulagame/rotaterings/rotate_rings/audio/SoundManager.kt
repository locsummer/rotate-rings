package com.nebulagame.rotaterings.rotate_rings.audio

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.HapticFeedbackConstants
import android.view.View

class SoundManager(private val context: Context) {
    var soundEnabled: Boolean = true
    var hapticsEnabled: Boolean = true

    private val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator

    fun playTouch(view: View? = null) {
        if (!hapticsEnabled) return
        view?.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
    }

    fun playRotateTick(view: View? = null) {
        if (!hapticsEnabled) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrator?.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK))
        } else {
            view?.performHapticFeedback(HapticFeedbackConstants.CLOCK_TICK)
        }
    }

    fun playReleasePop(view: View? = null) {
        if (!hapticsEnabled) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            vibrator?.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK))
        } else {
            view?.performHapticFeedback(HapticFeedbackConstants.CONTEXT_CLICK)
        }
    }

    fun playVictory(view: View? = null) {
        if (!hapticsEnabled) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createOneShot(120, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(120)
        }
    }
}

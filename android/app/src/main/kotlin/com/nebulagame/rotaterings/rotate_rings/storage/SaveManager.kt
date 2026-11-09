package com.nebulagame.rotaterings.rotate_rings.storage

import android.content.Context
import android.content.SharedPreferences

class SaveManager(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("rotate_rings_prefs", Context.MODE_PRIVATE)

    var currentLevel: Int
        get() = prefs.getInt("current_level", 1)
        set(value) = prefs.edit().putInt("current_level", value).apply()

    var maxUnlockedLevel: Int
        get() = prefs.getInt("max_unlocked_level", 1)
        set(value) = prefs.edit().putInt("max_unlocked_level", value).apply()

    var acorns: Int
        get() = prefs.getInt("acorns", 0)
        set(value) = prefs.edit().putInt("acorns", value).apply()

    var soundEnabled: Boolean
        get() = prefs.getBoolean("sound_enabled", true)
        set(value) = prefs.edit().putBoolean("sound_enabled", value).apply()

    var musicEnabled: Boolean
        get() = prefs.getBoolean("music_enabled", true)
        set(value) = prefs.edit().putBoolean("music_enabled", value).apply()

    var hapticsEnabled: Boolean
        get() = prefs.getBoolean("haptics_enabled", true)
        set(value) = prefs.edit().putBoolean("haptics_enabled", value).apply()

    fun getStarsForLevel(level: Int): Int = prefs.getInt("stars_lvl_$level", 0)

    fun saveLevelCompletion(level: Int, stars: Int, acornsEarned: Int) {
        val oldStars = getStarsForLevel(level)
        if (stars > oldStars) {
            prefs.edit().putInt("stars_lvl_$level", stars).apply()
        }
        acorns += acornsEarned
        if (level == maxUnlockedLevel && maxUnlockedLevel < 200) {
            maxUnlockedLevel = level + 1
        }
        if (level < 200) {
            currentLevel = level + 1
        }
    }
}

package com.nebulagame.rotaterings.rotate_rings.model

data class LevelData(
    val levelNumber: Int,
    val title: String,
    val category: String,
    val difficulty: Int,
    val rings: MutableList<Ring>,
    val joints: MutableList<Joint>,
    val targetMoves: Int,
    val targetSeconds: Int,
    val totalAcorns: Int = rings.count { it.hasAcorn }
) {
    fun clone(): LevelData {
        return LevelData(
            levelNumber = levelNumber,
            title = title,
            category = category,
            difficulty = difficulty,
            rings = rings.map { it.copy() }.toMutableList(),
            joints = joints.map { it.copy() }.toMutableList(),
            targetMoves = targetMoves,
            targetSeconds = targetSeconds,
            totalAcorns = totalAcorns
        )
    }
}

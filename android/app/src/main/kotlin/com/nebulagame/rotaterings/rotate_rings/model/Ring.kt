package com.nebulagame.rotaterings.rotate_rings.model

import kotlin.math.PI
import kotlin.math.abs

enum class RingShapeType {
    C_LOCK, D_RING, S_FLEX, TRIANGLE_LOCK, DOUBLE_RING,
    TRIPLE_RING, SPIRAL_LOCK, MULTI_LAYER, INTERLOCKED_CHAIN, COMPLEX_GEOMETRY
}

enum class RingStatus {
    LOCKED, MOVABLE, UNLOCKED, RELEASED, COMPLETED
}

data class Ring(
    val id: String,
    val cx: Float,
    val cy: Float,
    val radius: Float,
    val strokeWidth: Float = 24f,
    val colorHex: Long,
    val shapeType: RingShapeType = RingShapeType.C_LOCK,
    val layer: Int = 0,
    val hasAcorn: Boolean = false,
    val gapStartAngle: Double,
    val gapSweep: Double = 1.25,
    var currentAngle: Double = 0.0,
    var status: RingStatus = RingStatus.MOVABLE,
    var releaseProgress: Float = 0f,
    var releaseOffsetX: Float = 0f,
    var releaseOffsetY: Float = 0f,
    var releaseRotation: Float = 0f,
    var releaseOpacity: Float = 1f
) {
    val currentGapCenterAngle: Double
        get() {
            val base = currentAngle + gapStartAngle + (gapSweep / 2.0)
            return normalizeAngle(base)
        }

    fun isAngleInGap(targetAngle: Double, tolerance: Double = 0.28): Boolean {
        val normTarget = normalizeAngle(targetAngle)
        val gapCenter = currentGapCenterAngle
        var diff = abs(normTarget - gapCenter)
        if (diff > PI) diff = (2.0 * PI) - diff
        return diff <= ((gapSweep / 2.0) + tolerance)
    }

    companion object {
        fun normalizeAngle(angle: Double): Double {
            val twoPi = 2.0 * PI
            var res = angle % twoPi
            if (res < 0) res += twoPi
            if (res >= twoPi - 1e-5) res = 0.0
            return res
        }
    }
}

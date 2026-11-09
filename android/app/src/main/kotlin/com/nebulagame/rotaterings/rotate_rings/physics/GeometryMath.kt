package com.nebulagame.rotaterings.rotate_rings.physics

import com.nebulagame.rotaterings.rotate_rings.model.Ring
import com.nebulagame.rotaterings.rotate_rings.model.RingStatus
import kotlin.math.*

object GeometryMath {
    const val TWO_PI = 2.0 * PI

    fun normalizeAngle(angle: Double): Double {
        var res = angle % TWO_PI
        if (res < 0) res += TWO_PI
        if (res >= TWO_PI - 1e-5) res = 0.0
        return res
    }

    fun shortestAngleDelta(fromAngle: Double, toAngle: Double): Double {
        var diff = normalizeAngle(toAngle) - normalizeAngle(fromAngle)
        if (diff > PI) {
            diff -= TWO_PI
        } else if (diff < -PI) {
            diff += TWO_PI
        }
        return diff
    }

    fun angleFromCenter(cx: Float, cy: Float, px: Float, py: Float): Double {
        val dx = (px - cx).toDouble()
        val dy = (py - cy).toDouble()
        return normalizeAngle(atan2(dy, dx))
    }

    fun distance(x1: Float, y1: Float, x2: Float, y2: Float): Float {
        val dx = x2 - x1
        val dy = y2 - y1
        return sqrt(dx * dx + dy * dy)
    }

    fun hitTestRing(touchX: Float, touchY: Float, rings: List<Ring>): Ring? {
        val candidates = rings
            .filter { it.status == RingStatus.MOVABLE || it.status == RingStatus.LOCKED }
            .sortedByDescending { it.layer }

        for (ring in candidates) {
            val dist = distance(ring.cx, ring.cy, touchX, touchY)
            val halfW = ring.strokeWidth * 0.9f
            if (dist >= ring.radius - halfW && dist <= ring.radius + halfW) {
                return ring
            }
        }
        return null
    }

    fun isJointInGap(ring: Ring, jointAngleOnRing: Double, tolerance: Double = 0.28): Boolean {
        val normJoint = normalizeAngle(jointAngleOnRing)
        val gapCenter = ring.currentGapCenterAngle
        var diff = abs(normJoint - gapCenter)
        if (diff > PI) diff = TWO_PI - diff
        return diff <= ((ring.gapSweep / 2.0) + tolerance)
    }
}

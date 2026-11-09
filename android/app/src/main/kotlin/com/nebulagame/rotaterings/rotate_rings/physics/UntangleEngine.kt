package com.nebulagame.rotaterings.rotate_rings.physics

import com.nebulagame.rotaterings.rotate_rings.model.Joint
import com.nebulagame.rotaterings.rotate_rings.model.LevelData
import com.nebulagame.rotaterings.rotate_rings.model.Ring
import com.nebulagame.rotaterings.rotate_rings.model.RingStatus
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin

data class UntangleResult(
    val freedRings: List<Ring>,
    val freedJoints: List<Joint>,
    val acornsGained: Int,
    val puzzleComplete: Boolean
)

object UntangleEngine {
    fun checkAndReleaseCascade(level: LevelData): UntangleResult {
        val newlyFreedRings = mutableListOf<Ring>()
        val newlyFreedJoints = mutableListOf<Joint>()
        var acornsCount = 0

        var stateChanged = true
        while (stateChanged) {
            stateChanged = false

            // 1. Check all joints that are still holding pieces
            for (joint in level.joints) {
                if (joint.isReleased) continue

                val ringA = level.rings.first { it.id == joint.ringIdA }
                val ringB = joint.ringIdB?.let { bId -> level.rings.first { it.id == bId } }

                if (ringA.status == RingStatus.RELEASED || ringA.status == RingStatus.COMPLETED ||
                    (ringB != null && (ringB.status == RingStatus.RELEASED || ringB.status == RingStatus.COMPLETED))
                ) {
                    joint.detachedFromA = true
                    joint.detachedFromB = true
                    joint.isReleased = true
                    newlyFreedJoints.add(joint)
                    stateChanged = true
                    continue
                }

                if (!joint.detachedFromA) {
                    val angleA = atan2((joint.py - ringA.cy).toDouble(), (joint.px - ringA.cx).toDouble())
                    if (GeometryMath.isJointInGap(ringA, angleA)) {
                        joint.detachedFromA = true
                        joint.updateReleaseState()
                        stateChanged = true
                    }
                }

                if (ringB != null && !joint.detachedFromB) {
                    val angleB = atan2((joint.py - ringB.cy).toDouble(), (joint.px - ringB.cx).toDouble())
                    if (GeometryMath.isJointInGap(ringB, angleB)) {
                        joint.detachedFromB = true
                        joint.updateReleaseState()
                        stateChanged = true
                    }
                }

                if (joint.isReleased && !newlyFreedJoints.contains(joint)) {
                    newlyFreedJoints.add(joint)
                }
            }

            // 2. Check rings with no remaining joints
            for (ring in level.rings) {
                if (ring.status == RingStatus.RELEASED || ring.status == RingStatus.COMPLETED || ring.status == RingStatus.UNLOCKED) continue

                val isHeld = level.joints.any { j ->
                    val otherId = if (j.ringIdA == ring.id) j.ringIdB else j.ringIdA
                    val otherRing = otherId?.let { oId -> level.rings.firstOrNull { it.id == oId } }
                    val isOtherFreed = otherRing != null && otherRing.id != ring.id &&
                            (otherRing.status == RingStatus.RELEASED || otherRing.status == RingStatus.COMPLETED || otherRing.status == RingStatus.UNLOCKED)
                    j.isHoldingRing(ring.id, isOtherRingFreed = isOtherFreed)
                }

                if (!isHeld) {
                    ring.status = RingStatus.UNLOCKED
                    ring.releaseOffsetX = (cos(ring.currentAngle) * 450.0).toFloat()
                    ring.releaseOffsetY = (sin(ring.currentAngle) * 450.0).toFloat()
                    ring.releaseProgress = 0.0f
                    ring.releaseOpacity = 1.0f

                    if (ring.hasAcorn) {
                        acornsCount++
                    }

                    newlyFreedRings.add(ring)
                    stateChanged = true
                }
            }
        }

        val allFreed = level.rings.all {
            it.status == RingStatus.UNLOCKED || it.status == RingStatus.RELEASED || it.status == RingStatus.COMPLETED
        }

        return UntangleResult(
            freedRings = newlyFreedRings,
            freedJoints = newlyFreedJoints,
            acornsGained = acornsCount,
            puzzleComplete = allFreed
        )
    }
}

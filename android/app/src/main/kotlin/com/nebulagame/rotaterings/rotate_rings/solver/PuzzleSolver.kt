package com.nebulagame.rotaterings.rotate_rings.solver

import com.nebulagame.rotaterings.rotate_rings.model.LevelData
import com.nebulagame.rotaterings.rotate_rings.model.Ring
import com.nebulagame.rotaterings.rotate_rings.model.RingStatus
import com.nebulagame.rotaterings.rotate_rings.physics.GeometryMath
import kotlin.math.abs

data class HintStep(
    val ringId: String,
    val targetAngle: Double,
    val deltaAngle: Double,
    val isClockwise: Boolean,
    val message: String
)

object PuzzleSolver {
    fun findNextMove(level: LevelData): HintStep? {
        val activeRings = level.rings.filter {
            it.status == RingStatus.MOVABLE || it.status == RingStatus.LOCKED
        }
        if (activeRings.isEmpty()) return null

        val unreleasedJoints = level.joints.filter { !it.isReleased }
        if (unreleasedJoints.isEmpty()) {
            val first = activeRings.first()
            return HintStep(
                ringId = first.id,
                targetAngle = first.currentAngle,
                deltaAngle = 0.0,
                isClockwise = true,
                message = "Chạm vào vòng để tháo gỡ hoàn toàn"
            )
        }

        var bestRing: Ring? = null
        var bestTargetAngle = 0.0
        var bestDelta = 0.0
        var bestPriority = Double.NEGATIVE_INFINITY

        for (ring in activeRings) {
            val ringJoints = unreleasedJoints.filter { it.ringIdA == ring.id || it.ringIdB == ring.id }
            for (joint in ringJoints) {
                val jointAngle = if (joint.ringIdA == ring.id) joint.angleOnA else (joint.angleOnB ?: joint.angleOnA)
                val targetAngle = GeometryMath.normalizeAngle(jointAngle - ring.gapStartAngle - (ring.gapSweep / 2.0))
                val delta = GeometryMath.shortestAngleDelta(ring.currentAngle, targetAngle)

                // Simulate move score
                val oldAngle = ring.currentAngle
                ring.currentAngle = targetAngle
                var freedCount = 0
                for (j in unreleasedJoints) {
                    if (j.ringIdA == ring.id && GeometryMath.isJointInGap(ring, j.angleOnA)) freedCount++
                    else if (j.ringIdB == ring.id && j.angleOnB != null && GeometryMath.isJointInGap(ring, j.angleOnB)) freedCount++
                }
                ring.currentAngle = oldAngle

                val priority = (freedCount * 100.0) - (abs(delta) * 10.0)
                if (priority > bestPriority) {
                    bestPriority = priority
                    bestRing = ring
                    bestTargetAngle = targetAngle
                    bestDelta = delta
                }
            }
        }

        if (bestRing == null) return null

        val isCw = bestDelta >= 0
        val dir = if (isCw) "thuận chiều kim đồng hồ" else "ngược chiều kim đồng hồ"
        return HintStep(
            ringId = bestRing.id,
            targetAngle = bestTargetAngle,
            deltaAngle = bestDelta,
            isClockwise = isCw,
            message = "Xoay vòng $dir để mở chốt"
        )
    }
}

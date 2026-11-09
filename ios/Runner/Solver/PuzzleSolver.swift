import Foundation
import CoreGraphics

public struct HintStep {
    public let ringId: String
    public let targetAngle: Double
    public let deltaAngle: Double
    public let isClockwise: Bool
    public let message: String
}

public struct PuzzleSolver {
    public static func findNextMove(level: LevelData) -> HintStep? {
        let activeRings = level.rings.filter { $0.status == .movable || $0.status == .locked }
        if activeRings.isEmpty { return nil }

        let unreleasedJoints = level.joints.filter { !$0.isReleased }
        if unreleasedJoints.isEmpty {
            let first = activeRings.first!
            return HintStep(
                ringId: first.id,
                targetAngle: first.currentAngle,
                deltaAngle: 0.0,
                isClockwise: true,
                message: "Chạm vào vòng để tháo gỡ hoàn toàn"
            )
        }

        var bestRing: Ring? = nil
        var bestTargetAngle = 0.0
        var bestDelta = 0.0
        var bestPriority = -Double.infinity

        for ring in activeRings {
            let ringJoints = unreleasedJoints.filter { $0.ringIdA == ring.id || $0.ringIdB == ring.id }
            for joint in ringJoints {
                let jointAngle = (joint.ringIdA == ring.id) ? joint.angleOnA : (joint.angleOnB ?? joint.angleOnA)
                let targetAngle = GeometryMath.normalizeAngle(jointAngle - ring.gapStartAngle - (ring.gapSweep / 2.0))
                let delta = GeometryMath.shortestAngleDelta(from: ring.currentAngle, to: targetAngle)

                // Simulate score
                var simRing = ring
                simRing.currentAngle = targetAngle
                var freedCount = 0
                for j in unreleasedJoints {
                    if j.ringIdA == ring.id && GeometryMath.isJointInGap(ring: simRing, jointAngleOnRing: j.angleOnA) { freedCount += 1 }
                    else if j.ringIdB == ring.id, let aB = j.angleOnB, GeometryMath.isJointInGap(ring: simRing, jointAngleOnRing: aB) { freedCount += 1 }
                }

                let priority = Double(freedCount * 100) - (abs(delta) * 10.0)
                if priority > bestPriority {
                    bestPriority = priority
                    bestRing = ring
                    bestTargetAngle = targetAngle
                    bestDelta = delta
                }
            }
        }

        guard let ring = bestRing else { return nil }
        let isCw = bestDelta >= 0
        let dir = isCw ? "thuận chiều kim đồng hồ" : "ngược chiều kim đồng hồ"
        return HintStep(
            ringId: ring.id,
            targetAngle: bestTargetAngle,
            deltaAngle: bestDelta,
            isClockwise: isCw,
            message: "Xoay vòng \(dir) để mở chốt"
        )
    }
}

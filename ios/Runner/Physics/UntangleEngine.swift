import Foundation
import CoreGraphics

public struct UntangleResult {
    public let freedRings: [Ring]
    public let freedJoints: [Joint]
    public let acornsGained: Int
    public let puzzleComplete: Bool
}

public class UntangleEngine {
    public static func checkAndReleaseCascade(level: LevelData) -> UntangleResult {
        var newlyFreedRings: [Ring] = []
        var newlyFreedJoints: [Joint] = []
        var acornsCount: Int = 0

        var stateChanged = true
        while stateChanged {
            stateChanged = false

            for joint in level.joints {
                if joint.isReleased { continue }

                guard let ringA = level.rings.first(where: { $0.id == joint.ringIdA }) else { continue }
                let ringB = joint.ringIdB != nil ? level.rings.first(where: { $0.id == joint.ringIdB }) : nil

                if ringA.status == .released || ringA.status == .completed ||
                    (ringB != nil && (ringB!.status == .released || ringB!.status == .completed)) {
                    joint.detachedFromA = true
                    joint.detachedFromB = true
                    joint.isReleased = true
                    newlyFreedJoints.append(joint)
                    stateChanged = true
                    continue
                }

                if !joint.detachedFromA {
                    let angleA = Double(atan2(joint.position.y - ringA.center.y, joint.position.x - ringA.center.x))
                    if GeometryMath.isJointInGap(ringA, angleA) {
                        joint.detachedFromA = true
                        joint.updateReleaseState()
                        stateChanged = true
                    }
                }

                if let rB = ringB, !joint.detachedFromB {
                    let angleB = Double(atan2(joint.position.y - rB.center.y, joint.position.x - rB.center.x))
                    if GeometryMath.isJointInGap(rB, angleB) {
                        joint.detachedFromB = true
                        joint.updateReleaseState()
                        stateChanged = true
                    }
                }

                if joint.isReleased && !newlyFreedJoints.contains(where: { $0.id == joint.id }) {
                    newlyFreedJoints.append(joint)
                }
            }

            for ring in level.rings {
                if ring.status == .unlocked || ring.status == .released || ring.status == .completed { continue }

                let isHeld = level.joints.contains { j in
                    let otherId = (j.ringIdA == ring.id) ? j.ringIdB : j.ringIdA
                    let otherRing = otherId != nil ? level.rings.first(where: { $0.id == otherId }) : nil
                    let isOtherFreed = otherRing != nil && otherRing!.id != ring.id &&
                        (otherRing!.status == .released || otherRing!.status == .completed || otherRing!.status == .unlocked)
                    return j.isHoldingRing(ring.id, isOtherRingFreed: isOtherFreed)
                }

                if !isHeld {
                    ring.status = .unlocked
                    ring.releaseOffset = CGPoint(
                        x: CGFloat(cos(ring.currentAngle) * 450.0),
                        y: CGFloat(sin(ring.currentAngle) * 450.0)
                    )
                    ring.releaseProgress = 0.0
                    ring.releaseOpacity = 1.0

                    if ring.hasAcorn {
                        acornsCount += 1
                    }

                    newlyFreedRings.append(ring)
                    stateChanged = true
                }
            }
        }

        let allFreed = level.rings.allSatisfy { $0.status == .unlocked || $0.status == .released || $0.status == .completed }

        return UntangleResult(
            freedRings: newlyFreedRings,
            freedJoints: newlyFreedJoints,
            acornsGained: acornsCount,
            puzzleComplete: allFreed
        )
    }
}

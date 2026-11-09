import Foundation
import CoreGraphics

public struct GeometryMath {
    public static let twoPi = 2.0 * Double.pi

    public static func normalizeAngle(_ angle: Double) -> Double {
        var res = angle.truncatingRemainder(dividingBy: twoPi)
        if res < 0 { res += twoPi }
        if res >= twoPi - 1e-5 { res = 0.0 }
        return res
    }

    public static func shortestAngleDelta(from fromAngle: Double, to toAngle: Double) -> Double {
        var diff = normalizeAngle(toAngle) - normalizeAngle(fromAngle)
        if diff > .pi {
            diff -= twoPi
        } else if diff < -.pi {
            diff += twoPi
        }
        return diff
    }

    public static func angleFromCenter(cx: CGFloat, cy: CGFloat, px: CGFloat, py: CGFloat) -> Double {
        let dx = Double(px - cx)
        let dy = Double(py - cy)
        return normalizeAngle(atan2(dy, dx))
    }

    public static func distance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat {
        let dx = x2 - x1
        let dy = y2 - y1
        return sqrt(dx * dx + dy * dy)
    }

    public static func hitTestRing(touchX: CGFloat, touchY: CGFloat, rings: [Ring]) -> Ring? {
        let candidates = rings
            .filter { $0.status == .movable || $0.status == .locked }
            .sorted { $0.layer > $1.layer }

        for ring in candidates {
            let dist = distance(x1: ring.cx, y1: ring.cy, x2: touchX, y2: touchY)
            let halfW = ring.strokeWidth * 0.9
            if dist >= ring.radius - halfW && dist <= ring.radius + halfW {
                return ring
            }
        }
        return nil
    }

    public static func isJointInGap(ring: Ring, jointAngleOnRing: Double, tolerance: Double = 0.28) -> Bool {
        let normJoint = normalizeAngle(jointAngleOnRing)
        let gapCenter = ring.currentGapCenterAngle
        var diff = abs(normJoint - gapCenter)
        if diff > .pi { diff = twoPi - diff }
        return diff <= ((ring.gapSweep / 2.0) + tolerance)
    }
}

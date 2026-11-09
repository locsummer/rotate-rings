import Foundation
import CoreGraphics

public enum RingShapeType: Int, Codable {
    case cLock, dRing, sFlex, triangleLock, doubleRing
    case tripleRing, spiralLock, multiLayer, interlockedChain, complexGeometry
}

public enum RingStatus: Int, Codable {
    case locked, movable, unlocked, released, completed
}

public struct Ring: Codable, Identifiable {
    public let id: String
    public var cx: CGFloat
    public var cy: CGFloat
    public var radius: CGFloat
    public var strokeWidth: CGFloat
    public var colorHex: UInt32
    public var shapeType: RingShapeType
    public var layer: Int
    public var hasAcorn: BooleanLiteralType
    public var gapStartAngle: Double
    public var gapSweep: Double
    public var currentAngle: Double
    public var status: RingStatus
    public var releaseProgress: CGFloat
    public var releaseOffsetX: CGFloat
    public var releaseOffsetY: CGFloat
    public var releaseRotation: CGFloat
    public var releaseOpacity: CGFloat

    public init(
        id: String,
        cx: CGFloat,
        cy: CGFloat,
        radius: CGFloat,
        strokeWidth: CGFloat = 24.0,
        colorHex: UInt32,
        shapeType: RingShapeType = .cLock,
        layer: Int = 0,
        hasAcorn: Bool = false,
        gapStartAngle: Double,
        gapSweep: Double = 1.25,
        currentAngle: Double = 0.0,
        status: RingStatus = .movable,
        releaseProgress: CGFloat = 0.0,
        releaseOffsetX: CGFloat = 0.0,
        releaseOffsetY: CGFloat = 0.0,
        releaseRotation: CGFloat = 0.0,
        releaseOpacity: CGFloat = 1.0
    ) {
        self.id = id
        self.cx = cx
        self.cy = cy
        self.radius = radius
        self.strokeWidth = strokeWidth
        self.colorHex = colorHex
        self.shapeType = shapeType
        self.layer = layer
        self.hasAcorn = hasAcorn
        self.gapStartAngle = gapStartAngle
        self.gapSweep = gapSweep
        self.currentAngle = currentAngle
        self.status = status
        self.releaseProgress = releaseProgress
        self.releaseOffsetX = releaseOffsetX
        self.releaseOffsetY = releaseOffsetY
        self.releaseRotation = releaseRotation
        self.releaseOpacity = releaseOpacity
    }

    public var currentGapCenterAngle: Double {
        let base = currentAngle + gapStartAngle + (gapSweep / 2.0)
        return Ring.normalizeAngle(base)
    }

    public func isAngleInGap(_ targetAngle: Double, tolerance: Double = 0.28) -> Bool {
        let normTarget = Ring.normalizeAngle(targetAngle)
        let gapCenter = currentGapCenterAngle
        var diff = abs(normTarget - gapCenter)
        if diff > .pi { diff = (2.0 * .pi) - diff }
        return diff <= ((gapSweep / 2.0) + tolerance)
    }

    public static func normalizeAngle(_ angle: Double) -> Double {
        let twoPi = 2.0 * Double.pi
        var res = angle.truncatingRemainder(dividingBy: twoPi)
        if res < 0 { res += twoPi }
        if res >= twoPi - 1e-5 { res = 0.0 }
        return res
    }
}

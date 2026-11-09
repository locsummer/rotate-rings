import Foundation
import CoreGraphics

public enum JointType: String, Codable {
    case sleeve
    case pin
    case chainLink
    case pivot
}

public class Joint {
    public let id: String
    public let type: JointType
    public let position: CGPoint
    public let ringIdA: String
    public let ringIdB: String?
    public let colorHex: String
    public let isSilver: BooleanLiteralType
    public let angleOnA: Double
    public let angleOnB: Double?
    
    public var detachedFromA: Bool = false
    public var detachedFromB: Bool = false
    public var isReleased: Bool = false
    public var releaseAnimation: CGFloat = 0.0

    public init(
        id: String,
        type: JointType = .sleeve,
        position: CGPoint,
        ringIdA: String,
        ringIdB: String? = nil,
        colorHex: String,
        isSilver: Bool = false,
        angleOnA: Double,
        angleOnB: Double? = nil,
        isReleased: Bool = false
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.ringIdA = ringIdA
        self.ringIdB = ringIdB
        self.colorHex = colorHex
        self.isSilver = isSilver
        self.angleOnA = angleOnA
        self.angleOnB = angleOnB
        self.isReleased = isReleased
    }

    public func isHoldingRing(_ ringId: String, isOtherRingFreed: Bool = false) -> Bool {
        if isReleased { return false }
        if type == .pin {
            if ringIdA == ringId { return !detachedFromA }
            return false
        }
        if ringIdA == ringId {
            if detachedFromA { return false }
            if isOtherRingFreed || detachedFromB { return false }
            return true
        }
        if ringIdB == ringId {
            if detachedFromB { return false }
            if isOtherRingFreed || detachedFromA { return false }
            return true
        }
        return false
    }

    public func updateReleaseState() {
        if detachedFromA || detachedFromB {
            isReleased = true
        }
    }
}

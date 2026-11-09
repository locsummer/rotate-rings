import Foundation
import CoreGraphics

public struct LevelCatalog {
    public static let totalLevels = 200

    public static func getLevel(_ levelNumber: Int) -> LevelData {
        let n = max(1, min(totalLevels, levelNumber))
        switch n {
        case 65:
            return buildLevel65()
        case 1...20:
            return buildTier1(n)
        case 21...40:
            return buildTier2(n)
        case 41...60:
            return buildTier3(n)
        case 61...80:
            return buildTier4(n)
        case 81...100:
            return buildTier5(n)
        case 101...130:
            return buildTier6(n)
        case 131...160:
            return buildTier7(n)
        case 161...180:
            return buildTier8(n)
        default:
            return buildTier9(n)
        }
    }

    private static func buildTier1(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()

        if n <= 8 {
            rings.append(Ring(id: "r1", cx: 200, cy: 300, radius: 80, colorHex: 0xFFFF9233, gapStartAngle: 0.0, currentAngle: 0.5, hasAcorn: true))
            joints.append(Joint(id: "j1", type: .pin, px: 200, py: 220, ringIdA: "r1", colorHex: 0xFF4A5568, angleOnA: -.pi / 2))
        } else {
            rings.append(Ring(id: "r1", cx: 145, cy: 300, radius: 68, colorHex: 0xFF34A9F4, gapStartAngle: 0.0, currentAngle: 0.8, hasAcorn: true))
            rings.append(Ring(id: "r2", cx: 255, cy: 300, radius: 68, colorHex: 0xFF9E4FE8, gapStartAngle: 0.0, currentAngle: 1.5))
            joints.append(Joint(id: "j1_2", px: 200, py: 300, ringIdA: "r1", ringIdB: "r2", colorHex: 0xFF4A5568, angleOnA: 0.0, angleOnB: .pi))
        }
        return LevelData(levelNumber: n, title: "Căn Bản \(n)", category: "Làm Quen", difficulty: 1, rings: rings, joints: joints, targetMoves: rings.count * 2, targetSeconds: 30)
    }

    private static func buildTier2(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()
        let count = (n < 32) ? 2 : 3

        for i in 0..<count {
            rings.append(Ring(id: "r\(i + 1)", cx: 200, cy: CGFloat(190 + i * 110), radius: 55, colorHex: (i % 2 == 0) ? 0xFF34A9F4 : 0xFF78C826, gapStartAngle: Double(i) * 0.3, currentAngle: Double(i) * 0.9, hasAcorn: (i % 2 == 0)))
        }
        for i in 0..<(count - 1) {
            joints.append(Joint(id: "j_\(i + 1)_\(i + 2)", px: 200, py: CGFloat(245 + i * 110), ringIdA: "r\(i + 1)", ringIdB: "r\(i + 2)", colorHex: 0xFF4A5568, angleOnA: .pi / 2, angleOnB: -.pi / 2))
        }
        return LevelData(levelNumber: n, title: "Khe Hở Kép \(n)", category: "Hai Vòng", difficulty: 2, rings: rings, joints: joints, targetMoves: count * 2 + 1, targetSeconds: 35)
    }

    private static func buildTier3(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()
        let centers: [(CGFloat, CGFloat)] = [(145, 230), (255, 230), (200, 360)]

        for i in 0..<3 {
            rings.append(Ring(id: "r\(i + 1)", cx: centers[i].0, cy: centers[i].1, radius: 58, colorHex: 0xFFFF9233, shapeType: (i % 2 == 0) ? .cLock : .dRing, gapStartAngle: Double(i) * 0.5, currentAngle: Double(i) * 1.1, hasAcorn: (i == 0)))
        }
        joints.append(createJoint(id: "j1_2", rA: rings[0], rB: rings[1], colorHex: 0xFF4A5568))
        joints.append(createJoint(id: "j2_3", rA: rings[1], rB: rings[2], colorHex: 0xFF4A5568))
        return LevelData(levelNumber: n, title: "Khóa C-Lock \(n)", category: "C-Lock & D-Ring", difficulty: 3, rings: rings, joints: joints, targetMoves: 8, targetSeconds: 45)
    }

    private static func buildTier4(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()
        for i in 0..<5 {
            let cx: CGFloat = (i % 2 == 0) ? 150 : 250
            let cy: CGFloat = CGFloat(160 + i * 75)
            rings.append(Ring(id: "r\(i + 1)", cx: cx, cy: cy, radius: 54, colorHex: 0xFF9E4FE8, shapeType: .interlockedChain, gapStartAngle: Double(i) * 0.4, currentAngle: Double(i) * 0.8, hasAcorn: (i % 2 == 1)))
        }
        for i in 0..<4 {
            joints.append(createJoint(id: "j_\(i + 1)_\(i + 2)", rA: rings[i], rB: rings[i + 1], colorHex: 0xFF4A5568))
        }
        return LevelData(levelNumber: n, title: "Chuỗi Mắt Xích \(n)", category: "Mắt Xích Đan Xen", difficulty: 3, rings: rings, joints: joints, targetMoves: 10, targetSeconds: 50)
    }

    private static func buildLevel65() -> LevelData {
        let rings = [
            Ring(id: "r1", cx: 155, cy: 150, radius: 52, colorHex: 0xFFFF9233, gapStartAngle: 0.0, currentAngle: -0.8, hasAcorn: true),
            Ring(id: "r2", cx: 230, cy: 215, radius: 52, colorHex: 0xFF34A9F4, gapStartAngle: 0.0, currentAngle: 1.2),
            Ring(id: "r3", cx: 170, cy: 305, radius: 52, colorHex: 0xFF9E4FE8, gapStartAngle: 0.0, currentAngle: -0.6, hasAcorn: true),
            Ring(id: "r4", cx: 265, cy: 335, radius: 52, colorHex: 0xFF2EA868, gapStartAngle: 0.0, currentAngle: 2.1),
            Ring(id: "r5", cx: 110, cy: 385, radius: 52, colorHex: 0xFFE84545, gapStartAngle: 0.0, currentAngle: -2.3),
            Ring(id: "r6", cx: 195, cy: 420, radius: 52, colorHex: 0xFF78C826, gapStartAngle: 0.0, currentAngle: 0.5, hasAcorn: true),
            Ring(id: "r7", cx: 155, cy: 510, radius: 52, colorHex: 0xFF3B72DE, gapStartAngle: 0.0, currentAngle: 0.0)
        ]
        let joints = [
            createJoint(id: "j1_2", rA: rings[0], rB: rings[1], colorHex: 0xFF34A9F4),
            createJoint(id: "j2_3", rA: rings[1], rB: rings[2], colorHex: 0xFF9E4FE8),
            createJoint(id: "j3_5", rA: rings[2], rB: rings[4], colorHex: 0xFFE84545),
            createJoint(id: "j3_6", rA: rings[2], rB: rings[5], colorHex: 0xFF9E4FE8),
            createJoint(id: "j6_4", rA: rings[5], rB: rings[3], colorHex: 0xFF78C826),
            createJoint(id: "j6_7", rA: rings[5], rB: rings[6], colorHex: 0xFF78C826)
        ]
        return LevelData(levelNumber: 65, title: "Mắt Xích Kỳ Diệu 65", category: "Nebula Classic", difficulty: 4, rings: rings, joints: joints, targetMoves: 14, targetSeconds: 60)
    }

    private static func buildTier5(_ n: Int) -> LevelData {
        let rings = [
            Ring(id: "r1", cx: 200, cy: 300, radius: 50, colorHex: 0xFFFF9233, gapStartAngle: 0.0, hasAcorn: true),
            Ring(id: "r2", cx: 200, cy: 300, radius: 85, colorHex: 0xFF34A9F4, gapStartAngle: 0.5),
            Ring(id: "r3", cx: 200, cy: 300, radius: 120, colorHex: 0xFF9E4FE8, gapStartAngle: 1.0)
        ]
        let joints = [
            Joint(id: "j1_2", px: 200, py: 233, ringIdA: "r1", ringIdB: "r2", colorHex: 0xFF4A5568, angleOnA: -.pi / 2, angleOnB: -.pi / 2),
            Joint(id: "j2_3", px: 200, py: 198, ringIdA: "r2", ringIdB: "r3", colorHex: 0xFF4A5568, angleOnA: -.pi / 2, angleOnB: -.pi / 2)
        ]
        return LevelData(levelNumber: n, title: "Ba Vòng Hòa Nhịp \(n)", category: "Ba Vòng", difficulty: 3, rings: rings, joints: joints, targetMoves: 8, targetSeconds: 45)
    }

    private static func buildTier6(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()
        let count = 4
        for i in 0..<count {
            let a = (2.0 * .pi / Double(count)) * Double(i) - .pi / 2
            let cx = 200 + CGFloat(85.0 * cos(a))
            let cy = 300 + CGFloat(85.0 * sin(a))
            rings.append(Ring(id: "r\(i + 1)", cx: cx, cy: cy, radius: 50, colorHex: 0xFFFF9233, gapStartAngle: Double(i) * 0.5, hasAcorn: (i == 0)))
        }
        for i in 0..<count {
            joints.append(createJoint(id: "j_\(i + 1)_\((i + 1) % count + 1)", rA: rings[i], rB: rings[(i + 1) % count], colorHex: 0xFF4A5568))
        }
        return LevelData(levelNumber: n, title: "Khung Đa Giác \(n)", category: "Khóa Hình Học", difficulty: 4, rings: rings, joints: joints, targetMoves: 10, targetSeconds: 60)
    }

    private static func buildTier7(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()
        let center = Ring(id: "r_c", cx: 200, cy: 300, radius: 60, colorHex: 0xFFFF9233, gapStartAngle: 0.0, hasAcorn: true)
        rings.append(center)
        for i in 0..<3 {
            let a = (2.0 * .pi / 3.0) * Double(i) - .pi / 2
            let cx = 200 + CGFloat(95.0 * cos(a))
            let cy = 300 + CGFloat(95.0 * sin(a))
            let r = Ring(id: "r_o_\(i + 1)", cx: cx, cy: cy, radius: 54, colorHex: 0xFF34A9F4, gapStartAngle: Double(i) * 0.4)
            rings.append(r)
            joints.append(createJoint(id: "j_c_\(i)", rA: center, rB: r, colorHex: 0xFF4A5568))
        }
        return LevelData(levelNumber: n, title: "Khóa Đa Tầng \(n)", category: "Nhiều Tầng", difficulty: 4, rings: rings, joints: joints, targetMoves: 12, targetSeconds: 65)
    }

    private static func buildTier8(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()
        let centers: [(CGFloat, CGFloat)] = [(130, 200), (270, 200), (200, 300), (130, 400), (270, 400)]
        for i in 0..<5 {
            rings.append(Ring(id: "r\(i + 1)", cx: centers[i].0, cy: centers[i].1, radius: 52, colorHex: 0xFF78C826, gapStartAngle: Double(i) * 0.3, hasAcorn: (i == 2)))
        }
        joints.append(createJoint(id: "j1_3", rA: rings[0], rB: rings[2], colorHex: 0xFF4A5568))
        joints.append(createJoint(id: "j2_3", rA: rings[1], rB: rings[2], colorHex: 0xFF4A5568))
        joints.append(createJoint(id: "j4_3", rA: rings[3], rB: rings[2], colorHex: 0xFF4A5568))
        joints.append(createJoint(id: "j5_3", rA: rings[4], rB: rings[2], colorHex: 0xFF4A5568))
        return LevelData(levelNumber: n, title: "Khóa Lai Tạo \(n)", category: "Kết Hợp", difficulty: 5, rings: rings, joints: joints, targetMoves: 14, targetSeconds: 75)
    }

    private static func buildTier9(_ n: Int) -> LevelData {
        var rings = [Ring]()
        var joints = [Joint]()
        for i in 0..<6 {
            let cx: CGFloat = (i % 2 == 0) ? 140 : 260
            let cy: CGFloat = CGFloat(180 + i * 60)
            rings.append(Ring(id: "r\(i + 1)", cx: cx, cy: cy, radius: 50, colorHex: 0xFFE84545, gapStartAngle: Double(i) * 0.4, hasAcorn: (i % 2 == 1)))
        }
        for i in 0..<5 {
            joints.append(createJoint(id: "j_\(i + 1)_\(i + 2)", rA: rings[i], rB: rings[i + 1], colorHex: 0xFF4A5568))
        }
        return LevelData(levelNumber: n, title: "Bậc Thầy \(n)", category: "Master", difficulty: 5, rings: rings, joints: joints, targetMoves: 16, targetSeconds: 90)
    }

    private static func createJoint(id: String, rA: Ring, rB: Ring, colorHex: UInt32) -> Joint {
        let mx = (rA.cx + rB.cx) / 2.0
        let my = (rA.cy + rB.cy) / 2.0
        let aOnA = atan2(Double(my - rA.cy), Double(mx - rA.cx))
        let aOnB = atan2(Double(my - rB.cy), Double(mx - rB.cx))
        return Joint(id: id, type: .sleeve, px: mx, py: my, ringIdA: rA.id, ringIdB: rB.id, colorHex: colorHex, angleOnA: aOnA, angleOnB: aOnB)
    }
}

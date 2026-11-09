import Foundation

public struct LevelData: Codable {
    public let levelNumber: Int
    public let title: String
    public let category: String
    public let difficulty: Int
    public var rings: [Ring]
    public var joints: [Joint]
    public let targetMoves: Int
    public let targetSeconds: Int
    public let totalAcorns: Int

    public init(
        levelNumber: Int,
        title: String,
        category: String,
        difficulty: Int,
        rings: [Ring],
        joints: [Joint],
        targetMoves: Int,
        targetSeconds: Int,
        totalAcorns: Int? = nil
    ) {
        self.levelNumber = levelNumber
        self.title = title
        self.category = category
        self.difficulty = difficulty
        self.rings = rings
        self.joints = joints
        self.targetMoves = targetMoves
        self.targetSeconds = targetSeconds
        self.totalAcorns = totalAcorns ?? rings.filter { $0.hasAcorn }.count
    }
}

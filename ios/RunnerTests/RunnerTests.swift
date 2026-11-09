import XCTest
@testable import Runner

class RunnerTests: XCTestCase {

    func testAngleNormalization() {
        XCTAssertEqual(GeometryMath.normalizeAngle(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(GeometryMath.normalizeAngle(2 * .pi), 0.0, accuracy: 0.001)
        XCTAssertEqual(GeometryMath.normalizeAngle(-.pi / 2), 4.7123, accuracy: 0.001)
    }

    func testAll200Levels() {
        XCTAssertEqual(LevelCatalog.totalLevels, 200)
        for i in 1...200 {
            let lvl = LevelCatalog.getLevel(i)
            XCTAssertEqual(lvl.levelNumber, i)
            XCTAssertFalse(lvl.rings.isEmpty)
            XCTAssertGreaterThan(lvl.targetMoves, 0)
        }
    }

    func testLevel65Sample() {
        let lvl65 = LevelCatalog.getLevel(65)
        XCTAssertEqual(lvl65.levelNumber, 65)
        XCTAssertEqual(lvl65.rings.count, 7)
        XCTAssertEqual(lvl65.joints.count, 6)
        XCTAssertTrue(lvl65.rings.contains { $0.hasAcorn })
    }

    func testSolverAndUntangle() {
        var lvl = LevelCatalog.getLevel(1)
        let hint = PuzzleSolver.findNextMove(level: lvl)
        XCTAssertNotNil(hint)
        XCTAssertFalse(hint!.message.isEmpty)

        // Align gap with joint
        let joint = lvl.joints[0]
        lvl.rings[0].currentAngle = GeometryMath.normalizeAngle(joint.angleOnA - lvl.rings[0].gapStartAngle - (lvl.rings[0].gapSweep / 2.0))

        let result = UntangleEngine.checkAndReleaseCascade(level: &lvl)
        XCTAssertFalse(result.freedRings.isEmpty)
        XCTAssertTrue(result.puzzleComplete)
    }
}

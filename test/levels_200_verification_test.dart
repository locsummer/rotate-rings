import 'package:flutter_test/flutter_test.dart';
import 'package:rotate_rings/levels/level_catalog.dart';
import 'package:rotate_rings/physics/untangle_engine.dart';
import 'package:rotate_rings/solver/puzzle_solver.dart';

void main() {
  group('Individual Verification of All 200 Handcrafted Levels', () {
    for (int lvlNum = 1; lvlNum <= 200; lvlNum++) {
      test('Level $lvlNum: Structural Integrity, Solver & Solvability', () {
        final level = LevelCatalog.getLevel(lvlNum);

        // 1. Basic properties
        expect(level.levelNumber, lvlNum);
        expect(level.title.isNotEmpty, isTrue, reason: "Level $lvlNum title is empty");
        expect(level.category.isNotEmpty, isTrue, reason: "Level $lvlNum category is empty");
        expect(level.difficulty, inInclusiveRange(1, 5), reason: "Level $lvlNum difficulty out of range");
        expect(level.targetMoves, greaterThan(0), reason: "Level $lvlNum targetMoves <= 0");
        expect(level.targetSeconds, greaterThan(0), reason: "Level $lvlNum targetSeconds <= 0");

        // 2. Rings validation
        expect(level.rings.length, greaterThanOrEqualTo(2), reason: "Level $lvlNum has fewer than 2 rings");
        final ringIds = level.rings.map((r) => r.id).toSet();
        expect(ringIds.length, level.rings.length, reason: "Level $lvlNum has duplicate ring IDs");

        for (final ring in level.rings) {
          expect(ring.radius, greaterThan(0.0), reason: "Ring ${ring.id} radius <= 0");
          expect(ring.strokeWidth, greaterThan(0.0), reason: "Ring ${ring.id} strokeWidth <= 0");
          expect(ring.currentAngle.isNaN, isFalse);
          expect(ring.gapStartAngle.isNaN, isFalse);
          expect(ring.gapSweep.isNaN, isFalse);
        }

        // 3. Joints validation
        expect(level.joints.length, greaterThanOrEqualTo(1), reason: "Level $lvlNum has no joints");
        final jointIds = level.joints.map((j) => j.id).toSet();
        expect(jointIds.length, level.joints.length, reason: "Level $lvlNum has duplicate joint IDs");

        for (final joint in level.joints) {
          expect(ringIds.contains(joint.ringIdA), isTrue,
              reason: "Level $lvlNum joint ${joint.id} has invalid ringIdA '${joint.ringIdA}'");
          if (joint.ringIdB != null) {
            expect(ringIds.contains(joint.ringIdB!), isTrue,
                reason: "Level $lvlNum joint ${joint.id} has invalid ringIdB '${joint.ringIdB}'");
          }
        }

        // 4. Initial hint availability
        final initialHint = PuzzleSolver.findNextMove(level);
        expect(initialHint, isNotNull, reason: "Level $lvlNum solver produced null initial hint");
        expect(ringIds.contains(initialHint!.ringId), isTrue,
            reason: "Level $lvlNum hint referenced non-existent ring '${initialHint.ringId}'");
        expect(initialHint.message.isNotEmpty, isTrue);

        // 5. Automated complete solution simulation
        bool reachedVictory = false;
        for (int step = 0; step < 40; step++) {
          var cascade = UntangleEngine.checkAndReleaseCascade(level);
          if (cascade.puzzleComplete || level.rings.every((r) => r.isFreed)) {
            reachedVictory = true;
            break;
          }

          var hint = PuzzleSolver.findNextMove(level);
          if (hint == null) break;

          var ring = level.rings.firstWhere((r) => r.id == hint.ringId);
          ring.currentAngle = hint.targetAngle;

          var stepCascade = UntangleEngine.checkAndReleaseCascade(level, activeRing: ring);
          if (stepCascade.puzzleComplete || level.rings.every((r) => r.isFreed)) {
            reachedVictory = true;
            break;
          }
        }

        final finalCascade = UntangleEngine.checkAndReleaseCascade(level);
        bool allFreed = level.rings.every((r) => r.isFreed);

        expect(reachedVictory || finalCascade.puzzleComplete || allFreed, isTrue,
            reason: "Level $lvlNum was not solved to 100% completion by solver within 40 moves");
      });
    }
  });
}

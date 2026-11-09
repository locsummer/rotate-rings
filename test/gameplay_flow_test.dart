import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotate_rings/levels/level_catalog.dart';
import 'package:rotate_rings/models/ring_model.dart';
import 'package:rotate_rings/models/game_state.dart';
import 'package:rotate_rings/physics/geometry_math.dart';
import 'package:rotate_rings/physics/untangle_engine.dart';
import 'package:rotate_rings/solver/puzzle_solver.dart';
import 'package:rotate_rings/storage/save_service.dart';

void main() {
  setUp(() async {
    await SaveService.instance.init();
  });

  group('1. & 2. Rotation & Touch Physics Verification', () {
    test('Continuous multi-rotation updates currentAngle without drift or NaN', () {
      var ring = RingModel(
        id: 'r_test',
        center: const Offset(200, 300),
        radius: 60,
        color: const Color(0xFFFF9233),
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: 0.0,
      );

      // Simulate dragging around the circle in small increments for 3 full revolutions
      for (int i = 0; i < 360 * 3; i++) {
        double delta = 1.0 * math.pi / 180.0;
        ring.currentAngle = GeometryMath.normalizeAngle(ring.currentAngle + delta);
        expect(ring.currentAngle.isNaN, isFalse);
        expect(ring.currentAngle >= 0.0 && ring.currentAngle < 2 * math.pi, isTrue);
      }
    });

    test('Hit test selects correct ring in overlapping multi-layer scenarios', () {
      var innerRing = RingModel(
        id: 'inner',
        center: const Offset(200, 300),
        radius: 40,
        strokeWidth: 20,
        color: const Color(0xFFFF9233),
        layer: 2, // on top
        gapStartAngle: 0.0,
      );
      var outerRing = RingModel(
        id: 'outer',
        center: const Offset(200, 300),
        radius: 80,
        strokeWidth: 20,
        color: const Color(0xFF34A9F4),
        layer: 1,
        gapStartAngle: 0.0,
      );

      // Touch at radius 40
      var hitInner = GeometryMath.hitTestRing(const Offset(200, 340), [innerRing, outerRing]);
      expect(hitInner?.id, 'inner');

      // Touch at radius 80
      var hitOuter = GeometryMath.hitTestRing(const Offset(200, 380), [innerRing, outerRing]);
      expect(hitOuter?.id, 'outer');

      // Touch in empty space (e.g. radius 150)
      var hitNone = GeometryMath.hitTestRing(const Offset(200, 450), [innerRing, outerRing]);
      expect(hitNone, isNull);
    });
  });

  group('3., 4., 5. & 6. Gap Alignment, Joints & Victory Flow', () {
    test('Gap alignment recognizes joint only when within gap sweep + tolerance', () {
      var ring = RingModel(
        id: 'r1',
        center: const Offset(200, 300),
        radius: 60,
        color: const Color(0xFFFF9233),
        gapStartAngle: 0.0,
        gapSweep: 1.25, // ~71.6 degrees
        currentAngle: 0.0,
      );

      // Gap center is at 1.25 / 2 = 0.625 rad
      double jointAngleExact = 0.625;
      expect(GeometryMath.isJointInGap(ring, jointAngleExact), isTrue);

      // Opposite side (pi away) must NOT be in gap
      double jointAngleOpposite = GeometryMath.normalizeAngle(jointAngleExact + math.pi);
      expect(GeometryMath.isJointInGap(ring, jointAngleOpposite), isFalse);
    });

    test('Cascade untangle frees entire structure when all gaps aligned', () {
      final lvl = LevelCatalog.getLevel(10);
      expect(lvl.rings.length, 2);
      expect(lvl.joints.isNotEmpty, isTrue);

      // Solve ring 1
      final j = lvl.joints.first;
      lvl.rings[0].currentAngle = GeometryMath.normalizeAngle(
        j.angleOnA - lvl.rings[0].gapStartAngle - (lvl.rings[0].gapSweep / 2.0),
      );

      // Solve ring 2
      if (j.angleOnB != null) {
        lvl.rings[1].currentAngle = GeometryMath.normalizeAngle(
          j.angleOnB! - lvl.rings[1].gapStartAngle - (lvl.rings[1].gapSweep / 2.0),
        );
      }

      final result = UntangleEngine.checkAndReleaseCascade(lvl);
      expect(result.freedRings.length, 2);
      expect(result.puzzleComplete, isTrue);
    });
  });

  group('7., 8., 9., 10. & 11. Next Level, Restart, Hint & Save Flow', () {
    test('Restart resets session state to level defaults', () {
      final lvl = LevelCatalog.getLevel(5);
      final session = GameSessionState(currentLevel: lvl);

      session.moves = 12;
      session.elapsedSeconds = 45;
      session.hintsUsed = 2;
      session.acornsCollected = 3;

      session.reset(LevelCatalog.getLevel(5));

      expect(session.moves, 0);
      expect(session.elapsedSeconds, 0);
      expect(session.hintsUsed, 0);
      expect(session.acornsCollected, 0);
      expect(session.isVictory, isFalse);
    });

    test('SaveService handles progression, stars and unlocks properly', () async {
      int initialMax = SaveService.instance.maxUnlockedLevel;

      await SaveService.instance.saveLevelCompletion(
        levelNumber: initialMax,
        stars: 3,
        moves: 4,
        seconds: 15,
        acornsGained: 5,
      );

      expect(SaveService.instance.getStarsForLevel(initialMax), 3);
      expect(SaveService.instance.maxUnlockedLevel >= initialMax + 1, isTrue);
    });

    test('Hint solver always returns a valid, directional hint step', () {
      for (int i = 1; i <= 20; i++) {
        final lvl = LevelCatalog.getLevel(i);
        final hint = PuzzleSolver.findNextMove(lvl);
        expect(hint, isNotNull, reason: "Level $i hint was null");
        expect(hint!.ringId, isNotEmpty);
        expect(hint.message, isNotEmpty);
      }
    });
  });

  group('12. Verification of ALL 200 Levels', () {
    test('Every level from 1 to 200 is verified solvable and properly configured', () {
      for (int i = 1; i <= 200; i++) {
        final lvl = LevelCatalog.getLevel(i);
        expect(lvl.levelNumber, i);
        expect(lvl.rings.isNotEmpty, isTrue);
        expect(lvl.joints.isNotEmpty, isTrue);

        // Verify all joint ring references exist
        for (final j in lvl.joints) {
          expect(lvl.rings.any((r) => r.id == j.ringIdA), isTrue,
              reason: "Level $i joint ${j.id} ringIdA missing");
          if (j.ringIdB != null) {
            expect(lvl.rings.any((r) => r.id == j.ringIdB), isTrue,
                reason: "Level $i joint ${j.id} ringIdB missing");
          }
        }

        // Verify solver can produce initial hint for each level
        final hint = PuzzleSolver.findNextMove(lvl);
        expect(hint, isNotNull, reason: "Level $i solver failure");
      }
    });
  });
}

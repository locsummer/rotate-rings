import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:rotate_rings/physics/geometry_math.dart';
import 'package:rotate_rings/levels/level_catalog.dart';
import 'package:rotate_rings/physics/untangle_engine.dart';
import 'package:rotate_rings/solver/puzzle_solver.dart';
import 'package:rotate_rings/main.dart';

void main() {
  group('Geometry Math Tests', () {
    test('Angle normalization to [0, 2*pi]', () {
      expect(GeometryMath.normalizeAngle(0.0), closeTo(0.0, 0.0001));
      expect(GeometryMath.normalizeAngle(2 * math.pi), closeTo(0.0, 0.001));
      expect(GeometryMath.normalizeAngle(-1.5708), closeTo(4.7124, 0.001));
    });

    test('Shortest angle delta', () {
      double d = GeometryMath.shortestAngleDelta(0.1, 0.5);
      expect(d, closeTo(0.4, 0.001));

      double wrap = GeometryMath.shortestAngleDelta(6.0, 0.2);
      expect(wrap, isPositive);
    });
  });

  group('Level Catalog & Structure Tests', () {
    test('All 200 levels exist and have valid data', () {
      expect(LevelCatalog.totalLevels, 200);

      for (int i = 1; i <= 200; i++) {
        final lvl = LevelCatalog.getLevel(i);
        expect(lvl.levelNumber, i);
        expect(lvl.rings.isNotEmpty, isTrue, reason: "Level $i has no rings");
        expect(lvl.title.isNotEmpty, isTrue);
        expect(lvl.category.isNotEmpty, isTrue);
        expect(lvl.difficulty >= 1 && lvl.difficulty <= 5, isTrue);
        expect(lvl.targetMoves > 0, isTrue);
        expect(lvl.targetSeconds > 0, isTrue);
      }
    });

    test('Level 65 (Nebula Sample) has 7 rings and 6 joints', () {
      final lvl65 = LevelCatalog.getLevel(65);
      expect(lvl65.rings.length, 7);
      expect(lvl65.joints.length, 6);
      expect(lvl65.rings.any((r) => r.hasAcorn), isTrue);
    });
  });

  group('Untangle & Solver Tests', () {
    test('Solver finds valid hint move for Level 1', () {
      final lvl = LevelCatalog.getLevel(1);
      final hint = PuzzleSolver.findNextMove(lvl);
      expect(hint, isNotNull);
      expect(hint!.ringId, isNotEmpty);
      expect(hint.message, isNotEmpty);
    });

    test('Untangle cascade releases ring when gap is aligned', () {
      final lvl = LevelCatalog.getLevel(1);
      final r2 = lvl.rings[1];
      final joint = lvl.joints.first;

      // Align r2 gap directly with joint
      double angle = math.atan2(joint.position.dy - r2.center.dy, joint.position.dx - r2.center.dx);
      r2.currentAngle = GeometryMath.normalizeAngle(
        angle - r2.gapStartAngle - (r2.gapSweep / 2.0),
      );

      final result = UntangleEngine.checkAndReleaseCascade(lvl);
      expect(result.freedRings.isNotEmpty, isTrue);
      expect(result.puzzleComplete, isTrue);
    });
  });

  group('UI App Test', () {
    testWidgets('App renders Game Screen with Level, Acorns and Mascot Banner', (WidgetTester tester) async {
      await tester.pumpWidget(const RotateRingsApp());
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Level'), findsOneWidget);
      expect(find.text('XOAY ĐỂ'), findsOneWidget);
      expect(find.text('MỞ KHÓA'), findsOneWidget);
    });
  });
}

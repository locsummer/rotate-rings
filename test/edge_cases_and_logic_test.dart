import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotate_rings/levels/level_catalog.dart';
import 'package:rotate_rings/models/ring_model.dart';
import 'package:rotate_rings/models/joint_model.dart';
import 'package:rotate_rings/models/game_state.dart';
import 'package:rotate_rings/physics/geometry_math.dart';
import 'package:rotate_rings/physics/untangle_engine.dart';
import 'package:rotate_rings/solver/puzzle_solver.dart';
import 'package:rotate_rings/storage/save_service.dart';
import 'package:rotate_rings/audio/sound_service.dart';
import 'package:rotate_rings/ui/components/particle_system.dart';
import 'package:rotate_rings/ui/components/acorn_widget.dart';
import 'package:rotate_rings/ui/components/squirrel_mascot.dart';
import 'package:rotate_rings/ui/components/victory_dialog.dart';
import 'package:rotate_rings/ui/screens/game_screen.dart';
import 'package:rotate_rings/ui/screens/level_select_screen.dart';

void main() {
  setUp(() async {
    await SaveService.instance.init();
  });

  group('Group 1: Geometry Math & Angle Edge Cases', () {
    test('1.1: normalizeAngle handles 0.0 correctly', () {
      expect(GeometryMath.normalizeAngle(0.0), closeTo(0.0, 1e-5));
    });

    test('1.2: normalizeAngle handles 2*pi correctly (wraps to 0)', () {
      expect(GeometryMath.normalizeAngle(2 * math.pi), closeTo(0.0, 1e-4));
    });

    test('1.3: normalizeAngle handles negative angles', () {
      expect(GeometryMath.normalizeAngle(-math.pi / 2), closeTo(3 * math.pi / 2, 1e-4));
    });

    test('1.4: normalizeAngle handles large positive angles (> 4*pi)', () {
      expect(GeometryMath.normalizeAngle(5 * math.pi), closeTo(math.pi, 1e-4));
    });

    test('1.5: normalizeAngle safely handles NaN by returning 0.0', () {
      expect(GeometryMath.normalizeAngle(double.nan), 0.0);
    });

    test('1.6: normalizeAngle safely handles Infinity by returning 0.0', () {
      expect(GeometryMath.normalizeAngle(double.infinity), 0.0);
      expect(GeometryMath.normalizeAngle(double.negativeInfinity), 0.0);
    });

    test('1.7: shortestAngleDelta clockwise distance', () {
      expect(GeometryMath.shortestAngleDelta(0.5, 1.5), closeTo(1.0, 1e-4));
    });

    test('1.8: shortestAngleDelta counter-clockwise distance', () {
      expect(GeometryMath.shortestAngleDelta(1.5, 0.5), closeTo(-1.0, 1e-4));
    });

    test('1.9: shortestAngleDelta across 0/2pi boundary clockwise', () {
      expect(GeometryMath.shortestAngleDelta(6.0, 0.28), greaterThan(0));
    });

    test('1.10: shortestAngleDelta across 0/2pi boundary counter-clockwise', () {
      expect(GeometryMath.shortestAngleDelta(0.28, 6.0), lessThan(0));
    });

    test('1.11: shortestAngleDelta identical angles returns 0.0', () {
      expect(GeometryMath.shortestAngleDelta(1.234, 1.234), closeTo(0.0, 1e-5));
    });

    test('1.12: angleFromCenter for points in 4 quadrants', () {
      Offset c = const Offset(200, 200);
      expect(GeometryMath.angleFromCenter(c, const Offset(300, 200)), closeTo(0.0, 1e-4)); // Right
      expect(GeometryMath.angleFromCenter(c, const Offset(200, 300)), closeTo(math.pi / 2, 1e-4)); // Down
      expect(GeometryMath.angleFromCenter(c, const Offset(100, 200)), closeTo(math.pi, 1e-4)); // Left
      expect(GeometryMath.angleFromCenter(c, const Offset(200, 100)), closeTo(3 * math.pi / 2, 1e-4)); // Up
    });

    test('1.13: angleFromCenter on exact center point singularity returns 0.0 safely', () {
      Offset c = const Offset(150, 150);
      expect(GeometryMath.angleFromCenter(c, c), 0.0);
    });

    test('1.14: distance function computes Euclidean distance accurately', () {
      expect(GeometryMath.distance(const Offset(0, 0), const Offset(3, 4)), closeTo(5.0, 1e-5));
      expect(GeometryMath.distance(const Offset(10, 20), const Offset(10, 20)), closeTo(0.0, 1e-5));
    });

    test('1.15: rotatePoint rotates coordinates accurately', () {
      Offset p = const Offset(250, 200);
      Offset origin = const Offset(200, 200);
      Offset r90 = GeometryMath.rotatePoint(p, origin, math.pi / 2);
      expect(r90.dx, closeTo(200.0, 1e-4));
      expect(r90.dy, closeTo(250.0, 1e-4));
    });
  });

  group('Group 2: Hit-Testing & Layer Selection Edge Cases', () {
    test('2.1: Hit test inside ring stroke succeeds', () {
      var r = RingModel(
        id: 'r1',
        center: const Offset(200, 300),
        radius: 60,
        strokeWidth: 20,
        color: Colors.orange,
        gapStartAngle: 0.0,
      );
      expect(GeometryMath.hitTestRing(const Offset(200, 360), [r])?.id, 'r1');
    });

    test('2.2: Hit test at inner boundary succeeds', () {
      var r = RingModel(
        id: 'r1',
        center: const Offset(200, 300),
        radius: 60,
        strokeWidth: 20,
        color: Colors.orange,
        gapStartAngle: 0.0,
      );
      // inner boundary is 60 - (20 * 0.95) = 41
      expect(GeometryMath.hitTestRing(const Offset(200, 345), [r])?.id, 'r1');
    });

    test('2.3: Hit test outside ring fails (returns null)', () {
      var r = RingModel(
        id: 'r1',
        center: const Offset(200, 300),
        radius: 60,
        strokeWidth: 20,
        color: Colors.orange,
        gapStartAngle: 0.0,
      );
      expect(GeometryMath.hitTestRing(const Offset(200, 420), [r]), isNull);
    });

    test('2.4: Hit test at dead center of ring fails (returns null)', () {
      var r = RingModel(
        id: 'r1',
        center: const Offset(200, 300),
        radius: 60,
        strokeWidth: 20,
        color: Colors.orange,
        gapStartAngle: 0.0,
      );
      expect(GeometryMath.hitTestRing(const Offset(200, 300), [r]), isNull);
    });

    test('2.5: Hit test with overlapping rings selects highest layer', () {
      var rLow = RingModel(
        id: 'low',
        center: const Offset(200, 300),
        radius: 60,
        strokeWidth: 30,
        color: Colors.blue,
        layer: 0,
        gapStartAngle: 0.0,
      );
      var rHigh = RingModel(
        id: 'high',
        center: const Offset(200, 300),
        radius: 60,
        strokeWidth: 30,
        color: Colors.red,
        layer: 5,
        gapStartAngle: 0.0,
      );
      expect(GeometryMath.hitTestRing(const Offset(200, 360), [rLow, rHigh])?.id, 'high');
    });

    test('2.6: Hit test ignores rings that are already freed', () {
      var r = RingModel(
        id: 'r_freed',
        center: const Offset(200, 300),
        radius: 60,
        strokeWidth: 20,
        color: Colors.green,
        gapStartAngle: 0.0,
        status: RingStatus.completed,
      );
      expect(GeometryMath.hitTestRing(const Offset(200, 360), [r]), isNull);
    });
  });

  group('Group 3: RingModel & JointModel Data Integrity', () {
    test('3.1: RingModel currentGapCenterAngle computes accurately', () {
      var r = RingModel(
        id: 'r',
        center: Offset.zero,
        radius: 50,
        color: Colors.black,
        gapStartAngle: 1.0,
        gapSweep: 0.8,
        currentAngle: 0.5,
      );
      // center is 0.5 + 1.0 + (0.8 / 2) = 1.9
      expect(r.currentGapCenterAngle, closeTo(1.9, 1e-4));
    });

    test('3.2: isAngleInGap returns true inside gap sweep and tolerance', () {
      var r = RingModel(
        id: 'r',
        center: Offset.zero,
        radius: 50,
        color: Colors.black,
        gapStartAngle: 0.0,
        gapSweep: 1.0,
        currentAngle: 0.0,
      );
      expect(r.isAngleInGap(0.5), isTrue); // Dead center
      expect(r.isAngleInGap(0.1), isTrue); // Inside
      expect(r.isAngleInGap(0.9), isTrue); // Inside
    });

    test('3.3: isAngleInGap returns false far from gap', () {
      var r = RingModel(
        id: 'r',
        center: Offset.zero,
        radius: 50,
        color: Colors.black,
        gapStartAngle: 0.0,
        gapSweep: 1.0,
        currentAngle: 0.0,
      );
      expect(r.isAngleInGap(math.pi), isFalse);
    });

    test('3.4: Closed ring has zero sweep and isAngleInGap is always false', () {
      var r = RingModel(
        id: 'closed',
        center: Offset.zero,
        radius: 50,
        color: Colors.black,
        shapeType: RingShapeType.closedRing,
        gapStartAngle: 0.0,
        gapSweep: 0.0,
      );
      expect(r.isAngleInGap(0.0), isFalse);
      expect(r.isAngleInGap(1.0), isFalse);
    });

    test('3.5: RingModel isFreed getter handles all statuses correctly', () {
      var r = RingModel(id: 'r', center: Offset.zero, radius: 50, color: Colors.blue, gapStartAngle: 0.0);
      r.status = RingStatus.movable;
      expect(r.isFreed, isFalse);
      r.status = RingStatus.locked;
      expect(r.isFreed, isFalse);
      r.status = RingStatus.unlocked;
      expect(r.isFreed, isTrue);
      r.status = RingStatus.released;
      expect(r.isFreed, isTrue);
      r.status = RingStatus.completed;
      expect(r.isFreed, isTrue);
    });

    test('3.6: RingModel clone creates independent deep copy', () {
      var r1 = RingModel(
        id: 'r1',
        center: const Offset(10, 20),
        radius: 50,
        color: Colors.red,
        gapStartAngle: 0.5,
        hasAcorn: true,
      );
      var r2 = r1.clone();
      r2.currentAngle = 1.5;
      expect(r1.currentAngle, 0.0);
      expect(r2.hasAcorn, isTrue);
      expect(r2.center, const Offset(10, 20));
    });

    test('3.7: JointModel isHoldingRing handles detached states', () {
      var j = JointModel(
        id: 'j',
        position: const Offset(50, 50),
        ringIdA: 'rA',
        ringIdB: 'rB',
        color: Colors.green,
        angleOnA: 0.0,
        angleOnB: math.pi,
      );
      expect(j.isHoldingRing('rA'), isTrue);
      expect(j.isHoldingRing('rB'), isTrue);

      j.detachedFromA = true;
      expect(j.isHoldingRing('rA'), isFalse);
      // When A is detached, sleeve no longer anchors B
      expect(j.isHoldingRing('rB'), isFalse);
    });

    test('3.8: JointModel isHoldingRing pin type is independent', () {
      var pin = JointModel(
        id: 'pin1',
        type: JointType.pin,
        position: const Offset(50, 50),
        ringIdA: 'rA',
        color: Colors.grey,
        angleOnA: 0.0,
      );
      expect(pin.isHoldingRing('rA'), isTrue);
      pin.detachedFromA = true;
      expect(pin.isHoldingRing('rA'), isFalse);
    });
  });

  group('Group 4: Untangle Engine & Cascade Mechanics', () {
    test('4.1: Cascade releases 2-ring chain upon single gap alignment', () {
      final lvl = LevelCatalog.getLevel(1);
      final r2 = lvl.rings[1];
      final j = lvl.joints.first;

      double angle = math.atan2(j.position.dy - r2.center.dy, j.position.dx - r2.center.dx);
      r2.currentAngle = GeometryMath.normalizeAngle(angle - r2.gapStartAngle - (r2.gapSweep / 2.0));

      final res = UntangleEngine.checkAndReleaseCascade(lvl, activeRing: r2);
      expect(res.freedRings.length, 2);
      expect(res.puzzleComplete, isTrue);
    });

    test('4.2: Acorn counter increments accurately when acorn ring frees', () {
      final lvl = LevelCatalog.getLevel(1);
      expect(lvl.rings[1].hasAcorn, isTrue);

      final r2 = lvl.rings[1];
      final j = lvl.joints.first;
      double angle = math.atan2(j.position.dy - r2.center.dy, j.position.dx - r2.center.dx);
      r2.currentAngle = GeometryMath.normalizeAngle(angle - r2.gapStartAngle - (r2.gapSweep / 2.0));

      final res = UntangleEngine.checkAndReleaseCascade(lvl);
      expect(res.acornsGained, 1);
    });

    test('4.3: smashRing immediately frees targeted ring and detaches joints', () {
      final lvl = LevelCatalog.getLevel(2);
      final target = lvl.rings.first;
      expect(target.isFreed, isFalse);

      final res = UntangleEngine.smashRing(lvl, target);
      expect(res.freedRings.contains(target), isTrue);
      expect(target.isFreed, isTrue);
    });

    test('4.4: smashRing on already freed ring is a safe no-op', () {
      final lvl = LevelCatalog.getLevel(1);
      final target = lvl.rings.first;
      target.status = RingStatus.completed;

      final res = UntangleEngine.smashRing(lvl, target);
      expect(res.freedRings.isEmpty, isTrue);
      expect(res.acornsGained, 0);
    });

    test('4.5: updateAnimations progresses releaseProgress and fades opacity', () {
      final lvl = LevelCatalog.getLevel(1);
      final r = lvl.rings.first;
      r.status = RingStatus.released;
      r.releaseProgress = 0.2;
      r.releaseOpacity = 0.8;

      UntangleEngine.updateAnimations(lvl, 0.1);
      expect(r.releaseProgress, greaterThan(0.2));
      expect(r.releaseOpacity, lessThan(0.8));
    });

    test('4.6: updateAnimations transitions to completed when progress >= 1.0', () {
      final lvl = LevelCatalog.getLevel(1);
      final r = lvl.rings.first;
      r.status = RingStatus.released;
      r.releaseProgress = 0.95;

      UntangleEngine.updateAnimations(lvl, 0.1);
      expect(r.status, RingStatus.completed);
      expect(r.releaseProgress, 1.0);
      expect(r.releaseOpacity, 0.0);
    });
  });

  group('Group 5: Puzzle Solver & Hint Recommendations', () {
    test('5.1: Solver finds hint for Level 65 (Nebula Reference)', () {
      final lvl = LevelCatalog.getLevel(65);
      final hint = PuzzleSolver.findNextMove(lvl);
      expect(hint, isNotNull);
      expect(hint!.ringId, isNotEmpty);
      expect(hint.message, isNotEmpty);
      expect(hint.targetAngle.isNaN, isFalse);
    });

    test('5.2: Solver finds hint for Level 85 (Flower)', () {
      final lvl = LevelCatalog.getLevel(85);
      final hint = PuzzleSolver.findNextMove(lvl);
      expect(hint, isNotNull);
      expect(hint!.ringId, isNotEmpty);
    });

    test('5.3: Solver finds hint for Level 46 (Robot)', () {
      final lvl = LevelCatalog.getLevel(46);
      final hint = PuzzleSolver.findNextMove(lvl);
      expect(hint, isNotNull);
    });

    test('5.4: Solver returns null when all rings are already freed', () {
      final lvl = LevelCatalog.getLevel(1);
      for (final r in lvl.rings) {
        r.status = RingStatus.completed;
      }
      final hint = PuzzleSolver.findNextMove(lvl);
      expect(hint, isNull);
    });
  });

  group('Group 6: SaveService & Game Session State', () {
    test('6.1: GameSessionState calculates 3 stars when moves <= targetMoves and isVictory is true', () {
      final lvl = LevelCatalog.getLevel(1);
      final session = GameSessionState(currentLevel: lvl, isVictory: true);
      session.moves = lvl.targetMoves;
      expect(session.calculateStars(), 3);
    });

    test('6.2: GameSessionState calculates 2 stars when moves <= 1.5 * targetMoves and isVictory is true', () {
      final lvl = LevelCatalog.getLevel(1);
      final session = GameSessionState(currentLevel: lvl, isVictory: true);
      // For level 1 targetMoves is 2: 3 moves is > 2 and <= (2 * 1.5).ceil() = 3
      session.moves = (lvl.targetMoves * 1.5).ceil();
      expect(session.calculateStars(), 2);
    });

    test('6.3: GameSessionState calculates 1 star for high move count and isVictory is true', () {
      final lvl = LevelCatalog.getLevel(1);
      final session = GameSessionState(currentLevel: lvl, isVictory: true);
      session.moves = lvl.targetMoves * 4;
      expect(session.calculateStars(), 1);
    });

    test('6.3b: GameSessionState calculates 0 stars when isVictory is false', () {
      final lvl = LevelCatalog.getLevel(1);
      final session = GameSessionState(currentLevel: lvl, isVictory: false);
      session.moves = 1;
      expect(session.calculateStars(), 0);
    });

    test('6.4: GameSessionState progress ratio tracks freed rings correctly', () {
      final lvl = LevelCatalog.getLevel(1);
      final session = GameSessionState(currentLevel: lvl);
      expect(session.progress, 0.0);

      lvl.rings.first.status = RingStatus.completed;
      expect(session.progress, 0.5);

      lvl.rings.last.status = RingStatus.completed;
      expect(session.progress, 1.0);
    });

    test('6.5: SoundService toggles persist and update soundEnabled', () {
      SoundService.instance.soundEnabled = true;
      expect(SoundService.instance.soundEnabled, isTrue);
      SoundService.instance.soundEnabled = false;
      expect(SoundService.instance.soundEnabled, isFalse);
      SoundService.instance.soundEnabled = true;
    });

    test('6.6: SoundService methods execute without throwing exceptions', () {
      expect(() => SoundService.instance.playTouch(), returnsNormally);
      expect(() => SoundService.instance.playTick(), returnsNormally);
      expect(() => SoundService.instance.playUnlock(), returnsNormally);
      expect(() => SoundService.instance.playVictory(), returnsNormally);
      expect(() => SoundService.instance.playAcornCollect(), returnsNormally);
    });
  });

  group('Group 7: Particle System & Visual Components', () {
    test('7.1: ParticleController spawns burst particles', () {
      final ctrl = ParticleController();
      expect(ctrl.particles.isEmpty, isTrue);
      ctrl.spawnRingBurst(const Offset(100, 100), Colors.amber, count: 20);
      expect(ctrl.particles.length, 20);
    });

    test('7.2: ParticleController update ages particles and removes expired ones', () {
      final ctrl = ParticleController();
      ctrl.spawnRingBurst(const Offset(100, 100), Colors.amber, count: 10);
      ctrl.update(0.1);
      expect(ctrl.particles.isNotEmpty, isTrue);

      // Force aging past maxLife
      ctrl.update(5.0);
      expect(ctrl.particles.isEmpty, isTrue);
    });

    test('7.3: ParticleController spawns confetti for victory', () {
      final ctrl = ParticleController();
      ctrl.spawnVictoryConfetti(const Size(400, 800), count: 50);
      expect(ctrl.particles.length, 50);
    });
  });

  group('Group 8: UI Widget Rendering Tests', () {
    testWidgets('8.1: GameScreen renders Level, Acorn Counter and Yellow Banner', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen(initialLevelNumber: 1)));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Level'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('XOAY ĐỂ'), findsOneWidget);
      expect(find.text('MỞ KHÓA'), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('8.2: Settings dialog opens upon tapping gear icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameScreen(initialLevelNumber: 1)));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Tùy Chọn'), findsOneWidget);
      expect(find.text('Âm Thanh ASMR'), findsOneWidget);
      expect(find.text('Nhạc Nền Thư Giãn'), findsOneWidget);
      expect(find.text('Chơi Lại'), findsOneWidget);
    });

    testWidgets('8.3: LevelSelectScreen renders tiers and grid', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LevelSelectScreen()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CHỌN MÀN CHƠI'), findsOneWidget);
      expect(find.text('1–20'), findsOneWidget);
      expect(find.text('21–40'), findsOneWidget);
    });

    testWidgets('8.4: VictoryDialog renders stars, acorns, and Next button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryDialog(
            levelNumber: 1,
            stars: 3,
            moves: 4,
            seconds: 15,
            acornsEarned: 18,
            onNextLevel: () {},
            onReplay: () {},
            onHome: () {},
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CHIẾN THẮNG!'), findsOneWidget);
      expect(find.text('+18'), findsOneWidget);
      expect(find.text('Tiếp Theo'), findsOneWidget);
    });

    testWidgets('8.5: SquirrelMascot renders without error', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SquirrelMascot(encouragement: "Great!")),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Great!'), findsOneWidget);
      expect(find.byType(SquirrelMascot), findsOneWidget);
    });

    testWidgets('8.6: AcornWidget renders without error', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: AcornWidget(size: 32)),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AcornWidget), findsOneWidget);
    });
  });
}

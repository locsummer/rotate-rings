import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import '../models/joint_model.dart';
import '../models/level_data.dart';
import '../ui/theme/game_colors.dart';

class LevelCatalog {
  static const int totalLevels = 200;
  static final Map<int, LevelData> _cachedLevels = {};

  /// Retrieves a level by its 1-based index (1 to 200)
  static LevelData getLevel(int levelNumber) {
    if (levelNumber < 1) levelNumber = 1;
    if (levelNumber > totalLevels) levelNumber = totalLevels;

    if (_cachedLevels.containsKey(levelNumber)) {
      return _cachedLevels[levelNumber]!.clone();
    }

    LevelData level = _generateLevel(levelNumber);
    for (final ring in level.rings) {
      _lockRingInitially(ring, level.joints);
    }
    _cachedLevels[levelNumber] = level;
    return level.clone();
  }

  /// Ensures every ring starts in a locked puzzle state (no joint starts inside a gap)
  static void _lockRingInitially(RingModel ring, List<JointModel> joints) {
    if (ring.gapSweep <= 0.001) return;
    final ringJoints = joints.where((j) => j.ringIdA == ring.id || j.ringIdB == ring.id).toList();
    if (ringJoints.isEmpty) return;

    // If current orientation is already safe, keep it
    bool isCurrentlySafe = !ringJoints.any((j) {
      double jAngle = math.atan2(j.position.dy - ring.center.dy, j.position.dx - ring.center.dx);
      return ring.isAngleInGap(jAngle, tolerance: 0.15);
    });
    if (isCurrentlySafe) return;

    for (double testAngle = 0.1; testAngle < 2 * math.pi; testAngle += 0.2) {
      ring.currentAngle = testAngle;
      bool anyJointInGap = ringJoints.any((j) {
        double jAngle = math.atan2(j.position.dy - ring.center.dy, j.position.dx - ring.center.dx);
        return ring.isAngleInGap(jAngle, tolerance: 0.15);
      });
      if (!anyJointInGap) return;
    }
  }

  static LevelData _generateLevel(int n) {
    if (n == 1) return _buildLevel1();
    if (n == 2) return _buildLevel2();
    if (n == 65) return _buildLevel65(); // Faithful reproduction of Shot 1
    if (n == 85) return _buildLevel85(); // Flower layout from Shot 2
    if (n == 46) return _buildLevel46(); // Robot layout from Shot 3
    if (n == 75) return _buildLevel75(); // Concentric rings from Shot 4
    if (n == 98) return _buildLevel98(); // Rocket ship from Shot 5
    if (n == 89) return _buildLevel89(); // Mandala square from Shot 6
    if (n == 36) return _buildLevel36(); // Double nested chain from Shot 7
    if (n == 42) return _buildLevel42(); // Totem layout from Shot 8

    // Progressive difficulty scaling: ring count scales from 2 up to 10
    int ringCount;
    if (n <= 5) {
      ringCount = 2;
    } else if (n <= 15) {
      ringCount = 3;
    } else if (n <= 35) {
      ringCount = 4;
    } else if (n <= 60) {
      ringCount = 5;
    } else if (n <= 90) {
      ringCount = 6;
    } else if (n <= 125) {
      ringCount = 7;
    } else if (n <= 160) {
      ringCount = 8;
    } else if (n <= 185) {
      ringCount = 9;
    } else {
      ringCount = 10;
    }

    // 7 rich archetypes rotate dynamically so every consecutive level feels completely distinct!
    int archetype = (n + (n ~/ 8)) % 7;
    switch (archetype) {
      case 0:
        return _buildVineTreeLevel(n, ringCount);
      case 1:
        return _buildFloralLevel(n, ringCount);
      case 2:
        return _buildPolygonLevel(n, ringCount);
      case 3:
        return _buildConcentricOrbitalLevel(n, ringCount);
      case 4:
        return _buildBranchingTreeLevel(n, ringCount);
      case 5:
        return _buildGridLatticeLevel(n, ringCount);
      case 6:
      default:
        return _buildGrandmasterHybridLevel(n, ringCount);
    }
  }

  // =========================================================================
  // TUTORIAL LANDMARK LEVELS 1 & 2
  // =========================================================================
  static LevelData _buildLevel1() {
    var r1 = RingModel(
      id: 'r1',
      center: const Offset(145, 300),
      radius: 64,
      strokeWidth: 24,
      color: GameColors.pastelSkyBlue,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.35,
      currentAngle: math.pi, // facing left away from joint
      hasAcorn: false,
    );
    var r2 = RingModel(
      id: 'r2',
      center: const Offset(255, 300),
      radius: 64,
      strokeWidth: 24,
      color: GameColors.pastelOrange,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.35,
      currentAngle: 0.0, // facing right away from joint
      hasAcorn: true,
    );
    var j1 = _createJoint('j1', r1, r2, GameColors.pastelSkyBlue);
    return LevelData(
      levelNumber: 1,
      title: "Khởi Đầu Thư Giãn",
      category: "Làm Quen Vòng Tròn",
      difficulty: 1,
      rings: [r1, r2],
      joints: [j1],
      targetMoves: 2,
      targetSeconds: 20,
    );
  }

  static LevelData _buildLevel2() {
    var r1 = RingModel(
      id: 'r1',
      center: const Offset(135, 230),
      radius: 56,
      strokeWidth: 22,
      color: GameColors.pastelOrange,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.30,
      currentAngle: -0.8,
      hasAcorn: false,
    );
    var r2 = RingModel(
      id: 'r2',
      center: const Offset(265, 230),
      radius: 56,
      strokeWidth: 22,
      color: GameColors.pastelSkyBlue,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.30,
      currentAngle: 1.2,
      hasAcorn: true,
    );
    var r3 = RingModel(
      id: 'r3',
      center: const Offset(200, 360),
      radius: 56,
      strokeWidth: 22,
      color: GameColors.pastelPurple,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.30,
      currentAngle: 0.0,
      hasAcorn: true,
    );
    return LevelData(
      levelNumber: 2,
      title: "Bộ Ba Nhập Cuộc",
      category: "Làm Quen Vòng Tròn",
      difficulty: 1,
      rings: [r1, r2, r3],
      joints: [
        _createJoint('j1_3', r1, r3, GameColors.pastelOrange),
        _createJoint('j2_3', r2, r3, GameColors.pastelSkyBlue),
      ],
      targetMoves: 4,
      targetSeconds: 30,
    );
  }

  // =========================================================================
  // PROCEDURAL LEVEL HELPERS & STYLING
  // =========================================================================
  static const List<Color> _palette = [
    GameColors.pastelOrange,
    GameColors.pastelSkyBlue,
    GameColors.pastelPurple,
    GameColors.pastelGreen,
    GameColors.pastelRed,
    GameColors.pastelRoyalBlue,
    GameColors.pastelForestGreen,
    GameColors.pastelYellow,
  ];

  static Color _getColor(int index, int shift) {
    return _palette[(index + shift).abs() % _palette.length];
  }

  static double _getRadius(int ringCount) {
    if (ringCount <= 2) return 62.0;
    if (ringCount == 3) return 56.0;
    if (ringCount == 4) return 52.0;
    if (ringCount <= 6) return 48.0;
    if (ringCount <= 8) return 42.0;
    return 38.0;
  }

  static double _getStrokeWidth(int ringCount) {
    if (ringCount <= 2) return 24.0;
    if (ringCount <= 4) return 22.0;
    if (ringCount <= 6) return 20.0;
    return 19.0;
  }

  static double _getGapSweep(int n) {
    return math.max(1.08, 1.34 - (n / 200.0) * 0.26);
  }

  static int _getDifficulty(int n) {
    if (n <= 15) return 1;
    if (n <= 50) return 2;
    if (n <= 100) return 3;
    if (n <= 160) return 4;
    return 5;
  }

  // =========================================================================
  // ARCHETYPE 0: SERPENTINE VINE / SNAKE CHAIN (Inspired by Level 65)
  // =========================================================================
  static LevelData _buildVineTreeLevel(int n, int count) {
    final rng = math.Random(n * 733 + 17);
    final rings = <RingModel>[];
    final joints = <JointModel>[];
    final radius = _getRadius(count);
    final stroke = _getStrokeWidth(count);
    final sweep = _getGapSweep(n);
    final colorShift = (n * 3) % _palette.length;

    const double cx = 195.0;
    if (count <= 2) {
      rings.add(RingModel(
        id: 'r1',
        center: const Offset(cx - 50, 300),
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(0, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: math.pi,
        hasAcorn: false,
      ));
      rings.add(RingModel(
        id: 'r2',
        center: const Offset(cx + 50, 300),
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(1, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: 0.0,
        hasAcorn: true,
      ));
      joints.add(_createJoint('j_1_2', rings[0], rings[1], rings[0].color));
    } else {
      const double startY = 175.0;
      const double endY = 465.0;
      final double stepY = (endY - startY) / (count - 1);
      final double swing = 44.0 + (n % 4) * 6.0;

      for (int i = 0; i < count; i++) {
        double phase = (i * 1.35) + (n * 0.4);
        double x = cx + swing * math.sin(phase);
        double y = startY + i * stepY;

        rings.add(RingModel(
          id: 'r${i + 1}',
          center: Offset(x, y),
          radius: radius,
          strokeWidth: stroke,
          color: _getColor(i, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i % 3 == 1),
        ));
      }

      for (int i = 0; i < count - 1; i++) {
        joints.add(_createJoint(
          'j_${rings[i].id}_${rings[i + 1].id}',
          rings[i],
          rings[i + 1],
          rings[i].color,
        ));
      }
    }

    return LevelData(
      levelNumber: n,
      title: "Dây Leo Uốn Lượn $n",
      category: "Cấu Trúc Dây Leo",
      difficulty: _getDifficulty(n),
      rings: rings,
      joints: joints,
      targetMoves: count * 2 + (n ~/ 25),
      targetSeconds: 25 + count * 6 + (n ~/ 10),
    );
  }

  // =========================================================================
  // ARCHETYPE 1: RADIAL FLOWER / STARBURST (Inspired by Level 85)
  // =========================================================================
  static LevelData _buildFloralLevel(int n, int count) {
    final rng = math.Random(n * 521 + 31);
    final rings = <RingModel>[];
    final joints = <JointModel>[];
    final radius = _getRadius(count);
    final stroke = _getStrokeWidth(count);
    final sweep = _getGapSweep(n);
    final colorShift = (n * 2) % _palette.length;
    const double cx = 195.0;
    const double cy = 285.0;

    if (count <= 2) {
      return _buildVineTreeLevel(n, count);
    }

    // Center flower core
    final centerRing = RingModel(
      id: 'r1',
      center: const Offset(cx, cy - 10),
      radius: radius * 0.9,
      strokeWidth: stroke,
      color: _getColor(0, colorShift),
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: sweep,
      currentAngle: rng.nextDouble() * 2 * math.pi,
      hasAcorn: true,
    );
    rings.add(centerRing);

    final int petalCount = count - 1;
    final double dist = radius * 1.82;
    final double angleOffset = (n * 0.3) - math.pi / 2;

    for (int i = 0; i < petalCount; i++) {
      Offset pos;
      if (count >= 6 && i == petalCount - 1) {
        pos = Offset(cx, cy + dist * 1.35);
      } else {
        double a = angleOffset + (i * 2 * math.pi / (count >= 6 ? petalCount - 1 : petalCount));
        pos = Offset(cx + dist * math.cos(a), (cy - 10) + dist * math.sin(a));
      }

      final petal = RingModel(
        id: 'r${i + 2}',
        center: pos,
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(i + 1, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i == 1 || i == 3),
      );
      rings.add(petal);

      joints.add(_createJoint(
        'j_${centerRing.id}_${petal.id}',
        centerRing,
        petal,
        petal.color,
      ));
    }

    if (rings.length >= 4) {
      joints.add(_createJoint(
        'j_${rings[1].id}_${rings[2].id}',
        rings[1],
        rings[2],
        rings[1].color,
      ));
    }

    return LevelData(
      levelNumber: n,
      title: "Đóa Hoa Kỳ Diệu $n",
      category: "Cấu Trúc Tự Nhiên",
      difficulty: _getDifficulty(n),
      rings: rings,
      joints: joints,
      targetMoves: count * 2 + (n ~/ 25),
      targetSeconds: 25 + count * 6 + (n ~/ 10),
    );
  }

  // =========================================================================
  // ARCHETYPE 2: GEOMETRIC POLYGON LOOP
  // =========================================================================
  static LevelData _buildPolygonLevel(int n, int count) {
    final rng = math.Random(n * 643 + 47);
    final rings = <RingModel>[];
    final joints = <JointModel>[];
    final radius = _getRadius(count);
    final stroke = _getStrokeWidth(count);
    final sweep = _getGapSweep(n);
    final colorShift = (n * 5) % _palette.length;
    const double cx = 195.0;
    const double cy = 300.0;

    if (count <= 2) {
      return _buildVineTreeLevel(n, count);
    }

    double polyRadius;
    if (count == 3) {
      polyRadius = 58.0;
    } else if (count == 4) {
      polyRadius = 72.0;
    } else if (count <= 6) {
      polyRadius = 88.0;
    } else if (count <= 8) {
      polyRadius = 102.0;
    } else {
      polyRadius = 112.0;
    }

    double startAngle = -math.pi / 2 + (n * 0.22);
    for (int i = 0; i < count; i++) {
      double a = startAngle + (i * 2 * math.pi / count);
      Offset pos = Offset(cx + polyRadius * math.cos(a), cy + (polyRadius * 0.94) * math.sin(a));

      rings.add(RingModel(
        id: 'r${i + 1}',
        center: pos,
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(i, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i % 2 == 0),
      ));
    }

    for (int i = 0; i < count; i++) {
      int next = (i + 1) % count;
      joints.add(_createJoint(
        'j_${rings[i].id}_${rings[next].id}',
        rings[i],
        rings[next],
        rings[i].color,
      ));
    }

    if (count >= 7) {
      int opposite = count ~/ 2;
      joints.add(_createJoint(
        'j_strut_${rings[0].id}_${rings[opposite].id}',
        rings[0],
        rings[opposite],
        rings[0].color,
      ));
    }

    return LevelData(
      levelNumber: n,
      title: "Đa Giác Khép Kín $n",
      category: "Khóa Hình Học",
      difficulty: _getDifficulty(n),
      rings: rings,
      joints: joints,
      targetMoves: count * 2 + (n ~/ 20),
      targetSeconds: 25 + count * 6 + (n ~/ 10),
    );
  }

  // =========================================================================
  // ARCHETYPE 3: CONCENTRIC & ORBITAL SATELLITES (Inspired by Level 75)
  // =========================================================================
  static LevelData _buildConcentricOrbitalLevel(int n, int count) {
    final rng = math.Random(n * 811 + 59);
    final rings = <RingModel>[];
    final joints = <JointModel>[];
    final sweep = _getGapSweep(n);
    final colorShift = (n * 4) % _palette.length;
    const double cx = 195.0;
    const double cy = 295.0;

    if (count <= 2) {
      var r1 = RingModel(
        id: 'r1',
        center: const Offset(cx, cy),
        radius: 44,
        strokeWidth: 22,
        color: _getColor(0, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: true,
      );
      var r2 = RingModel(
        id: 'r2',
        center: const Offset(cx, cy),
        radius: 86,
        strokeWidth: 22,
        color: _getColor(1, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: false,
      );
      rings.addAll([r1, r2]);
      joints.add(_createJoint(
        'j_c1_2',
        r1,
        r2,
        r1.color,
        customPosition: const Offset(cx, cy - 65),
      ));
    } else {
      final inner = RingModel(
        id: 'r1',
        center: const Offset(cx, cy),
        radius: 38,
        strokeWidth: 20,
        color: _getColor(0, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: true,
      );
      final outer = RingModel(
        id: 'r2',
        center: const Offset(cx, cy),
        radius: 78,
        strokeWidth: 20,
        color: _getColor(1, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: false,
      );
      rings.addAll([inner, outer]);

      joints.add(_createJoint(
        'j_core',
        inner,
        outer,
        inner.color,
        customPosition: const Offset(cx, cy - 58),
      ));

      int satellites = count - 2;
      double orbDist = 118.0;
      double rotStart = -math.pi / 2 + (n * 0.25);

      for (int i = 0; i < satellites; i++) {
        double a = rotStart + (i * 2 * math.pi / satellites);
        Offset pos = Offset(cx + orbDist * math.cos(a), cy + orbDist * math.sin(a));

        var sat = RingModel(
          id: 'r${i + 3}',
          center: pos,
          radius: 38,
          strokeWidth: 19,
          color: _getColor(i + 2, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i % 2 == 1),
        );
        rings.add(sat);

        joints.add(_createJoint(
          'j_orb_${outer.id}_${sat.id}',
          outer,
          sat,
          sat.color,
        ));
      }

      if (satellites >= 4) {
        joints.add(_createJoint(
          'j_sat_loop',
          rings[2],
          rings[3],
          rings[2].color,
        ));
      }
    }

    return LevelData(
      levelNumber: n,
      title: "Vòng Đồng Tâm Quỹ Đạo $n",
      category: "Cấu Trúc Ba Vòng",
      difficulty: _getDifficulty(n),
      rings: rings,
      joints: joints,
      targetMoves: count * 2 + (n ~/ 20),
      targetSeconds: 25 + count * 6 + (n ~/ 10),
    );
  }

  // =========================================================================
  // ARCHETYPE 4: BRANCHING TREE / FORK
  // =========================================================================
  static LevelData _buildBranchingTreeLevel(int n, int count) {
    final rng = math.Random(n * 907 + 73);
    final rings = <RingModel>[];
    final joints = <JointModel>[];
    final radius = _getRadius(count);
    final stroke = _getStrokeWidth(count);
    final sweep = _getGapSweep(n);
    final colorShift = (n * 6) % _palette.length;
    const double cx = 195.0;
    const double cy = 300.0;

    if (count <= 2) {
      return _buildVineTreeLevel(n, count);
    }

    final root = RingModel(
      id: 'r1',
      center: const Offset(cx, cy + 115),
      radius: radius,
      strokeWidth: stroke,
      color: _getColor(0, colorShift),
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: sweep,
      currentAngle: rng.nextDouble() * 2 * math.pi,
      hasAcorn: true,
    );
    rings.add(root);

    final mid = RingModel(
      id: 'r2',
      center: const Offset(cx, cy + 40),
      radius: radius,
      strokeWidth: stroke,
      color: _getColor(1, colorShift),
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: sweep,
      currentAngle: rng.nextDouble() * 2 * math.pi,
      hasAcorn: false,
    );
    rings.add(mid);
    joints.add(_createJoint('j_root_mid', root, mid, root.color));

    if (count == 3) {
      final top = RingModel(
        id: 'r3',
        center: const Offset(cx, cy - 35),
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(2, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: true,
      );
      rings.add(top);
      joints.add(_createJoint('j_mid_top', mid, top, mid.color));
    } else {
      final leftBranch = RingModel(
        id: 'r3',
        center: const Offset(cx - 58, cy - 25),
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(2, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: false,
      );
      final rightBranch = RingModel(
        id: 'r4',
        center: const Offset(cx + 58, cy - 25),
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(3, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: true,
      );
      rings.addAll([leftBranch, rightBranch]);
      joints.add(_createJoint('j_mid_left', mid, leftBranch, leftBranch.color));
      joints.add(_createJoint('j_mid_right', mid, rightBranch, rightBranch.color));

      int leaves = count - 4;
      if (leaves > 0) {
        double span = 145.0;
        for (int k = 0; k < leaves; k++) {
          double x = cx - (span / 2) + k * (span / (leaves > 1 ? leaves - 1 : 1));
          double y = cy - 95 - (k % 2 == 1 ? 12 : 0);

          final leaf = RingModel(
            id: 'r${k + 5}',
            center: Offset(x, y),
            radius: radius,
            strokeWidth: stroke,
            color: _getColor(k + 4, colorShift),
            shapeType: RingShapeType.cLock,
            gapStartAngle: 0.0,
            gapSweep: sweep,
            currentAngle: rng.nextDouble() * 2 * math.pi,
            hasAcorn: (k % 2 == 0),
          );
          rings.add(leaf);

          var parent = (x <= cx) ? leftBranch : rightBranch;
          joints.add(_createJoint('j_leaf_${k + 1}', parent, leaf, leaf.color));
        }
      }
    }

    return LevelData(
      levelNumber: n,
      title: "Nhánh Cây Tri Thức $n",
      category: "Cấu Trúc Cây Khóa",
      difficulty: _getDifficulty(n),
      rings: rings,
      joints: joints,
      targetMoves: count * 2 + (n ~/ 25),
      targetSeconds: 25 + count * 6 + (n ~/ 10),
    );
  }

  // =========================================================================
  // ARCHETYPE 5: GRID / MATRIX LATTICE
  // =========================================================================
  static LevelData _buildGridLatticeLevel(int n, int count) {
    final rng = math.Random(n * 977 + 89);
    final rings = <RingModel>[];
    final joints = <JointModel>[];
    final radius = _getRadius(count);
    final stroke = _getStrokeWidth(count);
    final sweep = _getGapSweep(n);
    final colorShift = (n * 7) % _palette.length;
    const double cx = 195.0;
    const double cy = 300.0;

    if (count <= 3) {
      return _buildPolygonLevel(n, count);
    }

    if (count == 4) {
      List<Offset> positions = [
        const Offset(cx - 48, cy - 48),
        const Offset(cx + 48, cy - 48),
        const Offset(cx - 48, cy + 48),
        const Offset(cx + 48, cy + 48),
      ];
      for (int i = 0; i < 4; i++) {
        rings.add(RingModel(
          id: 'r${i + 1}',
          center: positions[i],
          radius: radius,
          strokeWidth: stroke,
          color: _getColor(i, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i == 0 || i == 3),
        ));
      }
      joints.add(_createJoint('j1_2', rings[0], rings[1], rings[0].color));
      joints.add(_createJoint('j3_4', rings[2], rings[3], rings[2].color));
      joints.add(_createJoint('j1_3', rings[0], rings[2], rings[0].color));
      joints.add(_createJoint('j2_4', rings[1], rings[3], rings[1].color));
    } else if (count == 5) {
      List<Offset> positions = [
        const Offset(cx, cy),
        const Offset(cx, cy - 74),
        const Offset(cx, cy + 74),
        const Offset(cx - 74, cy),
        const Offset(cx + 74, cy),
      ];
      for (int i = 0; i < 5; i++) {
        rings.add(RingModel(
          id: 'r${i + 1}',
          center: positions[i],
          radius: radius,
          strokeWidth: stroke,
          color: _getColor(i, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i == 0 || i == 2),
        ));
      }
      joints.add(_createJoint('j_c_top', rings[0], rings[1], rings[1].color));
      joints.add(_createJoint('j_c_bot', rings[0], rings[2], rings[2].color));
      joints.add(_createJoint('j_c_left', rings[0], rings[3], rings[3].color));
      joints.add(_createJoint('j_c_right', rings[0], rings[4], rings[4].color));
    } else if (count == 6) {
      List<Offset> positions = [];
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 2; col++) {
          positions.add(Offset(cx - 48 + col * 96, cy - 82 + row * 82));
        }
      }
      for (int i = 0; i < 6; i++) {
        rings.add(RingModel(
          id: 'r${i + 1}',
          center: positions[i],
          radius: radius,
          strokeWidth: stroke,
          color: _getColor(i, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i % 2 == 1),
        ));
      }
      joints.add(_createJoint('jh_0_1', rings[0], rings[1], rings[0].color));
      joints.add(_createJoint('jh_2_3', rings[2], rings[3], rings[2].color));
      joints.add(_createJoint('jh_4_5', rings[4], rings[5], rings[4].color));
      joints.add(_createJoint('jv_0_2', rings[0], rings[2], rings[0].color));
      joints.add(_createJoint('jv_1_3', rings[1], rings[3], rings[1].color));
      joints.add(_createJoint('jv_2_4', rings[2], rings[4], rings[2].color));
      joints.add(_createJoint('jv_3_5', rings[3], rings[5], rings[3].color));
    } else {
      List<Offset> grid = [];
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          grid.add(Offset(cx - 68 + c * 68, cy - 68 + r * 68));
        }
      }
      if (count == 10) {
        grid.add(const Offset(cx, cy - 128));
      }
      for (int i = 0; i < count; i++) {
        rings.add(RingModel(
          id: 'r${i + 1}',
          center: grid[i],
          radius: radius,
          strokeWidth: stroke,
          color: _getColor(i, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i % 3 == 0),
        ));
      }
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          int idx = r * 3 + c;
          if (idx >= count) break;
          if (c < 2 && (idx + 1) < count) {
            joints.add(_createJoint('j_h_${idx}_${idx + 1}', rings[idx], rings[idx + 1], rings[idx].color));
          }
          if (r < 2 && (idx + 3) < count) {
            joints.add(_createJoint('j_v_${idx}_${idx + 3}', rings[idx], rings[idx + 3], rings[idx].color));
          }
        }
      }
      if (count == 10) {
        joints.add(_createJoint('j_crown', rings[9], rings[1], rings[9].color));
      }
    }

    return LevelData(
      levelNumber: n,
      title: "Mạng Lưới Ma Trận $n",
      category: "Khóa Lưới Đa Chiều",
      difficulty: _getDifficulty(n),
      rings: rings,
      joints: joints,
      targetMoves: count * 2 + (n ~/ 20),
      targetSeconds: 25 + count * 6 + (n ~/ 10),
    );
  }

  // =========================================================================
  // ARCHETYPE 6: GRANDMASTER HYBRID (Sculptures, Totems, Wings)
  // =========================================================================
  static LevelData _buildGrandmasterHybridLevel(int n, int count) {
    final rng = math.Random(n * 1033 + 97);
    final rings = <RingModel>[];
    final joints = <JointModel>[];
    final radius = _getRadius(count);
    final stroke = _getStrokeWidth(count);
    final sweep = _getGapSweep(n);
    final colorShift = (n * 3) % _palette.length;
    const double cx = 195.0;
    const double cy = 295.0;

    int theme = n % 3;
    if (theme == 0) {
      final centerCore = RingModel(
        id: 'r1',
        center: const Offset(cx, cy),
        radius: radius,
        strokeWidth: stroke,
        color: _getColor(0, colorShift),
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: sweep,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: true,
      );
      rings.add(centerCore);

      List<Offset> wingOffsets = [
        const Offset(cx - 68, cy - 55),
        const Offset(cx + 68, cy - 55),
        const Offset(cx - 68, cy + 55),
        const Offset(cx + 68, cy + 55),
        const Offset(cx, cy - 95),
        const Offset(cx, cy + 95),
        const Offset(cx - 110, cy),
        const Offset(cx + 110, cy),
        const Offset(cx, cy - 145),
      ];

      for (int i = 0; i < count - 1; i++) {
        var wing = RingModel(
          id: 'r${i + 2}',
          center: wingOffsets[i % wingOffsets.length],
          radius: radius * (i >= 4 ? 0.9 : 1.0),
          strokeWidth: stroke,
          color: _getColor(i + 1, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i % 2 == 1),
        );
        rings.add(wing);

        if (i < 4) {
          joints.add(_createJoint('j_core_${wing.id}', centerCore, wing, wing.color));
        } else if (i == 4) {
          joints.add(_createJoint('j_head', rings[1], wing, wing.color));
        } else if (i == 5) {
          joints.add(_createJoint('j_tail', rings[3], wing, wing.color));
        } else if (i == 6) {
          joints.add(_createJoint('j_ltip', rings[1], wing, wing.color));
        } else if (i == 7) {
          joints.add(_createJoint('j_rtip', rings[2], wing, wing.color));
        } else {
          joints.add(_createJoint('j_ant', rings[5], wing, wing.color));
        }
      }
    } else if (theme == 1) {
      List<Offset> rocketPositions = [
        const Offset(cx, cy - 115),
        const Offset(cx, cy - 45),
        const Offset(cx, cy + 25),
        const Offset(cx - 65, cy + 25),
        const Offset(cx + 65, cy + 25),
        const Offset(cx - 65, cy + 95),
        const Offset(cx + 65, cy + 95),
        const Offset(cx, cy + 95),
        const Offset(cx - 105, cy + 70),
        const Offset(cx + 105, cy + 70),
      ];

      for (int i = 0; i < count; i++) {
        rings.add(RingModel(
          id: 'r${i + 1}',
          center: rocketPositions[i % rocketPositions.length],
          radius: radius,
          strokeWidth: stroke,
          color: _getColor(i, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i == 0 || i == 2),
        ));
      }

      joints.add(_createJoint('j_spine1', rings[0], rings[1], rings[0].color));
      if (count > 2) joints.add(_createJoint('j_spine2', rings[1], rings[2], rings[1].color));
      if (count > 3) joints.add(_createJoint('j_boost_l', rings[2], rings[3], rings[3].color));
      if (count > 4) joints.add(_createJoint('j_boost_r', rings[2], rings[4], rings[4].color));
      if (count > 5) joints.add(_createJoint('j_fin_l', rings[3], rings[5], rings[5].color));
      if (count > 6) joints.add(_createJoint('j_fin_r', rings[4], rings[6], rings[6].color));
      if (count > 7) joints.add(_createJoint('j_engine', rings[2], rings[7], rings[7].color));
      if (count > 8) joints.add(_createJoint('j_out_l', rings[3], rings[8], rings[8].color));
      if (count > 9) joints.add(_createJoint('j_out_r', rings[4], rings[9], rings[9].color));
    } else {
      List<Offset> totemPositions = [
        const Offset(cx, cy - 90),
        const Offset(cx - 60, cy - 35),
        const Offset(cx + 60, cy - 35),
        const Offset(cx, cy + 20),
        const Offset(cx - 60, cy + 75),
        const Offset(cx + 60, cy + 75),
        const Offset(cx, cy + 130),
        const Offset(cx - 105, cy + 20),
        const Offset(cx + 105, cy + 20),
        const Offset(cx, cy - 145),
      ];

      for (int i = 0; i < count; i++) {
        rings.add(RingModel(
          id: 'r${i + 1}',
          center: totemPositions[i % totemPositions.length],
          radius: radius,
          strokeWidth: stroke,
          color: _getColor(i, colorShift),
          shapeType: RingShapeType.cLock,
          gapStartAngle: 0.0,
          gapSweep: sweep,
          currentAngle: rng.nextDouble() * 2 * math.pi,
          hasAcorn: (i % 2 == 0),
        ));
      }

      for (int i = 0; i < count - 1; i++) {
        joints.add(_createJoint(
          'j_totem_${i + 1}_${i + 2}',
          rings[i],
          rings[i + 1],
          rings[i].color,
        ));
      }
      if (count >= 5) {
        joints.add(_createJoint('j_totem_cross', rings[1], rings[3], rings[1].color));
      }
    }

    return LevelData(
      levelNumber: n,
      title: "Tuyệt Phẩm Cơ Khí $n",
      category: "Cấu Trúc Tinh Xảo",
      difficulty: _getDifficulty(n),
      rings: rings,
      joints: joints,
      targetMoves: count * 2 + (n ~/ 20),
      targetSeconds: 25 + count * 6 + (n ~/ 10),
    );
  }

  // =========================================================================
  // LEVEL 65: EXACT REPLICA OF THE GAME SAMPLE SCREENSHOT (Shot 1)
  // 7 interlocking C-rings arranged in a vertical branching structure
  // 3 Golden Acorns inside Orange, Purple, and Light Green
  // =========================================================================
  static LevelData _buildLevel65() {
    List<RingModel> rings = [
      // 1. Orange top-left ring (with acorn)
      RingModel(
        id: 'r1',
        center: const Offset(155, 140),
        radius: 52,
        strokeWidth: 24,
        color: GameColors.pastelOrange,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: -0.7, // Facing somewhat up-left
        hasAcorn: true,
      ),
      // 2. Light blue upper-middle ring
      RingModel(
        id: 'r2',
        center: const Offset(235, 205),
        radius: 52,
        strokeWidth: 24,
        color: GameColors.pastelSkyBlue,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: 1.3,
        hasAcorn: false,
      ),
      // 3. Purple middle ring (with acorn)
      RingModel(
        id: 'r3',
        center: const Offset(170, 295),
        radius: 52,
        strokeWidth: 24,
        color: GameColors.pastelPurple,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: -0.6,
        hasAcorn: true,
      ),
      // 4. Red left branch ring
      RingModel(
        id: 'r4',
        center: const Offset(105, 380),
        radius: 52,
        strokeWidth: 24,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: -2.3,
        hasAcorn: false,
      ),
      // 5. Dark green right branch ring
      RingModel(
        id: 'r5',
        center: const Offset(270, 325),
        radius: 52,
        strokeWidth: 24,
        color: GameColors.pastelForestGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: 2.1,
        hasAcorn: false,
      ),
      // 6. Light green lower-center ring (with acorn)
      RingModel(
        id: 'r6',
        center: const Offset(195, 415),
        radius: 52,
        strokeWidth: 24,
        color: GameColors.pastelGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: 0.5,
        hasAcorn: true,
      ),
      // 7. Royal blue bottom ring
      RingModel(
        id: 'r7',
        center: const Offset(155, 505),
        radius: 52,
        strokeWidth: 24,
        color: GameColors.pastelRoyalBlue,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: 0.0,
        hasAcorn: false,
      ),
    ];

    List<JointModel> joints = [
      // Joint between Orange (r1) and Blue (r2)
      _createJoint('j1_2', rings[0], rings[1], GameColors.pastelSkyBlue),
      // Joint between Blue (r2) and Purple (r3)
      _createJoint('j2_3', rings[1], rings[2], GameColors.pastelPurple),
      // Joint between Purple (r3) and Red (r4)
      _createJoint('j3_4', rings[2], rings[3], GameColors.pastelRed),
      // Joint between Purple (r3) and Light Green (r6)
      _createJoint('j3_6', rings[2], rings[5], GameColors.pastelPurple),
      // Joint between Light Green (r6) and Dark Green (r5)
      _createJoint('j6_5', rings[5], rings[4], GameColors.pastelGreen),
      // Joint between Light Green (r6) and Bottom Blue (r7)
      _createJoint('j6_7', rings[5], rings[6], GameColors.pastelGreen),
    ];

    return LevelData(
      levelNumber: 65,
      title: "Mắt Xích Kỳ Diệu 65",
      category: "Nebula Classic",
      difficulty: 4,
      rings: rings,
      joints: joints,
      targetMoves: 14,
      targetSeconds: 60,
    );
  }

  // =========================================================================
  // LEVEL 85: FLOWER STRUCTURE (Shot 2)
  // Center ring with stem and radiating petal arcs
  // =========================================================================
  static LevelData _buildLevel85() {
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    // Center circular flower core
    var centerRing = RingModel(
      id: 'flower_center',
      center: const Offset(200, 240),
      radius: 36,
      strokeWidth: 20,
      color: GameColors.pastelSkyBlue,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.30,
      currentAngle: 0.0,
      hasAcorn: true,
    );
    rings.add(centerRing);

    // 4 Petal arcs
    List<Offset> petalOffsets = [
      const Offset(200, 130), // Top
      const Offset(280, 240), // Right
      const Offset(120, 240), // Left
      const Offset(130, 330), // Lower Left
    ];
    List<Color> petalColors = [
      GameColors.pastelRed,
      GameColors.pastelOrange,
      GameColors.pastelGreen,
      GameColors.pastelPurple,
    ];

    for (int i = 0; i < 4; i++) {
      var p = RingModel(
        id: 'petal_$i',
        center: petalOffsets[i],
        radius: 46,
        strokeWidth: 20,
        color: petalColors[i],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.35,
        currentAngle: (i * 1.2),
        hasAcorn: (i == 1),
      );
      rings.add(p);
      joints.add(_createJoint('j_flower_$i', centerRing, p, petalColors[i], isSilver: true));
    }

    // Stem ring
    var stem = RingModel(
      id: 'stem',
      center: const Offset(230, 390),
      radius: 65,
      strokeWidth: 20,
      color: GameColors.pastelGreen,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.40,
      currentAngle: -1.0,
      hasAcorn: true,
    );
    rings.add(stem);
    joints.add(_createJoint('j_stem', centerRing, stem, GameColors.pastelGreen));

    return LevelData(
      levelNumber: 85,
      title: "Đóa Hoa Kỳ Diệu 85",
      category: "Cấu Trúc Tự Nhiên",
      difficulty: 4,
      rings: rings,
      joints: joints,
      targetMoves: 10,
      targetSeconds: 50,
    );
  }

  // =========================================================================
  // LEVEL 46: ROBOT FACE (Shot 3)
  // Antennas, eye rings, mouth bar, body frame
  // =========================================================================
  static LevelData _buildLevel46() {
    List<RingModel> rings = [
      // Left eye with acorn
      RingModel(
        id: 'eye_left',
        center: const Offset(150, 220),
        radius: 38,
        strokeWidth: 22,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -0.5,
        hasAcorn: true,
      ),
      // Right eye with acorn
      RingModel(
        id: 'eye_right',
        center: const Offset(250, 220),
        radius: 38,
        strokeWidth: 22,
        color: GameColors.pastelGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 1.2,
        hasAcorn: true,
      ),
      // Left antenna
      RingModel(
        id: 'ant_left',
        center: const Offset(110, 110),
        radius: 36,
        strokeWidth: 20,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.8,
        hasAcorn: false,
      ),
      // Right antenna
      RingModel(
        id: 'ant_right',
        center: const Offset(290, 110),
        radius: 36,
        strokeWidth: 20,
        color: GameColors.pastelForestGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -1.2,
        hasAcorn: false,
      ),
      // Neck lollipop ring
      RingModel(
        id: 'neck',
        center: const Offset(200, 310),
        radius: 36,
        strokeWidth: 20,
        color: GameColors.pastelSkyBlue,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.0,
        hasAcorn: false,
      ),
      // Belly ring with acorn
      RingModel(
        id: 'belly',
        center: const Offset(160, 400),
        radius: 40,
        strokeWidth: 22,
        color: GameColors.pastelOrange,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 1.5,
        hasAcorn: true,
      ),
    ];

    List<JointModel> joints = [
      _createJoint('j_ant_eye_l', rings[2], rings[0], GameColors.pastelRed, isSilver: true),
      _createJoint('j_ant_eye_r', rings[3], rings[1], GameColors.pastelForestGreen, isSilver: true),
      _createJoint('j_eyes', rings[0], rings[1], GameColors.pastelSkyBlue),
      _createJoint('j_eye_neck', rings[0], rings[4], GameColors.pastelSkyBlue, isSilver: true),
      _createJoint('j_neck_belly', rings[4], rings[5], GameColors.pastelOrange),
    ];

    return LevelData(
      levelNumber: 46,
      title: "Người Máy Thông Minh 46",
      category: "Hình Học Độc Đáo",
      difficulty: 3,
      rings: rings,
      joints: joints,
      targetMoves: 12,
      targetSeconds: 50,
    );
  }

  // =========================================================================
  // LEVEL 75: CONCENTRIC RINGS (Shot 4)
  // Outer red, middle purple, inner orange, core blue
  // =========================================================================
  static LevelData _buildLevel75() {
    Offset center = const Offset(200, 190);
    List<RingModel> rings = [
      // Core blue (with acorn)
      RingModel(
        id: 'core_blue',
        center: center,
        radius: 42,
        strokeWidth: 20,
        color: GameColors.pastelSkyBlue,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -0.8,
        hasAcorn: true,
        layer: 3,
      ),
      // Inner orange
      RingModel(
        id: 'mid_orange',
        center: center,
        radius: 72,
        strokeWidth: 20,
        color: GameColors.pastelOrange,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: 1.4,
        hasAcorn: false,
        layer: 2,
      ),
      // Middle purple
      RingModel(
        id: 'mid_purple',
        center: center,
        radius: 104,
        strokeWidth: 20,
        color: GameColors.pastelPurple,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.20,
        currentAngle: 0.5,
        hasAcorn: false,
        layer: 1,
      ),
      // Outer red
      RingModel(
        id: 'outer_red',
        center: center,
        radius: 136,
        strokeWidth: 20,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.15,
        currentAngle: -1.2,
        hasAcorn: false,
        layer: 0,
      ),
      // Hanging lower ring with acorn
      RingModel(
        id: 'lower_hub',
        center: const Offset(200, 390),
        radius: 48,
        strokeWidth: 22,
        color: GameColors.pastelOrange,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.0,
        hasAcorn: true,
      ),
    ];

    List<JointModel> joints = [
      _createJoint('j_blue_orange', rings[0], rings[1], GameColors.pastelOrange),
      _createJoint('j_orange_purple', rings[1], rings[2], GameColors.pastelPurple),
      _createJoint('j_purple_red', rings[2], rings[3], GameColors.pastelRed),
      _createJoint('j_red_hub', rings[3], rings[4], GameColors.pastelOrange, isSilver: true),
    ];

    return LevelData(
      levelNumber: 75,
      title: "Vòng Đồng Tâm 75",
      category: "Nhiều Tầng Sâu",
      difficulty: 4,
      rings: rings,
      joints: joints,
      targetMoves: 10,
      targetSeconds: 55,
    );
  }

  // =========================================================================
  // LEVEL 98: ROCKET SHIP (Shot 5)
  // Nose cone, fuselage rings, fins, thrusters
  // =========================================================================
  static LevelData _buildLevel98() {
    List<RingModel> rings = [
      // Fuselage central ring (with acorn)
      RingModel(
        id: 'cabin',
        center: const Offset(200, 240),
        radius: 50,
        strokeWidth: 22,
        color: GameColors.pastelOrange,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: 0.0,
        hasAcorn: true,
      ),
      // Nose cone left
      RingModel(
        id: 'nose_l',
        center: const Offset(155, 140),
        radius: 65,
        strokeWidth: 20,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -0.7,
        hasAcorn: false,
      ),
      // Nose cone right
      RingModel(
        id: 'nose_r',
        center: const Offset(245, 140),
        radius: 65,
        strokeWidth: 20,
        color: GameColors.pastelGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.7,
        hasAcorn: false,
      ),
      // Left wing fin
      RingModel(
        id: 'fin_l',
        center: const Offset(90, 290),
        radius: 44,
        strokeWidth: 20,
        color: GameColors.pastelPurple,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 1.4,
        hasAcorn: false,
      ),
      // Right wing fin
      RingModel(
        id: 'fin_r',
        center: const Offset(310, 290),
        radius: 44,
        strokeWidth: 20,
        color: GameColors.pastelForestGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -1.4,
        hasAcorn: false,
      ),
      // Thruster ring (with acorn)
      RingModel(
        id: 'engine',
        center: const Offset(200, 360),
        radius: 42,
        strokeWidth: 20,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: math.pi,
        hasAcorn: true,
      ),
    ];

    List<JointModel> joints = [
      _createJoint('j_nose_tip', rings[1], rings[2], GameColors.pastelRed, isSilver: true),
      _createJoint('j_cabin_nose_l', rings[0], rings[1], GameColors.pastelOrange),
      _createJoint('j_cabin_nose_r', rings[0], rings[2], GameColors.pastelOrange),
      _createJoint('j_cabin_fin_l', rings[0], rings[3], GameColors.pastelPurple, isSilver: true),
      _createJoint('j_cabin_fin_r', rings[0], rings[4], GameColors.pastelForestGreen, isSilver: true),
      _createJoint('j_cabin_engine', rings[0], rings[5], GameColors.pastelRed),
    ];

    return LevelData(
      levelNumber: 98,
      title: "Tàu Vũ Trụ Vươn Xa 98",
      category: "Cấu Trúc Tàu Không Gian",
      difficulty: 4,
      rings: rings,
      joints: joints,
      targetMoves: 12,
      targetSeconds: 60,
    );
  }

  // =========================================================================
  // LEVEL 89: MANDALA SQUARE (Shot 6)
  // Center glowing ring with 4 symmetric petals and outer frame
  // =========================================================================
  static LevelData _buildLevel89() {
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    // Center core
    var centerRing = RingModel(
      id: 'center_core',
      center: const Offset(200, 300),
      radius: 42,
      strokeWidth: 22,
      color: GameColors.pastelSkyBlue,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.25,
      currentAngle: 0.0,
      hasAcorn: false,
    );
    rings.add(centerRing);

    List<Offset> dirOffsets = [
      const Offset(200, 205), // Top
      const Offset(295, 300), // Right
      const Offset(200, 395), // Bottom
      const Offset(105, 300), // Left
    ];
    List<Color> ringColors = [
      GameColors.pastelGreen,
      GameColors.pastelOrange,
      GameColors.pastelRed,
      GameColors.pastelPurple,
    ];

    for (int i = 0; i < 4; i++) {
      var r = RingModel(
        id: 'cross_$i',
        center: dirOffsets[i],
        radius: 42,
        strokeWidth: 20,
        color: ringColors[i],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: (i * math.pi / 2) + 0.6,
        hasAcorn: (i % 2 == 1),
      );
      rings.add(r);
      joints.add(_createJoint('j_c_$i', centerRing, r, ringColors[i]));
    }

    return LevelData(
      levelNumber: 89,
      title: "Mạn-đà-la Đối Xứng 89",
      category: "Hình Học Kỳ Ảo",
      difficulty: 4,
      rings: rings,
      joints: joints,
      targetMoves: 10,
      targetSeconds: 50,
    );
  }

  // =========================================================================
  // LEVEL 36: DOUBLE NESTED CHAIN (Shot 7)
  // =========================================================================
  static LevelData _buildLevel36() {
    List<RingModel> rings = [
      RingModel(
        id: 'r1',
        center: const Offset(120, 180),
        radius: 46,
        strokeWidth: 22,
        color: GameColors.pastelPurple,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -0.8,
        hasAcorn: false,
      ),
      RingModel(
        id: 'r2',
        center: const Offset(240, 180),
        radius: 46,
        strokeWidth: 22,
        color: GameColors.pastelSkyBlue,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 1.2,
        hasAcorn: false,
      ),
      RingModel(
        id: 'r3',
        center: const Offset(180, 290),
        radius: 48,
        strokeWidth: 22,
        color: GameColors.pastelOrange,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.3,
        hasAcorn: true,
      ),
      RingModel(
        id: 'r4',
        center: const Offset(260, 360),
        radius: 46,
        strokeWidth: 22,
        color: GameColors.pastelGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -1.5,
        hasAcorn: true,
      ),
      RingModel(
        id: 'r5',
        center: const Offset(130, 420),
        radius: 46,
        strokeWidth: 22,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.8,
        hasAcorn: true,
      ),
    ];

    List<JointModel> joints = [
      _createJoint('j1_2', rings[0], rings[1], GameColors.pastelPurple),
      _createJoint('j1_3', rings[0], rings[2], GameColors.pastelOrange),
      _createJoint('j2_3', rings[1], rings[2], GameColors.pastelSkyBlue),
      _createJoint('j3_4', rings[2], rings[3], GameColors.pastelGreen),
      _createJoint('j3_5', rings[2], rings[4], GameColors.pastelRed),
    ];

    return LevelData(
      levelNumber: 36,
      title: "Xích Đan Kép 36",
      category: "Mắt Xích Đan Xen",
      difficulty: 3,
      rings: rings,
      joints: joints,
      targetMoves: 10,
      targetSeconds: 45,
    );
  }

  // =========================================================================
  // LEVEL 42: TOTEM FACE (Shot 8)
  // =========================================================================
  static LevelData _buildLevel42() {
    List<RingModel> rings = [
      RingModel(
        id: 'top_crown',
        center: const Offset(150, 130),
        radius: 42,
        strokeWidth: 22,
        color: GameColors.pastelForestGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.0,
        hasAcorn: false,
      ),
      RingModel(
        id: 'eye_left',
        center: const Offset(150, 220),
        radius: 44,
        strokeWidth: 22,
        color: GameColors.pastelGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.8,
        hasAcorn: true,
      ),
      RingModel(
        id: 'ear_right',
        center: const Offset(270, 240),
        radius: 44,
        strokeWidth: 22,
        color: GameColors.pastelRed,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: -0.8,
        hasAcorn: false,
      ),
      RingModel(
        id: 'mouth_arch',
        center: const Offset(200, 340),
        radius: 50,
        strokeWidth: 22,
        color: GameColors.pastelSkyBlue,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.0,
        hasAcorn: true,
      ),
      RingModel(
        id: 'chin',
        center: const Offset(200, 440),
        radius: 42,
        strokeWidth: 22,
        color: GameColors.pastelGreen,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: 0.0,
        hasAcorn: false,
      ),
    ];

    List<JointModel> joints = [
      _createJoint('j_crown_eye', rings[0], rings[1], GameColors.pastelForestGreen),
      _createJoint('j_eye_mouth', rings[1], rings[3], GameColors.pastelGreen),
      _createJoint('j_ear_mouth', rings[2], rings[3], GameColors.pastelRed),
      _createJoint('j_mouth_chin', rings[3], rings[4], GameColors.pastelGreen, isSilver: true),
    ];

    return LevelData(
      levelNumber: 42,
      title: "Mặt Nạ Totem 42",
      category: "Hình Học Độc Đáo",
      difficulty: 3,
      rings: rings,
      joints: joints,
      targetMoves: 8,
      targetSeconds: 45,
    );
  }



  static JointModel _createJoint(
    String id,
    RingModel rA,
    RingModel rB,
    Color color, {
    bool isSilver = false,
    Offset? customPosition,
  }) {
    Offset pos = customPosition ??
        Offset((rA.center.dx + rB.center.dx) / 2, (rA.center.dy + rB.center.dy) / 2);
    double aOnA = math.atan2(pos.dy - rA.center.dy, pos.dx - rA.center.dx);
    double aOnB = math.atan2(pos.dy - rB.center.dy, pos.dx - rB.center.dx);
    return JointModel(
      id: id,
      type: JointType.sleeve,
      position: pos,
      ringIdA: rA.id,
      ringIdB: rB.id,
      color: color,
      isSilver: isSilver,
      angleOnA: aOnA,
      angleOnB: aOnB,
    );
  }
}

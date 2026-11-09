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
    _cachedLevels[levelNumber] = level;
    return level.clone();
  }

  static LevelData _generateLevel(int n) {
    if (n == 65) return _buildLevel65(); // Faithful reproduction of Shot 1
    if (n == 85) return _buildLevel85(); // Flower layout from Shot 2
    if (n == 46) return _buildLevel46(); // Robot layout from Shot 3
    if (n == 75) return _buildLevel75(); // Concentric rings from Shot 4
    if (n == 98) return _buildLevel98(); // Rocket ship from Shot 5
    if (n == 89) return _buildLevel89(); // Mandala square from Shot 6
    if (n == 36) return _buildLevel36(); // Double nested chain from Shot 7
    if (n == 42) return _buildLevel42(); // Totem layout from Shot 8

    if (n <= 20) {
      return _buildTier1(n); // 1-20: Intro & Basics (2-3 rings)
    } else if (n <= 40) {
      return _buildTier2(n); // 21-40: Dual Rings & Gaps (3-4 rings)
    } else if (n <= 60) {
      return _buildTier3(n); // 41-60: C-Lock & D-Ring Structures
    } else if (n <= 80) {
      return _buildTier4(n); // 61-80: Interlocked Chains & Trees (4-6 rings)
    } else if (n <= 100) {
      return _buildTier5(n); // 81-100: Triple Rings & Concentric Layers
    } else if (n <= 130) {
      return _buildTier6(n); // 101-130: Geometric Locks (Triangle, Diamond, Hex)
    } else if (n <= 160) {
      return _buildTier7(n); // 131-160: Multi-Layer Depth Hierarchies
    } else if (n <= 180) {
      return _buildTier8(n); // 161-180: Hybrid Multi-Structure Locks
    } else {
      return _buildTier9(n); // 181-200: Master Complex Puzzles (6-9 rings)
    }
  }

  // =========================================================================
  // TIER 1: Levels 1–20 (Làm quen, 2-3 vòng)
  // =========================================================================
  static LevelData _buildTier1(int n) {
    if (n == 1) {
      // 2 rings, 1 sleeve, 1 acorn
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
        currentAngle: math.pi * 0.45, // rotating clockwise hits joint
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

    if (n == 2) {
      // 3 rings, 2 sleeves
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

    // Procedural Tier 1 (n = 3..20): 2 to 3 rings in diverse chains
    final rng = math.Random(n * 101 + 7);
    int count = (n <= 10) ? 2 : 3;
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    List<Color> palette = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelPurple,
      GameColors.pastelGreen,
    ];

    double baseX = 200.0;
    double baseY = 240.0;
    for (int i = 0; i < count; i++) {
      Offset c = Offset(baseX + (i == 1 ? 55 : (i == 2 ? -55 : 0)), baseY + (i * 90));
      rings.add(RingModel(
        id: 'r${i + 1}',
        center: c,
        radius: 56,
        strokeWidth: 22,
        color: palette[i % palette.length],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.30,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i % 2 == 1),
      ));
    }

    for (int i = 0; i < count - 1; i++) {
      joints.add(_createJoint('j_${i + 1}_${i + 2}', rings[i], rings[i + 1], rings[i].color));
    }

    return LevelData(
      levelNumber: n,
      title: "Vòng Xoay $n",
      category: "Làm Quen Vòng Tròn",
      difficulty: 1,
      rings: rings,
      joints: joints,
      targetMoves: count * 2,
      targetSeconds: 30,
    );
  }

  // =========================================================================
  // TIER 2: Levels 21–40 (3-4 rings)
  // =========================================================================
  static LevelData _buildTier2(int n) {
    final rng = math.Random(n * 211 + 13);
    int count = 4;
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    List<Offset> centers = [
      const Offset(140, 200),
      const Offset(260, 200),
      const Offset(140, 340),
      const Offset(260, 340),
    ];

    List<Color> palette = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelPurple,
      GameColors.pastelGreen,
    ];

    for (int i = 0; i < count; i++) {
      rings.add(RingModel(
        id: 'r${i + 1}',
        center: centers[i],
        radius: 54,
        strokeWidth: 22,
        color: palette[i],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i == 0 || i == 3),
      ));
    }

    // Connect into a ring/square chain
    joints.add(_createJoint('j1_2', rings[0], rings[1], palette[0]));
    joints.add(_createJoint('j1_3', rings[0], rings[2], palette[2]));
    joints.add(_createJoint('j2_4', rings[1], rings[3], palette[1]));

    return LevelData(
      levelNumber: n,
      title: "Liên Hoàn Tứ Giác $n",
      category: "Khe Hở Kép",
      difficulty: 2,
      rings: rings,
      joints: joints,
      targetMoves: 8,
      targetSeconds: 40,
    );
  }

  // =========================================================================
  // TIER 3: Levels 41–60 (C-Lock & D-Ring Structures)
  // =========================================================================
  static LevelData _buildTier3(int n) {
    final rng = math.Random(n * 307 + 31);
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    // Central anchor ring with 3 radiating petals
    var centerRing = RingModel(
      id: 'r_c',
      center: const Offset(200, 290),
      radius: 54,
      strokeWidth: 24,
      color: GameColors.pastelPurple,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.20,
      currentAngle: rng.nextDouble() * 2 * math.pi,
      hasAcorn: true,
    );
    rings.add(centerRing);

    List<double> angles = [-math.pi / 2, math.pi / 6, 5 * math.pi / 6];
    List<Color> colors = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelGreen,
    ];

    for (int i = 0; i < 3; i++) {
      double a = angles[i];
      Offset c = Offset(centerRing.center.dx + 98 * math.cos(a), centerRing.center.dy + 98 * math.sin(a));
      var petal = RingModel(
        id: 'r_p$i',
        center: c,
        radius: 50,
        strokeWidth: 22,
        color: colors[i],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i == 0),
      );
      rings.add(petal);
      joints.add(_createJoint('j_c_$i', centerRing, petal, colors[i]));
    }

    return LevelData(
      levelNumber: n,
      title: "Hoa Cánh Xoay $n",
      category: "Cấu Trúc C-Lock",
      difficulty: 3,
      rings: rings,
      joints: joints,
      targetMoves: 8,
      targetSeconds: 45,
    );
  }

  // =========================================================================
  // TIER 4: Levels 61–80 (Interlocked Chains & Trees)
  // =========================================================================
  static LevelData _buildTier4(int n) {
    final rng = math.Random(n * 409 + 43);
    int count = 5;
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    List<Offset> centers = [
      const Offset(150, 160),
      const Offset(250, 220),
      const Offset(150, 300),
      const Offset(250, 380),
      const Offset(150, 460),
    ];

    List<Color> palette = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelPurple,
      GameColors.pastelGreen,
      GameColors.pastelRed,
    ];

    for (int i = 0; i < count; i++) {
      rings.add(RingModel(
        id: 'r${i + 1}',
        center: centers[i],
        radius: 54,
        strokeWidth: 22,
        color: palette[i % palette.length],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.20,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i % 2 == 1),
      ));
    }

    for (int i = 0; i < count - 1; i++) {
      joints.add(_createJoint('j_${i + 1}_${i + 2}', rings[i], rings[i + 1], rings[i].color));
    }

    return LevelData(
      levelNumber: n,
      title: "Chuỗi Liên Hoàn $n",
      category: "Mắt Xích Đan Xen",
      difficulty: 3,
      rings: rings,
      joints: joints,
      targetMoves: 10,
      targetSeconds: 50,
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

  // =========================================================================
  // TIER 5 to 9 Procedural Generators
  // =========================================================================
  static LevelData _buildTier5(int n) {
    final rng = math.Random(n * 503 + 53);
    Offset center = const Offset(200, 290);
    List<RingModel> rings = [
      RingModel(
        id: 'r1',
        center: center,
        radius: 45,
        strokeWidth: 20,
        color: GameColors.pastelOrange,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: true,
        layer: 2,
      ),
      RingModel(
        id: 'r2',
        center: center,
        radius: 80,
        strokeWidth: 20,
        color: GameColors.pastelSkyBlue,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.20,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: false,
        layer: 1,
      ),
      RingModel(
        id: 'r3',
        center: center,
        radius: 115,
        strokeWidth: 20,
        color: GameColors.pastelPurple,
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.15,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: false,
        layer: 0,
      ),
    ];

    return LevelData(
      levelNumber: n,
      title: "Vòng Đồng Tâm $n",
      category: "Cấu Trúc Ba Vòng",
      difficulty: 3,
      rings: rings,
      joints: [
        _createJoint('j1_2', rings[0], rings[1], GameColors.pastelSkyBlue),
        _createJoint('j2_3', rings[1], rings[2], GameColors.pastelPurple),
      ],
      targetMoves: 8,
      targetSeconds: 45,
    );
  }

  static LevelData _buildTier6(int n) {
    final rng = math.Random(n * 607 + 61);
    int nodes = 5;
    List<RingModel> rings = [];
    List<JointModel> joints = [];
    Offset center = const Offset(200, 290);
    double radius = 105.0;

    List<Color> palette = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelPurple,
      GameColors.pastelGreen,
      GameColors.pastelRed,
    ];

    for (int i = 0; i < nodes; i++) {
      double angle = (i * 2 * math.pi / nodes) - math.pi / 2;
      Offset pos = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      rings.add(RingModel(
        id: 'r${i + 1}',
        center: pos,
        radius: 46,
        strokeWidth: 20,
        color: palette[i % palette.length],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i % 2 == 0),
      ));
    }

    for (int i = 0; i < nodes; i++) {
      int next = (i + 1) % nodes;
      joints.add(_createJoint('j_${i + 1}_${next + 1}', rings[i], rings[next], palette[i]));
    }

    return LevelData(
      levelNumber: n,
      title: "Ngũ Giác Hoa $n",
      category: "Khóa Hình Học",
      difficulty: 4,
      rings: rings,
      joints: joints,
      targetMoves: 10,
      targetSeconds: 50,
    );
  }

  static LevelData _buildTier7(int n) {
    final rng = math.Random(n * 709 + 71);
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    var hub = RingModel(
      id: 'r_hub',
      center: const Offset(200, 290),
      radius: 54,
      strokeWidth: 22,
      color: GameColors.pastelPurple,
      shapeType: RingShapeType.cLock,
      gapStartAngle: 0.0,
      gapSweep: 1.20,
      currentAngle: rng.nextDouble() * 2 * math.pi,
      hasAcorn: true,
    );
    rings.add(hub);

    List<Color> colors = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelGreen,
      GameColors.pastelRed,
    ];

    for (int i = 0; i < 4; i++) {
      double a = (i * math.pi / 2);
      Offset pos = Offset(hub.center.dx + 95 * math.cos(a), hub.center.dy + 95 * math.sin(a));
      var r = RingModel(
        id: 'r_$i',
        center: pos,
        radius: 48,
        strokeWidth: 20,
        color: colors[i],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i == 1),
      );
      rings.add(r);
      joints.add(_createJoint('j_h_$i', hub, r, colors[i]));
    }

    return LevelData(
      levelNumber: n,
      title: "Đa Tầng Đối Xứng $n",
      category: "Cấu Trúc Nhiều Tầng",
      difficulty: 4,
      rings: rings,
      joints: joints,
      targetMoves: 10,
      targetSeconds: 55,
    );
  }

  static LevelData _buildTier8(int n) {
    final rng = math.Random(n * 811 + 83);
    int count = 6;
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    List<Color> palette = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelPurple,
      GameColors.pastelGreen,
      GameColors.pastelRed,
      GameColors.pastelForestGreen,
    ];

    List<Offset> positions = [
      const Offset(140, 160),
      const Offset(260, 160),
      const Offset(200, 260),
      const Offset(140, 360),
      const Offset(260, 360),
      const Offset(200, 460),
    ];

    for (int i = 0; i < count; i++) {
      rings.add(RingModel(
        id: 'r${i + 1}',
        center: positions[i],
        radius: 50,
        strokeWidth: 20,
        color: palette[i],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i == 2 || i == 5),
      ));
    }

    joints.add(_createJoint('j1_3', rings[0], rings[2], palette[0]));
    joints.add(_createJoint('j2_3', rings[1], rings[2], palette[1]));
    joints.add(_createJoint('j3_4', rings[2], rings[3], palette[2]));
    joints.add(_createJoint('j3_5', rings[2], rings[4], palette[2]));
    joints.add(_createJoint('j4_6', rings[3], rings[5], palette[3]));
    joints.add(_createJoint('j5_6', rings[4], rings[5], palette[4]));

    return LevelData(
      levelNumber: n,
      title: "Khóa Lai Tạo $n",
      category: "Kết Hợp Đa Dạng",
      difficulty: 5,
      rings: rings,
      joints: joints,
      targetMoves: 14,
      targetSeconds: 70,
    );
  }

  static LevelData _buildTier9(int n) {
    final rng = math.Random(n * 919 + 97);
    int count = 7;
    List<RingModel> rings = [];
    List<JointModel> joints = [];

    List<Color> palette = [
      GameColors.pastelOrange,
      GameColors.pastelSkyBlue,
      GameColors.pastelPurple,
      GameColors.pastelGreen,
      GameColors.pastelRed,
      GameColors.pastelForestGreen,
      GameColors.pastelRoyalBlue,
    ];

    List<Offset> positions = [
      const Offset(150, 140),
      const Offset(250, 140),
      const Offset(200, 230),
      const Offset(120, 320),
      const Offset(280, 320),
      const Offset(200, 410),
      const Offset(200, 500),
    ];

    for (int i = 0; i < count; i++) {
      rings.add(RingModel(
        id: 'r${i + 1}',
        center: positions[i],
        radius: 48,
        strokeWidth: 20,
        color: palette[i],
        shapeType: RingShapeType.cLock,
        gapStartAngle: 0.0,
        gapSweep: 1.25,
        currentAngle: rng.nextDouble() * 2 * math.pi,
        hasAcorn: (i == 0 || i == 2 || i == 5),
      ));
    }

    joints.add(_createJoint('j1_3', rings[0], rings[2], palette[0]));
    joints.add(_createJoint('j2_3', rings[1], rings[2], palette[1]));
    joints.add(_createJoint('j3_4', rings[2], rings[3], palette[2]));
    joints.add(_createJoint('j3_5', rings[2], rings[4], palette[2]));
    joints.add(_createJoint('j4_6', rings[3], rings[5], palette[3]));
    joints.add(_createJoint('j5_6', rings[4], rings[5], palette[4]));
    joints.add(_createJoint('j6_7', rings[5], rings[6], palette[5]));

    return LevelData(
      levelNumber: n,
      title: "Bậc Thầy Tháo Gỡ $n",
      category: "Puzzle Phức Tạp",
      difficulty: 5,
      rings: rings,
      joints: joints,
      targetMoves: 16,
      targetSeconds: 85,
    );
  }

  static JointModel _createJoint(
    String id,
    RingModel rA,
    RingModel rB,
    Color color, {
    bool isSilver = false,
  }) {
    Offset mid = Offset((rA.center.dx + rB.center.dx) / 2, (rA.center.dy + rB.center.dy) / 2);
    double aOnA = math.atan2(mid.dy - rA.center.dy, mid.dx - rA.center.dx);
    double aOnB = math.atan2(mid.dy - rB.center.dy, mid.dx - rB.center.dx);
    return JointModel(
      id: id,
      type: JointType.sleeve,
      position: mid,
      ringIdA: rA.id,
      ringIdB: rB.id,
      color: color,
      isSilver: isSilver,
      angleOnA: aOnA,
      angleOnB: aOnB,
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum RingShapeType {
  cLock,            // Standard circular C-ring with 1 gap
  dRing,            // D-shaped ring with straight side & gap
  sFlex,            // S-shaped double curved link
  triangleLock,     // Triangle rounded frame
  doubleRing,       // Intersecting dual ring
  tripleRing,       // Concentric ring layer
  spiralLock,       // Spiral curved ring
  multiLayer,       // Nested depth ring
  interlockedChain, // Linear chain link
  closedRing,       // Full circular ring without gap
  straightRod,      // Linear pipe/rod
  lPipe             // L-shaped angled pipe
}

enum RingStatus {
  locked,    // Still blocked by joints
  movable,   // Free to rotate by user
  unlocked,  // All joints cleared, triggered release
  released,  // Animating outward/flying away
  completed  // Successfully removed from puzzle
}

class RingModel {
  final String id;
  final Offset center;
  final double radius;
  final double strokeWidth;
  final Color color;
  final RingShapeType shapeType;
  final int layer; // Z-order (higher is drawn on top)
  final bool hasAcorn;
  final bool hasBomb;

  // Gap definition: angle where opening starts, and sweep length
  // For C-rings, the gap is between gapStartAngle and (gapStartAngle + gapSweep)
  // For closed rings, gapSweep is 0.0
  final double gapStartAngle; // in radians [0, 2*pi]
  final double gapSweep;      // in radians (e.g. 70 deg = ~1.22 rad)

  // Dynamic state
  double currentAngle; // player's current rotation in radians
  RingStatus status;
  
  // Animation state for release
  double releaseProgress; // 0.0 to 1.0
  Offset releaseOffset;   // Direction the ring slides when freed
  double releaseRotation; // Extra rotational spin during release
  double releaseOpacity;  // Fade out during release
  double releaseScale;    // Scale during release

  RingModel({
    required this.id,
    required this.center,
    required this.radius,
    this.strokeWidth = 24.0,
    required this.color,
    this.shapeType = RingShapeType.cLock,
    this.layer = 0,
    this.hasAcorn = false,
    this.hasBomb = false,
    required this.gapStartAngle,
    this.gapSweep = 1.25, // ~72 degrees
    this.currentAngle = 0.0,
    this.status = RingStatus.movable,
    this.releaseProgress = 0.0,
    this.releaseOffset = Offset.zero,
    this.releaseRotation = 0.0,
    this.releaseOpacity = 1.0,
    this.releaseScale = 1.0,
  });

  bool get isFreed => status == RingStatus.unlocked || status == RingStatus.released || status == RingStatus.completed;

  /// The center angle of the gap in world space
  double get currentGapCenterAngle {
    if (gapSweep <= 0.001) return 0.0;
    double base = (currentAngle + gapStartAngle + (gapSweep / 2.0));
    return normalizeAngle(base);
  }

  /// Check if a world-space angle falls within the ring's gap
  bool isAngleInGap(double worldAngle, {double tolerance = 0.28}) {
    if (gapSweep <= 0.001) return false; // Closed ring has no gap
    double normTarget = normalizeAngle(worldAngle);
    double gapCenter = currentGapCenterAngle;
    double diff = (normTarget - gapCenter).abs();
    if (diff > math.pi) diff = (2 * math.pi) - diff;
    return diff <= ((gapSweep / 2.0) + tolerance);
  }

  static double normalizeAngle(double a) {
    double twoPi = 2 * math.pi;
    double res = a % twoPi;
    if (res < 0) res += twoPi;
    return res;
  }

  RingModel copyWith({
    String? id,
    Offset? center,
    double? radius,
    double? strokeWidth,
    Color? color,
    RingShapeType? shapeType,
    int? layer,
    bool? hasAcorn,
    bool? hasBomb,
    double? gapStartAngle,
    double? gapSweep,
    double? currentAngle,
    RingStatus? status,
    double? releaseProgress,
    Offset? releaseOffset,
    double? releaseRotation,
    double? releaseOpacity,
    double? releaseScale,
  }) {
    return RingModel(
      id: id ?? this.id,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      color: color ?? this.color,
      shapeType: shapeType ?? this.shapeType,
      layer: layer ?? this.layer,
      hasAcorn: hasAcorn ?? this.hasAcorn,
      hasBomb: hasBomb ?? this.hasBomb,
      gapStartAngle: gapStartAngle ?? this.gapStartAngle,
      gapSweep: gapSweep ?? this.gapSweep,
      currentAngle: currentAngle ?? this.currentAngle,
      status: status ?? this.status,
      releaseProgress: releaseProgress ?? this.releaseProgress,
      releaseOffset: releaseOffset ?? this.releaseOffset,
      releaseRotation: releaseRotation ?? this.releaseRotation,
      releaseOpacity: releaseOpacity ?? this.releaseOpacity,
      releaseScale: releaseScale ?? this.releaseScale,
    );
  }

  RingModel clone() {
    return RingModel(
      id: id,
      center: center,
      radius: radius,
      strokeWidth: strokeWidth,
      color: color,
      shapeType: shapeType,
      layer: layer,
      hasAcorn: hasAcorn,
      hasBomb: hasBomb,
      gapStartAngle: gapStartAngle,
      gapSweep: gapSweep,
      currentAngle: currentAngle,
      status: status,
      releaseProgress: releaseProgress,
      releaseOffset: releaseOffset,
      releaseRotation: releaseRotation,
      releaseOpacity: releaseOpacity,
      releaseScale: releaseScale,
    );
  }
}

import 'package:flutter/material.dart';

enum JointType {
  sleeve,     // Rectangular interlocking sleeve/bracket connecting 2 rings
  pin,        // Fixed post/anchor that locks a single ring in place
  chainLink,  // Chain shackle
  pivot       // Central pivot joint
}

class JointModel {
  final String id;
  final JointType type;
  final Offset position;
  final String ringIdA;
  final String? ringIdB;
  final Color color;
  final bool isSilver;
  
  // Angle of this joint relative to ring A's center
  final double angleOnA;
  // Angle of this joint relative to ring B's center (if ringIdB != null)
  final double? angleOnB;

  // Independent detachment states
  bool detachedFromA;
  bool detachedFromB;

  // Overall release status (true when detached from all connected rings)
  bool isReleased;
  double releaseAnimation; // 0.0 to 1.0 (for fade/pop effect)

  JointModel({
    required this.id,
    this.type = JointType.sleeve,
    required this.position,
    required this.ringIdA,
    this.ringIdB,
    required this.color,
    this.isSilver = false,
    required this.angleOnA,
    this.angleOnB,
    this.detachedFromA = false,
    this.detachedFromB = false,
    this.isReleased = false,
    this.releaseAnimation = 0.0,
  });

  /// Checks if this joint is still holding a specific ring in place
  bool isHoldingRing(String ringId, {bool isOtherRingFreed = false}) {
    if (isReleased) return false;

    if (type == JointType.pin) {
      if (ringIdA == ringId) return !detachedFromA;
      return false;
    }

    // Sleeve between A and B
    if (ringIdA == ringId) {
      if (detachedFromA) return false;
      if (isOtherRingFreed || detachedFromB) return false;
      return true;
    }

    if (ringIdB == ringId) {
      if (detachedFromB) return false;
      if (isOtherRingFreed || detachedFromA) return false;
      return true;
    }

    return false;
  }

  /// Updates isReleased based on detachment
  void updateReleaseState() {
    if (detachedFromA || detachedFromB) {
      isReleased = true;
    }
  }

  JointModel copyWith({
    String? id,
    JointType? type,
    Offset? position,
    String? ringIdA,
    String? ringIdB,
    Color? color,
    bool? isSilver,
    double? angleOnA,
    double? angleOnB,
    bool? detachedFromA,
    bool? detachedFromB,
    bool? isReleased,
    double? releaseAnimation,
  }) {
    return JointModel(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      ringIdA: ringIdA ?? this.ringIdA,
      ringIdB: ringIdB ?? this.ringIdB,
      color: color ?? this.color,
      isSilver: isSilver ?? this.isSilver,
      angleOnA: angleOnA ?? this.angleOnA,
      angleOnB: angleOnB ?? this.angleOnB,
      detachedFromA: detachedFromA ?? this.detachedFromA,
      detachedFromB: detachedFromB ?? this.detachedFromB,
      isReleased: isReleased ?? this.isReleased,
      releaseAnimation: releaseAnimation ?? this.releaseAnimation,
    );
  }

  JointModel clone() {
    return JointModel(
      id: id,
      type: type,
      position: position,
      ringIdA: ringIdA,
      ringIdB: ringIdB,
      color: color,
      isSilver: isSilver,
      angleOnA: angleOnA,
      angleOnB: angleOnB,
      detachedFromA: detachedFromA,
      detachedFromB: detachedFromB,
      isReleased: isReleased,
      releaseAnimation: releaseAnimation,
    );
  }
}

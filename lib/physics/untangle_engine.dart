import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import '../models/joint_model.dart';
import '../models/level_data.dart';
import 'geometry_math.dart';

class UntangleResult {
  final List<RingModel> freedRings;
  final List<JointModel> freedJoints;
  final int acornsGained;
  final bool puzzleComplete;

  UntangleResult({
    required this.freedRings,
    required this.freedJoints,
    required this.acornsGained,
    required this.puzzleComplete,
  });
}

class UntangleEngine {
  /// Evaluates current state of rings and joints, releasing any that satisfy gap alignments.
  /// Cascades through dependencies until no further releases occur.
  static UntangleResult checkAndReleaseCascade(LevelData level, {RingModel? activeRing}) {
    List<RingModel> newlyFreedRings = [];
    List<JointModel> newlyFreedJoints = [];
    int acornsCount = 0;

    bool stateChanged = true;

    while (stateChanged) {
      stateChanged = false;

      // 1. Check all joints that are still holding pieces
      for (final joint in level.joints) {
        if (joint.isReleased) continue;

        final ringA = level.rings.firstWhere((r) => r.id == joint.ringIdA);
        final ringB = joint.ringIdB != null
            ? level.rings.firstWhere((r) => r.id == joint.ringIdB)
            : null;

        // If either ring is already freed, this joint can no longer anchor anything
        if (ringA.isFreed || (ringB != null && ringB.isFreed)) {
          joint.detachedFromA = true;
          joint.detachedFromB = true;
          joint.isReleased = true;
          newlyFreedJoints.add(joint);
          stateChanged = true;
          continue;
        }

        // Check if Ring A's gap is aligned with this joint
        if (!joint.detachedFromA) {
          double angleA = math.atan2(joint.position.dy - ringA.center.dy, joint.position.dx - ringA.center.dx);
          if (GeometryMath.isJointInGap(ringA, angleA)) {
            joint.detachedFromA = true;
            joint.updateReleaseState();
            stateChanged = true;
          }
        }

        // Check if Ring B's gap is aligned with this joint
        if (ringB != null && !joint.detachedFromB) {
          double angleB = math.atan2(joint.position.dy - ringB.center.dy, joint.position.dx - ringB.center.dx);
          if (GeometryMath.isJointInGap(ringB, angleB)) {
            joint.detachedFromB = true;
            joint.updateReleaseState();
            stateChanged = true;
          }
        }

        if (joint.isReleased && !newlyFreedJoints.contains(joint)) {
          newlyFreedJoints.add(joint);
        }
      }

      // 2. Check each active ring: if it has no remaining holding joints, it is completely free!
      for (final ring in level.rings) {
        if (ring.isFreed) continue;

        // Check if any joint still holds this ring
        bool isHeld = level.joints.any((j) {
          final otherId = (j.ringIdA == ring.id) ? j.ringIdB : j.ringIdA;
          final otherRing = otherId != null
              ? level.rings.firstWhere((r) => r.id == otherId, orElse: () => ring)
              : null;
          bool isOtherFreed = otherRing != null && otherRing.id != ring.id && otherRing.isFreed;
          return j.isHoldingRing(ring.id, isOtherRingFreed: isOtherFreed);
        });

        if (!isHeld) {
          // Ring is completely unlocked!
          ring.status = RingStatus.unlocked;

          // Calculate outward fly direction away from center of the board
          Offset boardCenter = const Offset(200, 320);
          Offset dir = ring.center - boardCenter;
          double dist = dir.distance;
          Offset normDir = dist > 15 ? dir / dist : const Offset(0, -1);

          ring.releaseOffset = normDir * 460.0;
          ring.releaseProgress = 0.0;
          ring.releaseOpacity = 1.0;
          ring.releaseRotation = (math.Random().nextBool() ? 1.0 : -1.0) * 0.9;
          ring.releaseScale = 1.0;

          if (ring.hasAcorn) {
            acornsCount++;
          }

          newlyFreedRings.add(ring);
          stateChanged = true;
        }
      }
    }

    bool allRingsFreed = level.rings.every((r) => r.isFreed);

    return UntangleResult(
      freedRings: newlyFreedRings,
      freedJoints: newlyFreedJoints,
      acornsGained: acornsCount,
      puzzleComplete: allRingsFreed,
    );
  }

  /// Advances physics and particle animations per frame
  static void updateAnimations(LevelData level, double dt) {
    for (final ring in level.rings) {
      if (ring.status == RingStatus.unlocked || ring.status == RingStatus.released) {
        ring.status = RingStatus.released;
        ring.releaseProgress += dt * 2.4; // completes in ~400ms
        ring.releaseOpacity = (1.0 - ring.releaseProgress).clamp(0.0, 1.0);
        ring.releaseScale = 1.0 + (ring.releaseProgress * 0.2);

        if (ring.releaseProgress >= 1.0) {
          ring.status = RingStatus.completed;
          ring.releaseProgress = 1.0;
          ring.releaseOpacity = 0.0;
        }
      }
    }

    for (final joint in level.joints) {
      if (joint.isReleased && joint.releaseAnimation < 1.0) {
        joint.releaseAnimation = (joint.releaseAnimation + dt * 3.0).clamp(0.0, 1.0);
      }
    }
  }

  /// Directly smashes/frees a specific ring (used by Hammer booster)
  static UntangleResult smashRing(LevelData level, RingModel targetRing) {
    if (targetRing.isFreed) {
      return UntangleResult(
        freedRings: [],
        freedJoints: [],
        acornsGained: 0,
        puzzleComplete: level.rings.every((r) => r.isFreed),
      );
    }

    targetRing.status = RingStatus.unlocked;
    targetRing.releaseOffset = const Offset(0, -400);
    targetRing.releaseProgress = 0.0;
    targetRing.releaseOpacity = 1.0;

    // Detach all joints from this ring
    for (final j in level.joints) {
      if (j.ringIdA == targetRing.id) j.detachedFromA = true;
      if (j.ringIdB == targetRing.id) j.detachedFromB = true;
      j.updateReleaseState();
    }

    int acorns = targetRing.hasAcorn ? 1 : 0;

    // Cascade to see if any other rings become free
    var cascadeRes = checkAndReleaseCascade(level);

    List<RingModel> allFreed = [targetRing, ...cascadeRes.freedRings];
    return UntangleResult(
      freedRings: allFreed,
      freedJoints: cascadeRes.freedJoints,
      acornsGained: acorns + cascadeRes.acornsGained,
      puzzleComplete: level.rings.every((r) => r.isFreed),
    );
  }
}

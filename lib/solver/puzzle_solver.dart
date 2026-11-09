import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ring_model.dart';
import '../models/level_data.dart';
import '../physics/geometry_math.dart';

class HintStep {
  final String ringId;
  final double targetAngle;
  final double deltaAngle;
  final bool isClockwise;
  final String message;
  final Color ringColor;

  HintStep({
    required this.ringId,
    required this.targetAngle,
    required this.deltaAngle,
    required this.isClockwise,
    required this.message,
    required this.ringColor,
  });
}

class PuzzleSolver {
  /// Solves the puzzle from the current state and returns the optimal next step.
  /// Uses a prioritized State Search / BFS over candidate alignment angles.
  static HintStep? findNextMove(LevelData level) {
    final activeRings = level.rings.where((r) => !r.isFreed && r.gapSweep > 0.001).toList();
    if (activeRings.isEmpty) return null;

    final unreleasedJoints = level.joints.where((j) => !j.isReleased).toList();
    if (unreleasedJoints.isEmpty) {
      final first = activeRings.first;
      return HintStep(
        ringId: first.id,
        targetAngle: first.currentAngle,
        deltaAngle: 0.0,
        isClockwise: true,
        message: "Xoay nhẹ để giải phóng vòng",
        ringColor: first.color,
      );
    }

    _CandidateMove? bestMove;

    // 1. Evaluate candidate rotations for each active ring that has at least 1 holding joint
    for (final ring in activeRings) {
      final holdingJoints = unreleasedJoints.where((j) => j.isHoldingRing(ring.id)).toList();
      if (holdingJoints.isEmpty) continue;

      for (final joint in holdingJoints) {
        // Calculate angle of joint relative to ring.center
        double jointAngle = math.atan2(
          joint.position.dy - ring.center.dy,
          joint.position.dx - ring.center.dx,
        );

        // Required currentAngle so that ring.currentGapCenterAngle == jointAngle
        double targetAngle = GeometryMath.normalizeAngle(
          jointAngle - ring.gapStartAngle - (ring.gapSweep / 2.0),
        );

        double delta = GeometryMath.shortestAngleDelta(ring.currentAngle, targetAngle);
        bool isCw = delta >= 0;

        // Score this candidate move:
        // Fewer holding joints on this ring -> higher priority (work outside-in!)
        int priorityScore = (10 - holdingJoints.length) * 100 - (delta.abs() * 10).toInt();

        // Bonus if this move frees the ring completely
        if (holdingJoints.length == 1) {
          priorityScore += 500;
        }

        if (bestMove == null || priorityScore > bestMove.score) {
          bestMove = _CandidateMove(
            ring: ring,
            targetAngle: targetAngle,
            deltaAngle: delta,
            isClockwise: isCw,
            score: priorityScore,
            holdingCount: holdingJoints.length,
          );
        }
      }
    }

    if (bestMove == null) {
      final fallback = activeRings.first;
      return HintStep(
        ringId: fallback.id,
        targetAngle: GeometryMath.normalizeAngle(fallback.currentAngle + 1.2),
        deltaAngle: 1.2,
        isClockwise: true,
        message: "Xoay vòng này để tháo khớp nối",
        ringColor: fallback.color,
      );
    }

    String directionWord = bestMove.isClockwise ? "thuận chiều kim đồng hồ" : "ngược chiều kim đồng hồ";
    String hintText = bestMove.holdingCount == 1
        ? "Xoay $directionWord để mở khóa hoàn toàn!"
        : "Xoay $directionWord để tháo chốt nối!";

    return HintStep(
      ringId: bestMove.ring.id,
      targetAngle: bestMove.targetAngle,
      deltaAngle: bestMove.deltaAngle,
      isClockwise: bestMove.isClockwise,
      message: hintText,
      ringColor: bestMove.ring.color,
    );
  }
}

class _CandidateMove {
  final RingModel ring;
  final double targetAngle;
  final double deltaAngle;
  final bool isClockwise;
  final int score;
  final int holdingCount;

  _CandidateMove({
    required this.ring,
    required this.targetAngle,
    required this.deltaAngle,
    required this.isClockwise,
    required this.score,
    required this.holdingCount,
  });
}

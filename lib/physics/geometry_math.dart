import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ring_model.dart';

class GeometryMath {
  static const double twoPi = 2.0 * math.pi;

  /// Normalizes any angle into [0, 2*PI)
  /// Safely handles NaN, Infinity, negative angles and boundary values
  static double normalizeAngle(double angle) {
    if (angle.isNaN || angle.isInfinite) return 0.0;
    double res = angle % twoPi;
    if (res < 0) res += twoPi;
    if (res >= twoPi - 1e-5) res = 0.0;
    return res;
  }

  /// Shortest signed angular distance from angle A to angle B in [-PI, PI]
  /// Positive means clockwise from A to B
  static double shortestAngleDelta(double fromAngle, double toAngle) {
    if (fromAngle.isNaN || toAngle.isNaN) return 0.0;
    double diff = normalizeAngle(toAngle) - normalizeAngle(fromAngle);
    if (diff > math.pi) {
      diff -= twoPi;
    } else if (diff < -math.pi) {
      diff += twoPi;
    }
    return diff;
  }

  /// Calculates world angle from center to point P
  /// Safely handles identical points (dx=0, dy=0)
  static double angleFromCenter(Offset center, Offset point) {
    double dx = point.dx - center.dx;
    double dy = point.dy - center.dy;
    if (dx == 0.0 && dy == 0.0) return 0.0;
    return normalizeAngle(math.atan2(dy, dx));
  }

  /// Calculates Euclidean distance between two points
  static double distance(Offset a, Offset b) {
    double dx = a.dx - b.dx;
    double dy = a.dy - b.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Hit tests rings from topmost layer to bottom layer.
  /// Returns the ring being touched, or null if touch is outside any ring.
  static RingModel? hitTestRing(Offset touchPoint, List<RingModel> rings) {
    // Sort movable rings by layer descending (top-most layer first)
    final candidates = rings
        .where((r) => !r.isFreed)
        .toList()
      ..sort((a, b) => b.layer.compareTo(a.layer));

    for (final ring in candidates) {
      double dist = distance(ring.center, touchPoint);
      double halfWidth = ring.strokeWidth * 0.95;
      double minR = (ring.radius - halfWidth).clamp(0.0, double.infinity);
      double maxR = ring.radius + halfWidth;

      if (dist >= minR && dist <= maxR) {
        return ring;
      }
    }
    return null;
  }

  /// Check if a given joint is aligned with ring's gap.
  /// jointAngleOnRing is the angular coordinate of the joint relative to ring.center.
  static bool isJointInGap(RingModel ring, double jointAngleOnRing, {double tolerance = 0.28}) {
    return ring.isAngleInGap(jointAngleOnRing, tolerance: tolerance);
  }

  /// Rotates a point around an origin by given angle
  static Offset rotatePoint(Offset point, Offset origin, double angle) {
    double cosA = math.cos(angle);
    double sinA = math.sin(angle);
    double dx = point.dx - origin.dx;
    double dy = point.dy - origin.dy;
    return Offset(
      origin.dx + (dx * cosA - dy * sinA),
      origin.dy + (dx * sinA + dy * cosA),
    );
  }
}

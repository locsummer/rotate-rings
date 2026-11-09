import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ring_model.dart';
import '../../models/joint_model.dart';
import '../../models/level_data.dart';
import '../../physics/geometry_math.dart';
import '../../physics/untangle_engine.dart';
import '../../audio/sound_service.dart';
import 'particle_system.dart';

class FloatingText {
  final String text;
  final Offset position;
  final Color color;
  double life; // 0.0 to 1.0

  FloatingText({
    required this.text,
    required this.position,
    required this.color,
    this.life = 0.0,
  });
}

class RingCanvas extends StatefulWidget {
  final LevelData level;
  final String? hintRingId;
  final double? hintTargetAngle;
  final bool? hintIsClockwise;
  final bool isHammerMode;
  final VoidCallback onMoveMade;
  final Function(UntangleResult) onUntangleStep;
  final ParticleController particleController;

  const RingCanvas({
    super.key,
    required this.level,
    this.hintRingId,
    this.hintTargetAngle,
    this.hintIsClockwise,
    this.isHammerMode = false,
    required this.onMoveMade,
    required this.onUntangleStep,
    required this.particleController,
  });

  @override
  State<RingCanvas> createState() => _RingCanvasState();
}

class _RingCanvasState extends State<RingCanvas> with SingleTickerProviderStateMixin {
  RingModel? _activeRing;
  double? _lastTouchAngle;
  late AnimationController _animController;
  DateTime _lastFrameTime = DateTime.now();

  // Floating comic popups ("Great!", "Excellent!", etc.)
  final List<FloatingText> _floatingTexts = [];

  // Drag tick sound tracking
  double _accumulatedAngleSinceTick = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animController.addListener(_onTick);
  }

  void _onTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastFrameTime).inMicroseconds) / 1000000.0;
    _lastFrameTime = now;
    double safeDt = dt.clamp(0.001, 0.05);

    // Advance untangle fly-out animations
    if (widget.level.rings.any((r) => r.status == RingStatus.unlocked || r.status == RingStatus.released)) {
      setState(() {
        UntangleEngine.updateAnimations(widget.level, safeDt);
      });
    }

    // Advance floating texts
    if (_floatingTexts.isNotEmpty) {
      setState(() {
        for (final ft in _floatingTexts) {
          ft.life += safeDt * 1.4;
        }
        _floatingTexts.removeWhere((ft) => ft.life >= 1.0);
      });
    }

    widget.particleController.update(safeDt);
  }

  @override
  void dispose() {
    _animController.removeListener(_onTick);
    _animController.dispose();
    super.dispose();
  }

  void _spawnFloatingText(String text, Offset pos, Color color) {
    _floatingTexts.add(FloatingText(
      text: text,
      position: pos,
      color: color,
    ));
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    Offset touchPoint = _transformCoordinates(details.localPosition, constraints);
    RingModel? hit = GeometryMath.hitTestRing(touchPoint, widget.level.rings);

    if (hit != null && !hit.isFreed) {
      // If hammer mode is active, smash this ring immediately!
      if (widget.isHammerMode) {
        SoundService.instance.playSnap();
        HapticFeedback.heavyImpact();
        widget.particleController.spawnRingBurst(hit.center, hit.color, count: 28);
        _spawnFloatingText("SMASH!", hit.center, Colors.orangeAccent);

        UntangleResult res = UntangleEngine.smashRing(widget.level, hit);
        widget.onUntangleStep(res);
        setState(() {});
        return;
      }

      setState(() {
        _activeRing = hit;
        _lastTouchAngle = GeometryMath.angleFromCenter(hit.center, touchPoint);
        _accumulatedAngleSinceTick = 0.0;
      });
      SoundService.instance.playTouch();
    }
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_activeRing == null || _lastTouchAngle == null || _activeRing!.isFreed) return;

    Offset touchPoint = _transformCoordinates(details.localPosition, constraints);
    double currentTouchAngle = GeometryMath.angleFromCenter(_activeRing!.center, touchPoint);
    double deltaAngle = GeometryMath.shortestAngleDelta(_lastTouchAngle!, currentTouchAngle);

    if (deltaAngle.abs() > 0.001) {
      setState(() {
        _activeRing!.currentAngle = GeometryMath.normalizeAngle(_activeRing!.currentAngle + deltaAngle);
        _lastTouchAngle = currentTouchAngle;

        _accumulatedAngleSinceTick += deltaAngle.abs();
        if (_accumulatedAngleSinceTick >= (math.pi / 14)) {
          _accumulatedAngleSinceTick = 0.0;
          SoundService.instance.playTick();
        }

        // REAL-TIME CHECK: Instant detachment the moment gap aligns with joint!
        UntangleResult result = UntangleEngine.checkAndReleaseCascade(
          widget.level,
          activeRing: _activeRing,
        );

        if (result.freedJoints.isNotEmpty || result.freedRings.isNotEmpty) {
          SoundService.instance.playUnlock();
          HapticFeedback.mediumImpact();

          for (final freed in result.freedRings) {
            widget.particleController.spawnRingBurst(freed.center, freed.color);

            List<String> praises = ["Great!", "Awesome!", "Excellent!", "Good!", "Perfect!"];
            praises.shuffle();
            _spawnFloatingText(praises.first, freed.center + const Offset(10, -20), const Color(0xFF29B6F6));
          }

          widget.onUntangleStep(result);

          // If the ring being dragged was freed, release touch lock
          if (_activeRing!.isFreed) {
            _activeRing = null;
            _lastTouchAngle = null;
          }
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeRing != null) {
      widget.onMoveMade();
      // Final cascade check on release
      UntangleResult result = UntangleEngine.checkAndReleaseCascade(widget.level);
      if (result.freedRings.isNotEmpty) {
        SoundService.instance.playUnlock();
        HapticFeedback.heavyImpact();
        widget.onUntangleStep(result);
      }
      setState(() {
        _activeRing = null;
        _lastTouchAngle = null;
      });
    }
  }

  Offset _transformCoordinates(Offset localPos, BoxConstraints constraints) {
    const double boardWidth = 400.0;
    const double boardHeight = 620.0;

    double scaleX = constraints.maxWidth / boardWidth;
    double scaleY = constraints.maxHeight / boardHeight;
    double scale = math.min(scaleX, scaleY);

    double offsetX = (constraints.maxWidth - (boardWidth * scale)) / 2.0;
    double offsetY = (constraints.maxHeight - (boardHeight * scale)) / 2.0;

    double transformedX = (localPos.dx - offsetX) / scale;
    double transformedY = (localPos.dy - offsetY) / scale;

    return Offset(transformedX, transformedY);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double boardWidth = 400.0;
        const double boardHeight = 620.0;

        double scaleX = constraints.maxWidth / boardWidth;
        double scaleY = constraints.maxHeight / boardHeight;
        double scale = math.min(scaleX, scaleY);

        double offsetX = (constraints.maxWidth - (boardWidth * scale)) / 2.0;
        double offsetY = (constraints.maxHeight - (boardHeight * scale)) / 2.0;

        return GestureDetector(
          onPanStart: (d) => _onPanStart(d, constraints),
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: Container(
            color: Colors.transparent,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  width: boardWidth * scale,
                  height: boardHeight * scale,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: boardWidth,
                      height: boardHeight,
                      child: CustomPaint(
                        painter: _EnhancedRingPainter(
                          level: widget.level,
                          activeRingId: _activeRing?.id,
                          hintRingId: widget.hintRingId,
                          hintTargetAngle: widget.hintTargetAngle,
                          hintIsClockwise: widget.hintIsClockwise,
                          animValue: _animController.value,
                          floatingTexts: _floatingTexts,
                        ),
                      ),
                    ),
                  ),
                ),
                // Particle celebration layer
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ParticlePainter(controller: widget.particleController),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedRingPainter extends CustomPainter {
  final LevelData level;
  final String? activeRingId;
  final String? hintRingId;
  final double? hintTargetAngle;
  final bool? hintIsClockwise;
  final double animValue;
  final List<FloatingText> floatingTexts;

  _EnhancedRingPainter({
    required this.level,
    this.activeRingId,
    this.hintRingId,
    this.hintTargetAngle,
    this.hintIsClockwise,
    required this.animValue,
    required this.floatingTexts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sort rings by layer ascending
    final sortedRings = List<RingModel>.from(level.rings)
      ..sort((a, b) => a.layer.compareTo(b.layer));

    // 2. Draw rings drop shadows
    for (final ring in sortedRings) {
      if (ring.status != RingStatus.completed) {
        _drawRingShadow(canvas, ring);
      }
    }

    // 3. Draw active rings & glossy 3D tubes
    for (final ring in sortedRings) {
      if (ring.status != RingStatus.completed) {
        _drawRing(canvas, ring);
      }
    }

    // 4. Draw joints & sleeves
    for (final joint in level.joints) {
      if (!joint.isReleased || joint.releaseAnimation < 1.0) {
        _drawJoint(canvas, joint);
      }
    }

    // 5. Draw acorns inside rings
    for (final ring in sortedRings) {
      if (ring.hasAcorn && ring.status != RingStatus.completed) {
        _drawAcorn(canvas, ring);
      }
    }

    // 6. Draw hint glow & tutorial hand
    if (hintRingId != null) {
      final hintRing = level.rings.firstWhere(
        (r) => r.id == hintRingId,
        orElse: () => level.rings.first,
      );
      if (!hintRing.isFreed) {
        _drawHintIndicator(canvas, hintRing);
      }
    }

    // 7. Draw floating popups ("Great!", "Excellent!")
    for (final ft in floatingTexts) {
      _drawFloatingText(canvas, ft);
    }
  }

  void _drawRingShadow(Canvas canvas, RingModel ring) {
    canvas.save();
    if (ring.status == RingStatus.released) {
      Offset pos = ring.center + (ring.releaseOffset * ring.releaseProgress);
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(ring.releaseRotation * ring.releaseProgress);
      canvas.scale(ring.releaseScale);
      canvas.translate(-ring.center.dx, -ring.center.dy);
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12 * ring.releaseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring.strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    double drawAngle = ring.currentAngle + ring.gapStartAngle + ring.gapSweep;
    double drawSweep = (2 * math.pi) - ring.gapSweep;

    canvas.drawArc(
      Rect.fromCircle(center: ring.center + const Offset(0, 4), radius: ring.radius),
      drawAngle,
      drawSweep,
      false,
      shadowPaint,
    );

    canvas.restore();
  }

  void _drawRing(Canvas canvas, RingModel ring) {
    canvas.save();

    if (ring.status == RingStatus.released) {
      Offset pos = ring.center + (ring.releaseOffset * ring.releaseProgress);
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(ring.releaseRotation * ring.releaseProgress);
      canvas.scale(ring.releaseScale);
      canvas.translate(-ring.center.dx, -ring.center.dy);
    }

    double drawAngle = ring.currentAngle + ring.gapStartAngle + ring.gapSweep;
    double drawSweep = (2 * math.pi) - ring.gapSweep;

    // A. Main vibrant lacquer tube
    final ringPaint = Paint()
      ..color = ring.color.withOpacity(ring.releaseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring.strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: ring.center, radius: ring.radius),
      drawAngle,
      drawSweep,
      false,
      ringPaint,
    );

    // B. Inner glossy 3D specular highlight strip
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.40 * ring.releaseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring.strokeWidth * 0.28
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: ring.center, radius: ring.radius - ring.strokeWidth * 0.16),
      drawAngle + 0.08,
      (drawSweep - 0.16).clamp(0.0, 2 * math.pi),
      false,
      highlightPaint,
    );

    // C. Outer bottom edge shading
    final edgePaint = Paint()
      ..color = Colors.black.withOpacity(0.10 * ring.releaseOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring.strokeWidth * 0.22
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: ring.center, radius: ring.radius + ring.strokeWidth * 0.18),
      drawAngle + 0.1,
      (drawSweep - 0.2).clamp(0.0, 2 * math.pi),
      false,
      edgePaint,
    );

    // D. Active touch halo
    if (activeRingId == ring.id) {
      final activeHalo = Paint()
        ..color = Colors.white.withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.strokeWidth + 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: ring.center, radius: ring.radius),
        drawAngle,
        drawSweep,
        false,
        activeHalo,
      );
    }

    canvas.restore();
  }

  void _drawJoint(Canvas canvas, JointModel joint) {
    double opacity = joint.isReleased ? (1.0 - joint.releaseAnimation).clamp(0.0, 1.0) : 1.0;
    if (opacity <= 0.0) return;

    canvas.save();
    canvas.translate(joint.position.dx, joint.position.dy);

    // Align sleeve tangent to circle
    canvas.rotate(joint.angleOnA + math.pi / 2);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 24, height: 16),
      const Radius.circular(5),
    );

    // Drop shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withOpacity(0.18 * opacity),
    );

    // Sleeve body color (Silver metallic or matching accent)
    Color sleeveCol = (joint.isSilver ? const Color(0xFFD6DBDF) : joint.color).withOpacity(opacity);
    canvas.drawRRect(rrect, Paint()..color = sleeveCol);

    // Bevel edge highlight
    final bevelPaint = Paint()
      ..color = Colors.white.withOpacity(0.55 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, bevelPaint);

    // Slit groove where tube passes through
    final slitPaint = Paint()..color = Colors.black.withOpacity(0.35 * opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 5, height: 11),
        const Radius.circular(2),
      ),
      slitPaint,
    );

    // Metallic collar rivets
    final rivetPaint = Paint()..color = Colors.white.withOpacity(0.7 * opacity);
    canvas.drawCircle(const Offset(-7, 0), 1.6, rivetPaint);
    canvas.drawCircle(const Offset(7, 0), 1.6, rivetPaint);

    canvas.restore();
  }

  void _drawAcorn(Canvas canvas, RingModel ring) {
    canvas.save();
    canvas.translate(ring.center.dx, ring.center.dy);
    if (ring.status == RingStatus.released) {
      canvas.translate(ring.releaseOffset.dx * ring.releaseProgress, ring.releaseOffset.dy * ring.releaseProgress);
      canvas.scale(ring.releaseScale);
    }

    // Gentle floating bob
    double bob = math.sin((animValue * 2 * math.pi) + ring.radius) * 3.5;
    canvas.translate(0, bob);

    _paint3DAcorn(canvas, const Size(36, 36));

    canvas.restore();
  }

  void _paint3DAcorn(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Drop shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.95), width: w * 0.6, height: h * 0.22),
      Paint()..color = Colors.black.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Acorn nut body (golden)
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.18, h * 0.38);
    bodyPath.cubicTo(w * 0.15, h * 0.70, w * 0.35, h * 0.96, w * 0.5, h * 0.98);
    bodyPath.cubicTo(w * 0.65, h * 0.96, w * 0.85, h * 0.70, w * 0.82, h * 0.38);
    bodyPath.close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFF57C00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(bodyPath, bodyPaint);

    // Specular body shine
    canvas.drawOval(
      Rect.fromLTWH(w * 0.32, h * 0.48, w * 0.16, h * 0.28),
      Paint()..color = Colors.white.withOpacity(0.48),
    );

    // Acorn cap (caramel / brown)
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.24, w * 0.76, h * 0.22),
      const Radius.circular(8),
    );
    final capPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(capRect, capPaint);

    // Stem
    final stemPath = Path();
    stemPath.moveTo(w * 0.5, h * 0.24);
    stemPath.cubicTo(w * 0.48, h * 0.12, w * 0.58, h * 0.08, w * 0.54, h * 0.04);
    canvas.drawPath(
      stemPath,
      Paint()
        ..color = const Color(0xFF4E342E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHintIndicator(Canvas canvas, RingModel ring) {
    double pulse = 0.5 + 0.5 * math.sin(animValue * 2 * math.pi);

    // Glowing aura around target ring
    final auraPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.4 + pulse * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ring.strokeWidth + 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    double drawAngle = ring.currentAngle + ring.gapStartAngle + ring.gapSweep;
    double drawSweep = (2 * math.pi) - ring.gapSweep;

    canvas.drawArc(
      Rect.fromCircle(center: ring.center, radius: ring.radius),
      drawAngle,
      drawSweep,
      false,
      auraPaint,
    );

    // White animated cartoon hand pointing
    double handAngle = ring.currentAngle + (animValue * 0.4);
    double handDist = ring.radius;
    Offset handPos = Offset(
      ring.center.dx + handDist * math.cos(handAngle),
      ring.center.dy + handDist * math.sin(handAngle),
    );

    _drawCartoonHand(canvas, handPos);
  }

  void _drawCartoonHand(Canvas canvas, Offset pos) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(-math.pi / 4);

    // Glove drop shadow
    canvas.drawOval(
      const Rect.fromLTWH(0, 4, 30, 24),
      Paint()..color = Colors.black.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Glove white body
    final handPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(15, 12), 12, handPaint);

    // Index finger pointing
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(4, -14, 11, 20), const Radius.circular(6)),
      handPaint,
    );

    // Hand outline
    final strokePaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(const Offset(15, 12), 12, strokePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(4, -14, 11, 20), const Radius.circular(6)),
      strokePaint,
    );

    // Yellow glove cuff
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(3, 20, 24, 9), const Radius.circular(4)),
      Paint()..color = const Color(0xFFFFB300),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(3, 20, 24, 9), const Radius.circular(4)),
      strokePaint,
    );

    canvas.restore();
  }

  void _drawFloatingText(Canvas canvas, FloatingText ft) {
    double yOffset = -40.0 * ft.life;
    double scale = 1.0 + (math.sin(ft.life * math.pi) * 0.3);
    double opacity = (1.0 - ft.life).clamp(0.0, 1.0);

    canvas.save();
    canvas.translate(ft.position.dx, ft.position.dy + yOffset);
    canvas.scale(scale);

    final textSpan = TextSpan(
      text: ft.text,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: ft.color.withOpacity(opacity),
        shadows: [
          const Shadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 2),
          const Shadow(color: Colors.white, offset: Offset(2, -2), blurRadius: 2),
          const Shadow(color: Colors.white, offset: Offset(-2, 2), blurRadius: 2),
          const Shadow(color: Colors.white, offset: Offset(2, 2), blurRadius: 2),
          Shadow(color: Colors.black.withOpacity(0.2 * opacity), offset: const Offset(0, 3), blurRadius: 6),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EnhancedRingPainter oldDelegate) {
    return true;
  }
}

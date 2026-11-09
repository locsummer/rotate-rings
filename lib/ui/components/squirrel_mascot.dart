import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/game_colors.dart';

class SquirrelMascot extends StatefulWidget {
  final String? encouragement;
  const SquirrelMascot({super.key, this.encouragement});

  @override
  State<SquirrelMascot> createState() => _SquirrelMascotState();
}

class _SquirrelMascotState extends State<SquirrelMascot> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, _) {
        double bobbing = math.sin(_animCtrl.value * math.pi) * 4.0;
        return Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: [
            // Encouragement speech bubble
            if (widget.encouragement != null)
              Positioned(
                top: -30 + bobbing * 0.5,
                right: 25,
                child: _SpeechBubble(text: widget.encouragement!),
              ),

            // Squirrel character illustration
            Transform.translate(
              offset: Offset(0, bobbing),
              child: SizedBox(
                width: 110,
                height: 125,
                child: CustomPaint(
                  painter: _SquirrelPainter(animationVal: _animCtrl.value),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: GameColors.pastelSkyBlue, width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: GameColors.pastelRoyalBlue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SquirrelPainter extends CustomPainter {
  final double animationVal;
  _SquirrelPainter({required this.animationVal});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Bushy Tail in background (fluffy orange/brown curve)
    final tailPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFE87820), Color(0xFFC05510)],
      ).createShader(Rect.fromLTWH(-w * 0.2, h * 0.1, w * 0.7, h * 0.8));
    final tailPath = Path()
      ..moveTo(w * 0.2, h * 0.85)
      ..cubicTo(-w * 0.2, h * 0.6, -w * 0.15, h * 0.1, w * 0.15, h * 0.2)
      ..cubicTo(w * 0.35, h * 0.25, w * 0.3, h * 0.6, w * 0.3, h * 0.85)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // Body (warm squirrel fur)
    final bodyPaint = Paint()..color = const Color(0xFFE67E22);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.55, h * 0.75), width: w * 0.55, height: h * 0.45),
      bodyPaint,
    );

    // Blue denim overalls
    final overallsPaint = Paint()..color = const Color(0xFF2980B9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.55, h * 0.8), width: w * 0.45, height: h * 0.35),
        const Radius.circular(10),
      ),
      overallsPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFFF39C12);
    canvas.drawCircle(Offset(w * 0.6, h * 0.42), w * 0.26, headPaint);

    // Chubby cheeks (light peach fur)
    final cheekPaint = Paint()..color = const Color(0xFFFFE0B2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.52, h * 0.48), width: w * 0.22, height: h * 0.18),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.72, h * 0.48), width: w * 0.22, height: h * 0.18),
      cheekPaint,
    );

    // Cute ears with pink interior
    final earPaint = Paint()..color = const Color(0xFFD35400);
    final earInnerPaint = Paint()..color = const Color(0xFFFFAB91);
    // Left ear
    canvas.drawCircle(Offset(w * 0.42, h * 0.22), w * 0.09, earPaint);
    canvas.drawCircle(Offset(w * 0.42, h * 0.22), w * 0.05, earInnerPaint);
    // Right ear
    canvas.drawCircle(Offset(w * 0.78, h * 0.22), w * 0.09, earPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.22), w * 0.05, earInnerPaint);

    // Blue Artist Beret Hat
    final beretPaint = Paint()..color = const Color(0xFF1F618D);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.58, h * 0.22), width: w * 0.42, height: h * 0.18),
      beretPaint,
    );
    // Beret tip
    canvas.drawCircle(Offset(w * 0.58, h * 0.12), w * 0.04, beretPaint);

    // Big Sparkly Eyes
    final eyePaint = Paint()..color = const Color(0xFF2C3E50);
    final eyeShine = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.53, h * 0.39), w * 0.055, eyePaint);
    canvas.drawCircle(Offset(w * 0.515, h * 0.375), w * 0.022, eyeShine);

    canvas.drawCircle(Offset(w * 0.69, h * 0.39), w * 0.055, eyePaint);
    canvas.drawCircle(Offset(w * 0.675, h * 0.375), w * 0.022, eyeShine);

    // Tiny cute nose & smiling mouth
    final nosePaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.61, h * 0.45), width: w * 0.07, height: h * 0.045),
      nosePaint,
    );

    // Painter Palette in right paw
    final palettePaint = Paint()..color = const Color(0xFFE0BB85);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.88, h * 0.78), width: w * 0.26, height: h * 0.18),
      palettePaint,
    );
    // Colorful paint dabs on palette
    canvas.drawCircle(Offset(w * 0.82, h * 0.75), 3, Paint()..color = Colors.red);
    canvas.drawCircle(Offset(w * 0.88, h * 0.72), 3, Paint()..color = Colors.amber);
    canvas.drawCircle(Offset(w * 0.94, h * 0.76), 3, Paint()..color = Colors.blue);
    canvas.drawCircle(Offset(w * 0.88, h * 0.82), 3, Paint()..color = Colors.green);

    // Paintbrush in left paw
    final brushStick = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.32, h * 0.68), Offset(w * 0.22, h * 0.52), brushStick);
    canvas.drawCircle(Offset(w * 0.22, h * 0.52), 4, Paint()..color = const Color(0xFF3498DB));
  }

  @override
  bool shouldRepaint(covariant _SquirrelPainter oldDelegate) => true;
}

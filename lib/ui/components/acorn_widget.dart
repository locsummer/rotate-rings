import 'package:flutter/material.dart';

class AcornWidget extends StatelessWidget {
  final double size;
  const AcornWidget({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AcornPainter(),
    );
  }
}

class _AcornPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Nut Body (warm golden amber)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD043), Color(0xFFE59819)],
      ).createShader(Rect.fromLTWH(0, h * 0.35, w, h * 0.65))
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(w * 0.2, h * 0.45)
      ..cubicTo(w * 0.15, h * 0.75, w * 0.45, h * 0.98, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.55, h * 0.98, w * 0.85, h * 0.75, w * 0.8, h * 0.45)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Nut Cap (rich textured brown)
    final capPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9E5C23), Color(0xFF6B3C14)],
      ).createShader(Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.8, h * 0.35))
      ..style = PaintingStyle.fill;

    final capRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.76, h * 0.22),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(capRRect, capPaint);

    // Stem
    final stemPaint = Paint()
      ..color = const Color(0xFF532E0E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.1
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(w * 0.5, h * 0.28)
      ..quadraticBezierTo(w * 0.52, h * 0.12, w * 0.58, h * 0.08);
    canvas.drawPath(stemPath, stemPaint);

    // Subtle highlight shine on body
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.38, h * 0.62), width: w * 0.16, height: h * 0.22),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double alpha;
  double life;
  double maxLife;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.maxLife,
    this.alpha = 1.0,
    this.life = 0.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
  });

  bool update(double dt) {
    life += dt;
    if (life >= maxLife) return false;
    position += velocity * dt;
    velocity = Offset(velocity.dx * 0.96, velocity.dy * 0.96 + (180.0 * dt)); // Gravity
    rotation += rotationSpeed * dt;
    alpha = (1.0 - (life / maxLife)).clamp(0.0, 1.0);
    return true;
  }
}

class ParticleController extends ChangeNotifier {
  final List<Particle> particles = [];
  final math.Random _rng = math.Random();

  void spawnBurst(Offset origin, Color color, {int count = 18}) {
    List<Color> palette = [
      color,
      Colors.amber,
      Colors.white,
      color.withOpacity(0.8),
    ];

    for (int i = 0; i < count; i++) {
      double angle = _rng.nextDouble() * 2 * math.pi;
      double speed = 80.0 + _rng.nextDouble() * 220.0;
      particles.add(Particle(
        position: origin,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed - 60.0),
        color: palette[_rng.nextInt(palette.length)],
        size: 5.0 + _rng.nextDouble() * 7.0,
        maxLife: 0.6 + _rng.nextDouble() * 0.5,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 8.0,
      ));
    }
    notifyListeners();
  }

  void spawnRingBurst(Offset origin, Color color, {int count = 18}) {
    spawnBurst(origin, color, count: count);
  }

  void spawnVictoryConfetti(Size size, {int count = 70}) {
    List<Color> palette = [
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.amberAccent,
      Colors.greenAccent,
      Colors.deepOrangeAccent,
      Colors.purpleAccent,
    ];

    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        position: Offset(_rng.nextDouble() * size.width, -20),
        velocity: Offset((_rng.nextDouble() - 0.5) * 80.0, 120.0 + _rng.nextDouble() * 220.0),
        color: palette[_rng.nextInt(palette.length)],
        size: 6.0 + _rng.nextDouble() * 8.0,
        maxLife: 2.5 + _rng.nextDouble() * 1.5,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 10.0,
      ));
    }
    notifyListeners();
  }

  void update(double dt) {
    if (particles.isEmpty) return;
    particles.removeWhere((p) => !p.update(dt));
    notifyListeners();
  }
}

class ParticlePainter extends CustomPainter {
  final ParticleController controller;
  ParticlePainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in controller.particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.8),
          const Radius.circular(2.0),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class ParticleView extends StatelessWidget {
  final ParticleController controller;
  const ParticleView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(controller: controller),
        );
      },
    );
  }
}

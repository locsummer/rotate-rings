import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../storage/save_service.dart';
import '../theme/game_colors.dart';
import '../components/acorn_widget.dart';
import '../components/squirrel_mascot.dart';
import '../components/settings_dialog.dart';
import '../components/stats_dialog.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _logoAnim;

  @override
  void initState() {
    super.initState();
    _logoAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _logoAnim.dispose();
    super.dispose();
  }

  void _onPlay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(initialLevelNumber: SaveService.instance.currentLevel),
      ),
    ).then((_) => setState(() {}));
  }

  void _onLevelSelect() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
    ).then((_) => setState(() {}));
  }

  void _onSettings() {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(onChanged: () => setState(() {})),
    );
  }

  void _onStats() {
    showDialog(
      context: context,
      builder: (_) => const StatsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = SaveService.instance;

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background rings
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _logoAnim,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _HomeBgPainter(anim: _logoAnim.value),
                  );
                },
              ),
            ),

            // Top Status Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Acorns counter pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: GameColors.pillBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [GameColors.softShadow],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AcornWidget(size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "${s.acorns}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: GameColors.textDarkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stars counter pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: GameColors.pillBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [GameColors.softShadow],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: GameColors.starGold, size: 24),
                        const SizedBox(width: 6),
                        Text(
                          "${s.totalStarsEarned}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: GameColors.textDarkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings Button
                  InkWell(
                    onTap: _onSettings,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GameColors.backgroundCard,
                        shape: BoxShape.circle,
                        boxShadow: [GameColors.softShadow],
                      ),
                      child: const Icon(Icons.settings_rounded, color: GameColors.textDarkBrown, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Center Content: Logo & Menu
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Game Logo
                    AnimatedBuilder(
                      animation: _logoAnim,
                      builder: (context, _) {
                        return Transform.rotate(
                          angle: math.sin(_logoAnim.value * 2 * math.pi) * 0.04,
                          child: Column(
                            children: [
                              // Icon Graphic: Intersecting Pastel Rings
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: CustomPaint(
                                  painter: _LogoRingsPainter(anim: _logoAnim.value),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Game Title
                              const Text(
                                "ROTATE RINGS",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: GameColors.textDarkBrown,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(color: Color(0x33000000), offset: Offset(0, 3), blurRadius: 4),
                                  ],
                                ),
                              ),
                              const Text(
                                "Mở Khóa Không Gian & ASMR",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: GameColors.textMediumBrown,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 38),

                    // Play Button
                    _BigMenuButton(
                      label: "CHƠI TIẾP (MÀN ${s.currentLevel})",
                      icon: Icons.play_arrow_rounded,
                      color: GameColors.pastelGreen,
                      onPressed: _onPlay,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 14),

                    // Level Select Button
                    _BigMenuButton(
                      label: "CHỌN MÀN (200 MÀN)",
                      icon: Icons.grid_view_rounded,
                      color: GameColors.pastelSkyBlue,
                      onPressed: _onLevelSelect,
                    ),
                    const SizedBox(height: 14),

                    // Stats & Achievements Button
                    _BigMenuButton(
                      label: "BẢNG THÀNH TÍCH",
                      icon: Icons.emoji_events_rounded,
                      color: GameColors.pastelOrange,
                      onPressed: _onStats,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Squirrel Mascot
            const Positioned(
              bottom: 12,
              right: 18,
              child: SquirrelMascot(encouragement: "Sẵn sàng chưa?"),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _BigMenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: isPrimary ? 6 : 3,
          shadowColor: color.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoRingsPainter extends CustomPainter {
  final double anim;
  _LogoRingsPainter({required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    double spin = anim * 2 * math.pi;

    // Orange ring
    final p1 = Paint()
      ..color = GameColors.pastelOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c + const Offset(-12, -4), radius: 34),
      spin,
      4.8,
      false,
      p1,
    );

    // Blue ring
    final p2 = Paint()
      ..color = GameColors.pastelSkyBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c + const Offset(12, 6), radius: 34),
      -spin + 1.2,
      4.8,
      false,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoRingsPainter oldDelegate) => true;
}

class _HomeBgPainter extends CustomPainter {
  final double anim;
  _HomeBgPainter({required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFF1E9DB).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    // Subtle ambient background ring silhouettes
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 0.1, size.height * 0.25), radius: 100),
      anim * 2 * math.pi * 0.2,
      4.5,
      false,
      p,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 0.9, size.height * 0.75), radius: 130),
      -anim * 2 * math.pi * 0.15,
      4.2,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeBgPainter oldDelegate) => true;
}

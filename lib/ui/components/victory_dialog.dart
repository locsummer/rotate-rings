import 'package:flutter/material.dart';
import '../theme/game_colors.dart';
import 'acorn_widget.dart';

class VictoryDialog extends StatelessWidget {
  final int levelNumber;
  final int stars;
  final int moves;
  final int seconds;
  final int acornsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const VictoryDialog({
    super.key,
    required this.levelNumber,
    required this.stars,
    required this.moves,
    required this.seconds,
    required this.acornsEarned,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    String timeStr = "${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: GameColors.backgroundCard,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: GameColors.pastelOrange.withOpacity(0.4), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Header Banner
            const Text(
              "CHIẾN THẮNG!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: GameColors.textDarkBrown,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Màn $levelNumber Hoàn Tất",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: GameColors.textMediumBrown,
              ),
            ),
            const SizedBox(height: 20),

            // 3-Star Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                bool earned = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    earned ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: earned ? GameColors.starGold : Colors.grey.shade300,
                    size: 48,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Performance Stats Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: GameColors.pillBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: "Số Bước", value: "$moves"),
                  Container(width: 1, height: 32, color: GameColors.textMediumBrown.withOpacity(0.2)),
                  _StatItem(label: "Thời Gian", value: timeStr),
                  Container(width: 1, height: 32, color: GameColors.textMediumBrown.withOpacity(0.2)),
                  _StatItem(
                    label: "Hạt Dẻ",
                    value: "+$acornsEarned",
                    icon: const AcornWidget(size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                // Home Button
                _CircleActionButton(
                  icon: Icons.home_rounded,
                  color: Colors.grey.shade200,
                  iconColor: GameColors.textDarkBrown,
                  onTap: onHome,
                ),
                const SizedBox(width: 12),

                // Replay Button
                _CircleActionButton(
                  icon: Icons.refresh_rounded,
                  color: Colors.grey.shade200,
                  iconColor: GameColors.textDarkBrown,
                  onTap: onReplay,
                ),
                const SizedBox(width: 12),

                // Next Level Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameColors.pastelGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tiếp Theo",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Widget? icon;
  const _StatItem({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 4)],
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: GameColors.textDarkBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: GameColors.textMediumBrown,
          ),
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }
}

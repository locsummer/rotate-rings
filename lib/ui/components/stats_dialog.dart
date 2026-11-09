import 'package:flutter/material.dart';
import '../../storage/save_service.dart';
import '../theme/game_colors.dart';
import 'acorn_widget.dart';

class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SaveService.instance;
    int minutes = s.totalPlayTimeSeconds ~/ 60;
    int seconds = s.totalPlayTimeSeconds % 60;
    String playTime = "${minutes}m ${seconds}s";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        decoration: BoxDecoration(
          color: GameColors.backgroundCard,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Thành Tích",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: GameColors.textDarkBrown,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: GameColors.textMediumBrown),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _StatCard(
              title: "Màn Đã Hoàn Thành",
              value: "${s.completedLevelsCount} / 200",
              icon: Icons.check_circle_rounded,
              color: GameColors.pastelGreen,
            ),
            const SizedBox(height: 10),

            _StatCard(
              title: "Tổng Số Sao Đạt Được",
              value: "${s.totalStarsEarned} / 600",
              icon: Icons.star_rounded,
              color: GameColors.starGold,
            ),
            const SizedBox(height: 10),

            _StatCard(
              title: "Tổng Hạt Dẻ Thu Thập",
              value: "${s.acorns}",
              customIcon: const AcornWidget(size: 24),
              color: GameColors.pastelOrange,
            ),
            const SizedBox(height: 10),

            _StatCard(
              title: "Tổng Số Bước Xoay",
              value: "${s.totalMoves}",
              icon: Icons.rotate_right_rounded,
              color: GameColors.pastelSkyBlue,
            ),
            const SizedBox(height: 10),

            _StatCard(
              title: "Tổng Thời Gian Chơi",
              value: playTime,
              icon: Icons.timer_rounded,
              color: GameColors.pastelPurple,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Widget? customIcon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.icon,
    this.customIcon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: customIcon ?? Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GameColors.textMediumBrown,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: GameColors.textDarkBrown,
            ),
          ),
        ],
      ),
    );
  }
}

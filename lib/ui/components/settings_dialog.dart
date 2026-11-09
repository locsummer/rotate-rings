import 'package:flutter/material.dart';
import '../../audio/sound_service.dart';
import '../../storage/save_service.dart';
import '../theme/game_colors.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback onChanged;
  final VoidCallback? onReplay;
  final VoidCallback? onLevelSelect;

  const SettingsDialog({
    super.key,
    required this.onChanged,
    this.onReplay,
    this.onLevelSelect,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _sound;
  late bool _music;
  late bool _haptics;

  @override
  void initState() {
    super.initState();
    _sound = SoundService.instance.soundEnabled;
    _music = SoundService.instance.musicEnabled;
    _haptics = SoundService.instance.hapticsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF6EE),
          borderRadius: BorderRadius.circular(28),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tùy Chọn",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4E342E),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8D6E63), size: 26),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sound Effects Toggle
            _SettingRow(
              icon: Icons.volume_up_rounded,
              title: "Âm Thanh ASMR",
              value: _sound,
              onChanged: (val) {
                setState(() => _sound = val);
                SaveService.instance.setSound(val);
                widget.onChanged();
              },
            ),
            const Divider(height: 16),

            // Music Toggle
            _SettingRow(
              icon: Icons.music_note_rounded,
              title: "Nhạc Nền Thư Giãn",
              value: _music,
              onChanged: (val) {
                setState(() => _music = val);
                SaveService.instance.setMusic(val);
                widget.onChanged();
              },
            ),
            const Divider(height: 16),

            // Haptics Toggle
            _SettingRow(
              icon: Icons.vibration_rounded,
              title: "Rung Cảm Ứng",
              value: _haptics,
              onChanged: (val) {
                setState(() => _haptics = val);
                SaveService.instance.setHaptics(val);
                widget.onChanged();
              },
            ),
            const SizedBox(height: 20),

            // Action Buttons: Chơi lại & Chọn màn
            Row(
              children: [
                if (widget.onReplay != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onReplay!();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text("Chơi Lại", style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                  ),
                if (widget.onReplay != null && widget.onLevelSelect != null)
                  const SizedBox(width: 12),
                if (widget.onLevelSelect != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onLevelSelect!();
                      },
                      icon: const Icon(Icons.grid_view_rounded, size: 20),
                      label: const Text("Chọn Màn", style: TextStyle(fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4E342E),
                        side: const BorderSide(color: Color(0xFF8D6E63), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFF2E4D4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4E342E), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4E342E),
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: GameColors.pastelGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

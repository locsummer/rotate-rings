import 'package:flutter/material.dart';
import '../../storage/save_service.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final int? currentLevel;
  final ValueChanged<int>? onLevelSelected;

  const LevelSelectScreen({
    super.key,
    this.currentLevel,
    this.onLevelSelected,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _selectedTierIndex = 0;

  final List<_TierInfo> _tiers = [
    _TierInfo(title: "1–20", startLevel: 1, endLevel: 20, name: "Làm Quen"),
    _TierInfo(title: "21–40", startLevel: 21, endLevel: 40, name: "Hai Vòng"),
    _TierInfo(title: "41–60", startLevel: 41, endLevel: 60, name: "C-Lock & D-Ring"),
    _TierInfo(title: "61–80", startLevel: 61, endLevel: 80, name: "Mắt Xích Đan Xen"),
    _TierInfo(title: "81–100", startLevel: 81, endLevel: 100, name: "Ba Vòng"),
    _TierInfo(title: "101–130", startLevel: 101, endLevel: 130, name: "Khóa Hình Học"),
    _TierInfo(title: "131–160", startLevel: 131, endLevel: 160, name: "Nhiều Tầng"),
    _TierInfo(title: "161–180", startLevel: 161, endLevel: 180, name: "Khóa Lai Tạo"),
    _TierInfo(title: "181–200", startLevel: 181, endLevel: 200, name: "Bậc Thầy"),
  ];

  @override
  void initState() {
    super.initState();
    int cur = widget.currentLevel ?? SaveService.instance.currentLevel;
    for (int i = 0; i < _tiers.length; i++) {
      if (cur >= _tiers[i].startLevel && cur <= _tiers[i].endLevel) {
        _selectedTierIndex = i;
        break;
      }
    }
  }

  void _onLevelTap(int levelNum) {
    if (levelNum > SaveService.instance.maxUnlockedLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hãy hoàn thành các màn trước để mở khóa màn này!"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (widget.onLevelSelected != null) {
      Navigator.of(context).pop();
      widget.onLevelSelected!(levelNum);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameScreen(initialLevelNumber: levelNum),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = SaveService.instance;
    final currentTier = _tiers[_selectedTierIndex];
    int countInTier = currentTier.endLevel - currentTier.startLevel + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4E342E)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Column(
                    children: [
                      const Text(
                        "CHỌN MÀN CHƠI",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4E342E),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        currentTier.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ],
                  ),
                  // Acorns total
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E4D4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: Color(0xFFFFB300), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${s.acorns}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tier Selector Tabs
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _tiers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final t = _tiers[index];
                  final isSelected = index == _selectedTierIndex;
                  return ChoiceChip(
                    label: Text(t.title),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedTierIndex = index);
                    },
                    selectedColor: const Color(0xFFFFB300),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF4E342E),
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Level Grid (e.g. 4 columns)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemCount: countInTier,
                itemBuilder: (context, idx) {
                  int levelNum = currentTier.startLevel + idx;
                  bool isUnlocked = levelNum <= s.maxUnlockedLevel;
                  int stars = s.getStarsForLevel(levelNum);
                  bool isCurrent = levelNum == (widget.currentLevel ?? s.currentLevel);

                  return GestureDetector(
                    onTap: () => _onLevelTap(levelNum),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFFFE082)
                            : (isUnlocked ? Colors.white : const Color(0xFFECEFF1)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFFB300)
                              : (isUnlocked ? const Color(0xFFD7CCC8) : const Color(0xFFCFD8DC)),
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isUnlocked)
                            const Icon(Icons.lock_rounded, color: Colors.grey, size: 24)
                          else ...[
                            Text(
                              "$levelNum",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isCurrent ? const Color(0xFFE65100) : const Color(0xFF4E342E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Stars row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (starIdx) {
                                return Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: starIdx < stars ? const Color(0xFFFFB300) : const Color(0xFFE0E0E0),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierInfo {
  final String title;
  final int startLevel;
  final int endLevel;
  final String name;

  _TierInfo({
    required this.title,
    required this.startLevel,
    required this.endLevel,
    required this.name,
  });
}

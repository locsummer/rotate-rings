import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import '../audio/sound_service.dart';

class SaveService {
  static final SaveService instance = SaveService._();
  SaveService._();

  int currentLevel = 1;
  int maxUnlockedLevel = 1;
  int acorns = 0;
  Map<int, int> starsMap = {}; // levelNumber -> stars (1..3)
  int totalMoves = 0;
  int totalPlayTimeSeconds = 0;
  int completedLevelsCount = 0;

  bool _initialized = false;
  File? _saveFile;

  Future<void> init() async {
    if (_initialized) return;

    try {
      if (!kIsWeb) {
        // Safe cross-platform local path
        _saveFile = File('rotate_rings_save.json');
        if (await _saveFile!.exists()) {
          final content = await _saveFile!.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;
          currentLevel = data['currentLevel'] as int? ?? 1;
          maxUnlockedLevel = data['maxUnlockedLevel'] as int? ?? 1;
          acorns = data['acorns'] as int? ?? 0;
          totalMoves = data['totalMoves'] as int? ?? 0;
          totalPlayTimeSeconds = data['totalPlayTime'] as int? ?? 0;
          completedLevelsCount = data['completedCount'] as int? ?? 0;

          SoundService.instance.soundEnabled = data['soundEnabled'] as bool? ?? true;
          SoundService.instance.musicEnabled = data['musicEnabled'] as bool? ?? true;
          SoundService.instance.hapticsEnabled = data['hapticsEnabled'] as bool? ?? true;

          if (data['stars'] != null) {
            final stars = data['stars'] as Map<String, dynamic>;
            starsMap = stars.map((k, v) => MapEntry(int.parse(k), v as int));
          }
        }
      }
    } catch (_) {
      // In-memory defaults
    }

    // Integrity validation
    if (currentLevel < 1) currentLevel = 1;
    if (currentLevel > 200) currentLevel = 200;
    if (maxUnlockedLevel < 1) maxUnlockedLevel = 1;
    if (maxUnlockedLevel > 200) maxUnlockedLevel = 200;
    if (currentLevel > maxUnlockedLevel) maxUnlockedLevel = currentLevel;

    _initialized = true;
  }

  int getStarsForLevel(int level) => starsMap[level] ?? 0;
  int get totalStarsEarned => starsMap.values.fold(0, (sum, s) => sum + s);

  Future<void> saveLevelCompletion({
    required int levelNumber,
    required int stars,
    required int moves,
    required int seconds,
    required int acornsGained,
  }) async {
    totalMoves += moves;
    totalPlayTimeSeconds += seconds;
    acorns += acornsGained;

    int oldStars = starsMap[levelNumber] ?? 0;
    if (stars > oldStars) {
      starsMap[levelNumber] = stars;
    }

    if (levelNumber == maxUnlockedLevel && maxUnlockedLevel < 200) {
      maxUnlockedLevel = levelNumber + 1;
    }
    if (levelNumber < 200) {
      currentLevel = levelNumber + 1;
    }

    completedLevelsCount = starsMap.length;
    await _persist();
  }

  Future<void> selectLevel(int level) async {
    currentLevel = level.clamp(1, maxUnlockedLevel);
    await _persist();
  }

  Future<void> setSound(bool enabled) async {
    SoundService.instance.soundEnabled = enabled;
    await _persist();
  }

  Future<void> setMusic(bool enabled) async {
    SoundService.instance.musicEnabled = enabled;
    await _persist();
  }

  Future<void> setHaptics(bool enabled) async {
    SoundService.instance.hapticsEnabled = enabled;
    await _persist();
  }

  Future<void> _persist() async {
    if (kIsWeb || _saveFile == null) return;
    try {
      final data = {
        'currentLevel': currentLevel,
        'maxUnlockedLevel': maxUnlockedLevel,
        'acorns': acorns,
        'totalMoves': totalMoves,
        'totalPlayTime': totalPlayTimeSeconds,
        'completedCount': completedLevelsCount,
        'soundEnabled': SoundService.instance.soundEnabled,
        'musicEnabled': SoundService.instance.musicEnabled,
        'hapticsEnabled': SoundService.instance.hapticsEnabled,
        'stars': starsMap.map((k, v) => MapEntry(k.toString(), v)),
      };
      await _saveFile!.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}

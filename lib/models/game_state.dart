import 'level_data.dart';
import 'ring_model.dart';

class GameSessionState {
  LevelData currentLevel;
  int moves;
  int elapsedSeconds;
  int hintsUsed;
  int acornsCollected;
  bool isVictory;
  bool isPaused;
  String? activeHintRingId;
  double? activeHintTargetAngle;
  String? activeHintText;

  GameSessionState({
    required this.currentLevel,
    this.moves = 0,
    this.elapsedSeconds = 0,
    this.hintsUsed = 0,
    this.acornsCollected = 0,
    this.isVictory = false,
    this.isPaused = false,
    this.activeHintRingId,
    this.activeHintTargetAngle,
    this.activeHintText,
  });

  int get totalRings => currentLevel.rings.length;
  int get clearedRings => currentLevel.rings.where((r) => r.status == RingStatus.completed).length;
  double get progress => totalRings > 0 ? (clearedRings / totalRings) : 0.0;

  /// Calculate stars earned: 3 stars (perfect), 2 stars (good), 1 star (cleared)
  int calculateStars() {
    if (!isVictory) return 0;
    if (hintsUsed == 0 && moves <= currentLevel.targetMoves) {
      return 3;
    } else if (moves <= (currentLevel.targetMoves * 1.5).ceil()) {
      return 2;
    } else {
      return 1;
    }
  }

  void reset(LevelData freshLevel) {
    currentLevel = freshLevel.clone();
    moves = 0;
    elapsedSeconds = 0;
    hintsUsed = 0;
    acornsCollected = 0;
    isVictory = false;
    isPaused = false;
    activeHintRingId = null;
    activeHintTargetAngle = null;
    activeHintText = null;
  }
}

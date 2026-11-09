import 'ring_model.dart';
import 'joint_model.dart';

class LevelData {
  final int levelNumber;
  final String title;
  final String category;
  final int difficulty; // 1 to 5
  final List<RingModel> rings;
  final List<JointModel> joints;
  final int targetMoves;
  final int targetSeconds;
  final int totalAcorns;

  LevelData({
    required this.levelNumber,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.rings,
    required this.joints,
    required this.targetMoves,
    required this.targetSeconds,
    int? totalAcorns,
  }) : totalAcorns = totalAcorns ?? rings.where((r) => r.hasAcorn).length;

  LevelData clone() {
    return LevelData(
      levelNumber: levelNumber,
      title: title,
      category: category,
      difficulty: difficulty,
      rings: rings.map((r) => r.copyWith()).toList(),
      joints: joints.map((j) => j.copyWith()).toList(),
      targetMoves: targetMoves,
      targetSeconds: targetSeconds,
      totalAcorns: totalAcorns,
    );
  }
}

// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:rotate_rings/levels/level_catalog.dart';
import 'package:rotate_rings/physics/untangle_engine.dart';
import 'package:rotate_rings/solver/puzzle_solver.dart';

void main() {
  test('Simulate automated gameplay solution for all 200 levels', () {
    int solved = 0;
    List<int> failedLevels = [];

    for (int i = 1; i <= 200; i++) {
      final lvl = LevelCatalog.getLevel(i);
      bool done = false;
      for (int step = 0; step < 40; step++) {
        var res = UntangleEngine.checkAndReleaseCascade(lvl);
        if (res.puzzleComplete || lvl.rings.every((r) => r.isFreed)) {
          done = true;
          break;
        }
        var hint = PuzzleSolver.findNextMove(lvl);
        if (hint == null) break;
        var ring = lvl.rings.firstWhere((r) => r.id == hint.ringId);
        ring.currentAngle = hint.targetAngle;
      }
      var finalRes = UntangleEngine.checkAndReleaseCascade(lvl);
      if (done || finalRes.puzzleComplete || lvl.rings.every((r) => r.isFreed)) {
        solved++;
      } else {
        failedLevels.add(i);
      }
    }

    print('=== SOLVABILITY REPORT ===');
    print('Total Levels: 200');
    print('Solved to 100% completion: $solved');
    print('Failed levels: $failedLevels');

    expect(solved, 200, reason: "Levels failed: $failedLevels");
  });
}

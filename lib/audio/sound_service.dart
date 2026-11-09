import 'package:flutter/services.dart';

class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;

  void playTouch() {
    if (!soundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
    if (hapticsEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  void playRotateTick() {
    if (!soundEnabled) return;
    if (hapticsEnabled) {
      try {
        HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  void playTick() => playRotateTick();

  void playReleasePop() {
    if (!soundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
    if (hapticsEnabled) {
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  void playUnlock() => playReleasePop();
  void playSnap() => playReleasePop();

  void playAcornCollect() {
    if (!soundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
    if (hapticsEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  void playVictory() {
    if (!soundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    if (hapticsEnabled) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }
}

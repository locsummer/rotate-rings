import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/level_data.dart';
import '../../models/game_state.dart';
import '../../levels/level_catalog.dart';
import '../../solver/puzzle_solver.dart';
import '../../storage/save_service.dart';
import '../../audio/sound_service.dart';
import '../../physics/untangle_engine.dart';
import '../components/acorn_widget.dart';
import '../components/squirrel_mascot.dart';
import '../components/ring_canvas.dart';
import '../components/particle_system.dart';
import '../components/victory_dialog.dart';
import '../components/settings_dialog.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  final int? initialLevelNumber;
  const GameScreen({super.key, this.initialLevelNumber});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int _currentLevelNumber;
  late GameSessionState _session;
  final ParticleController _particleCtrl = ParticleController();

  Timer? _timer;
  String? _squirrelEncouragement;
  Timer? _encouragementTimer;

  // Hint state
  String? _hintRingId;
  double? _hintTargetAngle;
  bool? _hintIsClockwise;
  String? _hintMessage;

  // Booster states
  bool _isHammerMode = false;
  int _hammerCount = 5;
  int _hintCount = 5;

  @override
  void initState() {
    super.initState();
    _currentLevelNumber = widget.initialLevelNumber ?? SaveService.instance.currentLevel;
    if (_currentLevelNumber < 1) _currentLevelNumber = 1;
    _initLevel(_currentLevelNumber);
  }

  void _initLevel(int lvlNum) {
    LevelData freshLevel = LevelCatalog.getLevel(lvlNum);
    _session = GameSessionState(currentLevel: freshLevel);

    _hintRingId = null;
    _hintTargetAngle = null;
    _hintIsClockwise = null;
    _hintMessage = null;
    _isHammerMode = false;

    // Show initial tutorial hand for Level 1 automatically
    if (lvlNum == 1) {
      _onHint(silent: true);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_session.isVictory && !_session.isPaused && mounted) {
        setState(() {
          _session.elapsedSeconds++;
        });
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _encouragementTimer?.cancel();
    super.dispose();
  }

  void _onMoveMade() {
    setState(() {
      _session.moves++;
      // Clear hint after player makes a move
      _hintRingId = null;
      _hintTargetAngle = null;
      _hintIsClockwise = null;
      _hintMessage = null;
      _isHammerMode = false;
    });
  }

  void _onUntangleStep(UntangleResult result) {
    if (_isHammerMode) {
      setState(() {
        if (_hammerCount > 0) _hammerCount--;
        _isHammerMode = false;
        _hintMessage = null;
      });
    }

    if (result.freedRings.isNotEmpty) {
      _showEncouragement();
    }

    if (result.acornsGained > 0) {
      setState(() {
        _session.acornsCollected += result.acornsGained;
      });
    }

    if (result.puzzleComplete && !_session.isVictory) {
      _onLevelVictory();
    }
  }

  void _showEncouragement() {
    List<String> words = ["Great!", "Awesome!", "Nice Move!", "Perfect!", "Tuyệt Vời!"];
    words.shuffle();
    setState(() {
      _squirrelEncouragement = words.first;
    });

    _encouragementTimer?.cancel();
    _encouragementTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _squirrelEncouragement = null;
        });
      }
    });
  }

  Future<void> _onLevelVictory() async {
    _session.isVictory = true;
    _timer?.cancel();
    SoundService.instance.playVictory();

    // Spawn victory confetti
    final media = MediaQuery.of(context).size;
    _particleCtrl.spawnVictoryConfetti(media);

    int stars = _session.calculateStars();
    int acornsEarned = _session.acornsCollected + (stars * 5);

    await SaveService.instance.saveLevelCompletion(
      levelNumber: _currentLevelNumber,
      stars: stars,
      moves: _session.moves,
      seconds: _session.elapsedSeconds,
      acornsGained: acornsEarned,
    );

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => VictoryDialog(
          levelNumber: _currentLevelNumber,
          stars: stars,
          moves: _session.moves,
          seconds: _session.elapsedSeconds,
          acornsEarned: acornsEarned,
          onNextLevel: () {
            Navigator.of(context).pop();
            if (_currentLevelNumber < LevelCatalog.totalLevels) {
              setState(() {
                _currentLevelNumber++;
                _initLevel(_currentLevelNumber);
              });
            }
          },
          onReplay: () {
            Navigator.of(context).pop();
            _initLevel(_currentLevelNumber);
          },
          onHome: () {
            Navigator.of(context).pop();
            _openLevelSelect();
          },
        ),
      );
    });
  }

  void _onHint({bool silent = false}) {
    final hint = PuzzleSolver.findNextMove(_session.currentLevel);
    if (hint != null) {
      if (!silent) {
        SoundService.instance.playTouch();
      }
      setState(() {
        _isHammerMode = false;
        _hintRingId = hint.ringId;
        _hintTargetAngle = hint.targetAngle;
        _hintIsClockwise = hint.isClockwise;
        _hintMessage = hint.message;
        if (!silent && _hintCount > 0) _hintCount--;
      });
    }
  }

  void _onHammerToggle() {
    SoundService.instance.playTouch();
    if (_hammerCount <= 0 && !_isHammerMode) {
      setState(() {
        _hintMessage = "Hết búa rồi!";
      });
      return;
    }
    setState(() {
      _isHammerMode = !_isHammerMode;
      _hintRingId = null;
      _hintMessage = _isHammerMode ? "Chạm vào vòng bất kỳ để đập vỡ!" : null;
    });
  }

  void _onSettings() {
    showDialog(
      context: context,
      builder: (_) => SettingsDialog(
        onChanged: () => setState(() {}),
        onReplay: () => _initLevel(_currentLevelNumber),
        onLevelSelect: () => _openLevelSelect(),
      ),
    );
  }

  void _openLevelSelect() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelSelectScreen(
          currentLevel: _currentLevelNumber,
          onLevelSelected: (lvl) {
            setState(() {
              _currentLevelNumber = lvl;
              _initLevel(_currentLevelNumber);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int acornsTotal = SaveService.instance.acorns + _session.acornsCollected;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ===============================================================
            // TOP BAR: Level (Left) | Acorn Pill (Center) | Settings (Right)
            // ===============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Level Number
                  InkWell(
                    onTap: _openLevelSelect,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Level",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8D6E63),
                            ),
                          ),
                          Text(
                            "$_currentLevelNumber",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4E342E),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center: Rounded Acorn Pill Counter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E4D4),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AcornWidget(size: 26),
                        const SizedBox(width: 8),
                        Text(
                          "$acornsTotal",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Settings Gear Button
                  InkWell(
                    onTap: _onSettings,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF4EA),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                        border: Border.all(color: const Color(0xFFEFEBE9), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: Color(0xFF5D4037),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===============================================================
            // CENTRAL PLAYFIELD: Interactive 3D Puzzle Canvas
            // ===============================================================
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RingCanvas(
                      level: _session.currentLevel,
                      hintRingId: _hintRingId,
                      hintTargetAngle: _hintTargetAngle,
                      hintIsClockwise: _hintIsClockwise,
                      isHammerMode: _isHammerMode,
                      onMoveMade: _onMoveMade,
                      onUntangleStep: _onUntangleStep,
                      particleController: _particleCtrl,
                    ),
                  ),

                  // Floating Boosters: Hammer & Hint
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BoosterButton(
                          icon: Icons.lightbulb_rounded,
                          label: "Hint",
                          count: _hintCount,
                          isActive: _hintRingId != null,
                          activeColor: const Color(0xFFFFB300),
                          onTap: () => _onHint(),
                        ),
                        const SizedBox(height: 10),
                        _BoosterButton(
                          icon: Icons.hardware_rounded,
                          label: "Hammer",
                          count: _hammerCount,
                          isActive: _isHammerMode,
                          activeColor: const Color(0xFFE53935),
                          onTap: _onHammerToggle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===============================================================
            // BOTTOM BAR: Yellow Hill Banner + 3D Text + Squirrel Mascot
            // ===============================================================
            _YellowHillBanner(
              encouragement: _squirrelEncouragement,
              hintMessage: _hintMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _BoosterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _BoosterButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isActive ? Colors.white : const Color(0xFFE0E0E0),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isActive ? Colors.white : const Color(0xFF5D4037),
        ),
      ),
    );
  }
}

class _YellowHillBanner extends StatelessWidget {
  final String? encouragement;
  final String? hintMessage;

  const _YellowHillBanner({this.encouragement, this.hintMessage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 135,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Yellow Curved Hill Background
          Positioned.fill(
            child: CustomPaint(
              painter: _HillPainter(),
            ),
          ),

          // 3D Text Banner on Left: "XOAY ĐỂ MỞ KHÓA"
          const Positioned(
            left: 24,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Text3D(
                  text: "XOAY ĐỂ",
                  fontSize: 22,
                ),
                _Text3D(
                  text: "MỞ KHÓA",
                  fontSize: 26,
                ),
              ],
            ),
          ),

          // Squirrel Mascot standing on right of banner
          Positioned(
            right: 12,
            bottom: 6,
            child: SquirrelMascot(encouragement: encouragement),
          ),
        ],
      ),
    );
  }
}

class _Text3D extends StatelessWidget {
  final String text;
  final double fontSize;

  const _Text3D({required this.text, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: const Color(0xFFFFF9C4), // Cream / soft yellow fill
        letterSpacing: 1.2,
        shadows: const [
          // Extruded 3D shadow in rich chocolate brown
          Shadow(color: Color(0xFF4E342E), offset: Offset(0, 1), blurRadius: 0),
          Shadow(color: Color(0xFF4E342E), offset: Offset(0, 2), blurRadius: 0),
          Shadow(color: Color(0xFF4E342E), offset: Offset(0, 3), blurRadius: 0),
          Shadow(color: Color(0xFF3E2723), offset: Offset(0, 4), blurRadius: 2),
        ],
      ),
    );
  }
}

class _HillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Smooth wavy hill curve
    final path = Path();
    path.moveTo(0, 25);
    path.quadraticBezierTo(w * 0.45, 0, w, 20);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    // Warm golden yellow gradient
    final hillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFEE58), Color(0xFFFFCA28), Color(0xFFFFB300)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Drop shadow under hill
    canvas.drawPath(
      path.shift(const Offset(0, -3)),
      Paint()..color = const Color(0x18000000)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Hill fill
    canvas.drawPath(path, hillPaint);

    // Light top highlight line along the hill crest
    final crestPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final crestPath = Path();
    crestPath.moveTo(0, 25);
    crestPath.quadraticBezierTo(w * 0.45, 0, w, 20);
    canvas.drawPath(crestPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

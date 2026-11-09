import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'storage/save_service.dart';
import 'ui/theme/game_theme.dart';
import 'ui/screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SaveService.instance.init();
  runApp(const RotateRingsApp());
}

class RotateRingsApp extends StatelessWidget {
  const RotateRingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotate Rings',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.themeData,
      home: const GameScreen(),
    );
  }
}

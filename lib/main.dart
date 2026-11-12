import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/punhos_game.dart';
import 'ui/overlays.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const PunhosApp());
}

class PunhosApp extends StatelessWidget {
  const PunhosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Punhos de Rua',
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<PunhosGame>.controlled(
          gameFactory: PunhosGame.new,
          initialActiveOverlays: const ['title'],
          overlayBuilderMap: {
            'title': (BuildContext c, PunhosGame g) => TitleOverlay(game: g),
            'story': (BuildContext c, PunhosGame g) => StoryOverlay(game: g),
            'controls': (BuildContext c, PunhosGame g) => ControlsOverlay(game: g),
            'gameOver': (BuildContext c, PunhosGame g) => GameOverOverlay(game: g),
            'ending': (BuildContext c, PunhosGame g) => EndingOverlay(game: g),
          },
        ),
      ),
    );
  }
}

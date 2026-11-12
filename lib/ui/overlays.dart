import 'package:flutter/material.dart';

import '../game/game_enums.dart';
import '../game/levels/level_data.dart';
import '../game/punhos_game.dart';

const _gold = Color(0xFFFFD966);
const _mono = 'monospace';

class TitleOverlay extends StatelessWidget {
  const TitleOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x99000000),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('PUNHOS DE RUA', style: TextStyle(fontFamily: _mono, fontSize: 36, fontWeight: FontWeight.bold, color: _gold)),
          const SizedBox(height: 16),
          FilledButton(onPressed: game.startGame, child: const Text('COMEÇAR')),
        ],
      ),
    );
  }
}

/// Páginas de história antes de cada nível; toca para avançar.
class StoryOverlay extends StatefulWidget {
  const StoryOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  State<StoryOverlay> createState() => _StoryOverlayState();
}

class _StoryOverlayState extends State<StoryOverlay> {
  int _page = 0;

  void _next() {
    final pages = widget.game.level.storyPages;
    if (_page + 1 >= pages.length) {
      widget.game.beginPlay();
    } else {
      setState(() => _page++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TextScreen(lines: widget.game.level.storyPages[_page], onTap: _next, hint: 'toca para continuar');
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  Widget build(BuildContext context) {
    return _TextScreen(lines: ['FIM DE JOGO', '', 'PONTOS: ${game.player.score}'], onTap: game.startGame, hint: 'toca para jogar de novo');
  }
}

class EndingOverlay extends StatelessWidget {
  const EndingOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  Widget build(BuildContext context) {
    return _TextScreen(lines: Levels.endingLines(game.player.score), onTap: game.startGame, hint: 'toca para jogar de novo');
  }
}

class _TextScreen extends StatelessWidget {
  const _TextScreen({required this.lines, required this.onTap, required this.hint});
  final List<String> lines;
  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: const Color(0xDD05050F),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final l in lines)
              Text(
                l,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _mono,
                  fontSize: 16,
                  height: 1.4,
                  color: (l.startsWith('NÍVEL') || l.startsWith('VITÓRIA') || l.startsWith('FIM')) ? _gold : Colors.white,
                ),
              ),
            const SizedBox(height: 16),
            Text(hint, style: const TextStyle(fontFamily: _mono, fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/// Direcional à esquerda e botões de ação à direita (multitoque).
class ControlsOverlay extends StatelessWidget {
  const ControlsOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  Widget build(BuildContext context) {
    final input = game.input;
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: 12,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Hold('▲', (v) => input.up = v),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _Hold('◀', (v) => input.left = v),
                  const SizedBox(width: 48),
                  _Hold('▶', (v) => input.right = v),
                ]),
                _Hold('▼', (v) => input.down = v),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _Action('AGARRAR', () => game.player.onAction(GameAction.grab)),
              _Action('SALTO', () => game.player.onAction(GameAction.jump)),
              _Action('SOCO', () => game.player.onAction(GameAction.punch)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Hold extends StatelessWidget {
  const _Hold(this.label, this.onChange);
  final String label;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onChange(true),
      onPointerUp: (_) => onChange(false),
      onPointerCancel: (_) => onChange(false),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: const Color(0x55FFFFFF), borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onTap(),
      child: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: const BoxDecoration(color: Color(0xAAC0392B), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

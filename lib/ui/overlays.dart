import 'package:flutter/material.dart';

import '../game/components/player.dart';
import '../game/game_enums.dart';
import '../game/levels/level_data.dart';
import '../game/punhos_game.dart';

const _gold = Color(0xFFFFD966);
const _mono = 'monospace';

/// Ecrã inicial: escolher o lutador.
class TitleOverlay extends StatelessWidget {
  const TitleOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  Widget build(BuildContext context) {
    return _Illustrated(
      image: 'assets/images/titulo.jpg',
      shade: const Color(0xCC05050F),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Outlined('PUNHOS DE RUA', size: 34, color: _gold),
              const SizedBox(height: 4),
              const Text('ESCOLHE O TEU LUTADOR', style: TextStyle(fontFamily: _mono, fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final h in PlayerHero.values) _HeroCard(hero: h, onTap: () => game.startGame(h)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.hero, required this.onTap});
  final PlayerHero hero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: _gold, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Color(0x88FFD966), blurRadius: 12)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              width: 120,
              child: switch (hero.portrait) {
                null => Image.asset(hero.image, fit: BoxFit.cover, alignment: Alignment(hero.imageFocusX, 0), filterQuality: FilterQuality.none),
                final String p => Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(hero.image, fit: BoxFit.cover, alignment: Alignment(hero.imageFocusX, 0), filterQuality: FilterQuality.none),
                      const ColoredBox(color: Color(0x99000000)),
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 6),
                        child: Image.asset(p, fit: BoxFit.contain, alignment: Alignment.bottomCenter, filterQuality: FilterQuality.none),
                      ),
                    ],
                  ),
              },
            ),
            Container(
              width: double.infinity,
              color: const Color(0xEE120C18),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  Text(hero.displayName, style: const TextStyle(fontFamily: _mono, fontSize: 16, fontWeight: FontWeight.bold, color: _gold)),
                  Text(hero.tagline, style: const TextStyle(fontFamily: _mono, fontSize: 9, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Páginas de história antes de cada nível, sobre a ilustração do cenário; toca para avançar.
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
    final game = widget.game;
    final name = game.player.hero.name;
    return _TextScreen(
      image: game.level.image,
      focusX: game.level.imageFocusX,
      lines: [for (final l in game.level.storyPages[_page]) l.replaceAll('{HEROI}', name)],
      onTap: _next,
      hint: 'toca para continuar',
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  Widget build(BuildContext context) {
    return _TextScreen(
      image: game.level.image,
      focusX: game.level.imageFocusX,
      lines: ['FIM DE JOGO', '', 'PONTOS: ${game.player.score}'],
      onTap: game.startGame,
      hint: 'toca para jogar de novo',
    );
  }
}

class EndingOverlay extends StatelessWidget {
  const EndingOverlay({super.key, required this.game});
  final PunhosGame game;

  @override
  Widget build(BuildContext context) {
    return _TextScreen(
      image: game.player.hero.image,
      focusX: game.player.hero.imageFocusX,
      lines: Levels.endingLines(game.player.score, game.player.hero.name),
      onTap: game.backToTitle,
      hint: 'toca para voltar ao início',
    );
  }
}

/// Ilustração a ecrã inteiro com uma camada escura por cima.
class _Illustrated extends StatelessWidget {
  const _Illustrated({required this.image, required this.child, this.shade = const Color(0x99000000)});
  final String image;
  final Widget child;
  final Color shade;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF05050F)),
        Image.asset(image, fit: BoxFit.cover, filterQuality: FilterQuality.none),
        ColoredBox(color: shade),
        child,
      ],
    );
  }
}

/// Texto com contorno escuro, para se ler sobre as ilustrações.
class _Outlined extends StatelessWidget {
  const _Outlined(this.text, {this.size = 16, this.color = Colors.white});
  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontFamily: _mono, fontSize: size, height: 1.4, fontWeight: size > 20 ? FontWeight.bold : FontWeight.normal);
    return Stack(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color(0xFF05050F),
          ),
        ),
        Text(text, textAlign: TextAlign.center, style: base.copyWith(color: color)),
      ],
    );
  }
}

/// Texto à esquerda e a ilustração (recortada à volta da personagem) à direita.
class _TextScreen extends StatelessWidget {
  const _TextScreen({required this.image, required this.focusX, required this.lines, required this.onTap, required this.hint});
  final String image;
  final double focusX;
  final List<String> lines;
  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ColoredBox(
        color: const Color(0xFF05050F),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final l in lines)
                        Text(
                          l,
                          style: TextStyle(
                            fontFamily: _mono,
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: _isHeading(l) ? FontWeight.bold : FontWeight.normal,
                            color: _isHeading(l) ? _gold : Colors.white,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(hint, style: const TextStyle(fontFamily: _mono, fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(image, fit: BoxFit.cover, alignment: Alignment(focusX, 0), filterQuality: FilterQuality.none),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF05050F), Color(0x0005050F)], stops: [0, .25]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isHeading(String l) => l.startsWith('NÍVEL') || l.startsWith('VITÓRIA') || l.startsWith('FIM') || l.startsWith('NOVA IORQUE');
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

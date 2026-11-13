import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/text.dart';

import '../game_enums.dart';
import 'enemy.dart';
import '../punhos_game.dart';

/// Vida, vidas, pontos, arma, barra do chefe e seta "IR".
class Hud extends PositionComponent with HasGameReference<PunhosGame> {
  Hud() : super(priority: 100);

  static final TextPaint _small = TextPaint(style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 9, fontFamily: 'monospace'));
  static final TextPaint _big = TextPaint(style: const TextStyle(color: Color(0xFFFFD966), fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold));

  @override
  void render(Canvas canvas) {
    if (game.phase != GamePhase.playing) return;
    final p = game.player;
    final w = game.viewWidth;

    canvas.drawRect(const Rect.fromLTWH(6, 5, 78, 9), Paint()..color = const Color(0xFF000000));
    for (var i = 0; i < p.maxHp; i++) {
      canvas.drawRect(Rect.fromLTWH(8.0 + i * 6, 7, 5, 5), Paint()..color = i < p.hp ? const Color(0xFF3DDC84) : const Color(0xFF333333));
    }
    _small.render(canvas, 'x${math.max(0, p.lives)}', Vector2(90, 5));
    _small.render(canvas, 'PONTOS ${p.score}', Vector2(w - 6, 5), anchor: Anchor.topRight);
    if (p.weapon != null) {
      final name = p.weapon == Weapon.knife ? 'FACA' : 'TACO';
      _small.render(canvas, '$name ${p.weaponUses}', Vector2(w - 6, 16), anchor: Anchor.topRight);
    }
    for (final e in game.enemies) {
      if (e.kind.isBoss && !e.defeated) {
        final ratio = math.max(0, e.hp) / e.maxHp;
        canvas.drawRect(Rect.fromLTWH(w - 86, 28, 80, 7), Paint()..color = const Color(0xFF000000));
        canvas.drawRect(Rect.fromLTWH(w - 85, 29, 78 * ratio, 5), Paint()..color = const Color(0xFFE74C3C));
        break;
      }
    }
    if (game.showGo && !game.locked && (game.frame >> 4).isOdd) {
      _big.render(canvas, 'IR ▶', Vector2(w - 34, 50), anchor: Anchor.topCenter);
    }
  }
}

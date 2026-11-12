import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/game_config.dart';
import '../levels/level_data.dart';
import '../punhos_game.dart';

const _neon = [Color(0xFFFF3D81), Color(0xFF3DF0FF), Color(0xFF8AFF3D), Color(0xFFFFB03D)];

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

/// Cenário em camadas com paralaxe, névoa, néon e luz. Tudo desenhado por código.
class Background extends PositionComponent with HasGameReference<PunhosGame> {
  Background() : super(priority: -100);

  @override
  void render(Canvas canvas) {
    final lv = game.level;
    final w = game.viewWidth;
    final cam = game.cameraX;
    final t = game.frame / 60;
    final rooftop = game.levelIndex == 2;

    _sky(canvas, lv, w, t);
    _skyline(canvas, w, cam, .10, 38, 88, 30, 42, lv.far, false, t);
    _fog(canvas, w, 50, 92, lv.sky.last.withAlpha(110));
    _skyline(canvas, w, cam, .28, 46, 96, 36, 38, lv.mid, true, t);
    _fog(canvas, w, 70, 100, lv.sky.last.withAlpha(70));
    if (rooftop) {
      _parapet(canvas, w, cam);
    } else {
      _storefronts(canvas, lv, w, cam, t);
    }
    _ground(canvas, lv, w, cam);
    _lamps(canvas, w, cam);
  }

  void _sky(Canvas canvas, LevelData lv, double w, double t) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 112),
      Paint()..shader = Gradient.linear(Offset.zero, const Offset(0, 105), lv.sky, const [0, .55, 1]),
    );
    final star = Paint();
    for (var i = 0; i < 40; i++) {
      final tw = .4 + .6 * math.sin(t * 2 + i * 1.7).abs();
      star.color = Color.fromRGBO(255, 255, 255, .7 * tw);
      canvas.drawRect(Rect.fromLTWH((i * 97.0) % w, (i * 53.0) % 62, 1, 1), star);
    }
    final m = Offset(w - 70, 30);
    canvas.drawCircle(m, 44, Paint()..shader = Gradient.radial(m, 44, const [Color(0xCCFFF0C8), Color(0x00FFC896)], const [.15, 1]));
    canvas.drawCircle(m, 9, Paint()..color = const Color(0xFFFFF3D0));
    final crater = Paint()..color = const Color(0x22B09060);
    canvas.drawCircle(m + const Offset(-2.5, -1.5), 2, crater);
    canvas.drawCircle(m + const Offset(3, 2.5), 1.5, crater);
    final cloud = Paint()
      ..color = Color.fromRGBO(255, 255, 255, .07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (var i = 0; i < 3; i++) {
      final x = ((i * 150 + t * 4) % (w + 160)) - 80;
      canvas.drawOval(Rect.fromCenter(center: Offset(x, 22 + i * 16), width: 90, height: 9), cloud);
    }
  }

  void _fog(Canvas canvas, double w, double y0, double y1, Color c) {
    canvas.drawRect(
      Rect.fromLTWH(0, y0, w, y1 - y0),
      Paint()..shader = Gradient.linear(Offset(0, y0), Offset(0, y1), [c.withAlpha(0), c]),
    );
  }

  void _skyline(Canvas canvas, double w, double cam, double speed, double bw, double base, double minH, double varH, Color color, bool windows, double t) {
    final n0 = (cam * speed / bw).floor();
    final lit = Paint()..color = const Color(0xFFFFD27A);
    final blue = Paint()..color = const Color(0xFF7AD7FF);
    final line = Paint()..color = const Color(0xFF0A0814);
    for (var i = -1; i <= w / bw + 1; i++) {
      final n = n0 + i;
      final h = minH + (n * 2654435761).abs() % varH;
      final bx = n * bw - cam * speed;
      canvas.drawRect(
        Rect.fromLTWH(bx, base - h, bw - 3, h),
        Paint()..shader = Gradient.linear(Offset(0, base - h), Offset(0, base), [_mix(color, const Color(0xFFFFFFFF), .1), color]),
      );
      canvas.drawRect(Rect.fromLTWH(bx, base - h, bw - 3, 1), Paint()..color = const Color(0x22FFFFFF));
      if (n % 5 == 0) {
        canvas.drawRect(Rect.fromLTWH(bx + 6, base - h - 8, 8, 8), line);
        canvas.drawRect(Rect.fromLTWH(bx + 5, base - h - 10, 10, 2), line);
      } else if (n % 3 == 0) {
        canvas.drawRect(Rect.fromLTWH(bx + bw / 2, base - h - 12, 1, 12), line);
      }
      if (!windows) continue;
      for (var j = 0; j < (h - 8) / 10; j++) {
        for (var q = 0; q < 2; q++) {
          final on = (n * 7 + j * 3 + q * 5) % 4 > 0 && ((n + j) * 11 + (t * 1.5).floor()) % 29 != 0;
          if (on) {
            canvas.drawRect(Rect.fromLTWH(bx + 5 + q * (bw - 17), base - h + 6 + j * 10, 5, 5), (n + j + q) % 5 == 0 ? blue : lit);
          }
        }
      }
    }
  }

  void _storefronts(Canvas canvas, LevelData lv, double w, double cam, double t) {
    const bw = 70.0;
    final n0 = (cam * .7 / bw).floor();
    for (var i = -1; i <= w / bw + 1; i++) {
      final n = n0 + i;
      final bx = n * bw - cam * .7;
      final neon = _neon[((n % 4) + 4) % 4];
      canvas.drawRect(
        Rect.fromLTWH(bx, 52, bw - 2, 48),
        Paint()..shader = Gradient.linear(const Offset(0, 52), const Offset(0, 100), [_mix(lv.mid, const Color(0xFF000000), .15), _mix(lv.mid, const Color(0xFF000000), .6)]),
      );
      // letreiro de néon com brilho
      final sign = Rect.fromLTWH(bx + 10, 58, bw - 22, 7);
      final flick = (math.sin(t * 7 + n * 3) > .96) ? .4 : 1.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(sign.inflate(1), const Radius.circular(3)),
        Paint()
          ..color = neon.withAlpha((120 * flick).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(sign, const Radius.circular(3)), Paint()..color = _mix(neon, const Color(0xFFFFFFFF), .35).withAlpha((255 * flick).round()));
      // toldo às riscas
      final awning = _mix(lv.mid, neon, .55);
      for (var s = 0; s < 6; s++) {
        canvas.drawRect(Rect.fromLTWH(bx + 4 + s * 10, 74, 10, 6), Paint()..color = s.isEven ? awning : _mix(awning, const Color(0xFFFFFFFF), .55));
      }
      canvas.drawRect(Rect.fromLTWH(bx + 4, 80, bw - 10, 2), Paint()..color = const Color(0x55000000));
      // montra iluminada
      final win = Rect.fromLTWH(bx + 8, 83, bw - 18, 17);
      canvas.drawRect(win, Paint()..shader = Gradient.linear(win.topCenter, win.bottomCenter, const [Color(0xFFFFCF7A), Color(0xFFA8602A)]));
      canvas.drawRect(Rect.fromLTWH(bx + bw / 2 - 5, 83, 2, 17), Paint()..color = const Color(0xFF1A1224));
      canvas.drawRect(Rect.fromLTWH(bx + 14, 92, 6, 8), Paint()..color = const Color(0x66000000));
    }
  }

  void _parapet(Canvas canvas, double w, double cam) {
    canvas.drawRect(
      Rect.fromLTWH(0, 88, w, 14),
      Paint()..shader = Gradient.linear(const Offset(0, 88), const Offset(0, 102), const [Color(0xFF4A5068), Color(0xFF262A3A)]),
    );
    canvas.drawRect(Rect.fromLTWH(0, 88, w, 2), Paint()..color = const Color(0x55FFFFFF));
    final n0 = (cam * .7 / 120).floor();
    for (var n = n0 - 1; n <= n0 + w / 120 + 1; n++) {
      final x = n * 120.0 - cam * .7;
      canvas.drawRect(Rect.fromLTWH(x + 20, 72, 30, 16), Paint()..color = const Color(0xFF2C3146));
      for (var v = 0; v < 4; v++) {
        canvas.drawRect(Rect.fromLTWH(x + 24 + v * 6, 75, 3, 9), Paint()..color = const Color(0xFF1A1E2E));
      }
      if (n.isEven) canvas.drawRect(Rect.fromLTWH(x + 80, 60, 8, 28), Paint()..color = const Color(0xFF2C3146));
    }
  }

  void _ground(Canvas canvas, LevelData lv, double w, double cam) {
    // passeio com lajes
    canvas.drawRect(
      Rect.fromLTWH(0, 100, w, 12),
      Paint()..shader = Gradient.linear(const Offset(0, 100), const Offset(0, 112), const [Color(0xFF6D6A7A), Color(0xFF4A4858)]),
    );
    final tile = Paint()..color = const Color(0x33000000);
    final off = cam % 24;
    for (var x = -off; x < w; x += 24) {
      canvas.drawRect(Rect.fromLTWH(x, 100, 1, 12), tile);
    }
    canvas.drawRect(Rect.fromLTWH(0, 111, w, 1.5), Paint()..color = const Color(0xFF9A97A8));
    // objetos do passeio
    final n0 = (cam / 260).floor();
    for (var n = n0; n <= n0 + w / 260 + 1; n++) {
      final x = n * 260.0 + 130 - cam;
      if (n.isEven) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, 94, 11, 15), const Radius.circular(2)), Paint()..color = const Color(0xFF3B4A44));
        canvas.drawRect(Rect.fromLTWH(x - 1, 93, 13, 3), Paint()..color = const Color(0xFF55675F));
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 2, 98, 6, 11), const Radius.circular(2)), Paint()..color = const Color(0xFFC0392B));
        canvas.drawRect(Rect.fromLTWH(x + 1, 97, 8, 2), Paint()..color = const Color(0xFFE05A4A));
      }
    }
    // estrada
    canvas.drawRect(
      Rect.fromLTWH(0, 112, w, GameConfig.viewHeight - 112),
      Paint()..shader = Gradient.linear(const Offset(0, 112), const Offset(0, GameConfig.viewHeight), lv.road),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 112, w, 14),
      Paint()..shader = Gradient.linear(const Offset(0, 112), const Offset(0, 126), const [Color(0x33000000), Color(0x00000000)]),
    );
    final dash = Paint()..color = const Color(0x73F0E6C8);
    final off2 = cam % 48;
    for (var x = -off2; x < w; x += 48) {
      canvas.drawRect(Rect.fromLTWH(x, 145, 24, 2), dash);
    }
    canvas.drawRect(Rect.fromLTWH(0, 176, w, 1), Paint()..color = const Color(0x22FFFFFF));
  }

  void _lamps(Canvas canvas, double w, double cam) {
    final n0 = (cam / 180).floor();
    for (var n = n0; n <= n0 + 3; n++) {
      final lx = n * 180.0 + 60 - cam;
      final head = Offset(lx + 9, 54);
      final pole = Paint()..color = const Color(0xFF1B1624);
      canvas.drawRect(Rect.fromLTWH(lx, 50, 2, 52), pole);
      canvas.drawRect(Rect.fromLTWH(lx, 50, 10, 2), pole);
      // cone de luz
      final cone = Path()
        ..moveTo(head.dx - 2, 56)
        ..lineTo(head.dx + 2, 56)
        ..lineTo(head.dx + 24, 112)
        ..lineTo(head.dx - 24, 112)
        ..close();
      canvas.drawPath(
        cone,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = Gradient.linear(head, Offset(head.dx, 112), const [Color(0x40FFDC96), Color(0x00FFDC96)]),
      );
      canvas.drawCircle(
        head,
        26,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = Gradient.radial(head, 26, const [Color(0x99FFDC96), Color(0x00FFC878)]),
      );
      canvas.drawCircle(head, 2.2, Paint()..color = const Color(0xFFFFF3C8));
      // poça de luz na estrada
      canvas.save();
      canvas.translate(head.dx, 132);
      canvas.scale(1, .26);
      canvas.drawCircle(
        Offset.zero,
        58,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = Gradient.radial(Offset.zero, 58, const [Color(0x55FFD28C), Color(0x00FFC878)]),
      );
      canvas.restore();
    }
  }
}

/// Escurece ligeiramente os cantos do ecrã para dar profundidade.
class Vignette extends PositionComponent with HasGameReference<PunhosGame> {
  Vignette() : super(priority: 90);

  @override
  void render(Canvas canvas) {
    final w = game.viewWidth;
    final c = Offset(w / 2, 90);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, GameConfig.viewHeight),
      Paint()..shader = Gradient.radial(c, w * .62, const [Color(0x00000000), Color(0x7A000000)], const [.55, 1]),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/text.dart';

import '../../core/game_config.dart';
import '../game_enums.dart';
import '../levels/level_data.dart';
import '../punhos_game.dart';

const _neon = [Color(0xFFFF3D81), Color(0xFF3DF0FF), Color(0xFF8AFF3D), Color(0xFFFFB03D)];

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

/// Imagens de um cenário: camada principal e, opcionalmente, um fundo mais lento.
class SceneryImages {
  const SceneryImages(this.main, this.far);
  final String main;
  final String? far;
}

/// Cenário em camadas com paralaxe. Usa as imagens de assets/images/cenarios/
/// quando existem; caso contrário desenha névoa, néon e luz por código.
class Background extends PositionComponent with HasGameReference<PunhosGame> {
  Background() : super(priority: -100);

  @override
  void render(Canvas canvas) {
    final lv = game.level;
    final w = game.viewWidth;
    final cam = game.cameraX;
    final t = game.frame / 60;

    final imgs = game.sceneryImages[lv.scene];
    if (imgs != null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, GameConfig.viewHeight), Paint()..color = lv.sky.first);
      final far = imgs.far;
      if (far != null) _imageLayer(canvas, game.images.fromCache(far), w, cam * .3);
      _imageLayer(canvas, game.images.fromCache(imgs.main), w, cam);
      return;
    }

    switch (lv.scene) {
      case Scenery.newYork:
        _sky(canvas, lv, w, t);
        _skyline(canvas, w, cam, .10, 30, 88, 40, 50, lv.far, false, t, spires: true);
        _fog(canvas, w, 50, 92, lv.sky.last.withAlpha(90));
        _skyline(canvas, w, cam, .28, 46, 96, 36, 38, _mix(lv.far, const Color(0xFF000000), .2), true, t);
        _newYorkFront(canvas, lv, w, cam, t);
        _ground(canvas, lv, w, cam);
        _lamps(canvas, w, cam);
      case Scenery.london:
        _sky(canvas, lv, w, t, moon: false);
        _clockTower(canvas, w, cam);
        _skyline(canvas, w, cam, .10, 44, 90, 20, 22, lv.far, false, t);
        _fog(canvas, w, 40, 96, const Color(0x55A89CB0));
        _londonFront(canvas, lv, w, cam, t);
        _fog(canvas, w, 80, 104, const Color(0x40C8C0D0));
        _ground(canvas, lv, w, cam);
        _lamps(canvas, w, cam);
      case Scenery.europeNight:
        _sky(canvas, lv, w, t);
        _oldTown(canvas, lv, w, cam);
        _river(canvas, lv, w, cam, t);
        _europeFront(canvas, lv, w, cam, t);
        _ground(canvas, lv, w, cam, cobbles: true);
        _lamps(canvas, w, cam, gas: true);
      case Scenery.diner:
        _sky(canvas, lv, w, t, moon: false, sun: true);
        _mesas(canvas, lv, w, cam);
        _palms(canvas, w, cam);
        _dinerFront(canvas, lv, w, cam, t);
        _ground(canvas, lv, w, cam);
        _lamps(canvas, w, cam, light: const Color(0xFFFF7AB0));
    }
  }

  static final TextPaint _signText = TextPaint(style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 5, fontFamily: 'monospace', fontWeight: FontWeight.bold));
  static final TextPaint _pubText = TextPaint(style: const TextStyle(color: Color(0xFFD9B45A), fontSize: 4.5, fontFamily: 'serif', fontWeight: FontWeight.bold));
  static final TextPaint _neonText = TextPaint(style: const TextStyle(color: Color(0xFFFFD0E4), fontSize: 11, fontFamily: 'serif', fontStyle: FontStyle.italic, fontWeight: FontWeight.bold));

  /// Percorre blocos de largura [bw] numa camada com paralaxe [speed].
  void _tiles(double w, double cam, double speed, double bw, void Function(int n, double x) draw) {
    final n0 = (cam * speed / bw).floor();
    for (var i = -1; i <= w / bw + 1; i++) {
      final n = n0 + i;
      draw(n, n * bw - cam * speed);
    }
  }

  static final Paint _pixels = Paint()..filterQuality = FilterQuality.none;

  /// Desenha uma imagem com a altura do ecrã, repetida na horizontal e deslocada [offset].
  void _imageLayer(Canvas canvas, Image img, double w, double offset) {
    final k = GameConfig.viewHeight / img.height;
    final tw = img.width * k;
    final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    for (var x = -(offset % tw); x < w; x += tw) {
      // +0.5 evita uma linha fina entre repetições
      canvas.drawImageRect(img, src, Rect.fromLTWH(x, 0, tw + .5, GameConfig.viewHeight), _pixels);
    }
  }

  static int _hash(int n) => (n * 2654435761).abs();

  void _sky(Canvas canvas, LevelData lv, double w, double t, {bool moon = true, bool sun = false}) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 112),
      Paint()..shader = Gradient.linear(Offset.zero, const Offset(0, 105), lv.sky, const [0, .55, 1]),
    );
    if (sun) {
      final c = Offset(w * .3, 86);
      canvas.drawCircle(c, 60, Paint()..shader = Gradient.radial(c, 60, const [Color(0x99FFD27A), Color(0x00FFB35A)]));
      canvas.drawCircle(c, 20, Paint()..color = const Color(0xFFFFD27A));
      for (var i = 0; i < 4; i++) {
        canvas.drawRect(Rect.fromLTWH(c.dx - 22, c.dy - 6 + i * 4.5, 44, 1.6), Paint()..color = lv.sky[1].withAlpha(200));
      }
      return;
    }
    final star = Paint();
    for (var i = 0; i < 40; i++) {
      final tw = .4 + .6 * math.sin(t * 2 + i * 1.7).abs();
      star.color = Color.fromRGBO(255, 255, 255, .7 * tw);
      canvas.drawRect(Rect.fromLTWH((i * 97.0) % w, (i * 53.0) % 62, 1, 1), star);
    }
    if (moon) {
      final m = Offset(w - 70, 30);
      canvas.drawCircle(m, 44, Paint()..shader = Gradient.radial(m, 44, const [Color(0xCCFFF0C8), Color(0x00FFC896)], const [.15, 1]));
      canvas.drawCircle(m, 9, Paint()..color = const Color(0xFFFFF3D0));
      final crater = Paint()..color = const Color(0x22B09060);
      canvas.drawCircle(m + const Offset(-2.5, -1.5), 2, crater);
      canvas.drawCircle(m + const Offset(3, 2.5), 1.5, crater);
    }
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

  void _skyline(Canvas canvas, double w, double cam, double speed, double bw, double base, double minH, double varH, Color color, bool windows, double t, {bool spires = false}) {
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
      if (spires && n % 4 == 1) {
        // arranha-céu com agulha (estilo art déco)
        final top = Paint()..color = _mix(color, const Color(0xFFFFFFFF), .1);
        canvas.drawPath(
          Path()
            ..moveTo(bx + 3, base - h)
            ..lineTo(bx + (bw - 3) / 2, base - h - 16)
            ..lineTo(bx + bw - 6, base - h)
            ..close(),
          top,
        );
        canvas.drawRect(Rect.fromLTWH(bx + (bw - 3) / 2 - .5, base - h - 26, 1, 12), top);
      } else if (n % 5 == 0) {
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

  /// Loja com letreiro de néon, toldo e montra (rés-do-chão de Nova Iorque).
  void _shop(Canvas canvas, LevelData lv, double bx, double bw, int n, double t) {
    final neon = _neon[((n % 4) + 4) % 4];
    final sign = Rect.fromLTWH(bx + 10, 70, bw - 22, 5);
    final flick = (math.sin(t * 7 + n * 3) > .96) ? .4 : 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(sign.inflate(1), const Radius.circular(3)),
      Paint()
        ..color = neon.withAlpha((120 * flick).round())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(RRect.fromRectAndRadius(sign, const Radius.circular(3)), Paint()..color = _mix(neon, const Color(0xFFFFFFFF), .35).withAlpha((255 * flick).round()));
    final awning = _mix(lv.mid, neon, .55);
    final stripes = ((bw - 10) / 10).floor();
    for (var s = 0; s < stripes; s++) {
      canvas.drawRect(Rect.fromLTWH(bx + 4 + s * 10, 77, 10, 5), Paint()..color = s.isEven ? awning : _mix(awning, const Color(0xFFFFFFFF), .55));
    }
    final win = Rect.fromLTWH(bx + 8, 84, bw - 18, 16);
    canvas.drawRect(win, Paint()..shader = Gradient.linear(win.topCenter, win.bottomCenter, const [Color(0xFFFFCF7A), Color(0xFFA8602A)]));
    canvas.drawRect(Rect.fromLTWH(bx + bw / 2 - 5, 84, 2, 16), Paint()..color = const Color(0xFF1A1224));
  }

  /// Nova Iorque: prédios de tijolo com escadas de incêndio, caixas de água
  /// no telhado e entradas do metro com grades verdes e candeeiros de globo.
  void _newYorkFront(Canvas canvas, LevelData lv, double w, double cam, double t) {
    const bw = 90.0;
    final dark = Paint()..color = const Color(0xFF1A0C14);
    final lit = Paint()..color = const Color(0xFFFFCF7A);
    final iron = Paint()
      ..color = const Color(0xFF120A10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    _tiles(w, cam, .7, bw, (n, bx) {
      final top = 34.0 + _hash(n) % 10;
      canvas.drawRect(
        Rect.fromLTWH(bx, top, bw - 2, 100 - top),
        Paint()..shader = Gradient.linear(Offset(0, top), const Offset(0, 100), [lv.mid, _mix(lv.mid, const Color(0xFF000000), .45)]),
      );
      canvas.drawRect(Rect.fromLTWH(bx - 1, top - 2, bw, 2), Paint()..color = _mix(lv.mid, const Color(0xFF000000), .5));
      if (n % 3 == 0) {
        // caixa de água
        final wx = bx + 16;
        final tank = Paint()..color = const Color(0xFF24121C);
        canvas.drawRect(Rect.fromLTWH(wx, top - 13, 12, 10), tank);
        canvas.drawPath(Path()..moveTo(wx - 1, top - 13)..lineTo(wx + 6, top - 19)..lineTo(wx + 13, top - 13)..close(), tank);
        canvas.drawRect(Rect.fromLTWH(wx + 1, top - 3, 1, 3), tank);
        canvas.drawRect(Rect.fromLTWH(wx + 10, top - 3, 1, 3), tank);
      }
      for (var j = 0; j < 2; j++) {
        for (var q = 0; q < 4; q++) {
          final on = (_hash(n * 4 + q + j * 13) % 3) == 0;
          canvas.drawRect(Rect.fromLTWH(bx + 7 + q * 20, top + 6 + j * 15, 9, 10), on ? lit : dark);
        }
      }
      // escada de incêndio
      final fy = top + 18;
      canvas.drawLine(Offset(bx + 24, fy), Offset(bx + 66, fy), iron);
      canvas.drawLine(Offset(bx + 24, fy + 15), Offset(bx + 66, fy + 15), iron);
      canvas.drawLine(Offset(bx + 28, fy + 1), Offset(bx + 62, fy + 14), iron);
      if (n.isEven) {
        _subway(canvas, bx, bw, t);
      } else {
        _shop(canvas, lv, bx, bw, n, t);
      }
    });
  }

  void _subway(Canvas canvas, double bx, double bw, double t) {
    final green = Paint()..color = const Color(0xFF1F6B45);
    // escadas a descer
    canvas.drawRect(Rect.fromLTWH(bx + 14, 86, bw - 30, 14), Paint()..color = const Color(0xFF0C0A10));
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(bx + 16, 89 + i * 4, bw - 34, 1), Paint()..color = const Color(0xFF3A3446));
    }
    // grades
    canvas.drawRect(Rect.fromLTWH(bx + 10, 84, bw - 22, 1.5), green);
    canvas.drawRect(Rect.fromLTWH(bx + 10, 90, bw - 22, 1), green);
    for (var x = bx + 10; x <= bx + bw - 12; x += 6) {
      canvas.drawRect(Rect.fromLTWH(x, 84, 1, 16), green);
    }
    // placa
    final sign = Rect.fromLTWH(bx + bw / 2 - 16, 74, 30, 8);
    canvas.drawRect(sign, Paint()..color = const Color(0xFF111111));
    canvas.drawRect(sign, Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .6);
    _signText.render(canvas, 'SUBWAY', Vector2(sign.center.dx, sign.center.dy), anchor: Anchor.center);
    // candeeiros de globo verde
    for (final gx in [bx + 10, bx + bw - 12]) {
      canvas.drawRect(Rect.fromLTWH(gx - 1, 74, 2, 12), green);
      final g = Offset(gx, 72);
      canvas.drawCircle(g, 9, Paint()..shader = Gradient.radial(g, 9, const [Color(0x995FE08A), Color(0x005FE08A)]));
      canvas.drawCircle(g, 2.6, Paint()..color = const Color(0xFFB8FFCF));
    }
  }

  /// Londres ao longe: torre do relógio no nevoeiro.
  void _clockTower(Canvas canvas, double w, double cam) {
    final x = w * .72 - cam * .05;
    final p = Paint()..color = const Color(0xFF2A2836);
    canvas.drawRect(Rect.fromLTWH(x, 20, 14, 70), p);
    canvas.drawPath(Path()..moveTo(x - 2, 20)..lineTo(x + 7, 2)..lineTo(x + 16, 20)..close(), p);
    canvas.drawCircle(Offset(x + 7, 30), 4.2, Paint()..color = const Color(0xFFF4E6B8));
    canvas.drawLine(Offset(x + 7, 30), Offset(x + 7, 27.4), Paint()
      ..color = const Color(0xFF2A2836)
      ..strokeWidth = .8);
    canvas.drawLine(Offset(x + 7, 30), Offset(x + 9, 31), Paint()
      ..color = const Color(0xFF2A2836)
      ..strokeWidth = .8);
  }

  /// Londres: casas de tijolo em banda, chaminés, janelas de guilhotina,
  /// pubs e cabines telefónicas vermelhas.
  void _londonFront(Canvas canvas, LevelData lv, double w, double cam, double t) {
    const bw = 80.0;
    final mortar = Paint()..color = const Color(0x33000000);
    final frame = Paint()
      ..color = const Color(0xFFE8E0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    _tiles(w, cam, .7, bw, (n, bx) {
      const top = 42.0;
      canvas.drawRect(Rect.fromLTWH(bx, top, bw, 100 - top), Paint()..color = lv.mid);
      for (var y = top + 4; y < 100; y += 4) {
        canvas.drawRect(Rect.fromLTWH(bx, y, bw, .6), mortar);
      }
      canvas.drawRect(Rect.fromLTWH(bx, top - 2, bw, 2.5), Paint()..color = const Color(0xFFD8D0C0));
      final chim = Paint()..color = const Color(0xFF3A1A16);
      canvas.drawRect(Rect.fromLTWH(bx + 10, top - 10, 7, 8), chim);
      canvas.drawRect(Rect.fromLTWH(bx + 58, top - 8, 7, 6), chim);
      canvas.drawRect(Rect.fromLTWH(bx + 1, top - 2, 1, 58), Paint()..color = const Color(0x44000000));
      for (var q = 0; q < 2; q++) {
        final r = Rect.fromLTWH(bx + 12 + q * 38, top + 6, 16, 20);
        final on = _hash(n * 2 + q) % 3 == 0;
        canvas.drawRect(r, Paint()..color = on ? const Color(0xFFFFD27A) : const Color(0xFF14121A));
        canvas.drawRect(r, frame);
        canvas.drawLine(Offset(r.left, r.center.dy), Offset(r.right, r.center.dy), frame);
      }
      final kind = ((n % 3) + 3) % 3;
      if (kind == 0) {
        // pub
        canvas.drawRect(Rect.fromLTWH(bx + 6, 74, bw - 12, 26), Paint()..color = const Color(0xFF1A3A2A));
        canvas.drawRect(Rect.fromLTWH(bx + 12, 80, 24, 14), Paint()..color = const Color(0xFFFFCF7A));
        canvas.drawRect(Rect.fromLTWH(bx + 44, 80, 14, 20), Paint()..color = const Color(0xFF0E2218));
        final sign = Rect.fromLTWH(bx + 8, 68, bw - 16, 7);
        canvas.drawRect(sign, Paint()..color = const Color(0xFF1A3A2A));
        canvas.drawRect(sign, Paint()
          ..color = const Color(0xFFD9B45A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7);
        _pubText.render(canvas, 'THE CROWN', Vector2(sign.center.dx, sign.center.dy), anchor: Anchor.center);
      } else {
        // porta georgiana
        canvas.drawRect(Rect.fromLTWH(bx + 30, 78, 14, 22), Paint()..color = const Color(0xFF14121A));
        canvas.drawRect(Rect.fromLTWH(bx + 30, 78, 14, 22), frame);
        // bandeira em leque por cima da porta
        canvas.drawArc(Rect.fromCircle(center: Offset(bx + 37, 78), radius: 7), math.pi, math.pi, true, Paint()..color = const Color(0xFFE8E0D0));
        canvas.drawArc(Rect.fromCircle(center: Offset(bx + 37, 78), radius: 5.6), math.pi, math.pi, true, Paint()..color = const Color(0xFF14121A));
        if (kind == 1) _phoneBox(canvas, bx + 58, 100);
        if (kind == 2) {
          // grafiti punk
          canvas.save();
          canvas.translate(bx + 6, 92);
          canvas.rotate(-.1);
          _signText.render(canvas, 'OI!', Vector2.zero());
          canvas.restore();
        }
      }
    });
  }

  void _phoneBox(Canvas canvas, double x, double base) {
    final red = Paint()..color = const Color(0xFFC8202A);
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromLTWH(x, base - 24, 10, 24), topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), red);
    canvas.drawRect(Rect.fromLTWH(x + 1, base - 20, 8, 2), Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawRect(Rect.fromLTWH(x + 2, base - 17, 6, 14), Paint()..color = const Color(0xFFFFE8A0));
    final bar = Paint()..color = const Color(0xFFC8202A);
    canvas.drawRect(Rect.fromLTWH(x + 2, base - 12.5, 6, .8), bar);
    canvas.drawRect(Rect.fromLTWH(x + 2, base - 8, 6, .8), bar);
    canvas.drawRect(Rect.fromLTWH(x + 4.6, base - 17, .8, 14), bar);
  }

  /// Cidade velha europeia: cúpula, torre de igreja e telhados ao longe.
  void _oldTown(Canvas canvas, LevelData lv, double w, double cam) {
    final p = Paint()..color = lv.far;
    final lit = Paint()..color = const Color(0x99FFCF7A);
    _tiles(w, cam, .1, 70, (n, bx) {
      canvas.drawRect(Rect.fromLTWH(bx, 62, 70, 20), p);
      canvas.drawPath(Path()..moveTo(bx, 62)..lineTo(bx + 12, 54)..lineTo(bx + 24, 62)..lineTo(bx + 36, 56)..lineTo(bx + 50, 62)..close(), p);
      switch (((n % 4) + 4) % 4) {
        case 0:
          canvas.drawRect(Rect.fromLTWH(bx + 50, 34, 9, 28), p);
          canvas.drawPath(Path()..moveTo(bx + 49, 34)..lineTo(bx + 54.5, 20)..lineTo(bx + 60, 34)..close(), p);
          canvas.drawRect(Rect.fromLTWH(bx + 53, 40, 3, 4), lit);
        case 2:
          canvas.drawRect(Rect.fromLTWH(bx + 20, 46, 22, 16), p);
          canvas.drawArc(Rect.fromLTWH(bx + 20, 36, 22, 20), math.pi, math.pi, true, p);
          canvas.drawRect(Rect.fromLTWH(bx + 30, 30, 2, 7), p);
        default:
          break;
      }
      canvas.drawRect(Rect.fromLTWH(bx + 8 + _hash(n) % 40, 66, 2, 3), lit);
    });
  }

  /// Rio com ponte de pedra em arcos e reflexos das luzes.
  void _river(Canvas canvas, LevelData lv, double w, double cam, double t) {
    canvas.drawRect(
      Rect.fromLTWH(0, 80, w, 20),
      Paint()..shader = Gradient.linear(const Offset(0, 80), const Offset(0, 100), const [Color(0xFF1C3260), Color(0xFF0A1430)]),
    );
    final bridge = Paint()..color = const Color(0xFF2C3C70);
    final glow = Paint()..color = const Color(0xFFFFE2A0);
    final refl = Paint()..color = const Color(0x55FFCF7A);
    _tiles(w, cam, .3, 40, (n, bx) {
      canvas.drawRect(Rect.fromLTWH(bx, 72, 40, 5), bridge);
      canvas.drawPath(
        Path()
          ..moveTo(bx, 77)
          ..lineTo(bx + 40, 77)
          ..lineTo(bx + 40, 88)
          ..quadraticBezierTo(bx + 20, 72, bx, 88)
          ..close(),
        bridge,
      );
      canvas.drawCircle(Offset(bx + 20, 70.5), 1.2, glow);
      final wob = math.sin(t * 2 + n) * .8;
      canvas.drawRect(Rect.fromLTWH(bx + 19 + wob, 89, 2, 9), refl);
    });
  }

  /// Fachadas antigas com janelas em arco, varandas e telhados de telha,
  /// com aberturas para o rio.
  void _europeFront(Canvas canvas, LevelData lv, double w, double cam, double t) {
    const bw = 64.0;
    const facades = [Color(0xFF3A2A36), Color(0xFF33283A), Color(0xFF2E3446), Color(0xFF40302A)];
    final dark = Paint()..color = const Color(0xFF1C1420);
    final lit = Paint()..color = const Color(0xFFFFCF7A);
    final rail = Paint()
      ..color = const Color(0xFF0C0810)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8;
    _tiles(w, cam, .7, bw, (n, bx) {
      if (((n % 4) + 4) % 4 == 3) {
        // muro do cais, deixa ver o rio
        canvas.drawRect(Rect.fromLTWH(bx, 94, bw, 6), Paint()..color = const Color(0xFF4A4658));
        for (var x = bx + 4; x < bx + bw; x += 8) {
          canvas.drawRect(Rect.fromLTWH(x, 90, 1.5, 4), Paint()..color = const Color(0xFF14101A));
        }
        canvas.drawRect(Rect.fromLTWH(bx, 89.5, bw, 1), Paint()..color = const Color(0xFF14101A));
        return;
      }
      final top = 36.0 + _hash(n) % 8;
      final col = facades[_hash(n) % facades.length];
      canvas.drawRect(Rect.fromLTWH(bx, top, bw - 1, 100 - top), Paint()..color = col);
      // telhado de telha
      canvas.drawPath(
        Path()
          ..moveTo(bx - 2, top)
          ..lineTo(bx + 8, top - 9)
          ..lineTo(bx + bw - 9, top - 9)
          ..lineTo(bx + bw + 1, top)
          ..close(),
        Paint()..color = const Color(0xFF5A2A22),
      );
      canvas.drawRect(Rect.fromLTWH(bx + bw / 2 - 4, top - 7, 8, 5), dark);
      for (var j = 0; j < 3; j++) {
        for (var q = 0; q < 3; q++) {
          final on = _hash(n * 9 + j * 3 + q) % 4 == 0;
          final r = RRect.fromRectAndCorners(Rect.fromLTWH(bx + 7 + q * 19, top + 6 + j * 18, 9, 13), topLeft: const Radius.circular(4.5), topRight: const Radius.circular(4.5));
          canvas.drawRRect(r, on ? lit : dark);
        }
        if (j == 1) {
          final y = top + 6 + j * 18 + 13;
          canvas.drawRect(Rect.fromLTWH(bx + 4, y - 4, bw - 9, 4), rail);
          for (var x = bx + 6; x < bx + bw - 6; x += 3) {
            canvas.drawLine(Offset(x, y - 4), Offset(x, y), rail);
          }
        }
      }
    });
  }

  /// Deserto ao entardecer: mesas rochosas ao longe.
  void _mesas(Canvas canvas, LevelData lv, double w, double cam) {
    final p = Paint()..color = lv.far;
    _tiles(w, cam, .08, 120, (n, bx) {
      final h = 10.0 + _hash(n) % 14;
      canvas.drawPath(
        Path()
          ..moveTo(bx, 92)
          ..lineTo(bx + 14, 92 - h)
          ..lineTo(bx + 60, 92 - h)
          ..lineTo(bx + 72, 92 - h * .4)
          ..lineTo(bx + 120, 92 - h * .3)
          ..lineTo(bx + 120, 92)
          ..close(),
        p,
      );
    });
  }

  void _palms(Canvas canvas, double w, double cam) {
    final p = Paint()..color = const Color(0xFF1A0C22);
    final trunk = Paint()
      ..color = const Color(0xFF1A0C22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    _tiles(w, cam, .3, 110, (n, bx) {
      if (n % 2 != 0) return;
      final x = bx + 30;
      const top = 40.0;
      canvas.drawPath(Path()..moveTo(x, 96)..quadraticBezierTo(x + 2, 70, x + 5, top), trunk);
      for (var i = 0; i < 6; i++) {
        final a = -math.pi + i * math.pi / 5;
        final tip = Offset(x + 5 + math.cos(a) * 16, top + 6 + math.sin(a).abs() * -4 + (i == 0 || i == 5 ? 6 : 0));
        canvas.drawPath(
          Path()
            ..moveTo(x + 5, top)
            ..quadraticBezierTo((x + 5 + tip.dx) / 2, top - 6, tip.dx, tip.dy)
            ..quadraticBezierTo((x + 5 + tip.dx) / 2, top - 2, x + 5, top + 1)
            ..close(),
          p,
        );
      }
    });
  }

  /// Lanchonete retro de inox com letreiro de néon e motas estacionadas.
  void _dinerFront(Canvas canvas, LevelData lv, double w, double cam, double t) {
    const bw = 170.0;
    _tiles(w, cam, .7, bw, (n, bx) {
      if (n.isOdd) {
        // painel publicitário
        final post = Paint()..color = const Color(0xFF2A1A30);
        canvas.drawRect(Rect.fromLTWH(bx + 40, 62, 2, 38), post);
        canvas.drawRect(Rect.fromLTWH(bx + 90, 62, 2, 38), post);
        final board = Rect.fromLTWH(bx + 30, 46, 72, 18);
        canvas.drawRect(board, Paint()..color = const Color(0xFFF4E6C8));
        canvas.drawRect(board.deflate(2), Paint()..color = const Color(0xFFC8202A));
        _signText.render(canvas, 'BURGERS 25¢', Vector2(board.center.dx, board.center.dy), anchor: Anchor.center);
        return;
      }
      final body = RRect.fromRectAndRadius(Rect.fromLTWH(bx + 4, 64, bw - 14, 36), const Radius.circular(10));
      canvas.drawRRect(
        body,
        Paint()
          ..shader = Gradient.linear(Offset(0, body.top), Offset(0, body.bottom), const [Color(0xFFF4F6FA), Color(0xFF9AA4B4), Color(0xFF5A6274), Color(0xFFC8D0DC)], const [0, .45, .55, 1]),
      );
      canvas.drawRect(Rect.fromLTWH(bx + 4, 84, bw - 14, 3), Paint()..color = const Color(0xFF2AB0B8));
      canvas.drawRect(Rect.fromLTWH(bx + 4, 94, bw - 14, 6), Paint()..color = const Color(0xFFC8202A));
      final win = Rect.fromLTWH(bx + 12, 69, bw - 30, 13);
      canvas.drawRect(win, Paint()..color = const Color(0xFFFFE6A8));
      for (var x = win.left + 20; x < win.right; x += 20) {
        canvas.drawRect(Rect.fromLTWH(x, win.top, 1.4, win.height), Paint()..color = const Color(0xFF5A6274));
        canvas.drawCircle(Offset(x - 10, win.bottom - 2), 2, Paint()..color = const Color(0xFFC8202A));
      }
      canvas.drawRect(Rect.fromLTWH(bx + bw / 2 - 8, 86, 14, 14), Paint()..color = const Color(0xFFFFE6A8));
      // letreiro de néon
      final post = Paint()..color = const Color(0xFF5A6274);
      canvas.drawRect(Rect.fromLTWH(bx + bw / 2 - 26, 54, 2, 10), post);
      canvas.drawRect(Rect.fromLTWH(bx + bw / 2 + 18, 54, 2, 10), post);
      final sign = Rect.fromLTWH(bx + bw / 2 - 36, 38, 66, 17);
      canvas.drawRRect(RRect.fromRectAndRadius(sign, const Radius.circular(3)), Paint()..color = const Color(0xFF1A1028));
      final flick = (math.sin(t * 6 + n) > .97) ? .3 : 1.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(sign.deflate(1.5), const Radius.circular(3)),
        Paint()
          ..color = const Color(0xFF3DF0FF).withAlpha((200 * flick).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
      canvas.drawCircle(sign.center, 22, Paint()..color = const Color(0xFFFF3D81).withAlpha((60 * flick).round())..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      _neonText.render(canvas, 'Diner', Vector2(sign.center.dx, sign.center.dy), anchor: Anchor.center);
    });
  }

  void _ground(Canvas canvas, LevelData lv, double w, double cam, {bool cobbles = false}) {
    final scene = lv.scene;
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
      if (scene == Scenery.diner) {
        _chopper(canvas, x - 10, 108, n.isEven ? const Color(0xFF8A1A1A) : const Color(0xFF1A1A1A));
      } else if (scene == Scenery.europeNight) {
        // banco de jardim
        final wood = Paint()..color = const Color(0xFF5A3A24);
        final iron = Paint()..color = const Color(0xFF14101A);
        canvas.drawRect(Rect.fromLTWH(x, 98, 22, 2), wood);
        canvas.drawRect(Rect.fromLTWH(x, 102, 22, 2), wood);
        canvas.drawRect(Rect.fromLTWH(x + 1, 98, 1.5, 11), iron);
        canvas.drawRect(Rect.fromLTWH(x + 19.5, 98, 1.5, 11), iron);
      } else if (n.isEven) {
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
    if (cobbles) {
      // calçada de pedra: fiadas desencontradas
      final joint = Paint()..color = const Color(0x40000000);
      final shine = Paint()..color = const Color(0x14FFFFFF);
      for (var row = 0; row < 9; row++) {
        final y = 114.0 + row * 7.4;
        canvas.drawRect(Rect.fromLTWH(0, y + 6, w, .8), joint);
        final step = 9.0 + row * .6;
        final off3 = (cam + row * 4.5) % step;
        for (var x = -off3; x < w; x += step) {
          canvas.drawRect(Rect.fromLTWH(x, y, .8, 6.5), joint);
          canvas.drawRect(Rect.fromLTWH(x + 1.5, y + .8, step - 4, 1), shine);
        }
      }
    } else {
      final dash = Paint()..color = const Color(0x73F0E6C8);
      final off2 = cam % 48;
      for (var x = -off2; x < w; x += 48) {
        canvas.drawRect(Rect.fromLTWH(x, 145, 24, 2), dash);
      }
    }
    canvas.drawRect(Rect.fromLTWH(0, 176, w, 1), Paint()..color = const Color(0x22FFFFFF));
  }

  /// Mota estilo chopper estacionada (rodas assentes em [base]).
  void _chopper(Canvas canvas, double x, double base, Color tank) {
    final tyre = Paint()
      ..color = const Color(0xFF141218)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final chrome = Paint()
      ..color = const Color(0xFFC8D0DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(x + 4, base - 4), 4, tyre);
    canvas.drawCircle(Offset(x + 28, base - 4), 4, tyre);
    canvas.drawPath(Path()..moveTo(x + 4, base - 4)..lineTo(x + 11, base - 9)..lineTo(x + 20, base - 9)..lineTo(x + 28, base - 4), chrome);
    canvas.drawPath(Path()..moveTo(x + 20, base - 10)..lineTo(x + 25, base - 16)..lineTo(x + 26, base - 18), chrome);
    canvas.drawLine(Offset(x + 25, base - 16), Offset(x + 28, base - 4), chrome);
    canvas.drawPath(
      Path()
        ..moveTo(x + 10, base - 10)
        ..quadraticBezierTo(x + 14, base - 15, x + 20, base - 12)
        ..lineTo(x + 20, base - 9.5)
        ..lineTo(x + 10, base - 9.5)
        ..close(),
      Paint()..color = tank,
    );
    canvas.drawRect(Rect.fromLTWH(x + 12, base - 9, 5, 3), Paint()..color = const Color(0xFF9AA4B4));
  }

  void _lamps(Canvas canvas, double w, double cam, {bool gas = false, Color light = const Color(0xFFFFDC96)}) {
    final n0 = (cam / 180).floor();
    for (var n = n0; n <= n0 + 3; n++) {
      final lx = n * 180.0 + 60 - cam;
      final head = gas ? Offset(lx + 1, 52) : Offset(lx + 9, 54);
      final pole = Paint()..color = const Color(0xFF1B1624);
      if (gas) {
        // candeeiro a gás: lanterna de ferro no topo do poste
        canvas.drawRect(Rect.fromLTWH(lx, 56, 2, 46), pole);
        canvas.drawRect(Rect.fromLTWH(lx - 2, 100, 6, 2), pole);
        canvas.drawPath(Path()..moveTo(lx - 4, 48)..lineTo(lx + 6, 48)..lineTo(lx + 4, 57)..lineTo(lx - 2, 57)..close(), pole);
        canvas.drawPath(Path()..moveTo(lx - 5, 48)..lineTo(lx + 1, 44)..lineTo(lx + 7, 48)..close(), pole);
        canvas.drawRect(Rect.fromLTWH(lx - 2, 49.5, 6, 6), Paint()..color = const Color(0xFFFFE8A8));
      } else {
        canvas.drawRect(Rect.fromLTWH(lx, 50, 2, 52), pole);
        canvas.drawRect(Rect.fromLTWH(lx, 50, 10, 2), pole);
      }
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
          ..shader = Gradient.linear(head, Offset(head.dx, 112), [light.withAlpha(0x40), light.withAlpha(0)]),
      );
      canvas.drawCircle(
        head,
        26,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = Gradient.radial(head, 26, [light.withAlpha(0x99), light.withAlpha(0)]),
      );
      if (!gas) canvas.drawCircle(head, 2.2, Paint()..color = const Color(0xFFFFF3C8));
      // poça de luz na estrada
      canvas.save();
      canvas.translate(head.dx, 132);
      canvas.scale(1, .26);
      canvas.drawCircle(
        Offset.zero,
        58,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = Gradient.radial(Offset.zero, 58, [light.withAlpha(0x55), light.withAlpha(0)]),
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

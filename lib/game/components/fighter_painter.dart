import 'dart:math' as math;
import 'dart:ui';

import '../game_enums.dart';

class FighterPalette {
  const FighterPalette({
    required this.shirt,
    required this.pants,
    required this.hair,
    required this.skin,
    required this.hairStyle,
    required this.accent,
    this.outfit = Outfit.tee,
  });

  final Color shirt;
  final Color pants;
  final Color hair;
  final Color skin;
  final HairStyle hairStyle;
  final Color accent;
  final Outfit outfit;
}

abstract final class Palettes {
  static const hero = FighterPalette(shirt: Color(0xFF1E6FD9), pants: Color(0xFF2B2B55), hair: Color(0xFF3B2412), skin: Color(0xFFF0C090), hairStyle: HairStyle.headband, accent: Color(0xFFE22222));
  static const grunt = FighterPalette(shirt: Color(0xFFB03A2E), pants: Color(0xFF3A2A2A), hair: Color(0xFF222222), skin: Color(0xFFE0A070), hairStyle: HairStyle.cap, accent: Color(0xFF111111), outfit: Outfit.vest);
  static const thug = FighterPalette(shirt: Color(0xFF2E8B57), pants: Color(0xFF1D3B2A), hair: Color(0xFFE8C34A), skin: Color(0xFFD49A6A), hairStyle: HairStyle.mohawk, accent: Color(0xFFE8C34A), outfit: Outfit.jacket);
  static const knifer = FighterPalette(shirt: Color(0xFF2A4A8A), pants: Color(0xFF1A1A22), hair: Color(0xFFAA5522), skin: Color(0xFFD49A6A), hairStyle: HairStyle.cap, accent: Color(0xFFFF8A3D), outfit: Outfit.jacket);
  static const boss = FighterPalette(shirt: Color(0xFF6A1B9A), pants: Color(0xFF2A1038), hair: Color(0xFF111111), skin: Color(0xFFC98A5A), hairStyle: HairStyle.bald, accent: Color(0xFFE8C34A), outfit: Outfit.coat);
  static const viper = FighterPalette(shirt: Color(0xFF146B5A), pants: Color(0xFF10241F), hair: Color(0xFFE8E8F0), skin: Color(0xFFC98A5A), hairStyle: HairStyle.mohawk, accent: Color(0xFF7CFFC4), outfit: Outfit.coat);
}

/// Desenho vetorial das personagens (pés na origem, viradas à direita):
/// contorno, sombreado, animação de passo/respiração, inclinação nos golpes.
abstract final class FighterPainter {
  static const _ol = Color(0xFF150F1C);
  static final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final Paint _fill = Paint();

  static Color _light(Color c, double t) => Color.lerp(c, const Color(0xFFFFFFFF), t)!;
  static Color _dark(Color c, double t) => Color.lerp(c, const Color(0xFF000000), t)!;

  static void _limb(Canvas c, List<Offset> pts, double w, Color col, {bool shine = true}) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    c.drawPath(path, _stroke..strokeWidth = w + 1.8..color = _ol);
    c.drawPath(path, _stroke..strokeWidth = w..color = col);
    if (shine) {
      c.drawPath(path.shift(Offset(-w * .16, -w * .2)), _stroke..strokeWidth = w * .32..color = _light(col, .4).withAlpha(140));
    }
  }

  static void paint(
    Canvas c, {
    required FighterPalette palette,
    required int facing,
    required double phase,
    required FighterPose pose,
    bool moving = false,
    double time = 0,
    double height = 0,
    double scale = 1,
    bool flash = false,
    Weapon? weapon,
  }) {
    final p = palette;

    // sombra suave
    final shadowR = 13 * scale * (1 - math.min(height, 60) / 120);
    c.save();
    c.scale(1, .28);
    _fill.shader = Gradient.radial(Offset.zero, shadowR, const [Color(0x99000000), Color(0x00000000)]);
    c.drawCircle(Offset.zero, shadowR, _fill);
    _fill.shader = null;
    c.restore();

    if (flash) {
      c.saveLayer(null, Paint()..colorFilter = const ColorFilter.mode(Color(0xB3FFFFFF), BlendMode.srcATop));
    }
    c.save();
    c.translate(0, -height);
    c.scale(facing * scale, scale);
    if (pose == FighterPose.down) c.rotate(-1.5);

    final air = height > 0;
    final kick = pose == FighterPose.kick;
    final punch = pose == FighterPose.punch;
    final hurt = pose == FighterPose.hurt;
    final sw = air ? 0.0 : math.sin(phase) * .65;
    final bob = (moving && !air) ? -math.sin(phase * 2).abs() * 1.3 : math.sin(time * 3.2) * .5;
    final lean = punch ? .10 : kick ? -.12 : hurt ? -.18 : moving ? .04 : 0.0;

    void upper(void Function() draw) {
      c.save();
      c.translate(0, -17 + bob);
      c.rotate(lean);
      c.translate(0, 17);
      draw();
      c.restore();
    }

    void leg(double a, bool front) {
      late double fx, fy, kx, ky;
      if (air) {
        fx = front ? 8 : -4;
        fy = -7;
        kx = front ? 8 : 0;
        ky = -13;
      } else if (front && kick) {
        fx = 21;
        fy = -21;
        kx = 10;
        ky = -19;
      } else {
        fx = math.sin(a) * 11;
        fy = -17 + math.cos(a) * 16.5;
        kx = math.sin(a) * 5.5 + 1.5;
        ky = -17 + math.cos(a) * 8.5;
      }
      _limb(c, [const Offset(0, -17), Offset(kx, ky), Offset(fx, fy)], 6, front ? p.pants : _dark(p.pants, .25));
      _limb(c, [Offset(fx - 1.5, fy - 1), Offset(fx + 4, fy - 1)], 4.4, const Color(0xFF1B1B22), shine: false);
      _limb(c, [Offset(fx - 1.5, fy + .8), Offset(fx + 4, fy + .8)], 1.2, const Color(0xFFE8E4EE), shine: false);
    }

    void arm(Offset s, Offset e, Offset h, {bool back = false}) {
      final sleeve = p.outfit != Outfit.vest ? p.shirt : p.skin;
      _limb(c, [s, e], 5, back ? _dark(sleeve, .25) : sleeve);
      _limb(c, [e, h], 4.2, back ? _dark(p.skin, .2) : p.skin);
    }

    void torso() {
      _fill.color = p.skin;
      c.drawRect(const Rect.fromLTWH(-1, -33, 4, 4), _fill);
      final path = Path()
        ..moveTo(-6.5, -30)
        ..lineTo(6.5, -30)
        ..lineTo(5.2, -16.5)
        ..lineTo(-5.2, -16.5)
        ..close();
      _fill.color = p.outfit == Outfit.vest ? p.skin : p.shirt;
      c.drawPath(path, _fill);
      if (p.outfit == Outfit.vest) {
        _fill.color = p.shirt;
        c.drawPath(
            Path()
              ..moveTo(-6.5, -30)
              ..lineTo(-1.5, -30)
              ..lineTo(-.5, -16.5)
              ..lineTo(-5.2, -16.5)
              ..close(),
            _fill);
        c.drawPath(
            Path()
              ..moveTo(6.5, -30)
              ..lineTo(1.5, -30)
              ..lineTo(.5, -16.5)
              ..lineTo(5.2, -16.5)
              ..close(),
            _fill);
      }
      _fill.shader = Gradient.linear(const Offset(0, -30), const Offset(0, -16.5), const [Color(0x40FFFFFF), Color(0x66000000)]);
      c.drawPath(path, _fill);
      _fill.shader = null;
      c.drawPath(path, _stroke..strokeWidth = 1.2..color = _ol);
      if (p.outfit == Outfit.jacket) {
        c.drawLine(const Offset(4.2, -29.5), const Offset(3.6, -17.5), _stroke..strokeWidth = 1.4..color = p.accent);
      } else if (p.outfit == Outfit.coat) {
        c.drawLine(const Offset(-2, -30), const Offset(1.5, -20), _stroke..strokeWidth = 1.4..color = p.accent);
        c.drawLine(const Offset(3, -30), const Offset(1.5, -20), _stroke..strokeWidth = 1.4..color = p.accent);
      }
      _fill.color = const Color(0xFF17131C);
      c.drawRect(const Rect.fromLTWH(-5.4, -18.2, 10.8, 2.6), _fill);
      _fill.color = p.accent;
      c.drawRect(const Rect.fromLTWH(-.2, -18.2, 3.2, 2.6), _fill);
      c.drawLine(const Offset(5.4, -28.5), const Offset(4.6, -19), _stroke..strokeWidth = 1..color = const Color(0x40FFFFFF));
    }

    void head() {
      const o = Offset(1.5, -36);
      _fill.color = _dark(p.skin, .12);
      c.drawCircle(const Offset(-2.2, -35.6), 1.6, _fill);
      _fill.color = p.skin;
      c.drawCircle(o, 5.4, _fill);
      _fill.shader = Gradient.radial(const Offset(.2, -38), 7, const [Color(0x55FFFFFF), Color(0x33000000)]);
      c.drawCircle(o, 5.4, _fill);
      _fill.shader = null;
      c.drawCircle(o, 5.4, _stroke..strokeWidth = 1.2..color = _ol);

      _fill.color = p.hair;
      switch (p.hairStyle) {
        case HairStyle.mohawk:
          {
            final w = math.sin(time * 6) * .6;
            final m = Path()
              ..moveTo(-3, -38.5)
              ..lineTo(-2.5, -45)
              ..lineTo(-.5, -42)
              ..lineTo(.5 + w, -48.5)
              ..lineTo(2.5, -42.5)
              ..lineTo(4.5 + w, -47)
              ..lineTo(5.5, -39)
              ..close();
            c.drawPath(m, _fill);
            c.drawPath(m, _stroke..strokeWidth = 1..color = _ol);
          }
        case HairStyle.bald:
          {
            c.drawArc(Rect.fromCircle(center: o, radius: 5.2), .2, math.pi - .5, true, _fill);
            c.drawArc(Rect.fromCircle(center: o, radius: 4), math.pi * 1.15, .6, false, _stroke..strokeWidth = 1..color = const Color(0x66FFFFFF));
          }
        case HairStyle.headband:
        case HairStyle.cap:
          {
            final r = Rect.fromCircle(center: const Offset(1.5, -36.3), radius: 5.9);
            c.drawArc(r, math.pi * .9, math.pi * 1.2, true, _fill);
            c.drawRect(const Rect.fromLTWH(-5.2, -38, 3.2, 7), _fill);
            c.drawArc(r, math.pi * .9, math.pi * 1.2, false, _stroke..strokeWidth = 1..color = _ol);
            if (p.hairStyle == HairStyle.headband) {
              _fill.color = p.accent;
              c.drawRect(const Rect.fromLTWH(-5, -38.4, 12.4, 2), _fill);
              final fl = math.sin(time * 9) * 1.5;
              _limb(c, [const Offset(-4.5, -37.4), Offset(-8.5, -36 + fl), Offset(-12.5, -34.5 + fl * 1.6)], 1.8, p.accent, shine: false);
            }
          }
      }

      if (p.hairStyle == HairStyle.bald) {
        _fill.color = const Color(0xFF0C0C12);
        c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(2.2, -38, 5.6, 2.4), const Radius.circular(1)), _fill);
        c.drawLine(const Offset(3, -37.6), const Offset(5, -37.6), _stroke..strokeWidth = .6..color = const Color(0x99FFFFFF));
      } else if (hurt) {
        c.drawLine(const Offset(3, -37.5), const Offset(5.4, -36), _stroke..strokeWidth = .9..color = _ol);
        c.drawLine(const Offset(3, -36), const Offset(5.4, -37.5), _stroke..strokeWidth = .9..color = _ol);
      } else {
        _fill.color = const Color(0xFFFFFFFF);
        c.drawOval(Rect.fromCenter(center: const Offset(4, -36.7), width: 3, height: 2.6), _fill);
        _fill.color = const Color(0xFF111111);
        c.drawCircle(const Offset(4.7, -36.6), .95, _fill);
        c.drawLine(const Offset(2.4, -39), const Offset(6.2, -37.9), _stroke..strokeWidth = 1..color = _dark(p.hair, .3));
      }
      // boca e nariz
      _fill.color = _dark(p.skin, .18);
      c.drawCircle(const Offset(6.6, -35), .8, _fill);
      if (punch || kick || hurt) {
        _fill.color = const Color(0xFF5A1010);
        c.drawOval(Rect.fromCenter(center: const Offset(4.4, -33.2), width: 2.2, height: 1.8), _fill);
      } else {
        c.drawLine(const Offset(3.2, -33.2), const Offset(5.6, -33.2), _stroke..strokeWidth = .8..color = _dark(p.skin, .5));
      }
      if (p.hairStyle == HairStyle.bald) {
        // barba
        _fill.color = p.hair;
        c.drawArc(Rect.fromCircle(center: o, radius: 5.5), .15, math.pi - .35, true, _fill);
        _fill.color = _dark(p.skin, .18);
        c.drawCircle(const Offset(6.6, -35), .8, _fill);
      }
    }

    // ---- ordem de desenho: de trás para a frente ----
    if (p.outfit == Outfit.coat) {
      final tail = Path()
        ..moveTo(-6, -18)
        ..lineTo(5, -18)
        ..lineTo(8 - sw * 3, -5)
        ..lineTo(-9 - sw * 3, -5)
        ..close();
      _fill.color = _dark(p.shirt, .35);
      c.drawPath(tail, _fill);
      c.drawPath(tail, _stroke..strokeWidth = 1..color = _ol);
    }
    leg(-sw, false);
    upper(() {
      final bh = kick ? const Offset(-7, -24) : Offset(-2 + sw * 9, -17);
      arm(const Offset(-1, -28), const Offset(-3.5, -22), bh, back: true);
      torso();
    });
    leg(sw, true);
    upper(() {
      head();
      late double hx, hy;
      if (punch) {
        arm(const Offset(1, -28), const Offset(9, -28.5), const Offset(17, -28));
        hx = 18;
        hy = -28;
        _fill.color = p.skin;
        c.drawCircle(Offset(hx, hy), 3.2, _fill);
        c.drawCircle(Offset(hx, hy), 3.2, _stroke..strokeWidth = 1..color = _ol);
        c.drawCircle(Offset(hx - .8, hy - .9), 1, Paint()..color = const Color(0x66FFFFFF));
      } else {
        hx = kick ? 9 : 2 - sw * 9;
        hy = kick ? -31 : -17;
        arm(const Offset(1, -28), Offset((1 + hx) / 2 + 1, (-28 + hy) / 2), Offset(hx, hy));
      }
      _fill.color = p.outfit == Outfit.vest ? p.skin : p.shirt;
      c.drawCircle(const Offset(1, -28.5), 3.8, _fill);
      c.drawCircle(const Offset(1, -28.5), 3.8, _stroke..strokeWidth = 1..color = _ol);
      if (weapon == Weapon.knife) {
        _limb(c, [Offset(hx + 1, hy + 1), Offset(hx + 10, hy - 5)], 2.4, const Color(0xFFD8DDE8));
        _limb(c, [Offset(hx - 1, hy + 2), Offset(hx + 2, hy)], 3.4, const Color(0xFF2A2A33), shine: false);
      } else if (weapon == Weapon.bat) {
        _limb(c, [Offset(hx - 1, hy + 3), Offset(hx + 8, hy - 15)], 3.6, const Color(0xFFA8743A));
        _limb(c, [Offset(hx - 1, hy + 3), Offset(hx + 1.2, hy - 1.5)], 3.7, const Color(0xFF222222), shine: false);
      }
    });

    c.restore();
    if (flash) c.restore();
  }
}

import 'dart:math' as math;
import 'dart:ui';

import '../game_enums.dart';
import 'fighter_painter.dart';
import 'sprite_data.dart';

/// Desenha um lutador a partir de uma folha de sprites em pixel art
/// (pés na origem, sprite virado à direita no atlas).
abstract final class SpritePainter {
  static final Paint _paint = Paint()..filterQuality = FilterQuality.medium;

  static SpriteFrame frameFor(SpriteSheetData s, {required FighterPose pose, required bool moving, required double phase, required bool air}) {
    switch (pose) {
      case FighterPose.punch:
        return s.punch;
      case FighterPose.kick:
        return s.kick;
      case FighterPose.hurt:
        return s.hurt;
      case FighterPose.down:
        return s.down;
      case FighterPose.idle:
        if (air) return s.kickWindup ?? s.idle;
        if (!moving) return s.idle;
        final i = (phase / (math.pi / 2)).floor() % s.walk.length;
        return s.walk[i];
    }
  }

  static void paint(
    Canvas c, {
    required Image image,
    required SpriteSheetData sheet,
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
    FighterPainter.drawShadow(c, scale * (sheet == SpriteSheets.bigtyk ? 1.5 : 1), height);
    final f = frameFor(sheet, pose: pose, moving: moving, phase: phase, air: height > 0);
    final k = sheet.pxScale * scale;
    // respiração quando está parado
    final breathe = (pose == FighterPose.idle && !moving && height == 0) ? 1 + math.sin(time * 3.2) * .012 : 1.0;

    c.save();
    c.translate(0, -height);
    c.scale(facing * k, k * breathe);
    final dst = Rect.fromLTWH(-f.ax, -f.ay, f.w, f.h);
    final src = Rect.fromLTWH(f.x, f.y, f.w, f.h);
    if (flash) {
      c.saveLayer(dst.inflate(2), Paint());
      c.drawImageRect(image, src, dst, _paint);
      c.drawRect(dst.inflate(2), Paint()
        ..color = const Color(0xB3FFFFFF)
        ..blendMode = BlendMode.srcATop);
      c.restore();
    } else {
      c.drawImageRect(image, src, dst, _paint);
    }
    c.restore();

    if (weapon != null && pose != FighterPose.down && pose != FighterPose.hurt) {
      // mão da frente, em unidades do jogo (aproximado para as poses do atlas)
      final punch = pose == FighterPose.punch;
      c.save();
      c.translate(0, -height);
      c.scale(facing * scale, scale);
      FighterPainter.drawWeapon(c, weapon, punch ? 17 : 7, punch ? -31 : -27);
      c.restore();
    }
  }
}

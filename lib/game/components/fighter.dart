import 'dart:ui';

import 'package:flame/components.dart';

import '../game_enums.dart';
import '../punhos_game.dart';
import 'fighter_painter.dart';
import 'sprite_data.dart';
import 'sprite_painter.dart';

/// Base de qualquer lutador. A posição é o ponto dos pés; [z] é a altura.
abstract class Fighter extends PositionComponent with HasGameReference<PunhosGame> {
  Fighter({required this.maxHp, required this.palette, this.bodyScale = 1}) : hp = maxHp;

  final int maxHp;
  int hp;
  FighterPalette palette;
  final double bodyScale;

  int facing = 1;
  double z = 0;
  double vz = 0;
  double walkPhase = 0;
  double hurtTimer = 0;
  double flashTimer = 0;
  FighterPose pose = FighterPose.idle;
  double _lastPhase = 0;
  bool _moving = false;

  Weapon? get visibleWeapon => null;

  /// Folha de sprites em pixel art; sem ela usa-se o desenho vetorial.
  SpriteSheetData? get sheet => null;

  /// Escala extra da sprite (ex.: chefes maiores).
  double get spriteScale => 1;
  bool get hidden => false;

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.round();
    _moving = walkPhase != _lastPhase;
    _lastPhase = walkPhase;
    if (flashTimer > 0) flashTimer -= dt * 60;
  }

  @override
  void render(Canvas canvas) {
    if (hidden) return;
    final s = sheet;
    if (s != null && game.images.containsKey(s.file)) {
      SpritePainter.paint(
        canvas,
        image: game.images.fromCache(s.file),
        sheet: s,
        facing: facing,
        phase: walkPhase,
        pose: pose,
        moving: _moving,
        time: game.frame / 60,
        height: z,
        scale: spriteScale,
        flash: flashTimer > 0,
        weapon: visibleWeapon,
      );
      return;
    }
    FighterPainter.paint(
      canvas,
      palette: palette,
      facing: facing,
      phase: walkPhase,
      pose: pose,
      moving: _moving,
      time: game.frame / 60,
      height: z,
      scale: bodyScale,
      flash: flashTimer > 0,
      weapon: visibleWeapon,
    );
  }
}

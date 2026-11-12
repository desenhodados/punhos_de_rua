import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

import '../game_enums.dart';

/// Arma caída no chão.
class Pickup extends PositionComponent {
  Pickup({required this.weapon, required Vector2 at}) : super(position: at, priority: at.y.round());

  final Weapon weapon;

  @override
  void render(Canvas canvas) {
    final glow = Paint()..shader = Gradient.radial(Offset.zero, 14, const [Color(0x59FFE696), Color(0x00FFE696)]);
    canvas.drawCircle(Offset.zero, 14, glow);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (weapon == Weapon.knife) {
      canvas.drawLine(const Offset(-4, -2), const Offset(3, -3), line..strokeWidth = 2.2..color = const Color(0xFFD8DDE8));
      canvas.drawLine(const Offset(3, -3), const Offset(7, -3), line..strokeWidth = 3.5..color = const Color(0xFF333333));
    } else {
      canvas.drawLine(const Offset(-8, -2), const Offset(8, -3), line..strokeWidth = 3.5..color = const Color(0xFFA8743A));
      canvas.drawLine(const Offset(5, -3), const Offset(8, -3), line..strokeWidth = 5..color = const Color(0xFFC58A48));
    }
  }
}

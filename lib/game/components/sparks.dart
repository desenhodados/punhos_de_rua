import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

class _Spark {
  _Spark(this.x, this.y, this.vx, this.vy, this.life);
  double x, y, vx, vy, life;
}

/// Faíscas dos golpes.
class Sparks extends PositionComponent {
  Sparks() : super(priority: 500);

  final List<_Spark> _list = [];
  final math.Random _rng = math.Random();

  void emit(double x, double y, int n) {
    for (var i = 0; i < n; i++) {
      _list.add(_Spark(x, y, (_rng.nextDouble() - .5) * 5, -_rng.nextDouble() * 3.5, 12 + _rng.nextDouble() * 10));
    }
  }

  @override
  void update(double dt) {
    final f = dt * 60;
    for (final s in _list) {
      s.x += s.vx * f;
      s.y += s.vy * f;
      s.vy += .25 * f;
      s.life -= f;
    }
    _list.removeWhere((s) => s.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    final p = Paint();
    for (final s in _list) {
      p.color = Color.fromRGBO(255, math.min(255, 200 + (s.life * 2).round()), 120, math.min(1.0, s.life / 10));
      canvas.drawRect(Rect.fromLTWH(s.x, s.y, 2, 2), p);
    }
  }
}

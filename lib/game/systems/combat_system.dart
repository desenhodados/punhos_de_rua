import '../components/enemy.dart';
import '../components/player.dart';

/// Regras de acerto dos golpes do jogador.
class CombatSystem {
  CombatSystem(this._enemies);

  final List<Enemy> _enemies;

  /// Devolve quantos inimigos foram atingidos.
  int strike({
    required Player attacker,
    required double range,
    required int damage,
    required bool knockdown,
  }) {
    var hits = 0;
    for (final e in List<Enemy>.of(_enemies)) {
      if (!e.canBeHit) continue;
      final dx = (e.position.x - attacker.position.x) * attacker.facing;
      final dy = (e.position.y - attacker.position.y).abs();
      if (dx > -6 && dx < range && dy < 10) {
        e.takeDamage(damage, dir: attacker.facing, knockdown: knockdown);
        hits++;
      }
    }
    return hits;
  }
}

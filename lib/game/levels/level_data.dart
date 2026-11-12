import 'dart:ui';

import '../components/enemy.dart';
import '../game_enums.dart';

const _g = EnemyKind.grunt;
const _t = EnemyKind.thug;
const _k = EnemyKind.knifer;
const _b = EnemyKind.boss;
const _v = EnemyKind.viper;

class PickupSpawn {
  const PickupSpawn(this.weapon, this.x, this.y);
  final Weapon weapon;
  final double x;
  final double y;
}

/// Um nível é só dados: cores, ondas de inimigos, armas e história.
class LevelData {
  const LevelData({
    required this.sky,
    required this.far,
    required this.mid,
    required this.road,
    required this.bossHp,
    required this.waves,
    required this.storyPages,
    required this.pickups,
  });

  final List<Color> sky;
  final Color far;
  final Color mid;
  final List<Color> road;
  final int bossHp;
  final List<List<EnemyKind>> waves;
  final List<List<String>> storyPages;
  final List<PickupSpawn> pickups;
}

abstract final class Levels {
  static const List<LevelData> all = [
    LevelData(
      sky: [Color(0xFF0E0A2E), Color(0xFF5B2A6B), Color(0xFFF08A5D)],
      far: Color(0xFF2B1A55),
      mid: Color(0xFF241A4A),
      road: [Color(0xFF2E2E3A), Color(0xFF15151C)],
      bossHp: 22,
      waves: [[_g, _g], [_g, _t, _g], [_t, _g, _t, _g], [_b, _t, _g]],
      pickups: [PickupSpawn(Weapon.bat, 640, 150)],
      storyPages: [
        ['PORTO NOVO, 1987', '', 'As Serpentes de Néon tomaram', 'a cidade e raptaram o', 'mestre Hiro.'],
        ['Tomás, o seu melhor aluno,', 'jura trazê-lo de volta.', '', 'NÍVEL 1: O CAIS'],
      ],
    ),
    LevelData(
      sky: [Color(0xFF1A0F08), Color(0xFF5A2A12), Color(0xFFD9822B)],
      far: Color(0xFF3A1C10),
      mid: Color(0xFF2A160E),
      road: [Color(0xFF3A3028), Color(0xFF1C1612)],
      bossHp: 30,
      waves: [[_g, _k, _g], [_t, _k, _g, _t], [_k, _t, _k, _g], [_b, _k, _t, _g]],
      pickups: [PickupSpawn(Weapon.knife, 420, 150), PickupSpawn(Weapon.bat, 900, 140)],
      storyPages: [
        ['Os capangas falam de um', 'armazém no fim do cais.', 'É lá que o mestre está preso.', '', 'NÍVEL 2: O ARMAZÉM'],
      ],
    ),
    LevelData(
      sky: [Color(0xFF050818), Color(0xFF1B2A5A), Color(0xFF4A7AC8)],
      far: Color(0xFF10183A),
      mid: Color(0xFF0E1634),
      road: [Color(0xFF3A4256), Color(0xFF1A1E2C)],
      bossHp: 40,
      waves: [[_k, _t, _k], [_t, _k, _t, _k], [_k, _t, _k, _g, _t], [_v, _k, _t, _k]],
      pickups: [PickupSpawn(Weapon.bat, 380, 150), PickupSpawn(Weapon.knife, 800, 150)],
      storyPages: [
        ['Num bilhete, o chefe revela-se:', 'a Víbora espera no telhado.', 'Ninguém lhe escapou... até hoje.', '', 'NÍVEL 3: O TELHADO'],
      ],
    ),
  ];

  static List<String> endingLines(int score) => [
        'VITÓRIA!',
        '',
        'A Víbora cai e o mestre Hiro',
        'está livre. “Orgulho-me de ti,',
        'Tomás.”',
        '',
        'PONTOS: $score',
      ];
}

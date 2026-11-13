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

/// Um nível é só dados: cenário, cores, ondas de inimigos, armas e história.
/// Nas páginas de história, `{HEROI}` é trocado pelo nome do lutador escolhido.
class LevelData {
  const LevelData({
    required this.scene,
    required this.image,
    this.imageFocusX = 0,
    required this.sky,
    required this.far,
    required this.mid,
    required this.road,
    required this.bossHp,
    required this.waves,
    required this.storyPages,
    required this.pickups,
  });

  final Scenery scene;

  /// Ilustração mostrada nas páginas de história (ver assets/images).
  final String image;

  /// Posição horizontal da personagem na ilustração (-1 esquerda, 1 direita).
  final double imageFocusX;
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
      scene: Scenery.newYork,
      image: 'assets/images/nova_iorque.jpg',
      imageFocusX: .04,
      sky: [Color(0xFF0B0A26), Color(0xFF3A1F5C), Color(0xFFD0607A)],
      far: Color(0xFF1D1640),
      mid: Color(0xFF4A2230),
      road: [Color(0xFF2A2638), Color(0xFF0D0C14)],
      bossHp: 0,
      waves: [[_g, _g], [_g, _t, _g], [_t, _g, _k], [_t, _k, _t, _g]],
      pickups: [PickupSpawn(Weapon.bat, 640, 150)],
      storyPages: [
        ['NOVA IORQUE, 1987', '', 'O gangue Cobras de Aço, punks', 'de Londres e motoqueiros da', 'Rota 66, raptou a Lena à', 'saída do metro.'],
        ['{HEROI} não vai esperar', 'pela polícia.', '', 'NÍVEL 1: O METRO'],
      ],
    ),
    LevelData(
      scene: Scenery.london,
      image: 'assets/images/londres.jpg',
      imageFocusX: -.02,
      sky: [Color(0xFF1A1A24), Color(0xFF3E3A4E), Color(0xFF8A7A6E)],
      far: Color(0xFF2A2836),
      mid: Color(0xFF6A2E26),
      road: [Color(0xFF34323E), Color(0xFF121118)],
      bossHp: 28,
      waves: [[_t, _g, _t], [_t, _k, _g, _t], [_k, _t, _t, _g], [_v, _t, _g]],
      pickups: [PickupSpawn(Weapon.knife, 420, 150), PickupSpawn(Weapon.bat, 900, 140)],
      storyPages: [
        ['Um capanga deixa escapar:', 'a pista leva a Londres, ao', 'bando de punks da Víbora.', '', 'NÍVEL 2: LONDRES'],
      ],
    ),
    LevelData(
      scene: Scenery.europeNight,
      image: 'assets/images/paris.jpg',
      imageFocusX: -.05,
      sky: [Color(0xFF050A1E), Color(0xFF14285A), Color(0xFF3F6AA8)],
      far: Color(0xFF22336A),
      mid: Color(0xFF3A2A36),
      road: [Color(0xFF4A4658), Color(0xFF16141E)],
      bossHp: 34,
      waves: [[_k, _t, _k], [_t, _k, _t, _k], [_k, _t, _k, _g, _t], [_v, _k, _t]],
      pickups: [PickupSpawn(Weapon.bat, 380, 150), PickupSpawn(Weapon.knife, 800, 150)],
      storyPages: [
        ['A Víbora fugiu para Paris.', 'Numa noite fria, nas ruelas', 'de Montmartre, quer vingança.', '', 'NÍVEL 3: PARIS'],
      ],
    ),
    LevelData(
      scene: Scenery.diner,
      image: 'assets/images/lanchonete.jpg',
      imageFocusX: -.35,
      sky: [Color(0xFF2A1250), Color(0xFFC2456A), Color(0xFFFFB35A)],
      far: Color(0xFF6A2A4A),
      mid: Color(0xFF1A1028),
      road: [Color(0xFF4A3A4A), Color(0xFF1A1218)],
      bossHp: 44,
      waves: [[_k, _g, _k], [_t, _k, _k, _g], [_k, _t, _k, _t, _g], [_b, _k, _t]],
      pickups: [PickupSpawn(Weapon.knife, 380, 150), PickupSpawn(Weapon.bat, 760, 140)],
      storyPages: [
        ['A Víbora confessa: o chefe', 'é o Big Tyk, rei dos motoqueiros.', 'A Lena está presa numa', 'lanchonete na Rota 66.', '', 'NÍVEL 4: A LANCHONETE'],
      ],
    ),
  ];

  static List<String> endingLines(int score, String hero) => [
        'VITÓRIA!',
        '',
        'O Big Tyk cai no asfalto e a',
        'Lena está livre. “Sabia que',
        'vinhas, $hero.”',
        '',
        'PONTOS: $score',
      ];
}

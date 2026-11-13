// Gerado a partir da folha de sprites em pixel art (assets/images/sprites/).
// Cada pose é um retângulo no atlas e um ponto de âncora (os pés).

/// Um quadro: retângulo no atlas e ponto de âncora (pés) dentro do quadro, em píxeis.
class SpriteFrame {
  const SpriteFrame(this.x, this.y, this.w, this.h, this.ax, this.ay);
  final double x, y, w, h, ax, ay;
}

/// Todas as poses de uma personagem num atlas.
class SpriteSheetData {
  const SpriteSheetData({required this.file, required this.pxScale, required this.idle, required this.walk, required this.punch, required this.kick, required this.hurt, required this.down, this.windup, this.kickWindup});

  /// Ficheiro do atlas, relativo a assets/images/.
  final String file;

  /// Unidades do jogo por píxel do atlas.
  final double pxScale;
  final SpriteFrame idle;
  final List<SpriteFrame> walk;
  final SpriteFrame punch;
  final SpriteFrame kick;
  final SpriteFrame hurt;
  final SpriteFrame down;
  final SpriteFrame? windup;
  final SpriteFrame? kickWindup;

  /// As mesmas poses noutro atlas (variante de cores).
  SpriteSheetData withFile(String other) => SpriteSheetData(
        file: other,
        pxScale: pxScale,
        idle: idle,
        walk: walk,
        punch: punch,
        kick: kick,
        hurt: hurt,
        down: down,
        windup: windup,
        kickWindup: kickWindup,
      );
}

abstract final class SpriteSheets {
  /// Punks inimigos: crista vermelha; a Víbora tem crista verde.
  static final punkRed = punk.withFile('sprites/punk_red.png');
  static final punkGreen = punk.withFile('sprites/punk_green.png');

  static List<SpriteSheetData> get all => [leo, punk, punkRed, punkGreen, bigtyk, clara];

  static const leo = SpriteSheetData(
    file: 'sprites/leo.png',
    pxScale: 0.3672,
    idle: SpriteFrame(0, 0, 63, 128, 30.0, 128),
    walk: [
      SpriteFrame(65, 0, 61, 124, 32.1, 124),
      SpriteFrame(128, 0, 64, 123, 36.2, 123),
      SpriteFrame(194, 0, 58, 128, 31.2, 128),
      SpriteFrame(254, 0, 63, 126, 35.3, 126),
    ],
    punch: SpriteFrame(426, 0, 103, 129, 48.3, 129),
    kick: SpriteFrame(613, 0, 101, 129, 19.1, 129),
    hurt: SpriteFrame(716, 0, 75, 122, 27.7, 122),
    down: SpriteFrame(793, 0, 138, 47, 69.0, 47),
    windup: SpriteFrame(319, 0, 105, 128, 44.4, 128),
    kickWindup: SpriteFrame(531, 0, 80, 127, 47.3, 127),
  );

  static const punk = SpriteSheetData(
    file: 'sprites/punk.png',
    pxScale: 0.3657,
    idle: SpriteFrame(0, 0, 61, 134, 33.2, 134),
    walk: [
      SpriteFrame(63, 0, 68, 134, 30.8, 134),
      SpriteFrame(133, 0, 68, 134, 39.2, 134),
      SpriteFrame(203, 0, 59, 135, 33.1, 135),
      SpriteFrame(264, 0, 56, 142, 32.0, 142),
    ],
    punch: SpriteFrame(390, 0, 101, 137, 42.0, 137),
    kick: SpriteFrame(493, 0, 117, 136, 20.6, 136),
    hurt: SpriteFrame(612, 0, 80, 130, 26.7, 130),
    down: SpriteFrame(694, 0, 141, 38, 70.5, 38),
    windup: SpriteFrame(322, 0, 66, 137, 33.6, 137),
  );

  static const bigtyk = SpriteSheetData(
    file: 'sprites/bigtyk.png',
    pxScale: 0.4138,
    idle: SpriteFrame(0, 0, 140, 174, 68.1, 174),
    walk: [
      SpriteFrame(142, 0, 114, 178, 53.3, 178),
      SpriteFrame(258, 0, 129, 173, 65.8, 173),
    ],
    punch: SpriteFrame(389, 0, 172, 177, 77.4, 177),
    kick: SpriteFrame(563, 0, 156, 182, 107.6, 182),
    hurt: SpriteFrame(721, 0, 132, 153, 99.4, 153),
    down: SpriteFrame(855, 0, 192, 82, 96.0, 82),
  );

  static const clara = SpriteSheetData(
    file: 'sprites/clara.png',
    pxScale: 0.3038,
    idle: SpriteFrame(0, 0, 69, 158, 31.2, 158),
    walk: [
      SpriteFrame(71, 0, 69, 153, 30.4, 153),
      SpriteFrame(142, 0, 75, 152, 31.2, 152),
      SpriteFrame(219, 0, 81, 154, 37.2, 154),
    ],
    punch: SpriteFrame(302, 0, 119, 154, 41.6, 154),
    kick: SpriteFrame(423, 0, 137, 158, 29.9, 158),
    hurt: SpriteFrame(562, 0, 100, 161, 48.8, 161),
    down: SpriteFrame(664, 0, 169, 60, 84.5, 60),
  );
}

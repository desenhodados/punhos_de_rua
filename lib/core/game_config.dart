/// Constantes do jogo. Todas as coordenadas são "lógicas": o ecrã tem sempre
/// 180 de altura e a largura depende da proporção do telemóvel.
abstract final class GameConfig {
  static const double viewHeight = 180;
  static const double worldWidth = 1500;
  static const double groundMinY = 112;
  static const double groundMaxY = 172;
  static const double playerSpeedX = 1.5;
  static const double playerSpeedY = 1.2;

  /// Posição X onde cada onda de inimigos é ativada.
  static const List<double> zoneTriggers = [220, 560, 900, 1180];
}

enum GamePhase { title, story, playing, gameOver, ending }

enum GameAction { punch, jump, grab }

enum Weapon { bat, knife }

enum FighterPose { idle, punch, kick, hurt, down }

enum HairStyle { headband, cap, mohawk, bald, feathered, ponytail, biker }

enum Outfit { tee, vest, jacket, coat, leather, bomber, punkVest, bikerVest }

/// Cenários: cada nível desenha uma cidade diferente.
enum Scenery {
  newYork('nova_iorque'),
  london('londres'),
  europeNight('paris'),
  diner('lanchonete');

  const Scenery(this.fileName);

  /// Nome do ficheiro do cenário em assets/images/cenarios/.
  final String fileName;
}

/// Lutadores que o jogador pode escolher.
enum PlayerHero { jack, leo, clara, punk }

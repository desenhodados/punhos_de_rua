import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import '../core/game_config.dart';
import 'audio/audio_manager.dart';
import 'components/background.dart';
import 'components/enemy.dart';
import 'components/hud.dart';
import 'components/pickup.dart';
import 'components/player.dart';
import 'components/sparks.dart';
import 'components/sprite_data.dart';
import 'game_enums.dart';
import 'input_state.dart';
import 'levels/level_data.dart';
import 'systems/combat_system.dart';

/// Jogo principal: estado, câmara, ondas de inimigos e passagem de níveis.
class PunhosGame extends FlameGame {
  final InputState input = InputState();
  final AudioManager audio = AudioManager();
  late final CombatSystem combat = CombatSystem(enemies);

  /// Raiz escalada para que o ecrã tenha sempre 180 unidades de altura.
  final PositionComponent root = PositionComponent();

  /// Mundo que desliza com a câmara.
  final PositionComponent stage = PositionComponent();
  final Player player = Player();
  final Sparks sparks = Sparks();
  final List<Enemy> enemies = [];
  final List<Pickup> pickups = [];
  final math.Random _rng = math.Random();

  GamePhase phase = GamePhase.title;
  int levelIndex = 0;
  int zone = 0;
  int frame = 0;
  bool locked = false;
  bool showGo = false;
  double cameraX = 0;
  double lockCamera = 0;
  double viewWidth = 320;
  double shake = 0;

  LevelData get level => Levels.all[levelIndex];

  /// Imagens de cenário encontradas em assets/images/cenarios/ (chave do cache de imagens).
  final Map<Scenery, SceneryImages> sceneryImages = {};

  @override
  Future<void> onLoad() async {
    await images.loadAll([for (final s in SpriteSheets.all) s.file]);
    await _loadSceneryImages();
    await add(root);
    root.add(Background());
    root.add(stage);
    root.add(Vignette());
    root.add(Hud());
    stage.add(player);
    stage.add(sparks);
    _loadLevel(0);
  }

  /// Procura cenários em pixel art; os que faltarem são desenhados por código.
  Future<void> _loadSceneryImages() async {
    Set<String> assets;
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      assets = manifest.listAssets().toSet();
    } catch (_) {
      return;
    }
    String? find(String name) {
      for (final ext in const ['png', 'jpg', 'jpeg', 'webp']) {
        final path = 'assets/images/cenarios/$name.$ext';
        if (assets.contains(path)) return path.substring('assets/images/'.length);
      }
      return null;
    }

    for (final scene in Scenery.values) {
      final main = find(scene.fileName);
      if (main == null) continue;
      final far = find('${scene.fileName}_fundo');
      await images.loadAll([main, if (far != null) far]);
      sceneryImages[scene] = SceneryImages(main, far);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final s = size.y / GameConfig.viewHeight;
    root.scale = Vector2.all(s);
    viewWidth = size.x / s;
  }

  // ---- Fluxo do jogo ----

  /// Começa um jogo novo; sem [hero] repete o lutador anterior.
  void startGame([PlayerHero? hero]) {
    overlays
      ..remove('title')
      ..remove('gameOver')
      ..remove('ending');
    if (hero != null) player.chooseHero(hero);
    player.resetForNewGame();
    _loadLevel(0);
    phase = GamePhase.story;
    overlays.add('story');
  }

  void backToTitle() {
    overlays
      ..remove('gameOver')
      ..remove('ending')
      ..add('title');
    phase = GamePhase.title;
    _loadLevel(0);
  }

  void beginPlay() {
    overlays.remove('story');
    phase = GamePhase.playing;
    overlays.add('controls');
  }

  void onGameOver() {
    input.clear();
    phase = GamePhase.gameOver;
    overlays
      ..remove('controls')
      ..add('gameOver');
  }

  void _completeLevel() {
    audio.play(Sfx.levelClear);
    input.clear();
    overlays.remove('controls');
    if (levelIndex < Levels.all.length - 1) {
      _loadLevel(levelIndex + 1);
      phase = GamePhase.story;
      overlays.add('story');
    } else {
      phase = GamePhase.ending;
      overlays.add('ending');
    }
  }

  void _loadLevel(int index) {
    levelIndex = index;
    for (final e in List<Enemy>.of(enemies)) {
      e.removeFromParent();
    }
    enemies.clear();
    for (final p in List<Pickup>.of(pickups)) {
      p.removeFromParent();
    }
    pickups.clear();
    cameraX = 0;
    zone = 0;
    locked = false;
    showGo = false;
    stage.position.x = 0;
    player.prepareForLevel(index);
    for (final s in level.pickups) {
      final p = Pickup(weapon: s.weapon, at: Vector2(s.x, s.y));
      pickups.add(p);
      stage.add(p);
    }
  }

  // ---- Utilitários usados pelos componentes ----

  void removePickup(Pickup p) {
    pickups.remove(p);
    p.removeFromParent();
  }

  void spawnSparks(double x, double y, int n) => sparks.emit(x, y, n);

  // ---- Ciclo ----

  @override
  void update(double dt) {
    super.update(dt);
    frame++;
    _updateShake(dt);
    if (phase != GamePhase.playing) return;

    final hi = locked ? lockCamera : math.max(0.0, GameConfig.worldWidth - viewWidth);
    cameraX = math.max(cameraX, math.min(player.position.x - viewWidth * .4, hi));
    stage.position.x = -cameraX;

    if (!locked && zone < level.waves.length && player.position.x > GameConfig.zoneTriggers[zone]) {
      _spawnWave();
    } else if (locked && enemies.every((e) => e.defeated)) {
      locked = false;
      zone++;
      showGo = true;
      if (zone >= level.waves.length) _completeLevel();
    }
  }

  void _spawnWave() {
    final kinds = level.waves[zone];
    for (var i = 0; i < kinds.length; i++) {
      final side = (i + zone).isOdd ? 1 : -1;
      final kind = kinds[i];
      final e = Enemy(kind: kind, hp: kind.isBoss ? level.bossHp : kind.baseHp);
      e.position.setValues(
        side < 0 ? cameraX - 20 - i * 22 : cameraX + viewWidth + 20 + i * 22,
        118 + _rng.nextDouble() * 48,
      );
      e.facing = -side;
      enemies.add(e);
      stage.add(e);
    }
    locked = true;
    showGo = false;
    lockCamera = math.min(GameConfig.worldWidth - viewWidth, math.max(cameraX, player.position.x - viewWidth * .4));
  }

  void _updateShake(double dt) {
    if (shake > .3) {
      final k = shake * root.scale.x;
      root.position.setValues((_rng.nextDouble() - .5) * k, (_rng.nextDouble() - .5) * k);
      shake *= math.pow(.85, dt * 60).toDouble();
    } else if (shake != 0) {
      shake = 0;
      root.position.setZero();
    }
  }
}

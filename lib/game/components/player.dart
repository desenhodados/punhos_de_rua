import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../../core/game_config.dart';
import '../audio/audio_manager.dart';
import '../game_enums.dart';
import 'enemy.dart';
import 'fighter.dart';
import 'fighter_painter.dart';

class Player extends Fighter {
  Player() : super(maxHp: 12, palette: Palettes.hero) {
    position = Vector2(50, 140);
  }

  int lives = 3;
  int score = 0;
  Weapon? weapon;
  int weaponUses = 0;
  int combo = 0;
  double attackTimer = 0;
  double cooldown = 0;
  double comboTimer = 0;
  double invuln = 0;
  double holdTimer = 0;
  bool _kickAnim = false;
  Enemy? held;

  @override
  Weapon? get visibleWeapon => z == 0 ? weapon : null;

  @override
  bool get hidden => invuln > 0 && hurtTimer <= 0 && (game.frame >> 2).isOdd;

  void resetForNewGame() {
    hp = maxHp;
    lives = 3;
    score = 0;
    weapon = null;
    prepareForLevel(0);
  }

  void prepareForLevel(int index) {
    if (index > 0) hp = math.min(maxHp, hp + 6);
    held = null;
    z = 0;
    vz = 0;
    hurtTimer = 0;
    invuln = 0;
    position.setValues(50, 140);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.phase != GamePhase.playing) return;
    final f = dt * 60;
    final input = game.input;

    if (hurtTimer > 0) {
      hurtTimer -= f;
    } else {
      position.x += input.dx * GameConfig.playerSpeedX * f;
      position.y += input.dy * GameConfig.playerSpeedY * f;
      if (input.dx != 0) {
        facing = input.dx.toInt();
        walkPhase += .3 * f;
      } else if (input.dy != 0) {
        walkPhase += .3 * f;
      }
    }
    position.y = position.y.clamp(GameConfig.groundMinY, GameConfig.groundMaxY).toDouble();
    position.x = position.x.clamp(game.cameraX + 8, game.cameraX + game.viewWidth - 8).toDouble();

    attackTimer = math.max(0.0, attackTimer - f);
    cooldown = math.max(0.0, cooldown - f);
    comboTimer = math.max(0.0, comboTimer - f);
    invuln = math.max(0.0, invuln - f);
    z += vz * f;
    vz -= .3 * f;
    if (z <= 0) {
      z = 0;
      vz = 0;
    }
    pose = hurtTimer > 0
        ? FighterPose.hurt
        : attackTimer > 0
            ? (_kickAnim ? FighterPose.kick : FighterPose.punch)
            : FighterPose.idle;

    _pickUpItems();
    final h = held;
    if (h != null) {
      holdTimer += f;
      if (!h.isHeld || holdTimer > 150) _release();
    }
  }

  void _pickUpItems() {
    if (weapon != null || z > 0) return;
    for (final item in List.of(game.pickups)) {
      if ((item.position.x - position.x).abs() < 12 && (item.position.y - position.y).abs() < 9) {
        weapon = item.weapon;
        weaponUses = item.weapon == Weapon.knife ? 10 : 8;
        game.removePickup(item);
        game.audio.play(Sfx.pickup);
        break;
      }
    }
  }

  void onAction(GameAction action) {
    if (hurtTimer > 0) return;
    switch (action) {
      case GameAction.jump:
        if (z == 0) {
          vz = 4.3;
          game.audio.play(Sfx.jump);
        }
      case GameAction.grab:
        _grabOrThrow();
      case GameAction.punch:
        _attack();
    }
  }

  void _attack() {
    if (cooldown > 0) return;
    if (z > 0) {
      _swing(kick: true, cd: 18, range: 32, damage: 2, knockdown: true, air: true);
      return;
    }
    final h = held;
    if (h != null) {
      _kickAnim = true;
      attackTimer = 8;
      cooldown = 14;
      h.takeDamage(1, dir: facing);
      return;
    }
    if (game.input.down) {
      comboTimer = 0;
      _swing(kick: true, cd: 22, range: 32, damage: 1, knockdown: true);
      return;
    }
    final knife = weapon == Weapon.knife;
    combo = comboTimer > 0 ? (combo + 1) % 3 : 0;
    comboTimer = 26;
    _swing(
      kick: false,
      cd: knife ? 8 : 11,
      range: weapon == Weapon.bat ? 34 : 24,
      damage: weapon == null ? 1 : (knife ? 2 : 3),
      knockdown: combo == 2,
    );
  }

  void _swing({
    required bool kick,
    required double cd,
    required double range,
    required int damage,
    required bool knockdown,
    bool air = false,
  }) {
    _kickAnim = kick;
    attackTimer = kick ? 14 : 8;
    cooldown = cd;
    final hits = game.combat.strike(attacker: this, range: range, damage: damage, knockdown: knockdown);
    if (!air && hits > 0 && weapon != null) {
      weaponUses -= hits;
      if (weaponUses <= 0) weapon = null;
    }
  }

  void _grabOrThrow() {
    final h = held;
    if (h != null) {
      held = null;
      h.beThrown(facing);
      cooldown = 14;
      attackTimer = 10;
      _kickAnim = false;
      game.shake = 3;
      game.audio.play(Sfx.throwEnemy);
      return;
    }
    if (z > 0 || cooldown > 0) return;
    for (final e in game.enemies) {
      final dx = (e.position.x - position.x) * facing;
      if (e.canBeGrabbed && dx > -4 && dx < 20 && (e.position.y - position.y).abs() < 9) {
        held = e;
        e.beHeld();
        holdTimer = 0;
        break;
      }
    }
  }

  void _release() {
    held?.release();
    held = null;
  }

  void takeHit(int damage, int fromFacing) {
    if (invuln > 0 || z > 6) return;
    hp -= damage;
    hurtTimer = 16;
    invuln = 45;
    flashTimer = 10;
    position.x += fromFacing * 8;
    _release();
    game.shake = 5;
    game.spawnSparks(position.x, position.y - 22, 8);
    game.audio.play(Sfx.hurt);
    if (hp <= 0) {
      lives--;
      if (lives < 0) {
        game.onGameOver();
      } else {
        hp = maxHp;
        invuln = 100;
      }
    }
  }
}

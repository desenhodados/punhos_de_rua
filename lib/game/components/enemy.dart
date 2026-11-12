import 'dart:math' as math;

import 'fighter.dart';
import 'fighter_painter.dart';
import '../game_enums.dart';

enum EnemyKind { grunt, thug, knifer, boss, viper }

extension EnemyKindStats on EnemyKind {
  bool get isBoss => this == EnemyKind.boss || this == EnemyKind.viper;

  int get baseHp => switch (this) {
        EnemyKind.grunt => 4,
        EnemyKind.thug => 6,
        EnemyKind.knifer => 5,
        EnemyKind.boss => 0,
        EnemyKind.viper => 0,
      };

  double get speed => switch (this) {
        EnemyKind.grunt => .65,
        EnemyKind.thug => .85,
        EnemyKind.knifer => .8,
        EnemyKind.boss => .55,
        EnemyKind.viper => .55,
      };

  int get damage => (this == EnemyKind.grunt || this == EnemyKind.thug) ? 1 : 2;
  double get scale => isBoss ? 1.35 : 1;
  Weapon? get weapon => this == EnemyKind.knifer ? Weapon.knife : null;

  FighterPalette get palette => switch (this) {
        EnemyKind.grunt => Palettes.grunt,
        EnemyKind.thug => Palettes.thug,
        EnemyKind.knifer => Palettes.knifer,
        EnemyKind.boss => Palettes.boss,
        EnemyKind.viper => Palettes.viper,
      };
}

class Enemy extends Fighter {
  Enemy({required EnemyKind kind, required int hp})
      : kind = kind,
        super(maxHp: hp, palette: kind.palette, bodyScale: kind.scale);

  final EnemyKind kind;
  double attackTimer = 0;
  double cooldown = 50;
  double stun = 0;
  double downTimer = 0;
  double thrownFrames = 0;
  double _vx = 0;
  bool defeated = false;
  bool isHeld = false;
  bool _hitDone = false;

  bool get isDown => downTimer > 0;
  bool get canBeHit => !defeated && !isDown && !isHeld && thrownFrames <= 0;
  bool get canBeGrabbed => canBeHit && !kind.isBoss;

  @override
  Weapon? get visibleWeapon => kind.weapon;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.phase != GamePhase.playing) return;
    final f = dt * 60;
    final player = game.player;

    if (isHeld) {
      position.setValues(player.position.x + player.facing * 11, player.position.y);
      facing = -player.facing;
      pose = FighterPose.idle;
      return;
    }
    if (thrownFrames > 0) {
      _fly(f);
      return;
    }
    if (downTimer > 0) {
      downTimer -= f;
      pose = FighterPose.down;
      if (downTimer <= 0 && defeated) {
        game.enemies.remove(this);
        removeFromParent();
      }
      return;
    }
    if (stun > 0) {
      stun -= f;
      pose = FighterPose.hurt;
      return;
    }

    final ddx = player.position.x - position.x;
    final ddy = player.position.y - position.y;
    facing = ddx > 0 ? 1 : -1;
    if (attackTimer > 0) attackTimer -= f;
    if (attackTimer <= 0) {
      final tx = ddx - facing * 20;
      if (tx.abs() > 3) {
        position.x += tx.sign * kind.speed * f;
        walkPhase += .25 * f;
      }
      if (ddy.abs() > 3) {
        position.y += ddy.sign * .5 * f;
        walkPhase += .25 * f;
      }
    }
    if (cooldown > 0) {
      cooldown -= f;
    } else if (ddx.abs() < 30 && ddy.abs() < 9 && attackTimer <= 0) {
      attackTimer = 16;
      cooldown = 55;
      _hitDone = false;
    }
    if (attackTimer > 0 && attackTimer <= 8 && !_hitDone) {
      _hitDone = true;
      if (ddx.abs() < 32 && ddy.abs() < 10) player.takeHit(kind.damage, facing);
    }
    pose = attackTimer > 8 ? FighterPose.punch : FighterPose.idle;
  }

  void takeDamage(int amount, {required int dir, bool knockdown = false}) {
    hp -= amount;
    stun = 14;
    flashTimer = 10;
    position.x += dir * (knockdown ? 20 : 5);
    if (knockdown) downTimer = 38;
    game.player.score += 10;
    game.spawnSparks(position.x, position.y - 22, knockdown ? 14 : 7);
    game.shake = knockdown ? 6 : 3;
    if (hp <= 0) _defeat();
  }

  void _defeat() {
    if (defeated) return;
    defeated = true;
    isHeld = false;
    if (downTimer <= 0) downTimer = 38;
    game.player.score += kind.isBoss ? 1000 : 100;
  }

  void beHeld() {
    isHeld = true;
    attackTimer = 0;
  }

  void release() {
    isHeld = false;
    cooldown = 40;
  }

  void beThrown(int dir) {
    isHeld = false;
    thrownFrames = 24;
    _vx = dir * 4.2;
    downTimer = 40;
    hp -= 3;
  }

  void _fly(double f) {
    position.x += _vx * f;
    thrownFrames -= f;
    z = math.sin(math.max(0.0, thrownFrames) / 24 * math.pi) * 16;
    pose = FighterPose.down;
    for (final o in game.enemies) {
      if (identical(o, this) || !o.canBeHit) continue;
      if ((o.position.x - position.x).abs() < 14 && (o.position.y - position.y).abs() < 10) {
        o.takeDamage(2, dir: _vx.sign.toInt(), knockdown: true);
      }
    }
    if (thrownFrames <= 0) {
      z = 0;
      downTimer = 30;
      if (hp <= 0) _defeat();
    }
  }
}

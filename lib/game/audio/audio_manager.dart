enum Sfx { hit, jump, pickup, throwEnemy, hurt, levelClear }

/// Ponto único para sons. Ainda não toca nada: ligar aqui o `flame_audio`
/// quando houver ficheiros em assets/audio.
class AudioManager {
  bool muted = false;

  void play(Sfx sfx) {
    if (muted) return;
    // TODO: FlameAudio.play('${sfx.name}.wav');
  }
}

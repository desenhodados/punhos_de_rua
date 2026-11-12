# Punhos de Rua

Jogo de pancadaria 2D para Android, feito com Flutter + Flame. Personagens e história originais.

## Como correr
1. `flutter create punhos_de_rua --platforms=android`
2. Copiar para dentro dessa pasta: `lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml` (substituir).
3. `flutter pub get` e `flutter run` (telemóvel ou emulador, em modo horizontal).

## Controlos (ecrã tátil)
- Direcional: mover. SOCO: combo de 3 golpes (o 3.º derruba). SALTO + SOCO: pontapé no ar.
- ▼ + SOCO: rasteira. AGARRAR junto a um inimigo: SOCO = joelhada, AGARRAR outra vez = atirar.
- Armas (taco, faca) apanham-se passando por cima.

## Estrutura
- `lib/core/` configuração do jogo.
- `lib/game/punhos_game.dart` estado, câmara, ondas, níveis.
- `lib/game/components/` jogador, inimigos, armas, cenário, HUD, desenho das personagens.
- `lib/game/systems/` regras de combate.
- `lib/game/levels/` os 3 níveis e a história (dados, não lógica).
- `lib/game/audio/` ponto de ligação para os sons (ainda vazio).
- `lib/ui/` ecrãs em Flutter: título, história, controlos, fim.

## Próximos passos
1. Trocar o desenho vetorial (`fighter_painter.dart`) por spritesheets (SpriteAnimationComponent).
2. Sons e música com `flame_audio` em `audio_manager.dart`.
3. Mais inimigos, armas e níveis em `level_data.dart`.

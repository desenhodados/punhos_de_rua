# Punhos de Rua

Jogo de pancadaria 2D para Android, feito com Flutter + Flame. Personagens e história originais.

## Como correr
1. `flutter create punhos_de_rua --platforms=android`
2. Copiar para dentro dessa pasta: `lib/`, `assets/`, `pubspec.yaml`, `analysis_options.yaml` (substituir).
3. `flutter pub get` e `flutter run` (telemóvel ou emulador, em modo horizontal).

## Personagens e cenários
| Ilustração | Personagem | Onde aparece |
|---|---|---|
| `assets/images/nova_iorque.jpg` | **Jack**, lutador urbano dos EUA: loiro, casaco de cabedal, ganga rasgada | Jogável; nível 1 (metro de Brooklyn) |
| `assets/images/londres.jpg` | **Punks** britânicos: crista, colete de ganga com tachas (e a chefe **Víbora**) | Inimigos; nível 2 (becos de Londres à chuva) |
| `assets/images/paris.jpg` | **Clara**, heroína de ação: casaco de cabedal vermelho, rabo de cavalo | Jogável; nível 3 (Paris à noite) |
| `assets/images/lanchonete.jpg` | **Touro**, chefão motoqueiro: careca, barba, colete, tatuagens | Chefe final; nível 4 (lanchonete da Rota 66) |

As ilustrações em pixel art aparecem no ecrã de escolha do lutador e nas páginas de história. Dentro do jogo,
as personagens e cenários são desenhados por código com as mesmas cores (`fighter_painter.dart`, `background.dart`).
Para ter pixel art também durante o combate é preciso trocar esse desenho por spritesheets animadas (ver "Próximos passos").

## Controlos (ecrã tátil)
- Direcional: mover. SOCO: combo de 3 golpes (o 3.º derruba). SALTO + SOCO: pontapé no ar.
- ▼ + SOCO: rasteira. AGARRAR junto a um inimigo: SOCO = joelhada, AGARRAR outra vez = atirar.
- Armas (taco, faca) apanham-se passando por cima.

## Estrutura
- `lib/core/` configuração do jogo.
- `lib/game/punhos_game.dart` estado, câmara, ondas, níveis.
- `lib/game/components/` jogador, inimigos, armas, cenário, HUD, desenho das personagens.
- `lib/game/systems/` regras de combate.
- `lib/game/levels/` os 4 níveis e a história (dados, não lógica).
- `lib/game/audio/` ponto de ligação para os sons (ainda vazio).
- `lib/ui/` ecrãs em Flutter: escolha do lutador, história ilustrada, controlos, fim.
- `assets/images/` ilustrações (PNG) e respetivas fontes SVG.

## Próximos passos
1. Trocar o desenho vetorial (`fighter_painter.dart`) por spritesheets (SpriteAnimationComponent).
2. Sons e música com `flame_audio` em `audio_manager.dart`.
3. Mais inimigos, armas e níveis em `level_data.dart`.

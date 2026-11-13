# Punhos de Rua

Jogo de pancadaria 2D para Android, feito com Flutter + Flame. Personagens e história originais.

## Como correr
1. `flutter create punhos_de_rua --platforms=android`
2. Copiar para dentro dessa pasta: `lib/`, `assets/`, `pubspec.yaml`, `analysis_options.yaml` (substituir).
3. `flutter pub get` e `flutter run` (telemóvel ou emulador, em modo horizontal).

## Personagens e cenários
| Ilustração | Personagem | Onde aparece |
|---|---|---|
| `assets/images/nova_iorque.png` | **Jack**, lutador urbano dos EUA: loiro, casaco de cabedal, ganga | Jogável; nível 1 (entrada do metro de Nova Iorque) |
| `assets/images/londres.png` | **Punks** britânicos: crista, colete de ganga com tachas, calças escocesas (e a chefe **Víbora**) | Inimigos; nível 2 (ruas de Londres) |
| `assets/images/europa_noite.png` | **Rita**, heroína de ação: casaco bomber, rabo de cavalo | Jogável; nível 3 (cidade europeia à noite) |
| `assets/images/lanchonete.png` | **Touro**, chefão motoqueiro: careca, bandana, barba, tatuagens | Chefe final; nível 4 (lanchonete retro dos EUA) |

As ilustrações aparecem no ecrã de escolha do lutador e nas páginas de história. Dentro do jogo, as
personagens e cenários são desenhados por código com o mesmo visual (`fighter_painter.dart`, `background.dart`).

As fontes das ilustrações são SVG em `assets/images/src/`. Depois de editar um SVG, gerar os PNG com
`node tool/render_images.js` (precisa do pacote `playwright` com Chromium).

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

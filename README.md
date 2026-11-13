# Punhos de Rua

Jogo de pancadaria 2D para Android, feito com Flutter + Flame. Personagens e história originais.

## Como correr
1. `flutter create punhos_de_rua --platforms=android`
2. Copiar para dentro dessa pasta: `lib/`, `assets/`, `pubspec.yaml`, `analysis_options.yaml` (substituir).
3. `flutter pub get` e `flutter run` (telemóvel ou emulador, em modo horizontal).

## Personagens e cenários
| Ilustração | Personagem | Onde aparece |
|---|---|---|
| `assets/images/nova_iorque.jpg` | **Jack**, lutador urbano dos EUA: loiro, casaco de cabedal, ganga rasgada | Jogável; nível 1 (metro de Brooklyn). Também jogáveis: **Leo** (do diner) e **Spike** (o punk) |
| `assets/images/londres.jpg` | **Punks** britânicos: crista, colete de ganga com tachas (e a chefe **Víbora**) | Inimigos; nível 2 (becos de Londres à chuva) |
| `assets/images/paris.jpg` | **Clara**, heroína de ação: casaco de cabedal vermelho, rabo de cavalo | Jogável; nível 3 (Paris à noite) |
| `assets/images/lanchonete.jpg` | **Big Tyk**, chefão motoqueiro: careca, barba, colete, tatuagens | Chefe final; nível 4 (lanchonete da Rota 66) |

As ilustrações aparecem no ecrã de escolha do lutador (fundo: `titulo.jpg`, o grupo todo) e nas páginas de história.

### Sprites em combate
As folhas de sprites estão em `assets/images/sprites/` (um atlas PNG transparente por personagem) e as
posições de cada pose em `lib/game/components/sprite_data.dart`; `sprite_painter.dart` desenha-as.

| Atlas | Personagem | Usado por |
|---|---|---|
| `leo.png` | Leo | jogador |
| `clara.png` | Clara | jogador |
| `punk.png` | Spike (crista azul) | jogador |
| `punk_red.png`, `punk_green.png` | punk com crista vermelha / verde | punks inimigos / Víbora |
| `bigtyk.png` | Big Tyk | chefe final |

Poses: parado, andar (2–4 quadros), soco, pontapé, levar pancada, no chão. O Jack e os inimigos sem
folha de sprites (arruaceiro de boné e rufia da navalha) continuam com o desenho vetorial de `fighter_painter.dart`.

### Cenários em pixel art
Ponha uma imagem por nível em `assets/images/cenarios/` (`nova_iorque`, `londres`, `paris`, `lanchonete`, em PNG ou JPG)
e o jogo usa-a em vez do cenário desenhado por código. Os pés dos lutadores ficam entre 62% e 96% da altura da
imagem; o tamanho ideal é 4 a 5 vezes mais larga do que alta (ex.: 2400×480). Uma camada `<nome>_fundo` opcional
desliza mais devagar por trás. Detalhes em `assets/images/cenarios/LEIA-ME.txt`.

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
1. Imagens de cenário em pixel art para os 4 níveis (`assets/images/cenarios/`).
2. Folhas de sprites para o Jack e para os inimigos que ainda são vetoriais.
3. Sons e música com `flame_audio` em `audio_manager.dart`.
4. Experimentar num telemóvel Android.
5. Mais inimigos, armas e níveis em `level_data.dart`.

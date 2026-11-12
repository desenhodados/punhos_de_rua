/// Estado do direcional (preenchido pelos botões do ecrã).
class InputState {
  bool left = false;
  bool right = false;
  bool up = false;
  bool down = false;

  double get dx => (right ? 1.0 : 0.0) - (left ? 1.0 : 0.0);
  double get dy => (down ? 1.0 : 0.0) - (up ? 1.0 : 0.0);

  void clear() => left = right = up = down = false;
}

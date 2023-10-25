part of hexagons;

// Konstanty pro validaci rozsahu
const int _minValue = -2147483648 ~/ 2; // -2^31
const int _maxValue = 2147483647 ~/ 2; // 2^31 - 1

// Konstanta pro posunutí bitů
const int _shiftAmount = 32;

// Funkce pro vytvoření unikátního identifikátoru z dvou celých čísel
String _createId(Cube c) {
  if (c.q < _minValue || c.q > _maxValue || c.r < _minValue || c.r > _maxValue) {
    throw ArgumentError("Coordinates must be limited from $_minValue to $_maxValue.");
  }
  int combined = (_positive(c.q) << _shiftAmount) | (_positive(c.r) & 0xFFFFFFFF);
  return combined.toRadixString(32);
}

// Funkce pro získání původních dvou čísel z unikátního identifikátoru
Cube _createCube(String identifier) {
  int combined = int.parse(identifier, radix: 32);
  int q = _revert(combined >> _shiftAmount);
  int r = _revert(combined & 0xFFFFFFFF);
  return Cube(q, r, -q - r);
}

int _positive(int a) {
  if (a >= 0) return a * 2;
  return (a * -2) - 1;
}

int _revert(int pos) {
  if (pos % 2 == 0) return pos ~/ 2;
  return -((pos + 1) ~/ 2);
}

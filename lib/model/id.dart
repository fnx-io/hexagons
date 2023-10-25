part of hexagons;

const int _minValue = -2 ^ 29;
const int _maxValue = 2 ^ 29;
const int _shiftAmount = 32;

String _createId(Cube c) {
  if (c.q < _minValue || c.q > _maxValue || c.r < _minValue || c.r > _maxValue) {
    throw ArgumentError("Coordinates must be limited from $_minValue to $_maxValue.");
  }
  int combined = (_positive(c.q) << _shiftAmount) | (_positive(c.r) & 0xFFFFFFFF);
  return combined.toRadixString(32);
}

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

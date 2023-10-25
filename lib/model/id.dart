part of hexagons;

const int _minValue = -2 ^ 29;
const int _maxValue = 2 ^ 29;
const int _shiftAmount = 32;

// Funkce pro vytvoření unikátního identifikátoru z dvou celých čísel
String _createCubeId(Cube c) {
  String rStr = _positive(c.r).toRadixString(32);
  String qStr = _positive(c.q).toRadixString(32);

  // Získáme délku delšího řetězce a upravíme kratší řetězec tak, aby měl stejnou délku
  int maxLength = (rStr.length > qStr.length) ? rStr.length : qStr.length;
  rStr = rStr.padLeft(maxLength, '0');
  qStr = qStr.padLeft(maxLength, '0');
  return rStr + qStr;
}

// Funkce pro získání původních dvou čísel z unikátního identifikátoru
Cube _createCubeFromId(String identifier) {
  int halfLength = identifier.length ~/ 2;
  String rStr = identifier.substring(0, halfLength);
  String qStr = identifier.substring(halfLength);

  int r = _revert(int.parse(rStr, radix: 32));
  int q = _revert(int.parse(qStr, radix: 32));

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

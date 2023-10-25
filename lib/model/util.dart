part of hexagons;

const sqrt3 = 1.73205080757;

var _r = Random();

/// This global function allows you to enforce repeatable random results within this library. You should set this seed only once and before first the 'random' method call.
void setRandomSeed(int seed) {
  _r = Random(seed);
}

int cubeDistance(Cube a, Cube b) {
  if (a == b) return 0;
  return ((a.q - b.q).abs() + (a.r - b.r).abs() + (a.s - b.s).abs()) ~/ 2;
}

double _lerp(num a, num b, double t) {
  return a + (b - a) * t;
}

Cube cubeLerp(Cube a, Cube b, double t) {
  return Cube(_lerp(a.q, b.q, t).round(), _lerp(a.r, b.r, t).round(), _lerp(a.s, b.s, t).round());
}

List<Cube> cubeLinedraw(Cube a, Cube b) {
  var dist = cubeDistance(a, b);
  var results = <Cube>[];
  for (var i = 0; i <= dist; i++) {
    results.add(cubeLerp(a, b, 1.0 / dist * i));
  }
  return results;
}

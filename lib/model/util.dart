part of '../hex_toolkit.dart';

const _sqrt3 = 1.73205080757; // sqrt(3)
const _sqrt3_2 = 0.86602540378; // sqrt(3) / 2

double _lerp(num a, num b, double t) {
  return a + (b - a) * t;
}

/// Distance of two cubes in "steps".
int cubeDistance(Cube a, Cube b) {
  if (a == b) return 0;
  return ((a.q - b.q).abs() + (a.r - b.r).abs() + (a.s - b.s).abs()) >> 1; // ~/2
}

/// Linear interpolation between two cubes.
Cube cubeLerp(Cube a, Cube b, double t) {
  var q = _lerp(a.q, b.q, t).round();
  var r = _lerp(a.r, b.r, t).round();
  return Cube(q, r, -r - q);
}

/// Returns a list of cubes between two cubes.
List<Cube> cubeLinedraw(Cube a, Cube b) {
  var dist = cubeDistance(a, b);
  var results = <Cube>[];
  for (var i = 0; i <= dist; i++) {
    results.add(cubeLerp(a, b, 1.0 / dist * i));
  }
  return results;
}

/// Rounds a 'double' cube to the nearest 'int' cube.
Cube cubeRound(double q, double r, double s) {
  var rq = q.round();
  var rr = r.round();
  var rs = s.round();

  var qDiff = (rq - q).abs();
  var rDiff = (rr - r).abs();
  var sDiff = (rs - s).abs();

  if (qDiff > rDiff && qDiff > sDiff) {
    rq = -rr - rs;
  } else if (rDiff > sDiff) {
    rr = -rq - rs;
  } else {
    rs = -rq - rr;
  }
  return Cube(rq, rr, rs);
}

/// Returns moving window of segments of defined size. With path a,b,c,d,e and segmentSize 3, this method returns: [[a,b,c], [b,c,d], [c,d,e]]. If the segments size is
/// bigger then the path length, the method returns the whole path as a one segment.
Iterable<Iterable<T>> segmentsIterator<T>(List<T> path, int segmentSize) sync* {
  assert(segmentSize > 0);
  if (segmentSize > path.length) {
    yield path;
    return;
  }
  for (int i = 0; i < path.length - segmentSize + 1; i++) {
    yield path.sublist(i, i + segmentSize);
  }
}

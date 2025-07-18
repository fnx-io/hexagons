import 'package:hex_toolkit/hex_toolkit.dart';

void main() {
  var center = Hex.zero();
  var hexB = Hex(-5, -2, 7);

  print(center.neighbors());
  // Prints: [Hex(0, 1, -1), Hex(-1, 1, 0), Hex(-1, 0, 1), Hex(0, -1, 1), Hex(1, -1, 0), Hex(1, 0, -1)]

  print(center.distanceTo(hexB));
  // Prints: 7

  print(center.cheapestPathTo(hexB));
  // Prints: [Hex(0, 0, 0), Hex(-1, 0, 1), Hex(-2, 0, 2), Hex(-2, -1, 3), ...

  print(center.ring(3));
  // Prints: [Hex(3, -3, 0), Hex(3, -2, -1), Hex(3, -1, -2), Hex(3, 0, -3), ...

  var hex = Hex(3, 0, -3);

  print("Original hex: $hex");
  print("Rotate by 1 step (60 degrees): ${hex.rotateAround(center, 1)}");
  print("Rotate by 2 steps (120 degrees): ${hex.rotateAround(center, 2)}");
  // ...

  // interpolate example
  var start = Hex.zero();
  var end = Hex(6, 0, -6);

  print("\nInterpolate examples:");
  print("Start: $start");
  print("End: $end");
  print("Linear interpolation at t=0.5: ${start.interpolate(end, 0.5)}");
  print("EaseInQuad interpolation at t=0.5: ${start.interpolate(end, 0.5, Easing.easeInQuad)}");
  // ...

  // hexA.randomHexInArea(radius)
  // hexA.randomShape(50);
  // hexA.randomNeighbor();
  // hexA.randomNeighborWhere(filter);
}

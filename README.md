Utilities for working with hexagons on a hexagonal grid.
Based on magnificent https://www.redblobgames.com/grids/hexagons/ article.

Zero dependencies. Framework agnostic. Use with Flutter, on Web, CLI, or anywhere Dart runs.

Example:
```dart
import 'package:hex_toolkit/hex_toolkit.dart';

void main() {
  var hexA = Hex.zero();
  var hexB = Hex(-5, -2, 7);

  print(hexA.neighbors());
  // Prints: [Hex(0, 1, -1), Hex(-1, 1, 0), Hex(-1, 0, 1), Hex(0, -1, 1), Hex(1, -1, 0), Hex(1, 0, -1)]

  print(hexA.distanceTo(hexB));
  // Prints: 7

  print(hexA.pathTo(hexB));
  // Prints: [Hex(0, 0, 0), Hex(-1, 0, 1), Hex(-2, 0, 2), Hex(-2, -1, 3), ...

  print(hexA.ring(3));
  // Prints: [Hex(3, -3, 0), Hex(3, -2, -1), Hex(3, -1, -2), Hex(3, 0, -3), ...

  // hexA.randomHexInArea(radius)
  // hexA.randomShape(50);
  // hexA.randomNeighbor();
  // hexA.randomNeighborWhere(filter);
}
```
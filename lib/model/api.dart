part of hex_toolkit;

/// This function describes the cost of moving from one hex to another. Both hexes are adjacent.
/// The cost is a double value, where double.infinity means that the move is impossible (target hex is a wall).
/// The cost should always be > 0, but this is not enforced.
typedef MoveCost = double Function(Hex from, Hex to);

/// Filter function for cube coordinates. Returns true if the cube should be included in the result.
typedef CubeFilter = bool Function(Cube cube);

/// Filter function for hexes. Returns true if the hex should be included in the result.
typedef HexFilter = bool Function(Hex hex);

/// This class represents a point on a screen or canvas. Easily convert it to Flutter Offset (`Offset(pixel.x, pixel.y)`)
/// or whatever object your framework desires.
class PixelPoint {
  // Yes, that's X.
  final double x;

  // This is Y.
  final double y;
  PixelPoint(this.x, this.y);

  @override
  String toString() {
    return '[$x, $y]';
  }

  double distanceTo(PixelPoint p2) {
    return sqrt(pow(x - p2.x, 2) + pow(y - p2.y, 2));
  }

  PixelPoint centerWith(PixelPoint p2) {
    return PixelPoint((x + p2.x) / 2, (y + p2.y) / 2);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PixelPoint && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// This is a path from one hex to another. It contains the total cost of the path,
/// and the list of hexes that make up the path. See [Hex.cheapestPathTo] for more details.
class HexPath {
  final Hex from;
  final Hex to;
  final UnmodifiableListView<Hex> path;
  final double totalCost;
  HexPath(this.from, this.to, Iterable<Hex> path, this.totalCost) : this.path = UnmodifiableListView(path.toList());

  /// Returns moving window of segments of defined size. With path a,b,c,d,e and segmentSize 3, this method returns: [[a,b,c], [b,c,d], [c,d,e]]. If the segments size is
  /// bigger then the path length, the method returns the whole path as a one segment.
  Iterable<Iterable<Hex>> segments(int segmentSize) sync* {
    assert(segmentSize > 0);
    if (segmentSize > path.length) {
      yield path;
      return;
    }
    for (int i = 0; i < path.length - segmentSize + 1; i++) {
      yield path.sublist(i, i + segmentSize);
    }
  }
}

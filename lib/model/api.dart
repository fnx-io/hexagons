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
}

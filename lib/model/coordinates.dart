part of hex_toolkit;

/// Two possible layouts of a hexagonal grid, which are used to convert between cube and offset coordinates, or when actually drawing the grid.
/// In https://www.redblobgames.com/grids/hexagons/ these are called "odd-r" (pointy) and "odd-q" (flat).
enum GridLayout {
  POINTY_TOP,
  FLAT_TOP,
}

/// Rather impractical representation of a hexagon in a hexagonal grid, positioned by [q] (column) and [r] (row) coordinates.
/// "Zero" hexagon is in the top left corner. Odd rows (columns) are shifted to the right (down).
/// See https://www.redblobgames.com/grids/hexagons/#coordinates for more information.
class GridOffset {
  final int q;
  final int r;

  GridOffset(this.q, this.r);

  /// Converts this offset to a [Cube] coordinate, using the given [GridLayout].
  Cube toCube({GridLayout gridLayout = GridLayout.POINTY_TOP}) {
    if (gridLayout == GridLayout.POINTY_TOP) {
      var cq = q - (r - (r & 1)) ~/ 2;
      var cr = r;
      return Cube(cq, cr, -cq - cr);
      // } else if (gridLayout == GridLayout.evenR) {
      //   var cq = q - (r + (r & 1)) ~/ 2;
      //   var cr = r;
      //   return Cube(cq, cr, -cq - cr);
    } else if (gridLayout == GridLayout.FLAT_TOP) {
      var cq = q;
      var cr = r - (q - (q & 1)) ~/ 2;
      return Cube(cq, cr, -cq - cr);
      // } else if (gridLayout == GridLayout.evenQ) {
      //   var cq = q;
      //   var cr = r - (q + (q & 1)) ~/ 2;
      //   return Cube(cq, cr, -cq - cr);
    } else
      throw ArgumentError('Invalid grid class: $gridLayout');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GridOffset && runtimeType == other.runtimeType && q == other.q && r == other.r;

  @override
  int get hashCode => q.hashCode ^ r.hashCode;

  @override
  String toString() {
    return 'Offset{q: $q, r: $r}';
  }
}

Cube roundCube(double q, double r, double s) {
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

/// Smart representation of a hexagon in a hexagonal grid, positioned on three axis. Very practical for a lots of algorithms. Sum of these coordinates is always 0, so technically only [q] and [r] are actually necessary (these are called axial coordinates, see [Cube.fromAxial])).
/// See https://www.redblobgames.com/grids/hexagons/#coordinates for more information.
class Cube {
  final int q;
  final int r;
  final int s;

  Cube(this.q, this.r, this.s) {
    assert(q + r + s == 0);
  }

  Cube.fromAxial(int q, int r) : this(q, r, -q - r);

  factory Cube.fromGridOffset(GridOffset o, [GridLayout gridLayout = GridLayout.POINTY_TOP]) => o.toCube(gridLayout: gridLayout);

  /// Converts this cube to an [GridOffset] coordinate, using the given [GridLayout].
  GridOffset toGridOffset([GridLayout gridLayout = GridLayout.POINTY_TOP]) {
    if (gridLayout == GridLayout.POINTY_TOP) {
      var col = q + (r - (r & 1)) ~/ 2;
      var row = r;
      return GridOffset(col, row);
      // } else if (gridLayout == GridLayout.evenR) {
      //   var col = q + (r + (r & 1)) ~/ 2;
      //   var row = r;
      //   return Offset(col, row);
    } else if (gridLayout == GridLayout.FLAT_TOP) {
      var col = q;
      var row = r + (q - (q & 1)) ~/ 2;
      return GridOffset(col, row);
      // } else if (gridLayout == GridLayout.evenQ) {
      //   var col = q;
      //   var row = r + (q + (q & 1)) ~/ 2;
      //   return Offset(col, row);
    } else
      throw ArgumentError('Invalid grid layout: $gridLayout');
  }

  PixelPoint centerPoint(double size, [GridLayout gridLayout = GridLayout.POINTY_TOP]) {
    if (gridLayout == GridLayout.POINTY_TOP) {
      var x = size * (_sqrt3 * q + _sqrt3_2 * r);
      var y = size * (3 / 2 * r);
      return PixelPoint(x, y);
    } else if (gridLayout == GridLayout.FLAT_TOP) {
      var x = size * (3 / 2 * q);
      var y = size * (_sqrt3_2 * q + _sqrt3 * r);
      return PixelPoint(x, y);
    } else
      throw ArgumentError('Invalid grid layout: $gridLayout');
  }

  Cube operator +(Cube delta) {
    return Cube(q + delta.q, r + delta.r, s + delta.s);
  }

  Cube operator -(Cube delta) {
    return Cube(q - delta.q, r - delta.r, s - delta.s);
  }

  Cube operator *(int scalar) {
    return Cube(q * scalar, r * scalar, s * scalar);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cube && runtimeType == other.runtimeType && q == other.q && r == other.r && s == other.s;

  @override
  int get hashCode => q.hashCode ^ r.hashCode ^ s.hashCode;

  String toString() => 'Cube($q, $r, $s)';
}

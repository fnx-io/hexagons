part of '../hex_toolkit.dart';

// All my neighbors
var _directions = [
  Cube(1, 0, -1),
  Cube(1, -1, 0),
  Cube(0, -1, 1),
  Cube(-1, 0, 1),
  Cube(-1, 1, 0),
  Cube(0, 1, -1),
];

Hex _toHex(Cube cube) => Hex.fromCube(cube);

/// An unmodifiable abstraction of a hexagon in a hexagonal grid.
///
/// Offers several useful methods to measure distance, find path etc. Position of the hexagon is defined by a [Cube] coordinates.
class Hex {
  /// Coordinate of the hexagon in a hexagonal grid.
  final Cube cube;

  /// Creates a new hexagon with the given [Cube] coordinates.
  Hex(int q, int r, int s) : cube = Cube(q, r, s);

  /// Creates hexagon from a given [Cube].
  Hex.fromCube(this.cube);

  /// Creates hexagon from a given axial coordinates, see [Cube.fromAxial].
  Hex.fromAxial(int q, int r) : cube = Cube.fromAxial(q, r);

  /// Creates hexagon in 0,0,0
  Hex.zero() : cube = Cube(0, 0, 0);

  /// Creates hexagon from a given [GridOffset] coordinates, using the given [GridLayout].
  Hex.fromOffset(GridOffset offset, {GridLayout gridLayout = GridLayout.POINTY_TOP}) : cube = offset.toCube(gridLayout: gridLayout);

  /// Creates hexagon from a given [id].
  Hex.fromId(String id) : cube = _createCubeFromId(id);

  /// Creates hexagon from a given [PixelPoint] coordinates, using the given [GridLayout] and size of one hex in grid.
  factory Hex.fromPixelPoint(PixelPoint point, double hexSize, {GridLayout gridLayout = GridLayout.POINTY_TOP}) {
    if (gridLayout == GridLayout.POINTY_TOP) {
      var q = (_sqrt3 / 3 * point.x - 1 / 3 * point.y) / hexSize;
      var r = (2 / 3 * point.y) / hexSize;
      return Hex.fromCube(cubeRound(q, r, -q - r));
    } else if (gridLayout == GridLayout.FLAT_TOP) {
      var q = (2 / 3 * point.x) / hexSize;
      var r = (-1 / 3 * point.x + _sqrt3 / 3 * point.y) / hexSize;
      return Hex.fromCube(cubeRound(q, r, -q - r));
    } else {
      throw ArgumentError('Unknown grid layout: $gridLayout');
    }
  }

  String? _id;

  /// Returns a unique id of the hexagon. Id is a string representation of the underlaying [Cube]
  /// coordinates of this hexagon. It can be used to restore the [Hex] using [Hex.fromId] constructor.
  String get id => (_id ??= _createCubeId(cube));

  /// Creates [GridOffset] coordinates from this hexagon, using the given [GridLayout].
  GridOffset toOffset({GridLayout gridLayout = GridLayout.POINTY_TOP}) {
    return cube.toGridOffset(gridLayout);
  }

  Cube _cubeAtDirection(int direction) {
    return _directions[direction];
  }

  Cube _cubeNeighbor(Cube hex, int direction) {
    return hex + _cubeAtDirection(direction);
  }

  /// All my six neighboring hexagons.
  List<Hex> neighbors() {
    return _directions.map((Cube direction) => cube + direction).map(_toHex).toList();
  }

  /// Distance to the given hexagon - the number of steps needed to get to the given hexagon.
  int distanceTo(Hex other) {
    return cubeDistance(cube, other.cube);
  }

  bool isNeighborOf(Hex other) {
    return distanceTo(other) == 1;
  }

  /// Chooses random neighbor.
  Hex randomNeighbor() {
    return _toHex(_cubeNeighbor(cube, _r.nextInt(6)));
  }

  /// Chooses random neighbor that matches the given filter.
  Hex? randomNeighborWhere(HexFilter filter) {
    var ns = neighbors().where(filter);
    if (ns.isEmpty) return null;
    if (ns.length == 1) return ns.first;
    return ns.elementAt(_r.nextInt(ns.length));
  }

  /// Creates a list of all hexes with the given radius=distance (a 'ring' with 'this' in the center).
  Iterable<Hex> ring(int radius) sync* {
    if (radius == 0) {
      yield this;
      return;
    }
    var hex = cube + _cubeAtDirection(4) * radius;
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < radius; j++) {
        yield _toHex(hex);
        hex = _cubeNeighbor(hex, i);
      }
    }
  }

  /// Creates a list of all hexes with the distance <= radius (a 'spiral' with 'this' in the center).
  Iterable<Hex> spiral(int radius) sync* {
    for (var i = 0; i <= radius; i++) {
      yield* ring(i);
    }
  }

  Iterable<Hex> line(Hex to) sync* {
    var n = distanceTo(to);
    var step = 1.0 / max(n, 1);
    for (var i = 0; i <= n; i++) {
      yield Hex.fromCube(cubeLerp(cube, to.cube, step * i));
    }
  }

  /// Random hex with distance to 'this' <= radius.
  /// Probability is the same for all hexes within the area (as opposed to higher probability near the center).
  Hex randomHexInArea(int radius) {
    var all = spiral(radius).toList();
    return all[_r.nextInt(all.length)];
  }

  /// Generates random shape. The shape is a list of randomly chosen (but connected) hexes, with [hexCount] members,
  /// one of these hexes is 'this'. There is no guarantee of position of 'this' within the shape.
  Iterable<Hex> randomShape(int hexCount, {num spread = 0.3}) {
    assert(hexCount > 0);
    assert(spread >= 0 && spread <= 1);
    List<Hex> sources = [this];
    Set<Hex> result = {};
    result.add(this);
    while (result.length < hexCount) {
      var source = sources.removeAt(0);
      var nbs = source.neighbors().toList()..shuffle();
      double trashold = 1;
      while (spread <= trashold && nbs.isNotEmpty && result.length < hexCount) {
        //print("Testing ${nbs.last} for $source");
        var nb = nbs.removeLast();
        if (!result.contains(nb)) {
          result.add(nb);
          sources.add(nb);
          trashold = _r.nextDouble();
        }
      }
      if (sources.isEmpty) {
        sources.addAll(result);
      }
    }
    return result;
  }

  /// Computes the shortest path to other hex. The path is a list of connected hexes, including 'this' and [to]. If there is no path,
  /// method returns null. The path is computed using the given [costFunction], which is a function that returns the cost of
  /// transition from one hex to another. See [MoveCost]. Default [costFunction] assigns value 1 to any transition.
  /// The searched area is limited by a circle with radius [maximumDistanceFromTo] and
  /// center in [to]. Default value of [maximumDistanceFromTo] is arbitrary value of `max(distanceTo(to) * 2, 10)`.
  ///
  HexPath? cheapestPathTo(Hex to, {MoveCost? costFunction, int? maximumDistanceFromTo}) {
    maximumDistanceFromTo ??= max(distanceTo(to) * 2, 10);
    costFunction ??= (from, to) => 1;
    return findCheapestPath(this, to, costFunction, maximumDistanceFromTo);
  }

  /// Center of this hex in a pixel grid.
  PixelPoint centerPoint(double size, {GridLayout gridLayout = GridLayout.POINTY_TOP}) {
    return cube.centerPoint(size, gridLayout);
  }

  /// Top left corner of this hex in a pixel grid (use it to draw the hex using a raster graphics).
  PixelPoint topLeftPoint(double size, {GridLayout gridLayout = GridLayout.POINTY_TOP}) {
    var center = cube.centerPoint(size, gridLayout);
    if (gridLayout == GridLayout.POINTY_TOP) {
      double w = _sqrt3_2 * size;
      return PixelPoint(center.x - w, center.y - size);
    } else if (gridLayout == GridLayout.FLAT_TOP) {
      double h = _sqrt3_2 * size;
      return PixelPoint(center.x - size, center.y - h);
    } else {
      throw ArgumentError('Unknown grid layout: $gridLayout');
    }
  }

  /// Returns a list of vertices of this hex in a pixel grid (use it to draw the hex using a vector graphics).
  /// See: https://www.redblobgames.com/grids/hexagons/#basics
  List<PixelPoint> vertices(double size, {GridLayout gridLayout = GridLayout.POINTY_TOP, double padding = 0}) {
    var center = cube.centerPoint(size, gridLayout);
    double paddedSize = size - padding;
    double paddedSize_2 = paddedSize / 2;
    if (gridLayout == GridLayout.POINTY_TOP) {
      double w = _sqrt3_2 * paddedSize;
      return [
        PixelPoint(center.x, center.y - paddedSize),
        PixelPoint(center.x + w, center.y - paddedSize_2),
        PixelPoint(center.x + w, center.y + paddedSize_2),
        PixelPoint(center.x, center.y + paddedSize),
        PixelPoint(center.x - w, center.y + paddedSize_2),
        PixelPoint(center.x - w, center.y - paddedSize_2),
      ];
    } else if (gridLayout == GridLayout.FLAT_TOP) {
      double h = _sqrt3_2 * paddedSize;
      return [
        PixelPoint(center.x - paddedSize, center.y),
        PixelPoint(center.x - paddedSize_2, center.y + h),
        PixelPoint(center.x + paddedSize_2, center.y + h),
        PixelPoint(center.x + paddedSize, center.y),
        PixelPoint(center.x + paddedSize_2, center.y - h),
        PixelPoint(center.x - paddedSize_2, center.y - h),
      ];
    } else {
      throw ArgumentError('Unknown grid layout: $gridLayout');
    }
  }

  /// Rotates this hex around the given center hex by the specified number of steps.
  /// Each step is a 60-degree rotation clockwise.
  /// Returns a new Hex instance.
  Hex rotateAround(Hex center, int steps) {
    // Normalize steps to 0-5 range
    steps = steps % 6;
    if (steps == 0) return this;

    // Convert to relative coordinates
    var rel = cube - center.cube;

    // Apply rotation
    Cube rotated;
    switch (steps) {
      case 1:
        rotated = Cube(-rel.r, -rel.s, -rel.q);
        break;
      case 2:
        rotated = Cube(rel.s, rel.q, rel.r);
        break;
      case 3:
        rotated = Cube(-rel.q, -rel.r, -rel.s);
        break;
      case 4:
        rotated = Cube(rel.r, rel.s, rel.q);
        break;
      case 5:
        rotated = Cube(-rel.s, -rel.q, -rel.r);
        break;
      default:
        rotated = rel;
    }

    // Convert back to absolute coordinates
    return Hex.fromCube(center.cube + rotated);
  }

  /// Interpolates between this hex and the target hex using the specified easing function.
  /// The parameter t should be between 0 and 1, where 0 returns this hex and 1 returns the target hex.
  /// Returns a new Hex instance.
  Hex interpolate(Hex target, double t, [EasingFunction easing = Easing.linear]) {
    assert(t >= 0 && t <= 1);
    double easedT = easing(t);
    return Hex.fromCube(cubeLerp(cube, target.cube, easedT));
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hex && runtimeType == other.runtimeType && cube == other.cube;

  @override
  int get hashCode => cube.hashCode;

  @override
  String toString() => 'Hex(${cube.q}, ${cube.r}, ${cube.s})';

  /// Convenient method to serialize hex to string (uses [id])
  String serialize() => id;

  /// Convenient method to deserialize hex from string (uses [Hex.fromId])
  static Hex deserialize(String id) => Hex.fromId(id);
}

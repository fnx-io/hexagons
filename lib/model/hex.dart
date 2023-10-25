part of hex_toolkit;

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

  /// Creates hexagon from a given [Offset] coordinates, using the given [GridLayout].
  Hex.fromOffset(Offset offset, [GridLayout gridLayout = GridLayout.POINTY_TOP]) : cube = offset.toCube(gridLayout);

  /// Creates hexagon from a given [id].
  Hex.fromId(String id) : cube = _createCubeFromId(id);

  String? _id;

  /// Returns a unique id of the hexagon. Id is a string representation of the underlaying [Cube]
  /// coordinates of this hexagon. It can be used to restore the [Hex] using [Hex.fromId] constructor.
  String get id => (_id ??= _createCubeId(cube));

  /// Creates [Offset] coordinates from this hexagon, using the given [GridLayout].
  Offset toOffset([GridLayout gridLayout = GridLayout.POINTY_TOP]) {
    return cube.toOffset(gridLayout);
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
  List<Hex> ring(int radius) {
    if (radius == 0) return [this];
    var results = <Hex>[];
    var hex = cube + _cubeAtDirection(4) * radius;
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < radius; j++) {
        results.add(_toHex(hex));
        hex = _cubeNeighbor(hex, i);
      }
    }
    return results;
  }

  /// Creates a list of all hexes with the distance <= radius (a 'spiral' with 'this' in the center).
  List<Hex> spiral(int radius) {
    var results = <Hex>[];
    for (var i = 0; i <= radius; i++) {
      results.addAll(ring(i));
    }
    return results;
  }

  /// Random hex with distance to 'this' <= radius.
  /// Probability is the same for all hexes within the area (as opposed to higher probability near the center).
  Hex randomHexInArea(int radius) {
    var all = spiral(radius);
    return all[_r.nextInt(all.length)];
  }

  /// Generates random shape. The shape is a list of randomly chosen (but connected) hexes, with [hexCount] members,
  /// one of these hexes is 'this'. There is no guarantee of position of 'this' within the shape.
  List<Hex> randomShape(int hexCount) {
    assert(hexCount > 0);
    List<Hex> result = [];
    result.add(this);
    while (result.length < hexCount) {
      var hex = result[_r.nextInt(result.length)];
      var neighbor = hex.randomNeighbor();
      if (!result.contains(neighbor)) {
        result.add(neighbor);
      }
    }
    return result;
  }

  /// Computes the shortest path to other hex. The path is a list of connected hexes, including 'this' and [to]. If there is no path,
  /// method returns null. The path is computed using the given [costFunction], which is a function that returns the cost of
  /// transition from one hex to another. See [MoveCost]. Default [costFunction] assigns value 1 to any transition.
  /// The grid searched is limited by a circle with radius [maximumDistanceFromTo] and
  /// center in [to]. Default value of [maximumDistanceFromTo] is arbitrary value of `2 * this.distanceTo(to) + 10`.
  ///
  List<Hex>? pathTo(Hex to, {MoveCost? costFunction, int? maximumDistanceFromTo}) {
    maximumDistanceFromTo ??= distanceTo(to) * 2 + 10;
    costFunction ??= (from, to) => 1;
    return findShortestPath(this, to, costFunction, maximumDistanceFromTo);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hex && runtimeType == other.runtimeType && cube == other.cube;

  @override
  int get hashCode => cube.hashCode;

  String toString() => 'Hex(${cube.r}, ${cube.q}, ${cube.s})';

  /// Convenient method to serialize hex to string (uses [id])
  String serialize() => id;

  /// Convenient method to deserialize hex from string (uses [Hex.fromId])
  static Hex deserialize(String id) => Hex.fromId(id);
}

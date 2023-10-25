part of hexagons;

var _directions = [
  Cube(1, 0, -1),
  Cube(1, -1, 0),
  Cube(0, -1, 1),
  Cube(-1, 0, 1),
  Cube(-1, 1, 0),
  Cube(0, 1, -1),
];

Hex _toHex(Cube cube) => Hex.fromCube(cube);

class Hex {
  final Cube cube;

  Hex(int r, int q, int s) : cube = Cube(r, q, s);

  Hex.fromCube(this.cube);

  Hex.zero() : cube = Cube(0, 0, 0);

  Hex.fromOffset(Offset offset, [GridLayout gridClass = GridLayout.oddR]) : cube = offset.toCube(gridClass);

  Hex.fromId(String id) : cube = _createCubeFromId(id);

  String? _id;

  String get id => (_id ??= _createCubeId(cube));

  Offset toOffset([GridLayout gridClass = GridLayout.oddR]) {
    return cube.toOffset(gridClass);
  }

  Cube _cubeDirection(int direction) {
    return _directions[direction];
  }

  Cube _neighbor(Cube hex, int direction) {
    return hex + _cubeDirection(direction);
  }

  List<Hex> neighbors() {
    return _directions.map((Cube direction) => cube + direction).map(_toHex).toList();
  }

  int distanceTo(Hex other) {
    return cubeDistance(cube, other.cube);
  }

  Hex randomNeighbor() {
    return _toHex(_neighbor(cube, _r.nextInt(6)));
  }

  Hex? randomNeighborWhere(HexFilter filter) {
    var ns = neighbors().where(filter);
    if (ns.isEmpty) return null;
    if (ns.length == 1) return ns.first;
    return ns.elementAt(_r.nextInt(ns.length));
  }

// https://www.redblobgames.com/grids/hexagons/#rings
  List<Hex> ring(int radius) {
    if (radius == 0) return [this];
    if (radius == 1) return neighbors();
    var results = <Hex>[];
    var hex = cube + _cubeDirection(4) * radius;
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < radius; j++) {
        results.add(_toHex(hex));
        hex = _neighbor(hex, i);
      }
    }
    return results;
  }

  List<Hex> spiral(int radius) {
    var results = <Hex>[];
    for (var i = 0; i <= radius; i++) {
      results.addAll(ring(i));
    }
    return results;
  }

  Hex randomHexInArea(int radius) {
    var all = spiral(radius);
    return all[_r.nextInt(all.length)];
  }

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

  List<Hex>? pathTo(Hex to, MoveCost costFunction, {int? maximumDistanceFromTo}) {
    maximumDistanceFromTo ??= distanceTo(to) * 2;
    return findShortestPath(this, to, costFunction, maximumDistanceFromTo);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hex && runtimeType == other.runtimeType && cube == other.cube;

  @override
  int get hashCode => cube.hashCode;

  String toString() => 'Hex(${cube.r}, ${cube.q}, ${cube.s})';
}

class _PathTodo implements Comparable<_PathTodo> {
  double priority;
  Hex hex;
  _PathTodo(this.priority, this.hex);

  @override
  int compareTo(_PathTodo other) {
    return priority.compareTo(other.priority);
  }
}

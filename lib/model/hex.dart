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

  Hex.fromOffset(Offset offset, [GridClass gridClass = GridClass.oddR]) : cube = offset.toCube(gridClass);

  Offset toOffset([GridClass gridClass = GridClass.oddR]) {
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

  List<Hex>? pathTo(Hex to, MoveCost costFunction) {
    if (to == this) return [this];
    if (cubeDistance(cube, to.cube) == 1) {
      if (costFunction(this, to) == double.infinity) return null;
      return [this, to];
    }

    var frontier = <_PathTodo>[];
    frontier.insert(0, _PathTodo(0, cube));
    var cameFrom = <Cube, Cube?>{};
    var costSoFar = <Cube, double>{};
    cameFrom[cube] = null;
    costSoFar[cube] = 0;

    while (frontier.isNotEmpty) {
      frontier.sort();
      var current = _toHex(frontier.removeAt(0).cube);
      if (current == to) break;

      for (var next in current.neighbors()) {
        var newCost = costSoFar[current.cube]! + costFunction(current, next);
        if (!costSoFar.containsKey(next) || newCost < (costSoFar[next] ?? double.infinity)) {
          costSoFar[next.cube] = newCost;
          var priority = cubeDistance(to.cube, next.cube).toDouble();
          frontier.add(_PathTodo(priority, next.cube));
          cameFrom[next.cube] = current.cube;
        }
      }
    }

    var path = <Hex>[];
    var current = to;
    while (current != this) {
      path.add(current);
      current = _toHex(cameFrom[current.cube]!);
    }
    path.add(this);
    path = path.reversed.toList();
    return path;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Hex && runtimeType == other.runtimeType && cube == other.cube;

  @override
  int get hashCode => cube.hashCode;

  String toString() => 'Hex(${cube.r}, ${cube.q}, ${cube.s})';
}

class _PathTodo implements Comparable<_PathTodo> {
  double priority;
  Cube cube;
  _PathTodo(this.priority, this.cube);

  @override
  int compareTo(_PathTodo other) {
    return priority.compareTo(other.priority);
  }
}

part of hexagons;

/// Djikstra's algorithm for finding shortest path between two hexes.
List<Hex>? findShortestPath(Hex from, Hex to, MoveCost costFunction, int maximumDistanceTo) {
  Map<Hex, double> dist = {};
  Map<Hex, int> distanceTo = {};
  Map<Hex, Hex?> prev = {};
  Set<Hex> unvisited = {from};
  Set<Hex> visited = {};

  dist[from] = 0;
  distanceTo[from] = from.distanceTo(to);

  int count = 0;

  while (unvisited.isNotEmpty) {
    count++;
    int closestToTarget = unvisited.map((hex) => distanceTo[hex]!).reduce((a, b) => a < b ? a : b);
    Hex current = unvisited.firstWhere((hex) => distanceTo[hex]! == closestToTarget);

    unvisited.remove(current);
    visited.add(current);

    if (current == to) {
      break;
    }
    for (Hex neighbor in current.neighbors()) {
      // unvisited neighbor
      if (!visited.contains(neighbor)) {
        if (costFunction(current, neighbor) == double.infinity) {
          // but it can't be reached from current
          continue;
        }
        int distanceToNeighbor = neighbor.distanceTo(to);
        if (distanceToNeighbor > maximumDistanceTo) {
          // it's too far
          continue;
        }
        if (!dist.containsKey(neighbor) || dist[neighbor] == double.infinity) {
          // new node worth exploring
          unvisited.add(neighbor);
          dist[neighbor] = double.infinity;
          prev[neighbor] = null;
          distanceTo[neighbor] = distanceToNeighbor;
        }
        double tentativeDist = dist[current]! + costFunction(current, neighbor);

        if (tentativeDist < dist[neighbor]!) {
          dist[neighbor] = tentativeDist;
          prev[neighbor] = current;
        }
      }
    }
    if (unvisited.isEmpty) {
      //print("Stuck at $current");
      // print("Stuck $count");
      return null;
    }
  }
  //print(count);
  List<Hex> path = [];
  Hex? current = to;
  while (current != null) {
    path.add(current);
    current = prev[current];
  }
  return path.reversed.toList();
}

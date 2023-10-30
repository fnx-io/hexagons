part of hex_toolkit;

/// Find the cheapest path from [from] to [to] using [costFunction]. Djikstra's algorithm.
HexPath? findCheapestPath(Hex from, Hex to, MoveCost costFunction, int maximumDistanceTo) {
  Map<Hex, double> dist = {};
  Map<Hex, Hex> prev = {};
  Set<Hex> unvisited = {};
  dist[from] = 0.0;
  unvisited.add(from);

  while (unvisited.isNotEmpty) {
    Hex? current = unvisited.reduce((hexA, hexB) => dist[hexA]! < dist[hexB]! ? hexA : hexB);
    unvisited.remove(current);

    if (current == to) {
      List<Hex> path = [];
      double totalCost = dist[current]!;
      while (current != null) {
        path.insert(0, current);
        current = prev[current];
      }
      return HexPath(from, to, path, totalCost);
    }

    for (Hex neighbor in current.neighbors()) {
      if (neighbor.distanceTo(to) > maximumDistanceTo) {
        // this is too far, don't even consider it
        continue;
      }
      double tentativeDist = dist[current]! + costFunction(current, neighbor);
      if (tentativeDist < (dist[neighbor] ?? double.infinity)) {
        dist[neighbor] = tentativeDist;
        prev[neighbor] = current;
        unvisited.add(neighbor);
      }
    }
  }
  return null;
}

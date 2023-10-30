part of hex_toolkit;

List<List<T>> _connectedClustersOfNodes<T>(Iterable<T> candidates, bool Function(T, T) areConnected) {
  List<List<T>> clusters = [];
  Set<T> visited = Set();

  void dfs(T current, List<T> cluster) {
    visited.add(current);
    cluster.add(current);

    for (T neighbor in candidates) {
      if (!visited.contains(neighbor) && areConnected(current, neighbor)) {
        dfs(neighbor, cluster);
      }
    }
  }

  for (T candidate in candidates) {
    if (!visited.contains(candidate)) {
      List<T> cluster = [];
      dfs(candidate, cluster);
      if (cluster.isNotEmpty) {
        clusters.add(cluster);
      }
    }
  }

  return clusters;
}

List<List<Hex>> connectedClusters(Iterable<Hex> candidates) {
  return _connectedClustersOfNodes(candidates, (Hex a, Hex b) => a.distanceTo(b) <= 1);
}

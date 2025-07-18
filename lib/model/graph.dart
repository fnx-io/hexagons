part of '../hex_toolkit.dart';

List<List<T>> _connectedClustersOfNodes<T>(
    Iterable<T> candidates, bool Function(T, T) areConnected) {
  List<List<T>> clusters = [];
  Set<T> visited = {};

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
  return _connectedClustersOfNodes(
      candidates, (Hex a, Hex b) => a.distanceTo(b) <= 1);
}

int areaHeight(Iterable<Hex> area) {
  if (area.isEmpty) {
    return 0;
  }
  int min = area.first.cube.r;
  int max = area.first.cube.r;
  for (Hex hex in area) {
    if (hex.cube.r < min) {
      min = hex.cube.r;
    }
    if (hex.cube.r > max) {
      max = hex.cube.r;
    }
  }
  return max - min + 1;
}

int areaWidth(Iterable<Hex> area) {
  if (area.isEmpty) {
    return 0;
  }
  int min = area.first.cube.q;
  int max = area.first.cube.q;
  for (Hex hex in area) {
    if (hex.cube.q < min) {
      min = hex.cube.q;
    }
    if (hex.cube.q > max) {
      max = hex.cube.q;
    }
  }
  return max - min + 1;
}

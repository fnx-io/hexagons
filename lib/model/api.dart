part of hex_toolkit;

/// This function describes the cost of moving from one hex to another. Both hexes are adjacent.
/// The cost is a double value, where double.infinity means that the move is impossible (target hex is a wall).
/// The cost should always be > 0, but this is not enforced.
typedef MoveCost = double Function(Hex from, Hex to);

/// Filter function for cube coordinates. Returns true if the cube should be included in the result.
typedef CubeFilter = bool Function(Cube cube);

/// Filter function for hexes. Returns true if the hex should be included in the result.
typedef HexFilter = bool Function(Hex hex);

part of hexagons;

enum GridLayout {
  oddR,
  evenR,
  oddQ,
  evenQ,
}

class Offset {
  final int q;
  final int r;

  Offset(this.q, this.r);

  Cube toCube([GridLayout gridLayout = GridLayout.oddR]) {
    if (gridLayout == GridLayout.oddR) {
      var cq = q - (r - (r & 1)) ~/ 2;
      var cr = r;
      return Cube(cq, cr, -cq - cr);
    } else if (gridLayout == GridLayout.evenR) {
      var cq = q - (r + (r & 1)) ~/ 2;
      var cr = r;
      return Cube(cq, cr, -cq - cr);
    } else if (gridLayout == GridLayout.oddQ) {
      var cq = q;
      var cr = r - (q - (q & 1)) ~/ 2;
      return Cube(cq, cr, -cq - cr);
    } else if (gridLayout == GridLayout.evenQ) {
      var cq = q;
      var cr = r - (q + (q & 1)) ~/ 2;
      return Cube(cq, cr, -cq - cr);
    } else
      throw ArgumentError('Invalid grid class: $gridLayout');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Offset && runtimeType == other.runtimeType && q == other.q && r == other.r;

  @override
  int get hashCode => q.hashCode ^ r.hashCode;

  @override
  String toString() {
    return 'Offset{q: $q, r: $r}';
  }
}

class Cube {
  final int q;
  final int r;
  final int s;

  Cube(this.q, this.r, this.s) {
    assert(q + r + s == 0);
  }

  Cube.fromAxial(int q, int r) : this(q, r, -q - r);

  Offset toOffset([GridLayout gridLayout = GridLayout.oddR]) {
    if (gridLayout == GridLayout.oddR) {
      var col = q + (r - (r & 1)) ~/ 2;
      var row = r;
      return Offset(col, row);
    } else if (gridLayout == GridLayout.evenR) {
      var col = q + (r + (r & 1)) ~/ 2;
      var row = r;
      return Offset(col, row);
    } else if (gridLayout == GridLayout.oddQ) {
      var col = q;
      var row = r + (q - (q & 1)) ~/ 2;
      return Offset(col, row);
    } else if (gridLayout == GridLayout.evenQ) {
      var col = q;
      var row = r + (q + (q & 1)) ~/ 2;
      return Offset(col, row);
    } else
      throw ArgumentError('Invalid grid class: $gridLayout');
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

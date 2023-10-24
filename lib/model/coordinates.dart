part of hexagons;

enum GridClass {
  oddR,
  evenR,
  oddQ,
  evenQ,
}

class Offset {
  final int q;
  final int r;

  Offset(this.q, this.r);

  Cube toCube([GridClass gridClass = GridClass.oddR]) {
    if (gridClass == GridClass.oddR) {
      var cq = q - (r - (r & 1)) ~/ 2;
      var cr = r;
      return Cube(cq, cr, -cq - cr);
    } else if (gridClass == GridClass.evenR) {
      var cq = q - (r + (r & 1)) ~/ 2;
      var cr = r;
      return Cube(cq, cr, -cq - cr);
    } else if (gridClass == GridClass.oddQ) {
      var cq = q;
      var cr = r - (q - (q & 1)) ~/ 2;
      return Cube(cq, cr, -cq - cr);
    } else if (gridClass == GridClass.evenQ) {
      var cq = q;
      var cr = r - (q + (q & 1)) ~/ 2;
      return Cube(cq, cr, -cq - cr);
    } else
      throw ArgumentError('Invalid grid class: $gridClass');
  }
}

class Cube {
  final int q;
  final int r;
  final int s;

  Cube(this.q, this.r, this.s) {
    assert(q + r + s == 0);
  }

  Cube.axial(int q, int r) : this(q, r, -q - r);

  Offset toOffset([GridClass gridClass = GridClass.oddR]) {
    if (gridClass == GridClass.oddR) {
      var col = q + (r - (r & 1)) ~/ 2;
      var row = r;
      return Offset(col, row);
    } else if (gridClass == GridClass.evenR) {
      var col = q + (r + (r & 1)) ~/ 2;
      var row = r;
      return Offset(col, row);
    } else if (gridClass == GridClass.oddQ) {
      var col = q;
      var row = r + (q - (q & 1)) ~/ 2;
      return Offset(col, row);
    } else if (gridClass == GridClass.evenQ) {
      var col = q;
      var row = r + (q + (q & 1)) ~/ 2;
      return Offset(col, row);
    } else
      throw ArgumentError('Invalid grid class: $gridClass');
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

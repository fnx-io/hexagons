import 'package:hexagons/hexagons.dart';
import 'package:test/test.dart';

void main() {
  group("coordinates", () {
    test('cube_equals', () {
      var a = Cube(0, 0, 0);
      var b = Cube(0, 0, 0);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      b = Cube(1, -1, 0);
      expect(a, isNot(equals(b)));
    });
  });
  group("hex", () {
    test('distance', () {
      var testSets = [
        _Set(Hex(0, 0, 0), Hex(0, 0, 0), 0),
        _Set(Hex(0, 0, 0), Hex(0, 0, 0).randomNeighbor(), 1),
        _Set(Hex(2, -2, -0), Hex(2, -2, -0).randomNeighbor(), 1),
        _Set(Hex(2, -2, -0), Hex(2, -2, -0).neighbors().first.neighbors().first, 2), // sousede zacinaji vzdy stejnym smerem
        _Set(Hex(-1, -3, 4), Hex(-3, 4, -1), 7),
      ];
      var d = Cube(12, -7, -5);
      for (var i in testSets) {
        // print("Testing $i");
        expect(cubeDistance(i.a.cube, i.b.cube), equals(i.r), reason: "cubeDistance(${i.a.cube}, ${i.b.cube}) != ${i.r}");
        expect(cubeDistance(i.a.cube + d, i.b.cube + d), equals(i.r), reason: "cubeDistance(${i.a.cube + d}, ${i.b.cube + d}) != ${i.r}");
        expect(i.a.distanceTo(i.b), equals(i.r), reason: "${i.a}.distanceTo(${i.b}) != ${i.r}");
      }
    });
    test('distance', () {
      var d = Hex(12, -7, -5);
      var nbrs = d.neighbors();
      expect(nbrs.length, equals(6));
      expect({...nbrs}.length, equals(6));
      nbrs.forEach((n) {
        expect(d.distanceTo(n), equals(1), reason: "cubeDistance($d, $n) != 1");
      });
    });
    test('id', () {
      var d = Hex(12, -7, -5);
      var items = d.neighbors().toList();
      items.add(d);
      items.forEach((n) {
        String id = n.id;
        print(id);
        expect(id, isNotNull);
        expect(id, isNotEmpty);
        expect(id, equals(n.id));
        Hex h = Hex.fromId(id);
        expect(h, equals(n));
      });
    });
  });
}

class _Set<A, B, R> {
  final A a;
  final B b;
  final R r;
  _Set(this.a, this.b, this.r);

  @override
  String toString() {
    return '$a && $b => $r';
  }
}

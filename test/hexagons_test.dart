import 'dart:math';

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
    test('coordinates', () {
      var d = Hex(12, -7, -5);
      for (int a = 0; a < 100; a++) {
        var h = d.randomHexInArea(20);
        expect(h, isNotNull);
        {
          // some default
          var o = h.toOffset();
          expect(Hex.fromOffset(o), equals(h));
        }
        {
          // oddR is default
          var o = h.toOffset();
          expect(Hex.fromOffset(o, GridLayout.oddR), equals(h));
        }
        {
          // oddR is default
          var o = h.toOffset(GridLayout.oddR);
          expect(Hex.fromOffset(o), equals(h));
        }
        for (var clazz in GridLayout.values) {
          // explicit class
          var o = h.toOffset(clazz);
          expect(Hex.fromOffset(o, clazz), equals(h));
        }
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
        expect(id, isNotNull);
        expect(id, isNotEmpty);
        expect(id, equals(n.id));
        Hex h = Hex.fromId(id);
        expect(h, equals(n));
      });
    });
    test('offset', () {
      var d = Hex(1, 7, -8);
      var items = d.neighbors().toList();
      items.add(d);
      items.forEach((n) {
        Offset o = n.toOffset();
        expect(o, isNotNull);
        expect(o, equals(n.toOffset()));
        Hex h = Hex.fromOffset(o);
        expect(h, equals(n));
      });
    });
    test('randomShape', () {
      var d = Hex.zero();
      var h = d.randomHexInArea(10);
      for (int a = 1; a < 100; a++) {
        var shape = h.randomShape(a);
        expect(shape.length, equals(a));
        expect({...shape}.length, equals(a));
      }
    });
    test('pathStraight', () {
      var d = Hex.zero();
      var ring = d.ring(10);
      var h = ring[Random().nextInt(ring.length)];
      int distance = d.distanceTo(h);
      var path = d.pathTo(h, (Hex h, Hex n) => 1)!;
      expect(path.length, equals(distance + 1));
    });
    test('pathCosts', () {
      var d = Hex(1, 0, -1);
      var t = Hex(-9, 9, 0);
      int minDistance = d.distanceTo(t);
      // "even" hex is wall
      bool forbiddenHex(Hex h) => h.cube.r.abs() % 2 == 0 && h.cube.q.abs() % 2 == 0;
      var path = d.pathTo(t, (Hex movingFrom, Hex movingTo) => forbiddenHex(movingTo) ? double.infinity : 1)!;
      expect(path.length, greaterThanOrEqualTo(minDistance + 1));
      for (var o in path) {
        expect(forbiddenHex(o), isFalse);
      }
    });
    test('pathAround', () {
      var c = Hex.zero();
      var a = Hex(-10, 10, 0);
      var b = Hex(10, -10, 0);
      int distanceToCenter = a.distanceTo(c);
      var wall = c.ring(9);
      bool forbiddenHex(Hex h) => wall.contains(h);
      var path = a.pathTo(b, (Hex movingFrom, Hex movingTo) => forbiddenHex(movingTo) ? double.infinity : 1)!;
      for (var o in path) {
        expect(forbiddenHex(o), isFalse);
        // we are running in circle around the wall
        expect(o.distanceTo(c), equals(distanceToCenter));
      }
    });
    test('pathUnreachable', () {
      var c = Hex.zero();
      var a = Hex(-10, 10, 0);
      var wall = c.ring(9);
      bool forbiddenHex(Hex h) => wall.contains(h);
      var path = a.pathTo(c, (Hex movingFrom, Hex movingTo) => forbiddenHex(movingTo) ? double.infinity : 1);
      expect(path, isNull);
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

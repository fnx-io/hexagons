import 'dart:math';

import 'package:hex_toolkit/hex_toolkit.dart';
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
        TestSet(Hex(0, 0, 0), Hex(0, 0, 0), 0),
        TestSet(Hex(0, 0, 0), Hex(0, 0, 0).randomNeighbor(), 1),
        TestSet(Hex(2, -2, -0), Hex(2, -2, -0).randomNeighbor(), 1),
        TestSet(
            Hex(2, -2, -0),
            Hex(2, -2, -0).neighbors().first.neighbors().first,
            2), // sousede zacinaji vzdy stejnym smerem
        TestSet(Hex(-1, -3, 4), Hex(-3, 4, -1), 7),
      ];
      var d = Cube(12, -7, -5);
      for (var i in testSets) {
        // print("Testing $i");
        expect(cubeDistance(i.a.cube, i.b.cube), equals(i.r),
            reason: "cubeDistance(${i.a.cube}, ${i.b.cube}) != ${i.r}");
        expect(cubeDistance(i.a.cube + d, i.b.cube + d), equals(i.r),
            reason: "cubeDistance(${i.a.cube + d}, ${i.b.cube + d}) != ${i.r}");
        expect(i.a.distanceTo(i.b), equals(i.r),
            reason: "${i.a}.distanceTo(${i.b}) != ${i.r}");
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
          // POINTY_TOP is default
          var o = h.toOffset();
          expect(
              Hex.fromOffset(o, gridLayout: GridLayout.POINTY_TOP), equals(h));
        }
        {
          // POINTY_TOP is default
          var o = h.toOffset(gridLayout: GridLayout.POINTY_TOP);
          expect(Hex.fromOffset(o), equals(h));
        }
        for (var clazz in GridLayout.values) {
          // explicit class
          var o = h.toOffset(gridLayout: clazz);
          expect(Hex.fromOffset(o, gridLayout: clazz), equals(h));
        }
      }
    });
    test('distance', () {
      var d = Hex(12, -7, -5);
      var nbrs = d.neighbors();
      expect(nbrs.length, equals(6));
      expect({...nbrs}.length, equals(6));
      for (var n in nbrs) {
        expect(d.distanceTo(n), equals(1), reason: "cubeDistance($d, $n) != 1");
      }
    });
    test('id', () {
      Random rnd = Random();
      for (int a = 0; a < 100; a++) {
        int max = 10e8.toInt();
        var r = rnd.nextInt(max) - max ~/ 2;
        var q = rnd.nextInt(max) - max ~/ 2;
        var n = Hex(r, q, -r - q);
        String id = n.id;
        expect(id, isNotNull);
        expect(id, isNotEmpty);
        expect(id, equals(n.id));
        Hex h = Hex.fromId(id);
        expect(h, equals(n));
      }
    });
    test('offset', () {
      var d = Hex(1, 7, -8);
      var items = d.neighbors().toList();
      items.add(d);
      for (var n in items) {
        GridOffset o = n.toOffset();
        expect(o, isNotNull);
        expect(o, equals(n.toOffset()));
        Hex h = Hex.fromOffset(o);
        expect(h, equals(n));
      }
    });
    test('randomShape', () {
      var d = Hex.zero();
      var h = d.randomHexInArea(10);
      var spreads = [0.0, 0.2, 0.5, 0.9, 1.0];
      for (int a = 1; a < 100; a++) {
        for (var c in spreads) {
          var shape = h.randomShape(a, spread: c);
          expect(shape.length, equals(a));
          expect({...shape}.length, equals(a));
        }
      }
    });
    test('pathStraight', () {
      var d = Hex.zero();
      var ring = d.ring(10).toList();
      var h = ring[Random().nextInt(ring.length)];
      int distance = d.distanceTo(h);
      var path = d.cheapestPathTo(h)!;
      expect(path.path.length, equals(distance + 1));
      expect(path.from, d);
      expect(path.to, h);
      expect(path.path.first, d);
      expect(path.path.last, h);
      // and in this case also:
      expect(path.totalCost.round(), equals(distance));
    });
    test('pathAroundWalls', () {
      var d = Hex(1, 0, -1);
      var t = Hex(-9, 9, 0);
      int minDistance = d.distanceTo(t);
      // "even" hex is wall
      bool forbiddenHex(Hex h) =>
          h.cube.r.abs() % 2 == 0 && h.cube.q.abs() % 2 == 0;
      var path = d.cheapestPathTo(t,
          costFunction: (Hex movingFrom, Hex movingTo) =>
              forbiddenHex(movingTo) ? double.infinity : 1)!;
      expect(path.path.length, greaterThanOrEqualTo(minDistance + 1));
      for (var o in path.path) {
        expect(forbiddenHex(o), isFalse);
      }
    });
    test('pathCosts', () {
      var from = Hex(0, 0, 0);
      var a = Hex(1, -1, 0);
      var b = Hex(1, 0, -1);
      var to = Hex(2, -1, -1);

      double costOfA = 3;
      double cost(Hex f, Hex t) {
        if (t == a) return costOfA;
        if (t == b) return 2;
        if (t == to) return 1;
        if (t == from) return 1;
        return 2;
      }

      {
        costOfA = 3;
        var path = from.cheapestPathTo(to, costFunction: cost)?.path;
        expect(path, isNotNull);
        expect(path!.length, equals(3));
        expect(path[0], equals(from));
        expect(path[1], equals(b));
        expect(path[2], equals(to));
      }
      {
        costOfA = 1;
        var path = from.cheapestPathTo(to, costFunction: cost)?.path;
        expect(path, isNotNull);
        expect(path!.length, equals(3));
        expect(path[0], equals(from));
        expect(path[1], equals(a));
        expect(path[2], equals(to));
      }
      {
        costOfA = 3;
        var path = to.cheapestPathTo(from, costFunction: cost)?.path;
        expect(path, isNotNull);
        expect(path!.length, equals(3));
        expect(path[0], equals(to));
        expect(path[1], equals(b));
        expect(path[2], equals(from));
      }
      {
        costOfA = 1;
        var path = to.cheapestPathTo(from, costFunction: cost)?.path;
        expect(path, isNotNull);
        expect(path!.length, equals(3));
        expect(path[0], equals(to));
        expect(path[1], equals(a));
        expect(path[2], equals(from));
      }
    });
    test('pathAround', () {
      var c = Hex.zero();
      var a = Hex(-10, 10, 0);
      var b = Hex(10, -10, 0);
      int distanceToCenter = a.distanceTo(c);
      var wall = c.ring(9);
      bool forbiddenHex(Hex h) => wall.contains(h);
      var path = a.cheapestPathTo(b,
          costFunction: (Hex movingFrom, Hex movingTo) =>
              forbiddenHex(movingTo) ? double.infinity : 1)!;
      for (var o in path.path) {
        expect(forbiddenHex(o), isFalse);
        // we are running in circle around the wall
        expect(o.distanceTo(c), equals(distanceToCenter));
      }
    });
    test('pathMountains', () {
      var c = Hex.zero();
      var a = Hex(-5, 5, 0);
      var b = Hex(5, -5, 0);
      var wall = c.ring(4);
      bool expensiveHex(Hex h) => wall.contains(h);
      var path = a.cheapestPathTo(b,
          costFunction: (Hex movingFrom, Hex movingTo) =>
              expensiveHex(movingTo) ? 100 : 1)!;
      for (var o in path.path) {
        // mountains can be passed, but are expensive, so should be avoided
        expect(expensiveHex(o), isFalse);
      }
    });
    test('line', () {
      Hex a = Hex(-10, 10, 0);
      Hex b = Hex(10, -10, 0);
      List<Hex> line = a.line(b).toList();
      expect(line.length, equals(21));
      expect(line.first, equals(a));
      expect(line.last, equals(b));
    });
    test('segments', () {
      Hex a = Hex(-10, 10, 0);
      Hex b = Hex(10, -10, 0);
      List<Hex> line = a.line(b).toList();
      {
        var segements = segmentsIterator(line, 2).toList();
        expect(segements.length, equals(20));
        expect(segements.first, equals([a, Hex(-9, 9, 0)]));
        expect(segements.last, equals([Hex(9, -9, 0), b]));
        for (int a = 0; a < 19; a++) {
          expect(segements[a], equals([line[a], line[a + 1]]));
        }
      }
      {
        for (int a = 2; a < 10; a++) {
          var segements = segmentsIterator(line, a);
          expect(segements.length, equals(line.length - a + 1));
          for (var s in segements) {
            expect(s.length, equals(a));
          }
        }
      }
    });
    test('pathUnreachable', () {
      var c = Hex.zero();
      var a = Hex(-10, 10, 0);
      var wall = c.ring(9);
      bool forbiddenHex(Hex h) => wall.contains(h);
      var path = a.cheapestPathTo(c,
          maximumDistanceFromTo: 13,
          costFunction: (Hex movingFrom, Hex movingTo) =>
              forbiddenHex(movingTo) ? double.infinity : 1);
      expect(path, isNull);
    });
    test('pixelCenters', () {
      var sizes = [1.0, 2.0, pi, 10.0, 100.0];
      var hexes = Hex.zero().ring(10).toList();
      hexes.shuffle();
      hexes = hexes.take(20).toList();
      for (var layout in GridLayout.values) {
        for (var size in sizes) {
          for (var d in hexes) {
            PixelPoint center = d.centerPoint(size, gridLayout: layout);
            Hex invert = Hex.fromPixelPoint(center, size, gridLayout: layout);
            expect(invert, equals(d));
          }
        }
      }
    });
    test('pixelsCca', () {
      var inRadius = sqrt(3) / 2;
      var sizes = [1.0, 2.0, pi, 10.0, 100.0];
      var hexes = Hex.zero().ring(10).toList();
      hexes.shuffle();
      hexes = hexes.take(20).toList();
      for (var layout in GridLayout.values) {
        for (var size in sizes) {
          for (var d in hexes) {
            PixelPoint center = d.centerPoint(size, gridLayout: layout);
            double inradius = size * inRadius;
            // random points within hex
            for (int a = 0; a < 50; a++) {
              double randomAngle = Random().nextDouble() * pi * 2;
              double randomX = center.x +
                  cos(randomAngle) * inradius * Random().nextDouble();
              double randomY = center.y +
                  sin(randomAngle) * inradius * Random().nextDouble();
              PixelPoint randomInnerPoint = PixelPoint(randomX, randomY);
              Hex invert = Hex.fromPixelPoint(randomInnerPoint, size,
                  gridLayout: layout);
              expect(invert, equals(d));
            }
            // vertices computed with non-zero padding
            var innerVertices =
                d.vertices(size, gridLayout: layout, padding: 0.00001);
            for (var innerVertex in innerVertices) {
              Hex invert =
                  Hex.fromPixelPoint(innerVertex, size, gridLayout: layout);
              expect(invert, equals(d));
            }
            // center of any pair of vertices should be inside the hex
            for (int a = 0; a < innerVertices.length; a++) {
              for (int b = a + 1; b < innerVertices.length; b++) {
                PixelPoint centerOfPair =
                    innerVertices[a].centerWith(innerVertices[b]);
                Hex invert =
                    Hex.fromPixelPoint(centerOfPair, size, gridLayout: layout);
                expect(invert, equals(d));
              }
            }
          }
        }
      }
    });
    test('vertices', () {
      var sizes = [1.0, 2.0, pi, 10.0, 100.0];
      var hexes = Hex.zero().ring(10).toList();
      hexes.shuffle();
      hexes = hexes.take(20).toList();
      for (var layout in GridLayout.values) {
        for (var size in sizes) {
          // We don't use the hex from hexes, just need to run this code multiple times
          for (int i = 0; i < hexes.length; i++) {
            var d = Hex.zero();
            var vertices = d.vertices(size, gridLayout: layout);
            var c = d.centerPoint(size, gridLayout: layout);
            expect(vertices.length, equals(6));
            for (var vertex in vertices) {
              // should be on circle around the center
              expect(vertex.distanceTo(c), closeTo(size, 0.0001));
            }
            for (int a = 0; a < 5; a++) {
              expect(vertices[a].distanceTo(vertices[a + 1]),
                  closeTo(size, 0.0001));
            }
          }
        }
      }
    });

    test('rotateAround', () {
      var center = Hex.zero();
      var hex = Hex(3, 0, -3);

      // Test rotation by 0 steps (no change)
      expect(hex.rotateAround(center, 0), equals(hex));

      // Test rotation by 1 step (60 degrees)
      expect(hex.rotateAround(center, 1), equals(Hex(0, 3, -3)));

      // Test rotation by 2 steps (120 degrees)
      expect(hex.rotateAround(center, 2), equals(Hex(-3, 3, 0)));

      // Test rotation by 3 steps (180 degrees)
      expect(hex.rotateAround(center, 3), equals(Hex(-3, 0, 3)));

      // Test rotation by 4 steps (240 degrees)
      expect(hex.rotateAround(center, 4), equals(Hex(0, -3, 3)));

      // Test rotation by 5 steps (300 degrees)
      expect(hex.rotateAround(center, 5), equals(Hex(3, -3, 0)));

      // Test rotation by 6 steps (360 degrees, back to original)
      expect(hex.rotateAround(center, 6), equals(hex));

      // Test rotation with non-zero center
      var nonZeroCenter = Hex(1, 1, -2);
      var hexToRotate = Hex(4, 1, -5);

      // Rotate by 1 step
      var rotated = hexToRotate.rotateAround(nonZeroCenter, 1);

      // Verify that distance is preserved
      expect(hexToRotate.distanceTo(nonZeroCenter),
          equals(rotated.distanceTo(nonZeroCenter)));

      // Verify that rotating 6 times brings us back to the original
      var fullRotation = hexToRotate;
      for (int i = 0; i < 6; i++) {
        fullRotation = fullRotation.rotateAround(nonZeroCenter, 1);
      }
      expect(fullRotation, equals(hexToRotate));
    });

    test('interpolate', () {
      var start = Hex.zero();
      var end = Hex(6, 0, -6);

      // Test t = 0 (should be start)
      expect(start.interpolate(end, 0), equals(start));

      // Test t = 1 (should be end)
      expect(start.interpolate(end, 1), equals(end));

      // Test t = 0.5 (should be halfway)
      expect(start.interpolate(end, 0.5), equals(Hex(3, 0, -3)));

      // Test with different easing functions
      var quarter = start.interpolate(end, 0.5, Easing.easeInQuad);
      var threeQuarters = start.interpolate(end, 0.5, Easing.easeOutQuad);

      // easeInQuad should be less than linear at t=0.5
      expect(quarter.distanceTo(start), lessThan(3));

      // easeOutQuad should be more than linear at t=0.5
      expect(threeQuarters.distanceTo(start), greaterThan(3));

      // Test that interpolation preserves the cube constraint (q + r + s = 0)
      var interpolated = start.interpolate(end, 0.3);
      expect(interpolated.cube.q + interpolated.cube.r + interpolated.cube.s,
          equals(0));
    });
  });
}

class TestSet<A, B, R> {
  final A a;
  final B b;
  final R r;
  TestSet(this.a, this.b, this.r);

  @override
  String toString() {
    return '$a && $b => $r';
  }
}

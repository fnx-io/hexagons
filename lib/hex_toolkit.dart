library hex_toolkit;

import 'dart:collection';
import 'dart:math';

part 'model/api.dart';
part 'model/coordinates.dart';
part 'model/graph.dart';
part 'model/hex.dart';
part 'model/id.dart';
part 'model/path.dart';
part 'model/util.dart';

var _r = Random();

/// This global function allows you to enforce repeatable random results within this library. You should set this seed only once and before first the 'random' method call.
void setRandomSeed(int seed) {
  _r = Random(seed);
}

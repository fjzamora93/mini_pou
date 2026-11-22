import 'entities/defense_map_entity.dart';

/// A [MapRoute] measured for constant-speed travel: distance -> position.
class RoutePath {
  RoutePath(MapRoute route) : points = route.points {
    assert(points.length >= 2, 'A route needs at least two points');
    var acc = 0.0;
    _cumulative.add(0);
    for (var i = 1; i < points.length; i++) {
      acc += points[i - 1].distanceTo(points[i]);
      _cumulative.add(acc);
    }
  }

  final List<MapPoint> points;
  final _cumulative = <double>[];

  double get length => _cumulative.last;

  /// Position after travelling [distance] from the start (clamped to ends).
  MapPoint positionAt(double distance) {
    if (distance <= 0) return points.first;
    if (distance >= length) return points.last;
    var i = 1;
    while (_cumulative[i] < distance) {
      i++;
    }
    final a = points[i - 1], b = points[i];
    final seg = _cumulative[i] - _cumulative[i - 1];
    final t = seg == 0 ? 0.0 : (distance - _cumulative[i - 1]) / seg;
    return MapPoint(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
  }
}

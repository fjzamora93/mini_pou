import 'dart:math' as math;

/// A point in map pixels (origin top-left of the map image).
class MapPoint {
  const MapPoint(this.x, this.y);

  final double x;
  final double y;

  double distanceTo(MapPoint other) =>
      math.sqrt(math.pow(x - other.x, 2) + math.pow(y - other.y, 2));

  @override
  bool operator ==(Object other) =>
      other is MapPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'MapPoint($x, $y)';
}

/// Polyline enemies follow, from spawn (usually off-map) to the exit.
class MapRoute {
  const MapRoute(this.name, this.points);

  final String name;
  final List<MapPoint> points;
}

/// Static description of a level: image, walkable routes and where the pet
/// may stand. Data only; generated maps live in `maps/`.
class DefenseMap {
  const DefenseMap({
    required this.image,
    required this.width,
    required this.height,
    required this.cellSize,
    required this.routes,
    required this.placementGrid,
  });

  /// Flame image-cache key (relative to `assets/images/`).
  final String image;
  final int width;
  final int height;
  final int cellSize;
  final List<MapRoute> routes;

  /// One string per row of cells: `#` = grass (placeable), anything else not.
  final List<String> placementGrid;

  int get columns => placementGrid.first.length;
  int get rows => placementGrid.length;

  bool isGrassCell(int col, int row) =>
      row >= 0 &&
      row < rows &&
      col >= 0 &&
      col < columns &&
      placementGrid[row].codeUnitAt(col) == 0x23; // '#'

  /// Whether a pet whose footprint is a circle of [radius] centred on [p]
  /// stands entirely on grass: every cell the circle touches must be grass.
  bool canPlace(MapPoint p, {required double radius}) {
    final c0 = ((p.x - radius) / cellSize).floor();
    final c1 = ((p.x + radius) / cellSize).floor();
    final r0 = ((p.y - radius) / cellSize).floor();
    final r1 = ((p.y + radius) / cellSize).floor();
    for (var r = r0; r <= r1; r++) {
      for (var c = c0; c <= c1; c++) {
        // Closest point of the cell to the centre decides if it's touched.
        final nx = p.x.clamp(c * cellSize, (c + 1) * cellSize - 1e-6);
        final ny = p.y.clamp(r * cellSize, (r + 1) * cellSize - 1e-6);
        final dx = nx - p.x, dy = ny - p.y;
        if (dx * dx + dy * dy > radius * radius) continue;
        if (!isGrassCell(c, r)) return false;
      }
    }
    return true;
  }
}

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

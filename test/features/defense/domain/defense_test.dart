import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pou/features/defense/domain/defense_map.dart';
import 'package:mini_pou/features/defense/domain/defense_rules.dart';
import 'package:mini_pou/features/defense/domain/maps/jungle_camp.dart';

void main() {
  group('DefenseRules', () {
    test('speed level goes up by one every 10 seconds', () {
      expect(DefenseRules.speedLevel(0), 0);
      expect(DefenseRules.speedLevel(9.99), 0);
      expect(DefenseRules.speedLevel(10), 1);
      expect(DefenseRules.speedLevel(25), 2);
    });

    test('enemy speed grows linearly with the level', () {
      const base = DefenseBalance.baseEnemySpeed;
      expect(DefenseRules.enemySpeed(0), base);
      expect(
        DefenseRules.enemySpeed(20),
        closeTo(base * (1 + 2 * DefenseBalance.speedStepIncrease), 1e-9),
      );
      expect(DefenseRules.speedMultiplier(30), closeTo(1.6, 1e-9));
    });
  });

  group('RoutePath', () {
    const route = MapRoute('l', [
      MapPoint(0, 0),
      MapPoint(10, 0),
      MapPoint(10, 10),
    ]);

    test('measures length and interpolates by distance', () {
      final path = RoutePath(route);
      expect(path.length, 20);
      expect(path.positionAt(5), const MapPoint(5, 0));
      expect(path.positionAt(15), const MapPoint(10, 5));
    });

    test('clamps outside the route', () {
      final path = RoutePath(route);
      expect(path.positionAt(-3), const MapPoint(0, 0));
      expect(path.positionAt(99), const MapPoint(10, 10));
    });
  });

  group('jungle camp map', () {
    const map = jungleCampMap;
    const r = DefenseBalance.petFootprintRadius;

    test('grid covers the image', () {
      expect(map.columns * map.cellSize, lessThanOrEqualTo(map.width));
      expect(map.rows * map.cellSize, lessThanOrEqualTo(map.height));
      expect(
        map.placementGrid.every((row) => row.length == map.columns),
        isTrue,
      );
    });

    test('open grass accepts the pet', () {
      expect(map.canPlace(const MapPoint(1000, 540), radius: r), isTrue);
      expect(map.canPlace(const MapPoint(60, 580), radius: r), isTrue);
    });

    test('path, sand clearings, buildings and off-map are rejected', () {
      expect(
        map.canPlace(const MapPoint(700, 430), radius: r),
        isFalse,
      ); // path
      expect(
        map.canPlace(const MapPoint(500, 220), radius: r),
        isFalse,
      ); // sand
      expect(
        map.canPlace(const MapPoint(1040, 260), radius: r),
        isFalse,
      ); // hut
      expect(map.canPlace(const MapPoint(-50, 500), radius: r), isFalse);
    });

    test('a pet can never stand on any route', () {
      for (final route in map.routes) {
        final path = RoutePath(route);
        for (var d = 0.0; d <= path.length; d += 8) {
          final p = path.positionAt(d);
          expect(
            map.canPlace(p, radius: r),
            isFalse,
            reason: '${route.name} at $p',
          );
        }
      }
    });

    test('routes start and end outside the map', () {
      bool outside(MapPoint p) =>
          p.x < 0 || p.y < 0 || p.x > map.width || p.y > map.height;
      for (final route in map.routes) {
        expect(outside(route.points.first), isTrue, reason: route.name);
        expect(outside(route.points.last), isTrue, reason: route.name);
      }
    });
  });
}

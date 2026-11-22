import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../domain/defense_rules.dart';
import '../../../domain/entities/defense_map_entity.dart';

/// Pulsing tint over every spot where the pet may stand. Shown only while
/// the player is choosing where to place it.
class PlacementOverlay extends Component {
  PlacementOverlay({required this.map}) : super(priority: 50000);

  final DefenseMapEntity map;
  late final Path _path;
  double _time = 0;

  final _fill = Paint();

  @override
  Future<void> onLoad() async {
    _path = Path();
    final s = map.cellSize.toDouble();
    for (var r = 0; r < map.rows; r++) {
      for (var c = 0; c < map.columns; c++) {
        final centre = MapPoint((c + 0.5) * s, (r + 0.5) * s);
        if (map.canPlace(centre, radius: DefenseBalance.petFootprintRadius)) {
          _path.addRect(Rect.fromLTWH(c * s, r * s, s, s));
        }
      }
    }
  }

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    final a = 0.18 + 0.1 * math.sin(_time * 3);
    _fill.color = const Color(0xFF7CFF6B).withValues(alpha: a);
    canvas.drawPath(_path, _fill);
  }
}

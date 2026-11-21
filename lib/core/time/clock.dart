import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of "now". Always UTC so persisted timestamps are immune to
/// timezone / DST changes between sessions.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now().toUtc();

/// Overridable in tests to simulate the passage of time.
final clockProvider = Provider<Clock>((ref) => systemClock);

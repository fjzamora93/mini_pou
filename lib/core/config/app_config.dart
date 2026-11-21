/// App-wide technical knobs (not game balance: that lives in each feature's
/// domain layer).
abstract final class AppConfig {
  /// How often the live simulation advances while the app is in foreground.
  static const tickInterval = Duration(seconds: 1);

  /// Minimum time between two disk writes while state keeps changing.
  static const saveThrottle = Duration(seconds: 3);
}

import 'package:flutter/scheduler.dart';

/// Runs [fn] now, or at the end of the frame if Flutter is mid-build.
///
/// GameWidget may run `update()` while Flutter is building (e.g. on window
/// resize), and notifying widgets/providers in that phase throws
/// "setState() called during build". Every signal leaving a Flame game
/// goes through here.
void runOutsideBuild(VoidCallback fn) {
  final scheduler = SchedulerBinding.instance;
  if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks) {
    scheduler.addPostFrameCallback((_) => fn());
  } else {
    fn();
  }
}

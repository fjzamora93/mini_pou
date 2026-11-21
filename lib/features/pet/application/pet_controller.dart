import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/time/clock.dart';
import '../data/local_pet_repository.dart';
import '../domain/pet.dart';
import '../domain/pet_repository.dart';
import '../domain/pet_rules.dart';
import '../domain/pet_species.dart';

final petControllerProvider = AsyncNotifierProvider<PetController, Pet>(
  PetController.new,
);

/// Orchestrates the pet: loads it, applies offline decay, runs the live tick,
/// translates player intents into [PetRules] calls and persists the result.
class PetController extends AsyncNotifier<Pet> {
  late PetRepository _repository;
  late Clock _clock;

  Timer? _ticker;
  Timer? _pendingSave;
  AppLifecycleListener? _lifecycle;

  @override
  Future<Pet> build() async {
    _repository = ref.watch(petRepositoryProvider);
    _clock = ref.watch(clockProvider);

    // Registered before any await so nothing leaks if we're disposed while
    // loading. Ticks are no-ops until the first value exists. No save on
    // dispose: the only dispose path is `reset()`, which must not re-persist.
    _lifecycle = AppLifecycleListener(
      onResume: _onResume,
      onInactive: _flushSave,
      onPause: _onPause,
      onDetach: _flushSave,
    );
    _startTicker();
    ref.onDispose(() {
      _stopTicker();
      _pendingSave?.cancel();
      _pendingSave = null;
      _lifecycle?.dispose();
      _lifecycle = null;
    });

    final now = _clock();
    final saved = await _repository.load();
    // Offline catch-up: same rules as live ticks, applied from lastUpdatedAt.
    final pet = saved == null
        ? Pet.newborn(name: 'Blob', now: now)
        : PetRules.advanceTo(saved, now);
    await _repository.save(pet);
    return pet;
  }

  // --- Player intents --------------------------------------------------------

  void feed() => _apply(PetRules.feed);
  void toggleSleep() => _apply(PetRules.toggleSleep, saveNow: true);
  void clean() => _apply(PetRules.clean);
  void cuddle() => _apply(PetRules.cuddle);
  void rewardCatch() => _apply(PetRules.rewardCatch);
  void finishMinigame() => _apply(PetRules.finishMinigame, saveNow: true);
  void changeSpecies(PetSpecies species) =>
      _apply((pet) => PetRules.changeSpecies(pet, species), saveNow: true);

  /// Debug helper: wipe the save and hatch a new pet.
  Future<void> reset() async {
    await _repository.clear();
    ref.invalidateSelf();
  }

  // --- Internals ---------------------------------------------------------------

  /// Brings the pet up to "now" first, then applies [action]. This guarantees
  /// actions always operate on a fresh state regardless of tick timing.
  void _apply(Pet Function(Pet) action, {bool saveNow = false}) {
    final current = state.value;
    if (current == null) return;
    final next = action(PetRules.advanceTo(current, _clock()));
    if (next == current) return;
    state = AsyncData(next);
    saveNow ? _flushSave() : _scheduleSave();
  }

  void _tick() => _apply((pet) => pet);

  void _startTicker() {
    _ticker ??= Timer.periodic(AppConfig.tickInterval, (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _onResume() {
    _tick(); // catches up the time spent in background
    _startTicker();
  }

  void _onPause() {
    _stopTicker();
    _flushSave();
  }

  /// Throttled save: at most one write every [AppConfig.saveThrottle].
  void _scheduleSave() {
    _pendingSave ??= Timer(AppConfig.saveThrottle, _flushSave);
  }

  void _flushSave() {
    _pendingSave?.cancel();
    _pendingSave = null;
    final pet = state.value;
    if (pet != null) unawaited(_repository.save(pet));
  }
}

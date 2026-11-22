import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/time/clock.dart';
import '../../pet_species/domain/pet_species.dart';
import '../data/local_pet_repository.dart';
import '../domain/entities/pet_roster_entity.dart';
import '../domain/entities/pet_status_entity.dart';
import '../domain/pet_repository.dart';
import '../domain/pet_status_rules.dart';
import '../domain/roster_rules.dart';

final petControllerProvider =
    AsyncNotifierProvider<PetController, PetRosterEntity>(PetController.new);

/// Orchestrates every raised pet: loads the roster, applies offline decay to
/// the active pet, runs its live tick, translates player intents into
/// [PetStatusRules] / [RosterRules] calls and auto-saves every change.
class PetController extends AsyncNotifier<PetRosterEntity> {
  late PetRepository _repository;
  late Clock _clock;

  Timer? _ticker;
  Timer? _pendingSave;
  AppLifecycleListener? _lifecycle;

  @override
  Future<PetRosterEntity> build() async {
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
    // Nothing raised yet: the UI asks for a first species and a name.
    if (saved == null) return PetRosterEntity.empty;
    // Offline catch-up (active pet only; resting pets are frozen): same
    // rules as live ticks, applied from lastUpdatedAt.
    final roster = RosterRules.updateActiveStatus(
      saved,
      (status) => PetStatusRules.advanceTo(status, now),
    );
    await _repository.save(roster);
    return roster;
  }

  // --- Player intents --------------------------------------------------------

  void feed() => _applyToActive(PetStatusRules.feed);
  void toggleSleep() =>
      _applyToActive(PetStatusRules.toggleSleep, saveNow: true);
  void clean() => _applyToActive(PetStatusRules.clean);
  void cuddle() => _applyToActive(PetStatusRules.cuddle);

  /// Raises a brand-new pet of [species] named [name] (level 0) and makes it
  /// the active one. Returns why the name was rejected, or `null` on success.
  PetNameError? adopt(PetSpecies species, String name) {
    final roster = state.value;
    if (roster == null || !RosterRules.canAdopt(roster, species)) return null;
    final error = RosterRules.validateName(roster, name);
    if (error != null) return error;
    final now = _clock();
    _set(
      RosterRules.adopt(
        _advanceActive(roster, now),
        species: species,
        name: name,
        now: now,
      ),
      saveNow: true,
    );
    return null;
  }

  /// Goes back to an already raised pet; the current one starts resting.
  void switchTo(String petId) {
    final roster = state.value;
    if (roster == null) return;
    final now = _clock();
    _set(
      RosterRules.switchTo(_advanceActive(roster, now), petId, now),
      saveNow: true,
    );
  }

  /// Experience earned by pet [petId] (e.g. enemies it defeated).
  void awardXp(String petId, int amount) {
    final roster = state.value;
    if (roster == null) return;
    _set(RosterRules.awardXp(roster, petId, amount));
  }

  /// PetEntity [petId] got tired by fighting (e.g. one shot fired).
  void spendEnergy(String petId, double amount) {
    final roster = state.value;
    if (roster == null) return;
    _set(RosterRules.spendEnergy(roster, petId, amount));
  }

  /// Debug helper: wipe the save (every raised pet).
  Future<void> reset() async {
    await _repository.clear();
    ref.invalidateSelf();
  }

  // --- Internals ---------------------------------------------------------------

  /// Brings the active pet's status up to "now" first, then applies
  /// [action]. Actions always operate on a fresh state regardless of ticks.
  void _applyToActive(
    PetStatusEntity Function(PetStatusEntity) action, {
    bool saveNow = false,
  }) {
    final roster = state.value;
    if (roster == null) return;
    final now = _clock();
    _set(
      RosterRules.updateActiveStatus(
        roster,
        (status) => action(PetStatusRules.advanceTo(status, now)),
      ),
      saveNow: saveNow,
    );
  }

  PetRosterEntity _advanceActive(PetRosterEntity roster, DateTime now) =>
      RosterRules.updateActiveStatus(
        roster,
        (s) => PetStatusRules.advanceTo(s, now),
      );

  void _set(PetRosterEntity next, {bool saveNow = false}) {
    if (next == state.value) return;
    state = AsyncData(next);
    saveNow ? _flushSave() : _scheduleSave();
  }

  void _tick() => _applyToActive((pet) => pet);

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
    final roster = state.value;
    if (roster != null) unawaited(_repository.save(roster));
  }
}

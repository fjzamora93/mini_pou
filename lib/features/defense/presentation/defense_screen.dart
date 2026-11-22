import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared_features/pet_skills/domain/pet_progression.dart';
import '../../../shared_features/pet_species/presentation/widgets/bird_frame.dart';
import '../../../shared_features/pet_status/application/pet_controller.dart';
import '../../../shared_features/pet_status/domain/entities/pet_entity.dart';
import '../../../shared_features/pet_status/domain/entities/pet_roster_entity.dart';
import '../../../shared_features/pet_status/domain/pet_status_balance.dart';
import '../domain/entities/defense_map_entity.dart';
import '../domain/maps/jungle_camp.dart';
import 'game/defense_game.dart';
import 'game/defense_hud_state.dart';

/// Tower-defense run with every pet the player has raised. Landscape while
/// open; the exit button is always available. XP earned by each pet goes
/// straight to [PetController], which auto-saves it.
class DefenseScreen extends ConsumerStatefulWidget {
  const DefenseScreen({super.key, this.map = jungleCampMap});

  final DefenseMapEntity map;

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const DefenseScreen());

  @override
  ConsumerState<DefenseScreen> createState() => _DefenseScreenState();
}

class _DefenseScreenState extends ConsumerState<DefenseScreen> {
  late final DefenseGame _game;

  @override
  void initState() {
    super.initState();
    unawaited(Flame.device.setLandscape());
    final controller = ref.read(petControllerProvider.notifier);
    _game = DefenseGame(
      map: widget.map,
      onEnemyKilledBy: (petId) =>
          controller.awardXp(petId, PetProgression.xpPerEnemy),
      onPetFired: (petId) =>
          controller.spendEnergy(petId, PetStatusBalance.energyPerShot),
    );
    ref.listenManual<AsyncValue<PetRosterEntity>>(petControllerProvider, (
      _,
      next,
    ) {
      final roster = next.value;
      if (roster != null) _game.pets = roster.pets;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _game.disposeNotifiers();
    unawaited(Flame.device.setPortrait());
    super.dispose();
  }

  void _exit() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petControllerProvider).value?.pets ?? const [];
    return Scaffold(
      backgroundColor: const Color(0xFF26301E),
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          SafeArea(
            child: ValueListenableBuilder<DefenseHudState>(
              valueListenable: _game.hud,
              builder: (context, hud, _) => _Hud(
                hud: hud,
                pets: pets,
                onSelect: _game.selectPet,
                onExit: _exit,
                onRestart: _game.restart,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.hud,
    required this.pets,
    required this.onSelect,
    required this.onExit,
    required this.onRestart,
  });

  final DefenseHudState hud;
  final List<PetEntity> pets;
  final ValueChanged<String> onSelect;
  final VoidCallback onExit;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 8,
          top: 8,
          child: IconButton.filledTonal(
            tooltip: 'Salir',
            icon: const Icon(Icons.close),
            onPressed: onExit,
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Wrap(
            spacing: 6,
            children: [
              _Chip(icon: Icons.favorite, text: '${hud.lives}'),
              _Chip(icon: Icons.bolt, text: '${hud.kills}'),
              _Chip(icon: Icons.timer, text: '${hud.seconds}s'),
              _Chip(
                icon: Icons.speed,
                text: 'x${hud.speedMultiplier.toStringAsFixed(1)}',
              ),
            ],
          ),
        ),
        if (!hud.gameOver)
          Align(
            alignment: Alignment.bottomCenter,
            child: _PetBar(hud: hud, pets: pets, onSelect: onSelect),
          ),
        if (hud.gameOver)
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¡Te han superado!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enemigos derrotados: ${hud.kills} · '
                      'Tiempo: ${hud.seconds}s',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: onExit,
                          child: const Text('Salir'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: onRestart,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(text),
          ],
        ),
      ),
    );
  }
}

/// Raised pets available for the run. The selected one is placed by the next
/// tap on the map; placed pets are marked and can't be placed again.
class _PetBar extends StatelessWidget {
  const _PetBar({
    required this.hud,
    required this.pets,
    required this.onSelect,
  });

  final DefenseHudState hud;
  final List<PetEntity> pets;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hint = hud.selectedId != null
        ? 'Toca una zona verde para colocar a la mascota elegida'
        : 'Todas tus mascotas están en el mapa';
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hint, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final pet in pets)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _PetTile(
                          pet: pet,
                          placed: hud.placedIds.contains(pet.id),
                          selected: hud.selectedId == pet.id,
                          scheme: scheme,
                          onTap: () => onSelect(pet.id),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetTile extends StatelessWidget {
  const _PetTile({
    required this.pet,
    required this.placed,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  final PetEntity pet;
  final bool placed;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Opacity(
      opacity: placed ? 0.45 : 1,
      child: Material(
        color: selected
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: selected
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: placed ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 10, 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BirdFrame(species: pet.species, size: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.name, style: text.labelMedium),
                    Text(
                      '${placed ? 'En el mapa' : 'Nv. ${pet.skills.level}'}'
                      ' · ⚡${pet.status.energy.round()}%',
                      style: text.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

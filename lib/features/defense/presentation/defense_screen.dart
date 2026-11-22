import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';

import '../../pet/domain/pet_species.dart';
import '../domain/defense_map.dart';
import '../domain/maps/jungle_camp.dart';
import 'game/defense_game.dart';
import 'game/defense_hud_state.dart';

/// Tower-defense run with the player's pet. Landscape while open; the exit
/// button is always available and simply leaves (nothing is persisted).
class DefenseScreen extends StatefulWidget {
  const DefenseScreen({
    super.key,
    required this.species,
    this.map = jungleCampMap,
  });

  final PetSpecies species;
  final DefenseMap map;

  static Route<void> route(PetSpecies species) =>
      MaterialPageRoute(builder: (_) => DefenseScreen(species: species));

  @override
  State<DefenseScreen> createState() => _DefenseScreenState();
}

class _DefenseScreenState extends State<DefenseScreen> {
  late final DefenseGame _game;

  @override
  void initState() {
    super.initState();
    unawaited(Flame.device.setLandscape());
    _game = DefenseGame(map: widget.map, species: widget.species);
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
    return Scaffold(
      backgroundColor: const Color(0xFF26301E),
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          SafeArea(
            child: ValueListenableBuilder<DefenseHudState>(
              valueListenable: _game.hud,
              builder: (context, hud, _) =>
                  _Hud(hud: hud, onExit: _exit, onRestart: _game.restart),
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
    required this.onExit,
    required this.onRestart,
  });

  final DefenseHudState hud;
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
        if (!hud.petPlaced)
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text('Toca una zona verde para colocar a tu mascota'),
                ),
              ),
            ),
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

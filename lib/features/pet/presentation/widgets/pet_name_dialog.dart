import 'package:flutter/material.dart';

import '../../../../shared_features/pet_skills/domain/pet_traits.dart';
import '../../../../shared_features/pet_skills/presentation/pet_traits_catalog.dart';
import '../../../../shared_features/pet_species/domain/pet_species.dart';
import '../../../../shared_features/pet_species/presentation/pet_species_catalog.dart';
import '../../../../shared_features/pet_species/presentation/widgets/bird_frame.dart';
import '../../../../shared_features/pet_status/domain/roster_rules.dart';

/// Asks for the name of a new pet. A pet can't be saved without one, so the
/// dialog only closes with a valid name (or when cancelled -> `null`).
///
/// [submit] tries to adopt with the given name and returns why it failed,
/// or `null` on success.
Future<bool> showPetNameDialog(
  BuildContext context, {
  required PetSpecies species,
  required PetNameError? Function(String name) submit,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _PetNameDialog(species: species, submit: submit),
    ) ??
    false;

class _PetNameDialog extends StatefulWidget {
  const _PetNameDialog({required this.species, required this.submit});

  final PetSpecies species;
  final PetNameError? Function(String name) submit;

  @override
  State<_PetNameDialog> createState() => _PetNameDialogState();
}

class _PetNameDialogState extends State<_PetNameDialog> {
  final _controller = TextEditingController();
  PetNameError? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.submit(_controller.text);
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final species = widget.species;
    return AlertDialog(
      title: Text('Nuevo ${species.label.toLowerCase()}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BirdFrame(species: species, size: 96),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              TraitChip.element(species.element),
              TraitChip.type(species.type),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: RosterRules.maxNameLength,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nombre',
              errorText: _error?.message,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          Text(
            'Empezará en el nivel 0.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}

extension PetNameErrorMessage on PetNameError {
  String get message => switch (this) {
    PetNameError.empty => 'Ponle un nombre para poder guardarla',
    PetNameError.tooLong => 'Máximo ${RosterRules.maxNameLength} caracteres',
    PetNameError.taken => 'Ya tienes una mascota con ese nombre',
  };
}

import 'package:flutter/material.dart';

/// Widget simple para mostrar los integrantes del equipo (3 personas).
class TeamInfo extends StatelessWidget {
  final List<String> members;

  const TeamInfo({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'Equipo:',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: members
              .map((m) => Chip(
                    label: Text(m),
                    backgroundColor: Color.alphaBlend(
                      Theme.of(context).colorScheme.secondary.withAlpha(20),
                      Theme.of(context).colorScheme.surface,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

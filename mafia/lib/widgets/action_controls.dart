import 'package:flutter/material.dart';

class ActionControls extends StatelessWidget {
  final String title;
  final List<String> players;
  final List<int> eliminatedPlayers;
  final void Function(int) onSelect;

  const ActionControls({
    super.key,
    required this.title,
    required this.players,
    required this.eliminatedPlayers,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(players.length, (index) {
            return ElevatedButton(
              onPressed:
                  eliminatedPlayers.contains(index)
                      ? null
                      : () => onSelect(index),
              child: Text(players[index]),
            );
          }),
        ),
      ],
    );
  }
}

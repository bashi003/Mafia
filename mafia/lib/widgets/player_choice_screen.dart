import 'package:flutter/material.dart';

class PlayerChoiceScreen extends StatelessWidget {
  final String title;
  final List<String> players;
  final Function(String) onSelect;

  const PlayerChoiceScreen({
    super.key,
    required this.title,
    required this.players,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (_, index) {
          return Card(
            child: ListTile(
              title: Text(players[index]),
              onTap: () => onSelect(players[index]),
            ),
          );
        },
      ),
    );
  }
}

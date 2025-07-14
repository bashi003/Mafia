import 'package:flutter/material.dart';

class PlayerTile extends StatelessWidget {
  final String name;
  final String role;
  final bool revealed;

  const PlayerTile({
    super.key,
    required this.name,
    required this.role,
    this.revealed = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: revealed ? Colors.deepPurple[300] : Colors.grey[800],
      child: Center(
        child: Text(
          revealed ? '$name\n($role)' : name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

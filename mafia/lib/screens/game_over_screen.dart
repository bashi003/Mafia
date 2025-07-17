import 'package:flutter/material.dart';
import 'game_setup_screen.dart';

class GameOverScreen extends StatelessWidget {
  final String winningTeam;

  const GameOverScreen({super.key, required this.winningTeam});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$winningTeam Wins!",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const GameSetupScreen()),
                    (_) => false,
                  );
                },
                child: const Text("Play Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'night_phase_screen.dart';
import 'package:mafia/utils/win_conditions.dart';
import 'game_over_screen.dart';

class GameBeginScreen extends StatelessWidget {
  final List<String> allPlayers;
  final List<String> alivePlayers;
  final Map<String, String> roles;

  const GameBeginScreen({
    super.key,
    required this.allPlayers,
    required this.alivePlayers,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    final winner = checkWinCondition(alivePlayers, roles);
    if (winner != null) {
      return GameOverScreen(winningTeam: winner);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'THE GAME BEGINS',
              style: TextStyle(
                color: Colors.red,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => NightPhaseScreen(
                          allPlayers: allPlayers,
                          alivePlayers: alivePlayers,
                          roles: roles,
                        ),
                  ),
                );
              },
              child: const Text('Proceed to Night Phase'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'night_phase_screen.dart';
import 'game_over_screen.dart';
import 'win_conditions.dart';

class VotingPhaseScreen extends StatefulWidget {
  final List<String> allPlayers;
  final List<String> alivePlayers;
  final Map<String, String> roles;

  const VotingPhaseScreen({
    super.key,
    required this.allPlayers,
    required this.alivePlayers,
    required this.roles,
  });

  @override
  State<VotingPhaseScreen> createState() => _VotingPhaseScreenState();
}

class _VotingPhaseScreenState extends State<VotingPhaseScreen> {
  String? selectedPlayer;
  bool showRole = false;

  void confirmElimination() {
    if (selectedPlayer == null) return;

    final updatedAlive = List<String>.from(widget.alivePlayers);
    updatedAlive.remove(selectedPlayer!);
    final role = widget.roles[selectedPlayer!];

    // Check win condition
    final winner = checkWinCondition(widget.roles, updatedAlive);
    if (winner != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GameOverScreen(winner: winner)),
      );
    } else {
      // No winner, proceed to next night
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => NightPhaseScreen(
                allPlayers: widget.allPlayers,
                alivePlayers: updatedAlive,
                roles: widget.roles,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Vote to eliminate a player",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children:
                    widget.alivePlayers.map((player) {
                      final isSelected = selectedPlayer == player;
                      final showCard = isSelected && showRole;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedPlayer == player) {
                              showRole = !showRole;
                            } else {
                              selectedPlayer = player;
                              showRole = false;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: showCard ? Colors.white : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.red : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child:
                                showCard
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          player,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          widget.roles[player]!,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    )
                                    : Text(
                                      player,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: confirmElimination,
                icon: const Icon(Icons.gavel),
                label: const Text("Confirm Elimination"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

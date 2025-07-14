import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../widgets/player_tile.dart';
import '../widgets/action_controls.dart';
import '../widgets/flip_card.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool showRoles = true;
  bool isNightPhase = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: widget.gameState.nightDurationSeconds),
      () {
        setState(() {
          showRoles = false;
          isNightPhase = true;
        });
      },
    );
  }

  void _selectPlayer(String actionType, int playerIndex) {
    setState(() {
      switch (actionType) {
        case 'mafia':
          widget.gameState.mafiaTarget = playerIndex;
          break;
        case 'doctor':
          widget.gameState.doctorSave = playerIndex;
          break;
      }
    });
  }

  void _resolveNight() {
    setState(() {
      if (widget.gameState.mafiaTarget != widget.gameState.doctorSave) {
        widget.gameState.eliminatedPlayers.add(widget.gameState.mafiaTarget!);
      }
      widget.gameState.history.add(
        'Mafia chose ${widget.gameState.players[widget.gameState.mafiaTarget!]} '
        '| Doctor saved ${widget.gameState.players[widget.gameState.doctorSave!]}',
      );
      widget.gameState.mafiaTarget = null;
      widget.gameState.doctorSave = null;
      isNightPhase = false;
    });
  }

  void _startNextNight() {
    setState(() {
      isNightPhase = true;
      widget.gameState.nightCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.gameState.players;
    final roles = widget.gameState.roles;
    final eliminated = widget.gameState.eliminatedPlayers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mafia Game - Night ${widget.gameState.nightCount}'),
        actions: [
          Icon(
            widget.gameState.soundEnabled ? Icons.volume_up : Icons.volume_off,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          if (showRoles)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return FlipCard(name: players[index], role: roles[index]);
                },
              ),
            )
          else if (isNightPhase)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    ActionControls(
                      title: 'Mafia: Choose a player',
                      players: players,
                      eliminatedPlayers: eliminated,
                      onSelect: (index) => _selectPlayer('mafia', index),
                    ),
                    const Divider(height: 30),
                    ActionControls(
                      title: 'Doctor: Choose someone to save',
                      players: players,
                      eliminatedPlayers: eliminated,
                      onSelect: (index) => _selectPlayer('doctor', index),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          (widget.gameState.mafiaTarget != null &&
                                  widget.gameState.doctorSave != null)
                              ? _resolveNight
                              : null,
                      child: const Text('Confirm Night Outcome'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const Text('Results', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 12),
                    if (widget.gameState.history.isNotEmpty)
                      Text(widget.gameState.history.last),
                    const SizedBox(height: 24),
                    const Text('Eliminated players:'),
                    Wrap(
                      spacing: 10,
                      children:
                          eliminated
                              .map((index) => Chip(label: Text(players[index])))
                              .toList(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _startNextNight,
                      child: const Text('Next Night'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

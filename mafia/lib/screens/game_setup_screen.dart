import 'dart:math';
import 'package:flutter/material.dart';
import 'player_name_input_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  _GameSetupScreenState createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int playerCount = 5;
  int mafiaCount = 1;
  int doctorCount = 1;

  List<String> generateRoles() {
    List<String> roles = [];
    roles.addAll(List.generate(mafiaCount, (_) => 'Mafia'));
    roles.addAll(List.generate(doctorCount, (_) => 'Doctor'));
    int remaining = playerCount - mafiaCount - doctorCount;
    roles.addAll(List.generate(remaining, (_) => 'Villager'));
    return roles;
  }

  void startGame() {
    final roles = generateRoles();
    roles.shuffle();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerNameInputScreen(roles: roles)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int maxMafia = playerCount - 2;
    int maxDoctor = playerCount - mafiaCount - 1;

    return Scaffold(
      appBar: AppBar(title: const Text("Setup Game")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group, size: 90),
            const SizedBox(height: 24),
            Text('Players: $playerCount'),
            Slider(
              activeColor: Colors.black,
              value: playerCount.toDouble(),
              min: 5,
              max: 10,
              divisions: 5,
              label: playerCount.toString(),
              onChanged: (val) {
                setState(() {
                  playerCount = val.toInt();
                  mafiaCount = min(mafiaCount, playerCount - 2);
                  doctorCount = min(doctorCount, playerCount - mafiaCount - 1);
                });
              },
            ),
            Text('Mafia: $mafiaCount'),
            Slider(
              activeColor: Colors.black,
              value: mafiaCount.toDouble(),
              min: 1,
              max: maxMafia.toDouble(),
              divisions: maxMafia,
              label: mafiaCount.toString(),
              onChanged: (val) {
                setState(() {
                  mafiaCount = val.toInt();
                  doctorCount = min(doctorCount, playerCount - mafiaCount - 1);
                });
              },
            ),
            Text('Doctor: $doctorCount'),
            Slider(
              activeColor: Colors.black,
              value: doctorCount.toDouble(),
              min: 1,
              max: maxDoctor.toDouble(),
              divisions: maxDoctor,
              label: doctorCount.toString(),
              onChanged: (val) {
                setState(() {
                  doctorCount = val.toInt();
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: startGame,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Start Game"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

void main() {
  runApp(const MafiaGame());
}

class MafiaGame extends StatelessWidget {
  const MafiaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mafia Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey,
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const GameSetupScreen(),
    );
  }
}

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
            const Icon(Icons.group, size: 80),
            const SizedBox(height: 24),
            Text('Players: $playerCount'),
            Slider(
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

class PlayerNameInputScreen extends StatefulWidget {
  final List<String> roles;
  const PlayerNameInputScreen({super.key, required this.roles});

  @override
  State<PlayerNameInputScreen> createState() => _PlayerNameInputScreenState();
}

class _PlayerNameInputScreenState extends State<PlayerNameInputScreen> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.roles.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void proceed() {
    List<String> names =
        controllers.map((controller) => controller.text.trim()).toList();
    if (names.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter all names")));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => RoleRevealScreen(playerNames: names, roles: widget.roles),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Player Names")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: widget.roles.length,
          itemBuilder:
              (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: 'Player ${i + 1}',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: proceed,
          child: const Text("Continue"),
        ),
      ),
    );
  }
}

class RoleRevealScreen extends StatefulWidget {
  final List<String> playerNames;
  final List<String> roles;
  const RoleRevealScreen({
    super.key,
    required this.playerNames,
    required this.roles,
  });

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int current = 0;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void flipCard() async {
    if (isFront) {
      await _controller.forward(from: 0);
      setState(() => isFront = false);
    } else {
      await _controller.reverse();
      setState(() {
        isFront = true;
        if (current < widget.playerNames.length - 1) {
          current++;
        } else {
          final rolesMap = {
            for (int i = 0; i < widget.playerNames.length; i++)
              widget.playerNames[i]: widget.roles[i],
          };
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => GameBeginScreen(
                    allPlayers: widget.playerNames,
                    roles: rolesMap,
                    alivePlayers: List.from(widget.playerNames),
                  ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.roles[current];
    final name = widget.playerNames[current];

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  double value = _animation.value;
                  bool showFront = value < 0.5;
                  return Transform(
                    transform: Matrix4.rotationY(pi * value),
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10),
                        ],
                      ),
                      child: Container(
                        width: 270,
                        height: 425,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                        child:
                            showFront
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/images/card_back.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Transform(
                                  transform: Matrix4.rotationY(pi),
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/${role.toLowerCase()}.png',
                                          height: 180,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'You are the $role!',
                                          textAlign: TextAlign.center,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.headlineMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFront ? "Tap to reveal" : "Tap to pass",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

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
    // Check win first
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
              onPressed: () {
                Navigator.push(
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

class NightPhaseScreen extends StatefulWidget {
  final List<String> allPlayers;
  final List<String> alivePlayers;
  final Map<String, String> roles;

  const NightPhaseScreen({
    super.key,
    required this.allPlayers,
    required this.alivePlayers,
    required this.roles,
  });

  @override
  State<NightPhaseScreen> createState() => _NightPhaseScreenState();
}

class _NightPhaseScreenState extends State<NightPhaseScreen> {
  final player = AudioPlayer();
  int step = 0;
  String? mafiaTarget;
  String? doctorSave;

  @override
  void initState() {
    super.initState();
    startNightPhase();
  }

  Future<void> startNightPhase() async {
    await player.play(AssetSource('sounds/city_sleep.mp3'));
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    setState(() => step = 1);
    await player.play(AssetSource('sounds/mafia_wake.mp3'));
  }

  void onMafiaSelect(String name) async {
    setState(() {
      mafiaTarget = name;
      step = 2;
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() => step = 3);
    await player.play(AssetSource('sounds/doctor_wake.mp3'));
  }

  void onDoctorSelect(String name) async {
    setState(() {
      doctorSave = name;
      step = 4;
    });

    await player.play(AssetSource('sounds/city_wake.mp3'));
    await Future.delayed(const Duration(seconds: 3));

    String? deadPlayer;
    if (mafiaTarget != doctorSave) {
      deadPlayer = mafiaTarget;
    }

    List<String> updatedAlive = [...widget.alivePlayers];
    if (deadPlayer != null) {
      updatedAlive.remove(deadPlayer);
    }

    // Check win
    final winner = checkWinCondition(updatedAlive, widget.roles);
    if (!mounted) return;

    if (winner != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GameOverScreen(winningTeam: winner)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => MorningRecapScreen(
                mafiaTarget: mafiaTarget,
                doctorSave: doctorSave,
                deadPlayer: deadPlayer,
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
    switch (step) {
      case 0:
        return const _InfoScreen(message: "City is sleeping...");
      case 1:
        return _PlayerChoiceScreen(
          title: "Mafia, choose a player to eliminate",
          players: widget.alivePlayers,
          onSelect: onMafiaSelect,
        );
      case 2:
        return const _InfoScreen(message: "...");
      case 3:
        return _PlayerChoiceScreen(
          title: "Doctor, choose a player to save",
          players: widget.alivePlayers,
          onSelect: onDoctorSelect,
        );
      case 4:
        return const _InfoScreen(message: "City is waking up...");
      default:
        return const SizedBox.shrink();
    }
  }
}

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

  void confirmVote() {
    if (selectedPlayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a player to eliminate")),
      );
      return;
    }

    List<String> updatedAlive = [...widget.alivePlayers];
    updatedAlive.remove(selectedPlayer);

    // Check win
    final winner = checkWinCondition(updatedAlive, widget.roles);
    if (winner != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GameOverScreen(winningTeam: winner)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => GameBeginScreen(
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
      appBar: AppBar(title: const Text("Vote to Eliminate")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            widget.alivePlayers
                .map(
                  (player) => RadioListTile<String>(
                    title: Text(player),
                    value: player,
                    groupValue: selectedPlayer,
                    onChanged: (value) {
                      setState(() => selectedPlayer = value);
                    },
                  ),
                )
                .toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: confirmVote,
          icon: const Icon(Icons.check),
          label: const Text("Confirm Vote"),
        ),
      ),
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final String winningTeam;

  const GameOverScreen({super.key, required this.winningTeam});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$winningTeam Wins!",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text("Return to Start"),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function
String? checkWinCondition(
  List<String> alivePlayers,
  Map<String, String> roles,
) {
  int mafiaCount = alivePlayers.where((p) => roles[p] == 'Mafia').length;
  int villagerCount = alivePlayers.where((p) => roles[p] != 'Mafia').length;

  if (mafiaCount == 0) return 'Villagers';
  if (mafiaCount >= villagerCount) return 'Mafia';
  return null;
}

// Supporting widgets
class _PlayerChoiceScreen extends StatelessWidget {
  final String title;
  final List<String> players;
  final Function(String) onSelect;

  const _PlayerChoiceScreen({
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
        itemBuilder:
            (_, index) => Card(
              child: ListTile(
                title: Text(players[index]),
                onTap: () => onSelect(players[index]),
              ),
            ),
      ),
    );
  }
}

class _InfoScreen extends StatelessWidget {
  final String message;
  const _InfoScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MorningRecapScreen extends StatelessWidget {
  final String? mafiaTarget;
  final String? doctorSave;
  final String? deadPlayer;
  final List<String> allPlayers;
  final List<String> alivePlayers;
  final Map<String, String> roles;

  const MorningRecapScreen({
    super.key,
    required this.mafiaTarget,
    required this.doctorSave,
    required this.deadPlayer,
    required this.allPlayers,
    required this.alivePlayers,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    if (deadPlayer == null) {
      message = "$mafiaTarget was attacked but saved by the Doctor!";
    } else {
      message = "$deadPlayer was eliminated during the night.";
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Morning Recap",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => VotingPhaseScreen(
                          allPlayers: allPlayers,
                          alivePlayers: alivePlayers,
                          roles: roles,
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.gavel),
              label: const Text("Proceed to Voting"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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

  List<String> generateRoles(int count) {
    List<String> dynamicRoles = [];
    dynamicRoles.addAll(List.generate(mafiaCount, (_) => 'Mafia'));
    dynamicRoles.addAll(List.generate(doctorCount, (_) => 'Doctor'));
    int remaining = count - mafiaCount - doctorCount;
    dynamicRoles.addAll(List.generate(remaining, (_) => 'Villager'));
    return dynamicRoles;
  }

  void assignRoles() {
    final roles = generateRoles(playerCount);
    roles.shuffle(Random());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoleRevealScreen(roles: roles)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int maxMafia = playerCount - 2;
    int maxDoctor = playerCount - mafiaCount - 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Game')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group, size: 80, color: Colors.black),
            const SizedBox(height: 24),
            Text(
              'Select Number of Players',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text('Players: $playerCount'),
            Slider(
              activeColor: Colors.black,
              value: playerCount.toDouble(),
              min: 5,
              max: 10,
              divisions: 5,
              label: playerCount.toString(),
              onChanged: (value) {
                setState(() {
                  playerCount = value.toInt();
                  mafiaCount = min(mafiaCount, playerCount - 2);
                  doctorCount = min(doctorCount, playerCount - mafiaCount - 1);
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Mafia: $mafiaCount'),
            Slider(
              activeColor: Colors.black,
              value: mafiaCount.toDouble(),
              min: 1,
              max: maxMafia.toDouble(),
              divisions: max(1, maxMafia),
              label: mafiaCount.toString(),
              onChanged: (value) {
                setState(() {
                  mafiaCount = value.toInt();
                  doctorCount = min(doctorCount, playerCount - mafiaCount - 1);
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Doctor: $doctorCount'),
            Slider(
              activeColor: Colors.black,
              value: doctorCount.toDouble(),
              min: 1,
              max: maxDoctor.toDouble(),
              divisions: max(1, maxDoctor),
              label: doctorCount.toString(),
              onChanged: (value) {
                setState(() {
                  doctorCount = value.toInt();
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: assignRoles,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleRevealScreen extends StatefulWidget {
  final List<String> roles;
  const RoleRevealScreen({super.key, required this.roles});

  @override
  _RoleRevealScreenState createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen>
    with SingleTickerProviderStateMixin {
  int currentPlayer = 0;
  bool isFront = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  String getRoleImage(String role) {
    switch (role) {
      case 'Mafia':
        return 'lib/assets/images/mafia.png';
      case 'Doctor':
        return 'lib/assets/images/doc.png';
      default:
        return 'lib/assets/images/villager.png';
    }
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleTap() async {
    if (isFront) {
      await _controller.forward(from: 0);
      setState(() {
        isFront = false;
      });
    } else {
      // Flip back
      await _controller.reverse();
      setState(() {
        isFront = true;
        if (currentPlayer < widget.roles.length - 1) {
          currentPlayer++;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GameBeginScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String role = widget.roles[currentPlayer];

    return Scaffold(
      appBar: AppBar(title: Text('Player ${currentPlayer + 1}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: handleTap,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  double rotationValue = _animation.value;
                  bool showFront = rotationValue < 0.5;

                  return Center(
                    child: Transform(
                      transform: Matrix4.rotationY(pi * rotationValue),
                      alignment: Alignment.center,
                      child: Container(
                        height: 425,
                        width: 270,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 12),
                          ],
                        ),
                        child:
                            showFront
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'lib/assets/images/card_back.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Transform(
                                  transform: Matrix4.rotationY(pi),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        getRoleImage(role),
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
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFront
                  ? 'Tap to reveal your role'
                  : (currentPlayer < widget.roles.length - 1
                      ? 'Tap to pass to next player'
                      : 'Tap to start the game'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class GameBeginScreen extends StatelessWidget {
  const GameBeginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'THE GAME BEGINS',
          style: TextStyle(
            color: Colors.red,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

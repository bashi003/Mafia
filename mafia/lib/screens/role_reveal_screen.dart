import 'dart:math';
import 'package:flutter/material.dart';
import 'game_begin_screen.dart';

class RoleRevealScreen extends StatefulWidget {
  final Map<String, String> rolesMap;
  final List<String> playerNames;

  const RoleRevealScreen({
    super.key,
    required this.rolesMap,
    required this.playerNames,
  });

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  int currentIndex = 0;

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

  String getRoleImage(String role) {
    switch (role) {
      case 'Mafia':
        return 'assets/images/mafia.png';
      case 'Doctor':
        return 'assets/images/doctor.png';
      default:
        return 'assets/images/villager.png';
    }
  }

  void handleTap() async {
    if (isFront) {
      await _controller.forward(from: 0);
      setState(() {
        isFront = false;
      });
    } else {
      await _controller.reverse();
      setState(() {
        isFront = true;
        if (currentIndex < widget.playerNames.length - 1) {
          currentIndex++;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => GameBeginScreen(
                    allPlayers: widget.playerNames,
                    alivePlayers: List.from(widget.playerNames),
                    roles: widget.rolesMap,
                  ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.playerNames[currentIndex];
    final role = widget.rolesMap[name]!;

    return Scaffold(
      appBar: AppBar(title: Text("Player ${currentIndex + 1}")),
      body: Padding(
        padding: const EdgeInsets.all(10),
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
                                    'assets/images/card_back.png',
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
                  : (currentIndex < widget.playerNames.length - 1
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

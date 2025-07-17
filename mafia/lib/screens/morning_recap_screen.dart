import 'package:flutter/material.dart';
import 'voting_phase_screen.dart';

class MorningRecapScreen extends StatefulWidget {
  final List<String> allPlayers;
  final List<String> alivePlayers;
  final Map<String, String> roles;
  final String? mafiaTarget;
  final String? doctorSave;

  const MorningRecapScreen({
    super.key,
    required this.allPlayers,
    required this.alivePlayers,
    required this.roles,
    required this.mafiaTarget,
    required this.doctorSave,
  });

  @override
  State<MorningRecapScreen> createState() => _MorningRecapScreenState();
}

class _MorningRecapScreenState extends State<MorningRecapScreen>
    with SingleTickerProviderStateMixin {
  late String message;
  String? eliminated;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    if (widget.mafiaTarget == widget.doctorSave) {
      message = "No one was eliminated during the night.";
    } else {
      message = "${widget.mafiaTarget} was eliminated during the night.";
      eliminated = widget.mafiaTarget;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Morning Recap",
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: opacity,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final updatedAlivePlayers = List<String>.from(
                    widget.alivePlayers,
                  );
                  if (eliminated != null) {
                    updatedAlivePlayers.remove(eliminated);
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => VotingPhaseScreen(
                            allPlayers: widget.allPlayers,
                            alivePlayers: updatedAlivePlayers,
                            roles: widget.roles,
                          ),
                    ),
                  );
                },
                child: const Text("Proceed to Voting"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

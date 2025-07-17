import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/player_choice_screen.dart';
import '../widgets/info_screen.dart';
import 'morning_recap_screen.dart';

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
  final AudioPlayer player = AudioPlayer();
  int step = 0;
  String? mafiaTarget;
  String? doctorSave;

  late List<String> mafiaPlayers;
  late String? doctorPlayer;

  @override
  void initState() {
    super.initState();

    mafiaPlayers =
        widget.roles.entries
            .where((entry) => entry.value == 'Mafia')
            .map((entry) => entry.key)
            .toList();

    doctorPlayer =
        widget.roles.entries
            .firstWhere(
              (entry) => entry.value == 'Doctor',
              orElse: () => const MapEntry('', ''),
            )
            .key;

    if (doctorPlayer == '') doctorPlayer = null;

    startNightPhase();
  }

  Future<void> startNightPhase() async {
    try {
      await player.play(AssetSource('sounds/city_sleep.mp3'));
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() => step = 1);
      await player.play(AssetSource('sounds/mafia_wake.mp3'));
    } catch (e) {
      print("Error during night phase: $e");
    }
  }

  void onMafiaSelect(String name) async {
    setState(() {
      mafiaTarget = name;
      step = 2;
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // If Doctor is dead, skip step 3 (Doctor choice)
    if (doctorPlayer == null || !widget.alivePlayers.contains(doctorPlayer)) {
      setState(() => step = 4);
      await player.play(AssetSource('sounds/city_wake.mp3'));
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => MorningRecapScreen(
                allPlayers: widget.allPlayers,
                alivePlayers: widget.alivePlayers,
                roles: widget.roles,
                mafiaTarget: mafiaTarget,
                doctorSave: null,
              ),
        ),
      );
    } else {
      setState(() => step = 3);
      await player.play(AssetSource('sounds/doctor_wake.mp3'));
    }
  }

  void onDoctorSelect(String name) async {
    setState(() {
      doctorSave = name;
      step = 4;
    });

    await player.play(AssetSource('sounds/city_wake.mp3'));
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => MorningRecapScreen(
              allPlayers: widget.allPlayers,
              alivePlayers: widget.alivePlayers,
              roles: widget.roles,
              mafiaTarget: mafiaTarget,
              doctorSave: doctorSave,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return const InfoScreen(message: "City is sleeping...");
      case 1:
        final mafiaChoices =
            widget.alivePlayers
                .where((p) => !mafiaPlayers.contains(p))
                .toList();
        return PlayerChoiceScreen(
          title: "Mafia eleminate a player",
          players: mafiaChoices,
          onSelect: onMafiaSelect,
        );
      case 2:
        return const InfoScreen(message: "...");
      case 3:
        return PlayerChoiceScreen(
          title: "Doctor, choose a player to save",
          players: widget.alivePlayers,
          onSelect: onDoctorSelect,
        );
      case 4:
        return const InfoScreen(message: "City is waking up...");
      default:
        return const SizedBox.shrink();
    }
  }
}

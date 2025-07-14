import 'package:flutter/material.dart';
import '../models/game_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _nightDuration = 3.0;
  bool _soundEnabled = true;

  void _saveSettings(BuildContext context) {
    // This would typically use something like Provider, Riverpod, or passed GameState
    GameState.defaultNightDurationSeconds = _nightDuration.toInt();
    GameState.defaultSoundEnabled = _soundEnabled;

    Navigator.pop(context); // Go back to selection screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Sound'),
                const Spacer(),
                Switch(
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() => _soundEnabled = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Night phase duration'),
                const Spacer(),
                Text('${_nightDuration.toInt()}s'),
              ],
            ),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              label: '${_nightDuration.toInt()}s',
              value: _nightDuration,
              onChanged: (value) {
                setState(() => _nightDuration = value);
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              onPressed: () => _saveSettings(context),
            ),
          ],
        ),
      ),
    );
  }
}

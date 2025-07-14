import 'package:flutter/material.dart';
import 'models/game_state.dart';
import 'screens/player_selection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MafiaGameApp());
}

class MafiaGameApp extends StatelessWidget {
  const MafiaGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mafia Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PlayerSelectionScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/game') {
          final args = settings.arguments as GameState;
          return MaterialPageRoute(builder: (_) => GameScreen(gameState: args));
        }
        return null;
      },
    );
  }
}

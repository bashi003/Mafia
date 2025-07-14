class GameState {
  static int defaultNightDurationSeconds = 3;
  static bool defaultSoundEnabled = true;

  final List<String> players;
  final List<String> roles;
  final List<int> eliminatedPlayers;
  final List<String> history;
  int nightCount;
  int? mafiaTarget;
  int? doctorSave;
  int nightDurationSeconds;
  bool soundEnabled;

  GameState({
    required this.players,
    int? nightDurationSeconds,
    bool? soundEnabled,
  }) : roles = _assignRoles(players.length),
       eliminatedPlayers = [],
       history = [],
       nightCount = 1,
       mafiaTarget = null,
       doctorSave = null,
       nightDurationSeconds =
           nightDurationSeconds ?? defaultNightDurationSeconds,
       soundEnabled = soundEnabled ?? defaultSoundEnabled;

  static List<String> _assignRoles(int count) {
    final List<String> roles = [];
    for (int i = 0; i < count; i++) {
      if (i == 0) {
        roles.add('Mafia');
      } else if (i == 1) {
        roles.add('Doctor');
      } else {
        roles.add('Villager');
      }
    }
    roles.shuffle();
    return roles;
  }
}

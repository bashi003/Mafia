String? checkWinCondition(
  Map<String, String> roles,
  List<String> alivePlayers,
) {
  int mafiaCount = 0;
  int nonMafiaCount = 0;

  for (final player in alivePlayers) {
    if (roles[player] == 'Mafia') {
      mafiaCount++;
    } else {
      nonMafiaCount++;
    }
  }

  if (mafiaCount == 0) {
    return 'Villagers';
  } else if (mafiaCount >= nonMafiaCount) {
    return 'Mafia';
  }

  return null; // No winner yet
}

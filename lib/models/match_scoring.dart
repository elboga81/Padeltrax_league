// lib/models/match_scoring.dart

class MatchScoring {
  final Map<String, SetScore> teamScores = {
    'team1': SetScore(),
    'team2': SetScore(),
  };

  bool isMatchComplete = false;
  String? winner;
}

class SetScore {
  int sets;
  List<int> games;

  SetScore({
    this.sets = 0,
    this.games = const [],
  });

  bool isValidSet(int team1Games, int team2Games) {
    // One team must have at least 6 games
    if (team1Games < 6 && team2Games < 6) return false;

    // Regular set win (6-0 to 6-4)
    if (team1Games == 6 && team2Games <= 4) return true;
    if (team2Games == 6 && team1Games <= 4) return true;

    // 7-5 win
    if (team1Games == 7 && team2Games == 5) return true;
    if (team2Games == 7 && team1Games == 5) return true;

    // 7-6 tiebreak win
    if (team1Games == 7 && team2Games == 6) return true;
    if (team2Games == 7 && team1Games == 6) return true;

    return false;
  }
}

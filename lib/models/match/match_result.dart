import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchOutcome {
  win,
  loss,
  draw;

  bool get isWin => this == MatchOutcome.win;
  bool get isLoss => this == MatchOutcome.loss;
  bool get isDraw => this == MatchOutcome.draw;

  String toDisplayString() {
    switch (this) {
      case MatchOutcome.win:
        return 'Win';
      case MatchOutcome.loss:
        return 'Loss';
      case MatchOutcome.draw:
        return 'Draw';
    }
  }
}

class MatchResult {
  final String matchId;
  final DateTime date;
  final MatchOutcome outcome;
  final int setsWon;
  final int setsLost;
  final int gamesWon;
  final int gamesLost;
  final bool hasPerfectSet;
  final String opponent;
  final double ratingChange;

  const MatchResult({
    required this.matchId,
    required this.date,
    required this.outcome,
    required this.setsWon,
    required this.setsLost,
    required this.gamesWon,
    required this.gamesLost,
    this.hasPerfectSet = false,
    required this.opponent,
    this.ratingChange = 0.0,
  });

  bool get isWin => outcome == MatchOutcome.win;
  bool get isLoss => outcome == MatchOutcome.loss;
  bool get isDraw => outcome == MatchOutcome.draw;

  int get totalGames => gamesWon + gamesLost;
  int get gamesDifference => gamesWon - gamesLost;
  int get setsDifference => setsWon - setsLost;

  double get winPercentage {
    if (totalGames == 0) return 0;
    return (gamesWon / totalGames) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'date': Timestamp.fromDate(date),
      'outcome': outcome.toString(),
      'setsWon': setsWon,
      'setsLost': setsLost,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'hasPerfectSet': hasPerfectSet,
      'opponent': opponent,
      'ratingChange': ratingChange,
    };
  }

  factory MatchResult.fromMap(Map<String, dynamic> map) {
    return MatchResult(
      matchId: map['matchId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      outcome: MatchOutcome.values.firstWhere(
        (e) => e.toString() == map['outcome'],
        orElse: () => MatchOutcome.loss,
      ),
      setsWon: (map['setsWon'] as num).toInt(),
      setsLost: (map['setsLost'] as num).toInt(),
      gamesWon: (map['gamesWon'] as num).toInt(),
      gamesLost: (map['gamesLost'] as num).toInt(),
      hasPerfectSet: map['hasPerfectSet'] as bool? ?? false,
      opponent: map['opponent'] as String,
      ratingChange: (map['ratingChange'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static MatchResult createFromScore({
    required String matchId,
    required int team1Sets,
    required int team2Sets,
    required List<int> team1Games,
    required List<int> team2Games,
    required String opponent,
    double ratingChange = 0.0,
  }) {
    final now = DateTime.now();
    final setsWon = team1Sets;
    final setsLost = team2Sets;
    final gamesWon = team1Games.fold<int>(0, (total, game) => total + game);
    final gamesLost = team2Games.fold<int>(0, (total, game) => total + game);

    MatchOutcome outcome;
    if (team1Sets > team2Sets) {
      outcome = MatchOutcome.win;
    } else if (team1Sets < team2Sets) {
      outcome = MatchOutcome.loss;
    } else {
      outcome = MatchOutcome.draw;
    }

    final hasPerfectSet = team1Games.contains(6) && team2Games.contains(0);

    return MatchResult(
      matchId: matchId,
      date: now,
      outcome: outcome,
      setsWon: setsWon,
      setsLost: setsLost,
      gamesWon: gamesWon,
      gamesLost: gamesLost,
      hasPerfectSet: hasPerfectSet,
      opponent: opponent,
      ratingChange: ratingChange,
    );
  }
}

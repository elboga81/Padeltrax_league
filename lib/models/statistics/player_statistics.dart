import '../match/match_result.dart';
import '../match/achievement.dart';

class PlayerStatistics {
  int wins;
  int losses;
  int draws;
  int setsWon;
  int setsLost;
  int gamesWon;
  int gamesLost;
  List<String> recentMatches;
  List<MatchResult> recentResults;
  double winRate;
  double rating;
  int currentStreak;
  List<double> last10MatchesRating;
  Map<String, int> partnershipMatches;
  Map<String, double> partnershipWinRate;
  List<Achievement> achievements;
  DateTime? lastMatchDate;

  PlayerStatistics({
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.setsWon = 0,
    this.setsLost = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    List<String>? recentMatches,
    List<MatchResult>? recentResults,
    this.winRate = 0.0,
    this.rating = 0.0,
    this.currentStreak = 0,
    List<double>? last10MatchesRating,
    Map<String, int>? partnershipMatches,
    Map<String, double>? partnershipWinRate,
    List<Achievement>? achievements,
    this.lastMatchDate,
  })  : recentMatches = recentMatches ?? [],
        recentResults = recentResults ?? [],
        last10MatchesRating = last10MatchesRating ?? [],
        partnershipMatches = partnershipMatches ?? {},
        partnershipWinRate = partnershipWinRate ?? {},
        achievements = achievements ?? [];

  factory PlayerStatistics.fromMap(Map<String, dynamic>? map) {
    if (map == null) return PlayerStatistics();

    return PlayerStatistics(
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      losses: (map['losses'] as num?)?.toInt() ?? 0,
      draws: (map['draws'] as num?)?.toInt() ?? 0,
      setsWon: (map['setsWon'] as num?)?.toInt() ?? 0,
      setsLost: (map['setsLost'] as num?)?.toInt() ?? 0,
      gamesWon: (map['gamesWon'] as num?)?.toInt() ?? 0,
      gamesLost: (map['gamesLost'] as num?)?.toInt() ?? 0,
      recentMatches: (map['recentMatches'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recentResults: (map['recentResults'] as List<dynamic>?)
              ?.map((e) => MatchResult.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      winRate: (map['winRate'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      last10MatchesRating: (map['last10MatchesRating'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      partnershipMatches: (map['partnershipMatches'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toInt())) ??
          {},
      partnershipWinRate: (map['partnershipWinRate'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toDouble())) ??
          {},
      achievements: (map['achievements'] as List<dynamic>?)
              ?.map((e) => Achievement.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastMatchDate: map['lastMatchDate'] != null
          ? DateTime.parse(map['lastMatchDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'setsWon': setsWon,
      'setsLost': setsLost,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'recentMatches': recentMatches,
      'recentResults': recentResults.map((r) => r.toMap()).toList(),
      'winRate': winRate,
      'rating': rating,
      'currentStreak': currentStreak,
      'last10MatchesRating': last10MatchesRating,
      'partnershipMatches': partnershipMatches,
      'partnershipWinRate': partnershipWinRate,
      'achievements': achievements.map((a) => a.toMap()).toList(),
      'lastMatchDate': lastMatchDate?.toIso8601String(),
    };
  }

  void updateStats(MatchResult result) {
    if (result.isWin) {
      wins++;
      currentStreak = currentStreak > 0 ? currentStreak + 1 : 1;
    } else if (result.isDraw) {
      draws++;
      currentStreak = 0;
    } else {
      losses++;
      currentStreak = currentStreak < 0 ? currentStreak - 1 : -1;
    }

    setsWon += result.setsWon;
    setsLost += result.setsLost;
    gamesWon += result.gamesWon;
    gamesLost += result.gamesLost;

    winRate = totalMatches > 0 ? (wins / totalMatches) * 100 : 0;
    rating += result.ratingChange;

    recentResults.insert(0, result);
    if (recentResults.length > 10) {
      recentResults = recentResults.sublist(0, 10);
    }

    recentMatches.insert(0, result.isWin ? 'W' : (result.isDraw ? 'D' : 'L'));
    if (recentMatches.length > 10) {
      recentMatches = recentMatches.sublist(0, 10);
    }

    last10MatchesRating.insert(0, rating);
    if (last10MatchesRating.length > 10) {
      last10MatchesRating = last10MatchesRating.sublist(0, 10);
    }

    lastMatchDate = DateTime.now();
    _checkAchievements(result);
  }

  void _checkAchievements(MatchResult result) {
    if (currentStreak >= 5) {
      achievements.add(Achievement.createAchievement(
        type: AchievementType.winStreak,
        value: currentStreak,
      ));
    }

    if (wins == 1) {
      achievements.add(Achievement.createAchievement(
        type: AchievementType.firstWin,
      ));
    }

    if (result.hasPerfectSet) {
      achievements.add(Achievement.createAchievement(
        type: AchievementType.perfectSet,
      ));
    }
  }

  void updatePartnershipStats(String partnerName, bool isWin) {
    partnershipMatches.update(
      partnerName,
      (value) => value + 1,
      ifAbsent: () => 1,
    );

    final currentWins = partnershipWinRate[partnerName] ?? 0;
    final totalMatches = partnershipMatches[partnerName] ?? 0;

    if (isWin) {
      partnershipWinRate[partnerName] =
          ((currentWins * totalMatches) + 100) / (totalMatches + 1);
    } else {
      partnershipWinRate[partnerName] =
          (currentWins * totalMatches) / (totalMatches + 1);
    }
  }

  int get totalMatches => wins + losses + draws;
}

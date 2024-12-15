import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'match/match_result.dart';
import 'match/achievement.dart';

class MatchStatistics {
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
  DateTime lastMatchDate;

  // Getters
  int get totalMatches => wins + losses + draws;
  double get gamesWinRate => gamesWon + gamesLost > 0
      ? (gamesWon / (gamesWon + gamesLost)) * 100
      : 0.0;
  double get setsWinRate =>
      setsWon + setsLost > 0 ? (setsWon / (setsWon + setsLost)) * 100 : 0.0;
  bool get hasPlayed => totalMatches > 0;

  MatchStatistics({
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
    DateTime? lastMatchDate,
  })  : recentMatches = recentMatches ?? [],
        recentResults = recentResults ?? [],
        last10MatchesRating = last10MatchesRating ?? [],
        partnershipMatches = partnershipMatches ?? {},
        partnershipWinRate = partnershipWinRate ?? {},
        achievements = achievements ?? [],
        lastMatchDate = lastMatchDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    try {
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
        'lastMatchDate': Timestamp.fromDate(lastMatchDate),
      };
    } catch (e) {
      debugPrint('Error converting MatchStatistics to map: $e');
      rethrow;
    }
  }

  factory MatchStatistics.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MatchStatistics();

    try {
      // Handle recent matches
      List<String> recentMatchesList = [];
      if (map['recentMatches'] != null) {
        recentMatchesList =
            List<String>.from(map['recentMatches'] as List<dynamic>);
      }

      // Handle recent results
      List<MatchResult> recentResultsList = [];
      if (map['recentResults'] != null) {
        recentResultsList = (map['recentResults'] as List<dynamic>)
            .map((e) => MatchResult.fromMap(e as Map<String, dynamic>))
            .toList();
      }

      // Handle ratings history
      List<double> ratingHistory = [];
      if (map['last10MatchesRating'] != null) {
        ratingHistory = (map['last10MatchesRating'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList();
      }

      // Handle partnership matches
      Map<String, int> partnershipMatchesMap = {};
      if (map['partnershipMatches'] != null) {
        partnershipMatchesMap =
            (map['partnershipMatches'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toInt()),
        );
      }

      // Handle partnership win rates
      Map<String, double> partnershipWinRateMap = {};
      if (map['partnershipWinRate'] != null) {
        partnershipWinRateMap =
            (map['partnershipWinRate'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
      }

      // Handle achievements
      List<Achievement> achievementsList = [];
      if (map['achievements'] != null) {
        achievementsList = (map['achievements'] as List<dynamic>)
            .map((e) => Achievement.fromMap(e as Map<String, dynamic>))
            .toList();
      }

      return MatchStatistics(
        wins: (map['wins'] as num?)?.toInt() ?? 0,
        losses: (map['losses'] as num?)?.toInt() ?? 0,
        draws: (map['draws'] as num?)?.toInt() ?? 0,
        setsWon: (map['setsWon'] as num?)?.toInt() ?? 0,
        setsLost: (map['setsLost'] as num?)?.toInt() ?? 0,
        gamesWon: (map['gamesWon'] as num?)?.toInt() ?? 0,
        gamesLost: (map['gamesLost'] as num?)?.toInt() ?? 0,
        recentMatches: recentMatchesList,
        recentResults: recentResultsList,
        winRate: (map['winRate'] as num?)?.toDouble() ?? 0.0,
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
        last10MatchesRating: ratingHistory,
        partnershipMatches: partnershipMatchesMap,
        partnershipWinRate: partnershipWinRateMap,
        achievements: achievementsList,
        lastMatchDate:
            (map['lastMatchDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error creating MatchStatistics from map: $e');
      return MatchStatistics(); // Return default statistics on error
    }
  }

  void updateStats(MatchResult result) {
    try {
      // Update wins/losses/draws
      if (result.isWin) {
        wins++;
        currentStreak = currentStreak > 0 ? currentStreak + 1 : 1;
        recentMatches.insert(0, 'W');
      } else if (result.isDraw) {
        draws++;
        currentStreak = 0;
        recentMatches.insert(0, 'D');
      } else {
        losses++;
        currentStreak = currentStreak < 0 ? currentStreak - 1 : -1;
        recentMatches.insert(0, 'L');
      }

      // Keep only last 5 recent matches
      if (recentMatches.length > 5) {
        recentMatches = recentMatches.sublist(0, 5);
      }

      // Update match stats
      setsWon += result.setsWon;
      setsLost += result.setsLost;
      gamesWon += result.gamesWon;
      gamesLost += result.gamesLost;

      // Update win rate
      winRate = totalMatches > 0 ? (wins / totalMatches) * 100 : 0;

      // Update rating with change
      rating += result.ratingChange;

      // Add to recent results
      recentResults.insert(0, result);
      if (recentResults.length > 10) {
        recentResults = recentResults.sublist(0, 10);
      }

      // Update last match date
      lastMatchDate = DateTime.now();

      // Track rating history
      last10MatchesRating.insert(0, rating);
      if (last10MatchesRating.length > 10) {
        last10MatchesRating = last10MatchesRating.sublist(0, 10);
      }

      // Check for achievements
      _checkForAchievements(result);
    } catch (e) {
      debugPrint('Error updating statistics: $e');
      rethrow;
    }
  }

  void updatePartnershipStats(String partnerName, bool isWin) {
    try {
      partnershipMatches.update(
        partnerName,
        (value) => value + 1,
        ifAbsent: () => 1,
      );

      final wins = partnershipWinRate[partnerName] ?? 0;
      final total = partnershipMatches[partnerName] ?? 0;

      if (isWin) {
        partnershipWinRate[partnerName] = ((wins * total) + 100) / (total + 1);
      } else {
        partnershipWinRate[partnerName] = (wins * total) / (total + 1);
      }

      // Check for partnership achievements
      _checkPartnershipAchievements(partnerName);
    } catch (e) {
      debugPrint('Error updating partnership stats: $e');
      rethrow;
    }
  }

  void _checkForAchievements(MatchResult result) {
    // Win streak achievements
    if (currentStreak >= 5) {
      achievements.add(Achievement.createAchievement(
        type: AchievementType.winStreak,
        value: currentStreak,
      ));
    }

    // First win achievement
    if (wins == 1) {
      achievements.add(Achievement.createAchievement(
        type: AchievementType.firstWin,
      ));
    }

    // Perfect set achievement
    if (result.hasPerfectSet) {
      achievements.add(Achievement.createAchievement(
        type: AchievementType.perfectSet,
      ));
    }
  }

  void _checkPartnershipAchievements(String partnerName) {
    final matchesWithPartner = partnershipMatches[partnerName] ?? 0;
    final winRateWithPartner = partnershipWinRate[partnerName] ?? 0.0;

    // Add partnership-based achievements here
    if (matchesWithPartner >= 10 && winRateWithPartner >= 70) {
      achievements.add(Achievement.createAchievement(
        type: AchievementType.popularPlayer,
      ));
    }
  }

  // Helper method to get form string
  String getFormString() {
    return recentMatches.join('-');
  }

  // Helper method to get rating trend
  double getRatingTrend() {
    if (last10MatchesRating.length < 2) return 0;
    return last10MatchesRating.first - last10MatchesRating.last;
  }
}

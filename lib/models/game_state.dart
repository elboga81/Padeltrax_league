// lib/models/game_state.dart

import 'package:flutter/foundation.dart';
import 'player.dart';
import 'match/match_result.dart';

class GameState extends ChangeNotifier {
  List<Player> players = [];
  List<Map<String, dynamic>> matches = [];

  // Update match score
  void updateMatchScore(
    String matchId,
    String playerKey,
    String scoreType,
    int value,
  ) {
    final matchIndex = int.tryParse(matchId);
    if (matchIndex == null || matchIndex >= matches.length) return;

    var match = matches[matchIndex];
    var scores = match['score'] as Map<String, dynamic>?;
    if (scores == null) return;

    var playerScore = scores[playerKey] as Map<String, dynamic>?;
    if (playerScore == null) return;

    if (playerScore[scoreType] != null) {
      playerScore[scoreType] = value;
      _updatePlayerStats(match, playerKey);
      notifyListeners();
    }
  }

  // Update player stats after a match
  void _updatePlayerStats(Map<String, dynamic> match, String playerKey) {
    try {
      // Safely get player data
      final playerData = match[playerKey] as Map<String, dynamic>?;
      final playerName = playerData?['name'] as String?;
      if (playerName == null) return;

      // Find player
      final player = players.firstWhere(
        (p) => p.name == playerName,
        orElse: () => throw Exception('Player not found'),
      );

      // Safely extract scores
      final scores = match['score'] as Map<String, dynamic>?;
      final playerScore = scores?[playerKey] as Map<String, dynamic>?;
      final opponentKey = playerKey == 'team1' ? 'team2' : 'team1';
      final opponentScore = scores?[opponentKey] as Map<String, dynamic>?;

      if (playerScore == null || opponentScore == null) return;

      // Calculate stats
      final setsWon = playerScore['sets'] as int? ?? 0;
      final setsLost = opponentScore['sets'] as int? ?? 0;
      final playerGames = playerScore['games'] as List<dynamic>? ?? [];
      final opponentGames = opponentScore['games'] as List<dynamic>? ?? [];
      final totalGamesWon =
          playerGames.fold<int>(0, (sum, game) => sum + (game as int? ?? 0));
      final totalGamesLost =
          opponentGames.fold<int>(0, (sum, game) => sum + (game as int? ?? 0));

      // Determine match outcome
      final outcome = setsWon > setsLost
          ? MatchOutcome.win
          : setsWon < setsLost
              ? MatchOutcome.loss
              : MatchOutcome.draw;

      // Check for perfect set
      final hasPerfectSet =
          playerGames.contains(6) && opponentGames.contains(0);

      // Get opponent name
      final opponentData = match[opponentKey] as Map<String, dynamic>?;
      final opponentName = opponentData?['name'] as String? ?? 'Unknown';

      // Create match result
      final result = MatchResult(
        matchId: match['id']?.toString() ?? DateTime.now().toString(),
        date: DateTime.now(),
        outcome: outcome,
        setsWon: setsWon,
        setsLost: setsLost,
        gamesWon: totalGamesWon,
        gamesLost: totalGamesLost,
        hasPerfectSet: hasPerfectSet,
        opponent: opponentName,
      );

      // Update player stats
      player.updateMatchStats(result);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating player stats: $e');
    }
  }

  // Get matches for a specific player
  List<Map<String, dynamic>> getMatchesForPlayer(String playerId) {
    return matches.where((match) {
      // Safely convert team1Players and team2Players to List<String>
      final team1Players = (match['team1Players'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final team2Players = (match['team2Players'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      return team1Players.contains(playerId) || team2Players.contains(playerId);
    }).toList();
  }

  // Get player's team key in a match
  String? _getPlayerTeamKey(Map<String, dynamic> match, String playerId) {
    final team1Players = (match['team1Players'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    if (team1Players.contains(playerId)) return 'team1';

    final team2Players = (match['team2Players'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    if (team2Players.contains(playerId)) return 'team2';

    return null;
  }

  // Get recent matches for a player
  List<Map<String, dynamic>> getRecentMatches(String playerId,
      {int limit = 5}) {
    final playerMatches = getMatchesForPlayer(playerId);
    playerMatches.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime.now();
      final dateB =
          DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    return playerMatches.take(limit).toList();
  }

  // Additional utility methods
  void addMatch(Map<String, dynamic> match) {
    matches.add(match);
    notifyListeners();
  }

  Map<String, dynamic>? getMatch(int index) {
    if (index >= 0 && index < matches.length) {
      return matches[index];
    }
    return null;
  }

  void clearMatches() {
    matches.clear();
    notifyListeners();
  }

  void addPlayer(Player player) {
    if (!players.any((p) => p.id == player.id)) {
      players.add(player);
      notifyListeners();
    }
  }

  void removePlayer(String playerId) {
    players.removeWhere((p) => p.id == playerId);
    notifyListeners();
  }

  Player? getPlayerById(String id) {
    try {
      return players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void updatePlayer(Player updatedPlayer) {
    final index = players.indexWhere((p) => p.id == updatedPlayer.id);
    if (index != -1) {
      players[index] = updatedPlayer;
      notifyListeners();
    }
  }

  List<Player> getPlayersByRank() {
    final sortedPlayers = List<Player>.from(players);
    sortedPlayers.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedPlayers;
  }

  double getPlayerWinRate(String playerId) {
    final playerMatches = getMatchesForPlayer(playerId);
    if (playerMatches.isEmpty) return 0.0;

    final wins = playerMatches.where((match) {
      final playerKey = _getPlayerTeamKey(match, playerId);
      if (playerKey == null) return false;

      final scores = match['score'] as Map<String, dynamic>?;
      if (scores == null) return false;

      final playerScore = scores[playerKey]['sets'] as int? ?? 0;
      final opponentScore =
          scores[playerKey == 'team1' ? 'team2' : 'team1']['sets'] as int? ?? 0;
      return playerScore > opponentScore;
    }).length;

    return (wins / playerMatches.length) * 100;
  }
}

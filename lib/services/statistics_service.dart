import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/match.dart';
import 'firebase_service.dart';

class StatisticsService {
  final FirebaseFirestore _firestore;

  StatisticsService() : _firestore = FirebaseService.instance.firestore;

  Future<void> updateMatchStatistics(Match match) async {
    if (match.status != MatchStatus.completed) return;

    try {
      debugPrint('Updating statistics for match: ${match.id}');
      final batch = _firestore.batch();

      await Future.wait([
        if (match.team1Player1 != null)
          _updatePlayerStatsInBatch(
              batch, match.team1Player1!.id, match, 'team1'),
        if (match.team1Player2 != null)
          _updatePlayerStatsInBatch(
              batch, match.team1Player2!.id, match, 'team1'),
        if (match.team2Player1 != null)
          _updatePlayerStatsInBatch(
              batch, match.team2Player1!.id, match, 'team2'),
        if (match.team2Player2 != null)
          _updatePlayerStatsInBatch(
              batch, match.team2Player2!.id, match, 'team2'),
      ]);

      await batch.commit();
      debugPrint('Successfully updated statistics for match: ${match.id}');
    } catch (e) {
      debugPrint('Error updating match statistics: $e');
      throw Exception('Failed to update match statistics: $e');
    }
  }

  Future<void> _updatePlayerStatsInBatch(
    WriteBatch batch,
    String playerId,
    Match match,
    String team,
  ) async {
    try {
      final playerRef = _firestore.collection('players').doc(playerId);
      final playerDoc = await playerRef.get();

      if (!playerDoc.exists) {
        debugPrint('Player document not found: $playerId');
        return;
      }

      Map<String, dynamic> data = playerDoc.data() ?? {};
      Map<String, dynamic> stats =
          (data['statistics'] as Map<String, dynamic>?) ?? {};
      final String opposingTeam = team == 'team1' ? 'team2' : 'team1';

      // Initial rating logging
      double initialRating = (stats['rating'] as num?)?.toDouble() ?? 0.0;
      debugPrint('Player $playerId - Initial Rating: $initialRating');

      // Game calculations
      List<int> playerGames = List<int>.from(match.score[team]?.games ?? []);
      List<int> opponentGames =
          List<int>.from(match.score[opposingTeam]?.games ?? []);
      int gamesWonTotal = playerGames.fold(0, (sum, game) => sum + game);
      int gamesLostTotal = opponentGames.fold(0, (sum, game) => sum + game);

      // Match outcome determination
      String? matchWinner = match.winner;
      bool isWinner = matchWinner == team;
      bool isDraw = matchWinner == null;

      // Points calculation
      double pointsEarned = 0.15; // Base points for participating
      debugPrint('Base participation points: +0.15');

      if (isWinner) {
        stats['wins'] = (stats['wins'] as int? ?? 0) + 1;
        pointsEarned += 0.9;
        debugPrint('Win bonus: +0.9');
      } else if (isDraw) {
        stats['draws'] = (stats['draws'] as int? ?? 0) + 1;
        pointsEarned += 0.2;
        debugPrint('Draw bonus: +0.2');
      } else {
        stats['losses'] = (stats['losses'] as int? ?? 0) + 1;
        pointsEarned -= 1.0;
        debugPrint('Loss penalty: -1.0');
      }

      // Update match statistics
      stats['setsWon'] =
          (stats['setsWon'] as int? ?? 0) + (match.score[team]?.sets ?? 0);
      stats['setsLost'] = (stats['setsLost'] as int? ?? 0) +
          (match.score[opposingTeam]?.sets ?? 0);
      stats['gamesWon'] = (stats['gamesWon'] as int? ?? 0) + gamesWonTotal;
      stats['gamesLost'] = (stats['gamesLost'] as int? ?? 0) + gamesLostTotal;

      // Update form
      List<String> recentMatches =
          List<String>.from(stats['recentMatches'] as List<dynamic>? ?? []);
      recentMatches.insert(0, isWinner ? 'W' : (isDraw ? 'D' : 'L'));
      if (recentMatches.length > 5) {
        recentMatches = recentMatches.sublist(0, 5);
      }
      stats['recentMatches'] = recentMatches;

      // Update streaks
      int currentStreak = stats['currentStreak'] as int? ?? 0;
      if (isWinner) {
        currentStreak = currentStreak >= 0 ? currentStreak + 1 : 1;
      } else if (isDraw) {
        currentStreak = 0;
      } else {
        currentStreak = currentStreak <= 0 ? currentStreak - 1 : -1;
      }
      stats['currentStreak'] = currentStreak;

      // Calculate win rate
      int totalMatches = (stats['wins'] as int? ?? 0) +
          (stats['losses'] as int? ?? 0) +
          (stats['draws'] as int? ?? 0);
      stats['winRate'] = totalMatches > 0
          ? ((stats['wins'] as int? ?? 0) / totalMatches) * 100
          : 0.0;

      // Update final rating
      stats['rating'] = initialRating + pointsEarned;
      debugPrint('Final Rating: ${stats['rating']} (Change: $pointsEarned)');

      // Update rating history
      List<double> ratingHistory = List<double>.from(
          stats['last10MatchesRating'] as List<dynamic>? ?? []);
      ratingHistory.insert(0, stats['rating'] as double);
      if (ratingHistory.length > 10) {
        ratingHistory = ratingHistory.sublist(0, 10);
      }
      stats['last10MatchesRating'] = ratingHistory;

      // Update partnerships
      _updatePartnershipStats(stats, match, team, playerId, isWinner);

      // Commit updates
      batch.update(playerRef, {
        'statistics': stats,
        'lastMatchDate': FieldValue.serverTimestamp(),
      });

      debugPrint('Added statistics update for player: $playerId');
    } catch (e) {
      debugPrint('Error updating stats for player $playerId: $e');
      throw Exception('Failed to update player statistics: $e');
    }
  }

  void _updatePartnershipStats(Map<String, dynamic> stats, Match match,
      String team, String playerId, bool isWin) {
    try {
      stats['partnershipMatches'] =
          (stats['partnershipMatches'] as Map<String, dynamic>?) ?? {};
      stats['partnershipWinRate'] =
          (stats['partnershipWinRate'] as Map<String, dynamic>?) ?? {};

      String? partnerName;
      if (team == 'team1') {
        partnerName = match.team1Player2?.name;
      } else {
        partnerName = match.team2Player2?.name;
      }

      if (partnerName != null) {
        stats['partnershipMatches'][partnerName] =
            (stats['partnershipMatches'][partnerName] as int? ?? 0) + 1;

        int totalMatches = stats['partnershipMatches'][partnerName] as int;
        double currentWinRate =
            stats['partnershipWinRate'][partnerName] as double? ?? 0.0;

        if (isWin) {
          stats['partnershipWinRate'][partnerName] =
              ((currentWinRate * (totalMatches - 1)) + 100) / totalMatches;
        } else {
          stats['partnershipWinRate'][partnerName] =
              (currentWinRate * (totalMatches - 1)) / totalMatches;
        }
      }
    } catch (e) {
      debugPrint('Error updating partnership stats: $e');
    }
  }
}

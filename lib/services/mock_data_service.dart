import '../models/player.dart';
import '../models/match.dart';
import 'data_service_interface.dart';
import 'package:flutter/foundation.dart';

class MockDataService implements DataServiceInterface {
  final List<Match> _matches = [];
  final List<Player> _players = [
    Player(
      id: "1",
      name: "John Smith",
      rating: 4.5,
      rank: 1,
      profileImage: "assets/images/profile.png",
      createdAt: DateTime.now(),
    ),
    Player(
      id: "2",
      name: "Maria Garcia",
      rating: 4.3,
      rank: 2,
      profileImage: "assets/images/profile.png",
      createdAt: DateTime.now(),
    ),
  ];
  final List<Map<String, dynamic>> _bookings = [];

  @override
  Stream<List<Player>> getPlayersStream() {
    return Stream.value(_players);
  }

  @override
  Future<List<Player>> getAllPlayers() async {
    return _players;
  }

  @override
  Future<void> createBooking(
      String playerId, String day, String timeslot) async {
    _bookings.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'playerId': playerId,
      'day': day,
      'timeslot': timeslot,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getBookingsForDay(String day) {
    return Stream.value(
      _bookings.where((booking) => booking['day'] == day).toList(),
    );
  }

  @override
  Future<void> loadBookingsForPlayer(String playerId) async {
    // In mock service, data is already in memory
    return;
  }

  @override
  Future<void> deletePlayerBookings(String playerId) async {
    _bookings.removeWhere((booking) => booking['playerId'] == playerId);
  }

  @override
  Future<void> createMatch({
    required DateTime date,
    required String time,
    required List<String> team1PlayerIds,
    required List<String> team2PlayerIds,
  }) async {
    final match = Match(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      time: time,
      status: MatchStatus.scheduled,
      players: {
        'team1_player1': _players.firstWhere((p) => p.id == team1PlayerIds[0]),
        'team1_player2': _players.firstWhere((p) => p.id == team1PlayerIds[1]),
        'team2_player1': _players.firstWhere((p) => p.id == team2PlayerIds[0]),
        'team2_player2': _players.firstWhere((p) => p.id == team2PlayerIds[1]),
      },
      score: {
        'team1': Score(sets: 0, games: []),
        'team2': Score(sets: 0, games: []),
      },
      createdAt: DateTime.now(),
    );
    _matches.add(match);
  }

  // Helper method to create a mock match
  Match createMockMatch({
    int availablePlayers = 0,
    String? specificDay,
    String? specificTime,
  }) {
    final playersNeeded = 4 - availablePlayers;
    final Map<String, Player?> matchPlayers = {};

    // Add available players first
    for (var i = 0; i < availablePlayers && i < _players.length; i++) {
      final position = i < 2 ? 'team1_player${i + 1}' : 'team2_player${i - 1}';
      matchPlayers[position] = _players[i];
    }

    // Fill remaining slots with null
    final positions = [
      'team1_player1',
      'team1_player2',
      'team2_player1',
      'team2_player2'
    ];
    for (var position in positions) {
      if (!matchPlayers.containsKey(position)) {
        matchPlayers[position] = null;
      }
    }

    return Match(
      id: 'mock_match_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      time: specificTime ?? 'Later Timeslot',
      status: playersNeeded > 0
          ? MatchStatus.waitingPlayers
          : MatchStatus.scheduled,
      players: matchPlayers,
      score: {
        'team1': Score(sets: 0, games: []),
        'team2': Score(sets: 0, games: []),
      },
      createdAt: DateTime.now(),
      availableSlots: playersNeeded,
    );
  }

  @override
  Stream<List<Match>> getMatchesStream() {
    return Stream.value(_matches);
  }

  @override
  Future<List<Match>> getAllMatches() async {
    return _matches;
  }

  @override
  Future<void> updateMatchScore(
    String matchId,
    String team,
    String type,
    dynamic value,
  ) async {
    final matchIndex = _matches.indexWhere((m) => m.id == matchId);
    if (matchIndex == -1) return;

    final match = _matches[matchIndex];
    final newScore = Map<String, Score>.from(match.score);

    if (type == 'sets') {
      newScore[team] = newScore[team]!.copyWith(sets: value as int);
    } else if (type == 'games') {
      newScore[team] = newScore[team]!.copyWith(games: value as List<int>);
    }

    _matches[matchIndex] = match.copyWith(score: newScore);

    // Update player statistics
    _updatePlayerStats(match, team);
  }

  void _updatePlayerStats(Match match, String team) {
    final isWinner = match.score[team]!.sets >
        match.score[team == 'team1' ? 'team2' : 'team1']!.sets;

    // Update stats for both players on the team
    final player1 = match.players['${team}_player1'];
    final player2 = match.players['${team}_player2'];

    if (player1 != null) {
      _updateSinglePlayerStats(player1, isWinner, match, team);
    }
    if (player2 != null) {
      _updateSinglePlayerStats(player2, isWinner, match, team);
    }
  }

  void _updateSinglePlayerStats(
      Player player, bool isWinner, Match match, String team) {
    final playerIndex = _players.indexWhere((p) => p.id == player.id);
    if (playerIndex == -1) return;

    final updatedPlayer = _players[playerIndex];
    if (isWinner) {
      updatedPlayer.statistics.wins++;
    } else {
      updatedPlayer.statistics.losses++;
    }

    // Update sets and games
    final teamScore = match.score[team]!;
    final opposingScore = match.score[team == 'team1' ? 'team2' : 'team1']!;

    updatedPlayer.statistics.setsWon += teamScore.sets;
    updatedPlayer.statistics.setsLost += opposingScore.sets;

    updatedPlayer.statistics.gamesWon +=
        teamScore.games.fold(0, (sum, game) => sum + game);
    updatedPlayer.statistics.gamesLost +=
        opposingScore.games.fold(0, (sum, game) => sum + game);

    // Update win rate
    final totalMatches =
        updatedPlayer.statistics.wins + updatedPlayer.statistics.losses;
    if (totalMatches > 0) {
      updatedPlayer.statistics.winRate =
          (updatedPlayer.statistics.wins / totalMatches) * 100;
    }

    _players[playerIndex] = updatedPlayer;
  }

  @override
  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    final matchIndex = _matches.indexWhere((m) => m.id == matchId);
    if (matchIndex == -1) return;

    _matches[matchIndex] = _matches[matchIndex].copyWith(status: status);
  }

  @override
  Future<void> loadBookingsForDay(String day) async {
    try {
      debugPrint('Loading bookings for day: $day');
      // In mock service, data is already in memory
      // Just simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error loading bookings for day: $e');
      throw Exception('Failed to load bookings for day: $e');
    }
  }
}
